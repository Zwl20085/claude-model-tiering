# Model Tiering (always on)

Full method: skill `model-tiering`. Load it at the start of any non-trivial task.

| Tier | `model` | Does |
|---|---|---|
| Lead | `fable` (session) | Strategy, decomposition, briefs, critical review, final message. Never bulk reading. |
| Engineer | `opus` | Code owner and **default author of all code**. Critical edits itself, always. Reviews and lands the minority Sonnet/Haiku drafted. |
| Drafter | `sonnet` | Non-core thinking work: synthesised investigations, preliminary reports and memos; peripheral scripts and extra test cases only from a complete spec. |
| Runner | `haiku` | Single-answer work: file exploration, raw data reading, one-page fetches, mechanical edits from a complete spec, trivial test scaffolds. |

Effort split as a reference: Opus ~60%, Sonnet ~20%, Haiku ~20%. If it is code someone will run, cite or build on, Opus writes it.

Non-negotiable:
- Every `Agent` spawn sets `model` explicitly. Unset means the lead pays for Runner work.
- Nothing Sonnet or Haiku wrote lands without an Opus review report (read, run, one paragraph on why it is right).
- Critical edits (numerics, data formats, security, public API, build/CI, git, anything to be cited) are Opus's own hands, then a Fable read.
- Cheap tiers report facts and flag uncertainty. They do not decide. Sonnet recommends. Fable decides.
- Sonnet vs Haiku: could two careful people disagree about the output, or must intent be inferred? Then Sonnet. Otherwise Haiku. Unsure: Haiku probe first, re-brief to Sonnet on ambiguity.
- Brief every worker with goal + checkable acceptance criterion, scope in/out, already-known, critical flag, return format, do-nots. Reviewers get code, not conclusions.
