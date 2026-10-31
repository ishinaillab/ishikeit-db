-- Applied to Supabase project vhmrliqemkfxblzsoyaz through its authorized migration API
-- on 2026-11-01 (Asia/Manila). Private, aggregate-only worker health metadata.
BEGIN;
CREATE TABLE IF NOT EXISTS public.ishikeit_worker_heartbeats (
  instance_id uuid NOT NULL,
  worker_name text NOT NULL CHECK (worker_name IN ('inbound_processor','outbound_dispatcher')),
  worker_status text NOT NULL CHECK (worker_status IN ('disabled','not_started','stopped','idle','working','long_running','stalled')),
  observed_at timestamptz NOT NULL DEFAULT now(),
  last_completed_at timestamptz,
  total_iterations bigint NOT NULL DEFAULT 0 CHECK (total_iterations >= 0),
  failed_iterations bigint NOT NULL DEFAULT 0 CHECK (failed_iterations >= 0),
  PRIMARY KEY (instance_id,worker_name)
);
CREATE INDEX IF NOT EXISTS idx_ishikeit_worker_heartbeats_observed_at
  ON public.ishikeit_worker_heartbeats (observed_at DESC);
ALTER TABLE public.ishikeit_worker_heartbeats ENABLE ROW LEVEL SECURITY;
REVOKE ALL PRIVILEGES ON TABLE public.ishikeit_worker_heartbeats FROM PUBLIC, anon, authenticated;
COMMIT;
