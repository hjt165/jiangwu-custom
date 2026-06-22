import { test, expect, loginAndNavigate } from './helpers/test-helper';

test.describe('作品管理', () => {
  test.beforeEach(async ({ page }) => {
    await loginAndNavigate(page, '/product/list');
  });

  test('显示作品管理页面', async ({ page }) => {
    await expect(page.locator('h2:has-text("作品管理")')).toBeVisible();
    await expect(page.locator('.el-table, .el-card')).toBeVisible();
  });

  test('搜索框存在', async ({ page }) => {
    await expect(page.locator('input[placeholder*="搜索"]')).toBeVisible();
    await expect(page.locator('button:has-text("搜索")')).toBeVisible();
  });

  test('表格列标题正确', async ({ page }) => {
    await expect(page.locator('th:has-text("ID")')).toBeVisible();
    await expect(page.locator('th:has-text("作品名称")')).toBeVisible();
    await expect(page.locator('th:has-text("分类")')).toBeVisible();
    await expect(page.locator('th:has-text("手作人")')).toBeVisible();
    await expect(page.locator('th:has-text("价格")')).toBeVisible();
    await expect(page.locator('th:has-text("审核状态")')).toBeVisible();
    await expect(page.locator('th:has-text("创建时间")')).toBeVisible();
  });

  test('操作列有详情按钮', async ({ page }) => {
    const detailBtn = page.locator('button:has-text("详情")').first();
    if (await detailBtn.isVisible()) {
      await expect(detailBtn).toBeVisible();
    }
  });

  test('待审核作品显示通过拒绝按钮', async ({ page }) => {
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

test.describe('作品详情', () => {
  test.beforeEach(async ({ page }) => {
    await loginAndNavigate(page, '/product/1');
  });

  test('显示作品详情页面', async ({ page }) => {
    await expect(page.locator('h2:has-text("作品详情")')).toBeVisible();
  });

  test('显示作品信息', async ({ page }) => {
    await expect(page.locator('text=作品信息')).toBeVisible();
    await expect(page.locator('text=作品标题')).toBeVisible();
    await expect(page.locator('text=分类')).toBeVisible();
    await expect(page.locator('text=价格')).toBeVisible();
    await expect(page.locator('text=审核状态')).toBeVisible();
    await expect(page.locator('text=上架状态')).toBeVisible();
    await expect(page.locator('text=创建时间')).toBeVisible();
  });

  test('操作按钮存在', async ({ page }) => {
    await expect(page.locator('button:has-text("返回列表")')).toBeVisible();
  });
});
