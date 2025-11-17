<script lang="ts">
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import { getDataStore } from '$lib/stores/database';
  import { deckStore } from '$lib/stores/deck';
  import { scopeStore } from '$lib/stores/scope';
  import { authStore } from '$lib/stores/auth';
  import Header from '$lib/components/Header.svelte';
  import { Compass, LogIn } from 'lucide-svelte';

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
      <!-- Stats -->
      <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
        <div class="bg-card-bg border rounded-lg p-4 text-center" style="border-color: var(--card-border)">
          <div class="text-3xl font-bold mb-1" style="color: var(--accent-1)">{stats.new}</div>
          <div class="text-sm" style="color: var(--muted)">New</div>
        </div>
        <div class="bg-card-bg border rounded-lg p-4 text-center" style="border-color: var(--card-border)">
          <div class="text-3xl font-bold mb-1" style="color: var(--accent-2)">{stats.learning}</div>
          <div class="text-sm" style="color: var(--muted)">Learning</div>
        </div>
        <div class="bg-card-bg border rounded-lg p-4 text-center" style="border-color: var(--card-border)">
          <div class="text-3xl font-bold mb-1" style="color: var(--g-good)">{stats.retention}</div>
          <div class="text-sm" style="color: var(--muted)">Retention</div>
        </div>
        <div class="bg-card-bg border rounded-lg p-4 text-center" style="border-color: var(--card-border)">
          <div class="text-3xl font-bold mb-1" style="color: var(--danger)">{stats.leeches}</div>
          <div class="text-sm" style="color: var(--muted)">Leeches</div>
        </div>
      </div>

      <!-- Actions -->
      <div class="space-y-6">
        <button
          on:click={startReview}
          class="w-full py-6 px-6 rounded-lg font-semibold text-xl transition-all hover:scale-[1.02] active:scale-[0.98]"
          style="background: var(--accent-1); color: var(--bg); box-shadow: var(--shadow-lg)"
        >
          Start Review
        </button>
      </div>

      <!-- Total count -->
      <div class="text-center mt-8">
        <p class="text-sm" style="color: var(--muted)">
          {stats.total} {stats.total === 1 ? 'word' : 'words'} in {$scopeStore.type === 'all' ? 'all decks' : 'current deck'}
        </p>
      </div>
    {/if}
  </div>
</div>
