<script lang="ts">
  import { onMount, onDestroy } from 'svelte';
  import { goto } from '$app/navigation';
  import { studyStore, isComplete } from '$lib/stores/study';
  import { getDataStore } from '$lib/stores/database';
  import { deckStore } from '$lib/stores/deck';
  import { scopeStore } from '$lib/stores/scope';
  import { settingsStore } from '$lib/stores/settings';
  import { buildQueueByScope } from '@runedeck/core/queue';
  import { gradeCardZen } from '@runedeck/core/scheduler';
  import { uuid } from '@runedeck/core/models';
  import type { ScheduledWord } from '@runedeck/core/models';
  import type { IDataStore } from '@runedeck/data';
  import CardLevel from '$lib/components/CardLevel.svelte';
  import MasteryCelebration from '$lib/components/MasteryCelebration.svelte';
  import GradeButtons from '$lib/components/GradeButtons.svelte';
  import Header from '$lib/components/Header.svelte';
  import { ArrowLeft } from 'lucide-svelte';

  let loading = true;
  let error = '';
  let keyboardEnabled = true;
  let dataStore: IDataStore | null = null;
  let freeStudyMode = false;
  let failedQueue: ScheduledWord[] = []; // Cards marked "Didn't Get It" - pushed to end
  let failCounts: Map<string, number> = new Map(); // Track fails per card this session (max 3)
  let navigatingHome = false; // Flag to prevent completion redirect when user clicks Home
  let showMasteryCelebration = false; // Trigger gong + petal when card reaches mastery
  const MAX_FAILS_PER_SESSION = 3;

  onMount(async () => {
    try {
      // Load deck first
      await deckStore.load();
      const currentDeckId = $deckStore.currentDeckId;

      if (!currentDeckId) {
        error = 'No deck selected. Please select a deck first.';
        loading = false;
        return;
      }

      dataStore = await getDataStore();

      // Build study queue: due + new cards (up to daily limit)
      const config = {
        dueLimit: $settingsStore.dueLimit,
        newPerDay: $settingsStore.newPerDay,
      };

      let result = await buildQueueByScope(dataStore, $scopeStore, currentDeckId, config);
      let cards = result.cards;

      // If no cards due, enable free study mode with all cards
      if (cards.length === 0) {
        freeStudyMode = true;
        const freeStudyConfig = {
          dueLimit: 10000,
          newPerDay: 10000,
        };

        result = await buildQueueByScope(dataStore, $scopeStore, currentDeckId, freeStudyConfig);
        cards = result.cards;

        if (cards.length === 0) {
          error = 'No cards in this deck. Add some words to get started!';
          loading = false;
          return;
        }
      }

      studyStore.startSession(cards);
      loading = false;

      // Add keyboard listener
      window.addEventListener('keydown', handleKeyboard);
    } catch (err: any) {
      error = err.message;
      loading = false;
    }
  });

  onDestroy(() => {
    window.removeEventListener('keydown', handleKeyboard);
  });

  function handleKeyboard(e: KeyboardEvent) {
    if (!keyboardEnabled) return;
    if (e.target instanceof HTMLInputElement || e.target instanceof HTMLTextAreaElement) return;

    const key = e.key.toLowerCase();

    if (key === ' ' || key === 'r') {
      e.preventDefault();
      reveal();
    } else if (key === '1') {
      e.preventDefault();
      handleGrade(false); // Didn't Get It
    } else if (key === '2') {
      e.preventDefault();
      handleGrade(true); // Got It
    } else if (key === 'escape') {
      e.preventDefault();
      goHome();
    }
  }

  function reveal() {
    studyStore.reveal();
  }

  async function handleGrade(gotIt: boolean) {
    const state = $studyStore;
    if (!state.session || !state.currentCard || !dataStore) return;
    if (!state.revealed) return; // Must reveal before grading

    try {
      const card = state.currentCard;
      const elapsed = state.session.elapsed();

      // Zen grading: Got It (true) / Didn't Get It (false)
      const newScheduling = gradeCardZen(card.scheduling, gotIt);
      await dataStore.upsertScheduling(newScheduling);

      // Check if card just reached mastery (is_mastered flipped to 1)
      if (gotIt && newScheduling.is_mastered === 1 && card.scheduling.is_mastered === 0) {
        showMasteryCelebration = true;
        // Celebration will auto-hide after 3 seconds
      }

      // Save review (use 2 for "Got It", 1 for "Didn't Get It" for backwards compat)
      await dataStore.addReview({
        id: uuid(),
        word_id: card.word.id,
        ts: Date.now(),
        grade: gotIt ? 2 : 1,
        elapsed_ms: elapsed,
      });

      // Failed card logic: push to end of queue (max 3 fails per card per session)
      if (!gotIt) {
        const currentFails = failCounts.get(card.word.id) || 0;

        if (currentFails < MAX_FAILS_PER_SESSION) {
          // Track this fail
          failCounts.set(card.word.id, currentFails + 1);

          // Push to end of session queue (with updated scheduling)
          const cardForRetry: ScheduledWord = {
            ...card,
            scheduling: newScheduling,
          };
          failedQueue.push(cardForRetry);
        }
        // If >= MAX_FAILS, card sleeps until tomorrow (not re-added)
      }

      // Move to next card
      studyStore.nextCard();

      // Get fresh state after moving to next card
      const currentState = $studyStore;

      // If main queue empty but we have failed cards, add them back
      if (currentState.session && currentState.session.queue.length === 0 && failedQueue.length > 0) {
        studyStore.addCards(failedQueue);
        failedQueue = [];
      }
    } catch (err: any) {
      console.error('Failed to grade card:', err);
      error = err.message;
    }
  }

  function goHome() {
    navigatingHome = true; // Set flag to prevent completion redirect
    studyStore.reset();
    goto('/');
  }

  $: if ($isComplete && !loading && !navigatingHome) {
    setTimeout(() => {
      studyStore.reset();
      goto('/complete');
    }, 500);
  }
