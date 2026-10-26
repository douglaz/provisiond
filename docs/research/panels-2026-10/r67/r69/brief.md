# Panel E r69: corrected confirmation read — Q1 S-final/F-final; Q2 combined K candidate. 2026-10-25

You are one of four independent readers in a fresh throwaway clone of `provisiond-spec` at `c5f897c`.
Read `AGENTS.md` first. `br show pv-tcs pv-ytv` prints the beads; `.beads/issues.jsonl` is the fallback.
You may edit tracked files inside this clone to test a claim. Write nothing outside it. Never commit, push,
call a provider API, delegate, background or wait. Run no gate and no `lake`; keep TMPDIR as set. Draft by minute 25.

**This round replaces voided r68 tallies.** Q1 reads **S-final S1–S6 and F-final F1–F10 as printed in r68**.
Q2 reads **K1–K6, combined candidate, unreviewed**, assembled exactly as r68's tally specifies. Separate options
and archived reader proposals are supplied below; nothing is silently merged into S/F. **No combined F repair
is claimed complete.** Q1 remains an owner choice about storage, latency and cost; Q2 asks whether to apply K.

Reader 1–4 are neutral author labels. Retained options name r67 authors; the additional extracts name r68 authors.
Your seat is not assigned an author label. Author marks are their claims, not a manager endorsement. New
coordinator prose and combinations remain unreviewed until this read concludes. The exact preserved S/F forms
and archived proposals contain disclosed quotation defects; give exact wording repairs, not silent rewrites.

Quotes and anchors are checked against `c5f897c` (anchors with whitespace normalization where wrapped).
Quotes of proposed text are checked against their labelled proposal, not represented as current repository text.
The r68 tally's verified traces below are reused. Check any claim you rely on and report brief errors with evidence.
Line numbers are hints: `04:262` means `04-api-contract.md` line 262.

## The gate, and the mark every AMEND needs

- Vote **ACCEPT**, **AMEND** or **CANNOT ACCEPT** on each form read: S-final and F-final (Q1), K candidate (Q2).
- **Every AMEND carries one explicit mark, "behaviour unchanged" or "behaviour changed"**, plus exact replacement
  text for its span only. "Behaviour unchanged" means that your text changes no behaviour the form states (a
  wording, quoting or citation fix). An AMEND that changes behaviour is marked "behaviour changed". It counts as
  CANNOT ACCEPT, so name its gated loss.
- **A CANNOT ACCEPT must name a loss that changes a checked verdict.** That is a `CNF` assertion or a Lean theorem
  the form flips, makes unreachable or makes vacuous (give its id or theorem name), or a MUST/SHOULD (file and
  requirement id) together with a trace that breaks it. A form that lists a `CNF` assertion as amended has not
  "lost" it; a flipped assertion it does not list is a loss. A CANNOT ACCEPT that names none of these is recorded
  but does not block. Wording you dislike is not counted.
- **Each option** (S-a, F-a, K-a, …) gets "take" or "leave" from you. An option changes its form only if three
  readers take it.
- **PR #25 lesson: any text you propose must satisfy `AGENTS.md`'s quoting rule strictly.** A sentence saying what another
  requirement does or is carries that requirement's verbatim words; only a bare "see `X`" pointer is exempt; and no
  MUST lands outside the requirement that owns the rule. If a text below breaks that rule, report it as a wording
  AMEND ("behaviour unchanged") with the verbatim fix.

An author's “behaviour unchanged” mark does not turn added test assertions, a new normative exception or a
changed payload obligation into a wording repair. No new combination goes to the owner as reviewed without a
whole-form read. Give take/leave on each separate r68 proposal too; alternatives are never concatenated.

## Settled (not for re-vote)

- `pv-14b`'s verdict wording in `API-7`: "not sellable under `PRV-13b` or `PRV-31`, or absent from the offers the
  check reads" (04:268), and "No additional lookup is made for this verdict" (04:275).
- `OPS-43`'s claim-time sale re-test and price check, on "one current driver List offers result taken at claim"
  (03:760-761), and its steps 4-6 (03:785-790).
- `PRV-42`'s presence check "is a dispatch check, not a provider lookup during `API-7`'s read-only tail
  collection" (02:1271).
- `PRV-33`: "an ambiguous create on that channel MUST resolve to an operator, never to a guess" (02:1048-1049).
- Robot's standard channel has not passed `CNF-180`: "Satisfied on the auction channel 2026-09-04; the standard
  channel remains open" (10:1491-1492).
