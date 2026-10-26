# Panel E r72 — Reader 2 (opus): one whole-form read of S1–S6 plus M1–M7 at c5f897c

## Vote

**AMEND (behaviour changed)** on the whole candidate, so it counts as **CANNOT ACCEPT** under the rules. It would block under rule 3 because of one omitted flip: **`CNF-343`, 10:4106–4107**. I also give three quotation repairs, Q1–Q3. They don't change behaviour and they don't block.

## The blocking finding: CNF-343's "further creates lose" flips on a stale listing

Base, 10:4106–4107, verbatim:

```text
Kill the winner after step 8 commits and keep it unresolved across engine restart and assert further
      creates lose on every replica; settle it and assert the exclusion releases.
```

Two lines earlier, at 10:4103–4105, the same item says what losing looks like: "the loser receives an ordinary HTTP `409 conflict`/`state` error with `retryable: false`, no `details.refusals`, no synthesized pacing or `Retry-After`, and no commitment, balance change, operation or receipt."

**How a further create loses in base.** It passes steps 1–5d. Its tail collects nothing: the account is healthy, the offer is sellable, a rate is present, and cap and balance pass. It then reaches the admitting conditional write and fails it. `PRV-42` says "The create's admitting transaction MUST acquire a conditional-write claim on the account, channel and offer before opening a commitment or operation; a snapshot read alone does not enforce this." It also says "If the claim fails, the create MUST use `API-7`'s "ordinary HTTP `409 conflict`/`state` error with `retryable: false`, no `details.refusals`, no synthesized pacing or `Retry-After`, and no commitment, operation or receipt" resource-offer guard response."

**The same create under the candidate.** Give it a stored listing that contains the offer but is older than the offer-listing age. S1 says "If the tail has collected no refusal and the stored listing has a `read_at` older than the stated offer-listing age (`OVR-19`) at the admitting transaction, the create MUST be refused `provider` (`01-domain-model.md`'s error taxonomy) with `retryable: true` before any admission write, committing nothing." The create never reaches the claim. It gets **502 `provider` with `retryable: true`** instead of 409 `conflict`/`state` with `retryable: false`. The asserted "lose" response is flipped.

**M6 does not cover this, judged on its replacement text.**
- M6's condition is attached to the sentence "Both read an open snapshot".
- Its referent, "For this race", is the opening race: "Race two different tenants and two replicas on one `offer_is_resource` account/channel/offer."
- The further creates come in a later phase: after the kill, after step 8 and across an engine restart. That is exactly when a stored listing can age past the limit.
- The coordinator's reason, "applies to both contenders", reads M6 the same way.
- The inventory says "later existing resource exclusion remains tested" (`assertion-inventory.md:94`). That rests on a fresh witness, and the brief rules that out: "unchanged bytes or a fresh witness do not defeat an unqualified stale counterexample."
- `traces.md` doesn't model these creates. It has only the M6/M7 lines, 921–922.

**What my block depends on:** whether M6's "each create" reaches the creates issued after the restart. If the tally reads it as covering them, this objection is not gated. I read it as not covering them, for the reasons above.

**M8 — `10-conformance-checklist.md`, `CNF-343`, 10:4106–4107. Behaviour changed.**
Before: the verbatim base block quoted above.
Replacement:

```text
Kill the winner after step 8 commits and keep it unresolved across engine restart and assert further creates lose on every replica; settle it and assert the exclusion releases. Each of these further creates, including any create used to show the release, uses a stored listing containing the named sellable offer, with its `read_at` no older than the offer-listing age (`OVR-19`) at the admitting transaction.
```

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

## Trace obligations

| Case | What happens under the candidate | Verdict |
|---|---|---|
| **D1**: healthy, stale, unsellable or absent offer, rate present, cap supplied or omitted | An offer refusal is collected, so the age clause never fires. Singleton `offer_not_sellable`, false retryability. Skips use `because: offer_not_sellable`: cap and balance, or balance only without a cap. No hidden amounts. | Unchanged |
| **D2/D3**: every channel, solvency, rate and cap combination, every account status | A refusal is always collected. A stale sellable listing is read regardless of age and adds no offer refusal. Order, skips, pacing and retryability match base. | Unchanged |
| **D4** | Balance is always evaluated, because the age clause fires only after collection ("If the tail has collected no refusal"). Every fixture where `not_checked: []` is observable collects a refusal (closed channel, solvency, short balance), so the age clause never fires there. Where nothing is refused, base admits and `not_checked` isn't observable. | Unchanged; the coordinator's claim holds and D4 needs no amendment |
| **D5** | A stale, otherwise-successful replay gets 502 `provider`, `true`. "Committing nothing" means no receipt. M1's fresh fixture then succeeds. | Listed (M1) |
| **Unhealthy matrix**: status × stale/fresh/no row × sellable/unsellable/absent × the other faults | `state` is always collected, so the age clause never fires. A stale sellable listing invents no offer refusal. No row is read as an empty set, so the offer is absent and `offer_not_sellable` is collected. A recoverable account with an absent offer gives envelope `false` (`WIR-9b`), and so does a terminated account. | Unchanged |
| **Healthy, no row** | 400 `invalid_request`/`offer_not_sellable`, `false`. Both priced checks are skipped for that reason, and no price is exposed. This is base's absent-offer verdict. | Unchanged |
| **Healthy, stale, nothing else refused** | Every applicable priced check runs, then 502 `provider`, `true`, with no write, receipt or provider call. At exactly the age limit there is no refusal ("older than"). | The settled new refusal |
| **CNF-278** | Unhealthy creates are 409 `state` at every age. The second barrier says only "assert the create is refused", and a stale create is refused, by `provider`. The other barriers start from an admitted create, and the claim still reads the provider live (`OPS-43` step 4). | Unchanged |
| **CNF-307**: early, extension and conditional-write controls | The age clause applies only to creates. | Unchanged |

