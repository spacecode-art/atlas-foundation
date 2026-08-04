# ADR-0006: Accept MiniStack Crash-Persistence Gap

## Status
Accepted

## Date
2026-08-04

## Context
MiniStack's persistence (PERSIST_STATE=1, S3_PERSIST=1) reliably survives
graceful stop/start cycles. It does not reliably survive abrupt container
death (observed: exit code 255, likely a snapshot-interval gap) — older
resources (bootstrap's bucket and lock table) survived a real crash,
while a newer resource (the dev module's bucket) did not.

## Decision
Accept this as a known limitation. Do not pursue a write-through or
more aggressive persistence mode. Rely on existing habits (`make check`
before starting work; `terraform apply` to self-heal any detected drift)
to catch and recover from this automatically.

## Rationale
- This is a local development/portfolio environment, not a production
  system with real users
- The detection and recovery workflow already exists and already works
- Investigating MiniStack's internals further has low payoff relative
  to time cost, versus continuing Phase 1's remaining scope

## Consequences
### Positive
- No time lost chasing a deeper guarantee not needed for this project
### Negative
- An uncontrolled MiniStack crash can silently lose recent work until
  the next `terraform plan`/`apply` surfaces the drift
