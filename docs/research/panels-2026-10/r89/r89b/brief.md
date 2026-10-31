# Panel J r89b — pv-9ecf Q1: one consensus round

Read this brief and notes.md whole. Use only your own reader clone at PIN 3109b5b44eae17e288cf52aaa976993bd8c5626c, plus this complete packet. Do not edit source, Git state, tracker or panel records; do not commit, push, reset, checkout, stash, clean, contact a PR, start subagents/background work, or read any other clone/round, the main checkout, ~/.claude, ~/.codex, ~/.grok, auth/session/config files, kubeconfig or browser profiles. Temp files only under /var/tmp/provisiond-panel-r89/r89b/tmp/<your-seat>/. No internet/provider call. Readers run no lake build, formal gate or check-all. The manager runs the gates independently. Return a substantive answer within the 3600-second bound; aim <=1800 words plus any complete exact alternative.

**apply notes.md rule 6 exactly as written; this prompt adds no void rule.**

## Fixed owner policy and adoption boundary

Owner, 2026-10-30, owner-decisions-1030.md item 4, after the pin:

Question: "When an account has ordering switched off, which creates should that block?"
Answer: **"Every paid create (Recommended)"**.
Option shown: "The switch and the per-request purchase acknowledgement cover any create that starts billing, hourly cloud VMs included. 'Orders off' means the account can't spend. Cost: cloud accounts also need the switch on, and each cloud create carries the acknowledgement. This is the 10-27 triage's pick. The exact wording gets a panel read before it lands."
Rejected: "Upfront purchases only". No form excluding paid hourly rental can count. The policy is fixed, not a vote. Suspension mechanics belong to Panel D, not this question.

Owner, 2026-10-28: "For such wording questions, try to solve by getting a consensus of the panel". A settled form that only words the fixed policy can become ready-for-agent with both precedents quoted. A form adding or dropping a check, test obligation or other behavior beyond item 4 needs owner approval with the settled exact form recommended. In particular the explicit hourly conformance cases are an additional test obligation, not just word choice; do not treat this panel as adoption of that obligation. They are implementation-conformance text, not a repository runtime test or authorization of a live sale.

## Plain example and the remaining disagreement

With ordering switched off, a request for an hourly rented machine with no setup fee must fail even if its purchase acknowledgement is true. With ordering on, the same paid create still requires the acknowledgement. Every candidate expressly covers that owner-fixed case.

The separate question is what happens to a create that starts no provider billing. The pinned wire rule requires acknowledgement true without a billing condition. A–D add a condition; the worker fixtures in CNF-34 and CNF-342 acquire the same paid-create scope. Opus objects that the fixed policy did not authorize exempting any create, and offers C′: C's centralized definition and hourly cases, retaining those three pinned blocks. The other readers saw the narrowing, but accepted C; they have not yet read C′.

## Prior tally, preserved without void

| Reader | Final | Exact acceptability |
|---|---|---|
| fable | C | A/C accept; B/D cannot accept for duplicate ownership, not rule-3 verdict loss |
| opus | C′ | A/B/C/D cannot accept; C′ complete; printed-form ranking C>A>D>B is not acceptance |
| astra | C | A/C accept; B/D cannot accept for duplicate ownership, not rule-3 verdict loss |
| sol | C | A/B/C/D accept without edits; prefers centralized definition and hourly assertions |

C has three explicit picks, A/C have three accepts, but the manager held settlement under the no-blocking-loss part of notes rule 2. This is not a tie invented from the accepts, and no vote was voided. Check the manager's diagnosis independently; do not accept it merely because it is in this packet. All readers' complete prior answers appear verbatim below so you can respond to their reasoning directly. Requested strongest counterarguments in those answers are not votes.

## Verified evidence and disputed inferences

1. WIR-17 at 13-wire-contract.md:665–666 says "`acknowledge_purchase` MUST be literal `true` (`API-15`, `PRV-10`)" without a billing condition. Every A–D changes it to a condition. CNF-34's "On separate creates" becomes paid creates; CNF-342's resource-offer fixture becomes paid. All original readers acknowledge this textual scope change.
2. CNF-315 at 10-conformance-checklist.md:822–831 includes "a zero recurring price and a null floor"; CNF-316 at :832–845 says "Accept an order on an offer whose `first_unit` is zero". LDG-39 at 12-billing-and-ledger.md:1241–1246 addresses positive seconds at zero recurring price. DOM-9 at 01-domain-model.md:165–173 separately permits setup fee zero. **Zero first_unit alone does not prove no billing**: exact elapsed-time billing can give zero first_unit with a positive recurring price, and it says nothing alone about a setup fee. No live free v1 offer is claimed.
3. The manager's proposed rule-3 loss: take an otherwise valid create that starts no new provider billing, with zero recurring price, null floor and zero setup fee, account enabled, fresh key and acknowledgement false. The pinned wire MUST rejects it independently of cost. With A–D's non-billing reading, that unconditional rejection is no longer required. PRV-10/API-15 use the same condition and OVR-6's "billable actions" supplies no unconditional substitute. Decide whether this is a verified normative/fixture loss, an unreachable premise, or an already authorized scope correction. Quote the owner and full trace; distinguish removing a required refusal from forcing admission.
4. Opus's claim that a per-create condition necessarily moves the offer-price read is **not established**. API-7's tail at 04-api-contract.md:263–264 owns the stored-offer snapshot; no candidate expressly moves it, and an account-level classification can be known without pricing a particular offer. Verify any claimed reordering rather than inheriting it. The capability predicate is account-level (permits a paid create); the acknowledgement predicate is per-create. Mixed capability withholding remains whole-capability, not a per-offer replacement gate.
5. The parent brief expressly said the wire field rule "gets the same scope predicate". Therefore opus's claim that this textual change was wholly undisclosed is too broad. The source quotes match the pin and no premise-changing brief error was found; notes rule 6 did not void the prior votes. The broad prose about "the property" at capability level was imprecise for request-level acknowledgement. Do not create a new void rule from it.
6. Absence of a new hourly fixture is not a blocker. The original checklist has worker acknowledgement cases and CNF-182's pre-existing Robot/test-mode Cancelled assertion, but no explicit core admission 400 case for absent/false purchase acknowledgement. Do not overclaim that the checklist never mentions absence at all. A/B preserve fewer explicit demonstrations; C/D/C′ add hourly admission, successful control, restart and stored-acknowledgement cases.
7. B/D repeat the scope predicate at consuming sites. AGENTS.md says "One rule, one home; everywhere else points at it." This maintenance objection is separate from a rule-3 checked/normative loss. No additional scope wording or new descriptor field is needed to realize the paid-hourly decision.

## Your consensus task — Q1 only

For every complete printed A/B/C/D/C′ form below, write CAN ACCEPT / CAN ACCEPT WITH THIS FIX / CANNOT ACCEPT, preserving unqualified acceptance separately from preference. An acceptance with a fix is a different exact form; supply it completely (all replacement/retention blocks), and identify changes. Do not silently combine repairs or regard others' unseen acceptance as known.

Address the strongest reasons on both sides: one owner plus direct hourly tests versus retaining the existing unconditional wire/worker coverage. Read the other answers verbatim. Say whether the manager's proposed rule-3 loss is verified, with the owner and trace; if rejecting it, explain exactly which premise fails. Identify any loss/new obligation in C′ as printed, including fixtures, check order, error details, gates and test strength. Re-trace the paid-hourly off/on cases and claim-time cases; no runtime execution is claimed. Do not weaken a safeguard merely to obtain a majority.

End `Final: <one exact form>` preferring a form the other seats can accept; give your own preference separately if different. State whether it is wording-only under item 4 or would need owner approval because it changes test/behavior obligations. The manager, not this round, will tally. This is the ONE consensus round; a remaining failure to settle goes to the owner, not another round.

## Pinned source evidence from r89, verbatim


### Configuration catalogue — `00-overview.md:403–416` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`

```text
403: | Operator-principal ceilings | `SEC-39` | integers | yes |
404: | Lightning ceiling | `SEC-49` | satoshis | yes |
405: | Order budget declaration, per provider account and ordering channel | `PRV-40`, `PRV-44` | `{limit, per}` — positive limit and finite, positive period in each channel descriptor; documentation and the alarm raised on the provider's reported 403, not a local admission counter | yes |
406: | Activation funding minimum | `API-35`, `LDG-44` | positive integer satoshis | yes |
407: | Enrolment per-source concurrency | `API-36` | integer | yes |
408: | Pending-tenant ceiling | `API-41` | integer | yes |
409: | Rescue timeouts | `RSC-35` | durations | yes |
410: | Address canonical form | `STO-41` | normalisation rule | yes |
411: | Retention windows | `STO-14`, `STO-43` | durations | yes |
412: | `allow_orders`, per ordering account | `DOM-16` | boolean | yes |
413: | Negative-resolution window, per provider | `OPS-33` | duration | yes |
414: | Tenant-to-account assignment policy | `API-57`, `SEC-43` | policy over assignable accounts | yes |
415: | Startup-lock wait bound | `OPS-47`, `OPS-15` | finite duration expressible exactly as a positive whole number of milliseconds accepted by both `OPS-15` timeout settings, minimum 1 ms; also the generation advance's `statement_timeout` and `lock_timeout` (`OPS-15`) | yes |
416: | Startup-lock connection keepalives | `OPS-47` | durations | yes |
```

### Capability owners — `01-domain-model.md:515–538` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`

```text
515: **DOM-10** Every operation with a capability MUST be gated on it before the
516: driver is called, **including create**; the driver methods with no capability entry are the ones
517: `PRV-4` names. There MUST be no operation whose only gate is
518: a driver-internal check. A capability check failure MUST return an "unsupported" error
519: naming the provider account and the capability, with `retryable: false` on both the error and the operation view where there is one.
520: 
521: Mapping from operation to required capability:
522: 
523: | Operation | Required capability |
524: |---|---|
525: | create machine, `kind = virtual` | `provision_virtual` |
526: | create machine, `kind = bare_metal` | `provision_bare_metal` |
527: | refresh | none — every driver MUST implement machine lookup |
528: | power on/off/reboot | `power_control` |
529: | hard reset | `hard_reset` |
530: | install, `provider_native` + `catalog` | `native_rebuild` |
531: | list offers | `list_offers` |
532: | rescue inventory | `rescue_ssh` (`RSC-38` boots rescue to read the inventory) |
533: | install, `rootfs_via_rescue` | `install_rootfs_via_rescue` |
534: | install, `raw_disk` | `install_raw_disk_via_rescue` |
535: | install, `provider_catalogue` | `install_via_provider_catalogue` |
536: | reverse DNS | `reverse_dns` |
537: | delete | `delete_machine` |
538: | release attachment | `delete_machine` — a driver that can delete a machine can release what it left behind (`PRV-45`) |
```

### Capability/opt-in scope owners — `01-domain-model.md:564–573` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`

```text
564: **DOM-15** A capability that is declared but whose code path returns "unsupported" is a
565: defect. Declaration and implementation MUST agree; the conformance checklist tests this
566: (`10-conformance-checklist.md`). An ordering capability withheld under `DOM-16` is excepted from that agreement (`PRV-4`).
567: 
568: *Amended 2026-10-22 (`pv-p3k`; panel r62, `docs/research/panels-2026-10/r62/`; owner decision 2026-10-22): applied the reviewed ordering-capability change.*
569: 
570: **DOM-16** Ordering capabilities (`provision_virtual`, `provision_bare_metal`) for providers that bill per order MUST be conditional on an explicit per-account `allow_orders` configuration flag: the descriptor (`PRV-44`) of an account whose flag is false does not declare them, so that a misconfigured deployment cannot spend money. This is in addition to, not instead of, the per-request purchase acknowledgement
571: (`API-15`).
572: 
573: *Amended 2026-10-22 (`pv-p3k`; panel r62, `docs/research/panels-2026-10/r62/`; owner decision 2026-10-22): applied the reviewed ordering-capability change.*
```

### Provider opt-in owner — `02-provider-contract.md:159–164` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`

```text
159: **PRV-10** For a provider that bills on order, create MUST reject the request unless the
160: request carries an explicit purchase acknowledgement (`WIR-17`'s top-level
161: `acknowledge_purchase`), *and* the account
162: is configured to allow ordering. Both, not either. The configuration half is `DOM-10`'s gate on the create's ordering capability (`DOM-16`): `API-7`'s step 5d at admission and `OPS-43`'s step 3 at claim.
163: 
164: *Amended 2026-10-22 (`pv-p3k`; panel r62, `docs/research/panels-2026-10/r62/`; owner decision 2026-10-22): applied the reviewed ordering-capability change.*
```

### API acknowledgement owner — `04-api-contract.md:983–992` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`

```text
983: **API-14** An install request MUST carry an explicit destructive acknowledgement, and a
984: delete request MUST carry one. Absent or false MUST fail `400`. This is per request, and
985: is not satisfied by authentication, by idempotency, or by having sent one previously.
986: 
987: **API-15** A create request against an order-billed provider MUST carry an explicit
988: purchase acknowledgement — `WIR-17`'s top-level `acknowledge_purchase`, which the wire contract
989: owns — in addition to the account being configured to allow ordering (`PRV-10`). *"In its provider
990: options" until 2026-09-05, while `WIR-17` placed it at the top level; the wire contract wins, and a
991: spending authorization nested inside a driver-private object is one a strict server could not tell
992: from any other option.*
```

### API gate position — `04-api-contract.md:203–213` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`

```text
203:    — rejected a suspended tenant here, which made 5b unreachable and defeated its stated reason
204:    for existing: every write retried after its tenant was suspended lost the stored idempotent
205:    result `API-11` promises it, including a suspend whose own `202` was lost;*
206: 3. validate the idempotency key;
207: 4. authorize the target resource against the tenant;
208: 5. deserialize and validate the body;
209: 5a. **compute the request fingerprint and check it** (`WIR-3`): an equal fingerprint under the
210:     same `(principal, key)` returns the stored result, a different one fails `conflict`. This step
211:     needs the parsed body, which is why it cannot live at step 3;
212: 5b. **reject with `suspended`** if the tenant is suspended and this is not a maintenance action
213:     (`API-58`, `DOM-20`). **This is the only step that rejects for suspension** — step 2 passes a
```

### API ordering gate — `04-api-contract.md:241–241` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`

```text
241: 5d. **gate a create on its ordering capability** under `DOM-10` (`PRV-10`, `DOM-16`). A refusal stops here and is not collected by the tail.
```

### Claim gates — `03-operation-lifecycle.md:774–800` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`

```text
774: The worker MUST order the following steps as listed:
775: 
776: 1. Read the provider account's stored status (`STO-47`). This is a plain read, not a
777:    conditional-write guard; the guard remains the conditional write at step 8. If the status
778:    is not `healthy`, fail `conflict`, with `API-63`'s “`details.reason: "account_terminated"`
779:    where the status is `terminated` and `"state"` for the two recoverable statuses, since
780:    presenting an unreachable account as a permanent termination is false, and with
781:    `retryable: false` for `"account_terminated"` and `retryable: true` for `"state"` on both the
782:    error and the operation view”. Make no
783:    provider request and release the commitment in full under `LDG-39`'s "Deterministic rejection
784:    before acceptance" case.
785: 2. Read the stored channel closure (`PRV-40`: "the worker MUST read the stored closure for that
786:    account and ordering channel when it claims the operation (`OPS-5`), before any provider
787:    request, including a per-order key upload").
788: 3. Repeat boundary validation under `OPS-23`: "Validation that was performed at the API boundary
789:    MUST be repeated in the worker before the driver is called". This includes `PRV-10`'s
790:    "explicit purchase acknowledgement", `PRV-8`'s "at least one SSH public key", the missing-field
791:    checks defined in `OPS-23`, and `DOM-10`'s gate on the create's ordering capability, which is
792:    `PRV-10`'s "the account is configured to allow ordering". The checks on caller-supplied fields
793:    run first, then the checks on fields the `api` wrote at admission, then the capability gate.
794: 4. Gate on `list_offers` under `DOM-10`, then obtain the current driver List offers result.
795: 5. Check for the named offer's absence from that result, applying the create-tail verdict quoted
796:    above; if present, re-test the named offer for sale on that result and the running descriptor.
797: 6. Compare its price using that same List offers result, as below. An unsellable offer gets no
798:    price comparison.
799: 7. Run `PRV-47`'s driver validation: "the driver MUST validate every value it forwards to the
800:    provider, including provider options". For the rejection's error, see `PRV-47`.
```

### Wire field owner — `13-wire-contract.md:665–668` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`

```text
665: `ssh_public_keys` MUST be non-empty (`PRV-8`, `API-13`). `acknowledge_purchase` MUST be literal
666: `true` (`API-15`, `PRV-10`). `image` (nullable, a catalog identifier), `user_data` (nullable,
667: ≤1 MiB, `API-13`) and `labels` (string→string; the correlator's reserved key is the driver's, `PRV-26`, and a caller
668: label colliding with it MUST be rejected, `OPS-38`) are the create inputs
```

### Illustrative matrix — `08-provider-notes.md:24–32` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`

```text
24: The shape the reference implementation arrived at, as an illustration of how unevenly
25: providers cover the model. A driver's own row is its descriptor's `capabilities` (`PRV-44`); this
26: table is not read by anything.
27: 
28: | Capability | Cloud VPS | Dedicated (robot-style) | Dedicated (cherry-style) |
29: |---|:--:|:--:|:--:|
30: | List offers | yes | yes | yes |
31: | Create | yes | opt-in ordering | opt-in ordering |
32: | ~~Adopt~~ | — | — | — |
```

### Historical defect wording — `09-known-defects.md:161–169` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`

```text
161: ### DEF-17 — Requeue re-ran non-idempotent purchases with no additional gate
162: 
163: Requeue re-executed the original request verbatim. For a create against an order-billed
164: provider that is a second purchase, gated by nothing beyond the same tenant token that
165: placed the first one.
166: 
167: **Prohibition** — a create gets exactly one attempt and nothing re-places the order (`ADR-0014`);
168: requeue itself no longer exists (`ADR-0017`), and the surviving operator recovery, `API-64`'s retry
169: of a `stalled` episode, re-issues only a cancellation and never a purchase.
```

### Existing conformance capability cases — `10-conformance-checklist.md:124–154` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`

