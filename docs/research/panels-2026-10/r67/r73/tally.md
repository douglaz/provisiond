# r73 tally (panel E: Form H checklist default versus Form U per-item union). 2026-10-26

Base: `c5f897c32f7894d77a544528872176f241394d0d`. Rules: [notes.md](notes.md), fixed before launch;
[brief.md](brief.md); [fable](fable.md), [opus](opus.md), [astra](astra.md), [sol](sol.md).
The structure follows r72/tally.md only. Its votes, outcome and any other round's extra void
instruction are not imported. Q2 is not voted again.

**Answer validity checked first:** all current exit files contain 0; all current answers are
substantive; none contains a session-limit line. The two archived Claude answers in
`failed-0840/` consist only of “You've hit your session limit · resets 11:10am (UTC)” and do
not count. The current fable/opus answers are the replacement batch received around 11:23Z,
on the same brief; astra/sol were not replaced. [answer-validity.json](/var/tmp/provisiond-panel-r73/tally-evidence/answer-validity.json)
records current first lines, sizes and hashes. [unchanged-inputs.json](/var/tmp/provisiond-panel-r73/tally-evidence/unchanged-inputs.json)
checks the prepared hashes of the brief, notes, forms and analysis inputs. No failed answer is a vote.

## Outcome: reviewed H carries; both tallies valid, not void

**H: 4 counted ACCEPT / 0 CANNOT ACCEPT. U: 0 counted ACCEPT / 4 CANNOT ACCEPT.**
There is no AMEND on either form from any reader. No verified unlisted rule-3 loss blocks H.
H alone qualifies under rule 2 and goes into the Run under the recorded owner ruling. The
preference tie-break is not invoked; every reader explicitly states H, but none accepts U.
U's fixture-completeness objections affect its counted-ACCEPT threshold even without a blocking
loss. An absence of a blocking loss does not convert CANNOT ACCEPT to ACCEPT.

[run-input.md](run-input.md) is written: exact reviewed Form H, file by file, with literal
base before spans and their exact after spans, plus the exact r69 K1–K6 and original K-d at
r69 brief.md:361–362. It quotes the relevant decisions verbatim from
`/var/tmp/provisiond-manager/owner-q1-sync-2026-10-23.md`. No new wording repair rides. The
already-integrated Q1–Q3 quotations are part of what all four just accepted.

No Run, new panel, owner question, specification edit, bead edit, commit, push or memory edit
was made. Rule 4's neither-form fallback is not reached. Rule 5 authorizes no deletion here;
no unread combination substitutes for H.

## Reader verdicts and strongest arguments

| Reader | H verdict | U verdict | Exact AMEND / behaviour mark | Preference | Counted H / U |
|---|---|---|---|---|---|
| fable | ACCEPT | CANNOT ACCEPT, “no gated loss” | None; no AMEND and no mark | H | ACCEPT / CANNOT ACCEPT |
| opus | ACCEPT | CANNOT ACCEPT, “count objection; no verified gated loss, does not block” | None; no AMEND and no mark | H | ACCEPT / CANNOT ACCEPT |
| astra | ACCEPT | CANNOT ACCEPT | “No AMEND is proposed.” | H | ACCEPT / CANNOT ACCEPT |
| sol | ACCEPT | CANNOT ACCEPT | “No amendments proposed.” | H | ACCEPT / CANNOT ACCEPT |

**Fable, H — strongest argument:** “It scopes the fresh fixture to ‘asserts or relies on a
create being admitted or succeeding’, which reaches implicit creates (‘admit a complete create’,
‘claim a create’, a machine that exists only through admission) that any enumeration misses”.
Its U objection is the missing conditions on CNF-364, CNF-318 and CNF-278 setups. It explicitly
says: “Any repair that adds the missing fixtures is behaviour changed”. That is an argument,
not an exact replacement or AMEND vote.

**Opus, H — strongest argument:** “The default makes completeness depend on a rule instead of
a list.” Its acceptance explicitly takes the per-assertion reading; the scope verification
below therefore matters to the count. Its U argument is the contrast between M3 and the
unqualified reserve/setup cases: “When nine items spell out a fresh listing, a reader can infer
that the items without one may run at any age.” The number belongs to [sweep.json](/var/tmp/provisiond-panel-r73/check/sweep.json),
not a fresh claim that every selected path proves a broken assertion.

