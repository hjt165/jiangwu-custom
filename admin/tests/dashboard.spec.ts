import { test, expect } from '@playwright/test';

test.describe('工作台', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/login');
    await page.waitForLoadState('networkidle');
    await page.fill('input[placeholder="请输入手机号"]', '13800000000');
    await page.fill('input[placeholder="请输入密码"]', 'admin123');
    await page.click('button:has-text("登 录")');
    await expect(page).toHaveURL(/.*dashboard/, { timeout: 10000 });
  });

  test('显示统计卡片', async ({ page }) => {
    await expect(page.locator('text=用户总数')).toBeVisible();
    await expect(page.locator('text=订单总数')).toBeVisible();
    await expect(page.locator('text=总交易额')).toBeVisible();
    await expect(page.locator('text=手作人数')).toBeVisible();
  });

  test('显示图表', async ({ page }) => {
    await expect(page.locator('.echarts-chart, .el-card:has-text("待办事项")')).toBeVisible();
  });
});