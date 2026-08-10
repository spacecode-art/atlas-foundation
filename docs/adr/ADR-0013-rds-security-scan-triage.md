# ADR-0013: RDS Module Security Scan Triage

## Status
Accepted

## Date
2026-08-10

## Context
The `security-scan` CI job (added this session) ran for the first time
against the RDS-inclusive codebase and correctly failed the build — the
`database` module was never triaged against Checkov before, since it
was built after ADR-0010's manual scan pass.

## Decision
Fixed immediately: copy_tags_to_snapshot, auto_minor_version_upgrade,
CloudWatch log exports (postgresql, upgrade) — all cheap, zero tradeoff.

Deferred, added to CI's skip list: Multi-AZ and deletion protection
(already configurable per-environment via ADR-0011's variables,
defaulting off for dev by design); enhanced monitoring and performance
insights (require additional paid infrastructure — an IAM monitoring
role and extra cost — not justified for a dev/portfolio database);
Postgres query logging (requires a custom DB parameter group not yet
built — genuine future work, not a quick fix).

## Rationale
Same principle as ADR-0010: fix what's cheap and unambiguous, defer
what's a real cost/complexity tradeoff with the reasoning written down,
rather than either blindly fixing everything a scanner flags or
silently ignoring findings.

## Consequences
### Positive
- security-scan CI job's skip list is now complete and accurate —
  the gate will correctly catch any *new* regression without false-
  failing on already-reviewed, deliberate choices
### Negative
- Enhanced monitoring, performance insights, and query logging remain
  unimplemented; revisit if this module is ever used for a real
  production database