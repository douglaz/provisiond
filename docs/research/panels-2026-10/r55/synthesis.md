# Panel r55 synthesis — triage of `pv-14b`, the checks `OPS-43`'s claim order leaves unplaced, 2026-10-16

Readers: fable (claude-fable-5-1, xhigh), opus (claude-opus-5-5, xhigh), astra (gpt-6-astra, high), sol
(gpt-6.1-sol, xhigh); clones at `cdc6adf`. All exit 0. The brief waived the gates (a text question; green at
`3acb2ef`).

## What the text already forces

- **`API-63`: before step 5, nothing more, all four.** "with no provider mutation" (04:1414) and "the last write
  before the ordering call" (04:1408-1409) order the check against step 5 only. `CNF-278`'s "no provider call"
  (10:2349) is stricter than its owner (fable). Since "Every item gates" (10:10), the requirements allow both
  placements and the checklist rejects one (sol).
- **`OPS-23`: before step 2, all four.** "Validation that was performed at the API boundary MUST be repeated in
  the worker before the driver is called" (03:1671-1672), and the sale re-test is its only stated exception
  (03:1678-1680). Its missing-field failure names no kind (03:1673-1676). `internal` is ambiguous under
  `OPS-11` (03:263-264), so it would park a create that was never sent in `needs_reconciliation`, which
  "pages a human for a typo" (03:243; fable, opus).
- **`PRV-10` and `PRV-8` fall under `OPS-23`.** The acknowledgement and the `allow_orders` opt-in are boundary
  validation (`API-15`, 04:975-977; `CNF-55`, 10:278-280), and so is the non-empty key list (13:644). They
  therefore run before step 2 (fable; opus and sol place them there). `allow_orders` is configuration (00:395)
  and can change between accept and claim (opus). Its claim-time kind is unnamed; `DOM-16` makes ordering
  capabilities conditional on it only as a SHOULD (01:566-570).
- **`PRV-47`: unplaced against the key upload, all four.** It bars only "that order request" (02:159), and a
  key uploaded first "blocks the caller's next same-key create" (02:151).
- **The absent offer has no outcome, all four.** `OPS-43` bars every step-5 mutation (03:693-695), but its
  failure paragraph opens "If the re-test finds the offer unsellable" (03:697). fable: with the descriptor's
  `traffic_bound` null, "An offer with no declared traffic bound MUST NOT be sold" (02:282) reaches it; with a
  declared bound nothing does.
- **Precedence is first-refusal everywhere outside the tail.** "Steps 1–5c still stop at their first refusal"
  (04:287). The claim-time error carries "neither `details.refusals` nor `details.not_checked`" (03:703-704),
  and `CNF-241`'s order-of-checks case assumes this (10:2589-2592; fable). The text already makes claim and
  admission disagree: a create both closed and unsellable fails `rate_limited` at claim (step 1 first) but
  `offer_not_sellable` at admission (04:266-269; opus).
- **Admission is silent on an absent offer, all four.** No clause names where admission gets its offer data.
  The tail runs "without an extra lock, ceiling slot, write or provider call" (04:262-263), and `PRV-42`'s check
  "is a dispatch check, not a provider lookup during `API-7`'s read-only tail collection" (02:1234-1235).
  Neither `LDG-27` (12:1860-1864) nor `WIR-30`'s "the commitment is priced at accept time" (13:1066) names a
  source (opus, fable; checked here).

## Claims the readers broke

1. The bead's "`OPS-23`'s missing-field failure … likewise unplaced", and the brief's "Place `OPS-23`'s … checks
   before step 5": all four. Its own text already forces it before step 2. Only its kind is open.
2. The brief's "the first failing step settles the operation": astra. A failed step-2 read may be ambiguous
   under `OPS-11`, and that is `pv-qga`'s question. Astra's wording leaves it open: "first failing check stops
   subsequent checks; its owning classification governs disposition". opus kept "the first failure settles"
   but flagged that it "needs an outcome for a failed step 2".
3. The brief's lean, placing the account check after step 4 alone: fable, opus and sol add a plain read at
   step 1. opus: without it, the claim reverses admission's account-first order (04:264-269), and step 2 calls
   the provider with credentials already recorded rejected.
