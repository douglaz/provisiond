# Panel brief: triage of bead pv-k4l (an interrupted create that ordered nothing goes to an operator), 2026-10-17

You are one of four independent reviewers. The working directory is a throwaway clone of the
specification repository `provisiond-spec` at `96ce45c` (branch `post-pr6-notes`: master `1292174` plus bead
comments). Read `AGENTS.md` first. `br show pv-k4l` prints the bead; `br comments pv-k4l` prints its one
comment (the PR #6 codex finding plus two triage inputs). Do not edit tracked files; write scratch files only
inside this clone (never `/tmp` or `/var/tmp`). This is a text question; you need not run the gates (green at
`1292174`). Never call a provider API. This owner often shows my framing wrong with a first-principles
question; check this framing too, and verify every fact below before relying on it.

## Settled and off-limits

- `pv-14b`'s claim order in `OPS-43` (03:681-708; panels r55/r55b, owner decisions 2026-10-16/17),
  including the correlator entry at step 8 in `API-63`'s transaction. If you think the entry must move
  earlier, say so as shape (d) below and say what it costs; don't assume it.
- `ADR-0035`'s acceptance rule and `details.accepted` (`PRV-5`).
- How a *classified* failure of the step-4 List offers read is classified is `pv-qga`'s question. Question 5
  asks only how the two beads relate.

## The story

A create is claimed. Steps 1-7 run: account read, closure read, field checks, one List offers read (step 4),
sale re-test, price comparison, driver validation. The engine restarts (deploy, OOM) during step 4. Nothing
was ordered and no key was uploaded: step 9 holds every provider mutation. On restart the create goes to an
operator and the customer's commitment stays held until `OPS-33` releases it, which on Robot is bounded by
operator response time (`PRV-33`, 02:1036-1038). The spec defines no graceful shutdown.

## Facts I rely on (verify each)

1. `OPS-15` (03:347-352) moves "every `running` operation to `needs_reconciliation`". It has a `refresh`
   exception that settles `failed` with `internal` (03:375-380) and a `suspend_tenant` exception (03:382-391)
   that "does not fire on a restore" (03:363). `STO-3`'s startup-pass bullet (05:42-45) is guarded `(id, status =
   running)` with no claim term.
2. `OPS-38` (03:627-628): "A create that recorded none has no count: `OPS-27`'s row for 'no verified
   correlator exists for the operation's ordering channel' applies, and it is **Unresolved**." `OPS-27`'s last
   row (03:473): "Escalate to an operator"; "Released per `OPS-33`". `OPS-29` (03:1256-1257).
3. `OPS-45` (03:1334-1343) "does **not** reach `create`", and warns that unscoped, "the marker is unset, so
   settle `failed`" would settle every ambiguous create as a deterministic failure. Its settle rule
   "classifies a failure a worker recorded; an operation interrupted rather than classified is `OPS-15`'s,
   whatever the markers hold" (03:1385-1387). Its marker writes are "guarded like any other worker write
   (`STO-3`)", "each acknowledged by the store before the provider call it precedes is made" (03:1439-1447).
4. On a `correlator: none` channel (`PRV-33`, 02:1022-1028; Robot standard, `PRV-32` 02:964-965) no text
   says what step 8 writes into `operations.correlator_kind`/`correlator_value` (05:382: "what the create
   wrote into the provider"). So a null pair cannot alone prove "not dispatched" there.
5. `API-63` (04:1414-1431) already uses the entry as a dispatch test: "the correlator entry is what tells the
   termination which case it is: a claimed create with no entry has not passed the conditional-write check
   and does not dispatch", and "A claimed create with an entry MUST be treated as potentially dispatched".
   Fact 4's gap reaches this sentence too.
6. I found no text forcing step 8's *operation-row* write to be durably acknowledged before step 9, or to
   carry `STO-3`'s worker guard. `STO-3` lists "every settled-state write, and a worker moving its own
   operation into `needs_reconciliation`" (05:20-21). `PRV-26` says "before the order is sent" (02:871-872).
   `OPS-47` (03:136-141): "where two engines run, nothing here refuses the second". Check.
7. On a restore, a `running` create with no entry in the restored store may have passed step 8 and ordered
   inside the lost interval (`STO-54`, `OPS-15` 03:354-366).
8. Prior rejection, no `.out-of-scope/` exists. `ADR-0035` rejected "A durable dispatch marker on create,
   like `OPS-45`'s", because "its marker cannot tell a key upload from an order or a rejection from an
   acceptance" (adr/0035:59-61). Its 2026-10-08 amendment rejected "settling a pre-send `network` failure as
   `failed` (a behaviour change beyond the question)" (adr/0035:107). My reading: the first rejects using a
   *set* marker to decide ambiguity; pv-k4l reads only the *unset* case, before any dispatch. The second was
   scoping, not merits.

## Shapes

- (a) A new create marker, written in step 8's transaction on every channel, never cleared (comment 2).
- (b) No new column: step 8 always writes `correlator_kind`, with a `none` value on a `PRV-33` channel. It
  also repairs fact 5.
- (c) Wontfix: the window is seconds, and `OPS-31`'s `absent` verb lets the operator release it in one act.
- (d) Anything else, including moving the entry earlier.

Home for the settlement: an `OPS-15` startup exception like `refresh` (restart only, never on a restore), or
an automatic resolved-absent in `OPS-27`/`OPS-38` on engine evidence, which keeps `OPS-45`'s
"interrupted ... is `OPS-15`'s" uniform.

## What I need from you

1. **What the text forces today** for the story, quoted. Confirm or break facts 4-6.
2. **Soundness:** what must hold for "no step-8 record" to prove "no provider mutation" across a crash, an
   overtaken worker and a restore? Which of these does the text already force, and which must the fix add?
3. **Your pick** of shape and home. Name the identifiers it lands on. Give the settled error kind,
   `retryable`, the `OPS-11` reading and the `LDG-39` row. Say how `API-63`'s sentence changes, if it does.
4. **`ADR-0035`:** does your pick escape its rejected alternative? Is a new ADR or an `ADR-0035` amendment
   needed?
5. **`pv-qga`:** a step-4 timeout parks under `OPS-11`'s literal rule, while under your pick an interruption
   in the same read may settle `failed`. Should the two be decided together, should one depend on the other,
   or should they merge?
6. Then, labelled "Strongest case for the other side (written on request)", the best argument against your
   pick. It is not your position.

Under 800 words. Cite `file:line` or identifiers for every claim.
