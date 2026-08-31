---
description: Manual fallback for Oracle tasks using Codex 5.3
agent: oracle
model: openai/gpt-5.3-codex
---

Use this when Oracle's primary Antigravity Opus route is unavailable or fails.

Task:

- Continue the Oracle-style analysis for: `$ARGUMENTS`.
- If `$ARGUMENTS` is empty, ask the user for the exact analysis scope.

Output requirements:

- Keep output read-only and architecture/debug focused.
- Include assumptions, risks, and recommended next actions.
