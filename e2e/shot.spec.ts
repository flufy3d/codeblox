import { test, expect } from '@playwright/test';

const BASE = 'http://localhost:4321/codeblox/';

// 仅用于人工视觉检查 UI（不是断言测试）
test('截图：地图轮播 + 底部导航', async ({ page }) => {
  await page.setViewportSize({ width: 430, height: 880 });
  await page.goto(BASE);

  await expect(async () => {
    await page.getByRole('button', { name: /谁在学习/ }).click();
    await expect(page.getByRole('button', { name: '＋ 新建小档案' })).toBeVisible({ timeout: 1500 });
  }).toPass({ timeout: 20_000 });
  await page.getByRole('button', { name: '＋ 新建小档案' }).click();
  await page.getByPlaceholder('起个名字').fill('小明');
  await page.getByRole('button', { name: '创建' }).click();
  await page.waitForTimeout(600);
  await page.screenshot({ path: 'test-results/ui-home.png' });

  // 翻到第 3 单元看看轮播切换
  await page.getByRole('button', { name: '第一个脚本：让方块听我的话' }).click();
  await page.waitForTimeout(500);
  await page.screenshot({ path: 'test-results/ui-unit3.png' });

  // 徽章墙
  await page.goto(BASE + 'badges/');
  await page.waitForTimeout(500);
  await page.screenshot({ path: 'test-results/ui-badges.png' });
});
