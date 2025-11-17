<script lang="ts">
  export let width = 16;
  export let height = 32;
  export let animate = false;
</script>

<svg
  {width}
  {height}
  viewBox="0 0 16 32"
  fill="none"
  xmlns="http://www.w3.org/2000/svg"
  class:bamboo-sway={animate}
  class="bamboo-icon"
>
  <rect x="4" y="0" width="8" height="8" rx="1" fill="#6B8E23" />
  <rect x="4" y="8" width="8" height="8" rx="1" fill="#6B8E23" />
  <rect x="4" y="16" width="8" height="8" rx="1" fill="#6B8E23" />
  <rect x="4" y="24" width="8" height="8" rx="1" fill="#6B8E23" />
  <path d="M8 0L8 32" stroke="#228B22" stroke-width="2" opacity="0.5" />
  <path
    d="M2 4L6 2M10 2L14 4M2 12L6 10M10 10L14 12M2 20L6 18M10 18L14 20M2 28L6 26M10 26L14 28"
    stroke="#90EE90"
    stroke-width="1"
  />
</svg>

<style>
  .bamboo-icon {
    display: inline-block;
    vertical-align: middle;
  }

  .bamboo-sway {
    animation: bamboo-breeze 4s ease-in-out infinite;
    transform-origin: bottom center;
  }

  @keyframes bamboo-breeze {
    0%,
    100% {
      transform: rotate(0deg);
    }
    25% {
      transform: rotate(1deg);
    }
    75% {
      transform: rotate(-1deg);
    }
  }

  /* Respect user motion preferences */
  @media (prefers-reduced-motion: reduce) {
    .bamboo-sway {
      animation: none;
    }
  }
</style>