```text
124: - [ ] **CNF-18** — **AMENDED 2026-09-08 (`ADR-0018`) — the table is `DOM-10`'s, and the descriptor's
125:       fields are rows too.** For every driver, every declared capability has a working code path,
126:       and every implemented operation with a capability entry in `DOM-10`'s table has its
127:       capability declared. Table-driven over that table, one case per (driver, capability) pair;
128:       the three capability-less methods are `CNF-20`'s and are not rows here. **Then iterate the
129:       descriptor** (`PRV-44`), one case per (driver, field): a declared value has a working code
130:       path behind it — a declared ordering channel is searched, a declared evidence source is read,
131:       a declared surviving attachment kind is listed, and each ordering channel carries
132:       its own validated `order_budget` — and a field with nothing to declare says so
133:       explicitly rather than being absent. An ordering capability withheld under `DOM-16` is outside the implemented-implies-declared rows for that account; `CNF-19` and `CNF-55` cover its gate. (`DOM-15`, `DOM-10`, `PRV-4`, `PRV-44`)
134:       *Amended 2026-10-09 (`ADR-0036`): the order-budget field is iterated per channel.*
135:       *Amended 2026-10-22 (`pv-p3k`; panel r62, `docs/research/panels-2026-10/r62/`; owner decision 2026-10-22): applied the reviewed ordering-capability change.*
136: 
137: - [ ] **CNF-19** — Create is refused when the provider has not declared the matching
138:       provision capability — with the driver's internal ordering flag set to permissive,
139:       so the test proves the outer gate exists. (`DOM-10`, `DEF-10`)
140: - [ ] **CNF-364** — **The claim-time List offers read is gated on `list_offers`.** Admit a
141:       complete resource-offer (`offer_is_resource`) create on an account that declares
142:       `list_offers` and the ordering capability. Assert this create's exclusion for its provider
143:       account, ordering channel and offer id is held at admission (`PRV-42`, `STO-58`).
144:       While it is still queued and unclaimed, restart with a descriptor for that account that
145:       removes only `list_offers`, keeping the ordering capability declared and the driver's
146:       List offers code path answering, so the test proves the gate exists, as `CNF-19` does. Assert the worker
147:       refuses the create at `OPS-43`'s step 4: `unsupported` with `details.provider_account`
148:       naming the account and `details.capability: "list_offers"`, `retryable: false` on both the
149:       error and the operation view, no `details.refusals` or `details.not_checked`, `failed`, the
150:       commitment released in full with no setup-fee or first-unit debit, this create's settlement
151:       freeing that same held resource-offer exclusion (`STO-58`), and no List offers read,
152:       per-order key upload or order request. (`DOM-10`, `OPS-43`, `OPS-11`, `LDG-39`, `WIR-9a`,
153:       `WIR-9b`)
154:       *Amended 2026-10-22 (`pv-009`; panel r62, `docs/research/panels-2026-10/r62/`): applied the reviewed claim-time capability gate and refusal checks.*
```

### Existing worker validation case — `10-conformance-checklist.md:256–279` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`

```text
256: - [ ] **CNF-34** — Validation is enforced in the worker even when the stored request bypasses
257:       the API layer. On separate creates, store records missing a caller-supplied field —
258:       `acknowledge_purchase` (`WIR-17`: "`acknowledge_purchase` MUST be literal `true`") — and
259:       an api-filled admission field, using the accepted-price fields in `request_summary`
260:       (`OPS-43`: "the accepted recurring price, its currency and its period"). For the caller field assert `invalid_request` with
261:       `details.field: "/acknowledge_purchase"` and `retryable: false`; for the api-filled
262:       field assert `conflict`, `details.reason: "incomplete_record"` and `retryable: true`.
263:       Assert the same kind, applicable reason and `retryable` on the error and the operation
264:       view (`WIR-9b`), `failed`, no driver call, and the create's commitment released in full
265:       with no setup-fee or first-unit debit.
266:       Repeat the caller-field case on an install, using `API-14`'s "explicit destructive
267:       acknowledgement". Assert `invalid_request` with `details.field: "/acknowledge_destruction"` and `retryable: false`
268:       on the error and view, `failed`, no driver call, both marker columns still null,
269:       `disk_effect: "none"` and `rescue_exit: "none"`. The install fixture uses that caller
270:       acknowledgement; an api-filled install case applies only if the release names a field the
271:       `api` writes at install admission, and the fixture must identify that field. It asserts
272:       `conflict`/`incomplete_record`, `retryable: true` and the same untouched-install outcome.
273:       Complete-record controls on create and install proceed. (`OPS-23`, `OPS-43`, `API-14`,
274:       `WIR-17`, `WIR-9a`, `WIR-9b`, `OPS-11`, `OPS-45`, `LDG-39`)
275:       *Amended 2026-10-17 (`pv-14b`; panel r55, `docs/research/panels-2026-10/r55/`):
276:       added missing-field fixtures, error/view agreement, commitment release,
277:       install marker outcomes and complete-record controls.*
278: 
279:       *Amended 2026-10-22 (`pv-ss4`; panel r62, `docs/research/panels-2026-10/r62/`): applied the reviewed field-pointer form and validation ordering.*
```

### Existing acknowledgement case — `10-conformance-checklist.md:340–359` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`

```text
340: - [ ] **CNF-55** — Create against an order-billed provider is rejected without both the
341:       per-request purchase acknowledgement and the account-level opt-in. On an account whose
342:       `allow_orders` is false, assert `GET /v1/providers` lists it without its ordering
343:       capability, and that a create carrying `acknowledge_purchase: true` is refused at `API-7`'s
344:       step 5d: HTTP `501`, `unsupported`, `details.provider_account` and `details.capability`
345:       naming the account and that capability, `retryable: false`, and, with a balance too low for
346:       the create, no `details.refusals` or `details.not_checked` and no operation or commitment.
347:       A same-key, same-body replay of a create admitted before the flag was turned off returns its
348:       stored result. Admit a complete resource-offer (`offer_is_resource`) create with
349:       `allow_orders` true, and assert this create's exclusion for its provider account, ordering
350:       channel and offer id is held at admission (`PRV-42`, `STO-58`). While it is still queued
351:       and unclaimed, restart with only that flag changed to false, and assert the worker
352:       refuses it at `OPS-43`'s step 3 with the same kind, `details`
353:       and `retryable: false` on both the error and the operation view, `failed`, the commitment
354:       released in full with no setup-fee or first-unit debit, this create's settlement freeing
355:       that same held resource-offer exclusion (`STO-58`), and no provider request, including
356:       no List offers read. (`API-15`, `PRV-10`, `DOM-10`, `DOM-16`, `API-7`, `OPS-43`, `WIR-9a`,
357:       `WIR-9b`, `LDG-39`)
358: 
359:       *Amended 2026-10-22 (`pv-p3k`; panel r62, `docs/research/panels-2026-10/r62/`; owner decision 2026-10-22): applied the reviewed ordering-capability change.*
```

### Robot test mode — `10-conformance-checklist.md:2371–2376` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`

```text
2371: - [ ] **CNF-182** — The Robot driver's order test flag **defaults to test mode**, and a real
2372:       purchase requires an explicit spend intent that is set exactly once, where `API-15`'s
2373:       acknowledgement and `PRV-10`'s `allow_orders` both hold. Asserted by placing an order with
2374:       the acknowledgement absent and confirming the API returns a `Cancelled` transaction and no
2375:       server. **A driver defaulting to "real purchase" turns every mistaken conformance run into a
2376:       bought server.** (`PRV-34`, `API-15`, `PRV-10`)
```

### Worker acknowledgement paragraph — `10-conformance-checklist.md:4311–4320` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`

```text
4311:       Separately omit the caller-supplied purchase acknowledgement from the stored record:
4312:       admit a complete, valid resource-offer (`offer_is_resource`) create and assert this
4313:       create's exclusion for its provider account, ordering channel and offer id is held at
4314:       admission (`PRV-42`, `STO-58`), then remove only the stored caller-supplied acknowledgement
4315:       before worker claim and validation (`OPS-23`). Assert rejection at
4316:       `OPS-43`'s step 3, "Repeat boundary validation under `OPS-23`": `invalid_request` with
4317:       `details.field: "/acknowledge_purchase"`, `retryable: false` on the error and operation view, `failed`, commitment
4318:       released in full with no setup-fee or first-unit debit, this create's settlement freeing
4319:       that same held resource-offer exclusion (`STO-58`), and no provider request at all,
4320:       including no List offers read.
```

### Channel declarations — `10-conformance-checklist.md:4358–4363` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`

```text
4358: - [ ] **CNF-344** — **Amended 2026-10-12 (`ADR-0037`, Q28).** **Each channel declares its own order budget.** Enumerate the
4359:       descriptor's ordering channels and assert each has a positive `limit` and finite,
4360:       positive `per`; no top-level `order_budget` substitutes for a missing channel
4361:       entry. Verify the declared limit documents capacity; Robot's reported `403 RATE_LIMIT_EXCEEDED` raises `PRV-5`'s alarm naming account and request path (and channel where useful) and closes the local gate. No local request count raises that alarm.
4362:       Another channel's mere declaration authorizes no new ordering capability.
4363:       (`PRV-44`, `PRV-40`, `DOM-10`)
```

### Launch and sale scope — `docs/adr/0010-v1-ships-three-drivers-across-two-companies.md:62–66` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`

```text
62: 
63: **Amended 2026-10-09 (`ADR-0039`).** The v1 sale scope is currently Robot's default
64: unlimited-traffic dedicated offers. Cloud, DigitalOcean and Robot 10 Gbit offers remain
65: withheld until the live evidence gate in `ADR-0039` re-admits an offer. This changes
66: which offers may be sold, not the three-driver specification or its conformance scope.
```


## Additional pinned evidence for the dissent

### Zero-price conformance cases — `10-conformance-checklist.md:822–845` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`

```text
822: - [ ] **CNF-315** — **The unit is committed at the customer rate before the order is placed.**
823:       Create against an offer with a non-zero unit: the commitment includes `first_unit` at the
824:       customer rate and the setup fee at cost. Kill the process between the commitment's open and
825:       the order: no order is placed (`LDG-12`). With a balance that covers every other term but
826:       not the unit, the create is refused before any provider call. On a floor-priced offer the
827:       term is the floor with the margin, not `seconds` at the rate. On an offer whose `first_unit`
828:       is zero — zero `seconds` and a null floor, or a zero recurring price and a null floor — the
829:       commitment carries no unit term and the ambiguous row parks nothing for the unit
830:       (2026-10-08, `ADR-0033`). (`PRV-13b`, `PRV-44`,
831:       `LDG-12`, `LDG-24`, `LDG-39`)
832: - [ ] **CNF-316** — **Successful settlement after acceptance debits the authorized amount as its
833:       own kind, paired with the decrement.** Move the rate
834:       between the create and the provider's acceptance. The entry is a
835:       `first_unit_debit`, never a `usage_debit`, for exactly the satoshi amount
836:       `operations.request_summary` carries as authorized and not a re-conversion; the commitment
837:       is decremented by the same amount in the same transaction (kill the process between them
838:       and neither survives); `available` does not move. A machine that lives ten seconds has paid
839:       the whole unit, and the meter has posted nothing for it. Accept an order on an offer whose
840:       `first_unit` is zero: no `first_unit_debit` and no entry of any kind is posted for the unit,
841:       and no deficiency is ever recorded for it (2026-10-08, `ADR-0033`). Assert the machine
842:       reference identifies its own nonzero debit on paid settlement and remains null on the
843:       zero case. Inject failure between debit, decrement, reference and same-transaction seed:
844:       all or none persist; replay creates no duplicate. Repeat with settlement by resolution
845:       and with a delayed first seed after purging the operation: eligibility still reads the
```

### Zero-unit owner — `12-billing-and-ledger.md:1240–1246` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`

```text
1240: transaction showing **the unit** was charged, applied to the unit on its own; the fee's trigger
1241: stays the fee's. **Where `first_unit` is zero** — whatever made it so: `PRV-44`'s zero `seconds`
1242: with a null floor, where "`first_unit` is the floor alone or nothing", or a positive `seconds` at a
1243: zero recurring price with a null floor — **there is no obligation: the create MUST NOT commit,
1244: park, debit or record anything for the unit**, because `LDG-7` says "**Every entry moves real money.**"
1245: and `STO-45` says "a zero-value ledger row is not legal". For the seed, `LDG-38` requires:
1246: "an unpaid first seed MUST write it at the seed instant".
```

### Offer price representation — `01-domain-model.md:165–173` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`

```text
165: | `name` | Human-readable |
166: | `kind` | `virtual` \| `bare_metal` |
167: | `regions` | Where the offer can be placed |
168: | `currency`, `recurring_price`, `recurring_period` (`hour` \| `month`), `setup_fee` | Prices are strings to avoid float rounding. **Exactly one recurring price with its period, and one setup fee (`"0"` where the channel charges none), all required** — *until 2026-09-05 this row was two nullable prices and no setup fee, which could not carry Robot's per-location `price_setup` at all and let an offer with neither price pass as legal* |
169: | `install_strategies` | The offer's subset of `DOM-13`'s strategies, which **gates** them (`WIR-30`). Present on every offer; empty means no install is available for it |
170: | `max_image_bytes` | The ceiling `RSC-40` enforces against a caller-supplied image stream |
171: | `guest_requirements` | Prose the caller relays to whoever built the image; null where the strategy imposes none, non-null for `provider_catalogue` (`RSC-43`, `WIR-30`) |
172: | `min_runway_seconds`, `setup_fee_sats`, `first_unit_sats`, `billing_unit_seconds`, `max_rate_outage_seconds` | `PRV-13d`'s floor, `LDG-39`'s at-cost fee, the prepaid first billing unit's customer price in satoshis and its duration in seconds beside the fee (`ADR-0033`, `PRV-13b`; added 2026-10-08 — the unit's `native_floor` and native rate never reach the customer surface, `LDG-26`), and `LDG-64`'s disclosed bound — the operator's current limit, which can change (`WIR-30`) |
173: | `traffic_bound` | The offer's declared traffic limit, disclosed as `unlimited` for currently sellable offers (`PRV-44`, `WIR-30`); an allowance with headroom is conditional on `ADR-0039`'s live evidence gate (*added 2026-10-09, `ADR-0039`*) |
```

### Billable-action umbrella — `00-overview.md:46–47` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`

```text
46: **OVR-6** Destructive and billable actions MUST require an explicit per-request
47: acknowledgement in the request body, independent of authentication and idempotency.
```

### Create body and literal acknowledgement — `13-wire-contract.md:637–678` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`

```text
637: and `available_sats == balance_sats − committed_sats` (`LDG-9`) hold only because such entries are
638: included. `earliest_runway_until` is the minimum non-null `runway_until` over all non-deleted
639: billable machines including `cancellation_scheduled`, and is `null` when there are none.
640: 
641: **WIR-17** **AMENDED** `POST /v1/machines` — create:
642: 
643: ```json
644: {
645:   "provider_account": "hetzner-robot-1",
646:   "offer": "market:12345",
647:   "region": "fsn1",
648:   "hostname": "worker-1",
649:   "image": null,
650:   "ssh_public_keys": ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIexamplekeyxxxxxxxxxxxxxxxxxxxxxxxx"],
651:   "user_data": null,
652:   "labels": {"team": "batch"},
653:   "runway_seconds": 2592000,
654:   "max_commitment_sats": 90000,
655:   "acknowledge_purchase": true,
656:   "provider_options": {}
657: }
658: ```
659: 
660: This create uses `WIR-30`'s `"market:12345"` Robot default-uplink offer; the
661: running operation (`WIR-10`) and resulting machine (`WIR-11`) show the same
662: purchase at later stages. `WIR-30` says "the commitment is priced at accept
663: time"; its earlier listing quote is indicative.
664: 
665: `ssh_public_keys` MUST be non-empty (`PRV-8`, `API-13`). `acknowledge_purchase` MUST be literal
666: `true` (`API-15`, `PRV-10`). `image` (nullable, a catalog identifier), `user_data` (nullable,
667: ≤1 MiB, `API-13`) and `labels` (string→string; the correlator's reserved key is the driver's, `PRV-26`, and a caller
668: label colliding with it MUST be rejected, `OPS-38`) are the create inputs
669: the other requirements accept and this body previously omitted — under `WIR-2` a conforming server
670: would otherwise reject them. `runway_seconds` is `PRV-13d`'s caller-chosen runway; a value **below**
671: the wind-down floor MUST be **rejected** `invalid_request` with `details.min_runway_seconds`, never
672: silently raised — silently reserving more of a caller's money than it asked for is a money bug.
673: `max_commitment_sats` (optional) caps spend: if the computed commitment exceeds it the request
674: fails `invalid_request` (not `insufficient_balance`) **before** any commitment opens, so an agent
675: can bound a purchase priced at an attacker-influenceable rate (`LDG-41`). `WIR-9a` owns its
676: cap details; `API-7` owns tail combination and ordering.
677: 
678: *`WIR-18` — `POST /v1/machines/adopt` — is withdrawn with adopt (`ADR-0020`). It returns as a
```

### Body validation and replay — `04-api-contract.md:206–211` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`

```text
206: 3. validate the idempotency key;
207: 4. authorize the target resource against the tenant;
208: 5. deserialize and validate the body;
209: 5a. **compute the request fingerprint and check it** (`WIR-3`): an equal fingerprint under the
210:     same `(principal, key)` returns the stored result, a different one fails `conflict`. This step
211:     needs the parsed body, which is why it cannot live at step 3;
```

### Offer snapshot order — `04-api-contract.md:261–264` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`

```text
261: 
262: **Rich purchase tails (create and extend-runway only; amended 2026-10-04, `ADR-0030`).** After steps 1–5d, the tail MUST
263: collect every applicable refusal once, from one read-only snapshot inside the existing `LDG-35`
264: transaction, without an extra lock, ceiling slot, write or provider call. On create, the offers the check reads are the provider account's stored offer listing (`05-persistence.md`, `offer_listings`), read in that snapshot, and the tail prices the commitment and takes the offer snapshot from it. On create, the tail reads the stored listing regardless of age, or an empty offers set if no listing is stored. If the tail has collected no refusal and the stored listing has a `read_at` older than the stated offer-listing age (`OVR-19`) at the admitting transaction, the create MUST be refused `provider` (`01-domain-model.md`'s error taxonomy) with `retryable: true` before any admission write, committing nothing. Every offer-derived input used to size the commitment or populate `request_summary` comes from the named offer in that same stored listing, including recurring price, currency, period, setup fee, `install_strategies`, and any offer-reported billing unit or cancellation bound. Descriptor-declared inputs come from the descriptor the `api` runs with. See `PRV-44`, `PRV-13b` and `05-persistence.md`. `details.refusals`
```

### Worker validation owner — `03-operation-lifecycle.md:2018–2045` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`

