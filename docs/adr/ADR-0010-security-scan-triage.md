# ADR-0010: Security Scan Findings Triage (Checkov + tfsec)

## Status
Accepted

## Date
2026-08-04

## Context
Ran Checkov (20 passed, 18 failed) and tfsec (7 passed, 34 findings: 22
high, 8 medium, 4 low) against the full Terraform tree. Both tools
converged on the same three clusters: S3 bucket hardening, DynamoDB
hardening, and VPC visibility/hardening.

## Decision
Fixed immediately: S3 public access blocks + encryption at rest
(bootstrap state bucket and storage module), DynamoDB encryption at
rest + point-in-time recovery, VPC default security group lockdown.

Deferred, documented, not fixed: S3 access logging (needs a dedicated
log bucket), S3 lifecycle policies (no retention policy decided yet),
S3 cross-region replication (unnecessary for dev-tier), customer-
managed KMS keys on S3/DynamoDB (AWS-managed encryption is adequate
at this stage), VPC flow logs (belongs to Phase 3 Observability per
the project's own roadmap), S3 event notifications (no consumer
exists yet).

Explicitly NOT a finding to fix: public subnets assigning public IPs
on launch. This is flagged by both tools but is the deliberate,
correct behavior of a public subnet — "fixing" it would defeat the
subnet's purpose. Kept as-is by design.

## Rationale
Security hardening should be proportionate to what the infrastructure
actually needs right now, not applied uniformly to every possible
finding regardless of context. Fixing everything a scanner flags,
including checks that contradict the resource's own design intent,
would be worse engineering judgment than triaging deliberately.

## Consequences
### Positive
- Meaningful hardening applied where it costs nothing and adds real
  protection
- Full evidence trail (before/after scan output) available for review
### Negative
- Some findings remain open; a stricter security review (e.g. before
  any real production use) would need to revisit the deferred list