---
description: Dry-run Principal Reviewer route (Codex) for architecture/code quality checks
agent: principal-software-engineer-reviewer
---

You are running a routing probe for the Principal Software Engineer Reviewer role.

Task:

- Review this scope: `$ARGUMENTS`.
- If empty, use: `API handler + database migration + tests`.
- Keep this probe read-only; do not produce patches.

Output format:

- `Route`: principal-software-engineer-reviewer -> expected model `openai/gpt-5.3-codex`
- `Top risks`: 3 bullets with severity labels
- `Review checklist`: architecture, correctness, security, performance, operability
- `Go-live handoff`: one short sentence for actionable review execution
