const state = { sessionId: null };

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
    <h2>Lopputulos</h2>
    <p><strong>Suositus:</strong> ${escapeHtml(report.recommendation)}</p>
    <p>${escapeHtml(report.recommendation_rationale)}</p>
    <pre></pre>
  `;
  reportEl.querySelector("pre").textContent = report.concept_document_markdown;
}

function escapeHtml(text) {
  const div = document.createElement("div");
  div.textContent = text;
  return div.innerHTML;
}
