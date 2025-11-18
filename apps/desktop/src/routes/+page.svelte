<script lang="ts">
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import { getDataStore } from '$lib/stores/database';
  import { deckStore } from '$lib/stores/deck';
  import { scopeStore } from '$lib/stores/scope';
  import { authStore } from '$lib/stores/auth';
  import Header from '$lib/components/Header.svelte';
  import { Compass, LogIn } from 'lucide-svelte';

  let zenStats = {
    total: 0,
    due: 0,
    new: 0,
    mastered: 0,
  };
  let loading = true;

  async function loadStats() {
    try {
      const currentDeckId = $deckStore.currentDeckId;
      if (!currentDeckId) {
        loading = false;
        return;
      }

      const dataStore = await getDataStore();
      const now = Date.now();

      // Get zen stats: due, new, mastered
      const [dueCards, newCards, allCards] = await Promise.all([
        dataStore.getDueByScope($scopeStore, currentDeckId, 10000, now),
        dataStore.getNewByScope($scopeStore, currentDeckId, 10000),
        dataStore.getAllWordsByScope($scopeStore, currentDeckId, 100000)
      ]);

      zenStats = {
        total: allCards.length,
        due: dueCards.length,
        new: newCards.length,
        mastered: allCards.filter(card => card.scheduling.is_mastered === 1).length,
      };

      loading = false;
    } catch (err: any) {
      console.error('Failed to load stats:', err);
      loading = false;
    }
  }

  onMount(async () => {
    await authStore.init();

    // Only load decks/stats if authenticated
    if ($authStore.user) {
      await deckStore.load();
      await loadStats();
    } else {
      loading = false;
    }

    // Check for import success param and clear it
    if ($page.url.searchParams.get('imported') === 'success') {
      // Stats will be refreshed by reactive statement below
      // Clear the URL param
      const url = new URL(window.location.href);
      url.searchParams.delete('imported');
      window.history.replaceState({}, '', url.toString());
    }
  });

  // Reload stats when deck or scope changes
  $: if ($authStore.user && $scopeStore && $deckStore.currentDeckId) {
    loadStats();
  }

  function playDeck() {
    // Auto-select first deck if none selected
    if (!$deckStore.currentDeckId && $deckStore.decks.length > 0) {
      deckStore.selectDeck($deckStore.decks[0].id);
      // Wait for state to update, then navigate
      setTimeout(() => goto('/study'), 100);
      return;
    }

    if (!$deckStore.currentDeckId) {
      alert('Create a deck first to start studying.');
      return;
    }

    goto('/study');
  }

  function goToImport() {
    goto('/import');
  }

  function goToGraveyard() {
    goto('/graveyard');
  }

  function goToExplore() {
    goto('/explore');
  }

  function goToSignIn() {
    goto('/auth/signin');
  }
</script>

<Header />

