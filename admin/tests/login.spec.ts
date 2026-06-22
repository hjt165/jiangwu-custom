import { test, expect } from './helpers/test-helper';

test.describe('登录页面', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/login');
    await page.waitForLoadState('networkidle');
  });

  test('页面标题正确', async ({ page }) => {
    await expect(page).toHaveTitle(/匠物定制/);
  });

  test('管理员登录成功', async ({ page }) => {
    await page.fill('input[placeholder="请输入手机号"]', '13800000000');
    await page.fill('input[placeholder="请输入密码"]', 'admin123');
    await page.click('button:has-text("登 录")');
    await page.waitForURL(/.*dashboard/, { timeout: 15000 }).catch(() => {});
    const token = await page.evaluate(() => localStorage.getItem('jiangwu_admin_token'));
    expect(token).toBeTruthy();
  });

  test('错误密码提示', async ({ page }) => {
    await page.fill('input[placeholder="请输入手机号"]', '13800000000');
    await page.fill('input[placeholder="请输入密码"]', 'wrong123');
    await page.click('button:has-text("登 录")');
    await expect(page.locator('.el-message--error').first()).toBeVisible({ timeout: 10000 });
  });
});