- Q2's null-pair shape (an earlier "Form N") is not read this round. r67 traced a `PRV-26` loss in it (02:895-897,
  "Whichever it is, the kind and the value MUST be recorded on the operation row"). A reader who still prefers a
  null pair may give it as a third shape with exact text; it is recorded and does not block K-final.


## r68 disclosure: raw votes are VOID, not a majority to follow

Both question tallies were voided. **Q1 raw picks S 4 / F 0; Q2 raw support K 4 / other 0.** None is an approval.
Q1's false premise treated every account without `list_offers` as having no listing; a retained fresh row is a
counterexample. Its F coverage omitted surviving OPS-35/OPS-11/schema constraints and the CNF-31b trace below.
Q2's account-read universal put a post-read step-8 refusal at step 1. These errors are corrected below.

Raw option takes, also VOID: S-a 4, S-b 0, S-c 2, S-d 2 (two distinct texts); F-a Reader 3 3 / printed 1;
F-b 1; F-c printed 2 / Reader 3 2; F-d 0; F-e 2; F9 3; F10 4 with qualifications. K-a 0, K-b 0;
K-c Reader 2 3 / Reader 3 1; K-d 3 take / 1 leave. Vote afresh; these counts do not enter this round's tally.
The r68 tally verified the claim-scoped no-request checks and claim publication placement; no S gated loss was
established. Its nine wrapped before-strings match after whitespace normalization, not as literal single lines.

## Q1 (pv-tcs): which offer data does create admission read, and how fresh?

**Plain terms.** A customer lists offers at 12:00 and sees auction offer `market:12345` at 90 sats/hour. At 12:03
the provider re-lists it at 120, or drops it. At 12:04 the customer creates. Under S-final, admission prices the
create from a stored listing up to one stated age old: it reserves 90/hour and admits. Under F-final, admission
reads the listing for this request: it reserves 120/hour, or refuses `offer_not_sellable`. Under S-final the claim
then re-reads, and `OPS-43` fails the create only "where the provider's price has risen past what the reserve
covers"; a dropped offer fails as absent. No machine is wrongly bought under either. What differs is whether the
create is admitted, how much balance it holds, and whether admission spends a provider read.

**Surviving F constraints (r68 verified; not a complete repair):**

- `OPS-35` (03:30–33): "The provider account MUST be resolved and written to the operation record **before** any driver call."
- `OPS-11` (03:256–263), of its admission-only kinds including balance and halt: "they are decided before any driver call, they MUST NOT be emitted by a worker or a driver".
- Schema (05:441): "The `provider_account` write retains `OPS-35`'s "before any driver call"."
- `CNF-31b` (10:235–239): "Admission-only inputs remain pre-provider, with acceptance false." and "At admission, a local `PRV-40` closure is a pre-provider refusal with no operation to classify; at claim it settles the queued operation `failed` (`CNF-283`); a driver-emitted `rate_limited` remains in the classifier, including after accepted mutation, except the accepted dated cancellation read-back and post-order read (`PRV-13`, `PRV-13c`; `OPS-11`'s exception paragraph)."

Trace: F1 passes 5d, makes a successful provider read, then refuses balance or local closure in the tail; there
is no admitted operation row. F10 changes a different owner. Both F11 proposals, and Reader 2's F12, are
supplied below, but omit the schema quotation and the CNF-31b disposition. **Neither is a complete F repair.**
Judge the printed form and name every surviving loss; do not infer an exception beyond the printed spans.

Relevant unchanged words: `OVR-17` (00:269), "Every component that runs without a caller MUST be assigned to a module";
`PRV-41` (02:1246–1248), "A driver MUST therefore treat an `authentication` failure as terminal for that credential, MUST NOT re-attempt it on a schedule, and MUST surface it for an operator (`OPS-26`).";
`DOM-9` (01:185), "Prices MUST be carried as strings exactly as the provider returned them.".
S2's new owner below says "Every successful driver List offers read MUST publish its complete result to the account's row."
Its publication belongs outside the driver read: `PRV-50` (02:123), "The driver's List offers MUST be read-only".
Read the r68 S2/S3/S4/S6 proposals against these words. New duties need conformance coverage; an added assertion
is not automatically a wording-only amendment.

### S-final: stored listing. r67 Reader 4's S1–S6, exactly as r68 printed

