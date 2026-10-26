## Q1 (pv-tcs)

**S-final: AMEND, behaviour unchanged** (S3, S4 below). **F-final: CANNOT ACCEPT as printed.** Loss: `OPS-35`, `03-operation-lifecycle.md:30-31`, "The provider account MUST be resolved and written to the operation record **before** any driver call." Trace: F1 has the `api` call the driver's List offers after step 5d and "before that transaction opens"; the operation row is created inside that transaction, so the driver is called while no operation record exists. F10 amends `OPS-1` and nothing amends `OPS-35`. 05:441 repeats it: "The `provider_account` write retains `OPS-35`'s "before any driver call"". The repair is one span, F11, given below.

**Pick: S-final.** Admission under S makes no driver call, so `OPS-1`, `OPS-35`, `PRV-40`, `API-7`'s "without an extra lock, ceiling slot, write or provider call" and the five `CNF` items stay true as written. F-final rewrites ten rules and still missed one.

**Options.**
- S-a take. 04:291, "Steps 1–5d still stop at their first refusal", is where a pre-tail refusal belongs.
- S-b leave. It moves an engine component's schedule into a schema subsection and adds a "healthy" condition S3 does not have.
- S-c take. S1's list restates 05:444's inputs; let 05 hold them.
- S-d take; text below.
- F-a: F1 as printed. F-b leave: 04:287 says "A refused tail MUST commit nothing", and "purchase write" narrows it. F-c: F5 as printed. F-d leave. F-e take.
- F9 leave: a dated record quotes what `PRV-40` said that day. F10 take, with F11.

**Coordinator points.**
1. All four are worker assertions: CNF-55's follows "restart with it false before claim"; CNF-342's two are on stored creates at step 3; CNF-278's follows "record `credentials_rejected` before claim, then claim it"; CNF-364's is "the worker refuses the create at `OPS-43`'s step 4". No unlisted flip.
2. None. CNF-364 admits on an account that "declares `list_offers` and the ordering capability"; CNF-55's flag case is the ordering capability.
3. No. The claim-time "no write" items (10:1719, 1755, 2146-2193, 2627-2641, 3907) concern cut-off records, disks, the sweep and attachments; CNF-278 and CNF-364 assert "no provider request" and "no List offers read". The publish precedes step 8, so `API-63`'s "the last write before the ordering call" holds, and it is an engine write `OPS-50` fences.

**Note, not a vote:** S1 refuses a stale listing `provider`, whose taxonomy row reads "Provider returned an error response" (01:584). A local cache miss is not one.

**Against my pick:** S-final adds a table, a background engine component, two parameters and a refusal kind that misdescribes a cache miss. A customer who listed at 12:00 is admitted at 12:04 on a price the provider already dropped and learns at claim. F-final prices truthfully and needs no new component.

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

## Q2 (pv-ytv)

**K-final: ACCEPT.**

- K-a leave. K2 makes the key and its send MUSTs; K-a's "still send" names no generated key.
- K-b leave. K1's bare "See `PRV-33`" is exempt, and the quote adds nothing checkable.
- K-c: Reader 2's text. It names `correlator_kind`'s value; "the fingerprint pair" does not.
- K-d take.

**3.** Yes. The order carried the per-order key (K2), so the machine "bore" it and 05:326's pair holds `ssh_key_fingerprint` and its fingerprint. After retention, "A vanished operation record satisfies only the settlement condition; the sweep MUST still check the provisioning condition against retained `machines` rows" (`PRV-9`). The sweep computes the fingerprints of the keys tagged with the operation id, finds the row by `machines.correlator_value`, reads `provisioning`, and "Every temporary key tagged with that operation id, including a caller key distinct from Robot's correlator key, has the same eligibility", so the caller key is kept too. A null pair gives the sweep no row to find, which is Reader 2's loss.

**4.** Yes. `OPS-38` owns cardinality ("Correlator matching MUST define cardinality"), and K3 says such a create "has no count", so "Exactly one resource across every channel" has no count to match and only the no-verified-correlator row applies. CNF-371 and K-d check it.

**Against K-final:** The row records a correlator kind on a channel whose descriptor says `correlator: none`, so `PRV-32`'s "MUST declare no correlator" and a row holding `ssh_key_fingerprint` read as a contradiction until the reader reaches K3. A null pair with the fingerprint in `request_summary` keeps declaration and record aligned, at `PRV-26`'s cost.

## Brief errors

- **Eight before-strings span a line break** and return zero from `grep -cF`: F2 (10:544-545), F5's second (10:1893-1894), F7 (10:3695-3696), F8 (02:1211-1213), K1 (02:898-899), K2 (02:990-991), K4 (10:2824-2825), K6 (10:2937-2938). Each hits once after the lines are joined. The applier must join them.
- **F-final's rule inventory omits `OPS-35`** (03:30-31, quoted above), and 05:441's "retains `OPS-35`'s "before any driver call"".
- **00:113's sequence diagram** places the only List offers read at claim: "E->>P: List offers read, sale re-test, price re-check, OPS-43". F-final leaves it stale. Non-normative, so not a loss.
- `PRV-9`'s quoted sentence is at 02:150-151, and the error taxonomy table starts at 01:575. Line hints only.