**Astra, H — strongest argument:** “The header’s ‘asserts or relies on a create being admitted
or succeeding’ covers implicit admission dependencies, while ‘only the admission or success
assertion and any create used to reach it’ confines the fixture qualification.” Its U objection
is concrete: CNF-364 starts “Admit a complete create on an account that declares `list_offers`
and the ordering capability.” A stale otherwise-eligible admission cannot reach that item's
claim-time assertion. Astra expressly treats this as a fixture-completeness count objection,
not an additional gated loss.

**Sol, H — strongest argument:** “Its scope follows the asserted behavior rather than an
inventory of item numbers”. Its U objection names CNF-364, CNF-241 and CNF-151, then says:
“A fresh fixture remains possible, and some conservative inventory paths use injected records
or driver-only execution. My U vote rests on incomplete explicit fixture coverage.” CNF-151's
more limited routing-table scope is checked below; CNF-364 remains a concrete admission example.

## Verification of every verdict-changing claim

Verification uses frozen base source, independently applied complete candidates and the exact
printed header. [verify.py](/var/tmp/provisiond-panel-r73/tally-evidence/verify.py) passed; its full
[source-evidence.md](/var/tmp/provisiond-panel-r73/tally-evidence/source-evidence.md) carries verbatim owner wording and
source coordinates beside the analysis. The preparation quotation manifest was independently
checked with fixed-string `rg` after whitespace normalization; additional source passages were
checked the same way. No external-provider fact is needed for this tally.

### Header scope, including fable's reading note and opus's condition

The reviewed first sentence says, verbatim:

> An item that asserts or relies on a create being admitted or succeeding, including a create used to show a release, without specifying the stored listing's age, runs on a stored listing that contains the named offer and has a `read_at` no older than the stated offer-listing age at the admitting transaction (see `OVR-19`).

The reviewed limiting sentence says, verbatim:

> This default qualifies only the admission or success assertion and any create used to reach it; an item asserting a refusal without specifying the stored listing's age asserts it whatever that age.

Read together, the first sentence includes an admission the item relies on, and the second
includes “any create used to reach it”. The restriction belongs to that create/admission,
not every assertion or every later clock instant in the item. An explicitly aged separate
create does not assign that age to all other creates in the same item. This supports opus's
stated acceptance condition without changing the printed text.

Fable flags “qualifies only the admission or success assertion” against “relies on”, but also
says: “Read with the first sentence it is unambiguous; I do not stake the vote on it and
propose no AMEND, since a scope clarification could not be verified behaviour-unchanged.”
That is faithfully retained. **No clarification is certified behaviour unchanged or added.**
The Run input carries the reading note as a note, and the reviewed words as the words to apply.

Checked mixed-item consequences:

- CNF-166's earlier control says “An otherwise sellable offer with a bound no later than
  provider-local today and a sellable traffic bound is admitted and opens a commitment sized
  to that bound.” S6's new stale case starts “Separately”. The header supplies the earlier
  admission's age; the separate explicit stale refusal does not cancel it.
- CNF-343's initial race says “at the admitting conditional-write barrier exactly one wins”.
  The initial competing creates are needed to reach that shared assertion. The separate
  assertion “A catalogue product admits independent creates” also gets the default.
  M8's “Each of these further creates” applies to the continued probes, not those other creates.
- CNF-278 says “leave a create `queued` and unclaimed” and “claim a create”; its account-read
  cases start “admit a create and leave it `queued` and unclaimed”. H supplies an earlier
  admitted setup wherever needed. The later termination, claim-time status, step-8 and provider
  mutation assertions retain their own conditions. Freshness is not required again at claim.

These are the concrete cases that would have made opus reject an item-wide reading. That
reading is not adopted by any reader, and the printed limiting sentence supports their common
reading. No premise-changing briefing error is established.

### Success classes and U omissions

The complete H default covers the named categories by its words: direct/proceeds admission,
first-send success, a create chosen for a generic write assertion, both participating admissions
needed for a winning-race assertion, the expressly named release create, and earlier admissions
used to reach a later assertion. A driver-only or injected-state fixture may bypass API admission;
the header does not invent an API call in such a fixture. No reader names a success outside H's scope.

Concrete U omissions verified against its applied bytes:

