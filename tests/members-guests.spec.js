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

test('guests page loads without errors', async ({ page }) => {
  await login(page);
  await page.goto(`${BASE}/members/guests.cfm`);
  await expect(page.locator('body')).toContainText('Guest');
  await expect(page.locator('body')).not.toContainText('is undefined');
  await expect(page.locator('body')).not.toContainText('An error occurred');
});

test('add a guest - name only', async ({ page }) => {
  await login(page);
  await page.goto(`${BASE}/members/guests.cfm`);
  await page.locator('input[name="name"]').fill('Test Guest Playwright');
  await page.locator('select[name="guestGroup"]').selectOption({ index: 1 });
  await page.locator('form input[name="action"][value="add_guest"]')
    .locator('..').locator('button[type="submit"]').click();
  await page.waitForURL(/guests/);
  await expect(page.locator('body')).toContainText('Test Guest Playwright');
});

test('add a guest - with email and dietary restrictions', async ({ page }) => {
  await login(page);
  await page.goto(`${BASE}/members/guests.cfm`);
  await page.locator('input[name="name"]').fill('Guest With Email');
  await page.locator('input[name="email"]').fill('guestwithmail@example.com');
  await page.locator('select[name="guestGroup"]').selectOption({ index: 1 });
  await page.locator('input[name="dietaryRestrictions"]').fill('Vegan');
  await page.locator('form input[name="action"][value="add_guest"]')
    .locator('..').locator('button[type="submit"]').click();
  await page.waitForURL(/guests/);
  await expect(page.locator('body')).toContainText('Guest With Email');
});

test('add a guest with plus one', async ({ page }) => {
  await login(page);
  await page.goto(`${BASE}/members/guests.cfm`);
  await page.locator('input[name="name"]').fill('Guest Plus One');
  await page.locator('select[name="guestGroup"]').selectOption({ index: 1 });
  await page.locator('#plusOneCheck').check();
  await expect(page.locator('#plusOneNameWrap')).toBeVisible();
  await page.locator('input[name="plusOneName"]').fill('Plus One Name');
  await page.locator('form input[name="action"][value="add_guest"]')
    .locator('..').locator('button[type="submit"]').click();
  await page.waitForURL(/guests/);
  await expect(page.locator('body')).toContainText('Guest Plus One');
});

test('add guest - name required, blocks empty submit', async ({ page }) => {
  await login(page);
  await page.goto(`${BASE}/members/guests.cfm`);
  await page.locator('form input[name="action"][value="add_guest"]')
    .locator('..').locator('button[type="submit"]').click();
  // browser validation should prevent navigation
  const nameInput = page.locator('input[name="name"]');
  const validationMsg = await nameInput.evaluate(el => el.validationMessage);
  expect(validationMsg).not.toBe('');
});

test('delete a guest', async ({ page }) => {
  await login(page);
  await page.goto(`${BASE}/members/guests.cfm`);

  // add a throwaway guest first
  await page.locator('input[name="name"]').fill('DELETE ME Playwright');
  await page.locator('select[name="guestGroup"]').selectOption({ index: 1 });
  await page.locator('form input[name="action"][value="add_guest"]')
    .locator('..').locator('button[type="submit"]').click();
  await page.waitForURL(/guests/);
  await expect(page.locator('body')).toContainText('DELETE ME Playwright');

  // delete them
  page.on('dialog', d => d.accept());
  const deleteBtn = page.locator('form input[name="action"][value="delete_guest"]')
    .locator('..').locator('button[type="submit"]').last();
  await deleteBtn.click();
  await page.waitForURL(/guests/);
  await expect(page.locator('body')).not.toContainText('DELETE ME Playwright');
});
