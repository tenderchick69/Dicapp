import type { SchedulingData } from '../models/types';

/**
 * Zen Ladder scheduling configuration
 */
export interface ZenConfig {
  intervals: number[]; // Progressive intervals in days: [1, 1.2, 3, 12, 30]
  maxFailsPerSession: number; // Max times a card can be marked "Didn't Get It" in one session (default 3)
  dailyNewLimit: number; // Max new cards per day (default 20)
}

export const DEFAULT_ZEN_CONFIG: ZenConfig = {
  intervals: [1, 1.2, 3, 12, 30],
  maxFailsPerSession: 3,
  dailyNewLimit: 20,
};

/**
 * Grade a card using Zen Ladder algorithm
 *
 * @param s Current scheduling data
 * @param gotIt true = "Got It" button, false = "Didn't Get It" button
 * @param now Current timestamp (default: Date.now())
 * @param config Zen configuration
 * @returns Updated scheduling data
 */
export function gradeCardZen(
  s: SchedulingData,
  gotIt: boolean,
  now = Date.now(),
  config = DEFAULT_ZEN_CONFIG
): SchedulingData {
  const { intervals } = config;

  // "Didn't Get It" - Reset progress
  if (!gotIt) {
    return {
      ...s,
      times_correct: 0,
      lapses: s.lapses + 1,
      is_new: 0, // No longer "new" after first attempt
      // due_ts stays the same - card is pushed to end of queue in study logic
    };
  }

  // "Got It" - Progress up the ladder
  const newTimesCorrect = s.times_correct + 1;

  // Calculate interval based on times_correct (0-indexed into intervals array)
  const intervalIndex = Math.min(newTimesCorrect - 1, intervals.length - 1);
  const interval = intervals[intervalIndex];
  const due_ts = now + (interval * 86400000); // Convert days to milliseconds

  // Check if mastered (reached level 5)
  const isMastered = newTimesCorrect >= 5 ? 1 : 0;

  return {
    word_id: s.word_id,
    due_ts,
    interval,
    ease: s.ease, // Keep ease for compatibility (not used in zen algorithm)
    lapses: s.lapses,
    is_new: 0,
    times_correct: newTimesCorrect,
    is_mastered: isMastered,
  };
}

/**
 * Get the card's current level (0-4) based on times_correct
 * This is used for visual evolution of the card
 */
export function getCardLevel(s: SchedulingData): number {
  return Math.min(s.times_correct, 4);
}

/**
 * Check if card is mastered (reached graveyard)
 */
export function isMastered(s: SchedulingData): boolean {
  return s.is_mastered === 1;
}

/**
 * Check if a card is due for review
 */
export function isDue(s: SchedulingData, now = Date.now()): boolean {
  return s.due_ts <= now && !isMastered(s);
}

/**
 * Preview the next interval if user presses "Got It"
 * Used for UI display (e.g., "1 day", "3 days", "12 days")
 */
export function previewNextInterval(
  s: SchedulingData,
  config = DEFAULT_ZEN_CONFIG
): number | null {
  const { intervals } = config;

  if (isMastered(s)) {
    return null; // Mastered cards don't have a next interval
  }

  const nextIndex = Math.min(s.times_correct, intervals.length - 1);
  return intervals[nextIndex];
}

/**
 * Format interval for display
 * @param days Number of days
 * @returns Formatted string like "1 day", "3 days", "12 days"
 */
export function formatInterval(days: number): string {
  if (days < 1) {
    const hours = Math.round(days * 24);
    return hours === 1 ? '1 hour' : `${hours} hours`;
  }
  if (days === 1) return '1 day';
  if (days < 30) return `${Math.round(days)} days`;
  if (days < 365) {
    const months = Math.round(days / 30);
    return months === 1 ? '1 month' : `${months} months`;
  }
  const years = Math.round(days / 365);
  return years === 1 ? '1 year' : `${years} years`;
}
