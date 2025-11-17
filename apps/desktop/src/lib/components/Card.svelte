<script lang="ts">
  import type { Word } from '@runedeck/core/models';
  import { frequencyToRarity } from '@runedeck/core/models';
  import { modeOf, type SchedulingData } from '@runedeck/core/scheduler';
  import { settingsStore } from '$lib/stores/settings';

  export let word: Word;
  export let scheduling: SchedulingData;
  export let revealed = false;

  $: rarity = frequencyToRarity(word.freq);
  $: actualMode = modeOf(scheduling);

  // Determine if we should show the answer
  $: frontShowsAnswer =
    revealed ||
    (actualMode === 'learning' && $settingsStore.learningReveal === 'rich') ||
    actualMode === 'clinic';

  // Study orientation
  $: orientation = $settingsStore.studyOrientation;

  const rarityGems: Record<string, string> = {
    mythic: '◆',
    rare: '●',
    uncommon: '▲',
    common: '○',
  };

  const rarityColors: Record<string, string> = {
    mythic: '#ff6b9d',
    rare: '#8b5cf6',
    uncommon: '#3b82f6',
    common: '#6b7280',
  };
</script>

<div
  class="card-frame zen-card"
  style="
    width: var(--card-w);
    max-width: 95vw;
    height: var(--card-h);
    max-height: 85vh;
    background: var(--card-bg);
    border-radius: 45% 55% 42% 58% / 48% 52% 48% 52%;
    box-shadow: var(--shadow-card);
    display: flex;
    flex-direction: column;
    overflow: hidden;
    position: relative;
    backdrop-filter: blur(8px);
  "
