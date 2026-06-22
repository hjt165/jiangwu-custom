import { test, expect, loginAndNavigate } from './helpers/test-helper';

test.describe('用户详情', () => {
  test.beforeEach(async ({ page }) => {
    await loginAndNavigate(page, '/user/list');
  });

  test('从列表进入用户详情页', async ({ page }) => {
    const detailBtn = page.locator('button:has-text("详情")').first();
    if (await detailBtn.isVisible()) {
      await detailBtn.click();
      await expect(page).toHaveURL(/.*user\/\d+/);
      await expect(page.locator('h2:has-text("用户详情")')).toBeVisible();
    }
  });

  test('显示基本信息卡片', async ({ page }) => {
    await page.goto('/user/1');
    await page.waitForLoadState('networkidle');
    await expect(page.locator('h2:has-text("用户详情")')).toBeVisible();
    await expect(page.locator('.el-card:has-text("基本信息")')).toBeVisible();
    await expect(page.locator('.el-descriptions__label:has-text("手机号")')).toBeVisible();
    await expect(page.locator('.el-descriptions__label:has-text("昵称")')).toBeVisible();
    await expect(page.locator('.el-descriptions__label:has-text("角色")')).toBeVisible();
    await expect(page.locator('.el-descriptions__label:has-text("信用分")')).toBeVisible();
    await expect(page.locator('.el-descriptions__label:has-text("状态")')).toBeVisible();
  });

  test('显示操作区域', async ({ page }) => {
    await page.goto('/user/1');
    await page.waitForLoadState('networkidle');
    await expect(page.locator('text=操作')).toBeVisible();
    await expect(page.locator('text=信用分调整')).toBeVisible();
    await expect(page.locator('text=账号状态')).toBeVisible();
  });

  test('信用分调整输入框和按钮存在', async ({ page }) => {
    await page.goto('/user/1');
    await page.waitForLoadState('networkidle');
    await expect(page.locator('.el-input-number')).toBeVisible();
    await expect(page.locator('button:has-text("调整")')).toBeVisible();
  });

  test('账号状态开关存在', async ({ page }) => {
    await page.goto('/user/1');
    await page.waitForLoadState('networkidle');
    await expect(page.locator('.el-switch')).toBeVisible();
  });

  test('返回按钮存在', async ({ page }) => {
    await page.goto('/user/1');
    await page.waitForLoadState('networkidle');
    await expect(page.locator('button:has-text("返回")')).toBeVisible();
  });
});
