CREATE TABLE IF NOT EXISTS public.meta_outbound_reconciliations (
  outbox_id uuid PRIMARY KEY REFERENCES public.outbox(id) ON DELETE CASCADE,
  disposition text NOT NULL CHECK (disposition IN ('followup_required','reviewed_do_not_resend')),
  evidence text NOT NULL CHECK (evidence IN ('provider_record','manual_thread_review','customer_confirmation')),
  reviewer_hash text NOT NULL CHECK (reviewer_hash ~ '^[a-f0-9]{64}$'),
  reviewed_at timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE public.meta_outbound_reconciliations ENABLE ROW LEVEL SECURITY;
REVOKE ALL PRIVILEGES ON TABLE public.meta_outbound_reconciliations FROM PUBLIC, anon, authenticated;
