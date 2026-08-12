# ADR-0017: MiniStack RDS Destroy Hangs Indefinitely

## Status
Accepted

## Date
2026-08-11

## Context
A Terratest run against the `database` module fixture applied
successfully (instance created, outputs retrieved correctly), but the
subsequent `terraform destroy` hung on `aws_db_instance.this` for over
6 minutes with no progress ("Still destroying...") before the test's
10-minute timeout force-killed the Go process. Investigation after the
fact confirmed the delete itself completed server-side — a follow-up
`rds describe-db-instances` showed the test instance genuinely gone,
no orphaned resource at that time. The defect is in the provider's
wait-for-completion polling against MiniStack, which never recognized
the deletion as finished, not in deletion itself never occurring.

## Decision
Treat this as a MiniStack RDS limitation, independent of this
repository's Terraform code — `storage` and `networking` modules
destroy cleanly and quickly against the same MiniStack instance. Do
not run the `database` module's Terratest in CI until resolved.

## Rationale
Consistent with ADR-0016: verify emulator behavior rather than assume
it; document real gaps rather than mask them with test-specific
workarounds.

## Consequences
### Positive
- A second real, reproducible MiniStack RDS limitation documented
### Negative
- No automated test coverage for the `database` module
- See ADR-0018: a follow-up investigation into this same fixture
  surfaced a more serious, related MiniStack defect