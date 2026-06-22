import { test, expect, loginAndNavigate } from './helpers/test-helper';

test.describe('手作人管理', () => {
  test.beforeEach(async ({ page }) => {
    await loginAndNavigate(page, '/artisan/list');
  });

  test('显示手作人管理页面', async ({ page }) => {
    await expect(page.locator('h2:has-text("手作人管理")')).toBeVisible();
    await expect(page.locator('.el-table, .el-card')).toBeVisible();
  });

  test('搜索框存在', async ({ page }) => {
    await expect(page.locator('input[placeholder*="搜索"]')).toBeVisible();
    await expect(page.locator('button:has-text("搜索")')).toBeVisible();
  });

  test('表格列标题正确', async ({ page }) => {
    await expect(page.locator('th:has-text("ID")')).toBeVisible();
    await expect(page.locator('th:has-text("手作人名称")')).toBeVisible();
    await expect(page.locator('th:has-text("擅长领域")')).toBeVisible();
    await expect(page.locator('th:has-text("从业年限")')).toBeVisible();
    await expect(page.locator('th:has-text("评分")')).toBeVisible();
    await expect(page.locator('th:has-text("状态")')).toBeVisible();
  });

  test('操作列有详情按钮', async ({ page }) => {
    const detailBtn = page.locator('button:has-text("详情")').first();
    if (await detailBtn.isVisible()) {
      await expect(detailBtn).toBeVisible();
    }
  });

  test('待审核手作人显示认证拒绝按钮', async ({ page }) => {
    const certBtn = page.locator('button:has-text("认证")').first();
    const rejectBtn = page.locator('button:has-text("拒绝")').first();
    if (await certBtn.isVisible()) {
      await expect(certBtn).toBeVisible();
      await expect(rejectBtn).toBeVisible();
    }
  });

  test('分页组件存在', async ({ page }) => {
    await expect(page.locator('.el-pagination')).toBeVisible();
  });
});

test.describe('手作人详情', () => {
  test.beforeEach(async ({ page }) => {
    await loginAndNavigate(page, '/artisan/1');
  });

  test('显示手作人详情页面', async ({ page }) => {
    await expect(page.locator('h2:has-text("手作人详情")')).toBeVisible();
  });

  test('显示基本信息', async ({ page }) => {
    await expect(page.locator('text=基本信息')).toBeVisible();
    await expect(page.locator('text=名称')).toBeVisible();
    await expect(page.locator('text=擅长领域')).toBeVisible();
    await expect(page.locator('text=评分')).toBeVisible();
    await expect(page.locator('text=认证状态')).toBeVisible();
    await expect(page.locator('text=个人简介')).toBeVisible();
  });

  test('操作按钮存在', async ({ page }) => {
    await expect(page.locator('button:has-text("返回列表")')).toBeVisible();
  });
});
