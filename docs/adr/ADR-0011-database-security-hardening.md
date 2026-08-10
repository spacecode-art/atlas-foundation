# ADR-0011: Database Module Security Hardening

## Status
Accepted

## Date
2026-08-10

## Context
Initial `database` module implementation used `random_password` +
plaintext `password` attribute (stored in Terraform state), hardcoded
`skip_final_snapshot`/`deletion_protection`/`multi_az` (unsuitable if
reused for staging/production), and an unrestricted egress rule
(0.0.0.0/0, all ports) on the database security group.

## Decision
- Replaced random_password + plaintext password with
  `manage_master_user_password = true` (AWS Secrets Manager-backed,
  password never stored in Terraform state)
- Made `skip_final_snapshot`, `deletion_protection`, and `multi_az`
  variables with dev-safe defaults, overridable per environment
- Removed the database security group's egress rule entirely — a
  database has no legitimate need to initiate outbound connections;
  no rule denies all egress by default, the correct posture here

## Rationale
A database credential is among the most sensitive values a Terraform
module can handle. Storing it in plaintext state, even encrypted at
rest, is worse practice than delegating to a purpose-built secrets
service. Hardcoded safety-relevant flags silently carry a dev
assumption into every future environment that reuses the module — an
easy, dangerous mistake to make by omission months from now.

## Consequences
### Positive
- No database credential ever appears in Terraform state
- Module is genuinely safe to reuse for staging/production without a
  silent gap
### Negative
- `manage_master_user_password` requires a Secrets Manager `GetSecretValue`
  call to retrieve the actual password when needed (e.g. for an app's
  connection string) — one more moving part than a plain output, but
  the correct tradeoff
- MiniStack accepts `manage_master_user_password = true` without error
  but does not actually provision a Secrets Manager secret
  (`MasterUserSecret` returns `null` via `describe-db-instances`,
  rather than a populated `SecretArn`). This is a genuine emulator
  gap — distinct from the "not implemented" pattern seen with
  Organizations/SSO Admin — and means this specific behavior is
  unverified against MiniStack. The Terraform configuration itself is
  correct AWS practice regardless; verifying the actual secret
  creation would require a real AWS account or a burst-deploy per the
  zero-cost plan's guidance.  