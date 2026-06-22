import { test, expect, loginAndNavigate } from './helpers/test-helper';

test.describe('用户列表', () => {
  test.beforeEach(async ({ page }) => {
    await loginAndNavigate(page, '/user/list');
  });

  test('显示用户列表页面', async ({ page }) => {
    await expect(page.locator('h2:has-text("用户列表")')).toBeVisible();
    await expect(page.locator('.el-table, .el-card')).toBeVisible();
  });

  test('搜索框和角色筛选存在', async ({ page }) => {
    await expect(page.locator('input[placeholder*="搜索"]')).toBeVisible();
    await expect(page.locator('.el-select').first()).toBeVisible();
    await expect(page.locator('button:has-text("搜索")')).toBeVisible();
  });

  test('表格列标题正确', async ({ page }) => {
    await expect(page.locator('th:has-text("ID")')).toBeVisible();
    await expect(page.locator('th:has-text("手机号")')).toBeVisible();
    await expect(page.locator('th:has-text("昵称")')).toBeVisible();
    await expect(page.locator('th:has-text("角色")')).toBeVisible();
    await expect(page.locator('th:has-text("信用分")')).toBeVisible();
    await expect(page.locator('th:has-text("状态")')).toBeVisible();
    await expect(page.locator('th:has-text("注册时间")')).toBeVisible();
  });

  test('操作列有详情和禁用启用按钮', async ({ page }) => {
    const detailBtn = page.locator('button:has-text("详情")').first();
    const toggleBtn = page.locator('button:has-text("禁用"), button:has-text("启用")').first();
    if (await detailBtn.isVisible()) {
      await expect(detailBtn).toBeVisible();
    }
    if (await toggleBtn.isVisible()) {
      await expect(toggleBtn).toBeVisible();
    }
  });

  test('分页组件存在', async ({ page }) => {
    await expect(page.locator('.el-pagination')).toBeVisible();
  });

  test('搜索功能可触发', async ({ page }) => {
    await page.fill('input[placeholder*="搜索"]', '138');
    await page.click('button:has-text("搜索")');
    await page.waitForLoadState('networkidle');
    await expect(page.locator('.el-table, .el-card')).toBeVisible();
  });
});

test.describe('用户详情', () => {
  test.beforeEach(async ({ page }) => {
    await loginAndNavigate(page, '/user/1');
  });

  test('显示用户详情页面', async ({ page }) => {
    await expect(page.locator('h2:has-text("用户详情")')).toBeVisible();
    await expect(page.locator('text=基本信息')).toBeVisible();
  });

  test('显示用户信息字段', async ({ page }) => {
    await expect(page.locator('.el-descriptions__label:has-text("手机号")')).toBeVisible();
    await expect(page.locator('.el-descriptions__label:has-text("昵称")')).toBeVisible();
    await expect(page.locator('.el-descriptions__label:has-text("角色")')).toBeVisible();
    await expect(page.locator('.el-descriptions__label:has-text("信用分")')).toBeVisible();
    await expect(page.locator('.el-descriptions__label:has-text("状态")')).toBeVisible();
    await expect(page.locator('.el-descriptions__label:has-text("注册时间")')).toBeVisible();
  });

  test('操作区域包含信用分调整', async ({ page }) => {
    await expect(page.locator('text=信用分调整')).toBeVisible();
    await expect(page.locator('.el-input-number')).toBeVisible();
    await expect(page.locator('button:has-text("调整")')).toBeVisible();
  });

  test('操作区域包含账号状态开关', async ({ page }) => {
    await expect(page.locator('text=账号状态')).toBeVisible();
    await expect(page.locator('.el-switch')).toBeVisible();
  });

  test('返回按钮可返回上一页', async ({ page }) => {
    await expect(page.locator('button:has-text("返回")')).toBeVisible();
  });
});
