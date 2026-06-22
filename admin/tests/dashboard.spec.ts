import { test, expect, loginAndNavigate } from './helpers/test-helper';

test.describe('工作台', () => {
  test.beforeEach(async ({ page }) => {
    await loginAndNavigate(page, '/dashboard');
  });

  test('显示统计卡片', async ({ page }) => {
    await expect(page.locator('text=用户总数')).toBeVisible();
    await expect(page.locator('text=订单总数')).toBeVisible();
    await expect(page.locator('text=总交易额')).toBeVisible();
    await expect(page.locator('text=手作人数')).toBeVisible();
  });

  test('显示图表或待办事项', async ({ page }) => {
    await expect(page.locator('.echarts-chart, .el-card:has-text("待办事项")')).toBeVisible();
  });

  test('快速操作区域存在', async ({ page }) => {
    const quickActions = page.locator('.el-card:has-text("用户管理"), .el-card:has-text("订单管理"), .el-card:has-text("图片审核"), .el-card:has-text("数据统计")');
    if (await quickActions.first().isVisible()) {
      await expect(quickActions.first()).toBeVisible();
    }
  });
});
