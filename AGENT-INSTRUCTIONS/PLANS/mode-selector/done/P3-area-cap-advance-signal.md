## Phase P3 - Area-cap advance signal [DONE]

User-confirmed. Build instructions retired. Later work consumes this frozen contract:

- `frontend/app.js` - `state` now tracks `areaIndex` (set on session start from
  `data.area_index`, updated after every answered turn). In `answerForm`'s non-`done`
  branch, `capForced = data.area_index !== state.areaIndex && data.verdict !== "kestava"`
  is derived purely client-side from fields P2 already returns - no backend change, no
  new API field. When `capForced`, a new `addAreaCapNote()` call appends a
  `.area-cap-note` div to `#messages` between the verdict stamp and the next question.
- `frontend/style.css` - `.area-cap-note` is a distinct, non-tilted informational
  element (dashed left border, `--paper-dim` text) - deliberately not a `.verdict-stamp`
  variant, since it communicates a process note, not a verdict.
- `app/core/engine.py` - untouched; `Engine.submit_answer`'s `resolved` condition
  (`verdict == "kestava" or attempts >= MAX_ATTEMPTS_PER_AREA`) and
  `MAX_ATTEMPTS_PER_AREA` are unchanged. This phase only makes an existing gate
  visible; it does not change when an area advances.
- **Verified:** the cap-forced path (three consecutive non-`kestävä` answers advancing
  the area) was exercised by the user, who confirmed the phase.
- **Not independently re-verified:** the negative case (a genuine `kestävä` advance
  showing no note) was not separately walked end-to-end in this session - the
  evaluation prompt (`app/prompts/evaluation.py`) proved strict enough in manual testing
  that reaching a first/second-try `kestävä` verdict was difficult to engineer on
  demand. The code path for this case is a direct, symmetric consequence of the same
  `capForced` boolean (it is false whenever the last verdict is `kestävä`, regardless of
  whether the area advanced), so it is covered by the same logic already exercised, not
  by an independent code path. If a future session finds the note appearing on a
  genuine `kestävä` advance, this is the first place to check.
- **Open note (not this phase's scope):** the evaluation prompt's apparent strictness
  (hard to reach `kestävä` even with a strong-seeming answer) surfaced during this
  phase's testing. Not investigated or changed here - flagged for a future session if
  it becomes a product concern.
