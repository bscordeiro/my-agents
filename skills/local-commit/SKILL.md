---
name: local-commit
description: Create exactly one safe local Git commit from the current changes. Use only when the user explicitly requests a local commit — e.g. "commit this", "create a commit", "commit my changes". Applies its fixed Conventional Commits standard regardless of repository conventions, runs required checks, never pushes or rewrites history, and reports the result and remaining worktree state.
---

Create one local commit — at most one per invocation, only on an explicit
request — whose message, staged content, and user intent agree. When they
cannot, **stop**: end without committing, unstage exactly what this skill
staged (a pre-existing index stays untouched), and report the reason and
repository state. Ask at most one focused question when user input can
unblock. The Standard below is the only message policy — apply it regardless
of any convention the repository defines.

## Invariants

- Local only — no push, remote mutation, tag or release publication; a
  request bundling one → one focused question: local commit only, or stop.
- Additive history only — no amend, rebase, or destructive reset; a rewrite
  intent stops rather than getting a substitute commit.
- Hooks always run — never `--no-verify`; report their outcomes.
- Commit-only authorization — staging (per the flow) and one commit are the
  only mutations; everything else stays untouched.
- Never guess a project command or the user's intent — ask or report.
- Never force-add an ignored path.

## Flow

1. **Preflight.** Stop for: bare repository, detached HEAD, missing
   `user.name`/`user.email`, unresolved conflicts, or an active merge,
   rebase, cherry-pick, revert, or bisect. An unborn branch is fine — the
   empty tree is its baseline.
2. **Baseline.** Record HEAD (or the unborn state), the index tree, and
   `git status --porcelain` for all later comparison.
3. **Candidate.** Non-empty index → the exact staged set, complete and
   indivisible; not one coherent change → stop and ask for a prepared index.
   Empty index → screen paths against the sensitive-content gate, then stage
   whole paths serving one intent (a rename's old and new path together);
   mixed hunks or uncertain inclusion → stop and ask. Nothing matching the
   intent → stop: nothing to commit.
4. **Message.** Draft the header per the Standard, then read
   `git diff --cached`; a staged path the header cannot truthfully cover
   means stop.
5. **Gates.** Apply the Gates below; any block without a recorded
   exception → stop.
6. **Commit.** `git commit -F <tempfile>` — never an editor, hooks running.
7. **Verify.** Compare HEAD, index, and worktree with the baseline; read the
   created commit back (`git show`) and confirm content and message match
   what was reviewed. Divergence (e.g. a mutating hook) → flag for user
   follow-up; never restore, amend, or reset.
8. **Report.** Hash and message (or the stop reason), gate conclusions,
   exceptions and confirmations, hook mutations, and remaining unstaged and
   untracked work.

## Standard

`<type>(<optional-scope>): <description>` — types `build chore ci docs feat
fix perf refactor revert style test`. English imperative header of at most
72 characters, lowercase start, no trailing period, describing the result of
the change rather than a file operation. Scope is a domain — never a
filename — omitted on weak evidence. Body only when the header cannot
truthfully summarize alone: one blank line, wrapped at 72. Breaking change:
`!` before the colon plus a `BREAKING CHANGE:` footer.

## Gates

- **Sensitive content** — materially suspicious at minimum: paths matching
  `.env*`, `*.pem`, `*.key`, `id_rsa*`, `*.p12`, `credentials*`, `secrets*`;
  private-key blocks; known token prefixes; high-entropy literals under
  credential-like names. Suspicion → stop, unless the user explicitly
  confirms the path safe (record it); never reproduce a flagged value —
  report by path and redacted description. A conservative screen, not
  comprehensive detection; say so in the report.
- **Required checks** — `git diff --cached --check` always runs: a conflict
  marker blocks; whitespace findings get one confirmation (Markdown hard
  breaks are legitimate). Beyond it, only the user's explicit instruction
  makes a check required. A failing or unavailable required check blocks
  unless the user grants a recorded exception.
