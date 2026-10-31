**Seat: fable. Clone at 3109b5b, clean. Every one of the 24 quoted ranges in this packet matches the pin; C′ as printed is C with exactly the three named blocks swapped to retain-verbatim (checked block by block).**

## 1. Packet check (notes rule 6 applied as written)

No quotation is wrong and no premise-changing error exists, so no tally is void. I agree with evidence item 5: the parent brief did say the wire rule "gets the same scope predicate", so opus's "undisclosed" is too broad. Disclosure by the manager is not owner authorization, which is the point that matters below.

## 2. Verdicts

| Form | Verdict |
|---|---|
| A | CANNOT ACCEPT as printed |
| B | CANNOT ACCEPT (duplicate ownership, and the same wire narrowing) |
| C | CAN ACCEPT WITH THIS FIX: retain `13-wire-contract.md:665–666`, CNF-34 and the CNF-342 paragraph verbatim at the pin. That repaired form is **C′ exactly as printed in this packet**, byte for byte, so I tender no second copy |
| D | CANNOT ACCEPT (duplicate ownership, and the same wire narrowing) |
| C′ | CAN ACCEPT, unqualified |

The only repair I would take for A is the same three retentions. I do not tender that as a new form: it is unread by every other seat and this is the one consensus round, while C′ already carries the repair together with the hourly cases three readers asked for.

## 3. The manager's rule-3 loss: verified, under the second prong

Rule 3 is satisfied by any of three things. The second is "quote a MUST/SHOULD with file, owner and trace". The diagnosis does that:

