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

test('wedding party page loads without errors', async ({ page }) => {
  await login(page);
  await page.goto(`${BASE}/members/wedding-party.cfm`);
  await expect(page.locator('body')).toContainText('Wedding Party');
  await expect(page.locator('body')).not.toContainText('is undefined');
  await expect(page.locator('body')).not.toContainText('An error occurred');
});

test('add a wedding party member', async ({ page }) => {
  await login(page);
  await page.goto(`${BASE}/members/wedding-party.cfm`);
  await page.locator('input[name="name"]').fill('Playwright Bridesmaid');
  await page.locator('input[name="email"]').fill('bridesmaid@example.com');
  await page.locator('select[name="partyRole"]').selectOption('Bridesmaid');
  await page.locator('select[name="partySide"]').selectOption('bride');
  await page.locator('form input[name="action"][value="add_member"]')
    .locator('..').locator('button[type="submit"]').click();
  await page.waitForURL(/wedding-party/);
  await expect(page.locator('body')).toContainText('Playwright Bridesmaid');
});

test('add a wedding party member - name and role required', async ({ page }) => {
  await login(page);
  await page.goto(`${BASE}/members/wedding-party.cfm`);
  await page.locator('form input[name="action"][value="add_member"]')
    .locator('..').locator('button[type="submit"]').click();
  const nameInput = page.locator('input[name="name"]');
  const validationMsg = await nameInput.evaluate(el => el.validationMessage);
  expect(validationMsg).not.toBe('');
});

test('mobile card view is shown on small screen', async ({ page }) => {
  await page.setViewportSize({ width: 390, height: 844 });
  await login(page);
  await page.goto(`${BASE}/members/wedding-party.cfm`);
  await expect(page.locator('div.wp-desktop').first()).toBeHidden();
  await expect(page.locator('div.wp-mobile').first()).toBeVisible();
});

test('delete a wedding party member', async ({ page }) => {
  await login(page);
  await page.goto(`${BASE}/members/wedding-party.cfm`);

  // add throwaway member
  await page.locator('input[name="name"]').fill('DELETE ME Party Member');
  await page.locator('select[name="partyRole"]').selectOption('Groomsman');
  await page.locator('form input[name="action"][value="add_member"]')
    .locator('..').locator('button[type="submit"]').click();
  await page.waitForURL(/wedding-party/);
  await expect(page.locator('body')).toContainText('DELETE ME Party Member');

  page.on('dialog', d => d.accept());
  const removeBtn = page.locator('form input[name="action"][value="remove_member"]')
    .locator('..').locator('button[type="submit"]').last();
  if (await removeBtn.isVisible()) {
    await removeBtn.click();
    await page.waitForURL(/wedding-party/);
    await expect(page.locator('body')).not.toContainText('DELETE ME Party Member');
  }
});
