# r71 tally (panel E: whole-form S1–S6 preservation read). 2026-10-26

Base: `c5f897c32f7894d77a544528872176f241394d0d`. Rules: [notes.md](notes.md), fixed before launch. Inputs: [brief.md](brief.md), [fable](fable.md), [opus](opus.md), [astra](astra.md), [sol](sol.md). The structure follows r70/tally.md; no earlier vote is counted. Previously verified r70 mechanics/history are reused, not experimentally re-run.

**Answer validity checked first:** every exit file is 0; every answer is substantive; none contains a session-limit line. In particular, opus's initial “Saved at” pointer is followed by its complete answer. [answer-validity.json](/var/tmp/provisiond-panel-r71/tally-evidence/answer-validity.json) records first lines, sizes and hashes. No replacement reader is needed. Stored listing, preservation of unhealthy-account precedence, and exact r69 K1–K6 plus original K-d remain settled; Q2 is not re-tallied.

## Outcome: (b) corrected reading; tally VOID under this task's explicit brief-error instruction

**Raw counted result under rules 1–3: 2 ACCEPT / 2 CANNOT ACCEPT.** Fable ACCEPT; opus ACCEPT; astra CANNOT ACCEPT; sol CANNOT ACCEPT. The ACCEPT threshold fails independently of the verified blocking loss. Neither dissenter supplies a wording-only acceptance condition. No S text goes into the Run, and no AMEND rides.

**Both dissent traces verify and identify the same defect:** healthy-account stale-listing refusal occurs before tail collection and changes surviving healthy `CNF-307` verdicts. The unhealthy-account repair itself works. This is a candidate-versus-base loss, already present in printed S; it is not a newly introduced r71/S1c regression. Details and the novelty qualification are below.

**Verified brief error:** brief.md:136 labels its `CNF-307` block “read this entire unchanged item”, but the block ends at base line 1284; the item continues through line 1300. The omitted text includes the success/retry control at 1292–1293: “Clear recoverable faults and resend the exact request and key: admission succeeds, proving refusal left no replay receipt.” The exact missing source is [omitted-cnf307.txt](/var/tmp/provisiond-panel-r71/tally-evidence/omitted-cnf307.txt); the boundary is independently checked in [verify.py](/var/tmp/provisiond-panel-r71/tally-evidence/verify.py) and [verification.json](/var/tmp/provisiond-panel-r71/tally-evidence/verification.json).

**Rule distinction, made explicit:** notes rule 6 voids only an error changing the premise. This omission does not change the stated preservation target, the instruction to read the items whole in the clone, or the core stale-unsellable counterexample (which is printed in the brief). Astra and sol explicitly say it does not void the premise; no contrary causal claim about their votes is established. However, this tally task additionally says **“A verified brief error voids the tally; say so.”** Applying that stricter task instruction, the tally is VOID. The raw votes and source findings remain faithfully recorded; they are not approval or valid policy votes for a replacement form. Under notes rule 6 alone the raw 2–2 would stand, and rule 4 would send the non-converging behavioural repair choice to the owner. The stricter instruction requires the corrected reading first, so the operative outcome here is (b), with no owner-question.md.

The repairs differ in behaviour. Astra R1–R2 remove age-based admission refusal. Sol A–B preserve it after an otherwise successful tail. Both restore the demonstrated refusal cases, but differ on a stale otherwise-admissible create, and sol's form still needs reconciliation with the unchanged-success target. Neither has whole-panel approval. Optional sol C adds assertions and is behavioural. No combination of these texts is approved or recommended as reviewed.

## Reader verdicts and strongest arguments

