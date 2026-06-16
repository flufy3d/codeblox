import { defineConfig } from 'vitest/config';

// 仅跑 src 下的单测；e2e/ 的 Playwright 用例由 playwright test 单独运行。
export default defineConfig({
  test: {
    include: ['src/**/*.test.ts'],
  },
});