- CNF-364: “Admit a complete create on an account that declares `list_offers` and the ordering
  capability.” This is an unambiguous API admission setup. U leaves that item unchanged.
- CNF-318: “Re-list the offer with a 3600-second unit between a create accepted at 60 seconds
  and the machine's first seed”. That earlier accepted create has no U age condition.
- CNF-241: “With the offer still sellable and the price unchanged or lower, it proceeds.”
  Its surrounding text says “Restart the process between API acceptance and claim”. The earlier
  API acceptance is a genuine dependency; U leaves its age unstated. The quoted “proceeds”
  itself is claim-time progress, not a second admission-time age check.

For a concrete stale counterexample, publish a sellable row at dispatch t=0, take an age setting
of 60 seconds, let non-authentication refresh attempts fail so the row remains, and attempt an
otherwise-eligible healthy create at t=61. S1 says “If the tail has collected no refusal” and
then “the create MUST be refused `provider` … with `retryable: true` before any admission
write, committing nothing.” There is no operation to claim. A t=60 admission satisfies
“no older than”; a new successful read followed by timely admission supplies a fresh witness.
This verifies the missing explicit fixture, not a new impossible/universal requirement.

Sol's CNF-151 example needs qualification. The complete item says “Asserted against the routing
table”. Opus identifies that restriction correctly. It is not independently established as a
runtime success test that stale admission flips; it is not counted as an additional gated loss.
Sol's CNF-364 example and incomplete-fixture rationale survive that qualification, so its stated
vote is retained, not rewritten or inferred into a different vote.

[inventory-audit.json](/var/tmp/provisiond-panel-r73/tally-evidence/inventory-audit.json) checks that the active-item identifiers
and selected/explicit/omitted lists reconcile with the source and [sweep.json](/var/tmp/provisiond-panel-r73/check/sweep.json).
That list owns the counts. Neither the list nor this tally proves that every conservative path
is an independent mandatory API assertion. The omissions were disclosed in the brief. Each
reader rejects U on target-(3) completeness while explicitly disclaiming an extra verified gated
loss. The demonstrated stale change is target (2), which rule 3 expressly exempts; fresh setups
remain reachable. The counted result stays U 0/4.

### Shared races, continued guard probes and the later refusal distinction

M8's reviewed sentence is exact reader text in both forms:

> Each of these further creates, including any create used to show the release, uses a stored listing containing the named sellable offer, with its `read_at` no older than the offer-listing age (`OVR-19`) at the admitting transaction.

This explicitly restricts the continued losing probes as well as the release probe. It is a
declared fixture amendment under rule 3, not an unspecified refusal whose age is silently
narrowed by the header. After restart, a stale otherwise-eligible probe would encounter S1's
age refusal before its conditional write. That result alone cannot demonstrate exclusion.
M8 makes the probes reach the guard, and is retained exactly; its release half is redundant
with H's default and remains part of the accepted reader text.

**Fable's same-instant claim is not verified and is not an implementation assumption.**
The account row is shared, but snapshots on two replicas need not occur at one instant and
the row may be republished between them. Being one account does not prove equal ages. H
supplies the fresh admission fixture for each create used to reach the shared winning-race
assertion; U's explicit race fixture also covers each create. That is the basis for acceptance,
consistent with opus/astra/sol and the preparation trace note, without fable's extra assumption.

The base guard text remains: API-7 says “Admission retains the conditional-write guards in
`API-63`, `LDG-62` and `PRV-42`; collection does not replace them with read-only guards.”
CNF-307 says “rich collection must not weaken either guard”; CNF-278 says “a mere read there is
not enough under snapshot isolation”. A stale `provider` refusal can satisfy an unspecific
“is refused” subcase without testing the guard. That is a limitation of that individual witness,
not permission to omit the fresh eligible branch: the unspecified-age refusal keeps the fresh
case too, which must exercise the conditional write. No verified guard assertion becomes
unreachable or vacuous over all its fixtures. Neither form silently adds a new all-ages guard
fixture restriction. This records fable/opus's requested counterargument without treating it as a vote.

CNF-163's serialized balance loser is different: the source asserts “one commitment and one
`insufficient_balance`”, and a collected balance refusal is considered before S1's age test.
The shared success fixture supplies admission freshness; a stale listing does not replace a
collected insufficient-balance result.

### Complete refusal projections and model limits