| Reader | Whole-form verdict | Strongest argument, theirs | Count under rule 1 |
|---|---|---|---|
| fable | **ACCEPT**, no AMEND | Healthy-only S1 plus S1c restores the unhealthy tail: base `API-7` orders “`conflict`/`state` for create against a provider account not `healthy`”; the missing row follows “An offer absent from the offers the check reads is an unsellable offer for every rule in this tail”. | **ACCEPT**. Its additional claim that healthy stale fixtures are irrelevant is rejected below; the explicit vote is preserved. |
| opus | **ACCEPT**, no AMEND | Unhealthy status always reaches the state-first tail, preserving `CNF-278`'s “a create naming it is `409` `state`” and `CNF-307`'s “termination makes the envelope `retryable: false`”. It accepts only by treating healthy fixtures as implicitly fresh. | **ACCEPT**. Its narrowed reading conflicts with the explicit target/instructions; do not silently convert its vote to AMEND or CA. |
| astra | **CANNOT ACCEPT**; R1/R2 **behaviour changed** | `CNF-307`, base 10:1259–1262: “On an unsellable create with a healthy account and available rate, assert a singleton offer refusal, false retryability, and both priced checks skipped for `offer_not_sellable` when a cap is supplied.” Printed S1 instead returns 502/true on the stale row before collection. | **CANNOT ACCEPT**, verified rule-3 loss relative to base, inherited from printed S. |
| sol | **CANNOT ACCEPT**; A/B and optional C **behaviour changed** | Same unsellable trace; also the healthy channel/solvency/rate combinations lose their required entries. Move availability refusal after collection, contingent on no collected refusal, rather than hiding independent faults. | **CANNOT ACCEPT**, same verified rule-3 loss. Its hypothetical acceptance after A+B is not an ACCEPT of r71. |

There is no formal whole-form AMEND verdict and no amendment marked “behaviour unchanged”. Repairs attached to CA answers do not become extra votes. Requested counterarguments and unendorsed alternatives are separated below.

## Both dissent traces checked whole

All source files here are frozen from `git show c5f897c:<path>` in [tally-evidence/source](/var/tmp/provisiond-panel-r71/tally-evidence/source). All seven candidate operations were applied to [candidate](/var/tmp/provisiond-panel-r71/tally-evidence/candidate); every edited file matches preparation's scratch byte for byte. Both target CNF items remain byte-identical. [source-checks.txt](/var/tmp/provisiond-panel-r71/tally-evidence/source-checks.txt) records fixed source searches with `rg` followed by numbered `sed` ranges, for base and applied candidate. [history-checks.txt](/var/tmp/provisiond-panel-r71/tally-evidence/history-checks.txt) records the printed-S comparison. These are specification/source traces; no implementation exists or is simulated by this evidence.

### Source rules

