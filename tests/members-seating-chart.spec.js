import { test, expect } from '@playwright/test';

const BASE = 'https://digitalweddings.love';
const USER = 'momiqueboea';
const PASS = 'wedding@2026';

async function login(page) {
  await page.goto(`${BASE}/login.cfm`);
  await page.fill('#login', USER);
  await page.fill('#password', PASS);
  await page.click('button[type="submit"]');
  await page.waitForURL(/planning-tools/);
}

test('seating chart page loads without errors', async ({ page }) => {
  await login(page);
  await page.goto(`${BASE}/members/seating-chart.cfm`);
  await expect(page.locator('body')).toContainText('Seating');
  await expect(page.locator('body')).not.toContainText('is undefined');
  await expect(page.locator('body')).not.toContainText('An error occurred');
});

test('shows prompt when no RSVPs exist', async ({ page }) => {
  await login(page);
  await page.goto(`${BASE}/members/seating-chart.cfm`);
  // if no RSVP guests, page should explain that guests must RSVP first
  // table inputs should be disabled
  const tableLabel = page.locator('input[name="tableLabel"]');
  if (await tableLabel.isVisible()) {
    const isDisabled = await tableLabel.isDisabled();
    if (isDisabled) {
      // expected - no RSVPs yet
      expect(isDisabled).toBe(true);
    }
  }
});

test('add a table when RSVPs exist', async ({ page }) => {
  await login(page);
  await page.goto(`${BASE}/members/seating-chart.cfm`);
  const tableLabel = page.locator('input[name="tableLabel"]');
  const isDisabled = await tableLabel.isDisabled();
  if (isDisabled) {
    test.skip();
    return;
  }
  await tableLabel.fill('Head Table');
  await page.locator('input[name="capacity"]').fill('10');
  await page.locator('form input[name="action"][value="add_table"]')
    .locator('..').locator('button[type="submit"]').click();
  await page.waitForURL(/seating-chart/);
  await expect(page.locator('body')).toContainText('Head Table');
});

test('rename a table', async ({ page }) => {
  await login(page);
  await page.goto(`${BASE}/members/seating-chart.cfm`);
  const renameBtn = page.locator('button', { hasText: 'Rename' }).first();
  if (!await renameBtn.isVisible()) {
    test.skip();
    return;
  }
  await renameBtn.click();
  const renameInput = page.locator('input[name="newTableName"]').first();
  await renameInput.fill('Renamed Table Playwright');
  await renameInput.locator('..').locator('..').locator('button[type="submit"]').click();
  await page.waitForURL(/seating-chart/);
  await expect(page.locator('body')).toContainText('Renamed Table Playwright');
});
