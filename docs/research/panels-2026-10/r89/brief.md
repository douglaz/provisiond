# Panel J r89 — pv-9ecf: exact wording for every paid create

Read this brief and `/var/tmp/provisiond-panel-r89/notes.md` whole. Each reader has an independent clean clone pinned to origin/master **3109b5b44eae17e288cf52aaa976993bd8c5626c**. The owner already decided policy. This is one exact-form wording question, not a vote on whether hourly cloud creates are covered. No source has been amended.

Read-only: do not change source, Git state, tracker, panel records or any main-checkout content; do not commit, push, checkout, reset, stash, clean, contact a PR, start subagents or background work. Do not run `lake build`, the formal gate, or `check-all.sh`; the manager runs the required gates in a separate clone and readers share the host's formal-build limit. Temporary files may be written only under `/var/tmp/provisiond-panel-r89/tmp/<your-seat>/`. Do not read credential/session/config locations (`~/.claude`, `~/.codex`, `~/.grok`, authentication files, kubeconfig, browser profiles), other reader outputs/clones, or unrelated main-worktree content. Pinned sources in your own clone and this packet are the evidence. No internet or live provider call is needed. Return a substantive final answer within the 3600-second launcher limit; aim for <=2000 words plus any complete exact alternative. Do not wait on other readers.

**apply notes.md rule 6 exactly as written; this prompt adds no void rule.**

## Fixed owner decision, verbatim

Source: `/var/tmp/provisiond-manager/owner-decisions-1030.md` item 4, 2026-10-30 (a decision after the pin, not claimed to be in it):

Question: "When an account has ordering switched off, which creates should that block?"

Answer: **"Every paid create (Recommended)"**.

Option text shown: "The switch and the per-request purchase acknowledgement cover any create that starts billing, hourly cloud VMs included. 'Orders off' means the account can't spend. Cost: cloud accounts also need the switch on, and each cloud create carries the acknowledgement. This is the 10-27 triage's pick. The exact wording gets a panel read before it lands."

Rejected: **"Upfront purchases only"**. A candidate excluding hourly rental is out of scope and cannot count as an alternative. The policy is not a panel question. `pv-kv2`'s queued-after-suspension mechanics belong to Panel D r83 Q4 and are not to be re-asked here.

## Plain-terms failure story and the one question

An operator turns ordering off on a cloud provider account. A caller sends a request for a machine rented by the hour, with the purchase acknowledgement present. There is no setup fee. An implementation that interprets the old words as covering only upfront purchases could still rent this machine and start the operator's hourly bill. The owner has decided that it must be blocked. Separately, turning the switch on does not waive the acknowledgement on each paid create.

The pinned motivating evidence below contains the four undefined phrases, and `CNF-55` still opens with "Create against an order-billed provider". This is a wording gap at the pin, not evidence that a running engine has actually charged anyone. We make no assertion that both old readings conform, or that the repository gates test an engine. The proposed hourly checks are implementation-conformance checklist cases, not a new repository gate or a live purchase authorization.

**Q1 — Which complete printed form lands the owner's decision?** Choose A, B, C or D. Separately mark each exact form ACCEPT or CANNOT ACCEPT, name every site it misses, and identify any exact repair it needs. The forms are defined in the candidate sections below:

| Form | Scope wording | Check coverage |
|---|---|---|
| A | Define **paid create** once in `DOM-16`; consuming sites cite it | Scope correction of existing checks |
| B | Spell out the same billing property at each site | Scope correction of existing checks |
| C | Define **paid create** once in `DOM-16`; consuming sites cite it | A plus explicit hourly cases in `CNF-55` |
| D | Spell out the same billing property at each site | B plus explicit hourly cases in `CNF-55` |

A is the minimal defined-term form; B is the self-contained shape. C and D expressly fail an engine that starts hourly billing with ordering off and separately cover the hourly acknowledgement requirement. These are alternatives as complete packages, not a mix-and-match request. All implement the triage row's explicit billing-property direction, with the owner's broad scope. No-change and upfront-only forms are not defensible under the settled decision. A narrower edit footprint without new hourly fixtures is already represented by A and B; it must not be read as a narrower billing scope. A self-contained predicate repeats scope text and must be assessed against the repository's one-owner convention, rather than silently treated as equivalent maintenance cost.

