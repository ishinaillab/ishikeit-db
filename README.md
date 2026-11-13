# Ishikeit Database

Canonical Supabase/PostgreSQL schema and migration repository for the Ishikeit backend deployed at `apps.ishinaillab.com`.

Database schema changes belong in `supabase/migrations/` and should be applied with the Supabase CLI. Do not commit database passwords, access tokens, connection strings, Meta secrets, or other credentials.

## Production workflow

1. `supabase login`
2. `supabase link --project-ref <project-ref>`
3. `supabase migration list`
4. `supabase db push`

Once migration management is in use, avoid making production schema changes directly in the Supabase Table Editor or SQL Editor; capture changes as migrations so Git and the remote migration history remain synchronized.


## Meta migration recovery checkpoint — 2026-10-29

Production Supabase `ishikeit-db` contains app-owned Meta messaging migrations already applied through the authenticated Supabase interface. This repository mirrors the **exact existing application SQL** (not a new attempt to reapply it) for:

- `20261028064646_meta_human_handoff_blocks`
- `20261028133037_meta_whatsapp_template_opt_in_consent`
- `20261028150142_meta_delivery_receipt_indexes`
- `20261028162157_meta_native_routing_ownership`
- `20261028163318_meta_whatsapp_opt_out_tombstones`
- `20261028205639_meta_whatsapp_source_event_fk_indexes`

The final index migration was verified applied and its two expected btree indexes exist; the Supabase performance advisor no longer reports those two unindexed foreign keys. All customer data and consent status were preserved, and **no production migration was replayed by this repository reconciliation**.

**Source-history gap recovered:** The original `20261025105859_restrict_future_public_client_privileges_postgres` SQL was read verbatim from the live, read-only `supabase_migrations.schema_migrations.statements` record. It has now been restored to this repository alongside the six exact Meta migrations. No database DDL or migration replay was performed by this source-only reconciliation. Before any future `supabase db push`, independently verify project identity, local/remote migration versions and the proposed changes; do not run blind resets or migration repairs.


## Tenancy and administrator migration history reconciliation — 2026-11-11

The nine migrations from `20261102014946` through `20261102105835` were **already applied** in production Supabase using its official migration mechanism. On November 11, a read-only inspection of `supabase_migrations.schema_migrations.statements[1]` confirmed that each applied statement matches the corresponding `ishinaillab/ishikeit` application SQL **exactly, byte-for-byte** (all nine lengths and full contents match). They cover verified workspace connections, connection intents, tenant event provenance, session binding, private browser OTP/MFA session storage, email encryption, approved initial owner bootstrap, platform administrator provisioning and workspace-member invitations.

These files are a source-history mirror, **not unapplied migrations**: do not re-run them, repair migration history, reset the project, or re-invite the first owner. Always compare `supabase migration list` against the linked project and review a dry-run diff before future schema changes. The application deployment and customer messaging must remain unchanged by this repository-only checkpoint.

## Provider TOTP and one-use workspace claim migration provenance — November 12, 2026

Two production migrations **were already applied via the official Supabase migration API** before this Git source reconciliation. Do not re-run either migration, repair their history or reset the DB when fetching this repository:

- `20261112023259_provider_totp_factor_lifecycle.sql` — exact original source from `ishinaillab/ishikeit` application `migrations/0021_provider_totp_factor_lifecycle.sql`, compared read-only with `supabase_migrations.schema_migrations.statements[1]` in the actual project; both matched **exactly (1,916 characters)**. This mirror only restores previously missing migration source history, and changes no TOTP factor, session or policy.
- `20261112104427_workspace_connection_intent_claims.sql` — exact new application migration source `migrations/0022_workspace_connection_intent_claims.sql`. Applied once via the official Supabase migration action on 2026-11-12; read-back version/name verified; source matches the recorded production statement by **1,439 characters and MD5 `6e02e5cdc4b321878a450e05cf8d79ef`**. Read-back schema verified `auth_session_id NOT NULL`, `claimed_connection_id` and `claimed_at` columns, validated claim-state CHECK and composite same-workspace FK, and RLS/default-deny unchanged. No existing intents or account claims existed at application time.

Application release must follow the schema migration; never deploy code referencing claimed fields before that version is present. This is a **private, inactive owner session-bound claim gate**, not live provider onboarding or tenant-aware event routing. Continue preserving all active owner MFA factors, existing provider credentials and legacy production messaging.

## Tenant provenance constraint-validation reconciliation — November 13, 2026

The production project `vhmrliqemkfxblzsoyaz` was updated **once** via the official Supabase `apply_migration` action after the validated [application PR #289](https://github.com/ishinaillab/ishikeit/pull/289) was deployed and all four protected checks passed. The remote history confirms migration **`20261113143209_ishikeit_validate_event_tenant_provenance`** applied. This repository mirrors that exact existing SQL from the application source `migrations/0023_ishikeit_validate_event_tenant_provenance.sql`. A read-only SQL query of the actual `supabase_migrations.schema_migrations.statements[1]` returned **973 characters** and MD5 **`df891fbcf366d4a2f62e96931803b112`**, matching the local mirror's exactly **973 bytes** and MD5.

The change runs `ALTER TABLE ... VALIDATE CONSTRAINT` only for the six existing tenant shape/workspace/connection foreign-key constraints on `public.inbound_events` and `public.outbox`. All six were verified `convalidated=true` by a separate production read-back. RLS stayed enabled, and `anon`/`authenticated` SELECT permissions remained denied. The read-only postmigration queue snapshot showed **754 inbound** and **1,053 outbox** records, all **without tenant provenance**. Growing counts reflect normal live processing; **no legacy rows were assigned to a guessed workspace**, and this does not activate tenant-aware messaging.

**This migration is ALREADY APPLIED in production.** Do not apply it again when pulling this repository, reset production, or repair migration versions. Compare local and remote histories before future `supabase db push`. All real owner MFA factors, Telegram legacy routing, provider OAuth credentials and ongoing customer messaging were preserved. The application-side security guard parks any future tenant-stamped outbox jobs until a future, separately verified tenant-aware dispatch cutover.
