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

**Known pre-existing history gap:** production also lists `20261025105859_restrict_future_public_client_privileges_postgres`, whose original exact migration SQL is not present in this repository. Do not fabricate or silently repair that version, mark the complete history reconciled, or run a blind `supabase db push` from a fresh checkout until its original verified source is recovered and migration ordering/history are checked. Keep this gap explicit. The app repository's `migrations/0003`–`0008` are the verified SQL provenance for the six mirrored Meta versions.
