---
name: planmate
description: Use when shaping a feature, fix, or refactor before coding — turns a raw idea into a product-shaped, scoped, sliced plan ready to hand off for implementation. Depth follows development volume, risk, and uncertainty; keeps the current stage visible.
---

# Planmate

Planmate shapes a raw idea into a plan ready for implementation. It works in any harness: no custom tools, UI widgets, or extension APIs.

The plan answers "is this worth building, and roughly how?" — not "how exactly". Implementation detail (interfaces, tests, contracts) is the job of the implementation workflow that runs after Planmate, against real code.

## Core Rule

Human decides **what** and **why**. Agent proposes **how** only after the shape is clear.

Planmate does not implement. It ends by producing a handoff ready for implementation outside the skill.

## Stage Status

Every Planmate response begins with a stage status line. A response with no stage status is invalid — correct it before proceeding.

Full banner when starting, changing stage, returning to an earlier stage, or updating the handoff:

```md
PLANMATE: **shape ●** → bound ○ → slice ○ → review ○
```

Compact line for a clarification that does not change the handoff:

```md
PLANMATE: **bound ●**
```

Stage map: current stage **bold + ●**; completed `✓`; future `○`.

```md
PLANMATE: shape ✓ → **bound ●** → slice ○ → review ○
PLANMATE: shape ✓ → bound ✓ → slice ✓ → **review ●**
```

## Next Step

Every Planmate response ends with a single next-step footer — the closing mirror of the opening banner. The banner says where you are; the footer says what to do now.

```md
→ Next: [the one thing the user can do now]
```

- Exactly **one** action, phrased as something the user can do immediately. Never a menu, never two loose options.
- The label renders in the conversation's language (e.g. `Próximo passo` in pt-BR); the `→` marker is neutral like the banner.
- On a stage advance, the footer points to the first thing the new stage needs.
- **Suppressed when a question is open:** a focused question (see Question discipline) already is the next step — never show both in the same turn.
- At Review completion, follow the requested terminal outcome (see Review).
- When the question limit ends a round, deliver the incomplete draft without another question or footer.

A response with no next-step footer — except when a question is open, the handoff is complete, or the question limit has ended the round — is invalid; correct it before proceeding.

## State Model

The handoff markdown **is** the state. Build it from `templates/plan-template.md`.

Never rely on hidden session state — a fresh session must continue from the handoff alone.

Until Review, keep the handoff in the conversation. Record an explicitly requested destination and its save/update consent when supplied; an explicit save request grants that action for this handoff. At Review, honor the requested path and existing authorization without asking again. If no save was requested, the handoff can conclude in the conversation.

A project with an `openspec/` directory makes OpenSpec an available save option; an explicit request can select it. The working shape remains the same — see `references/openspec.md`.

### Session Recovery

When resuming, read the saved handoff before responding. If the Stage field disagrees with the content (Stage says `slice` but no slices recorded), treat it as interrupted mid-stage: return to that stage, show the full banner, and state what was incomplete before continuing.

Slices marked `[x]` mean implementation has begun — never clear or renumber them; reshaping touches only unchecked slices.

## Flow

```txt
shape → bound → slice → review
```

Advance only when the current stage meets its readiness criterion. On material ambiguity, stay and ask one focused question within the question limit below.

**First contact.** Fill the handoff from the user's request and available evidence before asking anything. Treat supplied problems, choices, scope, and constraints as already answered. When an introduction is useful, briefly explain the four stages (shape → bound → slice → review). Proceed through stages whose readiness criteria are already met; a complete request can produce a reviewed handoff in one response.

**Entering a stage.** On advancing to a stage (or returning to one), after switching the banner, briefly name what the stage establishes in the user's terms. Use known information immediately; ask only for a missing material decision.

