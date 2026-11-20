# Ishikeit Priority 3 — protected database release hold

Updated: 2026-11-15 (Asia/Manila). This document is a **local-only
implementation checkpoint**, not permission to deploy or enable native tenant
messaging. Keep Priority 4/5 blocked.

## Source, CI and migration facts

- This review branch adds `.github/workflows/migration-ci.yml`: a
  non-deploying, credentials-free GitHub Actions candidate that checks
  migration filenames/unique timestamps, starts **disposable local** Supabase,
  replays `supabase/migrations` with `supabase db reset --no-seed` **without
  `--remote`**, lints local `public` SQL with `--fail-on error`, and stops
  the runner's local Supabase resources. This workflow has not been pushed
  to GitHub or passed hosted CI. It contains no production migration command.
- `node --test scripts/test-verify-migration-layout.mjs` passed **3/3**
  locally. `node scripts/verify-migration-layout.mjs` counted **42 unique
  versioned SQL migrations**, including the three draft Priority 3 versions.
- The matching application SQL
  `migrations/0026_priority3_active_disconnect_quarantine.sql` and
  database SQL `20261115040000_priority3_active_disconnect_quarantine.sql`
  were independently SHA-256 verified identical:
  `10095ec305745aebe2ca97f8df4198fba8930556fe1f690e26192b25cf1cf63f`.
- Existing live production migration history remains unchanged. In particular,
  draft versions `20261115013500`, `20261115021500` and
  `20261115040000` have **not** been applied to production.

## Mandatory external owner/release boundaries (NOT completed)

1. Ensure a **single** exclusive owner and fencing generation across GitHub,
   Supabase and Hostinger. Verify all other windows/workflows/agents cannot
   modify either repository or deploy during the protected release; keep
   the current coordination hold until that is proven. There is no proof
   that other ChatGPT conversations, GitHub bots or Windows processes are
   stopped merely because this review checkout is clean.
2. GitHub owners must enable branch rules for BOTH repositories: reviewed PRs,
   required successful app CI and this DB `migration-ci` check, prevention
   of force push/deletion and appropriate bypass restrictions. Configure a
   genuinely protected release environment with real reviewer enforcement
   **only where the private-repository plan supports it**; an environment
   name by itself is not protection. Confirm rules via API/readback.
3. Hostinger currently has automatic deployment enabled on app `main`.
   A protected release needs this path disabled or otherwise externally
   intercepted **without removing the running app** and with documented
   restoration and rollback. No Hostinger configuration has been changed.
4. A privileged controller must recheck the exact approved app/DB `main`
   SHAs and the current PostgreSQL release-fence generation before each
   migration/deployment side effect. The existing PG fencing primitive
   alone does not stop direct Hostinger or database writes. Test competing
   claims, stale and expired leases, unapproved branches and bypass routes.
5. Confirm a retrievable production backup and tested recovery, owner MFA,
   read-only remote migration-history parity, Supabase project identity,
   application/DB API compatibility and the final diff. Deploy **additive
   database expansion first**, then an exact reviewed application commit.
   Release ownership is distinct from provider owner consent.
6. Native provider onboarding, revocation and current-account customer-origin
   acceptance must pass independently. Existing legacy messaging is the
   production baseline; never revoke a shared app token or turn on native
   outbound routing merely because mocked provider tests pass.
7. Meta App Review submission remains held for a separate explicit owner
   decision; this branch changes no Meta permissions or accounts.

## Verification limitations

- DB workflow syntax/content and migration-name tests were inspected locally;
  a real hosted Supabase CLI database rebuild has **not** been performed.
  The application-side matching migration was executed successfully in
  disposable PostgreSQL 17 integration tests. Both need protected
  GitHub-hosted acceptance before release.
- No push, merge, production SQL, Hostinger configuration, provider consent,
  customer send, deployment or Meta submission has been performed here.