- **S1** `04-api-contract.md`, `API-7`: after «without an extra lock, ceiling slot, write or provider call.» insert:
  > On create, the offers the check reads are the provider account's stored offer listing (`05-persistence.md`, `offer_listings`), read in that snapshot, and the tail prices the commitment and takes the offer snapshot from it. Where no listing is stored, or its `read_at` is older than the stated offer-listing age (`OVR-19`) at the admitting transaction, the create MUST be refused `provider` (`01-domain-model.md`'s error taxonomy) with `retryable: true` before the tail, committing nothing. Every offer-derived input used to size the commitment or populate `request_summary` comes from the named offer in that same stored listing, including recurring price, currency, period, setup fee, `install_strategies`, and any offer-reported billing unit or cancellation bound. Descriptor-declared inputs come from the descriptor the `api` runs with. See `PRV-44`, `PRV-13b` and `05-persistence.md`.

- **S2** `05-persistence.md`, new subsection: before «### `tenants`» insert:
  > ### `offer_listings`
  >
  > **STO-60** `read_at` is the dispatch instant of the successful driver List offers call. Every successful driver List offers read MUST publish its complete result to the account's row, replacing an existing row only when the incoming `read_at` is later. A failed read MUST leave the row unchanged. See `OPS-51`.
  >
  > | Column | Type | Notes |
  > |---|---|---|
  > | `provider_account` | text | primary key |
  > | `read_at` | timestamp | see `STO-60` |
  > | `offers` | json | the driver's List offers result, prices as strings (`DOM-9`) |

- **S3** `03-operation-lifecycle.md`, new requirement after `OPS-50`: after «its guarantee covers one writable database history.» insert:
  > **OPS-51** A refresh pass MUST read every account declaring `list_offers` at least once per stated offer-listing refresh interval, except while that credential is subject to the authentication stop. `PRV-41` says “A driver MUST therefore treat an `authentication` failure as terminal for that credential, MUST NOT re-attempt it on a schedule, and MUST surface it for an operator”.
- **S4** `00-overview.md`, `OVR-17`'s table: after «| `OPS-32`'s account sweep | `engine` | Lists resources at a provider, so it needs a provider credential |» insert:
  > | Offer-listing refresh (`OPS-51`) | `engine`, running in the engine process | See `OPS-50`. |
- **S5** `00-overview.md`, `OVR-19`'s register: after «| Refresh freshness window | `DOM-8` | finite, positive duration at least twice the account-sweep interval | yes |» insert:
  > | Offer-listing age | `API-7` | finite, positive duration | yes |
  > | Offer-listing refresh interval | `OPS-51` | finite, positive duration, shorter than the offer-listing age | yes |

- **S6** `10-conformance-checklist.md`, `CNF-166`: «absent from every source admission could read» → «absent from the stored offer listing»; and after «Cap and balance do not run; there is no commitment, purchase write or provider order.» insert:
  > Separately let the account's stored listing be older than the offer-listing age: the create is refused `provider`, `retryable: true`, with no provider call. Separately re-list the named offer, inside the age, at a higher price sufficient to exceed what the admitted reserve covers, leaving the stored listing unchanged until admission: the create is admitted at the stored price, and the claim fails `conflict` with `details.reason: "price_moved"` (`OPS-43`: "where the provider's price has risen past what the reserve covers").

The r68 S2 row's bare DOM-9 attribution and the historical S4 alternative below are disclosed quoting defects.
Read the exact quote repairs too. S3 already contains the credential exception. The S5 register rows are the
r68 coordinator's rendering of the interval/age relation. No r68 proposal has been merged here.

**S options (take or leave each):**
- **S-a (Reader 1): a numbered step for the staleness refusal.** Replace S1's second sentence with a new step after
  5d (04:241), and change "steps 1–5d" to "steps 1–5e" at 04:262 and 04:291, the only two "1–5d" ranges [coordinator: the
  consequential edit]:
  > 5e. **refuse a create whose provider account has no stored offer listing** (`STO-60`) **or whose listing's `read_at` is older than the stated offer-listing age** (`OVR-19`): `provider` with `retryable: true` and `details.provider_account`. A refusal stops here and is not collected by the tail.

  Reader 1's reason: 04:291, "Steps 1–5d still stop at their first refusal".
- **S-b (Reader 3): one `STO-60` with the timestamp, atomicity and refresh rules.** Replace S2's `STO-60` paragraph
  and S3 with the text below. S4's row and S5's interval row then cite `STO-60`, not `OPS-51`.
  > **STO-60** Each successful complete driver List offers result MUST be recorded in `offer_listings`. `read_at` is the store-clock timestamp obtained immediately before dispatch, not response completion. Replacement MUST be atomic and occur only when no row exists or the incoming `read_at` is later. Failed or incomplete reads MUST NOT advance `read_at`. Recording is outside the driver read.
  >
  > The engine’s refresh pass MUST attempt a read for each healthy account declaring `list_offers` at least once per stated refresh interval, except while its credential is barred following authentication failure. `PRV-41` says “treat an `authentication` failure as terminal for that credential” and “MUST NOT re-attempt it on a schedule”. See `OPS-50`.
