-- Idempotent: add times_correct and is_mastered to scheduling table
ALTER TABLE scheduling
ADD COLUMN IF NOT EXISTS times_correct INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS is_mastered INTEGER DEFAULT 0;

-- Backfill existing rows so no card is stuck in limbo
UPDATE scheduling
SET
  times_correct = 0,
  is_mastered = 0
WHERE times_correct IS NULL OR is_mastered IS NULL;
