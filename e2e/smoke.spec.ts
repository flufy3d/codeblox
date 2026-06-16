import { test, expect } from '@playwright/test';

const BASE = 'http://localhost:4321/codeblox/';

test('核心路径：建档案 → 完成一课 → 进度持久化', async ({ page }) => {
  await page.goto(BASE);

  // 1. 创建学习者档案（重试点开菜单，等 header 孤岛水合）
  await expect(async () => {
    await page.getByRole('button', { name: /谁在学习/ }).click();
    await expect(page.getByRole('button', { name: '＋ 新建小档案' })).toBeVisible({ timeout: 1500 });
  }).toPass({ timeout: 20_000 });
  await page.getByRole('button', { name: '＋ 新建小档案' }).click();
  await page.getByPlaceholder('起个名字').fill('小明');
  await page.getByRole('button', { name: '创建' }).click();
  await expect(page.getByRole('button', { name: /小明/ })).toBeVisible();

  // 2. 进入第一课（点“继续学习”横幅）
  await page.getByRole('link', { name: /打开我的工作室/ }).click();
  await expect(page).toHaveURL(/01-01-open-studio/);

  // 3. 勾选全部任务（等孤岛水合：checkbox 从 disabled 变 enabled）
  const checks = page.locator('main input[type=checkbox]');
  await expect(checks.first()).toBeEnabled({ timeout: 10_000 });
  const n = await checks.count();
  for (let i = 0; i < n; i++) await checks.nth(i).check();

  // 4. 答对小测验
  await page.getByRole('button', { name: 'Roblox Studio', exact: true }).click();
  await page.getByRole('button', { name: 'W / A / S / D', exact: true }).click();
  await page.getByRole('button', { name: '按住鼠标右键拖动', exact: true }).click();
  await page.getByRole('button', { name: '提交答案' }).click();
  await expect(page.getByText(/答对 3 \/ 3/)).toBeVisible();

  // 5. 完成这一课
  const completeBtn = page.getByRole('button', { name: /完成这一课/ });
  await expect(completeBtn).toBeEnabled();
  await completeBtn.click();
  await expect(page.getByText('完成啦！')).toBeVisible();

  // 6. 进度已写入 localStorage
  const data = await page.evaluate(() => {
    const s = JSON.parse(localStorage.getItem('codeblox.v1') || '{}');
    const pid = s.activeProfileId;
    const p = s.profiles?.[pid]?.progress;
    return { xp: p?.xp ?? 0, done: !!p?.completedLessons?.['1.1'] };
  });
  expect(data.xp).toBeGreaterThan(0);
  expect(data.done).toBe(true);

  // 7. 刷新后档案与进度仍在（本地保存生效）
  await page.goto(BASE);
  await expect(page.getByRole('button', { name: /小明/ })).toBeVisible();
});
