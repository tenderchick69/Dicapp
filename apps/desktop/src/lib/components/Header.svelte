<script lang="ts">
  import { onMount } from 'svelte';
  import { goto, invalidateAll } from '$app/navigation';
  import { deckStore } from '$lib/stores/deck';
  import { authStore } from '$lib/stores/auth';
  import { Settings as SettingsIcon, Compass } from 'lucide-svelte';

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
    goto('/settings');
  }

  function goToExplore() {
    goto('/explore');
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
        <button
          on:click={goToSettings}
          class="p-2 rounded-lg hover:opacity-70 transition-opacity"
          title="Settings"
        >
          <SettingsIcon size={20} style="color: var(--muted)" />
        </button>
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
