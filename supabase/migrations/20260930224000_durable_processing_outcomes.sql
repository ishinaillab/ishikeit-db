BEGIN;

ALTER TABLE public.inbound_events
  ADD COLUMN IF NOT EXISTS processing_outcome text,
  ADD COLUMN IF NOT EXISTS handoff_reason text;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'inbound_events_processing_outcome_check'
      AND conrelid = 'public.inbound_events'::regclass
  ) THEN
    ALTER TABLE public.inbound_events
      ADD CONSTRAINT inbound_events_processing_outcome_check
      CHECK (
        processing_outcome IS NULL
        OR processing_outcome IN ('handled','handoff','ignored','rollout_skipped')
      );
  END IF;
END
$$;
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'inbound_events_handoff_reason_check'
      AND conrelid = 'public.inbound_events'::regclass
  ) THEN
    ALTER TABLE public.inbound_events
      ADD CONSTRAINT inbound_events_handoff_reason_check
      CHECK (handoff_reason IS NULL OR processing_outcome = 'handoff');
  END IF;
END
$$;

CREATE INDEX IF NOT EXISTS inbound_events_processing_outcome_idx
  ON public.inbound_events (processing_outcome, received_at DESC);

COMMIT;
