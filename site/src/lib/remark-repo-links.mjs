// Rewrites the relative links inside docs/*.md so they work on the site:
// pages the site has become site routes, everything else points at GitHub.
import path from 'node:path';
import { visit } from 'unist-util-visit';

const REPO = 'https://github.com/cookc/steadyship/blob/main/';

const ROUTES = {
  'README.md': '/',
  'README.md#quick-start': '/get-started',
  'docs/why-steadyship.md': '/why',
  'docs/quickstart/windows-claude-desktop.md': '/get-started#windows-claude-desktop',
  'docs/quickstart/windows-claude-code.md': '/get-started#windows-claude-code',
  'docs/quickstart/mac-claude-desktop.md': '/get-started#mac-claude-desktop',
  'docs/quickstart/mac-linux-claude-code.md': '/get-started#mac-linux-claude-code',
};

export function remarkRepoLinks() {
  return (tree, file) => {
    const repoRoot = path.resolve(file.cwd, '..');
    const fromDir = path.dirname(file.path ?? path.join(repoRoot, 'docs', 'x.md'));
    visit(tree, 'link', (node) => {
      const url = node.url ?? '';
      if (/^([a-z]+:|#|\/)/i.test(url)) return;
      const [target, hash] = url.split('#');
      const abs = path.resolve(fromDir, target);
      const rel = path.relative(repoRoot, abs).split(path.sep).join('/');
      const withHash = hash ? `${rel}#${hash}` : rel;
      node.url = ROUTES[withHash] ?? ROUTES[rel] ?? REPO + rel + (hash ? `#${hash}` : '');
    });
  };
}
