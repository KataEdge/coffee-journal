-- Widen tasting_notes taste parameter CHECK constraints from 1-5 to 1-10.
--
-- Background: commit b6ac47a ("feat: change taste rating scale from 5 to 10")
-- widened the Swift-side range (TasteParameter, CreateNoteView, TasteRadarChart)
-- from 1-5 to 1-10, but never shipped a corresponding DB migration. The live
-- Supabase `tasting_notes` table kept its original 1-5 CHECK constraints,
-- causing "violates check constraint tasting_notes_<column>_check" errors on
-- any insert/update with a value above 5. Applied directly via the Supabase
-- SQL Editor on 2026-07-31; this file records that change for future
-- environments/history since no migration file previously existed for it.

ALTER TABLE tasting_notes DROP CONSTRAINT tasting_notes_acidity_check;
ALTER TABLE tasting_notes ADD CONSTRAINT tasting_notes_acidity_check CHECK (acidity BETWEEN 1 AND 10);

ALTER TABLE tasting_notes DROP CONSTRAINT tasting_notes_sweetness_check;
ALTER TABLE tasting_notes ADD CONSTRAINT tasting_notes_sweetness_check CHECK (sweetness BETWEEN 1 AND 10);

ALTER TABLE tasting_notes DROP CONSTRAINT tasting_notes_bitterness_check;
ALTER TABLE tasting_notes ADD CONSTRAINT tasting_notes_bitterness_check CHECK (bitterness BETWEEN 1 AND 10);

ALTER TABLE tasting_notes DROP CONSTRAINT tasting_notes_body_check;
ALTER TABLE tasting_notes ADD CONSTRAINT tasting_notes_body_check CHECK (body BETWEEN 1 AND 10);

ALTER TABLE tasting_notes DROP CONSTRAINT tasting_notes_aroma_check;
ALTER TABLE tasting_notes ADD CONSTRAINT tasting_notes_aroma_check CHECK (aroma BETWEEN 1 AND 10);