- `04-api-contract.md:262–264`, `API-7`: “After steps 1–5d, the tail MUST collect every applicable refusal once, from one read-only snapshot inside the existing `LDG-35` transaction, without an extra lock, ceiling slot, write or provider call.” At 04:192, “Steps 1–5 are common to every authenticated write”; at 04:291, “Steps 1–5d still stop at their first refusal”. The new listing check is in neither numbered/common sequence. Passing those steps does not imply a fresh listing.
- `04-api-contract.md:265–275`, `API-7`: “then, on create only, `invalid_request`/`offer_not_sellable` when the named offer is not sellable under `PRV-13b` or `PRV-31`, or absent from the offers the check reads”; “An offer absent from the offers the check reads is an unsellable offer for every rule in this tail, including cap and balance suppression and the `WIR-9a` `offer_not_sellable` refusal and `not_checked` entries.” No additional lookup is made.
- `02-provider-contract.md:575–578,594–596`, `PRV-31`: “an offer with **no bound declared in either the descriptor or the offer MUST NOT be sold on prepaid terms**”; “A missing declared cancellation bound in both the descriptor and the offer is an unsellable offer.” Raw driver results may contain data omitted from the customer listing; `DOM-9`, `01-domain-model.md:188–189`, says “The customer offer listing MUST include only offers sellable under `PRV-13b` and `PRV-31`.” An empty/omitting source gives the same absence predicate if X was filtered before storage.
- `13-wire-contract.md:155–165`, `WIR-9a`: “An unsellable-offer refusal is HTTP `400`, kind `invalid_request`, with `details.reason: "offer_not_sellable"`”; “Entries MUST be in check order `commitment_cap`, `balance`, then reason order `provider_account_not_healthy`, `offer_not_sellable`, `rate_unavailable`.” At 13:174 the offer entry is `false`. At 13:226–228, `WIR-9b`: “the envelope's `retryable` MUST be true iff every refusal entry's `retryable` is true.”
- Applied `04-api-contract.md:264`, proposed S1: “Where the account's `STO-47` status in that snapshot is `healthy` and its listing is absent or has a `read_at` older than the stated offer-listing age (`OVR-19`) at the admitting transaction, the create MUST be refused `provider` (`01-domain-model.md`'s error taxonomy) with `retryable: true` before the tail, committing nothing.” The taxonomy row at base `01-domain-model.md:587` is “`provider` | Provider returned an error response | 502”.
- Applied `05-persistence.md:572`, **proposed STO-60, not base text**: “Every successful driver List offers read MUST publish its complete result to the account's row, replacing an existing row only when the incoming `read_at` is later.” Also: “A failed read MUST leave the row unchanged.” Applied `03-operation-lifecycle.md:2003`, proposed OPS-51, requires reads “at least once per stated offer-listing refresh interval”, except during the credential stop; it does not require successful reads. Base `STO-47`, `05-persistence.md:1152–1164`, names “`API-63` is the writer” and the status/source columns. A failed non-authentication refresh without a status-writing action does not require the fixture's recorded status to change.

### Concrete healthy fixtures — astra and sol

Use separate fixtures on an assigned account declaring the required ordering and list-offers capabilities. Status stays `healthy`. The age is 60 seconds and refresh interval 20 seconds. A successful driver read dispatched at 12:00:00 publishes at 12:00:01. Subsequent scheduled reads at :20, :40 and 12:01:00 fail without changing status or the stored row. Use non-authentication failures, so scheduling continues. Create at 12:01:01 with a fresh key; authentication, authorization, body/key, replay, tenant state, ceiling and ordering-capability checks pass. Dispatch age is 61 seconds. No successful later read need be suppressed.

For the common dissenter's witness, the stored row contains X without a cancellation bound in either descriptor or offer; the channel is open, solvency is normal, rate available, cap supplied, balance otherwise sufficient. The stored observation can be unsellable; if filtering removed X, API-7's absence rule gives the same result. The base does not require any successful or fresh offer read at admission, so the tail can use the same observed offer facts at c5f897c.

| Trace and checked base source | Base required result | Printed r71 result |
|---|---|---|
| **D1: both readers' core trace**, healthy + unsellable + available rate + supplied cap, `10-conformance-checklist.md:1259–1263`, `CNF-307` quoted above | 400 `invalid_request`/`offer_not_sellable`; singleton refusal false; envelope false; `not_checked` cap then balance, each because `offer_not_sellable`; no cap/balance amounts | 502 `provider`, true, before tail collection; required offer entry, false retryability and skipped-check payload are lost |
| D1 without cap, same source | Same offer result; only balance skipped for `offer_not_sellable` | Same early 502/true; balance skip absent |
| **D2: both identify channel loss**, healthy + stale sellable X + closed channel + solvency halt + absent rate + supplied cap, `10-conformance-checklist.md:1231–1239`: “require channel before solvency/rate” | 429 channel headline with its own pacing; ordered channel/solvency/rate entries, all true; cap and balance skipped for `rate_unavailable` | 502/true; channel headline, pacing, refusal entries and skip entries are lost |
| D3: healthy repetition of unsellable + solvency + absent rate, add channel, `10-conformance-checklist.md:1264–1276`: “Repeat with healthy and terminated accounts” and “order account, offer, channel, solvency, rate” | Healthy omits account: offer/channel/solvency/rate, envelope false; cap then balance, reasons offer then rate for each | 502/true before any collection |
| **D4: astra's evaluation trace**, healthy + stale sellable X + available rate + omitted cap, `10-conformance-checklist.md:1281–1283`: “omitting the cap leaves balance evaluated and `not_checked: []`” | Balance evaluated, no skipped check; with adequate balance and no faults, admission | Printed r71 never evaluates balance |
| **D5: omitted success control**, clear a closed channel and any other recoverable base faults, resend exact request/key while stored sellable row remains stale, `10-conformance-checklist.md:1292–1293`: “admission succeeds, proving refusal left no replay receipt” | Successful admission; no receipt from earlier refusal prevents it | New availability refusal persists, 502/true |

