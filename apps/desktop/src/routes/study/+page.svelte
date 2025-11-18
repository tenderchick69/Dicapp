<script lang="ts">
  import { onMount, onDestroy } from 'svelte';
  import { goto } from '$app/navigation';
  import { studyStore } from '$lib/stores/study';
  import { deckStore } from '$lib/stores/deck';
  import { scopeStore } from '$lib/stores/scope';
  import { settingsStore } from '$lib/stores/settings';
  import { getDataStore } from '$lib/stores/database';
  import { buildQueueByScope } from '@runedeck/core/queue';
  import CardLevel from '$lib/components/CardLevel.svelte';
  import MasteryCelebration from '$lib/components/MasteryCelebration.svelte';
  import GradeButtons from '$lib/components/GradeButtons.svelte';
  import Header from '$lib/components/Header.svelte';

  let loading = true;
  let error = '';
  let showBack = false;
  let celebrating = false;

  onMount(async () => {
    try {
      // Load deck and build queue
      await deckStore.load();
      const currentDeckId = $deckStore.currentDeckId;

      if (!currentDeckId) {
        error = 'No deck selected';
        loading = false;
        return;
      }

      const dataStore = await getDataStore();
      const config = {
        dueLimit: $settingsStore.dueLimit,
        newPerDay: $settingsStore.newPerDay,
      };

      let result = await buildQueueByScope(dataStore, $scopeStore, currentDeckId, config);
      let cards = result.cards;

      // Free study mode if no cards due
      if (cards.length === 0) {
        result = await buildQueueByScope(dataStore, $scopeStore, currentDeckId, {
          dueLimit: 10000,
          newPerDay: 10000,
        });
        cards = result.cards;
      }

      if (cards.length === 0) {
        error = 'No cards in this deck';
        loading = false;
        return;
      }

      studyStore.startSession(cards);
      loading = false;

      // Keyboard listener
      window.addEventListener('keydown', handleKeyboard);
    } catch (err: any) {
      error = err.message || 'Failed to load study session';
      console.error('Study error:', err);
      loading = false;
    }
  });

  onDestroy(() => {
    window.removeEventListener('keydown', handleKeyboard);
  });

  function handleKeyboard(e: KeyboardEvent) {
    if (e.target instanceof HTMLInputElement || e.target instanceof HTMLTextAreaElement) return;

    if (e.key === ' ' || e.key === 'r' || e.key === 'R') {
      e.preventDefault();
      if (!showBack) reveal();
    } else if (e.key === '1') {
      e.preventDefault();
      if (showBack) grade(false);
    } else if (e.key === '2') {
      e.preventDefault();
      if (showBack) grade(true);
    } else if (e.key === 'Escape') {
      e.preventDefault();
      exit();
    }
  }

  function reveal() {
    showBack = true;
  }

  async function grade(gotIt: boolean) {
    if (!$studyStore.currentCard?.word) return;

    const card = $studyStore.currentCard;
    const wasNotMastered = card.scheduling?.is_mastered === 0;

    await studyStore.gradeCardZen(card.word.id, gotIt);

    // Check if reached mastery
    if (gotIt && wasNotMastered && $studyStore.currentCard?.scheduling?.is_mastered === 1) {
      celebrating = true;
      setTimeout(() => {
        celebrating = false;
        showBack = false;
        studyStore.nextCard();
      }, 3000);
    } else {
      showBack = false;
      studyStore.nextCard();
    }
  }

  function exit() {
    studyStore.endSession();
    goto('/');
  }

  $: if (!loading && !$studyStore.sessionActive) {
    goto('/');
  }
</script>

<Header />

