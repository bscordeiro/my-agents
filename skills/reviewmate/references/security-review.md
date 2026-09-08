# Security Review

Load for a security-sensitive change or explicit security review. This reference
owns the targeted threat-model pass; general review remains with
`code-review-and-quality`. Apply only relevant boundaries and explain exclusions.

## Threat model

Record the candidate and scope, assets at risk, actors and privileges, entry points,
trust transitions, deployment assumptions, and systems outside authorization.
Include credentials, personal/tenant data, code execution, integrity, availability,
and billing where applicable. Missing deployment facts that materially change the
verdict remain unknowns, not convenient assumptions.

Inspect execution surfaces statically before running tools. For external,
suspicious, or unresolved-provenance code, use `pr-audit` first. Never expose host
credentials or test third-party/production systems without explicit scope.

## Trace boundaries end to end

Follow input through normalization, validation, authorization, side effects,
persistence, output/logging, and cleanup. Trace each privileged sink back through
all affected callers; naming a middleware or sanitizer is not evidence that every
route passes through it. Verify failure is closed.

Check applicable boundaries:

1. **Authentication/session:** issuer/audience, expiry, revocation, replay,
   credential storage, and session lifecycle.
2. **Authorization:** object ownership, role/capability checks, deny defaults,
   mass assignment, and check/use races.
3. **Tenant isolation:** scope in storage, caches, search, exports, background
   work, logs, and inference through counts or errors.
4. **Injection:** query, shell/argv, templates, paths/symlinks, deserialization,
   archives, prompts/tools, and rendering contexts where sinks exist.
5. **Secrets/privacy:** collection and retention, redaction, telemetry, error
   paths, backups, process arguments, and deletion.
6. **Execution/extensions:** plugins, hooks, subprocesses, dynamic loading,
   environment inheritance, permissions, and isolation.
7. **Persistence/integrity:** atomicity, transactions, migrations, rollback,
   concurrency, path ownership, backup/restore, and cleanup after partial failure.
8. **Network/web:** SSRF including resolution/redirects, TLS, proxy trust,
   CORS/CSRF, webhook validation/replay, and request/body/time limits.
9. **Cryptography/randomness:** established primitives, secure randomness,
   key/nonce lifecycle, signature validation, and fallback behavior.
10. **Availability:** bounded work, allocation, queues, disk, recursion,
    decompression, retries, cancellation, and resource exhaustion.
11. **Supply chain/CI/release:** dependency provenance, lockfile drift, lifecycle
    scripts, workflow permissions, untrusted inputs with secrets, artifact identity.
12. **Malicious behavior:** covert networking, credential discovery, obfuscation,
    conditional bypasses, persistence, destructive behavior, or deceptive tests.

## Evidence

Use configured scanners only after inspecting their execution path. Read their
configuration, exclusions, baseline, and actual invocation; a green badge does
not prove coverage. Do not install scanners automatically. An unavailable scanner
is not a passing scan; name the resulting coverage limit.

After the static gate, use isolated synthetic data and inert canaries. Select
negative cases from the threat model: wrong-role/tenant, missing identity,
malformed or oversized input, encoding/path variants, replay, concurrency,
cancellation, and partial failure. Include a legitimate control case so blanket
denial is not mistaken for correct authorization. For fixes, require regression
evidence before/after when feasible. In read-only reviews, tests may live only in
disposable authorized artifacts, not source or snapshots.

## Findings and completion

A finding needs severity and confidence, asset/boundary, attacker prerequisites,
realistic failure or exploit path, exact evidence, impact, minimal remediation,
and verification. Separate substantiated vulnerabilities from hardening advice.
Never print, probe, or reproduce secrets in evidence; report sanitized metadata.
Keep sensitive findings private; publishing advisories/issues needs authorization.

Report boundaries checked with their evidence, exclusions, environmental gaps,
and residual risk. No findings means no substantiated findings in this scope,
not that the system is secure. Return results to Reviewmate for consolidation;
do not fix, publish, or start a second full general review here.
