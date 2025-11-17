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
  class="branch-icon"
>
  <path
    d="M4 28L12 20L20 28"
    stroke="#6B8E23"
    stroke-width="2"
    class:grow-branch={animate}
    class="branch-main"
  />
  <path
    d="M12 20L16 12L20 20"
    stroke="#6B8E23"
    stroke-width="2"
    class:grow-branch={animate}
    class="branch-sub"
    style="animation-delay: 0.2s"
  />
  <path
    d="M16 12L24 4"
    stroke="#6B8E23"
    stroke-width="2"
    class:grow-branch={animate}
    class="branch-tip"
    style="animation-delay: 0.4s"
  />
  <circle
    cx="12"
    cy="20"
    r="3"
    fill="#DAA520"
    opacity="0.8"
    class:bloom={animate}
    class="blossom-1"
  />
  <circle
    cx="20"
    cy="20"
    r="3"
    fill="#90EE90"
    opacity="0.8"
    class:bloom={animate}
    class="blossom-2"
    style="animation-delay: 0.2s"
  />
  <circle
    cx="16"
    cy="12"
    r="3"
    fill="#228B22"
    opacity="0.8"
    class:bloom={animate}
    class="blossom-3"
    style="animation-delay: 0.4s"
  />
  <circle
    cx="24"
    cy="4"
    r="3"
    fill="#87CEEB"
    opacity="0.5"
    class:bloom={animate}
    class="blossom-4"
    style="animation-delay: 0.6s"
  />
</svg>

<style>
  .branch-icon {
    display: inline-block;
    vertical-align: middle;
  }

  .grow-branch {
    animation: grow 0.8s ease-out forwards;
    stroke-dasharray: 50;
    stroke-dashoffset: 50;
  }

  .bloom {
    animation: bloom 0.5s ease-out forwards;
    transform: scale(0);
  }

  @keyframes grow {
    to {
      stroke-dashoffset: 0;
    }
  }

  @keyframes bloom {
    to {
      transform: scale(1);
    }
  }

  /* Respect user motion preferences */
  @media (prefers-reduced-motion: reduce) {
    .grow-branch,
    .bloom {
      animation: none;
      stroke-dashoffset: 0;
      transform: scale(1);
    }
  }
</style>
