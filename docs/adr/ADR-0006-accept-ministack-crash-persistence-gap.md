## Update (2026-08-11)

Re-tested via three independent stop/start cycles while recording the
Phase 1 demo video, including one with an extended 30-second `docker
stop` grace period. All three reproduced the same result: the native
S3 lockfile object (used by Terraform's `use_lockfile` locking,
ADR-0012) does not survive a *graceful* `docker stop`/`start`, not
just an abrupt crash as originally scoped by this ADR. The extended
grace period made no observable difference, ruling out an
insufficient-flush-time explanation.

Checked `docker exec ministack ps aux` — PID 1 is `python -m
ministack` directly, not a shell wrapper, ruling out a signal-
forwarding issue at the container level. The more likely explanation:
MiniStack's documented flush-on-shutdown behavior depends on an ASGI
`lifespan.shutdown` event, which is normally triggered by the ASGI
server catching `SIGTERM` and running a graceful sequence. Python's
default handling of `SIGTERM` (unlike `SIGINT`) is immediate process
termination unless the application explicitly intercepts it — if
MiniStack's entrypoint doesn't register that handler in a path that
reaches `lifespan.shutdown`, `docker stop` would kill the process
before any flush runs, independent of grace period length. Not
verified against MiniStack's source; stated here as the best-supported
explanation, not a confirmed root cause.

This narrows the original gap from "abrupt crashes only" to "any
container restart, graceful or not, for at least the state lock
object." The Demo Video (see README) does not attempt to demonstrate
MiniStack restart persistence live as a result; it demonstrates the
pipeline and a stable `terraform plan` instead.