- **S-c (Reader 3, offered for either form): a MUST on the offer-derived inputs.** Replace S1's last three
  sentences ("Every offer-derived input … `05-persistence.md`.") with:
  > The tail MUST take every offer-origin input to commitment pricing and the accepted snapshot from that result. Descriptor-declared inputs come from the admitting process’s immutable descriptor. See `PRV-44` and `05-persistence.md`.
- **S-d (r67 Reader 2; r68 Readers 1 and 2 supply different texts below): missing `list_offers`.**
  An account with no usable listing/history refuses under S1 until a usable row exists. An account that read and
  stored a row while declaring `list_offers`, then restarts without it while retaining ordering capability, can
  still admit while that retained row is fresh; S2 does not invalidate it. The old every-account/indefinitely
  premise is false. `CNF-364` starts with an account declaring both capabilities and removes `list_offers` only
  before claim. `OPS-43` step 4 says "Gate on `list_offers` under `DOM-10`, then obtain the current driver List offers result."
  Take or leave a new admission capability refusal; if take, choose an exact supplied S-d text or give an AMEND.
  Say whether the new refusal should apply even with a retained fresh listing. The archived Reader 2 rationale
  below repeats the false universal; it is preserved as reader speech and is not this round's premise.

### F-final: fresh admission read. S/F texts unchanged; F9/F10 coordinator text remains unreviewed

- **F1** `04-api-contract.md`, `API-7`: after «without an extra lock, ceiling slot, write or provider call.» insert:
  > On create, after step 5d and before that transaction opens, the `api` MUST obtain one current driver List offers result for the named offer's provider account, in the order of `OPS-43`'s step 4: "Gate on `list_offers` under `DOM-10`, then obtain the current driver List offers result." That result is the only source of the offers the check reads. The tail prices the commitment, takes the offer snapshot and tests the offer for sale from it. A gate refusal or a failed read stops the create as step 5d's does: "A refusal stops here and is not collected by the tail." A failed read refuses with the kind and `retryable` the read reported, committing nothing; see `DOM-17`. See `OVR-9` for the route.

- **F2** `10-conformance-checklist.md`, `CNF-95`: «**no provider call is made**» → «**no provider mutation is made**; the admission List offers read is permitted»
- **F3** `10-conformance-checklist.md`, `CNF-307`: «operation or receipt and makes no provider call» → «operation or receipt and makes no provider call other than a create's admission List offers read»
- **F4** `10-conformance-checklist.md`, `CNF-315`: «the create is refused before any provider call» → «the create is refused before any provider mutation»
- **F5** `10-conformance-checklist.md`, `CNF-283`: «`API-7` tail before any provider call» → «`API-7` tail before any provider mutation»; and «Subsequent local refusals make no provider request» → «Subsequent local refusals make no provider request other than the admission List offers read»

- **F6** `10-conformance-checklist.md`, `CNF-340`: «before any provider call or write» → «before any provider mutation or write; the admission List offers read is permitted»
- **F7** `10-conformance-checklist.md`, `CNF-166`: «absent from every source admission could read» → «absent from the admission List offers result»; and after «Cap and balance do not run; there is no commitment, purchase write or provider order.» insert:
  > Separately re-list the named offer at a higher price after a listing and before the create, and assert the commitment is sized at the new price. Fail the admission read with a retryable `provider` error, and assert `provider`, `retryable: true`, no commitment, operation or receipt. On an account declaring the ordering capability but not `list_offers`, assert `unsupported` with `details.capability: "list_offers"`, no `details.refusals`, and no List offers read, commitment, operation or receipt.

- **F8** `02-provider-contract.md`, `PRV-40` (Reader 4): «refuse subsequent creates on that account and channel before any provider call, with `rate_limited` and `retry_after_ms` for the remaining interval.» → «refuse subsequent creates on that account and channel before any provider mutation, with `rate_limited` and `retry_after_ms` for the remaining interval; the create's admission List offers read is permitted.»

- **F9 [coordinator, UNREVIEWED]** `03-operation-lifecycle.md`, the italic record at lines 276-277: «before any provider call" and, for a queued» → «before any provider mutation" and, for a queued»

