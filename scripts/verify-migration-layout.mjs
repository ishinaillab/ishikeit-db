import {readdir} from "node:fs/promises";
import {fileURLToPath} from "node:url";
import {resolve,dirname} from "node:path";

const migrationPattern=/^([0-9]{14})_([a-z][a-z0-9_]*)\.sql$/u;
// These versions are part of the unapproved stacked Priority 3 release;
// making them mandatory here only prevents losing them from THIS review
// branch. It does not mean they are applied, tested in hosted CI or released.
export const priority3MigrationVersions=Object.freeze([
  "20261115013500",
  "20261115021500",
  "20261115040000",
  "20261115040500",
  "20261118222000"
]);
export function verifyMigrationNames(names,required=priority3MigrationVersions){
  if(!Array.isArray(names)||names.length===0)throw Error("No versioned SQL migrations found");
  const versions=new Set(),matched=[];
  for(const name of names){
    if(typeof name!=="string")throw Error("Invalid SQL migration entry");
    if(!name.toLowerCase().endsWith(".sql"))continue;
    const parts=migrationPattern.exec(name);
    if(parts===null)throw Error("SQL migration filename is not versioned");
    if(versions.has(parts[1]))throw Error("Duplicate migration timestamp");
    versions.add(parts[1]);
    matched.push(name);
  }
  if(matched.length===0)throw Error("No versioned SQL migrations found");
  for(const version of required){
    if(!versions.has(version))throw Error("Priority 3 migration source missing");
  }
  // Verify no filesystem sorting aliases or hidden duplicate migrations.
  const sequence=[...matched].sort((a,b)=>a.localeCompare(b));
  if(sequence.length!==versions.size)throw Error("Unrecognized SQL migration entry");
  return {count:matched.length,first:sequence[0],last:sequence.at(-1)};
}
const ownFile=fileURLToPath(import.meta.url);
if(process.argv[1]!==undefined && resolve(process.argv[1])===ownFile){
  try{
    const migrations=resolve(dirname(ownFile),"../supabase/migrations");
    const result=verifyMigrationNames(await readdir(migrations));
    process.stdout.write(
      "Local migration naming verified: "+result.count+" distinct ordered SQL versions.\n");
  }catch{
    process.stderr.write("Priority 3 database migration source integrity failed.\n");
    process.exitCode=1;
  }
}
