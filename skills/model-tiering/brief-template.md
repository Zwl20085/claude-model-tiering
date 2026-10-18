# Subagent brief template

Copy, fill every line, delete nothing. Set `model` on the Agent call to the tier chosen.

```
TIER: haiku | sonnet | opus
CRITICAL: yes | no        (yes => opus only; a sonnet/haiku worker that finds itself in
                           critical territory stops and reports instead of continuing)

GOAL
  One sentence. Acceptance criterion stated so the worker can check it alone:
  "returns a table of ...", "all tests in tests/x pass", "diff touches only ...".

SCOPE
  In:  <files / dirs / URLs / data>
  Out: <what must not be touched or read>

ALREADY KNOWN (do not re-derive)
  - ...
  - ...

DO
  1. ...
  2. ...

DO NOT
  - do not refactor beyond the goal
  - do not install packages
  - do not edit tests (or: do not edit anything except tests)
  - do not summarise raw numbers; return them

RETURN
  - <facts as a table | findings as a list | diff + exact test command + pasted output>
  - "Open questions": anything ambiguous, inconsistent, or assumed. Empty is a valid answer.
  - For code: one paragraph on why it is correct, and what you did not test.
```

## Return formats by tier

**Haiku**
```
RESULT
| item | value | source (file:line or URL) |
COULD NOT READ / INCONSISTENT
- ...
```

**Sonnet**
```
DRAFT:        <path(s) or inline>
EXERCISE:     <exact command>
WEAK POINTS:  - ...
CRITICAL?:    stayed clear | touched <what>, stopped at <where>
OPEN QUESTIONS: - ...
```

**Opus**
```
LANDED:       <diff summary, files>
VERIFIED:     <command> -> <pasted output tail>
REVIEWS:      one paragraph per sonnet/haiku artefact: accepted as-is | rewrote <what> because <why>
FOR FABLE:    strategy questions, scope changes proposed, risks
```
