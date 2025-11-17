<script lang="ts">
  export let size = 24;
</script>

<svg
  width={size}
  height={size}
  viewBox="0 0 24 24"
  fill="none"
  xmlns="http://www.w3.org/2000/svg"
  class="stone-icon"
>
  <circle cx="12" cy="12" r="10" fill="#D2B48C" opacity="0.8" />
  <path
    d="M12 12C12 12 10 10 8 12C6 14 8 16 12 16C16 16 18 14 16 12C14 10 12 12 12 12Z"
    fill="#F5F5DC"
    opacity="0.5"
  />
  <circle cx="12" cy="12" r="2" fill="#228B22" opacity="0.3" />
  <path
    d="M6 18C6 18 8 16 12 16C16 16 18 18 18 18"
    stroke="#90EE90"
    stroke-width="1"
  />
</svg>

<style>
  .stone-icon {
    display: inline-block;
    vertical-align: middle;
    filter: drop-shadow(0 2px 4px rgba(107, 122, 107, 0.3));
  }
</style>
