-- A durable, private fence for Meta outbound message POSTs. A worker must
-- commit the send-start marker while it owns the lease BEFORE calling Meta.
-- If that worker crashes, the next worker must quarantine the unresolved
-- send rather than repeat a provider request that may already have succeeded.
-- Nullable: historical completed and unsent jobs are not backfilled.
BEGIN;

ALTER TABLE public.outbox
  ADD COLUMN IF NOT EXISTS meta_send_started_at timestamptz;

CREATE INDEX IF NOT EXISTS outbox_meta_send_pending_recovery_idx
  ON public.outbox (meta_send_started_at, id)
  WHERE topic = 'action.dispatch'
    AND meta_send_started_at IS NOT NULL
    AND published_at IS NULL
    AND dead_lettered_at IS NULL;

-- Existing outbox RLS and client-role revocations continue to apply.
-- No new relations, roles, policies or public grants.
COMMIT;
