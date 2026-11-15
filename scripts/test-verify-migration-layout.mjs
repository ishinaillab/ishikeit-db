import {test} from "node:test";
import assert from "node:assert/strict";
import {verifyMigrationNames,priority3MigrationVersions} from "./verify-migration-layout.mjs";

const names=[
  "20260930005600_foundation.sql",
  "20261115013500_provider_account_capability_app_scope.sql",
  "20261115021500_priority3_release_ownership_fence.sql",
  "20261115040000_priority3_active_disconnect_quarantine.sql",
  "20261115040500_priority3_tenant_send_generation_fence.sql"
];
test("accepts exact ordered unique Priority 3 migration source list",()=>{
  assert.deepEqual(priority3MigrationVersions,[
    "20261115013500","20261115021500","20261115040000","20261115040500"
  ]);
  assert.deepEqual(verifyMigrationNames(names),{
    count:5,first:"20260930005600_foundation.sql",
    last:"20261115040500_priority3_tenant_send_generation_fence.sql"
  });
});
test("rejects missing protected migration and duplicate version history",()=>{
  assert.throws(()=>verifyMigrationNames(names.slice(0,-1)),/source missing/);
  assert.throws(()=>verifyMigrationNames([...names,
    "20261115040000_different_duplicate.sql"]),/Duplicate migration/);
});
test("rejects unversioned, malformed and missing source without fallback",()=>{
  for(const invalid of [
    [...names,"manual_change.sql"],
    [...names,"20261115050000_unsafe-dash.sql"],
    [...names,"20261115050000_invalid.SQL"],
    [...names,"20261115050000_.sql"]
  ])assert.throws(()=>verifyMigrationNames(invalid),/versioned|unrecognized/);
  assert.throws(()=>verifyMigrationNames([]),/No versioned/);
});
