**Q1 pick: S. Q2: accept K.** Verdicts, AMEND texts and traces follow; every quote and anchor below was checked at `c5f897c`.

## Brief errors

- F's loss inventory is short by two items beyond the disclosed four. `CNF-307` (10:1223-1224) asserts "repeat with `account_unreachable`, `credentials_rejected` and `terminated`: the first two account entries are retryable", and `CNF-278` (10:2791-2792) asserts "a create naming it is `409` `state`". F1 places the read "after step 5d and before that transaction opens", so it runs before the tail's status refusal: on a `credentials_rejected` or `terminated` account the driver read fails `authentication`, on an unreachable one `network`, and F1's "A failed read refuses with the kind ... the read reported" returns that kind with no `details.refusals`. Both assertions flip.
- Reader 2's S-d rationale says S-final "refuses `provider`/`retryable: true` forever on such an account". With a retained fresh row S1 admits (the round's own correction). Reader 2's text is still the right one.
- S1's kind: `01-domain-model.md:587` defines `provider` as "Provider returned an error response | 502". A stale local row is none of those. No checked verdict depends on the kind, so this is an owner concern, not a vote.
- Pre-existing gap both K traces lean on: no sentence names the writer of `machines.correlator_value` on an operator `observed` attach (`WIR-35`); 05:326 only says what it holds. Not K-specific; the auction channel shares it.

## Q1

**S-final: AMEND, behaviour unchanged** (two wording repairs; everything else as printed).

- **S2**, replace the `offers` row:
> | `offers` | json | the driver's List offers result (`DOM-9`: "Prices MUST be carried as strings exactly as the provider returned them.") |

- **S4**, replace the row:
> | Offer-listing refresh (`OPS-51`) | `engine` | Reads offers at a provider, so it needs a provider credential. `STO-60`: "Every successful driver List offers read MUST publish its complete result to the account's row, replacing an existing row only when the incoming `read_at` is later." |

No gated loss found. Anchors match (04:264, 05:570, 03:2001, 00:296, 00:386, 10:3695-3699). `STO-60`/`OPS-51`/`CNF-371` are each the next id in their namespace. Quotes of `PRV-41` (02:1246-1248) and `OPS-43` ("where the provider's price has risen past what the reserve covers", 03:865) are verbatim. No Lean theorem models the offer source (`purchaseTail` takes `offerSellable` as a Bool; "provider failures ... are outside").

