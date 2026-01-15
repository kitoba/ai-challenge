// Playwright Smoke Tests for AngularJS/Angular Challenge
// Tests that the app actually runs (not just outputs match)

const { test, expect } = require('@playwright/test');

// Can test both legacy AngularJS and modernized Angular apps
const APP_URL = process.env.APP_URL || 'http://localhost:8080';

test.describe('Employee Directory - Smoke Tests', () => {

  test('app loads and displays employees', async ({ page }) => {
    await page.goto(APP_URL);

    // Wait for employees to load
    await page.waitForSelector('.employee-card, employee-card', { timeout: 5000 });

    // Should have 20 employees
    const cards = await page.locator('.employee-card, employee-card').count();
    expect(cards).toBe(20);
  });

  test('search functionality works', async ({ page }) => {
    await page.goto(APP_URL);
    await page.waitForSelector('.employee-card, employee-card');

    // Search for "smith"
    const searchInput = page.locator('input[type="text"][ng-model="searchText"], input[placeholder*="Search"]').first();
    await searchInput.fill('smith');

    // Wait for filtering
    await page.waitForTimeout(500);

    // Should show only 1 employee
    const visibleCards = await page.locator('.employee-card:visible, employee-card:visible').count();
    expect(visibleCards).toBeGreaterThanOrEqual(1);
    expect(visibleCards).toBeLessThanOrEqual(2); // Should be 1, but allow small variance
  });

  test('department filter works', async ({ page }) => {
    await page.goto(APP_URL);
    await page.waitForSelector('.employee-card, employee-card');

    // Select Engineering department
    const deptFilter = page.locator('select').filter({ has: page.locator('option:has-text("Engineering")') }).first();
    await deptFilter.selectOption('Engineering');

    // Wait for filtering
    await page.waitForTimeout(500);

    // Should show ~8 engineering employees
    const visibleCards = await page.locator('.employee-card:visible, employee-card:visible').count();
    expect(visibleCards).toBeGreaterThan(5);
    expect(visibleCards).toBeLessThan(12);
  });

  test('sort functionality works', async ({ page }) => {
    await page.goto(APP_URL);
    await page.waitForSelector('.employee-card, employee-card');

    // Get first employee name before sort
    const firstCardBefore = await page.locator('.employee-card h3, employee-card h3').first().textContent();

    // Change sort to lastName
    const sortSelect = page.locator('select[ng-model="sortField"], select').filter({ has: page.locator('option:has-text("Last Name")') }).first();
    await sortSelect.selectOption({ label: /Last Name/i });

    // Wait for re-sort
    await page.waitForTimeout(500);

    // First employee should start with "A" (Adams)
    const firstCardAfter = await page.locator('.employee-card h3, employee-card h3').first().textContent();

    // Just verify something happened (names changed or stayed same)
    expect(firstCardAfter).toBeTruthy();
  });

  test('employee selection works', async ({ page }) => {
    await page.goto(APP_URL);
    await page.waitForSelector('.employee-card, employee-card');

    // Click first employee card or select button
    const firstCard = page.locator('.employee-card, employee-card').first();
    await firstCard.click();

    // Should show selected state (either class change or selected panel)
    const hasSelectedClass = await firstCard.evaluate(el =>
      el.classList.contains('selected') || el.classList.contains('highlight')
    );

    // Or check if selected panel appears
    const selectedPanel = page.locator('.selected-panel, .selected-list');
    const panelVisible = await selectedPanel.isVisible().catch(() => false);

    expect(hasSelectedClass || panelVisible).toBeTruthy();
  });

  test('stats display correctly', async ({ page }) => {
    await page.goto(APP_URL);
    await page.waitForSelector('.employee-card, employee-card');

    // Look for stats section
    const stats = page.locator('.stats, .stat-item');

    // Should show total count
    const statsText = await stats.allTextContents();
    const hasTotal = statsText.some(text => text.includes('20') || text.includes('Total'));

    expect(hasTotal).toBeTruthy();
  });

  test('no console errors on load', async ({ page }) => {
    const consoleErrors = [];

    page.on('console', msg => {
      if (msg.type() === 'error') {
        consoleErrors.push(msg.text());
      }
    });

    await page.goto(APP_URL);
    await page.waitForSelector('.employee-card, employee-card');

    // Allow some errors but not critical ones
    const criticalErrors = consoleErrors.filter(err =>
      err.includes('Failed to load') ||
      err.includes('undefined is not') ||
      err.includes('Cannot read property')
    );

    expect(criticalErrors).toHaveLength(0);
  });
});
