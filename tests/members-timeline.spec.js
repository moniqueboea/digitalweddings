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

test('timeline page loads without errors', async ({ page }) => {
  await login(page);
  await page.goto(`${BASE}/members/timeline.cfm`);
  await expect(page.locator('body')).toContainText('Timeline');
  await expect(page.locator('body')).not.toContainText('is undefined');
  await expect(page.locator('body')).not.toContainText('An error occurred');
});

test('add a timeline event', async ({ page }) => {
  await login(page);
  await page.goto(`${BASE}/members/timeline.cfm`);
  await page.locator('input[name="eventTime"]').fill('14:30');
  await page.locator('input[name="eventName"]').fill('Playwright Test Event');
  await page.locator('input[name="description"]').fill('Added by automated test');
  await page.locator('form input[name="action"][value="add_event"]')
    .locator('..').locator('button[type="submit"]').click();
  await page.waitForURL(/timeline/);
  await expect(page.locator('body')).toContainText('Playwright Test Event');
});

test('add event - time and name required', async ({ page }) => {
  await login(page);
  await page.goto(`${BASE}/members/timeline.cfm`);
  await page.locator('form input[name="action"][value="add_event"]')
    .locator('..').locator('button[type="submit"]').click();
  const timeInput = page.locator('input[name="eventTime"]');
  const validationMsg = await timeInput.evaluate(el => el.validationMessage);
  expect(validationMsg).not.toBe('');
});

test('delete a timeline event', async ({ page }) => {
  await login(page);
  await page.goto(`${BASE}/members/timeline.cfm`);

  // add throwaway event
  await page.locator('input[name="eventTime"]').fill('23:59');
  await page.locator('input[name="eventName"]').fill('DELETE ME Timeline Event');
  await page.locator('form input[name="action"][value="add_event"]')
    .locator('..').locator('button[type="submit"]').click();
  await page.waitForURL(/timeline/);
  await expect(page.locator('body')).toContainText('DELETE ME Timeline Event');

  page.on('dialog', d => d.accept());
  const deleteBtn = page.locator('form input[name="action"][value="delete_event"]')
    .locator('..').locator('button[type="submit"]').last();
  await deleteBtn.click();
  await page.waitForURL(/timeline/);
  await expect(page.locator('body')).not.toContainText('DELETE ME Timeline Event');
});