4. "`CNF-278` fails a conformant engine": sol. The requirements allow both placements, and `CNF-278` rejects
   one because every checklist item gates (10:10). The defect is the same.
5. Brief fact 5's 03:262-263 is 03:263-264.

## Reader claims corrected here

- astra places `OPS-40` in the create order, but `OPS-40` is the install's signed-URL gate: it fails "if the URL
  cannot outlive the install's stated worst-case duration" (03:655-656; 13:752). `WIR-17`'s create body has no
  URL field (13:620-636).
- astra puts both `PRV-10` conditions after step 4. They are boundary validation, which `OPS-23` puts before
  step 2. astra's own order also lists acknowledgement validation under `OPS-23`.
- **The lockout count behind a step-1 account read (opus; astra argued it on request)** is too high. Robot
  blocks the source IP "for ten minutes after three failed login attempts" (02:1200), and every Robot call is
  HTTP basic (08:114). A driver that obeys `PRV-41`'s "treat an `authentication` failure as terminal for that
  credential" (02:1210-1211) stops at its first failed login, short of three. The rest of opus's point stands.
  A driver's memory of a failure need not outlive a restart, and it has none when the status was recorded
  another way. The stored status does both, and the step-1 read is how it reaches the claim. Two cases
  survive:
  - `account_unreachable`: without the read, step 2's `network` or `timeout` failure is ambiguous under
    `OPS-11`'s literal rule (03:263-264), which is `pv-qga`'s question. With the read, the create fails
    `conflict`/`state` at once and is released (04:1411-1413).
  - `credentials_rejected`: step 2's `authentication` failure is deterministic. The read changes the kind
    (`state` rather than `authentication`), honours the stored record and saves one provider call.
- fable's `CNF-278` draft opens "Record the account unhealthy before a queued create is claimed; assert it
  fails `account_terminated` at `OPS-43`'s step 1". Recording a termination already fails a queued,
  never-claimed create (04:1363-1365; the third barrier). A recoverable status fails `state`, not
  `account_terminated` (04:1411-1412). opus's draft gets both right.
- fable's "neither recoverable status appears in 04" goes too far. 04:47 names them, and 04:1411-1412 handles
  them at the worker's check. What holds is that recording one fails no queued create.
- opus says "every claim-time use of that pair is retryable" of `conflict`/`state`. No text gives a `retryable`
  value for `API-63`'s claim-time failure; 13:163 governs the tail's collection snapshot.
- Not raised by a reader: `05`'s `operations.correlator_kind`/`correlator_value` row says "Written **before**
  the provider call, like `provider_account` (`OPS-35`)" (05:382). `OPS-35` reads "before any driver call"
  (03:30-31). Read together, they put the correlator write before step 2, which is what `CNF-278` encodes.
  The rule's owners say "before the order is sent" (`PRV-26`, 02:865) and "the last write before the ordering
  call" (`API-63`, 04:1408-1409).

## Picks

| | fable | opus | astra | sol |
|---|---|---|---|---|
| Account | plain `STO-47` read at step 1, before closure; `API-63` write after step 4 | same, with `OPS-23`/`PRV-10` first | after step 4 only, no read | plain read after closure; `API-63` write after step 4 |
| `OPS-23` kind | `invalid_request`, `retryable: false` | `conflict`/`state`, `retryable: true` (re-submit succeeds) | `invalid_request`, naming the field | `internal`/`incomplete_create_record`, with an `OPS-11` exception |
| `PRV-47` | head of step 5, before any provider mutation | after step 4, before `API-63`'s write | after step 4 | before step 2 |
| Precedence | first failing step settles | first failure settles, asymmetry stated | first failing check stops; its own classification governs | stop at first failure, its own classification |
| Absent offer | `invalid_request`/`offer_not_sellable`, `retryable: false`, `failed`, `LDG-39` release | same, from a *complete* step-2 result; `PRV-42` claim freed | same | same, from a *successful* listing |
| Its home | `API-7`'s tail: "or not listed by the driver" | `OPS-43` now; file admission separately | `API-7`, `OPS-43` refers | `API-7`, `OPS-43` refers |
| `pv-qga` | depends on pv-14b | same Run, no merge, no dependency | depends on pv-14b | depends on pv-14b |
| `pv-nd6`, `pv-2s6` | independent | independent | independent | independent |

