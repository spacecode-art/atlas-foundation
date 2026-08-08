# ADR-0009: Service Control Policies Module is Design-and-Validate Only

## Status
Accepted

## Date
2026-08-04

## Context
The `policies` module creates and attaches Service Control Policies to
Organizational Units, depending on `aws_organizations_policy` and
`aws_organizations_policy_attachment`. `terraform plan` succeeds fully
(15 resources across organizations, iam, and policies modules,
correctly computing the cross-module OU reference). `terraform apply`
fails identically to ADR-0007's finding: `CreatePolicy` returns a clean
`InvalidAction: not implemented` JSON error from MiniStack — consistent
with `CreateOrganization`'s failure mode, distinct from `sso-admin`'s
HTTP 405/HTML failure mode (ADR-0008).

## Decision
The `policies` module is validated via `terraform validate` and
`terraform plan` only, consistent with ADR-0007 and ADR-0008.

## Rationale
- Consistent, clean `InvalidAction` responses from every Organizations-
  service resource attempted so far (organization, OU, account, policy)
  suggest this is a deliberate, uniform implementation depth in
  MiniStack's Organizations service, not a random gap
- SCP design and attachment logic (region-restriction policy, correctly
  targeting the Workloads OU via cross-module reference) is the
  competency this module exists to demonstrate — apply-time execution
  against a stub emulator adds nothing beyond what plan already proves
- Real SCP enforcement is safest validated with AWS policy simulators
  in a real (non-production) account if ever needed, rather than
  fought against an emulator with no path to success

## Consequences
### Positive
- Full evidence trail now exists comparing failure modes across three
  Organizations-adjacent services, each showing consistent behavior
  within its own service boundary
### Negative
- No apply-time verification that the SCP's JSON is functionally
  correct beyond terraform validate's structural check — a policy
  simulator or real-account test would be needed for that