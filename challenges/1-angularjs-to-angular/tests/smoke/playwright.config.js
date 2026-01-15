// Playwright Configuration for Smoke Tests

module.exports = {
  testDir: '.',
  timeout: 30000,
  retries: 1,
  use: {
    baseURL: process.env.APP_URL || 'http://localhost:8080',
    headless: true,
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },
  projects: [
    {
      name: 'chromium',
      use: { browserName: 'chromium' },
    },
  ],
};
