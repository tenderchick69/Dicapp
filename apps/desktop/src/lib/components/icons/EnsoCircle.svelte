<script lang="ts">
  export let size = 48;
  export let percent = 0; // 0-100 for progress ring

  const radius = 20;
  const circumference = 2 * Math.PI * radius;
  $: offset = circumference - (percent / 100) * circumference;
</script>

<svg
  width={size}
  height={size}
  viewBox="0 0 48 48"
  fill="none"
  xmlns="http://www.w3.org/2000/svg"
  class="enso-progress"
>
  <!-- Background circle (faint) -->
  <circle
    cx="24"
    cy="24"
    r={radius}
    stroke="#90EE90"
    stroke-width="4"
    fill="none"
    opacity="0.3"
  />

  <!-- Progress circle -->
  <circle
    cx="24"
    cy="24"
    r={radius}
    stroke="#228B22"
    stroke-width="4"
    fill="none"
    stroke-dasharray={circumference}
    stroke-dashoffset={offset}
    stroke-linecap="round"
    class="progress-ring"
  />

  <!-- Accent brush stroke effect -->
  <path
    d="M24 4A20 20 0 0 1 24 44"
    stroke="#DAA520"
    stroke-width="2"
    opacity="0.5"
  />
</svg>

<style>
  .enso-progress {
    display: inline-block;
    vertical-align: middle;
    filter: drop-shadow(0 2px 8px rgba(34, 139, 34, 0.3));
  }

  .progress-ring {
    transition: stroke-dashoffset 0.5s ease;
    transform: rotate(-90deg);
    transform-origin: 50% 50%;
  }
</style>
