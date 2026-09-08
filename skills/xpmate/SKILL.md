---
name: xpmate
description: >
  Extreme Programming implementation loop. Use when implementing an approved plan
  or specification, applying an OpenSpec change, fixing a bug, or bootstrapping
  a project for development.
---

# XPMate

The human owns what and why; the agent owns how within that authorization.
Apply `karpathy-guidelines`: surgical changes, explicit assumptions, simple design,
and verifiable outcomes. User and project rules govern this workflow and its specialists.

XP in practice: communicate decisions, work in small increments, seek rapid feedback,
refactor with confidence under green tests, and respect the human's priorities.

## Intake and recovery

- **OpenSpec Apply:** resolve the selected change and read its active schema, Apply
  instructions, required artifacts, and progress. Confirm readiness before editing.
  Those artifacts own scope and task state; update only fields the workflow permits.
  Do not create a competing plan or hard-code artifact names. Propose and archive
  are separate operations, not implementation prerequisites beyond Apply readiness.
- **Other plan/spec:** read its execution instructions, criteria, constraints,
  decisions, and verification. Preserve the approved order and completed work.
  Planning owns scope; implementation records progress and findings, not silent replanning.
- **Standalone:** derive a small increment and observable criteria from the request
  and code. Use an existing authorized progress record; a conversation handoff is
  sufficient when no durable destination was requested.

Resume from recorded unfinished work, reconciling it with current files and evidence.
Keep criteria, completed work, outstanding checks, and next action recoverable in that
record. If state is missing, explicitly reconstruct context and ask only for missing
material facts; an unchanged directory cannot prove which steps happened.

Git and CI are optional infrastructure, not requirements for local implementation.
Commit, push, merge, release, and archive require authorization covering those actions;
existing authorization persists. Read [bootstrap.md](bootstrap.md) only for a new project
or missing prerequisites that block the requested work.

## One cycle per increment

### 1. Read and select

Read affected code, conventions, and relevant guidance. Inspect existing solutions.
Before any baseline/build/install/test execution, use `pr-audit` for its static
trust gate and safe execution requirements if the candidate is external, suspicious,
of unresolved provenance, or changes execution machinery (build/test runners, hooks,
CI, or installation). This applies to trusted local machinery changes too, not to
every ordinary application-code or test-case edit. Reapply the prerequisite before
execution when edits change that surface, including during RED/GREEN and refactoring.
Missing isolation blocks dynamic work; a worktree alone is not a sandbox.
Then run applicable safe baseline checks before changing behavior; distinguish
existing failures from new regressions. Take the next authorized task and its
smallest coherent behavior slice, preserving dependencies and scope. State its
criteria and verification briefly; reuse the plan rather than interview the human again.

**Done:** the change point, criteria, and credible verification are identified from evidence.

### 2. Establish the verification baseline

Follow the plan's evidence path, owners, limitations, and support lifecycle. Resolve
technical details against actual project capabilities; if the path cannot establish
a material claim within scope, return that blocker to planning. Build verification
support only within authorization, clean up temporary support, and preserve required
gates and verification freshness.

For bugs or unexpected failures, diagnose first. Protect untested existing behavior with
characterization where needed, then use TDD for new or changed behavior, including fixes.
One behavioral test at a time: its expected result comes from a requirement, public
contract, domain example, fixture, or reproduced bug, not the implementation algorithm.
Run it and observe failure for the expected behavioral reason before writing the fix.
Setup/import failures require diagnosis, not permission to skip RED.

For behavior-preserving refactoring, establish a green baseline, characterizing untested
code if needed; do not manufacture RED for unchanged behavior. For prose-only skills or
documentation, use structural/semantic review instead of automated tests. These verification
choices also govern delegated specialists and the remaining steps.

**Done:** changed behavior has credible RED, pure refactoring has GREEN, or prose has explicit review criteria.

### 3. Make GREEN, then simplify

Implement only what the current criterion requires. Prefer the simplest evidenced design:
passes tests, reveals intent, avoids duplication, then uses fewer elements. Every added
mechanism must justify itself by the requested behavior or an existing contract.
Use a disposable spike only to resolve a concrete uncertainty; capture its finding and
remove the spike before delivery.

