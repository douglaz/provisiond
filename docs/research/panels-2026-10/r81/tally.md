# r81 tally — B settled for referral; no adoption

**apply notes.md rule 6 exactly as written; this prompt adds no void rule.**

Review pin: `c824e4fa4d612b231110bc5deb3e88b3b3e90f92`. Inputs are the complete [brief](brief.md), [notes](notes.md), and complete final [fable](fable.md), [opus](opus.md), [astra](astra.md), and [sol](sol.md) answers. The manager independently located the pinned sources with `rg`, then read them with `sed`. [Source extraction and Git-object equality receipts](/var/tmp/provisiond-manager/r81-tally-yazopglq/source-extraction.txt), [audit](/var/tmp/provisiond-manager/r81-tally-yazopglq/audit.json), and [reproduction script](/var/tmp/provisiond-manager/r81-tally-yazopglq/verify.py) retain that evidence. None of the reader-claim corrections below changes a recorded vote.

## Explicit picks and acceptability

| Reader | Explicit final pick | A as printed | B as printed | Other proposal |
|---|---|---|---|---|
| fable | **B** | CANNOT ACCEPT | ACCEPT | Offers its own B′ conditionally, but its target ordinal is invalid. Describes A′ without a complete ADR replacement. |
| opus | **A** | ACCEPT | CANNOT ACCEPT | Explicitly accepts its complete B′, **not** its final pick. Optional A1 tightening is not a condition of A acceptance. |
| astra | **B** | ACCEPT | ACCEPT | None. |
| sol | **B** | ACCEPT | ACCEPT | None. |

Explicit final-pick tally from this table: **B = fable, astra, sol (3); A = opus (1)**. Acceptability is separate:

| Exact form | ACCEPT set | CANNOT ACCEPT set | No exact-form judgment |
|---|---|---|---|
| [A, complete A1–A9](check/form-A.md), with unchanged STO-56 passages specified there | opus, astra, sol | fable | none |
| [B, exact replacement paragraph](check/form-B.txt) | fable, astra, sol | opus | none |
| [B′-opus, complete alternative](check/form-B-prime-opus.txt) | opus | none | fable, astra, sol |
| B′-fable, [original proposed replacement instruction](check/form-B-prime-fable-proposal.md) | Fable offers it conditionally; **no executable complete form as printed** | none | opus, astra, sol |
| A′-fable | Fable calls it acceptable but supplies **no complete form** | none | opus, astra, sol |
| Opus's optional A1 recovery-complete tightening | No separate final pick or complete-form acceptance | none | all other readers |

Do not merge the B′ proposals. Opus changes the absence predicate and the instant-comparison obligation. Fable proposes only a mismatch-sentence replacement, with an invalid ordinal; it is neither opus's complete form nor acceptance of it. A missing judgment is not rejection. A direction or partial proposal is not a counted complete form.

All participating final answers are substantive and their exit files contain 0. Their hashes, byte lengths, and Codex raw-output comparisons are in `audit.json` under `seats`. None is a usage/session-limit answer. Grok is missing under the prelaunch HTTP 402 receipt in [check/grok-preflight.txt](/var/tmp/provisiond-panel-r81/check/grok-preflight.txt); it contributes no vote. No new Grok call is needed because no further panel is triggered.

## Rule 6 and settlement under rule 2

**No verified brief error changes this question's premise.** The retained-instant/inserting-transaction conflict is real for an aborted first attempt followed by an inserting transaction with a distinct timestamp. A3's small span defect is real: its range includes a blank separator, while the replacement omits it. That is formatting, not a changed clock premise. Fable cites it when rejecting A; opus reports applying the cosmetic range correction while explicitly accepting A. The recorded A form is not silently patched. A9's handling of the dated decision record is a disputed review judgment, not evidence that the underlying clock question is false. The r81 addendum explicitly overrides historical template instance facts. Reader overclaims are not new brief-void conditions.

**Settled: B exactly as printed.** Under rule 2's Grok-down fallback, B has the required three final picks and more picks than the opposed form. A also has three acceptances, but its explicit final-pick set remains opus alone. Preserving the explicit preferences resolves the competing acceptable forms without an invented default or synthesized tie-break. B′-opus has only its author's exact-form acceptance; neither B′ replaces B.

