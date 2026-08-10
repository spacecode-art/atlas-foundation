# ADR-0015: RDS Second-Opinion Scan Triage (tfsec)

## Status
Accepted

## Date
2026-08-10

## Context
Running tfsec directly (not just Checkov) against the RDS module surfaced
two findings neither ADR-0010 nor ADR-0013 covered: missing backup
retention configuration (`aws-rds-specify-backup-retention`) and IAM
database authentication not enabled (`aws0176`). Checkov's equivalent
backup-policy check (`CKV_AWS_133`) passed, because it only checks that
the argument is set at all, not that it's set to a meaningful non-zero
value — the two tools check different things under similar names.

## Decision
Fixed immediately: `backup_retention_period` (new variable, default 7
days), `iam_database_authentication_enabled = true`. Both are free —
RDS automated backups are included up to allocated storage size, and
IAM auth is a boolean with no cost or availability impact.

## Rationale
Same triage principle as ADR-0010/0013: fix what's cheap and
unambiguous. Unlike Multi-AZ or Enhanced Monitoring, neither of these
findings has a real cost or complexity tradeoff — there was no reason
to defer them, only to notice them, which running a second scanner
(not just the one wired into CI) is what caught.

## Consequences
### Positive
- Two real gaps closed for free
- Confirms the value of running more than one scanner — Checkov and
  tfsec check for different things even on the same resource
### Negative
- None identified