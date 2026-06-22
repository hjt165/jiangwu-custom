import { test, expect, loginAndNavigate } from './helpers/test-helper';

test.describe('用户行为分析', () => {
  test.beforeEach(async ({ page }) => {
    await loginAndNavigate(page, '/stats/user');
  });

  test('显示用户行为分析页面', async ({ page }) => {
    await expect(page.locator('h2:has-text("用户行为分析")')).toBeVisible();
  });

  test('显示4个统计卡片', async ({ page }) => {
    await expect(page.locator('text=注册用户')).toBeVisible();
    await expect(page.locator('text=活跃用户')).toBeVisible();
    await expect(page.locator('text=留存率')).toBeVisible();
    await expect(page.locator('text=平均客单价')).toBeVisible();
  });

  test('统计卡片有数值显示', async ({ page }) => {
    const statValues = page.locator('.stat-value');
    const count = await statValues.count();
    expect(count).toBeGreaterThanOrEqual(4);
  });

  test('显示用户增长趋势图表', async ({ page }) => {
    await expect(page.locator('text=用户增长趋势')).toBeVisible();
    const growthChart = page.locator('div[style*="height: 350px"]').first();
    await expect(growthChart).toBeVisible();
  });

  test('显示用户构成图表', async ({ page }) => {
    await expect(page.locator('text=用户构成')).toBeVisible();
    const composeChart = page.locator('div[style*="height: 350px"]').nth(1);
    await expect(composeChart).toBeVisible();
  });
});
