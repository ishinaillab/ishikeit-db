-- Defense-in-depth: outbox attempt logs are internal to Ishikeit's server.
-- The existing public table has RLS enabled and client table grants revoked.
-- Its owned serial/identity sequence must also remain inaccessible to clients.
-- The privileged app DB roles (postgres and service_role) retain access.
REVOKE ALL PRIVILEGES ON SEQUENCE public.outbox_attempts_id_seq
  FROM anon, authenticated;
