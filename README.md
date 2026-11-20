# Ishikeit Database

Canonical Supabase/PostgreSQL schema and migration repository for the Ishikeit backend deployed at `apps.ishinaillab.com`.

Database schema changes belong in `supabase/migrations/` and should be applied with the Supabase CLI. Do not commit database passwords, access tokens, connection strings, Meta secrets, or other credentials.

## Production workflow — exclusive, protected release only

**Priority 3 release HOLD (2026-11-15): No push, migration, rebase, deployment, provider change or customer routing cutover is authorized yet.** Keep all released migrations and the deployed application unchanged until exclusive release ownership, protected GitHub main rules, production backup/recovery, explicit owner approval and verified provider safeguards are genuinely enforced.

1. Review both `ishinaillab/ishikeit` and `ishinaillab/ishikeit-db` release commits; preserve the exact current production deployment and already-applied migration history.
2. Pass the new `migration-ci` job in **GitHub-hosted CI**. Its PR checks must be made required in the DB repository's actual ruleset. A workflow file in Git is not a required branch check.
3. Independently verify the remote migration list and local/remote SQL history, application backward compatibility, RLS, privileges, backup/recovery, and additive release order. Never reset, repair or replay already-applied production versions.
4. Only an approved exclusive protected release controller with the current fencing generation, current exact app/DB SHAs and a human deployment approval can perform the versioned database migration followed by the exact application deployment and production acceptance.
5. When *that* separate production approval exists, Supabase CLI v3 requires explicit `--remote` and `--yes` for noninteractive hosted database changes. Those flags must **never** appear in the offline CI workflow; do not run production commands from this README without the actual enforced release controls.

Prefer the official version-controlled Supabase migration mechanism; do not change production schema directly in the Table Editor or SQL Editor.

## Priority 3 offline database CI checkpoint — 2026-11-15

- Local review branch `review/priority3-active-disconnect-db-chatfresh-20261115` includes an **unpublished** non-deploying workflow `.github/workflows/migration-ci.yml`. It runs for all PRs and main pushes without path filters, uses read-only GitHub contents permission, `supabase/setup-cli@v3` constrained to CLI major v3, and invokes `supabase db start`, `supabase db reset --no-seed`, `supabase db lint --fail-on error --schema public`, then runner-only `supabase stop --no-backup`.
- The 43 local migration versions are unique; three migration-history tests and three offline-CI safety tests all passed. The official `rhysd/actionlint` Docker checker passed with a read-only mount.
- **Actual local CLI v3.1.0 acceptance**: all 43 migrations applied on disposable PostgreSQL; independent `db reset --no-seed` exit 0; independent `db lint --fail-on error --schema public` exit 0 with **No schema errors found**. Local-only PostgreSQL used process-scoped `SUPABASE_DB_PORT=54620` because Windows reserves 54322. The local test volume/container were removed with exit 0. No Supabase production token/project was used or changed.
- New matching additive migration `20261115040500_priority3_tenant_send_generation_fence.sql` records a native tenant outbox send-start marker without enabling sending or changing the legacy queue claimant. The corresponding application `migrations/0027` SQL is SHA256-identical. The isolated application suite passed **1,029/1,029 tests in 129 files**, ESLint, TypeScript and production build; release acceptance has not happened.
- Current effective GitHub `ishinaillab/ishikeit-db` main rules were read publicly: PR and linear history rules exist, but **no required CI check and no required approving review**. The app also currently requires four CI checks but zero approving reviews. Neither current ruleset provides an externally enforced Priority 3 cross-repository release lease.
- Do not mistake passing local migration tests for successful GitHub-hosted CI, effective branch protection, approved production migration, deployment, provider-owner consent or safe live disconnect acceptance. The original legacy customer messaging must keep running on its verified path.



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

## Priority 3 reviewed external-step hold — November 15, 2026 (NOT APPLIED)

