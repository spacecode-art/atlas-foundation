# ADR-0014: Defer security, shared, staging, and production Environment Directories

## Status
Accepted

## Date
2026-08-10

## Context
ADR-0001 commits Atlas to a six-account structure (management, security,
shared, development, staging, production). `terraform/environments/`
currently contains real, applied-or-plan-validated configuration for
`management` and `development` only. The `security`, `shared`, `staging`,
and `production` directories exist as empty placeholders — they are not
tracked by git (git does not track empty directories), so they are not
actually visible in the repository on GitHub despite being listed in the
README's structure diagram.

## Decision
Formally defer building out `security`, `shared`, `staging`, and
`production` environment configurations until Phase 1's remaining
scope (threat model, incident runbook, evidence refresh) is complete.
Remove the four directories from the README's structure diagram until
each has real content, to avoid implying they exist when they don't.

## Rationale
An empty, untracked directory that appears in documentation but not in
the actual repository is a factual inconsistency, not a placeholder —
it should either contain something or not be claimed. Building out four
more environments before finishing the documentation and testing gaps
in the two environments that already exist would also be scope creep:
better to finish what's started before widening it further.

## Consequences
### Positive
- README accurately reflects what's actually in the repository
- Clear, written scope boundary for what "Phase 1 complete" means
### Negative
- The full six-account structure from ADR-0001 isn't demonstrated end
  to end yet; revisit this ADR when `security`/`shared`/`staging`/
  `production` are actually built