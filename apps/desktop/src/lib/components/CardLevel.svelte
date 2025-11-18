<!-- src/lib/components/CardLevel.svelte -->
<script lang="ts">
  export let level: number = 0;   // 0-4 ONLY. 5 is forbidden here.
</script>

<div class="card level-{level}">
  <slot />
</div>

<style>
  .card {
    background: #fffff0;
    border-radius: 2rem;
    padding: 2rem;
    box-shadow: 0 8px 32px rgba(0,0,0,0.2);
    transition: all 0.6s cubic-bezier(0.16, 1, 0.3, 1);
    position: relative;
    overflow: hidden;
  }

  .level-0::before { content: '💧'; position: absolute; top: 1rem; right: 1rem; opacity: 0.3; font-size: 3rem; }
  .level-1 { background: #fff8e6; border: 3px solid gold; }
  .level-2 { background: #fff2e6; }
  .level-3 { background: #f0fdf4; }
  .level-4 { background: #ecfdf5; box-shadow: 0 0 40px rgba(34, 197, 94, 0.4); }

  /* NO LEVEL 5 STYLE. NO MASTERED TEXT. EVER. */
</style>
