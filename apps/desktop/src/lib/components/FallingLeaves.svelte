<script lang="ts">
  // Zen Serenity - Subtle Falling Leaves Background Ambiance
  // 6 leaves with randomized animations for natural feel

  const leaves = [
    { id: 1, left: '8%', delay: '0s', duration: '14s', drift: -15, rotate: 120 },
    { id: 2, left: '25%', delay: '3s', duration: '16s', drift: 20, rotate: -90 },
    { id: 3, left: '45%', delay: '7s', duration: '13s', drift: -10, rotate: 140 },
    { id: 4, left: '65%', delay: '2s', duration: '15s', drift: 18, rotate: -110 },
    { id: 5, left: '82%', delay: '5s', duration: '12s', drift: -22, rotate: 100 },
    { id: 6, left: '92%', delay: '9s', duration: '14.5s', drift: 12, rotate: -130 },
  ];
</script>

<div class="falling-leaves-container" aria-hidden="true">
  {#each leaves as leaf}
    <div
      class="leaf"
      style="
        left: {leaf.left};
        animation-delay: {leaf.delay};
        animation-duration: {leaf.duration};
        --drift: {leaf.drift}px;
        --rotate-end: {leaf.rotate}deg;
      "
    >
      <!-- Simple leaf SVG - kept minimal for performance -->
      <svg
        width="50"
        height="50"
        viewBox="0 0 24 24"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
      >
        <path
          d="M12 2C12 2 16 6 16 12C16 18 12 22 12 22C12 22 8 18 8 12C8 6 12 2 12 2Z"
          fill="#228B22"
          opacity="0.6"
        />
        <path d="M12 2L12 22" stroke="#228B22" stroke-width="1" opacity="0.4" />
      </svg>
    </div>
  {/each}
</div>

<style>
  /* Falling Leaves - Zen Background Ambiance */
  .falling-leaves-container {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100vh;
    pointer-events: none;
    z-index: 0;
    overflow: hidden;
  }

  .leaf {
    position: absolute;
    top: -40px;
    opacity: 0;
    animation: fall-and-drift infinite ease-in;
    will-change: transform, opacity;
  }

  @keyframes fall-and-drift {
    0% {
      transform: translateY(0) translateX(0) rotate(0deg);
      opacity: 0;
    }
    5% {
      opacity: 0.15;
    }
    25% {
      opacity: 0.2;
    }
    50% {
      opacity: 0.18;
      transform: translateY(50vh) translateX(calc(var(--drift) * 0.5)) rotate(calc(var(--rotate-end) * 0.5));
    }
    75% {
      opacity: 0.15;
    }
    95% {
      opacity: 0.05;
    }
    100% {
      transform: translateY(100vh) translateX(var(--drift)) rotate(var(--rotate-end));
      opacity: 0;
    }
  }

  /* Respect user motion preferences - remove animation entirely */
  @media (prefers-reduced-motion: reduce) {
    .falling-leaves-container {
      display: none;
    }
  }

  /* Hide on small screens to reduce visual clutter */
  @media (max-width: 640px) {
    .falling-leaves-container {
      display: none;
    }
  }
</style>
