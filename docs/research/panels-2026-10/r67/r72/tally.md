# r72 tally (panel E: whole-form S1–S6 + M1–M7). 2026-10-26

Base: `c5f897c32f7894d77a544528872176f241394d0d`. Rules: [notes.md](notes.md), fixed before
launch; [brief.md](brief.md); [fable](fable.md), [opus](opus.md), [astra](astra.md), [sol](sol.md).
The structure follows r71/tally.md only; none of its votes, void rule or old all-verdicts target
is imported. The operative target is main's restatement in
`/var/tmp/provisiond-manager/owner-q1-sync-2026-10-23.md`, “Panel E r71 → r72”.

**Answer validity checked first:** every exit file is 0; every answer is substantive; no answer
contains a session-limit line. [answer-validity.json](/var/tmp/provisiond-panel-r72/tally-evidence/answer-validity.json) retains
first lines, sizes and hashes. No seat needs replacement. Q2's exact r69 K1–K6 plus original
K-d remains settled and is not tallied again.

## Outcome: (b) scoped whole-form read; valid tally, not void

**Counted result: 1 ACCEPT / 3 CANNOT ACCEPT.** Fable ACCEPT; opus AMEND (**behaviour changed**),
counted CA; astra CA; sol CA. Rule 1 does not convert an omitted-success-fixture amendment into
wording: it still changes behaviour. The acceptance threshold fails. The CNF-99, CNF-299 and
CNF-243 omissions also establish rule-3 blocking losses.

**The verified blockers converge on missing target-(3) amendments, not a policy conflict.**
Astra identifies distinct CNF-99 and CNF-299 success assertions; sol identifies CNF-243.
Each permits an otherwise eligible stale-listing create to which S1's new age refusal applies.
The policy matches target (2); its success fixture was not listed as target (3) requires.
These are different assertions with the same repair pattern, not one defect independently
found by all dissenters. Opus identifies a different CNF-343 continuation-scope question.
Its stale-guard hypothetical is real, but M6 already says “For this race, each create”; the
scope of that phrase and the meaning of “lose” prevent treating its conditional objection as
a verified additional checked-verdict loss. The full assessment and narrower-reading consequence
are below. Its changed AMEND still counts CA irrespective of whether it blocks.

**No S text goes into the Run yet.** The concrete unreviewed next form is
[next-read-candidate.md](/var/tmp/provisiond-panel-r72/tally-evidence/next-read-candidate.md): the complete printed S1–S6/M1–M7,
astra's exact CNF-99/299 replacements, sol's exact CNF-243 replacement, opus's exact M8, and
sol's exact Q1–Q3 quotation replacements. Its complete operation list is
[next-read-operations.json](/var/tmp/provisiond-panel-r72/tally-evidence/next-read-operations.json); applied bytes are
[proposed-next-read](/var/tmp/provisiond-panel-r72/tally-evidence/proposed-next-read/). It is a candidate for a read, not a
reviewed recommendation or a Run input. M8 is explicitly distinguished from success-only
target-(3) additions; the next read must resolve that scope rather than smuggle a refusal
policy amendment into a fixture. No new round or Run is launched here. No owner-question.md
is drafted: the verified blockers have compatible local repairs, not competing policy choices.

**No all-dissenter acceptance of that exact union has been recorded.** Opus formally offers
M8+its Q1–Q3 as an AMEND; astra and sol supply required local repairs but end CA. None has seen
the union, and neither CA explicitly promises ACCEPT even after just its own amendments.
Their quoted positions and exact text are preserved below. Do not report “all would accept”
or upgrade a vote on inference. Ask all four about the exact union in the scoped read.

## Reader verdicts and strongest arguments

