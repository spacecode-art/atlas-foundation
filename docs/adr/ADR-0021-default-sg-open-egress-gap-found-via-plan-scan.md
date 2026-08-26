# ADR-0021: Default SG had a real open-egress gap; plan-based Checkov caught it, static scan didn't

## Status
Accepted

## Context
Checkov's static scan of `terraform/` source reported `CKV2_AWS_12`
("default security group restricts all traffic") as PASSED for
`module.network.aws_vpc.this`. Checkov's plan-based scan (against
`environments/development/plan.json`) reported the same check as
FAILED for the same resource.

Investigating via `terraform plan` against the real `development`
MiniStack state confirmed the plan-based scan was right and the
static scan was wrong: the live `aws_default_security_group.this`
still carried AWS's auto-created default egress rule
(`0.0.0.0/0`, all ports, all protocols) — because the original code
only declared the resource with no `ingress`/`egress` blocks at all,
relying on the comment "intentionally empty ... locks down the
default SG" without actually telling Terraform to manage those
blocks. Omitting a block means Terraform doesn't touch it; it does
not mean AWS's default state is absent. The static scanner, parsing
HCL structure only, has no way to see AWS's implicit default and
so it evaluated "no block declared" as "no rules" — a false negative.

## Decision
Declare `ingress = []` and `egress = []` explicitly in
`aws_default_security_group.this`, so Terraform takes ownership of
both and actively reconciles them to empty on `apply` — closing the
real open-egress gap, not just satisfying a scanner.

## Consequences
- **This is a real security fix, not a documentation/scanner-noise
  fix.** The `development` default SG had unrestricted egress since
  it was first created. `terraform apply` against the corrected code
  (0 added, 12 changed, 0 destroyed) confirmed the egress rule was
  removed, and a re-scan confirmed `CKV2_AWS_12` now passes on both
  the static and plan-based checks.
- The static Checkov scan's blind spot here (can't see AWS-side
  implicit defaults, only declared HCL) is a real limitation, worth
  remembering elsewhere: an empty/omitted block is not provably "no
  rules" without a plan- or state-based check confirming it.
- `docs/evidence/security-scans/checkov-output-after-fixes.txt` is
  refreshed to show both scans passing post-fix, re-run 2026-08-26.
