-- ============================================================================
-- DIC APP - FRESH START (Nuclear Reset)
-- ============================================================================
-- This script drops EVERYTHING and recreates from scratch
-- Run this in Supabase SQL Editor to start clean
-- ============================================================================

-- ============================================================================
-- STEP 1: NUKE EVERYTHING
-- ============================================================================

-- Drop all tables (in order due to foreign keys)
DROP TABLE IF EXISTS public.merge_logs CASCADE;
DROP TABLE IF EXISTS public.ingests CASCADE;
DROP TABLE IF EXISTS public.settings CASCADE;
DROP TABLE IF EXISTS public.reviews CASCADE;
DROP TABLE IF EXISTS public.scheduling CASCADE;
DROP TABLE IF EXISTS public.words CASCADE;
DROP TABLE IF EXISTS public.decks CASCADE;
DROP TABLE IF EXISTS public.profiles CASCADE;

-- Drop functions
DROP FUNCTION IF EXISTS public.touch_updated_at() CASCADE;
DROP FUNCTION IF EXISTS public.set_auth_user_id() CASCADE;

-- ============================================================================
-- STEP 2: CREATE HELPER FUNCTIONS
-- ============================================================================

-- Automatically set user_id to the authenticated user
CREATE OR REPLACE FUNCTION public.set_auth_user_id()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF new.user_id IS NULL THEN
    new.user_id := auth.uid();
  END IF;
  RETURN new;
END;
$$;

-- Touch updated_at timestamp
CREATE OR REPLACE FUNCTION public.touch_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  new.updated_at := now();
  RETURN new;
END;
$$;

-- ============================================================================
-- STEP 3: CREATE TABLES
-- ============================================================================

-- Profiles (extended user info)
CREATE TABLE public.profiles (
  user_id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name text,
  avatar_url text,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "profiles_self_owned"
  ON public.profiles FOR ALL
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- Decks
CREATE TABLE public.decks (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  name text NOT NULL,
  slug text NOT NULL,
  visibility text NOT NULL DEFAULT 'private' CHECK (visibility IN ('private', 'public')),
  profile text NOT NULL CHECK (profile IN ('simple', 'full')),
  config jsonb NOT NULL DEFAULT '{
    "newPerDay": 10,
    "dueLimit": 20,
    "leechThreshold": 8,
    "studyOrientation": "word-to-def",
    "learningReveal": "minimal"
  }'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX decks_user_slug_idx ON public.decks(user_id, slug);
CREATE INDEX decks_user_id_idx ON public.decks(user_id);
CREATE INDEX decks_visibility_idx ON public.decks(visibility);

ALTER TABLE public.decks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "decks_owner_full_access"
  ON public.decks FOR ALL
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "decks_public_readable"
  ON public.decks FOR SELECT
  USING (visibility = 'public');

CREATE TRIGGER decks_set_user_id
  BEFORE INSERT ON public.decks
  FOR EACH ROW EXECUTE FUNCTION public.set_auth_user_id();

CREATE TRIGGER decks_touch_updated_at
  BEFORE UPDATE ON public.decks
  FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();

-- Words (with PostgreSQL ARRAY for tags!)
CREATE TABLE public.words (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  deck_id uuid NOT NULL REFERENCES public.decks(id) ON DELETE CASCADE,
  headword text NOT NULL,
  definition text NOT NULL,
  pos text DEFAULT '',
  ipa text DEFAULT '',
  example text DEFAULT '',
  gloss_de text DEFAULT '',
  etymology text DEFAULT '',
  mnemonic text DEFAULT '',
  tags text[] DEFAULT '{}', -- PostgreSQL array, not semicolon-delimited!
  freq double precision DEFAULT 3.0,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz
);

CREATE INDEX words_user_id_idx ON public.words(user_id);
CREATE INDEX words_deck_id_idx ON public.words(deck_id);
CREATE INDEX words_headword_idx ON public.words(lower(headword));
CREATE INDEX words_deleted_at_idx ON public.words(deleted_at) WHERE deleted_at IS NULL;
CREATE INDEX words_tags_idx ON public.words USING GIN(tags); -- Array index for tags

ALTER TABLE public.words ENABLE ROW LEVEL SECURITY;

CREATE POLICY "words_owner_full_access"
  ON public.words FOR ALL
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "words_public_deck_readable"
  ON public.words FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.decks d
      WHERE d.id = deck_id
        AND d.visibility = 'public'
    )
  );

CREATE TRIGGER words_set_user_id
  BEFORE INSERT ON public.words
  FOR EACH ROW EXECUTE FUNCTION public.set_auth_user_id();

CREATE TRIGGER words_touch_updated_at
  BEFORE UPDATE ON public.words
  FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();

