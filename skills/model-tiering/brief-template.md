# Brief templates

Pick the size that fits the piece. The `tier-*` agents already know their contract and return
format, so neither template repeats them.

## Probe

For a Runner lookup with one right answer. Write it as two or three plain sentences.

```
Agent(subagent_type: "tier-runner", description: "Find compute_loss callers", prompt:
  "Find every call site of `compute_loss` under src/ and tests/. I already know it is defined
   in src/fe/loss.py. Return file:line and the enclosing function for each, and say so if any
   call goes through an alias or a getattr.")
```

It has the question, where to look, what is already known, and what to return. Nothing else.

## Full brief

For anything that writes, synthesises, or runs longer than a lookup. Fill every heading. If a
heading has nothing under it, say "none" so the worker knows it was considered.

```
CRITICAL: yes | no
  (yes means tier-engineer only. A drafter or runner that finds itself in critical territory
   stops and reports.)

GOAL
  One or two sentences: what this is for and what done looks like. State the acceptance
  criterion so the worker can check it alone: "returns a table of ...", "all tests in tests/x
  pass", "the diff touches only ...".

SCOPE
  In:  <files, dirs, URLs, data>
  Out: <what must not be touched or read, and other workers' files if any run in parallel>

ALREADY KNOWN
  - <what you have established or ruled out, so the worker does not re-derive it>

HARD PART
  <the one thing a smart newcomer would get wrong here, if there is one>

DO NOT
  - <the two or three things that would waste the run: refactoring beyond the goal,
     installing packages, editing tests, committing, summarising raw numbers>

RETURN
  <only what differs from the tier's standard return, for example a fixed table schema>
```

For a review, give the reviewer the diff or the paths, the acceptance criterion and the test
command. Leave out what you think of the code.

## Return blocks for agents without a tier contract

When the worker is not a `tier-*` agent (for example `Explore` or `general-purpose` with
`model` set), paste the matching block into the brief.

Runner work:
```
Return:
RESULT
| item | value | source (file:line, URL or page) |
COULD NOT READ / INCONSISTENT
- ...
OPEN QUESTIONS
- anything ambiguous or assumed (write "none" if none)
Do not interpret or recommend. If you would have to assume something, list it under open
questions instead of acting on it.
```

Drafter work:
```
Return:
DRAFT:          <paths, or inline>
EXERCISE:       <the exact command that runs it and its pasted output, if it is code>
SOURCES:        <for every factual claim: file:line, URL or page>
WEAK POINTS:    - ...
CRITICAL:       stayed clear | touched <what>, stopped at <where>
OPEN QUESTIONS: - ...
```

Engineer work:
```
Return:
CHANGED:   <files and a short summary of the diff>
VERIFIED:  <command> and its pasted output
REVIEWS:   one paragraph per lower-tier artefact: accepted as is | rewrote <what> because <why>
NOT DONE:  <anything skipped or untested>
FOR LEAD:  strategy questions, proposed scope changes, risks
```
