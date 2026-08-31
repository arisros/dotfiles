---
description: Dry-run lightweight route (Gemini Flash) for small non-coding tasks
agent: atlas
---

You are running a lightweight routing probe.

Task:

- Use this small request: `$ARGUMENTS`.
- If empty, use: `Summarize a short technical note into 5 bullets`.
- Keep response lightweight and non-coding.

Output format:

- `Route`: atlas -> expected model `opencode/gemini-3-flash`
- `Task classification`: one line
- `Result sample`: concise output demonstrating lightweight behavior
- `Escalation rule`: one line describing when to hand off to Codex coding routes
