# Integration Review

Load when multiple changes are composed into one candidate, before integration
approval or when explicitly reviewing an already-integrated tree. Do not merge
changes merely to enable this pass. Use the available authorized candidate; if
it does not exist, state that composition remains unverified.

## Scope the composition

Identify the exact integrated candidate and contributing changes. Individual
PR verdicts are context, not proof of the resulting tree. A new head or dirty edit
invalidates evidence for affected surfaces. If provenance is unresolved or any
contribution is external/suspicious, complete `pr-audit` before execution.

Map interactions rather than reviewing each diff again:

- Producer/consumer contracts, defaults, schemas, configuration, and callers.
- Combined authorization, tenant scope, validation, and privileged sinks.
- Initialization/teardown, migrations, concurrent work, retries, and rollback.
- Dependencies, lockfile resolution, generated artifacts, CI and packaging.
- Public compatibility and documentation affected by the combined behavior.

Two individually acceptable changes can produce a bypass or regression together.
Choose evidence at those interaction points and delegate sensitive interactions
to the security pass without duplicating its investigation.

## Verify the actual tree

Run applicable trusted checks on the final integrated candidate and inspect their
results. Do not equate green contributor heads with a green integration. Required
platform or release matrices still apply; unavailable platforms stay explicit
limitations. Use `verification-before-completion`, not historical gate reuse.

Inspect conflict markers (including diff3), dropped or duplicated logic, stale
imports/configuration, and version/lockfile consistency. When changelogs are
required, check entry placement under the pending section and correct impact
category; unique headings alone do not catch entries stranded in released sections.

Report contributing changes, interaction evidence, final candidate identity,
checks/results, findings, and remaining platform or deployment gaps. Limit this
pass to composition hazards; it grants no merge, release, deploy, or CI-cancellation
authority. Return the result to Reviewmate's existing gate and review budget.
