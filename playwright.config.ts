import { defineConfig } from '@playwright/test';

// E2E：用 dev server（无需先 build）验证交互关键路径。
export default defineConfig({
  testDir: './e2e',
  timeout: 30_000,
  fullyParallel: false,
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:4321/codeblox/',
    reuseExistingServer: true,
    timeout: 120_000,
  },
  use: { headless: true },
});
