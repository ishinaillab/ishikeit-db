BEGIN;

CREATE TABLE public.oauth_credentials (
  provider text NOT NULL,
  account_id text NOT NULL,
  access_token_ciphertext bytea NOT NULL,
  access_token_iv bytea NOT NULL CHECK (octet_length(access_token_iv) = 12),
  access_token_tag bytea NOT NULL CHECK (octet_length(access_token_tag) = 16),
  refresh_token_ciphertext bytea,
  refresh_token_iv bytea CHECK (refresh_token_iv IS NULL OR octet_length(refresh_token_iv) = 12),
  refresh_token_tag bytea CHECK (refresh_token_tag IS NULL OR octet_length(refresh_token_tag) = 16),
  scopes text[] NOT NULL DEFAULT ARRAY[]::text[],
  access_expires_at timestamptz NOT NULL,
  refresh_expires_at timestamptz,
  token_version integer NOT NULL DEFAULT 1 CHECK (token_version >= 1),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (provider, account_id),
  CHECK (length(provider) BETWEEN 1 AND 64),
  CHECK (length(account_id) BETWEEN 1 AND 512),
  CHECK (
    (refresh_token_ciphertext IS NULL AND refresh_token_iv IS NULL AND refresh_token_tag IS NULL)
    OR
    (refresh_token_ciphertext IS NOT NULL AND refresh_token_iv IS NOT NULL AND refresh_token_tag IS NOT NULL)
  ),
  CHECK (refresh_expires_at IS NULL OR refresh_token_ciphertext IS NOT NULL)
);

CREATE INDEX oauth_credentials_provider_updated_idx
  ON public.oauth_credentials (provider, updated_at DESC);

CREATE TABLE public.oauth_authorization_states (
  state_hash text PRIMARY KEY,
  provider text NOT NULL,
  redirect_uri text NOT NULL,
  expires_at timestamptz NOT NULL,
  consumed_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  CHECK (state_hash ~ '^[0-9a-f]{64}$'),
  CHECK (length(provider) BETWEEN 1 AND 64),
  CHECK (length(redirect_uri) BETWEEN 1 AND 2048)
);

CREATE INDEX oauth_authorization_states_expiry_idx
  ON public.oauth_authorization_states (expires_at)
  WHERE consumed_at IS NULL;

ALTER TABLE public.oauth_credentials ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.oauth_authorization_states ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE public.oauth_credentials, public.oauth_authorization_states FROM anon, authenticated;

COMMIT;
