import fs from 'node:fs';
import {createHash} from 'node:crypto';

const baseline = JSON.parse(fs.readFileSync('tests/api-baseline.json', 'utf8'));
const normalize = source => source.replaceAll('\r\n', '\n');
const strip = source => source.replace(/--\[\[[\s\S]*?\]\]/g, '').replace(/--[^\n]*/g, '');

// The fixture captures the pinned public signatures and originally supported options.
for (const [file, {methods, options}] of Object.entries(baseline)) {
  const source = strip(normalize(fs.readFileSync(file, 'utf8')));
  const signatures = [...source.matchAll(/function\s+(\w+[.:][\w.:]+)\s*\(([^)]*)\)/g)]
    .map(match => match[1] + '(' + match[2].replace(/\s+/g, ' '));
  const reads = new Set([...source.matchAll(/\b(\w*Config)\.(\w+)/g)].map(match => match[0]));

  for (const method of methods) {
    // Existing arguments must stay in order. A method can add trailing optional arguments.
    if (!signatures.some(signature => signature === method || signature.startsWith(method + ', '))) {
      throw Error(file + ': lost signature ' + method + ')');
    }
  }

  for (const option of options) {
    if (!reads.has(option)) throw Error(file + ': no longer reads ' + option);
  }
}

const upstreamLicense = normalize(fs.readFileSync('licenses/Upstream-LICENSE', 'utf8'));
const upstreamHash = createHash('sha256').update(upstreamLicense).digest('hex');
if (upstreamHash !== '44d844d76e61f8a2ce40cba22d1962d65153c8f140d94d52eb2cbad3c25f6020') {
  throw Error('Upstream MIT license changed');
}

const projectLicense = normalize(fs.readFileSync('LICENSE', 'utf8'));
if (projectLicense !== upstreamLicense.replace('Copyright (c) 2026 Footages', 'Copyright (c) 2026 Salty (MrRos3)')) {
  throw Error('BrineUI MIT license changed');
}

console.log('PASS: API signatures and options for ' + Object.keys(baseline).length + ' modules, plus both MIT licenses.');
