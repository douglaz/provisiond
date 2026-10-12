**Verdict:** don't build a Robot request gate; size the refresh freshness window no shorter than the account-sweep interval, and the tenant read path on `GET /server/{n}` disappears into machinery the set already has.

**Traffic map** (v1 Robot; limits per hour from the reference, retrieved 2026-10-10; scope unstated):

| Path | Endpoints (limit) | Who drives it |
|---|---|---|
| refresh (`DOM-8`) | `GET /server/{n}` (200) | tenant; bounded only by `OPS-8` and the window |
| create | `POST /key` (200), `POST /order/*/transaction` (20/day), `GET …/transaction/{id}` polls (500), `GET /server/{n}` confirm (`OPS-27` 03:472; 200), `GET /server/{n}/cancellation` read-and-branch (`PRV-13c`; 200), `DELETE /key` (200) | tenant; capped by the order budget |
| resolution (`OPS-27`) | `GET /order/*/transaction` (500), `GET /server/{n}` (200) | system, per pending op per cadence |
| delete / system cancellation | `GET /server/{n}/cancellation` pre-read for `reserve_location` (08:405; 200), `POST …/cancellation` (200) | tenant (ceilinged, one paid machine each) and system |
| sweep (`OPS-32`) | `GET /server` once per interval (200); `GET /server/{n}` per missing candidate (03:1379) | system |
| rescue inventory / install / end rescue | `/boot/{n}/rescue` (500), `POST /reset/{n}` ×2 (50), `/key` (200) | tenant; `SEC-39` rescue-entry ceiling |
| power | `POST /reset/{n}` (50) | tenant; power-cycle ceiling |
| reverse-DNS | `/rdns/{ip}` (500) | tenant; ceilinged; no-op on equal value |
| attachment release | `/ip/{ip}/cancellation`, subnet cancellation (200) | system / operator |

**Why.** The framing "can a tenant exhaust it" is the wrong question for `GET /server/{n}`. 200 reads an hour on one credential is a fleet cap on any design that observes machines one at a time: 200 honest machines cannot each be observed once an hour, attacker or not. Per-machine windows (option b) are `N·3600/W` and fail at fleet size whatever `W`. The set already observes the fleet one call at a time: `OPS-32` enumerates the account per interval and `DOM-8` (01:133) says the sweep "MUST write what it saw (state, and `machines.state_observed_at`)", which is the column the refresh's cache check reads. Robot's list carries every field the single read carries except availability booleans (`reset`, `rescue`, `vnc`, `windows`, `plesk`, `cpanel`, `wol`, `hot_swap`, `linked_storagebox`); `status` is only "ready" or "in process", there is no power state, and rDNS is on neither. So on Robot a per-machine refresh observes nothing the list did not. With window ≥ interval, tenant refreshes cost zero provider reads while the sweep runs; when it falls behind, `ADR-0034` Decision 1's one-read-per-machine-per-window is the fallback, unchanged. That is option (a) with nothing new: no shared cache, no per-driver rule, no closure.

**Is the threat real?**

- `GET /server/{n}`: cheap (four auction machines at ~€0.3/h on a 60 s window), so (d) fails there. Opus's arithmetic assumes one bucket per endpoint per credential; the reference states neither the scope nor whether `{server-number}` instances share a bucket, and 08:416's `[verify]` covers ordering only. Exhaustion harm is bounded and self-healing: the sweep "writes no absence" on a failed re-read (03:1346), so a gone machine bills its tenant past `LDG-74`'s bound for the interval; `OPS-27`'s failed confirm "cannot establish success" and retries at the resolution cadence, so an operator-funded machine runs unattached for ≤1 h. No second order is placed.
- Cancellation endpoints: 200 tenant deletes an hour means 200 paid machines alive on one account, bought at ≤60/day (`ADR-0036`'s residual already running) and metered for days (`ADR-0033`). Harm: a system cancellation's `403` is `failed` → `stalled` (`OPS-48`) → operator retry. Priced, alarmed, same shape `ADR-0036` accepted. A closure (c) restores no capacity inside the interval; Robot's own `403` already refuses the tenant with the same information.
- `POST /reset` at 50/h: power, rescue inventory (×2) and install (×2) reach it; no system path does. Exhaustion strands another tenant's install at end-rescue, `PRV-22` "always ambiguous" → `needs_reconciliation`. Tenant-against-tenant, bounded by `SEC-39` ceilings × priced principals (`API-35` + a machine), the residual `ADR-0034`:70 already accepts; `SEC-43` scales it out.
- `GET …/transaction/{id}` at 500/h is the one bucket the system can hit alone: orders poll 4–7 min (08:402) at an unregistered cadence, so six concurrent creates at 5 s exceed it. A throttled poll after acceptance is `needs_reconciliation` and `OPS-27` resolves through the listing, a separate endpoint. Handled; worth a note, not a rule.

**Defects**

1. `docs/adr/0034:68-71`: "needs many paid machines, not one. At a sixty-second window that is about sixty" is Cloud arithmetic; on Robot four suffice. :71 "It never reaches the system's own deletes" was withdrawn by Q19 and still stands. :78 "Not covered here" needs the amendment.
2. `03-operation-lifecycle.md:1350` "what it observed *present* it may still record" (MAY) against `01-domain-model.md:133` "MUST write what it saw". The shape above depends on the present-write, and the owner says may. `12:541` mandates only the gone write.
3. `08-provider-notes.md:411-418` records orders and "cancellation is documented at 200 per hour"; reads, boot, reset, key and rdns limits are absent, and the scope `[verify]` names ordering only.
4. The brief's `PRV-50` does not exist; the mapping is `PRV-5` at `02-provider-contract.md:50`.
5. No CNF asserts the sweep's present-write or a zero-read refresh loop; `CNF-339` (10:3358) validates the window only as positive.

**Edits**

- `01:140` (`DOM-8`): "The window MUST be no shorter than the account-sweep interval (`OVR-19`), so a refresh inside a running sweep is answered by the sweep's observation and a provider read reaches the driver only when the sweep is behind."
- `00:377`: type "finite, positive duration, no shorter than the account-sweep interval".
- `03:1350` (`OPS-32`): "A complete pass MUST write state and `state_observed_at` for every machine it observed present, as it does for an absence (`STO-48`)." `DOM-8` quotes it.
- `08:411-418`: the limits table above, `[verify]` extended to every limit's scope and to whether `{server-number}` paths share one bucket; the order-poll arithmetic as a sizing note.
- `ADR-0034` amendment (Q20): the fleet-cap argument, the sizing rule, residuals accepted for cancellation and reset, :71 struck.
- `CNF-339`: startup refuses a window shorter than the sweep interval. New CNF: N machines, a tenant loops refresh on all; across one sweep interval assert one `GET /server`, N present-writes, zero `GET /server/{n}`; stop the sweep, assert one read per machine per window; inject `403` on the sweep's re-read, assert no absence; on `OPS-27`'s confirm, assert unresolved and retried at the cadence.
- Lean: nothing to prove. `ProviderTraffic.claimRefresh` is source-agnostic, so `fresh_claim_reuses` already covers a sweep-written observation; add one witness beside `Witnesses.lean:3787`: observed by the sweep at t, refresh at t+Δ<window → `reads = 0`; window shorter than the interval → `reads = 1`. The ordering constraint is configuration, which the model's header leaves to implementation.