>
  <!-- Water ripple effect on reveal -->
  <div class="water-ripple"></div>

  <!-- Decorative leaf corner -->
  <div class="leaf-decoration"></div>

  <!-- Header: Show headword only for word-to-def orientation -->
  {#if orientation === 'word-to-def'}
    <div class="card-header" style="padding: 2rem 2rem 1rem; border-bottom: 1px solid var(--card-border)">
      <h1
        class="text-4xl font-display font-bold mb-2"
        style="color: var(--accent-1); text-align: center; letter-spacing: 0.02em"
      >
        {word.headword}
      </h1>
      <div class="text-center space-x-3 text-sm" style="color: var(--muted)">
        {#if word.pos}
          <span class="font-medium">{word.pos}</span>
        {/if}
        {#if word.ipa}
          <span class="font-mono">{word.ipa}</span>
        {/if}
      </div>
    </div>
  {/if}

  <!-- Body -->
  <div class="card-body" style="flex: 1; padding: 2rem; overflow-y: auto; position: relative" data-revealed={frontShowsAnswer}>
    {#if orientation === 'def-to-word'}
      <!-- DEF → WORD: Show definition first, reveal headword -->
      <div class="space-y-6">
        <!-- PROMPT: Always visible -->
        <section class="prompt">
          <div class="text-xs font-semibold mb-2" style="color: var(--muted)">DEFINITION</div>
          <p class="text-xl leading-relaxed" style="color: var(--fg)">
            {word.definition}
          </p>
        </section>

        <!-- ANSWER: Only when revealed -->
        {#if frontShowsAnswer}
          <section class="answer reveal">
            <div class="text-xs font-semibold mb-2" style="color: var(--accent-1)">WORD</div>
            <h2 class="text-3xl font-display font-bold mb-4" style="color: var(--accent-1)">
              {word.headword}
            </h2>
            <div class="text-sm mb-4" style="color: var(--muted)">
              {#if word.pos}<span class="font-medium">{word.pos}</span>{/if}
              {#if word.ipa}<span class="font-mono ml-2">{word.ipa}</span>{/if}
            </div>

            {#if word.example}
              <p class="text-base italic mb-4" style="color: var(--muted)">"{word.example}"</p>
            {/if}

            {#if word.etymology}
              <div class="pl-4 py-2 italic text-sm mb-4" style="border-left: 3px solid var(--accent-1); color: var(--muted)">
                {word.etymology}
              </div>
            {/if}

            {#if word.mnemonic}
              <div class="p-3 rounded text-sm mb-4" style="background: rgba(191, 167, 106, 0.1); color: var(--fg)">
                <div class="font-semibold mb-1" style="color: var(--accent-1)">Mnemonic</div>
                {word.mnemonic}
              </div>
            {/if}

            {#if word.gloss_de}
              <div class="text-sm" style="color: var(--muted)">
                <span class="font-semibold">DE:</span> {word.gloss_de}
              </div>
            {/if}
          </section>
        {/if}
      </div>
    {:else}
      <!-- WORD → DEF: Show headword in header (already visible), reveal definition -->
      <div class="space-y-6">
        <!-- ANSWER: Only when revealed -->
        {#if frontShowsAnswer}
          <section class="answer reveal">
            <div class="text-xs font-semibold mb-2" style="color: var(--accent-1)">DEFINITION</div>
            <p class="text-xl leading-relaxed mb-4" style="color: var(--fg)">
              {word.definition}
            </p>

            {#if word.example}
              <p class="text-base italic mb-4" style="color: var(--muted)">"{word.example}"</p>
            {/if}

            {#if word.etymology}
              <div class="pl-4 py-2 italic text-sm mb-4" style="border-left: 3px solid var(--accent-1); color: var(--muted)">
                {word.etymology}
              </div>
            {/if}

            {#if word.mnemonic}
              <div class="p-3 rounded text-sm mb-4" style="background: rgba(191, 167, 106, 0.1); color: var(--fg)">
                <div class="font-semibold mb-1" style="color: var(--accent-1)">Mnemonic</div>
                {word.mnemonic}
              </div>
            {/if}

            {#if word.gloss_de}
              <div class="text-sm" style="color: var(--muted)">
                <span class="font-semibold">DE:</span> {word.gloss_de}
              </div>
            {/if}
          </section>
        {/if}
      </div>
    {/if}

    <!-- Small hint (doesn't block content) -->
    {#if !frontShowsAnswer}
      <div class="reveal-hint">Press R to reveal</div>
    {/if}
  </div>

  <!-- Footer -->
  <div
    class="card-footer"
    style="padding: 1rem 2rem; border-top: 1px solid var(--card-border); display: flex; justify-content: space-between; align-items: center"
  >
    <div class="text-xs" style="color: var(--muted)">
      {#if word.tags.length > 0}
        {word.tags.join(' • ')}
      {:else}
        <span style="opacity: 0.5">No tags</span>
      {/if}
    </div>
    <div
      class="rarity-gem text-2xl"
      style="color: {rarityColors[rarity]}"
      title="{rarity} (freq: {word.freq})"
    >
      {rarityGems[rarity]}
    </div>
  </div>
</div>

<style>
  /* Zen Card - Floating Leaf Effect */
  .zen-card {
    animation: float 6s ease-in-out infinite;
    transition: transform 0.3s ease, box-shadow 0.3s ease;
  }

  .zen-card:hover {
    transform: translateY(-6px) scale(1.01);
    box-shadow: 0 12px 48px rgba(34, 139, 34, 0.2), 0 0 0 1px var(--card-border);
  }

  @keyframes float {
    0%,
    100% {
      transform: translateY(0px) rotate(0deg);
    }
    33% {
      transform: translateY(-4px) rotate(0.3deg);
    }
    66% {
      transform: translateY(2px) rotate(-0.3deg);
    }
  }

  /* Water Ripple Effect */
  .water-ripple {
    position: absolute;
    inset: 0;
    pointer-events: none;
    background: radial-gradient(
      circle at center,
      rgba(135, 206, 235, 0.15) 0%,
      rgba(144, 238, 144, 0.1) 30%,
      transparent 70%
    );
    opacity: 0;
    transition: opacity 0.4s ease;
  }

  /* Water ripple appears on reveal */
  [data-revealed="true"] .water-ripple {
    opacity: 1;
    animation: ripple-expand 1.2s ease-out forwards;
  }

  @keyframes ripple-expand {
    0% {
      transform: scale(0.8);
      opacity: 0;
    }
    50% {
      opacity: 1;
    }
    100% {
      transform: scale(1.3);
      opacity: 0;
    }
  }

  /* Decorative Leaf Corner */
  .leaf-decoration {
    position: absolute;
    top: 1rem;
    right: 1rem;
    width: 24px;
    height: 24px;
    opacity: 0.2;
    pointer-events: none;
    background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='%23228B22'%3E%3Cpath d='M12 2C12 2 8 6 8 12C8 16 10 18 12 22C14 18 16 16 16 12C16 6 12 2 12 2Z' opacity='0.8'/%3E%3C/svg%3E");
    background-size: contain;
    background-repeat: no-repeat;
    animation: leaf-gentle-sway 3s ease-in-out infinite;
  }

  @keyframes leaf-gentle-sway {
    0%,
    100% {
      transform: rotate(-2deg);
    }
    50% {
      transform: rotate(2deg);
    }
  }

  /* Reveal animation */
  .reveal {
    transform: rotateY(90deg);
    opacity: 0;
    transition: transform 0.25s ease, opacity 0.25s ease;
  }

  [data-revealed="true"] .reveal {
    transform: rotateY(0deg);
    opacity: 1;
  }

  /* Small hint (doesn't block content) */
  .reveal-hint {
    position: absolute;
    bottom: 0.75rem;
    right: 0.75rem;
    opacity: 0.65;
    font-size: 0.8rem;
    pointer-events: none; /* CRITICAL: doesn't block clicks or content */
    color: var(--muted);
  }

  .card-body::-webkit-scrollbar {
    width: 6px;
  }

  .card-body::-webkit-scrollbar-track {
    background: transparent;
  }

  .card-body::-webkit-scrollbar-thumb {
    background: var(--card-border);
    border-radius: 3px;
  }

  /* Respect user motion preferences */
  @media (prefers-reduced-motion: reduce) {
    .zen-card {
      animation: none !important;
    }

    .water-ripple,
    .leaf-decoration {
      animation: none !important;
    }

    .zen-card:hover {
      transform: none;
    }
  }
</style>