```text
2018: **OPS-23** Validation that was performed at the API boundary MUST be repeated in the
2019: worker before the driver is called. The record may have been written by an older version
2020: of the service, or edited in the store. Validation is cheap; a wrong install is not. **A field a
2021: previous-release `api` may not have written is a deterministic failure in the worker, never a
2022: passed check** (added 2026-09-12, `ADR-0024`): a create admitted without `OPS-43`'s accepted-price
2023: fields fails before dispatch rather than dispatching at whatever the offer says now.
2024: 
2025: For create, install, power and delete, a missing required field MUST fail as follows:
2026: 
2027: - A field the `api` itself writes when it admits the operation fails `conflict`, with
2028:   `details.reason: "incomplete_record"` and `retryable: true` on both the error and the operation
2029:   view. The accepted-price fields above are such fields; the worker-written correlator is not.
2030: - A field the caller must supply fails `invalid_request` naming the field, with
2031:   `retryable: false` on both the error and the operation view.
2032: 
2033: A field that is present but fails this repeated validation fails as its writer's bullet above says, on both the error and the operation view, and settles as these missing-field failures do.
2034: 
2035: These missing-field failures settle `failed` under `OPS-11`. On a create they come at `OPS-43`'s
2036: step 3, and `OPS-11` says "Any create failure the worker records before any step-9 request (before any per-order key upload or order request) MUST settle `failed`, whatever its kind."
2037: Power and delete take its last row's "any failure the worker records while `OPS-45`'s write-started marker
2038: is unset", and its install row gives `failed`
2039: "for any failure at all while `OPS-45`'s two markers say the disk is untouched and no rescue
2040: session was left open". On a create, the commitment is
2041: released in full under `LDG-39`'s "Deterministic rejection before acceptance" case, whose fee
2042: and first-unit outcome is "**Never debited**; released with the commitment (`LDG-32`)".
2043: Install, power and delete release no commitment here. On an install, these checks MUST run
2044: before either `OPS-45` marker is written: its rescue marker is "**false, written before begin
2045: rescue (`PRV-15`) is dispatched**". The install settles `failed` with `disk_effect: "none"`
```


## Complete exact options

## Form A — One defined scope, existing checks

This is a complete landing form. The blocks below are all its replacements and explicitly retained direct dependents. Historical amendment paragraphs outside the printed replacement ranges stay as pinned; no new decision record is being proposed.

### Replace: DOM-16 — `01-domain-model.md:570–571` at the pin

```markdown
**DOM-16** A **paid create** is a create that starts new provider billing to the
operator, whether an upfront charge or hourly or other recurring machine rental; neither a
setup fee nor immediate payment is required. For each provider account, an ordering capability
(`provision_virtual` or `provision_bare_metal`) that permits a paid create MUST be conditional
on an explicit per-account `allow_orders` configuration flag: the descriptor (`PRV-44`) of an
account whose flag is false does not declare that capability, so that a misconfigured deployment
cannot start that billing. This is in addition to the per-request purchase acknowledgement
(`API-15`).
```

### Replace: PRV-10 — `02-provider-contract.md:159–162` at the pin

```markdown
**PRV-10** For a paid create (`DOM-16`), create MUST reject the request unless the
request carries an explicit purchase acknowledgement (`WIR-17`'s top-level
`acknowledge_purchase`), *and* the account is configured to allow ordering. Both, not either.
The configuration half is `DOM-10`'s gate on the create's ordering capability (`DOM-16`):
`API-7`'s step 5d at admission and `OPS-43`'s step 3 at claim.
```

### Replace: API-15 — `04-api-contract.md:987–992` at the pin

```markdown
**API-15** A paid create request (`DOM-16`) MUST carry an explicit purchase
acknowledgement — `WIR-17`'s top-level `acknowledge_purchase`, which the wire contract
owns — in addition to the account being configured to allow ordering (`PRV-10`). *"In its provider
options" until 2026-09-05, while `WIR-17` placed it at the top level; the wire contract wins, and a
spending authorization nested inside a driver-private object is one a strict server could not tell
from any other option.*
```

### Replace: configuration row — `00-overview.md:412–412` at the pin

```markdown
| `allow_orders`, per provider account with an ordering capability that permits a paid create (`DOM-16`) | `DOM-16` | boolean | yes |
```

### Replace: Create matrix row — `08-provider-notes.md:31–31` at the pin

```markdown
| Create | see `DOM-16` | see `DOM-16` | see `DOM-16` |
```

### Replace: DEF-17 historical scope paragraph — `09-known-defects.md:163–165` at the pin

```markdown
Requeue re-executed the original request verbatim. For a paid create (`DOM-16`), that is a
second purchase, gated by nothing beyond the same tenant token that placed the first one.
```

### Replace: WIR-17 field rules opening — `13-wire-contract.md:665–666` at the pin

```markdown
`ssh_public_keys` MUST be non-empty (`PRV-8`, `API-13`). For a paid create (`DOM-16`),
`acknowledge_purchase` MUST be literal `true` (`API-15`, `PRV-10`). `image` (nullable, a catalog identifier), `user_data` (nullable,
```

### Retain verbatim: CNF-18 — `10-conformance-checklist.md:124–135` at the pin

```markdown
- [ ] **CNF-18** — **AMENDED 2026-09-08 (`ADR-0018`) — the table is `DOM-10`'s, and the descriptor's
      fields are rows too.** For every driver, every declared capability has a working code path,
      and every implemented operation with a capability entry in `DOM-10`'s table has its
      capability declared. Table-driven over that table, one case per (driver, capability) pair;
      the three capability-less methods are `CNF-20`'s and are not rows here. **Then iterate the
      descriptor** (`PRV-44`), one case per (driver, field): a declared value has a working code
      path behind it — a declared ordering channel is searched, a declared evidence source is read,
      a declared surviving attachment kind is listed, and each ordering channel carries
      its own validated `order_budget` — and a field with nothing to declare says so
      explicitly rather than being absent. An ordering capability withheld under `DOM-16` is outside the implemented-implies-declared rows for that account; `CNF-19` and `CNF-55` cover its gate. (`DOM-15`, `DOM-10`, `PRV-4`, `PRV-44`)
      *Amended 2026-10-09 (`ADR-0036`): the order-budget field is iterated per channel.*
      *Amended 2026-10-22 (`pv-p3k`; panel r62, `docs/research/panels-2026-10/r62/`; owner decision 2026-10-22): applied the reviewed ordering-capability change.*
```

### Retain verbatim: CNF-19 — `10-conformance-checklist.md:137–139` at the pin

```markdown
- [ ] **CNF-19** — Create is refused when the provider has not declared the matching
      provision capability — with the driver's internal ordering flag set to permissive,
      so the test proves the outer gate exists. (`DOM-10`, `DEF-10`)
```

### Replace: CNF-34 — `10-conformance-checklist.md:256–279` at the pin

```markdown
- [ ] **CNF-34** — Validation is enforced in the worker even when the stored request bypasses
      the API layer. On separate paid creates (`DOM-16`), store records missing a caller-supplied field —
      `acknowledge_purchase` (`WIR-17`: "`acknowledge_purchase` MUST be literal `true`") — and
      an api-filled admission field, using the accepted-price fields in `request_summary`
      (`OPS-43`: "the accepted recurring price, its currency and its period"). For the caller field assert `invalid_request` with
      `details.field: "/acknowledge_purchase"` and `retryable: false`; for the api-filled
      field assert `conflict`, `details.reason: "incomplete_record"` and `retryable: true`.
      Assert the same kind, applicable reason and `retryable` on the error and the operation
      view (`WIR-9b`), `failed`, no driver call, and the create's commitment released in full
      with no setup-fee or first-unit debit.
      Repeat the caller-field case on an install, using `API-14`'s "explicit destructive
      acknowledgement". Assert `invalid_request` with `details.field: "/acknowledge_destruction"` and `retryable: false`
      on the error and view, `failed`, no driver call, both marker columns still null,
      `disk_effect: "none"` and `rescue_exit: "none"`. The install fixture uses that caller
      acknowledgement; an api-filled install case applies only if the release names a field the
      `api` writes at install admission, and the fixture must identify that field. It asserts
      `conflict`/`incomplete_record`, `retryable: true` and the same untouched-install outcome.
      Complete-record controls on create and install proceed. (`OPS-23`, `OPS-43`, `API-14`,
      `WIR-17`, `WIR-9a`, `WIR-9b`, `OPS-11`, `OPS-45`, `LDG-39`)
      *Amended 2026-10-17 (`pv-14b`; panel r55, `docs/research/panels-2026-10/r55/`):
      added missing-field fixtures, error/view agreement, commitment release,
      install marker outcomes and complete-record controls.*

      *Amended 2026-10-22 (`pv-ss4`; panel r62, `docs/research/panels-2026-10/r62/`): applied the reviewed field-pointer form and validation ordering.*
```

### Replace: CNF-55 — `10-conformance-checklist.md:340–359` at the pin

```markdown
- [ ] **CNF-55** — A paid create (`DOM-16`) is rejected without both the
      per-request purchase acknowledgement and the account-level opt-in. On an account whose
      `allow_orders` is false, assert `GET /v1/providers` lists it without its ordering
      capability, and that a create carrying `acknowledge_purchase: true` is refused at `API-7`'s
      step 5d: HTTP `501`, `unsupported`, `details.provider_account` and `details.capability`
      naming the account and that capability, `retryable: false`, and, with a balance too low for
      the create, no `details.refusals` or `details.not_checked` and no operation or commitment.
      A same-key, same-body replay of a create admitted before the flag was turned off returns its
      stored result. Admit a complete resource-offer (`offer_is_resource`) create with
      `allow_orders` true, and assert this create's exclusion for its provider account, ordering
      channel and offer id is held at admission (`PRV-42`, `STO-58`). While it is still queued
      and unclaimed, restart with only that flag changed to false, and assert the worker
      refuses it at `OPS-43`'s step 3 with the same kind, `details`
      and `retryable: false` on both the error and the operation view, `failed`, the commitment
      released in full with no setup-fee or first-unit debit, this create's settlement freeing
      that same held resource-offer exclusion (`STO-58`), and no provider request, including
      no List offers read. (`API-15`, `PRV-10`, `DOM-10`, `DOM-16`, `API-7`, `OPS-43`, `WIR-9a`,
      `WIR-9b`, `LDG-39`)

      *Amended 2026-10-22 (`pv-p3k`; panel r62, `docs/research/panels-2026-10/r62/`; owner decision 2026-10-22): applied the reviewed ordering-capability change.*
```

### Retain verbatim: CNF-182 Robot test-mode case — `10-conformance-checklist.md:2371–2376` at the pin

```markdown
- [ ] **CNF-182** — The Robot driver's order test flag **defaults to test mode**, and a real
      purchase requires an explicit spend intent that is set exactly once, where `API-15`'s
      acknowledgement and `PRV-10`'s `allow_orders` both hold. Asserted by placing an order with
      the acknowledgement absent and confirming the API returns a `Cancelled` transaction and no
      server. **A driver defaulting to "real purchase" turns every mistaken conformance run into a
      bought server.** (`PRV-34`, `API-15`, `PRV-10`)
```

### Replace: CNF-342 acknowledgement paragraph — `10-conformance-checklist.md:4311–4320` at the pin

```markdown
      Separately omit the caller-supplied purchase acknowledgement from the stored record:
      admit a complete, valid paid resource-offer (`offer_is_resource`) create (`DOM-16`) and assert this
      create's exclusion for its provider account, ordering channel and offer id is held at
      admission (`PRV-42`, `STO-58`), then remove only the stored caller-supplied acknowledgement
      before worker claim and validation (`OPS-23`). Assert rejection at
      `OPS-43`'s step 3, "Repeat boundary validation under `OPS-23`": `invalid_request` with
      `details.field: "/acknowledge_purchase"`, `retryable: false` on the error and operation view, `failed`, commitment
      released in full with no setup-fee or first-unit debit, this create's settlement freeing
      that same held resource-offer exclusion (`STO-58`), and no provider request at all,
      including no List offers read.
```

### Replace: CNF-364 setup and retained list-offers assertions — `10-conformance-checklist.md:140–154` at the pin

```markdown
- [ ] **CNF-364** — **The claim-time List offers read is gated on `list_offers`.** Admit a
      complete resource-offer (`offer_is_resource`) create on an account that declares
      `list_offers` and the ordering capability, with `allow_orders: true` and the request
      carrying `acknowledge_purchase: true`. Assert this create's exclusion for its provider
      account, ordering channel and offer id is held at admission (`PRV-42`, `STO-58`).
      While it is still queued and unclaimed, restart with a descriptor for that account that
      removes only `list_offers`, keeping the ordering capability declared and the driver's
      List offers code path answering, so the test proves the gate exists, as `CNF-19` does. Assert the worker
      refuses the create at `OPS-43`'s step 4: `unsupported` with `details.provider_account`
      naming the account and `details.capability: "list_offers"`, `retryable: false` on both the
      error and the operation view, no `details.refusals` or `details.not_checked`, `failed`, the
      commitment released in full with no setup-fee or first-unit debit, this create's settlement
      freeing that same held resource-offer exclusion (`STO-58`), and no List offers read,
      per-order key upload or order request. (`DOM-10`, `OPS-43`, `OPS-11`, `LDG-39`, `WIR-9a`,
      `WIR-9b`)
      *Amended 2026-10-22 (`pv-009`; panel r62, `docs/research/panels-2026-10/r62/`): applied the reviewed claim-time capability gate and refusal checks.*
```

### Retain verbatim: CNF-344 channel declaration is no capability grant — `10-conformance-checklist.md:4358–4363` at the pin

```markdown
- [ ] **CNF-344** — **Amended 2026-10-12 (`ADR-0037`, Q28).** **Each channel declares its own order budget.** Enumerate the
      descriptor's ordering channels and assert each has a positive `limit` and finite,
      positive `per`; no top-level `order_budget` substitutes for a missing channel
      entry. Verify the declared limit documents capacity; Robot's reported `403 RATE_LIMIT_EXCEEDED` raises `PRV-5`'s alarm naming account and request path (and channel where useful) and closes the local gate. No local request count raises that alarm.
      Another channel's mere declaration authorizes no new ordering capability.
      (`PRV-44`, `PRV-40`, `DOM-10`)
```


## Form B — Self-contained scope at each use, existing checks

This is a complete landing form. The blocks below are all its replacements and explicitly retained direct dependents. Historical amendment paragraphs outside the printed replacement ranges stay as pinned; no new decision record is being proposed.

### Replace: DOM-16 — `01-domain-model.md:570–571` at the pin

```markdown
**DOM-16** For each provider account, an ordering capability (`provision_virtual` or
`provision_bare_metal`) that permits a create that starts new provider billing to the operator,
whether an upfront charge or hourly or other recurring machine rental, MUST be conditional on
an explicit per-account `allow_orders` configuration flag. Neither a setup fee nor immediate
payment is required for this condition to apply. The descriptor (`PRV-44`) of an account whose
flag is false does not declare that capability, so that a misconfigured deployment cannot start
that billing. This is in addition to the per-request purchase acknowledgement (`API-15`).
```

### Replace: PRV-10 — `02-provider-contract.md:159–162` at the pin

```markdown
**PRV-10** For a create that starts new provider billing to the operator, whether an
upfront charge or hourly or other recurring machine rental, create MUST reject the request unless
the request carries an explicit purchase acknowledgement (`WIR-17`'s top-level
`acknowledge_purchase`), *and* the account is configured to allow ordering. Neither a setup fee nor
immediate payment is required for this condition to apply. Both, not either. The configuration
half is `DOM-10`'s gate on the create's ordering capability (`DOM-16`): `API-7`'s step 5d at
admission and `OPS-43`'s step 3 at claim.
```

### Replace: API-15 — `04-api-contract.md:987–992` at the pin

```markdown
**API-15** A request for a create that starts new provider billing to the operator,
whether an upfront charge or hourly or other recurring machine rental, MUST carry an explicit
purchase acknowledgement — `WIR-17`'s top-level `acknowledge_purchase`, which the wire contract
owns — in addition to the account being configured to allow ordering (`PRV-10`). Neither a setup
fee nor immediate payment is required for this condition to apply. *"In its provider options"
until 2026-09-05, while `WIR-17` placed it at the top level; the wire contract wins, and a spending
authorization nested inside a driver-private object is one a strict server could not tell from
any other option.*
```

### Replace: configuration row — `00-overview.md:412–412` at the pin

```markdown
| `allow_orders`, per provider account with an ordering capability that permits a create that starts new provider billing to the operator, whether an upfront charge or hourly or other recurring machine rental, without requiring a setup fee or immediate payment | `DOM-16` | boolean | yes |
```

### Replace: Create matrix row — `08-provider-notes.md:31–31` at the pin

```markdown
| Create | see `DOM-16` | see `DOM-16` | see `DOM-16` |
```

### Replace: DEF-17 historical scope paragraph — `09-known-defects.md:163–165` at the pin

```markdown
Requeue re-executed the original request verbatim. For a create that starts new provider billing
to the operator, whether an upfront charge or hourly or other recurring machine rental, that is a
second purchase, gated by nothing beyond the same tenant token that placed the first one. Neither
a setup fee nor immediate payment is required for this condition to apply.
```

### Replace: WIR-17 field rules opening — `13-wire-contract.md:665–666` at the pin

```markdown
`ssh_public_keys` MUST be non-empty (`PRV-8`, `API-13`). For a create that starts new provider
billing to the operator, whether an upfront charge or hourly or other recurring machine rental,
`acknowledge_purchase` MUST be literal `true` (`API-15`, `PRV-10`); neither a setup fee nor immediate
payment is required for this condition to apply. `image` (nullable, a catalog identifier), `user_data` (nullable,
```

### Retain verbatim: CNF-18 — `10-conformance-checklist.md:124–135` at the pin

```markdown
- [ ] **CNF-18** — **AMENDED 2026-09-08 (`ADR-0018`) — the table is `DOM-10`'s, and the descriptor's
      fields are rows too.** For every driver, every declared capability has a working code path,
      and every implemented operation with a capability entry in `DOM-10`'s table has its
      capability declared. Table-driven over that table, one case per (driver, capability) pair;
      the three capability-less methods are `CNF-20`'s and are not rows here. **Then iterate the
      descriptor** (`PRV-44`), one case per (driver, field): a declared value has a working code
      path behind it — a declared ordering channel is searched, a declared evidence source is read,
      a declared surviving attachment kind is listed, and each ordering channel carries
      its own validated `order_budget` — and a field with nothing to declare says so
      explicitly rather than being absent. An ordering capability withheld under `DOM-16` is outside the implemented-implies-declared rows for that account; `CNF-19` and `CNF-55` cover its gate. (`DOM-15`, `DOM-10`, `PRV-4`, `PRV-44`)
      *Amended 2026-10-09 (`ADR-0036`): the order-budget field is iterated per channel.*
      *Amended 2026-10-22 (`pv-p3k`; panel r62, `docs/research/panels-2026-10/r62/`; owner decision 2026-10-22): applied the reviewed ordering-capability change.*
```

### Retain verbatim: CNF-19 — `10-conformance-checklist.md:137–139` at the pin