Rejected for the absent offer by all four:
- `not_found`. `DOM-21` says it "invites a re-send" (01:599-600; fable), and an offer-number `not_found` "cannot
  prove the order absent" (02:1220; opus).
- `conflict`/`state`. The Q17c response "is specific to the resource-offer guard" (04:294; fable).

Draft edits: `CNF-278`'s fourth barrier becomes "no provider mutation; the List offers read is permitted",
with the after-entry half unchanged (all four). `CNF-342` asserts no per-order key upload as well as no order
request, plus the absent offer's full outcome (all four).

## Strongest case for the other side (written on request — not the readers' positions)

- Against the step-1 read (fable, opus): one account guard, not two. A second account rule is a second copy
  free to drift (`SEC-46`), and `PRV-41`'s "MUST NOT re-attempt it on a schedule" does not reach a claim
  (opus). sol: a single conditional write moved early instead. For the read (astra): no request on
  known-bad credentials, given `PRV-41`'s lockout.
- Absence is a fact about the listing, not about the terms, so `offer_not_sellable` makes "gone" look like
  "terms changed". A catalogue offer may return within the hour, which fits Q17c's `conflict`/`state` and its
  "the offer leaves the listing" (`ADR-0036`:102; fable, opus). `DOM-17`'s `not_found`, "Named resource does not
  exist" (01:579), fits absence better, and reappearance strains "The offer cannot be bought on the same
  request" (13:165; astra, sol).
- Naming the missing field `invalid_request` avoids adding an exception to `OPS-11` (sol).

Every `file:line` above was checked against `cdc6adf`. Three reader citations were off and are corrected here:
- fable's 03:1677-1679 is 03:1678-1680;
- fable's "in the driver" (02:159) is 02:160;
- opus's 03:1673-1674 for "repeated in the worker before the driver is called" is 03:1671-1672.

## Round r55b: the missing-field kind (`OPS-23`), 2026-10-16

The round-1 split was settled by a synthesized option that no reader had voted for, so it went to its own round
before reaching the owner. The brief and the four answers are in `r55b/`. The same readers ran on clones at
`cdc6adf` with the round-1 record copied in, and all four exited 0. Options:
- 1′ (synthesized): `conflict`, a new `details.reason: "incomplete_record"`, `retryable: true`;
- 2: `invalid_request`, `retryable: false`;
- 3: `internal` plus an `OPS-11` exception.

| | fable | opus | astra | sol |
|---|---|---|---|---|
| Pick | 1′ | 1′ for a field the `api` writes itself | 1′ where a fresh admission can fill the field from unchanged caller input | 1′ with retryability set per field |
| A field the caller must send | not addressed | `invalid_request` naming the field, `retryable: false`, which is what release N's boundary answers | `conflict`/`incomplete_record`, `retryable: false`, identifying the required input | same as astra; the release adding the field states which case applies |

Agreed by all four:
- The reason is new. `"state"` collides, and no existing reason fits.
- `retryable: true` is honest mid-roll. It means "can succeed when the condition clears", as `halted` does: "The
  same purchase can succeed when the gate clears" (13:162).
- `OPS-11` is unchanged. A pre-provider `conflict` is ambiguous only when "cut off mid-flight" (03:265). The
  formal `ambiguous` (`tools/formal/Provisiond/Tables.lean`) keys `conflict` on `cutOff` alone.
- The shape holds for install, power and delete:
  - install settles `failed` "for any failure at all while `OPS-45`'s two markers say the disk is untouched"
    (03:231), with `disk_effect` and `rescue_exit` `none` (13:187, 13:201);
  - only a create releases a commitment, because "an install or a delete opens none" (12:322).

Options 2 and 3 got no votes. Two further points:
- fable: option 3 would change `OPS-11`'s Lean declaration as well. Verified: `internal` is unconditionally
  ambiguous there.
- opus: for a delete, `retryable: false` would stop an obedient caller from deleting a machine that keeps billing.

