# OpenSpec as a Save Target

Governs the handoff after Review when the plan explicitly targets OpenSpec. The
conversation keeps the Planmate handoff shape until formalization; OpenSpec's
active workflow and schema own artifact names, templates, dependencies, and
project context.

## Target and Consent

- Apply this reference when the project has an `openspec/` root, or the user
  explicitly requests OpenSpec output.
- Detection alone does not grant consent. An explicit request to use OpenSpec
  for this handoff records `Path: OpenSpec change` and `consent: granted`.
  Reuse that recorded consent at Review; do not ask for it again.
- Keep exactly one canonical destination. When the OpenSpec target is granted,
  it is the change root resolved by OpenSpec. Do not silently change it to
  `docs/plans/` because a workflow or CLI is unavailable; that is a separate
  destination requiring an explicit user choice.
- If the user asks to conclude only in chat, keep the complete handoff in the
  conversation and do not create an OpenSpec change or invoke Propose. A later
  explicit chat-only instruction takes precedence over earlier detection or
  consent.

## Capability Check

Before formalizing, inspect capabilities available in the current host and
project. Use the actual installed interface; do not invent a command name.

1. If an installed OpenSpec Propose workflow is available, hand it the complete
   in-conversation handoff and let it own change creation, artifact generation,
   dependency order, and validation.
2. If no Propose workflow is available but the `openspec` CLI is installed and
   can resolve the authorized OpenSpec root, use the CLI workflow below.
3. If neither is available, leave the handoff in the conversation, state that
   OpenSpec formalization could not run, and stop. Never fall back automatically
   to a docs plan or claim that the OpenSpec target was saved.

Only the first two paths write OpenSpec artifacts, and only after the OpenSpec
target has explicit consent.

## Active Schema and Dependency Graph

The active project schema is the source of truth. Do not hard-code the
`spec-driven` artifact list or assume that `design.md` exists.

For the CLI path:

1. Resolve the nearest OpenSpec root. If the user named a registered store,
   discover its id with `openspec store list --json` and pass `--store <id>` to
   every command that reads or writes the change.
2. Derive an available kebab-case, verb-first change id for a new plan. Reuse
   an existing change only when authorized for the same work item; clarify a
   conflict with an explicitly requested target instead of overwriting it.
3. Create the change with `openspec new change <id> --json`, allowing the
   project's configured schema to resolve. Use `--schema <name>` only when the
   active schema was explicitly selected or reported by the CLI/workflow.
4. Read `openspec status --change <id> --json`. Use the returned schema,
   `applyRequires`, artifact statuses, and resolved paths instead of assuming
   repository-local paths or a fixed build order.
5. For each artifact that is ready, call
   `openspec instructions <artifact-id> --change <id> --json`. Treat its
   `template`, `instruction`, `context`, `rules`, `resolvedOutputPath`, and
   `dependencies` as authoritative. Read every completed dependency before
   creating the next artifact, then re-read status.
6. Stop only when every artifact listed by `applyRequires` is complete. The
   active workflow may require fewer, more, or differently named artifacts than
   the examples below.

Apply returned `context` and `rules` as instructions. Preserve relevant domain
facts through the mapping below rather than copying raw instruction blocks.

## Semantic Mapping

Map Planmate content to the active schema's artifact purpose and template. The
following is semantic guidance, not a fixed artifact contract:

