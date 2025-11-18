import type { IDataStore } from '../../data/src/IDataStore';
import type { Word, SchedulingData, WordWithScheduling, StudyScope } from '../models/types';

/**
 * Queue configuration
 */
export interface QueueConfig {
  dueLimit: number;
  newPerDay: number;
}

export const DEFAULT_QUEUE_CONFIG: QueueConfig = {
  dueLimit: 20,
  newPerDay: 10,
};

/**
 * Queue result
 */
export interface QueueResult {
  cards: WordWithScheduling[];
}

/**
 * Build study queue with due cards and new cards
 * @deprecated Use buildQueueByScope instead
 */
export async function buildQueue(
  store: IDataStore,
  deckId: string,
  config = DEFAULT_QUEUE_CONFIG
): Promise<QueueResult> {
  const { dueLimit, newPerDay } = config;

  const [due, fresh] = await Promise.all([
    store.getDue(deckId, dueLimit),
    store.getNew(deckId, newPerDay),
  ]);

  // Combine due and new cards
  const cards = [...due, ...fresh];

  return { cards };
}

/**
 * Build study queue using StudyScope (multi-deck support)
 */
export async function buildQueueByScope(
  store: IDataStore,
  scope: StudyScope,
  currentDeckId: string,
  config = DEFAULT_QUEUE_CONFIG
): Promise<QueueResult> {
  const { dueLimit, newPerDay } = config;

  const [due, fresh] = await Promise.all([
    store.getDueByScope(scope, currentDeckId, dueLimit),
    store.getNewByScope(scope, currentDeckId, newPerDay),
  ]);

  // Combine due and new cards
  const cards = [...due, ...fresh];

  return { cards };
}

/**
 * Session state for tracking study progress
 */
export class StudySession {
  private cards: WordWithScheduling[];
  private currentIndex: number = 0;
  private startTime: number = Date.now();
  private cardStartTime: number = Date.now();

  constructor(cards: WordWithScheduling[]) {
    this.cards = cards;
  }

  current(): WordWithScheduling | null {
    if (this.currentIndex >= this.cards.length) return null;
    return this.cards[this.currentIndex];
  }

  next(): void {
    this.currentIndex++;
    this.cardStartTime = Date.now();
  }

  elapsed(): number {
    return Date.now() - this.cardStartTime;
  }

  progress(): { current: number; total: number; percent: number } {
    const current = Math.min(this.currentIndex + 1, this.cards.length);
    const total = this.cards.length;
    const percent = total > 0 ? Math.round((current / total) * 100) : 0;
    return { current, total, percent };
  }

  isComplete(): boolean {
    return this.currentIndex >= this.cards.length;
  }

  totalElapsed(): number {
    return Date.now() - this.startTime;
  }
}
