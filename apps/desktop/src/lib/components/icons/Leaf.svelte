<script lang="ts">
  export let color = 'var(--zen-primary)';
  export let size = 24;
  export let animate = false;
</script>

<svg
  width={size}
  height={size}
  viewBox="0 0 24 24"
  fill="none"
  xmlns="http://www.w3.org/2000/svg"
  class:leaf-sway={animate}
  class="leaf-icon"
>
  <path
    d="M12 2C12 2 8 6 8 12C8 16 10 18 12 22C14 18 16 16 16 12C16 6 12 2 12 2Z"
    fill="#228B22"
    opacity="0.8"
  />
  <path
    d="M12 2L12 22"
    stroke="#228B22"
    stroke-width="1"
    opacity="0.4"
  />
  <path
    d="M12 12C12 12 10 10 8 12C6 14 8 16 12 16C16 16 18 14 16 12C14 10 12 12 12 12Z"
    fill="#90EE90"
    opacity="0.6"
  />
</svg>

<style>
  .leaf-icon {
    display: inline-block;
    vertical-align: middle;
  }

  .leaf-sway {
    animation: sway 3s ease-in-out infinite alternate;
    transform-origin: bottom center;
  }

  @keyframes sway {
    from {
      transform: rotate(-2deg);
    }
    to {
      transform: rotate(2deg);
    }
  }

  /* Respect user motion preferences */
  @media (prefers-reduced-motion: reduce) {
    .leaf-sway {
      animation: none;
    }
  }
</style>