For every refusing D1–D3 trace, base and r71 both make no provider call and no admission write; r71's missing rich payload is caused by its earlier branch, not by a provider error during create. Base `API-7`, 04:287–288: “A refused tail MUST commit nothing and write no `STO-35` receipt”; `CNF-307`, 10:1228–1229: “every refusing tail writes no commitment, balance, machine, operation or receipt and makes no provider call”. Preparation refreshes are separate actions. D4/D5's otherwise-successful base admission may write its admission records; r71 refuses without them.

D1 alone proves each CA's rule-3 loss, wholly within the brief's printed source. The S6 stale-listing assertion is disclosed, but no amendment of `CNF-307` is listed; it does not excuse changing that surviving assertion. Requiring every healthy witness to have a fresh row would silently narrow the checked domain, expressly forbidden by brief.md:23–24. Reachability of another fresh-row witness is insufficient.

### Unhealthy-account repair also checked, including source and payload

Applied S1c says: “For an account whose status in that snapshot is not `healthy`, the tail reads its stored listing regardless of age, or an empty offers set if no listing is stored.” The healthy predicate is false for every unhealthy fixture. Source age alone adds no offer fault.

Use `A` for 409 `conflict`/`state`, `O` for 400 `invalid_request`/`offer_not_sellable`, `S` for 503 `halted`/`solvency`, `R` for 503 `halted`/`rate_unavailable`. Entry retryability is in parentheses.

| Fixture | Ordered refusals | Envelope |
|---|---|---|
| `account_unreachable`, stale sellable X | A(true) | true |
| `credentials_rejected`, credential stopped, stale sellable X | A(true) | true |
| `terminated`, stale sellable X | A(false) | false |
| `terminated`, no row | A(false), O(false) | false |
| Either recoverable status, no row | A(true), O(false) | false |
| Any unhealthy status, stale unsellable X, or row omitting X | A(status-dependent), O(false) | false |
| Recoverable + stale sellable X + solvency + cap | A(true), S(true) | true |
| Same without rate | A(true), S(true), R(true) | true |
| Terminated + stale sellable X + solvency (+ no rate) | A(false), S(true) [, R(true)] | false |
| Terminated + no row + solvency (+ no rate) | A(false), O(false), S(true) [, R(true)] | false |

Every row's headline is 409 state. Base `CNF-278`, `10-conformance-checklist.md:2789–2792`, requires “a create naming it is `409` `state`” and “Assert the refusal on **all three** unhealthy statuses”; this holds. Base `CNF-307`, 10:1253–1255, requires “An unhealthy create account + sellable offer + solvency halt with a supplied cap: `409`, state then solvency, cap and balance unchecked because `provider_account_not_healthy`; repeat with no rate as well and require the rate refusal and both reasons for each skipped check.” The stale sellable-X rows reproduce it.

For each supplied-cap row, skip cap then balance for account health, then offer unsellability/absence when applicable, then absent rate when applicable. Without cap, only balance appears, with the same ordered reasons. No cap/balance amount is exposed. The missing-row cases read an empty set and are independent offer faults, rather than sellable-offer singleton-account cases. Recoverable account plus absent offer correctly has a false envelope. None of these refusing creates writes admission records, a receipt or listing data, or calls a provider. Subordinate halt pacing never supplies pacing to the state headline, per `API-7`, 04:283–286: “a subordinate entry MUST NOT supply pacing to a headline kind that does not require it.” Stopped credentials get no scheduled retry, per `PRV-41`'s quoted “MUST NOT re-attempt it on a schedule”.

