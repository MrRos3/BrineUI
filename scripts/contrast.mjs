// WCAG contrast for the Liquid themes. Glass shows whatever is behind it, so each pair is measured
// with the window over pure black and over pure white, without counting on the background blur.
import fs from 'node:fs';
const source = fs.readFileSync('src/themes/Liquid.lua', 'utf8');
const read = block => Object.fromEntries([...block.matchAll(/(\w+) = (?:hex\("(\w{6})"\)|([\d.]+))/g)].map(m => [m[1], m[2] ?? Number(m[3])]));
const cutAt = source.indexOf('local Light');
const dark = read(source.slice(0, cutAt));
const themes = {Liquid: dark, 'Liquid Light': {...dark, ...read(source.slice(cutAt))}};
const rgb = h => [0, 2, 4].map(i => parseInt(h.slice(i, i + 2), 16));
const over = (fg, bg, t) => fg.map((c, i) => c * (1 - t) + bg[i] * t);
const lum = c => { const [r, g, b] = c.map(v => (v /= 255) <= 0.03928 ? v / 12.92 : ((v + 0.055) / 1.055) ** 2.4); return 0.2126 * r + 0.7152 * g + 0.0722 * b; };
const ratio = (a, b) => { const [x, y] = [lum(a), lum(b)].sort((p, q) => q - p); return (x + 0.05) / (y + 0.05); };
// Layers are stacked over the backdrop in order.
const WINDOW = ['WindowBackground'], PANEL = [...WINDOW, 'PanelBackground'], CARD = [...PANEL, 'ElementBackground'];
const FIELD = [...CARD, 'Field'], TAB = [...WINDOW, 'TabBackgroundActive'];
// [text, layers, minimum, text transparency]
const pairs = [
  ['Text', WINDOW, 4.5, 0], ['Text', WINDOW, 4.5, 0.25], ['Text', WINDOW, 4.5, 'TabTextTransparency'], ['Text', TAB, 4.5, 0],
  ['Text', PANEL, 4.5, 0.1], ['Text', PANEL, 4.5, 0.25], ['Text', CARD, 4.5, 0], ['Text', CARD, 4.5, 0.2], ['Icon', CARD, 3, 0],
  ['Text', FIELD, 4.5, 0], ['Placeholder', FIELD, 4.5, 0], ['Placeholder', [...WINDOW, 'Field'], 4.5, 0],
  ['Slider', CARD, 3, 0], ['#FFFFFF', ['=Button'], 4.5, 0], ['#FFFFFF', ['=Checkbox'], 3, 0],
  ['Text', ['Dialog'], 4.5, 0.2], ['Text', ['DropdownBackground'], 4.5, 0.2], ['Text', ['Notification'], 4.5, 'NotificationContentTransparency'],
  ['#FFFFFF', ['=Tooltip'], 4.5, 0],
];
let failed = 0;
for (const [name, t] of Object.entries(themes)) for (const backdrop of ['000000', 'FFFFFF']) for (const [fg, layers, min, tr] of pairs) {
  let b = rgb(backdrop);
  for (const l of layers) b = l[0] === '=' ? rgb(t[l.slice(1)]) : over(rgb(t[l]), b, t[`${l}Transparency`] ?? 0);
  const f = over(rgb(fg[0] === '#' ? fg.slice(1) : t[fg]), b, typeof tr === 'string' ? t[tr] : tr), r = ratio(f, b);
  if (r < min) { failed++; console.error(`FAIL ${name} over ${backdrop}: ${fg} on ${layers.at(-1)} ${r.toFixed(2)} < ${min}`); }
}
if (failed) process.exit(1);
console.log(`PASS: ${pairs.length * 4} contrast pairs across 2 themes, over black and over white.`);
