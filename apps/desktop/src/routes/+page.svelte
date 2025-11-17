<script lang="ts">
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import { getDataStore } from '$lib/stores/database';
  import { deckStore } from '$lib/stores/deck';
  import { scopeStore } from '$lib/stores/scope';
  import { authStore } from '$lib/stores/auth';
  import Header from '$lib/components/Header.svelte';
  import { Compass, LogIn } from 'lucide-svelte';
  import { Seedling, WaterDrop, Bamboo, WiltedLeaf } from '$lib/components/icons';

  let stats = {
    total: 0,
    new: 0,
    due: 0,
    learning: 0,
    retention: 0,
    leeches: 0,
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
      stats = await dataStore.getStatsByScope($scopeStore, currentDeckId);
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
  });

  // Reload stats when scope changes
  $: if ($authStore.user && $scopeStore && $deckStore.currentDeckId) {
    loadStats();
  }

  function startReview() {
    if (!$deckStore.currentDeckId) {
      alert('Create a deck first to start studying.');
      return;
    }
    goto('/study');
  }

  function startPractice(mode: 'new' | 'learning' | 'all') {
    if (!$deckStore.currentDeckId) {
      alert('Create a deck first to start studying.');
      return;
    }
    goto(`/study?mode=practice&filter=${mode}`);
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
    {:else}
      <!-- Main Review Status - Big and Clear -->
      <div class="review-status mb-8" style="--stat-delay: 0ms">
        <div class="flex justify-center mb-3">
          {#if stats.due > 0}
            <WaterDrop size={48} animate={true} />
          {:else}
            <Bamboo width={32} height={48} animate={true} />
          {/if}
        </div>
        <div class="text-5xl font-bold mb-2" style="color: {stats.due > 0 ? 'var(--accent-1)' : 'var(--g-good)'}">
          {stats.due}
        </div>
        <div class="text-xl mb-2" style="color: var(--fg)">
          {stats.due === 1 ? 'card' : 'cards'} ready to review
        </div>
        {#if stats.due === 0 && stats.learning > 0}
          <p class="text-sm mt-2" style="color: var(--muted)">
            You have {stats.learning} cards in learning. They'll be ready for review soon!
          </p>
        {:else if stats.due === 0 && stats.new > 0}
          <p class="text-sm mt-2" style="color: var(--muted)">
            You have {stats.new} new cards waiting. Start reviewing to learn them!
          </p>
        {:else if stats.due === 0 && stats.total === 0}
          <p class="text-sm mt-2" style="color: var(--muted)">
            No cards in this deck. Add some words to get started!
          </p>
        {/if}
      </div>

      <!-- Secondary Stats - Smaller -->
      <div class="grid grid-cols-3 gap-3 mb-8 zen-stats">
        <div class="stat-card-small" style="border-color: var(--card-border); --stat-delay: 100ms" title="New cards you haven't studied yet">
          <div class="flex justify-center mb-1">
            <Seedling size={24} animate={false} />
          </div>
          <div class="text-2xl font-bold mb-0.5" style="color: var(--accent-1)">{stats.new}</div>
          <div class="text-xs" style="color: var(--muted)">New</div>
        </div>
        <div class="stat-card-small" style="border-color: var(--card-border); --stat-delay: 150ms" title="Cards you're actively learning (interval < 21 days)">
          <div class="flex justify-center mb-1">
            <WaterDrop size={20} animate={false} />
          </div>
          <div class="text-2xl font-bold mb-0.5" style="color: var(--accent-2)">{stats.learning}</div>
          <div class="text-xs" style="color: var(--muted)">Learning</div>
        </div>
        <div class="stat-card-small" style="border-color: var(--card-border); --stat-delay: 200ms" title="Difficult cards (failed 8+ times)">
          <div class="flex justify-center mb-1">
            <WiltedLeaf size={20} animate={false} />
          </div>
          <div class="text-2xl font-bold mb-0.5" style="color: var(--danger)">{stats.leeches}</div>
          <div class="text-xs" style="color: var(--muted)">Leeches</div>
        </div>
      </div>

      <!-- Action Buttons -->
      <div class="space-y-4">
        <!-- Primary: Review Due Cards (SRS Mode) -->
        <button
          on:click={startReview}
          disabled={stats.due === 0}
          class="w-full py-6 px-6 rounded-lg font-semibold text-xl transition-all hover:scale-[1.02] active:scale-[0.98] disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:scale-100"
          style="background: var(--accent-1); color: var(--bg); box-shadow: var(--shadow-lg)"
        >
          {#if stats.due > 0}
            Review Due Cards ({stats.due})
          {:else}
            No Cards Due
          {/if}
        </button>

        <!-- Secondary: Practice Modes -->
        {#if stats.total > 0}
          <div class="text-center mb-2 mt-6">
            <p class="text-sm font-medium" style="color: var(--muted)">Or practice anytime:</p>
          </div>
          <div class="grid grid-cols-2 gap-3">
            <button
              on:click={() => startPractice('new')}
              disabled={stats.new === 0}
              class="py-4 px-4 rounded-lg font-medium text-sm transition-all hover:scale-[1.02] active:scale-[0.98] disabled:opacity-40 disabled:cursor-not-allowed disabled:hover:scale-100"
              style="background: var(--card-bg); border: 1.5px solid var(--accent-1); color: var(--accent-1)"
              title="Practice new cards you haven't seen yet"
            >
              Practice New ({stats.new})
            </button>
            <button
              on:click={() => startPractice('learning')}
              disabled={stats.learning === 0}
              class="py-4 px-4 rounded-lg font-medium text-sm transition-all hover:scale-[1.02] active:scale-[0.98] disabled:opacity-40 disabled:cursor-not-allowed disabled:hover:scale-100"
              style="background: var(--card-bg); border: 1.5px solid var(--accent-2); color: var(--accent-2)"
              title="Practice cards you're actively learning"
            >
              Practice Learning ({stats.learning})
            </button>
          </div>
          <button
            on:click={() => startPractice('all')}
            class="w-full py-3 px-4 rounded-lg font-medium text-sm transition-all hover:scale-[1.02] active:scale-[0.98]"
            style="background: var(--card-bg); border: 1.5px solid var(--muted); color: var(--fg)"
            title="Practice all cards in deck, ignore due dates"
          >
            Practice All Cards ({stats.total})
          </button>
        {/if}
      </div>

      <!-- Total count -->
      <div class="text-center mt-8">
        <p class="text-sm" style="color: var(--muted)">
          {stats.total} {stats.total === 1 ? 'word' : 'words'} in {$scopeStore.type === 'all' ? 'all decks' : 'current deck'}
          {#if stats.retention > 0}
            <span class="ml-2">· {stats.retention}% retention</span>
          {/if}
        </p>
      </div>
    {/if}
  </div>
</div>

<style>
  /* Main Review Status - Prominent Display */
  .review-status {
    background: var(--card-bg);
    border: 2px solid var(--card-border);
    border-radius: 16px;
    padding: 2rem 1.5rem;
    text-align: center;
    animation: stat-appear 0.6s ease-out backwards;
    animation-delay: var(--stat-delay);
    box-shadow: 0 4px 16px rgba(34, 139, 34, 0.1);
  }

  /* Secondary Stats - Smaller Cards */
  .stat-card-small {
    background: var(--card-bg);
    border: 1px solid;
    border-radius: 8px;
    padding: 0.75rem 0.5rem;
    text-align: center;
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    animation: stat-appear 0.6s ease-out backwards;
    animation-delay: var(--stat-delay);
    cursor: help;
  }

  .stat-card-small:hover {
    transform: translateY(-2px) scale(1.02);
    box-shadow: 0 4px 12px rgba(34, 139, 34, 0.12);
    border-color: var(--accent-1);
  }

  @keyframes stat-appear {
    0% {
      opacity: 0;
      transform: translateY(20px) scale(0.95);
    }
    100% {
      opacity: 1;
      transform: translateY(0) scale(1);
    }
  }

  /* Respect user motion preferences */
  @media (prefers-reduced-motion: reduce) {
    .review-status,
    .stat-card-small {
      animation: none;
    }

    .stat-card-small:hover {
      transform: none;
    }
  }
</style>
