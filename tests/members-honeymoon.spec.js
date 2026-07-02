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

test('honeymoon page loads without errors', async ({ page }) => {
  await login(page);
  await page.goto(`${BASE}/members/honeymoon.cfm`);
  await expect(page.locator('body')).toContainText('Honeymoon');
  await expect(page.locator('body')).not.toContainText('is undefined');
  await expect(page.locator('body')).not.toContainText('An error occurred');
});

test('save honeymoon details', async ({ page }) => {
  await login(page);
  await page.goto(`${BASE}/members/honeymoon.cfm`);
  await page.locator('input[name="destination"]').fill('Maldives');
  await page.locator('input[name="startDate"]').fill('2026-09-01');
  await page.locator('input[name="endDate"]').fill('2026-09-10');
  await page.locator('input[name="estimatedBudget"]').fill('8000');
  await page.locator('textarea[name="notes"]').fill('Book overwater bungalow at Soneva Fushi');
  await page.locator('button[type="submit"]').click();
  await page.waitForURL(/honeymoon.*saved=1/);
  await expect(page.locator('body')).toContainText('Maldives');
});

test('honeymoon details persist after save', async ({ page }) => {
  await login(page);
  await page.goto(`${BASE}/members/honeymoon.cfm`);
  await page.locator('input[name="destination"]').fill('Jamaica');
  await page.locator('input[name="estimatedBudget"]').fill('5000');
  await page.locator('button[type="submit"]').click();
  await page.waitForURL(/honeymoon.*saved=1/);

  // reload and check value persisted
  await page.goto(`${BASE}/members/honeymoon.cfm`);
  const destination = await page.locator('input[name="destination"]').inputValue();
  expect(destination).toBe('Jamaica');
});

test('save honeymoon - no required fields, saves empty gracefully', async ({ page }) => {
  await login(page);
  await page.goto(`${BASE}/members/honeymoon.cfm`);
  await page.locator('button[type="submit"]').click();
  // should redirect to saved=1 without error
  await expect(page).toHaveURL(/honeymoon/);
  await expect(page.locator('body')).not.toContainText('An error occurred');
});