```markdown
- [ ] **CNF-19** — Create is refused when the provider has not declared the matching
      provision capability — with the driver's internal ordering flag set to permissive,
      so the test proves the outer gate exists. (`DOM-10`, `DEF-10`)
```

### Replace: CNF-34 — `10-conformance-checklist.md:256–279` at the pin

```markdown
- [ ] **CNF-34** — Validation is enforced in the worker even when the stored request bypasses
      the API layer. Use creates that start new provider billing to the operator, whether an
      upfront charge or hourly or other recurring machine rental. Neither a setup fee nor
      immediate payment is required for this condition to apply. On separate such creates,
      store records missing a caller-supplied field —
      `acknowledge_purchase` (`WIR-17`: "`acknowledge_purchase` MUST be literal `true`") — and
      an api-filled admission field, using the accepted-price fields in `request_summary`
      (`OPS-43`: "the accepted recurring price, its currency and its period"). For the caller field assert `invalid_request` with
      `details.field: "/acknowledge_purchase"` and `retryable: false`; for the api-filled
      field assert `conflict`, `details.reason: "incomplete_record"` and `retryable: true`.
      Assert the same kind, applicable reason and `retryable` on the error and the operation
      view (`WIR-9b`), `failed`, no driver call, and the create's commitment released in full
      with no setup-fee or first-unit debit.
      Repeat the caller-field case on an install, using `API-14`'s "explicit destructive
      acknowledgement". Assert `invalid_request` with `details.field: "/acknowledge_destruction"` and `retryable: false`
      on the error and view, `failed`, no driver call, both marker columns still null,
      `disk_effect: "none"` and `rescue_exit: "none"`. The install fixture uses that caller
      acknowledgement; an api-filled install case applies only if the release names a field the
      `api` writes at install admission, and the fixture must identify that field. It asserts
      `conflict`/`incomplete_record`, `retryable: true` and the same untouched-install outcome.
      Complete-record controls on create and install proceed. (`OPS-23`, `OPS-43`, `API-14`,
      `WIR-17`, `WIR-9a`, `WIR-9b`, `OPS-11`, `OPS-45`, `LDG-39`)
      *Amended 2026-10-17 (`pv-14b`; panel r55, `docs/research/panels-2026-10/r55/`):
      added missing-field fixtures, error/view agreement, commitment release,
      install marker outcomes and complete-record controls.*

      *Amended 2026-10-22 (`pv-ss4`; panel r62, `docs/research/panels-2026-10/r62/`): applied the reviewed field-pointer form and validation ordering.*
```

### Replace: CNF-55 — `10-conformance-checklist.md:340–359` at the pin

```markdown
- [ ] **CNF-55** — A create that starts new provider billing to the operator, whether an
      upfront charge or hourly or other recurring machine rental, is rejected without both the
      per-request purchase acknowledgement and the account-level opt-in. Neither a setup fee nor
      immediate payment is required for this condition to apply. On an account whose
      `allow_orders` is false, assert `GET /v1/providers` lists it without its ordering
      capability, and that a create carrying `acknowledge_purchase: true` is refused at `API-7`'s
      step 5d: HTTP `501`, `unsupported`, `details.provider_account` and `details.capability`
      naming the account and that capability, `retryable: false`, and, with a balance too low for
      the create, no `details.refusals` or `details.not_checked` and no operation or commitment.
      A same-key, same-body replay of a create admitted before the flag was turned off returns its
      stored result. Admit a complete resource-offer (`offer_is_resource`) create with
      `allow_orders` true, and assert this create's exclusion for its provider account, ordering
      channel and offer id is held at admission (`PRV-42`, `STO-58`). While it is still queued
      and unclaimed, restart with only that flag changed to false, and assert the worker
      refuses it at `OPS-43`'s step 3 with the same kind, `details`
      and `retryable: false` on both the error and the operation view, `failed`, the commitment
      released in full with no setup-fee or first-unit debit, this create's settlement freeing
      that same held resource-offer exclusion (`STO-58`), and no provider request, including
      no List offers read. (`API-15`, `PRV-10`, `DOM-10`, `DOM-16`, `API-7`, `OPS-43`, `WIR-9a`,
      `WIR-9b`, `LDG-39`)

      *Amended 2026-10-22 (`pv-p3k`; panel r62, `docs/research/panels-2026-10/r62/`; owner decision 2026-10-22): applied the reviewed ordering-capability change.*
```

### Retain verbatim: CNF-182 Robot test-mode case — `10-conformance-checklist.md:2371–2376` at the pin

```markdown
- [ ] **CNF-182** — The Robot driver's order test flag **defaults to test mode**, and a real
      purchase requires an explicit spend intent that is set exactly once, where `API-15`'s
      acknowledgement and `PRV-10`'s `allow_orders` both hold. Asserted by placing an order with
      the acknowledgement absent and confirming the API returns a `Cancelled` transaction and no
      server. **A driver defaulting to "real purchase" turns every mistaken conformance run into a
      bought server.** (`PRV-34`, `API-15`, `PRV-10`)
```

### Replace: CNF-342 acknowledgement paragraph — `10-conformance-checklist.md:4311–4320` at the pin

```markdown
      Separately omit the caller-supplied purchase acknowledgement from the stored record:
      admit a complete, valid resource-offer (`offer_is_resource`) create that starts new provider
      billing to the operator, whether an upfront charge or hourly or other recurring machine
      rental; neither a setup fee nor immediate payment is required for this condition to apply. Assert this
      create's exclusion for its provider account, ordering channel and offer id is held at
      admission (`PRV-42`, `STO-58`), then remove only the stored caller-supplied acknowledgement
      before worker claim and validation (`OPS-23`). Assert rejection at
      `OPS-43`'s step 3, "Repeat boundary validation under `OPS-23`": `invalid_request` with
      `details.field: "/acknowledge_purchase"`, `retryable: false` on the error and operation view, `failed`, commitment
      released in full with no setup-fee or first-unit debit, this create's settlement freeing
      that same held resource-offer exclusion (`STO-58`), and no provider request at all,
      including no List offers read.
```

### Replace: CNF-364 setup and retained list-offers assertions — `10-conformance-checklist.md:140–154` at the pin

```markdown
- [ ] **CNF-364** — **The claim-time List offers read is gated on `list_offers`.** Admit a
      complete resource-offer (`offer_is_resource`) create on an account that declares
      `list_offers` and the ordering capability, with `allow_orders: true` and the request
      carrying `acknowledge_purchase: true`. Assert this create's exclusion for its provider
      account, ordering channel and offer id is held at admission (`PRV-42`, `STO-58`).
      While it is still queued and unclaimed, restart with a descriptor for that account that
      removes only `list_offers`, keeping the ordering capability declared and the driver's
      List offers code path answering, so the test proves the gate exists, as `CNF-19` does. Assert the worker
      refuses the create at `OPS-43`'s step 4: `unsupported` with `details.provider_account`
      naming the account and `details.capability: "list_offers"`, `retryable: false` on both the
      error and the operation view, no `details.refusals` or `details.not_checked`, `failed`, the
      commitment released in full with no setup-fee or first-unit debit, this create's settlement
      freeing that same held resource-offer exclusion (`STO-58`), and no List offers read,
      per-order key upload or order request. (`DOM-10`, `OPS-43`, `OPS-11`, `LDG-39`, `WIR-9a`,
      `WIR-9b`)
      *Amended 2026-10-22 (`pv-009`; panel r62, `docs/research/panels-2026-10/r62/`): applied the reviewed claim-time capability gate and refusal checks.*
```

### Retain verbatim: CNF-344 channel declaration is no capability grant — `10-conformance-checklist.md:4358–4363` at the pin

```markdown
- [ ] **CNF-344** — **Amended 2026-10-12 (`ADR-0037`, Q28).** **Each channel declares its own order budget.** Enumerate the
      descriptor's ordering channels and assert each has a positive `limit` and finite,
      positive `per`; no top-level `order_budget` substitutes for a missing channel
      entry. Verify the declared limit documents capacity; Robot's reported `403 RATE_LIMIT_EXCEEDED` raises `PRV-5`'s alarm naming account and request path (and channel where useful) and closes the local gate. No local request count raises that alarm.
      Another channel's mere declaration authorizes no new ordering capability.
      (`PRV-44`, `PRV-40`, `DOM-10`)
```


## Form C — One defined scope, explicit hourly-cloud checks

This is a complete landing form. The blocks below are all its replacements and explicitly retained direct dependents. Historical amendment paragraphs outside the printed replacement ranges stay as pinned; no new decision record is being proposed.

### Replace: DOM-16 — `01-domain-model.md:570–571` at the pin

```markdown
**DOM-16** A **paid create** is a create that starts new provider billing to the
operator, whether an upfront charge or hourly or other recurring machine rental; neither a
setup fee nor immediate payment is required. For each provider account, an ordering capability
(`provision_virtual` or `provision_bare_metal`) that permits a paid create MUST be conditional
on an explicit per-account `allow_orders` configuration flag: the descriptor (`PRV-44`) of an
account whose flag is false does not declare that capability, so that a misconfigured deployment
cannot start that billing. This is in addition to the per-request purchase acknowledgement
(`API-15`).
```

### Replace: PRV-10 — `02-provider-contract.md:159–162` at the pin

```markdown
**PRV-10** For a paid create (`DOM-16`), create MUST reject the request unless the
request carries an explicit purchase acknowledgement (`WIR-17`'s top-level
`acknowledge_purchase`), *and* the account is configured to allow ordering. Both, not either.
The configuration half is `DOM-10`'s gate on the create's ordering capability (`DOM-16`):
`API-7`'s step 5d at admission and `OPS-43`'s step 3 at claim.
```

### Replace: API-15 — `04-api-contract.md:987–992` at the pin

```markdown
**API-15** A paid create request (`DOM-16`) MUST carry an explicit purchase
acknowledgement — `WIR-17`'s top-level `acknowledge_purchase`, which the wire contract
owns — in addition to the account being configured to allow ordering (`PRV-10`). *"In its provider
options" until 2026-09-05, while `WIR-17` placed it at the top level; the wire contract wins, and a
spending authorization nested inside a driver-private object is one a strict server could not tell
from any other option.*
```

### Replace: configuration row — `00-overview.md:412–412` at the pin

```markdown
| `allow_orders`, per provider account with an ordering capability that permits a paid create (`DOM-16`) | `DOM-16` | boolean | yes |
```

### Replace: Create matrix row — `08-provider-notes.md:31–31` at the pin

```markdown
| Create | see `DOM-16` | see `DOM-16` | see `DOM-16` |
```

### Replace: DEF-17 historical scope paragraph — `09-known-defects.md:163–165` at the pin

```markdown
Requeue re-executed the original request verbatim. For a paid create (`DOM-16`), that is a
second purchase, gated by nothing beyond the same tenant token that placed the first one.
```

### Replace: WIR-17 field rules opening — `13-wire-contract.md:665–666` at the pin

```markdown
`ssh_public_keys` MUST be non-empty (`PRV-8`, `API-13`). For a paid create (`DOM-16`),
`acknowledge_purchase` MUST be literal `true` (`API-15`, `PRV-10`). `image` (nullable, a catalog identifier), `user_data` (nullable,
```

### Retain verbatim: CNF-18 — `10-conformance-checklist.md:124–135` at the pin

```markdown
- [ ] **CNF-18** — **AMENDED 2026-09-08 (`ADR-0018`) — the table is `DOM-10`'s, and the descriptor's
      fields are rows too.** For every driver, every declared capability has a working code path,
      and every implemented operation with a capability entry in `DOM-10`'s table has its
      capability declared. Table-driven over that table, one case per (driver, capability) pair;
      the three capability-less methods are `CNF-20`'s and are not rows here. **Then iterate the
      descriptor** (`PRV-44`), one case per (driver, field): a declared value has a working code
      path behind it — a declared ordering channel is searched, a declared evidence source is read,
      a declared surviving attachment kind is listed, and each ordering channel carries
      its own validated `order_budget` — and a field with nothing to declare says so
      explicitly rather than being absent. An ordering capability withheld under `DOM-16` is outside the implemented-implies-declared rows for that account; `CNF-19` and `CNF-55` cover its gate. (`DOM-15`, `DOM-10`, `PRV-4`, `PRV-44`)
      *Amended 2026-10-09 (`ADR-0036`): the order-budget field is iterated per channel.*
      *Amended 2026-10-22 (`pv-p3k`; panel r62, `docs/research/panels-2026-10/r62/`; owner decision 2026-10-22): applied the reviewed ordering-capability change.*
```

### Retain verbatim: CNF-19 — `10-conformance-checklist.md:137–139` at the pin

```markdown
- [ ] **CNF-19** — Create is refused when the provider has not declared the matching
      provision capability — with the driver's internal ordering flag set to permissive,
      so the test proves the outer gate exists. (`DOM-10`, `DEF-10`)
```

### Replace: CNF-34 — `10-conformance-checklist.md:256–279` at the pin

```markdown
- [ ] **CNF-34** — Validation is enforced in the worker even when the stored request bypasses
      the API layer. On separate paid creates (`DOM-16`), store records missing a caller-supplied field —
      `acknowledge_purchase` (`WIR-17`: "`acknowledge_purchase` MUST be literal `true`") — and
      an api-filled admission field, using the accepted-price fields in `request_summary`
      (`OPS-43`: "the accepted recurring price, its currency and its period"). For the caller field assert `invalid_request` with
      `details.field: "/acknowledge_purchase"` and `retryable: false`; for the api-filled
      field assert `conflict`, `details.reason: "incomplete_record"` and `retryable: true`.
      Assert the same kind, applicable reason and `retryable` on the error and the operation
      view (`WIR-9b`), `failed`, no driver call, and the create's commitment released in full
      with no setup-fee or first-unit debit.
      Repeat the caller-field case on an install, using `API-14`'s "explicit destructive
      acknowledgement". Assert `invalid_request` with `details.field: "/acknowledge_destruction"` and `retryable: false`
      on the error and view, `failed`, no driver call, both marker columns still null,
      `disk_effect: "none"` and `rescue_exit: "none"`. The install fixture uses that caller
      acknowledgement; an api-filled install case applies only if the release names a field the
      `api` writes at install admission, and the fixture must identify that field. It asserts
      `conflict`/`incomplete_record`, `retryable: true` and the same untouched-install outcome.
      Complete-record controls on create and install proceed. (`OPS-23`, `OPS-43`, `API-14`,
      `WIR-17`, `WIR-9a`, `WIR-9b`, `OPS-11`, `OPS-45`, `LDG-39`)
      *Amended 2026-10-17 (`pv-14b`; panel r55, `docs/research/panels-2026-10/r55/`):
      added missing-field fixtures, error/view agreement, commitment release,
      install marker outcomes and complete-record controls.*

      *Amended 2026-10-22 (`pv-ss4`; panel r62, `docs/research/panels-2026-10/r62/`): applied the reviewed field-pointer form and validation ordering.*
```

### Replace: CNF-55 — `10-conformance-checklist.md:340–359` at the pin

```markdown
- [ ] **CNF-55** — A paid create (`DOM-16`) is rejected without both the
      per-request purchase acknowledgement and the account-level opt-in. On an account whose
      `allow_orders` is false, assert `GET /v1/providers` lists it without its ordering
      capability, and that a create carrying `acknowledge_purchase: true` is refused at `API-7`'s
      step 5d: HTTP `501`, `unsupported`, `details.provider_account` and `details.capability`
      naming the account and that capability, `retryable: false`, and, with a balance too low for
      the create, no `details.refusals` or `details.not_checked` and no operation or commitment.
      A same-key, same-body replay of a create admitted before the flag was turned off returns its
      stored result. Admit a complete resource-offer (`offer_is_resource`) create with
      `allow_orders` true, and assert this create's exclusion for its provider account, ordering
      channel and offer id is held at admission (`PRV-42`, `STO-58`). While it is still queued
      and unclaimed, restart with only that flag changed to false, and assert the worker
      refuses it at `OPS-43`'s step 3 with the same kind, `details`
      and `retryable: false` on both the error and the operation view, `failed`, the commitment
      released in full with no setup-fee or first-unit debit, this create's settlement freeing
      that same held resource-offer exclusion (`STO-58`), and no provider request, including
      no List offers read. (`API-15`, `PRV-10`, `DOM-10`, `DOM-16`, `API-7`, `OPS-43`, `WIR-9a`,
      `WIR-9b`, `LDG-39`)

      **Hourly cloud cases.** Each admission case uses a fresh idempotency key. Use an
      otherwise valid, sellable hourly cloud catalogue offer
      with a positive recurring provider price and no setup fee, on a healthy assigned provider
      account implementing `provision_virtual`. Keep all unrelated sale, price, balance and
      admission conditions satisfied in the fixture. The driver is internally permissive and
      would start hourly billing if its create method were called; count its create calls and
      simulated billing starts. This fixture supplies the sale evidence needed for the test;
      it does not authorize sale of a live offer withheld under `PRV-13b` or `PRV-31`.
      With `allow_orders: false` and `acknowledge_purchase: true`, assert the provider listing
      omits `provision_virtual` and a fresh-key create fails at `API-7`'s step 5d with HTTP `501`,
      `unsupported`, `details.provider_account` naming that account,
      `details.capability: "provision_virtual"`, and `retryable: false`. Assert no operation,
      commitment or provider request, zero driver create calls and zero simulated billing starts.
      With `allow_orders: true`, separately omit `acknowledge_purchase` and set it to `false`.
      Each request fails HTTP `400`, `invalid_request`, `details.field: "/acknowledge_purchase"`,
      `retryable: false`, without an operation, commitment or provider request, and with zero
      driver create calls and zero simulated billing starts. A fresh-key control with both
      `allow_orders: true` and `acknowledge_purchase: true` reaches the fixture driver's create
      exactly once and records exactly one simulated hourly billing start.
      Separately admit this hourly catalogue create while both are true; while queued and
      unclaimed, restart with only `allow_orders` changed to false. Assert rejection at
      `OPS-43`'s step 3 with `unsupported`, the same account and capability details and
      `retryable: false` on both the error and operation view, `failed`, commitment released in
      full with no setup-fee or first-unit debit, no provider request including no List offers
      read, zero driver create calls and zero simulated billing starts. This catalogue offer
      holds no resource-offer exclusion. On a separate admitted hourly create with
      `allow_orders: true`, remove only its stored `acknowledge_purchase` before claim. Assert
      `OPS-43`'s step-3 `invalid_request`, `details.field: "/acknowledge_purchase"`,
      `retryable: false` on the error and view, `failed`, full commitment release with no
      setup-fee or first-unit debit, no provider request including no List offers read, zero
      driver create calls and zero simulated billing starts. (`WIR-17`, `OPS-23`, `OPS-11`)

      *Amended 2026-10-22 (`pv-p3k`; panel r62, `docs/research/panels-2026-10/r62/`; owner decision 2026-10-22): applied the reviewed ordering-capability change.*
```

