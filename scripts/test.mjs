import fs from 'node:fs';
import path from 'node:path';
import os from 'node:os';
import {spawnSync} from 'node:child_process';
const compiler=process.env.LUAU_COMPILE || 'luau-compile';
const runtime=process.env.LUAU || 'luau';
function files(dir){return fs.readdirSync(dir,{withFileTypes:true}).flatMap(e=>e.isDirectory()&&e.name!=='.git'?files(path.join(dir,e.name)):e.name.endsWith('.lua')?[path.join(dir,e.name)]:[])}
const sources=files('src').concat(['dist/main.lua','dist/demo.lua',...files('examples')]);
for(const source of sources){const r=spawnSync(compiler,['--null',source],{encoding:'utf8'}); if(r.error)throw r.error;if(r.status){console.error(source,r.stderr,r.stdout);process.exit(r.status)}}
console.log(`PASS: ${sources.length} Luau files compile, including distribution.`);
const stub=fs.readFileSync('tests/navigation.luau','utf8');
const source=fs.readFileSync('src/components/window/Tab.lua','utf8');
const fixture=stub.replace('-- INSERT TAB MODULE',`local TabModule = (function()\n${source}\nend)()`);
const dir=fs.mkdtempSync(path.join(os.tmpdir(),'brine-test-'));
try {
 const standalone=fs.readFileSync('tests/standalone.luau','utf8')
  .replace('-- INSERT BUNDLE', () => fs.readFileSync('dist/main.lua','utf8'))
  .replace('-- INSERT EXAMPLE', () => fs.readFileSync('examples/StandaloneDemo.lua','utf8'));
 for (const [name, test] of [['navigation', fixture], ['standalone', standalone]]) {
  const file=path.join(dir,`${name}.luau`);
  fs.writeFileSync(file,test);
  const r=spawnSync(runtime,[file],{stdio:'inherit'});
  if(r.error)throw r.error;
  if(r.status)process.exitCode=r.status;
 }
} finally {fs.rmSync(dir,{recursive:true,force:true})}
