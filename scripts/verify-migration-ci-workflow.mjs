import {readFile} from "node:fs/promises";
import {resolve,dirname} from "node:path";
import {fileURLToPath} from "node:url";

/** Local static guard against accidentally turning the mandatory DB status
 * check into an optional/path-filtered workflow, or accidentally introducing
 * remote Supabase actions. This is NOT a GitHub ruleset or migration gate.
 * GitHub-hosted actionlint and disposable CLI execution remain separate.
 */
export function verifyOfflineMigrationWorkflow(yaml){
  if(typeof yaml!=="string"||yaml.length<300||yaml.length>30000)
    throw Error("Migration workflow source missing or unreasonable");
  if(/^\s+paths(?:-ignore)?:/mu.test(yaml))
    throw Error("Path-filtered required check can remain unreported for some PRs");
  const requirements=[
    [/^on:\s*\n  pull_request:\s*\n  push:\s*\n    branches: \[main\]\s*\n  workflow_dispatch:/mu,
      "Required check must run on every pull request"],
    [/^permissions:\s*\n  contents: read\s*$/mu,
      "Migration CI must have least-privileged read-only permissions"],
    [/^  migration-ci:\s*\n    name: migration-ci\s*$/mu,
      "Stable mandatory migration-ci job identity missing"],
    [/uses: supabase\/setup-cli@v3/u,"Supported Supabase CLI setup action absent"],
    [/version: '\^3'/u,"Stable Supabase CLI v3 major version not constrained"],
    [/^\s+supabase db start\s*$/mu,"Disposable DB-only start required"],
    [/^\s+run: supabase db reset --no-seed\s*$/mu,
      "Disposable no-seed migration replay missing"],
    [/^\s+run: supabase db lint --fail-on error --schema public\s*$/mu,
      "Fatal schema lint check missing"],
    [/^\s+run: supabase stop --no-backup\s*$/mu,
      "Runner-scoped cleanup missing"],
    [/^\s+if: always\(\)\s*$/mu,
      "Cleanup must run even after failed migrations"]
  ];
  for(const [regex,reason] of requirements){
    if(!regex.test(yaml))throw Error(reason);
  }
  // Never introduce production credentials or manual remote-operation flags.
  for(const blocked of [
    /\$\{\{\s*secrets\./u,
    /\$\{\{\s*vars\./u,
    /^\s+(?:-\s*)?(?:run:\s*)?supabase (?:link|login|db push|db pull|db dump|projects)/mu,
    /^\s+(?:-\s*)?(?:run:\s*)?supabase db (?:reset|lint|start) .*--remote/mu,
    /^\s+(?:-\s*)?(?:run:\s*)?supabase db reset .*--(?:db-url|linked|project-ref)/mu,
    /^\s+(?:-\s*)?environment:/mu
  ]){
    if(blocked.test(yaml))throw Error("Offline migration CI gained unsafe privileges");
  }
  return {offline:true,requiredCheck:"migration-ci"};
}

const self=fileURLToPath(import.meta.url);
if(process.argv[1]!==undefined&&resolve(process.argv[1])===self){
  try{
    const wf=await readFile(resolve(dirname(self),"../.github/workflows/migration-ci.yml"),"utf8");
    verifyOfflineMigrationWorkflow(wf);
    process.stdout.write("Offline migration CI safety guard accepted locally.\n");
  }catch{
    process.stderr.write("Offline migration CI safety guard rejected the workflow.\n");
    process.exitCode=1;
  }
}
