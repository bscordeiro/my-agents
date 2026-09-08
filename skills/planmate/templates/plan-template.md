# Planmate Handoff: [objective]

## Stage

Current: shape

Map: **shape ●** → bound ○ → slice ○ → review ○

## Plan File

- Path: [requested document path / OpenSpec change / conversation-only]
- Save/update consent: [granted / pending / not needed]
- Version note: [new plan / update confirmed for same work item / conflict unresolved]

## Problem

[The current situation and why it matters. A situation, not a pre-baked solution.]

## Development Volume

- Deliveries: [Observable behaviors and deliveries included in the work.]
- Reach: [Affected flows and components.]
- Dependencies: [Integrations, migrations, and dependencies, or explicitly none.]
- Planning depth: [light / full — rationale based on volume, risk, and uncertainty. Refine the description as scope and slices become clear.]

## Solution

[Fat marker sketch: what the user does and sees, in broad strokes. No implementation detail.]

## Scope

### Includes

- [Behavior inside this slice of work.]

### Excludes

- [Behavior deliberately left out.]

## Rabbit Holes

- [Specific place the work could sink unboundedly] → [how to avoid it]

## No-gos

- [What is explicitly out of scope.]

## Context

[Domain facts, constraints, users, integrations, prior decisions an agent cannot infer.]

## Decisions

- [Resolved decision and rationale. Move items here from Open Questions when resolved.]

## Open Questions

- [Unresolved material decision. Format: `field: question`. Keep explicit until resolved, then move to Decisions. Reaching the question limit does not resolve it.]

## Assumptions

- [Non-blocking assumption recorded instead of asking a nice-to-have question.]

## Critical Files

- [path/to/file] — [why it matters]

## Security and Privacy

- Impact: [none expected / describe secrets, PII, auth, logging, retention, exposure risk]
- Constraints: [what implementation must not expose, log, persist, or trust]

## Slices

- [ ] 1. [Thin vertical slice that delivers observable value on its own]
  - Criteria: [1–3 observable conditions a test could assert]
  - Verify: [command or manual check establishing the criteria]
  - Evidence owner: [accountable workflow role; one owner per distinct claim]
  - Evidence limits: [material limitations and conditions for broader/alternative checks, or none established]
  - Verification support: [only if needed: missing control/observability, scope/authorization, temporary cleanup or durable ownership; omit when unnecessary]
- [ ] 2. [Next vertical slice]
  - Criteria: […]
  - Verify: […]
  - Evidence owner: […]
  - Evidence limits: […]

## Risks and Stop Conditions

- [Stop if...]

## Readiness Checklist

- [ ] Problem reads as a situation, not a solution
- [ ] Development Volume describes deliveries, reach, and dependencies; planning depth accounts for risk and uncertainty
- [ ] Solution is a fat marker, free of implementation detail
- [ ] Scope includes/excludes draw the boundary
- [ ] Rabbit holes have avoidances; no-gos listed (or explicitly none)
- [ ] Open Questions empty — decisions resolved; any reclassified Assumption is demonstrably non-blocking and reversible
- [ ] Nice-to-have uncertainties recorded as assumptions
- [ ] Slices independently shippable; each has acceptance criteria, credible verification, an evidence owner, and explicit material limitations
- [ ] Any verification support has scoped authorization and a temporary/durable lifecycle
- [ ] Security/privacy impact covered
- [ ] Stop conditions explicit
- [ ] A fresh session can implement using this handoff only

## Execution Instructions

- Ready for implementation only after Review passes and Open Questions is empty.
- The project's implementation workflow owns interfaces, tests, and the coding loop; this plan owns scope.
- Implementation owns the Slices checkboxes and new Decisions entries; every other field belongs to planning. Resume from the first unchecked slice.
- Stay inside Scope; use Development Volume to understand the planned deliveries and dependencies. Code reality invalidates the shape → stop, record the finding under Decisions, and return to planning — never patch this plan silently.