No dissent demonstrates a second unhealthy-source defect. S1c's missing-row interpretation survives both whole-trace checks. Additional source-specific conformance assertions would be new behavioural amendments, as the readers acknowledge.

### Novelty and misleading acceptance rationales

The healthy stale-row refusal is already in printed r69 S1 (`docs/research/panels-2026-10/r67/r69/brief.md:108`) and r70 S1 (`/var/tmp/provisiond-panel-r70/parts/candidate.md:2`): “Where no listing is stored, or its `read_at` is older ... the create MUST be refused `provider` ... before the tail”. R71 restricts that predicate to healthy accounts and adds S1c; it does not introduce the healthy failure. At c5f897c `04-api-contract.md:262–292`, no listing-age pre-tail refusal exists. Thus both dissents establish the same real loss relative to base, **not a new loss since printed S**. Neither is presented as an r71-only regression. Rule 3 makes an exception for explicitly listed assertion amendments, not for inherited unapproved draft defects.

Fable's assertion that the unchanged CNFs say nothing about healthy stale listings is not a stated freshness precondition. Opus itself acknowledges the strict target fails but substitutes fresh/isolated fixtures. The brief explicitly rejects doing that. Opus's claim that “Any stored-listing form has this property” is also too broad: astra's literal stored-listing repair has no age refusal. Reachable fresh witnesses and unchanged file bytes do not prove unchanged verdicts. These corrections do not turn either reader's requested counterargument into a vote, or change its recorded ACCEPT.

## Exact repair texts and disposition

All before-spans below match the applied candidate exactly once. The deletion's trailing separating space is included in astra's machine-readable span. Complete unreviewed variants and the literal spans are in [exact-repairs.json](/var/tmp/provisiond-panel-r71/tally-evidence/exact-repairs.json), [astra whole form](/var/tmp/provisiond-panel-r71/tally-evidence/astra-repair-whole-form.md), and [sol whole form](/var/tmp/provisiond-panel-r71/tally-evidence/sol-repair-whole-form.md). Each core variant independently applies and passes structural coverage. No optional assertion is silently spliced into either variant.

### Astra: R1–R2 — behaviour changed

**R1** — `04-api-contract.md`, API-7; S1 sentences 2–3, after base line 264.

Before:

```text
Where the account's `STO-47` status in that snapshot is `healthy` and its listing is absent or has a `read_at` older than the stated offer-listing age (`OVR-19`) at the admitting transaction, the create MUST be refused `provider` (`01-domain-model.md`'s error taxonomy) with `retryable: true` before the tail, committing nothing. For an account whose status in that snapshot is not `healthy`, the tail reads its stored listing regardless of age, or an empty offers set if no listing is stored.
```

Replacement:

```text
The tail reads the stored listing regardless of whether its `read_at` is older than the stated offer-listing age (`OVR-19`), or an empty offers set if no listing is stored.
```

**R2** — `10-conformance-checklist.md`, CNF-166; S6 first added sentence, after base line 3699.

Before:

```text
Separately let a `healthy` account's stored listing be older than the offer-listing age: the create is refused `provider`, `retryable: true`, with no provider call. 
```

Replacement: **delete this sentence**, retaining the following stored-price/claim-price assertion and the remainder of S6.

### Sol: A–B — behaviour changed

**A** — `04-api-contract.md`, API-7; after base line 264.

Before:

```text
Where the account's `STO-47` status in that snapshot is `healthy` and its listing is absent or has a `read_at` older than the stated offer-listing age (`OVR-19`) at the admitting transaction, the create MUST be refused `provider` (`01-domain-model.md`'s error taxonomy) with `retryable: true` before the tail, committing nothing. For an account whose status in that snapshot is not `healthy`, the tail reads its stored listing regardless of age, or an empty offers set if no listing is stored.
```

