# r70 tally (panel E: scoped whole-form S1–S6 read). 2026-10-26

Base: `c5f897c32f7894d77a544528872176f241394d0d`. Rules: [notes.md](notes.md), fixed before launch. Inputs: [brief.md](brief.md), [fable](fable.md), [opus](opus.md), [astra](astra.md), [sol](sol.md). r69/tally.md supplies the structure, source history and previously verified mechanics; no r69 vote is counted in r70.

**Answer validity checked first:** all four exit files contain 0; all answers are substantive, and none is a session-limit line or contains one. Sizes, first lines and hashes are retained in [answer-validity.json](/var/tmp/provisiond-panel-r70/tally-evidence/answer-validity.json). No seat needs replacement. The owner's stored-listing direction and exact r69 K1–K6 plus original K-d remain settled; Q2 is not re-tallied.

## Outcome: (c) owner question about refusal precedence; S does not go into the Run

**Counted result: 2 ACCEPT / 2 CANNOT ACCEPT.** Fable and astra accept without amendments. Opus and sol cannot accept; neither supplies a wording-only acceptance condition. The threshold in rule 2 is not met independently of the blocking-loss disposition.

**Both dissent traces verify, and describe the same defect:** S1's absent/stale-listing refusal precedes the unhealthy-account tail. The resulting `provider`/502 changes the unchanged `CNF-278` account-refusal assertion and the `CNF-307` account/refusal-collection assertions. Opus additionally demonstrates the terminated-account retryability change. These are candidate-versus-base losses, not separate defects for each reader or each recoverable account status.

**Novelty is qualified explicitly:** this defect is already present in r69's printed S1, byte for byte. It is **not introduced by r70's S2 quotation/caller repairs or S6 coverage append**, and is not a new interaction created by their merger. It is absent at c5f897c: there is no absent/stale-listing refusal before the account tail. The new discovery is a checked contradiction in a still-unapproved draft. Rule 3 exempts an explicitly listed assertion amendment, not an overlooked contradiction inherited from an earlier proposed form. Thus the whole r70 candidate retains a verified rule-3 loss relative to the surviving base assertions. If “new” means new since printed S, neither dissent meets that novelty description; neither may be relayed as an r70-only regression.

**The tally is valid, not void.** No verified r70 brief error changes its premise. The candidate is expressly unreviewed; the brief does not assert that printed S has no defects. Prior r69 acceptance and the owner's direction choice do not approve its exact error precedence. See the error ledger below.

The supplied repair texts do **not converge on one behaviour**. Opus changes S1/S6 to preserve unhealthy-account precedence. Sol conditionally keeps S1 and narrows an assertion in new S7; it does not vote for that policy, and its S7 alone leaves the independently verified `CNF-307` cases undisposed. Rule 4 sends this behavioural choice to the owner. [owner-question.md](owner-question.md) asks only for that priority; neither repair is represented as a reviewed form or a panel-majority recommendation. Both would require a subsequent whole-form read. No wording AMEND rides, no manager merger is substituted, and no new round or Run is launched.

## Reader verdicts and strongest arguments

| Reader | Whole-form verdict | Strongest argument, theirs | Count under rule 1 |
|---|---|---|---|
| fable | **ACCEPT**, no AMEND | S1–S6 connect the admission source, publication, refresh and conformance, while admission makes no provider call and claim still checks a price rise. It treats the unhealthy-account precedence change as non-blocking because fresh-listing fixtures can still pass. | **ACCEPT**. Its classification of that loss is rejected below; its explicit vote is preserved. |
| opus | **CANNOT ACCEPT**; repair explicitly **behaviour changed** | A failed refresh or credential stop lets the listing expire; S1 then returns 502 before the checked 409 account refusal. Termination also changes the checked envelope to retryable true. | **CANNOT ACCEPT**, verified blocking loss relative to base, inherited from printed S. |
| astra | **ACCEPT**, no AMEND | A coherent witness uses the stored observation for admission, refreshes independently of customer demand, publishes through callers, and detects the later higher price at claim. No additional loss was found in its read. | **ACCEPT**. The unlisted assertion loss it missed is verified below. |
| sol | **CANNOT ACCEPT**; conditional S7 **AMEND, behaviour changed** | A stopped credential can lawfully retain an expired listing; S1 prevents the unhealthy-account create from reaching the checked 409 state response. S6 lists a different assertion amendment. | **CANNOT ACCEPT**, same verified loss; S7 is an unreviewed assertion narrowing. |

