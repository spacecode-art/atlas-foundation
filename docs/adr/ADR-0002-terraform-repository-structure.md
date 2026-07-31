# ADR-0002: Adopt a Layered Terraform Repository Structure

## Status

Accepted

## Date

2026-07-31

---

## Context

Atlas Foundation is intended to support a multi-account AWS platform with reusable infrastructure components and multiple deployment environments.

A flat Terraform repository becomes difficult to maintain as the number of resources, environments, and engineers increases.

The repository therefore requires a structure that separates reusable logic from environment-specific deployments and bootstrap infrastructure.

---

## Decision

The Terraform repository will be organized into three layers:

```text
terraform/
├── bootstrap/
├── modules/
└── environments/
```

### Bootstrap

Contains the infrastructure required for Terraform itself.

Examples:

- Remote state backend
- State locking
- Provider configuration
- Initial platform setup

---

### Modules

Contains reusable infrastructure components.

Examples:

- Networking
- IAM
- Security
- Organizations

Modules should not contain environment-specific values.

---

### Environments

Contains deployments for each AWS account or environment.

Examples:

- management
- security
- shared
- development
- staging
- production

Environment configurations compose reusable modules with environment-specific variables.

---

## Rationale

This structure provides:

- Clear separation of concerns
- High module reusability
- Easier maintenance
- Better testing
- Support for multi-account deployments
- Scalability as Atlas grows

---

## Alternatives Considered

### Flat Repository

Example:

```text
main.tf
variables.tf
outputs.tf
```

Advantages:

- Simple for small projects

Disadvantages:

- Difficult to scale
- Poor organization
- Low module reuse
- Increased maintenance cost

---

## Consequences

### Positive

- Easier collaboration
- Consistent repository layout
- Reusable infrastructure components
- Clear ownership boundaries

### Negative

- More directories
- Slightly steeper learning curve
- Additional planning required before implementation

---

## Review

This decision should be revisited if Atlas significantly changes its deployment model or cloud strategy.
