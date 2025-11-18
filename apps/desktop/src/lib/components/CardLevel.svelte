<script lang="ts">
  /**
   * CardLevel component - Visual evolution of a flashcard based on progress
   * Level 0: New/reset (dew drop)
   * Level 1: First success (thin gold border)
   * Level 2: Growing (sprout icon)
   * Level 3: Maturing (leaf texture)
   * Level 4: Nearly mastered (glowing veins)
   */

  export let level: number = 0; // 0-4
  export let headword: string;
  export let definition: string;
  export let showFront: boolean = true; // true = show headword, false = show definition

  // Clamp level to 0-4
  $: clampedLevel = Math.min(Math.max(level, 0), 4);

  // Level-specific styling
  $: levelStyles = {
    0: {
      bg: '#fffff0',
      border: '2px solid rgba(191, 167, 106, 0.3)',
      icon: 'dewdrop',
      fontSize: '1em',
    },
    1: {
      bg: '#fff8e6',
      border: '2px solid rgba(218, 165, 32, 0.5)',
      icon: 'none',
      fontSize: '1em',
    },
    2: {
      bg: '#fff2e6',
      border: '2px solid rgba(218, 165, 32, 0.6)',
      icon: 'sprout',
      fontSize: '1em',
    },
    3: {
      bg: '#f0fdf4',
      border: '2px solid rgba(34, 139, 34, 0.4)',
      icon: 'leaf',
      fontSize: '1.05em',
    },
    4: {
      bg: '#ecfdf5',
      border: '3px solid rgba(218, 165, 32, 0.7)',
      icon: 'veins',
      fontSize: '1.1em',
      shadow: '0 0 20px rgba(218, 165, 32, 0.3)',
    },
  }[clampedLevel];
</script>

<div
  class="card-level"
  style="
    background: {levelStyles.bg};
    border: {levelStyles.border};
    font-size: {levelStyles.fontSize};
    box-shadow: {levelStyles.shadow || 'none'};
  "
>
  <!-- Level indicator icon (top-right corner) -->
  {#if levelStyles.icon !== 'none'}
    <div class="level-icon">
      {#if levelStyles.icon === 'dewdrop'}
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
          <path
            d="M12 2.5C12 2.5 8 6.5 8 11C8 14.3 9.7 17 12 17C14.3 17 16 14.3 16 11C16 6.5 12 2.5 12 2.5Z"
            fill="rgba(135, 206, 235, 0.4)"
            stroke="rgba(135, 206, 235, 0.6)"
            stroke-width="1.5"
          />
        </svg>
      {:else if levelStyles.icon === 'sprout'}
        <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
          <path
            d="M12 22V12M12 12C12 8 14 6 17 6C17 9 15 11 12 12ZM12 12C12 8 10 6 7 6C7 9 9 11 12 12Z"
            stroke="rgba(34, 139, 34, 0.6)"
            stroke-width="2"
            stroke-linecap="round"
            stroke-linejoin="round"
          />
        </svg>
      {:else if levelStyles.icon === 'leaf'}
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
          <path
            d="M12 2C12 2 16 6 16 12C16 18 12 22 12 22C12 22 8 18 8 12C8 6 12 2 12 2Z"
            fill="rgba(34, 139, 34, 0.25)"
            stroke="rgba(34, 139, 34, 0.5)"
            stroke-width="1.5"
          />
          <path d="M12 2L12 22" stroke="rgba(34, 139, 34, 0.4)" stroke-width="1" />
        </svg>
      {:else if levelStyles.icon === 'veins'}
        <svg width="26" height="26" viewBox="0 0 24 24" fill="none">
          <circle cx="12" cy="12" r="8" fill="rgba(218, 165, 32, 0.1)" />
          <path
            d="M12 4 L12 12 M12 12 L8 8 M12 12 L16 8 M12 12 L12 20 M12 12 L8 16 M12 12 L16 16"
            stroke="rgba(218, 165, 32, 0.5)"
            stroke-width="1.5"
            stroke-linecap="round"
          />
        </svg>
      {/if}
    </div>
  {/if}

  <!-- Card content -->
  <div class="card-content">
    {#if showFront}
      <div class="headword">{headword}</div>
    {:else}
      <div class="definition">{definition}</div>
    {/if}
  </div>

  <!-- Subtle texture overlay for level 3 -->
  {#if clampedLevel === 3}
    <div class="leaf-texture"></div>
  {/if}

  <!-- Glowing veins overlay for level 4 -->
  {#if clampedLevel === 4}
    <div class="vein-glow"></div>
  {/if}
</div>

<style>
  .card-level {
    position: relative;
    width: 100%;
    min-height: 300px;
    border-radius: var(--radius);
    padding: 3rem;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: all 0.3s ease;
    overflow: hidden;
  }

  .level-icon {
    position: absolute;
    top: 1rem;
    right: 1rem;
    opacity: 0.7;
    transition: opacity 0.3s ease;
  }

  .card-level:hover .level-icon {
    opacity: 1;
  }

  .card-content {
    text-align: center;
    z-index: 2;
    width: 100%;
  }

  .headword {
    font-family: var(--font-display);
    font-size: 2.5em;
    font-weight: var(--fw-semibold);
    color: var(--fg);
    line-height: 1.3;
  }

  .definition {
    font-family: var(--font-body);
    font-size: 1.3em;
    color: var(--fg);
    line-height: 1.6;
    max-width: 500px;
    margin: 0 auto;
  }

  /* Leaf texture overlay for level 3 */
  .leaf-texture {
    position: absolute;
    inset: 0;
    opacity: 0.05;
    background-image: repeating-linear-gradient(
      45deg,
      transparent,
      transparent 20px,
      rgba(34, 139, 34, 0.1) 20px,
      rgba(34, 139, 34, 0.1) 22px
    );
    pointer-events: none;
    z-index: 1;
  }

  /* Glowing veins for level 4 */
  .vein-glow {
    position: absolute;
    inset: 0;
    background: radial-gradient(
      circle at 30% 40%,
      rgba(218, 165, 32, 0.08) 0%,
      transparent 50%
    ),
    radial-gradient(
      circle at 70% 60%,
      rgba(218, 165, 32, 0.08) 0%,
      transparent 50%
    );
    animation: pulse 3s ease-in-out infinite;
    pointer-events: none;
    z-index: 1;
  }

  @keyframes pulse {
    0%, 100% {
      opacity: 0.5;
    }
    50% {
      opacity: 1;
    }
  }

  /* Respect reduced motion */
  @media (prefers-reduced-motion: reduce) {
    .card-level {
      transition: none;
    }
    .vein-glow {
      animation: none;
      opacity: 0.7;
    }
  }
</style>
