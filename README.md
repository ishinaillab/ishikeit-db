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
