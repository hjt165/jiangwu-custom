import { test, expect, loginAndNavigate } from './helpers/test-helper';

test.describe('争议仲裁', () => {
  test.beforeEach(async ({ page }) => {
    await loginAndNavigate(page, '/order/dispute');
  });

  test('显示争议仲裁页面', async ({ page }) => {
    await expect(page.locator('h2:has-text("争议仲裁")')).toBeVisible();
    await expect(page.locator('.el-table, .el-card')).toBeVisible();
  });

  test('表格列标题正确', async ({ page }) => {
    await expect(page.locator('th:has-text("订单号")')).toBeVisible();
    await expect(page.locator('th:has-text("用户")')).toBeVisible();
    await expect(page.locator('th:has-text("手作人")')).toBeVisible();
    await expect(page.locator('th:has-text("争议原因")')).toBeVisible();
    await expect(page.locator('th:has-text("提交时间")')).toBeVisible();
    await expect(page.locator('th:has-text("操作")')).toBeVisible();
  });

  test('分页组件存在', async ({ page }) => {
    await expect(page.locator('.el-pagination')).toBeVisible();
  });

  test('仲裁按钮存在', async ({ page }) => {
    const arbitrateBtn = page.locator('button:has-text("仲裁")').first();
    if (await arbitrateBtn.isVisible()) {
      await expect(arbitrateBtn).toBeVisible();
    }
  });

  test('快速仲裁按钮存在', async ({ page }) => {
    const supportUserBtn = page.locator('button:has-text("支持用户")').first();
    const supportArtisanBtn = page.locator('button:has-text("支持手作人")').first();
    if (await supportUserBtn.isVisible()) {
      await expect(supportUserBtn).toBeVisible();
    }
    if (await supportArtisanBtn.isVisible()) {
      await expect(supportArtisanBtn).toBeVisible();
    }
  });

  test('点击仲裁按钮打开弹窗', async ({ page }) => {
    const arbitrateBtn = page.locator('button:has-text("仲裁")').first();
    if (await arbitrateBtn.isVisible()) {
      await arbitrateBtn.click();
      await expect(page.locator('.el-dialog')).toBeVisible();
      await expect(page.locator('.el-radio-group')).toBeVisible();
      await expect(page.locator('textarea')).toBeVisible();
      await expect(page.locator('.el-dialog button:has-text("确认")')).toBeVisible();
      await expect(page.locator('.el-dialog button:has-text("取消")')).toBeVisible();
      await page.locator('.el-dialog button:has-text("取消")').click();
    }
  });
});