| Reader | Whole-form verdict | Strongest argument, theirs | Count / gate disposition |
|---|---|---|---|
| fable | **ACCEPT**; its Q1–Q3 are explicitly not conditions | “The only changed verdicts are otherwise-admissible stale creates, and every base assertion such a create must satisfy is listed in M1–M7.” The first part describes the examined tail repair; the completeness claim is disproved by the CNF-99/299/243 sentences below. | **ACCEPT** remains its vote. Do not replace its vote with its requested counterargument. |
| opus | **AMEND (behaviour changed)**: M8, with quotation Q1–Q3 marked unchanged | Base CNF-343: “assert further creates lose on every replica; settle it and assert the exclusion releases.” It reads the later loss as the earlier 409/state/false and M6 as covering only initial contenders. | **CANNOT ACCEPT**, rule 1. Scope ambiguity recorded; no independently verified rule-3 block on the full-race M6 reading. |
| astra | **CANNOT ACCEPT**; CNF-99/299 repairs changed | CNF-99: “assert that creates and re-derivations proceed at the rate in force”; CNF-299: “the same key re-sent after capacity returns succeeds as a first send”. A stale, otherwise eligible create instead gets 502/provider/true. | **CANNOT ACCEPT**, verified omitted target-(3) success amendments; each is a rule-3 block. |
| sol | **CANNOT ACCEPT**; CNF-243 repair changed | CNF-243: “the re-assignment verb gives one of them a live account, `GET /v1/providers` then returns it, and a create against it succeeds.” The replacement account can be healthy while its stored listing is stale. | **CANNOT ACCEPT**, verified omitted target-(3) success amendment; rule-3 block. |

Rule 2 cannot carry a form with this count. Rule 4 calls for a scoped read of the compatible
repairs. Rule 5 authorizes no deletion, and none is proposed. Rule 7 is applied to the separately
labelled requested counterarguments below. The stored direction and Q2 remain settled.

## Verification of every verdict-changing claim

All source files were independently frozen from `git archive c5f897c` in
[source](/var/tmp/provisiond-panel-r72/tally-evidence/source/). Every printed application was made uniquely in
[candidate](/var/tmp/provisiond-panel-r72/tally-evidence/candidate/), including whitespace normalization of S6's wrapped
anchor; all changed-file bytes match preparation's applied copy. The candidate's omitted
success spans remain byte-exact before-spans. Literal repair before-spans match base and
applied candidate once each. [verify.py](/var/tmp/provisiond-panel-r72/tally-evidence/verify.py),
[verification.json](/var/tmp/provisiond-panel-r72/tally-evidence/verification.json), [applications.json](/var/tmp/provisiond-panel-r72/tally-evidence/applications.json)
and [exact-repairs.json](/var/tmp/provisiond-panel-r72/tally-evidence/exact-repairs.json) retain that evidence.

The required **grep, then sed** evidence is in
[source-checks.txt](/var/tmp/provisiond-panel-r72/tally-evidence/source-checks.txt) and
[source-checks-extra.txt](/var/tmp/provisiond-panel-r72/tally-evidence/source-checks-extra.txt), for both frozen base and
applied candidate. [traces.md](/var/tmp/provisiond-panel-r72/tally-evidence/traces.md) builds each witness with an explicit
clock, listing dispatch, failed refreshes, healthy status, amounts, rate, pipeline position,
retry key and admission effects. These are source traces, not implementation tests.

Common witness: age 10 minutes, refresh interval 5 minutes, row dispatched at 12:00, transient
failed refresh attempts at 12:05 and 12:10, create at 12:10:01. Sellable X, healthy account,
open ordering channel, present rate, no halt, reserve 100 sats, balance 1,000 sats, cap 200 sats,
free catalogue admission. S1 at applied 04:264 says “If the tail has collected no refusal”
and requires stale refusal “before any admission write, committing nothing”. STO-60 at applied
05:572 says “A failed read MUST leave the row unchanged.” OPS-51 at applied 03:2003 requires
a read attempt, not success: “MUST read every account declaring `list_offers` at least once
per stated offer-listing refresh interval”. Frozen STO-47 at 05:1185–1189 explicitly says
“`driver_observation` is reserved and today unreachable” and “on a launch deployment every row
carries `configuration` until an operator records something”. The failed reads do not force
the common witness to have an unhealthy stored status.

