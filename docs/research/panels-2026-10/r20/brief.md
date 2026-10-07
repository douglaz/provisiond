# Panel brief: a throttled read after an accepted create (2026-10-06)

You are one of four independent reviewers. The working directory is a throwaway clone of the
specification repository `provisiond-spec` at commit `3e4b6fa` (numbered Markdown requirements,
ADRs in `docs/adr/`, glossary `CONTEXT.md`, Lean in `tools/formal/`, beads readable with
`br show <id>` if `br` is on PATH). Read `AGENTS.md` first. Do not edit tracked files; you may write
scratch files, run the gates, and fetch public provider documentation. Search the Markdown with
whitespace normalised. This owner repeatedly shows my framing wrong with a first-principles question
and dissolves machinery rather than tuning it; check this framing too, and verify every fact I state
before relying on it.

## Settled today (do not re-litigate)

- `ADR-0033`: a machine's first billing unit is prepaid machine time.
- `ADR-0034`: refresh answered from cache; reverse-DNS ceilinged; the provider request limit is a
  declared budget with a reserve for `OPS-39` episodes, `OPS-27` resolution and the `OPS-32` sweep;
  admission is decided once per operation, before its first provider call, and a later request of an
  admitted operation is never refused locally.
- Retrying a throttled operation on a timer stays rejected (`F48`).

## The defect (found by the previous panel, `/var/tmp/provisiond-panel-r19/synthesis.md`, "T1")

Hetzner Cloud: the worker sends `POST /servers`; the provider creates the server and returns its id
and a create action. The worker polls the action; that read gets `429` (bucket empty: an attacker
drained it, or anything else on the project spent it). `PRV-5` maps it to `rate_limited`. `OPS-11`'s
create row is `needs_reconciliation` only "if the failure is *ambiguous*", and the ambiguity list is
`network`, `timeout`, `internal`, a cut-off `conflict`, or a 5xx; "A 4xx generally means the provider
rejected the request and did not act". So the create settles `failed`, `LDG-32` releases the
commitment, and the machine runs with the tenant's key while the operator pays. Any 4xx on a
follow-up read does the same: `404` while the new server is not yet visible (`PRV-36`), `401` after a
token rotation. `PRV-11` covers only a poll *timeout*. `OPS-45` deliberately excludes `create` from
its dispatch markers ("a create's own execution *cannot* tell you what happened"). `F48` says the
eligibility fact "no mutating request of this operation has been sent" is "a fact only the driver
has (`PRV-5`), and no requirement obliges a driver to report it".

## The options put to the owner

- **(a)** `PRV-5`: every driver error carries `details.dispatched`, true once the operation's
  mutating request was sent. `OPS-11`'s create row: any failure with `dispatched` true is
  `needs_reconciliation`, whatever its kind; `OPS-27`'s correlator search then attaches the machine
  to its tenant or resolves it absent. Other kinds unchanged (they have `OPS-45`'s marker).
- **(b)** Only `rate_limited` after the order is ambiguous (one sentence).
- **(c)** A durable dispatch marker on `create`, like `OPS-45`'s.

My recommendation: (a).

## What I want from you

1. **Is the defect real as written?** Trace one Hetzner Cloud create and one Robot create (order then
   transaction poll) through `PRV-5`, `PRV-11`, `PRV-32`/`PRV-33`, `OPS-11`, `LDG-32`, `LDG-39`. Does
   anything already catch the live machine afterwards (`OPS-32`'s sweep, `OPS-36` late attach,
   `OPS-33`)? Who pays, for how long, and does the tenant keep root on it? Cite lines.
2. **Where is (a) wrong?** What does "sent" mean when the connection dies mid-request (already
   ambiguous by kind?) or when a driver sends several mutating requests (Robot key upload then order;
   `PRV-9`'s temporary key)? Does a create held in `needs_reconciliation` lock the tenant's
   commitment, and can an attacker use (a) to manufacture reconciliations that cost the operator
   attention, request budget, or `OPS-33` windows? Does (a) collide with `ADR-0014`/`ADR-0017`
   (placed once, one correlator), `OPS-36`, `LDG-39`'s fee table, `WIR-35`?
3. **The other kinds.** I claimed power, reverse-DNS, delete and release attachment are fine because
   `OPS-45`'s marker records dispatch. Is that true? `OPS-11` classifies them by error kind too, and
   `05-persistence.md`'s `write_started_at` note says non-null "does NOT mean `not_applied` is
   unrecordable". Find any kind where a 4xx after dispatch releases money or stops a meter while the
   provider acted (release attachment and `LDG-32`'s "every billable attachment … has stopped billing"
   are the first place to look).
4. **A third shape?** E.g. the driver classifies (a 4xx on a read after a 2xx mutation is never a
   rejection of the mutation), or the classification keys on "the mutating request returned 2xx"
   rather than "was sent". Which is smaller and closes more?
5. **Formal layer:** does any declaration in `tools/formal/` (`Claim`, `Reconcile`, `Tables`) encode
   `OPS-11`'s create row or the ambiguity list? Name what (a) would change.
6. **The strongest "don't build this".**

## Output

At most 900 words, no preamble: verdict (a), (b), (c) or a named other in one line; why in one
paragraph; every defect in my framing with `file:line`; any other kind with the same hole; the
requirement ids and declarations the chosen answer edits.
