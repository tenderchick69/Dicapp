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
  class:wilt={animate}
  class="wilted-icon"
>
  <path
    d="M12 2C12 2 16 6 16 12C16 18 12 22 12 22C12 22 8 18 8 12C8 6 12 2 12 2Z"
    fill="#8B4513"
    opacity="0.8"
  />
  <path
    d="M12 2L12 22"
    stroke="#8B4513"
    stroke-width="1"
    opacity="0.4"
  />
  <path
    d="M12 12C12 12 14 14 12 16C10 14 12 12 12 12Z"
    fill="#D2B48C"
    opacity="0.6"
  />
  <path
    d="M16 16C16 16 14 18 12 18C10 18 8 16 8 16"
    stroke="#DAA520"
    stroke-width="1"
    opacity="0.5"
  />
</svg>

<style>
  .wilted-icon {
    display: inline-block;
    vertical-align: middle;
  }

  .wilt {
    animation: droop 2s ease-in-out infinite;
    transform-origin: top center;
  }

  @keyframes droop {
    0%,
    100% {
      transform: rotate(0deg);
      opacity: 0.8;
    }
    50% {
      transform: rotate(5deg) translateY(2px);
      opacity: 0.6;
    }
  }

  /* Respect user motion preferences */
  @media (prefers-reduced-motion: reduce) {
    .wilt {
      animation: none;
    }
  }
</style>
