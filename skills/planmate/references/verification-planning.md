# Planning an Evidence Path

Use during Slice for non-trivial changes, or earlier when uncertainty about
verification threatens feasibility or scope. Keep planning at the level of claims,
evidence, constraints, and cost. The implementation workflow owns concrete tests,
interfaces, diagnostic code, and execution against the actual system.

## Frame each material claim

State what observable behavior must become true, what must remain true, and the
conditions or failure modes that could invalidate the conclusion. Include affected
boundaries and important negative cases, not only a happy-path demonstration.
Acceptance criteria remain observable outcomes, not implementation mechanisms.

## Choose a credible evidence path

Inspect available inputs, observable effects, state transitions, invariants, and
project checks. For material uncertainty, compare a stronger or cheaper alternative
before choosing a proportionate path. Record the preferred command or manual check,
what it establishes, what it cannot establish, and when an alternative is needed.
For a routine slice with an obvious established check, a short Verify entry suffices.

If capabilities are unfamiliar, research the exact framework/dependency facilities
from project evidence or primary documentation. Do not invent commands or promise
observability the system does not have. A missing credible evidence path is a
material Open Question that blocks readiness, not an implementation surprise.

## Budget evidence, not quality

Give each distinct claim one accountable owner (a workflow role is enough) and the
minimum non-duplicative evidence covering its important boundaries. Share supporting
evidence across related criteria instead of planning identical expensive passes.
Name conditions that require broader verification. Do not use arbitrary time/token
budgets to reduce scope or waive required repository, security, or release checks.

Planning does not relax `verification-before-completion`. Prior evidence may inform
the path; freshness obligations still govern the implementation's final claims.

## Identify missing observability without designing a feature

If a claim cannot be established directly, identify the smallest needed ability to
control, observe, repeat, reset, or diagnose the relevant state. State its purpose,
constraints, and whether support should be temporary or durable; leave the mechanism
to implementation. Temporary support needs cleanup; durable support needs an owner.

A new dependency, persistent diagnostic surface, sensitive data access, or structural
change solely for verification must be inside explicit authorization. Otherwise
raise the material scope decision before treating that path as ready. Do not invent
product behavior to make evidence easier to gather.

## Carry the result

Keep the evidence path in the slice's Verify, Evidence owner, and Evidence limits
fields. Record any needed support and lifecycle under Verification support; omit
optional detail when unnecessary. Preserve material limitations and stop conditions
when saving or mapping the handoff to another schema.

At handoff, another agent must know the claim, credible evidence, important limits,
responsibility, and any support constraint without having to redesign product scope.
Implementation follows the path and reports each claim as established, limited, or
refuted; evidence gaps never become an implicit pass.

## Basis

Adapted from [akitaonrails/my-skills/verification-planning](https://github.com/akitaonrails/my-skills/blob/02a957219f1a607844ef6a0afd0fef6f48d78fa2/verification-planning/SKILL.md).
The local adaptation preserves Planmate's planning-only boundary and current
verification freshness policy.
