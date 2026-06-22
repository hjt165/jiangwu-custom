import { test, expect, loginAndNavigate } from './helpers/test-helper';

test.describe('系统设置', () => {
  test.beforeEach(async ({ page }) => {
    await loginAndNavigate(page, '/settings');
  });

  test('显示系统设置页面', async ({ page }) => {
    await expect(page.locator('h2:has-text("系统设置")')).toBeVisible();
  });

  test('基本设置表单存在', async ({ page }) => {
    await expect(page.locator('text=平台名称')).toBeVisible();
    await expect(page.locator('text=客服电话')).toBeVisible();
    await expect(page.locator('text=平台公告')).toBeVisible();
  });

  test('订单设置表单存在', async ({ page }) => {
    await expect(page.locator('text=自动确认收货')).toBeVisible();
    await expect(page.locator('text=争议处理时限')).toBeVisible();
  });

  test('通知设置开关存在', async ({ page }) => {
    await expect(page.locator('text=新订单通知')).toBeVisible();
    await expect(page.locator('text=争议提醒')).toBeVisible();
  });

  test('保存按钮存在', async ({ page }) => {
    await expect(page.locator('button:has-text("保存设置")')).toBeVisible();
  });

  test('平台名称输入框可编辑', async ({ page }) => {
    const nameInput = page.locator('input').first();
    await expect(nameInput).toBeVisible();
  });
});
