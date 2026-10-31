**Seat: fable. Pin verified: clone at 3109b5b, clean. Every quoted range in the packet matches the pin byte for byte.**

## 1. Packet check (notes.md rule 6 applied exactly as written)

I compared all eighteen quoted ranges against my clone. None is misquoted. The packet's claims about unedited consumers also hold: OPS-43 step 3 quotes PRV-10's "explicit purchase acknowledgement" and "the account is configured to allow ordering" at `03-operation-lifecycle.md:789-792`, and both strings survive every replacement. API-7 step 5d, PRV-4's exception sentence at `02-provider-contract.md:29`, and DOM-15's exception are untouched and still point at DOM-16. I found no error that changes the question's premise, so no void applies and the tally stands. One packet statement is loose but harmless: "`08-provider-notes.md`'s matrix marks Cloud VPS Create yes" belongs to the bead's description, and the provider notes at line 146 already record that Robot dedicated billing is "hourly rounded up with a monthly cap — the same shape as the cloud product", so the old "bills on order" phrase never cleanly separated the two products. That supports the owner's decision rather than undermining it.

## 2. Verdicts

**Final: C.**

- **A: ACCEPT.**
- **B: CANNOT ACCEPT.**
- **C: ACCEPT.**
- **D: CANNOT ACCEPT.**

B and D fail on the repository's own standing rule, not on a rule-3 loss. They write the same normative scope sentence into nine places. AGENTS.md says "One rule, one home; everywhere else points at it," and the set already deleted SEC-26 for restating API-15 and PRV-10 word for word (`07-security-requirements.md:161-165`, `README.md:244`). Nine copies of "Neither a setup fee nor immediate payment is required for this condition to apply" is the drift shape the project has twice paid for. A and C put the predicate in DOM-16 and cite it. I prefer C over A for the coverage reasons in section 4.

## 3. Missed sites and gate exposure

I searched every tracked Markdown file outside `docs/research/` for the aliases "bills on order", "bill per order", "order-billed", "opt-in ordering", "per ordering account" and "paid create". The only live sites are the seven the forms replace. Remaining mentions of `allow_orders` or the acknowledgement carry no scope phrase: PRV-4 line 29, PRV-34's paragraph at `02-provider-contract.md:1044-1047`, API-17b at `04-api-contract.md:1015-1019`, the SEC note at 07:161-165, finding F4, and the providers-listing fixture at `13-wire-contract.md:1017-1018`. The README withdrawn-index row for SEC-26 and the DEF-17 prohibition are historical. **No form misses a live site.**

Gate exposure, checked against `tools/`:

- **Citation gate.** The only gate-checked quotations attributed to rewritten paragraphs are DOM-15's "declaration and implementation MUST agree" (DOM-15 is not edited), PRV-10's two quotes in OPS-43, and CNF-34's colon-form quote of WIR-17 "`acknowledge_purchase` MUST be literal `true`". All four substrings survive in every form. No Lean docstring quotes DOM-16, PRV-10, API-15 or WIR-17. The Lean `orderingCapabilityGuard` docstring quotes API-7, which no form edits.
- **Obligation gate.** Its pattern is a requirement id immediately followed by MUST. No form introduces that shape.
- **Identifier and coverage gates.** Every new citation resolves, including PRV-13b, PRV-31, OPS-11, OPS-23 and WIR-17. No CNF item loses a citation.
- **Rendering and fixture gates.** No marked region sits near any edit, and no form adds JSON.

Optional, not a defect: CONTEXT.md does not glossary requirement-defined terms such as "resource-offer exclusion", so A and C defining **paid create** inside DOM-16 breaks no convention.

## 4. Traces

