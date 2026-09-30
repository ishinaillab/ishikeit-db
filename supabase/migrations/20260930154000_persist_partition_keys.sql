BEGIN;

ALTER TABLE public.inbound_events
  ADD COLUMN IF NOT EXISTS partition_key text;

UPDATE public.inbound_events AS events
SET partition_key = queue.partition_key
FROM public.outbox AS queue
WHERE events.partition_key IS NULL
  AND queue.topic = 'inbound.event.accepted'
  AND queue.payload->>'eventId' = events.id::text;

ALTER TABLE public.inbound_events
  ALTER COLUMN partition_key SET NOT NULL;

CREATE INDEX IF NOT EXISTS inbound_events_partition_idx
  ON public.inbound_events (partition_key, received_at);

COMMIT;