No AMEND is marked “behaviour unchanged”. There are no snippet take/leave votes in this round. Sol's conditional repair is not a whole-form ACCEPT or an unconditional preference for freshness precedence.

## Both dissent traces checked whole

Evidence is frozen from `git show c5f897c:<path>` in [tally-evidence/source](/var/tmp/provisiond-panel-r70/tally-evidence/source). The exact seven operations in `parts/candidate.json` are applied to [tally-evidence/candidate](/var/tmp/provisiond-panel-r70/tally-evidence/candidate), byte-checked against preparation's amended files. [source-checks.txt](/var/tmp/provisiond-panel-r70/tally-evidence/source-checks.txt) records `rg` first, then numbered `sed` ranges for both source and applied candidate; [history-checks.txt](/var/tmp/provisiond-panel-r70/tally-evidence/history-checks.txt) does the same for printed S and the settled K text. [verify.py](/var/tmp/provisiond-panel-r70/tally-evidence/verify.py), [verification.json](/var/tmp/provisiond-panel-r70/tally-evidence/verification.json) and [verify.exit](/var/tmp/provisiond-panel-r70/tally-evidence/verify.exit) preserve the construction. The following are source traces, not claims to have executed an implementation of this specifications-only system.

### Source rules and unchanged checks

All base file:line coordinates in this tally refer to c5f897c. Proposed declarations have applied-copy coordinates explicitly identified.

| Fact needed by the traces | Source words and location |
|---|---|
| The early pipeline can pass | `API-7`, `04-api-contract.md:195–244`: use an activated, unsuspended tenant, fresh valid key, authorized target, valid body, available ceiling and declared ordering capability. Step 5d is “gate a create on its ordering capability”; its refusal “stops here and is not collected by the tail”. None of those prerequisites requires an account's stored status to be healthy. |
| Base account refusal and collection | `API-7`, `04-api-contract.md:262–288`: “the tail MUST collect every applicable refusal once”; its first entry is “`conflict`/`state` for create against a provider account not `healthy`”. “Entry 0 is the headline: HTTP status, `kind`, `message` and per-kind details MUST match it”. “A refused tail MUST commit nothing”. |
| Lawful recorded unhealthy states | `API-63`, `04-api-contract.md:1359–1365`, gives the operator-only record-status route, which “writes `STO-47`”. `STO-47`, `05-persistence.md:1184–1192`, says “`driver_observation` is reserved and today unreachable” and “No requirement in `02-provider-contract.md` obliges a driver to report account-level status, and no launch driver does.” Choose such a descriptor, so there is no competing authoritative driver observation. The assignment is made while the account is healthy and retained for the subsequent create. |
| A stopped credential need not refresh | `PRV-41`, `02-provider-contract.md:1246–1248`: “A driver MUST therefore treat an `authentication` failure as terminal for that credential, MUST NOT re-attempt it on a schedule, and MUST surface it for an operator”. Proposed `OPS-51`, applied `03-operation-lifecycle.md:2003`, requires reads “except while that credential is subject to the authentication stop”. |
| An unsuccessful read retains the old timestamp | Proposed `STO-60`, applied `05-persistence.md:572`: “A failed read MUST leave the row unchanged.” Its full publication sentence is “Every successful driver List offers read MUST publish its complete result to the account's row, replacing an existing row only when the incoming `read_at` is later.” |
| S1's different precedence | Proposed `API-7`, applied `04-api-contract.md:264`: “Where no listing is stored, or its `read_at` is older than the stated offer-listing age (`OVR-19`) at the admitting transaction, the create MUST be refused `provider` (`01-domain-model.md`'s error taxonomy) with `retryable: true` before the tail, committing nothing.” The error-taxonomy row, `01-domain-model.md:587`, assigns `provider` HTTP 502. |
| Account assertion left unchanged | `CNF-278`, `10-conformance-checklist.md:2788–2794`: “a create naming it is `409` `state`”, including one using a catalogue read “taken **before** the termination”; “Assert the refusal on **all three** unhealthy statuses”. No listing-age qualification is present. |
| Collected refusal assertion left unchanged | `CNF-307`, `10-conformance-checklist.md:1210–1226`: a fresh key, singleton `details.refusals` for each fault alone, “unhealthy create account or fenced extension `409` `conflict` (reason `state` or `cancellation_committed`)”; “termination makes the envelope `retryable: false`”. Its combination at `10:1253–1255` is “An unhealthy create account + sellable offer + solvency halt with a supplied cap: `409`, state then solvency”. |

