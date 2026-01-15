# Playwright Smoke Tests

## Purpose

These smoke tests verify that the application **actually runs**, not just that outputs match golden files.

**Benefits:**
- Proves app loads without errors
- Tests UI interactions work
- Catches runtime errors
- Works for both legacy AngularJS AND candidate Angular apps

## Setup

```bash
npm install -D @playwright/test
npx playwright install chromium
```

## Running Tests

### Test Legacy AngularJS App

```bash
# Start legacy app
cd ../legacy-app
npm run serve &  # Runs on localhost:8080

# Run smoke tests
cd ../tests/smoke
npx playwright test
```

### Test Candidate's Angular App

```bash
# Start candidate's app
cd /path/to/candidate/output/angularjs-to-angular
npm start &  # Usually runs on localhost:4200

# Run smoke tests pointing to their app
cd /path/to/challenge-repo/challenges/1-angularjs-to-angular/tests/smoke
APP_URL=http://localhost:4200 npx playwright test
```

## Integration with test-candidate.sh

Add to the evaluation script:

```bash
# After running behavioral tests, run smoke tests
if candidate app has package.json; then
  cd $CANDIDATE_OUTPUT_DIR/angularjs-to-angular
  npm install
  npm start &
  APP_PID=$!

  sleep 5  # Wait for app to start

  cd $CHALLENGE_REPO/challenges/1-angularjs-to-angular/tests/smoke
  APP_URL=http://localhost:4200 npx playwright test > $OUTPUT_DIR/smoke-tests.txt

  kill $APP_PID
fi
```

## What These Tests Check

1. **App Loads:** Page loads without critical errors
2. **Data Displays:** 20 employee cards render
3. **Search Works:** Filtering by text works
4. **Filters Work:** Department/location dropdowns work
5. **Sort Works:** Sorting changes order
6. **Selection Works:** Clicking employees shows selection
7. **Stats Display:** Count totals show correctly
8. **No Errors:** No console errors on load

## Scoring Impact

**Smoke tests passing = bonus points**
- Shows app actually works, not fake outputs
- Proves UI is functional
- +5 bonus points for fully working app

## Future Enhancements

- Test all filter combinations
- Test export functionality
- Test mobile responsiveness
- Performance metrics (load time)