Claims the readers broke:
- **C2** (opus, astra, sol). A future release may add a field the caller must send, and the same body
  re-sent then fails at release N's boundary.
  - Nothing forbids such a field. `WIR-2` lets the server add *response* fields "without a version bump"
    (13:33-34; opus).
  - astra and sol give a concrete case: an acknowledgement in the shape of `API-14`, which "is not satisfied … by
    having sent one previously" (04:972-973).
  - "Same request" also means a fresh key, since a same-key re-send "MUST return the existing operation"
    (`API-11`, 04:929-930; opus, astra, sol).
- **C1** holds but doesn't decide (opus). `OPS-43` already emits `invalid_request`/`offer_not_sellable` at claim
  with no caller error (03:697-699).
- **C3** is scoped (astra). `suspend_tenant` is "never `failed` as a whole" (03:228).
- **C4** supports the kind only (opus). `price_moved` states no `retryable` (03:723-724; 10:2548-2551). The
  precedent for the flag is `PRV-40`'s claim-time closure: "operation-view `retryable: true`", released under
  `LDG-39`, and "A retry after expiry is a new operation" (02:1188-1194).
- **C5** was understated (opus). `"state"` is the set's generic reason (04:1045, 04:1072, 13:932). On a create
  it is also `PRV-42`'s resource-offer guard, with `retryable: false` (04:290-294).
- **The brief's "closed" reason list** (opus): `WIR-9a`'s table gives "Minimum keys" (13:125). `WIR-10a`'s
  closed enums (13:258) don't include `reason`.
- **C6** held.

Corrected here:
- fable says stating `retryable` would make 1′ "the only claim-time refusal with one". That is wrong.
  `PRV-40`'s closure (02:1191) and `OPS-43`'s unsellable offer (03:697-699) state theirs.
- The gap fable found stands: `price_moved` states no `retryable`.