### Concrete common setup

Use a configured Robot account A declaring `list_offers` and `provision_bare_metal`, with `allow_orders` true; assign the active tenant before making A unhealthy. Let the deployment's age be 60 seconds and refresh interval 20 seconds. At 12:00:00 dispatch a successful List offers read containing a sellable, bounded offer X; complete and publish it at 12:00:01, with `read_at` 12:00:00. No later successful read occurs before the request. The customer has a remembered offer ID; listing visibility need not be re-established at create. At 12:01:01 the tenant submits a valid create naming A/X, with a fresh key. Its auth, target, body, suspension, ceiling and ordering-capability checks pass. All price, balance and rate conditions can otherwise pass; the price can remain unchanged throughout.

**Opus trace (`account_unreachable`): verified.** At 12:00:10 connectivity fails and the operator records `account_unreachable`. Attempts at 12:00:20, :40 and 12:01:00 fail; these are reads at each interval, not successful publications. Proposed STO-60's “A failed read MUST leave the row unchanged” retains the 12:00:00 row. At the admitting transaction at 12:01:01 it is 61 seconds old. S1's quoted MUST therefore answers `provider`/502, retryable true, before collecting the `state` entry. At base, no such freshness step exists: the quoted `API-7` tail supplies account `conflict`/`state`, HTTP 409. The unchanged `CNF-278` and `CNF-307` expectations differ. Unreachability is a chosen reachable failure condition; it is not inferred merely from the status name, and it need not affect every conceivable List offers endpoint.

**Sol trace (`credentials_rejected` plus credential stop): verified.** Instead have the 12:00:20 read fail authentication. The driver stops that credential and surfaces it; the operator records `credentials_rejected` at 12:00:21. No driver account-status observation competes with that record. Proposed STO-60 retains the old row. Proposed OPS-51's quoted exception permits skipping subsequent refreshes while the stop remains; no prohibited scheduled authentication retry is needed. At 12:01:01 the same S1 MUST answers 502 before `state`. Base instead supplies the 409 state refusal. This demonstrates the same `CNF-278`/`CNF-307` change with a different lawful cause of staleness.

**Opus's extra cases: verified with limits.** Add a solvency halt and a supplied cap while keeping the offer sellable: base `CNF-307`'s quoted combination expects 409 and state/solvency entries; S1 still supplies the pre-tail 502, with no collected entries. On a separate account fixture, record `terminated` before it ever has a successful listing read. No healthy-status prerequisite is added to S1, so the absent-row branch returns `retryable: true`; base `CNF-307` expects termination to make the envelope false. Alternatively, terminate after the common stored read and allow it to expire with no successful replacement. No claim that termination inherently invalidates credentials or necessarily makes every read fail is needed. No restore, superseded engine, concurrent publication, or provider mutation is part of these witnesses.

