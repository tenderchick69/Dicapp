# Fix Guide: Enable Full CSV Schema Support

## Problem Summary

Your app was experiencing these issues:
1. "Bucket not found: uploads" error (misleading - uploads were actually working)
2. CSV imports dropping columns (etymology, mnemonic, ipa, example, etc.)
3. Database missing columns that the code expects
4. Tags type mismatch (array vs semicolon-delimited string)

## Root Cause

The Supabase database was created with a **simplified schema** (8 columns) but the application code supports the **full schema** (15 columns). The CSV parser was reading all 10 columns from your CSV files, but the database insert was dropping extra columns because they didn't exist in the database.

## What Was Fixed

### 1. Code Fixes ✅

**[apps/desktop/src/routes/api/import/+server.ts](apps/desktop/src/routes/api/import/+server.ts)**
- Removed misleading bucket check that caused "Bucket not found" error
- Added all missing columns to word insert: `ipa`, `example`, `gloss_de`, `etymology`, `mnemonic`, `freq`, `updated_at`
- Fixed tags type: Changed from array to semicolon-delimited string (line 148)

**[.env](.env) and [apps/desktop/.env.example](apps/desktop/.env.example)**
- Added `PUBLIC_UPLOAD_BUCKET=uploads` environment variable

### 2. Database Migration Created 🔧

**[supabase/migration_add_word_columns.sql](supabase/migration_add_word_columns.sql)**
- Migration script to add missing columns to your Supabase `words` table
- Safe to run multiple times (idempotent)
- Adds: `ipa`, `example`, `gloss_de`, `etymology`, `mnemonic`, `freq`, `updated_at`

## How to Apply the Fix

### Step 1: Run Database Migration

1. Go to your Supabase Dashboard: https://supabase.com/dashboard/project/mbcvuzvvcduknlzlgqlf
2. Click **SQL Editor** in the left sidebar
3. Click **New Query**
4. Copy the contents of [supabase/migration_add_word_columns.sql](supabase/migration_add_word_columns.sql)
5. Paste into the SQL Editor
6. Click **Run** (or press Ctrl+Enter)
7. Verify the output shows all columns were added successfully

### Step 2: Verify Database Schema

After running the migration, verify your `words` table has all columns:

```sql
SELECT column_name, data_type, column_default
FROM information_schema.columns
WHERE table_name = 'words'
ORDER BY ordinal_position;
```

You should see 15 columns:
- id (uuid)
- user_id (uuid)
- deck_id (uuid)
- headword (text)
- definition (text)
- pos (text)
- **ipa** (text) ← New
- **example** (text) ← New
- **gloss_de** (text) ← New
- **etymology** (text) ← New
- **mnemonic** (text) ← New
- tags (text)
- **freq** (double precision) ← New
- created_at (timestamptz)
- **updated_at** (timestamptz) ← New
- deleted_at (timestamptz)

### Step 3: Set Vercel Environment Variable

1. Go to Vercel Dashboard: https://vercel.com/tenderchick69/dicapp
2. Go to **Settings** > **Environment Variables**
3. Add new variable:
   - **Name**: `PUBLIC_UPLOAD_BUCKET`
   - **Value**: `uploads`
   - **Environments**: Check all (Production, Preview, Development)
4. Click **Save**
5. Redeploy your app (Vercel will prompt you)

### Step 4: Deploy Code Changes

```bash
git add .
git commit -m "fix(import): add full CSV schema support with all columns

- Remove misleading bucket check
- Add missing columns: ipa, example, gloss_de, etymology, mnemonic, freq, updated_at
- Fix tags type from array to semicolon-delimited string
- Add PUBLIC_UPLOAD_BUCKET env var"
git push origin main
```

### Step 5: Test CSV Import

1. Wait for Vercel deployment to complete
2. Sign in to your app: https://dicapp.xyz
3. Create a test CSV with the full schema:

