import { test, expect } from '@playwright/test';

test.describe('用户管理', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/login');
    await page.waitForLoadState('networkidle');
    await page.fill('input[placeholder="请输入手机号"]', '13800000000');
    await page.fill('input[placeholder="请输入密码"]', 'admin123');
    await page.click('button:has-text("登 录")');
    await expect(page).toHaveURL(/.*dashboard/, { timeout: 10000 });
    await page.goto('/user/list');
    await expect(page).toHaveURL(/.*user\/list/);
  });

  test('显示用户列表页面', async ({ page }) => {
    await expect(page.locator('h2:has-text("用户列表")')).toBeVisible();
    await expect(page.locator('.el-table, .el-card')).toBeVisible();
  });

  test('搜索框存在', async ({ page }) => {
    await expect(page.locator('input[placeholder="搜索手机号/昵称"]')).toBeVisible();
  });
});