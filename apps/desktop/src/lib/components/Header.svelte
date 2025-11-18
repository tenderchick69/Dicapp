<script lang="ts">
  import { onMount } from 'svelte';
  import { goto, invalidateAll } from '$app/navigation';
  import { deckStore } from '$lib/stores/deck';
  import { authStore } from '$lib/stores/auth';
  import { Settings as SettingsIcon, Compass, Menu, Plus, Upload, Download, Skull } from 'lucide-svelte';

  let menuOpen = false;

  onMount(() => {
    authStore.init();
  });

  async function handleDeckChange(e: Event) {
    const deckId = (e.target as HTMLSelectElement).value;
    if (deckId) {
      await deckStore.selectDeck(deckId);
      await invalidateAll();
      goto('/', { invalidateAll: true });
    }
  }

  function goToSettings() {
    menuOpen = false;
    goto('/settings');
  }

  function goToExplore() {
    goto('/explore');
  }

  async function createNewDeck() {
    menuOpen = false;
    const name = prompt('Enter deck name:');
    if (name && name.trim()) {
      try {
        await deckStore.createDeck(name.trim(), 'full');
        alert('Deck created!');
      } catch (err: any) {
        alert('Failed to create deck: ' + err.message);
      }
    }
  }

  function goToImport() {
    menuOpen = false;
    goto('/import');
  }

  function goToGraveyard() {
    menuOpen = false;
    goto('/graveyard');
  }

  function toggleMenu() {
    menuOpen = !menuOpen;
  }

  function closeMenu() {
    menuOpen = false;
  }
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

    <!-- Right: Deck Selector + Settings -->
    <div class="flex items-center gap-4">
      {#if $authStore.user && $deckStore.decks.length > 0}
        <div class="deck-selector">
          <select
            bind:value={$deckStore.currentDeckId}
            on:change={handleDeckChange}
            class="deck-select"
          >
            {#each $deckStore.decks as deck}
              <option value={deck.id}>
                {deck.name}
              </option>
            {/each}
          </select>
        </div>
      {/if}

      {#if $authStore.user}
        <div class="relative">
          <button
            on:click={toggleMenu}
            class="p-2 rounded-lg hover:opacity-70 transition-opacity"
            title="Menu"
          >
            <Menu size={20} style="color: var(--muted)" />
          </button>

          {#if menuOpen}
            <!-- svelte-ignore a11y-click-events-have-key-events -->
            <!-- svelte-ignore a11y-no-static-element-interactions -->
            <div class="fixed inset-0 z-40" on:click={closeMenu}></div>
            <div class="absolute right-0 mt-2 w-56 rounded-lg shadow-lg z-50" style="background: var(--card-bg); border: 1px solid var(--card-border)">
              <div class="py-2">
                <button
                  on:click={createNewDeck}
                  class="w-full px-4 py-3 text-left hover:opacity-70 transition-opacity flex items-center gap-3"
                  style="color: var(--fg)"
                >
                  <Plus size={18} />
                  Create New Deck
                </button>
                <button
                  on:click={goToImport}
                  class="w-full px-4 py-3 text-left hover:opacity-70 transition-opacity flex items-center gap-3"
                  style="color: var(--fg)"
                >
                  <Upload size={18} />
                  Import CSV
                </button>
                <div class="border-t my-2" style="border-color: var(--card-border)"></div>
                <button
                  on:click={goToGraveyard}
                  class="w-full px-4 py-3 text-left hover:opacity-70 transition-opacity flex items-center gap-3"
                  style="color: var(--fg)"
                >
                  <Skull size={18} />
                  Graveyard
                </button>
                <button
                  on:click={goToSettings}
                  class="w-full px-4 py-3 text-left hover:opacity-70 transition-opacity flex items-center gap-3"
                  style="color: var(--fg)"
                >
                  <SettingsIcon size={18} />
                  Settings
                </button>
              </div>
            </div>
          {/if}
        </div>
      {/if}
    </div>
  </div>
</header>

<style>
  header {
    backdrop-filter: blur(10px);
  }

  .deck-selector {
    max-height: 70vh;
  }

  .deck-select {
    background: var(--card-bg);
    color: var(--accent-1);
    padding: 0.5rem 1rem;
    border: 1px solid var(--card-border);
    border-radius: 0.5rem;
    font-size: 0.95rem;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.2s;
    max-height: 70vh;
    overflow-y: auto;
  }

  .deck-select:hover {
    border-color: var(--accent-1);
    opacity: 0.8;
  }

  .deck-select:focus {
    outline: none;
    border-color: var(--accent-1);
    box-shadow: 0 0 0 2px rgba(191, 167, 106, 0.2);
  }

  .deck-select option {
    background: var(--card-bg);
    color: var(--fg);
    padding: 0.75rem;
  }

  .deck-select option:checked {
    background: var(--accent-1);
    color: var(--bg);
  }
</style>
