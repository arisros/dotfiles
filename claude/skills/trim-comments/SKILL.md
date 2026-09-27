---
name: trim-comments
description: Strip comments that do not earn their place from the current diff (or given paths), applying the global comment rules. Use when asked to trim, clean up, or remove comments, or to "de-slop" a change before commit or PR.
user-invocable: true
argument-hint: "[paths... | --base <ref> | --all]"
allowed-tools:
  - Bash
  - Read
  - Edit
---

# /trim-comments

Remove comments, never code. Zero comments is the default; a comment survives only if it earns its place.

## Scope

- No args: comments on lines added or changed in the working tree and staged changes against `HEAD`, plus comments on lines inside hunks you touch. On a clean tree, use the branch diff against `git merge-base HEAD origin/main`.
- `--base <ref>`: the diff against that ref.
- Paths: only those files, and still only changed lines.
- `--all` with paths: every comment in those files. Use only when asked.

Never widen past the scope. Pre-existing comments outside the touched hunks belong to someone else's change.

## Delete

- Restates what the next line does (`// increment counter`, `// return the result`).
- Narrates the change or talks to the reader (`// added this`, `// as requested`, `// per review`, `// new logic`, `// fixed`).
- Section markers and banners (`// ---- helpers ----`, `// MARK:`, `#region`).
- Commented-out code.
- Stale: describes behavior the code no longer has.
- Doc comments on unexported or private symbols that just repeat the name (`// getUser gets the user`).

## Keep

- A non-obvious why: a constraint, an ordering requirement, a surprising edge case.
- A workaround that names the cause it works around (bug link, upstream issue, version).
- A spec, RFC, or ticket reference (`BL-1234`).
- Doc comments on exported or public API where the language's conventions require them (Go exported identifiers, public TS APIs with TSDoc). If one only restates the name, rewrite it to one line that says something, or leave it; do not delete it and break lint.
- Directives. These are not comments: `//go:build`, `//go:generate`, `//go:embed`, `//nolint`, `// Deprecated:`, `eslint-disable*`, `@ts-expect-error`, `@ts-ignore`, `# type: ignore`, `# noqa`, `// prettier-ignore`, `/* webpackChunkName */`, shebangs, license headers, generated-file markers.

If a comment is only needed because the code is unclear, say so in the report. Do not refactor the code in this skill.

## Steps

1. Collect the diff for the scope (`git diff -U0`, `git diff --cached -U0`, or `git diff -U0 <base>...HEAD`). List each candidate comment with file and line.
2. Classify each one as delete or keep. When unsure, keep it and list it as uncertain.
3. Edit the files. Remove the comment and any blank line left orphaned by it. Leave trailing code on the same line intact.
4. Check that only comments changed: `git diff` after editing should show removed comment lines and nothing else. Run the project formatter on touched files if one exists (`gofmt -l`, `bunx prettier --check`, etc.) and fix only what the removal broke.
5. Do not stage or commit.

## Report

A table, then stop:

| File:line | Action | Reason |
|---|---|---|

Group deletions by reason when there are many. List kept-but-uncertain comments separately so I can decide.