| Finding | Base coordinates / exact assertion | Concrete before → applied result | Kind / same defect? |
|---|---|---|---|
| astra CNF-99 | 10:721–724, “assert that creates and re-derivations proceed at the rate in force” | Below-quorum pass leaves an observation window producing R; no rate halt. Eligible create proceeds at R in base; the same priced facts with a 601-second stored row yield 502/provider/true and no admission. “Fresh window” qualifies the rate observations, not the listing. | **Real**, omitted success-fixture amendment under target (3). Does not contradict target (1)/(2). Distinct assertion from CNF-299/243. |
| astra CNF-299 | 10:1093–1099 (applied 1092–1098), “the same key re-sent after capacity returns succeeds as a first send” | Choose create for generic “write”. At 12:10:01 checkout overload yields 503 and no transaction/receipt. Restore capacity, resend identical new K at 12:10:02 without a fresh publication. Base admits; applied returns 502/provider/true, no receipt. Already-committed replay returns at 5a and is unchanged. | **Real**, omitted target-(3) success amendment. Distinct from CNF-99; same repair pattern. |
| sol CNF-243 | 10:3105–3108 (applied 3101–3104), “and a create against it succeeds” | Terminate old A; operator reassigns T to healthy B with the stale row; GET /v1/providers returns B; eligible create against B gets 502/provider/true, rather than base success. Assignment/catalogue do not force a successful List offers call. | **Real**, omitted target-(3) success amendment. Distinct from both astra assertions; same repair pattern. |
| opus CNF-343 continuation | 10:4106–4107 (applied 4096–4097), “assert further creates lose on every replica; settle it and assert the exclusion releases” | Initially fresh contenders race; winner's step 8 commits, winner stays unresolved across restart. A stale further create is 502 before the guard, where base can give 409/state/false. But M6 at applied 4095 says “For this race, each create” uses a fresh listing. If it covers the continued scenario, this stale witness is outside the listed fixture. The continuation does not separately specify the later refusal payload. | **Real scope ambiguity**, **not established as a checked-verdict flip** on the full-race M6 reading. On opus's narrower reading, missing follow-up fixture scope affects a refusal control as well as a possible success-after-release probe; it is not purely a target-(3) success amendment. No separate target-(1)/(2) violation is proved. Distinct from the success omissions. |

The full CNF-343 continuation remains in scope: M6's “For this race” is not silently rewritten
to “the initial pair”. Nor does this tally declare the converse interpretation impossible.
Opus explicitly makes its block conditional: “If the tally reads it as covering them, this
objection is not gated.” Its M8 disambiguates the continuation and any create used to observe
release, and retains its behaviour-changed mark. A guard check must actually be exercised;
502 alone cannot serve as evidence of a functioning exclusion. The proposed read must test
that requirement explicitly. This scope assessment is sufficient to withhold an unproved block;
it does not grant approval to the candidate or to M8.

For the normative guard claims, frozen PRV-42 at 02:1260–1266 says “An unresolved create retains
the claim until its outcome is known” and “If the claim fails” it MUST use the ordinary response.
API-7 at 04:298–302 scopes that response to “a create whose resource-offer conditional write
affects no row”. No such write occurs in the new stale trace; no resource is admitted through
an untested guard. STO-58 at 05:893–895 still says “Its lifetime follows the winning create's
outcome settlement; an unresolved exclusion has no independently invented expiry.” A source
trace cannot simply assert that the age clause releases that state.

The CNF-278 second barrier and CNF-307 conditional-write control are also checked in traces.md:
“assert the create is refused” (10:2796–2799) and “Race admission against the existing account/fence
conditional-write guards; rich collection must not weaken either guard” (10:1297–1298).
Setups that deliberately reach a guard can still do so fresh; a stale refusal is not evidence
of that guard. No stale admission bypass or additional required payload flip is established.
Opus labels CNF-285's proposed extension “plausible, not verified”, outside its AMEND. It is
preserved as a question for the next read, with no automatic new fixture restriction.

## Existing repair and M1–M7 disposition

All readers report that the age-after-collection core repairs the examined rich-tail refusals.
The inherited r71 findings are carried forward. S1's literal antecedent “If the tail has collected
no refusal” preserves existing collected fault entries; D4's “omitting the cap leaves balance
evaluated and `not_checked: []`” (CNF-307, base 10:1281–1283) is an evaluation assertion, not an
unqualified admission assertion. No D4 amendment is needed. Equality with the age bound does
not satisfy S1's “older than”. No-row still supplies the empty source. Claim-time OPS-43 at
03:759–761 retains “one current driver List offers result taken at claim”. No additional
Lean theorem loss is established; the full repository gate receipt below is not a proof of
the candidate's semantic completeness.

The exact M before/replacements are in brief.md, “Complete candidate”; no proposed M is altered
here. Their positive controls, confirmed against the before-spans, are:

