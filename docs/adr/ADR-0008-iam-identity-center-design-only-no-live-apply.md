# ADR-0008: IAM Identity Center Module is Design-and-Validate Only

## Status
Accepted

## Date
2026-08-04

## Context
IAM Identity Center cannot be created via Terraform in ANY AWS account,
real or emulated — AWS requires manual, one-time, console-based
enablement of an Identity Center instance; Terraform can only manage
resources *inside* an already-enabled instance.

Additionally, testing against MiniStack revealed `sso-admin` support is
incomplete: `terraform plan` succeeds fully (computing all resources
correctly), but `terraform apply` fails with HTTP 405 and an HTML
response body (not a JSON AWS-style error), indicating the endpoint
is not properly routed in MiniStack — a rawer gap than Organizations'
`CreateOrganization`, which fails with a proper JSON
`InvalidAction: not implemented` response.

## Decision
The `iam` module (permission sets, policy attachments, account
assignments) is validated via `terraform validate` and `terraform plan`
only. `sso_instance_arn` is a required variable, intentionally not
looked up or hardcoded, since no real instance exists to reference.
`account_assignments` is left as an empty list rather than populated
with fabricated principal IDs.

## Rationale
- No AWS account (real or MiniStack) supports creating an Identity
  Center instance via Terraform — this constraint exists independent
  of tooling choice
- A correct, fully-computed plan (13 resources across iam + organizations
  in this environment) demonstrates the design and module-composition
  competency this exists to prove
- Fabricating principal IDs for account_assignments would be dishonest
  placeholder data rather than a genuine capability demonstration

## Consequences
### Positive
- Module is complete, typed, and reusable the moment a real Identity
  Center instance ARN is available
### Negative
- No apply-time verification possible against any current tooling
- Cannot demonstrate account_assignments behavior without either a
  real AWS account or fabricated (dishonest) test data