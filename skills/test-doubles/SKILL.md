---
name: test-doubles
description: >
  Decide when and what to mock so tests stay behavioural. Use when a test needs a test double,
  you are mocking collaborators, tests break on refactors that don't change behaviour, or mocks
  are multiplying. Calibrates stub-vs-mock and only-mock-what-you-own against over-mocking.
---

# Test Doubles

A test double stands in for a real collaborator. At the right seam it isolates behaviour; at the
wrong one it couples the test to implementation — the failure `tdd` warns about:
the agent mocks its own structure and the test mirrors the code.

**`tdd`'s default wins: prefer real objects and integration-style tests.** This skill does not
change that default — it governs only the residual case where a double is genuinely unavoidable,
so that case stays disciplined instead of multiplying. Reaching for this skill often means the
classicist default has slipped; go back to it.

This skill governs **only the doubles**. The red-green cycle is `tdd`; the seam/adapter
vocabulary is `codebase-design`; each is the single source of truth for its part.

## The one rule that reconciles this with tdd

Mock at **seams you own** — a peer with its own responsibility (a gateway, repository, notifier,
clock). Never mock an **incidental internal** helper or a value. Peers you own are part of the
design contract, so a double there tests behaviour; a double on an incidental internal tests
structure, which is exactly what `tdd` forbids.

## Stub vs mock — query vs command

- **Query** (you ask for a value, no side effect) → use a **stub**: it returns a canned answer.
  Assert on what your code *does* with the answer, not that it asked.
- **Command** (you tell a peer to act, the effect is the point) → use a **mock**: assert the call
  happened as specified. This is the one place where verifying an interaction *is* the behaviour.

If you are verifying a query call or stubbing a command's return, the double is the wrong kind —
re-read which one it is.

## Only mock what you own

Never mock a third-party type directly. Wrap it behind a seam you own (`codebase-design`: an
adapter at a seam), then mock that seam. You control your seam's interface, so the test stays
stable when the library changes; mocking the library couples your test to its surface.

Never mock a **value** (a DTO, a date, a money amount) — construct the real thing, with a builder
if setup is noisy.

## Mock roles, not objects

Reaching for a mock is a design act: it declares the **role** a collaborator must play, surfacing
an interface the code needs. Name the role for what it does for the caller — discovered this way,
the seam tends to be deep.

## Listen to the tests

Test pain is a **design** signal, not a testing inconvenience:

- Many doubles to set up one test → the unit has too many collaborators; collapse or deepen it.
- You must mock a value or an incidental internal → the seam is in the wrong place.
- The test breaks when you refactor without changing behaviour → you mocked structure, not a role.

When setup hurts, fix the design before the test. Hand a confirmed smell to `codebase-design`;
hand a green-but-cluttered structure to `refactoring`.

## Discipline

- Default to the real collaborator. Introduce a double only for a peer you own that is slow,
  nondeterministic, or has a side effect you must assert.
- One adapter means a hypothetical seam; two means a real one (`codebase-design`). Don't invent a
  seam just to mock across it.
