# claude-model-tiering

A four-tier delegation pattern for [Claude Code](https://claude.com/claude-code). The session
model leads, Opus writes and owns the code, Sonnet does non-code thinking and peripheral drafts,
Haiku does reading, finding and mechanical edits. It ships as an always-on rule, a skill with the
method, and three subagent definitions with the model pinned for each worker tier.

| Tier | Spawned as | Model | Does |
|---|---|---|---|
| Lead | (the session) | Fable | Strategy, decomposition, briefs, critical review, final message |
| Engineer | `tier-engineer` | Opus | Writes the code, all critical edits, reviews and lands lower-tier drafts |
| Drafter | `tier-drafter` | Sonnet | Investigations, memos, reports; peripheral code from a complete spec |
| Runner | `tier-runner` | Haiku | Locating, reading, tabulating, fetching; mechanical edits from a complete spec |

The rule (`rules/model-tiering.md`) is the one place that holds the full tier table and the hard
rules. The skill (`skills/model-tiering/`) is the procedure for applying them and the brief
templates.

## What gets installed

Into the Claude config directory, which is `$CLAUDE_CONFIG_DIR` if set, otherwise `~/.claude`:

| From | To | Effect |
|---|---|---|
| `rules/model-tiering.md` | `rules/common/model-tiering.md` | Loaded into every session |
| `skills/model-tiering/` | `skills/model-tiering/` | The skill, `/model-tiering` or loaded by Claude when relevant |
| `agents/tier-*.md` | `agents/` | Subagent types `tier-engineer`, `tier-drafter`, `tier-runner`; the last two cannot spawn agents |

The installer replaces `skills/model-tiering/` as a whole, so files from an older version do not
linger. It does not touch other skills, other agents or anything else in the config directory.

## Install and uninstall

```powershell
# Windows PowerShell
git clone https://github.com/Zwl20085/claude-model-tiering
.\claude-model-tiering\install.ps1
.\claude-model-tiering\install.ps1 -Uninstall
```

```sh
# macOS, Linux, Git Bash
git clone https://github.com/Zwl20085/claude-model-tiering
sh claude-model-tiering/install.sh
sh claude-model-tiering/install.sh --uninstall
```

Both scripts print each path they install or remove, and are safe to re-run. Uninstall removes
only the items listed above. Start a new Claude Code session after either.

If PowerShell refuses to run the script, use
`powershell -ExecutionPolicy Bypass -File .\claude-model-tiering\install.ps1`.

Project-only install: copy the same three things into the repository's own `.claude/` directory
(`.claude/rules/`, `.claude/skills/model-tiering/`, `.claude/agents/`) instead of running the
installer. A project-level agent definition overrides a user-level one with the same name, which
is also how to give one project different models.

## Using other models

The worker models are set in two places that should agree:

- the `model:` line in the frontmatter of each `agents/tier-*.md`, which is what Claude Code uses
  when it spawns that agent;
- the tier table in `rules/model-tiering.md`, which is what the Lead reads.

The Lead is whatever model the session runs. If the session runs on Opus, the rule tells it to act
as Lead and Engineer at once. The skill's prose refers to Opus, Sonnet and Haiku by name; if you
swap models, those names become labels for the tiers rather than the literal models.

Without the agent files installed, the pattern still works through ordinary agent types with
`model` set on each spawn. The skill describes that fallback.

## Why this shape

- The Lead's context is the scarce resource. Reading forty files to find one function is work a
  cheaper model does as well.
- Code is not done as well by a cheaper model, so Opus writes it rather than reviewing someone
  else's attempt. The saving comes from Haiku reading and Sonnet doing non-code thinking.
- Pinning each worker's model in an agent definition means a spawn cannot silently inherit the
  Lead's model, and the worker's contract and return format travel with it instead of being
  pasted into every brief.
- Review only helps when the author and the reader are different and the review is real: run it,
  read the diff, say why it is right.

## License

MIT
