# Atlas Foundation — Incident Runbook

## Purpose
A short, practical guide for what to do when something goes wrong in
this repository's infrastructure or pipeline — written for whoever is
on call, including future-me who won't remember the context.

## Incident classes covered

### 1. CI pipeline is red
1. Open the failed job in GitHub Actions and identify which of the three
   jobs failed: `repository-check`, `terraform-plan`, or `security-scan`.
2. **`repository-check` fails** — a required file (README, LICENSE, etc.)
   is missing or was renamed. Fix is almost always a one-line restore.
3. **`terraform-plan` fails** — read the error before assuming Terraform
   itself is broken. Check for: a `required_version` mismatch (see
   ADR-0012's version bump for a real example), a MiniStack service
   container that failed its health check, or a genuine syntax/logic
   error in the plan. Reproduce locally with MiniStack running
   (`docker start ministack`) before pushing a fix.
4. **`security-scan` fails** — a new, real finding, or a deferred finding
   whose check ID isn't in `ci.yml`'s `skip_check` list yet. Read the
   `Check:` line in the log for the exact Checkov ID and guide URL.
   Cross-reference against ADR-0010/0013's deferral lists before deciding
   whether to fix the underlying resource or extend the skip list with a
   new ADR justifying the deferral. Never blanket-disable with
   `soft_fail: true` — that silences real regressions along with reviewed
   ones.

### 2. MiniStack state appears to have lost recent resources
This is the known gap documented in ADR-0006 (MiniStack does not
reliably persist through an abrupt container crash, only a graceful
stop/start). Recovery:
1. `cd` into the affected environment directory
2. `terraform plan` — this will surface any drift between state and
   what MiniStack actually has
3. `terraform apply` to recreate anything MiniStack lost; state itself
   (in the S3-backed backend, not MiniStack's own storage) is not
   affected by this gap

### 3. Suspected real-AWS credential leak (even in this local/MiniStack-only project)
1. Immediately rotate the credential at its source (AWS IAM console,
   or wherever it was issued)
2. Check `git log --all -p | grep -i "AKIA\|aws_secret"` across the full
   history, not just the current tree, to rule out an accidental commit
3. Re-run `make security-scan` after rotation to confirm no residual
   reference remains in Terraform code

### 4. Terraform state lock appears stuck
Since ADR-0012 (native S3 locking), a stuck lock manifests as a
`.tflock` object in the state bucket that doesn't get cleaned up after
an interrupted `apply`.
1. Confirm no `terraform apply`/`plan` is actually still running
   somewhere (another engineer, a stuck CI job)
2. If confirmed stale, the lock file can be manually removed from the
   S3 bucket — this is a deliberate, manual, logged action, not
   something to script casually

## Escalation
This is currently a single-maintainer portfolio project — there is no
on-call rotation. In a real multi-engineer context, this section would
name who to page and when.