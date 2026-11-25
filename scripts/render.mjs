// Runs the real bundle in tests/render/engine.luau and writes an HTML approximation of each scene.
// Usage: node scripts/render.mjs [outDir] [bundle]. Needs LUAU, or luau on PATH.
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';

const out = process.argv[2] || 'build/render';
const bundlePath = process.argv[3] || 'dist/main.lua';
const VIEW = {w: 900, h: 640};
const metrics = JSON.parse(fs.readFileSync('tests/render/metrics.json', 'utf8'));
const lua = t => '{' + Object.entries(t).map(([k, v]) => `[${k}]=${v}`).join(',') + '}';
const prelude = `METRICS={regular=${lua(metrics.regular)},bold=${lua(metrics.bold)},scale=${metrics.scale},line=${metrics.line}}\nVIEW_W,VIEW_H=${VIEW.w},${VIEW.h}\n`;
const engine = fs.readFileSync('tests/render/engine.luau', 'utf8');
const bundle = fs.readFileSync(bundlePath, 'utf8');
const icons = {};
for (const m of fs.readFileSync('src/Icons/lucide/dist/Icons.lua', 'utf8').matchAll(/\["?([\w-]+)"?\] = "(rbxassetid:\/\/\d+)"/g)) icons[m[2]] ??= m[1];
for (const m of fs.readFileSync('src/Icons/lucide/dist/Icons.lua', 'utf8').matchAll(/^\s+([a-z]\w*) = "(rbxassetid:\/\/\d+)"/gm)) icons[m[2]] ??= m[1];
const shapes = {};
for (const m of fs.readFileSync('src/modules/DynamicShape.lua', 'utf8').matchAll(/([\w-]+)(?:"\])? = \{\s+Image = "(rbxassetid:\/\/\d+)",\s+Rect = [^\n]+\n\s+Radius = (\d+) \/ 2/g)) shapes[m[2]] = {name: m[1], radius: m[3] / 2};
const weight = w => ({Thin: 200, Light: 300, Regular: 400, Medium: 500, SemiBold: 600, Bold: 700, Heavy: 900}[w] || 400);
const esc = s => s.replace(/<font color ?= ?"(#\w+)">/g, '<b style="font-weight:inherit;color:$1">').replaceAll('</font>', '</b>').replace(/&(?!\w+;)/g, '&amp;').replace(/<(?!\/?(b|i|u|s)\b)/g, '&lt;');
const rgba = (hex, t) => `rgba(${parseInt(hex.slice(1, 3), 16)},${parseInt(hex.slice(3, 5), 16)},${parseInt(hex.slice(5, 7), 16)},${(1 - t).toFixed(3)})`;
const corners = (name, r) => ({Square: '0', 'SquircleH-TL-TR': `${r}px 0 0 ${r}px`, 'SquircleH-BL-BR': `0 ${r}px ${r}px 0`, 'Squircle-TL-TR': `${r}px ${r}px 0 0`, 'Squircle-BL-BR': `0 0 ${r}px ${r}px`})[name] || `${r}px`;

function node(n, px, py) {
  const s = [`left:${n.x - px}px`, `top:${n.y - py}px`, `width:${n.w}px`, `height:${n.h}px`, `z-index:${n.z}`];
  let inner = '';
  // Roblox multiplies a gradient's color and transparency with the object's own.
  const ramp = (g, base, tr) => {
    const stops = [...new Set([0, 1, ...g.c.map(k => k[0]), ...g.t.map(k => k[0])])].sort((p, q) => p - q);
    const at = (keys, x, fallback, mix) => {
      if (!keys.length) return fallback;
      let i = keys.findIndex(k => k[0] >= x);
      if (i <= 0) return keys[Math.max(i, 0)][1];
      const [t0, v0] = keys[i - 1], [t1, v1] = keys[i];
      return mix(v0, v1, (x - t0) / (t1 - t0 || 1));
    };
    const rgbOf = h => [1, 3, 5].map(i => parseInt(h.slice(i, i + 2), 16));
    return `linear-gradient(${90 + (g.r || 0)}deg,${stops.map(x => {
      const tint = rgbOf(at(g.c, x, '#ffffff', (p, q, k) => k < 0.5 ? p : q)), own = rgbOf(base);
      const alpha = (1 - tr) * (1 - at(g.t, x, 0, (p, q, k) => p + (q - p) * k));
      return `rgba(${own.map((v, i) => Math.round(v * tint[i] / 255)).join(',')},${alpha.toFixed(3)}) ${(x * 100).toFixed(0)}%`;
    }).join(',')})`;
  };
  if (n.bg && n.bt < 1) s.push(`background:${n.g ? ramp(n.g, n.bg, n.bt) : rgba(n.bg, n.bt)}`);
  if (n.img) {
    const sh = shapes[n.img];
    if (sh) {
      s.push(`border-radius:${corners(sh.name, Math.min(sh.radius * n.ss, n.w / 2, n.h / 2))}`);
      if (/Outline/.test(sh.name)) s.push(`box-shadow:inset 0 0 0 1.4px ${rgba(n.ic, n.it)}`);
      else if (/Glass/.test(sh.name)) s.push(`box-shadow:inset 0 0 0 1px ${rgba(n.ic, 1 - (1 - n.it) * 0.5)}`);
      else s.push(`background:${n.g ? ramp(n.g, n.ic, n.it) : rgba(n.ic, n.it)}`);
      // Stands in for the live background blur behind the window.
      if (n.n === 'Background' && n.k.some(k => k.n === 'Glass') && n.w > 300 && n.it < 1) s.push('backdrop-filter:blur(22px) saturate(1.5)');
    } else if (n.img === 'rbxassetid://8992230677') {
      inner += `<i style="position:absolute;inset:50px;border-radius:22px;box-shadow:0 0 50px ${rgba(n.ic, n.it)}"></i>`;
    } else if (n.img === 'rbxassetid://120997033468887') {
      inner += `<i style="position:absolute;right:42%;bottom:42%;width:14px;height:14px;border:solid ${rgba(n.ic, n.it)};border-width:0 2px 2px 0;border-radius:0 0 10px 0"></i>`;
    } else if (n.img.startsWith('rbxasset') && n.w <= 40) {
      s.push(`color:${rgba(n.ic, n.it)}`);
      inner += `<i data-lucide="${icons[n.img] || 'check'}"${icons[n.img] ? '' : ` data-unmapped="${n.img}"`}></i>`;
    }
  }
  const r = n.r || 0;
  if (r) s.push(`border-radius:${Math.min(r, n.w / 2, n.h / 2)}px`);
  if (n.sc) {
    const paint = n.sg ? ramp(n.sg, n.sc, n.st) : `linear-gradient(${rgba(n.sc, n.st)},${rgba(n.sc, n.st)})`;
    inner += `<i style="position:absolute;inset:${-n.sw}px;padding:${n.sw}px;border-radius:${Math.min(r, n.w / 2, n.h / 2) + n.sw}px;background:${paint};-webkit-mask:linear-gradient(#000 0 0) content-box exclude,linear-gradient(#000 0 0);mask:linear-gradient(#000 0 0) content-box exclude,linear-gradient(#000 0 0);pointer-events:none"></i>`;
  }
  if (n.clip) s.push('overflow:hidden');
  if (n.rot) s.push(`transform:rotate(${n.rot}deg)`);
  if (n.t) {
    const j = {Left: 'flex-start', Center: 'center', Right: 'flex-end'}[n.ta], a = {Top: 'flex-start', Center: 'center', Bottom: 'flex-end'}[n.tv];
    inner += `<span style="position:absolute;inset:${n.tp[1]}px ${n.tp[2]}px ${n.tp[3]}px ${n.tp[0]}px;display:flex;justify-content:${j};align-items:${a};text-align:${n.ta.toLowerCase()};color:${rgba(n.tc, n.tt)};font:${weight(n.fw)} ${n.ts * metrics.scale}px/${n.ts * metrics.line}px var(--face);white-space:${n.tw ? 'normal' : 'pre'}"><span data-text>${esc(n.t)}</span></span>`;
  }
  return `<div data-n="${n.n}" style="position:absolute;box-sizing:border-box;${s.join(';')}">${inner}${n.k.map(k => node(k, n.x, n.y)).join('')}</div>`;
}

fs.mkdirSync(out, {recursive: true});
const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'brine-render-'));
let failed = false;
for (const f of fs.readdirSync('tests/render/scenes').filter(f => f.endsWith('.luau') && f.startsWith(process.env.SCENE || ''))) {
  const source = fs.readFileSync(`tests/render/scenes/${f}`, 'utf8');
  const themes = (process.env.THEMES || (source.match(/^-- themes: (.+)$/m) || [, 'Liquid,Liquid Light'])[1]).split(',').map(s => s.trim());
  for (const theme of themes) {
    const name = `${f.replace('.luau', '')}-${theme.toLowerCase().replaceAll(' ', '-')}`;
    const file = path.join(dir, 'scene.luau');
    fs.writeFileSync(file, prelude + engine
      .replace('-- INSERT BUNDLE', () => `local Brine=(function()\n${bundle}\nend)()\nlocal THEME=${JSON.stringify(theme)}\n`)
      .replace('-- INSERT SCENE', () => source));
    const r = spawnSync(process.env.LUAU || 'luau', [file], {encoding: 'utf8', maxBuffer: 1 << 28});
    const lines = (r.stdout || '').split(/\r?\n/);
    const json = lines.find(l => l.startsWith('@@'));
    for (const l of lines) if (l && !l.startsWith('@@')) console.log(`  [${name}] ${l}`);
    if (!json) { console.error(`FAIL ${name}`, (r.stderr || r.stdout || String(r.error)).slice(0, 1500)); failed = true; continue; }
    const data = JSON.parse(json.slice(2));
    const errors = [...new Set(data.errors)];
    if (errors.length) { failed = true; console.error(`ERRORS ${name}:\n${errors.slice(0, 4).join('\n')}`); }
    fs.writeFileSync(path.join(out, `${name}.html`), `<!doctype html><html lang="en"><meta charset="utf-8"><title>${name}</title><link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap"><style>:root{--face:'Inter',sans-serif}body{margin:0;background:radial-gradient(circle at 78% 18%,#ffd27a 0 8%,transparent 30%),radial-gradient(circle at 20% 85%,#1fae6b 0 14%,transparent 42%),radial-gradient(circle at 85% 80%,#7a4bff 0 10%,transparent 40%),linear-gradient(160deg,#38b6ff,#0b5fd0 55%,#123a6b);width:${VIEW.w}px;height:${VIEW.h}px;position:relative;overflow:hidden}svg{width:100%;height:100%;display:block}i{font-style:normal}</style><div style="position:relative;width:${VIEW.w}px;height:${VIEW.h}px">${data.nodes.map(n => node(n, 0, 0)).join('')}</div><script src="https://unpkg.com/lucide@0.460.0/dist/umd/lucide.min.js"></script><script>lucide.createIcons()</script></html>`);
    console.log(`rendered ${name}`);
  }
}
fs.rmSync(dir, {recursive: true, force: true});
process.exitCode = failed ? 1 : 0;