Replacement:

```text
On create, the tail reads the stored listing regardless of age, or an empty offers set if no listing is stored. If the tail has collected no refusal and the stored listing has a `read_at` older than the stated offer-listing age (`OVR-19`) at the admitting transaction, the create MUST be refused `provider` (`01-domain-model.md`'s error taxonomy) with `retryable: true` before any admission write, committing nothing.
```

**B** — `10-conformance-checklist.md`, CNF-166; after base line 3699.

Before:

```text
Separately let a `healthy` account's stored listing be older than the offer-listing age: the create is refused `provider`, `retryable: true`, with no provider call.
```

Replacement:

```text
Separately let a `healthy` account's stored listing contain the named sellable offer and be older than the offer-listing age, with no other refusal condition: the create is refused `provider`, `retryable: true`, after tail collection and before any admission write, with no provider call.
```

### Sol: optional C — behaviour changed

**C** — `10-conformance-checklist.md`, S6 closing See span.

Before:

```text
See `STO-60` and `OPS-51`.
```

Replacement:

```text
Separately use each unhealthy status with a stale row containing the named sellable offer, a stale row containing an unsellable named offer, a row omitting the named offer, and no row. Assert the `conflict`/`state` entry first and an additional `invalid_request`/`offer_not_sellable` entry exactly when the named offer is unsellable or absent. Repeat with solvency halt, absent rate, and supplied and omitted caps; assert retryability, ordered skipped-check reasons, and no admission writes or provider calls. See `STO-60` and `OPS-51`.
```

**Disposition:** R1 changes healthy stale/missing-row outcomes and R2 deletes a conformance assertion. A changes refusal ordering/conditions and missing-row outcomes; B narrows the stale fixture to otherwise-admissible creates. C adds assertions. All need a reading; none rides as wording. Both core variants restore D1–D3, with missing rows yielding existing absent-offer refusals. They differ on D5: astra allows the stale otherwise-admissible create, whereas sol still returns 502 after collection. A fresh-source condition for the surviving “admission succeeds” assertion is not contained in either source item; adding it would be another semantic amendment. Sol's “I would ACCEPT it” is a reader's conditional repair endorsement, not evidence that all preservation cases pass or that three readers accept it.

### Unendorsed source alternatives and follow-up suggestions — not formal AMEND verdicts

Fable explicitly says **“not my vote; behaviour changed”**. Its exact alternative replaces S1c's substring:

```text
or an empty offers set if no listing is stored
```

with:

```text
and, where no listing is stored, collects no offer refusal and no `offer_not_sellable` skip reason
```

Opus explicitly says **“behaviour changed: a normative exception; I do not propose it”**. Its exact replacement for S1c is:

```text
For an account whose status in that snapshot is not `healthy`, the tail reads its stored listing regardless of age; where no listing is stored, the offer check is not made for this create and adds no refusal or skip reason.
```

Both suppress the independently applicable absent-offer entry and its skip reason, against API-7's quoted “for every rule in this tail” absence clause. Recoverable no-row becomes state-only/true instead of state+offer/false; terminated stays false but loses its offer entry/reasons. Neither reader advocates this alternative, neither fixes the healthy stale loss, and neither is included in a next-read form or the Run.

Fable explicitly does **not** AMEND for an extra assertion. Its exact suggested follow-up text, after CNF-307 base 10:1226, is:

```text
For the unhealthy-account cases, repeat with the stored listing older than the offer-listing age and with no stored listing: the former changes nothing; the latter adds `offer_not_sellable` after the account entry with its skip reason and no `provider` refusal.
```