- **MUST and file.** `13-wire-contract.md:665–666`: "`acknowledge_purchase` MUST be literal `true` (`API-15`, `PRV-10`)". No condition.
- **Owner.** `WIR-17`. `API-15` itself says the field is "`WIR-17`'s top-level `acknowledge_purchase`, which the wire contract owns". The field rule's home is the wire contract.
- **Trace.** Offer with recurring price zero, null floor, setup fee `"0"`; account healthy with `allow_orders` true; fresh key; `acknowledge_purchase: false`. At the pin, `API-7` step 5 "deserialize and validate the body" fails it `invalid_request`, HTTP 400 (`DOM-17`'s table), `details.field: "/acknowledge_purchase"` (`WIR-9a` row at `13-wire-contract.md:134`, "also where the named field is absent"). Under A–D the wire sentence is prefixed "For a paid create (`DOM-16`)", `API-15` and `PRV-10` carry the same condition, and `OVR-6` reaches only "Destructive and billable actions". No sentence then requires the refusal.

**The premise is model-reachable.** `12-billing-and-ledger.md:1241–1243` itself handles "a positive `seconds` at a zero recurring price with a null floor". `01-domain-model.md:168` makes the setup fee "`"0"` where the channel charges none". `CNF-315` at `:828` fixtures "a zero recurring price and a null floor". I searched for any rule forbidding the two zeros together or forbidding a zero-sized commitment and found none. No live v1 offer is free, but rule 3 does not say "v1", and C's own hourly fixture relies on conformance fixtures not being live sales.

**It is not owner-authorized.** Item 4 says the switch and acknowledgement "cover any create that starts billing, hourly cloud VMs included". That states what they cover. It does not say any create stops being covered. The rejected option was "Upfront purchases only"; no option exempted free creates.

**Removal of a required refusal, not forced admission.** A–D do not say a free create MUST be admitted without the acknowledgement. They stop requiring its refusal. Two conforming engines may then disagree on it, which is the defect shape pv-9ecf exists to remove.

**What the unconditional sentence protects.** Under it, the acknowledgement check never depends on classifying a create as paid. Under A–D it does, per create, and the brief's own item 2 names the trap: zero `first_unit` arises with a positive recurring price under exact elapsed-time billing, so an engine that reads "free" off `first_unit_sats == 0` would admit an hourly create without acknowledgement. Retaining the sentence costs item 4 nothing: it is a strict superset of "every paid create".

**Why I moved from r89.** My r89 acceptance of A and C rested on "no v1 verdict flips". That is not rule 3's test. My r89 preference was already to keep 665–666 as pinned; C′ is that preference made into a form.

**Strongest counterargument, and why it does not carry.** `07-security-requirements.md:163–165` says "The acknowledgements themselves are unchanged and are `API-14`'s and `API-15`'s", and `API-15` and `PRV-10` were already scoped at the pin. On that reading WIR-17's unconditional sentence is a drifted second copy, and A–D are the AGENTS.md drift repair. Two things answer it. First, `API-15` assigns the field to the wire contract, and a wire contract is allowed to be stricter than the obligation it renders, as `WIR-2` is about unknown fields; the pin's shape (owner scoped, wire strict) has stood since 2026-09-05 without being called drift. Second, notes rule 7: "Do not weaken or delete a disputed rule to clear a review. Preserve what it protects." Whether the sentence was deliberate is for the owner, not this panel, and C′ preserves it while A–D decide it silently.

## 4. Opus's check-order claim

Agreed with evidence item 4: not established as necessary. No candidate moves `API-7`'s tail read at `:264`. But the predicate A–D put at step 5 is per create ("a create that starts new provider billing"), and the only offer price the api holds is read in the tail. An account-level classification suffices only if every offer the capability permits is paid, which the text does not say. C′ removes the question rather than answering it.

## 5. C′ as printed: losses and new obligations

- **Dropped against the pin:** nothing beyond the owner-fixed scope wording (`DOM-16`, `PRV-10`, `API-15`, configuration row, matrix row, `DEF-17` paragraph, `CNF-55` heading). `DOM-16` loses ", not instead of,"; "in addition to" plus `PRV-10`'s "Both, not either" carry it.
- **New obligation:** the hourly cloud cases inside `CNF-55`. That is a test obligation beyond item 4 and needs owner approval. `CNF-364`'s two added preconditions are fixture clarification, not a new assertion.
- **Error details check out.** 501/`unsupported` with account and capability: `DOM-10:518–519` and `DOM-17`. 400/`invalid_request`/pointer: `DOM-17` and `WIR-9a:134`. Claim-time `unsupported` at step 3: `OPS-43:791–793`, settling under `LDG-39`'s "Deterministic rejection before acceptance" (`OPS-23:2040–2042`). "Holds no resource-offer exclusion": `PRV-42` at `02-provider-contract.md:1269`, "Catalogue products do not take this claim."
- **Check order:** unchanged. `API-7` and `OPS-43` are not edited by any form.
- **Gates (reasoned from the tool sources, not run).** The citation gate's colon form in retained CNF-34 still finds "`acknowledge_purchase` MUST be literal `true`" in retained WIR-17. The only Lean docstring near this area, `Admission.lean:317–318`, quotes `API-7`, which no form edits. The obligation gate's regex needs a backticked id directly followed by MUST; no new sentence has that shape. `PRV-13b`, `PRV-31`, `OPS-11`, `OPS-23` resolve.
- **Test strength.** The positive control must clear steps 4–9 to reach the driver once; "Keep all unrelated sale, price, balance and admission conditions satisfied" is the fixture's burden. "Catalogue offer" is undefined vocabulary, recoverable from "holds no resource-offer exclusion". Neither is a loss.

## 6. Traces under C′

- **Hourly rental, no setup fee, ordering off, acknowledgement true.** `DOM-16`: a paid create needs neither "a setup fee nor immediate payment", so `provision_virtual` "permits a paid create" and the descriptor withholds it. `DOM-10` gates "before the driver is called, **including create**"; `API-7` 5d: "A refusal stops here and is not collected by the tail". 501, no commitment. Asserted by `CNF-55`'s base case and the hourly block.
- **Same create, ordering on, acknowledgement absent or false.** WIR-17 unconditional fails it at step 5, 400, pointer `/acknowledge_purchase`. Asserted by the hourly block; at the pin no admission case asserted this.
- **Claim time.** Restart with the flag off: `OPS-43` step 3, caller fields first, then api fields, then the capability gate, before step 4's List offers read. Stored acknowledgement removed: `OPS-23`'s caller-field bullet, `invalid_request`, `retryable: false`. Both release in full with no debit.
- **Free create, acknowledgement false.** Still 400 under C′, as at the pin. Under A–D, undetermined.

## 7. Status for the owner

C′ is not wording-only: the hourly block is a new conformance obligation and goes to the owner as the recommended exact form. Its three retentions are neutral to item 4. No printed form is wording-only, because A–D all drop the unconditional wire check; a wording-only form would be A with the same three retentions, which I do not tender.

**Final: C′** (as printed in this packet). My own preference is also C′.
