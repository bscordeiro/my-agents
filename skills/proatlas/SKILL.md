---
name: proatlas
description: Build or refresh a project context atlas (`AGENTS.md`, `CONTEXT.md`, and `CONVENTIONS.md`, plus a `CLAUDE.md` pointer to `AGENTS.md`) from repository evidence. Use when project AI guidance, context, or engineering conventions are missing or stale.
---

# Proatlas

Proatlas builds a compact, harness-neutral atlas: `AGENTS.md`, `CONTEXT.md`, and `CONVENTIONS.md` side by side in one project root, plus a root `CLAUDE.md` pointer so the Claude Code harness loads `AGENTS.md`. `README.md` is read as evidence but never written.

## Steps

### 1. Resolve a fenced root

Use the explicit project root when supplied. Otherwise, ask one focused question in the user's language for the project root.

Canonicalize the path and verify it is an existing directory. Scope project inspection and mutation to that canonical root; reading this skill's own resources is exempt. Resolve existing target symlinks before writing and stop when any of `AGENTS.md`, `CONTEXT.md`, `CONVENTIONS.md`, or `CLAUDE.md` escapes the root. Quote the root in commands.

Completion criterion: one canonical project root is validated, all four destinations resolve inside it, and every project command is scoped to it.

### 2. Probe repository evidence

Start with search and top-level listings, then read only high-signal files:
- manifests and lockfiles
- README and existing guidance (`AGENTS.md`, `CLAUDE.md`, `CONTEXT.md`, legacy `context.md`) — `README.md` is evidence only, never a write target
- files that define test, build, lint, type-check, install, and dev commands
- explicit convention sources: `.editorconfig`, linter, formatter, build, test, and commit-tooling configuration, plus convention documents anywhere in the repository
- directories needed to identify application, tests, documentation, and generated output

Treat `.git`, `node_modules`, `dist`, `build`, `coverage`, `.venv`, `vendor`, and detected equivalents as excluded paths during the normal probe. Record existing excluded paths instead of traversing them. Derive facts from repository evidence; collect required unknowns under `Not detected`.

Detect a workspace only from explicit evidence: a manifest `workspaces` field, `pnpm-workspace.yaml`, a `Cargo.toml` `[workspace]` table, `go.work`, or an equivalent workspace configuration. In a workspace, record the member packages and the tool's per-package command pattern (for example `pnpm --filter <package> test`).

Record convention documents outside the root as migration candidates; never move or delete them. Stop when two explicit convention sources conflict and precedence cannot be established from repository evidence.

When a legacy root `context.md` exists, read it as evidence, carry its durable decisions forward into `CONTEXT.md`, and report it as a migration candidate; never move or delete it.

Completion criterion: stack, package manager, workspace layout (single-package, or workspace with member packages), project map, excluded paths, key commands, and candidate conventions are each backed by a repository source or explicitly listed as not detected.

### 3. Render the atlas files

Load [`references/file-templates.md`](references/file-templates.md) before editing.

Proatlas owns each atlas file in full: every run regenerates the whole file from its template with the canonical title, and regeneration from unchanged evidence must reproduce identical structure — same canonical title, section order, list order, relative paths, and exact commands. Only free-prose phrasing may vary, and the rendering rules in the templates file minimize even that. Manual notes belong in other files, not in atlas destinations.

Preflight every target before the first write; any preflight failure leaves every target unchanged. Stop with a diagnostic before writing anything when:
- a destination resolves outside the root
- an existing atlas destination does not match its template structure (canonical title and section order) — read it as evidence, carry forward what the templates can express, and ask before overwriting content that would not survive regeneration

`CLAUDE.md` is exempt from the template-structure check: it stays human-owned and only ever gains the `AGENTS.md` pointer, following the `CLAUDE.md` pointer rules in the templates file.

When refreshing `CONTEXT.md`, merge durable decisions from the existing `CONTEXT.md` and a legacy root `context.md` as an ordered union, deduplicating byte-identical entries; divergent variants of the same decision are a reported conflict, never a silent rewrite. Render optional fields only when evidence exists; group required unknowns under `Not detected`. Keep each atlas file under roughly 60 lines and all three under 180 lines combined; the `CLAUDE.md` pointer is exempt from the budget. Cross-link atlas files with repository-relative paths.

Create or update only `<root>/AGENTS.md`, `<root>/CONTEXT.md`, `<root>/CONVENTIONS.md`, and the `<root>/CLAUDE.md` pointer. `AGENTS.md` is the harness entry point and carries the operating guidance, stack summary, and project commands; `CONTEXT.md` carries the repository snapshot, project map, excluded paths, and durable decisions; `CONVENTIONS.md` carries engineering rules; `CLAUDE.md` only ever gains the `AGENTS.md` pointer.

In a workspace, render the atlas only in the root: list member packages as `Project Map` entries, record the per-package command pattern alongside root commands in `AGENTS.md`, and never create per-package atlas files.

Render a `CONVENTIONS.md` rule only from an explicit documentary or tool-enforced source; never promote a pattern merely observed in source code. Keep only rules that change a decision an agent makes while writing new code; summarize auto-enforced tool configuration as a one-line pointer per the rendering rules instead of restating it rule by rule. Omit categories without evidence or list them under `Not established`.

Completion criterion: all three atlas files exist, match their template structure with required sections and zero unresolved template tokens, stay within the line budget, carry the merged durable decisions, every convention rule is traceable to a read source, and the root `CLAUDE.md` references `AGENTS.md`.

### 4. Verify and report

Read every rendered file from disk. Confirm canonical titles and template section order, required sections, relative project paths and cross-links, merged decisions. Trace detected commands, facts, and convention rules back to files read during the probe.

Run mechanical checks from the root and read their output:
- `grep -n '{{' AGENTS.md CONTEXT.md CONVENTIONS.md` — must print nothing (zero unresolved template tokens)
- `wc -l AGENTS.md CONTEXT.md CONVENTIONS.md` — each file within its budget and the total under 180
- `grep -n 'AGENTS.md' CLAUDE.md` — must print at least one line (pointer present)

Report:
- files changed
- detected stack and package manager
- convention sources and migration candidates
- verification evidence, including the mechanical check output
- `CLAUDE.md` pointer status (created, appended, or already present)
- documentation impact, including onboarding gaps observed in the human-owned `README.md`
- hygiene risks observed outside scope

Completion criterion: every render criterion has fresh read or command evidence, and the report distinguishes detected facts, explicit unknowns, and out-of-scope observations.
