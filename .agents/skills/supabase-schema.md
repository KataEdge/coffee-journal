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
- `acidity`: `INT2` (Scale 1-5)
- `sweetness`: `INT2` (Scale 1-5)
- `bitterness`: `INT2` (Scale 1-5)
- `body`: `INT2` (Scale 1-5)
- `aroma`: `INT2` (Scale 1-5)
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