| Listed amendment | Quoted base assertion | Local disposition |
|---|---|---|
| M1, CNF-307 10:1292 | “admission succeeds, proving refusal left no replay receipt” | Fresh condition qualifies successful create retry; existing refusal combinations remain unqualified. |
| M2, CNF-138 10:1165 | “Assert that an EUR create and `extend-runway` are admitted” | Only the EUR create acquires age refusal; extension/deposit controls stay. |
| M3, CNF-315 10:805 | “the commitment includes `first_unit` at the customer rate and the setup fee at cost” | Covers the item's commitment assertions, including zero-unit controls. |
| M4, CNF-163 10:3674 | “one commitment and one `insufficient_balance`” | Freshness on both creates preserves the winner and balance-loser race. |
| M5, CNF-166 10:3690 | “is admitted and opens a commitment sized to that bound” | Qualifies the positive bounded-offer control; offer refusals stay. |
| M6, CNF-343 10:4102 | “exactly one wins, and the loser receives an ordinary HTTP `409 conflict`/`state` error” | Expressly qualifies both the winning and losing initial race fixtures; continuation scope is the opus issue above. |
| M7, CNF-343 10:4108 | “A catalogue product admits independent creates.” | Explicit fresh fixtures preserve independent catalogue admissions. |

Each is necessary for its own disclosed positive control under the round's interpretation;
none covers the unedited CNF-99/299/243 sentences. Fable's “No refusal fixture is narrowed in
any of them” overstates M6: the brief explicitly says it “discloses the restriction on the race
control as well as its success assertion”. That overstatement does not alter its ACCEPT vote.

## Exact behavioural repair texts and completeness

The following are copied byte for byte from the readers' fenced before/replacement blocks,
not manager rewrites. Each before-span matches frozen base and applied candidate exactly once.
They are mutually compatible applications. **All remain behaviour changed**, including those
that only add a missing listed success fixture. Local completeness does not confer a reviewed
whole-form acceptance.

### astra CNF-99 — behaviour changed

Before (exact, unique in the applied r72 candidate):

```text
**A sub-quorum pass with
      a fresh window**: with a window that produces a rate, run one pass below `LDG-59`'s quorum and
      assert that creates and re-derivations proceed at the rate in force, that no `LDG-40` halt
      fires and no `LDG-64` outage opens, and that the next accepting pass recomputes the rate.
```

Replacement (exact reader proposal):

```text
**A sub-quorum pass with
      a fresh window**: for the create-success assertion in this case, use a stored listing
      containing the named sellable offer, with its `read_at` no older than the offer-listing
      age (`OVR-19`) at the admitting transaction. With a window that produces a rate, run
      one pass below `LDG-59`'s quorum and assert that creates and re-derivations proceed at
      the rate in force, that no `LDG-40` halt fires and no `LDG-64` outage opens, and that
      the next accepting pass recomputes the rate.
```

### astra CNF-299 — behaviour changed

Before (exact, unique in the applied r72 candidate):

```text
Saturate one replica's
      write checkouts and assert the next write, under a key never sent before, is refused
      `overloaded`, 503, with `retry_after_ms`, that `STO-35` holds no receipt for that key, that
      the same key re-sent after capacity returns succeeds as a first send, and that a read still
      succeeds under the separate read budget; then repeat with a key whose first send committed
      before its reply was lost, and assert the re-send after the refusal returns the existing
      operation (`API-11`).
```

Replacement (exact reader proposal):

```text
Saturate one replica's
      write checkouts and assert the next write, under a key never sent before, is refused
      `overloaded`, 503, with `retry_after_ms`, that `STO-35` holds no receipt for that key, and
      that a read still succeeds under the separate read budget. After capacity returns,
      for the successful first-send retry of a create, publish a stored listing containing
      the named sellable offer, with its `read_at` no older than the offer-listing age
      (`OVR-19`) at the admitting transaction; resend the same key and assert it succeeds as
      a first send. Then repeat with a key whose first send committed before its reply was
      lost, and assert the re-send after the refusal returns the existing operation (`API-11`).
```

### sol CNF-243 — behaviour changed

Before (exact, unique in the applied r72 candidate):

```text
After `SEC-46` records a
      confirmed termination, the affected tenants are surfaced to the operator, the re-assignment
      verb gives one of them a live account, `GET /v1/providers` then returns it, and a create
      against it succeeds.
```

Replacement (exact reader proposal):

```text
After `SEC-46` records a
      confirmed termination, the affected tenants are surfaced to the operator, the re-assignment
      verb gives one of them a live account, `GET /v1/providers` then returns it, and, with a stored listing containing the named sellable offer, with its `read_at` no older than the offer-listing age (`OVR-19`) at the admitting transaction, a create against it succeeds.
```

