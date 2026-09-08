---
name: refactoring
description: >
  Refactor under green tests as a discipline separate from implementing. Use when a
  code smell surfaces (duplication, long method, shallow module, feature envy), a file
  ballooned in a single session, or you hesitate to touch code for fear of breaking it.
  Reached by xpmate once a test is green and structure needs cleaning.
---

# Refactoring

Refactoring is a **separate mode** from implementing: behaviour stays identical, only
structure improves. Never blend the two in one step — get behaviour right under a
failing-then-green test, *then* switch to refactoring with the tests already green.

## Precondition — green before you touch

Refactor only with the relevant tests passing. Green checks provide evidence that
behaviour is preserved. If covering tests are red, use `systematic-debugging` to diagnose
and restore the expected behavior first. If covering tests are absent, use `legacy-rescue`
to characterize existing behavior before restructuring.

## When to refactor — triggers

Switch into refactoring mode when any of these appear:

- A file grew 2–3× in a single session.
- Code was duplicated that already exists elsewhere.
- You hesitate to touch a file because you don't know what will break.
- A smell from the catalog surfaces (below).

## Smell → move catalog

Choose the smallest move that addresses the observed smell: duplication → extract,
long method → helpers, shallow module → deepen, feature envy → move logic to the data,
primitive obsession → value object. For seam and deep-vs-shallow decisions, use the
`codebase-design` vocabulary. Avoid adding an abstraction without a concrete need.

## Discipline

- One structural move at a time, named for the move: "Extract X", "DRY Y", "Simplify Z interface". Commit boundaries apply only when Git is in use and commits are authorized.
- Re-run the tests after each move. Green stays green, or you revert — never weaken a
  test to fit a refactor.

## Tidy first, after, or never — the timing decision

A refactor is a **structural** change: it preserves behaviour. Keep substantial structural
and behavioural changes in separate steps and, when authorized, separate commits
(Beck, *Tidy First?*). Small local cleanups may accompany the change under green tests when
project rules allow; refactoring never requires creating a repository or publishing work.

Decide *when* to tidy by the next behavioural change you are about to make:

- **First** — the tidying makes the imminent change easier to write, and is small. Do it now
  as a separate structural step, then make the behavioral change.
- **After** — you only saw the better structure once the change was working. Tidy now, while the
  understanding is fresh and the tests are green.
- **Never** — you will not touch this code again soon. Leave it; tidying it buys nothing.

Tidyings are small by definition — a guard clause, dead code removed, an explaining variable, a
normalized symmetry, reading order. Reach for the smell→move catalog for larger structural moves;
reach for a tidying when the change is this small and local.

## When to stop

Stop when the trigger that prompted the refactor is gone — not when the code is
"perfect". Avoid emergency surgery: many small continuous refactors beat one large
deferred rewrite, because risk scales with the size of the change.
