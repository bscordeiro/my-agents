---
name: legacy-rescue
description: >
  Get untested code under test before changing it. Use when the code you must
  modify has no covering tests or refactoring needs characterization first.
  Pins current behaviour with a characterization test, finds a seam, breaks the minimum
  dependency to test — then hands off to refactoring (now green) or tdd (for new behaviour).
---

# Legacy Rescue

Legacy code is code without tests. To change it safely it must be under test — but to put it
under test you often must change it first. This is the **legacy dilemma**, and this skill is the
safe way through it.

This skill ends where `refactoring` and `tdd` begin: it only gets existing untested code to
**green** around the change point. Once green, hand off.

## Precondition — you are about to change code that has no test

Reach for this when:
- The code you must modify has no covering test.
- `refactoring` needs characterization because covering tests are absent.
- You hesitate to touch a file because you cannot predict what breaks.

If the behaviour is new, that is `tdd`, not this skill. Legacy rescue is for behaviour that
**already exists** and must be pinned before you disturb it.

## The move

### 1. Find the change point and the seam

Locate exactly where the change must happen. Then find a **seam** near it — a place you can
alter behaviour without editing in that place (use the `codebase-design` vocabulary for
seam/adapter; do not redefine it). The seam is where the test will observe and substitute.

Done when: the change point is named and a seam is identified through which a test can drive it.

### 2. Break the minimum dependency to reach the seam

Untestable code is usually wired to something it constructs itself (a clock, a gateway, a DB).
Break only what blocks the test, with the safest available move:

- **Sensing** — expose what the code did (return a value, capture a call) so a test can observe it.
- **Separation** — pull a dependency to a parameter or an overridable seam so a test can substitute it.

Prefer parameterizing over rewriting. Change as little as possible — you have no test yet.

Done when: the code can be exercised from a test through the seam, with no behavioural change made.

### 3. Pin current behaviour with a characterization test

Write a **characterization test** that asserts what the code *actually does today* — not what it
should do. Run it, read the real output, and encode that. If the current behaviour looks wrong,
the test still pins it: correcting it is a separate, later change made under green.

Done when: a test passes that fails if the current behaviour changes — confirmed by running it.

### 4. Reach green around the change point, then hand off

Add characterization tests until the behaviour you are about to disturb is covered.

- Restructuring with **unchanged** behaviour, now green → `refactoring`.
- Adding or **changing** behaviour, including bug fixes → `tdd`: demonstrate the desired contract with a failing test before implementing it. A characterization test that pins a known bug may be updated as part of that approved correction; preserve coverage of unaffected behavior.

Done when: the behaviour at the change point is covered and green; control is handed to refactoring or tdd.

## Techniques for adding code without a seam yet

When you cannot cheaply get the existing code under test but must add behaviour:

- **Sprout** — write the new behaviour as a new, fully tested method/class, and call it from the
  untested code with a one-line edit. The new code is born tested; the legacy stays untouched.
- **Wrap** — rename the existing method, and put new tested behaviour in a method of the old name
  that calls the renamed original. Use when the new behaviour must run around the old.

Sprout and wrap make progress without first untangling the whole file — keep the unrescued
legacy quarantined behind the new tested code.

## Discipline

- A characterization test pins **actual** behaviour. Never adjust it to desired behaviour in the
  same step — that hides a behavioural change inside a test-adding change.
- Dependency-breaking edits before green are structural only and as small as possible; they carry
  risk because no test guards them yet.
- The instant the change point is green, this skill is done. Do not start refactoring here — that
  is a separate mode (`refactoring`).

## Stop conditions

- Getting a seam requires a large, risky edit with no test to guard it → stop, surface the risk,
  and agree on the smallest sensing/separation move before proceeding.
- Current behaviour is nondeterministic → stabilize the relevant inputs at an owned seam
  using existing fixtures or controlled time/network responses. Ask only when choosing what
  to pin would resolve a material behavior or data-handling decision without authorization.
