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
  class="water-droplet"
>
  <path
    d="M12 2C12 2 6 8 6 14C6 18 9 22 12 22C15 22 18 18 18 14C18 8 12 2 12 2Z"
    fill="#87CEEB"
    opacity="0.8"
  />
  <path
    d="M12 2C12 2 8 6 8 12C8 16 10 18 12 18C14 18 16 16 16 12C16 6 12 2 12 2Z"
    fill="#87CEEB"
  />
  <circle cx="12" cy="14" r="2" fill="#FFFFFF" opacity="0.5" />
</svg>

{#if animate}
  <div class="ripple-container">
    <div class="ripple"></div>
  </div>
{/if}

<style>
  .water-droplet {
    display: inline-block;
    vertical-align: middle;
    position: relative;
  }

  .ripple-container {
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    pointer-events: none;
  }

  .ripple {
    width: 100%;
    height: 100%;
    border-radius: 50%;
    background: radial-gradient(
      circle,
      rgba(135, 206, 235, 0.3) 0%,
      transparent 70%
    );
    animation: ripple 2s ease-out infinite;
  }

  @keyframes ripple {
    0% {
      transform: scale(0);
      opacity: 1;
    }
    100% {
      transform: scale(2);
      opacity: 0;
    }
  }

  /* Respect user motion preferences */
  @media (prefers-reduced-motion: reduce) {
    .ripple {
      animation: none;
    }
  }
</style>
