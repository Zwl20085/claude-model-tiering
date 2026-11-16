---
name: model-tiering
description: How to split a task across four model tiers in Claude Code - the session model leads, Opus writes and owns the code, Sonnet does non-code thinking and peripheral drafts, Haiku does reading, finding, fetching and mechanical edits. Covers when to delegate at all, which tier gets each piece, how to brief it, what must come back before work counts as done, and what to do when a return is wrong. Load before the first subagent spawn of any task, when asked which model should do something, or when a cheap model's output is about to be trusted without review.
---

# Model tiering: the method

The always-on Model Tiering rule holds the tier table and the hard rules, and it is normally
already in your context. This skill is how to apply them. You are reading it as the Lead: you
plan the split, write the briefs, check what comes back, and write the final message.

The pattern exists because the Lead's context is the scarce resource and its tokens are the
expensive ones. Reading and searching are done as well by a cheaper model. Code is not, which is
why Opus writes it instead of reviewing someone else's attempt. The saving comes from Haiku
doing the reading and Sonnet doing the non-code thinking, not from cheaper authorship.

## 1. How tiers are spawned

| Tier | `subagent_type` | Can spawn |
|---|---|---|
| Engineer | `tier-engineer` | `tier-drafter`, `tier-runner` |
| Drafter | `tier-drafter` | nothing |
| Runner | `tier-runner` | nothing |

Each definition pins its model and carries the tier's contract and return format, so a brief
does not need to repeat them. Do not pass `model` on a `tier-*` spawn: the call's `model`
overrides the definition, and the only reason to do that is a deliberate one-off.

