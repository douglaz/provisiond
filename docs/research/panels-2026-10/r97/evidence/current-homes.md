# Exact current homes at 2e2cd94637112f20538eb26b141672fedf0ba455

## DOM-10 — 01-domain-model.md:515

````text
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
539: 
540: *Amended 2026-10-22 (`pv-009`, `pv-p3k`; panel r62, `docs/research/panels-2026-10/r62/`; owner decision 2026-10-22): every capability check failure carries `retryable: false`, which is how the `pv-p3k` ruling "MUST, not retryable" reaches `API-7`'s step 5d and `OPS-43`'s claim-time gates.*
541: 
````

## DOM-16 — 01-domain-model.md:570

````text
570: **DOM-16** Ordering capabilities (`provision_virtual`, `provision_bare_metal`) for providers that bill per order MUST be conditional on an explicit per-account `allow_orders` configuration flag: the descriptor (`PRV-44`) of an account whose flag is false does not declare them, so that a misconfigured deployment cannot spend money. This is in addition to, not instead of, the per-request purchase acknowledgement
571: (`API-15`).
572: 
573: *Amended 2026-10-22 (`pv-p3k`; panel r62, `docs/research/panels-2026-10/r62/`; owner decision 2026-10-22): applied the reviewed ordering-capability change.*
574: 
575: ## Error taxonomy
576: 
577: One closed set of error kinds, used by drivers, the rescue engine, and the API alike.
578: 
579: | Kind | Meaning | HTTP |
580: |---|---|---|
581: | `invalid_request` | Caller error, deterministic | 400 |
582: | `not_found` | Named resource does not exist | 404 |
583: | `conflict` | State or idempotency conflict | 409 |
584: | `unsupported` | Capability not declared or not implemented | 501 |
585: | `authentication` | Caller or provider credential rejected | 401 |
586: | `rate_limited` | Caller or provider throttled | 429 |
587: | `provider` | Provider returned an error response | 502 |
588: | `network` | Transport failure reaching the provider | 502 |
589: | `timeout` | Operation exceeded its deadline | 502 |
590: | `integrity` | Digest or host-key verification failed | 422 |
591: | `internal` | Defect in this system | 500 |
592: | `insufficient_balance` | Available balance cannot fund the required commitment (`LDG-9`) | 402 |
593: | `not_activated` | Tenant exists but is still pending funding (`API-35`) | 403 |
594: | `halted` | Refused while a solvency halt is in force or a rate is unavailable (halt transitions: `LDG-40`; consequences: `LDG-20`) | 503 |
595: | `gone` | Resource existed and was removed by retention (`STO-14`, `STO-33`) | 410 |
596: | `suspended` | Tenant is suspended; only the maintenance actions remain (`API-58`) | 403 |
597: | `ceiling_exceeded` | A per-principal ceiling for the current interval is exhausted (`SEC-39`) | 429 |
598: | `overloaded` | The replica obtained no store connection within the checkout bound; refused before any transaction (`STO-55`). Retryable; the refusal leaves no receipt of its own | 503 |
599: 
````

## PRV-10 — 02-provider-contract.md:159

````text
159: **PRV-10** For a provider that bills on order, create MUST reject the request unless the
160: request carries an explicit purchase acknowledgement (`WIR-17`'s top-level
161: `acknowledge_purchase`), *and* the account
162: is configured to allow ordering. Both, not either. The configuration half is `DOM-10`'s gate on the create's ordering capability (`DOM-16`): `API-7`'s step 5d at admission and `OPS-43`'s step 3 at claim.
163: 
164: *Amended 2026-10-22 (`pv-p3k`; panel r62, `docs/research/panels-2026-10/r62/`; owner decision 2026-10-22): applied the reviewed ordering-capability change.*
165: 
````

## API-7 — 04-api-contract.md:159

