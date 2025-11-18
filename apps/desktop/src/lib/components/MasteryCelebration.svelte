<!-- MasteryCelebration - ONLY gong + petal, NO text, NO modal -->
<script lang="ts">
  export let active: boolean = false;

  let hasPlayed = false;

  // Play gong ONLY when active becomes true
  $: if (active && !hasPlayed) {
    hasPlayed = true;
    playGongSound();
  }

  // Reset when active goes false
  $: if (!active) {
    hasPlayed = false;
  }

  function playGongSound() {
    try {
      const audioContext = new (window.AudioContext || (window as any).webkitAudioContext)();
      const now = audioContext.currentTime;
      const duration = 2;

      const osc1 = audioContext.createOscillator();
      osc1.type = 'sine';
      osc1.frequency.setValueAtTime(150, now);
      osc1.frequency.exponentialRampToValueAtTime(140, now + duration);

      const osc2 = audioContext.createOscillator();
      osc2.type = 'sine';
      osc2.frequency.setValueAtTime(300, now);
      osc2.frequency.exponentialRampToValueAtTime(280, now + duration);

      const gain1 = audioContext.createGain();
      gain1.gain.setValueAtTime(0.3, now);
      gain1.gain.exponentialRampToValueAtTime(0.01, now + duration);

      const gain2 = audioContext.createGain();
      gain2.gain.setValueAtTime(0.15, now);
      gain2.gain.exponentialRampToValueAtTime(0.01, now + duration);

      const masterGain = audioContext.createGain();
      masterGain.gain.setValueAtTime(0.4, now);

      osc1.connect(gain1);
      osc2.connect(gain2);
      gain1.connect(masterGain);
      gain2.connect(masterGain);
      masterGain.connect(audioContext.destination);

      osc1.start(now);
      osc2.start(now);
      osc1.stop(now + duration);
      osc2.stop(now + duration);
    } catch (err) {
      console.warn('Could not play gong sound:', err);
    }
  }
</script>

{#if active}
  <div class="mastery-celebration">
    <!-- Falling petal - NO TEXT, NO MODAL -->
    <div class="petal-container">
      <svg class="petal" width="80" height="80" viewBox="0 0 24 24" fill="none">
        <path
          d="M12 2C12 2 16 6 16 12C16 18 12 22 12 22C12 22 8 18 8 12C8 6 12 2 12 2Z"
          fill="#FFD700"
          opacity="0.8"
        />
        <path d="M12 2L12 22" stroke="#DAA520" stroke-width="1.5" opacity="0.6" />
      </svg>
    </div>
  </div>
{/if}

<style>
  .mastery-celebration {
    position: fixed;
    inset: 0;
    z-index: 9999;
    pointer-events: none;
  }

  .petal-container {
    position: absolute;
    top: 10%;
    left: 50%;
    transform: translateX(-50%);
  }

  .petal {
    animation: fall-and-spin 3s ease-in forwards;
    filter: drop-shadow(0 4px 8px rgba(218, 165, 32, 0.3));
  }

  @keyframes fall-and-spin {
    0% {
      transform: translateY(0) rotate(0deg);
      opacity: 0;
    }
    10% {
      opacity: 1;
    }
    100% {
      transform: translateY(80vh) rotate(360deg);
      opacity: 0;
    }
  }

  @media (prefers-reduced-motion: reduce) {
    .petal {
      animation: none;
      opacity: 1;
    }
  }
</style>
