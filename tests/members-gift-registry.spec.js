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

test('gift registry page loads without errors', async ({ page }) => {
  await login(page);
  await page.goto(`${BASE}/members/gift-registry.cfm`);
  await expect(page.locator('body')).toContainText('Registry');
  await expect(page.locator('body')).not.toContainText('is undefined');
  await expect(page.locator('body')).not.toContainText('An error occurred');
});

test('save registry type and link', async ({ page }) => {
  await login(page);
  await page.goto(`${BASE}/members/gift-registry.cfm`);
  await page.locator('select[name="registryType"]').selectOption({ index: 1 });
  await page.locator('input[name="registryLink"]').fill('https://www.amazon.com/registry/wishlist/test');
  await page.locator('textarea[name="registryDetails"]').fill('We are registered at Amazon - any contribution is appreciated!');
  await page.locator('button[type="submit"]').click();
  await page.waitForURL(/gift-registry.*saved=1/);
  await expect(page.locator('body')).not.toContainText('An error occurred');
});

test('registry link persists after save', async ({ page }) => {
  await login(page);
  await page.goto(`${BASE}/members/gift-registry.cfm`);
  await page.locator('input[name="registryLink"]').fill('https://www.target.com/registry/test123');
  await page.locator('button[type="submit"]').click();
  await page.waitForURL(/gift-registry.*saved=1/);

  await page.goto(`${BASE}/members/gift-registry.cfm`);
  const link = await page.locator('input[name="registryLink"]').inputValue();
  expect(link).toBe('https://www.target.com/registry/test123');
});

test('registry link must be a valid URL', async ({ page }) => {
  await login(page);
  await page.goto(`${BASE}/members/gift-registry.cfm`);
  await page.locator('input[name="registryLink"]').fill('not a url');
  await page.locator('button[type="submit"]').click();
  const linkInput = page.locator('input[name="registryLink"]');
  const validationMsg = await linkInput.evaluate(el => el.validationMessage);
  expect(validationMsg).not.toBe('');
});
