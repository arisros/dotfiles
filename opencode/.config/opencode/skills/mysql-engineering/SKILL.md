---
name: mysql-engineering
description: Design and tune MySQL schema and queries for correctness, migration safety, and performance.
compatibility: opencode
metadata:
  database: mysql
---

## Focus

- Favor additive, rollback-safe migrations.
- Design indexes from query patterns, not assumptions.
- Guard transaction boundaries and isolation semantics.

## Validation

- Explain query plans on high-impact queries.
- Add tests for migration and data integrity constraints.
