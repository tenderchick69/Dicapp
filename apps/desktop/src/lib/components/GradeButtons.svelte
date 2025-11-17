<script lang="ts">
  import type { Grade } from '@runedeck/core/models';

  export let onGrade: (grade: Grade) => void;
  export let disabled = false;

  const grades: Array<{ grade: Grade; label: string; key: string; color: string }> = [
    { grade: 1, label: 'Again', key: '1', color: 'var(--g-again)' },
    { grade: 2, label: 'Hard', key: '2', color: 'var(--g-hard)' },
    { grade: 3, label: 'Good', key: '3', color: 'var(--g-good)' },
    { grade: 4, label: 'Easy', key: '4', color: 'var(--g-easy)' },
  ];

  function handleGrade(grade: Grade) {
    if (!disabled) {
      onGrade(grade);
    }
  }
</script>

<div class="grade-buttons zen-buttons">
  {#each grades as { grade, label, key, color }}
    <button
      on:click={() => handleGrade(grade)}
      {disabled}
      class="zen-btn"
      style="--btn-color: {color}"
      data-grade={grade}
    >
      <div class="btn-ripple"></div>
      <div class="btn-content">
        <div class="btn-label">{label}</div>
        <div class="btn-key">{key}</div>
      </div>
    </button>
  {/each}
</div>

<style>
  /* Zen Grade Buttons - Nature-Inspired Stone/Pebble Design */
  .zen-buttons {
    display: flex;
    gap: 1rem;
    justify-content: center;
    padding: 1rem 0;
  }

  .zen-btn {
    position: relative;
    flex: 1;
    max-width: 160px;
    padding: 1.5rem 1rem;
    border: none;
    cursor: pointer;
    overflow: hidden;
    font-family: var(--font-body);

    /* Stone-like organic shape - softer than card, still organic */
    border-radius: 45% 55% 48% 52% / 52% 48% 55% 45%;

    /* Nature gradient with texture */
    background:
      linear-gradient(135deg, var(--btn-color) 0%, color-mix(in srgb, var(--btn-color) 70%, black) 100%),
      repeating-linear-gradient(
        45deg,
        transparent,
        transparent 4px,
        rgba(255, 255, 255, 0.05) 4px,
        rgba(255, 255, 255, 0.05) 8px
      );

    /* Zen shadow - soft and natural */
    box-shadow:
      0 4px 12px color-mix(in srgb, var(--btn-color) 40%, transparent),
      inset 0 1px 2px rgba(255, 255, 255, 0.2),
      inset 0 -2px 4px rgba(0, 0, 0, 0.2);

    transition: all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
    will-change: transform, box-shadow;
  }

  .zen-btn:hover:not(:disabled) {
    transform: translateY(-4px) scale(1.05) rotate(0.5deg);
    box-shadow:
      0 8px 24px color-mix(in srgb, var(--btn-color) 50%, transparent),
      inset 0 1px 3px rgba(255, 255, 255, 0.3),
      inset 0 -2px 6px rgba(0, 0, 0, 0.25),
      0 0 0 2px color-mix(in srgb, var(--btn-color) 60%, white);
  }

  .zen-btn:active:not(:disabled) {
    transform: translateY(-1px) scale(1.02);
    box-shadow:
      0 2px 8px color-mix(in srgb, var(--btn-color) 30%, transparent),
      inset 0 1px 2px rgba(255, 255, 255, 0.15),
      inset 0 -1px 3px rgba(0, 0, 0, 0.3);
  }

  .zen-btn:disabled {
    opacity: 0.4;
    cursor: not-allowed;
    transform: none !important;
    filter: grayscale(0.5);
  }

  /* Button content */
  .btn-content {
    position: relative;
    z-index: 2;
    pointer-events: none;
  }

  .btn-label {
    font-size: 1.125rem;
    font-weight: 600;
    color: rgba(255, 255, 255, 0.95);
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.3);
    letter-spacing: 0.02em;
    margin-bottom: 0.25rem;
  }

  .btn-key {
    font-size: 0.75rem;
    font-family: var(--font-mono);
    color: rgba(255, 255, 255, 0.7);
    text-shadow: 0 1px 1px rgba(0, 0, 0, 0.2);
  }

  /* Ripple effect on click */
  .btn-ripple {
    position: absolute;
    inset: 0;
    background: radial-gradient(
      circle at center,
      rgba(255, 255, 255, 0.4) 0%,
      rgba(255, 255, 255, 0.2) 40%,
      transparent 70%
    );
    opacity: 0;
    transform: scale(0.5);
    pointer-events: none;
    z-index: 1;
  }

  .zen-btn:active:not(:disabled) .btn-ripple {
    animation: ripple-out 0.6s ease-out;
  }

  @keyframes ripple-out {
    0% {
      opacity: 0;
      transform: scale(0.5) rotate(0deg);
    }
    30% {
      opacity: 1;
    }
    100% {
      opacity: 0;
      transform: scale(1.8) rotate(8deg);
    }
  }

  /* Individual button color variations (subtle texture differences) */
  .zen-btn[data-grade="1"] {
    /* Again - Rocky/difficult */
    border-radius: 48% 52% 45% 55% / 50% 50% 52% 48%;
  }

  .zen-btn[data-grade="2"] {
    /* Hard - Sunset/challenging */
    border-radius: 52% 48% 50% 50% / 48% 52% 48% 52%;
  }

  .zen-btn[data-grade="3"] {
    /* Good - Growth/success */
    border-radius: 50% 50% 52% 48% / 52% 48% 50% 50%;
  }

  .zen-btn[data-grade="4"] {
    /* Easy - Clarity/mastery */
    border-radius: 45% 55% 50% 50% / 50% 50% 55% 45%;
  }

  /* Respect user motion preferences */
  @media (prefers-reduced-motion: reduce) {
    .zen-btn {
      transition: opacity 0.2s ease;
    }

    .zen-btn:hover:not(:disabled) {
      transform: none;
    }

    .zen-btn:active:not(:disabled) {
      transform: none;
    }

    .btn-ripple {
      animation: none !important;
    }
  }

  /* Responsive adjustments */
  @media (max-width: 768px) {
    .zen-buttons {
      gap: 0.5rem;
    }

    .zen-btn {
      max-width: none;
      padding: 1.25rem 0.75rem;
    }

    .btn-label {
      font-size: 1rem;
    }

    .btn-key {
      font-size: 0.7rem;
    }
  }
</style>
