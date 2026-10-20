// @ts-check
import { defineConfig } from 'astro/config';
import tailwindcss from '@tailwindcss/vite';
import { remarkRepoLinks } from './src/lib/remark-repo-links.mjs';

export default defineConfig({
  site: 'https://steadyship.vercel.app',
  markdown: {
    remarkPlugins: [remarkRepoLinks],
    shikiConfig: { themes: { light: 'github-light', dark: 'github-dark' } },
  },
  vite: { plugins: [tailwindcss()] },
});
