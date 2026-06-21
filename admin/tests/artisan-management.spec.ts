import { test, expect } from '@playwright/test';

test.describe('手作人管理', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/login');
    await page.waitForLoadState('networkidle');
    await page.fill('input[placeholder="请输入手机号"]', '13800000000');
    await page.fill('input[placeholder="请输入密码"]', 'admin123');
    await page.click('button:has-text("登 录")');
    await expect(page).toHaveURL(/.*dashboard/, { timeout: 10000 });
    await page.goto('/artisan/list');
    await expect(page).toHaveURL(/.*artisan\/list/);
  });

  test('显示手作人管理页面', async ({ page }) => {
    await expect(page.locator('h2:has-text("手作人管理")')).toBeVisible();
    await expect(page.locator('.el-table, .el-card')).toBeVisible();
  });

  test('搜索框存在', async ({ page }) => {
    await expect(page.locator('input[placeholder="搜索手作人名称"]')).toBeVisible();
    await expect(page.locator('button:has-text("搜索")')).toBeVisible();
  });

  test('表格列标题正确', async ({ page }) => {
    await expect(page.locator('th:has-text("ID")')).toBeVisible();
    await expect(page.locator('th:has-text("手作人名称")')).toBeVisible();
    await expect(page.locator('th:has-text("擅长领域")')).toBeVisible();
    await expect(page.locator('th:has-text("状态")')).toBeVisible();
  });

  test('分页组件存在', async ({ page }) => {
    await expect(page.locator('.el-pagination')).toBeVisible();
  });
});

test.describe('手作人详情', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/login');
    await page.waitForLoadState('networkidle');
    await page.fill('input[placeholder="请输入手机号"]', '13800000000');
    await page.fill('input[placeholder="请输入密码"]', 'admin123');
    await page.click('button:has-text("登 录")');
    await expect(page).toHaveURL(/.*dashboard/, { timeout: 10000 });
  });

  test('从列表进入详情页', async ({ page }) => {
    await page.goto('/artisan/list');
    await expect(page).toHaveURL(/.*artisan\/list/);
    const detailBtn = page.locator('button:has-text("详情")').first();
    if (await detailBtn.isVisible()) {
      await detailBtn.click();
      await expect(page).toHaveURL(/.*artisan\/\d+/);
      await expect(page.locator('h2:has-text("手作人详情")')).toBeVisible();
    }
  });
});
