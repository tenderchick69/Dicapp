<script lang="ts">
  export let width = 32;
  export let height = 24;
  export let animate = false;
</script>

<svg
  {width}
  {height}
  viewBox="0 0 32 24"
  fill="none"
  xmlns="http://www.w3.org/2000/svg"
  class:koi-swim={animate}
  class="koi-icon"
>
  <path
    d="M16 12C16 12 8 4 4 8C0 12 4 16 16 16C28 16 32 12 28 8C24 4 16 12 16 12Z"
    fill="#DAA520"
    opacity="0.7"
  />
  <path
    d="M16 12C16 12 20 8 24 12C28 16 24 20 16 20"
    fill="#90EE90"
    opacity="0.5"
  />
  <circle cx="24" cy="12" r="2" fill="#228B22" />
  <path d="M4 8L0 12L4 16" stroke="#87CEEB" stroke-width="1" />
  <path
    d="M28 4L32 12L28 20"
    stroke="#87CEEB"
    stroke-width="1"
    opacity="0.6"
  />
</svg>

<style>
  .koi-icon {
    display: inline-block;
    vertical-align: middle;
  }

  .koi-swim {
    animation: swim 3s ease-in-out infinite;
    transform-origin: center;
  }

  @keyframes swim {
    0%,
    100% {
      transform: translateX(0) rotate(0deg);
    }
    25% {
      transform: translateX(2px) rotate(2deg);
    }
    75% {
      transform: translateX(-2px) rotate(-2deg);
    }
  }

  /* Respect user motion preferences */
  @media (prefers-reduced-motion: reduce) {
    .koi-swim {
      animation: none;
    }
  }
</style>
