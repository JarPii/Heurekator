const state = { sessionId: null };

const VERDICT_LABELS = {
  pinnallinen: "Pinnallinen",
  ristiriitainen: "Ristiriitainen",
  puuttuva_nakokulma: "Puuttuva näkökulma",
  yksiulotteinen: "Yksiulotteinen",
  kestava: "Kestävä",
};
const RECOMMENDATION_LABELS = {
  jatka: "Jatka",
  kehita_lisaa: "Kehitä lisää",
  hylkaa: "Hylkää",
};
const PRIORITY_ORDER = { high: 0, medium: 1, low: 2 };
const PRIORITY_LABELS = { high: "Korkea", medium: "Keskitaso", low: "Matala" };
const RISK_KIND_LABELS = { risk: "Riskit", assumption: "Oletukset" };

const ideaForm = document.getElementById("idea-form");
const chat = document.getElementById("chat");
const messagesEl = document.getElementById("messages");
const answerForm = document.getElementById("answer-form");
const answerInput = document.getElementById("answer");
const reportEl = document.getElementById("report");
const startBtn = document.getElementById("start-btn");

startBtn.addEventListener("click", async () => {
  const idea = document.getElementById("idea").value.trim();
  if (!idea) return;
  startBtn.disabled = true;
  try {
    const res = await fetch("/api/sessions", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ idea }),
    });
    if (!res.ok) throw new Error(await res.text());
    const data = await res.json();
    state.sessionId = data.session_id;
    ideaForm.hidden = true;
    chat.hidden = false;
    addMessage("assistant", data.question);
  } catch (err) {
    alert(`Virhe session aloituksessa: ${err.message}`);
  } finally {
    startBtn.disabled = false;
  }
});

answerForm.addEventListener("submit", async (e) => {
  e.preventDefault();
  const answer = answerInput.value.trim();
  if (!answer || !state.sessionId) return;

  addMessage("user", answer);
  answerInput.value = "";
  setFormDisabled(true);

  try {
    const res = await fetch(`/api/sessions/${state.sessionId}/answer`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ answer }),
    });
    if (!res.ok) throw new Error(await res.text());
    const data = await res.json();

    if (data.done) {
      chat.hidden = true;
      reportEl.hidden = false;
      renderReport(data.report);
    } else {
      addMessage("assistant", data.question);
    }
  } catch (err) {
    addMessage("assistant", `[Virhe: ${err.message}]`);
  } finally {
    setFormDisabled(false);
  }
});

function setFormDisabled(disabled) {
  answerInput.disabled = disabled;
  answerForm.querySelector("button").disabled = disabled;
}

function addMessage(role, text) {
  const div = document.createElement("div");
  div.className = `message ${role}`;
  div.textContent = text;
  messagesEl.appendChild(div);
  messagesEl.scrollTop = messagesEl.scrollHeight;
}

function renderReport(report) {
  reportEl.innerHTML = `
    <h2>Konseptidokumentti</h2>
    <pre class="concept-doc"></pre>

    <h2>Arviointiprofiili</h2>
    <div class="evaluation-profile">${renderEvaluationProfile(report.evaluation_profile)}</div>

    <h2>Riskirekisteri</h2>
    <div class="risk-register">${renderRiskRegister(report.risk_register)}</div>

    <h2>Suositus</h2>
    <p class="recommendation"><strong>${escapeHtml(RECOMMENDATION_LABELS[report.recommendation] || report.recommendation)}</strong></p>
    <p>${escapeHtml(report.recommendation_rationale)}</p>
  `;
  reportEl.querySelector(".concept-doc").textContent = report.concept_document_markdown;
}

function renderEvaluationProfile(areas) {
  return areas.map(area => `
    <div class="area-card">
      <h3>${escapeHtml(area.area_label)} <span class="verdict-pill verdict-${area.verdict}">${escapeHtml(VERDICT_LABELS[area.verdict] || area.verdict)}</span></h3>
      <ul class="score-list">
        ${area.scores.map(s => `<li><strong>${escapeHtml(s.criterion)}</strong> ${s.score}/5 — ${escapeHtml(s.comment)}</li>`).join("")}
      </ul>
      ${area.weaknesses.length ? `
        <div class="weaknesses">
          <strong>Heikkoudet:</strong>
          <ul>${area.weaknesses.map(w => `<li>${escapeHtml(w)}</li>`).join("")}</ul>
        </div>
      ` : ""}
    </div>
  `).join("");
}

function renderRiskRegister(entries) {
  return ["risk", "assumption"].map(kind => {
    const items = entries
      .filter(e => e.kind === kind)
      .sort((a, b) => PRIORITY_ORDER[a.priority] - PRIORITY_ORDER[b.priority]);
    if (items.length === 0) return "";
    const hasHighPriority = items.some(e => e.priority === "high");
    return `
      <details class="risk-group" ${hasHighPriority ? "open" : ""}>
        <summary>${RISK_KIND_LABELS[kind]} (${items.length})</summary>
        <ul>
          ${items.map(e => `
            <li class="risk-item priority-${e.priority}">
              <span class="priority-badge">${escapeHtml(PRIORITY_LABELS[e.priority] || e.priority)}</span>
              ${escapeHtml(e.description)}
            </li>
          `).join("")}
        </ul>
      </details>
    `;
  }).join("");
}

function escapeHtml(text) {
  const div = document.createElement("div");
  div.textContent = text;
  return div.innerHTML;
}