**Same defect, not a vote count inflated by witnesses.** Both recoverable-status traces take `unhealthy status + stale row → S1 before tail`. Opus's absent-row/terminated variant also takes that branch and exposes an additional retryability consequence. There are two dissenting readers, not three independent vetoes. `WIR-9a`, `13-wire-contract.md:170–173`, supplies “The named account cannot recover” on the terminated account's **tail state refusal**; opus misattributes that row to `WIR-9b`. Since `WIR-9b:226–229` applies “For `API-7`'s rich purchase-tail refusal”, this source alone does not establish an independent WIR-9b MUST violation by S1's pre-tail response. The unchanged CNF assertions above suffice; do not overclaim another blocker.

### Printed-S and base comparison; why this remains an unlisted loss

[history-checks.txt](/var/tmp/provisiond-panel-r70/tally-evidence/history-checks.txt) and `verification.json` show r69 brief.md:108 S1 equals r70 S1 byte for byte. Printed S2 already had failed-read retention; printed S3 already had the credential-stop exception. The same traces therefore existed in printed S. Opus's “why it's new” is correct relative to base, not relative to printed S or the r70 combination. Sol makes no claim that the append itself causes it. The r69 tally's requested counterargument at :105 already mentioned changing unhealthy-account precedence, but did not disposition these assertions. Repeatedly proposing the precedence is not an explicit amendment of its checked consequence.

The only r70 checklist change is S6 in `CNF-166`; its stale-refusal assertion does not amend `CNF-278` or `CNF-307`. The owner's separately selected K4 changes a **different assertion within CNF-278**, the correlator pair in step-8/account-read cases (r69 brief.md:339); it does not qualify the create refusal at base `10:2789–2792`. Even an id appearing elsewhere in a chosen patch does not disclose this particular assertion flip. `CNF-307` is not amended by either chosen form.

Fable correctly observes that fresh-listing unhealthy-account witnesses can still return 409. That proves reachability of a passing witness, not compatibility of the stale witness with the unchanged assertion. Rule 3 includes a flipped verdict, not only an assertion made universally unreachable. The analogous r69 F finding is reused as precedent for this distinction, not as the S trace's source proof. The traces above independently demonstrate the base-versus-candidate response change.

## Exact AMEND texts and disposition

These are the readers' exact texts, preserved without silently completing or merging them. Neither is a wording-only repair. No reader has reviewed either repaired whole form in this round. [reader-checks.py](/var/tmp/provisiond-panel-r70/tally-evidence/reader-checks.py) confirms each of the three before/replacement pairs below is byte-identical to its reader's text and applies once. Separate [opus repair checks](/var/tmp/provisiond-panel-r70/tally-evidence/opus-repair-check.txt) and [sol repair checks](/var/tmp/provisiond-panel-r70/tally-evidence/sol-repair-check.txt) retain grep-then-sed inspection; neither experiment alters the candidate used for the tally.

### Opus: S1/S6, explicitly “behaviour changed”

**S1 before:**

```text
Where no listing is stored, or its `read_at` is older than the stated offer-listing age (`OVR-19`) at the admitting transaction, the create MUST be refused `provider` (`01-domain-model.md`'s error taxonomy) with `retryable: true` before the tail, committing nothing.
```

**S1 replacement:**

```text
Where the account's `STO-47` status in that snapshot is `healthy` and its listing is absent or has a `read_at` older than the stated offer-listing age (`OVR-19`) at the admitting transaction, the create MUST be refused `provider` (`01-domain-model.md`'s error taxonomy) with `retryable: true` before the tail, committing nothing.
```

**S6 before:**

```text
Separately let the account's stored listing be older than the offer-listing age:
```

**S6 replacement:**

```text
Separately let a `healthy` account's stored listing be older than the offer-listing age:
```

