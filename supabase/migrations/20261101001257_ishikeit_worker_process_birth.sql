-- Version applied to Supabase vhmrliqemkfxblzsoyaz, 2026-11-01 UTC.
-- Nullable for historical rows: only newer process instances can prove supersession.
ALTER TABLE public.ishikeit_worker_heartbeats
  ADD COLUMN IF NOT EXISTS process_started_at timestamptz;
