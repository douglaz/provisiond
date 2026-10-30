# Tally source verification at 3109b5b44eae17e288cf52aaa976993bd8c5626c

Excerpts independently obtained with git show. No source change.

## OVR-2 — 00-overview.md:22

````text
22: **OVR-2** Capability MUST be discoverable at runtime (`GET /v1/providers`). Clients
23: MUST NOT be required to infer support from a provider's name, and the server MUST NOT
24: accept an operation a provider has not declared support for. See `DOM-10`.
25: 
````

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

## DOM-13 — 01-domain-model.md:391

````text
391: **DOM-13** Only these pairings are valid; everything else MUST be rejected with an
392: invalid-request error before the operation is enqueued:
393: 
394: | Strategy | Valid image sources |
395: |---|---|
396: | `rootfs_via_rescue` | `rootfs_tarball` |
397: | `raw_disk` | `raw_disk` |
398: | `provider_native` | `catalog` (~~`ipxe`~~ and ~~`iso`~~ withdrawn, `DOM-22`) |
399: | `provider_catalogue` | `raw_disk` — the same caller input as a rescue raw-disk install, delivered by a different mechanism and with a different promise (`DOM-28`) |
400: 
401: A valid pairing is necessary and not sufficient. Capabilities are per **provider account**
402: (`DOM-10`), but rescue-install eligibility is a property of the **offer** — an auction listing and
403: a standard product at the same provider can differ — so the offer's `install_strategies`
404: (`13-wire-contract.md`, `WIR-30`) gates this table as well, and a strategy absent from it MUST be
405: rejected the same way. **The gate reads the machine's own copy of that list** —
406: `machines.install_strategies`, taken from the offer at create and never re-resolved
407: (`05-persistence.md`, `WIR-30`) — **not the offer as it stands at install time.**
408: 
````

## DOM-15 — 01-domain-model.md:564

````text
564: **DOM-15** A capability that is declared but whose code path returns "unsupported" is a
565: defect. Declaration and implementation MUST agree; the conformance checklist tests this
566: (`10-conformance-checklist.md`). An ordering capability withheld under `DOM-16` is excepted from that agreement (`PRV-4`).
567: 
568: *Amended 2026-10-22 (`pv-p3k`; panel r62, `docs/research/panels-2026-10/r62/`; owner decision 2026-10-22): applied the reviewed ordering-capability change.*
569: 
````

## DOM-16 — 01-domain-model.md:570

````text
570: **DOM-16** Ordering capabilities (`provision_virtual`, `provision_bare_metal`) for providers that bill per order MUST be conditional on an explicit per-account `allow_orders` configuration flag: the descriptor (`PRV-44`) of an account whose flag is false does not declare them, so that a misconfigured deployment cannot spend money. This is in addition to, not instead of, the per-request purchase acknowledgement
571: (`API-15`).
572: 
573: *Amended 2026-10-22 (`pv-p3k`; panel r62, `docs/research/panels-2026-10/r62/`; owner decision 2026-10-22): applied the reviewed ordering-capability change.*
574: 
````

## PRV-4 — 02-provider-contract.md:25

````text
25: **PRV-4** A driver MUST NOT declare a capability it does not implement, and — for every
26: operation with a capability entry in `DOM-10`'s table — MUST NOT implement one whose capability
27: it does not declare (`DOM-15`). The three methods with no entry there — *describe capabilities*,
28: *get machine* and *refresh rescue session* — are outside the second clause; `PRV-2` and `PRV-3`
29: govern them. An ordering capability that `DOM-16` withholds from an account whose `allow_orders` is false is not declared for that account, and a driver that implements it breaches neither this requirement's second clause nor `DOM-15`.
30: 
31: *Amended 2026-10-22 (`pv-p3k`; panel r62, `docs/research/panels-2026-10/r62/`; owner decision 2026-10-22): applied the reviewed ordering-capability change.*
32: 
````

## PRV-8 — 02-provider-contract.md:134

````text
134: **PRV-8** Create MUST require at least one SSH public key. The control plane MUST NOT
135: persist a provider-generated root password, so a machine created without a key would be
136: unreachable.
137: 
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

## PRV-13b — 02-provider-contract.md:296

````text
296: **PRV-13b** A system that resells a machine on prepaid terms MUST be able to bound its own
297: exposure before taking money, subject to `PRV-49`'s accepted residual: "an accident that no
298: adversary can cause: a stray address costs EUR 1.90 per month until noticed, with no operator
299: cap". *Amended 2026-10-11 (`ADR-0037`, Q23b).* That requires, per product: an API path to stop the cost, a bound
300: on the time until the customer's meter stops, and cleanup for every billable attachment
301: (`PRV-13a`, `PRV-45`); `PRV-49` is the enabling precondition for paths that can leave one
302: outliving its machine. Traffic overage is operator exposure too. Under `ADR-0039`, an offer
303: with `traffic_bound: unlimited` is sellable on this dimension; an allowance-bearing offer
304: MUST NOT be sold until a live test establishes counter freshness and bounds traffic after
305: the last reading through deletion under `ADR-0033`'s "priced, not amplified" criterion.
306: In this requirement, a traffic bound is declared for an offer exactly when the descriptor's
307: `traffic_bound` entry for that offer is non-null, or that entry is explicit `null` and the
308: offer reports a non-null `traffic_bound`: `PRV-44` says "Like `cancellation_bound`, it MAY
309: be reported on the offer instead". An offer with no declared traffic bound MUST NOT be
310: sold. An allowance-bearing offer
311: that passes the live gate declares allowance less headroom; see `WIR-30` for the
312: before-purchase disclosure. Crossing it would open an exposure-reducing cancellation
313: with future reason `traffic_allowance` beside `rate_outage_bound` (`OPS-39`, `STO-52`);
314: this path is deferred until re-admission, and no active reason or Fence branch is
315: created by this amendment. Wind-down funds the customer's meter through the gone-write. Its
316: latency allowance adds the waits in sequence: **`LDG-37`'s metering cadence + the mutating
317: provider call's deadline + `PRV-36`'s effective visibility window + `OVR-19`'s resolution-read
318: cadence + that read's own provider-call deadline + the worst-case machine-operation hold +
319: time margin**. `OVR-19` owns the deadline: "The deployment MUST state and enforce a finite, positive
320: provider-call deadline". Every term MUST enter the reserve at the customer rate, even when one
321: bound exceeds another. The visibility window begins at the end of the mutating call's wait,
322: whether a reply arrived or its deadline expired. `STO-53`'s dispatch-to-observation samples
323: widen the effective window; their stored timestamps do not move its start back to dispatch.
324: The provider's unit remainder is a different cost, absorbed by the operator under
325: `ADR-0033`; the accepted accounting gaps belong to `LDG-75`. *Amended 2026-10-08 (`ADR-0037`).
326: Amended 2026-10-09 (`ADR-0037`, Q13):
327: sequential wind-down waits. Amended 2026-10-09 (`ADR-0039`): traffic exposure, the sale gate
328: and conditional re-admission. Amended 2026-10-21 (`pv-nd6`): defined when a traffic bound is
329: declared — a non-null descriptor entry, or an explicit `null` entry with a non-null
330: offer-reported value; which source governs where both carry a value stays with `pv-2s6`.*
331: 
332: The reserve is computed **in the provider's billing currency** and converted once, when the
333: commitment is opened or re-sized, into the ledger unit:
334: 
335: ```
336: reserve_native = setup_fee                              # at cost, no markup (ADR-0006)
337:                + first_unit                             # the prepaid first billing unit, at the
338:                                                         # customer rate (ADR-0033; defined below)
339:                + requested_runway × customer_rate       # PRV-13d, customer-chosen
340:                + wind_down_cost                         # see below
341:                + billable_attachments                   # PRV-13a
342:                + cost_through_earliest_cancellation_date # exception branch only (PRV-13c)
343: 
344: commitment_sats = to_ledger_unit( reserve_native × (1 + conversion_haircut) )
345: ```
346: 
347: The `billable_attachments` term has no v1 value: no attachment has its own customer rate.
348: Enabling one requires an automatic, idempotent corrective credit for a stop learned behind the
349: subject's mark (`LDG-38`), a worst-case effective-date bound per attachment kind, and a
350: per-offer declaration of the kinds that an order creates. `PRV-44` describes
351: `surviving_attachments` as "the kinds that survive deletion"; this per-driver descriptor is
352: not an individual order's declaration.
353: *Amended 2026-10-10 (`ADR-0037`, Q18).*
354: 
355: *The `accrued_unbilled_usage` term was deleted from this formula on 2026-09-02.* Nothing produces
356: it: the sizing happens at create, where by construction no usage has accrued, and once the meter was
357: specified (`LDG-37`, `LDG-38`) consumption became a debit against the commitment rather than an
358: input to it. It is a survivor of the first version of the ledger — the one `12-billing-and-ledger.md`
359: opens by saying "consumed `accrued_unbilled_usage` in `PRV-13b`'s reserve formula and never said
360: what produced it". Deleted rather than tombstoned: nobody re-adds a zero term by accident.
361: 
362: **`customer_rate`, not provider cost.** The reserve must cover what the *customer* is committing
363: to spend, and since `customer_rate ≥ provider_rate` by construction, committing the customer
364: price also covers the operator's time-price exposure on sellable offers; the traffic sale gate
365: above is separately required. Using provider cost here would under-commit every
366: machine by exactly the margin. **The setup fee is committed at cost and debited at successful
367: settlement after acceptance** (amended 2026-10-08, `ADR-0035`; `LDG-39`: "an accepted but unresolved
368: create MUST take the `needs_reconciliation` pending-obligation row"), because `ADR-0006` passes it
369: through unmarked — the operator does not
370: profit from a fee it did not earn — and it is also a term that is entirely lost once the order
371: lands (the prepaid first unit, below, is another; *reworded 2026-10-08, `ADR-0033`*), so
372: it MUST be **fully committed before the order is placed**. *Both withdrawn
373: readings — "fully collected before the order" and "debited before the order is placed" — charged
374: the customer for a fee the operator never incurred whenever the provider rejected the order
375: outright or the create resolved absent.*
376: 
377: **The prepaid first billing unit is at the customer rate, where the fee is at cost** (`ADR-0033`,
378: added 2026-10-08). `first_unit` is the greater of `billing_unit.seconds` at the offer's recurring
379: price and `native_floor` (`PRV-44`), with the margin `LDG-24` applies — "The margin is a percentage
380: applied to machine time only (`ADR-0007`)" — because it is machine time; `ADR-0033`: "**Why the
381: customer rate and not cost.** The customer receives that hour." Like the fee it is entirely lost
382: once the order lands, so it MUST be **fully committed before the order is placed**, and like the fee
383: it is debited at successful settlement after acceptance (amended 2026-10-08, `ADR-0035`), as its own
384: kind and for the satoshi amount authorized here (`LDG-39`, `LDG-67`). On a floor-priced offer the floor
385: prices the unit and moves no instant:
386: `LDG-38` places an eligible first seed at "the seed instant plus the `billing_unit.seconds` the
387: machine's own row carries". A customer whose unit was debited and whose machine outlives `seconds` but not
388: what the floor's money bought at the provider pays the floor and then its metered seconds; the
389: difference is bounded by the floor and falls on the customer, never on the operator, so it is
390: priced and not amplified.
391: 
392: **`F18` fixed: there is one haircut and it belongs to the conversion, not to the sum.** The
393: earlier text trailed `× fx_haircut` after the formula without saying whether it multiplied the
394: whole reserve or only the foreign-currency part, and it conflated two different risks. They are
395: now separated:
396: 
397: - The **conversion haircut** covers the spread and the rate's staleness at the instant of
398:   conversion. It applies to the conversion, once.
399: - **There is no volatile-asset haircut**, because the reserve is no longer held in a volatile
400:   asset relative to its own liability. Under `ADR-0003` the ledger is denominated in satoshis
401:   and so is the customer's balance, so a bitcoin move re-prices the *customer's* purchasing
402:   power, not the operator's coverage. Movement is handled by re-deriving **`runway_until`** each
403:   period (`PRV-13e`, `LDG-33`) — *not by re-deriving the commitment, which `ADR-0011` withdrew* —
404:   and not by over-collateralising it once.
405: 
406: **`wind_down_cost` is conditional, and an earlier revision of this paragraph got it wrong in a way
407: worth recording.** That revision claimed `OPS-27` had reduced it from an on-call-rota figure
408: (24–72 hours) to minutes, because "a cancellation's true outcome is readable from provider
409: state." **The premise was false as stated.** `PRV-26`'s correlator is written by *create* and
410: identifies the create operation; a cancellation is a different operation with a different id and
411: nothing written provider-side, so there is no correlator to search for. That mistake mattered
412: because the claim was used to shrink a number every machine's reserve depends on — a
413: reconciliation error propagating into systematic under-reserving across the whole fleet.
414: 
415: The criterion is `PRV-29`'s "bound the time after which its evidence is truthful". Where the
416: driver can, size `wind_down_cost` from the sequential allowance above. **Where it cannot, the
417: pager-latency figure stands.** Scheduled-cancellation protection
418: remains the reserve formula's `cost_through_earliest_cancellation_date` (`PRV-13c`); see that
419: requirement for the exception branch.
420: 
````

## PRV-15 — 02-provider-contract.md:722

````text
722: **PRV-15** Begin rescue MUST both activate the rescue environment *and* initiate the
723: reboot or reset needed to enter it. The rescue engine waits for SSH; it does not reboot.
724: 
725: **Amended 2026-10-09 (`docs/research/provider-verify-2026-10.md`, V4/V10, retrieved 2026-10-06):** On Hetzner Cloud the driver MUST read `rescue_enabled` and disable an existing rescue activation before re-enabling it, then reset within the documented 60-minute auto-disable interval. On Hetzner Robot it MUST read `active` with `GET /boot/{n}/rescue` and disable an active rescue with `DELETE /boot/{n}/rescue` before re-enabling. Repeated-enable behavior remains `[verify]` for Cloud; Robot accepted a second activation for the next boot on 2026-10-12 (`docs/research/panels-2026-10/r45/live-session2.txt`). The disable-before-enable procedure remains required.
726: 
727: **Amended 2026-10-13 (`ADR-0041`, Q29).** On Robot, before activation, begin rescue MUST read `GET /boot/{server-number}/rescue/last` and retain its `boot_time` string as the baseline for this session, or no baseline when no record exists. Any other failure of this read MUST fail begin rescue before activation, with nothing to clean up. The baseline is driver refresh state in the in-memory session, never host-key pin material or durable state (`DOM-11`). The active-read and disable-before-enable procedure above still applies.
728: 
````

## PRV-25 — 02-provider-contract.md:851

````text
851: **PRV-25** The caller-supplied IP MUST have been verified by the control plane to belong
852: to the machine before the driver is called (`API-16`). The driver MUST still encode it
853: into the request path safely (`PRV-6`).
854: 
855: After the ordinary authorization, capability and `API-16` validation, the worker MUST compare
856: the requested PTR value with the machine's recorded value for that address under `OPS-8`'s
857: serialization. An identical established value MUST settle `succeeded` without a provider call.
858: Result shape: `WIR-10`. A missing or unknown value is not equality.
859: 
860: The machine's `reverse_dns` map records provider-established values by address. Drivers MUST
861: report those values when their machine read observes them, and the engine MUST store them;
862: unknown or unobserved values are absent. A confirmed completed write or authoritative resolution
863: MUST also record the established value. Enqueue, dispatch and acceptance alone MUST NOT establish it.
864: Before dispatching a differing write, the engine MUST invalidate the prior entry; uncertainty
865: MUST NOT leave that entry eligible for the no-op. Only provider evidence re-establishes it.
866: An address removed from `public_ips` loses its entry. For a request that reaches the provider,
867: classification remains under `OPS-11`: "On failure, the system MUST classify the error". *Amended 2026-10-08 (`ADR-0034`).*
868: 
869: ### Carrying a correlator
870: 
871: This is not an operation. It is an obligation on **create**, and it is what makes automated
872: recovery from an ambiguous outcome possible at all.
873: 
````

## PRV-44 — 02-provider-contract.md:79

````text
79: **PRV-44** The descriptor is a typed, immutable value: `account`, `kind`, `capabilities`,
80: `ordering_channels` (each with `correlator: operation_id | per_order_key | none`, `PRV-32`,
81: `PRV-33`, `PRV-38`, `offer_is_resource: true | false` (whether the offer names one machine, `PRV-42`), and
82: `order_budget: {limit, per}`, `PRV-40`), `evidence_sources` per mutation kind in descending strength (`PRV-36`),
83: `visibility_window` `{declared_seconds, sample_size, measured_on | unmeasured}` (`PRV-36`),
84: `cancellation_bound` per offer (`PRV-31`) — which MAY be reported on the offer instead —
85: `traffic_bound` per offer (`ADR-0039`) — `unlimited`,
86: `{allowance_bytes, headroom_bytes}` with nonnegative integer allowance bytes and
87: `0 < headroom_bytes ≤ allowance_bytes`; the resulting limit is
88: `allowance_bytes − headroom_bytes`, or explicit `null` where no bound is
89: declared. Like `cancellation_bound`, it MAY be
90: reported on the offer instead —
91: `billing_unit` per offer (`ADR-0033`, added 2026-10-08) — `{seconds, native_floor}`: the provider's
92: smallest charged span of machine time, in seconds — zero exactly where the provider charges exact
93: elapsed time with no minimum, a unit of no length under which the arithmetic is unchanged: nothing
94: is prepaid for time, `first_unit` is the floor alone or nothing (`PRV-13b`), and a machine's first
95: seed writes its mark at the seed instant (`LDG-38`) — and the money minimum on its price, a string
96: in the offer's currency as `DOM-9` carries every price and null where the offer has none; it is the
97: per-contract fact `PRV-13c` lists as billing granularity, and like the bound it MAY be reported on
98: the offer instead —
99: `rescue_address_family` (`RSC-45`), and `surviving_attachments` (the kinds that survive deletion,
100: each with `cleanup: api | manual`, `PRV-13a`). A field with nothing to declare says so explicitly.
101: **A value the engine reads MUST come from here and never from `08-provider-notes.md`**, which is
102: commentary on why a descriptor says what it says (`ADR-0018`). `WIR-29` exposes a subset of it.
103: `CNF-18` iterates its fields as it iterates capabilities: a declared value has a working code path
104: behind it.
105: *Amended 2026-10-08 (`ADR-0037`): the billing-stop window is withdrawn.
106: Amended 2026-10-09 (`ADR-0039`): the per-offer traffic bound is added. An allowance
107: declaration alone does not make an offer sellable; the live-evidence condition is below.*
108: *Amended 2026-10-09 (`ADR-0036`): `order_budget` is declared within each
109: `ordering_channels[]` entry, not once at descriptor top level.*
110: 
111: ### List offers
112: 
113: **Input** — none.
114: **Output** — offers (`DOM-9`).
115: **Capability** — `list_offers` (`DOM-22`); a driver that cannot enumerate offers does not
116: declare it, and the endpoint answers `unsupported` for that account.
117: 
118: May aggregate several provider endpoints (for example a standard catalog and an auction
119: market). Offers from different channels MUST be distinguishable by their identifier so
120: the create path can route on it.
121: 
````

## OPS-1 — 03-operation-lifecycle.md:17

````text
17: **OPS-1** Every mutating request MUST create or return a durable operation record before
18: any provider call is made, and MUST respond `202 Accepted` with that record.
19: 
````

## OPS-11 — 03-operation-lifecycle.md:240

````text
240: **OPS-11** On failure, the system MUST classify the error into `failed` or
241: `needs_reconciliation` using the operation kind and the error kind:
242: 
243: | Operation | Classification rule |
244: |---|---|
245: | refresh | Always `failed`. It is read-only; a failure changed nothing. *The row read "adopt, refresh" until `ADR-0020` withdrew adopt from v1.* |
246: | suspend_tenant | Never `needs_reconciliation`, and never `failed` as a whole. It is a parent whose per-machine children carry their own outcomes (`WIR-39`), and it settles `succeeded` once every child has either settled or **reached `needs_reconciliation`** — a child that reached that state counts as complete for the parent. `needs_reconciliation` is not itself settled (`OPS-3`); it is a state only evidence or an operator moves, so an unresolved child is a child-level fact, and blocking the parent on it would leave every suspended tenant's record permanently open. |
247: | rescue inventory | Same rows as `install`. It is **not** read-only in the relevant sense: it boots the machine into rescue, so an ambiguous failure can strand it there, and `PRV-22` makes an end-rescue failure always ambiguous. Classifying it with `refresh` would mark it `failed` while the machine sits in rescue. |
248: | install | `needs_reconciliation` for `network`, `timeout`, `provider`, `internal`, `conflict`, and `integrity` **once the write-started marker is set** (`OPS-45`). `failed` for the deterministic caller errors `invalid_request`, `not_found`, `unsupported`, `authentication` and `rate_limited` **where no rescue session was left open** (the paragraph below), **and for any failure at all while `OPS-45`'s two markers say the disk is untouched and no rescue session was left open** — including `integrity` before the connection, which is `RSC-3`'s host-key abort. An install that got further than that may have begun overwriting a disk, or may have left the machine in rescue; one that did neither, provably did neither. **`failed` past the write-started marker, where rescue exited cleanly, asserts that the install did not complete and nothing about the disk** (*2026-09-15, `pv-x8r`*): the deterministic caller kinds stay `failed` there because the engine knows what it did — an installer that rejected the layout it had begun partitioning for is a known outcome — and `needs_reconciliation` is the state for an outcome nobody knows (`CONTEXT.md`), whose only truthful verb here would be `abandoned`, which settles `failed` after a human looked. It does not mean `not_applied`, which `OPS-31` refuses there. What the disk holds is `OPS-45`'s marker's fact, rendered to the caller as `WIR-9a`'s `disk_effect`; the state does not carry it. |
249: | create | Any create failure the worker records before any step-9 request (before any per-order key upload or order request) MUST settle `failed`, whatever its kind. The boundary is the worker invoking the first step-9 per-order key upload or order call. It is the worker's position: this rule MUST NOT read `about_to_order_at`, nor any snapshot or cached copy of it. The settle write keeps the ordinary worker guard (`STO-3`; `OPS-6`: "every write that worker makes to the operation MUST carry `claim_number = mine`"), with no `about_to_order_at IS NULL` term. The error MUST keep its reported kind. For `network`, `timeout`, `internal`, `provider` with a 5xx or no upstream status, and a cut-off `conflict`, it MUST carry `retryable: true` on both the error and the operation view; a failure classified `failed` without this pre-step-9 rule keeps its stated `retryable`. An `OPS-21` cancellation of `execute` stays a cut-off `conflict`. The commitment is released in full under `LDG-32` ("A commitment MUST be closed, and its remaining amount released in full") and `LDG-39` ("**Never debited**; released with the commitment (`LDG-32`)"), with no setup-fee or first-unit debit. Settlement takes the `LDG-35` primitive, then follows `STO-3`: "The guarded status write precedes every money write in the transaction and short-circuits the rest". Where the create holds a resource-offer exclusion, it is freed under `STO-58`: "Its lifetime follows the winning create's outcome settlement". Before step 9 no provider mutation has been requested (`PRV-50`). From step 9 onward, including a key-upload failure or an order-call failure before any byte was sent: `needs_reconciliation` if the failure is *ambiguous*, otherwise `failed`. |
250: | power, reverse-DNS, delete, release attachment | Subject to the goal-state success rule, any failure the worker records while `OPS-45`'s write-started marker is unset, where no rescue session was opened or the one opened was closed without error, MUST settle `failed`, whatever its kind (`OPS-45`, which owns the rule), unless the mutation is known to have been accepted (`details.accepted` is `true`). Otherwise `needs_reconciliation` if the failure is *ambiguous*, otherwise `failed`. A release is a delete of a smaller thing (`PRV-45`) and classifies exactly as one. |
251: 
252: *Amended 2026-10-17 (`pv-k4l`; panels r56 and r56b, `docs/research/panels-2026-10/r56/` and `docs/research/panels-2026-10/r56/r56b/`): the restart settlement is outside this classification; see `OPS-15`: "A create found `running` at startup with `about_to_order_at` null MUST be settled `failed`, on a restart only."*
253: 
254: *Amended 2026-10-18 (`pv-qga`; panel r57, `docs/research/panels-2026-10/r57/`; `ADR-0043`): the restart exception reads the null column on a restart; the create row instead classifies a failure recorded by the worker, by position. After step 8 is acknowledged and before step 9 begins, a recorded failure settles `failed` with the column set. A restart in that same window takes the ordinary path (`OPS-15`: "the engine MUST move every `running` operation to `needs_reconciliation`"), since the column is set.*
255: 
256: *Amended 2026-10-23 (`pv-9j6`; panel r64b; owner decision “Yes, settle failed (Recommended)”; `ADR-0046`): made the last row read the write-started marker for recorded failures below goal-state success and except known-accepted mutations, with ambiguity in the fallback branch.*
257: 
258: **The table MUST be total, and seven kinds added later were missing.** `insufficient_balance`,
259: `not_activated`, `halted`, `gone`, `suspended`, — added 2026-09-02 — `ceiling_exceeded`
260: (`DOM-20`, `DOM-21`, `SEC-39`) and — added 2026-09-12 — `overloaded` (`STO-55`) are
261: **admission-only**: they are decided
262: before any driver call, they MUST NOT be emitted by a worker or a driver, and any pre-provider
263: occurrence classifies deterministically as `failed` for every operation kind. Nothing was
264: destroyed and nothing was ordered, so ambiguity cannot arise. Every kind in `DOM-17` MUST have a
265: defined classification for every operation kind. There is no implicit default, because the two possible defaults are both wrong:
266: defaulting to `failed` invites a caller to retry a mutation that may have happened, and
267: defaulting to `needs_reconciliation` pages a human for a typo. `CNF-31b` tests totality.
268: 
269: One case needs stating because two requirements appear to disagree. `PRV-22` says "Failure of end
270: rescue is *always* ambiguous". That does not conflict with the install row: an install whose
271: *rescue exit* fails has already done its work and reached the provider, so it is never a
272: deterministic caller error, and the install row classifies it `needs_reconciliation` regardless
273: of which error kind the driver reports. *Amended 2026-09-14: the same holds where the operation died
274: before reaching it. `OPS-45`'s second marker is one column, `false` for both, so the classification
275: cannot tell them apart, and the machine may be sitting in rescue either way — which is the fact the
276: marker records. The never-attempted exit was a third case until `RSC-18` was withdrawn, 2026-09-15.*
277: 
278: *Amended 2026-10-09 and 2026-10-10 (`ADR-0036`): `PRV-40` says to "refuse subsequent
279: creates on that account and channel before any provider call" and, for a queued
280: create closed at worker claim, to "settle the existing operation `failed`". These
281: are occurrences decided before provider acceptance, not an admission-only error
282: kind. `rate_limited` remains available to drivers and workers. See `API-7` for the
283: purchase-tail refusal.*
284: 
285: A failure is **ambiguous** when:
286: 
287: - the error kind is `network`, `timeout`, or `internal` — the request may have been
288:   received and acted on before the transport died; or
289: - the error kind is `conflict` *and* it arose from the worker being cut off mid-flight
290:   (`OPS-21`) rather than from a provider-reported state conflict; or
291: - the error kind is `provider` *and* the upstream status was 5xx, or no upstream status
292:   was recorded at all. A 4xx rejection of the mutating request itself means the provider did not
293:   accept that request; a 5xx means it may have acted and then failed to say so; or
294: - the operation's mutating request was accepted by the provider (`details.accepted: true`,
295:   `PRV-5`), whatever the later error kind or status.
296: 
297: **Amended 2026-10-08 (`ADR-0035`): acceptance is an additional ambiguity condition for the
298: create row and the last row.** A later `rate_limited`, `not_found`, `authentication`, or provider 4xx error MUST NOT
299: classify that accepted mutation `failed`. The goal-state success rule below still takes
300: precedence. The refresh, parent, install/rescue-inventory and admission-only rows are unchanged;
301: pre-provider admission has no accepted mutation. Unknown acceptance follows `PRV-5`'s
302: "MUST report `details.accepted: null` with the mutating request's own failure mapped as above",
303: never an implicit default.
304: 
305: The accepted dated cancellation read-back (`PRV-13`) is an evidence read after a successful
306: mutating response. Failure of that read alone does not enter this failure classifier; the
307: settlement for the known accepted date belongs to `PRV-13`. `PRV-13c` says "A failed
308: post-order read of any kind, `rate_limited` included, MUST NOT enter `OPS-11`'s classifier and
309: MUST NOT change the create's settlement." *Amended 2026-10-14 (`ADR-0037`, Q31).*
310: This exception does not reclassify unknown acceptance or a later failure of the mutating
311: request. *Clarified 2026-10-11
312: (`ADR-0037`, Q22).*
313: 
314: **AMENDED 2026-08-31 — "a 4xx means the provider did not act" is false, and believing it strands a
315: customer's money.** For a **goal-state mutation** — delete, power on, power off, end rescue — a
316: provider may reject the request precisely *because the goal state already holds*, and that rejection
317: means the opposite of failure. Measured: `DELETE /v2/images/{id}` against a resource already deleted
318: returns `422 "Can not delete an already deleted image."` Classified `failed` under the sentence
319: above, a delete that succeeded is recorded as a failure, and `LDG-32` then never closes the
320: commitment — the customer's satoshis stay reserved against a resource that is gone.
321: 
322: **A provider rejection whose meaning is "already in the target state" MUST classify `succeeded`.**
323: Which specific codes carry that meaning is a provider fact, so the mapping belongs in the driver
324: (`PRV-5` already owns translating provider responses) and MUST be recorded in
325: `08-provider-notes.md`, pinned to codes rather than to message text, and re-verified when the
326: provider's API changes. This table states the rule; it does not enumerate anyone's error codes.
327: 
````

