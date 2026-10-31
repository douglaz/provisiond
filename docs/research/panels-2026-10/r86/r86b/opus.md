# r86b: opus reader answer

I worked in the pinned clone at `3109b5b` and edited no source. **apply notes.md rule 6 exactly as written; this prompt adds no void rule.**

I applied each Q2 form, Q1-A, and Q1-A together with Q2-A-cited to separate scratch copies under `tmp/opus/`. On each copy I ran the four Python gates: citations, ids, obligations and coverage. No Lean, lake or Nix command ran. The citations gate needs Lean's `index.jsonl`, so I built a superset of it from the declaration names in the Lean sources; the unedited pin passes all four gates with it. I did not run the fixtures, regions or formal gates.

## Votes

| Form | Verdict | Pick |
|---|---|---|
| Q1-A | ACCEPT | **Final Q1 pick** |
| Q1-B | CANNOT ACCEPT: conflicts with OVR-2 (blocking) | |
| Q1-C0 | ACCEPT | |
| Q2-A | CANNOT ACCEPT as printed: the citations gate goes red | |
| Q2-B | CANNOT ACCEPT: the gate goes red, and it breaks DOM-10 (blocking) | |
| Q2-A-prime | ACCEPT | |
| Q2-A-cited | ACCEPT | **Final Q2 pick** |
| Q2-B-cited | CANNOT ACCEPT: breaks DOM-10 (blocking) | |

I submit no alternative form.

| Scratch copy | citations | ids, obligations, coverage |
|---|---|---|
| pin | pass | pass |
| Q2-A | **fail**: 2 quoted attributions it cannot verify, 3 Lean docstring quotes found nowhere | pass |
| Q2-B | **fail**: 1 and 1 (`"gate a create on its ordering capability"`) | pass |
| Q2-A-prime | pass (350 quoted attributions compared; the pin has 353) | pass |
| Q2-A-cited | pass (352 compared) | pass |
| Q2-B-cited | pass (353 compared) | pass |
| Q1-A | pass | pass |
| Q1-A + Q2-A-cited | pass | pass |

## What changed since r86, and which of my premise claims broke

- **Q1-B (was ACCEPT, now CANNOT ACCEPT).** The r86 brief left out OVR-2, so I treated the admission phase as open. It isn't.
- **Q1-C (was CANNOT ACCEPT, now ACCEPT for C0).** My objection rested on this trace: "one build answers 501 at once, another answers `202` and then fails". OVR-2 makes the `202` build non-conforming, so the trace no longer holds. The broken premise is the omission this round corrects; I am not claiming a new error.
- **Q2-A (was ACCEPT, now CANNOT ACCEPT as printed).** In r86 I did not run the gate. Fable's citation failure reproduces, and a red gate cannot land under AGENTS.md.
- **My STO-21 claim was too strong.** In r86 I said STO-21 requires such state to "live in named tables". That sentence (`05-persistence.md:684–686`) covers "Operational state a tenant needs in order to function". The only true part is narrower: no existing record holds a prior `machine_kind`.
- **Brief errors.** I found none in this packet that changes a question's premise. One small labelling slip: the docstring cited as `Admission.lean:15` carries its API-7 quote at line 19.

## Q1

**Q1-B is blocked.** OVR-2 (`00-overview.md:22–24`) says "the server MUST NOT accept an operation a provider has not declared support for". OPS-1 (`03:17–18`) defines accepting as creating a durable record and answering `202 Accepted`.

Trace: an authenticated hard reset names an account whose running api descriptor lacks `hard_reset`. B "enqueues an otherwise valid request even when the running api descriptor lacks that operation's capability", so it answers `202`, and the worker later fails the operation `unsupported`. The `202` itself breaks OVR-2, whatever the worker does afterwards. Sol's trace is correct.