**Disposition:** changes refusal precedence; not BU and does not ride. In an isolated application it removes the stale/absent pre-tail refusal on unhealthy accounts. Opus expressly leaves open what the tail's offer check reads when an unhealthy account has **no** stored row, and whether that adds an `offer_not_sellable` entry after state. Its proposal must not be reported as a complete resolution of that content question. There is no exact reader text settling this remaining case. It needs a complete candidate and its own reading if that priority is chosen.

### Sol: S7 in CNF-278, explicitly “AMEND, behaviour changed”, conditional on retaining S1

**Before (`10-conformance-checklist.md:2789`):**

```text
and a create naming it is `409` `state` —
```

**Replacement:**

```text
and, with a stored offer listing present and no older than the stated offer-listing age at the admitting transaction, a create naming it is `409` `state` —
```

**Disposition:** explicitly narrows a checked assertion by adding a fixture condition; not BU and does not ride. This is a conditional repair (“If S1's freshness precedence is retained”), not sol's vote to retain that priority. It does not change S1, and leaves the same stale/absent witness against unchanged `CNF-307`, including the terminated envelope. There is no supplied exact CNF-307 repair. Sol's separate coverage run with S7 at 74/exit 0 cannot establish that this incomplete disposition repairs all losses.

**Strict quotation disposition for these exact texts:** opus's replacement is a new rule inside API-7; the status/age/taxonomy references locate data and settings, as S1's original references did. Its S6 change and sol's S7 change modify their own fixture/assertion. None asserts another owner's normative behaviour without its words or copies a MUST into another normative owner. They require no quotation fix; their behavioural changes still require a read. No manager-drafted repair text is added here.

## Other factual claims and brief-error ledger

| Claim | Verification and disposition |
|---|---|
| A passing 409 fixture means there is no assertion flip (fable; missed by astra) | Rejected by the concrete stale-row counterexample and unchanged assertion words above. Preserve their ACCEPT votes; record the verified blocking dissent. |
| Admission's pre-provider protections survive (fable) | No new admission driver call is introduced by S1. Previously verified r69 mechanics are reused. This is compatible with the separate local error-precedence defect; it cannot prove that every CNF verdict survives. |
| Every caller publication is necessarily in the engine **process** (opus), or catalogue publication necessarily runs in api (fable) | Neither process universal follows. `00-overview.md:139–140,170–180` assigns module/credential boundaries and the narrow trait; `00:316–321` expressly says “A module is not a process”. Proposed S4 fixes the scheduled refresh in “`engine`, running in the engine process”. `OPS-50`, `03:1985–1996`, covers “every write transaction made in the engine process” and says “Writes made in the api process are not checked.” No additional publication placement or fence exemption is established by either aside. No second blocking trace is supplied. |
| Refresh interval shorter than age guarantees admission availability | Not promised. `read_at` is dispatch time in proposed STO-60; successful but delayed completion can still leave an old row. Failure/stopped-credential witnesses are expressly allowed. This does not add a separate checked loss beyond the disclosed refusal and its undisclosed precedence consequence. |
| Higher-price S6 witness is impossible once successful reads must publish | Not established. Change provider-side price after the stored observation; admit before another successful read completes; then claim sees a price “where the provider's price has risen past what the reserve covers” (`OPS-43`, `03:865`). No suppressed successful publication is required. The price rise alone, without that reserve condition, is not the assertion. |
| S6's publication and reverse-completion assertions conflict (opus nit) | Proposed STO-60's full replacement sentence is quoted above. Its conditional replacement permits the earlier-dispatched result to be superseded; S6 immediately tests this. Opus itself supplies no forced contradiction and no amendment. No additional rule-3 loss established. |
| The r70 quotation/context or assembly premise is wrong | No verified error. [quotation-checks.txt](/var/tmp/provisiond-panel-r70/tally-evidence/quotation-checks.txt) rechecks every recorded quoted source/before-string with fixed-string `rg`, whitespace normalization only. DOM-9 at `01:185`, PRV-50 at `02:123–124`, PRV-41 at `02:1246–1248`, and OPS-43 at `03:865` all match. The shorter PRV-50/41 excerpts have their period outside the quotation, and complete source sentences are supplied in brief context. The proposed STO-60 sentence is whole. No quotation repair rides. |
| The r70 coverage premise is false or the baseline was raised | No. Our exact applied candidate is byte-identical to preparation's amended files; its own unpiped run gives 74 uncovered, exit 0, baseline bytes unchanged. Each reader separately reports 74/exit 0. The previously measured printed-S 76/exit 1 and archived-append 74/exit 0 are r69 evidence explicitly reused by the brief, not a claim that those historical measurements certified this new combination. |
| The brief falsely presents printed S as cleared or revisits the owner's direction | No. It calls the full combination “unreviewed combined candidate”, says “Earlier snippet takes do not approve this combination”, and settles direction only. r69's failure to establish a blocking S trace is a historical tally finding, not a premise of no possible S defect in r70. No premise-changing brief error; rule 6 does not void this tally. |

Coverage evidence: [coverage.log](/var/tmp/provisiond-panel-r70/tally-evidence/coverage.log), [coverage.exit](/var/tmp/provisiond-panel-r70/tally-evidence/coverage.exit), [verification.json](/var/tmp/provisiond-panel-r70/tally-evidence/verification.json). Requirements 515, covered 409, ratcheted uncovered 74, baseline 74 unchanged. Passing this structural check does not decide the error-precedence semantics or certify a full gate pass for the candidate.

## Counterarguments written on request; not additional votes

- **fable:** its requested argument includes “a precedence change” where stopped credentials age out and create gets provider 502 instead of state 409. The trace is real; its additional assertion that this necessarily creates api-process publication is not established. This paragraph is not a third CA vote.
- **opus:** under its requested-against heading it observes “The `409 state` is still reachable while the listing is within the age” and that fixtures can still pass. Its explicit CA and concrete stale witness remain its vote. Its heading happens to contain an argument for accepting the candidate; do not recast it as an ACCEPT.
- **astra:** the assertions do not exhaust missing listings, equality boundaries, equal timestamps or every offer-derived field. These are coverage limitations it explicitly classifies as non-blocking, not an AMEND or CA.
- **sol:** the requested counterargument repeats the unlisted account-status verdict change. Its separately stated case for acceptance is coherence and repaired coverage. Neither supplies an ACCEPT vote.

## What main should do next

Relay [owner-question.md](owner-question.md): retain the already selected stored-listing direction, and decide whether the repaired form preserves unhealthy-account refusal precedence or explicitly changes those assertions. **There is no panel-majority pick on that new priority.** Two readers accept the original form; two reject its unchecked consequence. Opus supplies a preservation repair; sol supplies a conditional assertion narrowing. Those facts do not amount to two votes for each repair, or three votes for either one.

After that priority is settled, prepare **one complete** S1–S6 repair form and any added assertion spans, label it unreviewed, and have all four readers read that exact form. For preservation, start from opus's exact S1/S6 replacements above and explicitly settle the absent-listing unhealthy-account tail content. For freshness-first, sol's exact S7 is available but is insufficient: obtain an explicit disposition/text for all affected CNF-307 cases and ensure surviving normative/tail statements agree. Any completing text or combination is a new candidate and needs that read. Do not claim that the owner has thereby reviewed unexamined prose. No fresh-read substitution or Q2 re-vote is needed. The exact settled K1–K6 and original K-d remain available for the Run; no S text is admitted to it by this tally.

## Validation

Both required full gates ran unpiped on unchanged c5f897c and passed, exit 0, all seven gates PASS: before [log](tally-gate-before.log)/[exit](tally-gate-before.exit); after [log](tally-gate-after.log)/[exit](tally-gate-after.exit). These full gates concern the unchanged specification set. Only isolated coverage/source construction was run on the proposal. No specification, tracker, memory, commit or remote is changed; output is tally evidence, tally/owner-question artifacts and one UPDATE to the top manager RESUME bullet. No round or Run is launched.
