-- Migration: Add missing word columns
-- Run this in Supabase SQL Editor to add support for full CSV schema
--
-- This adds: ipa, example, gloss_de, etymology, mnemonic, freq, updated_at
-- to the words table if they don't already exist

-- First, ensure the touch_updated_at function exists
CREATE OR REPLACE FUNCTION public.touch_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  new.updated_at := now();
  RETURN new;
END;
$$;

-- Add ipa column if missing
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_name='words' AND column_name='ipa') THEN
        ALTER TABLE public.words ADD COLUMN ipa text default '';
    END IF;
END $$;

-- Add example column if missing
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_name='words' AND column_name='example') THEN
        ALTER TABLE public.words ADD COLUMN example text default '';
    END IF;
END $$;

-- Add gloss_de column if missing
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_name='words' AND column_name='gloss_de') THEN
        ALTER TABLE public.words ADD COLUMN gloss_de text default '';
    END IF;
END $$;

-- Add etymology column if missing
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_name='words' AND column_name='etymology') THEN
        ALTER TABLE public.words ADD COLUMN etymology text default '';
    END IF;
END $$;

-- Add mnemonic column if missing
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_name='words' AND column_name='mnemonic') THEN
        ALTER TABLE public.words ADD COLUMN mnemonic text default '';
    END IF;
END $$;

-- Add freq column if missing
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_name='words' AND column_name='freq') THEN
        ALTER TABLE public.words ADD COLUMN freq double precision default 3.0;
    END IF;
END $$;

-- Add updated_at column if missing
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_name='words' AND column_name='updated_at') THEN
        ALTER TABLE public.words ADD COLUMN updated_at timestamptz not null default now();
    END IF;
END $$;

-- Add trigger for updated_at if missing
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'words_touch_updated_at') THEN
        CREATE TRIGGER words_touch_updated_at
        BEFORE UPDATE ON public.words
        FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();
    END IF;
END $$;

-- Verify all columns exist
SELECT column_name, data_type, column_default
FROM information_schema.columns
WHERE table_name = 'words'
ORDER BY ordinal_position;