- **F10 [coordinator, UNREVIEWED]** `03-operation-lifecycle.md`, `OPS-1`: after «and MUST respond `202 Accepted` with that record.» insert:
  > This does not cover a create's admission List offers read, which comes before any record and is made whether or not the create is then admitted: `API-7` says "the `api` MUST obtain one current driver List offers result for the named offer's provider account".

F1–F7 derive from r67 Reader 2; F8 is r67 Reader 4's PRV-40 span with refusal-clause ordering fixed.
F9 synchronizes the current quotation at 03:276–277; F10 is a coordinator exception. Vote take/leave on F9/F10.
The listed edits are exactly F1–F10, **not a complete inventory of constraints affected**. F5's pre-existing
API-7 attribution lacks its owner's words; the two r68 repairs below are alternatives. F9/F10 quote proposed
F8/F1 text, not c5f897c's rule. No F11/F12, schema amendment or CNF-31b repair is merged into this form.

**F options (take or leave each):**
- **F-a: the failed-read sentence** (F1's "A failed read refuses with the kind and `retryable` the read reported,
  committing nothing; see `DOM-17`."). Say which you take, or "F1 as printed":
  - Reader 4: "A failed read refuses the create before the tail with the driver error’s own kind, details and retryability, committing nothing. See `PRV-5` and `PRV-41`."
  - Reader 3: "A failed admission read refuses before the tail and commits nothing, preserving the driver error’s kind, retryability and redacted details. See `PRV-5`, `PRV-41` and `DOM-17`."
- **F-b (Readers 3 and 4): `CNF-340` with "purchase write".** F6 becomes «before any provider call or write» → «before any provider mutation or purchase write; the admission List offers read is permitted».
- **F-c: `CNF-283`'s second sentence.** In place of F5's second replacement:
  - Reader 4: «Subsequent local refusals make no provider request» → «Subsequent local refusals make no provider request other than the create’s admission List offers read».
  - Reader 3: «Subsequent local refusals make no provider request and need no new provider-throttle alarm» → «Subsequent local refusals permit only the admission List offers read; the local refusal itself needs no new provider-throttle alarm».
- **F-d (Reader 3): `PRV-40` without "the create's".** F8's last clause becomes "the admission List offers read is permitted".
- **F-e (Reader 3): S-c above, applied to F1** in place of "The tail prices the commitment, takes the offer
  snapshot and tests the offer for sale from it."

### Q1 questions

1. ACCEPT / AMEND (explicit mark) / CANNOT ACCEPT on each complete printed form. Pick S or F (or exact third
   shape) with the strongest argument. Check the surviving constraints and CNF-31b trace, even if you prefer S.
2. Take/leave S-a, S-b, S-c, S-d (which supplied text), F-a (which variant or printed), F-b, F-c (which variant
   or printed), F-d, F-e, F9 and F10. Take/leave each r68 proposal below, including the alternative F11s and F5s.
3. Any additional gated loss from claim-time no-request checks, claim publication or the retained-row case?
   When a proposal deletes a guard or limit, state what it protected and whether that protection survives.

### Separate r68 reader proposals: verbatim archives, unreviewed here

### r68 Reader 1 — S3/S4 (BU), S-d (unmarked), F11 (unmarked)

````markdown
**S3, behaviour unchanged**, whole paragraph:
> **OPS-51** A refresh pass MUST read every account declaring `list_offers` at least once per stated offer-listing refresh interval, except a credential after an `authentication` failure: `PRV-41` says “A driver MUST therefore treat an `authentication` failure as terminal for that credential, MUST NOT re-attempt it on a schedule, and MUST surface it for an operator”.

**S4, behaviour unchanged**, the row:
> | Offer-listing refresh (`OPS-51`) | `engine` | Reads offers at a provider, so it needs a provider credential, and writes `offer_listings` (`STO-60`) |

**S-d text**, appended to S-a's 5e (or to S1's second sentence if S-a fails):
> A create whose provider account does not declare `list_offers` is refused here with `DOM-10`'s error: "A capability check failure MUST return an "unsupported" error naming the provider account and the capability, with `retryable: false`".

and appended to S6's insertion:
> On an account declaring the ordering capability but not `list_offers`, assert `unsupported` with `details.capability: "list_offers"`, `retryable: false`, no `details.refusals`, and no commitment, operation or receipt.

**F11** (`03-operation-lifecycle.md`, `OPS-35`), after «account was only ever determined inside the call that vanished.» insert:
> This does not cover a create's admission List offers read, which comes before any record: `API-7` says "the `api` MUST obtain one current driver List offers result for the named offer's provider account".
````

### r68 Reader 2 — F11/F12 (BU), F7 (unmarked separately)

