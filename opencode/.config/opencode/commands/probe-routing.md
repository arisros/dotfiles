---
description: Show the routing probe matrix for Codex and Gemini role checks
agent: sisyphus
---

Task:

- Build a concise routing verification checklist using the current role commands.
- If `$ARGUMENTS` is provided, adapt examples to that stack/domain.

Output format:

1. `Engineer (Codex)`: command + expected outcome
2. `Reviewer (Codex)`: command + expected outcome
3. `QA (Codex)`: command + expected outcome
4. `Product Owner (Gemini)`: command + expected outcome
5. `Lightweight (Gemini)`: command + expected outcome

Use these commands in the checklist:

- `/probe-engineer <task>`
- `/probe-reviewer <change-summary>`
- `/probe-qa <feature-or-bugfix>`
- `/probe-po <prd-or-feature-brief>`
- `/probe-lightweight <small-request>`