- `supabase/migrations/20261115030147_priority3_release_external_step_hold.sql` is the byte-identical DB mirror of the application review `migrations/0028_priority3_release_external_step_hold.sql`; both SHA256 `08ab5c5e3482986a1fdeb3a71c52cf01b54e73795192a478a097d762ff353117`.
- Additive dormant schema only: pending external operation kind/time and outcome readback fields on the private `ishikeit_release_ownership` row. No release owner is granted; no migration/deployment is triggered by this file.
- An in-flight hosted migration or Hostinger deploy may continue after a caller's HTTP request times out or a lease expires. Reassignment is denied while external work is unresolved, until an authorized independent release controller performs genuine provider readback. No browser/client success override exists.
- Production Supabase latest tracked migration at inspection remains `20261113143209`. This file and all other Priority 3 review migrations dated November 15 remain **unapplied**. Do not push any new migration while GitHub issue #284's shared-write HOLD and owner/provider approval gates remain active; never infer exclusive ownership from a local lease alone.

## Priority 3 review — native outbox insert-generation fence (2026-11-18, NOT APPLIED)

A new, **unpublished and unapplied** SQL mirror `supabase/migrations/20261118222000_priority3_native_outbox_write_fence.sql` is byte-identical to isolated application `migrations/0029_priority3_native_outbox_write_fence.sql` (SHA256 `62ce9b0b733062a2b220372b7782056f9cc7bfb296d0d444f112bb7b46227252`). It introduces a `SECURITY INVOKER` trigger to require active workspace/current connected generation and row-share locks before native tenant outbox INSERTs, and forbids retagging an existing queue record's provenance. It preserves all legacy/connectionless work and does not activate native dispatch. The real disposable PG17 negative tests were red before repair and 5/5 green after. Local DB migration layout and offline CI tests passed 6/6, counting 45 unique migrations. Full 132-file/1,066-test Node24+PG17 app regression, ESLint/typecheck/build passed. Official Supabase CLI full-history DB reset/lint and GitHub-hosted DB CI for this revision have **not** been executed; the CLI is not on the Windows shell PATH. This is **not production acceptance** and is subject to issue #284's shared-write HOLD, an exclusive owner-approved protected migration and deployment gate, and live provider-owner consent/cleanup acceptance. Do not run `supabase db push` or modify real provider accounts.

## 2026-11-19 — Full history official Supabase CLI offline acceptance (local-only)

- Clean review base `8185ee892b024457e59a57ecedb86fa19a919eca` includes the new native outbox write-admission migration `20261118222000_priority3_native_outbox_write_fence.sql` (matching isolated app `migrations/0029`, SHA256 `62ce9b0b733062a2b220372b7782056f9cc7bfb296d0d444f112bb7b46227252`). Production history was **not** changed.
- Used official stable **Supabase CLI 3.2.0** through `npx` on a temporary worktree with *only a local test* `supabase/config.toml` project ID `ishikeitp3cli20261119`. No remote project link or provider credentials existed; the command used no `--remote` option. After initial first-run Docker image downloads, `supabase db reset --no-seed` exited 0 with every **45/45** migration applied. `supabase db lint --fail-on error --schema public` exited 0: **No schema errors found**.
- Independent local psql readback: 45 migration records, one enabled `ishikeit_native_outbox_write_fence` trigger, `prosecdef=false` for its invoker function, and `anon`/`authenticated` execute privileges both false. The corresponding isolated app integration finished Node24/PG17 **1,066/1,066** tests in 132 files, ESLint, strict TypeScript, build, plus protected Hostinger release-controller Node tests and Actionlint.
- The official Supabase CLI local stack was stopped with `supabase stop --no-backup`; its local test container and synthetic data were removed. The temporary config change was restored exactly to `project_id = "ishikeit-db"` and the isolated `.npm-ci-cache` directory removed. No customer data, owner MFA or hosted schema changes were performed.
- **Still requires** owner-approved exclusive release handoff (GitHub #284), protected GitHub CI, live authenticated Hostinger Git/no-auto-deploy and scoped secret readiness, independent backup, safe app+DB release acceptance and provider-owner grants/revocation readback. DO NOT run production `db push`, submit Meta App Review, merge or deploy on this checkpoint.