<div class="study-container">
  {#if loading}
    <div class="loading">
      <div class="spinner"></div>
      <p>Loading cards...</p>
    </div>
  {:else if error}
    <div class="error">
      <p>{error}</p>
      <button on:click={exit}>Return Home</button>
    </div>
  {:else if $studyStore.currentCard}
    <MasteryCelebration active={celebrating} />

    <div class="card-area">
      <CardLevel level={$studyStore.currentCard?.scheduling?.times_correct ?? 0}>
        <div class="card">
          <div class="card-front">
            <h1 class="headword">{$studyStore.currentCard?.word?.headword ?? 'Loading...'}</h1>
            {#if $studyStore.currentCard?.word?.ipa}
              <p class="ipa">{$studyStore.currentCard.word.ipa}</p>
            {/if}
          </div>

          {#if showBack}
            <div class="card-back">
              <p class="definition">{$studyStore.currentCard?.word?.definition ?? ''}</p>
              {#if $studyStore.currentCard?.word?.example}
                <p class="example">{$studyStore.currentCard.word.example}</p>
              {/if}
              {#if $studyStore.currentCard?.word?.gloss_de}
                <p class="gloss">{$studyStore.currentCard.word.gloss_de}</p>
              {/if}
            </div>
          {/if}
        </div>
      </CardLevel>
    </div>

    <div class="controls">
      {#if !showBack}
        <button class="reveal-btn" on:click={reveal}>
          Reveal (Space)
        </button>
      {:else}
        <div class="grade-buttons">
          <GradeButtons onGrade={grade} disabled={false} />
        </div>
      {/if}
    </div>

    <p class="hint">Space=Reveal • 1=Didn't Get It • 2=Got It • Esc=Exit</p>
  {/if}
</div>

<style>
  .study-container {
    min-height: 100vh;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 2rem;
    gap: 2rem;
  }

  .loading, .error {
    text-align: center;
  }

  .spinner {
    width: 3rem;
    height: 3rem;
    border: 3px solid rgba(191, 167, 106, 0.2);
    border-top-color: var(--accent-1);
    border-radius: 50%;
    animation: spin 1s linear infinite;
    margin: 0 auto 1rem;
  }

  @keyframes spin {
    to { transform: rotate(360deg); }
  }

  .error p {
    color: #e74c3c;
    margin-bottom: 1rem;
  }

  .error button {
    padding: 0.75rem 2rem;
    background: var(--accent-1);
    color: var(--bg);
    border: none;
    border-radius: 0.5rem;
    cursor: pointer;
  }

  .card-area {
    perspective: 1000px;
  }

  .card {
    min-width: 400px;
    max-width: 600px;
    padding: 3rem 2rem;
    text-align: center;
  }

  .headword {
    font-size: 3rem;
    font-family: var(--font-display);
    color: var(--fg);
    margin-bottom: 0.5rem;
  }

  .ipa {
    font-size: 1.25rem;
    color: var(--muted);
    font-family: var(--font-mono);
  }

  .card-back {
    margin-top: 2rem;
    padding-top: 2rem;
    border-top: 2px solid var(--card-border);
  }

  .definition {
    font-size: 1.5rem;
    color: var(--fg);
    margin-bottom: 1rem;
  }

  .example {
    font-size: 1.1rem;
    color: var(--muted);
    font-style: italic;
    margin-bottom: 0.75rem;
  }

  .gloss {
    font-size: 1rem;
    color: var(--accent-2);
  }

  .controls {
    display: flex;
    justify-content: center;
    align-items: center;
  }

  .reveal-btn {
    padding: 1.5rem 4rem;
    font-size: 1.5rem;
    font-weight: 600;
    background: var(--accent-2);
    color: white;
    border: none;
    border-radius: 3rem;
    cursor: pointer;
    transition: all 0.2s;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
  }

  .reveal-btn:hover {
    transform: scale(1.05);
    box-shadow: 0 6px 16px rgba(0, 0, 0, 0.3);
  }

  .grade-buttons {
    width: 100%;
    max-width: 800px;
  }

  .hint {
    color: var(--muted);
    font-size: 0.875rem;
    opacity: 0.7;
    text-align: center;
  }

  @media (max-width: 768px) {
    .card {
      min-width: 300px;
      padding: 2rem 1rem;
    }

    .headword {
      font-size: 2rem;
    }

    .reveal-btn {
      padding: 1rem 2rem;
      font-size: 1.25rem;
    }
  }
</style>
