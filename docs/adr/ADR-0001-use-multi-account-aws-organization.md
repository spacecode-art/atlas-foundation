# ADR-0001: Use a Multi-Account AWS Organization

## Status

Accepted

## Date

2026-07-31

---

## Context

Atlas is intended to evolve into an Internal Developer Platform (IDP) capable of supporting multiple environments, reusable infrastructure, and secure cloud operations.

A key architectural decision is whether to deploy all infrastructure into a single AWS account or to establish a multi-account AWS Organization from the beginning.

---

## Decision

Atlas will adopt a multi-account AWS Organization.

The initial account strategy consists of:

- Management
- Security
- Shared Services
- Development
- Staging
- Production

Terraform modules and repository structure will be designed to support this model from the outset.

---

## Rationale

A multi-account strategy provides:

- Strong security boundaries.
- Clear separation of environments.
- Centralized governance.
- Simplified access management.
- Better cost allocation.
- Improved scalability as the platform grows.

Although it introduces additional operational complexity, it aligns with common enterprise cloud practices.

---

## Alternatives Considered

### Single AWS Account

Advantages:

- Simple to start.
- Fewer resources to manage.

Disadvantages:

- Weak isolation.
- Difficult permission management.
- Increased operational risk.
- Poor long-term scalability.

---

## Consequences

### Positive

- Platform designed for growth.
- Better governance.
- Easier automation.
- Enterprise-ready architecture.

### Negative

- More Terraform configuration.
- More IAM planning.
- More operational overhead during development.

---

## Review

This decision should be reviewed if the platform requirements change significantly.
