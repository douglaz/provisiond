## Q1 (pv-tcs)

**F: CANNOT ACCEPT as written. With the spans below it becomes ACCEPT. S: CANNOT ACCEPT as written. Pick: F, amended.** It names the same source claim already reads (`OPS-43` step 4). Two conforming engines then read the same thing, which closes the bead's A/B split, and it needs no table, pass or parameter.

**F's losses:**
- **`DOM-10` (01-domain-model.md):** "Every operation with a capability MUST be gated on it before the driver is called." Its map gives "list offers | `list_offers`". Trace: an account declares `provision_bare_metal` but not `list_offers` (`CNF-364`'s restart descriptor). A create calls the driver with no gate, and F's "`provider` or `timeout`" cannot express `unsupported`.
- **Unlisted flips:**
  - `CNF-340`: "before any provider call or write" (10:4028).
  - `CNF-283`: "Subsequent local refusals make no provider request" (10:1893-1894).
- **Settled text:** the replacement keeps 04:275's "No additional lookup is made for this verdict" true.

**S's loss:** `OVR-17` (00-overview.md) says "Every component that runs without a caller MUST be assigned to a module", and S's refresh pass has no row. Also amend: an account without `list_offers` never gets a listing, so S refuses it `provider`, `retryable: true`, forever.

**Q1.2.** The rule kept refused creates free at the provider. `ADR-0034`'s title is the stake: "Tenant traffic cannot spend the provider request budget the system needs".
- **What F spends:** a balance-short loop costs one listing read per request. On Robot that is two requests: `GET /order/server/product` and `GET /order/server_market/product` (08:109).
- **What bounds it:** the read sits after 5c, and `Admission.lean` says "A request that reaches 5c and is not refused there consumes one unit of its budget". So `SEC-39`'s creation ceiling bounds it per principal, but only where "A deployment whose callers are autonomous MUST" applies. Nothing bounds it across principals.
- **Why that is tolerable in v1:** `ADR-0034` deferred its reserve for v1 (Q19), so no reserve is breached. Admitted creates already pay this read at claim.
- **S and the fence:** once the pass is assigned to `engine`, `OPS-50` covers it by its own words ("every component `OVR-17` assigns to the engine"). `OPS-50` also says "Writes made in the api process are not checked", which is harmless under the later-`read_at` guard. No new fence text is needed.

**Q1.3.** Safety doesn't need the sources to match: claim re-tests on "one current driver List offers result taken at claim", before any mutation. Closing the bead does: under S, two engines with different refresh timing still admit differently within the age.

**Q1.4.** No. Both forms say "the tail prices the commitment and takes the offer snapshot from it". Every 05:444 field is an offer field in that result, and the descriptor's bound comes from `PRV-44`. Both forms add a pre-tail refusal that `createPurchaseTail` doesn't model. No theorem flips, since offer presence is an input.

**Against my pick:** F puts a provider round-trip into every synchronous create, refused ones included. That runs against `ADR-0034`'s cache-inside-a-window direction. S is that pattern applied to offers: it keeps every no-call assertion intact and costs one read per account per interval, whatever tenants do.

## Q2 (pv-ytv)

**K: CANNOT ACCEPT as written (one span). N: CANNOT ACCEPT. Pick: K, amended.** One fact gets one value. The pair records what the order carried on every channel, the machine copy follows it as on the auction channel, and 05:444's "the correlator" stays equal to it. Trust lives in the descriptor (`OPS-38`, `PRV-33`).

**K's loss: `CNF-278`.** K asserts the fingerprint pair "on both" across the barrier and account-read cases. But 05:441 says the pair is "Written in `API-63`'s correlator transaction, which is `OPS-43`'s step 8". The account-read cases fail at step 1, and the Fourth case terminates "before its step-8 transaction commits". So every conforming build fails the amended item, on the auction descriptor too.

**K amend:** "That declaration is the descriptor's `correlator: none`" restates `PRV-33` without quoting it, and "still sends" must be a MUST (Q2.2).

**Q2.2.**
- **K:** step 8 writes the fingerprint and the settle copies it (05:326: "what was actually written into the provider at create"). After retention, the tagged correlator key matches `machines.correlator_value` on a `provisioning` machine. `PRV-9`'s "Every temporary key tagged with that operation id… has the same eligibility" then keeps the caller key as well.
- **N:** the same result, through the `request_summary` copy.
- **Caller key only:** the caller's key can't serve. `PRV-26` requires "unique per operation" and says the correlator "MUST NOT encode… anything else linkable to a person". So the machine pair is null under both forms, and the sweep deletes the caller key while the machine is still `provisioning`. That breaks `PRV-9`'s "only when… no machine that operation produced still reads `provisioning`". Hence the MUST.

**Q2.3.** Under either form, no conforming engine auto-attaches. `PRV-33` says "attaching a discovered machine to a tenant MUST be an operator action".
- Under N, `OPS-27`'s search reads null, which is what master's engine B already does.
- 05:360's index is on `machines`, which keeps the fingerprint.
- `OPS-32` matches keys by operation-id tag while the operation row lives.
- After release, `OPS-33` says that channel's search is "an operator search, not an automatic one". K's new case should cover that window.

**Q2.4.** N contradicts `PRV-26`. `PRV-26` says "Whichever it is, the kind and the value MUST be recorded on the operation row". N says "both are null", then calls the fingerprint "the create's correlator in `request_summary`". That makes it a correlator the MUST puts on the row, and 05:444's "the correlator" then differs from the pair. N's `CNF-278` text also asserts a summary fingerprint in step-1 failures, and N names no time that would write it. For K, only the `CNF-278` loss above.

**Against my pick:** K writes a non-null `correlator_kind` on a channel declared `correlator: none`. Every reader that treats a non-null pair as searchable must also check the channel: `OPS-33`'s continued search, and `OPS-36`'s "attach the machine". A reader that forgets would auto-attach. N's null rules that mistake out.

## Brief errors

1. **The "four" undercounts.** `CNF-340` ("before any provider call or write", 10:4028) and `CNF-283`'s "Subsequent local refusals make no provider request" (10:1893-1894) also forbid a provider call on a refusal.
2. **04:306-307 is not API-7's rule.** It sits in the italic "*Amended 2026-10-09 (`ADR-0039`…)*" record. The normative 04:287-288 says "A refused tail MUST commit nothing and write no `STO-35` receipt" and names no provider call.
3. **Q2.3's "05:360's index" is on `machines`.** 05:357-361 ("index on `(correlator_value)` for reconciliation lookup") sits under `### machines`. The `operations` indexes at 05:467-469 include none on the correlator.

---

## Replacement text

**F, `API-7` insert** (replaces F's insert at 04:264):
> On create, after step 5d and before that transaction opens, the `api` MUST obtain, through `engine`'s narrow trait (`OVR-10a`), one current driver List offers result for the named offer's provider account, in the order of `OPS-43`'s step 4: "Gate on `list_offers` under `DOM-10`, then obtain the current driver List offers result." That result is the only source of the offers the check reads. The tail prices the commitment, takes the offer snapshot and tests the offer for sale from it. A gate refusal or a failed read stops the create as step 5d's does: "A refusal stops here and is not collected by the tail." A failed read refuses with the kind and `retryable` the read reported (`DOM-17`), committing nothing.

**F, 04:306-307:** leave it untouched. Add a new note: *Amended 2026-10-25 (`pv-tcs`; panel r67): named one admission List offers read, made before the tail, as the offers the check reads.*

**F, `CNF-340`:** "before any provider call or write" → "before any provider mutation or write; the admission List offers read is permitted".

**F, `CNF-283`:** "Subsequent local refusals make no provider request" → "Subsequent local refusals make no provider request other than the admission List offers read".

**F, `CNF-166`, added case:** "On an account declaring the ordering capability but not `list_offers`, assert `unsupported` with `details.capability: "list_offers"`, no `details.refusals`, and no List offers read, commitment, operation or receipt."

**S, new `OVR-17` row:**
> | The offer-listing refresh pass (`API-7`, `05-persistence.md` `offer_listings`) | `engine` | It lists offers at a provider, so it needs a provider credential |

**K, `CNF-278`:** "making no assertion about the correlator pair on the latter" → "asserting, where step 8 committed, `correlator_kind` `ssh_key_fingerprint` and the per-order key's fingerprint on both, and a null pair on both where it did not".

**K, `PRV-32` insert:**
> `PRV-33` says "The driver declares the absence as that channel's `correlator: none`". The driver MUST still send a per-order key unique to the order, and `PRV-26` says "Whichever it is, the kind and the value MUST be recorded on the operation row".

**K, new case, append:** "…and, after `OPS-33`'s window releases the commitment, no automatic attach by `OPS-32`'s sweep."
