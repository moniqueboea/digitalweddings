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

test('members vendors page loads without errors', async ({ page }) => {
  await login(page);
  await page.goto(`${BASE}/members/vendors.cfm`);
  await expect(page.locator('body')).toContainText('Vendor');
  await expect(page.locator('body')).not.toContainText('is undefined');
  await expect(page.locator('body')).not.toContainText('MissingInclude');
  await expect(page.locator('body')).not.toContainText('An error occurred');
});

test('vendor search by keyword', async ({ page }) => {
  await login(page);
  await page.goto(`${BASE}/members/vendors.cfm`);
  await page.getByRole('textbox', { name: 'Search' }).fill('photo');
  await page.getByRole('button', { name: 'Search' }).click();
  await expect(page).toHaveURL(/q=photo/);
  await expect(page.locator('body')).not.toContainText('An error occurred');
});

test('vendor search by category', async ({ page }) => {
  await login(page);
  await page.goto(`${BASE}/members/vendors.cfm`);
  await page.locator('select[name="category"]').selectOption('Photography');
  await page.getByRole('button', { name: 'Search' }).click();
  await expect(page).toHaveURL(/category=Photography/);
});

test('contact modal opens and closes', async ({ page }) => {
  await login(page);
  await page.goto(`${BASE}/members/vendors.cfm`);
  const contactBtn = page.locator('button', { hasText: 'Contact' }).first();
  if (await contactBtn.isVisible()) {
    await contactBtn.click();
    await expect(page.locator('#contactModal')).toBeVisible();
    await expect(page.locator('#contactModalTitle')).not.toBeEmpty();
    // close with X button
    await page.locator('#contactModal button[onclick="closeContact()"]').click();
    await expect(page.locator('#contactModal')).toBeHidden();
  }
});

test('contact modal closes with Escape key', async ({ page }) => {
  await login(page);
  await page.goto(`${BASE}/members/vendors.cfm`);
  const contactBtn = page.locator('button', { hasText: 'Contact' }).first();
  if (await contactBtn.isVisible()) {
    await contactBtn.click();
    await expect(page.locator('#contactModal')).toBeVisible();
    await page.keyboard.press('Escape');
    await expect(page.locator('#contactModal')).toBeHidden();
  }
});

test('contact form submits successfully', async ({ page }) => {
  await login(page);
  await page.goto(`${BASE}/members/vendors.cfm`);
  const contactBtn = page.locator('button', { hasText: 'Contact' }).first();
  if (!await contactBtn.isVisible()) { test.skip(); return; }

  await contactBtn.click();
  await page.locator('input[name="senderName"]').fill('Test Couple');
  await page.locator('input[name="senderEmail"]').fill('testcouple@example.com');
  await page.locator('textarea[name="message"]').fill('Hi, we are interested in your services for our September 2026 wedding.');
  await page.locator('#contactModal button[type="submit"]').click();
  await expect(page).toHaveURL(/contacted=1/);
  await expect(page.locator('body')).toContainText('message was sent');
});

test('clear search button resets filters', async ({ page }) => {
  await login(page);
  await page.goto(`${BASE}/members/vendors.cfm?q=photo`);
  const clearBtn = page.locator('a', { hasText: 'Clear' });
  if (await clearBtn.isVisible()) {
    await clearBtn.click();
    await expect(page).toHaveURL(/vendors\.cfm$/);
  }
});
