// Copies the brand files from docs/brand into public/brand so the site and the
// repository share one source for the mark and the logo.
import { cpSync, mkdirSync, readdirSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { join } from 'node:path';

const here = fileURLToPath(new URL('.', import.meta.url));
const src = join(here, '..', '..', 'docs', 'brand');
const dst = join(here, '..', 'public', 'brand');
mkdirSync(dst, { recursive: true });
for (const f of readdirSync(src)) {
  if (/\.(svg|png)$/.test(f)) cpSync(join(src, f), join(dst, f));
}
cpSync(join(src, 'mark-colour.svg'), join(here, '..', 'public', 'favicon.svg'));
