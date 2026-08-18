// Playwright config for Heurekator's E2E suite (D10). Drives the real FastAPI app
// against a real LLM provider — there is no mock mode (PROJECT.md §3), so runs are
// slow and consume real API quota. webServer reuses an already-running dev server
// (uvicorn on :8000) if present, so this also works during interactive development.
// @ts-check
const path = require("path");
const { defineConfig } = require("@playwright/test");

const repoRoot = path.resolve(__dirname, "..");

module.exports = defineConfig({
  testDir: "./tests",
  timeout: 40 * 60 * 1000,
  fullyParallel: false,
  retries: 0,
  reporter: "list",
  use: {
    baseURL: "http://localhost:8000",
    trace: "retain-on-failure",
  },
  webServer: {
    command: 'bash -c "source venv/bin/activate && uvicorn app.main:app --port 8000"',
    cwd: repoRoot,
    url: "http://localhost:8000",
    reuseExistingServer: true,
    timeout: 60 * 1000,
  },
});
