import { defineCollection, z } from 'astro:content';
import { glob } from 'astro/loaders';

// The site renders the repository's own docs: one source of truth.
const docs = defineCollection({
  loader: glob({ pattern: ['why-steadyship.md', 'quickstart/*.md'], base: '../docs' }),
  schema: z.object({}).passthrough(),
});

export const collections = { docs };
