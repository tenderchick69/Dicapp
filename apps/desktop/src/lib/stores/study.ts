import { writable, derived } from 'svelte/store';
import { getDataStore } from './database';
import { gradeCardZen } from '@runedeck/core/scheduler';
import { uuid } from '@runedeck/core/models';
import type { WordWithScheduling } from '@runedeck/core/models';

interface StudyState {
  sessionActive: boolean;
  cards: WordWithScheduling[];
  currentIndex: number;
  currentCard: WordWithScheduling | null;
}

function createStudyStore() {
  const { subscribe, set, update } = writable<StudyState>({
    sessionActive: false,
    cards: [],
    currentIndex: 0,
    currentCard: null,
  });

  return {
    subscribe,
    startSession: (cards: WordWithScheduling[]) => {
      set({
        sessionActive: true,
        cards,
        currentIndex: 0,
        currentCard: cards[0] || null,
      });
    },
    nextCard: () => {
      update((state) => {
        const nextIndex = state.currentIndex + 1;
        return {
          ...state,
          currentIndex: nextIndex,
          currentCard: state.cards[nextIndex] || null,
        };
      });
    },
    async gradeCardZen(cardId: string, gotIt: boolean) {
      const state = await new Promise<StudyState>((resolve) => {
        subscribe((s) => resolve(s))();
      });

      if (!state.currentCard) return;

      const dataStore = await getDataStore();
      const newScheduling = gradeCardZen(state.currentCard.scheduling, gotIt);

      await dataStore.upsertScheduling(newScheduling);
      await dataStore.addReview({
        id: uuid(),
        word_id: cardId,
        ts: Date.now(),
        grade: gotIt ? 2 : 1,
        elapsed_ms: 1000,
      });

      // Update current card with new scheduling
      update((s) => ({
        ...s,
        currentCard: s.currentCard ? {
          ...s.currentCard,
          scheduling: newScheduling,
        } : null,
      }));
    },
    endSession: () => {
      set({
        sessionActive: false,
        cards: [],
        currentIndex: 0,
        currentCard: null,
      });
    },
    reset: () => {
      set({
        sessionActive: false,
        cards: [],
        currentIndex: 0,
        currentCard: null,
      });
    },
  };
}

export const studyStore = createStudyStore();

export const isComplete = derived(
  studyStore,
  ($study) => !$study.sessionActive || $study.currentCard === null
);
