import { test, expect, loginAndNavigate } from './helpers/test-helper';

test.describe('交易统计', () => {
  test.beforeEach(async ({ page }) => {
    await loginAndNavigate(page, '/stats/transaction');
  });

  test('显示交易统计页面', async ({ page }) => {
    await expect(page.locator('h2:has-text("交易统计")')).toBeVisible();
  });

  test('显示4个统计卡片', async ({ page }) => {
    await expect(page.locator('text=总交易额')).toBeVisible();
    await expect(page.locator('text=总订单数')).toBeVisible();
    await expect(page.locator('text=平均客单价')).toBeVisible();
    await expect(page.locator('text=完成率')).toBeVisible();
  });

  test('统计卡片有数值显示', async ({ page }) => {
    const statValues = page.locator('.stat-value');
    const count = await statValues.count();
    expect(count).toBeGreaterThanOrEqual(4);
  });

  test('显示交易趋势图表', async ({ page }) => {
    await expect(page.locator('text=交易趋势')).toBeVisible();
    const trendChart = page.locator('div[style*="height: 400px"]').first();
    await expect(trendChart).toBeVisible();
  });

  test('显示订单状态分布图表', async ({ page }) => {
    await expect(page.locator('text=订单状态分布')).toBeVisible();
    const pieChart = page.locator('div[style*="height: 400px"]').nth(1);
    await expect(pieChart).toBeVisible();
  });
});
