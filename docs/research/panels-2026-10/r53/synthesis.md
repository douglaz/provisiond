# Panel r53 synthesis — triage of `pv-d21`, the rollout of `machines.declared_cancellation_bound`, 2026-10-16

Readers: fable (claude-fable-5-1, xhigh), opus (claude-opus-5-5, xhigh), astra (gpt-6-astra, high), sol
(gpt-6.1-sol, xhigh); clones at `02ed28a`. All exit 0. The brief waived the gates (a text question; green at
`02ed28a`).

## Does the text settle both halves?

- **Rows written before the column: settled, all four.** The `machines` row says "a null value MUST contribute
  no earliest-date term" (05:261), and `STO-13`'s "nullable in the release that adds it and tightened after a
  backfill in a later one" (05:1376-1377) requires no backfill (fable).
- **Attach cannot fail under `OPS-23`, all four.** `OPS-23` repeats validation "before the driver is called"
  (03:1623-1624); every writer the column row lists runs after the order landed, `OPS-27` says "Attach it and
  complete the operation as though it had succeeded" (03:470), and "Resolution transitions out of
  `needs_reconciliation` are made by no worker" (03:95; astra, sol).
- **Whether an absent snapshot member copies as null: split.** fable and opus read the copy rule plus
  `OPS-27`'s attach as giving null. astra and sol say "MUST be copied from the create's `request_summary` offer
  snapshot" (05:261) gives no result when the member is absent, and the null rule says how to read a null, not
  that absence becomes one.
- **Before dispatch: not settled, all four.** `OPS-23` says "Validation that was performed at the API boundary
  MUST be repeated in the worker before the driver is called", and `API-7`'s refusal covers an offer "not
  sellable under `PRV-13b` or `PRV-31`" (04:266-267). So the worker repeats the sale check, and no sentence names
  what it reads. Reading the snapshot makes the missing bound "a deterministic failure in the worker"
  (03:1625-1627); reading the live offer lets the create proceed to a null copy. Both outcomes cost no money:
  nothing has been ordered (fable, opus). `invalid_request` is not on `OPS-11`'s admission-only list (03:234-238),
  so a worker may emit it (opus). The same open input affects `PRV-13b` (opus).

## Is a null copy priced exactly?

All four: yes for every bound accepted under `PRV-31`'s v1 rule (02:547-549), because `LDG-33` prices the term
"only if later than provider-local today" (12:354). A late or operator attach cannot make a past date future, and
`CNF-356` already asserts zero for the `WIR-35` attach (10:3673). A successful post-order read fills
`earliest_cancellation_date`, so the fallback is not read; after a failed read either value leaves a deviation
unpriced, and Q25 says "Cost past the declared bound is operator-borne" (`ADR-0037`:294). `STO-13`'s stop stops
processes, not queued rows. Lifting the v1 rule later changes no bound already accepted, and the copy is "never
re-resolved afterwards" (05:261).

Not exact, each needing a deployment that ran without the column:
- a create admitted by an `api` that predates Q25 (fable, opus);
- a rollback to a pre-column binary (05:1394) from a release that both adds the column and lifts the v1 rule
  (opus);
- a missing copy once future-bound sales are allowed; `CNF-356` contrasts an injected future copy with a null
  one (10:3715-3724; astra, sol).

`impl-report-01.md` says "no implementation was produced"; `README.md` says "specifications only" (line 6) and
"code that never compiled and never ran" (lines 111-112). That no deployment exists elsewhere is the owner's
fact (astra).

## Claims in the brief that the readers broke

1. "Before dispatch, nothing in the worker reads the bound": all four. `OPS-43`'s list of fields is not the whole
   of the repeated validation; `OPS-23` also repeats `PRV-31`'s sale check, input unnamed.
2. `billing_unit_seconds` as precedent: opus. Its seconds are on `OPS-43`'s must-hold list (03:673-675), so a
   create without them fails before dispatch; the bound is not on that list. sol and astra add that both
   precedents set a null-read rule, not an absent-copy rule. `install_strategies` still serves (opus).
3. "Already specified" for the attach copy: astra, sol (above).

## Picks

| Reader | Pick | Lands on |
|---|---|---|
| fable | (A) `wontfix`, already specified; the release that lifts the v1 rule owns the line that existing null rows were sold under it | nothing |
| opus | (D) `wontfix` as **unreachable**, not as already specified; drop the `billing_unit_seconds` precedent; what `OPS-23`'s repeated sale check reads is a separate bead, since it reaches `PRV-13b` too | nothing; new bead |
| astra | (B) one sentence: "an absent snapshot bound MUST be copied as null on every attachment path named here, and machine rows predating the column MUST retain null", leaving queued creates under `OPS-23` | the `machines.declared_cancellation_bound` row |
| sol | (B) one sentence: "When a previous release recorded no declared cancellation bound at admission, migration and any subsequent attach MUST leave this column null." | the `machines.declared_cancellation_bound` row |

## Strongest case for the other side (written on request — not the readers' positions)

- fable, for (B) at `OPS-23`: the pre-dispatch gap is live text, and the exactness argument leans on a fact the
  repo never records (nothing shipped before Q25). Its sentence: "A field no check before dispatch reads,
  `declared_cancellation_bound` among them, is copied at attach as the snapshot holds it, null included, and is
  not this failure."
- opus, for (B) at `OPS-23`: the set says what happens when an older `api` omits the seconds and leaves the bound
  to the implementer, so two conformant engines differ. Its sentence: "A create whose snapshot lacks the declared
  cancellation bound MUST NOT be failed for its absence; the `machines.declared_cancellation_bound` row prices the
  null."
- astra, for (A): nullable storage, mandatory attach and the null rule already make null the natural reading,
  and v1 pricing is unchanged.
- sol, for (A): "specifications only" and "code that never compiled and never ran" remove any present rollout
  need.

Every `file:line` above was checked against `02ed28a`.

**Owner decision, 2026-10-16:** opus's (D). `pv-d21` closed `wontfix` as unreachable; what `OPS-23`'s repeated
sale check reads is `pv-hsm`.