The independent formula in [verify.py](/var/tmp/provisiond-panel-r73/tally-evidence/verify.py) matches every row of
[trace-cases.json](/var/tmp/provisiond-panel-r73/check/trace-cases.json); [projection-audit.json](/var/tmp/provisiond-panel-r73/tally-evidence/projection-audit.json)
records its complete create and extension products, zero skipped, and the declared changes.
It was derived from the source words quoted in source-evidence.md, not by running the
preparation's formula again. Both forms' policy/storage/refresh/settings bytes match each other.
This is source analysis, not implementation conformance or an independent Lean proof.

| Case | Verified result, common to H and U |
|---|---|
| D1, healthy stale unsellable | Offer 400/false; present priced checks skipped for offer; no priced amounts, writes, receipt, calls or headline pacing. |
| D2, sellable channel + solvency + no rate | Ordered channel/solvency/rate, 429/true; present priced checks skipped for rate; channel owns headline pacing. |
| D3, account/offer/channel/solvency/rate combinations | Unhealthy state first, offer then independent entries; skip reasons account/offer/rate in defined order; false offer or terminated entry makes the envelope false. |
| D4, healthy stale with available price inputs | Balance runs and `not_checked` is empty without cap; a short balance remains 402/false. Only an otherwise empty collection reaches the new 502/true refusal. |
| D5, same key after faults clear | A stale otherwise-eligible retry still refuses without receipt; H's default or U's M1 supplies freshness for the successful retry. |
| Every unhealthy status, every age/source branch | 409/state remains first; recoverable account entry true, termination false; independent entries survive; age alone adds no offer refusal to a sellable stored row. |
| Healthy no row | S1 supplies “an empty offers set if no listing is stored”; absence gives an offer refusal, not an otherwise-admissible stale `provider` refusal. |
| Extensions | Create-only account/offer/channel/age predicates do not change their fence/solvency/rate/cap/balance outcomes. |

API-7 says “Entry 0 is the headline” and “No maximum is taken and a subordinate entry MUST NOT
supply pacing to a headline kind that does not require it.” WIR-9b says “the envelope's
`retryable` MUST be true iff every refusal entry's `retryable` is true.” WIR-9a says skipped
entries follow “check order `commitment_cap`, `balance`, then reason order
`provider_account_not_healthy`, `offer_not_sellable`, `rate_unavailable`”. These owner words
verify the readers' precedence, skip, retryability and pacing claims. Amount fields remain
per-entry; no hidden offer price becomes a cap/balance amount. The projections summarize amount
visibility and pacing ownership; they are not a serializer or a numeric pricing implementation.

Fable's formal observation is accepted only at the model's stated scope. Admission.lean says
“`purchaseTail` carries `API-7`'s refusal collection over snapshot inputs; it does not read
provider-account or machine rows, compute a price, serialize responses or execute a write.”
`empty_iff_admitted` equates `purchaseTail`'s empty refusals with `tailAdmitted` over those
inputs. No listing-age argument appears there. S1 preserves those collected refusals and adds
an age result after empty collection; no existing theorem flip is verified. The current model
does not prove the new overall age policy. Fable's analogy to `createPurchaseTail`'s unsupported
gate is not a timing rule: the unsupported gate runs before collection; the new age check runs
after it. Any formal work required in the Run remains governed by AGENTS.md/ADR-0025, with no
theorem weakened or new statement silently substituted by this tally.

## Exact amendments and wording disposition

**No reader proposes an AMEND on H or U.** There is therefore no replacement text or behaviour
mark to apply under rule 1. None of the requested counterarguments is converted into one.

Fable's two other non-blocking wording notes are preserved: “the authentication stop” is not
a separately defined glossary label, and S4's “Why there” cell is a pointer. The reviewed S3
itself quotes PRV-41: “A driver MUST therefore treat an `authentication` failure as terminal
for that credential, MUST NOT re-attempt it on a schedule, and MUST surface it for an operator
(`OPS-26`).” Thus the operative exception is credential-scoped and has its owner's words;
neither note supplies an exact alternative or demonstrates a broken requirement. No fix rides.

