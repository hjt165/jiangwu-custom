import { test as base, expect, type Page } from '@playwright/test';

const ADMIN_PHONE = '13800000000';
const ADMIN_PASSWORD = 'admin123';

/**
 * 登录到管理后台
 */
export async function loginAsAdmin(page: Page) {
  await page.goto('/login');
  await page.waitForLoadState('networkidle');
  await page.fill('input[placeholder="请输入手机号"]', ADMIN_PHONE);
  await page.fill('input[placeholder="请输入密码"]', ADMIN_PASSWORD);
  await page.click('button:has-text("登 录")');
  await expect(page).toHaveURL(/.*dashboard/, { timeout: 15000 });
}

/**
 * 登录并导航到指定页面
 */
export async function loginAndNavigate(page: Page, path: string) {
  await loginAsAdmin(page);
  await page.goto(path);
  await page.waitForLoadState('networkidle');
}

/**
 * 扩展的 test fixture，自带 adminLogin
 */
export const test = base.extend<{
  adminLogin: Page;
}>({
  adminLogin: async ({ page }, use) => {
    await loginAsAdmin(page);
    await use(page);
  },
});

export { expect };