</script>

<Header />

<div class="min-h-screen flex flex-col">
  <!-- Free Study Mode Banner -->
  {#if !loading && !error && freeStudyMode}
    <div class="px-6 py-3 text-center" style="background: var(--accent-2); color: var(--bg)">
      <p class="text-sm font-medium">
        Free Study Mode - No cards due, reviewing all deck cards
      </p>
    </div>
  {/if}

  <!-- Progress Header -->
  <div class="p-4 flex items-center justify-between" style="background: var(--bg); border-bottom: 1px solid var(--card-border)">
    <button
      on:click={goHome}
      class="flex items-center gap-2 px-3 py-2 rounded hover:bg-opacity-10"
      style="color: var(--muted); transition: all 0.2s"
    >
      <ArrowLeft size={20} />
      <span>Home</span>
    </button>

    {#if $studyStore.session}
      <div class="flex-1 max-w-md mx-4">
        <div class="flex justify-between text-sm mb-1" style="color: var(--muted)">
          <span>{$studyStore.progress.current} / {$studyStore.progress.total}</span>
          <span>{$studyStore.progress.percent}%</span>
        </div>
        <div class="w-full h-2 rounded-full" style="background: rgba(191, 167, 106, 0.2)">
          <div
            class="h-full rounded-full transition-all duration-300"
            style="width: {$studyStore.progress.percent}%; background: var(--accent-1)"
          ></div>
        </div>
      </div>
    {/if}

    <div class="w-24"></div>
  </div>

  <!-- Main content -->
  <div class="flex-1 flex items-center justify-center p-8">
    {#if loading}
      <div class="text-center">
        <div class="animate-spin rounded-full h-12 w-12 border-b-2 mx-auto mb-4" style="border-color: var(--accent-1)"></div>
        <p style="color: var(--muted)">Loading cards...</p>
      </div>
    {:else if error}
      <div class="text-center max-w-md">
        <div class="bg-red-900/20 border border-red-500/50 rounded-lg p-6 mb-4">
          <p class="text-red-400">{error}</p>
        </div>
        <button
          on:click={goHome}
          class="px-6 py-2 rounded-lg"
          style="background: var(--accent-1); color: var(--bg)"
        >
          Return Home
        </button>
      </div>
    {:else if $studyStore.currentCard}
      <div class="space-y-6">
        <!-- Card with Evolution (CardLevel) -->
        <div class="flex justify-center">
          <CardLevel
            level={$studyStore.currentCard.scheduling.times_correct}
            headword={$studyStore.currentCard.word.headword}
            definition={$studyStore.currentCard.word.definition}
            showFront={!$studyStore.revealed}
          />
        </div>

        <!-- Reveal button -->
        {#if !$studyStore.revealed}
          <div class="flex justify-center">
            <button
              on:click={reveal}
              class="px-8 py-3 rounded-lg font-semibold transition-all hover:scale-105"
              style="background: var(--accent-2); color: white; box-shadow: 0 4px 12px rgba(0,0,0,0.3)"
            >
              Reveal (R)
            </button>
          </div>
        {/if}

        <!-- Grade buttons -->
        {#if $studyStore.revealed}
          <div class="max-w-3xl mx-auto">
            <GradeButtons onGrade={handleGrade} disabled={false} />
          </div>
        {/if}

        <!-- Keyboard hints -->
        <div class="text-center text-xs" style="color: var(--muted); opacity: 0.6">
          Keyboard: Space=Reveal • 1=Didn't Get It • 2=Got It • Esc=Exit
        </div>
      </div>
    {/if}
  </div>
</div>

<!-- Mastery Celebration Overlay -->
{#if showMasteryCelebration}
  <MasteryCelebration onComplete={() => { showMasteryCelebration = false; }} />
{/if}