```csv
headword,pos,ipa,definition,example,gloss_de,etymology,mnemonic,tags,freq
apple,n,/ˈæpəl/,"round fruit from a tree","I ate an apple",Apfel,"Old English æppel","A is for Apple",fruit;food,4.5
book,n,/bʊk/,"written work","Read a book",Buch,"Old English boc","A collection of pages",education;reading,5.0
```

4. Import this CSV into a deck
5. Verify all columns are preserved (check in Supabase Table Editor)

## CSV Format Specification

Your app now supports TWO CSV formats:

### Simple Format (2 columns)
For basic flashcards with just word + translation:

```csv
headword,translation
apple,Apfel
banana,Banane
```

The `translation` column is automatically mapped to the `definition` field.

### Full Format (10 columns)
For rich vocabulary entries with all linguistic details:

```csv
headword,pos,ipa,definition,example,gloss_de,etymology,mnemonic,tags,freq
```

**Column Descriptions:**
- `headword` (required): The word or phrase
- `pos` (optional): Part of speech (n, v, adj, adv, etc.)
- `ipa` (optional): IPA pronunciation (e.g., /ˈæpəl/)
- `definition` (required): English definition
- `example` (optional): Example sentence
- `gloss_de` (optional): German translation/gloss
- `etymology` (optional): Word origin and history
- `mnemonic` (optional): Memory aid or learning tip
- `tags` (optional): Semicolon-separated tags (e.g., `fruit;food;common`)
- `freq` (optional): Frequency score (default 3.0, range 0-10)

**Notes:**
- Empty columns are allowed (just use consecutive commas: `,,`)
- Tags should be separated by semicolons, not commas
- Frequency defaults to 3.0 if not provided
- Headers are case-insensitive (headword = Headword = HEADWORD)

## What the Errors Meant

### "Bucket not found: uploads"
This was a **misleading error**. The code was checking if the bucket exists using `getBucket()`, which failed due to permissions, but the actual file upload succeeded anyway. This check has been removed.

### "Could not find the 'etymology' column"
This was the **real problem**. Your database was missing columns that the code tried to insert. The migration fixes this.

### Files Uploading Despite Errors
The 3 CSV files in your Supabase storage prove that uploads work fine. The error was happening at the database insert step, not the storage upload step.

## Why This Happened

When you initially set up Supabase, you likely ran a simplified version of the schema that only included basic columns. The [supabase/schema.sql](supabase/schema.sql) file in your repo has the FULL schema, but it wasn't applied to your actual Supabase project.

The application code (CSV parser, Word model) was always ready for the full schema, but the database wasn't.

## Verification Checklist

After applying all fixes:

- [ ] Database has 15 columns in `words` table
- [ ] Vercel has `PUBLIC_UPLOAD_BUCKET=uploads` environment variable
- [ ] Code deployed to production (git push)
- [ ] Can import simple 2-column CSV successfully
- [ ] Can import full 10-column CSV successfully
- [ ] All columns (etymology, mnemonic, etc.) are preserved in database
- [ ] No "Bucket not found" errors
- [ ] No "column not found" errors

## Support

If you encounter issues after applying these fixes:

1. Check Vercel deployment logs for errors
2. Check Supabase Table Editor to verify column structure
3. Check browser console for client-side errors
4. Verify environment variables are set correctly

## Technical Details

**Tags Storage Format:**
- **In CSV**: Semicolon-separated (e.g., `fruit;food;common`)
- **In Database**: TEXT column with semicolon delimiters
- **In Application Model**: Array of strings
- **Conversion**: Array is joined with `;` before DB insert, split on read

**Timestamp Handling:**
- CSV parser uses Unix timestamps (milliseconds)
- Database uses PostgreSQL `timestamptz`
- Conversion happens at insert time using `new Date().toISOString()`

**Bucket Structure:**
CSV files are stored at: `{user_id}/ingests/{timestamp}-{filename}.csv`

Example: `a1b2c3d4-e5f6-7890-abcd-ef1234567890/ingests/1700000000000-vocab_words.csv`
