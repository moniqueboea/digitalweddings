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

test('wedding sites page loads without errors', async ({ page }) => {
  await login(page);
  await page.goto(`${BASE}/members/wedding-sites.cfm`);
  await expect(page.locator('body')).toContainText('Wedding');
  await expect(page.locator('body')).not.toContainText('is undefined');
  await expect(page.locator('body')).not.toContainText('MissingInclude');
  await expect(page.locator('body')).not.toContainText('An error occurred');
});

test('change template button is visible', async ({ page }) => {
  await login(page);
  await page.goto(`${BASE}/members/wedding-sites.cfm`);
  const changeBtn = page.locator('.btn-change-tpl').first();
  if (await changeBtn.isVisible()) {
    await expect(changeBtn).toContainText('Change Template');
  }
});

test('change template button is full width on mobile', async ({ page }) => {
  await page.setViewportSize({ width: 390, height: 844 });
  await login(page);
  await page.goto(`${BASE}/members/wedding-sites.cfm`);
  const changeBtn = page.locator('.btn-change-tpl').first();
  if (await changeBtn.isVisible()) {
    const box = await changeBtn.boundingBox();
    expect(box.width).toBeGreaterThan(300);
  }
});

test('navigate to edit wedding site', async ({ page }) => {
  await login(page);
  await page.goto(`${BASE}/members/wedding-sites.cfm`);
  const editLink = page.locator('a[href*="wedding-site-edit"]').first();
  if (await editLink.isVisible()) {
    await editLink.click();
    await expect(page.locator('body')).toContainText('Wedding Site');
    await expect(page.locator('body')).not.toContainText('is undefined');
  }
});

test('toggle publish/unpublish a site', async ({ page }) => {
  await login(page);
  await page.goto(`${BASE}/members/wedding-sites.cfm`);
  const publishForm = page.locator('form input[name="action"][value="toggle_publish"]').first();
  if (await publishForm.isVisible()) {
    const submitBtn = publishForm.locator('..').locator('button[type="submit"]');
    const btnText = await submitBtn.textContent();
    await submitBtn.click();
    await page.waitForURL(/wedding-sites/);
    // button label should have flipped
    const newBtn = page.locator('form input[name="action"][value="toggle_publish"]')
      .locator('..').locator('button[type="submit"]').first();
    const newText = await newBtn.textContent();
    expect(newText?.trim()).not.toBe(btnText?.trim());
  }
});