````markdown
F-final AMEND spans. They are "behaviour unchanged" because F10 already says the read "comes before any record".
- **F11** `OPS-35`, after «resolved and written to the operation record **before** any driver call.» insert:
  > This does not cover a create's admission List offers read, made before any operation record exists: `API-7` says "the `api` MUST obtain one current driver List offers result for the named offer's provider account".
- **F12** `OPS-11`: «they are decided before any driver call,» → «they are decided before any driver call other than a create's admission List offers read,»
- **F7**: «assert `unsupported` with `details.capability: "list_offers"`» → «assert `unsupported` with `details.provider_account` naming the account and `details.capability: "list_offers"`». `WIR-9a`'s row requires it: "`unsupported` | `provider_account`, `capability`".
````

### r68 Reader 2 — S-d, explicitly behaviour changed

````markdown
- **S-d: take.** This is "behaviour changed" against S-final, which refuses `provider`/`retryable: true` forever on such an account; no checked verdict changes (point 2). Insert in S1 before "Where no listing is stored" (if S-a passes, this sentence leads step 5e):
  > On create, an account that does not declare `list_offers` MUST be gated under `DOM-10` before the tail: "A capability check failure MUST return an "unsupported" error naming the provider account and the capability, with `retryable: false`".

  Append to S6:
  > On an account declaring the ordering capability but not `list_offers`, assert `unsupported` with `details.provider_account` and `details.capability: "list_offers"`, `retryable: false`, no `details.refusals`, and no commitment, operation or receipt.
````

### r68 Reader 3 — F5, BU

````markdown
**F5 wording AMEND — behaviour unchanged.** Replace its first replacement text, `` `API-7` tail before any provider mutation ``, with:

