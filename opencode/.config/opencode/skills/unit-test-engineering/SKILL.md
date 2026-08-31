---
name: unit-test-engineering
description: Create high-signal unit tests that prevent regressions and document expected behavior.
compatibility: opencode
metadata:
  quality: testing
---

## Focus

- Test behavior, not implementation details.
- Keep fixtures minimal and deterministic.
- Cover happy path, edge cases, and failure paths.

## Validation

- Ensure tests fail for the right reason before fix.
- Keep suites fast and isolated to support CI reliability.
