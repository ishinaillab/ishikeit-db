-- Durable Meta outbound send-start marker, applied before app code requiring it.
ALTER TABLE public.outbox ADD COLUMN IF NOT EXISTS meta_send_started_at timestamptz;
CREATE INDEX IF NOT EXISTS outbox_meta_send_pending_recovery_idx ON public.outbox (meta_send_started_at, id) WHERE topic = 'action.dispatch' AND meta_send_started_at IS NOT NULL AND published_at IS NULL AND dead_lettered_at IS NULL;