**No verified blocking loss under rule 3 was found for B.** This does not establish that its comparison mechanics are fully specified or erase opus's CANNOT ACCEPT. The full dissent check follows. No consensus round is triggered.

**Settlement is not adoption.** B substantively qualifies owner-adopted P; A would change UO's requirement. Main must take exact B to the owner before any requirement edit or fix Run. The committed pv-ymjo closure does not confer acceptance. The branch remains untouched and the drain held.

## Opus's blocking claim, checked against the exact words

### Reading 1 — mandatory comparison with the repeat's new timestamp: not verified

Opus writes:

> *Reading 1:* the natural upsert compares the repeat's own `transaction_timestamp()`.

and concludes:

> Then every repeat in case (ii) mismatches (t2 ≠ t1) and is refused, every time.

> **This is a verified blocking loss (rule 3).**

The comparator is an added premise. [Exact B](check/form-B.txt) instead requires:

> Repeating establishment with that id when a committed matching record exists MUST affect that record as a guarded no-op, not create or supersede another record, preserving its step marks and original restore instant.

The retained [STO-54 definition](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/05-persistence.md#L1636) says **“restore_instant is transaction_timestamp() of the newly begun transaction inserting this incident.”** A no-op transaction does not insert that incident. The definition does not turn a repeating transaction's timestamp into an expected value for an already committed record.

Concrete trace: T1 inserts N at t1, closes R if present and commits; its reply is lost. T2 at distinct t2 finds committed N. B requires preserving N's original t1 and marks on the matching no-op, then acknowledgement. [STO-54's boundary](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/05-persistence.md#L1632) says **“MUST start neither component until the transaction that commits `STO-56`'s record (below) has been acknowledged”**; B explicitly permits the matching repeat's acknowledgement. No clause orders a comparison of t2 with t1. An implementation that refuses this otherwise matching repeat because t2 differs would violate the explicit no-op duty; it is not a failure forced by B. This is a satisfiable trace through the printed obligations, not adoption of a comparison algorithm.

The pinned [r77b tally](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/docs/research/panels-2026-10/r77/r77b/tally.md#L41) likewise distinguishes an unstated current-open-row comparator from P's required matching no-op. That history corroborates the distinction; the current verdict follows from B's own words.

### Insert/refuse overlap: conditional ambiguity, not a verified unavoidable conflict

Opus writes:

> “finds no committed matching record … MUST insert” also covers a committed N whose predecessor differs. There one MUST says insert and the next says “MUST be refused”.

This identifies a real concern about **matching**. It is not established that this word must mean “matches every asserted field” rather than “matches that id”. B introduces the condition as **“establishment with that id”**, then separately requires refusal for **“A mismatch in the committed id's restore instant or predecessor”**. On an identity match with an actually incompatible predecessor assertion, refusal need not treat the committed id as absent. No pinned definition specifies a full-payload predicate or mandates entering both branches.

With opus's full-payload interpretation the obligations overlap on its mismatch trace. With identity lookup followed by validation they do not. These are rival readings of an unspecified comparison boundary. No unavoidable contradictory MUST or changed conformance/theorem verdict is verified. The manager does **not** replace the condition with opus's clearer “no committed record with that id”, delete the instant arm, select R2, or count a repair as acceptance of B. The ambiguity and dissent stay on record for the owner.

### Reusing a closed id: disclosed collateral concern, not a compliant blocking trace

Opus's reading 2 reuses the id of a closed N for a new actual restore, then accepts a no-op leaving no open incident. Fable raises the same concern in its **requested counterargument**. The unsafe consequence is real if the tool accepts that mistake and skips establishment: [STO-54](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/05-persistence.md#L1759) says **“When no restore record remains open, a process that starts is an ordinary restart”**; [STO-56](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/05-persistence.md#L1426) makes the open row distinguish continuation.

But B retains **“one new incident id per actual restore”** and **“A new actual store restore uses a distinct id even when the predecessor incident is still open.”** The bad trace begins by violating the distinct-id rule and also fails the fresh-incident/provenance obligations. A preserves a separately retained instant that can help detect mistaken reuse; B no longer requires that precommit input. That is a loss of redundant detection and a substantive cost, not permission to start with no open incident. Neither candidate permits skipped initialization.

## Each reader's strongest argument, quoted

These are reasons for the reader's own pick; requested counterarguments do not add or move votes.

**fable → B:**

> It is one paragraph in one file. It keeps the set's single clock: the store's transaction clock, which is also what `LDG-58` acceptance rows and CNF-99's "roll the transaction clock back" rely on.

**opus → A:**

> It keeps the owner-adopted P retry paragraph word for word. It changes only the definition that P's retained instant contradicts.

**astra → B:**

> B’s complete paragraph supplies the missing distinction: absence permits insertion using the inserting transaction’s event; an existing committed record requires a guarded no-op. I prefer its precise database event anchor and preservation of the existing reporting recipe.

**sol → B:**

> I prefer B because it preserves the precise database event definition and confines the policy qualification to establishment retries.

Fable's narrower database-event preference is supported; its universal “single clock” claim breaks below. Opus's preservation preference is supported, including the dependent recipe/documentation changes that A prints.

The common strongest **requested counterargument against B** is substantive: A preserves one selected event through aborted attempts and can yield a tighter upper bound. With certified accurate clocks, selection/aborted attempt at 100, insertion at 200, and no old-history acknowledgement after 100, A can use f=100 and B f=200 although recovered history is identical. Certificates for one clock/event need not certify the other. Opus's **requested counterargument against A** stresses the unnamed selection clock and selection potentially preceding completed recovery. These are tradeoffs, not additional votes.

## Independent factual audit of the picks

All source rows below were located with rg, read with sed, and checked against Git objects; whole excerpts and the independently regenerated consumer inventory are in the evidence linked above.

| Claim relied upon | Source and result |
|---|---|
| Aborted first attempt exposes the pin's contradiction; a committed-first no-op can preserve t1. All readers. | [STO-56](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/05-persistence.md#L1442): **“reuse both on a lost-reply retry”**; [STO-54](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/05-persistence.md#L1636): **“transaction_timestamp() of the newly begun transaction inserting this incident.”** PostgreSQL's [official current-time documentation](https://www.postgresql.org/docs/18/functions-datetime.html#FUNCTIONS-DATETIME-CURRENT) independently confirms transaction-start semantics and within-transaction stability. Distinct transaction values are the trace's explicit assumption. **Verified.** |
| The landed policy is adopted P, not an Implementer departure or a K-EXACT decision. All readers. | Full normalized comparison with [P/C5](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/docs/research/panels-2026-10/r77/r77b/brief.md#L334) matches after wrapping/backticks; the base event paragraph is unchanged. [Owner P answer](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/docs/research/panels-2026-10/r77/owner-decisions.md#L24): **“Adopt P (Recommended)”**. [UO answer](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/docs/research/panels-2026-10/r74/owner-decisions.md#L6): **“Report unknown (UO) (Recommended)”**. [K-EXACT](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/docs/research/panels-2026-10/r78/brief.md#L78) concerns the Startup-lock wait bound. **Verified.** |
| A preserves P's retry words, changes the event and dependent upper-bound recipe; its selection clock is unnamed. Opus/Astra/Sol; fable's substantive objection. | [Exact A](check/form-A.md) leaves STO-56 unchanged. A1 defines pre-first-attempt selection; A2 requires evidence that **“no old-history acknowledgement follows that selection”**. It does not name a specific selection clock. Clock/error provenance is still required. This is a real requirement change even on a successful first attempt. **Verified.** |
| B keeps the inserting-transaction definition/recipe, changes only the retry paragraph, and gives up required precommit instant retention. Fable/Astra/Sol. | [Exact B](check/form-B.txt) versus [STO-54](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/05-persistence.md#L1636). Absent N is inserted with the successful transaction's event; a committed matching N retains its event. **Verified, substantive qualification of P.** |
| B must compare the repeat's new timestamp and necessarily refuses all committed repeats. Opus. | **Not verified: added comparator premise**, traced above. Its claim to be a verified blocker breaks; the refusal vote is preserved. |
| B's insert/refuse overlap is unavoidable. Opus. | **Not verified as unavoidable**; it depends on an unstated full-payload meaning of “matching”. Its ambiguity is preserved, with no implicit repair. |
| Stopping, acknowledgement, null/unknown evidence and endpoint reuse remain mandatory. All readers. | [STO-54](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/05-persistence.md#L1632): **“MUST stop every engine and `api` process”** and the quoted start boundary. [STO-54](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/05-persistence.md#L1647): **“A bound without valid evidence is unknown, not an invented recovery time.”** [STO-54](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/05-persistence.md#L1672): **“Missing reporting evidence does not hold incident creation”** and **“Continuations reuse the persisted endpoints and evidence unchanged.”** [STO-56](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/05-persistence.md#L1453): **“The endpoints and reference MUST be written with the row; continuations MUST NOT recompute them.”** **Verified.** |
| Certificates stay true, though f may widen or become unknown. All readers. | [STO-54](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/05-persistence.md#L1644) requires b to certify inclusion of every earlier acknowledged source-history component commit and f to certify **“no component acknowledged an old-history commit after f”**. It retains **“Known b and f MUST be finite and satisfy b≤f”** and rejects inconsistent evidence. Neither A2 nor B waives those duties. **Verified conditionally on certification, not a guarantee of known endpoints.** Opus's incidental assertion that b≤f “always holds” merely because insertion follows recovery is not independently established; the explicit validation still applies. |
| Atomic supersession, fresh marks, provenance, step-(3) grace and continuation remain intact. All readers. | [STO-56](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/05-persistence.md#L1431): **“MUST close R by supersession and insert a distinct record naming R”**; **“no predecessor step mark satisfies a new step.”** [STO-54](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/05-persistence.md#L1716): **“the acknowledged transaction that establishes the restore record MUST set this column `true`”** on the specified surviving rows. [STO-56](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/05-persistence.md#L1459) writes grace **“as step (3)'s instant plus one re-derivation interval”**. [STO-54](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/05-persistence.md#L1749): **“A marked step does not run again”**, with the instant **“read from the record and never re-computed”**. **Verified.** |
| No extra CNF/WIR/OVR/CONTEXT replacement is forced; neither form changes an existing conformance assertion or negative control. All readers. | The whole-item consumer list is independently regenerated as `audit.json/cnf_inventory`. Its known-bound fixtures still need certificates; unknown fixtures use nulls. [CNF-295](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/10-conformance-checklist.md#L1019) requires grace to use **“its own event, not b, f or restore_instant.”** [OVR-19](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/00-overview.md#L421) requires **“certificates and provenance for any asserted clock-error bounds”**. [WIR-9a](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/13-wire-contract.md#L218) governs marker provenance, not the event clock. [WIR-1](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/13-wire-contract.md#L10) governs timestamp emission precision. **Verified for the printed choices; Q4 remains separate.** |
| The model does not prove SQL selection/retry mechanics; A's formal edits do not change executable meaning, theorem statements or guard hypotheses. All readers. | [Record](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/tools/formal/Provisiond/Restore.lean#L99) and [RestoreTrace](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/tools/formal/Provisiond/Restore.lean#L159) carry Nat values; [store](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/tools/formal/Provisiond/Restore.lean#L169) writes `restoreInstant := t.now`; [afterCrash](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/tools/formal/Provisiond/Restore.lean#L441) retrieves it; [step_three_writes_grace](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/tools/formal/Provisiond/Restore.lean#L555) uses independent `instant`. Exact A's noncomment Lean tokens equal the pin. [ADR-0025](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/docs/adr/0025-a-formalized-clause-lives-in-lean-and-the-markdown-renders-it.md#L39): **“Authority is per clause”**, **“A theorem is never conformance.”** **Verified; compilation proves neither retry policy.** |
| A3 consumes a blank separator; A9 rewrites the dated UO record. Fable/Opus. | [Restore.lean](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/tools/formal/Provisiond/Restore.lean#L21) has the separator. A9 replaces the body of [ADR-0023's dated UO section](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/docs/adr/0023-a-restore-is-a-recovery-incident-and-durability-is-bought-where-there-is-no-second-truth.md#L243). These are real printed-form features. [AGENTS](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/AGENTS.md#L26) says **“Land the rule; write the record after.”** It does not prescribe append-only ADRs or make a future reviewed amendment impossible. Fable's preferred record handling remains a judgment; no r81 owner adoption is fabricated. |
| E-KEEP and pv-kwuf precision remain independent. All readers. | A2 changes the event-side anchor, not [STO-54](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/05-persistence.md#L1651)'s source recipe **“e bounds the source clock's error”**. Neither candidate changes the startup-lock input cell, timeout serialization or wire precision. [E-KEEP](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/docs/research/panels-2026-10/r79/tally.md#L1) adopted no replacement clock-error wording. **Verified; no precision policy added.** |

## Broken or overbroad reader claims

The blocking-claim corrections above are part of this list. None is a reason to void the brief or silently discount an explicit vote.

| Reader claim | Independent result |
|---|---|
| Opus: reading 1 is a “verified blocking loss”; the repeat's own timestamp is its natural comparator. | **Not verified**: the comparator is not required. B explicitly preserves the committed instant; STO-54 refers to the transaction inserting N. |
| Opus: insert/refuse MUSTs necessarily overlap. | **Not verified as necessary**: full-payload “matching” is an added interpretation. Ambiguity remains; neither a fix nor R2 is adopted. |
| Fable: B keeps “the set's single clock”. | **Breaks as a universal.** [STO-54](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/05-persistence.md#L1662) says **“Source and event clocks may have different error bounds; record their provenance.”** [STO-49](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/05-persistence.md#L830) distinguishes acceptance time and **“Observation time remains evidence age, independent of this clock.”** Keeping the precise database-event anchor is a supported narrower preference. |
| Fable: B's instant mismatch arm “has no input and cannot fire” and is necessarily dead text. | **Not established.** Removing mandatory retention does not forbid extra retained/asserted information or validation against the committed row. No supplied input schema or comparator proves universal vacuity. Do not silently delete the MUST. |
| Fable: its B′ replaces B's “seventh sentence”. | **Broken target.** [Enumerated B sentences](/var/tmp/provisiond-manager/r81-tally-yazopglq/B-sentences.json) contain no seventh sentence. The intended mismatch clause is identifiable, but silently repairing the ordinal is not acceptance of a complete exact alternative by the panel. |
| Opus: its negative control proves “A3–A8 are forced by the gate”. | **Overbroad and independently refuted.** Exact A and A with only A3 applied to the Lean file both pass the citation gate; the latter retains A4–A8's unquoted clock descriptions. [Probe receipts](/var/tmp/provisiond-manager/r81-tally-yazopglq/static-probes.json), [A-only-A3 output](/var/tmp/provisiond-manager/r81-tally-yazopglq/A-only-A3-static-citations.log), [retained phrases](/var/tmp/provisiond-manager/r81-tally-yazopglq/clock-searches.json). A3's quotation needs synchronization; the gate does not enforce all descriptive prose. The other docstrings still need editorial synchronization for meaning. The probe uses a pinned retained declaration index and claims citation behavior only. |
| Opus: “the gate doesn't read ADRs”. | **False without qualification.** [Citation gate](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/tools/check_citations.py#L17) uses ADRs as sources, though they are not QUOTED input; its EXISTS corpus includes them. [Identifier gate](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/tools/check_ids.py#L51) reads ADR citations. The narrower limitation is valid: these gates do not establish a decision record's historical truth. |

Fable accurately quotes the historical r77b note calling the retry sentence “unreviewed” at that proposal stage ([r77b brief](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/docs/research/panels-2026-10/r77/r77b/brief.md#L340)). That is not evidence that adopted P remains unreviewed or has less authority than UO. The later owner adoption governs; both proposed amendments remain substantive.

Fable's statement that transactions begun at different instants necessarily have different values is broader than the checked PostgreSQL fact: no monotonic-clock guarantee was established, and [CNF-99](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/10-conformance-checklist.md#L558) explicitly tests a rolled-back transaction clock. The r81 conflict needs only the packet's explicit distinct-values trace; no vote is invalidated by this incidental overstatement.

## Separate Q4 result — conformance addition yes; new gate no

| Reader | CNF addition | New gate | Exact proposed landing |
|---|---|---|---|
| fable | YES | NO | Append to CNF-302 after its supersession paragraph |
| opus | YES | NO | Append to CNF-302 after its supersession paragraph |
| astra | YES | No new specification gate proposed | Append to CNF-302 after its supersession/lost-reply paragraph |
| sol | YES | A conformance addition, not a new gate | Add to CNF-295 |

All participating readers agree on conformance coverage and propose no new specification gate. **No exact CNF wording is settled:** the proposals below are distinct and have not been combined. Q4 is not part of B or a condition on any A/B acceptance. [CNF-302](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/10-conformance-checklist.md#L3076) says **“A lost transaction reply must not produce two open incidents or silently continue using predecessor step marks”**; it does not explicitly exercise the absent-record aborted-attempt clock and subsequent committed no-op value. The coverage gap is separate from the pin's actual normative conflict.

### fable — exact proposed case text

```text
Separately drive establishment twice for one actual restore with one retained id: once with
the first attempt's connection dropped before its commit reaches the store, and once with it
dropped after the commit is durable but before its reply. In each run assert exactly one
record carries that id, no refusal occurs, and recovery proceeds after the acknowledged
repeat without operator re-selection. In the aborted run assert the persisted
`restore_instant` equals the inserting retry transaction's own `transaction_timestamp()`,
read in that transaction, and not an instant captured before the first attempt; in the
committed run assert it is the first transaction's and the repeat changes nothing. `STO-56`:
"Repeating establishment with that id when a committed matching record exists MUST affect
that record as a guarded no-op".
```

Fable additionally says: Under A the aborted-run assertion would instead read **“equals the instant selected and retained before the first attempt”**, and the quote would cite A’s unchanged STO-56 sentence. This is a separate adaptation, not text included in B.

### opus — exact proposed case text

```text
For one actual restore, lose the establishment transaction's connection before it commits,
so that no record with the retained id exists, and repeat establishment with that id in a
later transaction whose start time differs: assert exactly one record with that id, its
`restore_instant` the value `STO-54` defines, its predecessor closed by supersession and
provenance initialized in the repeating transaction, and neither component started before
that transaction is acknowledged. Separately let establishment commit, drop its reply and
repeat with the same id: assert the repeat is acknowledged as a guarded no-op preserving the
stored instant, predecessor and step marks, that it is not refused merely because the
repeating transaction starts later, and that the components then start and continue that
incident. Neither arm leaves two open incidents. This case selects no predecessor-comparison
algorithm.
```

### astra — exact proposed case text

```text
**Establishment retry clock.** Exercise the following cases for one actual restore per run, retaining the same new incident id N throughout its establishment retries. Run each case with no inherited open incident and with an inherited open predecessor R whose ordinary close conditions are unmet. Use establishment transactions whose observed `transaction_timestamp()` values differ.

In the first case, let the first establishment transaction have timestamp t1, force it to abort, and lose its reply. Verify that N is absent and none of its establishment effects committed. Retry in a newly begun transaction with timestamp t2. Assert that the committed N carries restore_instant=t2, not t1. Lose this transaction’s commit reply too. Keep both components stopped, repeat establishment in a transaction with timestamp t3, and assert a matching guarded no-op preserving t2, the predecessor, step marks, endpoint fields and history_evidence_ref. Acknowledge that repeat before either component starts.

In a separate case, let the first establishment transaction commit N at t1 and lose its reply. Repeat in a transaction with timestamp t2 and assert the same preservation and acknowledgement behavior, with restore_instant still t1.

Use null endpoint fields with retained unknown-endpoint reasons for the unknown-evidence runs. Repeat with certified upper-bound evidence using STO-54’s event-clock recipe; assert that the upper bound uses the transaction event persisted by the successful insertion and remains unchanged on matching repeats. Assert no duplicate incident or additional supersession.
```

### sol — exact proposed case text

```text
Exercise establishment for one actual restore with incident id N, for backup restore and separately for restore-class promotion. Begin the first establishment transaction at t1, lose its connection/reply, and establish that it did not commit; assert N is absent. Retry the same actual restore with the same id in a newly begun transaction at t2 distinct from t1. Assert N is inserted once with restore_instant equal to t2. Repeat with an open predecessor and assert atomic supersession.

Separately let the first establishment transaction commit at t1 but lose its reply. Retry at distinct t2 and assert a guarded no-op preserving N’s original restore instant, predecessor, step marks, grace end, endpoints and evidence reference, without creating another incident. Neither component starts before establishment or its matching no-op is acknowledged.

Use null endpoint fields with a non-null incident-keyed evidence reference retaining the unknown-endpoint reasons. Also exercise the event-clock upper-bound recipe with certified evidence for the transaction that inserted N; assert it uses the persisted incident instant rather than an uncommitted attempt’s instant or the no-op transaction’s timestamp.
```

## Exact settled B and alternatives retained on record

**B — settled, not adopted.** The bytes equal the original brief’s B code block; the standalone exact text is [check/form-B.txt](check/form-B.txt).

```text
The operator MUST select and retain one new incident id per actual restore before attempting
establishment, and reuse that id on a lost-reply retry. If establishment with that id finds no
committed matching record, it MUST insert the incident with restore_instant defined by STO-54
for the newly begun transaction inserting it; an instant selected for an earlier attempt that
did not commit is not reused. Repeating establishment with that id when a committed matching
record exists MUST affect that record as a guarded no-op, not create or supersede another
record, preserving its step marks and original restore instant. A mismatch in the committed
id's restore instant or predecessor MUST be refused with both components stopped. The initial
establishment or its matching no-op repeat MUST be acknowledged before either component starts.
A new actual store restore uses a distinct id even when the predecessor incident is still open.
```

**B′-opus — accepted by opus only, not substituted for B:**

```text
The operator MUST select and retain one new incident id per actual restore before attempting
establishment, and reuse that id on a lost-reply retry. If establishment with that id finds no
committed record with that id, it MUST insert the incident with restore_instant defined by STO-54
for the newly begun transaction inserting it; the timestamp of an earlier attempt that did not
commit is not reused. Repeating establishment with that id when a committed matching record
exists MUST affect that record as a guarded no-op, not create or supersede another record,
preserving its step marks and original restore instant; the repeating transaction's own
timestamp is not compared with that instant. A mismatch in the committed id's predecessor MUST
be refused with both components stopped. The initial establishment or its matching no-op repeat
MUST be acknowledged before either component starts. A new actual store restore uses a distinct
id even when the predecessor incident is still open.
```

**B′-fable — original conditional instruction, with its invalid target retained:**

Exact alternative B′, a distinct form, offered only if the owner wants the dead arm gone. Same text as B with its seventh sentence replaced by:

```text
A mismatch in the committed id's predecessor MUST be refused with both components stopped.
```

I do not count B′ as a wording-only repair: it deletes a MUST arm, even a vacuous one.


## Scope and verification

Required unpiped `nix develop --command bash tools/check-all.sh` ran before tally work and again before report on the independent exact pinned export. Both real exit files contain **0** and both summaries say **All gates passed**: [before](/var/tmp/provisiond-manager/r81-tally-yazopglq/gate-before.log), [final](/var/tmp/provisiond-manager/r81-tally-yazopglq/gate-final.log). These validate the pinned corpus; they do not decide the clock policy. The exact-A noncomment comparison and limited citation probes are separately identified above.

Entry quotas: Claude session 74% (resets 2026-10-28 23:00 UTC), all-models week 13%, Fable week 19% exempt; active Codex WEEK 43%, allowed below 100%. See `quota-entry.json`. No new panel/Run is started, so there is no further launch quota check.

The main HEA/var/tmp/provisiond-manager/r81-tally-yazopglq/status, all tracked bytes and committed pv-ymjo closure are independently rechecked in [main-after.json](/var/tmp/provisiond-manager/r81-tally-yazopglq/main-after.json). Only r81 tally/evidence, independent scratch files and the requested one manager-brief UPDATE are written. No specification, Lean declaration, tracker edit, commit, push, PR action, consensus panel or rloop Run is made. All r7* and r80 folders stay read only. pv-ymjo remains closed in committed JSONL but the blocked package remains unaccepted. **Next: main refers exact B to the owner; no further work launched.**
