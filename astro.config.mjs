// @ts-check
import { defineConfig } from 'astro/config';

import svelte from '@astrojs/svelte';
import mdx from '@astrojs/mdx';
import tailwindcss from '@tailwindcss/vite';

// https://astro.build/config
export default defineConfig({
  // GitHub Pages 项目页：站点根 + 仓库名作为 base。
  // base 必须等于仓库名（带前导斜杠、无尾斜杠）。改仓库名要同步改这里。
  site: 'https://flufy3d.github.io',
  base: '/codeblox',
  integrations: [svelte(), mdx()],

  vite: {
    plugins: [tailwindcss()]
  }
});