### Retain verbatim: CNF-182 Robot test-mode case — `10-conformance-checklist.md:2371–2376` at the pin

```markdown
- [ ] **CNF-182** — The Robot driver's order test flag **defaults to test mode**, and a real
      purchase requires an explicit spend intent that is set exactly once, where `API-15`'s
      acknowledgement and `PRV-10`'s `allow_orders` both hold. Asserted by placing an order with
      the acknowledgement absent and confirming the API returns a `Cancelled` transaction and no
      server. **A driver defaulting to "real purchase" turns every mistaken conformance run into a
      bought server.** (`PRV-34`, `API-15`, `PRV-10`)
```

### Replace: CNF-342 acknowledgement paragraph — `10-conformance-checklist.md:4311–4320` at the pin

```markdown
      Separately omit the caller-supplied purchase acknowledgement from the stored record:
      admit a complete, valid paid resource-offer (`offer_is_resource`) create (`DOM-16`) and assert this
      create's exclusion for its provider account, ordering channel and offer id is held at
      admission (`PRV-42`, `STO-58`), then remove only the stored caller-supplied acknowledgement
      before worker claim and validation (`OPS-23`). Assert rejection at
      `OPS-43`'s step 3, "Repeat boundary validation under `OPS-23`": `invalid_request` with
      `details.field: "/acknowledge_purchase"`, `retryable: false` on the error and operation view, `failed`, commitment
      released in full with no setup-fee or first-unit debit, this create's settlement freeing
      that same held resource-offer exclusion (`STO-58`), and no provider request at all,
      including no List offers read.
```

### Replace: CNF-364 setup and retained list-offers assertions — `10-conformance-checklist.md:140–154` at the pin

```markdown
- [ ] **CNF-364** — **The claim-time List offers read is gated on `list_offers`.** Admit a
      complete resource-offer (`offer_is_resource`) create on an account that declares
      `list_offers` and the ordering capability, with `allow_orders: true` and the request
      carrying `acknowledge_purchase: true`. Assert this create's exclusion for its provider
      account, ordering channel and offer id is held at admission (`PRV-42`, `STO-58`).
      While it is still queued and unclaimed, restart with a descriptor for that account that
      removes only `list_offers`, keeping the ordering capability declared and the driver's
      List offers code path answering, so the test proves the gate exists, as `CNF-19` does. Assert the worker
      refuses the create at `OPS-43`'s step 4: `unsupported` with `details.provider_account`
      naming the account and `details.capability: "list_offers"`, `retryable: false` on both the
      error and the operation view, no `details.refusals` or `details.not_checked`, `failed`, the
      commitment released in full with no setup-fee or first-unit debit, this create's settlement
      freeing that same held resource-offer exclusion (`STO-58`), and no List offers read,
      per-order key upload or order request. (`DOM-10`, `OPS-43`, `OPS-11`, `LDG-39`, `WIR-9a`,
      `WIR-9b`)
      *Amended 2026-10-22 (`pv-009`; panel r62, `docs/research/panels-2026-10/r62/`): applied the reviewed claim-time capability gate and refusal checks.*
```

### Retain verbatim: CNF-344 channel declaration is no capability grant — `10-conformance-checklist.md:4358–4363` at the pin

```markdown
- [ ] **CNF-344** — **Amended 2026-10-12 (`ADR-0037`, Q28).** **Each channel declares its own order budget.** Enumerate the
      descriptor's ordering channels and assert each has a positive `limit` and finite,
      positive `per`; no top-level `order_budget` substitutes for a missing channel
      entry. Verify the declared limit documents capacity; Robot's reported `403 RATE_LIMIT_EXCEEDED` raises `PRV-5`'s alarm naming account and request path (and channel where useful) and closes the local gate. No local request count raises that alarm.
      Another channel's mere declaration authorizes no new ordering capability.
      (`PRV-44`, `PRV-40`, `DOM-10`)
```


## Form D — Self-contained scope at each use, explicit hourly-cloud checks

This is a complete landing form. The blocks below are all its replacements and explicitly retained direct dependents. Historical amendment paragraphs outside the printed replacement ranges stay as pinned; no new decision record is being proposed.

### Replace: DOM-16 — `01-domain-model.md:570–571` at the pin

```markdown
**DOM-16** For each provider account, an ordering capability (`provision_virtual` or
`provision_bare_metal`) that permits a create that starts new provider billing to the operator,
whether an upfront charge or hourly or other recurring machine rental, MUST be conditional on
an explicit per-account `allow_orders` configuration flag. Neither a setup fee nor immediate
payment is required for this condition to apply. The descriptor (`PRV-44`) of an account whose
flag is false does not declare that capability, so that a misconfigured deployment cannot start
that billing. This is in addition to the per-request purchase acknowledgement (`API-15`).
```

### Replace: PRV-10 — `02-provider-contract.md:159–162` at the pin

```markdown
**PRV-10** For a create that starts new provider billing to the operator, whether an
upfront charge or hourly or other recurring machine rental, create MUST reject the request unless
the request carries an explicit purchase acknowledgement (`WIR-17`'s top-level
`acknowledge_purchase`), *and* the account is configured to allow ordering. Neither a setup fee nor
immediate payment is required for this condition to apply. Both, not either. The configuration
half is `DOM-10`'s gate on the create's ordering capability (`DOM-16`): `API-7`'s step 5d at
admission and `OPS-43`'s step 3 at claim.
```

### Replace: API-15 — `04-api-contract.md:987–992` at the pin

```markdown
**API-15** A request for a create that starts new provider billing to the operator,
whether an upfront charge or hourly or other recurring machine rental, MUST carry an explicit
purchase acknowledgement — `WIR-17`'s top-level `acknowledge_purchase`, which the wire contract
owns — in addition to the account being configured to allow ordering (`PRV-10`). Neither a setup
fee nor immediate payment is required for this condition to apply. *"In its provider options"
until 2026-09-05, while `WIR-17` placed it at the top level; the wire contract wins, and a spending
authorization nested inside a driver-private object is one a strict server could not tell from
any other option.*
```

### Replace: configuration row — `00-overview.md:412–412` at the pin

```markdown
| `allow_orders`, per provider account with an ordering capability that permits a create that starts new provider billing to the operator, whether an upfront charge or hourly or other recurring machine rental, without requiring a setup fee or immediate payment | `DOM-16` | boolean | yes |
```

### Replace: Create matrix row — `08-provider-notes.md:31–31` at the pin

```markdown
| Create | see `DOM-16` | see `DOM-16` | see `DOM-16` |
```

### Replace: DEF-17 historical scope paragraph — `09-known-defects.md:163–165` at the pin

```markdown
Requeue re-executed the original request verbatim. For a create that starts new provider billing
to the operator, whether an upfront charge or hourly or other recurring machine rental, that is a
second purchase, gated by nothing beyond the same tenant token that placed the first one. Neither
a setup fee nor immediate payment is required for this condition to apply.
```

### Replace: WIR-17 field rules opening — `13-wire-contract.md:665–666` at the pin

```markdown
`ssh_public_keys` MUST be non-empty (`PRV-8`, `API-13`). For a create that starts new provider
billing to the operator, whether an upfront charge or hourly or other recurring machine rental,
`acknowledge_purchase` MUST be literal `true` (`API-15`, `PRV-10`); neither a setup fee nor immediate
payment is required for this condition to apply. `image` (nullable, a catalog identifier), `user_data` (nullable,
```

### Retain verbatim: CNF-18 — `10-conformance-checklist.md:124–135` at the pin

```markdown
- [ ] **CNF-18** — **AMENDED 2026-09-08 (`ADR-0018`) — the table is `DOM-10`'s, and the descriptor's
      fields are rows too.** For every driver, every declared capability has a working code path,
      and every implemented operation with a capability entry in `DOM-10`'s table has its
      capability declared. Table-driven over that table, one case per (driver, capability) pair;
      the three capability-less methods are `CNF-20`'s and are not rows here. **Then iterate the
      descriptor** (`PRV-44`), one case per (driver, field): a declared value has a working code
      path behind it — a declared ordering channel is searched, a declared evidence source is read,
      a declared surviving attachment kind is listed, and each ordering channel carries
      its own validated `order_budget` — and a field with nothing to declare says so
      explicitly rather than being absent. An ordering capability withheld under `DOM-16` is outside the implemented-implies-declared rows for that account; `CNF-19` and `CNF-55` cover its gate. (`DOM-15`, `DOM-10`, `PRV-4`, `PRV-44`)
      *Amended 2026-10-09 (`ADR-0036`): the order-budget field is iterated per channel.*
      *Amended 2026-10-22 (`pv-p3k`; panel r62, `docs/research/panels-2026-10/r62/`; owner decision 2026-10-22): applied the reviewed ordering-capability change.*
```

### Retain verbatim: CNF-19 — `10-conformance-checklist.md:137–139` at the pin

```markdown
- [ ] **CNF-19** — Create is refused when the provider has not declared the matching
      provision capability — with the driver's internal ordering flag set to permissive,
      so the test proves the outer gate exists. (`DOM-10`, `DEF-10`)
```

### Replace: CNF-34 — `10-conformance-checklist.md:256–279` at the pin

```markdown
- [ ] **CNF-34** — Validation is enforced in the worker even when the stored request bypasses
      the API layer. Use creates that start new provider billing to the operator, whether an
      upfront charge or hourly or other recurring machine rental. Neither a setup fee nor
      immediate payment is required for this condition to apply. On separate such creates,
      store records missing a caller-supplied field —
      `acknowledge_purchase` (`WIR-17`: "`acknowledge_purchase` MUST be literal `true`") — and
      an api-filled admission field, using the accepted-price fields in `request_summary`
      (`OPS-43`: "the accepted recurring price, its currency and its period"). For the caller field assert `invalid_request` with
      `details.field: "/acknowledge_purchase"` and `retryable: false`; for the api-filled
      field assert `conflict`, `details.reason: "incomplete_record"` and `retryable: true`.
      Assert the same kind, applicable reason and `retryable` on the error and the operation
      view (`WIR-9b`), `failed`, no driver call, and the create's commitment released in full
      with no setup-fee or first-unit debit.
      Repeat the caller-field case on an install, using `API-14`'s "explicit destructive
      acknowledgement". Assert `invalid_request` with `details.field: "/acknowledge_destruction"` and `retryable: false`
      on the error and view, `failed`, no driver call, both marker columns still null,
      `disk_effect: "none"` and `rescue_exit: "none"`. The install fixture uses that caller
      acknowledgement; an api-filled install case applies only if the release names a field the
      `api` writes at install admission, and the fixture must identify that field. It asserts
      `conflict`/`incomplete_record`, `retryable: true` and the same untouched-install outcome.
      Complete-record controls on create and install proceed. (`OPS-23`, `OPS-43`, `API-14`,
      `WIR-17`, `WIR-9a`, `WIR-9b`, `OPS-11`, `OPS-45`, `LDG-39`)
      *Amended 2026-10-17 (`pv-14b`; panel r55, `docs/research/panels-2026-10/r55/`):
      added missing-field fixtures, error/view agreement, commitment release,
      install marker outcomes and complete-record controls.*

      *Amended 2026-10-22 (`pv-ss4`; panel r62, `docs/research/panels-2026-10/r62/`): applied the reviewed field-pointer form and validation ordering.*
```

### Replace: CNF-55 — `10-conformance-checklist.md:340–359` at the pin

```markdown
- [ ] **CNF-55** — A create that starts new provider billing to the operator, whether an
      upfront charge or hourly or other recurring machine rental, is rejected without both the
      per-request purchase acknowledgement and the account-level opt-in. Neither a setup fee nor
      immediate payment is required for this condition to apply. On an account whose
      `allow_orders` is false, assert `GET /v1/providers` lists it without its ordering
      capability, and that a create carrying `acknowledge_purchase: true` is refused at `API-7`'s
      step 5d: HTTP `501`, `unsupported`, `details.provider_account` and `details.capability`
      naming the account and that capability, `retryable: false`, and, with a balance too low for
      the create, no `details.refusals` or `details.not_checked` and no operation or commitment.
      A same-key, same-body replay of a create admitted before the flag was turned off returns its
      stored result. Admit a complete resource-offer (`offer_is_resource`) create with
      `allow_orders` true, and assert this create's exclusion for its provider account, ordering
      channel and offer id is held at admission (`PRV-42`, `STO-58`). While it is still queued
      and unclaimed, restart with only that flag changed to false, and assert the worker
      refuses it at `OPS-43`'s step 3 with the same kind, `details`
      and `retryable: false` on both the error and the operation view, `failed`, the commitment
      released in full with no setup-fee or first-unit debit, this create's settlement freeing
      that same held resource-offer exclusion (`STO-58`), and no provider request, including
      no List offers read. (`API-15`, `PRV-10`, `DOM-10`, `DOM-16`, `API-7`, `OPS-43`, `WIR-9a`,
      `WIR-9b`, `LDG-39`)

      **Hourly cloud cases.** Each admission case uses a fresh idempotency key. Use an
      otherwise valid, sellable hourly cloud catalogue offer
      with a positive recurring provider price and no setup fee, on a healthy assigned provider
      account implementing `provision_virtual`. Keep all unrelated sale, price, balance and
      admission conditions satisfied in the fixture. The driver is internally permissive and
      would start hourly billing if its create method were called; count its create calls and
      simulated billing starts. This fixture supplies the sale evidence needed for the test;
      it does not authorize sale of a live offer withheld under `PRV-13b` or `PRV-31`.
      With `allow_orders: false` and `acknowledge_purchase: true`, assert the provider listing
      omits `provision_virtual` and a fresh-key create fails at `API-7`'s step 5d with HTTP `501`,
      `unsupported`, `details.provider_account` naming that account,
      `details.capability: "provision_virtual"`, and `retryable: false`. Assert no operation,
      commitment or provider request, zero driver create calls and zero simulated billing starts.
      With `allow_orders: true`, separately omit `acknowledge_purchase` and set it to `false`.
      Each request fails HTTP `400`, `invalid_request`, `details.field: "/acknowledge_purchase"`,
      `retryable: false`, without an operation, commitment or provider request, and with zero
      driver create calls and zero simulated billing starts. A fresh-key control with both
      `allow_orders: true` and `acknowledge_purchase: true` reaches the fixture driver's create
      exactly once and records exactly one simulated hourly billing start.
      Separately admit this hourly catalogue create while both are true; while queued and
      unclaimed, restart with only `allow_orders` changed to false. Assert rejection at
      `OPS-43`'s step 3 with `unsupported`, the same account and capability details and
      `retryable: false` on both the error and operation view, `failed`, commitment released in
      full with no setup-fee or first-unit debit, no provider request including no List offers
      read, zero driver create calls and zero simulated billing starts. This catalogue offer
      holds no resource-offer exclusion. On a separate admitted hourly create with
      `allow_orders: true`, remove only its stored `acknowledge_purchase` before claim. Assert
      `OPS-43`'s step-3 `invalid_request`, `details.field: "/acknowledge_purchase"`,
      `retryable: false` on the error and view, `failed`, full commitment release with no
      setup-fee or first-unit debit, no provider request including no List offers read, zero
      driver create calls and zero simulated billing starts. (`WIR-17`, `OPS-23`, `OPS-11`)

      *Amended 2026-10-22 (`pv-p3k`; panel r62, `docs/research/panels-2026-10/r62/`; owner decision 2026-10-22): applied the reviewed ordering-capability change.*
```

### Retain verbatim: CNF-182 Robot test-mode case — `10-conformance-checklist.md:2371–2376` at the pin

```markdown
- [ ] **CNF-182** — The Robot driver's order test flag **defaults to test mode**, and a real
      purchase requires an explicit spend intent that is set exactly once, where `API-15`'s
      acknowledgement and `PRV-10`'s `allow_orders` both hold. Asserted by placing an order with
      the acknowledgement absent and confirming the API returns a `Cancelled` transaction and no
      server. **A driver defaulting to "real purchase" turns every mistaken conformance run into a
      bought server.** (`PRV-34`, `API-15`, `PRV-10`)
```

### Replace: CNF-342 acknowledgement paragraph — `10-conformance-checklist.md:4311–4320` at the pin

```markdown
      Separately omit the caller-supplied purchase acknowledgement from the stored record:
      admit a complete, valid resource-offer (`offer_is_resource`) create that starts new provider
      billing to the operator, whether an upfront charge or hourly or other recurring machine
      rental; neither a setup fee nor immediate payment is required for this condition to apply. Assert this
      create's exclusion for its provider account, ordering channel and offer id is held at
      admission (`PRV-42`, `STO-58`), then remove only the stored caller-supplied acknowledgement
      before worker claim and validation (`OPS-23`). Assert rejection at
      `OPS-43`'s step 3, "Repeat boundary validation under `OPS-23`": `invalid_request` with
      `details.field: "/acknowledge_purchase"`, `retryable: false` on the error and operation view, `failed`, commitment
      released in full with no setup-fee or first-unit debit, this create's settlement freeing
      that same held resource-offer exclusion (`STO-58`), and no provider request at all,
      including no List offers read.
```

### Replace: CNF-364 setup and retained list-offers assertions — `10-conformance-checklist.md:140–154` at the pin

```markdown
- [ ] **CNF-364** — **The claim-time List offers read is gated on `list_offers`.** Admit a
      complete resource-offer (`offer_is_resource`) create on an account that declares
      `list_offers` and the ordering capability, with `allow_orders: true` and the request
      carrying `acknowledge_purchase: true`. Assert this create's exclusion for its provider
      account, ordering channel and offer id is held at admission (`PRV-42`, `STO-58`).
      While it is still queued and unclaimed, restart with a descriptor for that account that
      removes only `list_offers`, keeping the ordering capability declared and the driver's
      List offers code path answering, so the test proves the gate exists, as `CNF-19` does. Assert the worker
      refuses the create at `OPS-43`'s step 4: `unsupported` with `details.provider_account`
      naming the account and `details.capability: "list_offers"`, `retryable: false` on both the
      error and the operation view, no `details.refusals` or `details.not_checked`, `failed`, the
      commitment released in full with no setup-fee or first-unit debit, this create's settlement
      freeing that same held resource-offer exclusion (`STO-58`), and no List offers read,
      per-order key upload or order request. (`DOM-10`, `OPS-43`, `OPS-11`, `LDG-39`, `WIR-9a`,
      `WIR-9b`)
      *Amended 2026-10-22 (`pv-009`; panel r62, `docs/research/panels-2026-10/r62/`): applied the reviewed claim-time capability gate and refusal checks.*
```

### Retain verbatim: CNF-344 channel declaration is no capability grant — `10-conformance-checklist.md:4358–4363` at the pin

