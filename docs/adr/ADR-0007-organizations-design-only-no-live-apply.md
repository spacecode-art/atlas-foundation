# ADR-0007: AWS Organizations Module is Design-and-Validate Only

## Status
Accepted

## Date
2026-08-04

## Context
MiniStack's Organizations service accepts read/list operations but does
not implement `CreateOrganization` (confirmed: `InvalidAction: Operation
'CreateOrganization' not implemented`). `terraform plan` succeeds fully
(9 resources, correct dependency graph); `terraform apply` cannot
complete against MiniStack.

This is consistent with the zero-cost plan's own guidance for Phase 1
Organizations work and Phase 4 Networking: "designed and Terraform-coded,
validated with terraform plan, never applied."

## Decision
The `organizations` module and `management` environment are validated
via `terraform validate` and `terraform plan` only. No local `apply`
is attempted against MiniStack for this module. Plan output is captured
and committed as evidence (`docs/evidence/organizations-plan-output.txt`).

## Rationale
- MiniStack cannot execute this operation regardless of configuration
- Real AWS Organizations creation is a rare, structurally significant,
  account-wide operation — not something to burst-deploy casually even
  if it were technically possible for free
- A correct, reviewable plan showing the right resource graph and
  dependencies demonstrates the design competency this module exists
  to prove

## Consequences
### Positive
- No time lost fighting an emulator limitation that has no local fix
- Matches the zero-cost plan's own stated approach for this exact
  category of infrastructure
### Negative
- No "Live Demo" evidence possible for this specific module without a
  real (or different, more complete) AWS Organizations emulator