### opus M8 CNF-343 — behaviour changed

Before (exact, unique in the applied r72 candidate):

```text
Kill the winner after step 8 commits and keep it unresolved across engine restart and assert further
      creates lose on every replica; settle it and assert the exclusion releases.
```

Replacement (exact reader proposal):

```text
Kill the winner after step 8 commits and keep it unresolved across engine restart and assert further creates lose on every replica; settle it and assert the exclusion releases. Each of these further creates, including any create used to show the release, uses a stored listing containing the named sellable offer, with its `read_at` no older than the offer-listing age (`OVR-19`) at the admitting transaction.
```

**Completeness judgment:** astra's pair repairs both its local success assertions without
qualifying unrelated rate, overload, read-budget or stored-replay controls. Sol's replacement
repairs the local post-reassignment success while preserving the other CNF-243 assertions.
Opus's M8 supplies freshness both to further losing creates and to a create used to show
release; it resolves its scope concern on that proposed form. M8 is more than a success-only
fixture if its narrower-scope interpretation is adopted. None of these individual packages
covers the other readers' distinct findings. Their union plus the full quotation repairs
below covers every verified defect found in this tally and the recorded M6 scope ambiguity;
this is a bounded local statement, not an unreviewed claim of exhaustive checklist correctness.
No edit to S1/guards is justified or proposed by these local success witnesses.

## Each reader's exact wording amendments

These are the supplied quotation sections verbatim, preserving each author's ordering,
punctuation, optionality and mark. All restore quotations only; no normative exception,
payload or new assertion is authorized by their wording mark. The whole owner sentences were
checked at frozen PRV-50 02:123–124, PRV-41 02:1246–1248 and OPS-43 03:854–867. Sol Q1–Q3
match them under whitespace normalization and apply uniquely. They are the exact wording
package in the proposed next read; no wording repair alone makes r72 pass.

Fable Q2 still quotes only part of the long OPS-43 sentence and is **incomplete under the
explicit whole-sentence convention**, despite restoring the mutation qualifier. Its optional
Q3 restores the trailing citation; punctuation is wording. Opus Q2 is a bare pointer, which
the brief permits, rather than a claim that its shortened quote is the whole sentence.
Astra/sol's long Q3 supplies the complete owner sentence. These alternatives are not silently
merged into a new reader-authored wording package.

### fable — exact quotation proposals

## Strict-quotation repairs (behaviour unchanged, verified byte-exact against owners under whitespace normalization)

**Q1, S2 `STO-60`.** Before: `` `PRV-50` says "The driver's List offers MUST be read-only". `` Replacement:
```text
`PRV-50` says “The driver's List offers MUST be read-only under `PRV-12`'s guarantee: "Get machine MUST be read-only and free of side effects".”.
```
Omitted operative condition: "under `PRV-12`'s guarantee". Curly outer marks keep the inner pair intact for the citation gate, as S3 already does.

**Q2, S6.** Before: `` (`OPS-43`: "where the provider's price has risen past what the reserve covers") `` Replacement:
```text
(`OPS-43`: "fail the operation deterministically — before any provider mutation — where the provider's price has risen past what the reserve covers")
```
This is the span `CNF-248` (`10:3140–3142`) already quotes; the fragment omitted "before any provider mutation".

**Q3, S3, optional.** Before: `` MUST surface it for an operator” `` Replacement: `` MUST surface it for an operator (`OPS-26`).” `` Only the trailing citation was dropped; all operative conditions are present, so this one can be skipped.

The candidate's `DOM-9` and `WIR-30` quotes are whole sentences and verbatim. The current fragments pass the citation gate (coordinator's gate-after exit 0); these are `AGENTS.md` sentence-quoting repairs, reported, not blocking.

### opus — exact quotation proposals

## Quotation repairs (behaviour unchanged; reported, not blocking)

- **Q1, S2 (`STO-60`).** The quote cuts `PRV-50`'s sentence short and drops its operative words ("under `PRV-12`'s guarantee … free of side effects"). The inference "outside the driver read" rests on exactly those words.
  - Replace: `` `PRV-50` says "The driver's List offers MUST be read-only" ``
  - With: `` `PRV-50` says “The driver's List offers MUST be read-only under `PRV-12`'s guarantee: "Get machine MUST be read-only and free of side effects"” ``
