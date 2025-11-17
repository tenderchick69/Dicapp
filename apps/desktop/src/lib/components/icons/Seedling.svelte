<script lang="ts">
  export let size = 24;
  export let animate = false;
</script>

<svg
  width={size}
  height={size}
  viewBox="0 0 24 24"
  fill="none"
  xmlns="http://www.w3.org/2000/svg"
  class="seedling-icon"
>
  <path
    d="M12 22L12 12"
    stroke="#228B22"
    stroke-width="3"
    class:grow-stem={animate}
  />
  <path
    d="M8 16C8 16 10 18 12 18C14 18 16 16 16 16"
    fill="#90EE90"
    class:sprout={animate}
    class="leaf-bottom"
  />
  <path
    d="M6 12C6 12 8 14 12 14C16 14 18 12 18 12"
    fill="#90EE90"
    opacity="0.8"
    class:sprout={animate}
    class="leaf-top"
    style="animation-delay: 0.2s"
  />
  <circle
    cx="12"
    cy="8"
    r="2"
    fill="#DAA520"
    class:bloom-seed={animate}
  />
  <path
    d="M12 22C12 22 4 18 4 12C4 6 12 2 12 2C12 2 20 6 20 12C20 18 12 22 12 22Z"
    stroke="#228B22"
    stroke-width="1"
    opacity="0.3"
  />
</svg>

<style>
  .seedling-icon {
    display: inline-block;
    vertical-align: middle;
  }

  .grow-stem {
    animation: grow-up 1s ease-out forwards;
    stroke-dasharray: 50;
    stroke-dashoffset: 50;
  }

  .sprout {
    animation: sprout-leaf 0.6s ease-out forwards;
    transform: scaleY(0);
    transform-origin: center;
  }

  .bloom-seed {
    animation: bloom-seed 0.5s ease-out 0.4s forwards;
    transform: scale(0);
  }

  @keyframes grow-up {
    to {
      stroke-dashoffset: 0;
    }
  }

  @keyframes sprout-leaf {
    to {
      transform: scaleY(1);
    }
  }

  @keyframes bloom-seed {
    to {
      transform: scale(1);
    }
  }

  /* Respect user motion preferences */
  @media (prefers-reduced-motion: reduce) {
    .grow-stem,
    .sprout,
    .bloom-seed {
      animation: none;
      stroke-dashoffset: 0;
      transform: scale(1);
    }
  }
</style>