```markdown
- [ ] **CNF-344** — **Amended 2026-10-12 (`ADR-0037`, Q28).** **Each channel declares its own order budget.** Enumerate the
      descriptor's ordering channels and assert each has a positive `limit` and finite,
      positive `per`; no top-level `order_budget` substitutes for a missing channel
      entry. Verify the declared limit documents capacity; Robot's reported `403 RATE_LIMIT_EXCEEDED` raises `PRV-5`'s alarm naming account and request path (and channel where useful) and closes the local gate. No local request count raises that alarm.
      Another channel's mere declaration authorizes no new ordering capability.
      (`PRV-44`, `PRV-40`, `DOM-10`)
```


## Form C′ — Form C with the unconditional wire acknowledgement retained

This is a complete landing form. The blocks below are all its replacements and explicitly retained direct dependents. Historical amendment paragraphs outside the printed replacement ranges stay as pinned; no new decision record is being proposed.

Changes from Form C: the `WIR-17` field rules opening, `CNF-34` and the `CNF-342` acknowledgement paragraph become **Retain verbatim** at their pinned bytes. Every other block is identical to Form C.

### Replace: DOM-16 — `01-domain-model.md:570–571` at the pin

```markdown
**DOM-16** A **paid create** is a create that starts new provider billing to the
operator, whether an upfront charge or hourly or other recurring machine rental; neither a
setup fee nor immediate payment is required. For each provider account, an ordering capability
(`provision_virtual` or `provision_bare_metal`) that permits a paid create MUST be conditional
on an explicit per-account `allow_orders` configuration flag: the descriptor (`PRV-44`) of an
account whose flag is false does not declare that capability, so that a misconfigured deployment
cannot start that billing. This is in addition to the per-request purchase acknowledgement
(`API-15`).
```

### Replace: PRV-10 — `02-provider-contract.md:159–162` at the pin

```markdown
**PRV-10** For a paid create (`DOM-16`), create MUST reject the request unless the
request carries an explicit purchase acknowledgement (`WIR-17`'s top-level
`acknowledge_purchase`), *and* the account is configured to allow ordering. Both, not either.
The configuration half is `DOM-10`'s gate on the create's ordering capability (`DOM-16`):
`API-7`'s step 5d at admission and `OPS-43`'s step 3 at claim.
```

### Replace: API-15 — `04-api-contract.md:987–992` at the pin

```markdown
**API-15** A paid create request (`DOM-16`) MUST carry an explicit purchase
acknowledgement — `WIR-17`'s top-level `acknowledge_purchase`, which the wire contract
owns — in addition to the account being configured to allow ordering (`PRV-10`). *"In its provider
options" until 2026-09-05, while `WIR-17` placed it at the top level; the wire contract wins, and a
spending authorization nested inside a driver-private object is one a strict server could not tell
from any other option.*
```

### Replace: configuration row — `00-overview.md:412–412` at the pin

```markdown
| `allow_orders`, per provider account with an ordering capability that permits a paid create (`DOM-16`) | `DOM-16` | boolean | yes |
```

### Replace: Create matrix row — `08-provider-notes.md:31–31` at the pin

```markdown
| Create | see `DOM-16` | see `DOM-16` | see `DOM-16` |
```

### Replace: DEF-17 historical scope paragraph — `09-known-defects.md:163–165` at the pin

```markdown
Requeue re-executed the original request verbatim. For a paid create (`DOM-16`), that is a
second purchase, gated by nothing beyond the same tenant token that placed the first one.
```

### Retain verbatim: WIR-17 field rules opening — `13-wire-contract.md:665–666` at the pin

```markdown
`ssh_public_keys` MUST be non-empty (`PRV-8`, `API-13`). `acknowledge_purchase` MUST be literal
`true` (`API-15`, `PRV-10`). `image` (nullable, a catalog identifier), `user_data` (nullable,
```

### Retain verbatim: CNF-18 — `10-conformance-checklist.md:124–135` at the pin

```markdown
- [ ] **CNF-18** — **AMENDED 2026-09-08 (`ADR-0018`) — the table is `DOM-10`'s, and the descriptor's
      fields are rows too.** For every driver, every declared capability has a working code path,
      and every implemented operation with a capability entry in `DOM-10`'s table has its
      capability declared. Table-driven over that table, one case per (driver, capability) pair;
      the three capability-less methods are `CNF-20`'s and are not rows here. **Then iterate the
      descriptor** (`PRV-44`), one case per (driver, field): a declared value has a working code
      path behind it — a declared ordering channel is searched, a declared evidence source is read,
      a declared surviving attachment kind is listed, and each ordering channel carries
      its own validated `order_budget` — and a field with nothing to declare says so
      explicitly rather than being absent. An ordering capability withheld under `DOM-16` is outside the implemented-implies-declared rows for that account; `CNF-19` and `CNF-55` cover its gate. (`DOM-15`, `DOM-10`, `PRV-4`, `PRV-44`)
      *Amended 2026-10-09 (`ADR-0036`): the order-budget field is iterated per channel.*
      *Amended 2026-10-22 (`pv-p3k`; panel r62, `docs/research/panels-2026-10/r62/`; owner decision 2026-10-22): applied the reviewed ordering-capability change.*
```

### Retain verbatim: CNF-19 — `10-conformance-checklist.md:137–139` at the pin

```markdown
- [ ] **CNF-19** — Create is refused when the provider has not declared the matching
      provision capability — with the driver's internal ordering flag set to permissive,
      so the test proves the outer gate exists. (`DOM-10`, `DEF-10`)
```

### Retain verbatim: CNF-34 — `10-conformance-checklist.md:256–279` at the pin

```markdown
- [ ] **CNF-34** — Validation is enforced in the worker even when the stored request bypasses
      the API layer. On separate creates, store records missing a caller-supplied field —
      `acknowledge_purchase` (`WIR-17`: "`acknowledge_purchase` MUST be literal `true`") — and
      an api-filled admission field, using the accepted-price fields in `request_summary`
      (`OPS-43`: "the accepted recurring price, its currency and its period"). For the caller field assert `invalid_request` with
      `details.field: "/acknowledge_purchase"` and `retryable: false`; for the api-filled
      field assert `conflict`, `details.reason: "incomplete_record"` and `retryable: true`.
      Assert the same kind, applicable reason and `retryable` on the error and the operation
      view (`WIR-9b`), `failed`, no driver call, and the create's commitment released in full
      with no setup-fee or first-unit debit.
      Repeat the caller-field case on an install, using `API-14`'s "explicit destructive
      acknowledgement". Assert `invalid_request` with `details.field: "/acknowledge_destruction"` and `retryable: false`
      on the error and view, `failed`, no driver call, both marker columns still null,
      `disk_effect: "none"` and `rescue_exit: "none"`. The install fixture uses that caller
      acknowledgement; an api-filled install case applies only if the release names a field the
      `api` writes at install admission, and the fixture must identify that field. It asserts
      `conflict`/`incomplete_record`, `retryable: true` and the same untouched-install outcome.
      Complete-record controls on create and install proceed. (`OPS-23`, `OPS-43`, `API-14`,
      `WIR-17`, `WIR-9a`, `WIR-9b`, `OPS-11`, `OPS-45`, `LDG-39`)
      *Amended 2026-10-17 (`pv-14b`; panel r55, `docs/research/panels-2026-10/r55/`):
      added missing-field fixtures, error/view agreement, commitment release,
      install marker outcomes and complete-record controls.*

      *Amended 2026-10-22 (`pv-ss4`; panel r62, `docs/research/panels-2026-10/r62/`): applied the reviewed field-pointer form and validation ordering.*
```

### Replace: CNF-55 — `10-conformance-checklist.md:340–359` at the pin

```markdown
- [ ] **CNF-55** — A paid create (`DOM-16`) is rejected without both the
      per-request purchase acknowledgement and the account-level opt-in. On an account whose
      `allow_orders` is false, assert `GET /v1/providers` lists it without its ordering
      capability, and that a create carrying `acknowledge_purchase: true` is refused at `API-7`'s
      step 5d: HTTP `501`, `unsupported`, `details.provider_account` and `details.capability`
      naming the account and that capability, `retryable: false`, and, with a balance too low for
      the create, no `details.refusals` or `details.not_checked` and no operation or commitment.
      A same-key, same-body replay of a create admitted before the flag was turned off returns its
      stored result. Admit a complete resource-offer (`offer_is_resource`) create with
      `allow_orders` true, and assert this create's exclusion for its provider account, ordering
      channel and offer id is held at admission (`PRV-42`, `STO-58`). While it is still queued
      and unclaimed, restart with only that flag changed to false, and assert the worker
      refuses it at `OPS-43`'s step 3 with the same kind, `details`
      and `retryable: false` on both the error and the operation view, `failed`, the commitment
      released in full with no setup-fee or first-unit debit, this create's settlement freeing
      that same held resource-offer exclusion (`STO-58`), and no provider request, including
      no List offers read. (`API-15`, `PRV-10`, `DOM-10`, `DOM-16`, `API-7`, `OPS-43`, `WIR-9a`,
      `WIR-9b`, `LDG-39`)

      **Hourly cloud cases.** Each admission case uses a fresh idempotency key. Use an
      otherwise valid, sellable hourly cloud catalogue offer
      with a positive recurring provider price and no setup fee, on a healthy assigned provider
      account implementing `provision_virtual`. Keep all unrelated sale, price, balance and
      admission conditions satisfied in the fixture. The driver is internally permissive and
      would start hourly billing if its create method were called; count its create calls and
      simulated billing starts. This fixture supplies the sale evidence needed for the test;
      it does not authorize sale of a live offer withheld under `PRV-13b` or `PRV-31`.
      With `allow_orders: false` and `acknowledge_purchase: true`, assert the provider listing
      omits `provision_virtual` and a fresh-key create fails at `API-7`'s step 5d with HTTP `501`,
      `unsupported`, `details.provider_account` naming that account,
      `details.capability: "provision_virtual"`, and `retryable: false`. Assert no operation,
      commitment or provider request, zero driver create calls and zero simulated billing starts.
      With `allow_orders: true`, separately omit `acknowledge_purchase` and set it to `false`.
      Each request fails HTTP `400`, `invalid_request`, `details.field: "/acknowledge_purchase"`,
      `retryable: false`, without an operation, commitment or provider request, and with zero
      driver create calls and zero simulated billing starts. A fresh-key control with both
      `allow_orders: true` and `acknowledge_purchase: true` reaches the fixture driver's create
      exactly once and records exactly one simulated hourly billing start.
      Separately admit this hourly catalogue create while both are true; while queued and
      unclaimed, restart with only `allow_orders` changed to false. Assert rejection at
      `OPS-43`'s step 3 with `unsupported`, the same account and capability details and
      `retryable: false` on both the error and operation view, `failed`, commitment released in
      full with no setup-fee or first-unit debit, no provider request including no List offers
      read, zero driver create calls and zero simulated billing starts. This catalogue offer
      holds no resource-offer exclusion. On a separate admitted hourly create with
      `allow_orders: true`, remove only its stored `acknowledge_purchase` before claim. Assert
      `OPS-43`'s step-3 `invalid_request`, `details.field: "/acknowledge_purchase"`,
      `retryable: false` on the error and view, `failed`, full commitment release with no
      setup-fee or first-unit debit, no provider request including no List offers read, zero
      driver create calls and zero simulated billing starts. (`WIR-17`, `OPS-23`, `OPS-11`)

      *Amended 2026-10-22 (`pv-p3k`; panel r62, `docs/research/panels-2026-10/r62/`; owner decision 2026-10-22): applied the reviewed ordering-capability change.*
```

### Retain verbatim: CNF-182 Robot test-mode case — `10-conformance-checklist.md:2371–2376` at the pin

```markdown
- [ ] **CNF-182** — The Robot driver's order test flag **defaults to test mode**, and a real
      purchase requires an explicit spend intent that is set exactly once, where `API-15`'s
      acknowledgement and `PRV-10`'s `allow_orders` both hold. Asserted by placing an order with
      the acknowledgement absent and confirming the API returns a `Cancelled` transaction and no
      server. **A driver defaulting to "real purchase" turns every mistaken conformance run into a
      bought server.** (`PRV-34`, `API-15`, `PRV-10`)
```

### Retain verbatim: CNF-342 acknowledgement paragraph — `10-conformance-checklist.md:4311–4320` at the pin

```markdown
      Separately omit the caller-supplied purchase acknowledgement from the stored record:
      admit a complete, valid resource-offer (`offer_is_resource`) create and assert this
      create's exclusion for its provider account, ordering channel and offer id is held at
      admission (`PRV-42`, `STO-58`), then remove only the stored caller-supplied acknowledgement
      before worker claim and validation (`OPS-23`). Assert rejection at
      `OPS-43`'s step 3, "Repeat boundary validation under `OPS-23`": `invalid_request` with
      `details.field: "/acknowledge_purchase"`, `retryable: false` on the error and operation view, `failed`, commitment
      released in full with no setup-fee or first-unit debit, this create's settlement freeing
      that same held resource-offer exclusion (`STO-58`), and no provider request at all,
      including no List offers read.
```

### Replace: CNF-364 setup and retained list-offers assertions — `10-conformance-checklist.md:140–154` at the pin

```markdown
- [ ] **CNF-364** — **The claim-time List offers read is gated on `list_offers`.** Admit a
      complete resource-offer (`offer_is_resource`) create on an account that declares
      `list_offers` and the ordering capability, with `allow_orders: true` and the request
      carrying `acknowledge_purchase: true`. Assert this create's exclusion for its provider
      account, ordering channel and offer id is held at admission (`PRV-42`, `STO-58`).
      While it is still queued and unclaimed, restart with a descriptor for that account that
      removes only `list_offers`, keeping the ordering capability declared and the driver's
      List offers code path answering, so the test proves the gate exists, as `CNF-19` does. Assert the worker
      refuses the create at `OPS-43`'s step 4: `unsupported` with `details.provider_account`
      naming the account and `details.capability: "list_offers"`, `retryable: false` on both the
      error and the operation view, no `details.refusals` or `details.not_checked`, `failed`, the
      commitment released in full with no setup-fee or first-unit debit, this create's settlement
      freeing that same held resource-offer exclusion (`STO-58`), and no List offers read,
      per-order key upload or order request. (`DOM-10`, `OPS-43`, `OPS-11`, `LDG-39`, `WIR-9a`,
      `WIR-9b`)
      *Amended 2026-10-22 (`pv-009`; panel r62, `docs/research/panels-2026-10/r62/`): applied the reviewed claim-time capability gate and refusal checks.*
```

### Retain verbatim: CNF-344 channel declaration is no capability grant — `10-conformance-checklist.md:4358–4363` at the pin

```markdown
- [ ] **CNF-344** — **Amended 2026-10-12 (`ADR-0037`, Q28).** **Each channel declares its own order budget.** Enumerate the
      descriptor's ordering channels and assert each has a positive `limit` and finite,
      positive `per`; no top-level `order_budget` substitutes for a missing channel
      entry. Verify the declared limit documents capacity; Robot's reported `403 RATE_LIMIT_EXCEEDED` raises `PRV-5`'s alarm naming account and request path (and channel where useful) and closes the local gate. No local request count raises that alarm.
      Another channel's mere declaration authorizes no new ordering capability.
      (`PRV-44`, `PRV-40`, `DOM-10`)
```


## Prior reader answers, verbatim historical evidence

### BEGIN r89 fable answer

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


### END r89 fable answer

### BEGIN r89 opus answer

I'm the opus seat. My pick is a complete alternative, C′: Form C with the wire acknowledgement rule kept as it is at the pin. I can't accept any of A–D as printed, because all four make `WIR-17`'s acknowledgement rule conditional, and nothing the owner decided calls for that.

**Final: C′** (complete exact form at the end)

| Form | Verdict | Reason |
|---|---|---|
| A | CANNOT ACCEPT | `WIR-17` narrowing; no hourly cloud case |
| B | CANNOT ACCEPT | `WIR-17` narrowing; scope text repeated at nine sites |
| C | CANNOT ACCEPT | `WIR-17` narrowing; otherwise my pick |
| D | CANNOT ACCEPT | `WIR-17` narrowing; scope text repeated at nine sites |

Preference among the printed forms, kept separate from acceptance: C > A > D > B.

## 1. Packet check (rule 6)

- I compared all 18 pinned evidence blocks against my clone at `3109b5b`, and every one matches exactly.
- All four retained blocks in A–D match the pin, and `form-{A..D}.md` match the brief.
- C is exactly A plus the "Hourly cloud cases" paragraph, and D is exactly B plus the same paragraph.
- **No brief error changes the premise, so rule 6 does not void anything.**
- One inaccuracy that doesn't change the premise: the brief says the property "is tied to the creates a capability permits". That is true of `DOM-16`. But `PRV-10`, `API-15` and `WIR-17` say "For a paid create", which classifies each create separately. My blocking point comes from that text, not from the brief's sentence.

## 2. Blocking loss under rule 3, common to A–D

**The rule.** At the pin, `13-wire-contract.md:665–666` (`WIR-17`) says "`acknowledge_purchase` MUST be literal `true` (`API-15`, `PRV-10`)". That applies to every create. Every form makes it "For a paid create (`DOM-16`), …", and B and D spell the condition out in full.

**The case it breaks.** The set models creates that start no billing:
- `CNF-315` tests "a zero recurring price and a null floor".
- `CNF-316` says "Accept an order on an offer whose `first_unit` is zero".
- `12-billing-and-ledger.md:1242–1243` covers "a positive `seconds` at a zero recurring price".

**Trace.** A zero-price offer with setup fee `"0"`, `allow_orders: true`, and `acknowledge_purchase: false`:
- **At the pin:** `API-7` step 5 rejects it with `400 invalid_request`, `/acknowledge_purchase`. There is one possible verdict.
- **Under A–D:** "starts new provider billing … hourly or other recurring machine rental" can be read two ways for a zero-price rental:
  - Reading 1: a rental at zero price is still billing, so the create is paid and still gets 400.
  - Reading 2: nothing is charged, so the create isn't paid. Then no rule rejects it and it is admitted without the acknowledgement. `OVR-6`'s "billable actions" does not cover it either.
- Two engines can each cite the text and disagree, which is the kind of defect pv-9ecf was filed to fix.

**It also changes check order.** To apply the conditional rule at step 5, the api needs the offer's price. `API-7` reads offer data only later, in the tail: "the offers the check reads are the provider account's stored offer listing …, read in that snapshot". Under reading 2, the acknowledgement check effectively becomes a per-offer runtime check before that snapshot is read.

**Collateral narrowing of two checks.**
- `CNF-34` goes from "On separate creates" to "On separate paid creates".
- `CNF-342`'s fixture goes from "resource-offer create" to "paid resource-offer create".
- In both, a stored zero-price create with its acknowledgement removed no longer has to fail at `OPS-43` step 3.

