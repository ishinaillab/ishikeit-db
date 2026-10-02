BEGIN;

CREATE TABLE public.oauth_account_aliases (
  provider text NOT NULL,
  alias_account_id text NOT NULL,
  credential_account_id text NOT NULL,
  alias_kind text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (provider, alias_account_id),
  CHECK (length(provider) BETWEEN 1 AND 64),
  CHECK (length(alias_account_id) BETWEEN 1 AND 512),
  CHECK (length(credential_account_id) BETWEEN 1 AND 512),
  CHECK (length(alias_kind) BETWEEN 1 AND 128)
);

CREATE INDEX oauth_account_aliases_credential_idx
  ON public.oauth_account_aliases (provider, credential_account_id);

ALTER TABLE public.oauth_account_aliases ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE public.oauth_account_aliases FROM anon, authenticated;

COMMIT;
