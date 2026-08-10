# Atlas Foundation — Threat Model (STRIDE)

## Scope
This threat model covers the `atlas-foundation` repository as designed:
the AWS Organizations structure, IAM Identity Center configuration, SCPs,
Terraform state management, and the `storage`/`networking`/`database`
modules as consumed by the `management` and `development` environments.

It does not cover infrastructure outside this repo's control (application
code deployed onto Atlas-provisioned infrastructure, or the security of
GitHub itself as a platform).

## Assets
- Terraform state (contains resource IDs, and historically could contain
  secrets — see mitigation below)
- AWS account credentials used by CI and by engineers locally
- The S3 state bucket and its native lockfile
- RDS database credentials (managed via AWS Secrets Manager, ADR-0011)
- SCPs and IAM Identity Center permission sets (govern blast radius of
  a compromised identity)

## STRIDE Analysis

### Spoofing
- **Threat:** An attacker obtains AWS credentials (local `~/.aws/credentials`,
  a leaked CI secret) and acts as a legitimate engineer or the CI pipeline.
- **Mitigation:** CI's `terraform apply` only ever targets the ephemeral
  MiniStack service container, never real AWS — a compromised CI run
  cannot mutate real infrastructure. Real-AWS credentials are never
  present in this repository's CI. IAM Identity Center (not long-lived
  IAM users) is the intended access path for engineers, per ADR-0008.

### Tampering
- **Threat:** Terraform state is modified out-of-band, or a malicious PR
  smuggles in a resource change that isn't caught by `plan`-only CI.
- **Mitigation:** State is stored in a versioned, encrypted, public-
  access-blocked S3 bucket with native locking (ADR-0012), so concurrent
  writes are rejected and prior versions are recoverable. CI runs `plan`
  on every PR so reviewers see the exact diff before merge; `apply` is a
  manual, deliberate action outside CI for anything beyond the ephemeral
  MiniStack bootstrap.

### Repudiation
- **Threat:** No record of who made a given infrastructure change or why.
- **Mitigation:** All infrastructure changes are Terraform, reviewed via
  PR, and merged through git — every change has an author, a timestamp,
  and (for non-trivial decisions) an ADR explaining the reasoning.

### Information Disclosure
- **Threat:** Secrets (database passwords, API keys) leak via Terraform
  state, logs, or a committed file.
- **Mitigation:** The RDS module uses `manage_master_user_password = true`
  (ADR-0011) — AWS Secrets Manager generates and stores the credential;
  it never appears in Terraform state or in this repository. `.gitignore`
  excludes `.tfstate`/`.tfstate.*`/`.env` files. No `.tfstate` file has
  ever been committed to this repository (verified via `git log
  --diff-filter=A --name-only --all | grep tfstate`).

### Denial of Service
- **Threat:** A misconfigured SCP or a bad Terraform apply locks out
  legitimate access to an account or removes a resource that others
  depend on.
- **Mitigation:** SCPs are `plan`-validated only in this repo (ADR-0009)
  and have not been applied to a real account; a bad SCP would be caught
  in `plan` review before ever taking effect. `deletion_protection` on
  RDS is a configurable, per-environment variable (default off in dev,
  intended on for any future production environment — see ADR-0011).

### Elevation of Privilege
- **Threat:** A permission set or SCP grants broader access than intended,
  or the default VPC security group allows unintended lateral access.
- **Mitigation:** Only two permission sets exist today (`AdministratorAccess`,
  `ReadOnlyAccess`), both explicit and reviewed in `management/main.tf`.
  The default VPC security group is deliberately locked to zero rules
  (`networking` module) so nothing can accidentally inherit open access
  by attaching to it. The one active SCP (`restrict-region-us-east-1`)
  is a deny-by-default guardrail on the Workloads OU.

## Known Gaps (honest, not hidden)
- No `security`/`shared`/`staging`/`production` environments exist yet
  (ADR-0014) — this threat model will need revisiting once they do,
  since production will carry materially different risk (real user data,
  real traffic) than the dev/management environments modeled here.
- No automated secrets-scanning (Gitleaks) is wired into CI yet — planned
  for `atlas-security` (Phase 2), not duplicated here.
- Enhanced monitoring / Performance Insights on RDS are deferred
  (ADR-0013) — reduced visibility into anomalous database access
  patterns until that's revisited.