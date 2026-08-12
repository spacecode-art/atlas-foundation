# ADR-0020: Mandatory tagging drift found via OPA/Conftest policy

## Status
Accepted

## Context
Atlas Security's Phase 2 build added an OPA/Conftest policy
(`policies/opa/tagging.rego`) requiring every taggable AWS resource to
carry `Environment`, `ManagedBy`, and `Owner` tags. Checkov and tfsec
scan for vulnerabilities and misconfigurations — neither tool has any
concept of organizational tagging conventions, so this gap was
structurally invisible to every scanner already running in CI.

Running the policy against `atlas-foundation`'s development plan
(`terraform show -json` piped into `conftest test ... --all-namespaces`)
surfaced 11 real violations across all three reusable modules:

- `storage`: missing `Owner`
- `database` (db instance, subnet group, security group): missing
  `ManagedBy` and `Owner`
- `networking` (VPC, IGW, route table, all 4 subnets): missing
  `ManagedBy` and `Owner`

Only the `storage` module had ever set `ManagedBy`, and no module had
ever set `Owner`. This wasn't a regression — it was the original
state of every module since Phase 1, undetected until a policy
existed to check for it.

## Decision
- Added an `owner` variable (no default — must be supplied explicitly
  by every module caller) to `storage`, `database`, and `networking`.
- Introduced a `local.common_tags` map in each module
  (`Environment`, `ManagedBy = "terraform"`, `Owner = var.owner`),
  merged into every resource's `tags` argument via `merge()`.
- Updated `terraform/environments/development/main.tf` to pass
  `owner = "platform-team"` to all three module calls.
- Re-ran `conftest test ... --all-namespaces`: 11 failures → 0.

## Consequences
- Every future resource added to these modules inherits correct
  tagging automatically via `local.common_tags`, rather than relying
  on each resource block remembering to set tags by hand — the same
  mechanism that caused the original drift.
- `owner` has no default, by design: it forces every environment
  (staging, production, shared, etc.) to make an explicit ownership
  decision rather than silently inheriting a placeholder.
- This is the first policy-as-code finding in the Atlas platform that
  caught something no off-the-shelf scanner (Checkov, tfsec) could
  have caught, validating the reason `atlas-security`'s Phase 2 
  roadmap included OPA/Conftest as a distinct line item from IaC
  scanning.