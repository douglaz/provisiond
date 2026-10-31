I **CAN ACCEPT C′ exactly as printed**, without fixes. It is also my preference. I revise my earlier acceptance of A–D; those historical votes remain recorded and are not voided.

| Exact printed form | Verdict | Reason |
|---|---|---|
| A | **CANNOT ACCEPT** | Removes the unconditional acknowledgement obligation for non-billing creates. |
| B | **CANNOT ACCEPT** | Same loss; also repeats the scope predicate across consuming sites. |
| C | **CANNOT ACCEPT** | Same loss, despite its stronger hourly demonstrations. |
| D | **CANNOT ACCEPT** | Same loss and repeated scope ownership. |
| C′ | **CAN ACCEPT** | Preserves the unconditional acknowledgement and worker coverage while resolving paid-hourly scope. |

These are judgments on the complete printed packages. I propose no conditional acceptance or additional alternative.

I read notes.md whole and the prior answers verbatim. HEAD matches `3109b5b44eae17e288cf52aaa976993bd8c5626c`. The packet’s pinned evidence blocks match this clone, as do the candidates’ explicitly retained blocks. C′ differs from C only in the identified wire and worker blocks. Applying rule 6 exactly, I found no verified premise-changing brief error. Disagreement about authorization does not create another void rule.

**The manager’s proposed rule-3 normative loss is verified.** The owner selected **“Every paid create (Recommended)”**, with the explanation: **“The switch and the per-request purchase acknowledgement cover any create that starts billing, hourly cloud VMs included.”** That establishes paid-hourly coverage. It does not authorize removing an existing acknowledgement obligation from creates outside that coverage.

The distinguishing case needs more than zero `first_unit`. [CNF-315](/var/tmp/provisiond-panel-r89/r89b/sol/10-conformance-checklist.md:822) expressly includes “a zero recurring price and a null floor”; [LDG-39](/var/tmp/provisiond-panel-r89/r89b/sol/12-billing-and-ledger.md:1241) includes positive seconds at “a zero recurring price with a null floor.” [DOM-9](/var/tmp/provisiond-panel-r89/r89b/sol/01-domain-model.md:168) permits setup fee `"0"` “where the channel charges none.”

Use that zero recurring price, null floor and zero setup fee, with no other new provider charge, a healthy enabled account, fresh key and otherwise satisfied conditions. This supplies a non-billing specification case; it asserts neither a live free v1 offer nor that every zero-unit offer is free.

Its trace is:

- At the pin, [WIR-17](/var/tmp/provisiond-panel-r89/r89b/sol/13-wire-contract.md:665) says, unconditionally, “`acknowledge_purchase` MUST be literal `true`.” A false acknowledgement fails [API-7](/var/tmp/provisiond-panel-r89/r89b/sol/04-api-contract.md:208)’s “deserialize and validate the body” step: HTTP `400`, `invalid_request`, `/acknowledge_purchase`, before admission writes.
- A–D prefix that MUST with a billing condition. For this non-billing create, the unconditional refusal is no longer required. Their conditional PRV-10/API-15 do not restore it. OVR-6’s “Destructive and billable actions MUST require an explicit per-request acknowledgement” supplies no unconditional substitute.
- This removes a **required refusal**. It does not force admission despite another applicable refusal.

The fixture domains also narrow: CNF-34’s “On separate creates” becomes paid creates, including its api-filled-field fixture; CNF-342’s “complete, valid resource-offer” fixture becomes paid. I do not claim the pin expressly demanded a dedicated free-create test. The unconditional MUST loss independently satisfies rule 3.

My prior answer incorrectly treated an expressly offered scope correction as an authorized exemption. The manager therefore had grounds to hold settlement under rule 2’s blocking-loss condition despite C’s prior picks. That is neither a synthesized tie nor a voided vote.

C′ preserves the protection without contradicting its revised API-15. “A paid create request … MUST carry” establishes an obligation for paid creates; it does not say **only** paid creates require acknowledgement. API-15 still identifies the field as one “which the wire contract owns.” The retained wire owner supplies the broader obligation.

**The strongest arguments on both sides survive this correction.** Fable and Astra are right that centralized scope ownership matters: AGENTS.md says, “One rule, one home; everywhere else points at it.” B/D’s repetition is a separate maintenance objection, not another demonstrated rule-3 verdict loss.

They and my prior answer were also right that direct hourly demonstrations improve coverage. C′ retains those demonstrations alongside Opus’s preserved wire/worker protection. Conversely, A’s smaller footprint already states the fixed paid-hourly policy; absence of a newly specified hourly fixture is not itself a blocker. The added cases remain optional policy work requiring owner approval.

