# ADR-0005: Defer Migration to Native S3 Locking

## Status
Accepted

## Date
2026-08-03

## Context
Terraform's S3 backend now supports native locking via `use_lockfile`
(S3 conditional writes), deprecating the long-standing `dynamodb_table`
parameter. `terraform init` surfaces this as a deprecation warning, not
an error.

## Decision
Continue using `dynamodb_table` for now. Revisit once the parameter is
marked for removal (not just deprecated), or once a natural refactor
point arrives.

## Rationale
The DynamoDB table is already built, tested, and understood. Migrating
now is optimizing a working system with no current pressure to change,
at the cost of time better spent on Phase 1's remaining scope.

## Consequences
### Positive
- No time lost on a non-urgent migration
### Negative
- Carries a deprecation warning until addressed