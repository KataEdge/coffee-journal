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
- `name`: `TEXT` (Not Null)
- `address`: `TEXT` (Nullable)
- `latitude`: `DOUBLE PRECISION` (Nullable)
- `longitude`: `DOUBLE PRECISION` (Nullable)
- `created_at`: `TIMESTAMPTZ` (Default `now()`)

### 3. `tasting_notes`
- `id`: `UUID` (Primary Key, Default `gen_random_uuid()`)
- `user_id`: `UUID` (References `profiles.id`, Not Null)
- `cafe_id`: `UUID` (References `cafes.id`, Nullable)
- `bean_name`: `TEXT` (Not Null)
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
- `comment`: `TEXT` (Nullable)
- `created_at`: `TIMESTAMPTZ` (Default `now()`)

## Row Level Security (RLS) Policies
- `profiles`:
  - SELECT: Public
  - INSERT / UPDATE: `auth.uid() = id`
- `cafes`:
  - SELECT: Public
  - INSERT: Authenticated users (`auth.role() = 'authenticated'`)
- `tasting_notes`:
  - SELECT: Public
  - INSERT / UPDATE / DELETE: `auth.uid() = user_id`

## Swift Codable & Type Safety
- All DTOs must strictly reflect Supabase column names via `CodingKeys` (snake_case to camelCase).
- Always map database errors to Domain-specific `AppError` types.

## Migration Policy (Required)
- This file documents the *intended* schema, but it is not itself applied anywhere — it can drift from the live DB (this has happened before: see `docs/migrations/20260731_widen_tasting_notes_scale_to_10.sql`).
- Whenever you run DDL against the live Supabase project (SQL Editor, `psql`, dashboard), you MUST also:
  1. Add a `.sql` file to `docs/migrations/YYYYMMDD_description.sql` containing the exact statements applied.
  2. Update the table/column description above if it changed shape or constraints.
- Before assuming this doc is accurate for a bug investigation, prefer verifying against the live DB (e.g. `SELECT pg_get_constraintdef(oid) FROM pg_constraint WHERE conrelid = '<table>'::regclass`) rather than trusting this file alone.
- **Planned improvement**: adopt the Supabase CLI migration workflow (`supabase migration new`, `supabase db push`) so migration files are the actual mechanism of change rather than a manual record kept in sync by convention. Not yet adopted as of 2026-07-31.
