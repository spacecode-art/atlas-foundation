# ADR-0019: Makefile Did Not Actually Exclude the Unsafe `database` Terratest

## Status
Accepted

## Date
2026-08-12

## Context
ADR-0017 and ADR-0018 state the `database` module's Terratest is
"excluded from CI and from routine local runs." That exclusion was
never implemented — `make test` ran `go test -v -timeout 10m` with no
`-run` filter and no build constraint, so `database_module_test.go`
compiled and ran like any other test in the package. Running `make
check` triggered it, reproducing the ADR-0017 destroy hang (10-minute
timeout, forced panic) against a real MiniStack RDS instance
(`db-48AE6595E97B423CB1E9`).

A second, previously undocumented defect surfaced in the same run:
`assert.NotNil(t, instance.MasterUserSecret, ...)` failed. MiniStack's
`DescribeDBInstances` does not populate `MasterUserSecret` even though
the instance is created with `manage_master_user_password = true`.
Neither ADR-0017 nor ADR-0018 mention this — the previous run
apparently got far enough to retrieve outputs correctly before hitting
the destroy hang; this run failed the assertion first.
Independently confirmed against the real `development` instance
(`atlas-development-db`, applied and running normally): its
`describe-db-instances` output has no `MasterUserSecret` key at all.
This is not fixture-specific — MiniStack's RDS emulation does not
populate `MasterUserSecret` for any instance, regardless of
`manage_master_user_password`. The `database` module's own Terraform
code is correctly configured; MiniStack simply doesn't emulate this
AWS API field yet.

## Decision
1. `database_module_test.go` now requires the `ministack_unsafe_rds`
   build tag, making it physically excluded from `go build`/`go test`
   by default rather than merely undocumented-as-run. This is
   enforced by the compiler, not by remembering to pass a flag.
2. Added `make test-database-unsafe` as the only sanctioned way to run
   it, with an explicit warning printed every time.
3. Documenting the `MasterUserSecret` gap as a third distinct MiniStack
   RDS limitation, alongside ADR-0016 (modify-in-place) and ADR-0017
   (destroy hang).

## Rationale
A documented exclusion that isn't enforced in code is a documentation
bug wearing a safety-policy costume — the failure mode here is
identical in kind to the CHANGELOG/README staleness fixed earlier in
this repo's history, except this instance had a real consequence
(another live RDS instance created against MiniStack, another
destroy-hang timeout) instead of just an inaccurate README. The fix is
to make the constraint structural (compiler-enforced) rather than
procedural (someone remembering a claim in prose).

## Consequences
### Positive
- The unsafe test cannot run by accident again — no flag to forget
- A third, previously unknown MiniStack RDS defect documented
### Negative
- One more MiniStack RDS limitation stacked on `database` module
  automated coverage; still zero passing Terratest for this module