**Hourly cloud create, no setup fee, ordering off.** Under A and C: DOM-16's first sentence makes it a paid create, since "neither a setup fee nor immediate payment is required". `provision_virtual` on that account therefore "permits a paid create", so with the flag false the descriptor does not declare it. DOM-10 then refuses before the driver: "Every operation with a capability MUST be gated on it before the driver is called, **including create**", at API-7 step 5d with `unsupported`, 501, account and capability named, `retryable: false`, no tail and no commitment. Under B and D the same path runs off the inline sentence. Assertion: the base CNF-55 admission case in all four forms. C and D add the explicit hourly fixture with zero driver create calls and zero simulated billing starts. The claim-time variant under C and D follows OPS-43 step 3, where "`DOM-10`'s gate on the create's ordering capability" is repeated, and settles through LDG-39's "Deterministic rejection before acceptance" row. PRV-42 confirms "Catalogue products do not take this claim," so the hourly case correctly asserts no resource-offer exclusion.

**Hourly create, ordering on, acknowledgement absent or false.** WIR-17 in every form requires the literal `true` for this create. API-7 step 5 validates the body before 5d, so WIR-2 and WIR-9a's field-pointer row produce `invalid_request` with `details.field: "/acknowledge_purchase"`, HTTP 400 per DOM-17. At claim, OPS-43 step 3 repeats PRV-10's "explicit purchase acknowledgement" as a caller field under OPS-23, with `retryable: false`.

Here is the material difference between A and C. At the pin, no conformance item asserts the admission-time 400 for an absent or false acknowledgement. CNF-34 and CNF-342 are worker-side, CNF-55 sends the acknowledgement as true, and CNF-182 is a driver assertion. A inherits that gap. C's hourly block closes it with the absent and false admission cases, and separately asserts the claim-time restart and the missing stored acknowledgement on a catalogue fixture. The brief's failure story is an engine that reads the old words narrowly on cloud, and A's checklist can still go green on a Robot-only fixture set.

## 5. Collateral changes beyond the decision

- **WIR-17 narrowed from unconditional to conditional, in all four forms.** The pin at `13-wire-contract.md:665` says, with no condition, "`acknowledge_purchase` MUST be literal `true`". Every form prefixes "For a paid create". That is a substantive change, disclosed by the brief, and a MUST becomes scoped by a per-request billing classification taken at body validation. No v1 verdict flips, because every v1 driver's create starts billing, and no trace violates the owner's decision. So it is not blocking under rule 3. My preference, separate from acceptance, is to keep lines 665-666 as pinned: the unconditional wire rule is strictly stronger, and it keeps step 5 free of a classification the forms otherwise locate at the capability level. I accept the printed forms as they stand.
- **Latent mixed free/paid ambiguity.** DOM-16's gate is capability-level ("permits a paid create"), while PRV-10, API-15 and WIR-17 use the create-level predicate. If a capability ever permits a free offer, the flag still withholds the whole capability, which matches the owner's account-level control. Only the acknowledgement half becomes per-create. No v1 offer exercises this, so I report it without a repair.
- **DOM-16 drops "not instead of".** The owner's second sentence is still carried by "in addition to" and by PRV-10's "Both, not either". Editorial.
- **CNF-364 gains two explicit preconditions** (flag true, acknowledgement true). A clarification that stops the ordering gate from masking the list-offers gate. No assertion weakens.
- **DEF-17's historical paragraph is reworded.** Acceptable to avoid a live alias, but it is a historical record and B/D's version appends the predicate sentence to a defect description where it has no normative work to do.

Nothing changes the order of checks, the stored idempotent replay, the low-balance refusal ordering, the listing assertion or the worker repetition. API-7 and OPS-43 are untouched.

## 6. Counterargument on request, then my pick

The strongest case for the wording-only footprint is AGENTS.md's own sentence: "The rule and the record are two edits with two different failure rates." A lands the owner's decision in seven replacements whose every quoted dependency I could verify in minutes. C adds roughly forty lines of new test design inside CNF-55, with a synthetic sellable hourly cloud fixture that no live v1 driver can sell under ADR-0039, a new "simulated billing start" counter, and eight assertions that nobody has run. Each is new surface for a later misquote or a fixture that asserts an illegal configuration, which is exactly how the 13-wire-contract fixture went wrong on 2026-09-02.

That is not my vote. The bead exists because two engines could both cite the text and disagree on cloud. Wording alone leaves the checklist without one item whose fixture is hourly, and without any item asserting the admission 400 for a missing acknowledgement. C fixes both while keeping one owner for the predicate. **Final: C.**
