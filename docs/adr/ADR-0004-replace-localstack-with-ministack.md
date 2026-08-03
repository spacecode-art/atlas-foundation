# ADR-0004: Replace LocalStack with MiniStack for Local AWS Emulation

## Status
Accepted

## Date
2026-08-03

## Context
LocalStack discontinued free-tier persistence, requiring a Pro
subscription and API key (see ADR-0003). This made local development
workflow-breaking on the free tier: every session required
re-bootstrapping from scratch.

MiniStack (ministackorg/ministack) is a free, MIT-licensed,
drop-in-compatible alternative that supports genuine persistence on
the free tier.

## Decision
Atlas Foundation will use MiniStack instead of LocalStack for local
AWS emulation, run with explicit persistence configuration:

```bash
docker run -d --name ministack -p 4566:4566 \
  -e PERSIST_STATE=1 \
  -e S3_PERSIST=1 \
  -e STATE_DIR=/data/ministack-state \
  -e S3_DATA_DIR=/data/s3 \
  -v ~/ministack-data:/data \
  ministackorg/ministack
```

Note: persistence is opt-in via two separate flags (`PERSIST_STATE`
for general state, `S3_PERSIST` specifically for S3) — both default
to `0` in the image.

## Rationale
- Free, MIT licensed, no auth token or account required
- Verified persistence across container stop/start (bucket and table
  timestamps identical before/after restart)
- Drop-in compatible: same port, same endpoint pattern, same
  path-style S3 requirement as LocalStack

## Alternatives Considered
LocalStack free tier — rejected, persistence requires paid Pro tier
(ADR-0003).

## Consequences
### Positive
- No re-bootstrapping required each session
- $0 cost maintained

### Negative
- MiniStack is a young project (emerged 2026); less community
  track record than LocalStack
- Requires explicit persist flags + volume mount; easy to omit and
  silently get ephemeral behavior instead (happened during initial
  testing — see git history)

## Review
Revisit if MiniStack's service coverage proves insufficient for
later phases (e.g. Organizations, IAM Identity Center).
