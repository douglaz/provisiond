# Panel E r73: votes from the opus seat

**Votes:** H is ACCEPT. U is CANNOT ACCEPT, but only as a count objection: I verified no gated loss in U. I prefer H.

## Checks I ran

The clone is clean at c5f897c. I applied each form myself (`$TMPDIR/opus-apply/apply.py`) at the brief's base offsets:
- Every anchor matched its base span, with whitespace normalized.
- Spans were applied in descending order within each file, using assemble.py's separator rule.
- All 9 H spans and all 18 U spans applied.
- Both scratch trees are byte-identical to `check/H` and `check/U`: `diff -r -q` printed nothing.

| Form | `python3 tools/check_coverage.py` exit | Uncovered | Baseline |
|---|---|---|---|
| H | 0 | 74 | Unchanged. `coverage-baseline.json` and `citation-baseline.json` are byte-identical. The uncovered list matches base. Requirements go from 513 to 515: STO-60 and OPS-51 are both covered, through CNF-166. |
| U | 0 | 74 | Same as H. |

All four embedded quotations appear verbatim in base (whitespace normalized), each inside the requirement it is credited to: PRV-50 (including its nested PRV-12 words), PRV-41, DOM-9 and OPS-43.

## Form H: ACCEPT

**Strongest argument.**
- The default makes completeness depend on a rule instead of a list. The misses r72 verified (CNF-99, CNF-299, CNF-243) were all enumeration misses. The sweep shows 103 more create paths with no condition, so no list will close the gap.
- The header uses the same idiom as the existing "Seeds in the items below" preamble. It fixes the fixture wherever an item leaves it open, and it keeps every unspecified refusal universal over age. Target (1) therefore holds by construction.
- The only declared narrowing is exact M8, and M8 is necessary.

**Scope reading: it decides the vote, and I take the per-assertion reading.** The header says "An item that … without specifying the stored listing's age". Read per item, it would drop the default from every item that now states an age. A grep of the applied file finds exactly two: CNF-166 (S6) and CNF-343 (M8). Three assertions at U's M5/M6/M7 sites would then flip, which is a gate failure. The text rules that reading out:
1. **"the stored listing's age"** uses the definite article. S1 makes each create read "the provider account's stored offer listing", so the phrase names the listing the asserted create reads.
   - CNF-166's stale case is a different create, introduced by "Separately".
   - M8 names only "Each of these further creates".
   - Neither states an age for the bounded-offer create, the initial race or the catalogue creates.
2. **"This default qualifies only the admission or success assertion and any create used to reach it"** makes the assertion the unit, not the item.
3. **"For the stale-listing refusal case, see `CNF-166`"** places CNF-166 inside the header's scope.

**Does H cover every success?** Yes, on that reading; I found no miss. On the per-item reading, which I reject, the misses would be exactly three:
- CNF-166: "An otherwise sellable offer … is admitted".
- CNF-343: the initial race winner.
- CNF-343: "A catalogue product admits independent creates".

Each success class the brief named:
- **Proceeds.** CNF-99's "creates … proceed" is an admission, so it falls under "asserts … a create being admitted".
- **First send.** CNF-299's "succeeds as a first send" is covered, and so is its repeat whose first send committed.
- **Generic writes.** CNF-296 ("an `api` write" waiting in SyncRep) and CNF-21/22/23/24 (operations under one key) depend on admission whenever the chosen write is a create. A non-create write is outside S1, which says "On create". CNF-151 is checked statically "against the routing table", so listing age can't affect it.
- **Shared winning races.**
  - In CNF-343's initial race, the loser gets its 409 "at the admitting conditional-write barrier". S1's age check runs earlier, "before any admission write". Reaching the barrier therefore presupposes a fresh listing for both contenders, so the any-age clause for refusals can never demand a 409 from a stale loser.
  - In CNF-163, the tail collects the loser's `insufficient_balance` inside the serialized `LDG-35` transaction. A collected refusal takes precedence over the age check at every age.
- **Release probes.** The header says "including a create used to show a release", and M8 says the same.
- **Creates used to reach later assertions.** "relies on" and "any create used to reach it" cover them. Examples: CNF-278's queued and claimed creates, CNF-364, CNF-106, CNF-316–318 and the CNF-358–361 interruption drivers.
- **Claim time.** The header puts no condition on claim time, and no age check exists there.

**Does H narrow any refusal assertion (target 1)?** No. Earlier setup is fixed to a fresh listing; later refusals keep every age.
- **CNF-278.**
  - The 409 `state` for all three statuses, on both catalogue routes, is a tail refusal. It holds at every age and with no row.
  - **Second barrier:** "assert the create is refused" holds at every age. On a stale listing the refusal is `provider`, raised before the STO-47 write. On a fresh listing the guard itself refuses. Because the assertion is universal it includes the fresh case, so an implementation without the guard still fails it; it is not vacuous.
  - The Third and Fourth barriers and the account-read cases use fresh setup, then claim-time refusals that don't depend on age.
