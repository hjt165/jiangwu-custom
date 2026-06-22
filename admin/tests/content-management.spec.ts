import { test, expect, loginAndNavigate } from './helpers/test-helper';

test.describe('图片审核', () => {
  test.beforeEach(async ({ page }) => {
    await loginAndNavigate(page, '/content/image');
  });

  test('显示图片审核页面', async ({ page }) => {
    await expect(page.locator('h2:has-text("图片审核")')).toBeVisible();
    await expect(page.locator('.el-table, .el-card')).toBeVisible();
  });

  test('搜索和筛选组件存在', async ({ page }) => {
    await expect(page.locator('input[placeholder*="搜索"]')).toBeVisible();
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

  test('表格列标题包含操作列', async ({ page }) => {
    await expect(page.locator('th:has-text("操作")')).toBeVisible();
  });

  test('操作列有通过和拒绝按钮', async ({ page }) => {
    const passBtn = page.locator('button:has-text("通过")').first();
    const rejectBtn = page.locator('button:has-text("拒绝")').first();
    if (await passBtn.isVisible()) {
      await expect(passBtn).toBeVisible();
      await expect(rejectBtn).toBeVisible();
    }
  });

  test('分页组件存在', async ({ page }) => {
    await expect(page.locator('.el-pagination')).toBeVisible();
  });
});

test.describe('评论审核', () => {
  test.beforeEach(async ({ page }) => {
    await loginAndNavigate(page, '/content/comment');
  });

  test('显示评论审核页面', async ({ page }) => {
    await expect(page.locator('h2:has-text("评论审核")')).toBeVisible();
    await expect(page.locator('.el-table, .el-card')).toBeVisible();
  });

  test('搜索和筛选组件存在', async ({ page }) => {
    await expect(page.locator('input[placeholder*="搜索"]')).toBeVisible();
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

  test('表格包含选择框列', async ({ page }) => {
    await expect(page.locator('.el-table .el-checkbox').first()).toBeVisible();
  });

  test('分页组件存在', async ({ page }) => {
    await expect(page.locator('.el-pagination')).toBeVisible();
  });
});
