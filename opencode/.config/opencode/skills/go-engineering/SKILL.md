---
name: go-engineering
description: Build idiomatic Go services with strong interfaces, context handling, and testable design.
compatibility: opencode
metadata:
  language: go
---

## Focus

- Prefer explicit interfaces and package-level cohesion.
- Respect context cancellation and deadlines in I/O paths.
- Return wrapped errors with useful call-site context.

## Validation

- Run focused `go test` for touched packages.
- Check race-prone paths when concurrency is introduced.