## OPS-21 — 03-operation-lifecycle.md:1793

````text
1793: **OPS-21** `execute` MUST be cancellable. A cancellation of `execute` that the engine survives
1794: MUST be recorded before the engine exits, for every operation kind, subject to the bounded
1795: abandonment, later-stop and superseded (`OPS-50`) exits below. “Survives” means the process
1796: outlives the stop. A kill or crash records nothing; at the next start, `OPS-15` says "the engine
1797: MUST move every `running` operation to `needs_reconciliation`", subject to its exceptions. A
1798: stop that arrives while a store transaction inside `execute` is in flight or repeating under
1799: `OPS-49`, such as `OPS-43`'s step-8 transaction or an `OPS-45` marker write, is the cancellation
1800: being recorded. A transaction already sent MAY finish, since `OPS-49` says "the server decides
1801: every statement's fate before the client does"; the worker MUST NOT repeat it or begin anything
1802: it precedes, and makes the record. The worker MUST NOT pursue the record past the Stop-record
1803: bound (`OVR-19`), and the engine MUST NOT wait for it past that bound.
1804: 
1805: The worker classifies a recorded cancellation under `OPS-11` and makes its record write: the
1806: guarded write of `OPS-22`, except for a parent, whose record write is the defer below. The
1807: recorded error is a cut-off `conflict` with `details.reason: "cut_off"` (`WIR-9a`), for every
1808: kind whose record write is the guarded one, whether the row settles `failed` or enters
1809: `needs_reconciliation`.
1810: A provider call abandoned mid-flight whose failure enters `OPS-11`'s classifier is exactly the uncertainty this design exists to represent.
1811: For a create, a cancellation of `execute` recorded before step 9 is the exception, under the
1812: create row. `OPS-11` says "Any create failure the worker records before any step-9 request (before any per-order key upload or order request) MUST settle `failed`, whatever its kind."
1813: The other classification pointers are `OPS-11`'s install row, "while `OPS-45`'s two markers say
1814: the disk is untouched and no rescue session was left open", rescue inventory's "Same rows as
1815: `install`", the last row's "any failure the worker records while `OPS-45`'s write-started marker is unset", and
1816: refresh's "Always `failed`". The kind's row owns the outcome, including where
1817: it reads ambiguity.
1818: Where the row reads `OPS-45`'s markers, the record MUST classify against the markers its own transaction reads, since a marker write whose reply was lost may have committed.
1819: 
1820: The record write MUST NOT be cancelled by the cancellation that stopped `execute`.
1821: Store errors in that write use `OPS-49`'s whole-transaction loop, "the component MUST repeat the
1822: **whole transaction**".
1823: A later stop, one arriving after the stop being recorded and before that record lands, ends the record as an exit without worker classification at any point: before the record's first transaction, during it, or while `OPS-49` repeats it; the worker MUST NOT repeat a record transaction already sent when that later stop arrives.
1824: The sent transaction's fate is the server's: `OPS-49` says "the server decides every statement's fate before the client does".
1825: For the retry-loop exit, `OPS-49` says "A worker cancelled during the retry loop stops retrying and exits".
1826: Its store-error exit also classifies nothing: `OPS-49` says "on exhaustion the outcome in hand is
1827: thrown away and `OPS-15` classifies the row as interrupted".
1828: 
1829: A loss of the connection carrying `OPS-47`'s startup lock is not a later stop: `OPS-47` says
1830: “treat the loss as a stop of every worker not already recording one”. For a worker still in
1831: `execute`, this requirement's cancellation rules apply, including the stop that “MUST NOT cancel
1832: `execute`” and the parent's defer, which “records no error”; for one whose `execute` has
1833: returned, its settle write records it; it ends no record already pending. A stop that arrives
1834: after the engine detects the loss and before that record lands is a later stop. `OPS-50` says “A
1835: refused generation check ends recording without another attempt; an earlier attempt may already
1836: have committed with its reply lost.”
1837: 
1838: The Stop-record bound is measured from the stop, counts every repeat including serialization failures, and never resets.
1839: This includes the repeats of which `OPS-49` says "do not consume the bound"; that bound is the
1840: Store-retry bound, independent of this one. The Stop-record bound runs until the record lands
1841: and covers connection, execution, commit, read-back and backoff together. On expiry the worker
1842: MUST abandon the record, and the engine MUST log loudly, naming every operation whose record
1843: it did not see land, and exit. For the lost-reply case see `OPS-49`: "unless the bound's last
1844: repeat committed and its reply was lost"; a row still `running` goes to restart recovery as
1845: after a crash. There is no ordering constraint between the Stop-record bound and the
1846: Store-retry bound: whichever ends first ends the record, with the latter's exhaustion exit
1847: unchanged. The deployment's supervisor MUST wait at least the Stop-record bound after a stop
1848: before it kills the engine. A kill before the record lands is a crash.
1849: 
1850: A cancelled `suspend_tenant` parent MUST be returned to `queued` with `available_at` advanced at any point in its fan-out, subject to the same Stop-record bound and exits.
1851: This is the write `OPS-49` gives a waiting parent, "returned to `queued` with `available_at`
1852: advanced — the same write as `OPS-8`'s defer, though nothing refused it", which `STO-3` guards
1853: "on `(id, status = running, claim_number = mine)`". It records no error.
1854: Its next claim continues as `OPS-15`'s re-queued parent does, "resuming its fan-out from wherever
1855: it stopped"; that re-sweep "is idempotent by `OPS-39`'s dedup" (`OPS-15`), so it enqueues no
1856: child twice.
1857: 
1858: `execute` returns only once the outcome its settle write records is final, so every provider
1859: call that outcome depends on is made inside `execute`. For a create, the worker's settle-time
1860: verification is inside `execute`: `OPS-27`'s correlator search and its confirming read, so a
1861: stop during either is the cancellation being recorded. `PRV-13c`'s post-order read in that
1862: settlement pass and `PRV-13`'s direct read after an accepted dated cancellation are also inside
1863: `execute`, and their failure leaves the outcome in hand. `PRV-13c` says "A failed post-order
1864: read of any kind, `rate_limited` included, MUST NOT enter `OPS-11`'s classifier and MUST NOT
1865: change the create's settlement." `PRV-13` says "If the machine remains present, or this read
1866: fails for any reason including throttle, authentication, network error or deadline expiry, the
1867: accepted attempt settles `succeeded` as `cancellation_scheduled` with its effective date." A
1868: stop the engine survives after a create's settle-time confirming read succeeds, or after a
1869: delete's cancellation is accepted with an effective date, and before `execute` returns MUST NOT
1870: cancel `execute`. The worker still makes the read that follows, the stop ends it at once as a
1871: failed read unless it has already completed, `execute` returns the outcome that read gives, and
1872: the settle write records the stop as it records a stop after `execute` returns. A stop the
1873: engine survives that arrives after `execute` returns and before the worker's settle write lands
1874: MUST be recorded by that settle write, under the shielding below, and the Stop-record bound and
1875: exits that apply to a recorded cancellation. The settle write that records a stop after
1876: `execute` returns MUST NOT be cancelled or abandoned by that stop. This holds before that
1877: write's first transaction, during it and while `OPS-49` repeats it, whether the repeats began
1878: before the stop or after it, until the write lands or affects no row (`OPS-22`). The record of a
1879: stop after `execute` returns is the guarded write the worker would have made without the stop,
1880: settling the outcome in hand with that outcome's own error, if it has one, and with a failure
1881: classified under `OPS-11`; it is not a cut-off `conflict`. For a `suspend_tenant` parent that
1882: `execute` left waiting on its children, that write is the defer above, which records no error.
1883: The Stop-record bound and its expiry exit, the later-stop exit, the Store-retry bound's
1884: exhaustion exit, the superseded exit (`OPS-50`), the lost-reply case and the supervisor's wait
1885: apply to the record of a stop after `execute` returns as they do to a recorded cancellation; the
1886: cut-off classification and its reason do not, nor does the rule against repeating a transaction
1887: already sent inside `execute`. `OPS-50` says "the engine MUST log loudly that it was superseded and exit non-zero at once". A stop that arrives after a stop has cancelled `execute`, before
1888: that cancellation's record lands, is a later stop under that record's rules, not a stop after
1889: `execute` returns.
1890: 
1891: *Amended 2026-10-18 (`pv-qga`; panel r57, `docs/research/panels-2026-10/r57/`; `ADR-0043`): pointed the recorded cancellation at the create row; the retry-loop exits remain exits without worker classification.*
1892: 
1893: *Amended 2026-10-18 (`pv-tst`, `pv-f7a`; panels r58 and r58b, `docs/research/panels-2026-10/r58/` and `docs/research/panels-2026-10/r58/r58b/`; `ADR-0044`): required a bounded, shielded record of a survived stop and a parent defer; assigned the cut-off reason.*
1894: 
1895: *Amended 2026-10-18 (`pv-tst`; panel r58c, `docs/research/panels-2026-10/r58/r58c/`; `ADR-0044`): a stop during a store transaction inside `execute`, repeating or not, is the recorded cancellation; the record reads the markers its own transaction sees.*
1896: 
1897: *Amended 2026-10-19 (`pv-zbp`; `ADR-0044`): placed outcome-dependent provider calls within the cancellable execution and extended stop handling to settlement; kept a stop after a cancellation of `execute` a later stop of its record.*
1898: 
1899: *Amended 2026-10-19 (`pv-zbp`, `pv-ilb`; panel r59, `docs/research/panels-2026-10/r59/`; `ADR-0044`): a survived stop during a read whose failure leaves the outcome in hand ends that read as a failed read and is recorded by the settle write, not as a cut-off.*
1900: 
1901: *Amended 2026-10-20 (`pv-gq8`): extended the later-stop exit to every point before the record lands, with a sent record transaction left to the server and not repeated; the after-return paragraph's exclusion names the transaction sent inside `execute`, so the later-stop exit's no-repeat clause reaches both records.*
1902: 
1903: *Amended 2026-10-23 (`pv-9j6`; panel r64b; owner decision “Yes, settle failed (Recommended)”; `ADR-0046`): added the last row to the classification pointers.*
1904: 
1905: *Amended 2026-10-24 (`pv-buc`; panel r66e, `docs/research/panels-2026-10/r66/r66e/`; owner decisions “Yes, R (Recommended)” and “Adopt; one combined Run”; `ADR-0047`): recorded lock loss and included the generation-refusal exit.*
1906: 
````

## OPS-23 — 03-operation-lifecycle.md:2018

