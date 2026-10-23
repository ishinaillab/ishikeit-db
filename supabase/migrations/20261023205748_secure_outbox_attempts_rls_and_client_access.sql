-- Restrict internal operational attempt logs to the trusted database backend.
-- Existing Ishikeit workers use PostgreSQL's pg driver (not a public REST client).
-- Do not add anon/authenticated RLS policies: these logs are not a client API.
-- The privileged database owner and service_role retain access.
BEGIN;

REVOKE ALL PRIVILEGES ON TABLE public.outbox_attempts
  FROM anon, authenticated;

ALTER TABLE public.outbox_attempts ENABLE ROW LEVEL SECURITY;

COMMIT;
