# Model Tiering (always on)

Full method: skill `model-tiering`. Load it before the first spawn of any task that will use subagents.

| Tier | Spawn as | Model | Does |
|---|---|---|---|
| Lead | (the session) | `fable` | Strategy, decomposition, briefs, critical review, final message. Never bulk reading. |
| Engineer | `tier-engineer` | `opus` | Code owner and **default author of all code**. Critical edits itself, always. Reviews and lands the minority Sonnet/Haiku drafted. |
| Drafter | `tier-drafter` | `sonnet` | Non-core thinking work: synthesised investigations, preliminary reports and memos; peripheral scripts and extra test cases only from a complete spec. |
| Runner | `tier-runner` | `haiku` | Single-answer work: file exploration, raw data reading, one-page fetches, mechanical edits from a complete spec, trivial test scaffolds. |

Effort split as a reference: Opus ~60%, Sonnet ~20%, Haiku ~20%. If it is code someone will run, cite or build on, Opus writes it.

If the session runs on Opus, the session is both Lead and Engineer, and a critical edit is verified and its diff shown to the user in place of the Lead read. If you were spawned as a subagent, you are a worker, not the Lead: follow your brief and your tier's contract, and ignore the Lead duties here.

Non-negotiable:
- Every `Agent` spawn names its tier: a `tier-*` agent type (model pinned in its definition), or an explicit `model` on any other agent type. Unset means the Lead's model does Runner work.
- Nothing Sonnet or Haiku wrote lands without an Opus review report (read, run, one paragraph on why it is right).
- Critical edits (numerics, data formats, security, public API, build/packaging/CI, git operations that change state, anything to be cited, anything a brief marks critical) are Opus's own hands, then a Lead read.
- Facts from Sonnet or Haiku that will be cited or decided on come with a source, and the tier that uses them re-opens that source.
- Cheap tiers report facts and flag uncertainty. They do not decide. Sonnet recommends. The Lead decides.
- Sonnet vs Haiku: could two careful people disagree about the output, or must intent be inferred? Then Sonnet. Otherwise Haiku. Unsure: Haiku probe first, re-brief to Sonnet on ambiguity.
- Brief every worker with a goal and a checkable acceptance criterion, scope in and out, what is already known, whether it is critical, the do-nots, and for a non-`tier-*` agent the return format. Reviewers get code, not conclusions.
- Do not delegate what is cheaper to do: a known target and a handful of tool calls is the Lead's own work, unless the edit is critical.
