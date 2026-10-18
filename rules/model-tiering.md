# Model Tiering (always on)

Full method: skill `model-tiering`. Load it at the start of any non-trivial task.

| Tier | `model` | Does |
|---|---|---|
| Lead | `fable` (session) | Strategy, decomposition, briefs, critical review, final message. Never bulk reading. |
| Engineer | `opus` | Code owner. Critical edits itself. Reviews and lands every Sonnet/Haiku draft. |
| Drafter | `sonnet` | Drafts needing understanding: code, tests, analysis scripts, synthesised investigations, preliminary reports for Opus. |
| Runner | `haiku` | Single-answer work: file exploration, raw data reading, one-page fetches, mechanical edits from a complete spec, trivial test scaffolds. |

Non-negotiable:
- Every `Agent` spawn sets `model` explicitly. Unset means the lead pays for Runner work.
- Nothing Sonnet or Haiku wrote lands without an Opus review report (read, run, one paragraph on why it is right).
- Critical edits (numerics, data formats, security, public API, build/CI, git, anything to be cited) are Opus's own hands, then a Fable read.
- Cheap tiers report facts and flag uncertainty. They do not decide. Sonnet recommends. Fable decides.
- Sonnet vs Haiku: could two careful people disagree about the output, or must intent be inferred? Then Sonnet. Otherwise Haiku. Unsure: Haiku probe first, re-brief to Sonnet on ambiguity.
- Brief every worker with goal + checkable acceptance criterion, scope in/out, already-known, critical flag, return format, do-nots. Reviewers get code, not conclusions.
