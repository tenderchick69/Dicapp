<script lang="ts">
  export let size = 32;
  export let animate = false;
</script>

<svg
  width={size}
  height={size}
  viewBox="0 0 32 32"
  fill="none"
  xmlns="http://www.w3.org/2000/svg"
  class:lotus-bloom={animate}
  class="lotus-icon"
>
  <path
    d="M16 28C16 28 8 24 8 16C8 8 16 4 16 4C16 4 24 8 24 16C24 24 16 28 16 28Z"
    fill="#DAA520"
    opacity="0.3"
    class="petal-outer"
  />
  <path
    d="M16 4C16 4 12 8 12 16C12 24 16 28 16 28C16 28 20 24 20 16C20 8 16 4 16 4Z"
    fill="#90EE90"
    opacity="0.7"
    class="petal-inner"
  />
  <circle cx="16" cy="16" r="4" fill="#228B22" class="lotus-center" />
  <path
    d="M16 12C16 12 14 14 16 16C18 14 16 12 16 12Z"
    fill="#DAA520"
  />
</svg>

<style>
  .lotus-icon {
    display: inline-block;
    vertical-align: middle;
  }

  .lotus-bloom .petal-outer {
    animation: bloom-outer 1s ease-out forwards;
  }

  .lotus-bloom .petal-inner {
    animation: bloom-inner 1s ease-out 0.2s forwards;
  }

  .lotus-bloom .lotus-center {
    animation: bloom-center 1s ease-out 0.4s forwards;
  }

  @keyframes bloom-outer {
    from {
      transform: scale(0);
      opacity: 0;
    }
    to {
      transform: scale(1);
      opacity: 0.3;
    }
  }

  @keyframes bloom-inner {
    from {
      transform: scale(0);
      opacity: 0;
    }
    to {
      transform: scale(1);
      opacity: 0.7;
    }
  }

  @keyframes bloom-center {
    from {
      transform: scale(0);
      opacity: 0;
    }
    to {
      transform: scale(1);
      opacity: 1;
    }
  }

  /* Respect user motion preferences */
  @media (prefers-reduced-motion: reduce) {
    .lotus-bloom .petal-outer,
    .lotus-bloom .petal-inner,
    .lotus-bloom .lotus-center {
      animation: none;
    }
  }
</style>