The integrated Q1–Q3 whole-owner sentences in S2/S3/S6, plus DOM-9's price sentence, match
their base owners under whitespace normalization. The quotation insertions preserve the
operative S instructions and merely carry their owners' full words; they were already printed
and reviewed, not added after voting. All readers' sentence-by-sentence checks find no new
quotation/ownership defect. S1's MUST is in API-7; STO-60 and OPS-51 hold their own MUSTs;
the other introduced MUSTs are inside attributed owner quotations. No additional wording ride
is needed or certified.

## Brief and inventory error ledger — rule 6 exactly

Rule 6, verbatim:

> A verified brief error that changes a question's premise voids that question's tally only; re-ask it corrected. Other brief errors are reported with the tally, identifying any vote whose reason rests on one.

No verified premise-changing brief error is established for H or U. The compact independent
form renderings reproduce the prepared applied bytes; U retains the archived union's bytes.
The brief discloses U omissions, the conservative nature of the inventory, driver bypasses,
M8's explicit refusal-fixture scope and the source-projection limits. Its complete CNF-307
context and required CNF-278 passage match the source. Fable's header note and opus's alternate
reading concern candidate interpretation, not a false briefing fact. The supported common
reading is verified above; no acceptance depends on the alternate reading.

The same-instant race assumption is fable's own reasoning and is corrected above; it is not
in the brief, and the other acceptance basis does not require it. Sol's CNF-151 runtime example
is qualified by its source's routing-table sentence; this does not alter the disclosed U
fixture-completeness premise. No vote is upgraded or discarded on either issue. No extra
any-error void rule is supplied by this task. **Both tallies remain valid.**

## Counterarguments written on request — not votes

| Reader | H counterargument, quoted from the answer | U counterargument, quoted from the answer |
|---|---|---|
| fable | “A blanket default is only as good as its scope words” | “An unstated fixture is not a defect under the gate” |
| opus | “The header never says outright that its unit is the assertion.” | “When an item says "admit", the test author already has to arrange the admission.” |
| astra | “A blanket default requires careful assertion-level reading” | “An implementer could infer that an instruction to admit a create includes satisfying the new age prerequisite” |
| sol | “Per-item fixtures make those assumptions more visible.” | “Existing success tests can choose fresh listings without spelling out their age” |

The complete counterarguments remain in each linked answer. In particular, an argument that
U might work with implicit fixtures is not an ACCEPT vote, and a requested H scope objection
is not a CANNOT ACCEPT vote.

## What main should do next — exact scope of the carry

Use [run-input.md](run-input.md) when preparing the separately authorized Run. It contains the
reviewed H operations, not U's discarded per-item union, and the owner-approved Q2 instructions
exactly as printed in r69. The original K-d is inserted in K5 immediately before its cite list;
opus's completed-fixture alternative is absent. K-d's “After the negative window releases the
commitment” is conditional; it does not override OPS-33's “the negative window MUST NOT run
against a matched order that is still in progress”. No new Q2 decision or wording is inferred.

[run-input-verification.json](/var/tmp/provisiond-panel-r73/tally-evidence/run-input-verification.json) verifies every unique
base anchor, every reviewed H after span, the literal K instructions and original K-d,
verbatim decision excerpts and nonoverlap of the combined H/K edits. H alone reconstitutes
check/H exactly. [run-operations.json](/var/tmp/provisiond-panel-r73/tally-evidence/run-operations.json) retains exact
before/after strings; the applied combined scratch is retained for inspection, not committed.
This step does not launch a Run.

## Validation

- Independent complete H and U application: exact match to prepared candidate bytes;
  [coverage.json](/var/tmp/provisiond-panel-r73/tally-evidence/coverage.json), both coverage exits 0, ratcheted uncovered 74,
  coverage and citation baselines byte-identical to the base. Coverage is reported separately
  from the enumerated rule-3 loss gate.
- Required repository full gates before work: unpiped `nix develop --command bash tools/check-all.sh`,
  exit 0, all gates PASS; [tally-gate-before.log](tally-gate-before.log).
- Required repository full gates after work: the same unpiped command, exit 0, all gates PASS;
  [tally-gate-after.log](tally-gate-after.log). The tracked tree is clean at the base.
  [final-validation.json](/var/tmp/provisiond-panel-r73/tally-evidence/final-validation.json) records both observed exit codes
  and repository status. Exactly one UPDATE line was added to the top RESUME bullet;
  [resume-update.txt](/var/tmp/provisiond-panel-r73/tally-evidence/resume-update.txt) retains its exact text.
