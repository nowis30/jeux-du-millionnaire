import { execFileSync } from 'node:child_process';
import { existsSync, readFileSync } from 'node:fs';
import assert from 'node:assert/strict';
const modules = { client: 'client-jeux-millionnaire', server: 'server-jeux-millionnaire', mobile: 'mobile-jeux-millionnaire', releases: 'jeux-millionnaire-APK' };
for (const [directory, repository] of Object.entries(modules)) {
  const url = execFileSync('git', ['config', '-f', '.gitmodules', `submodule.${directory}.url`], { encoding: 'utf8' }).trim();
  assert.equal(url, `https://github.com/nowis30/${repository}.git`);
  const index = execFileSync('git', ['ls-files', '--stage', '--', directory], { encoding: 'utf8' });
  assert.match(index, /^160000 [0-9a-f]{40} 0\t/, `${directory} must pin a commit`);
}
for (const file of ['client/package.json', 'server/supabase/functions/heritier-api/index.ts', 'mobile/android/app/build.gradle']) {
  assert(existsSync(file), `Missing ${file}. Run npm run setup first.`);
}
assert.equal(JSON.parse(readFileSync('client/package.json', 'utf8')).name, '@hm/client');
console.log('Four submodule URLs and pinned commits verified; client, Supabase API and Android sources present.');
