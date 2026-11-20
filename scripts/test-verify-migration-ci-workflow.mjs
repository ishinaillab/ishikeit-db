import test from "node:test";
import assert from "node:assert/strict";
import {readFile} from "node:fs/promises";
import {verifyOfflineMigrationWorkflow} from "./verify-migration-ci-workflow.mjs";

// Normalize checkout-specific CRLF so every negative mutation actually runs.
const valid=(await readFile(new URL("../.github/workflows/migration-ci.yml",import.meta.url),"utf8")).replace(/\r\n/gu,"\n");
test("requires every pull request to report the stable offline migration job",()=>{
  assert.deepEqual(verifyOfflineMigrationWorkflow(valid),{
    offline:true,requiredCheck:"migration-ci"
  });
  assert.throws(()=>verifyOfflineMigrationWorkflow(
    valid.replace("  pull_request:\n","  pull_request:\n    paths:\n      - 'supabase/migrations/**'\n")
  ),/Path-filtered/);
  assert.throws(()=>verifyOfflineMigrationWorkflow(
    valid.replace("  pull_request:\n","  pull_request:\n    branches: [main]\n")
  ),/every pull request/);
});
test("rejects remote Supabase changes and unauthorized deployment secrets",()=>{
  for(const unsafe of [
    valid+"\n  - run: supabase db reset --remote --yes\n",
    valid+"\n  - run: supabase db push --remote --yes\n",
    valid+"\n  - environment: production\n",
    valid+"\n    TOKEN: ${{ secrets.PRODUCTION_DATABASE_URL }}\n"
  ])assert.throws(()=>verifyOfflineMigrationWorkflow(unsafe),/unsafe privileges/);
});
test("refuses missing disposable cleanup, unsupported setup action and nonfatal lint",()=>{
  for(const unsafe of [
    valid.replace("if: always()","if: success()"),
    valid.replace("setup-cli@v3","setup-cli@v1"),
    valid.replace("db lint --fail-on error","db lint --fail-on none")
  ])assert.throws(()=>verifyOfflineMigrationWorkflow(unsafe));
});
