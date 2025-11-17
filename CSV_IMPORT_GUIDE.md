# CSV Import Guide - For Your Webpage

Copy this guidance to display on your CSV import page.

---

## CSV Import Formats

Your vocabulary app supports flexible CSV imports. You can use either format:

### Simple Format (2 columns)
Perfect for basic flashcards with just the word and its translation.

**Required columns:**
- `headword` - The English word
- `translation` - The German translation

**Example:**
```csv
headword,translation
apple,Apfel
book,Buch
house,Haus
```

**Download template:** [test_import_simple.csv](test_import_simple.csv)

---

### Full Format (10 columns)
For rich vocabulary entries with pronunciation, examples, etymology, and more.

**Column specification:**
1. `headword` (required) - The word or phrase
2. `pos` (optional) - Part of speech (n, v, adj, adv, etc.)
3. `ipa` (optional) - IPA pronunciation (e.g., /ˈæpəl/)
4. `definition` (required) - English definition
5. `example` (optional) - Example sentence using the word
6. `gloss_de` (optional) - German translation/gloss
7. `etymology` (optional) - Word origin and history
8. `mnemonic` (optional) - Memory aid or learning tip
9. `tags` (optional) - Categories (separate with semicolons: `fruit;food;nature`)
10. `freq` (optional) - Frequency score 0-10 (default: 3.0)

**Example:**
```csv
headword,pos,ipa,definition,example,gloss_de,etymology,mnemonic,tags,freq
apple,n,/ˈæpəl/,"round fruit","I ate an apple",Apfel,"Old English æppel","A is for Apple",fruit;food,4.5
```

**Download template:** [test_import_full.csv](test_import_full.csv)

---

### Partial Format (Mix and Match)
You can also use any combination of columns. Only include the ones you need:

**Example with just headword, definition, and etymology:**
```csv
headword,definition,etymology
apple,"a round fruit","From Old English æppel"
book,"written work","From Old English boc"
```

Missing columns will be left empty - no problem!

---

## Important Notes

- **Headers required:** First row must contain column names (case-insensitive)
- **Tags format:** Use semicolons to separate tags: `fruit;food;nature` (not commas!)
- **Empty cells:** Just use `,,` for empty values - they're fine
- **Quotes:** Use quotes around text with commas: `"a fruit, red or green"`
- **File encoding:** UTF-8 recommended (supports all special characters)

---

## Tips for AI Generation

When asking AI to generate vocabulary CSV files, provide this prompt:

> Generate a CSV file with these columns:
> headword, pos, ipa, definition, example, gloss_de, etymology, mnemonic, tags, freq
>
> - Use IPA phonetic notation for pronunciation
> - Provide clear, concise definitions
> - Include example sentences showing usage
> - Add German translations (gloss_de)
> - Include brief etymology from Old/Middle English
> - Create memorable mnemonics
> - Add relevant tags separated by semicolons
> - Set frequency 0-10 based on word commonality

This ensures your CSV will display perfectly with all rich features!

---

## Troubleshooting

**"No valid words found"**
- Check that your file has the required columns: `headword` + (`definition` OR `translation`)
- Verify first row contains column headers
- Make sure there's at least one data row after headers

**"Encoding errors" or weird characters**
- Save your CSV as UTF-8 encoding
- In Excel: Save As → CSV UTF-8
- In Google Sheets: Download → CSV (UTF-8)

**Tags not showing correctly**
- Use semicolons (`;`), not commas (`,`)
- Example: `fruit;food;nature` ✓
- Not: `fruit,food,nature` ✗

---

## Sample Files

Two test files are included in this repository:
- [test_import_simple.csv](test_import_simple.csv) - 2-column basic format
- [test_import_full.csv](test_import_full.csv) - 10-column rich format

Download and try importing these to test the functionality!