**F-final: CANNOT ACCEPT.** Gated losses, each with the same trace (create passes 5d, F1's driver read succeeds, the tail then refuses, no operation row exists):
1. `OPS-35` MUST (03:30-31): "resolved and written to the operation record **before** any driver call". Unlisted.
2. `OPS-11` MUST (03:258-259): admission-only kinds "are decided before any driver call". Unlisted.
3. `CNF-31b` (10:235-236): "Admission-only inputs remain pre-provider, with acceptance false." Flips for a balance-short create. Unlisted.
4. Schema 05:441: "retains `OPS-35`'s "before any driver call"". Unlisted.
5. `CNF-307`/`CNF-278` per the error above. Unlisted.
Taking F11/F12 repairs 1, 2 and 4; 3 and 5 stay broken, so no combination here is complete.

**Pick: S.** Money is already safe under both (settled `OPS-43` re-test). F buys an earlier refusal at the price of a provider round-trip inside every customer create, a credential exercised on every unhealthy account, and exceptions in five documents plus a conformance item. S changes one invariant web nowhere and makes staleness a stated parameter.

**Options.** S-a take (04:291 "Steps 1–5d still stop at their first refusal"; the staleness refusal is such a stop). S-b leave (adds a "healthy" filter and an undefined "store-clock"; moves an engine duty into the schema). S-c leave (drops the enumerated inputs). S-d take, **Reader 2's text**, applying even with a retained fresh row: the claim refuses it anyway (`CNF-364`), and `OPS-51` cannot refresh an account not declaring `list_offers`, so the row goes stale within one age. Behaviour changed against S-final, no checked verdict flips. F-a Reader 3. F-b leave (`API-7` says "A refused tail MUST commit nothing"; "write" is the stricter true word). F-c printed. F-d leave. F-e leave. F9 take. F10 take only if F lands; it is a new normative exception, not wording.

**r68 proposals.** Reader 1 S3 leave ("after an `authentication` failure" outlives an operator-cleared stop). Reader 1 S4 leave (bare-cite claim about `STO-60`). Reader 1 S-d leave; Reader 1 F11 leave. Reader 2 F11 take, F12 take, F7 take (`WIR-9a` row "`unsupported` | `provider_account`, `capability`"). Reader 2 S-d take. Reader 3 F5 leave. Reader 4 S2 take, S6 take (asserts only duties S2/S3 state), F5 take.

**Q1.3.** Claim-time no-request checks (`CNF-364`; 10:344 "no provider request, including no List offers read") are claim-side and untouched by either form. Claim publication under `STO-60` is an engine write with a monotonic later-wins rule, so `OPS-50`'s fence is not needed for correctness. Retained row: S admits, claim refuses `unsupported` with the commitment released; S-d closes it. F deletes the "no provider call" guards in `CNF-95/307/315/340/283` and `PRV-40`; they protected record-first ordering and a credential-free admission path, and survive only for mutations.

## Q2

**K candidate: ACCEPT.** All six anchors and quotes match (02:897-898, 02:990-991, 03:711, 10:2824-2825, 10:3682, 10:2937-2938; `PRV-33` 02:1055-1056; `08:127`). No Lean theorem is tagged `PRV-26`, `PRV-32`, `PRV-33` or `OPS-38`, and `searchStep` has no channel kind. K2 is a payload obligation; the owner should note `PRV-32`'s condition 2 is verified on the auction channel only.

**Options.** K-a leave (restates `PRV-26`'s rule inside `PRV-32`, a second normative copy). K-b leave. K-c take candidate K4. K-d take. **Fixture:** no AMEND needed. K3 gives a none-channel create "no count", so no "matched order" exists for `OPS-33`'s "the negative window MUST NOT run against a matched order that is still in progress" to shield; `OPS-33` then mandates release ("the commitment MUST still be released on it", 03:1696) whatever the listing's progress state. K-d's after-release assertion is therefore reachable in K5's fixture, and a build that withheld release for an operator-visible in-process transaction would be treating it as a match, which K3 and `PRV-33` forbid.

**CNF-303 trace.** Step 8 writes `ssh_key_fingerprint`/fingerprint and `about_to_order_at` (05:441, K1). Step 9 registers the caller key and the generated key as temporary resources tagged with the operation id, then orders naming both (K2, `PRV-9`). Resolution has no count (K3), the operator attaches (`WIR-35` `observed`, K6), the machine stays `provisioning`, retention removes the operation row. The sweep: "A vanished operation record satisfies only the settlement condition; the sweep MUST still check the provisioning condition against retained `machines` rows", read through the fingerprint; "Every temporary key tagged with that operation id, including a caller key distinct from Robot's correlator key, has the same eligibility" (02:152-153). Both keys are retained, given the attach writes the pair (the gap noted above).

**Lost-reply trace.** `OPS-27` searches "on **every ordering channel the driver reaches**" and the standard listing carries `authorized_key[].fingerprint`, so one hit appears. Without K3 the "Exactly one resource across every channel" row attaches automatically, against `PRV-33`. With K3, `OPS-38` reads "or whose ordering channel is declared `correlator: none` ... has no count: `OPS-27`'s row for "no verified correlator exists for the operation's ordering channel" applies, and it is **Unresolved**"; `PRV-33` then requires "surface the recent-order listing to the operator as evidence". The fingerprint is evidence; the count is the authority, and K5 plus K-d assert no automatic attach before and after release.

**Against S (≤60).** F admits and prices on the live listing, so a dropped or re-priced offer never holds a customer's balance until claim, and no new table, sweep, two parameters or stale-row `502` reach the customer for an operator-side refresh gap.

**Against K (≤60).** Recording an unverified fingerprint in the column `OPS-27` searches invites a builder to count it; a null pair with the fingerprint in `request_summary` needs no `OPS-38` exception, and K2 mandates an extra key on a channel whose handling of it is unverified.
