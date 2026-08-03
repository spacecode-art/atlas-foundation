# ADR-0003: Accept Ephemeral LocalStack State

## Status
Superseded by ADR-0004

## Date
2026-08-03

## Context
LocalStack's persistence mechanism requires a Pro subscription and a
valid LOCALSTACK_API_KEY. This project ran on the free/community tier,
where persistence is unavailable regardless of configuration flags.

## Decision
Atlas Foundation initially treated all LocalStack state as ephemeral.
Every LocalStack session required bootstrap to be re-applied before any
downstream work. No workaround for persistence was pursued on the free
tier.

## Rationale
- Free tier has no persistence option; chasing it is not solvable
- Ephemeral state is acceptable for design/validation work (per the
  zero-cost plan's "Designed & Validated vs Live Demo" split)
- Forces the habit of drift-checking before work, which is good
  practice regardless of tooling

## Consequences
### Positive
- No time lost chasing an unavailable feature
- Reinforces the "verify before trusting" habit already in place

### Negative
- Every session start required a re-bootstrap step
- Cannot leave long-running demo state between sessions without a
  burst-deploy-and-screenshot approach

## Review
Superseded by ADR-0004, which replaces LocalStack with MiniStack —
a tool that supports genuine free-tier persistence, removing the
constraint this ADR was written to accept.