Opus’s claimed necessary price-read reordering is not established. [API-7](/var/tmp/provisiond-panel-r89/r89b/sol/04-api-contract.md:262) still places the tail “After steps 1–5d” and requires “one read-only snapshot.” No candidate expressly moves that snapshot. Account-level knowledge that a capability permits paid creates need not price a particular offer. The acknowledgement narrowing is sufficient to reject A–D without asserting an unproved reordering.

Likewise, the earlier claim that no checklist case mentions an absent acknowledgement was too broad. CNF-182 expressly says “with the acknowledgement absent” and expects a `Cancelled` transaction. That pre-existing Robot/test-mode assertion differs from an explicit core admission `400` case.

**The paid-hourly traces remain intact in C′.**

For a positive recurring hourly price, zero setup fee, ordering off and acknowledgement true, DOM-16 expressly includes “hourly or other recurring machine rental” and says “neither a setup fee nor immediate payment is required.” The account’s capability “permits a paid create,” so its descriptor withholds `provision_virtual`. DOM-10 requires gating “before the driver is called, **including create**.” API-7 step 5d says, “A refusal stops here and is not collected by the tail.”

The resulting refusal is `501 unsupported`, naming the account and capability, `retryable: false`, without an operation, commitment or provider request. CNF-55 retains the low-balance case’s absence of `details.refusals` and `details.not_checked`; its hourly addition expressly requires zero driver create calls and simulated billing starts. A mixed free/paid capability is withheld whole, rather than replaced with a per-offer gate.

With ordering on, missing or false acknowledgement fails the retained literal-true wire requirement during body validation: `400 invalid_request`, `/acknowledge_purchase`, `retryable: false`, with no operation, commitment or provider request. The hourly CNF-55 block requires separate absent/false cases and a control with both authorizations true reaching the fixture driver exactly once and recording one simulated billing start.

Replay remains separate. API-7 step 5a says an equal fingerprint “returns the stored result”; CNF-55 retains its same-key replay after flag disablement. Fresh keys prevent the new admission cases from accidentally testing replay.

At claim, [OPS-43](/var/tmp/provisiond-panel-r89/r89b/sol/03-operation-lifecycle.md:774) requires the listed order: account-status read, stored channel-closure read, then boundary validation. Within step 3, caller checks “run first, then the checks on fields the `api` wrote at admission, then the capability gate.”

Thus:

- Restarting a queued, complete hourly create with only ordering disabled reaches the capability refusal at step 3: `unsupported`, matching account/capability details, `retryable: false` on error and view, `failed`, full commitment release, no fee/unit debit and no provider request, including List offers.
- Removing its stored acknowledgement instead fails the caller-field check first. OPS-23 requires repeated boundary validation and says a caller field “fails `invalid_request` naming the field,” with `retryable: false` on error and view. The hourly fixture asserts the corresponding step-3 failure and release without provider activity.

The catalogue fixture correctly holds no resource-offer exclusion: PRV-42 says, “Catalogue products do not take this claim.” Existing resource-offer acquisition and settlement-release assertions remain.

**C′ adds obligations, but I found no further verified loss.** Its hourly CNF-55 block adds explicit admission refusals, successful control, restart and stored-acknowledgement demonstrations, including simulated billing observations. These are implementation-conformance obligations beyond item 4, not repository runtime tests or permission for a live sale. They instantiate a cloud fixture; they do not independently establish every driver’s implementation.

CNF-364 explicitly supplies `allow_orders: true` and acknowledgement true before removing only `list_offers`. That makes its intended step-4 refusal reachable without weakening its error details, release or exclusion assertions. C′ retains CNF-34 and CNF-342’s original fixture breadth, error/view agreement and settlement assertions, along with the other printed retained dependents.

No gate, theorem statement, guard hypothesis or formal negative control changes. The formal admission model explicitly says “Machine-kind selection and descriptor construction are outside this model”; its existing capability-before-tail proof does not prove the revised descriptor classification. Relevant quoted substrings survive, but I claim no gate result.

The owner’s 2026-10-28 instruction was **“For such wording questions, try to solve by getting a consensus of the panel.”** C′ is my best consensus recommendation because it combines the centralized scope and hourly cases with the retained safeguard. Other seats’ acceptance must still be determined by this round’s manager.

**C′ needs owner approval because it adds conformance obligations; it is not wording-only under item 4.** I recommend its exact printed form for that approval, without claiming panel settlement or adoption.

This was read-only. I ran no builds, gates, runtime tests, provider calls or subagents, and changed no source, Git state, tracker or panel records.

Final: C′