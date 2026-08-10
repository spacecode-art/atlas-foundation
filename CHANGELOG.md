# Changelog

All notable changes to this project are documented here. Format loosely
follows [Keep a Changelog](https://keepachangelog.com/).

## [Unreleased]

### Added
- Threat model, incident runbook, and README sections closing out the
  remaining Phase 1 documentation gaps (Problem Statement, Technology
  Choices with tradeoffs, Deployment Guide, CI/CD, Future Roadmap)
- ADR-0014: formally defer `security`/`shared`/`staging`/`production`
  environment directories
- `make check` and `make security-scan` targets (previously referenced
  by ADR-0006 but never implemented)

## [2026-08-10]

### Added
- `database` module (RDS Postgres) with Secrets Manager-backed
  credentials — no plaintext password ever written to Terraform state
  (ADR-0011)
- `security-scan` CI job (Checkov, hard-fail on unreviewed findings)
- ADR-0011, 0012, 0013

### Changed
- Migrated all environments from DynamoDB-based state locking to
  native S3 locking (`use_lockfile`), removing the DynamoDB lock table
  entirely (ADR-0012, supersedes ADR-0005)
- Bumped minimum Terraform version to 1.11 across CI and all
  `versions.tf` files — `use_lockfile` requires ≥1.10 and was
  experimental until 1.11

### Fixed
- Checkov skip list completed to cover all previously-reviewed
  deferrals from ADR-0010 and ADR-0013 (public-subnet public-IP
  behavior, Postgres query logging, Multi-AZ, deletion protection,
  enhanced monitoring, performance insights)
- `.terraform.lock.hcl` files now committed (were previously
  git-ignored, against Terraform's own guidance)

## [2026-08-04]

### Added
- `organizations` module + `management` environment: real AWS
  accounts, Organizational Units, and a Service Control Policy
  (`restrict-region-us-east-1`) — plan-validated only (ADR-0007)
- `iam` module: IAM Identity Center permission sets and account
  assignments — plan-validated only (ADR-0008)
- `policies` module: SCPs as code — plan-validated only (ADR-0009)
- ADR-0006 through ADR-0010

### Fixed
- S3 public-access-blocking and encryption, DynamoDB encryption and
  point-in-time recovery, VPC default-security-group lockdown — per
  first full Checkov/tfsec triage pass (ADR-0010)

## [2026-08-03]

### Added
- `networking` module (VPC, subnets, IGW, routing), consumed by
  `development` — fully applied and verified against MiniStack
- ADR-0003, 0004, 0005

### Changed
- Replaced LocalStack with MiniStack across the project after
  LocalStack discontinued free-tier state persistence (ADR-0004)

## [2026-07-31]

### Added
- Repository initialized: governance files, `.editorconfig`,
  `.gitignore`, CI skeleton
- `storage` module, `development` environment, isolated Terratest
  suite for `storage`
- Bootstrap backend (S3 state bucket, applied once with local state)
- ADR-0001, 0002