**Why this is beyond the decision.** The owner decided which creates the acknowledgement must cover ("any create that starts billing"). They did not decide to exempt any create. The brief does not disclose this flip.

**Repair.** Keep `WIR-17:665–666`, `CNF-34` and `CNF-342`'s paragraph exactly as at the pin.
- An unconditional wire rule requires a superset of `API-15`'s paid creates, so nothing conflicts.
- No verdict then depends on classifying an individual create. The acknowledgement is always required by `WIR-17`, and the `allow_orders` half is `DOM-10`'s gate on the account-level capability.
- `CNF-34`'s quote of `WIR-17` stays byte-intact.
- The pin already had `API-15` scoped more narrowly than `WIR-17`, so this adds no new mismatch.

## 3. Missed sites

Besides the search list, I inspected: `PRV-4` (02:29), `PRV-34` (02:1046), 04:1018, the descriptor fixture at 13:1016–1030, `OVR-6` (00:46–47), `SEC-39` (07:205–264), CONTEXT.md:321–323 ("order-shaped provider", which means where the correlator lives, not a billing scope), and README `SEC-26` (a withdrawn description). Nothing else in live text quotes the changed `DOM-16` phrases ("not instead of", "cannot spend money", "does not declare them").

- **All forms:** I found no missed site that conflicts. `OVR-6` is a related umbrella phrase ("billable actions MUST require an explicit per-request acknowledgement") that needs no edit. Under the pin's `WIR-17`, which C′ keeps, it is satisfied for every create. CONTEXT.md is an optional glossary, so leaving out a "paid create" entry isn't a miss.
- **B and D:** No missed site, but the predicate is copied into nine places and the copies already differ:
  - "Neither a setup fee nor immediate payment is required for this condition to apply"
  - "without requiring a setup fee or immediate payment" (overview row)
  - "; neither … required for this condition to apply" (`CNF-342`)

  AGENTS.md says "One rule, one home; everywhere else points at it", and holds up `SEC-46` as the example of a copy that drifted. B and D replace four undefined phrasings with nine defined-in-place ones. That's a maintenance cost, not a rule-3 loss. B and D's `DEF-17` also adds a scope sentence that sounds normative to a historical defect record.

## 4. Traces

**(a) Hourly cloud create, no setup fee, `allow_orders: false`, acknowledgement `true`.**
- Wording: `DOM-16` says `provision_virtual` "permits a paid create" (hourly rental, "neither a setup fee nor immediate payment is required"). So the descriptor withholds it, `GET /v1/providers` omits it, and `API-7` step 5d / `DOM-10` refuses with `501 unsupported`, the account and capability in `details`, and `retryable: false`. The low-balance order and same-key replay in `CNF-55`'s base text are unchanged.
- Assertions:
  - **A/B:** `CNF-55`'s first case doesn't name an account type. Its claim-time case uses a resource offer, which is Robot auction, itself hourly with `price_setup` 0 (08:405–407). An engine that treats cloud as unpaid still passes `CNF-18` by declaring the capability, and it can pass `CNF-55` if the case runs on Robot. Nothing forces a `provision_virtual` fixture.
  - **C/D/C′:** the hourly paragraph asserts `details.capability: "provision_virtual"`, 501 at 5d, zero driver create calls and zero billing starts.

**(b) Hourly create, `allow_orders: true`, acknowledgement absent or `false`.**
- Wording: `API-15` ("A paid create request … MUST carry") plus `WIR-17` literal-true give 400 at step 5, before 5d and before the tail.
- Assertions: at the pin, the checklist's only `acknowledge_purchase` hits are `CNF-34` (lines 258 and 261, worker side), `CNF-55` (line 343, acknowledgement true) and `CNF-342` (line 4317, worker side). **No case anywhere tests a create admission with the acknowledgement absent or false.** C/D/C′ add one, plus a positive control that reaches the driver exactly once.

**(c) Claim-time restart (C/D/C′).** `OPS-43` step 1 reads status (local), step 2 reads the channel closure (local), then step 3 runs caller fields, then api fields, then the capability gate, giving `unsupported` before step 4's List offers read. The `LDG-39` "Deterministic rejection before acceptance" row means a full release with no debit. The claim that a catalogue offer holds no exclusion is consistent with `PRV-42`/`STO-58`, which apply only to `offer_is_resource`.

**(d) Stored acknowledgement removed (C/D/C′).** The step-3 caller-field check, via `OPS-23` ("Validation that was performed at the API boundary MUST be repeated"), gives `invalid_request` on `/acknowledge_purchase`. Under C′ this holds for every create, because `WIR-17` stays unconditional.

## 5. Other changes, none blocking

- **`DOM-16` drops ", not instead of,".** "In addition to" together with `PRV-10`'s "Both, not either" keeps the obligation. Restoring it would be harmless, but I left C's text as printed.
- **"cannot spend money" becomes "cannot start that billing".** This is a rationale clause and nothing quotes it.
- **The matrix row becomes "see `DOM-16`".** The table "is not read by anything".
- **`CNF-364` gains `allow_orders: true` and acknowledgement `true`.** This is a fixture clarification and loses nothing.
- **"Catalogue offer" isn't a defined term.** "Holds no resource-offer exclusion" makes the meaning recoverable. "An offer whose `offer_is_resource` is false" would be tighter.
- **The hourly case runs on one cloud driver.** Running it for each driver would be stronger but isn't required.
- **Positive-control fixture.** It must also declare `list_offers` and have a fresh stored listing and free 5c ceiling slots. "Keep all unrelated … admission conditions satisfied" covers that.
- **`CNF-182`.** Placing an order "with the acknowledgement absent" can only be a driver-level test, because provisiond's API rejects that at step 5. That predates every form. Under A–D's conditional `WIR-17`, a test-mode Robot order that "starts no billing" could also read as unpaid, which is another side of §2. C′ avoids it.
- **No Lean impact.** `Admission.lean`'s step-5d model takes declaration as a supplied Boolean, and no theorem encodes the scope.

## 6. Counterargument (on request) and pick

The strongest case for the wording-only footprint (A): the checklist isn't a gate, and `DOM-16`'s definition alone already makes an engine that treats cloud as unpaid non-conforming. `CNF-55`'s new heading "A paid create (`DOM-16`)" already scopes the existing case to every paid create. The triage row asked only for an explicit property. The hourly paragraph adds about 30 lines, a new fixture idea ("simulated billing starts"), and assertions that partly repeat `CNF-55`'s base text inside the same item. That is more text to keep in sync for a requirement the definition already settles.

**My pick is still C′.** A and B have no case that forces a cloud `provision_virtual` fixture, so the owner's exact failure story stays untested. No checklist case at the pin rejects a create admission whose acknowledgement is absent or false. C′ closes both gaps with the defined term (one home for the scope) and without the `WIR-17` narrowing.

## Evidence

I did not run `lake`, the formal gate or `check-all.sh`. On copies under `tmp/opus/`, I ran `check_ids`, `check_obligations`, `check_coverage` and `check_citations` for the pin, A, B, C, D and C′:

- **Same results everywhere:** ids, obligations and coverage exit 0. The citation quote pass reports "353 compared; 6, none new against baseline 6".
- **Not gate results:** `check_citations` then exits 2 because `.lake/index.jsonl` doesn't exist without the formal build, and `check_fixtures` exits 1 because `markdown_it` isn't installed outside nix. Both happen at the pin too.

I made no changes to the source, Git state or tracker.

---

## Form C′ — Form C with the unconditional wire acknowledgement retained

This is a complete landing form. The blocks below are all its replacements and explicitly retained direct dependents. Historical amendment paragraphs outside the printed replacement ranges stay as pinned; no new decision record is being proposed.

Changes from Form C: the `WIR-17` field rules opening, `CNF-34` and the `CNF-342` acknowledgement paragraph become **Retain verbatim** at their pinned bytes. Every other block is identical to Form C.

### Replace: DOM-16 — `01-domain-model.md:570–571` at the pin

```markdown
**DOM-16** A **paid create** is a create that starts new provider billing to the
operator, whether an upfront charge or hourly or other recurring machine rental; neither a
setup fee nor immediate payment is required. For each provider account, an ordering capability
(`provision_virtual` or `provision_bare_metal`) that permits a paid create MUST be conditional
on an explicit per-account `allow_orders` configuration flag: the descriptor (`PRV-44`) of an
account whose flag is false does not declare that capability, so that a misconfigured deployment
cannot start that billing. This is in addition to the per-request purchase acknowledgement
(`API-15`).
```

### Replace: PRV-10 — `02-provider-contract.md:159–162` at the pin

```markdown
**PRV-10** For a paid create (`DOM-16`), create MUST reject the request unless the
request carries an explicit purchase acknowledgement (`WIR-17`'s top-level
`acknowledge_purchase`), *and* the account is configured to allow ordering. Both, not either.
The configuration half is `DOM-10`'s gate on the create's ordering capability (`DOM-16`):
`API-7`'s step 5d at admission and `OPS-43`'s step 3 at claim.
```

### Replace: API-15 — `04-api-contract.md:987–992` at the pin

```markdown
**API-15** A paid create request (`DOM-16`) MUST carry an explicit purchase
acknowledgement — `WIR-17`'s top-level `acknowledge_purchase`, which the wire contract
owns — in addition to the account being configured to allow ordering (`PRV-10`). *"In its provider
options" until 2026-09-05, while `WIR-17` placed it at the top level; the wire contract wins, and a
spending authorization nested inside a driver-private object is one a strict server could not tell
from any other option.*
```

### Replace: configuration row — `00-overview.md:412–412` at the pin

```markdown
| `allow_orders`, per provider account with an ordering capability that permits a paid create (`DOM-16`) | `DOM-16` | boolean | yes |
```

### Replace: Create matrix row — `08-provider-notes.md:31–31` at the pin

```markdown
| Create | see `DOM-16` | see `DOM-16` | see `DOM-16` |
```

### Replace: DEF-17 historical scope paragraph — `09-known-defects.md:163–165` at the pin

```markdown
Requeue re-executed the original request verbatim. For a paid create (`DOM-16`), that is a
second purchase, gated by nothing beyond the same tenant token that placed the first one.
```

### Retain verbatim: WIR-17 field rules opening — `13-wire-contract.md:665–666` at the pin

```markdown
`ssh_public_keys` MUST be non-empty (`PRV-8`, `API-13`). `acknowledge_purchase` MUST be literal
`true` (`API-15`, `PRV-10`). `image` (nullable, a catalog identifier), `user_data` (nullable,
```

### Retain verbatim: CNF-18 — `10-conformance-checklist.md:124–135` at the pin

```markdown
- [ ] **CNF-18** — **AMENDED 2026-09-08 (`ADR-0018`) — the table is `DOM-10`'s, and the descriptor's
      fields are rows too.** For every driver, every declared capability has a working code path,
      and every implemented operation with a capability entry in `DOM-10`'s table has its
      capability declared. Table-driven over that table, one case per (driver, capability) pair;
      the three capability-less methods are `CNF-20`'s and are not rows here. **Then iterate the
      descriptor** (`PRV-44`), one case per (driver, field): a declared value has a working code
      path behind it — a declared ordering channel is searched, a declared evidence source is read,
      a declared surviving attachment kind is listed, and each ordering channel carries
      its own validated `order_budget` — and a field with nothing to declare says so
      explicitly rather than being absent. An ordering capability withheld under `DOM-16` is outside the implemented-implies-declared rows for that account; `CNF-19` and `CNF-55` cover its gate. (`DOM-15`, `DOM-10`, `PRV-4`, `PRV-44`)
      *Amended 2026-10-09 (`ADR-0036`): the order-budget field is iterated per channel.*
      *Amended 2026-10-22 (`pv-p3k`; panel r62, `docs/research/panels-2026-10/r62/`; owner decision 2026-10-22): applied the reviewed ordering-capability change.*
```

### Retain verbatim: CNF-19 — `10-conformance-checklist.md:137–139` at the pin

```markdown
- [ ] **CNF-19** — Create is refused when the provider has not declared the matching
      provision capability — with the driver's internal ordering flag set to permissive,
      so the test proves the outer gate exists. (`DOM-10`, `DEF-10`)
```

### Retain verbatim: CNF-34 — `10-conformance-checklist.md:256–279` at the pin

```markdown
- [ ] **CNF-34** — Validation is enforced in the worker even when the stored request bypasses
      the API layer. On separate creates, store records missing a caller-supplied field —
      `acknowledge_purchase` (`WIR-17`: "`acknowledge_purchase` MUST be literal `true`") — and
      an api-filled admission field, using the accepted-price fields in `request_summary`
      (`OPS-43`: "the accepted recurring price, its currency and its period"). For the caller field assert `invalid_request` with
      `details.field: "/acknowledge_purchase"` and `retryable: false`; for the api-filled
      field assert `conflict`, `details.reason: "incomplete_record"` and `retryable: true`.
      Assert the same kind, applicable reason and `retryable` on the error and the operation
      view (`WIR-9b`), `failed`, no driver call, and the create's commitment released in full
      with no setup-fee or first-unit debit.
      Repeat the caller-field case on an install, using `API-14`'s "explicit destructive
      acknowledgement". Assert `invalid_request` with `details.field: "/acknowledge_destruction"` and `retryable: false`
      on the error and view, `failed`, no driver call, both marker columns still null,
      `disk_effect: "none"` and `rescue_exit: "none"`. The install fixture uses that caller
      acknowledgement; an api-filled install case applies only if the release names a field the
      `api` writes at install admission, and the fixture must identify that field. It asserts
      `conflict`/`incomplete_record`, `retryable: true` and the same untouched-install outcome.
      Complete-record controls on create and install proceed. (`OPS-23`, `OPS-43`, `API-14`,
      `WIR-17`, `WIR-9a`, `WIR-9b`, `OPS-11`, `OPS-45`, `LDG-39`)
      *Amended 2026-10-17 (`pv-14b`; panel r55, `docs/research/panels-2026-10/r55/`):
      added missing-field fixtures, error/view agreement, commitment release,
      install marker outcomes and complete-record controls.*

      *Amended 2026-10-22 (`pv-ss4`; panel r62, `docs/research/panels-2026-10/r62/`): applied the reviewed field-pointer form and validation ordering.*
```

### Replace: CNF-55 — `10-conformance-checklist.md:340–359` at the pin

```markdown
- [ ] **CNF-55** — A paid create (`DOM-16`) is rejected without both the
      per-request purchase acknowledgement and the account-level opt-in. On an account whose
      `allow_orders` is false, assert `GET /v1/providers` lists it without its ordering
      capability, and that a create carrying `acknowledge_purchase: true` is refused at `API-7`'s
      step 5d: HTTP `501`, `unsupported`, `details.provider_account` and `details.capability`
      naming the account and that capability, `retryable: false`, and, with a balance too low for
      the create, no `details.refusals` or `details.not_checked` and no operation or commitment.
      A same-key, same-body replay of a create admitted before the flag was turned off returns its
      stored result. Admit a complete resource-offer (`offer_is_resource`) create with
      `allow_orders` true, and assert this create's exclusion for its provider account, ordering
      channel and offer id is held at admission (`PRV-42`, `STO-58`). While it is still queued
      and unclaimed, restart with only that flag changed to false, and assert the worker
      refuses it at `OPS-43`'s step 3 with the same kind, `details`
      and `retryable: false` on both the error and the operation view, `failed`, the commitment
      released in full with no setup-fee or first-unit debit, this create's settlement freeing
      that same held resource-offer exclusion (`STO-58`), and no provider request, including
      no List offers read. (`API-15`, `PRV-10`, `DOM-10`, `DOM-16`, `API-7`, `OPS-43`, `WIR-9a`,
      `WIR-9b`, `LDG-39`)

      **Hourly cloud cases.** Each admission case uses a fresh idempotency key. Use an
      otherwise valid, sellable hourly cloud catalogue offer
      with a positive recurring provider price and no setup fee, on a healthy assigned provider
      account implementing `provision_virtual`. Keep all unrelated sale, price, balance and
      admission conditions satisfied in the fixture. The driver is internally permissive and
      would start hourly billing if its create method were called; count its create calls and
      simulated billing starts. This fixture supplies the sale evidence needed for the test;
      it does not authorize sale of a live offer withheld under `PRV-13b` or `PRV-31`.
      With `allow_orders: false` and `acknowledge_purchase: true`, assert the provider listing
      omits `provision_virtual` and a fresh-key create fails at `API-7`'s step 5d with HTTP `501`,
      `unsupported`, `details.provider_account` naming that account,
      `details.capability: "provision_virtual"`, and `retryable: false`. Assert no operation,
      commitment or provider request, zero driver create calls and zero simulated billing starts.
      With `allow_orders: true`, separately omit `acknowledge_purchase` and set it to `false`.
      Each request fails HTTP `400`, `invalid_request`, `details.field: "/acknowledge_purchase"`,
      `retryable: false`, without an operation, commitment or provider request, and with zero
      driver create calls and zero simulated billing starts. A fresh-key control with both
      `allow_orders: true` and `acknowledge_purchase: true` reaches the fixture driver's create
      exactly once and records exactly one simulated hourly billing start.
      Separately admit this hourly catalogue create while both are true; while queued and
      unclaimed, restart with only `allow_orders` changed to false. Assert rejection at
      `OPS-43`'s step 3 with `unsupported`, the same account and capability details and
      `retryable: false` on both the error and operation view, `failed`, commitment released in
      full with no setup-fee or first-unit debit, no provider request including no List offers
      read, zero driver create calls and zero simulated billing starts. This catalogue offer
      holds no resource-offer exclusion. On a separate admitted hourly create with
      `allow_orders: true`, remove only its stored `acknowledge_purchase` before claim. Assert
      `OPS-43`'s step-3 `invalid_request`, `details.field: "/acknowledge_purchase"`,
      `retryable: false` on the error and view, `failed`, full commitment release with no
      setup-fee or first-unit debit, no provider request including no List offers read, zero
      driver create calls and zero simulated billing starts. (`WIR-17`, `OPS-23`, `OPS-11`)

      *Amended 2026-10-22 (`pv-p3k`; panel r62, `docs/research/panels-2026-10/r62/`; owner decision 2026-10-22): applied the reviewed ordering-capability change.*
```

### Retain verbatim: CNF-182 Robot test-mode case — `10-conformance-checklist.md:2371–2376` at the pin

```markdown
- [ ] **CNF-182** — The Robot driver's order test flag **defaults to test mode**, and a real
      purchase requires an explicit spend intent that is set exactly once, where `API-15`'s
      acknowledgement and `PRV-10`'s `allow_orders` both hold. Asserted by placing an order with
      the acknowledgement absent and confirming the API returns a `Cancelled` transaction and no
      server. **A driver defaulting to "real purchase" turns every mistaken conformance run into a
      bought server.** (`PRV-34`, `API-15`, `PRV-10`)
```