The property is tied to the creates a capability permits on the named provider account, rather than the provider's invoice date, a company-name allowlist or an undefined provider class. Withholding the whole account capability preserves the existing descriptor mechanism; the text does not introduce a new descriptor field. If mixed free/paid offers under one capability expose a real ambiguity in an exact form, show the trace and repair without narrowing paid coverage or changing the account-level control into a per-offer runtime gate.

## Verification and coverage map

`check/bead.json` is the pinned committed `pv-9ecf` row, read without the shared `br` database. Its status is open/needs-triage. Its report and the 10-27 table row predate the owner's decision. `check/undefined-phrases.txt` and `check/dependencies.txt` are full tracked Markdown searches excluding archived panel history. Those searches and the quoted source below are the coverage list; there is no inferred universal claim that grep alone proves semantic completeness.

The direct checklist dependents are printed whole where practical: `CNF-18`, `CNF-19`, `CNF-34`, `CNF-55`, `CNF-182`, `CNF-342`'s acknowledgement paragraph, `CNF-364`, and the retained `CNF-344` channel declaration case. An item marked Retain verbatim is part of that exact candidate and is intentionally not an edit. The provider-notes Create row and DEF-17's historical phrase are also included so neither leaves a conflicting alias. WIR-17's literal-true field rule gets the same scope predicate. Other source paragraphs outside the exact replacement ranges retain their pinned bytes.

`OPS-43` quotes `PRV-10`'s "explicit purchase acknowledgement" and "the account is configured to allow ordering"; both strings remain in every replacement, so that consumer needs no quote repair. `API-7`'s step 5d remains a pointer to the existing capability gate. `PRV-4` and `DOM-15` retain their capability-withholding exception and cite its owner. The pinned `CNF-182` Robot test-mode outcome is printed verbatim and not being redesigned in this wording question; distinguish a pre-existing concern from a new inconsistency introduced by a form. Archived panel records, withdrawn-identifier descriptions and recorded past decisions are historical evidence, not replacement sites.

The existing live sale restriction is a separate rule. `ADR-0010` says "Cloud, DigitalOcean and Robot 10 Gbit offers remain withheld until the live evidence gate in `ADR-0039` re-admits an offer." The hourly cases use an otherwise sellable fixture so a separate sale refusal cannot mask a missing ordering gate. Nothing in a form re-admits a live offer or authorizes a provider purchase.

## Pinned evidence, verbatim

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

## Reader response contract

1. Check whether the packet contradicts itself or misquotes the pin. Identify any such error exactly; apply notes.md rule 6 exactly as written; this prompt adds no void rule.
2. Give `Final: A|B|C|D|<one complete exact alternative>` and an ACCEPT / CANNOT ACCEPT line for **each printed form**. An acceptance with edits is not acceptance of the printed form: supply the complete repaired form (all its replacement sites), and identify its changes. Keep preference separate from acceptance.
3. For every form, name a missed site if any, or state that you found none after inspecting the quoted evidence and your clone. Follow references beyond the search list if needed. In particular check the wire acknowledgement field, worker repetition, listing capability, low-balance refusal order, stored idempotent replay, and the resource-offer versus hourly catalogue distinction.
4. Trace the hourly no-setup-fee create with ordering off, and the hourly create with ordering on but acknowledgement absent or false. Explain which wording and which assertion reject them. For C/D check the claim-time restart and the missing stored acknowledgement too. Test descriptions are reviewable proposed text; do not claim runtime execution.
5. Identify any obligation, error, order of checks, quote, exclusion, retention rule or test strength the form inadvertently changes beyond the owner's decision and the explicitly offered hourly test addition. A blocking loss must meet notes.md rule 3. Do not silently weaken an existing check or propose a second scope owner without describing that maintenance tradeoff.
6. Give the strongest reason, **on request**, to prefer the minimal wording-only footprint over adding the hourly check, then state your actual pick. That counterargument is not your vote. If no printed form is acceptable, supply one complete exact form covering every affected site; no unreviewed manager synthesis will count later.

This turn only launches this round. It does not tally, adopt, edit the specification, write the tracker, run a follow-on round, start implementation or open a PR.
