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

test('thank you cards page loads without errors', async ({ page }) => {
  await login(page);
  await page.goto(`${BASE}/members/thank-you-cards.cfm`);
  await expect(page.locator('body')).toContainText('Thank You');
  await expect(page.locator('body')).not.toContainText('is undefined');
  await expect(page.locator('body')).not.toContainText('An error occurred');
});

test('add a thank you card recipient', async ({ page }) => {
  await login(page);
  await page.goto(`${BASE}/members/thank-you-cards.cfm`);
  await page.locator('input[name="recipientName"]').fill('Aunt Playwright');
  await page.locator('form input[name="action"][value="add_card"]')
    .locator('..').locator('button[type="submit"]').click();
  await page.waitForURL(/thank-you-cards/);
  await expect(page.locator('body')).toContainText('Aunt Playwright');
});

test('add card - recipient name required', async ({ page }) => {
  await login(page);
  await page.goto(`${BASE}/members/thank-you-cards.cfm`);
  await page.locator('form input[name="action"][value="add_card"]')
    .locator('..').locator('button[type="submit"]').click();
  const nameInput = page.locator('input[name="recipientName"]');
  const validationMsg = await nameInput.evaluate(el => el.validationMessage);
  expect(validationMsg).not.toBe('');
});

test('preview thank you card email', async ({ page }) => {
  await login(page);
  await page.goto(`${BASE}/members/thank-you-cards.cfm`);
  const previewLink = page.locator('a[href*="preview"]').first();
  if (await previewLink.isVisible()) {
    await previewLink.click();
    await expect(page.locator('body')).not.toContainText('An error occurred');
    await expect(page.locator('body')).not.toContainText('is undefined');
  }
});
