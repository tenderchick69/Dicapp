import { writable } from 'svelte/store';
import { getDataStore } from './database';
import { gradeCardZen } from '@runedeck/core/scheduler';
import { uuid } from '@runedeck/core/models';
import type { WordWithScheduling } from '@runedeck/core/models';

/**
 * Minimal study store - no complexity, no hidden state
 */
interface StudyState {
  cards: WordWithScheduling[];
  index: number;
}

const initial: StudyState = { cards: [], index: 0 };
const { subscribe, set, update } = writable<StudyState>(initial);

export const studyStore = {
  subscribe,

  start(cards: WordWithScheduling[]) {
    // Force all cards to start at 0 - trust nothing
    const cleanCards = cards.map(c => ({
      ...c,
      scheduling: {
        ...c.scheduling,
        times_correct: c.scheduling.times_correct ?? 0,
        is_mastered: c.scheduling.is_mastered ?? 0,
      }
    }));
    set({ cards: cleanCards, index: 0 });
  },

  current(): WordWithScheduling | null {
    let result: WordWithScheduling | null = null;
    subscribe(s => {
      result = s.cards[s.index] || null;
    })();
    return result;
  },

  async grade(gotIt: boolean): Promise<{ oldCorrect: number; newCorrect: number }> {
    let oldCorrect = 0;
    let newCorrect = 0;

    const state = await new Promise<StudyState>(resolve => {
      subscribe(s => resolve(s))();
    });

    const card = state.cards[state.index];
    if (!card) return { oldCorrect: 0, newCorrect: 0 };

    oldCorrect = card.scheduling.times_correct ?? 0;

    const dataStore = await getDataStore();
    const newScheduling = gradeCardZen(card.scheduling, gotIt);
    newCorrect = newScheduling.times_correct ?? 0;

    await dataStore.upsertScheduling(newScheduling);
    await dataStore.addReview({
      id: uuid(),
      word_id: card.word.id,
      ts: Date.now(),
      grade: gotIt ? 2 : 1,
      elapsed_ms: 1000,
    });

    // Update card in place
    update(s => {
      const updated = [...s.cards];
      updated[s.index] = { ...card, scheduling: newScheduling };
      return { ...s, cards: updated };
    });

    return { oldCorrect, newCorrect };
  },

  next() {
    update(s => ({ ...s, index: s.index + 1 }));
  },

  end() {
    set(initial);
  },

  isActive(): boolean {
    let active = false;
    subscribe(s => {
      active = s.cards.length > 0 && s.index < s.cards.length;
    })();
    return active;
  },
};
