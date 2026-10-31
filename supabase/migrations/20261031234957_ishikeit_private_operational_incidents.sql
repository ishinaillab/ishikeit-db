-- Applied by authorized Supabase migration API, 2026-11-01 Asia/Manila.
-- Sensitive operational statuses are intentionally not exposed to the Data API.
BEGIN;
CREATE TABLE IF NOT EXISTS public.ishikeit_operational_incidents (
  code text PRIMARY KEY CHECK (code IN ('stale_worker','queue_lag','recent_dead_letter','inbound_processing_failed','graph_rate_limited','oauth_renewal_failed')),
  severity text NOT NULL CHECK (severity IN ('warning','critical')),
  incident_count integer NOT NULL CHECK (incident_count >= 0),
  active boolean NOT NULL DEFAULT true,
  last_seen_at timestamptz NOT NULL DEFAULT now(),
  claimed_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_ishikeit_operational_incidents_active
  ON public.ishikeit_operational_incidents (last_seen_at DESC) WHERE active = true;
ALTER TABLE public.ishikeit_operational_incidents ENABLE ROW LEVEL SECURITY;
REVOKE ALL PRIVILEGES ON TABLE public.ishikeit_operational_incidents FROM PUBLIC, anon, authenticated;
COMMIT;
