-- Migration: Fix decks table - add missing visibility column
-- Run this in Supabase SQL Editor

-- Add visibility column if missing
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_name='decks' AND column_name='visibility') THEN
        ALTER TABLE public.decks ADD COLUMN visibility text not null default 'private' check (visibility in ('private', 'public'));

        -- Add index for visibility
        CREATE INDEX IF NOT EXISTS decks_visibility_idx ON public.decks(visibility);
    END IF;
END $$;

-- Verify decks table structure
SELECT column_name, data_type, column_default
FROM information_schema.columns
WHERE table_name = 'decks'
ORDER BY ordinal_position;
