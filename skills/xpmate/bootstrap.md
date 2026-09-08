# Bootstrap

Read only when starting a project or when missing prerequisites block an authorized
increment. Prepare the smallest environment that can exercise that work, then return
to [XPMate](SKILL.md). Git, remote CI, and deployment are not universal prerequisites.

## New project

1. Inspect the requested stack, available tools, and directory before creating anything.
2. Add only the structure, dependencies, and local checks needed for the first increment.
   For executable behavior, establish a way to run its tests; for prose-only work,
   structural and semantic review can be sufficient.
3. Create project guidance only when needed and authorized. Record known facts: purpose,
   stack, check commands, and non-obvious constraints. Environment variable names only;
   never secrets or invented placeholders. Follow existing guidance conventions.
4. Initialize Git or configure CI only when requested or required by the approved project
   setup. Commits and external writes still need authorization covering those actions.

## Existing project or repeated setup

Preserve code, user changes, established patterns, and useful documentation. Check that
existing artifacts work rather than assuming their presence proves readiness. Repair only
prerequisites needed for the approved increment; unrelated infrastructure improvements
remain separate proposals. Never require an existing project to contain no business logic
or rewrite its first commit.

Use the project's local test/build/check commands when CI is absent. Existing CI gates
remain binding for deliveries that require them; do not bypass a failure or report an
unavailable check as passed. A broken harness calls for diagnosis; an unresolved required
check blocks the dependent work, not unrelated authorized work.

**Done:** the first increment has a credible verification path, current baseline results
and limitations are known, and any necessary setup guidance is recorded. No separate
initial commit, remote pipeline, or release is needed to finish bootstrap.
