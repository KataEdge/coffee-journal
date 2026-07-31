-- Migration: Security RLS Policies and Text Length Constraints
-- Timestamp: 2026-08-01 00:00:00

-- 1. Add created_by column to cafes table for ownership tracking
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'cafes' AND column_name = 'created_by'
    ) THEN
        ALTER TABLE cafes ADD COLUMN created_by UUID REFERENCES profiles(id) ON DELETE SET NULL DEFAULT auth.uid();
    END IF;
END $$;

-- 2. Enable Row Level Security (RLS) on all core tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE cafes ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasting_notes ENABLE ROW LEVEL SECURITY;

-- 3. RLS Policies for profiles
DROP POLICY IF EXISTS "profiles_select_policy" ON profiles;
CREATE POLICY "profiles_select_policy" ON profiles FOR SELECT USING (true);

DROP POLICY IF EXISTS "profiles_insert_policy" ON profiles;
CREATE POLICY "profiles_insert_policy" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "profiles_update_policy" ON profiles;
CREATE POLICY "profiles_update_policy" ON profiles FOR UPDATE USING (auth.uid() = id);

-- 4. RLS Policies for cafes
DROP POLICY IF EXISTS "cafes_select_policy" ON cafes;
CREATE POLICY "cafes_select_policy" ON cafes FOR SELECT USING (true);

DROP POLICY IF EXISTS "cafes_insert_policy" ON cafes;
CREATE POLICY "cafes_insert_policy" ON cafes FOR INSERT WITH CHECK (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "cafes_update_policy" ON cafes;
CREATE POLICY "cafes_update_policy" ON cafes FOR UPDATE USING (auth.uid() = created_by);

DROP POLICY IF EXISTS "cafes_delete_policy" ON cafes;
CREATE POLICY "cafes_delete_policy" ON cafes FOR DELETE USING (auth.uid() = created_by);

-- 5. RLS Policies for tasting_notes
DROP POLICY IF EXISTS "tasting_notes_select_policy" ON tasting_notes;
CREATE POLICY "tasting_notes_select_policy" ON tasting_notes FOR SELECT USING (true);

DROP POLICY IF EXISTS "tasting_notes_insert_policy" ON tasting_notes;
CREATE POLICY "tasting_notes_insert_policy" ON tasting_notes FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "tasting_notes_update_policy" ON tasting_notes;
CREATE POLICY "tasting_notes_update_policy" ON tasting_notes FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "tasting_notes_delete_policy" ON tasting_notes;
CREATE POLICY "tasting_notes_delete_policy" ON tasting_notes FOR DELETE USING (auth.uid() = user_id);

-- 6. Add text length CHECK constraints to prevent payload inflation
ALTER TABLE profiles DROP CONSTRAINT IF EXISTS profiles_username_length_check;
ALTER TABLE profiles ADD CONSTRAINT profiles_username_length_check CHECK (char_length(username) <= 30);

ALTER TABLE cafes DROP CONSTRAINT IF EXISTS cafes_name_length_check;
ALTER TABLE cafes ADD CONSTRAINT cafes_name_length_check CHECK (char_length(name) <= 150);

ALTER TABLE tasting_notes DROP CONSTRAINT IF EXISTS tasting_notes_bean_name_length_check;
ALTER TABLE tasting_notes ADD CONSTRAINT tasting_notes_bean_name_length_check CHECK (char_length(bean_name) <= 100);

ALTER TABLE tasting_notes DROP CONSTRAINT IF EXISTS tasting_notes_comment_length_check;
ALTER TABLE tasting_notes ADD CONSTRAINT tasting_notes_comment_length_check CHECK (char_length(comment) <= 2000);
