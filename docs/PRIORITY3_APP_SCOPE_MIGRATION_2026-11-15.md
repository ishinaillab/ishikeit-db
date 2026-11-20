# Priority 3 — safe expand-only capability evidence migration

2026-11-15, Manila. **Not applied to live Supabase, not pushed/merged.**

The original proposed in-place migration was rejected after a RED real
PostgreSQL 17 regression proved that removing the old three-column default
would reject still-running old application writes; replacing its primary
key also would have broken legacy `ON CONFLICT(provider,account_id,evidence_key)`
statements. Do **not** run that original version.

This verified replacement creates **a separate, private table**
`public.provider_account_capability_facts_v2` with exact provider, immutable
account, trusted provider application and evidence key as its composite
primary key. It leaves the original legacy table, original indexes, exact
three-key primary key, and all legacy INSERT/UPSERT statements unchanged.

The new table has RLS enabled and explicitly revokes PUBLIC, anon and
authenticated privileges. Existing historical records are copied only to
the reserved `legacy-unbound` namespace for retention; the application
rejects this namespace as a valid source of rights. New application readers,
writers and owner-permission views use v2 exclusively. Old servers may
continue using the original table while draining, with no cross-app
capability privilege leakage. The original table is **not dropped** in
this migration; no contract/drop or misleading automatic backfill of later
old-server writes is attempted.

Migration procedure when exclusive release ownership and current
protected CI/security approvals are achieved:

1. Check exact protected application and DB main SHAs, existing production
   schema/grants/RLS, and confirm the older Node service is healthy.
2. Apply the additive DB migration through the approved Supabase migration
   workflow; verify v2 composite PK, RLS, client role revocations and
   historical `legacy-unbound` count without reading customer data.
3. Verify the old service's existing evidence writes still succeed; verify
   no current tenant connection or sender is enabled by the migration.
4. Deploy the matching verified Node24 app SHA from protected main and
   inspect Hostinger build SHA/health/auth/real owner permissions preview.
5. Never release any native provider messaging flow without real owner
   AAL2/MFA consent, current provider-owned app/asset rights and official
   approval. Respect Meta App Review hold #169.
6. Retain legacy table until a **separate** change proves all old writers
   drained, data retention, alias/deletion compliance, rollback design and
   explicit approval. No destructive contract is implied here.

App and DB migration contents must be byte-identical:
- `ishikeit/migrations/0024_provider_capability_application_scope.sql`
- `ishikeit-db/supabase/migrations/20261115013500_provider_account_capability_app_scope.sql`

Verification against disposable PostgreSQL17:
- Test first reproduced old-server INSERT failure on the removed-default
  version (1 failure, 9 passes).
- After safe expand-table migration and code/privacy changes, focused
  real PostgreSQL 17 / Node24 tests: **19/19 passed**, ESLint, strict TS,
  no customer data, temporary DB volume and network removed. The full
  suite is independently required before a commit/release.

Official standards:
- https://www.postgresql.org/docs/17/sql-createtable.html
- https://www.postgresql.org/docs/17/sql-altertable.html
- https://www.rfc-editor.org/rfc/rfc9700.html

No live DB writes, GitHub push/merge, owner OAuth enrollment, MFA or
Hostinger deployment were performed by this review.

## 2026-11-15 — same-provider, same-app account transfer provenance hardening

A real disposable PG17 regression exposed a remaining owner-rights preview
hazard: an earlier owner's in-flight provider readback can complete **after**
the same provider account is transferred to a different workspace. The
previous timestamp test (`observed_at >= new_link.created_at`) incorrectly
accepted the prior owner's result because both its observation and its
database write occurred after the new owner link. Before remediation this
test returned `official_account_replies=available` incorrectly (1 RED,
6 passing).

The v2 private facts table now adds nullable `source_connection_id uuid`.
Legacy/historical/unscoped fact rows intentionally keep it NULL.
Every native Instagram, Messenger, WhatsApp, TikTok and Telegram Business
verified proof is bound to its **server-verified registry connection ID**
after strict role, app, immutable provider ID and provider API verification.
The original Instagram OAuth grant also retains its actual originating
connection and original consent timestamp rather than acquiring fake fresh
scope rights from identity-only revalidation.

The protected owner/admin read-only preview requires exact matching:
provider + immutable provider account + provider application +
`source_connection_id=current connection UUID` + existing ownership,
timestamp, status, expiration and membership checks. Old owner proofs
cannot reauthorize a new owner even when recorded after transfer.
Unbound old evidence cannot be used for native account rights. The
writer refuses a single proof batch mixing connection IDs. If a late
old-owner proof overwrites the one-per-key v2 cache, the new owner's
rights become **unverified** until a new verified readback rather than
being incorrectly granted; tenant sending remains OFF throughout.
A future protected capability refresh must revalidate the exact current
connection and its generation and must not trust historical provider facts.

TDD RED: delayed previous-owner same-app readback incorrectly returned
`available` (1 failing real PG test / 6 passing). After fix the focused
Node24/PG17 eight-file suite passed 67/67, lint and strict TypeScript
PASS, Docker lab cleanup exit 0. A further negative test ensures that
same-app unbound legacy facts are invisible to the current owner. Full
independent verification is required before any commit.

Keep both matching SQL migrations **expand-only**, byte-identical
between isolated app and DB review clones. This change adds nullable
`source_connection_id uuid` solely to the new v2 table; it does not
alter original legacy schema or composite v2 primary key. The original legacy table and
writer's three-column conflict key remain untouched; no existing
production records, old app code, OAuth permissions, MFA or customer
traffic were modified. No production release or native account sending
was authorized.

### Final verification — origin-bound rollout (2026-11-15)

The full disposable Node 24 / PostgreSQL 17 lab
`ishikeit-p3-connection-bound-full2-20261115` completed with ESLint,
strict TypeScript, **994/994 Vitest tests across 123 files**, and a
compiled production build all PASS. Integration cases exercise true
cross-connection old-owner delayed readback, unbound legacy fact rejection,
same-app proof isolation, cross-connection mixed proof batch rejection,
actual anon/authenticated PostgreSQL database privileges, coexistence
with the original three-column INSERT and UPSERT, retained historic fact
quarantine, and Instagram account-deletion cleanup. Test exit 0, lab
cleanup 0, container list empty. No customer/provider data was used.

**No production writes were performed.** The native account preview
remains private read-only and tenant outgoing messaging remains OFF.
The GitHub protected release and provider owner consents remain separate
acceptance gates. This proof is not production approval or a release.