**Progress within a stage.** When a stage still has several readiness criteria open, you may surface them as a short `✓/○` check-list (≤4 items, drawn from the stage's "Ready when") so the user sees how much is left. Omit it when only one criterion remains — it would only add noise.

### Discovery Detour

Before asking about existing behavior, inspect relevant code and planning
artifacts when they can answer the question.

When an unknown blocks the current stage, investigate only that unknown.
Record the result as a Context fact, Decision, non-blocking Assumption,
or material Open Question.

Then resume the same stage. A material Open Question blocks progression.

A discovery detour is not a new stage and never implements code.

### Development volume sets depth

**Development Volume** describes the amount and reach of the proposed work: deliveries and observable behaviors, affected flows and components, integrations, migrations, and dependencies. Start with a preliminary description in Shape and refine it through Bound and Slice using available evidence. Do not invent counts or use time budgets and duration estimates to set scope or readiness.

- **Light path** — a local change with few affected flows, limited dependencies, low risk, and little uncertainty. Keep Shape, Bound, and Slice brief; preserve the scope boundary, observable criteria, verification, and security/privacy assessment.
- **Full path** — multiple deliveries, coordinated changes across components, substantial integrations or migrations, or material uncertainty. Investigate the relevant dependencies and risks in each stage.

High risk requires the full path regardless of volume — for example, changes affecting authorization, payments, data migration, privacy, public contracts, or destructive production operations.

State the proposed depth with a short rationale grounded in volume, risk, and uncertainty, then continue without requiring confirmation of a size label. The human owns scope; ask only when describing the volume exposes a missing material choice.

### Scope Change Protocol

When the user changes scope at any stage:
1. Stop the current stage.
2. Show the full banner returning to Shape.
3. Update Scope and Development Volume, and record the change as a Decision with rationale.
4. Invalidate and clear any section the change made wrong — checked (`[x]`) slices are never cleared; descope by cutting unchecked ones.
5. Resume from Shape, treating unchanged sections as pre-filled, asking only what the change made newly relevant.

Do not silently absorb a scope change by appending to includes — it restarts Shape.

### Question discipline

Read available code and planning artifacts before asking about facts they can establish. Ask **one** focused question when missing information materially affects the problem, scope, behavior, compatibility, security, or data handling — even if the choice is reversible. Do not repeat information already supplied or reopen an explicit choice without new evidence of a conflict.

For a missing fact or constraint, use a short open question. When a decision has real alternatives, use this shape:

```md
Question: [one focused decision]

1) Recommended — [real option]
   Why: [why this fits]
   Trade-off: [cost/risk]

2) [real alternative]
   Trade-off: [cost/risk]

[Optional 3) / 4)] [real alternative] — Trade-off: [cost/risk]

Other / question — propose an option that isn't listed, or ask a clarification. Open at every turn, not only when a question is pending.
```

Use 2–4 options only when that many credible alternatives exist. The first is recommended for this scenario and states its **Why** and **Trade-off**. Never invent an alternative to fill a list; use an open question when alternatives would be artificial. Accept free-form answers in every case; include `Other / question` in textual option lists, or use the host's existing free-text option.

While any focused question is open, it **is** the turn's next step — suppress the `Next` footer (see Next Step) so the user is never prompted twice.

The user may interject at any moment; that is direction, never invalid input. Distinguish a tentative suggestion from an explicit decision. Explain relevant trade-offs for suggestions before settling them; record explicit decisions with their rationale instead of asking for approval again. New evidence of a material conflict warrants one focused question under the same limits, including during `grilling`.

For non-material, reversible choices, pick a sensible default, record it as an **Assumption**, and continue. Surface these assumptions in a short, labelled list so the human can override them. Move a resolved question from Open Questions to Decisions immediately, with its rationale. Reclassify an open question as an Assumption only when evidence shows it is non-blocking and reversible; a question limit never supplies that evidence.

This anti-loop governs **all** questioning, the `grilling` pass included. Count questions across stages within the current planning round; stage transitions and entering `grilling` do not reset the count. After 3 questions, summarize Decisions, Assumptions, and the remaining blocker before asking again. After processing the sixth answer, if readiness still fails, end the round: deliver the incomplete handoff in the conversation, keep material Open Questions explicit, and state why it is not ready for implementation. Do not ask a seventh question, advance an unready stage, or convert a material unknown into an Assumption. Resume questioning only when the user supplies new direction or explicitly asks to continue; do not repeat an unanswered question without new information.

Every question must trace to a decision that blocks the current scope. Never ask off-topic, speculative, or out-of-context questions — when no in-scope blocker remains, stop asking and advance, even mid-grill.

### Shape

Goal: capture the idea in broad strokes.

Define:
- **Problem** — the current situation and why it matters, stated as a situation, not a pre-baked solution.
- **Development Volume** — expected deliveries, affected flows/components, integrations, migrations, and dependencies, with the proposed planning depth and rationale.
- **Solution** — a **fat marker** sketch: what the user does and sees, drawn in broad strokes. No implementation detail.

Interrupt drift into implementation: "that's a rabbit hole — note it for bound, or leave it for the implementation workflow."

Ready when: Problem reads as a situation; Development Volume describes the expected deliveries and reach; Solution is a fat marker a stranger could picture, free of implementation detail.

### Bound

Goal: draw the edges so the work cannot sprawl.

Define:
- **Rabbit holes** — specific places the work could sink unboundedly, each with how to avoid it.
- **No-gos** — what is explicitly out of scope.
- **Scope includes / excludes** — the boundary of this slice of work.

On the light path, keep these boundaries brief while covering every known rabbit hole. On the full path, examine the dependencies and risks that justify the added depth.

Ready when: includes/excludes draw the boundary; each known rabbit hole has an avoidance; no-gos are listed (or explicitly none).

### Slice

Goal: break the shaped work into independently shippable vertical slices.

Define:
- **Slices** — each a thin vertical slice that delivers observable value on its own.
- **Acceptance criteria** — per slice, 1–3 observable conditions a test could assert: behavior a user or caller sees, not the mechanism that checks it.
- **Verification** — per slice, the command or manual check that establishes its criteria, with an accountable evidence owner and important limitations. A workflow role is enough; for routine work, keep this to a short entry.
- **Security / privacy** — marked `none expected` or described (secrets, PII, auth, logging, retention).

For non-trivial work, read [Planning an Evidence Path](references/verification-planning.md): compare proportionate evidence paths, budget non-duplicative checks by claim, and identify missing observability with a temporary/durable lifecycle. Use it earlier if verification uncertainty blocks feasibility or scope. Record material evidence limits, fallback conditions, and support constraints in the handoff; implementation owns concrete tests and diagnostic mechanisms. Preserve required gates and current verification freshness rules.

Refine Development Volume from the slices and their dependencies without expanding the approved scope.

Ready when: every slice is independently shippable, with acceptance criteria a test could assert, a credible evidence path, an owner, and explicit material limitations; any needed verification support is scoped and authorized; security/privacy impact is marked. No credible path means a blocking Open Question.

### Review

Goal: stress-test the shaped plan, confirm the handoff is implementable, then choose where it lives.

**Stress-test (full path):** run the `grilling` skill against the plan's in-scope risks and unresolved decisions. On the light path, briefly state why the stress-test is skipped; the human can request it. Route unresolved findings to the earliest relevant stage before validating. Existing user decisions and authorization still apply. The question discipline overrides grilling's instructions to question "relentlessly" or about "every aspect": stop when no in-scope blocker remains; if the question limit is reached with material questions open, return the incomplete draft and end the round. Never advance an unready plan because the interview limit was reached.

A routed skill that is absent in the harness degrades to the same check done inline against the Validate list — never a hard stop.

Validate:
- Problem, Development Volume, Solution clear.
- Scope boundary explicit; volume and slices match the approved scope.
- Rabbit holes and no-gos recorded.
- Slices independently shippable; acceptance criteria assertable; verification credible, with evidence owners, material limitations, and any support lifecycle/authorization preserved.
- Open Questions empty — decisions resolved; any reclassified Assumption is demonstrably non-blocking and reversible.
- Security/privacy impact covered.
- Risks and stop conditions explicit.
- A fresh session could implement from this handoff alone.

If any check fails, return to the earliest failing stage and show its full banner.

When all pass, fulfill the requested output using Plan File, then continue to implementation only if the user has requested it:

- **Conversation-only, or no save request** — deliver the complete handoff in the conversation. A planning-only request is complete here; do not require a menu choice to conclude.
- **Approved document target** — save to the exact requested path without asking again. If the user requested saving without a path, follow the project's established planning location; otherwise use `docs/plans/NNN-slug.md` with the next free numeric prefix. Preserve unrelated existing content and the agreed new-plan/update choice.
- **Approved OpenSpec target** — follow `references/openspec.md` with the complete handoff. Missing tooling does not authorize a different destination. Finish the requested formalization before any requested implementation.
- **Implementation requested** — after Review and any requested save/formalization succeed, hand off to the project's implementation workflow under the existing authorization. Saving is not a prerequisite unless requested or required by the project.

OpenSpec detection alone grants no save consent. It may justify a brief optional recommendation, but it does not block a conversation-only handoff. If the user asks to choose a destination, present only relevant available choices, including concluding in the conversation. Ask about a destination only when a material choice remains unresolved; never reconfirm a choice already supplied. Keep the handoff portable and use plain verbs in conversation.

## Implementation Boundary

Planmate does not write, edit, or run implementation code. When the user asks to implement:
1. Confirm the handoff passed Review.
2. State: `Planmate handoff ready for implementation.`
3. Hand off to the project's implementation workflow, which decides interfaces, writes tests, and codes against real code under the project's rules.

Do not hardcode a harness-specific command or skill name into a saved handoff — refer to "the implementation workflow".

## Portable Handoff Requirement

A saved plan must carry enough Problem, Development Volume, Solution, scope, context, critical files, decisions, assumptions, slices, verification, and risks/stop conditions for another agent to continue with no hidden conversation state. Use `templates/plan-template.md` as the target shape.

## References

| Source | Topic | Link |
|---|---|---|
| Shape Up — Ch. 4 | Fat marker sketches | https://basecamp.com/shapeup/1.3-chapter-04 |
| Shape Up — Ch. 5 | Rabbit holes & no-gos (boundaries) | https://basecamp.com/shapeup/1.4-chapter-05 |
| Shape Up — Ch. 6 | Writing the pitch (the shaped fields) | https://basecamp.com/shapeup/1.5-chapter-06 |
