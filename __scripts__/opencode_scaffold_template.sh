#!/usr/bin/env bash

set -euo pipefail

TARGET_DIR="${1:-$PWD}"
FORCE="${2:-}"

if [ ! -d "$TARGET_DIR" ]; then
  echo "Target directory does not exist: $TARGET_DIR" >&2
  exit 1
fi

OPENCODE_DIR="$TARGET_DIR/.opencode"
AGENTS_DIR="$OPENCODE_DIR/agents"
SKILLS_DIR="$OPENCODE_DIR/skills"

if [ -d "$OPENCODE_DIR" ] && [ "$FORCE" != "--force" ]; then
  echo "Refusing to overwrite existing $OPENCODE_DIR" >&2
  echo "Re-run with --force to overwrite template files." >&2
  exit 1
fi

mkdir -p "$AGENTS_DIR" "$SKILLS_DIR/backend-engineer" "$SKILLS_DIR/frontend-engineer"

cat > "$OPENCODE_DIR/README.md" <<'EOF'
# OpenCode Project Template

This folder is a reusable project-local OpenCode setup.

## Use

Run OpenCode from the repository root so this config is auto-detected.

## Included

- `agents/project-architect.md` - planner-style project agent
- `skills/backend-engineer/SKILL.md` - backend-focused reusable skill
- `skills/frontend-engineer/SKILL.md` - frontend-focused reusable skill
EOF

cat > "$AGENTS_DIR/project-architect.md" <<'EOF'
---
description: >-
  Use this agent when the user needs planning, scoped implementation guidance,
  and architecture-aware sequencing for this repository.
mode: all
temperature: 0.1
---

## Role
You are Project Architect.

## Core behavior
- Ask clarifying questions when requirements are ambiguous.
- For multi-step implementation, create and maintain a task list.
- Do not implement changes unless the user explicitly asks for implementation.
- Follow existing repository patterns before proposing new conventions.
- Keep plans small, verifiable, and ordered by dependency.

## Output style
- Give concise actionable steps.
- Include risks and assumptions when relevant.
- Prefer concrete file paths and commands.
EOF

cat > "$SKILLS_DIR/backend-engineer/SKILL.md" <<'EOF'
---
name: backend-engineer
description: Backend implementation patterns and API-focused changes.
compatibility: opencode
---

## Instructions

- Respect existing service boundaries and contract-first design.
- Keep changes minimal for bugfixes; avoid unrelated refactors.
- Add verification steps (tests/build) for touched modules.
EOF

cat > "$SKILLS_DIR/frontend-engineer/SKILL.md" <<'EOF'
---
name: frontend-engineer
description: Frontend implementation patterns and UI-focused changes.
compatibility: opencode
---

## Instructions

- Preserve existing design system and component patterns.
- Ensure desktop/mobile behavior is validated.
- Keep accessibility and loading states explicit.
EOF

echo "OpenCode template scaffolded in: $OPENCODE_DIR"
echo "Next: run OpenCode from $TARGET_DIR"
