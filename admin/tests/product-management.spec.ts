import { test, expect } from '@playwright/test';

test.describe('作品管理', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/login');
    await page.waitForLoadState('networkidle');
    await page.fill('input[placeholder="请输入手机号"]', '13800000000');
    await page.fill('input[placeholder="请输入密码"]', 'admin123');
    await page.click('button:has-text("登 录")');
    await expect(page).toHaveURL(/.*dashboard/, { timeout: 10000 });
    await page.goto('/product/list');
    await expect(page).toHaveURL(/.*product\/list/);
  });

  test('显示作品管理页面', async ({ page }) => {
    await expect(page.locator('h2:has-text("作品管理")')).toBeVisible();
    await expect(page.locator('.el-table, .el-card')).toBeVisible();
  });

  test('搜索框存在', async ({ page }) => {
    await expect(page.locator('input[placeholder="搜索作品名称"]')).toBeVisible();
    await expect(page.locator('button:has-text("搜索")')).toBeVisible();
  });

  test('表格列标题正确', async ({ page }) => {
    await expect(page.locator('th:has-text("ID")')).toBeVisible();
    await expect(page.locator('th:has-text("作品名称")')).toBeVisible();
    await expect(page.locator('th:has-text("分类")')).toBeVisible();
    await expect(page.locator('th:has-text("价格")')).toBeVisible();
    await expect(page.locator('th:has-text("审核状态")')).toBeVisible();
  });

  test('分页组件存在', async ({ page }) => {
    await expect(page.locator('.el-pagination')).toBeVisible();
  });
});

test.describe('作品详情', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/login');
    await page.waitForLoadState('networkidle');
    await page.fill('input[placeholder="请输入手机号"]', '13800000000');
    await page.fill('input[placeholder="请输入密码"]', 'admin123');
    await page.click('button:has-text("登 录")');
    await expect(page).toHaveURL(/.*dashboard/, { timeout: 10000 });
  });

  test('从列表进入详情页', async ({ page }) => {
    await page.goto('/product/list');
    await expect(page).toHaveURL(/.*product\/list/);
    const detailBtn = page.locator('button:has-text("详情")').first();
    if (await detailBtn.isVisible()) {
      await detailBtn.click();
      await expect(page).toHaveURL(/.*product\/\d+/);
      await expect(page.locator('h2:has-text("作品详情")')).toBeVisible();
    }
  });
});
