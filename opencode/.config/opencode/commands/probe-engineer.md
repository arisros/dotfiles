---
description: Dry-run Software Engineer route (Codex) with skill suggestions
agent: software-engineer
---

You are running a routing probe for the Software Engineer role.

Task:

- Use this request: `$ARGUMENTS`.
- If empty, use: `Implement a small Go endpoint with tests`.
- Do not modify files and do not run write actions for this probe.

Output format:

- `Route`: software-engineer -> expected model `openai/gpt-5.3-codex`
- `Top skills to load`: 2-4 exact skill names
- `Dry-run plan`: 3-6 concrete implementation steps
- `Go-live handoff`: one short sentence for next execution step
