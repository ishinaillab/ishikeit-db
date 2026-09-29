BEGIN;

CREATE TABLE public.inbound_events (
  id uuid PRIMARY KEY,
  channel text NOT NULL CHECK (channel IN ('messenger','instagram','whatsapp')),
  account_id text NOT NULL,
  event_type text NOT NULL,
  provider_event_id text,
  provider_message_id text,
  deduplication_key text NOT NULL UNIQUE,
  payload_hash text NOT NULL,
  normalized_payload jsonb NOT NULL,
  schema_version integer NOT NULL DEFAULT 1 CHECK (schema_version > 0),
  status text NOT NULL CHECK (status IN ('persisted','processing','processed','failed')),
  attempt_count integer NOT NULL DEFAULT 0 CHECK (attempt_count >= 0),
  occurred_at timestamptz,
  received_at timestamptz NOT NULL,
  processed_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX inbound_events_pending_idx
  ON public.inbound_events (received_at, id)
  WHERE processed_at IS NULL;

CREATE TABLE public.outbox (
  id uuid PRIMARY KEY,
  topic text NOT NULL,
  partition_key text NOT NULL,
  payload jsonb NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  published_at timestamptz,
  attempt_count integer NOT NULL DEFAULT 0 CHECK (attempt_count >= 0),
  next_attempt_at timestamptz,
  lease_expires_at timestamptz,
  lease_token uuid,
  dead_lettered_at timestamptz,
  dead_letter_reason text,
  CHECK ((lease_expires_at IS NULL) = (lease_token IS NULL))
);

CREATE INDEX outbox_ready_idx
  ON public.outbox (COALESCE(next_attempt_at, created_at), created_at, id)
  WHERE published_at IS NULL AND dead_lettered_at IS NULL;

ALTER TABLE public.inbound_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.outbox ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE public.inbound_events, public.outbox FROM anon, authenticated;

COMMIT;