An added assertion is behavioural under rule 1. This text is not carried or merged with sol C. Opus's refresh-interval suggestion (“…by at least the provider-call deadline”) is not a full before/replacement AMEND. Its vocabulary/antecedent notes supply no exact wording repair and condition no ACCEPT. No manager-completed prose is substituted for them.

## Other factual claims and brief-error ledger

| Claim | Verified disposition |
|---|---|
| CNF-307 context is the “entire unchanged item” | **False completeness label**, verified above; actual excerpt 10:1210–1284, whole item 10:1210–1300. Astra identifies it and reads the continuation; sol says no premise-changing error. Operative VOID is this task's stricter error rule, not a fabricated premise-changing consequence under notes rule 6. |
| CNF-278 context begins after a leading fragment | True: brief's catalogue/create excerpt omits the `free balance passed this item.*` prefix at 10:2788. Its heading describes that excerpt, not the whole item, and no refusal condition is removed. No distinct false scope premise established. |
| S6 anchor is unmatchable | Only literal single-line matching fails across base 10:3696–3697. Whitespace-only normalization is permitted by the brief. Independent application succeeds once. This is not an assembly error. |
| Preparation traces establish universal preservation | They do not claim to be proof. The healthy cases are expressly conditioned on passing availability; build-traces.py skips healthy stale/no-row projections. That selection is inadequate evidence for the target, which the readers were asked to falsify. We do not cite its 1,600 projections as full-domain verification. |
| Stored-price/claim-price fixture is impossible under publication | Not established. Change the provider-side fixture while admission still sees its prior fresh stored observation; claim later reads the higher price. `OPS-43`, base 03:865–867, says “where the provider's price has risen past what the reserve covers: `conflict`, `details.reason: "price_moved"`”. No successful read must be concealed or left unpublished. This reuses r70's verified mechanics. |
| Reverse completion contradicts complete publication | Proposed STO-60's whole sentence, quoted above, retains “replacing an existing row only when the incoming `read_at` is later”. S6's reverse-completion control tests that condition. No additional loss is established. |
| Publication has no process fence | Scheduled refresh retains explicit engine-process placement. `OPS-50`, base 03:1985–1996, covers “every write transaction made in the engine process”; “Where the values differ, the transaction MUST roll back”; “Writes made in the api process are not checked.” Neither new reader trace demonstrates a bypass. No process universal is inferred for all other callers. |
| A Lean theorem flips | None is named with a failing trace. Base `tools/formal/Provisiond/Admission.lean:1058–1060` states “Snapshot facts only. Prices, locks, receipts, HTTP serialization and actual writes are omitted”; createPurchaseTail at 1160–1172 composes step 5d and the tail, without listing age. Opus requests synchronizing that boundary with an age gate in the eventual Run. This is a model-synchronization concern, not a demonstrated additional theorem failure, and not proof that the Markdown's early check is safe. No candidate lake run is claimed. |
| Strict quotation repair is needed | No verified defect in the candidate or literal repair variants. Fixed-string checks, whitespace normalization only: DOM-9 at 01:185; PRV-50 at 02:123–124; PRV-41 at 02:1246–1248; OPS-43 at 03:865. Prescribed S2/S3 excerpts retained. Proposed STO-60 is quoted whole and identified as proposed. Replacements own their API-7 rules rather than describing another requirement; remaining See pointers are bare. No MUST is copied into a second normative owner. Evidence: quotation-checks.txt. |
| Coverage regresses or the baseline rose | Independent runs on exact r71, astra R1–R2 and sol A–B all exit 0 / 74 uncovered. Every baseline is byte-identical to c5f897c. Optional C is verified applicable, but no separate coverage pass or full approval is claimed for a C combination. Evidence: verification.json and each form's coverage log/exit. |

## Counterarguments written on request; not additional votes

