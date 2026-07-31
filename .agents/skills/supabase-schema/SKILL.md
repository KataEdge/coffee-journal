---
name: supabase-schema
description: Supabase database table definitions, RLS security policies, and Swift Codable mapping guidelines for CoffeeJournal.
---

# Supabase Database Schema & RLS Policy Guidelines

## Tables Overview

### 1. `profiles`
- `id`: `UUID` (Primary Key, References `auth.users.id`)
- `username`: `TEXT` (Unique, Nullable)
- `avatar_url`: `TEXT` (Nullable)
- `updated_at`: `TIMESTAMPTZ`

### 2. `cafes`
- `id`: `UUID` (Primary Key, Default `gen_random_uuid()`)
- `name`: `TEXT` (Not Null, max 150 chars)
- `address`: `TEXT` (Nullable)
- `latitude`: `DOUBLE PRECISION` (Nullable)
- `longitude`: `DOUBLE PRECISION` (Nullable)
- `created_by`: `UUID` (References `profiles.id`, Default `auth.uid()`, Nullable)
- `created_at`: `TIMESTAMPTZ` (Default `now()`)

### 3. `tasting_notes`
- `id`: `UUID` (Primary Key, Default `gen_random_uuid()`)
- `user_id`: `UUID` (References `profiles.id`, Not Null)
- `cafe_id`: `UUID` (References `cafes.id`, Nullable)
- `bean_name`: `TEXT` (Not Null, max 100 chars)
- `roaster`: `TEXT` (Nullable)
- `origin`: `TEXT` (Nullable)
- `roast_level`: `TEXT` (e.g. "Light", "Medium", "Dark")
- `acidity`: `INT2` (Scale 1-10)
- `sweetness`: `INT2` (Scale 1-10)
- `bitterness`: `INT2` (Scale 1-10)
- `body`: `INT2` (Scale 1-10)
- `aroma`: `INT2` (Scale 1-10)
- `flavor_notes`: `TEXT[]` (Array of strings e.g. ["Floral", "Citrus"])
- `image_urls`: `TEXT[]` (Array of S3 image URLs)
- `comment`: `TEXT` (Nullable, max 2000 chars)
- `created_at`: `TIMESTAMPTZ` (Default `now()`)

## Row Level Security (RLS) Policies
- `profiles`:
  - SELECT: Public
  - INSERT / UPDATE: `auth.uid() = id`
- `cafes`:
  - SELECT: Public
  - INSERT: Authenticated users (`auth.role() = 'authenticated'`)
  - UPDATE / DELETE: `auth.uid() = created_by`
- `tasting_notes`:
  - SELECT: Public
  - INSERT / UPDATE / DELETE: `auth.uid() = user_id`

## Swift Codable & Type Safety
- All DTOs must strictly reflect Supabase column names via `CodingKeys` (snake_case to camelCase).
- Always map database errors to Domain-specific `AppError` types.

## Migration Policy (Required)
- This file documents the *intended* schema, but it is not itself applied anywhere — it can drift from the live DB (this has happened before: see `supabase/migrations/20260731001200_widen_tasting_notes_scale_to_10.sql`).
- **Standard workflow (adopted 2026-07-31)**: schema changes are written as Supabase CLI migration files, not applied ad hoc:
  1. `supabase migration new <description>` — creates `supabase/migrations/<timestamp>_<description>.sql`.
  2. Write the DDL in that file.
  3. `supabase db push` — applies pending migrations to the linked project (requires a one-time `supabase login` + `supabase link --project-ref <ref>`, done by a human, not the agent).
  4. Update the table/column description above if the change altered shape or constraints.
- **Fallback**: if the CLI isn't linked in a given environment and DDL must be applied directly (SQL Editor/`psql`/dashboard), still add the equivalent file to `supabase/migrations/` in the same session/PR so the migration history stays authoritative — do not let ad hoc changes go unrecorded.
- Before assuming this doc is accurate for a bug investigation, prefer verifying against the live DB (e.g. `SELECT pg_get_constraintdef(oid) FROM pg_constraint WHERE conrelid = '<table>'::regclass`) rather than trusting this file alone.
