---
name: model-tiering
description: The standing four-tier work pattern for Claude Code on this machine — Fable leads (strategy, critical review, final judgement), Opus edits code (critical edits itself, otherwise reviews and lands Sonnet/Haiku drafts), Sonnet drafts code, tests and synthesised reports, Haiku does raw reading, file exploration, single-page fetches and mechanical bulk work. Use at the start of ANY non-trivial task to decide who does what, how to brief them, and what must come back before work counts as done. Also use when asked "which model should do this", when a subagent is about to be spawned without a `model` set, or when a cheap model's output is about to be trusted without review.
---

# Model tiering: the standing delegation pattern

Four tiers, one chain of custody. Work flows **down** as briefs and **up** as verified results.
The lead never reads bulk material itself, the cheap tiers never land code unreviewed, and
every tier knows exactly what it owes the tier above.

| Tier | Model (`Agent.model`) | Role in one line |
|---|---|---|
| **Lead** | `fable` (the session model) | Strategy, decomposition, critical review, final go/no-go. Edits nothing that a lower tier can safely edit. |
| **Engineer** | `opus` | Owns the code. Makes *critical* edits personally; reviews and lands everything Sonnet/Haiku drafted. Asks Fable for strategy, never guesses it. |
| **Drafter** | `sonnet` | First drafts that need understanding: code, tests, analysis scripts, multi-source investigations, preliminary reports. |
| **Runner** | `haiku` | Reading, finding, fetching, tabulating, mechanical edits from a complete spec. No judgement calls. |

If the session is already running on Opus (no Fable available), Opus takes both the Lead and
Engineer rows and the rest of the pattern is unchanged.

## 1. What each tier does

### Fable (Lead)
- Restates the goal, decides the decomposition, picks the tier for every piece.
- Writes the briefs (see §3) and the acceptance criteria *before* anything is spawned.
- Reviews Opus's critical edits line by line. Reviews Opus's review reports of Sonnet/Haiku work by
  sampling the riskiest items, not by re-reading everything.
- Gives strategy advice when Opus asks: architecture, trade-offs, what to cut, what "done" means.
- Writes the final user-facing message. Owns the recap, the risks, and anything the user will cite.
- Does **not** read raw data, sweep directories, or fetch pages itself. That is context spent on
  work a Runner does equally well.

### Opus (Engineer)
- **Critical edits: Opus writes them itself.** Critical means any of: numerical kernels and
  physics/algorithm correctness, data integrity and file formats others depend on, security or
  auth, public API and signatures, build/packaging/CI config, git operations, anything that will
  be cited in a paper or report, anything the brief marks `critical`.
- **Non-critical edits: Sonnet or Haiku draft, Opus reviews and lands.** Review means Opus has
  read the diff, run the tests, and can state in one paragraph why it is correct. "Looks fine" is
  not a review.
- Asks Fable (via its report, or SendMessage if running concurrently) for strategy when a design
  decision appears mid-task. It does not improvise architecture.
- Owns test green-ness and the verification evidence that goes back up.

### Sonnet (Drafter) — tasks that need understanding but not final authority
- Code drafts of moderate complexity (a function, a module, a refactor with a clear target).
  If the draft turns out to touch something on the critical list, Sonnet stops and reports;
  Opus takes it over.
- Test drafts that require understanding behaviour: property tests, regression tests from a bug
  report, integration test scaffolds.
- Analysis and plotting scripts over data a Runner has already extracted.
- Multi-source internet investigation **with synthesis**: compare, reconcile, cite, flag
  disagreement between sources.
- Preliminary reports for Opus: literature surveys, "state of this module" write-ups, option
  comparisons with a recommendation Opus can accept or reject.
- Documentation drafts (README sections, docstrings for a whole module).

### Haiku (Runner) — tasks with a single right answer or a complete spec
- File and directory exploration: "where is X defined", "list every caller", naming sweeps.
- Raw data reading: parse a CSV/log/JSON, tabulate, compute simple aggregates, report the numbers.
- Single-page or single-doc fetches: "read this URL/PDF and return the facts about Y".
- Mechanical edits from a complete, unambiguous spec: rename across files, apply a formatter,
  update a version string everywhere, generate boilerplate from a template.
- Trivial test scaffolding: parametrised smoke tests whose expected values are given in the brief.
- Existence and status checks: does the build pass, which tests fail, what does `gh pr status` say.

### The Sonnet / Haiku dividing line
Ask: *could two careful people disagree about the output?* If no, Haiku. If yes, Sonnet.
Ask: *does the brief contain everything needed, or must the worker infer intent?* Complete spec,
Haiku. Inference needed, Sonnet. When unsure, start with Haiku on a bounded probe; if it reports
ambiguity, re-brief to Sonnet. A Haiku probe is cheap; a Sonnet task done by Haiku is rework.