- **fable:** questions use of taxonomy kind `provider` for a local stale-row condition, false retryability caused by a missing row's offer refusal, and api-process publication outside OPS-50. These are its requested counterarguments, not a CA vote; no additional traced checked loss is supplied there.
- **opus:** explicitly describes the unstated healthy listing-age condition, S1c's lack of a direct regression assertion, and createPurchaseTail's model boundary. Its own requested counterargument supports the verified healthy loss; its explicit verdict remains ACCEPT. Its acceptance reason, not the counterargument, narrows the target.
- **astra:** restricting the age gate to healthy accounts leaves offer/channel/halt precedence vulnerable. Its closed-channel example verifies as D2. Its favourable argument is that S1c retains independent unhealthy-account faults. Neither paragraph adds a vote.
- **sol:** the healthy stale unsellable trace is its requested strongest objection as well as its actual CA reason. Its favourable argument is coherent stored admission/publication/refresh/claim-price behaviour. Neither its favourable argument nor its repaired-form conditional acceptance is counted as ACCEPT of r71.

## What main should do next — exact scope of outcome (b)

Prepare a **corrected whole-form four-reader read**, not a Run and not an owner recommendation. No new round is launched by this tally. Supply the full base `CNF-307` item at `10-conformance-checklist.md:1210–1300`, with its actual end; retain the explicit instruction to read both target items whole, all settled choices, and the strict quotation rule. Include the omitted successful-retry control, not just the previously printed refusal combinations. Cite the complete item rather than a count of its assertions.

Read these two **separate, complete, unreviewed** forms at c5f897c:

1. **Astra form:** r71's complete S1–S6, replacing only the common S1/S1c before-span with exact **R1**, deleting exact **R2**. All S2–S5 and other S6 bytes retained. Exact entire form: [astra-repair-whole-form.md](/var/tmp/provisiond-panel-r71/tally-evidence/astra-repair-whole-form.md).
2. **Sol form:** r71's complete S1–S6, replacing only that same before-span with exact **A**, and the stale S6 sentence with exact **B**. All S2–S5 and other S6 bytes retained. Exact entire form: [sol-repair-whole-form.md](/var/tmp/provisiond-panel-r71/tally-evidence/sol-repair-whole-form.md).

The unchanged r71 printed form is the comparison/control, with this raw 2–2 and verified inherited loss disclosed; no prior vote clears either replacement. Every named replacement is **behaviour changed**, not wording only. Do not import optional sol C, fable's follow-up or either no-row suppression alternative into these forms; adding one would make another unreviewed combination. If extra assertions are wanted, print and ask for their full combined form explicitly rather than riding them on a wording mark.

Ask each reader for ACCEPT/AMEND/CANNOT ACCEPT on **each whole form**, with exact marks/spans and a separate final preference if both are acceptable. Test D1–D5, healthy no-row, all repaired unhealthy branches and the full unchanged target. Specifically: does sol's post-collection age refusal preserve the quoted successful-retry control without adding an unstated freshness condition? Does astra's acceptance of an otherwise-admissible stale listing require an owner scope decision, given r69 owner-question.md:7's “Missing or stale data refuses the create”? That prior explanation is not silently broadened into owner approval of an unreviewed repair. Reconcile it explicitly with main's unchanged-verdict target. Do not recommend a manager merger.

No repair preference has a panel majority: fable/opus accept r71; astra supplies R1/R2; sol supplies A/B. If a valid corrected read still produces a non-converging behavioural/scope choice, notes rule 4 sends that exact choice to the owner with the valid tally. The stored-source direction, unhealthy-account priority, and Q2 K1–K6 + original K-d remain settled throughout.

## Validation

Both required full gates on unchanged c5f897c ran unpiped and passed, exit 0, all seven gates PASS. Receipts: [before log](tally-gate-before.log)/[exit](tally-gate-before.exit) and [after log](tally-gate-after.log)/[exit](tally-gate-after.exit). Full gates certify the unchanged specification tree; the isolated proposal checks above certify application and structural coverage only. No spec, tracker, memory, commit or remote is changed. Output is this tally, evidence, and one UPDATE to the top RESUME bullet. No owner question, reader round or Run is launched.
