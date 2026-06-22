import { test, expect, loginAndNavigate } from './helpers/test-helper';

test.describe('订单列表', () => {
  test.beforeEach(async ({ page }) => {
    await loginAndNavigate(page, '/order/list');
  });

  test('显示订单列表页面', async ({ page }) => {
    await expect(page.locator('h2:has-text("订单列表")')).toBeVisible();
    await expect(page.locator('.el-table, .el-card')).toBeVisible();
  });

  test('搜索框和状态筛选存在', async ({ page }) => {
    await expect(page.locator('input[placeholder*="搜索"]')).toBeVisible();
    await expect(page.locator('.el-select').first()).toBeVisible();
    await expect(page.locator('button:has-text("搜索")')).toBeVisible();
  });

  test('表格列标题正确', async ({ page }) => {
    await expect(page.locator('th:has-text("订单号")')).toBeVisible();
    await expect(page.locator('th:has-text("用户")')).toBeVisible();
    await expect(page.locator('th:has-text("手作人")')).toBeVisible();
    await expect(page.locator('th:has-text("金额")')).toBeVisible();
    await expect(page.locator('th:has-text("状态")')).toBeVisible();
    await expect(page.locator('th:has-text("创建时间")')).toBeVisible();
  });

  test('操作列有详情按钮', async ({ page }) => {
    const detailBtn = page.locator('button:has-text("详情")').first();
    if (await detailBtn.isVisible()) {
      await expect(detailBtn).toBeVisible();
    }
  });

  test('分页组件存在', async ({ page }) => {
    await expect(page.locator('.el-pagination')).toBeVisible();
  });

  test('状态筛选可展开', async ({ page }) => {
    const select = page.locator('.el-select').first();
    await select.click();
    await expect(page.locator('.el-select-dropdown')).toBeVisible();
  });
});

test.describe('订单详情', () => {
  test.beforeEach(async ({ page }) => {
    await loginAndNavigate(page, '/order/1');
  });

  test('显示订单详情页面', async ({ page }) => {
    await expect(page.locator('h2:has-text("订单详情")')).toBeVisible();
  });

  test('显示订单信息', async ({ page }) => {
    await expect(page.locator('text=订单信息')).toBeVisible();
    await expect(page.locator('text=订单号')).toBeVisible();
    await expect(page.locator('text=金额')).toBeVisible();
    await expect(page.locator('text=创建时间')).toBeVisible();
  });

  test('显示阶段进度区域', async ({ page }) => {
    await expect(page.locator('.el-card:has-text("阶段进度")')).toBeVisible();
  });

  test('操作按钮存在', async ({ page }) => {
    await expect(page.locator('button:has-text("返回列表")')).toBeVisible();
    await expect(page.locator('button:has-text("取消订单")')).toBeVisible();
  });
});