-- Scheduling (SM-2 algorithm state)
CREATE TABLE public.scheduling (
  word_id uuid PRIMARY KEY REFERENCES public.words(id) ON DELETE CASCADE,
  due_ts bigint NOT NULL,
  interval int NOT NULL DEFAULT 0,
  ease double precision NOT NULL DEFAULT 2.5,
  lapses int NOT NULL DEFAULT 0,
  is_new int NOT NULL DEFAULT 1 CHECK (is_new IN (0, 1))
);

CREATE INDEX scheduling_due_ts_idx ON public.scheduling(due_ts);
CREATE INDEX scheduling_is_new_idx ON public.scheduling(is_new);

ALTER TABLE public.scheduling ENABLE ROW LEVEL SECURITY;

CREATE POLICY "scheduling_owner_access"
  ON public.scheduling FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.words w
      WHERE w.id = word_id AND w.user_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.words w
      WHERE w.id = word_id AND w.user_id = auth.uid()
    )
  );

-- Reviews (study history)
CREATE TABLE public.reviews (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  word_id uuid NOT NULL REFERENCES public.words(id) ON DELETE CASCADE,
  ts bigint NOT NULL,
  grade int NOT NULL CHECK (grade IN (1, 2, 3, 4)),
  elapsed_ms int NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX reviews_user_id_idx ON public.reviews(user_id);
CREATE INDEX reviews_word_id_ts_idx ON public.reviews(word_id, ts DESC);

ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;

CREATE POLICY "reviews_owner_full_access"
  ON public.reviews FOR ALL
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE TRIGGER reviews_set_user_id
  BEFORE INSERT ON public.reviews
  FOR EACH ROW EXECUTE FUNCTION public.set_auth_user_id();

-- Settings (per-user key-value store)
CREATE TABLE public.settings (
  user_id uuid NOT NULL,
  key text NOT NULL,
  value text NOT NULL,
  PRIMARY KEY (user_id, key)
);

ALTER TABLE public.settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "settings_self_owned"
  ON public.settings FOR ALL
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE TRIGGER settings_set_user_id
  BEFORE INSERT ON public.settings
  FOR EACH ROW EXECUTE FUNCTION public.set_auth_user_id();

-- Ingests (CSV import audit log)
CREATE TABLE public.ingests (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  deck_id uuid REFERENCES public.decks(id) ON DELETE SET NULL,
  filename text NOT NULL,
  storage_path text NOT NULL,
  profile text NOT NULL CHECK (profile IN ('simple', 'full')),
  rows_inserted int NOT NULL DEFAULT 0,
  rows_skipped int NOT NULL DEFAULT 0,
  errors jsonb DEFAULT '[]'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX ingests_user_id_idx ON public.ingests(user_id);
CREATE INDEX ingests_deck_id_idx ON public.ingests(deck_id);

ALTER TABLE public.ingests ENABLE ROW LEVEL SECURITY;

CREATE POLICY "ingests_owner_full_access"
  ON public.ingests FOR ALL
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE TRIGGER ingests_set_user_id
  BEFORE INSERT ON public.ingests
  FOR EACH ROW EXECUTE FUNCTION public.set_auth_user_id();

-- Merge Logs (deck merge history)
CREATE TABLE public.merge_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  from_deck_id uuid NOT NULL,
  to_deck_id uuid NOT NULL,
  strategy text NOT NULL CHECK (strategy IN ('skip-duplicates', 'merge-fields', 'force-move')),
  report jsonb NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX merge_logs_user_id_idx ON public.merge_logs(user_id);
CREATE INDEX merge_logs_created_at_idx ON public.merge_logs(created_at DESC);

ALTER TABLE public.merge_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "merge_logs_owner_full_access"
  ON public.merge_logs FOR ALL
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE TRIGGER merge_logs_set_user_id
  BEFORE INSERT ON public.merge_logs
  FOR EACH ROW EXECUTE FUNCTION public.set_auth_user_id();

-- ============================================================================
-- STEP 4: PERFORMANCE INDEXES
-- ============================================================================

CREATE INDEX words_deck_created_idx ON public.words(deck_id, created_at DESC);
CREATE INDEX scheduling_word_due_idx ON public.scheduling(word_id, due_ts);
CREATE INDEX reviews_word_ts_idx ON public.reviews(word_id, ts DESC);

-- ============================================================================
-- DONE! Verify Tables
-- ============================================================================

SELECT
  schemaname,
  tablename,
  tableowner
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY tablename;

-- ============================================================================
-- NEXT STEPS:
-- ============================================================================
-- 1. Go to Supabase Dashboard > Storage
-- 2. Create bucket named 'uploads' (private, 10MB limit, CSV files only)
-- 3. Set up storage policies (see supabase/storage.sql)
-- 4. Test CSV import!
-- ============================================================================