Any other agent type (`Explore`, `claude-code-guide`, `general-purpose`, a project's own agents)
has no tier built in. Set `model` on the call, and put the return format in the brief.

**The Lead is the hub.** You spawn the workers, their reports come back to you, and you pass
work between tiers. The one exception is the Engineer, which may spawn a Runner to locate or
read something, or a Drafter for a peripheral draft, inside its own task. It then reviews what
comes back and reports that it did so. Drafter and Runner never spawn.

If the session runs on Opus, you are Lead and Engineer at once: write the code yourself, spawn
only Drafter and Runner, and the two-reader rule for critical edits becomes "verify, then show
the user the diff". If the `tier-*` agents are not installed, use `general-purpose` with
`model` set and paste the return block from `brief-template.md` into the brief.

## 2. Delegate, or do it directly

A spawn costs a brief, a cold start in which the worker rebuilds context you already have, and
a summary that drops detail on the way back. Delegate when the work is worth that.

Do it yourself when:
- the target is known and it takes a handful of tool calls (read two files, run one command);
- the edit is a few lines, not critical, and the context is already in your head;
- the answer is already in the conversation.

Delegate when:
- finding the answer means reading across many files, pages or a dataset;
- there is code to write beyond a few lines, or any critical edit at all;
- pieces are independent and can run in parallel;
- you want a read that is not anchored on your own conclusion.

Critical edits have no floor. They are the Engineer's hands and then your read, however small,
because the value is in the author and the reader being different.

## 3. Route each piece

Ask these in order and stop at the first yes.

1. **Is it a critical edit?** Engineer writes it, you read the diff. Critical means: numerical
   kernels and algorithm or physics correctness, data integrity and file formats others depend
   on, security or auth, public API and signatures, build, packaging and CI config, git
   operations that change state, code or data behind a result that will be cited, and anything
   you mark critical in the brief. Prose that will be cited, such as a survey, is not an edit
   in this sense: a Drafter may draft it, and the gate is re-opening its sources (section 6).
2. **Is it code someone will run, cite or build on?** Engineer writes it and verifies it.
3. **Is it peripheral code or documentation with a complete spec, where reviewing the result is
   clearly cheaper than writing it?** Drafter writes it (Runner if it is purely mechanical),
   then the Engineer reviews and lands it. Typical cases: a plotting script over data already
   extracted, a fixture generator, extra cases for an existing parametrised test, a regression test
   reproducing a given bug report, a README section. Designing the core tests stays with the
   Engineer. If the Engineer could do it in one command, such as a scripted rename, the review
   costs more than the work and the Engineer just does it.
4. **Is it non-code work that needs judgement?** Drafter. Comparing sources, reconciling
   conflicts, an options memo with a recommendation, a "state of this module" write-up.
5. **Does it have a single right answer?** Runner. Where is X defined, list every caller, parse
   this log and tabulate, read this page and return the facts about Y, does the build pass.

For the Drafter and Runner split, ask whether two careful people could disagree about the
output, and whether the worker must infer what you meant. Either one makes it Drafter work.
When unsure, send a Runner on a bounded probe. If it reports ambiguity, re-brief to a Drafter.
The probe is cheap. Drafter work done by a Runner is rework.

The 60/20/20 split in the rule is what this routing tends to produce, not a quota to hit.

## 4. Write the brief

The worker knows nothing you do not write down. `brief-template.md` has two sizes.

- **Probe** (a Runner lookup with one answer): the question, where to look, and what to return.
  Two or three lines. Do not pad it.
- **Full brief** (anything that writes, synthesises, or runs longer than a lookup): the goal
  with an acceptance criterion the worker can check alone, scope in and out, what you already
  know or have ruled out, whether it is critical, and the two or three things that would waste
  the run.

A reviewer gets the code and the acceptance criterion. It does not get your hypothesis or your
opinion of the code. An anchored reviewer confirms, and an unanchored one finds.

If you cannot write the brief clearly, you do not understand the task yet. Decompose further
before spawning.

## 5. Run it

- **Independent pieces go out in one message** so they run in parallel.
- **One writer per file at a time.** Parallel writers in one repo need disjoint file sets named
  in each brief's scope, or `isolation: "worktree"`. Readers can run in any number.
- **Commits, merges and pushes are the Engineer's, one at a time**, and only when the brief
  asks for them.
- **A follow-up to a worker that already has the context is a `SendMessage`**, not a new spawn.
- **A fork** inherits your whole conversation and your model. Use it only when the worker needs
  that conversation. A fresh worker with a tight brief is cheaper and less anchored.
- **Many pieces or a fixed pipeline** can use the `Workflow` tool, only when the user has asked
  for multi-agent orchestration. Otherwise fan out with `Agent`.
- While workers run, do the work that does not depend on them. Never state a result before the
  worker's report has arrived.

## 6. Gates: what must come back

**Code from a Drafter or Runner** does not land until an Engineer has read the diff, run it,
and written a paragraph on why it is correct. "Looks fine" is not a review. If it needs
rewriting, the Engineer rewrites it and says so.

**Code from the Engineer** comes back with the test command and its pasted output. If it is
critical, you read the diff line by line before it counts.

**Facts** from a Drafter or Runner come with a source for each one: file and line, URL, or
page. Whoever uses a fact re-opens the source. Check all of them when they will be cited in a
paper or report, and the ones a decision turns on otherwise. A summary of a number is not the
number.

**An assumption is a question.** A worker that wrote "I assumed X" has not finished. Answer it,
or send the piece up a tier.

**Your own review** of an Engineer's report on lower-tier work samples the riskiest items. Do
not re-read everything, and do not skip it.

Done, per tier:

| Tier | Owes |
|---|---|
| Runner | The facts in the format asked, each with a source, a list of what it could not read or what looked inconsistent, and any open questions. |
| Drafter | The draft, the command that exercises it with its output, its own list of weak points, and whether it stayed out of critical territory. |
| Engineer | The change, the verification output pasted in full, one review paragraph per lower-tier artefact it accepted or rewrote, and any question it needs you to answer. |
| Lead | A message to the user that stands alone: what was found, what changed, what was verified, what was not, what is next. |

## 7. When a return is wrong

- **It missed the acceptance criterion.** First ask whether the brief caused it. If so, fix the
  brief and `SendMessage` the same worker, which still has its context.
- **It missed twice.** Move the piece up one tier. Do not send a third attempt to the same one.
- **It reported ambiguity or stopped at critical territory.** That is a correct return. Answer
  the question, or re-route the piece.
- **It went out of scope.** Discard the out-of-scope part. If that part touched anything
  critical, the Engineer redoes it from the original state.
- **Two workers disagree on a fact.** Neither wins by default. Open the source.
- **The Engineer hit a design decision.** It should have come back to you with a recommendation
  and not improvised. Decide, then continue the same worker.

## 8. Worked examples

| Request | Split |
|---|---|
| "Add a loss model to the FE package" | Lead: define the interface and the acceptance tests. Runner: find every caller of the old loss function, and extract reference numbers from the paper's tables with page numbers. Engineer: write the kernel, its unit tests and the integration (critical), re-opening the paper for the reference numbers. Drafter: validation and plotting script from the Engineer's spec, then Engineer review. Lead: read the kernel diff. |
| "Why did the suite get slow?" | Runner: run the suite with timing, tabulate the top 20. Engineer: profile the top 3, confirm the cause, fix it. Lead: decide whether the fix is worth the behaviour change. No Drafter unless the user wants a write-up. |
| "Survey the literature on X" | Runner per paper: facts only, in a fixed table, with page references. Drafter: synthesise, reconcile conflicts, draft the survey. Lead: re-open the sources behind the claims the survey rests on, set the framing. No Engineer. |
| "Rename `foo` to `bar` across the repo" | Engineer: scripted rename, run tests, report. One worker, no review chain. |
| "Fix this bug in the mesher" | Engineer: reproduce, fix, add the regression test, verify, spawning a Runner for callers if needed. Lead: read the diff if the mesher is on the critical list. |
| "What does `load_mesh` return?" | Lead reads the function. No spawn. |
| "Should we move to a monorepo?" | Runner: inventory repos, sizes, cross-dependencies. Drafter: options memo with trade-offs and a recommendation. Lead: decide. No Engineer. |

## 9. Anti-patterns

- The Lead reading forty files to answer a locating question. Spawn a Runner.
- The Lead spawning a Runner to read one file it could have opened itself.
- An Engineer "reviewing" by skimming. Run it, read the diff, write the paragraph.
- A Drafter writing a numerical kernel because nobody said it was critical. The brief must say.
- Handing ordinary code to a Drafter "to save Opus tokens". A draft that needs a full review
  and a partial rewrite costs more than the Engineer writing it.
- A Runner asked to "investigate and recommend". Runners report, Drafters recommend, the Lead
  decides.
- Citing a number a Runner extracted without opening the source.
- A spawn with no tier: a non-`tier-*` agent type and no `model`.
- Handing a reviewer your hypothesis. Give the code and ask for an independent read.
- Two writers in the same files at once.
- A third retry of the same brief on the same tier.
