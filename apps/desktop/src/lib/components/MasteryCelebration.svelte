<script lang="ts">
  /**
   * MasteryCelebration - Zen celebration when a card reaches mastery (level 5)
   * Shows a single falling petal animation and plays a gong sound
   */

  import { onMount } from 'svelte';

  export let onComplete: () => void = () => {};

  let visible = true;

  onMount(() => {
    // Play gong sound (using Web Audio API to generate a bell-like tone)
    playGongSound();

    // Hide after animation completes (3 seconds)
    setTimeout(() => {
      visible = false;
      onComplete();
    }, 3000);
  });

  function playGongSound() {
    try {
      const audioContext = new (window.AudioContext || (window as any).webkitAudioContext)();

      // Create a bell-like sound using multiple oscillators
      const now = audioContext.currentTime;
      const duration = 2;

      // Fundamental frequency (low gong tone)
      const osc1 = audioContext.createOscillator();
      osc1.type = 'sine';
      osc1.frequency.setValueAtTime(150, now);
      osc1.frequency.exponentialRampToValueAtTime(140, now + duration);

      // Harmonic overtones for richness
      const osc2 = audioContext.createOscillator();
      osc2.type = 'sine';
      osc2.frequency.setValueAtTime(300, now);
      osc2.frequency.exponentialRampToValueAtTime(280, now + duration);

      const osc3 = audioContext.createOscillator();
      osc3.type = 'sine';
      osc3.frequency.setValueAtTime(450, now);
      osc3.frequency.exponentialRampToValueAtTime(420, now + duration);

      // Gain nodes for envelope (fade out)
      const gain1 = audioContext.createGain();
      gain1.gain.setValueAtTime(0.3, now);
      gain1.gain.exponentialRampToValueAtTime(0.01, now + duration);

      const gain2 = audioContext.createGain();
      gain2.gain.setValueAtTime(0.15, now);
      gain2.gain.exponentialRampToValueAtTime(0.01, now + duration);

      const gain3 = audioContext.createGain();
      gain3.gain.setValueAtTime(0.1, now);
      gain3.gain.exponentialRampToValueAtTime(0.01, now + duration);

      // Master volume
      const masterGain = audioContext.createGain();
      masterGain.gain.setValueAtTime(0.4, now);

      // Connect nodes
      osc1.connect(gain1);
      osc2.connect(gain2);
      osc3.connect(gain3);
      gain1.connect(masterGain);
      gain2.connect(masterGain);
      gain3.connect(masterGain);
      masterGain.connect(audioContext.destination);

      // Start and stop
      osc1.start(now);
      osc2.start(now);
      osc3.start(now);
      osc1.stop(now + duration);
      osc2.stop(now + duration);
      osc3.stop(now + duration);
    } catch (err) {
      console.warn('Could not play gong sound:', err);
    }
  }
</script>

{#if visible}
  <div class="mastery-celebration" aria-live="polite">
    <!-- Overlay -->
    <div class="overlay"></div>

    <!-- Falling petal - NO TEXT, JUST PETAL -->
    <div class="petal-container">
      <svg
        class="petal"
        width="80"
        height="80"
        viewBox="0 0 24 24"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
      >
        <path
          d="M12 2C12 2 16 6 16 12C16 18 12 22 12 22C12 22 8 18 8 12C8 6 12 2 12 2Z"
          fill="#FFD700"
          opacity="0.8"
        />
        <path d="M12 2L12 22" stroke="#DAA520" stroke-width="1.5" opacity="0.6" />
      </svg>
    </div>

    <!-- NO TEXT. NO MODAL. JUST GONG + PETAL. -->
  </div>
{/if}

<style>
  .mastery-celebration {
    position: fixed;
    inset: 0;
    z-index: 9999;
    display: flex;
    align-items: center;
    justify-content: center;
    pointer-events: none;
  }

  .overlay {
    position: absolute;
    inset: 0;
    background: rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(2px);
    animation: fadeIn 0.3s ease-in;
  }

  .petal-container {
    position: absolute;
    top: 10%;
    left: 50%;
    transform: translateX(-50%);
    z-index: 2;
  }

  .petal {
    animation: fall-and-spin 3s ease-in forwards;
    filter: drop-shadow(0 4px 8px rgba(218, 165, 32, 0.3));
  }

  .text-container {
    position: relative;
    z-index: 3;
    text-align: center;
    animation: fadeInScale 0.5s ease-out;
    animation-delay: 0.5s;
    animation-fill-mode: backwards;
  }

  .mastery-text {
    font-family: var(--font-display);
    font-size: 3rem;
    font-weight: var(--fw-semibold);
    color: #FFD700;
    text-shadow: 0 2px 8px rgba(218, 165, 32, 0.5);
    margin-bottom: 0.5rem;
  }

  .mastery-subtitle {
    font-family: var(--font-body);
    font-size: 1.2rem;
    color: rgba(255, 255, 255, 0.9);
  }

  @keyframes fadeIn {
    from {
      opacity: 0;
    }
    to {
      opacity: 1;
    }
  }

  @keyframes fadeInScale {
    from {
      opacity: 0;
      transform: scale(0.8);
    }
    to {
      opacity: 1;
      transform: scale(1);
    }
  }

  @keyframes fall-and-spin {
    0% {
      transform: translateY(0) translateX(0) rotate(0deg);
      opacity: 0;
    }
    10% {
      opacity: 1;
    }
    100% {
      transform: translateY(80vh) translateX(30px) rotate(360deg);
      opacity: 0;
    }
  }

  /* Respect user motion preferences */
  @media (prefers-reduced-motion: reduce) {
    .overlay {
      animation: none;
    }
    .petal {
      animation: fadeIn 0.3s ease-in;
    }
    .text-container {
      animation: fadeIn 0.3s ease-in;
    }
  }
</style>
