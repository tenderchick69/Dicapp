-- Migration: Zen Ladder System
-- Add times_correct and is_mastered columns to scheduling table
-- for progressive interval learning (1d → 1.2d → 3d → 12d → 30d → mastered)

-- Add times_correct column if missing (tracks consecutive correct answers)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_name='scheduling' AND column_name='times_correct') THEN
        ALTER TABLE public.scheduling ADD COLUMN times_correct integer NOT NULL DEFAULT 0;
    END IF;
END $$;

-- Add is_mastered column if missing (tracks cards that reached level 5)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_name='scheduling' AND column_name='is_mastered') THEN
        ALTER TABLE public.scheduling ADD COLUMN is_mastered integer NOT NULL DEFAULT 0;
    END IF;
END $$;

-- Add index for querying mastered cards (graveyard)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_scheduling_is_mastered') THEN
        CREATE INDEX idx_scheduling_is_mastered ON public.scheduling (is_mastered);
    END IF;
END $$;

-- Verify columns exist
SELECT column_name, data_type, column_default
FROM information_schema.columns
WHERE table_name = 'scheduling'
ORDER BY ordinal_position;