- **Q2, S6 (`CNF-166`).** `` (`OPS-43`: "where the provider's price has risen past what the reserve covers") `` quotes a fragment of one long `OPS-43` sentence (03:854–867).
  - Replace it with the bare pointer `` (`OPS-43`) ``. The assertion stays where it is, and the brief allows bare pointers.
  - Base already quotes an `OPS-43` fragment the same way in `CNF-241` ("telling the caller to re-submit…"). So this is a repair under the strict rule, not a new kind of defect.
- **Q3, S3 (`OPS-51`).** The `PRV-41` quote leaves off the sentence's closing citation.
  - Replace: `MUST surface it for an operator”`
  - With: ``MUST surface it for an operator (`OPS-26`)”``
  - The missing citation isn't operative, but the strict rule asks for whole sentences.

The DOM-9 quote in S2 is a whole sentence and verbatim (01:185).

### astra — exact quotation proposals

**Quotation repairs — all behaviour unchanged; none resolves the blockers.**

The inherited excerpts match their source words, but the printed candidate does not quote the complete owner sentences. Printing complete sources elsewhere in the brief does not repair the candidate.

**Q1 — S2, STO-60, `05-persistence.md`, PRV-50 attribution.**

Before:

```text
`PRV-50` says "The driver's List offers MUST be read-only".
```

Replacement:

```text
`PRV-50` says “The driver's List offers MUST be read-only under `PRV-12`'s guarantee: "Get machine MUST be read-only and free of side effects".”
```

**Q2 — S3, OPS-51, `03-operation-lifecycle.md`, PRV-41 attribution.**

Before:

```text
`PRV-41` says “A driver MUST therefore treat an `authentication` failure as terminal for that credential, MUST NOT re-attempt it on a schedule, and MUST surface it for an operator”.
```

Replacement:

```text
`PRV-41` says “A driver MUST therefore treat an `authentication` failure as terminal for that credential, MUST NOT re-attempt it on a schedule, and MUST surface it for an operator (`OPS-26`).”
```

**Q3 — S6, CNF-166, `10-conformance-checklist.md`, OPS-43 citation span.**

Before:

```text
(`OPS-43`: "where the provider's price has risen past what the reserve covers")
```

Replacement, preserving the owner’s whole sentence and operative conditions:

```text
(`OPS-43`: “After the sale re-test passes, and before any per-order key upload or other provider mutation, the worker MUST re-read the offer's current price from that same List offers result **in the provider's own currency** and compare it with the native price the commitment was sized from — **carried on the operation's `request_summary`, which MUST hold the accepted recurring price, its currency and its period, and the accepted setup fee and prepaid first unit, the unit with its `billing_unit.seconds`** (`LDG-2`, `LDG-67`; *the unit and its seconds added 2026-10-08, `ADR-0033`, because the machine's row copies the seconds for its first seed, `LDG-38`, `05-persistence.md`*; *the fields are named so a worker restarted before claim can perform this comparison at all*; *named 2026-09-05 — a first form cited a native figure on the commitment row, which carries only `reserved_sats`*) — and **fail the operation deterministically — before any provider mutation — where the provider's price has risen past what the reserve covers**: `conflict`, `details.reason: "price_moved"`, the shortfall in `details`, telling the caller to re-submit, and `retryable: true` on both the error and the operation view (`WIR-9b`).”)
```

These restore quotations only; they add no fixture, payload or normative exception.

### sol — exact quotation proposals

**Quotation repairs — each behaviour unchanged.** The following before-spans match the applied candidate uniquely. Replacement quotations match complete owner sentences with whitespace normalization only. They were not silently applied. The DOM-9 price quotation already matches its complete sentence.

