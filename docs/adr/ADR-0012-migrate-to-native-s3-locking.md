# ADR-0012: Migrate to Native S3 Locking

## Status
Accepted — supersedes ADR-0005

## Date
2026-08-10

## Context
ADR-0005 deferred migrating from DynamoDB-based state locking to
Terraform's native S3 conditional-write locking (`use_lockfile`),
reasoning there was no urgency while `dynamodb_table` still worked.
A full-repo audit surfaced this as a natural refactor point.

## Decision
All environments (`development`, `management`) now use
`use_lockfile = true` in their backend configuration instead of
`dynamodb_table`. The `aws_dynamodb_table.terraform_locks` resource
has been removed from bootstrap entirely, since nothing references it.

## Rationale
- Verified: the "Deprecated Parameter" warning present on every
  plan/apply since the repo's first commit is now gone
- Verified: both environments still initialize and plan correctly
  against MiniStack's S3 implementation
- One fewer piece of infrastructure to create, secure, and reason
  about, with no loss of locking guarantees
- Leaving the DynamoDB table in place, unused, after migrating locking
  away from it would be dead infrastructure — worse than removing it

## Consequences
### Positive
- Simpler bootstrap layer (one fewer resource)
- No more deprecation warning on every Terraform command
### Negative
- The DynamoDB table's point-in-time-recovery and encryption hardening
  from ADR-0010 is now moot — removed along with the table, not lost
  as a regression