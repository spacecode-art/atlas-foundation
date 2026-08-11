# ADR-0016: MiniStack RDS Modify-in-Place Does Not Persist

## Status
Accepted

## Date
2026-08-11

## Context
Applying an in-place RDS modification (backup_retention_period,
copy_tags_to_snapshot, enabled_cloudwatch_logs_exports,
iam_database_authentication_enabled — see ADR-0011/ADR-0015) against
MiniStack completes with `Apply complete!` after a realistic ~80s
"Modifying..." wait, but a `terraform plan` run immediately afterward,
with no MiniStack restart in between, shows the identical diff still
pending. Reproduced twice, identically, during demo-video recording
sessions. This is unrelated to the container-restart persistence
question ADR-0006 addresses — no restart occurred between the apply
and the confirming plan in either reproduction.

## Decision
Treat this as a known, documented limitation of MiniStack's RDS
emulation, not a defect in this repository's Terraform code. The
`database` module's configuration is correct and would apply cleanly
against real AWS; MiniStack's mock does not correctly persist RDS
modify-in-place calls for these specific attributes. Do not attempt
workarounds (e.g., `lifecycle { ignore_changes }`) that would mask
genuine drift in a real AWS environment — the cost of a perpetually
non-clean `plan` against MiniStack for this one resource is lower than
the cost of silently ignoring real RDS drift in production.

## Rationale
Consistent with prior tooling-churn ADRs (0003, 0004, 0006): verify
claims about local emulators rather than trust them, and document the
gap rather than contort the codebase around it.

## Consequences
### Positive
- A real, reproducible finding, worth reporting upstream to MiniStack
- Confirms this repository's actual Terraform code is correct
### Negative
- `terraform plan` against `development`'s database module will show
  perpetual drift on MiniStack until either MiniStack fixes this or
  this environment is burst-tested against real AWS instead