### Retain verbatim: CNF-342 acknowledgement paragraph — `10-conformance-checklist.md:4311–4320` at the pin

```markdown
      Separately omit the caller-supplied purchase acknowledgement from the stored record:
      admit a complete, valid resource-offer (`offer_is_resource`) create and assert this
      create's exclusion for its provider account, ordering channel and offer id is held at
      admission (`PRV-42`, `STO-58`), then remove only the stored caller-supplied acknowledgement
      before worker claim and validation (`OPS-23`). Assert rejection at
      `OPS-43`'s step 3, "Repeat boundary validation under `OPS-23`": `invalid_request` with
      `details.field: "/acknowledge_purchase"`, `retryable: false` on the error and operation view, `failed`, commitment
      released in full with no setup-fee or first-unit debit, this create's settlement freeing
      that same held resource-offer exclusion (`STO-58`), and no provider request at all,
      including no List offers read.
```

### Replace: CNF-364 setup and retained list-offers assertions — `10-conformance-checklist.md:140–154` at the pin

```markdown
- [ ] **CNF-364** — **The claim-time List offers read is gated on `list_offers`.** Admit a
      complete resource-offer (`offer_is_resource`) create on an account that declares
      `list_offers` and the ordering capability, with `allow_orders: true` and the request
      carrying `acknowledge_purchase: true`. Assert this create's exclusion for its provider
      account, ordering channel and offer id is held at admission (`PRV-42`, `STO-58`).
      While it is still queued and unclaimed, restart with a descriptor for that account that
      removes only `list_offers`, keeping the ordering capability declared and the driver's
      List offers code path answering, so the test proves the gate exists, as `CNF-19` does. Assert the worker
      refuses the create at `OPS-43`'s step 4: `unsupported` with `details.provider_account`
      naming the account and `details.capability: "list_offers"`, `retryable: false` on both the
      error and the operation view, no `details.refusals` or `details.not_checked`, `failed`, the
      commitment released in full with no setup-fee or first-unit debit, this create's settlement
      freeing that same held resource-offer exclusion (`STO-58`), and no List offers read,
      per-order key upload or order request. (`DOM-10`, `OPS-43`, `OPS-11`, `LDG-39`, `WIR-9a`,
      `WIR-9b`)
      *Amended 2026-10-22 (`pv-009`; panel r62, `docs/research/panels-2026-10/r62/`): applied the reviewed claim-time capability gate and refusal checks.*
```

### Retain verbatim: CNF-344 channel declaration is no capability grant — `10-conformance-checklist.md:4358–4363` at the pin

```markdown
- [ ] **CNF-344** — **Amended 2026-10-12 (`ADR-0037`, Q28).** **Each channel declares its own order budget.** Enumerate the
      descriptor's ordering channels and assert each has a positive `limit` and finite,
      positive `per`; no top-level `order_budget` substitutes for a missing channel
      entry. Verify the declared limit documents capacity; Robot's reported `403 RATE_LIMIT_EXCEEDED` raises `PRV-5`'s alarm naming account and request path (and channel where useful) and closes the local gate. No local request count raises that alarm.
      Another channel's mere declaration authorizes no new ordering capability.
      (`PRV-44`, `PRV-40`, `DOM-10`)
```

The same text is at `/var/tmp/provisiond-panel-r89/tmp/opus/form-Cprime.md`.


### END r89 opus answer

### BEGIN r89 astra answer

**Final: C**

- **A — ACCEPT.** No missed site found. No repair required.
- **B — CANNOT ACCEPT.** No missed site found; my objection is repeated ownership of the scope predicate. The exact replacement package I accept instead is **A, as printed**.
- **C — ACCEPT.** No missed site found. No repair required. This is my preference.
- **D — CANNOT ACCEPT.** No missed site found; it has B’s repeated-ownership problem. The exact replacement package I accept instead is **C, as printed**.

My B/D dissent is a document-ownership objection, **not a verified blocking loss under notes.md rule 3**. I found no trace in which their printed billing predicates violate the fixed owner decision.

**Packet verification.** HEAD is `3109b5b44eae17e288cf52aaa976993bd8c5626c`. I read the brief and notes whole, checked the supplied coverage files, compared the pinned evidence blocks against this clone, and checked the explicitly retained candidate blocks. Those quotations match. I found no verified brief error changing the question’s premise, so notes.md rule 6 supplies no reason to void this question. The post-pin owner decision is clearly presented as packet evidence, rather than attributed to the pinned repository.

The decisive wording in C’s `DOM-16` is:

> “whether an upfront charge or hourly or other recurring machine rental; neither a setup fee nor immediate payment is required”

That resolves the motivating ambiguity. Its capability condition—

> “an ordering capability … that permits a paid create”

—applies to the named provider account’s capability, without requiring a new descriptor field or a provider-name classification.

B/D express the same substantive scope, but reproduce its definition in `PRV-10`, `API-15`, the configuration row, `DEF-17`, `WIR-17`, `CNF-34`, `CNF-55`, and the `CNF-342` paragraph. This conflicts with the repository instruction:

> “One rule, one home; everywhere else points at it.”

The maintenance consequence is concrete: a future scope amendment must synchronize independently written predicates across those sites. A/C give that definition one home in `DOM-16`. The exact existing packages A and C already provide the complete remedies; I am proposing no additional alternative or synthesized repair.

For **each form**, I found no omitted replacement site after inspecting the quoted evidence, supplied searches, and relevant references in the clone. In particular:

- The `WIR-17` replacement includes the paid-create scope and preserves “`acknowledge_purchase` MUST be literal `true`.”
- `OPS-43` retains its quoted phrases “explicit purchase acknowledgement” and “the account is configured to allow ordering”; both still occur in every proposed `PRV-10`.
- `WIR-29` says the listing’s capabilities “are the descriptor’s fields, rendered”; changing the descriptor condition therefore reaches discovery without another listing rule.
- `PRV-4`, `DOM-15`, and retained `CNF-18` keep the capability-withholding exception. Retained `CNF-19` still uses an internally permissive driver.
- The provider-notes matrix and `DEF-17` no longer leave competing active scope wording. Historical records need no rewriting.
- Retained `CNF-344` still says: “Another channel’s mere declaration authorizes no new ordering capability.”

**Admission traces.**

For an otherwise valid hourly create with a positive provider rental price, no setup fee, `allow_orders: false`, and `acknowledge_purchase: true`:

1. A/C classify it through “paid create”; B/D state the equivalent billing predicate directly.
2. Every proposed `DOM-16` requires withholding `provision_virtual`.
3. `DOM-10` requires gating “before the driver is called, **including create**.”
4. `API-7` step 5d says: “A refusal stops here and is not collected by the tail.”
5. The existing portion of every proposed `CNF-55` asserts HTTP `501`, `unsupported`, account/capability details, `retryable: false`, and no operation or commitment.

The existing low-balance assertion remains: the capability refusal has no `details.refusals` or `details.not_checked`, even when the balance cannot fund the create. C/D additionally instantiate this trace with the hourly fixture and require zero driver create calls and zero simulated billing starts.

For the hourly create with `allow_orders: true` but acknowledgement absent or false, the proposed `PRV-10` still requires “Both, not either,” and `WIR-17` still requires literal `true`. `API-7` step 5 is “deserialize and validate the body,” before the capability gate and purchase tail. C/D explicitly require separate absent and false cases returning HTTP `400`, `invalid_request`, `/acknowledge_purchase`, and `retryable: false`, with no operation, commitment, provider request, driver create call, or simulated billing start.

A/B impose that same obligation, but do not explicitly demand these hourly admission fixtures. Their opening `CNF-55` assertion requires rejection without both conditions, and their worker cases retain acknowledgement validation. The absence of the additional hourly fixtures is a coverage difference, not a contradiction or rule-3 blocking loss.

Stored replay remains distinct from a fresh create. `API-7` step 5a says an equal fingerprint under the same principal/key “returns the stored result,” before step 5d. Every form preserves `CNF-55`’s same-key, same-body replay assertion. C/D’s fresh-key instruction prevents that replay path from accidentally satisfying a new-create test.

**C/D claim-time traces.**

After admission with both settings true, restarting while the hourly create remains queued and unclaimed with only `allow_orders` changed to false removes its ordering capability. The proposed assertion requires refusal at `OPS-43` step 3: `unsupported`, matching account/capability details, `retryable: false` on error and operation view, `failed`, full commitment release, no setup-fee or first-unit debit, and no provider request—including no List offers read. Zero simulated billing starts makes the spending consequence explicit.

For the separately admitted hourly create whose stored acknowledgement is removed, `OPS-23` requires:

> “Validation that was performed at the API boundary MUST be repeated in the worker before the driver is called.”

Its caller-field rule requires `invalid_request` and `retryable: false` on both error and operation view. C/D assert those results at step 3, including `/acknowledge_purchase`, full release, no debit, no provider request, and zero simulated billing starts.

The catalogue/resource distinction is correct. `PRV-42` says:

> “Catalogue products do not take this claim.”

C/D accordingly state that the hourly catalogue fixture holds no resource-offer exclusion. They preserve the original resource-offer admission and exclusion-release assertions in the existing `CNF-55` case and the relevant dependents.

**Collateral effects and preservation.**

I found no unintended changed error, ordering rule, exclusion lifetime, retention rule, theorem statement, guard hypothesis, or retained negative-control assertion.

There are visible scope and fixture changes worth recording:

- Every form changes `WIR-17`’s previously unqualified literal-true rule to a paid-create condition. For a genuinely free create, that sentence no longer independently requires acknowledgement. This is an expressly offered scope correction, not an invisible editorial change.
- Every form selects paid fixtures in `CNF-34` and the acknowledgement paragraph of `CNF-342`. The missing api-filled field, caller-field error distinctions, complete-record controls, and install assertions remain. I found no prescribed free-create assertion that this removes.
- `CNF-364` now explicitly supplies `allow_orders: true` and `acknowledge_purchase: true`, allowing its intended List offers capability refusal to remain reachable.
- Retained `CNF-182`’s “API returns a `Cancelled` transaction” wording remains a pre-existing boundary/test-mode concern. Broadening the paid-create scope does not introduce it.
- The inspected formal admission model explicitly states that “descriptor construction [is] outside this model.” The proposals do not change its supplied capability Boolean, the capability-before-tail theorem, or its negative witness.

Mixed free/paid offers do not produce a new ambiguity requiring repair. If one account capability permits both, it “permits a paid create”; false therefore withholds the entire capability. Even a free offer using it is then refused by the capability gate. With the flag true, the acknowledgement condition applies to paid creates. This preserves the offered account-level mechanism rather than introducing a per-offer runtime capability decision.

C/D’s fixture is expressly otherwise sellable and internally permissive, with a successful control. Its statement—

> “it does not authorize sale of a live offer withheld under `PRV-13b` or `PRV-31`”

—preserves the separate live-sale restriction.

The strongest reason to prefer **A’s minimal footprint** is that its normative scope is already sufficient: it changes the definition and dependent wording while retaining existing checks, avoiding additional fixture detail and future checklist maintenance. A missing new hourly test is not proof that A permits hourly spending with ordering off.

My actual pick remains **C**. It keeps the scope definition in one place and expressly tests the precise hourly/no-setup-fee failure, independently tests acknowledgement with ordering enabled, and covers both claim-time failures with simulated billing observations.

This was a read-only review. No source, Git state, tracker, or panel record was changed; no gates, builds, runtime tests, provider calls, or subagents were run.

### END r89 astra answer

### BEGIN r89 sol answer

Final: C

| Printed form | Verdict | Missed sites | Required repair |
|---|---|---|---|
| A | ACCEPT | None found | None |
| B | ACCEPT | None found | None |
| C | ACCEPT | None found | None |
| D | ACCEPT | None found | None |

These are acceptances of the printed packages without edits. My preference is C.

I checked the pinned evidence excerpts and retained blocks against this clone at `3109b5b44eae17e288cf52aaa976993bd8c5626c`; they match. I found no verified premise-changing brief error and no other source misquotation. Applying notes.md rule 6 exactly, I have no basis to void this question’s tally.

**Scope and coverage.** A/C define the relevant property once: “A **paid create** is a create that starts new provider billing to the operator,” expressly including “hourly or other recurring machine rental” and requiring neither a setup fee nor immediate payment. B/D print that same property at the consuming sites. None depends on a company allowlist, invoice date or undefined provider class.

For each form, I found no missed replacement after inspecting the supplied coverage list and following its references. The packages address `DOM-16`, `PRV-10`, `API-15`, the configuration row, provider-notes Create row, DEF-17 paragraph, wire field rule and the printed checklist dependents.

The retained consumers remain usable:

- `OPS-43` quotes “explicit purchase acknowledgement” and “the account is configured to allow ordering”; both strings survive in every proposed `PRV-10`.
- `API-7` retains “gate a create on its ordering capability” and “A refusal stops here and is not collected by the tail.”
- `DOM-15` retains its exception for “An ordering capability withheld under `DOM-16`”; `PRV-4` likewise keeps that withholding exception.
- `WIR-29` says the listing’s capabilities are “the descriptor’s fields, rendered.” The revised descriptor condition therefore reaches discovery without introducing another declaration mechanism.
- The retained `CNF-344` statement, “Another channel’s mere declaration authorizes no new ordering capability,” remains compatible.

**Hourly create, ordering off.** Consider the otherwise valid hourly catalogue fixture, with positive recurring provider price, no setup fee and `acknowledge_purchase: true`.

In A/C, the proposed definition makes this a paid create. Their `DOM-16` then makes an ordering capability “that permits a paid create MUST be conditional” on `allow_orders`; with the flag false, the descriptor “does not declare that capability.” B/D reach the same result through their expanded predicate.

`DOM-10` requires capability gating “before the driver is called, **including create**.” Consequently, the listing omits `provision_virtual`, and the fresh create fails at admission step 5d. Every form’s `CNF-55` retains the HTTP `501`/`unsupported` assertion, account and capability details, `retryable: false`, and no operation or commitment. Its deliberately insufficient-balance case also retains **no** `details.refusals` or `details.not_checked`: the ordering refusal precedes the purchase tail.

C/D additionally require this outcome on the explicit hourly fixture, with no provider request, zero driver create calls and zero simulated billing starts. Their permissive driver and successful control make the rejection meaningful.

**Hourly create, ordering on, acknowledgement absent or false.** Enabling the capability satisfies only the configuration half. Every proposed `PRV-10` still says “Both, not either.” Every proposed `API-15` requires the request’s acknowledgement, and every proposed `WIR-17` requires `acknowledge_purchase` to be literal `true` within the same billing scope.

Thus omission and `false` fail body validation before an operation or commitment opens. C/D explicitly assert separate HTTP `400`/`invalid_request` cases, `details.field: "/acknowledge_purchase"`, `retryable: false`, no provider request and zero billing starts. They also require a fresh-key control with both values true to call the fixture driver exactly once and record one simulated hourly billing start.

A/B state the same obligation but lack those dedicated hourly admission fixtures. That is a difference in demonstration strength, not a narrower billing scope or a contradiction. Notes rule 3 expressly says, “A merely absent new runtime test is not a contradiction in the unchanged base.”

**C/D’s worker cases.** The hourly restart case admits while both authorizations hold, leaves the operation queued and unclaimed, and changes only `allow_orders`. The proposed assertion then rejects at `OPS-43` step 3 with `unsupported`, the account/capability details and `retryable: false` on both error and operation view. It requires `failed`, full commitment release, no setup-fee or first-unit debit, no provider request—including no List offers read—and zero billing starts.

The separate stored-acknowledgement case removes only that caller field. `OPS-23` says a missing caller-supplied field “fails `invalid_request` naming the field,” with `retryable: false` on both error and view. C/D assert that step-3 outcome and the same release and no-provider-request consequences.

These follow the unchanged worker ordering: `OPS-43` says caller-field checks “run first, then the checks on fields the `api` wrote at admission, then the capability gate.” The subsequent List offers read remains at step 4.

The exclusion distinction is preserved. `PRV-42` says, “Catalogue products do not take this claim.” C/D accordingly give the hourly catalogue fixture no resource-offer exclusion. They retain the original resource-offer case’s acquisition and settlement-release assertions; the revised `CNF-342` acknowledgement paragraph retains them too. The revised `CNF-364` supplies both authorizations before removing only `list_offers`, preserving its intended step-4 failure.

**Collateral effects and maintenance.** I found no unintended blocking loss meeting notes rule 3. The existing refusal ordering, stored replay, error/view agreement, commitment release and resource-offer exclusion checks remain. Every form retains `CNF-55`’s “same-key, same-body replay … returns its stored result”; the revised scope does not move that replay behind the capability gate.

There are substantive distinctions to disclose:

- All forms condition the formerly unqualified wire sentence, “`acknowledge_purchase` MUST be literal `true`,” on the selected billing scope. That sentence consequently no longer imposes the acknowledgement on a genuinely non-billing create. This is part of the offered scope correction, not a purely typographical change.
- All forms select paid fixtures for the acknowledgement-dependent `CNF-34` and `CNF-342` cases.
- C/D add implementation-conformance obligations. Their simulated billing assertions are stronger than A/B’s existing checks.
- B/D distribute the billing predicate across the normative requirements, catalogue and dependent text. That is a departure from the repository’s drafting discipline: `AGENTS.md` says, “One rule, one home; everywhere else points at it.” The repeated predicates currently agree, but future amendments must keep those copies synchronized. I do not treat that maintenance objection as a verified blocking loss under notes rule 3; it is a substantial reason to prefer A/C.

A mixed free/paid capability creates no ambiguity requiring repair. The proposed condition concerns a capability “that permits a paid create.” If it permits both free and paid creates, false withholds the **whole capability**, so free creates through it are refused too. The wording does not authorize retaining that capability and substituting a per-offer runtime spending gate.

The retained Robot assertion about an absent acknowledgement returning a `Cancelled` transaction is a pre-existing concern: the same text is pinned and retained in every form. It is not a newly introduced inconsistency. Likewise, C/D explicitly say the fixture “does not authorize sale of a live offer withheld under `PRV-13b` or `PRV-31`.”

**Strongest argument for the minimal footprint:** A resolves the wording question, centralizes the scope and preserves the existing checks without adding fixture and simulated-billing obligations. Nothing in the settled decision requires a newly specified hourly fixture, and the revised obligations already cover hourly creates.

My actual pick remains **C**. It combines that single scope owner with direct checks of the motivating hourly failure and the independent acknowledgement requirement, while preserving the existing assertions.

This was a read-only assessment of the proposed text. I ran no gates or runtime tests and changed no source, Git state or tracker records.

### END r89 sol answer