Strongest cases for the other side (written on request; not the readers' positions):
- **fable.** A repeated check should repeat its verdict, as `offer_not_sellable` keeps its admission kind at
  claim (03:697-699). A new wire word would cover a failure no deployment can reach today. And `true` without
  `retry_after_ms` invites a tight loop against an old replica.
- **opus.** 1′ makes every release author sort each new field into api-written or caller-sent, and nothing
  checks the sort. A misfiled field has agents looping, spending `SEC-39` slots, for the whole roll. Option 2's
  `false` costs at most one purchase.
- **astra, sol.** `internal` names who is responsible ("Defect in this system"), and a narrow pre-dispatch
  `OPS-11` exception would keep the settlement deterministic.

Every `file:line` above was checked against `cdc6adf`.

## Consolidated recommendation, for pv-14b's agent brief

This is the manager's consolidation of the picks above and the owner's decisions below. The finishing manager
writes the agent brief from it.

- **Category:** `bug`, all four readers.
- **`OPS-43`'s claim order.** The relative order r54 settled is kept. Each check runs before any provider
  mutation unless noted.
  1. Plain read of `STO-47`'s stored status (decision 1). It fails `conflict` with `"state"` or
     `"account_terminated"`, as `API-63` words them, and releases the commitment under `LDG-39`.
  2. The closure read (`PRV-40`), unchanged.
  3. `OPS-23`'s re-validation, which its text already forces before any driver call:
     - `PRV-10`'s acknowledgement and `allow_orders`;
     - `PRV-8`'s non-empty key list;
     - the missing-field rule (decision 2).
  4. List offers, unchanged.
  5. Absence from the result (decision 3 settles the rule's home), then the sale re-test.
  6. The price comparison.
  7. `PRV-47`'s driver validation. Amend `PRV-47` (02:159) to "before any provider mutation for that create,
     including a per-order key upload".
  8. `API-63`'s conditional write, in the correlator transaction.
  9. Step-5 mutations: the key upload, then the order.
- **Precedence.** Use astra's wording: "first failing check stops subsequent checks; its owning classification
  governs disposition". That leaves the classification of a failed step-2 read to `pv-qga`.
  - Claim-time refusals are not collected; the error carries no `details.refusals` (03:703-704).
  - State the asymmetry with admission openly (opus). A create both closed and unsellable fails
    `rate_limited` at claim but `offer_not_sellable` at admission.
- **`API-63`** (04:1416-1418). Qualify "a claimed attempt with no entry has not passed the check and will fail
  at it" (astra, sol). Such an attempt does not dispatch: it fails at the step-1 read, at an earlier failing
  check, or at the write.
- **The `05` correlator row** (05:382). "Written **before** the provider call, like `provider_account`
  (`OPS-35`)" puts the correlator write before step 2. Align it with its owners: "before the order is sent"
  (`PRV-26`, 02:865) and "the last write before the ordering call" (`API-63`, 04:1408-1409).
- **`CNF-278`'s fourth barrier.** Replace "no provider call" (10:2349) with "no provider mutation; the List
  offers read is permitted" (all four). Add the step-1 cases from opus's draft (`opus.md`, item 5), which gets
  both right:
  - a recorded `credentials_rejected` fails `conflict`/`state` with no provider request;
  - a termination committed after List offers and before the correlator entry fails `account_terminated`
    with no provider mutation.

  The after-entry half stays as written.
- **`CNF-342`.** Assert no per-order key upload as well as no order request, plus the absent offer's full
  outcome for an auction offer and a catalogue offer (fable's and opus's drafts).
- **`CNF-34`.** Decision 2's landing.
- **Not asked: `allow_orders` turned off between accept and claim.** Its claim-time kind is unnamed (see
  "What the text already forces"). opus's rule, "A failed re-validation keeps the kind the API would have
  given", covers it once the admission kind is confirmed. The finishing manager checks that kind in
  `PRV-10`/`API-15` and asks the owner only if the text doesn't settle it. *The text doesn't: filed as
  `pv-p3k`, 2026-10-17.*
- **Dependencies.**
  - `pv-qga` depends on pv-14b (fable, astra, sol). opus would decide both in one Run, without a dependency.
  - `pv-nd6` and `pv-2s6` are independent, all four.

## Owner decision

Asked one question at a time, 2026-10-16.

1. **Account check: option A, 3-1** (fable, opus and sol for A; astra for B, the check after step 4 alone).
   The worker reads `STO-47`'s stored status as the new first step of `OPS-43`'s claim order, before the
   ordering-channel closure read, as admission does (04:264-269). It fails `conflict` with
   `details.reason: "state"` or `"account_terminated"` and releases the commitment. `API-63`'s conditional
   write stays last before buying.
2. **The missing-field error kind (`OPS-23`): two kinds of field.** The desk-filled kind was settled 4-0 in
   r55b. For the customer-supplied kind the owner picked B, opus's, over A, astra's and sol's.
   - **A field the `api` fills in itself** (the accepted-price fields of 03:714-717 are the example) fails at
     claim before any provider call:
     - `conflict` with `details.reason: "incomplete_record"`;
     - `retryable: true` on the error and the operation view;
     - settles `failed` under `OPS-11`, unchanged;
     - on a create, the commitment is released in full under `LDG-39`'s "Deterministic rejection before
       acceptance".
   - **A field the caller must supply** fails with what the current release's boundary answers for that body:
     `invalid_request` naming the field, `retryable: false`, settling `failed`, with the same release.
   - A release that adds a required field states which kind it is.

   Landing:

   | Identifier | Change |
   |---|---|
   | `OPS-23` (03:1673-1676) | The missing-field sentence gets both cases above, the `retryable` values on error and view, the `failed` settlement, the create's `LDG-39` release, and the rule that a release states each new required field's kind |
   | `WIR-9a` (13:137) | `"incomplete_record"` (`OPS-23`) added to `conflict`'s `reason` values |
   | `CNF-34` | Store records missing each kind of field. Assert the kind, reason and `retryable` (equal on error and view, `WIR-9b`), `failed`, no driver call, and the create's commitment released in full. Repeat on an install and assert `disk_effect: "none"` and `rescue_exit: "none"`. Control: a complete record proceeds |
   | `OPS-11`, `tools/formal/` | No change |

   **`price_moved` states no `retryable`** (r55b, fable; 03:723-724, 10:2548-2551, 13:137). It predates
   pv-14b. Every other claim-time refusal states its value: `PRV-40`'s closure `true` (02:1191), `OPS-43`'s
   unsellable offer `false` (03:697-699), and now `OPS-23`. Two engines can differ on whether a caller should
   re-submit. Filed 2026-10-17 as `pv-xer` (`needs-triage`, depends on pv-14b), outside pv-14b's brief, with
   the correction under "Triage outcome".
3. **Where the absent-offer rule lives: option 1, 3-1** (fable, astra and sol; opus for option 2), decided
   2026-10-17. The rule's home is `API-7`'s create tail. Its verdict becomes "not sellable under `PRV-13b` or
   `PRV-31`, or absent from the offers the check reads", with no lookup added to the tail. `OPS-43` refers to
   it for the step-2 result, and `CNF-166` gains an admission case. The option-1 landing table below applies.
   The outcome is settled 4-0 under "Picks": an offer absent from a successful step-2 List offers result gets
   - `invalid_request`, `details.reason: "offer_not_sellable"`, `retryable: false` on the error and the view;
   - settles `failed`;
   - commitment released in full under `LDG-39`;
   - `PRV-42`'s claim freed;
   - no per-order key upload and no order request.

   Two options:
   - **Option 1 (fable, astra, sol; the manager recommends it):** the rule goes in `API-7`'s create tail, and
     `OPS-43` refers to it.
   - **Option 2 (opus):** the rule goes in `OPS-43` only, and admission's missing offer source becomes a
     separate bead.

   Landing, option 1:

   | Identifier | Change |
   |---|---|
   | `API-7` (04:266-267) | The create-tail verdict reads "not sellable under `PRV-13b` or `PRV-31`, or absent from the offers the check reads". No lookup is added to the tail, which stays "without … provider call" (04:262-263) |
   | `OPS-43` (03:693-711) | Absence from the step-2 result gets that verdict's outcome through 03:697-711's failure paragraph, released under `LDG-39`, with `PRV-42`'s claim freed. The step-5 bar stays |
   | `DOM-9` (01:189-192) | Unchanged. It quotes `API-7`, so update the quote if the words change |
   | `CNF-166` | Add an admission case for an offer id that is absent |
   | `CNF-342` | No per-order key upload as well as no order request. For an absent auction offer and an absent catalogue offer, assert the full outcome above |

   Landing, option 2: `OPS-43` and `CNF-342` change as above, and `API-7` is left alone. File a bead covering
   both "no clause names where admission gets its offer data" and admission's absent-id outcome, with `OPS-43`
   to be pointed at `API-7` once that bead lands.

   Under option 1, the unnamed admission source (`LDG-27`, `WIR-30`, 04:262-263; see "What the text already
   forces") remains a gap of its own: two engines can price and test sellability from different offer data.
   Filed 2026-10-17 as `pv-tcs` (`needs-triage`, depends on pv-14b).

## Triage outcome, 2026-10-17

- pv-14b: `bug`, `ready-for-agent`. Its agent brief covers the consolidated recommendation and the three
  decisions above. It is the later of two brief comments: the revision adds a landing table and the
  `OPS-43` step-number criterion, and supersedes the first.
- New `needs-triage` beads, each depending on pv-14b:
  - `pv-tcs`: admission's unnamed offer source.
  - `pv-xer`: claim-time create failures that state no `retryable`. Decision 2's `price_moved` paragraph says
    "Every other claim-time refusal states its value", and that is wrong: "No text gives a `retryable` value
    for `API-63`'s claim-time failure" (corrected claims, above). Decision 1's step-1 read fails the same way.
    `pv-xer` covers both, and pv-14b's brief states no value for either.
  - `pv-p3k`: `allow_orders` has no refusal kind, at admission or at claim. `PRV-10`, `API-15` and `CNF-55`
    name none. `DOM-16`'s SHOULD sends one engine to `DOM-10`'s `unsupported`, while another picks its own
    kind, so the "keeps the kind the API would have given" rule has nothing to inherit. pv-14b places the
    check and leaves the kind to this bead.
- `pv-qga` now depends on pv-14b (fable, astra, sol).
