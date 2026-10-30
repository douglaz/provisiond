
### 03-operation-lifecycle.md:978 at 3109b5b44eae17e288cf52aaa976993bd8c5626c
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

### 03-operation-lifecycle.md:1483 at 3109b5b44eae17e288cf52aaa976993bd8c5626c
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

### 03-operation-lifecycle.md:1798 at 3109b5b44eae17e288cf52aaa976993bd8c5626c
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

### 03-operation-lifecycle.md:2048 at 3109b5b44eae17e288cf52aaa976993bd8c5626c
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

### 03-operation-lifecycle.md:836 at 3109b5b44eae17e288cf52aaa976993bd8c5626c
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

### 10-conformance-checklist.md:2558 at 3109b5b44eae17e288cf52aaa976993bd8c5626c
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

### 10-conformance-checklist.md:3049 at 3109b5b44eae17e288cf52aaa976993bd8c5626c
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

### 05-persistence.md:421 at 3109b5b44eae17e288cf52aaa976993bd8c5626c
421: 
422: *Machine columns amended 2026-10-10 (`ADR-0038`, including Q15 and Q15b). The public object is
423: derived by `WIR-47`.*
424: 
425: **STO-48** **`state_observed_at` is a money column, and `updated_at` cannot stand in for it.**
426: `LDG-74` stops billing a machine the provider has destroyed at the instant the observation was made,

### 05-persistence.md:679 at 3109b5b44eae17e288cf52aaa976993bd8c5626c
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

### 01-domain-model.md:159 at 3109b5b44eae17e288cf52aaa976993bd8c5626c
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

### 02-provider-contract.md:76 at 3109b5b44eae17e288cf52aaa976993bd8c5626c
76: Pure and synchronous; it MUST NOT perform network I/O. It is called on every capability
77: check and on every `GET /v1/providers`.
78: 
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

### tools/formal/Provisiond/Witnesses.lean:4338 at 3109b5b44eae17e288cf52aaa976993bd8c5626c
4338: 
4339: /-- A create without its ordering declaration, with an otherwise clean tail except for balance.
4340: These inputs make the tail's answer independent of every unrelated guard. -/
4341: def undeclaredOrderingCreate (g : Admission.Guards) :=
4342:   createPurchaseTail g false .healthy true false false true false false true
4343: 
4344: /-- Step 5d, added 2026-10-22 (`pv-p3k`), stops this create before any tail collection. -/
4345: @[req "API-7"]
4346: theorem undeclared_ordering_is_unsupported_before_the_tail :
4347:     undeclaredOrderingCreate Admission.current =
4348:       { refusal := some .unsupported, tail := none } := by decide
4349: 
4350: /-- Without step 5d the same create reaches the purchase tail and its balance refusal. -/
4351: @[req "API-7"]
4352: theorem undeclared_ordering_reaches_the_tail_without_the_step :
4353:     undeclaredOrderingCreate { Admission.current with orderingCapabilityGuard := false } =
4354:       { refusal := none, tail := some { refusals := [.balance], notChecked := [] } } := by decide
4355: 
4356: /-- An otherwise clean stale create; neutral inputs isolate the age control from every other

### .github/workflows/ci.yml:908 at 3109b5b44eae17e288cf52aaa976993bd8c5626c
908:           Admission|cancellationDeclarationGuard|true|false|declarationSaleGuards Admission.current
909:           Admission|cancellationFutureGuard|true|false|futureSaleGuards Admission.current
910:           Admission|channelClosureGuard|true|false|channelClosed
911:           Admission|reverseDnsCeiling|true|false|reverseDnsAdmission
912:           Admission|orderingCapabilityGuard|true|false|undeclaredOrderingCreate
913:           Admission|listingAgeGuard|true|false|staleListingCreate
914:           ProviderTraffic|reuseFresh|true|false|freshClaim

### tools/formal/Provisiond/Wire.lean:545 at 3109b5b44eae17e288cf52aaa976993bd8c5626c
545:   kind                : Kind
546:   status              : Status
547:   machine             : Option MachineId
548:   providerAccount     : Option String
549:   request             : Option Payload
550:   providerIds         : List String
551:   correlator          : Option String
552:   offerSnapshot       : Option String
553:   setupFeeSats        : Option Nat
554:   writeStartedAt      : Option Nat
555:   rescueExitedCleanly : Option Bool

### 10-conformance-checklist.md:2573 at 3109b5b44eae17e288cf52aaa976993bd8c5626c
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

### 05-persistence.md:523 at 3109b5b44eae17e288cf52aaa976993bd8c5626c
523: | `request_summary` | json | what survives the purge: what was attempted, plus provider-side identifiers, plus, for a create, **one record and not a list** (`ADR-0014`): the correlator, the **offer snapshot** (`offer_id`, the offer's `install_strategies` as accepted, and — *added 2026-09-05, because `OPS-43`'s claim-time price check reads them and a worker restarted before claim had nothing to compare* — the accepted **recurring price, its currency and its period**, and — *added 2026-10-16, `pv-tsb`* — the **declared cancellation bound**) and the **at-cost setup fee** and, beside it since 2026-10-08, the **prepaid first billing unit** (`ADR-0033`) — each as native minor units, currency, and the satoshi amount authorized at the create, and the unit also with its `billing_unit.seconds` as the offer declared it when the create was accepted — the create's record of the unit's duration, from which `machines.billing_unit_seconds` takes the copy the machine's first seed reads, at create or at attach (`LDG-67`, `LDG-39`, `LDG-38`; `ADR-0033`, 2026-10-08). Resolution reads that snapshot as the copy the attached machine takes (`OPS-13`) and those two amounts as what `LDG-39` settles — each debited against a still-open commitment, or absorbed as an operator deficiency of its own where `OPS-33` has released it. The declared cancellation bound MUST be resolved to a provider-local date at API acceptance, in the create's admitting transaction, taking the later of the descriptor's `cancellation_bound` and the offer-reported bound where both exist: `PRV-31`'s sale refusal tests "if either its descriptor-declared bound or its offer-reported bound is later than the provider's local today". The snapshot uses `PRV-13`'s representation: "a day-only value MUST be stored as the UTC instant at the start of that day in the provider's date zone". *Amended 2026-10-16 (`ADR-0037`, `pv-tsb`).* *`F36` and `ADR-0014` record why this is one record rather than a per-attempt list* |

### 03-operation-lifecycle.md:850 at 3109b5b44eae17e288cf52aaa976993bd8c5626c
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
