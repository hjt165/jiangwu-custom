import { test, expect, loginAndNavigate } from './helpers/test-helper';

test.describe('订单详情', () => {
  test.beforeEach(async ({ page }) => {
    await loginAndNavigate(page, '/order/list');
  });

  test('从列表进入订单详情页', async ({ page }) => {
    const detailBtn = page.locator('button:has-text("详情")').first();
    if (await detailBtn.isVisible()) {
      await detailBtn.click();
      await expect(page).toHaveURL(/.*order\/\d+/);
      await expect(page.locator('h2:has-text("订单详情")')).toBeVisible();
    }
  });

  test('显示订单信息卡片', async ({ page }) => {
    await page.goto('/order/1');
    await page.waitForLoadState('networkidle');
    await expect(page.locator('h2:has-text("订单详情")')).toBeVisible();
    await expect(page.locator('text=订单信息')).toBeVisible();
    await expect(page.locator('.el-descriptions')).toBeVisible();
  });

  test('显示阶段进度区域', async ({ page }) => {
    await page.goto('/order/1');
    await page.waitForLoadState('networkidle');
    await expect(page.locator('.el-card:has-text("阶段进度")')).toBeVisible();
  });

  test('显示操作按钮', async ({ page }) => {
    await page.goto('/order/1');
    await page.waitForLoadState('networkidle');
    await expect(page.locator('button:has-text("返回列表")')).toBeVisible();
    await expect(page.locator('button:has-text("取消订单")')).toBeVisible();
  });

  test('取消订单按钮点击弹出确认框', async ({ page }) => {
    await page.goto('/order/1');
    await page.waitForLoadState('networkidle');
    const cancelBtn = page.locator('button:has-text("取消订单")');
    if (await cancelBtn.isEnabled()) {
      await cancelBtn.click();
      await expect(page.locator('.el-message-box')).toBeVisible();
      await page.locator('.el-message-box button:has-text("返回")').click();
    }
  });
});
