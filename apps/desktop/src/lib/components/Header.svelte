<script lang="ts">
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import { deckStore } from '$lib/stores/deck';
  import { scopeStore } from '$lib/stores/scope';
  import { authStore } from '$lib/stores/auth';
  import { Menu, Settings as SettingsIcon, Compass } from 'lucide-svelte';

  let showScopeMenu = false;

  onMount(() => {
    authStore.init();
  });

  function toggleScopeMenu() {
    showScopeMenu = !showScopeMenu;
  }

  function selectScope(type: 'current' | 'all') {
    if (type === 'current') {
      scopeStore.setCurrent();
    } else {
      scopeStore.setAll();
    }
    showScopeMenu = false;
  }

  function selectDeck(deckId: string) {
    deckStore.setCurrent(deckId);
    scopeStore.setCurrent(); // Auto-switch to current deck scope
    showScopeMenu = false;
    // Force page refresh to update stats
    goto('/', { invalidateAll: true });
  }

  function goToSettings() {
    goto('/settings');
  }

  function goToExplore() {
    goto('/explore');
  }

  $: currentDeck = $deckStore.decks.find(d => d.id === $deckStore.currentDeckId);
  $: scopeLabel = $scopeStore.type === 'all'
    ? 'All Decks'
    : $scopeStore.type === 'current'
    ? currentDeck?.name || 'No Deck'
    : `${$scopeStore.deckIds.length} Decks`;
</script>

<header class="border-b py-3 px-6" style="border-color: var(--card-border)">
  <div class="flex items-center justify-between max-w-7xl mx-auto">
    <!-- Left: Explore -->
    <div class="flex items-center gap-3">
      {#if $authStore.user}
        <button
          on:click={goToExplore}
          class="p-2 rounded-lg hover:opacity-70 transition-opacity"
          title="Explore"
        >
          <Compass size={20} style="color: var(--muted)" />
        </button>
      {/if}
    </div>

    <!-- Right: Settings + Deck Selector -->
    <div class="flex items-center gap-3">
      {#if $authStore.user}
        <button
          on:click={goToSettings}
          class="p-2 rounded-lg hover:opacity-70 transition-opacity"
          title="Settings"
        >
          <SettingsIcon size={20} style="color: var(--muted)" />
        </button>
      {/if}

      {#if $authStore.user && $deckStore.decks.length > 0}
        <div class="relative">
          <button
            on:click={toggleScopeMenu}
            class="flex items-center gap-2 px-3 py-1.5 rounded-lg hover:opacity-70 transition-opacity"
            style="color: var(--muted)"
          >
            <span class="text-sm font-medium">{scopeLabel}</span>
            <Menu size={16} />
          </button>

      {#if showScopeMenu}
        <!-- Dropdown Menu -->
        <div
          class="absolute right-0 mt-2 w-64 rounded-lg shadow-xl"
          style="background: var(--card-bg); border: 1px solid var(--card-border); z-index: 9999;"
        >
          <!-- Scope Options -->
          <div class="p-3 border-b" style="border-color: var(--card-border)">
            <div class="text-xs font-semibold mb-2" style="color: var(--muted)">STUDY SCOPE</div>
            <button
              on:click={() => selectScope('current')}
              class="w-full text-left px-3 py-2 rounded hover:opacity-80 transition-opacity mb-1"
              style="background: {$scopeStore.type === 'current' ? 'var(--accent-2)' : 'transparent'}; color: {$scopeStore.type === 'current' ? 'var(--bg)' : 'var(--fg)'}"
            >
              Current Deck Only
            </button>
            <button
              on:click={() => selectScope('all')}
              class="w-full text-left px-3 py-2 rounded hover:opacity-80 transition-opacity"
              style="background: {$scopeStore.type === 'all' ? 'var(--accent-1)' : 'transparent'}; color: {$scopeStore.type === 'all' ? 'var(--bg)' : 'var(--fg)'}"
            >
              All Decks ({$deckStore.decks.length})
            </button>
          </div>

          <!-- Deck List -->
          <div class="p-3 max-h-64 overflow-y-auto">
            <div class="text-xs font-semibold mb-2" style="color: var(--muted)">SELECT DECK</div>
            {#each $deckStore.decks as deck}
              <button
                on:click={() => selectDeck(deck.id)}
                class="w-full text-left px-3 py-2 rounded hover:opacity-80 transition-opacity mb-1 text-sm"
                style="background: {deck.id === $deckStore.currentDeckId ? 'rgba(191, 167, 106, 0.2)' : 'transparent'}"
              >
                <div class="flex items-center justify-between">
                  <span>{deck.name}</span>
                  {#if deck.id === $deckStore.currentDeckId}
                    <span class="text-xs px-2 py-0.5 rounded" style="background: var(--accent-1); color: var(--bg)">
                      CURRENT
                    </span>
                  {/if}
                </div>
                <div class="text-xs mt-1" style="color: var(--muted)">
                  {deck.profile} profile
                </div>
              </button>
            {/each}
          </div>
        </div>
      {/if}
    </div>
      {/if}
    </div>
  </div>
</header>

<!-- Click outside to close -->
{#if showScopeMenu}
  <div
    class="fixed inset-0"
    style="z-index: 9998;"
    on:click={() => showScopeMenu = false}
    on:keydown={(e) => e.key === 'Escape' && (showScopeMenu = false)}
    role="button"
    tabindex="0"
  ></div>
{/if}

<style>
  header {
    backdrop-filter: blur(10px);
  }
</style>