````text
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
2046: and `rescue_exit: "none"` (`WIR-9a`: "`none` where this operation is established to have written
2047: nothing to the target disk" and "`none` only where no rescue session was opened"). A release
2048: that adds a required field MUST state whether the caller supplies it or the `api` writes it
2049: at admission.
2050: 
2051: The worker's claim-time absence check and sale re-test at `OPS-43`'s step 5, "Check for the named
2052: offer's absence from that result", are exceptions to this requirement's "before the driver is
2053: called": they run on the result of `OPS-43`'s step 4, "Obtain the current driver List offers
2054: result", after that read.
2055: 
2056: *Amended 2026-10-16 (`pv-hsm`; panel r54, `docs/research/panels-2026-10/r54/`): added the
2057: pointer to `OPS-43`'s claim-time sale re-test and its timing exception.*
2058: 
2059: *Amended 2026-10-17 (`pv-14b`; panel r55, `docs/research/panels-2026-10/r55/`): distinguished
2060: caller-supplied and api-filled admission fields, their failure outcomes, and install marker
2061: timing; included offer absence in the timing exception.*
2062: 
2063: *Amended 2026-10-18 (`pv-qga`; panel r57, `docs/research/panels-2026-10/r57/`; `ADR-0043`):
2064: pointed a create's missing-field failure at the create row's step-9 boundary.*
2065: 
2066: *Amended 2026-10-22 (`pv-gpw`; panel r62, `docs/research/panels-2026-10/r62/`): applied the reviewed writer-based validation disposition and fixture.*
2067: 
2068: *Amended 2026-10-23 (`pv-9j6`; panel r64b; owner decision “Yes, settle failed (Recommended)”; `ADR-0046`): pointed power's and delete's missing-field failures at the last row's marker clause.*
2069: 
````

## OPS-40 — 03-operation-lifecycle.md:744

````text
744: **OPS-40** **A signed image URL is validated against the queue's latency, twice** (`F20`).
745: `OPS-2` persists a request so it can be executed after restarts and deferrals; `SEC-21` wants the
746: signed URLs inside it short-lived. The two meet as follows: at **accept**, a request carrying a
747: signed URL MUST be rejected unless the URL's expiry exceeds the deployment's stated worst-case
748: admission-to-start bound; at **claim**, a worker MUST fail the operation deterministically —
749: before any provider mutation and before rescue is entered — if the URL cannot outlive the
750: install's stated worst-case duration, with an error kind and message telling the caller to
751: re-submit with a fresh URL. An expiry mid-stream after that gate is an ordinary install failure
752: under `OPS-11`'s classification. **The gate exists because the alternative is entering rescue and
753: beginning a destructive write fed by a URL that is already doomed.** No refresh mechanism inside the
754: record is needed, because the caller re-submits with a fresh URL — which this requirement already
755: tells it to do; the operator never held the signed URL, `STO-9` having purged it.
756: 
````

## OPS-41 — 03-operation-lifecycle.md:970

````text
970: **OPS-41** **An exposure-reducing cancellation MUST apply the ordered decision below under the fence.**
971: *Amended 2026-10-05 (`pv-gip.43`, Q14, `ADR-0032`): step 2 owns the guarded retry
972: exception to the funding re-check, including after a resume.* A worker executing **any** exposure-reducing cancellation (`OPS-39`,
973: `LDG-64`) — *scoped by reason to exhaustion, late-attach cleanup and the rate-outage bound until
974: 2026-09-09, which contradicted the 2026-09-05 paragraph below keying the exemption on the tenant's
975: current state and not the reason; `ADR-0021`* — MUST, **except where step 2 applies**, **after claiming the
976: machine (`OPS-8`) and before any provider mutation**, re-read that machine's commitment and its
977: `runway_until` — **in the same serialized transaction that writes `OPS-42`'s fence**, without which
978: the extension it is racing can commit between the read and the write. Where re-deriving `LDG-33`
979: from what it read now puts **`runway_until` strictly in the future**, the worker MUST make no
980: provider call, settle the operation `succeeded` with a result recording that no mutation was
981: required, **write that re-derived `runway_until` to the machine row** (*withdrawn 2026-09-25,
982: `ADR-0028`: "and clear the deadline — `LDG-16`'s `machines.destroy_not_before` (the abort is the
983: second of the two authorized future-date writes, `ADR-0026`)" — no machine carries a deadline; the
984: restore grace's unpaused end is `STO-56`'s `grace_ends_at`*), **clear `machines.destroy_committed`**, and close
985: the episode where
986: it is still open (`OPS-48`; a gone-write may have closed it first, and a close is permanent) so a
987: later lapse can open a fresh one. *The date write was added 2026-09-05: the sweep routes on the
988: **stored** date, and an abort that re-derived a future date and wrote nothing left the stored one in
989: the past — so the next pass routed the same machine, the worker aborted again, and the fence was set
990: and cleared once per sweep until the next scheduled re-derivation. That is the non-terminating loop
991: this requirement warns about for the withdrawn predicate, reached through a stale column instead.
992: `LDG-62` had the same gap and carries the same write.*
993: **Those last two happen in the terminal transaction** (`OPS-48`'s no-mutation row): the fence exists to
994: order this worker against `LDG-62`, and leaving it set on a machine the worker has just decided not
995: to cancel would refuse extensions on a funded, running machine until another close.
996: 
997: **A claim made while a restore record is open and its `grace_ends_at` is null or in the future
998: defers, and writes no fence** (*added 2026-09-25, `ADR-0028`*). A worker claiming **any**
999: exposure-reducing cancellation MUST read the restore record (`STO-56`) at each such claim, before
1000: the fence transaction above, and while a restore record is open and its `grace_ends_at` is null or
1001: in the future the claim MUST defer: the operation is returned to `queued` with `available_at =
1002: grace_ends_at` where the instant is set, and by `OPS-8`'s ordinary short delay where it is not yet
1003: written. No fence is written and the re-check above does not run on that path, so `LDG-62`'s
1004: extension is refused by nothing the grace introduced. The null branch is real: claims begin after
1005: step (2) of `STO-54`'s procedure and the instant is written at step (3), so a delete re-run by step
1006: (2) and claimed before step (3) would otherwise fence, re-check the restored balance and call the
1007: provider on the very tenant the grace exists for. The rule applies whichever path enqueued the
1008: cancellation — a delete re-run by step (2), an operator's retry, `LDG-64`'s bound, a suspended
1009: tenant's. The deferral is the write `OPS-49` gives a waiting parent — `OPS-49` says it is "the same
1010: write as `OPS-8`'s defer, though nothing refused it", in a bullet `OPS-49` marks as `F51`'s. `OPS-8`
1011: itself covers an index refusal and a short delay — `OPS-8` says a refused claim "MUST return the
1012: operation to `queued` with a short delay" — which is why this paragraph states its own scope and
1013: duration rather than citing it. For the startup-read distinction, see `STO-56`.
1014: `OPS-48` gains no row — a re-queued attempt has not settled.
1015: 
1016: **Amended 2026-10-02 (`ADR-0029`): for a funding cancellation, the grace counts rate-present
1017: time, summed across outages.** From step (3)'s instant, derived as `grace_ends_at` minus one
1018: re-derivation interval, accumulate only time in which the machine's currency has a rate. An outage
1019: MUST pause that measure, neither spending the remaining grace nor resetting what accumulated.
1020: Compute it from the retained per-currency `STO-49` history on the same history basis as `STO-37`'s
1021: outage-start replay, using the stamped verdicts and bounds (*amended 2026-10-04, `pv-gip.28`*).
1022: The rate-present spans use `LDG-58`'s effective-time rule (*amended 2026-10-04, `pv-gip.6`,
1023: Q13*).
1024: Do not use a subject's `absorbed_until`, and do not assume `observed_at` increases in acceptance
1025: order. No accumulated measure or revised grace end is persisted.
1026: 
1027: The ordered decision below determines which cancellations reach the funding-only paused check
1028: in step 3. With no open restore record there is no restore-grace deferral. `STO-56` owns incident
1029: closure; `STO-54` says "the freeze lifts at `grace_ends_at`"; the paused portion does not extend it.
1030: 
1031: **AMENDED 2026-09-04 — the abort predicate was the routing predicate, so every correctly routed
1032: cancellation aborted.** *It read "where the remaining commitment now covers the wind-down floor at
1033: the current rate — `LDG-16`'s invariant, the same test that routed it here", and that parenthesis
1034: was the tell nobody followed. `LDG-16`'s invariant is a condition on the routing itself: a machine
1035: enters this path **while** its commitment still covers wind-down, so the operator is never left
1036: paying for a stop it can no longer afford. Every machine the sweep routes correctly therefore
1037: satisfies it on arrival, and a worker re-testing it under the fence aborts every cancellation it was
1038: sent to perform. `LDG-13` — "a machine whose funding fails MUST be cancelled" — becomes unreachable
1039: by the only path that reaches it, and an unfunded machine bills the operator indefinitely. Two
1040: full-set cross-model reviews read past this; the requirement cited the very thing that made it
1041: wrong.* What distinguishes a machine funded **since** routing is not the floor, which held all along,
1042: but the re-derived date. `OPS-41` already re-reads both terms `LDG-33` needs; only the test applied
1043: to them was wrong.
1044: 
1045: **The predicate is the re-derived `runway_until`, because that is what the sweep routes on.**
1046: `05-persistence.md` indexes `machines` on `(runway_until)` "for the exhaustion sweep (`LDG-13`)" and
1047: the date's clause of `LDG-16`'s routing predicate is "its stored `runway_until` has passed" —
1048: `usable_sats` is a term inside `LDG-33`'s formula and not a stored column, so no sweep can query it.
1049: *`usable_sats > 0` was tried on 2026-09-04 and reverted the same day. The argument for it read
1050: `LDG-33`'s "exhaustion begins when `usable_sats` reaches zero" as the sweep's predicate; in context
1051: that sentence is an argument for subtracting `protected_sats` before dividing, against a withdrawn
1052: form that divided the whole commitment. The two forms differ only where the remaining money buys
1053: under one second, and there the sweep does route the machine — so `usable_sats > 0` aborts, settles
1054: `succeeded` saying no mutation was needed, clears the fence, and hands the same machine back to the
1055: next pass, once per sweep, each cycle minting a tenant-visible operation that claims to be done.*
1056: Note that an extension is not the only thing that can satisfy this test: `LDG-33` re-derives in both
1057: directions, so a price cut moves the date too, and a build testing for a grown commitment rather than
1058: for the re-derived date would be wrong on exactly that path.
1059: 
1060: **Without this the survival path `OPS-36` offers does not work.** That branch attaches the machine
1061: and enqueues the cleanup cancellation *in the same transaction*, then tells the tenant it may
1062: `extend-runway` (`LDG-62`) "before the exhaustion sweep reaches it" — but there is no sweep left to
1063: beat: the delete is already queued, and nothing in `LDG-62`, `OPS-36` or `OPS-39` withdraws it,
1064: resolves its trigger, or re-examines the machine. The tenant pays, the payment is accepted and
1065: committed, and the disk is destroyed anyway. The satoshis come back when `LDG-32` closes the
1066: commitment; the data does not. `OPS-36` says of this branch "This is the branch that makes
1067: `OPS-33`'s early release safe", so the release was resting on a path that could not deliver.
1068: 
1069: **The check belongs under the fence, not in the extension.** Cancelling the queued operation from
1070: inside `LDG-62`'s transaction would have to win a race it holds nothing for — the worker may
1071: already have claimed the operation — and would still leave the case where the payment lands after
1072: the claim. Re-reading at the last moment before the mutation is correct under every interleaving,
1073: including a second extension.
1074: 
1075: **The worker decides in this order, inside the fence transaction and on what that transaction
1076: reads, never on its claim snapshot.** The order holds for every exposure-reducing cancellation,
1077: whatever reason the attempt was enqueued under, and the first step that applies decides.
1078: Enqueue reason does not substitute for step 2's origin test:
1079: 
1080: 1. **The machine is recorded gone, or its episode is closed.** The worker makes no provider call and
1081:    settles the attempt `succeeded` with a result recording that no mutation was required (`OPS-48`;
1082:    a close is permanent). **It writes no `runway_until`**: the date the no-mutation case above
1083:    writes is a re-derived one, and this step re-derives nothing.
1084: 2. **The attempt was enqueued by `API-64` retry and `destroy_committed` already holds its
1085:    episode's id, read in this transaction, or the tenant is suspended now.** The funding
1086:    re-check does not apply and the cancellation proceeds, regardless of the current rate.
1087:    A retry reading the fence null decides from step 3 unless the tenant is suspended now.
1088:    The fence read is the pre-existing value, never a fence this decision just wrote.
1089:    Step 1 and the restore claim gate above remain ahead of this decision. The durable origin
1090:    stamp is specified at `API-64`; the suspension paragraph below governs that exemption.
1091:    *Amended 2026-10-05 (`pv-gip.43`, Q14, `ADR-0032`); supersedes the unconditional
1092:    retry exemption of 2026-10-04.*
1093: 3. **A rate exists for the machine's currency** (`LDG-59`). The worker re-derives and applies the
1094:    predicate above **first**. If funded, it performs the no-mutation abort and settlement above,
1095:    including the re-derived date write, fence clearing and episode closure where applicable.
1096:    **Only if the predicate would cancel**, and a restore record is open, its original
1097:    `grace_ends_at` has passed, and the currency has accumulated less than one re-derivation
1098:    interval of rate-present time since step (3), the worker MUST return the attempt to `queued`
1099:    by `OPS-8`'s ordinary short delay. The paused check reads the restore record and currency
1100:    history on this transaction's reads, including the returned rate it sees, never the claim's
1101:    rate snapshot. It writes no new fence, makes no provider call, and neither settles the attempt
1102:    nor closes its episode. Otherwise it proceeds to the existing fence and cancellation path.
1103:    *Amended 2026-10-03 (`ADR-0029`): the paused check moved here from the claim. Withdrawn:
1104:    "After that wall-clock end, while a rate exists and a funding cancellation has unspent grace,
1105:    the claim MUST return the attempt to `queued` with `available_at` equal to
1106:    `now + (one re-derivation interval − accumulated rate-present time)`, the paused end computed
1107:    at this claim." The ordinary short delay replaces that availability.*
1108: 4. **There is no rate, and the outage's deadline has not passed** (`LDG-64` holds how the deadline
1109:    is computed). The claim defers: the operation is returned to `queued` by `OPS-8`'s ordinary
1110:    short delay, and no fence is written.
1111: 5. **There is no rate, and the deadline has passed.** This is `LDG-64`'s bound. The worker MUST, in
1112:    the same fence transaction, conditional-write **this machine's** open `rate_outage` deficiency
1113:    record (`STO-37`, guarded on `absorbed_until IS NULL`; a no-op write on the row, whose only
1114:    purpose is to contend). Where that write affects a row, the outage is still open for this
1115:    machine and the cancellation proceeds. Where it affects no row and a rate is now in force —
1116:    restoration (`LDG-64`) closed the record first — the worker takes step 3 at that returned rate,
1117:    including its re-derivation first and paused check on the returned currency history. Where it
1118:    affects no row and there is still no rate, the machine carries no open record and the cancellation proceeds as well: `LDG-64`'s bound reaches a machine the meter
1119:    opened no record for, and step 1 has already settled a machine that is gone.
1120: 
1121: **At the bound "no rate" is established by that conditional write, not by a read.** A read of "no
1122: rate" from a snapshot taken before restoration committed would let the worker delete a funded fleet
1123: on stale evidence, and `LDG-35`'s per-tenant primitive orders nothing against a deployment-wide
1124: event; the write contends with the one that closes the record (`LDG-64`), so the store orders the
1125: two. **One case is left unordered, and it is accepted** (`ADR-0029`): for a machine with no record
1126: nothing orders the worker against a rate returning at that instant, which takes a machine the meter
1127: never posted for and a rate returning at the bound itself.
1128: 
1129: **The short deferrals in steps 3 and 4 are not settlements.** The episode stays open and
1130: `OPS-48` gains no row — a re-queued attempt has not settled — and each later eligible claim
1131: decides again from step 1, so a suspension that joins the episode, a rate that returns and a
1132: machine recorded gone are each seen at the next claim, with no wake-up to arrange. The original
1133: wall-clock grace is still read first at the claim and precedes this order, including a bound
1134: inside that interval; the paused portion is decided only at step 3. A paused deferral does not
1135: clear an inherited fence.
1136: 
1137: *Amended 2026-10-02 (`ADR-0029`), with the withdrawn wording, kept because it reads as sound and
1138: was not. Until then this requirement held: "**Where there is no rate, the cancellation proceeds.**
1139: `LDG-40` requires the exhaustion sweep to continue during a rate outage because it reduces exposure,
1140: and `LDG-65` keeps it running on the last derived `runway_until`. A funding re-check that cannot be
1141: computed MUST NOT be read as "funded": the worker cancels. Failing safe here costs a machine that
1142: may have been rescuable; failing the other way is an unfunded machine billing indefinitely, which is
1143: what `LDG-13` exists to prevent." It cancelled a machine on a stored date that passed during the
1144: outage, and `ADR-0029` holds the argument against that. Withdrawn with it, the reading of
1145: a conditional write that affects no row with still no rate as "the machine's own meter stopped
1146: (`LDG-74`), there is nothing left to cancel, and it settles as the no-mutation case": in the first
1147: minutes of an outage no record exists yet, since the meter opens it only at the subject's first
1148: posting that computes no rate, so that reading settled a live machine's cancellation, closed its
1149: episode, and the sweep queued it again. And withdrawn, the scope of the bound: "A
1150: `rate_outage_bound` cancellation is enqueued only for a machine carrying such a record, which
1151: under `LDG-64` is every machine metered through the outage" — a machine the meter opened no record
1152: for would never meet the
1153: bound. The conditional write itself dates from 2026-09-05, when a `rate_outage_bound` cancellation
1154: was brought inside this requirement's scope; a first form of it named a deployment-wide outage row
1155: that `STO-37` does not have, applied the write on every exposure-reducing cancellation — so on the
1156: ordinary exhaustion path, with a rate in force and no open record, it affected no row and aborted
1157: every delete into the once-per-sweep loop — and mandated abort where restoration had closed the row
1158: even when re-derivation at the restored rate still put the date in the past.*
1159: 
1160: **The funding re-check does not apply where the machine's tenant IS suspended at the moment of
1161: the re-check, read in the same fence transaction** (`API-58`, `OPS-27`) — keyed on the tenant's
1162: current state, not on the reason the operation was enqueued under and not on the episode's
1163: `reasons` set, which is deduplication history. A suspension is not about funding, and a suspended
1164: tenant topping up its balance is not permission to keep the fleet. *Rewritten twice on 2026-09-05.
1165: The operation's own reason was wrong because `API-58`'s fan-out joins an already-open exhaustion
1166: episode, so the worker may hold an `exhausted` delete on a suspended tenant and a price rise would
1167: have aborted it as funded. The `reasons` set was wrong the other way: the reason is history, so a
1168: tenant that was later **resumed** (`WIR-41`) and funded its machine still had `tenant_suspended` on
1169: the episode, and a later attempt skipped the funding check and destroyed a machine its live tenant
1170: had paid for.*
1171: 
1172: **AMENDED 2026-09-02 — the exemption is scoped to the re-check, not to the abort.** `OPS-42` keys
1173: its fence on the **action**, so a `tenant_suspended` delete is an exposure-reducing cancellation and
1174: takes the fence like any other — and `OPS-42` then tells a worker whose guarded write affects no row
1175: to "settle as `OPS-41` requires", pointing at a requirement that, read whole, disclaimed the case
1176: entirely. **The abort-and-settle shape below applies to every exposure-reducing cancellation,
1177: whatever its reason**: make no provider call, settle `succeeded` with a result recording that no
1178: mutation was required, and close the episode per `OPS-48` where it is still open. What changes
1179: whether the *funding* test can send a worker down that path is step 2's exemption,
1180: including the tenant's **current** state — not the enqueue reason:
1181: a suspended tenant's machine cannot be found funded, and a
1182: resumed tenant's can, whatever reason the attempt was enqueued under, unless step 2's
1183: fenced-retry exemption applies (*this sentence said "for
1184: exhaustion and late-attach cleanup it can, for a suspension it cannot" until 2026-09-09*). *In practice a suspension cancel loses that race only to another
1185: cancellation of the same machine, which `OPS-39`'s per-action episode key already prevents, and
1186: never to `LDG-62`, which `API-7` step 5b refuses for a suspended tenant. The path is therefore
1187: expected to be unreachable — and it is specified anyway, because "unreachable" is a claim about
1188: today's rules and the abort instruction is written unconditionally.*
1189: 
1190: *Amended 2026-10-05 (`pv-gip.43`, Q14, `ADR-0032`): step 2 supersedes the 2026-10-04
1191: V2 exclusion of all `API-64` attempts from funding. The general abort-and-settle shape remains
1192: unconditional. Verification: `CNF-312` and `CNF-272`.*
1193: 
1194: *Model verification amended 2026-10-05 (`pv-gip.43`):
1195: `Provisiond.Fence.extension_first` uses the admitted extension's null fence directly to exclude
1196: the guarded retry exemption. It covers ordinary and retried attempts without assuming either
1197: reachability or a previously fenced episode. The enlarged lifecycle admits interruption,
1198: resolution and abstract pre-fence failure; the former RetryFenceInv and retry_has_episode_fence
1199: are withdrawn, falsified by sweep, claim, interrupt, resolve notApplied, retry with an open
1200: episode and null fence. For the survived-stop record see `OPS-21`: "A cancellation of `execute` that the engine survives MUST be recorded before the engine exits"; for the pre-fence conformance prefix see `CNF-312`. The model does not compose stop delivery or bounded recording with this lifecycle. The proof establishes no full crash/restore procedure, queue scheduling, database
1201: serialization, provider behavior or running-service conformance.*
1202: 
````

## OPS-42 — 03-operation-lifecycle.md:1203

````text
1203: **OPS-42** **`OPS-41`'s re-check is not sufficient on its own, and a fence is what makes it work.**
1204: The window that decides whether a paying customer keeps its machine is **between the worker's read
1205: and its provider call**, not inside the read's transaction. `LDG-69` forbids a provider call under
1206: the money serialization, so the worker must release it before mutating — and `LDG-62`'s
1207: extend-runway can commit in that gap. Entering the serialization changes nothing; the worker still
1208: reads *unfunded*, still lets go, and still destroys a machine the customer has just paid for.
1209: Nothing in `LDG-62`, `OPS-36`, `OPS-39` or `OPS-41` closed it.
1210: 
1211: **The cancellation and the extension MUST contend for one row, so that one of them provably loses:**
1212: 
1213: - Before any provider mutation, an exposure-reducing cancellation MUST record its decision on the
1214:   machine row — `machines.destroy_committed` set to its episode's id (`operations.episode_id`,
1215:   `STO-52`) — as a conditional write guarded on **`destroy_committed IS NULL` *or*
1216:   `destroy_committed` already holding this operation's episode id**, in the manner of `STO-3` —
1217:   **and on that episode being open** (`STO-52`, `state <> closed`; added 2026-09-09, `ADR-0021`,
1218:   since a gone-write may have closed it between the claim and this write, and a fence set under a
1219:   closed episode would clear never).
1220:   Where the write affects no row, another actor won the race and the worker MUST abort the
1221:   cancellation and settle as `OPS-41` requires.
1222: 
1223:   **AMENDED 2026-09-08 (`ADR-0017`) — the fence holds the episode, not the attempt.** It held the
1224:   attempt's operation id until today, and `IS NULL` alone until 2026-09-02: a first attempt that set
1225:   the fence, called the provider and failed left its own id in the column, a second attempt's write
1226:   affected no row, read that as "another actor won", and settled `succeeded` recording that no
1227:   mutation was required — resolving the episode on a machine still running and still billing, while
1228:   `LDG-62` was refused `conflict` with "the machine is already being cancelled", which was
1229:   permanently false. The episode outlives every attempt (`ADR-0017`), so a `retry`'s fresh attempt
1230:   (`OPS-48`, `API-64`) contends on the same id and executes. **A worker MUST NOT treat its episode's
1231:   id in that column as evidence that a previous attempt succeeded** — the whole reason a retry was
1232:   issued is that the provider did not act.
1233: - `LDG-62` MUST, in its own `LDG-35` transaction, conditional-write that same machine row guarded on
1234:   `destroy_committed IS NULL`, and MUST fail `conflict` where it affects no row. **No commitment is
1235:   opened or grown and no balance moves**; the tenant is told plainly that the machine is already
1236:   being cancelled.
1237: - **`OPS-41`'s re-check and this fence write MUST be one transaction, under `LDG-35`'s per-tenant
1238:   serialization.** The worker holds the machine (`OPS-8`) and enters the serialization for that
1239:   bounded read-and-write, which is the one nesting direction `LDG-69` permits; it releases it before the
1240:   provider call, which `LDG-69` forbids inside. **AMENDED 2026-09-02, because without this the fence
1241:   does not fence.** `LDG-62` runs in its own `LDG-35` transaction, so unless the read and the fence
1242:   write are inside one too, the extension can commit in the gap *between them* — the worker reads
1243:   *unfunded*, the extension commits and grows the commitment, the worker's `IS NULL` write then
1244:   succeeds because nothing has touched that column, and the machine the customer has just paid for
1245:   is destroyed. That is the identical window this requirement was written to close, moved earlier by
1246:   one step. Serializing the pair is what makes the next sentence true.
1247: - Because both transactions take the same tenant primitive and write the same row, the store totally
1248:   orders them. Fence first: the extension is
1249:   refused, and the customer keeps its satoshis. Extension first: the worker's read sees the new
1250:   commitment, `OPS-41` applies, and it makes no provider call at all.
1251: 
1252: **`LDG-62` never waits on the machine, which is why it is the fence rather than the ordering.**
1253: `LDG-62` is not an operation and holds no machine under `OPS-8` — a synchronous caller write cannot
1254: wait behind an install holding the machine for up to `RSC-35`'s ninety minutes, and refusing to
1255: extend runway for the duration of an install is precisely the wrong failure. **The worker holds the
1256: machine and then takes the tenant primitive**, in that order; `LDG-62` takes the tenant primitive
1257: and never the machine. A cycle needs two acquirers in opposite orders, and there is no second order here.
1258: 
1259: *This paragraph said the worker takes the machine and never the tenant primitive until 2026-09-02,
1260: and it is retained because the trap is live: that sentence was true of the withdrawn ordering-only
1261: design, it survived the amendment four bullets above that made the worker enter `LDG-35`'s
1262: serialization, and it is the sentence a builder implementing the ordering discipline would have
1263: read. Implementing it reopens the paid-machine deletion race this whole requirement exists to
1264: close. Found by both reviewers of 2026-09-02, independently.*
1265: 
1266: **The residual is stated rather than solved:** a payment landing after the fence is refused rather
1267: than silently ignored, so the customer learns the machine is going and keeps its money. That is the
1268: honest outcome, and it is the one `OPS-36` promised of its survival branch, "This is the branch
1269: that makes `OPS-33`'s early release safe" — a promise that requirement could not keep alone.
1270: 
1271: **Amended 2026-10-04 (`pv-gip.11`, `ADR-0032`).** On a `stalled` episode the fence, where written,
1272: persists until a close under `OPS-48`. The operator's paths are `API-64` retry and `API-68`
1273: keep; an extension still meets `LDG-62`'s fence check. The earlier retry-driven revival and
1274: accepted no-exit residual are withdrawn. A provider refusing deletion indefinitely no longer
1275: leaves the operator without a way to admit a customer's later extension: keep supplies that
1276: explicit decision. It buys no runway; `API-68` owns the next-sweep consequence.
1277: 
1278: *Both reviewers of 2026-08-31 rejected the ordering-only fix independently and converged on a fence;
1279: the shape here is the one that does not make extend-runway wait on the machine.*
1280: 
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
801: 8. Perform `API-63`'s conditional write on `STO-47`'s row, in the correlator transaction:
802:    "the worker MUST repeat the admission check as a conditional write on `STO-47`'s row guarded
803:    on `healthy`". It remains "the last write before the ordering call" (`API-63`).
804:    In this same transaction, on every ordering channel, including `correlator: none`, the worker
805:    MUST set `operations.about_to_order_at` to `COALESCE(about_to_order_at, <transaction time>)`
806:    guarded on `(id, status = running, claim_number = mine)` (`STO-3`; `OPS-6`:
807:    "every write that worker makes to the operation MUST carry `claim_number = mine`").
808:    The write MUST NOT be guarded on the column being null: a whole-transaction repeat after a
809:    lost reply affects one row and changes nothing. If this operation-row write affects zero rows,
810:    something else moved the operation: step 9 MUST NOT run and the worker MUST exit. This differs
811:    from the zero-row `STO-47` check above, of which `API-63` says "where it affects no row MUST
812:    fail the operation deterministically". A first attempt that fails that check commits no
813:    `about_to_order_at`. If an earlier step-8 transaction committed but its reply was lost, and an
814:    account-status write makes the account non-`healthy` before the whole-transaction repeat,
815:    the repeat can fail that check with the column already set. The create still settles `failed`
816:    under `OPS-11`'s create row: `OPS-11` says "Any create failure the worker records before any step-9 request (before any per-order key upload or order request) MUST settle `failed`, whatever its kind."
817:    Step 9 MUST begin only after step 8's transaction is acknowledged. A lost acknowledgement
818:    MUST take `OPS-49`'s "repeat the **whole transaction**" path, never speculative dispatch.
819: 9. Perform the per-order key upload, then the order. Here **per-order key upload** means every
820:    temporary key registration required for this create (`PRV-9`: "the driver MUST register and
821:    attach them as temporary provider-side resources").
822: 
823: *Amended 2026-10-17 (`pv-k4l`; panels r56 and r56b, `docs/research/panels-2026-10/r56/` and `docs/research/panels-2026-10/r56/r56b/`): made step 8 write the column under the worker guard and await acknowledgement before step 9.*
824: 
825: *Amended 2026-10-21 (`pv-p1y`): pointed step 7's rejection at `PRV-47`.*
826: 
827: *Amended 2026-10-21 (`pv-xer`; owner decision of 2026-10-21): extended step 1's quote of `API-63`
828: to its `retryable` values.*
829: 
830: The first failing check stops subsequent checks; its owning classification governs disposition.
831: Claim-time refusals are not collected: the error carries neither `details.refusals` nor
832: `details.not_checked`. The order differs from admission: a create both closed and unsellable
833: fails `rate_limited` at claim (`PRV-40`: "If the channel is closed at that read, the worker MUST
834: make no provider request and settle the existing operation `failed` with `rate_limited`") but
835: `offer_not_sellable` at admission, where `API-7` orders "`invalid_request`/`offer_not_sellable`"
836: before "`rate_limited` when the offer's account and ordering channel are closed under `PRV-40`".
837: 
838: The sale re-test and price comparison apply to the named offer as that result lists it. At
839: claim (`OPS-5`), `PRV-42`'s dispatch check ("the driver MUST confirm that the named offer is
840: still listed before sending the order request") reads that same step-4 List offers result.
841: `PRV-42` says "a missing offer MUST NOT be ordered"; for an offer absent from that result, the
842: worker MUST NOT perform any step-9 provider mutation either, including a per-order key
843: upload.
844: 
845: If the offer is absent from that result or the re-test finds it unsellable, the worker MUST fail
846: the operation deterministically before any provider mutation, with `invalid_request`,
847: `details.reason: "offer_not_sellable"` and `retryable: false` on both the error and the operation
848: view. The operation settles `failed` under the create row. `OPS-11` says "Any create failure the worker records before any step-9 request (before any per-order key upload or order request) MUST settle `failed`, whatever its kind." The error is `WIR-9`'s inner object under `WIR-10b`; `WIR-9` says "The inner
849: `error` object is exactly `kind`/`message`/`retryable`/`details` and nothing else, because it is
850: the object `WIR-10b` embeds in an operation view". It carries neither `details.refusals` nor
851: `details.not_checked`; `WIR-9a` introduces those keys "**On create and extend-runway tail
852: refusals**". Its details obey `WIR-9a`'s "no cap or balance result or amount derived from the
853: withheld offer's price". The commitment is released in full under `LDG-39`'s
854: "Deterministic rejection before acceptance" case — before provider acceptance — with no setup
855: fee or first unit debited: that row says "**Never debited**; released with the commitment
856: (`LDG-32`)". `LDG-32` requires "A commitment MUST be closed, and its remaining amount released
857: in full" on, among its terminal outcomes, "the create fails deterministically".
858: Where the create holds a resource-offer exclusion, settlement frees it (`STO-58`: "Its lifetime
859: follows the winning create's outcome settlement"; `PRV-42`: "An unresolved create retains the
860: claim until its outcome is known").
861: 
862: *Amended 2026-10-18 (`pv-qga`; panel r57, `docs/research/panels-2026-10/r57/`; `ADR-0043`): pointed settlement at the create row and accounted for a lost step-8 reply followed by an account-status write before the repeat; that refusal can leave the column set.*
863: 
864: After the sale re-test passes, and before any per-order key upload or other provider mutation,
865: the worker MUST re-read the offer's current price from that same List offers result **in the
866: provider's own currency** and compare it with the native price the commitment was sized from — **carried on the
867: operation's `request_summary`, which MUST hold the accepted recurring price, its
868: currency and its period, and the accepted setup fee and prepaid first unit, the unit with its
869: `billing_unit.seconds`** (`LDG-2`, `LDG-67`; *the unit and its seconds added 2026-10-08,
870: `ADR-0033`, because the machine's row copies the seconds for its first seed, `LDG-38`,
871: `05-persistence.md`*; *the
872: fields are named so a worker restarted before claim can perform this comparison at all*; *named 2026-09-05 — a first form cited a native figure on the commitment
873: row, which carries only `reserved_sats`*) — and **fail the operation deterministically — before any
874: provider
875: mutation — where the provider's price has risen past what the reserve covers**: `conflict`,
876: `details.reason: "price_moved"`, the shortfall in `details`, telling the caller to re-submit,
877: and `retryable: true` on both the error and the operation view (`WIR-9b`). **A
878: movement in the satoshi rate alone MUST NOT refuse** — that is `ADR-0011`'s business, and it moves
879: the runway date rather than the order. *Corrected 2026-09-05. The withdrawn test was "recompute
880: `PRV-13b`'s reserve at the current rate … where the open commitment no longer covers it", and the
881: reserve carries the satoshi rate, so any downtick between accept and claim refused; the caller
882: resubmitted at the new rate, the next downtick refused again, and under a falling market creates
883: failed persistently on a product that had no shortage of provider capacity. It also named no error
884: kind, and `OPS-11` makes `insufficient_balance` admission-only, so a worker had nothing legal to
885: emit.* Same shape and same point in the lifecycle as `OPS-40`'s
886: signed-URL gate: it fails before anything is bought, so nothing ambiguous is created and no
887: reconciliation is needed.
888: 
889: **Nothing is grown.** This is a refusal, not a top-up, so `ADR-0011` is untouched — a commitment
890: still increases only by `LDG-62` and `LDG-63`'s scheduled-cancellation branch.
891: 
892: *The asymmetry that exposed it: the second order the set once admitted (`ADR-0014`, `ADR-0017`) was
893: re-priced because it "happens later — possibly much later". An original create has the same latency
894: and had no such rule, so the operator absorbed the difference silently and learned about it from an
895: invoice.*
896: 
897: *Amended 2026-10-16 (`pv-hsm`; panel r54, `docs/research/panels-2026-10/r54/`): added the
898: claim-time sale re-test, its inputs and the five-step claim order; tied `PRV-42`'s dispatch
899: check at claim to the step-2 result and barred any step-5 provider mutation for an offer absent
900: from it; specified the re-test's deterministic failure and pointed at `LDG-39` for the
901: commitment release.*
902: 
903: *Amended 2026-10-17 (`pv-14b`; panel r55, `docs/research/panels-2026-10/r55/`): completed the
904: claim order and its precedence, placed validation and account checks, and extended the offer
905: failure outcome to absence with resource-offer exclusion settlement.*
906: 
907: *Amended 2026-10-21 (`pv-xer`; owner decision of 2026-10-21): gave `price_moved` `retryable: true`
908: on the error and the operation view.*
909: 
910: *Amended 2026-10-22 (`pv-p3k`; panel r62, `docs/research/panels-2026-10/r62/`; owner decision 2026-10-22): applied the reviewed ordering-capability change.*
911: 
912: *Amended 2026-10-22 (`pv-009`; panel r62, `docs/research/panels-2026-10/r62/`): applied the reviewed claim-time capability gate and refusal checks.*
913: 
````

## OPS-45 — 03-operation-lifecycle.md:1452

````text
1452: **OPS-45** **The engine knows whether it started writing, and that knowledge MUST be recorded and
1453: used before anyone asks a human.** `OPS-11` sends an install's `integrity` failure to
1454: `needs_reconciliation`; `RSC-3`'s host-key abort is an `integrity` failure that happens **before the
1455: connection is made**, with nothing written and the machine's disk untouched — and `OPS-31`'s verbs
1456: could only ever call that outcome "abandoned". So the differentiator's most security-critical
1457: success case (a pinned key that did not match, aborting exactly as designed) ended as an
1458: operator-resolved loss.
1459: 
1460: **This requirement governs the kinds that act on a machine that already exists — install, rescue
1461: inventory, power, reverse DNS, delete and release attachment (`PRV-45`) — and nothing else.** It does **not** reach `create`:
1462: there is no machine yet, the question is whether a *resource was produced*, and the answer
1463: comes from `OPS-27`'s correlator search rather than from anything the engine can record about
1464: itself (*except, since 2026-10-17, the null `about_to_order_at` that `OPS-15` settles on a restart,
1465: and, since 2026-10-18, a failure the worker records before any step-9 request (`OPS-11`'s create row);
1466: see the notes below*). Nor does it reach `suspend_tenant`, which mutates no provider (`OPS-11`). *Until
1467: 2026-09-08 this sentence excluded `adopt` on the same grounds, which were false for a machine that
1468: already exists; adopt is withdrawn (`ADR-0020`).* **Scoping this is
1469: not a formality**: read unscoped, "the marker is unset, so settle `failed`" would settle every
1470: ambiguous create as a deterministic failure, which deletes `OPS-27`'s resolution, `OPS-33`'s
1471: negative window, `OPS-36`'s late attach and `LDG-39`'s whole fee table in one sentence — the
1472: correlator exists precisely because a dispatched create's own execution cannot establish whether the provider produced a resource.
1473: 
1474: *Amended 2026-10-17 (`pv-k4l`; panels r56 and r56b, `docs/research/panels-2026-10/r56/` and `docs/research/panels-2026-10/r56/r56b/`): the execution-only argument above applies after step 8 may have committed. `OPS-15` now says "A create found `running` at startup with `about_to_order_at` null MUST be settled `failed`, on a restart only." The column is not a marker; only its null, read by that restart pass before any step-9 mutation could have begun, settles anything. A set column leaves the create on the ordinary ambiguous path (`ADR-0042`).*
1475: 
1476: *Amended 2026-10-18 (`pv-qga`; panel r57, `docs/research/panels-2026-10/r57/`; `ADR-0043`): extended the scope pointer. A worker-recorded failure also settles a create under `OPS-11`'s create row, reading neither the column nor a marker, even when the column is set (after step 8 is acknowledged or after a lost step-8 reply): `OPS-11` says "Any create failure the worker records before any step-9 request (before any per-order key upload or order request) MUST settle `failed`, whatever its kind." The 2026-10-17 note's "only its null, read by that restart pass before any step-9 mutation could have begun, settles anything" and "A set column leaves the create on the ordinary ambiguous path" now describe the restart path only.*
1477: 
1478: **The engine MUST persist a write-started marker on the operation**, at the moment a phase begins
1479: that could have altered the machine, and before that phase runs:
1480: 
1481: | Kind | The marker is set when |
1482: |---|---|
1483: | install, `rootfs_via_rescue` | the provider's OS installer is started (`RSC-25` verifies the digest first, so nothing before that point has touched the disk) |
1484: | install, `raw_disk` | the first byte is written to the target device (`RSC-28`) |
1485: | install, `provider_native` / `provider_catalogue` | the provider's rebuild call is dispatched |
1486: | power, reverse DNS, delete, release attachment | the provider call is dispatched |
1487: | rescue inventory (`RSC-38`) | **never** — it writes nothing to a disk by construction, so its whole classification turns on the second marker below |
1488: 
1489: **Entering rescue is itself a mutation, so a second marker is required and the two are read
1490: together.** Activating rescue reboots the machine into another operating system (`PRV-15`) and
1491: `PRV-22` makes *failure* of the exit always ambiguous — so "nothing was written" is not on its own
1492: "nothing happened". The engine MUST therefore also record **whether the rescue session it opened
1493: was closed without error** — `rescue_exited_cleanly` (`05-persistence.md`), three-valued: **null**,
1494: the column before its first write, which says no session was opened (*reworded 2026-09-19; it read
1495: "where begin rescue was never dispatched"*); **false, written before begin rescue (`PRV-15`) is
1496: dispatched**, as the write-started marker is written before its phase, and standing while the
1497: session is open, where the exit fails and where the operation dies before reaching it; **true**
1498: when the driver's end-rescue call returns success. A dead process writes nothing, which is why
1499: `false` precedes the session and not the exit: it is what lets `OPS-15`'s pass render `rescue_exit:
1500: "unknown"` (`RSC-19`, `WIR-9a`). `false` is the conservative value as much as the open-session one:
1501: a process that dies between that write and the dispatch leaves `false` over a machine that was
1502: never rebooted into rescue, and the column does not separate that row from one whose session is
1503: still open. Null is the only value that means no session was opened, and `false` moves to `true`
1504: and never back. **A driver's report that it cleaned up after a partial activation (`PRV-18`) does
1505: not move this marker**: the engine did not open the session and did not close it. On failed
1506: deactivation `PRV-18` reports "the identifier of the rescue environment left behind"; on failed
1507: eligible-key deletion it reports "the identifier of the key left behind". `PRV-18` also says "A key
1508: deliberately retained while deletion is ineligible is not a failed cleanup." Those reports are
1509: operator-facing facts, not the engine's record of its own execution. *Until 2026-09-16 this read "set when the driver's
1510: end-rescue call returns success, left unset when it fails or when the operation dies" — the
1511: classifier's two-way question standing where the column's three values belonged, and no sentence
1512: said when the column was written; a never-attempted exit was a third case until `RSC-18` was
1513: withdrawn, 2026-09-15. Four readers converged on the pre-dispatch write.*
1514: 
1515: **An operation settles `failed` — deterministically, with no operator and no reconciliation — when
1516: the write-started marker is unset *and* either no rescue session was opened or the one that was
1517: opened was closed without error.** In that state the engine has positive evidence from its own
1518: execution that the disk is untouched and the machine is back where it started. This rule classifies a failure a
1519: worker recorded; an operation interrupted rather than classified is `OPS-15`'s, whatever the markers
1520: hold, and after a restore `STO-54` quarantines it on the same footing (*scoped 2026-09-16*). Everything else
1521: follows `OPS-11`'s classification, and resolution then
1522: proceeds by `PRV-29`/`PRV-36`'s provider evidence where the driver can produce it, falling back to
1523: `OPS-31`'s `applied`/`not_applied`/`abandoned` where it cannot.
1524: 
1525: **The marker means two different things across the table above, and only one of them can foreclose
1526: anything.** On `rootfs_via_rescue` and `raw_disk` it means **the destructive phase was allowed to begin** — the
1527: installer invoked, or the first write issued — and from then on the machine's old contents MUST NOT
1528: be represented as preserved, whatever the outcome. The marker is written before the phase runs, so
1529: it establishes that preservation is no longer proven, not that a byte landed: a process that dies
1530: between the write and the phase leaves a set marker over an untouched disk, and nothing later can
1531: tell the two apart (*reworded 2026-09-15; it read "bytes have reached the disk"*). On `provider_native`, `provider_catalogue`, power, reverse DNS, delete and release
1532: attachment it means only
1533: that **a request was dispatched**, which is a fact about this process and not about the machine: a
1534: rebuild the provider never began, a power call it dropped, a delete whose response was lost, all set
1535: the marker and all may have changed nothing. *Recorded 2026-09-04 because a single column carrying
1536: two meanings was read as carrying the first one everywhere — see `WIR-35`, where it made
1537: `not_applied` unreachable on every kind whose marker is set at dispatch, which is every kind that
1538: accepts the verb except the two rescue-based install variants.* Where the marker means
1539: dispatch, whether the mutation landed is exactly the question `OPS-31`'s resolution exists to
1540: answer, and it is answered from the provider (`PRV-36`'s evidence sources), never from this column.
1541: 
1542: **The markers are per operation, and nothing clears them** (amended 2026-09-08, `ADR-0017`). An
1543: operation is one attempt; a later attempt on the same machine is a fresh operation with unset
1544: markers of its own, so "did **this** attempt dispatch" is answered by this row and no other. *Until
1545: today the dispatch-kind marker was cleared when the same record was re-run, so a second attempt
1546: stopping short did not inherit the first's ambiguity; a settled or unresolved record is no longer
1547: re-run (`ADR-0017`), and there is nothing to clear. A record claimed again after an `OPS-8` defer
1548: is the same attempt continuing under a new claim number (`OPS-6`), and its markers stay.*
1549: 
1550: **The pinned-host-key abort is the case this exists for.** `RSC-3` refuses to connect when the trust
1551: decision cannot be made — the security-critical decision in the whole workflow, working exactly as
1552: designed — and with the rescue exit succeeding, the machine is back in its installed
1553: system with nothing written. That is a clean, deterministic refusal, and it was reaching
1554: `needs_reconciliation` and then an operator's `abandoned`. **Where the same abort is followed by a
1555: failed rescue exit it stays ambiguous**, because the machine may be sitting in rescue with a
1556: temporary credential registered — which is `PRV-22`'s point and is a fact about the *machine*, not
1557: about the disk.
1558: 
1559: **Both markers MUST survive the payload purge** (`ADR-0005`, `OPS-2`). They live in named columns on
1560: the operation (`05-persistence.md`), which is what `OPS-11` and `OPS-31` read; the copy in
1561: `request_summary` is a **convenience copy for an operator reading a resolved record**, and the
1562: columns are authoritative. *Stated because one fact with two homes and no authority rule is how
1563: `SEC-46`'s amendment came to ship claiming it had applied.*
1564: 
1565: **What outlives the operation is the disk, not the marker.** A `rootfs_via_rescue` or `raw_disk`
1566: install whose marker is set may have altered the disk, and no later operation that stops short
1567: re-establishes that it did not; it is read from that operation's row, which `STO-14` retains
1568: as any settled row. `rescue_exited_cleanly` describes **the machine as that operation left it**,
1569: and a later operation that exits rescue cleanly genuinely repairs what a previous one left open,
1570: recorded on its own row.
1571: 
1572: A worker's write of either is guarded like any other worker write (`STO-3`), and MUST report
1573: whether it affected a row — a worker that has been overtaken MUST NOT record that it began writing;
1574: it exits. **The write sets the marker only where it is null** — `COALESCE(write_started_at, now)` under the
1575: worker guard, never a guard on the marker being null (amended 2026-09-12, `ADR-0022`): a repeat
1576: after a lost reply then affects a row and moves nothing, where a null-guarded write would affect
1577: no row and read as overtaken. The second marker has two writes of the same shape (*2026-09-16*):
1578: `COALESCE(rescue_exited_cleanly, false)` before the begin-rescue dispatch, and `true` on the
1579: end-rescue success, idempotent by value; both under the worker guard, and each acknowledged by the
1580: store before the provider call it precedes is made.
1581: 
````

## OPS-48 — 03-operation-lifecycle.md:1285

````text
1285: **OPS-48** **ADDED 2026-09-08 (`ADR-0017`) — the episode lifecycle.** An episode (`DOM-31`,
1286: `STO-52`) is opened in `attempting` by the sweep or transaction that detects the condition, with
1287: its first attempt enqueued in the same transaction; while it is open the index is the dedup and a
1288: sweep enqueues nothing against it (`OPS-39`). Every attempt is an ordinary operation carrying
1289: `operations.episode_id`, and `current_operation_id` names the latest. **An attempt settling
1290: `failed` does not close the episode**: `failed` is a fact about the attempt, and the episode is
1291: still open, still billing, and waiting on a decision. The transitions are exactly these, keyed on
1292: how the current attempt settled — by the worker, by `OPS-27`'s evidence, or by `OPS-31`/`OPS-45`'s
1293: operator verb — and on the operator verbs on the episode (`API-64`, `API-68`):
1294: 
1295: <!-- formal: Provisiond.Render.ops48Table -->
1296: | The attempt settled | The episode | `machines.destroy_committed` (the fence, `OPS-42`; exposure-reducing cancellations only) |
1297: |---|---|---|
1298: | `succeeded`, resource gone — including `OPS-11`'s goal-state row | `closed`, `close_reason: resource_gone`, in the terminal transaction | **Cleared**, same transaction |
1299: | `succeeded` recording that no mutation was required (`OPS-41`'s abort) | `closed`, `close_reason: funded`, in the terminal transaction: the condition has ended, and a later lapse opens a fresh episode | **Cleared**, same transaction |
1300: | `succeeded`, **scheduled** — the provider accepted a dated cancellation and the machine remains present (`DOM-19`, `STO-8a`, `PRV-13`) | `scheduled`; the later evidenced gone-write uses the last row, whether before or after the effective date. The date alone does not close it. Tombstoning follows only when `STO-18` permits. | **Unchanged** |
1301: | `failed` — deterministic; the provider did not act | `stalled` | **Unchanged** |
1302: | `needs_reconciliation` | `uncertain`, until the attempt is resolved (`OPS-27`, `OPS-31`) and one of the rows below applies | **Unchanged** |
1303: | Resolved `applied`, the resource gone (`OPS-45`) | `closed`, `close_reason: resource_gone`, in the resolution transaction | **Cleared**, same transaction |
1304: | Resolved `applied` **with an `effective_cancellation_date`** (`WIR-35`) — the operator established the provider *scheduled* it | `scheduled`, as the third row | **Unchanged** |
1305: | Resolved `not_applied` — the machine is still there | `stalled` | **Unchanged** |
1306: | Resolved `abandoned` — nobody established what happened | `closed`, `close_reason: abandoned`, in the resolution transaction | **Cleared**, same transaction, so a later sweep may open a fresh episode and fence again |
1307: | `retry` (`API-64`) on a `stalled` episode | `attempting`, with a fresh attempt enqueued in the same transaction as the state change; admissible in no other state; the attempt follows `OPS-41`'s ordered decision | **Unchanged**: the new attempt contends on the same episode id |
1308: | `keep` (`API-68`) on a `stalled` episode | `closed`, `close_reason: kept`, in the keep transaction; admissible in no other state | **Cleared**, same transaction |
1309: | No attempt settled — **the machine is recorded gone** (`ADR-0021`): the write of `machines.state` to gone with `machines.state_observed_at` (`STO-48`), by any of `LDG-74`'s triggers — a refresh, a driver read during any operation, `OPS-32`'s complete pass — or by `API-63`'s termination; in any open state, `scheduled` included. Where that write and an attempt's terminal write are one transaction, as a delete's own "already gone" answer is, they are one close under the first row | `closed`, `close_reason: resource_gone`, in the transaction that records the gone state | **Cleared**, same transaction |
1310: <!-- /formal -->
1311: 
1312: **Unchanged** preserves the actual fence value. An episode none of whose attempts reached
1313: the fence transaction holds null. *Token clarified 2026-10-05 (`pv-gip.43`, Q14, `ADR-0032`);
1314: no lifecycle outcome changes.*
1315: 
1316: *Amended 2026-10-04 (`pv-gip.11`, `ADR-0032`): the automatic funded-close row is
1317: removed; retry and keep use the operator rows above. The earlier still-unfunded universal is
1318: withdrawn. No timer moves a stalled episode; the evidenced gone-write remains a close.*
1319: 
1320: *The table is a marked region since 2026-09-15 (`ADR-0025`): its outcome tokens render `OPS-48`'s
1321: declaration, and the retry and scheduled rows' fence cells were reworded that day to carry the
1322: verdict token, with no row's meaning changed.*
1323: 
1324: *Amended 2026-10-11 (`ADR-0037`, Q21/Q22): the scheduled row remains open after its effective
1325: date while the machine is present. An evidenced gone-write, including `PRV-13`'s cancellation
1326: read-back, closes the episode and clears its fence; a retained gone machine can await attachment
1327: release evidence before tombstoning. A later attempt resolution cannot reopen the closed episode.*
1328: 
1329: **A close is permanent, and the rows above apply to an open episode only** (`ADR-0021`). An
1330: attempt under a closed episode that later settles, or is resolved under `OPS-31`, changes the
1331: attempt and not the episode: `closed_at`, `close_reason` and the cleared fence stand, `STO-52`'s
1332: index admits a fresh episode, and a `not_applied` on such an attempt does not put a closed episode
1333: back in `stalled`. The writes that could race a gone-write are guarded against it: `retry`'s
1334: `stalled → attempting` is a conditional write on `(id, state = stalled)` (`API-64`), and `OPS-42`'s
1335: fence write is guarded on the episode being open; keep uses `API-68`'s conditional close. The gone-write row keys on the **machine's** gone-write and never on the
1336: account's status: a machine `OPS-36` attaches under a terminated account has been observed present,
1337: carries no gone-write, and its cleanup episode goes `stalled` — `API-63`: "That is the honest end
1338: for it". `OPS-25` still
1339: retains the unresolved attempt; the termination establishes that the resource is gone, not which
1340: call made it so.
1341: 
1342: **A `stalled` episode is never retried by a timer.** A deterministic rejection repeated
1343: automatically is the loop `OPS-39` exists to prevent. A throttle refusing the mutation before
1344: acceptance is `failed` and stalls the episode;
1345: a later failure of an accepted mutation follows `OPS-11`'s
1346: "the operation's mutating request was accepted by the provider" condition. For an accepted
1347: dated cancellation whose read-back fails, `PRV-13` instead says "the accepted attempt settles
1348: `succeeded` as `cancellation_scheduled` with its effective date"; the episode takes the
1349: scheduled row and keeps its fence. Neither case returns the attempt to `queued` (`F48`
1350: records the rejected deferral). *Clarified 2026-10-11 (`ADR-0037`, Q22).*
1351: *Amended 2026-10-08 (`ADR-0035`): the earlier blanket throttled-delete failure description is
1352: withdrawn; the table consumes the classification and its episode/fence effects are unchanged.*
1353: A `stalled` or `uncertain` episode is therefore the operator's to look at
1354: (`OPS-26`): its machine may still be running and billing, and the episode is not over. A later
1355: rate can fund it; a deletion decision already recorded by a fence is not reversed by that rate. The open episode is what keeps a later sweep from enqueuing
1356: a **second** delete against the same machine, and a written fence is what keeps `LDG-62` from selling
1357: runway after the deletion decision. See `OPS-41`'s ordered decision for an unfenced episode's attempt.
1358: 
1359: **`scheduled` is the row a reader will not expect.** `DOM-19` says "Passing the date
1360: alone is no evidence of absence." While the machine is present it may still cost the operator,
1361: including after its effective date, and the next exhaustion sweep can find it. Closing the episode there
1362: is precisely the case `OPS-39`'s 2026-08-14 amendment warns about — "on a provider that accepts a
1363: *scheduled* cancellation the second call can then alter or repeat the first's mutation" — reached
1364: through resolution instead of through a reason key. So an `applied` carrying an
1365: `effective_cancellation_date` schedules rather than closes, exactly as it would had the worker's
1366: own call returned the schedule. *A cancellation resolves through `OPS-45`'s verbs, not through
1367: `observed`/`absent`: those name a resource a create may have produced, and a cancellation names a
1368: machine that already exists.*
1369: 
1370: **Nothing else clears `destroy_committed`.** The column's life is stated for every outcome in the
1371: table, and the deliberate answer for an attempt that *did* reach the provider without ending the
1372: exposure is that the fence **persists** — the customer keeps its satoshis and is told plainly that
1373: the machine is being cancelled — the residual `OPS-42` accepts, not an oversight. On
1374: the scheduled branch that is also the right answer on its own terms: runway bought past an
1375: effective cancellation date buys no customer-metered machine time, since `LDG-38` says
1376: "the earlier of its `effective_cancellation_date` and any gone observation" is the stop.
1377: The machine may remain present after that date; `LDG-74` says "A machine **still present after
1378: its date** has its meter stopped and is billing the operator". *Clarified 2026-10-11
1379: (`ADR-0037`, Q21/Q22).*
1380: 
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
````

## API-13 — 04-api-contract.md:962

````text
962: **API-13** The following MUST be enforced before an operation is enqueued:
963: 
964: | Field | Rule |
965: |---|---|
966: | hostname | 1–253 characters, no CR or LF |
967: | offer identifier | 1–256 characters |
968: | SSH public keys | at most 64, each ≤16 KiB, each recognizably an OpenSSH public key |
969: | expected rescue host keys | at most 16, each a complete OpenSSH public host key |
970: | catalog image | 1–256 characters |
971: | user data / post-install script | ≤1 MiB |
972: | provider options | MUST be a JSON object |
973: | image URL | ≤8192 bytes, no fragment, no embedded credentials, scheme `https` (or `http` only where explicitly enabled), host in the allowlist. **For a `provider_catalogue` install the allowlist is mandatory and an empty one refuses the request** (`SEC-19`, `RSC-39`), since provisiond itself is the client there; on the rescue strategies an empty list still means any host and is a startup warning. *"When one is configured" applied the fail-open reading to both paths and was withdrawn 2026-09-02* |
974: | disk identifier | a JSON string, non-empty after normalization (`RSC-46`); a `null`, non-string or empty-after-normalization `target.identifier` or `layout.drives[].identifier` MUST be refused `invalid_request` before enqueue. Resolution: `RSC-26`. |
975: | digest | exactly 64 hex characters (`DOM-14`) |
976: | strategy/image pairing | per `DOM-13` |
977: | host-key policy | pinned keys and "accept unpinned" MUST be mutually exclusive |
978: | request body size | globally capped (2 MiB is a reasonable default) |
979: 
980: *Amended 2026-10-22 (`pv-6p8`, panels r61–r61f; owner decision 2026-10-22): added admission of
981: disk identifiers before enqueue.*
982: 
````

## API-14 — 04-api-contract.md:983

````text
983: **API-14** An install request MUST carry an explicit destructive acknowledgement, and a
984: delete request MUST carry one. Absent or false MUST fail `400`. This is per request, and
985: is not satisfied by authentication, by idempotency, or by having sent one previously.
986: 
````

## API-16 — 04-api-contract.md:994

````text
994: **API-16** A reverse-DNS request MUST be rejected unless the supplied address is present
995: in the machine's recorded address list, and the hostname MUST be 1–253 characters with no
996: CR or LF.
997: 
998: The refresh and reverse-DNS endpoints retain `API-7`'s "enqueue an operation, then `202`".
999: Local successful settlement: `DOM-8` and `PRV-25`. Result bodies: `WIR-10`.
1000: *Amended 2026-10-08 (`ADR-0034`).*
1001: 
````

## API-58 — 04-api-contract.md:617

````text
617: **API-58** **A funded tenant MUST be suspended, never deleted.** Suspension is an operator action
618: that (1) marks the tenant `suspended` **in the admission transaction, before the `202` is returned**,
619: so no further **tenant-authorized** write succeeds —
620: the maintenance actions of `API-7` step 2 remain reachable, because a suspended owner must still be
621: able to revoke a stolen credential (`API-56`, `CNF-209`), and an operator may retry a stalled
622: episode (`API-64`), which skips step 5b like every operator verb (`API-7`) — then (2)
623: **fences work already in flight** — a create claimed before the suspension landed MUST be allowed
624: to settle rather than abandoned mid-order, and its machine is then cancelled by the same sweep,
625: because abandoning an in-flight order is how a machine ends up bought, unrecorded and unbilled —
626: then (3) enqueues a system cancellation per machine (`OPS-39`) — then (4) **transitions the tenant's own work — `requested_by: caller`, never a system
627: cancellation — that is already
628: `queued` but never claimed straight to `failed`, carrying the reason in the operation's `error`:
629: `conflict`, with `details.reason: "tenant_suspended"`** (`WIR-9a`, `WIR-10b`) — it
630: has touched no provider, so cancelling it needs no operation, and it does **not** carry the error
631: kind `suspended`, which `OPS-11` classifies as admission-only and forbids a worker to emit: that
632: kind stays an admission-time rejection of a *caller's* write (`DOM-20`).
633: **Its `requested_by` stays `caller` and its `system_reason` stays null**, because `WIR-10` permits
634: a non-null `system_reason` only on `requested_by: system`, and re-labelling the request `system`
635: to make room for one would attribute the caller's own create to the system and destroy the record
636: of who asked for it. The reason belongs in the error, which is where a caller reads why its work
637: did not run. *`system_reason: tenant_suspended` was the withdrawn form and it produced an
638: operation view no strict parser should accept.* The value stays legal on the step-(3)
639: cancellations, which the system really did request (`OPS-39`). This transition is also **not** a
640: worker classification: nothing was claimed and no driver was called, so `OPS-11`'s install row —
641: which sends `conflict` to `needs_reconciliation` "once the write-started marker is set" — does not reach it, and the operation goes
642: straight to `failed` as stated. **Not being a classification does not exempt the database write**:
643: it is `STO-3`'s fifth named case (fourth until the defer was listed on 2026-09-12), guarded on its full predicate — `(id, status = queued,
644: requested_by = caller, tenant suspended, this suspension's parent still unsettled)`, quoted rather
645: than paraphrased since 2026-09-05, when a paraphrase here dropped the `requested_by` term and let
646: step (4) fail the system delete step (3) had just named — and reporting whether it affected a row, so a child claimed
647: by a real worker in the meantime loses this race and settles through that worker instead. The fan-out then lets anything
648: already `running` settle, **then re-sweeps: a create that
649: settled after the fan-out has produced a machine the first pass never saw, and it MUST be
650: cancelled by a second pass rather than left running against a suspended tenant** — the fan-out
651: repeats until a pass finds no un-cancelled machine; then (5) aggregates the outcomes,
652: including any that end `needs_reconciliation`. **The parent then settles `succeeded`, with those
653: children named in its result** (`WIR-39`'s `cancellations`) — its own job was to fan out and
654: account for every machine, and it has done it. `OPS-11`'s `suspend_tenant` row already counts a
655: `needs_reconciliation` child as complete for the parent, and step (5) did not say what that makes
656: the parent's own outcome; it is `succeeded`, never `failed` and never `needs_reconciliation`. The
657: unresolved children are their own records, resolved by their own evidence or their own operator
658: verb (`OPS-27`, `OPS-31`), and read through `GET /v1/operations` like any other operation. Holding
659: the parent open until they resolve would fence `WIR-41`'s resume off indefinitely and leave every
660: suspended tenant with a record that never closes.
661: **A create that has produced no machine yet passes the re-sweep's test**, so settlement here is not
662: the last guard: where such a create later attaches a machine to a still-suspended tenant, `OPS-27`'s
663: one-transaction rule enqueues the cancellation in the attach transaction itself, under the same
664: `OPS-39` trigger step (3) uses. **A process that dies mid-fan-out MUST NOT strand
665: the suspension**: the engine's startup pass (`OPS-15`) returns an interrupted `suspend_tenant`
666: parent to `queued`, and it is re-claimed and resumed like any other queued work, because the sweep
667: is idempotent by the open episode (`STO-52`'s index) and mutates no provider itself. It MUST NOT go
668: to `needs_reconciliation` and, on a restart, MUST NOT need an operator — *after a restore it waits for one while `STO-54`'s freeze holds the exception off (`STO-54`, `OPS-15`), because the fan-out it would resume may have been reversed inside the
669: lost interval*. Reads of the ledger, the machine list **and the tenant's abuse
670: cases** (`API-59`) MUST continue
671: to work while suspended — the customer's history is their evidence, and `LDG-22` forbids purging
672: it anyway. *The case reads joined this list on 2026-08-16 for the same reason and one more: the
673: collection exists because a notice commonly arrives after the machine is gone, and a suspended
674: tenant is the likeliest holder of exactly that case.* `SEC-45`'s one-action termination is this verb; `API-34`'s deletion applies only to
675: **pending** tenants, which have no machines. They MAY hold a below-minimum credit, whose ledger
676: entries survive them (`STO-26`, `LDG-22`) and remain re-attributable through `WIR-42` — so
677: "no ledger" was wrong, and it is the case `API-34` exists to handle.
678: 
679: **AMENDED 2026-09-02 — "un-cancelled" is defined, and a deterministically-failed child no longer
680: hangs the fan-out.** The re-sweep's terminating condition was never defined, and the two readings a
681: builder could reach were both wrong. **A machine is *cancelled* for the purpose of step (4) when this suspension has already accounted
682: for it** — the fan-out enqueued a cancellation for it, whatever that cancellation then did —
683: **and *un-cancelled* otherwise.** The parent records the machines it has enqueued for, in
684: `WIR-39`'s `cancellations` result; the pass enqueues for every non-tombstoned machine of the tenant
685: that is not already named there, and terminates when a pass finds none. **Where `OPS-39`'s episode
686: is already open on a machine under the `delete` key** — an exhaustion episode that predates the
687: suspension, or the machine `OPS-27`'s suspended-attach clause enqueued for — the pass MUST NOT
688: enqueue, and MUST instead **append `tenant_suspended` to that episode's `reasons` set (`DOM-31`)
689: and name its `current_operation_id` in `cancellations`**, which is what "accounted for" means for
690: it. *Added
691: 2026-09-05. Without this the pass could neither enqueue for such a machine — `OPS-39` forbids the
692: duplicate — nor name it, so every pass found it un-cancelled, the parent never settled, `WIR-41`'s
693: resume was refused forever and a worker slot was pinned for the life of the tenant.* **An operation
694: that `OPS-41`'s no-mutation abort settled does NOT account for its machine**, whatever list names
695: it: the abort closed the episode (`OPS-48`), so the next pass opens a fresh one and enqueues afresh
696: — **and replaces the aborted operation's id in `cancellations` with the fresh one's**, so the
697: per-machine result always names the child currently accounting for the machine rather than one
698: that settled without acting — which `STO-52`'s index permits precisely because the episode is
699: closed. *Added 2026-09-05 against the interleaving where the worker's re-check reads the episode
700: before the join appends `tenant_suspended`, finds the machine funded after a price cut, and aborts
701: — after which a pass that trusted the name would settle the parent over a funded fleet on a
702: suspended tenant.*
703: 
704: *The test is the parent's own record, not the episode row.* An earlier draft of this
705: amendment keyed it on an episode existing "open or already resolved", which fails in both
706: directions: `OPS-48` **closes** the episode on `abandoned` and clears the fence, so an operator's
707: `abandoned` made a machine read un-cancelled again and the fan-out re-enqueued against it; and an
708: episode opened by an *exhaustion* sweep before the suspension would have made a machine read
709: cancelled that this suspension never touched. The parent's list is the thing that actually answers
710: "has this fan-out dealt with that machine", and it is already returned to the operator.
711: 
712: *Why the entry and not the outcome.* Keyed on the outcome, a child that fails deterministically —
713: `authentication` after a credential rotation, `unsupported` on an account that never declared
714: `delete_machine` — leaves its machine un-cancelled forever, while `OPS-39` forbids the next pass
715: enqueuing a second delete under the same open episode. The fan-out then cannot terminate and cannot
716: progress: the parent never settles, `WIR-41`'s resume is fenced indefinitely, and a worker slot is
717: pinned. Keyed on the entry, the pass terminates because the machine has been **accounted for**,
718: which is what the parent's job actually is.
719: 
720: **What that costs, stated rather than hidden: the parent settles `succeeded` while a machine of a
721: suspended tenant may still be running.** Three things bound it and all three are required. The
722: child's failure is a record of its own, named in the parent's result (`WIR-39`'s `cancellations`)
723: and readable through `GET /v1/operations`. A `failed` attempt moves its episode to `stalled`
724: (`OPS-48`), which `OPS-26`'s listing **surfaces to the operator** beside `uncertain`, and the
725: recovery is `API-64`'s retry on the same episode — which `API-7` skips step 5b for, so a suspended
726: tenant's stalled episode stays retryable. *Until 2026-09-05 this sentence continued "and the
727: machine keeps consuming its commitment, so `LDG-13`'s exhaustion path reaches it on the ordinary
728: schedule whether or not anyone looks" — which `OPS-48` forbids: the episode stays open, the sweep
729: enqueues nothing against an open episode, and the operator listing and retry are the only
730: recovery. `CNF-272` carried the same false clause and was corrected the day before; this copy was
731: not.* **A
732: suspension is not a promise that the fleet is gone; it is a promise that every machine has been
733: accounted for and that nothing further can be bought.** The terms and the operator documentation
734: MUST say so in those words, because "suspended" reads as "stopped" and on this one branch it is not.
735: 
736: **AMENDED 2026-08-31 — the flag lands at admission, not in the worker.** The withdrawn wording
737: said "the suspension flag and the full fan-out MUST commit together", which on a `202`-returning
738: endpoint (`WIR-39`) puts the flag in a *worker's* transaction. `API-7` step 5b reads
739: `tenants.status`, so until a worker claimed the parent the tenant was not suspended and its writes
740: were admitted — and `OPS-6` claims oldest-first, so its own queued work runs ahead of the suspension
741: that was meant to stop it. `SEC-45` calls this "one operator action" and sells it as immediate; on a
742: busy queue it was not effective on return.
743: 
744: The crash-safety the withdrawn clause was protecting is supplied elsewhere and better: the startup
745: pass (`OPS-15`) returns an interrupted `suspend_tenant` parent to `queued` rather than to
746: `needs_reconciliation`, and the open episode (`STO-52`) makes the re-sweep idempotent, so a crash
747: mid-fan-out strands nothing. **The flag and the enqueue of the parent commit together at admission;
748: the fan-out is the worker's.**
749: 
750: **Because the fan-out re-sweeps, resume MUST NOT be accepted while this parent is unsettled**
751: (`WIR-41`): a machine created after an early resume is exactly what the re-sweep is built to find,
752: and it would be cancelled by a suspension the operator already lifted. The parent's state is the
753: fence, and the refusal is a `conflict` naming the running suspension.
754: 
755: *Amended 2026-10-23 (`pv-n98`; panel r63, r63c’s Form F′, `docs/research/panels-2026-10/r63/`; owner decision Q2 “Clean up every startup (Recommended)”): bounded the post-restore parent wait by the exception’s freeze.*
756: 
````

## API-64 — 04-api-contract.md:1050

````text
1050: **API-64** **ADDED 2026-09-08 (`ADR-0017`) — a stalled episode is retried by an operator, and by
1051: nothing else.** `POST /v1/episodes/{id}/actions/retry` (`WIR-51`) is **operator-only** (`WIR-34`)
1052: and is admissible only on an episode in `stalled` (`DOM-31`): it moves the episode to `attempting`
1053: **by a conditional write guarded on `(id, state = stalled)`** and enqueues a fresh `delete_machine`
1054: attempt under it, both in one transaction, and answers `200`
1055: with the episode view. In any other state — including where that write affects no row because a
1056: gone-write closed the episode after the operator read it (`OPS-48`, `ADR-0021`) — it is refused
1057: `409` `conflict` with `details.reason: "state"`. It is idempotent under `WIR-24`'s one-transaction rule — the state change, the enqueue and
1058: the idempotency record commit together — and it counts against `SEC-39`'s operator retry ceiling
1059: (`API-7` step 5c). **A `stalled` episode is never retried by a timer** (`OPS-48`): the attempt
1060: settled `failed` because the provider rejected it and did not act, and repeating a deterministic
1061: rejection automatically is the loop `OPS-39` exists to prevent. *Amended 2026-10-08 (`ADR-0035`):* throttle classification follows `OPS-11`'s
1062: "the operation's mutating request was accepted by the provider" condition, and episode effects
1063: follow `OPS-48`: a pre-acceptance refusal can stall; post-acceptance ambiguity is `uncertain`,
1064: where this retry verb is inadmissible. `F48` retains the rejected automatic-deferral history. The
1065: episode, not the `failed` attempt row, is what
1066: outlives `STO-14`'s retention, which is why the verb is on the episode (`ADR-0017`).
1067: 
1068: *Amended 2026-10-04 (`pv-gip.11`, `ADR-0032`): The new attempt is stamped
1069: `requested_by: operator`, with its non-null `episode_id`, in the enqueue transaction;
1070: these fields identify its origin across claims and restarts.
1071: Keeping the machine is the distinct `API-68` verb.*
1072: 
1073: *Amended 2026-10-05 (`pv-gip.43`, Q14, `ADR-0032`): `OPS-41` step 2 owns the retry
1074: guard.*
1075: 
````

## API-65 — 04-api-contract.md:1102

````text
1102: **API-65** **ADDED 2026-09-08 — the operator's half of `PRV-45`, which had no route.**
1103: `GET /v1/machines/{id}/attachments` (`WIR-52`) is **operator-only** (`WIR-34`) and lists the
1104: machine's `machine_attachments` rows. `POST /v1/machines/{id}/attachments/{attachment_id}/actions/release`
1105: (`WIR-52`) is **operator-only** and admissible only on a row whose `released_at` is null; otherwise
1106: it is refused `409` `conflict` with `details.reason: "state"`. On a row whose `cleanup` is `api` it
1107: enqueues one `release_attachment` operation with `requested_by: operator` and answers `202` with
1108: the operation view — the same kind, and the same driver call, the delete's terminal transaction
1109: enqueues on its own. On a row whose `cleanup` is `manual` there is no driver call to make: it
1110: writes `released_at` and answers `200` with the row, minting no operation, and is in `API-48`'s
1111: list for that reason. A release the delete's terminal transaction enqueues carries the delete's own
1112: `requested_by` and `system_reason`, so `WIR-10a`'s set gains no member for it. The `202` form is
1113: idempotent as any operation is (`API-11`); the `200` form, returning no operation, commits the
1114: `released_at` write and its idempotency record together under `WIR-24`'s one-transaction rule.
1115: For the release's exit write, see `LDG-38`.
1116: `PRV-45`'s `released_at` write is what opens `STO-18`'s tombstone gate; a stored effective date
1117: alone leaves it closed. `LDG-74` owns the later tombstone. *Amended 2026-10-09 (`ADR-0037`, Q14).*
1118: 
````

## API-68 — 04-api-contract.md:1076

````text
1076: **API-68** **ADDED 2026-10-04 (`pv-gip.11`, `ADR-0032`) — keep a stalled machine.**
1077: `POST /v1/episodes/{id}/actions/keep` (`WIR-55`) MUST be operator-only and synchronous,
1078: returning `200` with `WIR-51`'s episode view and minting no operation. It is admissible only in
1079: `stalled`: under `LDG-35`'s per-tenant serialization, conditional-write on `(id, state = stalled)`
1080: to close `kept`, clear `machines.destroy_committed`, record the authenticated operator principal
1081: and the supplied evidence in `STO-52`, and write the `LDG-33` re-derived `runway_until` using the
1082: transaction's rate and clock, with no-rate handling governed by `LDG-65`. These effects
1083: and the `STO-35` idempotency receipt MUST commit in one transaction under `WIR-24`. A lost
1084: conditional write or any other episode state is `409` `conflict`, `details.reason: "state"`;
1085: `API-7` step 5a applies first: "an equal fingerprint under the
1086:     same `(principal, key)` returns the stored result". A keep racing a
1087: retry or gone-write cannot overwrite its winner's state or clear its fence.
1088: 
1089: Keep MUST NOT change the commitment or balance, mutate the provider, or settle/rewrite the
1090: old attempt. It adds no funding, suspension or retry-ceiling gate to `API-7`'s operator path.
1091: **A still-unfunded machine is routed again at the next exhaustion sweep under the existing
1092: predicate**, opening a fresh episode under `OPS-39`; keep grants no grace or exclusion from
1093: that population. The close and evidence survive with the episode under `STO-52`.
1094: 
1095: *Model verification note added 2026-10-04 (`pv-gip.11`):
1096: `Provisiond.Fence.keep_only_from_stalled` and `Provisiond.Fence.keep_stalled_row` check
1097: the transaction against its eligibility condition and table row.
1098: `Provisiond.Witnesses.keep_eligibility_guarded` and
1099: `Provisiond.Witnesses.keep_eligibility_unguarded` isolate the conditional-write control
1100: in a retry-wins race. These are model proofs, not running-service conformance (`ADR-0025`).*
1101: 
````

## STO-21 — 05-persistence.md:675

````text
675: **STO-21** **AMENDED 2026-08-12 — the original forbade what the rest of the specification
676: requires.** It said "nothing beyond these columns may be stored about a tenant", while
677: `API-17b`/`SEC-43` require a provider-account assignment, `API-33` requires an enrolment handle,
678: `SEC-39` requires ceiling counters, and `LDG-25` requires operation meters. Read strictly,
679: enrolment was unbuildable; read loosely, it constrained nothing and `CNF-80` — the only privacy
680: conformance item in the set — was satisfiable by moving the column to another table.
681: 
682: The rule that carries the intent is a **prohibition on categories, not on columns**: no
683: information that could identify, locate or contact a natural or legal person, and no information
684: derived from the network path a request arrived on. Operational state a tenant needs in order to
685: function — account assignment, meters, cached balance — is permitted and MUST live in
686: named tables. `CNF-80` tests the prohibition, not the column count.
687: 
688: **`SEC-39`'s ceiling counters live in the store** (amended 2026-09-08, `ADR-0016`). From
689: 2026-09-02 they were the one in-memory exception, on the argument that `ADR-0001`'s single process
690: made a per-process counter sufficient and a row per destructive request too dear. `ADR-0016` makes
691: `api` replicable, and a per-process counter then multiplies every principal's ceiling by the
692: replica count — a ceiling that is an abuse bound (`SEC-39`) cannot depend on how many replicas
693: happen to be running. The counter is therefore one row per `(principal, ceiling, interval)`,
694: incremented by a conditional write in the transaction of the write it gates, and refused
695: `ceiling_exceeded` where the increment would pass the stated integer. A destructive request is
696: rare and the row is small; the cost objection was an objection to the single-writer store this set
697: no longer has. `API-36`'s enrolment limiter stays in memory and per replica: it is best-effort
698: shedding, and `API-41`'s global pending-tenant ceiling is the control that counts.
699: 
700: `ADR-0005` remains a schema constraint. The place a privacy policy actually fails is still a
701: column somebody added because it seemed harmless — but a rule that forbids the whole system from
702: working gets deleted by the first engineer who needs it, and then nothing is enforced at all.
703: 
704: ### `ledger_entries`
705: 
706: *Amended 2026-10-04 (`pv-gip.39`): remove `settlement_ref`; `STO-57` owns billing references.*
707: 
708: **AMENDED 2026-08-15 — this section said only "Contents are specified by `LDG-5`–`LDG-8`", and
709: those requirements name four fields no column list ever provided.** It is the `commitments` gap
710: (below) and the `STO-34`–`STO-36` gap recurring a fourth time, on the one table `ADR-0002` makes
711: the authorization system.
712: 
713: | Column | Type | Notes |
714: |---|---|---|
715: | `id` | UUID | primary key |
716: | `tenant_id` | text | not null; **no foreign key** (`STO-26`) |
717: | `seq` | integer | not null; the per-tenant monotonic sequence of `LDG-6` |
718: | `kind` | enum | `topup` \| `usage_debit` \| `setup_fee_debit` \| `operation_fee_debit` \| `first_unit_debit` (*added 2026-10-08, `ADR-0033`*) \| `correction` — closed by `LDG-7` |
719: | `amount_sats` | integer | **signed** (`LDG-1`); a debit is negative. *Until 2026-09-02 this read "which is what makes `LDG-38`'s netting come out right" — `LDG-38` no longer nets over entries at all, and the sign rule stands on `LDG-1` alone* |
720: | `balance_after` | integer | the running balance after this entry (`LDG-6`); authoritative for reads per `LDG-70` |
721: | `subject_kind`, `subject_id` | enum, UUID | nullable; `machine` \| `attachment` — **`LDG-8`'s *subject*.** Required on every `usage_debit`, because a machine and each of its billable attachments (`PRV-13a`, `machine_attachments`) are separately metered subjects and `LDG-38` carries a rounding credit and a high-water mark **per subject** (`STO-45`). Carrying only `machine_id` merges them into one meter, and the merge under-bills by whichever subject is not the one being posted |
722: | `billing_period` | text | nullable; the period this entry falls in (`LDG-68`), required on every `usage_debit`. Part of `LDG-8`'s key and the boundary `LDG-38` apportions absorbed windows across. On a `correction` it is the period of the entry corrected, never the period of posting (`LDG-38`) |
723: | `corrects_entry_id` | UUID | nullable; the entry this one corrects (`LDG-5`). Set on `correction` and on nothing else. it is what files a correction under the period of the entry it names (`LDG-38`), and `WIR-42`'s re-attribution is reached through it — without the column neither is implementable |
724: | `idempotency_key` | text | not null; unique within the tenant (`LDG-8`). Derived from the thing being billed or from the payment (`STO-31`), never from a count of what has been posted |
725: | `operation_id`, `machine_id`, `commitment_id` | UUID | nullable; `LDG-6`'s causation ids |
726: | `deposit_id` | UUID | nullable; **required on every `topup`** and on the `correction` pair `WIR-42` posts. `LDG-43` requires an unattributed credit to carry the deposit it arrived at, because the deposit id is the only handle a returning customer still holds (`WIR-14`'s disclosure) and `ADR-0005` retains nothing about the payer — so without this column `WIR-42` can find the credits it must move by no route at all. It is the operator's own binding (`LDG-49`, `STO-29`), not information about a counterparty, so it costs `LDG-21` nothing. *Added 2026-09-02; it was a MUST in `12-billing-and-ledger.md` with no column anywhere, which is `STO-38`'s failure class for the fourth time* |
727: | `native_minor`, `native_currency` | integer, text | nullable; `LDG-2`'s provider-denominated amount, required on every provider-denominated entry |
728: | `rate_num`, `rate_den`, `rate_source`, `rate_observed_at`, `haircut_bps`, `rounding_rule_version` | integer, integer, text, timestamp, integer, text | nullable; `LDG-4`'s conversion evidence, **denormalised onto the entry** so it survives any pruning of a rate table |
729: | `created_at` | timestamp | |
730: 
731: Constraints: unique `(tenant_id, idempotency_key)`; unique `(tenant_id, seq)`; index on
732: `(tenant_id, seq desc)` for the balance read (`LDG-70`); index on
733: `(subject_kind, subject_id, billing_period, kind)` for `LDG-8`'s idempotency key and `LDG-38`'s period placement; index on
734: `(corrects_entry_id)`, which that same query traverses; index on `(deposit_id)`, which is how
735: `WIR-42` reaches the credits a deposit produced.
736: 
````

## STO-50 — 05-persistence.md:559

````text
559: **STO-50** **ADDED 2026-09-06 (`F38`) — `request_summary` is a closed enumeration, and anything not
560: on the list MUST NOT be written to it.** Its opening description is "what was attempted", which
561: names no field, and an open-ended summary standing beside a purged `request` is a hole in the purge
562: rather than a note about it: **`ADR-0005` is enforced by what survives, not by what is removed**, so
563: a bucket that admits anything admits exactly the material `STO-9` above lists as the reason the
564: purge exists. The contents are:
565: 
566: - **Always** — the operation's kind, its machine where it has one, the resolved provider account
567:   (`OPS-35`), and what `OPS-13` requires: what was attempted, and any provider-side identifiers
568:   that were created.
569: - **For a create** — the correlator, the offer snapshot and the at-cost setup fee enumerated on the
570:   `request_summary` row above, and since 2026-10-08 the prepaid first unit beside the fee
571:   (`ADR-0033`). The offer snapshot also includes the declared cancellation bound, as specified
572:   on the `request_summary` row. *Amended 2026-10-16 (`ADR-0037`, `pv-tsb`).*
573: - **For the kinds `OPS-45` governs** (*it names six; this said "five" until 2026-09-16*) — the two markers, `write_started_at` and `rescue_exited_cleanly`,
574:   copied from their columns as that row already requires.
575: 
576: **Nothing else.** In particular the summary MUST NOT carry a caller-chosen hostname, SSH public
577: keys, user data, a post-install script, a signed image URL, a disk layout, or a spending cap —
578: whether or not a given field looks harmless alone. *`PRV-26` already forbids a correlator encoding
579: "a hostname the customer chose", and there is no reason the record beside it should be laxer than
580: the value written into the provider.*
581: 
582: *This is what `F38` was really about: "every respect the summary records" pointed at a list nobody
583: had written, which is how a requirement came to state a test it could not run (`F39`). A closed
584: enumeration makes the phrase finite.*
585: 
````

## STO-60 — 05-persistence.md:652

````text
652: **STO-60** `read_at` is the dispatch instant of the successful driver List offers call. Every successful driver List offers read MUST publish its complete result to the account's row, replacing an existing row only when the incoming `read_at` is later. A failed read MUST leave the row unchanged. The read's caller publishes the result, outside the driver read: `PRV-50` says “The driver's List offers MUST be read-only under `PRV-12`'s guarantee: "Get machine MUST be read-only and free of side effects".” See `OPS-51`.
653: 
654: | Column | Type | Notes |
655: |---|---|---|
656: | `provider_account` | text | primary key |
657: | `read_at` | timestamp | see `STO-60` |
658: | `offers` | json | the driver's List offers result (`DOM-9`: "Prices MUST be carried as strings exactly as the provider returned them.") |
659: 
660: ### `tenants`
661: 
662: Required by `ADR-0002`: a self-serve tenant appears at runtime, so it must be a row rather than
663: an environment variable (`API-4` as amended).
664: 
665: | Column | Type | Notes |
666: |---|---|---|
667: | `id` | text | primary key; opaque, no personal data (`ADR-0005`) |
668: | `credential_digest` | text | not null; the **spending token** hash, never the credential itself (`API-3`). Replaced in place by `WIR-38` |
669: | `recovery_digest` | text | not null; the **recovery credential** hash (`API-55`). Minted with the row and never replaced by a spending-token revocation |
670: | `credential_generation` | integer | increments on every revocation (`API-56`); a token from an earlier generation never authenticates, so a replayed revocation cannot resurrect one |
671: | `status` | enum | `pending` \| `active` \| `suspended` (`API-58`; a suspended tenant authorizes no *tenant* write, retains ledger, machine and abuse-case reads, and retains the maintenance actions of `API-7` step 2 as narrowed by step 5b — including the abuse-statement write) |
672: | `pending_expires_at` | timestamp | nullable; unfunded enrolments are deleted at this time (`API-34`) |
673: | `created_at`, `activated_at` | timestamp | `activated_at` null until first funding (`API-35`) |
674: 
````

## RSC-41 — 06-rescue-install.md:503

````text
503: **RSC-41** **The import happens with the operation yielded, and is bounded.** The import touches
504: no machine; only the switch-over does. So the operation MUST import and poll the provider to a
505: usable state while **yielded** (`OPS-8`'s `yielded_at`), and hold the machine only for the rebuild
506: and the cleanup — the one exception `OPS-8` admits, and it is admitted *there* (amended
507: 2026-09-02) rather than asserted here. *Naming itself a narrowing did not make it one: `OPS-8`
508: said "for its duration" without qualification, so the two requirements were a straight
509: contradiction and the winner was whichever a builder read second.* On re-acquiring the machine
510: the operation MUST re-validate before the rebuild (`OPS-23`): an exposure-reducing cancellation
511: holding the machine during the import is the behaviour this narrowing exists to permit, so the
512: machine may be gone by the time the import finishes.
513: 
514: **A maximum import wait MUST be stated**, past which the operation aborts and the imported image is
515: deleted.
516: 
517: Three things go wrong without this, and the third is the expensive one. The caller's existing
518: machine is held and idle while still billing. An exposure-reducing cancellation queues behind it
519: (`OPS-8` defers with a short delay rather than waits, so it simply does not run). And `PRV-13b`
520: puts the deployment's worst-case operation hold inside `wind_down_cost`, which sizes the reserve
521: on **every machine in the fleet** — so an unbounded provider queue on one driver would raise the
522: commitment every customer must post before buying anything.
523: 
````

## SEC-15 — 07-security-requirements.md:84

````text
84: **SEC-15** Every operation MUST be capability-gated before the driver is called,
85: including create (`DOM-10`). A driver-internal check is defense in depth, not the gate.
86: 
````

## DEF-10 — 09-known-defects.md:70

````text
70: ### DEF-10 — Capability enforcement had a hole at create
71: 
72: Every operation called a capability gate except create, which was gated only by each
73: driver's internal ordering flag. The capability model clients were told to rely on was
74: therefore not enforced for the one operation that spends money.
75: 
76: **Prohibition** — gate every operation, including create (`DOM-10`, `SEC-15`).
77: 
78: *Reference: `crates/server/src/worker.rs:249`.*
79: 
````

## CNF-19 — 10-conformance-checklist.md:137

````text
137: - [ ] **CNF-19** — Create is refused when the provider has not declared the matching
138:       provision capability — with the driver's internal ordering flag set to permissive,
139:       so the test proves the outer gate exists. (`DOM-10`, `DEF-10`)
````

## CNF-55 — 10-conformance-checklist.md:340

````text
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
360: 
````

## CNF-201 — 10-conformance-checklist.md:2246

````text
2246: - [ ] **CNF-201** — A rescue-inventory run carries a trust policy and is capability-gated on
2247:       `rescue_ssh`; a failure whose rescue exit **also** failed classifies like an install, not like
2248:       a refresh — the machine can be left in rescue — while one whose exit succeeded is `failed`,
2249:       since the pass writes nothing to a disk and `OPS-45`'s first marker is never set for it. Both
2250:       halves; classifying every inventory failure as ambiguous fills an operator's queue with runs
2251:       that ended cleanly. (`WIR-40`, `DOM-10`, `OPS-11`, `OPS-45`)
````

## CNF-302 — 10-conformance-checklist.md:3049

````text
3049: - [ ] **CNF-302** — **`rescue_exit: "none"` is a fact, and the column is written before the session,
3050:       not after the exit** (added 2026-09-16). Drive an install refused before begin rescue —
3051:       `OPS-40`'s claim-time URL gate, or a `rescue_ssh` capability refusal (`DOM-10`) — and assert
3052:       `failed`, `rescue_exit: "none"`, no `rescue_address`, and `rescue_exited_cleanly` **null** in
3053:       the row and in `request_summary`. Then kill the engine after the pre-dispatch write commits
3054:       and before the begin-rescue dispatch (*step added 2026-09-20, `pv-v1f`*): no begin-rescue call
3055:       reaches the provider, `OPS-15` moves the operation to `needs_reconciliation`, the column is
3056:       **false** over a machine that was never rebooted into rescue, the error carries
3057:       `rescue_exit: "unknown"` with the `rescue_address` and `rescue_port` that `OPS-15`'s pass
3058:       renders from the machine row (`RSC-19`), and no key file exists. Then kill the engine between
3059:       the begin-rescue dispatch and the end-rescue call: `OPS-15` moves the operation to
3060:       `needs_reconciliation`, the error carries `rescue_exit: "unknown"` with `rescue_address` and
3061:       `rescue_port`, the column is **false**, and no key file exists (`RSC-19`: a crash persists
3062:       nothing, and `unknown` never implies a file). Then `CNF-301`'s clean exit: **true**. Then
3063:       repeat the pre-dispatch write after a simulated lost reply and assert it affects one row and
3064:       changes nothing (`ADR-0022`, `STO-3`). Then restore from a backup taken before the dispatch,
3065:       inserting an incident with null `lost_window_starts_at` and `loss_end_at` and a non-null
3066:       incident-keyed `history_evidence_ref` retaining the unknown-endpoint reasons (`STO-54`,
3067:       `STO-56`), and assert the quarantined row renders both keys `unknown` whatever the restored
3068:       columns hold (`WIR-9a`). Three distinct column values, or the item passes an implementation that writes the
3069:       marker only at the exit — which renders a crashed session as `none`, the one lie the column
3070:       exists to prevent. The pre-dispatch kill is the step that separates the required write from
3071:       one made at the dispatch instead: `OPS-45` states "false, written before begin rescue … is
3072:       dispatched", and an implementation that waits for the dispatch renders that row `none`.
3073:       (`OPS-45`, `OPS-15`, `RSC-19`, `WIR-9a`, `STO-50`, `STO-54`)
3074: 
3075:       Keep a restore incident open through the following paired cases. Restore a backup with an
3076:       unsettled install whose markers are `null` although its destructive phase and rescue dispatch
3077:       occurred in the lost interval. Complete step (3), then assert the old row renders both keys
3078:       `unknown`. Admit separate fresh raw-disk installs after step (3), and crash the engine while
3079:       each remains `running`: (a) before either marker write, (b) after the write-started marker and
3080:       pre-rescue `false` marker have committed, (c) after the write-started marker and clean
3081:       rescue-exit `true` marker have committed but before settlement. Run the successor's startup
3082:       pass and assert each row is `needs_reconciliation`, with no replay or automatic deterministic
3083:       settlement. Assert `none`/`none` for (a), `destructive_boundary_crossed`/`unknown` for (b),
3084:       `destructive_boundary_crossed`/`clean` for (c). Repeat successor startup, close the incident
3085:       under its ordinary close conditions, and purge payloads; assert the retained wire values do
3086:       not change merely because of those events. In another actual restore from a backup containing
3087:       a still-unsettled formerly fresh row, assert both keys now render `unknown`. For rescue
3088:       inventory repeat the old-row and later-restore cases with `rescue_exit` `unknown`; for
3089:       separate fresh rescue-inventory rows with rescue marker `null`, `false` and `true` assert
3090:       `none`, `unknown`, `clean`. Do not write an install write-started marker or introduce
3091:       `disk_effect` on that kind. Check provenance and rendering across a lost transition reply and
3092:       a repeat.
3093: 
3094:       Separately construct `CNF-300`'s unresolved failed-rescue-exit row with `disk_effect` `none` and
3095:       `rescue_exit` `unknown` without a prior restore, then back it up and actually restore it
3096:       (`CNF-300`: "`disk_effect: "none"` (it aborted before writing) and `rescue_exit:
3097:       "unknown"`"). It
3098:       remains `needs_reconciliation`, acquires `true` provenance before startup, and now renders
3099:       `unknown`/`unknown`. This is a declared conservative change on a row already awaiting
3100:       resolution. For settled rows with established `false` provenance, an actual restore does not
3101:       alone change their flag. During upgrade a `null` flag renders conservatively; backfill changes
3102:       only nulls, never a freshly admitted `false` row or an already-true row. Assert that a settled
3103:       pre-column install can therefore lose its former ordinary wire facts under the declared
3104:       upgrade policy, and that other operation kinds gain no marker wire keys.
3105: 
3106:       Repeat the actual restore using a backup containing an open predecessor whose ordinary close
3107:       conditions are unmet. Assert the predecessor is retained and closed by supersession, the
3108:       distinct new record names it and starts unmarked with a `null` grace end, provenance is
3109:       `true`, and the complete new procedure and its close conditions apply. Neither component
3110:       starts before that transaction is acknowledged. Include predecessor cases with unexpired
3111:       wall-clock grace, unfinished rate-present grace, an unconfirmed parent and an unfinished
3112:       account-sweep second pass; test the selected supersession rule's stated consequences. A mere
3113:       process crash must create no new incident or supersession. A lost transaction reply must not
3114:       produce two open incidents or silently continue using predecessor step marks.
3115: 
3116:       For one actual restore, lose the establishment transaction's connection before it commits,
3117:       so that no record with the retained id exists, and repeat establishment with that id in a
3118:       later transaction whose start time differs: assert exactly one record with that id, its
3119:       `restore_instant` the value `STO-54` defines, its predecessor closed by supersession and
3120:       provenance initialized in the repeating transaction, and neither component started before
3121:       that transaction is acknowledged. Separately let establishment commit, drop its reply and
3122:       repeat with the same id: assert the repeat is acknowledged as a guarded no-op preserving the
3123:       stored instant, predecessor and step marks, that it is not refused merely because the
3124:       repeating transaction starts later, and that the components then start and continue that
3125:       incident. Neither arm leaves two open incidents. This case selects no predecessor-comparison
3126:       algorithm.
3127: 
3128:       | Install case after successor pass | `disk_effect` / `rescue_exit` |
3129:       |---|---|
3130:       | Old unsettled row exposed to rollback, restored null/null | `unknown` / `unknown` |
3131:       | Fresh (a), null/null, no later actual restore | `none` / `none` |
3132:       | Fresh (b), write marker set, rescue false | `destructive_boundary_crossed` / `unknown` |
3133:       | Fresh (c), write marker set, rescue true | `destructive_boundary_crossed` / `clean` |
3134:       | Formerly fresh unsettled row exposed to another actual restore | `unknown` / `unknown` |
3135:       | Existing unresolved CNF-300-derived row, after actual restore | `unknown` / `unknown` |
3136: 
````

## CNF-312 — 10-conformance-checklist.md:2558

````text
2558: - [ ] **CNF-312** — **Interrupted cancellation before its fence (2026-10-05, `pv-gip.43`, Q14).**
2559:       Exercise `OPS-41` step 2 and `OPS-42` ordering on independent instances with an
2560:       available rate, a healthy provider account and no other admission refusal. Each starts
2561:       unfunded with an active tenant; the suspended row below changes that tenant's state.
2562:       For Orders A and B, provide sufficient available balance and choose an extension that
2563:       funds the machine at the deciding rate. The other rows use a favorable rate and
2564:       re-derivation to fund it, without an extension.
2565:       **Route 1 prefix:** let the sweep enqueue the cancellation and the worker claim it, then
2566:       kill the worker before its fence transaction. Restart: `OPS-15` requires "move every
2567:       `running` operation to `needs_reconciliation`" and "MUST NOT move them back to `queued`".
2568:       Assert that operation state and episode `uncertain`. Resolve `not_applied` as operator:
2569:       assert the attempt `failed`, episode `stalled`, null `destroy_committed`, null
2570:       `write_started_at`, and zero provider calls throughout the prefix. Drive the actual
2571:       lifecycle; manually seeded stalled rows and startup requeue do not satisfy this case.
2572: 
2573:       **Survived-stop prefix:** on a fresh independent instance with the same funding, account
2574:       and tenant conditions, enqueue and claim the cancellation, then deliver a stop while
2575:       `execute` is cancellable and before the first fence transaction is sent. Keep the engine
2576:       alive and the store working until its stop record is acknowledged within the stated
2577:       bounds, with no later stop or superseding generation. Assert the original attempt
2578:       settles `failed` with cut-off `conflict` and `details.reason: "cut_off"`, the episode is
2579:       `stalled`, `destroy_committed` and `write_started_at` remain null, and no provider call
2580:       occurred. No crash, startup classification, operator resolution or manually seeded
2581:       stalled row substitutes for this prefix. For stop classification and recording, see
2582:       `OPS-21` and `OPS-11`.
2583: 
2584:       Drive Orders A and B and the suspended/null-fence row on separate fresh instances of
2585:       each prefix: route 1 and the survived-stop prefix. The fenced rows retain their own
2586:       prefixes below. Do not inject a store error as a separate failed route: `OPS-49` requires
2587:       "repeat the **whole transaction**" and on bound exhaustion "the engine MUST exit non-zero".
2588:       Keep the record store available within both stated bounds; this is a recording-success
2589:       fixture, not abandonment or a lost-reply/later-stop case.
2590:       Instrument the deciding fence transaction's read/commit boundary:
2591:       retry enqueue alone establishes neither transaction order.
2592: 
2593:       **Fenced, undispatched prefix:** drive a real cancellation through its unfunded fence
2594:       transaction and wait for commit, then kill the worker **before the dispatch-marker
2595:       write and provider call**. `OPS-42` says the worker "releases it before the provider
2596:       call".
2597: 
2598:       `OPS-45`'s delete marker row says "the provider call is dispatched". Assert the
2599:       marker is still null at the injection boundary; a kill merely before the call does
2600:       not establish that. Restart through the same startup classification, then resolve
2601:       `not_applied` as operator. `OPS-45` says "an operation interrupted rather than classified
2602:       is `OPS-15`'s, whatever the markers hold"; `OPS-48`'s resolved-not-applied row is
2603:       `stalled` with the fence "**Unchanged**". Assert the original attempt `failed`, episode
2604:       `stalled`, fence still holding that episode's id, original attempt's `write_started_at`
2605:       null, and zero provider calls throughout this prefix.
2606: 
2607:       **Suspension fan-out:** on separate fresh instances of each prefix, route 1 and the survived-stop prefix, suspend the tenant. `API-58` says the
2608:       pass "MUST NOT enqueue" for an already-open delete episode, and must "append
2609:       `tenant_suspended` to that episode's `reasons` set" and "name its `current_operation_id`
2610:       in `cancellations`". Assert the same episode and its current failed attempt account for
2611:       the machine, the reason is appended, the parent terminates, and the fan-out enqueues
2612:       no new cancellation attempt.
2613: 
2614:       | Case | Required observations |
2615:       |---|---|
2616:       | Order A: extend, then retry | Extension admits and commits before the retry's fence transaction. The attempt settles `succeeded` with a no-mutation result; episode `closed`/`funded`; fence null; provider call count remains zero. The extension's commitment is kept: reconcile any legitimate metering independently and assert no cancellation-driven commitment release. |
2617:       | Order B: retry's fence transaction commits unfunded, then extend | Observe the fence holding the episode id before submitting the extension; it returns `409` / `cancellation_committed`, with no balance movement or commitment growth attributable to that refused extension. The provider is called. |
2618:       | Fenced control | Use `CNF-271`'s provider-failed stall after fencing, accept a favorable rate and re-derive future runway without clearing that fence. Retry still calls the provider again and does not close `funded` through a funding abort. |
2619:       | Fenced, undispatched control | Use the fenced, undispatched prefix above. Accept a favorable rate and re-derive funded runway without clearing the fence. Retry the same episode: observe a provider call and no funding-abort close to `funded`. The original attempt's `write_started_at` remains null; distinguish it from the fresh retry attempt's own initially unset marker. |
2620:       | Suspended, null fence | For each prefix, use its suspension fan-out above. Accept a favorable rate and re-derive funded runway while suspension remains current; do not extend. Retry as operator and observe that the deciding transaction reads a null fence and a currently suspended tenant. Observe a provider call and no funding-abort close to `funded`. |
2621: 
2622:       These assertions discriminate unconditional retry bypass (Order A), a funding re-check
2623:       on every retry (fenced control), and a missing extension fence (Order B).
2624:       The **fenced, undispatched control** fails a build that keys retry bypass on the
2625:       **previous attempt's `write_started_at`** instead of the episode fence: it re-checks
2626:       funding and closes `funded`, violating both the provider-call and no-funding-abort
2627:       assertions. That build passes Order A and the dispatched/provider-failed controls.
2628:       The **suspended, null-fence row** fails a build that branches to the null-fence funding
2629:       path **before considering current suspension**: it closes the funded machine's episode
2630:       and omits the provider call, violating the same assertions. `OPS-41` step 2 instead
2631:       says "A retry reading the fence null decides from step 3 unless the tenant is suspended
2632:       now." Preserve `CNF-271`'s timer and keep controls and `CNF-272`'s fenced/resume controls.
2633:       These new rows specify implementation observations, not additional model results:
2634:       the existing Fence model's interrupt handles only the pre-fence holding phase and
2635:       carries no persisted dispatch-marker history.
2636:       **Restore scope, inspected rather than rehearsed here:** `OPS-41` says "A claim made while
2637:       a restore record is open and its `grace_ends_at` is null or in the future defers, and writes
2638:       no fence" and "The rule applies whichever path enqueued the cancellation — a delete
2639:       re-run by step (2), an operator's retry". That claim gate precedes this item's decision;
2640:       after it, step 2's null-fence path uses the same ordered funding decision as a re-run
2641:       delete, including step 3's "Only if the predicate would cancel" paused-grace check.
2642:       `STO-54` directs goal-state kinds to "re-run, since `OPS-11` classifies ‘already in the
2643:       target state’ as `succeeded`". Text inspection finds no retry/first-attempt exception when
2644:       the provider already deleted but restore rolled the fence back: both retain the claim
2645:       gate and ordered decision; a dispatched delete uses that existing goal-state result.
2646:       A funded abort can precede dispatch on either path while the restored row still says
2647:       present. This item does not drive route 2 or establish restore conformance; that remains
2648:       with `CNF-218` and `CNF-295`. (`OPS-15`, `OPS-31`, `OPS-41`, `OPS-42`, `OPS-48`, `API-64`,
2649:       `LDG-62`, `STO-54`)
````

## CNF-334 — 10-conformance-checklist.md:4233

````text
4233: - [ ] **CNF-334** — **Reverse-DNS is ceilinged before local settlement.** Drive the authenticated
4234:       request pipeline at and below the per-principal reverse-DNS ceiling. Assert `ceiling_exceeded`
4235:       at the limit, including an identical recorded value; a replay spends no second slot. Below
4236:       the limit assert `202` followed by `succeeded` and `{}` with zero provider calls for an
4237:       identical established PTR. Reject a foreign machine, an address outside its recorded list,
4238:       an empty/overlong hostname and CR/LF even when its text matches a stored entry. Retain the
4239:       capability check. (`SEC-39`, `API-7`, `API-16`, `API-17`, `PRV-2`, `PRV-25`, `WIR-10`)
````

## CNF-364 — 10-conformance-checklist.md:140

````text
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
155: 
````

## WIR-17 — 13-wire-contract.md:641

````text
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
679: synchronous operator route in `API-48`'s list, answering with the machine view.*
680: 
````

## WIR-30 — 13-wire-contract.md:1034

````text
1034: **WIR-30** **AMENDED** `GET /v1/providers/{account}/offers` — customer prices only (`LDG-26`), an
1035: unassigned account `404`s (`WIR-36`), and **an account whose `STO-47` status is not `healthy` `404`s
1036: on this route too** — *added 2026-09-04, because the health filter went onto the collection route
1037: alone and this one is reachable by any caller that remembers an account name, serving a full price
1038: list that `WIR-29`'s create refusal then rejects at purchase*:
1039: 
1040: ```json
1041: {"offers": [{
1042:   "id": "market:12345", "name": "Auction dedicated server", "kind": "bare_metal", "regions": ["fsn1"],
1043:   "recurring_price": {"amount_sats": 90, "period": "hour"},
1044:   "setup_fee_sats": 0,
1045:   "first_unit_sats": 90,
1046:   "billing_unit_seconds": 3600,
1047:   "min_runway_seconds": 3600,
1048:   "quoted_at": "2026-08-12T13:59:00Z", "binding": false,
1049:   "max_rate_outage_seconds": 21600,
1050:   "traffic_bound": "unlimited",
1051:   "install_strategies": ["rootfs_via_rescue", "raw_disk"],
1052:   "max_image_bytes": 107374182400,
1053:   "guest_requirements": null
1054: }]}
1055: ```
1056: 
1057: **`install_strategies` is the offer's subset of `DOM-13`'s strategies, and it gates them.** The
1058: account's `capabilities` (`WIR-29`) say what the driver can do at all; eligibility for a
1059: rescue-based install is a property of the **offer**, because an auction listing and a standard
1060: product at the same provider can differ on it. The fixture shows a Robot
1061: default-uplink offer, currently sellable under `ADR-0039`. An install naming a strategy absent from its
1062: machine's recorded list MUST be rejected as `invalid_request` before the operation is enqueued,
1063: exactly as an invalid pairing is. The list MUST be present on every offer; an empty list means no
1064: install is available for that offer. **The gate reads the copy the machine took at create —
1065: `machines.install_strategies` (`05-persistence.md`) — not the offer as it stands at install time**,
1066: because an offer is a live listing that can change or disappear between the two, and re-resolving
1067: it either fails an install on a machine that is running and paid for or answers from terms its
1068: owner never bought. **That copy is returned to the caller on the machine view** (`WIR-11`,
1069: `DOM-30`), so a caller reasons about the same list the gate does rather than about this one. `offer_id` remains the provenance record of which offer that copy came from.
1070: A machine with no list is read as permitting nothing, and never falls back to the provider
1071: account's declared capabilities (`DOM-10`): capabilities are per account and eligibility is per
1072: product, so the account of an operator who runs one rescue-capable box would authorize a
1073: disk-wiping install on a machine that cannot take one (`05-persistence.md`).
1074: 
1075: `max_image_bytes` is `RSC-40`'s enforced ceiling on a caller-supplied image, checked against the
1076: stream and aborting the transfer when exceeded; it is the only thing about the image provisiond
1077: checks, because interpreting the content would put a parser for hostile binary inside the
1078: credential-holding process. `guest_requirements` is **prose** the caller relays to whoever built
1079: the image — null where the strategy imposes none, and non-null for `provider_catalogue`, where the
1080: provider converts and boots the image and its own rules decide whether the machine comes up at all
1081: (`RSC-43`). Prose deliberately: an agent can compute against a byte count and cannot compute
1082: against "cloud-init configured with the correct datasource order", which only the image's author
1083: can guarantee. *Structured what the agent must compute, prose what it must understand.*
1084: 
1085: `max_rate_outage_seconds` is `LDG-64`'s bound, disclosed before purchase because past it a
1086: machine is cancelled regardless of its runway. **It is the operator's current limit and not a term
1087: of the purchase**: it can change during an outage (`OVR-19` holds the rule), `binding: false`
1088: speaks to the price only, and for a machine the authoritative instant is its view's
1089: `rate_outage_deadline` (`WIR-11`) (*added 2026-10-02, `ADR-0029`*). Prices are integers of
1090: satoshis, already margined by
1091: the one pricing function (`LDG-23`, `LDG-24`)
1092: at the same rounding as commitment creation. `first_unit_sats` is the prepaid first billing unit's
1093: customer price and `billing_unit_seconds` its duration (`ADR-0033`, added 2026-10-08; `PRV-13b`
1094: prices it and `LDG-39` holds its lifecycle), disclosed beside the setup fee — a quote under the
1095: same `binding: false` as the recurring price; the unit's `native_floor` is a provider figure and
1096: does not appear. **An offer price is an indicative quote converted at
1097: read time; `binding` is `false` and the commitment is priced at accept time (`LDG-27`) and MAY
1098: differ** — a caller bounding spend uses `WIR-17`'s `max_commitment_sats`, not the quote. The
1099: provider's currency, price string and raw metadata MUST NOT appear.
1100: 
1101: This customer listing follows `DOM-9`'s sale filter and MUST disclose the
1102: `PRV-44` `traffic_bound` of every listed offer: `"unlimited"` or, following
1103: conditional re-admission under `ADR-0039`, `{ "limit_bytes": nonnegative integer }` for
1104: the declared allowance less headroom. For that conditional allowance branch, the
1105: listing MUST disclose before purchase that crossing `limit_bytes` causes an
1106: exposure-reducing cancellation that destroys the machine. This is a traffic
1107: limit, not a second customer price. For remembered IDs, see `API-7`'s create-tail
1108: "`invalid_request`/`offer_not_sellable` when the named offer is not sellable
1109: under `PRV-13b` or `PRV-31`".
1110: *Amended 2026-10-09 (`ADR-0039`).*
1111: 
````

## 01-domain-model.md:159

````text
159: A purchasable configuration: a cloud server type, a standard dedicated product, or an
160: auction/market listing.
161: 
162: | Field | Notes |
163: |---|---|
164: | `id` | Driver-scoped offer identifier, opaque to clients |
165: | `name` | Human-readable |
166: | `kind` | `virtual` \| `bare_metal` |
167: | `regions` | Where the offer can be placed |
168: | `currency`, `recurring_price`, `recurring_period` (`hour` \| `month`), `setup_fee` | Prices are strings to avoid float rounding. **Exactly one recurring price with its period, and one setup fee (`"0"` where the channel charges none), all required** — *until 2026-09-05 this row was two nullable prices and no setup fee, which could not carry Robot's per-location `price_setup` at all and let an offer with neither price pass as legal* |
169: | `install_strategies` | The offer's subset of `DOM-13`'s strategies, which **gates** them (`WIR-30`). Present on every offer; empty means no install is available for it |
170: | `max_image_bytes` | The ceiling `RSC-40` enforces against a caller-supplied image stream |
171: | `guest_requirements` | Prose the caller relays to whoever built the image; null where the strategy imposes none, non-null for `provider_catalogue` (`RSC-43`, `WIR-30`) |
172: | `min_runway_seconds`, `setup_fee_sats`, `first_unit_sats`, `billing_unit_seconds`, `max_rate_outage_seconds` | `PRV-13d`'s floor, `LDG-39`'s at-cost fee, the prepaid first billing unit's customer price in satoshis and its duration in seconds beside the fee (`ADR-0033`, `PRV-13b`; added 2026-10-08 — the unit's `native_floor` and native rate never reach the customer surface, `LDG-26`), and `LDG-64`'s disclosed bound — the operator's current limit, which can change (`WIR-30`) |
173: | `traffic_bound` | The offer's declared traffic limit, disclosed as `unlimited` for currently sellable offers (`PRV-44`, `WIR-30`); an allowance with headroom is conditional on `ADR-0039`'s live evidence gate (*added 2026-10-09, `ADR-0039`*) |
174: | `metadata` | Raw provider payload |
175: 
176: *The `install_strategies`, `max_image_bytes`, `guest_requirements` and limits rows
177: were added 2026-09-02; the two unit fields in the limits row,
178: 2026-10-08 (`ADR-0033`).* The customer-facing additions are required on the wire by
179: `WIR-30` and load-bearing somewhere — `install_strategies` is a **safety gate** whose absence
180: authorizes a disk-wiping install (`05-persistence.md`), `max_rate_outage_seconds` discloses a second
181: trigger that destroys a machine — and none was in the entity this document defines. A caller reading
182: `01` learned the domain had an offer with a price and a name; a caller reading `13` received
183: the listed fields without an entity behind them.
````

## 02-provider-contract.md:71

````text
71: ### Describe capabilities
72: 
73: **Input** — none.
74: **Output** — the descriptor (`PRV-44`).
75: 
76: Pure and synchronous; it MUST NOT perform network I/O. It is called on every capability
77: check and on every `GET /v1/providers`.
78: 
````

## 05-persistence.md:520

````text
520: | `correlator_kind`, `correlator_value` | text, text | nullable; what the create wrote into the provider (`PRV-26`) — `operation_uuid` where a free field exists, `ssh_key_fingerprint` on Robot (`PRV-32`). **A single value, not a list** (`ADR-0014`): a create has one attempt and one correlator. Written in `API-63`'s correlator transaction, which is `OPS-43`'s step 8, after its step-4 List offers read and before the order (`PRV-26`: "before the order is sent"; `API-63`: "the last write before the ordering call"), and null for every operation kind other than create. The `provider_account` write retains `OPS-35`'s "before any driver call". *Amended 2026-10-17 (`pv-14b`; panel r55, `docs/research/panels-2026-10/r55/`): aligned correlator timing with the correlator transaction, after List offers and before the order.* *`F36` and `ADR-0014` record what the withdrawn per-attempt list cost* |
521: | `about_to_order_at` | timestamp | nullable; create only, null on every other kind. Written once in `OPS-43`'s step 8, `API-63`'s correlator transaction, on every ordering channel including `correlator: none`; the only other writer is `STO-13`'s one-time migration backfill. **Never cleared; survives the request-data purge** on entry to a settled state or `needs_reconciliation`. It is a column outside `request`, not a correlator or one of `OPS-45`'s markers; nothing copies it to a machine or renders it on the wire. `OPS-43`: "MUST set `operations.about_to_order_at` to `COALESCE(about_to_order_at, <transaction time>)`". *Amended 2026-10-17 (`pv-k4l`; panels r56 and r56b, `docs/research/panels-2026-10/r56/` and `docs/research/panels-2026-10/r56/r56b/`): added the all-channel column; `ADR-0042`.* |
522: | `request` | json | caller payload — **live operations only**, purged on entry to any settled state **and to `needs_reconciliation`** (`ADR-0005`, `OPS-3`) |
523: | `request_summary` | json | what survives the purge: what was attempted, plus provider-side identifiers, plus, for a create, **one record and not a list** (`ADR-0014`): the correlator, the **offer snapshot** (`offer_id`, the offer's `install_strategies` as accepted, and — *added 2026-09-05, because `OPS-43`'s claim-time price check reads them and a worker restarted before claim had nothing to compare* — the accepted **recurring price, its currency and its period**, and — *added 2026-10-16, `pv-tsb`* — the **declared cancellation bound**) and the **at-cost setup fee** and, beside it since 2026-10-08, the **prepaid first billing unit** (`ADR-0033`) — each as native minor units, currency, and the satoshi amount authorized at the create, and the unit also with its `billing_unit.seconds` as the offer declared it when the create was accepted — the create's record of the unit's duration, from which `machines.billing_unit_seconds` takes the copy the machine's first seed reads, at create or at attach (`LDG-67`, `LDG-39`, `LDG-38`; `ADR-0033`, 2026-10-08). Resolution reads that snapshot as the copy the attached machine takes (`OPS-13`) and those two amounts as what `LDG-39` settles — each debited against a still-open commitment, or absorbed as an operator deficiency of its own where `OPS-33` has released it. The declared cancellation bound MUST be resolved to a provider-local date at API acceptance, in the create's admitting transaction, taking the later of the descriptor's `cancellation_bound` and the offer-reported bound where both exist: `PRV-31`'s sale refusal tests "if either its descriptor-declared bound or its offer-reported bound is later than the provider's local today". The snapshot uses `PRV-13`'s representation: "a day-only value MUST be stored as the UTC instant at the start of that day in the provider's date zone". *Amended 2026-10-16 (`ADR-0037`, `pv-tsb`).* *`F36` and `ADR-0014` record why this is one record rather than a per-attempt list* |
524: | `correlation_id` | text | not null; present in the record and in every log line for this request (`API-28`) |
525: | `result` | json | nullable, redacted |
526: | `error` | json | nullable, redacted |
527: | `resolution` | enum | nullable; `observed` \| `absent` \| `abandoned` for a create, and `applied` \| `not_applied` \| `abandoned` for a kind that acts on an existing machine — install, rescue inventory, power, reverse DNS, delete, release attachment (`OPS-27`, `OPS-31`, `OPS-45`, `WIR-35`). The first pair name a resource that may or may not have been created; the second pair name a mutation that may or may not have taken effect, which is a different question and had no verb until 2026-09-02. **The store MUST reject a value outside the set its operation's kind admits**, which is `WIR-35`'s rule enforced where `API-24` cannot reach |
528: | `write_started_at` | timestamp | nullable; `OPS-45`'s first marker — when a phase began that could have altered the machine, written **before** that phase runs. Null means the mutation provably did not begin — but **non-null does NOT mean `not_applied` is unrecordable**, and reading it that way is the defect corrected on 2026-09-04: only on a `rootfs_via_rescue` or `raw_disk` install does this column mean the destructive phase was allowed to begin — the old contents no longer represented as preserved, `OPS-45` — and only there does it refuse the verb (`WIR-35`, `OPS-45`). On every other kind it records a dispatch. **Write-once, and nothing clears it** (`OPS-45`): a marker is a fact about this one operation. Null on every kind `OPS-45` does not reach — a create has no machine to alter and is resolved by correlator instead (`OPS-27`). *Amended 2026-10-23 (`pv-9j6`; panel r64b; owner decision “Yes, settle failed (Recommended)”; `ADR-0046`): deleted the duplicate classification claim in favor of `OPS-11`.* |
529: | `rescue_exited_cleanly` | boolean | nullable; `OPS-45`'s second marker — true when the driver's end-rescue call returned success, null only where no rescue session was opened, false where the exit failed or the operation died before reaching it; written `false` before `PRV-15` is dispatched and `true` on the end-rescue success (`OPS-45`, which owns the rule). **A null `write_started_at` alone does not make a failure deterministic**: entering rescue reboots the machine into another operating system and `PRV-22` makes a failed exit always ambiguous, so an untouched disk on a machine possibly still sitting in rescue is not "nothing happened". Both are copied into `request_summary` so an operator reading a resolved record still has them after the payload purge (`ADR-0005`); **these columns are authoritative and the copy is a convenience** |
530: | `restore_markers_untrusted` | boolean | target non-null after `STO-13`'s staged migration; retained with the operation after payload purge; provenance owned by `STO-54`; wire rendering owned by `WIR-9a` |
531: | `privileged_seconds`, `bytes_transferred`, `storage_seconds` | integer, integer, integer | nullable; `LDG-25`'s metering of a privileged operation — rescue occupancy or import-to-switchover, and for a catalogue install the bytes transferred and the storage-seconds of the re-hosted copy (`RSC-39`, `RSC-42`). Free in v1 and counted from the first release, because a price cannot be introduced later for something that was never counted. Metering facts, not caller payload: they survive `ADR-0005`'s purge. *Added 2026-09-05; the MUST had no column* |
532: | `resolved_at`, `resolved_by`, `resolution_evidence` | timestamp, text, json | nullable; how a `needs_reconciliation` record was closed |
533: | `commitment_id` | UUID | nullable; the commitment opened in the same transaction as the enqueue (`LDG-11`). *Renamed from `hold_id` 2026-08-12* |
534: | `revision` | integer | strictly increases on every client-visible change (`API-53`); arbitrates out-of-order polls |
535: | *`pending_fee_native_minor`, `pending_fee_currency`, `pending_fee_sats`* | — | **Withdrawn 2026-09-05.** *They were "the scalar copy of the latest attempt's fee, kept for reading the outstanding obligation", while `LDG-67` itself said the amount debited on resolution is the matched attempt's entry in `request_summary` — a second representation of a figure the per-attempt entries already hold, the shape `LDG-73` was removed for. The outstanding obligation is the latest attempt's entry (`LDG-67`)* |
536: | `requested_by` | enum | `caller` \| `system` \| `operator` (`OPS-39`) |
537: | `system_reason` | text | nullable; set when `requested_by = system` — `exhausted`, `late_attach_cleanup`, `tenant_suspended` (`API-58`'s per-machine cancellations, never the caller's own queued work that the same fan-out fails: that keeps `requested_by = caller`, a null `system_reason`, and carries the reason in `error`), `rate_outage_bound` (`LDG-64`) |
538: | `episode_id` | UUID | nullable; foreign key to `episodes` (`STO-52`). Set on every attempt an episode enqueues (`OPS-48`), in the same transaction as the enqueue; null on every other operation. Replaces `system_trigger_id` (2026-09-08, `ADR-0017`): the episode is a row, so the operation carries a reference rather than a copy |
````

## 10-conformance-checklist.md:30

````text
30: seed under a unit of some seconds is `CNF-318`'s.
31: 
32: **Stored offer listings in the items below** (2026-10-26): An item that asserts or relies on a create being admitted or succeeding, including a create used to show a release, without specifying the stored listing's age, runs on a stored listing that contains the named offer and has a `read_at` no older than the stated offer-listing age at the admitting transaction (see `OVR-19`). This default qualifies only the admission or success assertion and any create used to reach it; an item asserting a refusal without specifying the stored listing's age asserts it whatever that age. For the stale-listing refusal case, see `CNF-166`.
````

## tools/formal/Provisiond/Admission.lean:15

````text
15: The pipeline (`API-7`, `WIR-34`, `API-55`, `API-56`): principal, tenant state,
16: listener and verb decide one outcome and whether the request consumed a ceiling slot.
17: The create-only step 5d is modelled in `createPurchaseTail`, outside `admit`, which stops at
18: 5c; `createAdmission` composes it with collection and the listing-age decision.
19: `API-7` says "A refusal stops here and is not collected by the tail." The ceilings
20: (`SEC-39`): which budget each verb counts against, and the two properties that make a ceiling a
````

## tools/formal/Provisiond/Admission.lean:317

````text
317: `orderingCapabilityGuard` (`API-7`, 2026-10-22, `pv-p3k`): `API-7` says
318: "**gate a create on its ordering capability**". Off, a create without that declaration reaches
319: the purchase tail.
320: 
````

## tools/formal/Provisiond/Admission.lean:1180

````text
1180: /-- Step 5d composed before the create's tail (`API-7`, `DOM-10`). The supplied Boolean answers
1181: whether the account declares the create's ordering capability. Machine-kind selection and
1182: descriptor construction are outside this model. Only creates enter this function; the shared
1183: steps 1–5c and extend-runway's tail are separate. -/
1184: @[req "API-7"]
1185: def createPurchaseTail (g : Guards) (orderingDeclared : Bool) (account : AccountStatus.Status)
1186:     (offerSellable channelClosed halted rate capPresent cap balance : Bool) : CreateTailResult :=
1187:   if g.orderingCapabilityGuard && !orderingDeclared then
1188:     { refusal := some .unsupported, tail := none }
1189:   else
1190:     { refusal := none, tail := some (purchaseTail g true account offerSellable channelClosed
1191:         false halted rate capPresent cap balance) }
1192: 
1193: /-- With step 5d enabled, an undeclared ordering capability refuses the create as unsupported
1194: and produces no tail result, regardless of the tail's snapshot inputs (`API-7`, `DOM-10`). -/
1195: @[req "API-7"]
1196: theorem undeclared_ordering_stops_before_tail (g : Guards)
1197:     (h : g.orderingCapabilityGuard = true) (account : AccountStatus.Status)
1198:     (o c s r q p b : Bool) :
1199:     createPurchaseTail g false account o c s r q p b =
1200:       { refusal := some .unsupported, tail := none } := by
1201:   simp [createPurchaseTail, h]
1202: 
1203: /-! ## Composed create admission
1204: 
1205: `API-7`: "On create, the tail reads the stored listing regardless of age, or an empty offers set
1206: if no listing is stored." The supplied sale verdict includes the named offer's absence, including
1207: an empty offers set. There is no separate no-row refusal or presence policy here. -/
1208: 
1209: /-- Age and limit are coherent durations in the same units from the admitting snapshot.
1210: No timestamp subtraction, clock or database read is performed by this model. -/
1211: @[req "API-7"]
1212: def listingStale (age limit : Nat) : Bool := decide (limit < age)
1213: 
1214: @[req "API-7"]
1215: theorem listing_stale_iff (age limit : Nat) :
1216:     listingStale age limit = true ↔ limit < age := by simp [listingStale]
1217: 
1218: @[req "API-7"]
1219: theorem listing_age_equality_is_fresh (limit : Nat) :
1220:     listingStale limit limit = false := by simp [listingStale]
1221: 
1222: /-- Apply age only to an empty, successfully collected result; retain that collection alongside
1223: any added refusal. The result contains no write continuation or wire serialization. -/
1224: @[req "API-7"]
1225: def afterListingAge (g : Guards) (age limit : Nat) (result : CreateTailResult) : CreateTailResult :=
1226:   match result.refusal, result.tail with
1227:   | none, some tail =>
1228:       if tail.refusals.isEmpty then
1229:         if g.listingAgeGuard && listingStale age limit then
1230:           { refusal := some .provider, tail := some tail }
1231:         else result
1232:       else result
1233:   | _, _ => result
1234: 
1235: /-- Direct composition over the existing step-5d and collection function. All sale and age
1236: inputs refer to the same admitting snapshot; supplying them coherently is not proved here. -/
1237: @[req "API-7"]
1238: def createAdmission (g : Guards) (orderingDeclared : Bool) (account : AccountStatus.Status)
1239:     (offerSellable channelClosed halted rate capPresent cap balance : Bool)
1240:     (age limit : Nat) : CreateTailResult :=
1241:   afterListingAge g age limit
1242:     (createPurchaseTail g orderingDeclared account offerSellable channelClosed
1243:       halted rate capPresent cap balance)
1244: 
1245: /-- Every pre-collection refusal survives at every age, with no collection introduced. -/
1246: @[req "API-7"]
1247: theorem age_preserves_early_refusal (g : Guards) (age limit : Nat) (kind : ErrorKind) :
1248:     afterListingAge g age limit { refusal := some kind, tail := none } =
1249:       { refusal := some kind, tail := none } := by rfl
1250: 
1251: @[req "API-7"]
1252: theorem age_preserves_step_5d (g : Guards) (h : g.orderingCapabilityGuard = true)
1253:     (a : AccountStatus.Status) (o c s r q p b : Bool) (age limit : Nat) :
1254:     createAdmission g false a o c s r q p b age limit =
1255:       { refusal := some .unsupported, tail := none } := by
1256:   simp [createAdmission, createPurchaseTail, afterListingAge, h]
1257: 
````

## tools/formal/Provisiond/Wire.lean:637

````text
637: structure Summary where
638:   kind                : Kind
639:   machine             : Option MachineId
640:   providerAccount     : Option String
641:   providerIds         : List String
642:   correlator          : Option String
643:   offerSnapshot       : Option String
644:   setupFeeSats        : Option Nat
645:   writeStartedAt      : Option Nat
646:   rescueExitedCleanly : Option Bool
647:   attempted           : Option Payload
648:   deriving DecidableEq, Repr
````
