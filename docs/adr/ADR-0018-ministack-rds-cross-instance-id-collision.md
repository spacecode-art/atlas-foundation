# ADR-0018: MiniStack RDS Cross-Instance ID Collision Destroyed Real Dev Database

## Status
Accepted

## Date
2026-08-11

## Context
While testing the `database` module Terratest fixture, a
`terraform plan` run inside `tests/terratest/fixtures/database/`
refreshed its local state against MiniStack. The refresh returned data
belonging to the unrelated, real `development` environment's RDS
instance (`atlas-development-db`, id `db-9727E6AFC5EC445E95E7`) instead
of the fixture's own instance (`atlas-terratest-db-db`), despite the
two having different identifiers, different VPCs, and being managed
from entirely separate Terraform state files. The subsequent
`terraform destroy`, run against what the plan showed, destroyed the
real `atlas-development-db` instance.

This is a MiniStack defect, not a Terraform or fixture design flaw:
the fixture's isolation (separate provider config, separate CIDR range
10.98.0.0/16, separate state) was correct. MiniStack's RDS backend
appears to conflate DB instances across unrelated Terraform states
under some condition not yet fully characterized.

A contributing process failure: the plan output showing the identifier
had already switched to `atlas-development-db` was reviewed and the
mismatch was not caught before approving the destroy. The correct
response upon seeing an unexpected resource identifier in a plan is to
stop and investigate before typing `yes`, regardless of which
directory the command was run from.

## Decision
1. Recreated `atlas-development-db` via `terraform apply` in
   `development/` — no real application data was lost, since this
   environment never held anything beyond infrastructure definitions.
2. The `database` module Terratest (ADR-0017) remains excluded from
   CI and is now also excluded from routine local runs until this
   MiniStack defect is understood or resolved — the risk of it
   recurring against a real environment's resources is too high to
   treat as routine.
3. Adopt a standing rule: **any Terraform plan/apply/destroy showing
   a resource identifier, ARN, or tag that doesn't match what was
   expected for that specific working directory is treated as a hard
   stop** — investigate before proceeding, never assume the tool's
   output is scoped correctly by default.

## Rationale
This is the most serious MiniStack limitation found this session —
more serious than ADR-0016 (a modify that doesn't persist) or ADR-0017
(a destroy that hangs), because it caused real, if low-stakes, data
loss rather than merely an inconvenient or unverifiable test result.
The zero-cost plan's entire premise — that a local emulator is safe to
experiment against — depends on that emulator correctly isolating
unrelated resources. This finding shows that assumption does not
always hold for MiniStack's RDS emulation specifically.

## Consequences
### Positive
- A significant, previously-unknown MiniStack defect identified with
  clear reproduction evidence, worth reporting upstream
- A concrete, generalizable process rule (verify identifiers before
  approving any destructive action) that applies beyond this incident
### Negative
- Real dev database recreated from scratch; any manual configuration
  beyond the Terraform definition (there was none of consequence here)
  would have been lost
- `database` module Terratest coverage remains blocked, compounding
  the gap from ADR-0017
- Reduces confidence in using MiniStack for any further destructive
  testing (`destroy`, in particular) against RDS resources without
  extremely careful pre-verification of resource identifiers first