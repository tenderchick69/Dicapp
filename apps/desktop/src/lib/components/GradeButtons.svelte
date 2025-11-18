<script lang="ts">
  // Zen two-button system: Got It (true) / Didn't Get It (false)
  export let onGrade: (gotIt: boolean) => void;
  export let disabled = false;

  function handleGrade(gotIt: boolean) {
    if (!disabled) {
      onGrade(gotIt);
    }
  }
</script>

<div class="zen-two-buttons">
  <!-- Didn't Get It - Red Brown -->
  <button
    on:click={() => handleGrade(false)}
    {disabled}
    class="zen-btn zen-btn-fail"
    data-key="1"
  >
    <div class="btn-content">
      <div class="btn-label">Didn't Get It</div>
      <div class="btn-key">1</div>
    </div>
  </button>

  <!-- Got It - Forest Green -->
  <button
    on:click={() => handleGrade(true)}
    {disabled}
    class="zen-btn zen-btn-pass"
    data-key="2"
  >
    <div class="btn-content">
      <div class="btn-label">Got It</div>
      <div class="btn-key">2</div>
    </div>
  </button>
</div>

<style>
  /* Zen Two-Button System - Full Width, Minimal */
  .zen-two-buttons {
    display: flex;
    gap: 1rem;
    padding: 1rem 0;
  }

  .zen-btn {
    flex: 1;
    padding: 2rem 1.5rem;
    border: none;
    border-radius: var(--radius);
    cursor: pointer;
    font-family: var(--font-body);
    transition: all 0.2s ease;
  }

  .zen-btn:disabled {
    opacity: 0.4;
    cursor: not-allowed;
  }

  .zen-btn-fail {
    background: var(--g-again);
    color: white;
  }

  .zen-btn-fail:hover:not(:disabled) {
    transform: translateY(-2px);
    box-shadow: 0 8px 20px rgba(139, 69, 19, 0.4);
  }

  .zen-btn-fail:active:not(:disabled) {
    transform: translateY(0);
    box-shadow: 0 4px 12px rgba(139, 69, 19, 0.3);
  }

  .zen-btn-pass {
    background: var(--g-good);
    color: white;
  }

  .zen-btn-pass:hover:not(:disabled) {
    transform: translateY(-2px);
    box-shadow: 0 8px 20px rgba(34, 139, 34, 0.4);
  }

  .zen-btn-pass:active:not(:disabled) {
    transform: translateY(0);
    box-shadow: 0 4px 12px rgba(34, 139, 34, 0.3);
  }

  .btn-content {
    pointer-events: none;
  }

  .btn-label {
    font-size: 1.25rem;
    font-weight: 600;
    margin-bottom: 0.25rem;
  }

  .btn-key {
    font-size: 0.75rem;
    font-family: var(--font-mono);
    opacity: 0.7;
  }

  @media (prefers-reduced-motion: reduce) {
    .zen-btn {
      transition: none;
    }
    .zen-btn:hover:not(:disabled),
    .zen-btn:active:not(:disabled) {
      transform: none;
    }
  }

  @media (max-width: 768px) {
    .zen-two-buttons {
      gap: 0.75rem;
    }
    .zen-btn {
      padding: 1.5rem 1rem;
    }
    .btn-label {
      font-size: 1.1rem;
    }
  }
</style>