````text
159: **API-7** **Authentication MUST happen before request-body validation.** An
160: unauthenticated caller MUST NOT be able to learn anything from validation error text, and
161: MUST NOT be able to make the server do parsing or policy work. See `DEF-4`.
162: 
163: **AMENDED 2026-09-04 — steps 2 and 5b test a TENANT, and an operator principal has none of its
164: own.** Every step still runs for every authenticated write, operator writes included: they carry
165: `Idempotency-Key` (`WIR-24`) so step 3 and 5a are load-bearing for them, and `SEC-39`'s ceilings at
166: 5c are the operator's whole budget. What changes is **whose** tenant steps 2 and 5b read, and what
167: step 4 authorizes against:
168: 
169: - **Every operator verb skips 2 and 5b**, whether or not it names a tenant. *Until 2026-09-08 one
170:   verb was excepted — `adopt`, the one that bought against the named tenant — and `ADR-0020`
171:   withdrew it; the exception returns with the verb. The list was stated as a one-verb list and not
172:   as "wherever a tenant is named", because the second reading — a repair of
173:   2026-09-04 — refused the operator surface on its ordinary inputs: `WIR-42`'s attribution target
174:   "MAY be `pending`, the ordinary case since a returning customer enrols afresh", so the only route
175:   back for an orphaned balance failed `not_activated`; and opening, closing, transmitting, revising a
176:   deadline and recording a restriction all name a tenant the operator may have just suspended for
177:   silence, so `SEC-45`'s escalation refused the case it escalates.* The principal is authorized by
178:   being on the operator listener (`WIR-34`) and bounded at 5c.
179: - **Step 4** authorizes the target resource by **existence** rather than by ownership for an
180:   operator, since cross-tenant reach is the point of the surface.
181: 
182: *Step 2's own amendment already had this idea — revoke, resolve and resume are "authorized by
183: principal rather than by tenant state" — and then expressed it as an allowlist while the
184: operator surface grew to suspend, attribute, assign-provider-account, record-status,
185: record-network-restriction, revise-deadline, address-resolution and `WIR-44`'s three abuse verbs.
186: Read literally, every one of those was rejected at step 2 for a tenant the principal does not have.
187: A first repair on 2026-09-04 over-corrected, exempting operators from 5b outright — which deleted
188: the ordering refusal above, since it lives on an operator-only verb and no other step performs
189: it. The carve-out is about the principal having no tenant **of its own**, and nothing more.*
190: 
191: **The tail is per endpoint class, because one universal pipeline was wrong for four of
192: the five classes.** Steps 1–5 are common to every authenticated write:
193: 
194: 1. authenticate, resolve principal;
195: 2. **reject a tenant that has never been activated** — a `pending` tenant fails `not_activated`
196:    (`API-35`), **except** the `API-43` allowlist and the **maintenance actions**: revoke
197:    (`API-56`), resolve and resume are authorized by principal rather than by tenant state,
198:    and gating them on an activated tenant would leave a suspended or pending tenant unable to
199:    replace a stolen credential —
200:    locking the owner out at exactly the moment the mechanism exists for. **This step is the
201:    issuance check and nothing else: it MUST NOT look at suspension.** A `suspended` tenant passes
202:    it and is rejected at 5b instead. *The withdrawn wording — "reject unless the tenant is active"
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
214:     suspended tenant through on purpose. It sits *after* 5a deliberately: a write replayed from
215:     before the suspension must return its stored result rather than a spurious rejection, and only
216:     the fingerprint check can tell a replay from a new write.
217:     **The abuse-statement write (`WIR-43`) is a maintenance action and MUST remain reachable while
218:     suspended**, and `API-58`'s retained reads extend to the case reads. Added 2026-08-16: `SEC-45`
219:     names an unanswered notice as a reason to suspend, so without this the operator's escalation for
220:     silence is what guarantees the silence — and the sentence `STO-40` exists to capture, the late
221:     one naming the actual cause, is refused at the moment it is most wanted. The write touches no
222:     provider and moves no money, which is the same ground `WIR-41`'s resume stands on.
223: 5c. **enforce `SEC-39`'s per-principal ceilings** and reject `ceiling_exceeded` (`DOM-17`) with
224:     `details.ceiling`, `details.limit`, `details.interval_seconds` and `details.retry_after_ms`
225:     (`WIR-9a`). **Added 2026-09-02**: `SEC-39` is the control that replaces a per-request
226:     acknowledgement when the caller is a program, `CNF-69` tests it, and **no step of this
227:     pipeline checked it** — so a builder following these steps literally shipped no ceilings at all
228:     while the requirement and its test both existed. It sits **after** 5a and 5b for the same
229:     reasons those sit where they do: a replay must return its stored result rather than spend a slot
230:     it already spent, and a suspended tenant is refused before its budget is consulted. It sits
231:     **before** the tail, so a ceiling refusal happens before any commitment opens and before
232:     anything is enqueued.
233:     **The exemptions are these, and no others.** `OPS-39` exempts exposure-reducing **system**
234:     cancellations, because a tenant that hit its destruction limit would otherwise keep machines it
235:     cannot pay for at the operator's expense — though that sweep enqueues directly and never
236:     traverses this pipeline, so the exemption bites here only on the other one: `SEC-39`'s stated
237:     override path for a genuine incident is the operator's, recorded as the uncapped thing.
238:     **`API-64`'s retry is not exempt**: it counts against `SEC-39`'s operator retry ceiling, and
239:     the operator is a program (`SEC-39`), so a loop retrying a deterministic rejection is exactly
240:     what the ceiling is for (`ADR-0017`).
241: 5d. **gate a create on its ordering capability** under `DOM-10` (`PRV-10`, `DOM-16`). A refusal stops here and is not collected by the tail.
242: 
243: The tail then depends on what the endpoint does:
244: 
245: | Class | Tail |
246: |---|---|
247: | **create** | evaluate the rich purchase tail below; on admission, commitment + operation in one transaction (`LDG-11`, `LDG-35`), then `202` |
248: | **power, install, reverse-DNS, refresh, rescue inventory** | enqueue an operation, then `202`. **No commitment**: they are not purchases, and they pass no spending gate |
249: | **retry** | operator-only (`API-64`, `WIR-51`); synchronous, `200` with the episode view; the episode's state change, the enqueue of a fresh `delete_machine` attempt and the idempotency record commit in one transaction (`WIR-24`); **no commitment and no spending gate** — the attempt reduces exposure, on the delete row's reasoning |
250: | **suspend** | operator-only; enqueue one cancellation per machine, then `202` (`API-58`) |
251: | **release attachment** | operator-only (`API-65`, `WIR-52`); on an `api` row enqueue one `release_attachment`, then `202`; on a `manual` row synchronous `200`, writing `released_at` (`API-48`); **no commitment and no spending gate** — it reduces exposure, on the delete row's reasoning |
252: | **revoke** | operator or recovery-credential principal (`API-56`, `WIR-38`); synchronous, `200`, no provider mutation (`API-48`) |
253: | **keep** (*added 2026-10-04, `pv-gip.11`*) | operator-only, synchronous `200` (`API-68`, `WIR-55`); **no commitment and no spending gate**; admission follows this pipeline, with no retry-ceiling treatment |
254: | **resume, resolve** | **operator-only** (`WIR-41`, `WIR-35`, `WIR-34`); synchronous, `200`, no provider mutation (`API-48`). The recovery credential reaches **neither** — `API-55` confines it to `API-56`, and a recovered-after-theft credential that could resume its own tenant or resolve an uncertain provider mutation would undo the suspension that answered the theft |
255: | **delete, cancel** | enqueue an operation, then `202`, and **bypass the rate and solvency gates entirely** — these reduce exposure, and refusing them because exposure is too high is the failure `LDG-20` already forbids |
256: | **deposit** | synchronous; allowed while pending; **refused `halted` while `LDG-20`'s solvency halt is in force** — that halt stops top-ups *first*, and minting a destination invites exactly the payment it forbids; otherwise **mints a destination and writes NO ledger entry** — a deposit is not money until it settles (`LDG-47`) — plus an idempotency record, in one transaction; `200` |
257: | **extend-runway** | evaluate the rich purchase tail below; on admission, the guarded extension (`LDG-62`) and idempotency record commit together (`WIR-24`); synchronous `200` |
258: | **abuse-case writes** | the tenant's statement (`WIR-43`) and the operator's five verbs (`API-60`, `API-61`) — synchronous, **no commitment, no spending gate, no provider mutation**; `201` on create and on a statement, `200` on the rest; each carries `Idempotency-Key` under `WIR-24`'s one-transaction rule. The statement write is a maintenance action and stays reachable while suspended (step 5b) |
259: | **attribute** | operator-only (`WIR-42`); synchronous, `200`; posts ledger entries, so it **takes `LDG-35`'s serialization for both tenants, in ascending tenant-identifier order**, and the primitive must not require a live `tenants` row — the source tenant is normally already reaped |
260: | **record billing** (*added 2026-10-04, `pv-gip.39`*) | operator-only (`API-66`, `WIR-53`); synchronous `200`; local row and receipt commit together; no provider mutation, commitment or spending gate |
261: 
262: **Rich purchase tails (create and extend-runway only; amended 2026-10-04, `ADR-0030`).** After steps 1–5d, the tail MUST
263: collect every applicable refusal once, from one read-only snapshot inside the existing `LDG-35`
264: transaction, without an extra lock, ceiling slot, write or provider call. On create, the offers the check reads are the provider account's stored offer listing (`05-persistence.md`, `offer_listings`), read in that snapshot, and the tail prices the commitment and takes the offer snapshot from it. On create, the tail reads the stored listing regardless of age, or an empty offers set if no listing is stored. If the tail has collected no refusal and the stored listing has a `read_at` older than the stated offer-listing age (`OVR-19`) at the admitting transaction, the create MUST be refused `provider` (`01-domain-model.md`'s error taxonomy) with `retryable: true` before any admission write, committing nothing. Every offer-derived input used to size the commitment or populate `request_summary` comes from the named offer in that same stored listing, including recurring price, currency, period, setup fee, `install_strategies`, and any offer-reported billing unit or cancellation bound. Descriptor-declared inputs come from the descriptor the `api` runs with. See `PRV-44`, `PRV-13b` and `05-persistence.md`. `details.refusals`
265: (`WIR-9a`) MUST be ordered: the request's own resource refusal (`conflict`/`state` for create
266: against a provider account not `healthy`, or `conflict`/`cancellation_committed` for extension);
267: then, on create only, `invalid_request`/`offer_not_sellable` when the named offer is
268: not sellable under `PRV-13b` or `PRV-31`, or absent from the offers the check reads;
269: then, on create only, `rate_limited` when the offer's account and ordering channel
270: are closed under `PRV-40`;
271: `halted`/`solvency`; `halted`/`rate_unavailable`; the commitment-cap refusal (`WIR-17`, `WIR-24`);
272: `insufficient_balance`. See `ADR-0030` for the order's rationale and `LDG-40` for halt retention.
273: An offer absent from the offers the check reads is an unsellable offer for every rule in this
274: tail, including cap and balance suppression and the `WIR-9a` `offer_not_sellable` refusal and
275: `not_checked` entries. No additional lookup is made for this verdict.
276: Both halted entries may appear; no duplicate
277: means no repeated refusal/check, not unique kind strings. The cap and balance checks MUST NOT
278: run without a rate, nor for create against an unhealthy account or unsellable offer:
279: `WIR-30` says "an account whose
280: `STO-47` status is not `healthy` `404`s on this route too". `WIR-9a` owns `not_checked`,
281: including cap presence, reasons and ordering. Each refusal is exactly
282: `WIR-9`'s inner error object, with no nested refusal list. Entry 0 is the headline: HTTP status,
283: `kind`, `message` and per-kind details MUST match it; top-level details additionally carry the
284: aggregate keys. Only top-level `retryable` may differ, under `WIR-9b`. Pacing belongs to the
285: headline: its `details.retry_after_ms` and `Retry-After` follow the existing per-kind rules and
286: `WIR-4`; each entry keeps its own required pacing. No maximum is taken and a subordinate
287: entry MUST NOT supply pacing to a headline kind that does not require it. A refused tail MUST
288: commit nothing and write no `STO-35` receipt (`WIR-3`), so clearing faults and resending the same
289: request/key evaluates afresh. Admission retains the conditional-write guards in `API-63`,
290: `LDG-62` and `PRV-42`; collection does not replace them with read-only guards. These are admission refusals
291: (`OPS-11`), never lists in operation views. Steps 1–5d still stop at their first refusal; see
292: those steps for their rationale. Deposit behavior and other tails are unchanged.
293: 
294: *Amended 2026-10-17 (`pv-14b`; panel r55, `docs/research/panels-2026-10/r55/`): included an offer
295: absent from the offers the tail reads in the unsellable verdict throughout the tail, without
296: an added lookup.*
297: 
298: **Amended 2026-10-10 (`ADR-0036`).** After an otherwise successful tail collection,
299: a create whose resource-offer conditional write affects no row (`PRV-42`) MUST receive an
300: ordinary HTTP `409 conflict`/`state` error with `retryable: false`, no
301: `details.refusals`, no synthesized pacing or `Retry-After`, and no commitment,
302: operation or receipt. This response is specific to the resource-offer guard.
303: 
304: *Amended 2026-10-09 (`ADR-0039`, `ADR-0030`'s Q12 amendment): an unsellable offer is a
305: create-only tail refusal after account health. It suppresses cap and balance evaluation,
306: while independent solvency and rate refusals remain collectible. A refused tail still
307: commits nothing, including no operation, machine, balance write, receipt or provider call.
308: The subordinate-entry pacing rule applies to every subordinate refusal.*
309: 
310: *Amended 2026-10-09 (`ADR-0036`, `ADR-0030`'s Q12 amendment): the stored
311: account-and-channel closure is a create-only snapshot input, collected after the offer
312: refusal and before solvency without a provider call or extra collection lock. It does
313: not suppress pricing checks or add a `not_checked` reason; `WIR-9a` owns that closed
314: reason set. The same request/key is evaluated again after a transient closure clears.*
315: 
316: *The withdrawn list applied the commitment and the spending gates to "every write endpoint", so a
317: literal builder opened a purchase commitment on a reboot and could be blocked from deleting a
318: machine during a rate outage — the one action that would have stopped the bleeding.*
319: 
320: **The attribute and abuse-case rows were added 2026-08-31.** Those endpoints had joined `API-48`'s closed list and `WIR-34`'s operator-route list and been
321: missed here, so a builder reached step 5b and the instructions stopped. `attribute` is the one that
322: mattered: it appends ledger entries to two tenants and nothing said it serialized.
323: 
324: The activation check, the spending-authority check and the commit-and-enqueue transaction were
325: all absent until 2026-08-12. The list was described as normative "for every
326: write endpoint", so **a builder following it literally shipped a create with no authorization at
327: all** — the money check existed in `12-billing-and-ledger.md` and in no sequence any handler
328: author would read.
329: 
330: *Amended 2026-10-22 (`pv-p3k`; panel r62, `docs/research/panels-2026-10/r62/`; owner decision 2026-10-22): added step 5d.*
331: 
332: ## Enrolment
333: 
334: Self-serve enrolment (`ADR-0002`) with no identity collected (`ADR-0005`) means the only thing
335: standing between a script and an unbounded table of tenant rows is this section.
336: 
````

## API-15 — 04-api-contract.md:1032

````text
1032: **API-15** A create request against an order-billed provider MUST carry an explicit
1033: purchase acknowledgement — `WIR-17`'s top-level `acknowledge_purchase`, which the wire contract
1034: owns — in addition to the account being configured to allow ordering (`PRV-10`). *"In its provider
1035: options" until 2026-09-05, while `WIR-17` placed it at the top level; the wire contract wins, and a
1036: spending authorization nested inside a driver-private object is one a strict server could not tell
1037: from any other option.*
1038: 
````

## OPS-43 — 03-operation-lifecycle.md:757

````text
757: **OPS-43** **The provider's price MUST be re-checked at claim, and the order refused where the
758: commitment no longer covers it.** A create is priced and its commitment sized when the API accepts
759: it; the purchase happens later, in a worker. `WIR-30` says an offer price is "an indicative quote
760: … `binding` is `false`", and the auction channel is a live market with other bidders in it, so the
761: provider's own price can move in that window — which on the dedicated product can be long, since
762: `OPS-33` records that robot-style orders poll through an `in process` state with no documented
763: bound.
764: 
765: **Sale re-test at claim.** At claim (`OPS-5`), before any provider mutation, the worker MUST
766: re-test the create's named offer for sale under `PRV-13b` and `PRV-31`, applying `API-7`'s
767: create-tail verdict: "`invalid_request`/`offer_not_sellable` when the named offer is
768: not sellable under `PRV-13b` or `PRV-31`, or absent from the offers the check reads".
769: The inputs are the descriptor the worker runs with
770: (`PRV-44`: "The descriptor is a typed, immutable value") and one current driver List offers
771: result taken at claim. Date bounds MUST resolve against provider-local today at the time of
772: the check.
773: 
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
785: 
786:    Next read this operation's tenant status. Where the tenant is suspended, fail this existing
787:    create with conflict, details.reason: "tenant_suspended", and retryable: false on both the error
788:    and operation view. This read precedes channel closure and boundary validation. Make no provider
789:    request, including List offers or a per-order key upload. Settle failed with full commitment
790:    release and no setup-fee or first-unit debit under OPS-11's pre-step-9 create rule; OPS-11 says "Any create failure the worker records before any step-9 request (before any per-order key upload or order request) MUST settle `failed`, whatever its kind." and “The commitment is released in full under `LDG-32` ("A commitment MUST be closed, and its remaining amount released in full") and `LDG-39` ("**Never debited**; released with the commitment (`LDG-32`)"), with no setup-fee or first-unit debit.”. Preserve
791:    requested_by and system_reason as originally recorded; do not emit the admission-only kind
792:    suspended. This is a plain read; the dispatch guard below closes the race after it.
793: 
794: 2. Read the stored channel closure (`PRV-40`: "the worker MUST read the stored closure for that
795:    account and ordering channel when it claims the operation (`OPS-5`), before any provider
796:    request, including a per-order key upload").
797: 3. Repeat boundary validation under `OPS-23`: "Validation that was performed at the API boundary
798:    MUST be repeated in the worker before the driver is called". This includes `PRV-10`'s
799:    "explicit purchase acknowledgement", `PRV-8`'s "at least one SSH public key", the missing-field
800:    checks defined in `OPS-23`, and `DOM-10`'s gate on the create's ordering capability, which is
801:    `PRV-10`'s "the account is configured to allow ordering". The checks on caller-supplied fields
802:    run first, then the checks on fields the `api` wrote at admission, then the capability gate.
803: 4. Gate on `list_offers` under `DOM-10`, then obtain the current driver List offers result.
804: 5. Check for the named offer's absence from that result, applying the create-tail verdict quoted
805:    above; if present, re-test the named offer for sale on that result and the running descriptor.
806: 6. Compare its price using that same List offers result, as below. An unsellable offer gets no
807:    price comparison.
808: 7. Run `PRV-47`'s driver validation: "the driver MUST validate every value it forwards to the
809:    provider, including provider options". For the rejection's error, see `PRV-47`.
810: 8. Perform `API-63`'s conditional write on `STO-47`'s row, in the correlator transaction:
811:    "the worker MUST repeat the admission check as a conditional write on `STO-47`'s row guarded
812:    on `healthy`". It remains "the last write before the ordering call" (`API-63`).
813:    In this same transaction the worker MUST conditional-write the operation's tenants row guarded
814:    on its status not being suspended. This write and API-58's admission-time suspension flag write
815:    MUST contend on that same row; a plain read or a lock confined to the earlier claim-time check
816:    is not a substitute; API-58 says "marks the tenant `suspended` **in the admission transaction, before the `202` is returned**". Where the tenant guard affects no row because suspension won, roll back
817:    the step-8 transaction and record conflict, details.reason: "tenant_suspended", retryable: false
818:    on both error and operation view, then settle failed under OPS-11's pre-step-9 rule with full
819:    release and no setup-fee or first-unit debit; OPS-11 says "Any create failure the worker records before any step-9 request (before any per-order key upload or order request) MUST settle `failed`, whatever its kind." and “The commitment is released in full under `LDG-32` ("A commitment MUST be closed, and its remaining amount released in full") and `LDG-39` ("**Never debited**; released with the commitment (`LDG-32`)"), with no setup-fee or first-unit debit.”. No step-9 key upload or order may begin. A first
820:    failed transaction commits neither about_to_order_at nor a correlator. A whole-transaction
821:    repeat after a lost acknowledgement rechecks this guard too: if suspension now defeats it,
822:    keep any previously committed about_to_order_at and correlator unchanged and settle the
823:    worker's recorded failure under the same pre-step-9 rule; do not add a null-column term to
824:    the settlement guard; OPS-11 says "Any create failure the worker records before any step-9 request (before any per-order key upload or order request) MUST settle `failed`, whatever its kind." and “The settle write keeps the ordinary worker guard (`STO-3`; `OPS-6`: "every write that worker makes to the operation MUST carry `claim_number = mine`"), with no `about_to_order_at IS NULL` term.”. OPS-49 says "the component MUST repeat the **whole
825:    transaction** — never the last failed statement, and never the provider call (`OPS-12`)" and "A
826:      serialization failure is repeated at once."; retry a serialization failure as a whole transaction and do not treat it as a tenant-status refusal. The operation-row claim guard and acknowledgement-before-
827:    step-9 rules remain required.
828:    In this same transaction, on every ordering channel, including `correlator: none`, the worker
829:    MUST set `operations.about_to_order_at` to `COALESCE(about_to_order_at, <transaction time>)`
830:    guarded on `(id, status = running, claim_number = mine)` (`STO-3`; `OPS-6`:
831:    "every write that worker makes to the operation MUST carry `claim_number = mine`").
832:    The write MUST NOT be guarded on the column being null: a whole-transaction repeat after a
833:    lost reply affects one row and changes nothing. If this operation-row write affects zero rows,
834:    something else moved the operation: step 9 MUST NOT run and the worker MUST exit. This differs
835:    from the zero-row `STO-47` check above, of which `API-63` says "where it affects no row MUST
836:    fail the operation deterministically". A first attempt that fails that check commits no
837:    `about_to_order_at`. If an earlier step-8 transaction committed but its reply was lost, and an
838:    account-status write makes the account non-`healthy` before the whole-transaction repeat,
839:    the repeat can fail that check with the column already set. The create still settles `failed`
840:    under `OPS-11`'s create row: `OPS-11` says "Any create failure the worker records before any step-9 request (before any per-order key upload or order request) MUST settle `failed`, whatever its kind."
841:    Step 9 MUST begin only after step 8's transaction is acknowledged. A lost acknowledgement
842:    MUST take `OPS-49`'s "repeat the **whole transaction**" path, never speculative dispatch.
843: 9. Perform the per-order key upload, then the order. Here **per-order key upload** means every
844:    temporary key registration required for this create (`PRV-9`: "the driver MUST register and
845:    attach them as temporary provider-side resources").
846: 
847: *Amended 2026-10-17 (`pv-k4l`; panels r56 and r56b, `docs/research/panels-2026-10/r56/` and `docs/research/panels-2026-10/r56/r56b/`): made step 8 write the column under the worker guard and await acknowledgement before step 9.*
848: 
849: *Amended 2026-10-21 (`pv-p1y`): pointed step 7's rejection at `PRV-47`.*
850: 
851: *Amended 2026-10-21 (`pv-xer`; owner decision of 2026-10-21): extended step 1's quote of `API-63`
852: to its `retryable` values.*
853: 
854: The first failing check stops subsequent checks; its owning classification governs disposition.
855: Claim-time refusals are not collected: the error carries neither `details.refusals` nor
856: `details.not_checked`. The order differs from admission: a create both closed and unsellable
857: fails `rate_limited` at claim (`PRV-40`: "If the channel is closed at that read, the worker MUST
858: make no provider request and settle the existing operation `failed` with `rate_limited`") but
859: `offer_not_sellable` at admission, where `API-7` orders "`invalid_request`/`offer_not_sellable`"
860: before "`rate_limited` when the offer's account and ordering channel are closed under `PRV-40`".
861: 
862: The sale re-test and price comparison apply to the named offer as that result lists it. At
863: claim (`OPS-5`), `PRV-42`'s dispatch check ("the driver MUST confirm that the named offer is
864: still listed before sending the order request") reads that same step-4 List offers result.
865: `PRV-42` says "a missing offer MUST NOT be ordered"; for an offer absent from that result, the
866: worker MUST NOT perform any step-9 provider mutation either, including a per-order key
867: upload.
868: 
869: If the offer is absent from that result or the re-test finds it unsellable, the worker MUST fail
870: the operation deterministically before any provider mutation, with `invalid_request`,
871: `details.reason: "offer_not_sellable"` and `retryable: false` on both the error and the operation
872: view. The operation settles `failed` under the create row. `OPS-11` says "Any create failure the worker records before any step-9 request (before any per-order key upload or order request) MUST settle `failed`, whatever its kind." The error is `WIR-9`'s inner object under `WIR-10b`; `WIR-9` says "The inner
873: `error` object is exactly `kind`/`message`/`retryable`/`details` and nothing else, because it is
874: the object `WIR-10b` embeds in an operation view". It carries neither `details.refusals` nor
875: `details.not_checked`; `WIR-9a` introduces those keys "**On create and extend-runway tail
876: refusals**". Its details obey `WIR-9a`'s "no cap or balance result or amount derived from the
877: withheld offer's price". The commitment is released in full under `LDG-39`'s
878: "Deterministic rejection before acceptance" case — before provider acceptance — with no setup
879: fee or first unit debited: that row says "**Never debited**; released with the commitment
880: (`LDG-32`)". `LDG-32` requires "A commitment MUST be closed, and its remaining amount released
881: in full" on, among its terminal outcomes, "the create fails deterministically".
882: Where the create holds a resource-offer exclusion, settlement frees it (`STO-58`: "Its lifetime
883: follows the winning create's outcome settlement"; `PRV-42`: "An unresolved create retains the
884: claim until its outcome is known").
885: 
886: *Amended 2026-10-18 (`pv-qga`; panel r57, `docs/research/panels-2026-10/r57/`; `ADR-0043`): pointed settlement at the create row and accounted for a lost step-8 reply followed by an account-status write before the repeat; that refusal can leave the column set.*
887: 
888: After the sale re-test passes, and before any per-order key upload or other provider mutation,
889: the worker MUST re-read the offer's current price from that same List offers result **in the
890: provider's own currency** and compare it with the native price the commitment was sized from — **carried on the
891: operation's `request_summary`, which MUST hold the accepted recurring price, its
892: currency and its period, and the accepted setup fee and prepaid first unit, the unit with its
893: `billing_unit.seconds`** (`LDG-2`, `LDG-67`; *the unit and its seconds added 2026-10-08,
894: `ADR-0033`, because the machine's row copies the seconds for its first seed, `LDG-38`,
895: `05-persistence.md`*; *the
896: fields are named so a worker restarted before claim can perform this comparison at all*; *named 2026-09-05 — a first form cited a native figure on the commitment
897: row, which carries only `reserved_sats`*) — and **fail the operation deterministically — before any
898: provider
899: mutation — where the provider's price has risen past what the reserve covers**: `conflict`,
900: `details.reason: "price_moved"`, the shortfall in `details`, telling the caller to re-submit,
901: and `retryable: true` on both the error and the operation view (`WIR-9b`). **A
902: movement in the satoshi rate alone MUST NOT refuse** — that is `ADR-0011`'s business, and it moves
903: the runway date rather than the order. *Corrected 2026-09-05. The withdrawn test was "recompute
904: `PRV-13b`'s reserve at the current rate … where the open commitment no longer covers it", and the
905: reserve carries the satoshi rate, so any downtick between accept and claim refused; the caller
906: resubmitted at the new rate, the next downtick refused again, and under a falling market creates
907: failed persistently on a product that had no shortage of provider capacity. It also named no error
908: kind, and `OPS-11` makes `insufficient_balance` admission-only, so a worker had nothing legal to
909: emit.* Same shape and same point in the lifecycle as `OPS-40`'s
910: signed-URL gate: it fails before anything is bought, so nothing ambiguous is created and no
911: reconciliation is needed.
912: 
913: **Nothing is grown.** This is a refusal, not a top-up, so `ADR-0011` is untouched — a commitment
914: still increases only by `LDG-62` and `LDG-63`'s scheduled-cancellation branch.
915: 
916: *The asymmetry that exposed it: the second order the set once admitted (`ADR-0014`, `ADR-0017`) was
917: re-priced because it "happens later — possibly much later". An original create has the same latency
918: and had no such rule, so the operator absorbed the difference silently and learned about it from an
919: invoice.*
920: 
921: *Amended 2026-10-16 (`pv-hsm`; panel r54, `docs/research/panels-2026-10/r54/`): added the
922: claim-time sale re-test, its inputs and the five-step claim order; tied `PRV-42`'s dispatch
923: check at claim to the step-2 result and barred any step-5 provider mutation for an offer absent
924: from it; specified the re-test's deterministic failure and pointed at `LDG-39` for the
925: commitment release.*
926: 
927: *Amended 2026-10-17 (`pv-14b`; panel r55, `docs/research/panels-2026-10/r55/`): completed the
928: claim order and its precedence, placed validation and account checks, and extended the offer
929: failure outcome to absence with resource-offer exclusion settlement.*
930: 
931: *Amended 2026-10-21 (`pv-xer`; owner decision of 2026-10-21): gave `price_moved` `retryable: true`
932: on the error and the operation view.*
933: 
934: *Amended 2026-10-22 (`pv-p3k`; panel r62, `docs/research/panels-2026-10/r62/`; owner decision 2026-10-22): applied the reviewed ordering-capability change.*
935: 
936: *Amended 2026-10-22 (`pv-009`; panel r62, `docs/research/panels-2026-10/r62/`): applied the reviewed claim-time capability gate and refusal checks.*
937: 
````

## WIR-17 — 13-wire-contract.md:659

````text
659: **WIR-17** **AMENDED** `POST /v1/machines` — create:
660: 
661: ```json
662: {
663:   "provider_account": "hetzner-robot-1",
664:   "offer": "market:12345",
665:   "region": "fsn1",
666:   "hostname": "worker-1",
667:   "image": null,
668:   "ssh_public_keys": ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIexamplekeyxxxxxxxxxxxxxxxxxxxxxxxx"],
669:   "user_data": null,
670:   "labels": {"team": "batch"},
671:   "runway_seconds": 2592000,
672:   "max_commitment_sats": 90000,
673:   "acknowledge_purchase": true,
674:   "provider_options": {}
675: }
676: ```
677: 
678: This create uses `WIR-30`'s `"market:12345"` Robot default-uplink offer; the
679: running operation (`WIR-10`) and resulting machine (`WIR-11`) show the same
680: purchase at later stages. `WIR-30` says "the commitment is priced at accept
681: time"; its earlier listing quote is indicative.
682: 
683: `ssh_public_keys` MUST be non-empty (`PRV-8`, `API-13`). `acknowledge_purchase` MUST be literal
684: `true` (`API-15`, `PRV-10`). `image` (nullable, a catalog identifier), `user_data` (nullable,
685: ≤1 MiB, `API-13`) and `labels` (string→string; the correlator's reserved key is the driver's, `PRV-26`, and a caller
686: label colliding with it MUST be rejected, `OPS-38`) are the create inputs
687: the other requirements accept and this body previously omitted — under `WIR-2` a conforming server
688: would otherwise reject them. `runway_seconds` is `PRV-13d`'s caller-chosen runway; a value **below**
689: the wind-down floor MUST be **rejected** `invalid_request` with `details.min_runway_seconds`, never
690: silently raised — silently reserving more of a caller's money than it asked for is a money bug.
691: `max_commitment_sats` (optional) caps spend: if the computed commitment exceeds it the request
692: fails `invalid_request` (not `insufficient_balance`) **before** any commitment opens, so an agent
693: can bound a purchase priced at an attacker-influenceable rate (`LDG-41`). `WIR-9a` owns its
694: cap details; `API-7` owns tail combination and ordering.
695: 
696: *`WIR-18` — `POST /v1/machines/adopt` — is withdrawn with adopt (`ADR-0020`). It returns as a
697: synchronous operator route in `API-48`'s list, answering with the machine view.*
698: 
````