**The funded null-fence retry (astra's trace, and mine in r86).**
- The retry is a new operator request, so OVR-2 governs its admission. Refusing it with `501` is required by the base, not a cost that A chose.
- It does not affect an attempt that was already accepted or enqueued by the system. OPS-41's step-1 gone/closed success, its step-3 funded abort, the restore defer (`03:998`, "defers, and writes no fence") and the no-rate defer (step 4, `03:1108`) are MUSTs on a claimed attempt. A's check runs after all of them.
- The operator can still close the episode with `API-68` keep.

**C0 against A.** With OVR-2 in view, the base already requires both phases for caller requests:
- refusal at admission (OVR-2);
- a gate before any driver call, never a driver-only gate (DOM-10);
- the worker repeating validation (OPS-23).

C0 is lawful and changes no verdict, so I accept it. It leaves three observable differences open between conforming builds, and A settles each one:

1. **Where a proceeding cancellation checks capability.** If the check runs before the fence transaction, a failed attempt leaves the fence null; after it, the fence is set. OPS-48's `failed` row says "Unchanged" either way, so whether the tenant can still extend under LDG-62 depends on the build. A puts the check after OPS-41's decision and after the fence.
2. **Error precedence.** At admission, an ineligible strategy on an account without the capability could answer 400 or 501. At claim, a doomed signed URL plus a withdrawn capability could fail with OPS-40's error or with `unsupported`. A runs local validation first.
3. **Rescue installs.** A checks the strategy's capability first, then `rescue_ssh`.

That is why A is my pick.

**Can A's API-64 path be ordered deterministically?** A's general rule says the check runs "after … all endpoint-local admission validation and admissibility checks, immediately before the enqueue transaction's first write". Its API-64 sentence says the retry "checks delete_machine before its state-change/enqueue transaction". API-64's admissibility is "a conditional write guarded on `(id, state = stalled)`".

Only one order satisfies every sentence:
1. a plain read of the episode state;
2. then the capability check;
3. then the transaction, with the guarded write still acting as the guard.

The set already uses this shape in OPS-43 step 1: "This is a plain read, not a conditional-write guard; the guard remains the conditional write at step 8".

The outcomes are then fixed:
- the episode is not `stalled` when read: 409 `state`, whatever the capability;
- `stalled` and `delete_machine` missing: 501;
- `stalled` and declared, but a gone-write wins the race: 409, through the guard.

A build that skips the plain read and answers 501 for a non-stalled episode puts the capability check ahead of admissibility, which breaks A's general rule. So the two can coexist deterministically, but A never names the plain read. This does not condition my vote, and C0 leaves the same case open anyway.

**What A preserves (checked):**
- both defers;
- the gone/closed and funded no-call successes;
- the identical-PTR success staying after the capability check (PRV-25, `02:855`);
- the null rescue marker on a capability refusal (CNF-302);
- CNF-312's prefixes: a survived stop still records a cut-off `conflict`, and a crash still leads to `needs_reconciliation`;
- the suspend parent, whose children carry the `unsupported` result.

A's new local error precedence is an amendment. I don't claim it describes how every implementation already behaved.

## Q2

### The formal question (astra's and sol's dissent)

Astra's strongest trace: "The existing formal composition, with `orderingDeclared = false` and `offerSellable = false`, returns `unsupported`, with no tail. Q2-A skips the capability check and returns the collected `offer_not_sellable` result." Sol adds: "Reinterpreting `orderingDeclared` as automatic success for absence would also change its documented meaning."

**They are right that this is a substantive change.**
- If an account declares neither provisioning capability, the pin's Boolean is false whatever kind gets selected.
- `Admission.lean:1203–1207` counts absence among the sale inputs.
- So the pinned set says: on an account with no ordering capability, every create stops at step 5d with `unsupported`, including a create naming an absent offer. CNF-55's refusal assertion checks the same thing, because it doesn't specify whether the offer is present.

A-prime and A-cited narrow that rule to present offers. Their docstring edit is a semantic narrowing. Its effect is the same as adding `offerPresent = true` as a hypothesis to `undeclared_ordering_stops_before_tail`. It is not an editorial repair, and I don't call it one.

**It is still lawful.** I checked what changes and what doesn't:
- **No proof fails.** The brief's "A failed proof may not be cleared by silently changing…" is not triggered, and the redefinition is printed openly at lines 1181–1183.
- **Every input combination can still occur, so no theorem becomes vacuous.** `orderingDeclared = false` with `offerSellable = false` is a present but unsellable offer whose kind's capability is not declared — for example, one with a future PRV-31 cancellation bound.
- **The negative control keeps its strength.** `undeclaredOrderingCreate` (`Witnesses.lean:4341`) uses a present, sellable offer, and its `ci.yml:912` row is unchanged.
- **The pin already put this selection outside the model:** "Machine-kind selection and descriptor construction are outside this model". At the pin an absent offer has no defined kind at all, since WIR-17 has no caller `kind` field. That is the gap pv-e45e names.

**What it costs.** One verdict is lost: an absent offer on an account with no ordering capability goes from `501 unsupported` to `400 offer_not_sellable` with `not_checked`, or to a `409 state` headline if the account is unhealthy.

**What pv-p3k protects survives:**
- No create is ever admitted without its kind's capability. `04:273` says "An offer absent from the offers the check reads is an unsellable offer for every rule in this tail".
- Both refusals are `retryable: false`, and no money moves.
- PRV-10's "create MUST reject" still holds. Its pointer to step 5d (`02:162`) stays true for every create that could actually place an order.

**Is a declaration amendment necessary?** Adding `offerPresent` to `createPurchaseTail` would let Lean see the branch instead of hiding it in how the input is supplied. But it would change no model output for any case, and it would narrow an existing theorem with a non-guard hypothesis. That is ADR-0025's "weakening", the same change reached another way. I judge it unnecessary. I don't author it: I can't build Lean here, and a Lean form only I have reviewed couldn't settle anything. If a reader holds that the branch must live in the declaration, neither printed repair contains it, and they should say so.

### Q2-B and DOM-10 (fable's trace)

Fable's trace: "a descriptor with `machine_kind: bare_metal` declaring only `provision_bare_metal`; a later refresh stores a virtual offer under the same credential; a create names it. Step 5d passes on `provision_bare_metal` … the worker orders a virtual machine."

My decision is that this is a remaining breach of DOM-10's outer gate, not an input outside the contract:
- **The driver is not conforming.** It breaks B's "Every offer returned for the account MUST have that machine kind".
- **But DOM-10's outer gate exists for exactly this case.** CNF-19 runs "with the driver's internal ordering flag set to permissive, so the test proves the outer gate exists". DOM-10 says "There MUST be no operation whose only gate is a driver-internal check".
- **The server ignores a kind it can see.** It holds the offer's own `kind` in the stored listing (`01:166`) and will record it in `machines.kind` (`05:395`). Yet it gates on the descriptor's other capability. So "Every operation with a capability MUST be gated on it" (`01:515`) goes unchecked for a kind the server itself records. The only remaining barrier is the driver's duty.
- **This is where B differs from A.** A also trusts the reported kind, but it ignores nothing the server can see, and it checks the live kind again at claim.
- **Rule 3:** owner DOM-10, `01-domain-model.md:515–518`, trace above. This blocks both B and B-cited.

If "returned" is read as a duty on the server instead, B still names no server action for a mismatched offer: drop the offer, refuse the listing, or refuse the create. The outcome is unspecified, so the gap stays open.

**Can B's configuration rules be enforced?**
- B says a mixed-kind account must be rejected "before api or engine enables that account". The descriptor can't detect that, because Describe capabilities "MUST NOT perform network I/O" (`02:76`). B names no offer read before enabling, and a provider can add a product line after the account is enabled.
- Keeping `machine_kind` fixed for a retained account identity needs a prior value. No existing record holds one, and B adds none.

So B-cited's CNF-19 configuration assertions can only be met by inventing a mechanism. That makes them incomplete, not contradictory, and on its own it is not a rule-3 loss. The DOM-10 trace is the blocking loss.

### Q2-A's costs, checked

| Case | Under Q2-A-cited |
|---|---|
| Valid retained kind, capability withdrawn before claim | Step 3 refuses using the persisted kind, before List offers. CNF-55's "no List offers read" holds. |
| Retained kind missing or corrupt | The `api` writes this field, so OPS-23 gives `conflict`/`incomplete_record`, `retryable: true`. A create still queued across the upgrade fails this way, under OPS-23's previous-release rule (the same pattern as the accepted-price fields). |
| Live offer's kind no longer matches | New step-5 refusal `offer_not_sellable`, `retryable: false`. No price comparison or provider mutation; full release; the resource-offer exclusion is freed. |
| `list_offers` withdrawn | Step 4 is unchanged; CNF-364 still holds. |
| Collected refusal ranks | Unchanged. An unhealthy account still heads the list ahead of `offer_not_sellable` (panel-E settlement 1). |
| Old stored listing | Step 5d reads the listing whatever its age, so a present offer gets the 501 at any age. The stale `provider` refusal still comes only after an empty collection. The header default is untouched; CNF-55's added "fresh and old" line repeats it rather than reversing it. |
| Mixed-kind account | Supported. |

I accept A's costs over B's: the absent-offer precedence change, the formal narrowing above, and one more field in STO-50's closed list. B's costs are a domain restriction plus the open DOM-10 gap. That every launch driver sells one kind per account proves neither choice.

**Why A-cited over A-prime.** They mean the same thing. A-cited restores the OPS-23, PRV-10 and PRV-8 quotations in step 3, as AGENTS.md's "Quote the sentence" asks. It still drops PRV-10's "the account is configured to allow ordering", but PRV-10's own pointer (`02:162`) to the gate at step 3 stays correct.

## Strongest case for leaving each question alone (requested; not my vote)

- **Q1:** OVR-2, DOM-10, OPS-23, OPS-41, PRV-25 and CNF-302 already fix every safety-relevant order. What remains is which non-mutating, non-retryable refusal a client sees first, and whether a stuck cancellation's fence ends up set. The bead is a P3.
- **Q2:** every v1 driver sells one kind per account, so the divergence is latent today. A future ADR for a driver that sells both kinds could settle it with real provider facts.

## How Q1-A and Q2-A-cited compose

- Q1-A covers non-create operations only. Q2-A-cited changes the create's step 5d, the opening of the purchase tail, and OPS-43 steps 3 and 5.
- Q1-A's API-7 pointer follows the rewritten step 5d, and both OPS-23 insertions sit before its amendment notes.
- Both forms use the same order at claim: caller-supplied fields, then `api`-written fields, then the capability check.
- Replay, suspension and ceilings (steps 5a–5c) stay ahead of everything new. No collected-refusal rank or listing-age decision moves.
- The combined scratch copy passes all four Python gates.
