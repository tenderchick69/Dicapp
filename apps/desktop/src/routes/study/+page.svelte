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

  // Reactive current card from store
  $: currentCard = $studyStore.cards[$studyStore.index] || null;
  $: isActive = $studyStore.cards.length > 0 && $studyStore.index < $studyStore.cards.length;

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
        console.log('%c FREE STUDY FALLBACK TRIGGERED — THESE MUST BE VIRGIN', 'color:magenta;font-size:20px;background:black');
        result = await buildQueueByScope(dataStore, $scopeStore, currentDeckId, {
          dueLimit: 10000,
          newPerDay: 10000,
        });
        cards = result.cards;
        console.log('%c FALLBACK CARDS RAW', 'color:magenta;font-size:16px', cards.map(c => ({
          headword: c.word.headword,
          times_correct: c.scheduling.times_correct,
          is_mastered: c.scheduling.is_mastered
        })));
      }

      if (cards.length === 0) {
        error = 'No cards in this deck';
        loading = false;
        return;
      }

      studyStore.start(cards);

      // ZEN FORENSIC AUDIT - these MUST all be 0
      console.log('%c ZEN SESSION START — THESE MUST ALL BE 0', 'color:lime;font-size:24px;background:black', cards.map(c => ({
        headword: c.word.headword,
        times_correct: c.scheduling.times_correct,
        is_mastered: c.scheduling.is_mastered
      })));

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
    if (!currentCard?.word) return;

    const oldCorrect = currentCard.scheduling.times_correct ?? 0;
    const wasMastered = currentCard.scheduling.is_mastered === 1;

    console.log('%c GRADE START', 'color:yellow', {
      headword: currentCard.word.headword,
      oldCorrect,
      wasMastered,
      gotIt
    });

    const { newCorrect } = await studyStore.grade(gotIt);

    console.log('%c GRADE END', 'color:green', {
      newCorrect,
      willCelebrate: gotIt && oldCorrect === 4 && newCorrect === 5 && !wasMastered
    });

    // Only celebrate if we just reached mastery (exactly 4 → 5) - IRON-CLAD
    const shouldCelebrate = gotIt &&
                            oldCorrect === 4 &&
                            newCorrect === 5 &&
                            !wasMastered &&
                            typeof oldCorrect === 'number';

    console.log('%c CELEBRATION CHECK', 'color:orange;font-size:14px', {
      gotIt,
      oldCorrect,
      newCorrect,
      wasMastered,
      shouldCelebrate
    });

    if (shouldCelebrate) {
      celebrating = true;
      setTimeout(() => {
        celebrating = false;
        showBack = false;
        studyStore.next();
      }, 2800);
    } else {
      showBack = false;
      studyStore.next();
    }
  }

  function exit() {
    studyStore.end();
    goto('/');
  }

  // Graceful session end: redirect home when session inactive or queue empty
  $: if (!loading && !isActive) {
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
  {:else if currentCard}
    <MasteryCelebration active={celebrating} />

    <div class="card-area">
      <CardLevel level={currentCard.scheduling?.times_correct ?? 0}>
        <div class="card">
          <div class="card-front">
            <h1 class="headword">{currentCard.word?.headword ?? 'Loading...'}</h1>
            {#if currentCard.word?.ipa}
              <p class="ipa">{currentCard.word.ipa}</p>
            {/if}
          </div>

          {#if showBack}
            <div class="card-back">
              <p class="definition">{currentCard.word?.definition ?? ''}</p>
              {#if currentCard.word?.example}
                <p class="example">{currentCard.word.example}</p>
              {/if}
              {#if currentCard.word?.gloss_de}
                <p class="gloss">{currentCard.word.gloss_de}</p>
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
