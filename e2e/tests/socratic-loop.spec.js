// E2E coverage for the "Idea runs through the Socratic loop" workflow
// (AGENT-INSTRUCTIONS/WORKFLOWS/MAP.md). Drives the real UI + real LLM end to end:
// mode select -> mittakaava select -> idea intake -> all 7 areas -> report. This is
// also interrogation-ui Phase P2's own move-on gate ("full session runs through all
// 7 areas to completion") and exercises P2's per-turn area label + verdict stamp.
//
// MAX_ATTEMPTS_PER_AREA (app/core/criteria.py) guarantees every area advances within
// 3 answers regardless of verdict quality, so a fixed, generic-but-substantive answer
// bounds the run at 7-21 rounds without needing the LLM to judge any answer "kestävä".
const { test, expect } = require("@playwright/test");

const MAX_ROUNDS = 25; // safety margin above the 21-round worst case (7 areas x 3 attempts)
const ROUND_TIMEOUT_MS = 180_000; // the final round also generates the report (a bigger LLM call)

const IDEA_TEXT =
  "Sisäinen työkalu, joka automatisoi laskujen tarkastuksen kirjanpito-osastolla.";

const ANSWER_TEXT =
  "Kirjanpito-osasto käyttää tällä hetkellä keskimäärin kolme tuntia päivässä " +
  "laskujen manuaaliseen tarkastukseen, mikä hidastaa kuukausittaista " +
  "tilinpäätöstä ja aiheuttaa virheitä noin viidessä prosentissa laskuista. " +
  "Kohderyhmä on organisaation oma kirjanpito-osasto, noin kuusi henkilöä. " +
  "Vaihtoehtona harkittiin ulkoistamista, mutta se olisi kalliimpi ja hitaampi " +
  "ottaa käyttöön. Oletuksena on, että laskudata on jo digitaalisessa muodossa. " +
  "Riskinä on virheellinen automaattinen hyväksyntä, jota lievennetään " +
  "poikkeamien ohjaamisella ihmisen tarkastettavaksi.";

test("idea validation session runs through all 7 areas to the report", async ({ page }) => {
  const consoleErrors = [];
  page.on("console", (msg) => {
    if (msg.type() === "error") consoleErrors.push(msg.text());
  });
  const pageErrors = [];
  page.on("pageerror", (err) => pageErrors.push(String(err)));

  await page.goto("/");

  await page.click("#mode-idea-btn");
  await page.click('[data-mittakaava="sisainen_toiminta"]');

  await page.fill("#idea", IDEA_TEXT);
  await page.click("#start-btn");

  await expect(page.locator("#chat")).toBeVisible({ timeout: ROUND_TIMEOUT_MS });
  await expect(page.locator(".message.assistant").first()).toBeVisible();

  let rounds = 0;
  while (!(await page.locator("#report").isVisible())) {
    rounds += 1;
    if (rounds > MAX_ROUNDS) {
      throw new Error(`Session did not complete within ${MAX_ROUNDS} rounds`);
    }

    const assistantCountBefore = await page.locator(".message.assistant").count();
    await page.fill("#answer", ANSWER_TEXT);
    await page.click('#answer-form button[type="submit"]');

    const deadline = Date.now() + ROUND_TIMEOUT_MS;
    for (;;) {
      if (await page.locator("#report").isVisible()) break;
      if ((await page.locator(".message.assistant").count()) > assistantCountBefore) break;
      if (Date.now() > deadline) {
        throw new Error(`Timed out waiting for round ${rounds} to advance`);
      }
      await page.waitForTimeout(500);
    }
  }

  await expect(page.locator("#report")).toBeVisible();
  await expect(page.locator("#report h2").first()).toContainText("Konseptidokumentti");
  await expect(page.locator(".recommendation")).not.toBeEmpty();

  // P2's own exit criteria: an area label and a verdict stamp on every judged turn.
  await expect(page.locator(".message.assistant").last()).toContainText("ALUE 07/07");
  const verdictStampCount = await page.locator(".verdict-stamp").count();
  expect(verdictStampCount).toBeGreaterThanOrEqual(7);

  expect(consoleErrors, `console errors: ${consoleErrors.join("; ")}`).toEqual([]);
  expect(pageErrors, `page errors: ${pageErrors.join("; ")}`).toEqual([]);
});