| Planmate content | Mapping rule |
|---|---|
| Problem + Development Volume | Artifact that establishes why/intent. Preserve volume across deliveries/behaviors, flows/components, and integrations/migrations/dependencies; depth follows volume, risk, and uncertainty. |
| Solution + Scope includes/excludes + No-gos | Artifact that defines what changes and its boundary. Keep the fat-marker intent separate from implementation mechanics. |
| Context + Critical Files | Carry domain facts, constraints, integrations, prior decisions, and file paths into the schema sections that provide project context. Never drop these fields because a template lacks a same-named heading. |
| Decisions + Assumptions + Security and Privacy | Preserve rationale, non-blocking assumptions, and security/privacy constraints in the artifact(s) intended for technical or cross-cutting constraints. Create such an artifact only when the active schema requires or supports it. |
| Rabbit Holes + Risks and Stop Conditions | Preserve avoidances, risks with mitigations, and explicit conditions that stop implementation. If the active schema has no risk section, place them in its closest instructed constraints section without weakening their meaning. |
| Observable behavior and slice Criteria | Derive requirements from behavior and criteria. Requirements are capability/contract units, not a mandatory one-to-one copy of slices. |
| Slices and per-slice Verify, Evidence owner, Evidence limits, and Verification support | Use slices to organize implementation tasks and verification. Preserve claim ownership, material limitations, alternative-check conditions, and authorized support lifecycle in the closest schema-supported fields. A slice may touch several requirements, and one requirement may be delivered by several slices. |

Follow the active template when placing each field. If the schema cannot carry a
material field without semantic loss, stop and report the mismatch instead of
silently omitting it.

## Requirements and Existing Capabilities

- Derive requirements from observable behavior and acceptance criteria. Keep
  mechanisms, file edits, and task ordering out of requirement statements.
- Follow the active schema's syntax and normative language. With the installed
  `spec-driven` schema, each requirement needs at least one `#### Scenario:`
  using WHEN/THEN, and `MODIFIED Requirements` must include the complete
  existing requirement block.
- If the active schema has no separate requirements artifact, carry observable
  behavior and criteria in the artifact whose instructions define that
  contract. Do not invent a missing artifact or force `design.md`.
- Before marking a capability modified, inspect the exact existing capability
  at the resolved OpenSpec root. Use its existing name. If no capability matches, use
  the active schema's new-capability operation and keep the delta limited to
  what that schema requests.
- Open Questions are not exported. Formalization requires them to be empty;
  unresolved material questions remain in the conversation and block the
  OpenSpec handoff.

## Validation Gate

Use the installed Propose workflow's applicable validation and inspect its
reported results, or use the following checks for the CLI path. Both paths
require the semantic check below.

1. Run `openspec schema validate <schema>` and confirm every artifact required
   by the active workflow's `applyRequires` is present with dependencies
   satisfied in `openspec status --change <id> --json`.
2. When the active schema includes delta-spec artifacts, run
   `openspec validate <id> --strict`; fix findings and re-run before claiming
   strict validation.
3. When the active schema has no delta-spec artifact, use schema validation,
   status/dependency completion, and the semantic check below as the applicable
   gate. OpenSpec CLI 1.6.0's generic change validator can still demand a
   `specs/` delta for a valid custom schema containing only `proposal` and
   `tasks`; report that limitation explicitly and never claim `validate
   --strict` passed. Do not fabricate a specs artifact to satisfy it.
4. Perform a semantic completeness check beyond tool validation: Problem,
   Development Volume, Solution, scope, Context, Critical Files, Decisions,
   Assumptions, Security and Privacy, Rabbit Holes, Risks, Stop Conditions, requirements,
   scenarios, slices, criteria, Verify content, evidence ownership and limits, and any
   verification-support authorization/lifecycle must be represented where
   the active schema supports those concepts; behavior and criteria must still
   be represented according to the active instructions when it does not. Any
   requirements must cover observable behavior, and no material constraint may
   have been lost while following the active template.

Tool validation is necessary where applicable but does not prove that the
Planmate handoff was semantically preserved.

## Implementation Boundary

After the required artifacts are created and applicable validation passes, report the
exact change id and resolved change root. If implementation was already
requested and authorized, hand off to the project's implementation workflow
under that authorization. Otherwise offer the Apply workflow using the actual
interface installed in the host (for example, a discovered
`openspec-apply-change` skill or `/opsx:apply` command) and wait for a new
implementation request. Mention that interface only in conversation, never
inside saved artifacts.

The OpenSpec change root is the portable handoff. A missing Propose or Apply
workflow does not authorize a different save target or an automatic
implementation path.