## M1–M7: necessary, complete, and the verdict each changes

Each is necessary: without it, a stale listing changes the asserted outcome. Each is complete for its own span. "Before" means base; "after" means a stale fixture without the M condition.

| Amendment | Before | After, stale without it | Notes |
|---|---|---|---|
| **M1**, `CNF-307` 1292 | Resend: "admission succeeds" | 502 `provider`, `true`, no receipt | Scoping the change to creates is right |
| **M2**, `CNF-138` 1165 | EUR create admitted | 502 | `extend-runway`, the deposit and the "valued terms short" `solvency` refusals are unchanged |
| **M3**, `CNF-315` 805 | Commitment includes the unit at the customer rate; floor, zero-unit and kill-between cases | No commitment, 502 | The insufficient-balance refusal is unchanged |
| **M4**, `CNF-163` 3674 | One commitment and one `insufficient_balance` | Both 502, no commitment | |
| **M5**, `CNF-166` 3690 | Admitted, commitment sized to the bound | 502 | Unsellable and never-listed refusals unchanged |
| **M6**, `CNF-343` 4102 | One winner; the loser gets 409 `state`/`false` | No winner; both 502, `true` | Complete for the two contenders only; see M8 |
| **M7**, `CNF-343` 4108 | Independent catalogue creates admitted | 502 | |

**Setup, not assertions:**
- `CNF-340`'s "can reach purchase admission"
- `CNF-356`'s "accept creates … assert the admitting transaction's `request_summary`"
- "admit a create" in `CNF-278` and `CNF-364`
- the accept-then-claim setup in `CNF-241`

My searches found no other create-success assertion without a fresh-listing condition.

## Objections I'm recording (they don't block and are not part of the vote)

- **CNF-285: plausible, not verified.** At 10:1927 it says "Assert `offer_is_resource` still enforces `PRV-42`'s admission claim." If the tester shows enforcement with a second create, a stale listing turns that into 502 too. A possible text, behaviour changed and outside my AMEND: "Assert `offer_is_resource` still enforces `PRV-42`'s admission claim, using for any create that tests the claim a stored listing containing the named sellable offer, with its `read_at` no older than the offer-listing age (`OVR-19`) at the admitting transaction."
- **The age refusal's wire shape is unspecified.** S1 doesn't say whether the 502 carries `details.refusals` or `details.not_checked`. `WIR-9a` says "On create and extend-runway tail refusals, `details.refusals` is the ordered list", which may apply. But `WIR-9a`'s retryability table and `API-7`'s ordered list have no `provider` row.
- **Some controls stop telling builds apart on a stale fixture.** `CNF-278`'s second barrier holds on a stale fixture only because the age refusal fires first, so a build with only a lock passes it. The same goes for `CNF-343`'s "Race account termination separately to retain `API-63`'s guard". A fresh fixture still tells the builds apart, under the reading that an item covers every fixture it doesn't exclude.

## Strongest argument for my vote

The settled target says "omitted flips still block". The coordinator's whole method reads an item as covering every fixture it doesn't exclude, and that reading is the only reason M1–M7 exist. Under the same reading, `CNF-343`'s "lose" names the specific response defined just above it, 409 `state`/`false`, and a stale listing turns it into 502 `provider`/`true`. M6's own reason limits its fixture to "both contenders". Accepting this form would apply a standard to M1–M7 and then not apply it to the sentence right after M6.

## Counterargument, written on request (not my vote)

Read "further creates lose" as "are not admitted". Read M6's "For this race, each create" as every create in the race scenario, including the ones after the restart. On that reading the item is covered and nothing flips. M8 only makes explicit what a careful tester would do anyway. The remaining defects are quotation repairs, and the form could be accepted with Q1–Q3.

## Coverage and premise

- **Command:** `python3 tools/check_coverage.py`, run unpiped at the root of a scratch copy made with `git archive c5f897c` at `opus/.r72/scratch`.
- **Application:** all 14 changes applied. Each anchor matched exactly once, with no application failures. The result is byte-identical to the coordinator's `check/scratch`, apart from `.git`.
- **Result:** exit **0**; **74** uncovered; baseline **74** (set 2026-10-22). The baseline file is byte-identical to base.
- **Brief:** every before-span and source coordinate checks out at c5f897c, so there is no premise error. My vote rests on a gap in the inventory and the traces, not on a brief error.
- **Span checks:** M8's before-span matches exactly once in the applied form, after M6 and M7. The Q1–Q3 before-spans each match exactly once in the applied S2, S6 and S3 text.

The AMEND is M8 (behaviour changed) with Q1–Q3 (behaviour unchanged). Under the rules it counts as CANNOT ACCEPT, and the gated loss is that the `CNF-343` assertion flips.

Final: AMEND (behaviour changed)
