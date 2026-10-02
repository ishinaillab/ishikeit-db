BEGIN;

CREATE TABLE public.oauth_revocations (
  provider text NOT NULL,
  account_id text NOT NULL,
  reason text NOT NULL,
  revoked_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (provider, account_id),
  CHECK (length(provider) BETWEEN 1 AND 64),
  CHECK (length(account_id) BETWEEN 1 AND 512),
  CHECK (length(reason) BETWEEN 1 AND 128)
);

CREATE TABLE public.oauth_data_deletion_requests (
  confirmation_code text PRIMARY KEY,
  provider text NOT NULL,
  account_id text NOT NULL,
  status text NOT NULL CHECK (status IN ('processing','completed','failed')),
  details jsonb NOT NULL DEFAULT '{}'::jsonb,
  requested_at timestamptz NOT NULL DEFAULT now(),
  completed_at timestamptz,
  CHECK (confirmation_code ~ '^[A-Za-z0-9]{16,64}$'),
  CHECK (length(provider) BETWEEN 1 AND 64),
  CHECK (length(account_id) BETWEEN 1 AND 512)
);

CREATE INDEX oauth_data_deletion_requests_account_idx
  ON public.oauth_data_deletion_requests (provider, account_id, requested_at DESC);

ALTER TABLE public.oauth_revocations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.oauth_data_deletion_requests ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE
  public.oauth_revocations,
  public.oauth_data_deletion_requests
FROM anon, authenticated;

COMMIT;