- **CNF-307.** Every listed refusal is collected by the tail. The early pipeline runs before the tail. "Race admission against … conditional-write guards" is generic and universal.
- **M8** limits CNF-343's further losing creates to a fresh listing. It is CNF-343 text, not CNF-278 or CNF-307, and it is declared.
  - It is also needed. At a stale age, "further creates lose" either is satisfied by a `provider` refusal, which proves nothing about the exclusion guard, or contradicts S1's MUST, if "lose" means the 409.
  - Because M8 states the age, the header's any-age clause doesn't override it. Its release-probe half repeats the header and agrees with it.

**Traces.** I derived these from S1's guard ("If the tail has collected no refusal…") and from base: "An offer absent from the offers the check reads is an unsellable offer for every rule in this tail". They agree with `check/traces.md`.

| Case | Result (same in H and U) |
|---|---|
| D1: healthy, stale, unsellable | 400 `offer_not_sellable`, retryable false. Cap and balance skipped with `because: offer_not_sellable`. No pacing, amounts, writes, receipt or provider calls. Same as base at every age. |
| D2 | 429 with the channel refusal as headline. Entries: channel, solvency, rate. Cap and balance skipped for `rate_unavailable`. Retryable true; channel pacing only. Same as base. |
| D3: every unhealthy status × offer × rate × cap | 409 `state` comes first. Terminated gives false. A recoverable status gives true, unless an offer entry (unsellable, or absent when there is no row) makes it false. Each present check is skipped for `provider_account_not_healthy`, then `offer_not_sellable`. Same as base when fresh, stale and with no row. |
| D4 | Balance is evaluated. A short balance gives 402, same as base. An adequate balance gives target (2): 502 `provider`, retryable true, no entries. |
| D5 | Stale retry: 502, retryable true. It writes nothing and leaves no receipt, so the same key is evaluated afresh. Fresh retry: 202, with the normal admission writes and receipt. H supplies the fresh listing through its default; U through M1. |
| Healthy, no row | The empty set means the offer is absent: 400, retryable false, cap and balance skipped. Never `provider`. |
| Healthy, stale, no other refusal | 502 `provider`, `retryable: true`. Raised after collection, with priced checks evaluated, and before any admission write. No commitment, operation, receipt, provider call or pacing. |

**Strict quoting, span by span.**
- **S1:** references only; its MUST sits in API-7's tail.
- **S2:** its MUSTs sit in its owner, STO-60. The PRV-50 and DOM-9 quotations are verbatim.
- **S3:** its MUST sits in OPS-51. The PRV-41 quotation is verbatim and defines "the authentication stop".
- **S4/S5:** table rows, no MUST.
- **S6:** assertions only; the OPS-43 quotation is verbatim.
- **M8 and the header:** references only, no MUST.

No sentence asserts what another requirement says without quoting its words.

**Counterargument, written on request.**
- The header never says outright that its unit is the assertion. A reader who takes the per-item reading flips the three assertions listed above.
- Guard probes outside M8 can still be run stale and "pass" without exercising the guard: CNF-278's second barrier and CNF-343's API-63 termination race. Universality keeps the property, but not a lazy test.
- A blanket rule over age is new meaning that every reader has to apply correctly across 112 create paths.

## Form U: CANNOT ACCEPT (count objection; no verified gated loss, does not block)

**Strongest argument.** U has the same S spans, M8 and traces as H, so it has no policy defect. Its fixture conditions are selective, and the selection is inconsistent:
- M3 conditions CNF-315 "For the commitment assertions in this item". CNF-106 asserts the same kind of thing — "The reserve commits **customer** price … and the setup fee **at cost**" — and gets no condition.
- CNF-364 starts "Admit a complete create on an account that declares `list_offers`…" and gets no condition. On a stale listing, its claim-time assertions can't be reached.
- 103 create paths carry no condition (sweep.json).

When nine items spell out a fresh listing, a reader can infer that the items without one may run at any age. That inference is the defect the header was written to remove.

The other omissions I checked do not flip under a strict reading, which is why I claim no gated loss:
- CNF-364 is a setup instruction.
- CNF-340 is existential ("can reach purchase admission").
- CNF-229 is a comparison.
- CNF-34's records bypass the API.
- CNF-106 is vacuous rather than false when no reserve exists.

**Counterargument, written on request.**
- U keeps the checklist's existing per-item fixture idiom and adds no blanket rule or scope question for readers to get wrong.
- It repairs every miss r72 verified.
- Its omissions are disclosed, and none of those I checked flips an assertion. When an item says "admit", the test author already has to arrange the admission.

## Preference

H.