<div class="min-h-screen flex items-center justify-center p-8">
  <div class="max-w-2xl w-full">
    <!-- Title Section -->
    <div class="text-center mb-12">
      <h1 class="text-6xl font-display font-bold mb-4" style="color: var(--accent-1)">
        VOC APP
      </h1>
      {#if $authStore.user && $scopeStore.type === 'all'}
        <p class="text-sm mt-2" style="color: var(--accent-2)">
          Studying across all {$deckStore.decks.length} decks
        </p>
      {/if}
    </div>

    {#if loading}
      <div class="text-center py-12">
        <div class="animate-spin rounded-full h-12 w-12 border-b-2 mx-auto" style="border-color: var(--accent-1)"></div>
        <p class="mt-4" style="color: var(--muted)">Loading...</p>
      </div>
    {:else if !$authStore.user}
      <!-- Signed Out State -->
      <div class="space-y-6">
        <div class="text-center py-8 px-6 rounded-lg" style="background: var(--card-bg); border: 1px solid var(--card-border)">
          <p class="text-lg mb-6" style="color: var(--muted)">
            Sign in to create decks and start learning
          </p>
          <button
            on:click={goToSignIn}
            class="px-6 py-3 rounded-lg font-semibold transition-all hover:scale-105 inline-flex items-center gap-2"
            style="background: var(--accent-1); color: var(--bg)"
          >
            <LogIn size={20} />
            Sign In with Google
          </button>
        </div>

        <div class="text-center">
          <p class="mb-4" style="color: var(--muted)">Or browse public decks</p>
          <button
            on:click={goToExplore}
            class="px-6 py-3 rounded-lg font-medium transition-all hover:scale-105 inline-flex items-center gap-2"
            style="background: var(--card-bg); border: 1px solid var(--card-border); color: var(--fg)"
          >
            <Compass size={20} />
            Explore Public Decks
          </button>
        </div>
      </div>
    {:else if $deckStore.decks.length === 0}
      <!-- Empty State (No Decks) -->
      <div class="text-center py-12 px-6 rounded-lg" style="background: var(--card-bg); border: 1px solid var(--card-border)">
        <p class="text-lg mb-4" style="color: var(--muted)">
          Create your first deck to get started
        </p>
        <p class="text-sm" style="color: var(--muted)">
          Use the menu in the header to create, import, or explore decks
        </p>
      </div>
    {:else if zenStats.total === 0}
      <!-- Empty Deck State -->
      <div class="text-center py-12">
        <div class="mb-6 text-6xl opacity-20">🍃</div>
        <p class="text-lg mb-2" style="color: var(--muted)">This deck is empty</p>
        <p class="text-sm mb-6" style="color: var(--muted); opacity: 0.7">Import words to begin your journey</p>
        <button
          on:click={goToImport}
          class="px-8 py-4 rounded-xl font-semibold text-lg transition-all hover:scale-105"
          style="background: var(--accent-1); color: var(--bg); box-shadow: var(--shadow-lg)"
        >
          Import CSV
        </button>
      </div>
    {:else}
      <!-- Zen Home: Single Play Button + Minimal Stats -->

      <!-- Big Play Deck Button -->
      <button
        on:click={playDeck}
        disabled={zenStats.total === 0}
        class="zen-play-button w-full py-8 px-6 rounded-2xl font-display font-semibold text-2xl transition-all hover:scale-[1.02] active:scale-[0.98] disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:scale-100 mb-4"
        style="background: var(--accent-1); color: var(--bg); box-shadow: var(--shadow-lg)"
      >
        Play Deck
      </button>

      <!-- Minimal Stats: "47 due · 12 new · 312 mastered" -->
      <div class="text-center">
        {#if zenStats.due === 0 && zenStats.new > 0}
          <p class="text-sm mb-1" style="color: var(--muted); opacity: 0.7">
            No reviews due · {zenStats.new} new card{zenStats.new === 1 ? '' : 's'} ready
          </p>
        {:else}
          <p class="text-sm" style="color: var(--muted); opacity: 0.7">
            {zenStats.due} due · {zenStats.new} new · <button on:click={goToGraveyard} class="hover:opacity-100 transition-opacity" style="color: var(--muted)">{zenStats.mastered} mastered</button>
          </p>
        {/if}
      </div>
    {/if}
  </div>
</div>

<style>
  .zen-play-button {
    position: relative;
    overflow: hidden;
  }

  .zen-play-button::before {
    content: '';
    position: absolute;
    top: 50%;
    left: 50%;
    width: 0;
    height: 0;
    border-radius: 50%;
    background: rgba(255, 255, 255, 0.2);
    transform: translate(-50%, -50%);
    transition: width 0.6s, height 0.6s;
  }

  .zen-play-button:hover::before {
    width: 300px;
    height: 300px;
  }

  @media (prefers-reduced-motion: reduce) {
    .zen-play-button {
      transition: none;
    }
    .zen-play-button::before {
      display: none;
    }
  }
</style>
