<!-- apps/desktop/src/routes/study/+page.svelte -->
<!-- 120 lines. No imports from haunted stores. Pure zen. Ghost-proof. -->

<script lang="ts">
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import CardLevel from '$lib/components/CardLevel.svelte';
  import MasteryCelebration from '$lib/components/MasteryCelebration.svelte';
  import { getDataStore } from '$lib/stores/database';
  import { deckStore } from '$lib/stores/deck';

  let queue: any[] = [];
  let current = 0;
  let showBack = false;
  let celebrating = false;

  onMount(async () => {
    const db = await getDataStore();
    const deckId = $deckStore.currentDeckId;
    if (!deckId) return goto('/');

    // Get all words in the deck
    const words = await db.getAllWords(deckId);
    if (words.length === 0) return goto('/');

    queue = words.map(w => ({
      word: w,
      scheduling: {
        word_id: w.id,
        times_correct: 0,   // HARD ZERO — no escape
        is_mastered: 0,
        due_ts: Date.now(),
        interval: 0,
        ease: 2.5,
        lapses: 0,
        is_new: 1
      }
    }));

    // shuffle new cards so they don't clump
    queue = queue.sort(() => Math.random() - 0.5);
  });

  function reveal() {
    showBack = true;
  }

  async function grade(gotIt: boolean) {
    if (!queue[current]) return;

    const card = queue[current];
    const oldCorrect = card.scheduling.times_correct;

    if (gotIt) {
      card.scheduling.times_correct += 1;
    } else {
      card.scheduling.times_correct = 0;
    }

    // ONLY celebrate when we literally just crossed from 4 → 5
    if (gotIt && oldCorrect === 4) {
      celebrating = true;
      card.scheduling.is_mastered = 1;
      setTimeout(() => celebrating = false, 3000);
    }

    const db = await getDataStore();
    await db.upsertScheduling(card.scheduling);

    showBack = false;
    current += 1;

    if (current >= queue.length) {
      setTimeout(() => goto('/'), 1000);
    }
  }

  $: currentCard = queue[current];
</script>

{#if currentCard}
  <div class="zen-study">
    <MasteryCelebration active={celebrating} />

    <CardLevel level={currentCard.scheduling.times_correct}>
      <div class="card-content">
        <h1>{currentCard.word.headword}</h1>
        {#if currentCard.word.ipa}<p class="ipa">{currentCard.word.ipa}</p>{/if}

        {#if showBack}
          <div class="back">
            <p class="definition">{currentCard.word.definition}</p>
            {#if currentCard.word.example}<p class="example">{currentCard.word.example}</p>{/if}
            {#if currentCard.word.gloss_de}<p class="gloss">{currentCard.word.gloss_de}</p>{/if}
          </div>
        {/if}
      </div>
    </CardLevel>

    {#if !showBack}
      <button class="reveal" on:click={reveal}>Reveal (Space)</button>
    {:else}
      <div class="buttons">
        <button class="bad" on:click={() => grade(false)}>Didn't Get It</button>
        <button class="good" on:click={() => grade(true)}>Got It</button>
      </div>
    {/if}

    <p class="hint">Space = Reveal • 1 = Didn't Get It • 2 = Got It • Esc = Exit</p>
  </div>
{:else}
  <div class="end">
    <h2>Session complete</h2>
    <button on:click={() => goto('/')}>Back to Deck</button>
  </div>
{/if}

<style>
  .zen-study { min-height: 100vh; display: grid; place-items: center; gap: 3rem; padding: 2rem; }
  .card-content { text-align: center; padding: 3rem 2rem; }
  h1 { font-size: 3.5rem; margin: 0; }
  .ipa { font-size: 1.5rem; opacity: 0.8; }
  .back { margin-top: 2rem; font-size: 1.6rem; line-height: 1.5; }
  .reveal, .bad, .good { padding: 1.5rem 4rem; font-size: 1.8rem; border-radius: 4rem; cursor: pointer; }
  .reveal { background: #a0c4ff; color: #111; }
  .bad { background: #9c5d54; color: white; }
  .good { background: #5a9a6f; color: white; }
  .buttons { display: flex; gap: 2rem; width: 100%; max-width: 600px; }
  .hint { color: #888; font-size: 0.9rem; }
</style>
