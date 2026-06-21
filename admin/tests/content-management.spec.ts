import { test, expect } from '@playwright/test';

test.describe('图片审核', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/login');
    await page.waitForLoadState('networkidle');
    await page.fill('input[placeholder="手机号"]', '13800000000');
    await page.fill('input[placeholder="密码"]', 'admin123');
    await page.click('button:has-text("登 录")');
    await expect(page).toHaveURL(/.*dashboard/, { timeout: 10000 });
    await page.goto('/content/image');
    await expect(page).toHaveURL(/.*content\/image/);
  });

  test('显示图片审核页面', async ({ page }) => {
    await expect(page.locator('h2:has-text("图片审核")')).toBeVisible();
    await expect(page.locator('.el-table, .el-card')).toBeVisible();
  });

  test('搜索和筛选组件存在', async ({ page }) => {
    await expect(page.locator('input[placeholder="搜索图片描述"]')).toBeVisible();
    await expect(page.locator('.el-select').first()).toBeVisible();
    await expect(page.locator('button:has-text("搜索")')).toBeVisible();
    await expect(page.locator('button:has-text("重置")')).toBeVisible();
  });

  test('批量操作按钮存在', async ({ page }) => {
    await expect(page.locator('button:has-text("批量通过")')).toBeVisible();
    await expect(page.locator('button:has-text("批量拒绝")')).toBeVisible();
  });

  test('表格包含选择框列', async ({ page }) => {
    await expect(page.locator('.el-table .el-checkbox').first()).toBeVisible();
  });
});

test.describe('评论审核', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/login');
    await page.waitForLoadState('networkidle');
    await page.fill('input[placeholder="手机号"]', '13800000000');
    await page.fill('input[placeholder="密码"]', 'admin123');
    await page.click('button:has-text("登 录")');
    await expect(page).toHaveURL(/.*dashboard/, { timeout: 10000 });
    await page.goto('/content/comment');
    await expect(page).toHaveURL(/.*content\/comment/);
  });

  test('显示评论审核页面', async ({ page }) => {
    await expect(page.locator('h2:has-text("评论审核")')).toBeVisible();
    await expect(page.locator('.el-table, .el-card')).toBeVisible();
  });

  test('搜索和筛选组件存在', async ({ page }) => {
    await expect(page.locator('input[placeholder="搜索评论内容"]')).toBeVisible();
    await expect(page.locator('.el-select').first()).toBeVisible();
    await expect(page.locator('button:has-text("搜索")')).toBeVisible();
    await expect(page.locator('button:has-text("重置")')).toBeVisible();
  });

  test('批量操作按钮存在', async ({ page }) => {
    await expect(page.locator('button:has-text("批量通过")')).toBeVisible();
    await expect(page.locator('button:has-text("批量拒绝")')).toBeVisible();
  });

  test('评分筛选下拉框存在', async ({ page }) => {
    const ratingSelect = page.locator('.el-select').nth(1);
    await expect(ratingSelect).toBeVisible();
  });
});
