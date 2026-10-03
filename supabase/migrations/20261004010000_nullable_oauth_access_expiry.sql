BEGIN;

ALTER TABLE public.oauth_credentials
  ALTER COLUMN access_expires_at DROP NOT NULL;

COMMIT;
