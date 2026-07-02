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

test('save the date page loads without errors', async ({ page }) => {
  await login(page);
  await page.goto(`${BASE}/members/save-the-date.cfm`);
  await expect(page.locator('body')).toContainText('Save the Date');
  await expect(page.locator('body')).not.toContainText('is undefined');
  await expect(page.locator('body')).not.toContainText('An error occurred');
});

test('add a save the date recipient', async ({ page }) => {
  await login(page);
  await page.goto(`${BASE}/members/save-the-date.cfm`);
  await page.locator('input[name="recipientName"]').fill('Playwright Recipient');
  await page.locator('input[name="recipientEmail"]').fill('std-test@example.com');
  await page.locator('form input[name="action"][value="add_recipient"]')
    .locator('..').locator('button[type="submit"]').click();
  await page.waitForURL(/save-the-date/);
  await expect(page.locator('body')).toContainText('Playwright Recipient');
});

test('add recipient - blocks duplicate email', async ({ page }) => {
  await login(page);
  await page.goto(`${BASE}/members/save-the-date.cfm`);
  // try adding same email twice
  for (let i = 0; i < 2; i++) {
    await page.locator('input[name="recipientName"]').fill('Duplicate Test');
    await page.locator('input[name="recipientEmail"]').fill('duplicate-std@example.com');
    await page.locator('form input[name="action"][value="add_recipient"]')
      .locator('..').locator('button[type="submit"]').click();
    await page.waitForURL(/save-the-date/);
  }
  await expect(page).toHaveURL(/error=duplicate/);
});

test('add recipient - invalid email shows error', async ({ page }) => {
  await login(page);
  await page.goto(`${BASE}/members/save-the-date.cfm`);
  await page.locator('input[name="recipientName"]').fill('Bad Email');
  await page.locator('input[name="recipientEmail"]').fill('not-an-email');
  await page.locator('form input[name="action"][value="add_recipient"]')
    .locator('..').locator('button[type="submit"]').click();
  const emailInput = page.locator('input[name="recipientEmail"]');
  const validationMsg = await emailInput.evaluate(el => el.validationMessage);
  expect(validationMsg).not.toBe('');
});

test('mobile card view shown on small screen', async ({ page }) => {
  await page.setViewportSize({ width: 390, height: 844 });
  await login(page);
  await page.goto(`${BASE}/members/save-the-date.cfm`);
  await expect(page.locator('div.std-desktop').first()).toBeHidden();
  await expect(page.locator('div.std-mobile').first()).toBeVisible();
});
