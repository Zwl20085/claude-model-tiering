# claude-model-tiering

A standing four-tier delegation pattern for [Claude Code](https://claude.com/claude-code):
the expensive model thinks, the mid model owns the code, the cheap models read, fetch and draft.
Shipped as a **skill** (the full method) plus an **always-on rule** (the one-screen version),
so every session on the machine follows it without being asked.

Used daily since mid-2026 on research code (FE solvers, PCB design, paper pipelines) and ordinary
software work. Swap the model names if your account has different tiers; the shape is what matters.

## The pattern

| Tier | Model | Role |
|---|---|---|
| **Lead** | Fable (session model) | Strategy, decomposition, briefs, critical review, final answer. Never bulk reading. |
| **Engineer** | Opus | Owns the code and writes most of it: default author for any edit, sole author for critical ones. Reviews and lands the minority the lower tiers draft. Asks the Lead for strategy, never guesses it. |
| **Drafter** | Sonnet | Non-core thinking work: multi-source investigations with synthesis, preliminary reports and memos; peripheral scripts and extra test cases only from a complete spec. |
| **Runner** | Haiku | Single-answer work: file exploration, raw data reading, single-page fetches, mechanical edits from a complete spec, trivial test scaffolds. |

Reference split of delegated effort: **Opus ~60%, Sonnet ~20%, Haiku ~20%**. If it is code someone will
run, cite or build on, Opus writes it. The saving comes from Haiku doing the reading and Sonnet doing
the non-code thinking, not from cheaper authorship.

Chain of custody:

```
Haiku result  -> Sonnet (only if ambiguity flagged) -> Opus review -> lands
Sonnet draft  -> Opus review (always)               -> lands
Opus edit     -> Lead review if critical, else self-verified and reported
Lead decision -> user
```

Three rules do most of the work:

1. **Every subagent spawn sets `model` explicitly.** Unset inherits the lead, so Runner work silently burns Lead tokens.
2. **Nothing a cheap tier wrote lands without an Opus review report**: read it, run it, one paragraph on why it is right.
3. **Critical edits are Opus's own hands, then a Lead read.** Critical = numerics, data formats, security, public API, build/CI, git, anything to be cited.

The Opus/Sonnet line: *will someone run, cite or build on this code?* Then Opus. Sonnet gets code only
when it is peripheral and the spec leaves no design decisions.

The Sonnet/Haiku line: *could two careful people disagree about the output, or must intent be inferred?*
Then Sonnet. Otherwise Haiku. Unsure: a cheap Haiku probe first, re-brief to Sonnet on ambiguity.

## Install

```powershell
# Windows
git clone https://github.com/Zwl20085/claude-model-tiering
.\claude-model-tiering\install.ps1
```

```sh
# macOS / Linux
git clone https://github.com/Zwl20085/claude-model-tiering
./claude-model-tiering/install.sh
```

This copies:

- `skills/model-tiering/` to `~/.claude/skills/model-tiering/` (invoke with `/model-tiering`, or Claude loads it itself at the start of non-trivial tasks)
- `rules/model-tiering.md` to `~/.claude/rules/common/model-tiering.md` (loaded into every session automatically)

Project-only install: copy the same two things into `<repo>/.claude/skills/` and `<repo>/.claude/rules/` instead.

## Files

```
skills/model-tiering/SKILL.md          full method: roles, escalation, briefing, mechanism choice, worked examples, anti-patterns
skills/model-tiering/brief-template.md the brief every worker gets, and the return format each tier owes
rules/model-tiering.md                 one-screen always-on version
install.ps1 / install.sh               copy into ~/.claude
```

## Why this shape

- The lead's context is the scarce resource. Reading forty files to locate one function is Runner work.
- Review is cheaper than rework, but only if it is real: run it, diff it, say why it is right.
- Cheap models are excellent at tasks with one right answer and poor at tasks that need intent inferred. The Sonnet/Haiku split follows that line rather than "size of task".
- A brief the lead cannot write clearly is a task the lead does not understand yet. Decompose first.

## License

MIT
