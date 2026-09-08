# Proatlas File Templates

This file owns rendered atlas content; `SKILL.md` owns probing and update behavior. Proatlas owns each destination file in full: render the whole file from its template, starting at the canonical title, replace every `{{template token}}` with repository evidence, and omit optional lines without evidence. Generated files contain no template tokens.

## `AGENTS.md`

Canonical title: `# Agent Guidance`.

`AGENTS.md` is the harness entry point: most agent harnesses read it first and may not follow links, so it carries the project facts that change agent behavior — stack and exact commands — with `CONTEXT.md` and `CONVENTIONS.md` as detail.

````md
# Agent Guidance

## Project essentials

- Stack: {{detected stack}}
- Package manager: {{detected package manager}}
- Detail files: `CONTEXT.md` (snapshot, project map, durable decisions), `CONVENTIONS.md` (engineering rules). Read `CONTEXT.md` before non-trivial work.

## Commands

- {{detected command purpose}}: `{{exact project command}}`
- Per-package pattern: `{{workspace tool per-package command pattern}}` — omit this line outside a workspace
- Not detected: {{required commands not supported by repository evidence; omit this line when empty}}

## Working rules

- Start from one explicit goal; search before broad reading; keep work within requested scope and `CONVENTIONS.md`.
- Verify with checks proportional to change risk, using the commands above.
- Stop for material ambiguity involving requirements, public contracts, data loss, security, or irreversible actions.
- Use repository evidence for APIs, commands, endpoints, files, and behavior.
- Keep secrets, tokens, PII, and private paths out of logs and examples.

## Documentation impact

After verified code or configuration changes, report whether public behavior, setup, contracts, architecture, security, or developer-workflow documentation needs updating.
````

## `CONTEXT.md`

Canonical title: `# Project Context`.

````md
# Project Context

## Snapshot

- Root: `.`
- Stack: {{detected stack}}
- Package manager: {{detected package manager}}
- Application paths: {{detected relative paths}}
- Test paths: {{detected relative paths}}
- Workspace: {{workspace tool and member package paths; omit this line outside a workspace}}
- Commands: recorded in `AGENTS.md`.
- Not detected: {{required facts not supported by repository evidence; omit this line when empty}}

## Project Map

- `{{relative path}}`: {{evidence-backed responsibility}}
- `{{relative path}}`: {{evidence-backed responsibility}}

## Excluded Paths

- Normal probe skips: {{detected generated and dependency paths, or `not detected`}}.
- Inspect these paths only when the task concerns generated output, dependencies, or local tooling.

## Durable Decisions

- {{ordered union of decisions from the existing `CONTEXT.md` and a legacy root `context.md`, byte-identical duplicates removed; otherwise `None recorded yet.`}}
````

## `CONVENTIONS.md`

Canonical title: `# Engineering Conventions`.

````md
# Engineering Conventions

Every rule below traces to an explicit source; patterns merely observed in source code are never promoted to rules.

## Formatting

- {{rule}} — source: `{{relative path}}`

## Linting and Types

- {{rule}} — source: `{{relative path}}`

## Testing

- {{rule}} — source: `{{relative path}}`

## Commits and Workflow

- {{rule}} — source: `{{relative path}}`

## Not established

- {{convention categories with no explicit evidence; omit this section when every category has evidence}}

## Migration candidates

- `{{relative path of a convention document outside the root}}` — {{one-line summary}}; omit this section when none exist
````

## `CLAUDE.md` pointer

The root `CLAUDE.md` must reference `AGENTS.md` so the Claude Code harness loads the atlas. Canonical pointer line: `@AGENTS.md` (a Claude Code import).

- No root `CLAUDE.md`: create it containing exactly the pointer line.
- Existing `CLAUDE.md` with no `AGENTS.md` reference: append the pointer line on its own line at the end; change nothing else.
- Existing `CLAUDE.md` that already references `AGENTS.md` (import or prose): leave the file untouched.

Outside the pointer line, `CLAUDE.md` stays human-owned: it is exempt from template-structure preflight and from the line budget, and its other content is never rewritten.

## Rendering rules

- Keep paths repository-relative; represent project root as `.`.
- Keep only project-map entries that help navigation or explain responsibility. In a workspace, list each member package as a project-map entry.
- Copy commands exactly from manifests, task runners, or project documentation.
- For `{{evidence-backed responsibility}}`, reuse the first sentence of the directory's own README, manifest description, or top-level docstring when one exists; otherwise write one short phrase.
- Render deterministically: list commands in manifest or task-runner order, list project-map entries in alphabetical path order, and reuse the source's own wording when a convention source states a rule in prose.
- Preserve existing durable decisions verbatim; report suspected stale decisions instead of rewriting them.
- Use one `Not detected` line per section instead of empty fields.
- Omit any `CONVENTIONS.md` category section that has no explicit source; a rule without a traceable source is never rendered.
- Render a `CONVENTIONS.md` rule only when it changes a decision an agent makes while writing new code: naming, structure, test or commit requirements, or formatting a formatter does not auto-fix. Summarize auto-enforced tool configuration as one line — `Enforced by {{tool}} — source: {{relative path}}` — instead of restating it rule by rule.