For executable code, refactor after relevant tests are green, only where a concrete smell
warrants it; preserve behavior and rerun tests after each move. For prose, evaluate the edit
against its review criteria. Structural cleanup is a separate step, not scope expansion.

**Done:** the criterion is satisfied by the selected verification, with existing contracts preserved.

### 4. Review and verify

Route the review through `reviewmate`, which uses `code-review-and-quality` unchanged
and selects adversarial, security, or composition passes only when applicable.
Share the candidate, criteria, and evidence; avoid duplicate review passes. Reviewmate
owns findings and re-review budgets, while this workflow owns authorized fixes.

Run relevant regression, build, lint, and security checks available for this project.
Observe each criterion at an appropriate boundary: automated integration or
end-to-end tests can be real execution; manual verification is required only when it
provides missing evidence. Follow configured CI gates when applicable; absent or inaccessible
CI is a reported limitation, never a claimed pass.

Apply [security.md](security.md) when touching external input, authentication/authorization,
sensitive data, file access, outbound requests, or a plan-marked security/privacy risk.
Fix in-scope defects and rerun affected checks. Never delete, skip, or weaken a failing test
to fit the implementation; diagnose code, oracle, and harness separately. An approved
requirement change can justify updating its test, not a convenient green result.

**Done:** criteria have observed evidence, review findings are addressed, and required checks
pass. A blocked required check leaves the increment unverified, with the limitation explicit.

### 5. Record and continue

Update necessary documentation and durable decisions or hurdles in their established
location, updating equivalent entries instead of duplicating them. Then record verification
and mark a task complete only after all its obligations are satisfied. On interruption,
leave unfinished obligations visible; preserve completed history and record follow-up work
when new evidence or an authorized adjustment changes it.

Report the delivered behavior, checks and results, remaining limitations, and next unfinished
work. Continue authorized increments; integration/release or archive happens only when requested.

**Done:** documentation and progress agree with verified work; the requested delivery is complete
or its exact blocker is reported. Local delivery does not require publication.

## Routing

Load specialists only when their trigger applies. Diagnosis precedes a fix; characterization
protects existing behavior; TDD changes behavior; refactoring preserves it. Return to this
cycle after the specialist's bounded work.

| Trigger | Skill |
|---|---|
| Bug, test/build failure, flaky or unexpected behavior | `systematic-debugging` |
| Existing behavior lacks protection before a change | `legacy-rescue` |
| New or changed executable behavior, including bug fixes | `tdd` |
| A test needs a double | `test-doubles` |
| Module coupling or an interface/design decision | `codebase-design` |
| Concrete structural smell with relevant tests green | `refactoring` |
| An unresolved in-scope plan/design risk needs challenge | `grilling` |
| Produced changes need review | `reviewmate` |
| About to claim completion or passing checks | `verification-before-completion` |

A missing specialist is reported; perform its essential check inline when credible.
Missing tooling blocks only dependent work. Neither fallback nor a specialist can weaken
scope, authorization, test integrity, or completion gates.

## Decisions and delegation

Stop for an unresolved material decision: conflicting criteria, scope or contract changes,
new sensitive risk, insufficient authorization, or no credible verification path. Ask one
focused question and wait. Approved sensitive work does not require repeated approval.
Correct non-material reversible assumptions and continue; if evidence invalidates the
plan's scope, record the finding and return to planning rather than silently reshape it.

Routine failures call for diagnosis and an evidence-backed correction within scope.
`systematic-debugging` owns the bounded retry/escalation policy; infrastructure failure is
not evidence of faulty architecture or permission to change execution protocols.

Delegate one bounded subtask for coupled reasoning, architectural trade-offs, high risk,
or unclear root cause; size alone is not a trigger. Verify available agents/models rather
than assume inheritance or a stronger tier. Give scope, constraints, evidence, and expected
output; keep one writer per workspace and no worker-initiated helpers. The primary agent
integrates and independently verifies results. Use files for large reports, not mandatory
briefs for every small task.

## Basis

Adapted for human-agent implementation from [Extreme Programming Explained](https://www.informit.com/articles/article.aspx?p=367636)
and [Beck's simple-design rules](https://martinfowler.com/bliki/BeckDesignRules.html).