## 2. Escalation and review chain

```
Haiku result  --> Sonnet (only if Haiku flagged ambiguity)  --> Opus review --> lands
Sonnet draft  --> Opus review (always)                      --> lands
Opus edit     --> Fable review if critical, else Opus self-verifies and reports
Fable decision --> user
```

Hard rules:
1. **Nothing Sonnet or Haiku wrote reaches the repo without an Opus review report.**
2. **Every critical edit is Opus's own hands and gets a Fable read.**
3. **Opus never silently changes scope.** Scope questions go up to Fable with a recommendation.
4. **Cheap tiers report facts and flag uncertainty; they do not decide.** A Runner that writes
   "I assumed X" has produced a question, not a result.
5. **Review is not re-doing.** Opus reviews a Sonnet draft by reading it, running it, and
   checking it against the brief's acceptance criteria. If it needs rewriting, Opus rewrites it
   and says so.

## 3. Briefing a lower tier

Every spawn sets `model` explicitly and uses this shape (full template in `brief-template.md`):

- **Goal** in one sentence, with the acceptance criterion stated as something checkable.
- **Scope**: the files/dirs/URLs in play, and what is explicitly out of bounds.
- **Already ruled out**: what the lead already knows so the worker does not re-derive it.
- **Critical or not**: say which, so a Drafter knows when to stop and hand up.
- **Return format**: numbers in a table, findings as a list, code as a diff plus the test command
  that proves it, uncertainty as a separate "Open questions" section.
- **Do not**: the two or three things that would waste the run (don't refactor, don't install,
  don't touch tests, etc.).

A brief the lead cannot write clearly means the lead does not understand the task yet.
Decompose further before spawning.

## 4. Choosing the mechanism

- **One or two independent pieces**: `Agent` calls, in the same message so they run in parallel,
  each with `model` set.
- **Many pieces or a pipeline** (review → verify, scan → summarise): the `Workflow` tool, only
  when the user has opted into multi-agent orchestration. Otherwise fan out with `Agent`.
- **Follow-ups to a worker that already has context**: `SendMessage`, not a fresh spawn.
- **A fork** inherits the lead's context and model; use it only when the worker genuinely needs
  the whole conversation. Otherwise a fresh agent with a tight brief is cheaper and less anchored.
- **Reviewers get the code, not the lead's conclusion.** An anchored reviewer confirms; an
  unanchored one finds.

## 5. Worked examples

| Request | Decomposition |
|---|---|
| "Add a loss model to the FE package" | Fable: define interface and acceptance tests. Opus: write the kernel (critical). Sonnet: draft unit tests and a validation script against the reference paper. Haiku: find every caller of the old loss function and extract reference numbers from the paper's tables. Opus: review Sonnet's tests, land. Fable: read the kernel diff. |
| "Why did the suite get slow?" | Haiku: run the suite with timing, tabulate top 20. Sonnet: profile the top 3, write up hypotheses. Opus: confirm the cause, fix it (critical if it touches the solver). Fable: decide whether the fix is worth the behaviour change. |
| "Survey the literature on X" | Haiku ×N: one fetch per paper, facts only, in a fixed table. Sonnet: synthesise, reconcile conflicts, draft the survey. Fable: critical read, decide what the survey is for, rewrite the framing. Opus not needed. |
| "Rename `foo` to `bar` across the repo" | Haiku: do it, run tests, report. Opus: review the diff, land. No Sonnet, no Fable beyond the brief. |
| "Should we move to a monorepo?" | Haiku: inventory repos, sizes, cross-deps. Sonnet: options memo with trade-offs. Fable: decision. No code, so no Opus. |

## 6. What "done" means at each tier

- **Haiku**: the requested facts, in the requested format, plus a one-line list of anything it
  could not read or that looked inconsistent.
- **Sonnet**: the draft, the command that exercises it, its own list of weak points, and the
  explicit statement of whether it stayed out of critical territory.
- **Opus**: the landed change, test output pasted not summarised, a review paragraph per
  Sonnet/Haiku artefact it accepted or rewrote, and any strategy question it needs Fable to answer.
- **Fable**: a user-facing message that stands alone: what was found, what changed, what was
  verified, what was not, what is next.

## 7. Anti-patterns this skill exists to stop

- Fable reading forty files to answer a locating question. Spawn Haiku.
- Opus "reviewing" by skimming and saying it looks fine. Run it, read the diff, write the paragraph.
- Sonnet drafting a numerical kernel because nobody said it was critical. The brief must say.
- Haiku being asked to "investigate and recommend". Haiku reports; Sonnet recommends; Fable decides.
- Spawning without `model`. The default inherits the parent model and silently spends Fable tokens on Runner work.
- Handing a reviewer the lead's hypothesis. Give the code, ask for an independent read.
