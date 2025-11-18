<script lang="ts">
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import { getDataStore } from '$lib/stores/database';
  import { deckStore } from '$lib/stores/deck';
  import { scopeStore } from '$lib/stores/scope';
  import type { IDataStore } from '@runedeck/data';
  import type { ScheduledWord } from '@runedeck/core/models';
  import Header from '$lib/components/Header.svelte';
  import { ArrowLeft } from 'lucide-svelte';

  let loading = true;
  let error = '';
  let dataStore: IDataStore | null = null;
  let masteredCards: ScheduledWord[] = [];
  let resurrecting: Set<string> = new Set(); // Track cards being brought back

  onMount(async () => {
    try {
      await deckStore.load();
      const currentDeckId = $deckStore.currentDeckId;

      if (!currentDeckId) {
        error = 'No deck selected.';
        loading = false;
        return;
      }

      dataStore = await getDataStore();
      await loadMasteredCards();
      loading = false;
    } catch (err: any) {
      error = err.message;
      loading = false;
    }
  });

  async function loadMasteredCards() {
    if (!dataStore || !$deckStore.currentDeckId) return;

    // Get all cards in deck, filter for mastered
    const allCards = await dataStore.getAllWordsByScope($scopeStore, $deckStore.currentDeckId, 10000);
    masteredCards = allCards.filter(card => card.scheduling.is_mastered === 1);
  }

  async function bringBack(card: ScheduledWord) {
    if (!dataStore || resurrecting.has(card.word.id)) return;

    try {
      resurrecting.add(card.word.id);
      resurrecting = resurrecting; // Trigger reactivity

      // Reset card to new state
      const resetScheduling = {
        ...card.scheduling,
        times_correct: 0,
        is_mastered: 0,
        due_ts: Date.now(),
        is_new: 1,
        interval: 0,
      };

      await dataStore.upsertScheduling(resetScheduling);

      // Remove from mastered list
      masteredCards = masteredCards.filter(c => c.word.id !== card.word.id);

      resurrecting.delete(card.word.id);
      resurrecting = resurrecting;
    } catch (err: any) {
      console.error('Failed to bring back card:', err);
      error = err.message;
      resurrecting.delete(card.word.id);
      resurrecting = resurrecting;
    }
  }

  function goHome() {
    goto('/');
  }
</script>

<Header />

<div class="min-h-screen" style="background: var(--bg); color: var(--fg)">
  <!-- Header -->
  <div class="p-4 flex items-center justify-between" style="border-bottom: 1px solid var(--card-border)">
    <button
      on:click={goHome}
      class="flex items-center gap-2 px-3 py-2 rounded hover:bg-opacity-10"
      style="color: var(--muted); transition: all 0.2s"
    >
      <ArrowLeft size={20} />
      <span>Home</span>
    </button>

    <h1 class="text-2xl font-semibold" style="color: var(--fg)">Graveyard</h1>

    <div class="w-24"></div>
  </div>

  <!-- Content -->
  <div class="max-w-4xl mx-auto p-8">
    {#if loading}
      <div class="text-center py-12">
        <div class="animate-spin rounded-full h-12 w-12 border-b-2 mx-auto mb-4" style="border-color: var(--accent-1)"></div>
        <p style="color: var(--muted)">Loading mastered cards...</p>
      </div>
    {:else if error}
      <div class="bg-red-900/20 border border-red-500/50 rounded-lg p-6">
        <p class="text-red-400">{error}</p>
      </div>
    {:else if masteredCards.length === 0}
      <div class="text-center py-12">
        <div class="mb-4 text-6xl opacity-30">🪦</div>
        <p class="text-lg mb-2" style="color: var(--muted)">No mastered cards yet</p>
        <p class="text-sm" style="color: var(--muted); opacity: 0.7">
          Cards that reach level 5 rest here in eternal peace
        </p>
      </div>
    {:else}
      <div class="mb-6">
        <p class="text-sm" style="color: var(--muted)">
          {masteredCards.length} card{masteredCards.length === 1 ? '' : 's'} at rest
        </p>
      </div>

      <div class="space-y-3">
        {#each masteredCards as card (card.word.id)}
          <div
            class="rounded-lg p-4 flex items-center justify-between"
            style="background: var(--card-bg); border: 1px solid var(--card-border); transition: all 0.2s"
          >
            <div class="flex-1">
              <div class="font-semibold mb-1" style="color: var(--fg); font-family: var(--font-display)">
                {card.word.headword}
              </div>
              <div class="text-sm" style="color: var(--muted)">
                {card.word.definition}
              </div>
            </div>

            <button
              on:click={() => bringBack(card)}
              disabled={resurrecting.has(card.word.id)}
              class="ml-4 px-4 py-2 rounded text-sm font-medium transition-all hover:scale-105 disabled:opacity-50 disabled:cursor-not-allowed"
              style="background: var(--accent-2); color: white"
            >
              {resurrecting.has(card.word.id) ? 'Resurrecting...' : 'Bring Back'}
            </button>
          </div>
        {/each}
      </div>
    {/if}
  </div>
</div>
