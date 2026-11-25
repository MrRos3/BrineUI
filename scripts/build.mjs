import fs from 'node:fs';
import {spawnSync} from 'node:child_process';
const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
fs.mkdirSync('dist', {recursive:true});
fs.writeFileSync('build/package.lua', `return [==[${JSON.stringify(pkg)}]==]\n`);
const tool = process.env.DARKLUA || 'darklua';
const result = spawnSync(tool, ['process','src/Init.lua','dist/main.lua','--config','build/darklua.dev.config.json'], {stdio:'inherit'});
if (result.error) throw result.error;
if (result.status) process.exit(result.status);
const notices = [
  fs.readFileSync('LICENSE', 'utf8'),
  'Upstream MIT license:\n' + fs.readFileSync('licenses/Upstream-LICENSE', 'utf8'),
  'Icons dependency:\n' + fs.readFileSync('src/Icons/LICENSE', 'utf8'),
  fs.readFileSync('THIRD_PARTY_NOTICES.md', 'utf8'),
  'Lucide:\n' + fs.readFileSync('licenses/Lucide-LICENSE', 'utf8'),
  'Gravity UI:\n' + fs.readFileSync('licenses/Gravity-LICENSE', 'utf8'),
].join('\n\n');
const header = `--[==[\nBrineUI ${pkg.version} by ${pkg.author}\n${notices}\n]==]\n`;
const bundle = fs.readFileSync('dist/main.lua', 'utf8').replaceAll('\r\n', '\n');
const demo = fs.readFileSync('examples/StandaloneDemo.lua', 'utf8').replaceAll('\r\n', '\n');
fs.writeFileSync('dist/main.lua', header.replaceAll('\r\n','\n') + bundle);
fs.writeFileSync('dist/demo.lua', header.replaceAll('\r\n','\n') + `\nlocal Brine = (function()\n${bundle}\nend)()\n\nreturn (function(...)\n${demo}\nend)(Brine)\n`);
console.log(`Built dist/main.lua (${fs.statSync('dist/main.lua').size} bytes)`);
console.log(`Built dist/demo.lua (${fs.statSync('dist/demo.lua').size} bytes)`);
