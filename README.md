# Ishikeit Database

Canonical Supabase/PostgreSQL schema and migration repository for the Ishikeit backend deployed at `apps.ishinaillab.com`.

Database schema changes belong in `supabase/migrations/` and should be applied with the Supabase CLI. Do not commit database passwords, access tokens, connection strings, Meta secrets, or other credentials.

## Production workflow

1. `supabase login`
2. `supabase link --project-ref <project-ref>`
3. `supabase migration list`
4. `supabase db push`

Once migration management is in use, avoid making production schema changes directly in the Supabase Table Editor or SQL Editor; capture changes as migrations so Git and the remote migration history remain synchronized.