Q1 — [05-persistence.md](https://github.com/douglaz/provisiond/blob/c5f897c32f7894d77a544528872176f241394d0d/05-persistence.md), S2 / STO-60 caller-publication sentence; **behaviour unchanged**.

Before:

```text
The read's caller publishes the result, outside the driver read: `PRV-50` says "The driver's List offers MUST be read-only".
```

Replacement:

```text
The read's caller publishes the result, outside the driver read: `PRV-50` says “The driver's List offers MUST be read-only under `PRV-12`'s guarantee: "Get machine MUST be read-only and free of side effects".”
```

Q2 — [03-operation-lifecycle.md](https://github.com/douglaz/provisiond/blob/c5f897c32f7894d77a544528872176f241394d0d/03-operation-lifecycle.md), S3 / OPS-51 attribution sentence; **behaviour unchanged**.

Before:

```text
`PRV-41` says “A driver MUST therefore treat an `authentication` failure as terminal for that credential, MUST NOT re-attempt it on a schedule, and MUST surface it for an operator”.
```

Replacement:

```text
`PRV-41` says “A driver MUST therefore treat an `authentication` failure as terminal for that credential, MUST NOT re-attempt it on a schedule, and MUST surface it for an operator (`OPS-26`).”
```

Q3 — [10-conformance-checklist.md](https://github.com/douglaz/provisiond/blob/c5f897c32f7894d77a544528872176f241394d0d/10-conformance-checklist.md#L3700), S6 / CNF-166 OPS-43 parenthetical; **behaviour unchanged**.

Before:

```text
(`OPS-43`: "where the provider's price has risen past what the reserve covers").
```

Replacement:

```text
(`OPS-43`: “After the sale re-test passes, and before any per-order key upload or other provider mutation, the worker MUST re-read the offer's current price from that same List offers result **in the provider's own currency** and compare it with the native price the commitment was sized from — **carried on the operation's `request_summary`, which MUST hold the accepted recurring price, its currency and its period, and the accepted setup fee and prepaid first unit, the unit with its `billing_unit.seconds`** (`LDG-2`, `LDG-67`; *the unit and its seconds added 2026-10-08, `ADR-0033`, because the machine's row copies the seconds for its first seed, `LDG-38`, `05-persistence.md`*; *the fields are named so a worker restarted before claim can perform this comparison at all*; *named 2026-09-05 — a first form cited a native figure on the commitment row, which carries only `reserved_sats`*) — and **fail the operation deterministically — before any provider mutation — where the provider's price has risen past what the reserve covers**: `conflict`, `details.reason: "price_moved"`, the shortfall in `details`, telling the caller to re-submit, and `retryable: true` on both the error and the operation view (`WIR-9b`).”).
```

## Acceptance conditions — what was actually said

| Reader | Quoted position | What can be claimed |
|---|---|---|
| fable | “three strict-quotation repairs supplied below as behaviour-unchanged wording, not conditions of the vote” | ACCEPT on the printed form; no vote on the union of newly discovered success repairs. |
| opus | “The AMEND is M8 (behaviour changed) with Q1–Q3 (behaviour unchanged).” Also: “If the tally reads it as covering them, this objection is not gated.” | A formal amendment package for its own scope concern; no promise to accept astra's or sol's additional success fixtures. Its counterargument says “the form could be accepted with Q1–Q3” on the broader reading, but rule 7 forbids converting that requested counterargument into its vote. |
| astra | “Proposed replacement — **behaviour changed**, narrowing only this create-success fixture” and “Both before-spans match base and the applied candidate exactly. These proposals were **not applied** to the reviewed candidate.” Final: “CANNOT ACCEPT.” | Exact CNF-99/299 additions offered and locally verified; no explicit ACCEPT-after-patch statement, and no review of the union. |
| sol | “Required additional amendment — behaviour changed.” Also: “This narrows a success fixture. It requires a behavioural amendment and was **not applied** to the reviewed candidate.” Final: “CANNOT ACCEPT.” | Exact CNF-243 addition required and locally verified; no explicit ACCEPT-after-patch statement, and no review of the union. |

Therefore **whether every CA/AMEND reader would ACCEPT exactly the complete additions is not
established by these answers**. The proper next action is a whole-form read asking that exact
question; neither the manager nor a tally may supply the missing votes. The exact additions
are printed above and in next-read-candidate.md, not merely described as “freshness fixes”.

## Brief and inventory error ledger — rule 6 exactly

Rule 6 says: “A verified brief error that changes a question's premise voids that question's
tally only; re-ask it corrected. Other brief errors are reported with the tally, identifying
any vote whose reason rests on one.” This task adds no void rule. No changed premise is
established. The brief explicitly asks readers to challenge the inventory, inspect for
omissions and treat omitted flips as blocks under target (3). Discovering an omitted success
amendment is the intended result of that review, not grounds to void its votes.

| Claim/error | Verified disposition / vote dependence |
|---|---|
| Inventory CNF-99, check/assertion-inventory.md:25, “No independent unconditional admission-success assertion identified” | False under this round's reading: base 10:723 explicitly asserts creates proceed. Astra disproves it. Fable's strongest completeness reason rests on the mistaken inventory conclusion, but its vote is retained. |
| Inventory CNF-243, check/assertion-inventory.md:66, same generic classification | False: base 10:3105–3108 expressly says a create succeeds. Sol disproves it. Fable and opus's no-other-success-omission claims miss it. |
| CNF-299 absent from success inventory | Verified absent entry, despite generic “write” and “succeeds as a first send”. Astra supplies the create witness. Fable/opus's stated sweeps miss it. |
| Inventory CNF-343:94, “later existing resource exclusion remains tested” | A fresh race witness exists; the wording does not settle M6's continuation scope or certify every stale outcome. Record the ambiguity; do not treat that inventory claim as an independent proof or a new void rule. |
| Fable “No unlisted unqualified success assertion found”; opus “My searches found no other create-success assertion without a fresh-listing condition” | Search conclusions, not source facts; defeated by the verified success sentences. This does not create extra CA votes or invalidate their recorded answers. Astra and sol each also miss the other's omissions; their own blockers remain real. |
| Wrapped S6 before-span / temporary 76-uncovered copies | Only whitespace normalization is needed. Every complete applied form reports 74 and baseline unchanged. An incomplete failed application is not the final candidate; no remaining application failure. |
| Quote fragments in S2/S3/S6 | Real convention defects, wording-only under rule 3; full sentences are supplied above. Not a changed technical premise and not a blocking semantic loss. |

No reader's dissent relies on a premise-changing false brief claim: astra/sol cite the actual
success text; opus expressly states its own scope dependency. No tally is voided.

## Counterarguments written on request — not votes

* Fable conditionally suggests additional guard fixtures if barrier reach is treated as an
  assertion. It ends “I do not adopt it.” Do not relabel that paragraph as fable's objection.
* Opus offers the full-scenario M6 reading and generic non-admission meaning of “lose” as its
  requested counterargument. Its formal vote remains changed AMEND.
* Astra says CNF-99 could be read only as rate-gate permissiveness and CNF-299 could use a
  nonpurchase write, but “they narrow the printed assertions without a listed amendment”.
* Sol says a naturally fresh reassignment witness would pass, but “A fresh witness cannot
  defeat the unqualified stale counterexample under this round's rules.”

## What main should do next — exact scope of (b)

Prepare a whole-form four-reader confirmation of **exactly**
[next-read-candidate.md](/var/tmp/provisiond-panel-r72/tally-evidence/next-read-candidate.md), with all original S1–S6/M1–M7
plus the literal additions/replacements above. Carry no votes forward. Keep the restated
target and ask all readers to confirm acceptance of the entire union; independently check
the success inventory beyond literal “create” matches. Resolve M6/M8's continued-race scope
expressly and distinguish its losing guard control from a pure success-fixture amendment.
Keep CNF-278/307 and tentative CNF-285 guard concerns as checks, not silently added fixtures.
No new policy, age ordering, guard ordering, optional C or no-row alternative is included.

Supply the complete CNF-99/299/243/343 context in the clones alongside the original whole
CNF-307 through its actual end and CNF-278 create/claim passage. The clocked source traces
in traces.md are the concrete challenge cases. Preserve old refusals, freshness equality,
no-row absence, retry receipts, extension controls and the existing claim-time live read.
All fixture narrowing remains behaviour changed even when it only completes target (3).
Only a later qualifying count and verified loss check can make that whole form Run-ready.

This tally launches nothing. No repository spec, bead, commit, remote or memory edit was made.

## Validation

* Required full repository gates before tally: unpiped `nix develop --command bash tools/check-all.sh`,
  exit 0, all gates PASS; [tally-gate-before.log](tally-gate-before.log) and .exit.
* Exact printed candidate: unpiped `python3 tools/check_coverage.py` in tally-evidence/candidate,
  exit 0, 74 uncovered, baseline 74 byte-identical; [receipt](/var/tmp/provisiond-panel-r72/tally-evidence/verification.json).
* Exact proposed union: same coverage command in tally-evidence/proposed-next-read, exit 0,
  74 uncovered, same baseline. This is coverage evidence only, not panel approval or a full
  candidate gate certification. All reader repair anchors apply uniquely and quote owners match.
* Required full repository gates after tally: unpiped `nix develop --command bash tools/check-all.sh`, exit 0, all gates PASS; [tally-gate-after.log](tally-gate-after.log) and .exit. Repository tracked tree remains clean at c5f897c.
