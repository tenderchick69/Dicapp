# VOC APP - Complete Architecture & Implementation Guide

**Version:** 1.1.0
**Last Updated:** 2025-01-18
**Status:** Active Development - Major UX Redesign In Progress
**Theme:** Zen Serenity Edition

---

## 📋 Table of Contents

1. [Project Overview](#project-overview)
2. [Vision & Goals](#vision--goals)
3. [Tech Stack](#tech-stack)
4. [Project Structure](#project-structure)
5. [Architecture Layers](#architecture-layers)
6. [Database Schema](#database-schema)
7. [Data Flow](#data-flow)
8. [State Management](#state-management)
9. [Key Features](#key-features)
10. [Current Status](#current-status)
11. [Planned Changes](#planned-changes)
12. [Known Issues](#known-issues)
13. [Development Workflow](#development-workflow)
14. [Deployment](#deployment)
15. [For AI Collaborators](#for-ai-collaborators)

---

## 🎯 Project Overview

**VOC APP** (formerly RuneDeck) is an advanced vocabulary training application built with spaced repetition learning at its core. Think Anki, but modern, beautiful, and focused on vocabulary learning.

### Key Differentiators

- **Offline-first**: Works completely offline, no cloud dependency
- **Cross-platform**: Desktop (Tauri) + Web (PWA) with shared codebase
- **Beautiful UX**: Zen Serenity theme with nature-inspired design
- **Type-safe**: Full TypeScript with Zod validation
- **Simple & Powerful**: Easy for beginners, powerful for advanced users

---

## 🎨 Vision & Goals

### Core Philosophy

> "Learning vocabulary should feel like a walk in a zen garden - calm, focused, naturally progressive."

### Primary Goals

1. **Simplicity First**: One button to play deck, two buttons to grade (Got It / Didn't Get It)
2. **Progressive Mastery**: Clear path from "new" → "learning" → "mastered"
3. **No Cognitive Overhead**: Hide complexity, expose only what matters
4. **Beautiful by Default**: Zen aesthetic that reduces stress
5. **User Owns Data**: Full export/import, no lock-in

### Current Major Redesign (In Progress)

**FROM** (Current - Complex):
- 4 card states (New, Learning, Retention, Leeches)
- 4 grade buttons (Again, Hard, Good, Easy)
- Multiple study modes (Review, Learn New, Learn)
- Confusing stats (Learning %, Retention %, Leeches)

**TO** (Target - Simple):
- Unified study experience: "Play Deck" button
- 2 grade buttons: "Didn't Get It" (red) vs "Got It" (green)
- Progressive intervals: 1 day → 1.2 days → 3 days → 12 days → 30 days (mastered)
- Simple stats: "X cards due today" + total count
- Optional "graveyard" for mastered cards

---

## 🛠️ Tech Stack

### Frontend

- **SvelteKit** (v2.0+) - Full-stack framework
  - Why: Smaller bundle, faster than React, great DX
  - SSR/SSG support for web deploy
  - File-based routing

- **Svelte 4** - UI framework
  - Reactive stores for state
  - Compiler optimizations
  - No virtual DOM overhead

- **TypeScript** (v5.3+) - Type safety
  - Strict mode enabled
  - Zod for runtime validation

- **Tailwind CSS** - Utility-first styling
  - Custom theme tokens
  - Dark/light mode support

### Desktop Platform

- **Tauri 2** - Native app framework
  - Rust backend
  - WebView for UI
  - ~5MB binary size
  - Native SQLite via `tauri-plugin-sql`

### Web Platform

- **sql.js** - SQLite in browser (WASM)
  - Same SQL dialect as desktop
  - IndexedDB persistence
  - ~2MB overhead

### Backend (Cloud - Optional)

- **Supabase** - PostgreSQL + Auth
  - Only for multi-device sync (Phase 3)
  - Row-level security (RLS)
  - Currently used for: auth, public deck sharing

### Core Libraries

- **Papa Parse** - CSV import/export
- **Zod** - Schema validation
- **date-fns** - Date manipulation
- **nanoid** - ID generation

### Development

- **Vite** - Build tool (fast HMR)
- **Vitest** - Unit testing
- **pnpm** - Fast package manager
- **Monorepo** - Workspace-based architecture

---

## 📁 Project Structure

```
DICAPP/
├── apps/
│   ├── desktop/              # Tauri desktop app
│   │   ├── src/
│   │   │   ├── routes/       # SvelteKit pages
│   │   │   │   ├── +page.svelte           # Home page
│   │   │   │   ├── study/+page.svelte     # Study session
│   │   │   │   ├── import/+page.svelte    # CSV import
│   │   │   │   ├── clinic/+page.svelte    # Leech management
│   │   │   │   ├── settings/+page.svelte  # Settings
│   │   │   │   ├── decks/+page.svelte     # Deck manager
│   │   │   │   ├── explore/+page.svelte   # Public decks
│   │   │   │   ├── complete/+page.svelte  # Session end
│   │   │   │   └── +layout.svelte         # Root layout
│   │   │   ├── lib/
│   │   │   │   ├── components/
│   │   │   │   │   ├── Card.svelte        # Flashcard UI
│   │   │   │   │   ├── GradeButtons.svelte
│   │   │   │   │   ├── Header.svelte      # Navigation
│   │   │   │   │   ├── FallingLeaves.svelte # Zen background
│   │   │   │   │   └── icons/             # Nature SVG icons
│   │   │   │   ├── stores/
│   │   │   │   │   ├── auth.ts            # Supabase auth
│   │   │   │   │   ├── database.ts        # DB singleton
│   │   │   │   │   ├── deck.ts            # Deck state
│   │   │   │   │   ├── scope.ts           # Study scope
│   │   │   │   │   ├── settings.ts        # User settings
│   │   │   │   │   └── study.ts           # Study session
│   │   │   │   └── supabase.ts            # Supabase client
│   │   │   ├── app.css                    # Global styles
│   │   │   └── app.html                   # HTML template
│   │   └── src-tauri/        # Rust backend
│   │       ├── src/main.rs   # Entry point
│   │       └── Cargo.toml    # Rust deps
│   └── web/                  # Web PWA (future)
│
├── packages/
│   ├── core/                 # Business logic (shared)
│   │   ├── src/
│   │   │   ├── models/       # TypeScript types
│   │   │   │   ├── types.ts  # Zod schemas
│   │   │   │   └── utils.ts  # Model helpers
│   │   │   ├── scheduler/    # Spaced repetition
│   │   │   │   ├── sm2.ts    # SM-2 algorithm
│   │   │   │   └── sm2.test.ts
│   │   │   ├── queue/        # Study queue builder
│   │   │   │   └── builder.ts
│   │   │   └── csv/          # Import/export
│   │   │       └── parser.ts
│   │   └── package.json
│   │
│   ├── data/                 # Database layer (shared)
│   │   ├── src/
│   │   │   ├── IDataStore.ts      # Interface
│   │   │   ├── SqliteStore.ts     # Desktop DB
│   │   │   ├── WasmSqliteStore.ts # Web DB
│   │   │   ├── CloudStore.ts      # Supabase DB
│   │   │   └── schema.ts          # SQL migrations
│   │   └── package.json
│   │
│   └── ui/                   # Shared components (future)
│
├── scripts/                  # Utilities
│   └── sample-deck.csv       # Sample data
│
├── package.json              # Root workspace
├── pnpm-workspace.yaml       # Monorepo config
├── ARCHITECTURE.md           # This file
├── STATUS.md                 # Implementation status
├── ZEN_THEME_IMPLEMENTATION.md
└── README.md
```

---

## 🏗️ Architecture Layers

### High-Level Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     User Interface                          │
│  ┌──────────────────────┐      ┌──────────────────────┐   │
│  │   Desktop (Tauri)    │      │    Web (PWA)         │   │
│  │  • Windows/Mac/Linux │      │  • Browser-based     │   │
│  │  • Native binary     │      │  • Offline capable   │   │
│  │  • SQLite via Rust   │      │  • sql.js (WASM)     │   │
│  └──────────┬───────────┘      └──────────┬───────────┘   │
│             │                              │               │
│             └──────────┬───────────────────┘               │
│                        │                                   │
│              ┌─────────▼──────────┐                        │
│              │   SvelteKit UI     │                        │
│              │  • Pages (routes)  │                        │
│              │  • Components      │                        │
│              │  • Stores (state)  │                        │
│              └─────────┬──────────┘                        │
│                        │                                   │
│              ┌─────────▼──────────┐                        │
│              │   Data Package     │                        │
│              │  • IDataStore      │  ◄── Interface layer   │
│              │  • SqliteStore     │  ◄── Desktop impl     │
│              │  • WasmSqliteStore │  ◄── Web impl         │
│              │  • CloudStore      │  ◄── Supabase impl    │
│              └─────────┬──────────┘                        │
│                        │                                   │
│              ┌─────────▼──────────┐                        │
│              │   Core Package     │                        │
│              │  • Models (types)  │                        │
│              │  • SM-2 Scheduler  │                        │
│              │  • Queue Builder   │                        │
│              │  • CSV Parser      │                        │
│              └────────────────────┘                        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Layer Responsibilities

**Layer 1: UI (SvelteKit)**
- Rendering pages
- User interactions
- Routing
- Theme management
- State reactivity

**Layer 2: Data (IDataStore)**
- Database abstraction
- CRUD operations
- Query optimization
- Transaction handling
- Platform-specific implementations

**Layer 3: Core (Business Logic)**
- Spaced repetition algorithm
- Data validation
- CSV parsing
- Queue building
- Pure functions (no side effects)

---

## 🗄️ Database Schema

### Current Schema (Version 2)

```sql
-- Schema version tracking
CREATE TABLE schema_version (
  version INTEGER PRIMARY KEY
);

-- Decks (collections of words)
CREATE TABLE decks (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  slug TEXT NOT NULL UNIQUE,
  profile TEXT NOT NULL CHECK(profile IN ('simple', 'full')),
  created_at INTEGER NOT NULL,
  config_json TEXT NOT NULL  -- JSON: {newPerDay, dueLimit, leechThreshold, ...}
);

-- Vocabulary words
CREATE TABLE words (
  id TEXT PRIMARY KEY,
  deck_id TEXT NOT NULL REFERENCES decks(id) ON DELETE CASCADE,
  headword TEXT NOT NULL,           -- Main word
  pos TEXT,                          -- Part of speech
  ipa TEXT,                          -- Pronunciation (IPA)
  definition TEXT NOT NULL,          -- Primary definition
  example TEXT,                      -- Example sentence
  gloss_de TEXT,                     -- German translation
  etymology TEXT,                    -- Word origin
  mnemonic TEXT,                     -- Memory aid
  tags TEXT,                         -- JSON array of tags
  freq REAL DEFAULT 3.0,             -- Frequency (1-5, for rarity gem)
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

-- Spaced repetition scheduling
CREATE TABLE scheduling (
  word_id TEXT PRIMARY KEY REFERENCES words(id) ON DELETE CASCADE,
  due_ts INTEGER NOT NULL,           -- Unix timestamp when card is due
  interval REAL NOT NULL DEFAULT 0,  -- Days until next review
  ease REAL NOT NULL DEFAULT 2.5,    -- Ease factor (SM-2)
  lapses INTEGER NOT NULL DEFAULT 0, -- Times card was failed
  is_new INTEGER NOT NULL DEFAULT 1  -- 1 = never reviewed, 0 = seen
);

-- Review history (for statistics)
CREATE TABLE reviews (
  id TEXT PRIMARY KEY,
  word_id TEXT NOT NULL REFERENCES words(id) ON DELETE CASCADE,
  ts INTEGER NOT NULL,               -- Unix timestamp of review
  grade INTEGER NOT NULL CHECK(grade IN (1,2,3,4)),  -- Button pressed
  elapsed_ms INTEGER NOT NULL        -- Time spent on card
);

-- User settings (key-value store)
CREATE TABLE settings (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL
);

-- Indexes for performance
CREATE INDEX idx_words_headword ON words(headword);
CREATE INDEX idx_words_deck ON words(deck_id);
CREATE INDEX idx_words_freq ON words(freq);
CREATE INDEX idx_sched_due ON scheduling(due_ts);
CREATE INDEX idx_sched_lapses ON scheduling(lapses);
CREATE INDEX idx_reviews_word ON reviews(word_id);
CREATE INDEX idx_reviews_ts ON reviews(ts);
CREATE INDEX idx_decks_slug ON decks(slug);
```

### Entity Relationships

```
decks (1) ──────► (N) words
                       │
          ┌────────────┼────────────┐
          │                         │
          ▼ (1)                 (N) ▼
    scheduling               reviews
     (1:1)                    (1:N)
```

### Planned Schema Changes (Next Sprint)

Add columns to `scheduling` table for simplified system:

```sql
ALTER TABLE scheduling ADD COLUMN times_correct INTEGER DEFAULT 0;
ALTER TABLE scheduling ADD COLUMN is_mastered INTEGER DEFAULT 0;
```

**Purpose:**
- `times_correct`: Count consecutive correct answers (0-5)
- `is_mastered`: 1 = card graduated to "graveyard", 0 = still active

---

## 🔄 Data Flow

### Study Session Flow (Current)

```
1. User clicks "Play Deck"
   │
   ├──> Load deck configuration
   ├──> Build study queue:
   │    ├──> getDueByScope() ──► SQL: WHERE due_ts <= NOW() AND is_new = 0
   │    ├──> getNewByScope() ──► SQL: WHERE is_new = 1
   │    └──> Mix new + due cards
   │
   ├──> Initialize StudySession
   │    └──> Load first card
   │
2. User views card → presses "Reveal" (if retention mode)
   │
3. User grades card (1-4)
   │
   ├──> gradeCard(scheduling, grade)  ← SM-2 algorithm
   │    ├──> Calculate new interval
   │    ├──> Adjust ease factor
   │    ├──> Set new due_ts
   │    └──> Return updated SchedulingData
   │
   ├──> dataStore.upsertScheduling()  ← Save to DB
   │
   ├──> dataStore.addReview()         ← Log review event
   │
   ├──> If grade = 1 (Again):
   │    └──> Add to againQueue (re-review in same session)
   │
   └──> studyStore.nextCard()
        ├──> If queue empty + againQueue not empty:
        │    └──> studyStore.addCards(againQueue)
        └──> Show next card
```

### Study Session Flow (Planned - Simplified)

```
1. User clicks "Play Deck"
   │
   ├──> Get due cards:
   │    SQL: WHERE is_mastered = 0 AND (is_new = 1 OR due_ts <= NOW())
   │
   ├──> Mix and shuffle
   │
   └──> Start session
   │
2. User views card
   │
3. User clicks "Got It" (green) or "Didn't Get It" (red)
   │
   ├──> If "Didn't Get It":
   │    ├──> times_correct = 0 (reset)
   │    ├──> lapses++
   │    └──> Add to againQueue (review again in session)
   │
   └──> If "Got It":
        ├──> times_correct++
        ├──> interval = [1, 1.2, 3, 12, 30][times_correct-1]
        ├──> due_ts = NOW() + interval * 86400000
        ├──> If times_correct >= 5:
        │    └──> is_mastered = 1 (goes to graveyard)
        └──> Move to next card
```

### CSV Import Flow

```
1. User uploads CSV file
   │
   ├──> Papa.parse(file, { preview: 20 })
   │    └──> Show preview table
   │
2. User clicks "Import"
   │
   ├──> Papa.parse(file, { complete })
   │    └──> Parse all rows
   │
   ├──> For each row:
   │    ├──> Validate with Zod schema
   │    ├──> Create Word object with UUID
   │    ├──> Create initial SchedulingData
   │    └──> Collect errors
   │
   ├──> dataStore.batchImportWords(words)
   │    └──> Transaction:
   │         ├──> INSERT INTO words ...
   │         └──> INSERT INTO scheduling ...
   │
   └──> Show success/error summary
```

---

## 📦 State Management

### Svelte Stores Architecture

```typescript
// Singleton pattern
export const authStore = writable<AuthState>({ user: null, loading: true });
export const deckStore = writable<DeckState>({ decks: [], currentDeckId: null });
export const scopeStore = writable<StudyScope>({ type: 'current' });
export const settingsStore = writable<Settings>(DEFAULT_SETTINGS);
export const themeStore = writable<'dark' | 'light'>('dark');

// Derived store
export const studyStore = createStudyStore();  // Complex study session logic
```

### Store Responsibilities

**authStore** (`lib/stores/auth.ts`)
- Supabase authentication
- User session management
- Sign in/out logic

**deckStore** (`lib/stores/deck.ts`)
- Load all decks
- Current deck selection
- Deck CRUD operations

**scopeStore** (`lib/stores/scope.ts`)
- Study scope (current deck, all decks, or custom)
- Used for multi-deck statistics

**settingsStore** (`lib/stores/settings.ts`)
- User preferences
- Theme, limits, thresholds
- Persists to localStorage

**studyStore** (`lib/stores/study.ts`)
- Study session state
- Current card, progress, revealed state
- Queue management
- Methods: startSession(), reveal(), nextCard(), reset()

**databaseStore** (`lib/stores/database.ts`)
- Singleton IDataStore instance
- Platform detection (Tauri vs Web)
- Returns SqliteStore or WasmSqliteStore

### State Flow Pattern

```
User Action → Component Event Handler → Store Update → Reactive UI Update
```

Example:
```typescript
// In +page.svelte
function handleGrade(grade: Grade) {
  studyStore.grade(grade);  // Updates store
  // Svelte reactivity triggers re-render
}

$: currentCard = $studyStore.currentCard;  // Reactive variable
```

---

## ⚡ Key Features

### 1. Spaced Repetition (SM-2 Algorithm)

**Current Implementation:**
- 4 grade buttons (Again, Hard, Good, Easy)
- Ease factor adjustment based on performance
- Interval growth: 1 day → ease × interval
- Lapse tracking (cards that fail repeatedly)

**Files:**
- `packages/core/src/scheduler/sm2.ts` - Algorithm
- `packages/core/src/scheduler/sm2.test.ts` - Tests (100% coverage)

**Planned Simplification:**
- 2 buttons (Got It, Didn't Get It)
- Fixed interval progression: 1d → 1.2d → 3d → 12d → 30d
- Mastery at 5 correct in a row

### 2. Multi-Deck Support

- Create unlimited decks
- Per-deck configuration (newPerDay, dueLimit, etc.)
- Study across all decks or filter by current
- Import CSV to specific deck

**Files:**
- `apps/desktop/src/routes/decks/+page.svelte` - Deck manager
- `lib/stores/deck.ts` - Deck state
- `lib/stores/scope.ts` - Multi-deck querying

### 3. CSV Import/Export

**Import:**
- Papa Parse library
- Preview first 20 rows
- Row-level error reporting
- Batch insert with transaction
- Supports "simple" (2 columns) or "full" (10 columns) profiles

**Export:**
- CSV format (all fields)
- JSON format (words + reviews for backup)

**Files:**
- `apps/desktop/src/routes/import/+page.svelte`
- `packages/core/src/csv/parser.ts`

### 4. Zen Serenity Theme

**Phase 1-3 Complete:**
- Beige background (#f5f5dc)
- Nature-inspired colors (goldenrod, forest green, sky blue)
- Lora serif font (calm, readable)
- Organic card shapes (leaf-like border-radius)
- Floating animation (subtle vertical bounce)
- Water ripple effect on reveal

**Phase 4-5 In Progress:**
- Falling leaves background (animated SVG)
- Nature icon library (seedling, lotus, bamboo, water drop, etc.)
- Stats visualization with enso circle progress ring

**Files:**
- `apps/desktop/src/app.css` - Global theme
- `apps/desktop/src/lib/components/Card.svelte` - Card design
- `apps/desktop/src/lib/components/FallingLeaves.svelte`
- `apps/desktop/src/lib/components/icons/` - Icon components

### 5. Keyboard Navigation

- **R** - Reveal card (retention mode)
- **1** - Again (fail)
- **2** - Hard
- **3** - Good
- **4** - Easy
- **Esc** - Exit to home
- Automatically disabled when typing in input fields

**Files:**
- `apps/desktop/src/routes/study/+page.svelte` (handleKeyboard function)

### 6. Cloud Sync (Optional - Supabase)

**Currently Implemented:**
- User authentication (email/password, OAuth)
- Public deck sharing (explore page)
- CloudStore for Supabase backend

**Planned:**
- Multi-device sync with conflict resolution
- E2EE for user data

**Files:**
- `packages/data/src/CloudStore.ts`
- `lib/stores/auth.ts`
- `lib/supabase.ts`

---

## ✅ Current Status

### What's Working

- ✅ Desktop app launches (Tauri)
- ✅ Multi-deck support (create, edit, delete, switch)
- ✅ CSV import/export
- ✅ Study session with SM-2
- ✅ Keyboard navigation
- ✅ Theme system (dark/light toggle)
- ✅ Stats display (total, new, due, learning, retention, leeches)
- ✅ Clinic view for leeches
- ✅ Settings page
- ✅ Supabase auth
- ✅ Public deck browsing (explore page)
- ✅ Practice modes (Learn New, Learn)
- ✅ "Again" loop (cards marked Again come back in same session)
- ✅ Reset deck feature
- ✅ Falling leaves background animation
- ✅ Nature icon library (10 SVG icons)
- ✅ Deck switcher in header dropdown

### Recent Fixes (Last Session)

1. **Practice Mode Bug**: Fixed `getAllWordsByScope` to properly fetch learning cards regardless of due dates
2. **Reset Deck Error**: Fixed PostgreSQL boolean/integer mismatch in CloudStore
3. **Study Crash**: Fixed stale state reference causing "Cannot read properties of undefined" error when pressing Again
4. **Button Labels**: Simplified to "Learn New" and "Learn"
5. **Home Navigation**: Fixed unwanted redirect to completion screen when clicking Home button
6. **Visual Issues**:
   - Removed pixelated background texture
   - Made falling leaves bigger (50px)
   - Fixed deck switcher z-index to always be clickable

### Known Issues

1. ❌ **Stats Calculation Bug**: Retention % shows incorrect value (40% when should be 0% after reset)
2. ❌ **Deck Switcher**: Still reports as not working despite z-index fix (needs further investigation)
3. ❌ **Too Many Buttons**: User finds 3 study modes confusing ("Learn New", "Learn", redundant with overall deck play)
4. ❌ **4 Grade Buttons**: Too complex, users only need "Got It" vs "Didn't Get It"
5. ❌ **Leeches Category**: Confusing terminology, threshold too high (8 failures), remove or rename

### In Progress

- 🔄 **Major UX Redesign**: Simplifying to 2-button system (see Planned Changes below)

---

## 🚀 Planned Changes

### CRITICAL: UX Simplification (Next Sprint)

#### 1. Database Schema Update

Add to `scheduling` table:
```sql
ALTER TABLE scheduling ADD COLUMN times_correct INTEGER DEFAULT 0;
ALTER TABLE scheduling ADD COLUMN is_mastered INTEGER DEFAULT 0;
```

Run migration in all 3 stores (SqliteStore, WasmSqliteStore, CloudStore).

#### 2. Grading Logic Simplification

**Replace** 4-button SM-2 with 2-button progressive system:

```typescript
function gradeCardSimplified(scheduling: SchedulingData, gotIt: boolean): SchedulingData {
  if (!gotIt) {
    return {
      ...scheduling,
      times_correct: 0,  // Reset
      lapses: scheduling.lapses + 1,
    };
  }

  const timesCorrect = scheduling.times_correct + 1;
  const intervals = [1, 1.2, 3, 12, 30];  // Fixed progression
  const interval = intervals[Math.min(timesCorrect - 1, 4)];
  const isMastered = timesCorrect >= 5 ? 1 : 0;

  return {
    ...scheduling,
    times_correct: timesCorrect,
    interval,
    due_ts: Date.now() + (interval * 86400000),
    is_new: 0,
    is_mastered: isMastered,
  };
}
```

#### 3. UI Changes

**Home Page:**
- Remove: "Learn New", "Learn" buttons
- Replace with: Single large "Play Deck" button
- Stats: Show only "X cards due today" (remove learning %, retention %, leeches)

**Study Page:**
- Remove: 4 grade buttons (Again, Hard, Good, Easy)
- Replace with: 2 large buttons
  - Red/Brown: "Didn't Get It" (adds to againQueue)
  - Green: "Got It" (progressive intervals)

**Stats Calculation:**
```typescript
async getDueStats() {
  const total = COUNT(*) FROM words WHERE deck_id = ?;
  const due = COUNT(*) FROM scheduling s
    INNER JOIN words w ON s.word_id = w.id
    WHERE w.deck_id = ?
      AND s.is_mastered = 0
      AND (s.is_new = 1 OR s.due_ts <= NOW());
  const mastered = COUNT(*) WHERE is_mastered = 1;

  return { total, due, mastered };
}
```

#### 4. Remove Leeches Concept

- Don't show "Leeches" stat
- Remove clinic view (or rename to "Difficult Cards")
- Difficult cards just come back more frequently naturally

#### 5. Graveyard View (Optional)

- Add "View Mastered Cards" link (separate page)
- Shows cards with `is_mastered = 1`
- Option to "un-master" and bring back to active learning

---

## 🐛 Known Issues

### High Priority

1. **Stats Retention Calculation**: Shows 40% when should be 0-5%. Check `getStatsByScope` query.
2. **Deck Switcher**: User reports still can't click decks in dropdown despite z-index fix.
3. **Web App**: WasmSqliteStore not fully tested/wired to web app build.

### Medium Priority

1. **PWA Build**: Not configured yet (vite-plugin-pwa needed)
2. **Mobile**: No touch gestures, card swipe not implemented
3. **Performance**: Large decks (1000+ cards) not tested for sql.js memory usage

### Low Priority

1. **Icons**: Still using placeholder favicon, need to generate Tauri app icons
2. **Tests**: Only SM-2 scheduler has tests, need integration tests for stores
3. **Accessibility**: Focus indicators could be more visible

---

## 💻 Development Workflow

### Prerequisites

```bash
# Install Node.js 18+
# Install pnpm
npm install -g pnpm

# Install Rust (for Tauri desktop builds)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Clone repo
git clone <repo-url>
cd DICAPP

# Install dependencies
pnpm install
```

### Common Commands

```bash
# Development
pnpm dev:desktop         # Run Tauri dev mode
pnpm dev:web             # Run web dev mode (browser)

# Build
pnpm build:desktop       # Build desktop installer (MSI/DMG/DEB)
pnpm build:web           # Build static web app

# Testing
pnpm test                # Run Vitest unit tests
pnpm test:watch          # Watch mode

# Type checking
pnpm type-check          # Check all TypeScript

# Linting
pnpm lint                # ESLint
```

### Git Workflow

1. Create feature branch: `git checkout -b feature/my-feature`
2. Make changes
3. Commit with descriptive messages: `git commit -m "feat(study): add 2-button grading"`
4. Push and create PR

### Commit Message Convention

```
feat(scope): Add new feature
fix(scope): Fix bug
refactor(scope): Refactor code
docs(scope): Update documentation
test(scope): Add tests
style(scope): Code style changes
```

Scopes: `study`, `import`, `ui`, `db`, `core`, `theme`, etc.

---

## 🚀 Deployment

### Desktop

**Build:**
```bash
cd apps/desktop
pnpm tauri build
```

**Output:**
- Windows: `src-tauri/target/release/bundle/msi/VOC-APP_1.0.0_x64_en-US.msi`
- macOS: `src-tauri/target/release/bundle/dmg/VOC-APP.dmg`
- Linux: `src-tauri/target/release/bundle/deb/voc-app_1.0.0_amd64.deb`

### Web (Vercel/Netlify)

**Build:**
```bash
cd apps/web
pnpm build  # Outputs to dist/
```

**Deploy:**
- Push to GitHub
- Connect Vercel/Netlify to repo
- Auto-deploys on push to main

**Environment Variables:**
```env
PUBLIC_SUPABASE_URL=https://xxxxx.supabase.co
PUBLIC_SUPABASE_ANON_KEY=ey...
```

---

## 🤖 For AI Collaborators (Grok, Claude, etc.)

### Quick Onboarding

**What This App Does:**
- Vocabulary training with spaced repetition
- Users import word lists, study cards, app schedules reviews based on performance

**Current Tech:**
- SvelteKit frontend
- 3 database backends: SqliteStore (desktop), WasmSqliteStore (web), CloudStore (Supabase)
- SM-2 spaced repetition algorithm
- Monorepo with pnpm workspaces

**Where to Start:**

1. **Understand Data Flow**: Read `packages/core/src/scheduler/sm2.ts` - this is the heart
2. **See UI**: Look at `apps/desktop/src/routes/study/+page.svelte`
3. **Check DB**: Look at `packages/data/src/IDataStore.ts` (interface) and `SqliteStore.ts` (impl)

**Current Pain Points (What to Fix Next):**

1. **Stats bug**: `getStatsByScope` in all 3 stores returns wrong retention % - investigate why
2. **Deck switcher**: Header dropdown z-index fixed but still reports as broken - debug `Header.svelte`
3. **UX redesign**: Implement 2-button grading system (see Planned Changes section above)
4. **Database migration**: Add `times_correct` and `is_mastered` columns to scheduling table

**Code Style:**
- TypeScript strict mode
- Zod for validation
- Svelte reactive statements (`$:`)
- Comments for complex logic
- Keep functions pure when possible

**Testing:**
- Unit tests in `.test.ts` files next to source
- Run `pnpm test` to verify
- Currently only scheduler has tests - more needed!

**Don't Break:**
- Database schema compatibility (desktop SQLite must match web sql.js)
- CSV import/export format (users rely on this)
- Keyboard shortcuts (power users love them)

---

## 📚 Key Files Reference

### Most Important Files

1. **`packages/core/src/scheduler/sm2.ts`** - Spaced repetition algorithm (will be replaced soon)
2. **`packages/data/src/IDataStore.ts`** - Database interface (all stores implement this)
3. **`apps/desktop/src/routes/study/+page.svelte`** - Main study session UI
4. **`apps/desktop/src/lib/stores/study.ts`** - Study session state machine
5. **`packages/data/src/schema.ts`** - SQL schema and migrations
6. **`packages/core/src/models/types.ts`** - TypeScript types and Zod schemas
7. **`apps/desktop/src/routes/+page.svelte`** - Home page (stats, navigation)
8. **`apps/desktop/src/app.css`** - Global theme and Zen aesthetic

### Database Implementations

- **Desktop**: `packages/data/src/SqliteStore.ts`
- **Web**: `packages/data/src/WasmSqliteStore.ts`
- **Cloud**: `packages/data/src/CloudStore.ts`

All implement `IDataStore` interface for consistency.

---

## 🎯 Next Steps (Priority Order)

1. **Fix stats calculation bug** (retention % showing wrong value)
2. **Debug deck switcher** (still reported as broken)
3. **Implement 2-button grading system** (major UX improvement)
4. **Add database migration** (times_correct, is_mastered columns)
5. **Update UI** (remove 4 buttons, add "Play Deck" button)
6. **Simplify stats** (remove leeches, retention %, show only "X due today")
7. **Test thoroughly** (make sure nothing breaks)
8. **Deploy new version**

---

## 📖 Additional Resources

- **SM-2 Algorithm**: https://www.supermemo.com/en/archives1990-2015/english/ol/sm2
- **Anki Manual**: https://docs.ankiweb.net/studying.html (inspiration)
- **Svelte Docs**: https://svelte.dev/docs
- **SvelteKit Docs**: https://kit.svelte.dev/docs
- **Tauri Docs**: https://tauri.app/v1/guides/
- **Supabase Docs**: https://supabase.com/docs

---

## 🔄 Version History

- **v1.1.0** (2025-01-18): Zen theme complete, practice modes added, major UX redesign planned
- **v1.0.0** (2025-10-28): Initial MVP - Runebound Blackglass theme, SM-2, multi-deck support

---

**Last Updated:** 2025-01-18
**Maintained By:** Claude + Grok (AI collaboration)
**Project Status:** Active Development

For questions, check GitHub issues or ask the AI team! 🤖