> tail before any provider mutation (`API-7`: “`rate_limited` when the offer's account and ordering channel are closed under `PRV-40`”)
````

### r68 Reader 4 — S2/S6/F5, each BU

````markdown
**S2 — AMEND, behaviour unchanged.** Replace the `offers` table row with:

```text
| `offers` | json | the driver's List offers result (`DOM-9`: "Prices MUST be carried as strings exactly as the provider returned them.") |
```

**S6 — AMEND, behaviour unchanged.** Append to its inserted conformance text:

> With no customer requests, assert each account declaring `list_offers` is read within each stated offer-listing refresh interval, except while its credential is subject to the authentication stop. Assert no scheduled retry for a stopped credential. After successful reads, assert publication of the complete result with `read_at` equal to the dispatch instant. Complete two reads in reverse dispatch order and assert the row retains the later read's `read_at` and offers. Fail a read and assert the existing row is unchanged. See `STO-60` and `OPS-51`.

This demonstrates the new duties and supplies their otherwise missing conformance citations.

**F5 — AMEND, behaviour unchanged.** Replace its first replacement text with:

```text
`API-7` tail ("then, on create only, `rate_limited` when the offer's account and ordering channel are closed under `PRV-40`") before any provider mutation
```
````

### Coordinator quotation correction for Reader 1 S4 (wording only; not reader-authored)

Main corrected this candidate's STO-60 quotation to the whole sentence exactly as S2 has it; this is wording only.

If that individual row is used, replace its attribution to the storage owner with the proposed owner's actual words. This repairs the quoting defect; it is not a merged S recommendation:

```text
| Offer-listing refresh (`OPS-51`) | `engine` | Reads offers at a provider, so it needs a provider credential. `STO-60`: "Every successful driver List offers read MUST publish its complete result to the account's row, replacing an existing row only when the incoming `read_at` is later." |
```

## Q2 (pv-ytv): on a `correlator: none` channel, what does the correlator pair hold?

**Plain terms.** A Robot create goes out on the standard channel, which the descriptor declares
`correlator: none`. The order carries a per-order SSH key with fingerprint `29:07:2c:…`. The order reply is lost.
At `c5f897c`, engine A has written that fingerprint into `operations.correlator_value` before ordering, and engine B
has written null. Both cite the text. Under both, `PRV-33` sends the create to an operator. The difference that
reaches a check comes later. After the machine is delivered and retention removes the operation row, `OPS-32`'s key
sweep reads the guard through `machines.correlator_value` (`CNF-303`). K candidate makes engine A's behaviour the rule.

**Verified facts.**

- `PRV-32`: "Until a driver's own channel passes `CNF-180`, it MUST declare no correlator and `PRV-33` governs"
  (02:990-991). `PRV-33`: "The driver declares the absence as that channel's `correlator: none` in the descriptor's
  `ordering_channels`" (02:1053-1054).
- `PRV-26`: "Whichever it is, the kind and the value MUST be recorded on the operation row —
  `operations.correlator_kind` and `operations.correlator_value` (`05-persistence.md`) — before the order is sent"
  (02:895-897). It names no channel exception.
- 05:441: the `operations` pair holds "`ssh_key_fingerprint` on Robot (`PRV-32`)", and is "Written in `API-63`'s
  correlator transaction, which is `OPS-43`'s step 8". 05:326 (the `machines` pair) is "Nullable, for a machine that
  bore none when adopt returns (`ADR-0020`)". Neither names a channel.
- `PRV-9`: "For an operation that produced a machine, its `machines.correlator_value` is the operation UUID on
  Hetzner Cloud and DigitalOcean, or its per-order correlator-key fingerprint on Robot" (02:151-152). `CNF-303`:
  "Read the guard through retained `machines.correlator_value`: operation UUID for Cloud and DigitalOcean,
  per-order correlator-key fingerprint for Robot" (10:2936-2938).
- Master does not state that a Robot order on a `correlator: none` channel carries a generated per-order key.
  `PRV-32`: "`PRV-9` already requires the driver to register a temporary key per order, so making it **unique per
  order** costs nothing" (02:962-964). K candidate states the key as a MUST.
- `OPS-38`: "A create that recorded none has no count: `OPS-27`'s row for "no verified correlator exists for the
  operation's ordering channel" applies, and it is **Unresolved**" (03:710-712). `OPS-27`'s rows include "Exactly
  one resource across every channel" and the no-verified-correlator row, and the table states no precedence
  between them.
- `CNF-278` repeats "the step-8 barriers and account-read cases" on a `correlator: none` descriptor, "making no
  assertion about the correlator pair on the latter" (10:2821-2825). The credentials-rejected/account-unreachable cases fail at step 1. The fresh-account case says
  "let the List offers read complete, then commit termination before step 8 commits" (10:2817–2820): it passes
  the read at step 4 and fails the conditional write at step 8. The barrier cases commit termination before
  or after step 8 respectively (10:2803–2825). Thus step 8 commits in some cases, not others; pair assertions
  must follow that outcome, not a universal step-1 assumption.
- `OPS-33`, on a channel with no verified correlator: "the search it bounds is an **operator** search, not an
  automatic one" (03:1697-1698).

### K candidate: combined candidate, unreviewed — K1–K6

- **K1** `02-provider-contract.md`, `PRV-26`: after «reconciliation would otherwise have nothing durable to search for.» insert:
  > For Robot, this recording obligation applies on every ordering channel, including one declared `correlator: none`: the kind is `ssh_key_fingerprint` and the value is the per-order key's fingerprint. See `PRV-33`.
- **K2** `02-provider-contract.md`, `PRV-32`: after «it MUST declare no correlator and `PRV-33` governs.» insert:
  > On every Robot ordering channel, including one declared `correlator: none`, the driver MUST generate a throwaway key unique to that order, and the order MUST name it in `authorized_key[]` beside the caller's keys (`08-provider-notes.md`: "`authorized_key[]` supplies fingerprints to orders"). See `PRV-9`, `PRV-26` and `PRV-33`.

- **K3** `03-operation-lifecycle.md`, `OPS-38`: «A create that recorded none has no count:» → «A create that recorded none, or whose ordering channel is declared `correlator: none` (see `PRV-33`), has no count:» (r67 K; the rest of the sentence stays). [coordinator: r67 K's "(`PRV-33`)" becomes the bare pointer "(see `PRV-33`)".]
- **K4** `10-conformance-checklist.md`, `CNF-278`: «making no assertion about the correlator pair on the latter» → «asserting, where step 8 committed, `correlator_kind` `ssh_key_fingerprint` and the per-order key's fingerprint on both, and a null pair on both where it did not»
- **K5** `10-conformance-checklist.md`, new item after `CNF-165`: after «and why the others are believed spurious. (`OPS-38`, `OPS-31`)» insert:
  > - [ ] **CNF-371** — On a standard-channel (`correlator: none`) descriptor, lose a create's order reply with exactly one standard-listing transaction carrying its fingerprint; assert **Unresolved**, operator escalation and no automatic attach. (`OPS-38`, `PRV-33`, `OPS-27`)

- **K6** `10-conformance-checklist.md`, `CNF-303` (Reader 4): after «per-order correlator-key fingerprint for Robot.» insert:
  > Run this Robot case on a standard-channel (`correlator: none`) descriptor too, settling the create through the operator's attach (`PRV-33`: "attaching a discovered machine to a tenant MUST be an operator action").

K1/K3/K5 remain r68's text; K2/K6 are r68 Reader 2's exact extracts; K4 is the r67 Reader-2 K-c
text specified in r68's tally. K2 changes the printed order-payload obligation; it is not a wording-only ride.
K6 uses the operator route. These three changes form one unreviewed combined candidate, not an accepted K-final.
No earlier pair write is authorized. See `PRV-9`, `PRV-33`, 05:326 and 05:441.

**K options (take or leave each):**
- **K-a (r67 Reader 2; zero raw r68 takes): `PRV-32` with a verbatim `PRV-33` lead-in.** Alternative to candidate K2:
  > `PRV-33` says "The driver declares the absence as that channel's `correlator: none`". The driver MUST still send a per-order key unique to the order, and `PRV-26` says "Whichever it is, the kind and the value MUST be recorded on the operation row".
- **K-b (r67 Reader 3; zero raw r68 takes): `PRV-26` quoting `PRV-33`.** Alternative to candidate K1:
  > On every Robot ordering channel, including one declared `correlator: none`, the recorded kind is `ssh_key_fingerprint` and the value is that order’s generated key fingerprint. `PRV-33` says “an ambiguous create on that channel MUST resolve to an operator, never to a guess”.
- **K-c: the `CNF-278` fix.** All four r67 readers fixed the same defect: K's first form asserted the fingerprint
  "on both" in cases that fail before step 8 commits. Candidate K4 already uses Reader 2 exactly. Take/leave that selection; if leave, choose a variant:
  - Reader 1: "asserting the pair null on both before step 8 commits, and `correlator_kind` `ssh_key_fingerprint` with the per-order key's fingerprint on both after it"
  - Reader 2: "asserting, where step 8 committed, `correlator_kind` `ssh_key_fingerprint` and the per-order key's fingerprint on both, and a null pair on both where it did not"
  - Reader 3: "asserting a null correlator pair before any successful step-8 commit, and `ssh_key_fingerprint` with the generated per-order fingerprint after that commit, on both Robot descriptors"
- **K-d (Reader 2): the window's end.** In K5, before the cite list, add:
  > After the negative window releases the commitment, assert still no automatic attach (`OPS-33`: "the search it bounds is an **operator** search, not an automatic one").

  [coordinator: Reader 2 wrote "after `OPS-33`'s window releases the commitment, no automatic attach by `OPS-32`'s
  sweep"; `OPS-33`'s verbatim words added for the quoting rule.]

**K-d fixture question, separate take/leave.** The r68 dissent cited `OPS-33` (03:1689–1692):
"the negative window MUST NOT run against a matched order that is still in progress". K5 does not specify
the transaction's progress status. K-d begins conditionally, after release; it does not explicitly force early
release. Does this exact after-release assertion need an explicit completed/not-in-progress fixture, or is it
sufficiently conditional already? Give the strongest trace, and an exact marked AMEND if a fixture change is
needed. Do not treat the three voided takes as approval of a new coordinator guard.

### Q2 questions

1. ACCEPT / AMEND (explicit mark) / CANNOT ACCEPT on the complete K candidate K1–K6.
2. Take/leave K-a, K-b, K-c (candidate K4 or exact alternative), and separate K-d; answer its fixture question.
3. Trace `CNF-303` again on this complete candidate for a standard-channel Robot create: step-8 pair,
   temporary key registration, operator attach, retained machine fingerprint, operation retention removal,
   then sweep. Does the provisioning machine retain every tagged key, including a distinct caller key?
4. Trace the lost reply with one fingerprint-bearing standard-listing transaction. Does K3 prevent automatic
   attachment through the exactly-one row while preserving operator resolution? A recorded fingerprint is
   not itself matching authority. Cite the candidate and surviving owners' words for your answer.

## Answer

- Q1: verdict on each complete form; pick and strongest argument; every option/proposal take/leave with a
  variant named. Against my pick (written on request), at most 60 words.
- Q2: verdict on the complete K candidate; every option take/leave; fixture and two traces; strongest argument.
  Against K (written on request), at most 60 words.
- Every AMEND: span id, exact replacement (and exact anchor for any new span), explicit “behaviour unchanged”
  or “behaviour changed”. Every CANNOT ACCEPT: gated loss with assertion/theorem or MUST/SHOULD and trace.
- Brief errors: each wrong fact and its evidence. Keep counterarguments distinct from votes.

At most 1,100 words excluding exact replacement text. Use compact option lines; do not omit a form verdict.
