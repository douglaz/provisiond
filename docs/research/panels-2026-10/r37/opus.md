**Verdict:** build (a), plus (d)'s alarm. Reject (b) and (c) for now. Accept the `POST /reset` limit under (d). The brief assumes Robot counts each endpoint once per account; Robot never says so, and only (a) works under every possible counting rule.

**Traffic map (Robot v1; limit per hour)**

| Path | Endpoints | Can a tenant repeat it? |
|---|---|---|
| refresh | `GET /server/{n}` (200); `PRV-35` `locked` via `/ip`, `/subnet` (5000) | yes. At most one successful read per machine per window; unbounded while reads fail (01:149) |
| create | product check (500), `POST /key` (200), order (20/day), poll (500), **confirming `GET /server/{n}`** (03:493) | bounded by the order budget |
| `OPS-27` | transaction search (500), confirming `GET /server/{n}` | system |
| delete (tenant or `OPS-39`) | `GET`, then `POST /server/{n}/cancellation` (200 each) | once per machine, plus retries under the destroy ceiling |
| `OPS-32` sweep | `GET /server` (200), direct `GET /server/{n}`, `/ip`, `/subnet`, `/key` | system |
| install, inventory | `/boot/{n}/rescue` (500), **`POST /reset` ×2** (08:129) | yes, under `SEC-39` |
| power, hard reset | `POST /reset` (50; its `type` includes `power`) | yes, under `SEC-39` |

**Why**

- **Shared endpoint:** the `/server` family (200/hour) is the tightest limit that refresh shares with the system's own reads.
- **The counting scope is undocumented.** The reference says only "If the request limit is reached, the HTTP status "403 - Forbidden" is returned". It doesn't say whether it counts per webservice user, per account or per source IP. It also doesn't say whether `{server-number}` counts per endpoint template or per server.
  - If it counts per server, r36's "four machines' loops exceed 200" is false.
  - If it counts per template and account, the endpoint throttles once N > 200·W/3600 (N machines, freshness window W in seconds). The 60 s window is `ADR-0034`'s illustration, not an `OVR-19` value.
- **Fleet growth hits it with no attacker.** At W = 60 s, four honestly polled machines go over. An attacker only needs four auction servers ("`price_setup` is **`0.0000`**", billed hourly).
- **The throttle keeps itself going:** a refresh whose read fails just reads again (01:149).
- **Harms, in the owning requirements' words:**
  - The sweep "MUST yield to `rate_limited`" (03:1424). That breaks "the maximum time a customer can be billed for a machine that no longer exists" (03:1405).
  - "a failed confirming read likewise cannot establish success" (03:493). Accepted creates sit in `needs_reconciliation`, unmetered.
  - If all six `/server` endpoints share one counter, the delete's pre-read fails before acceptance and `OPS-48` stalls exhaustion deletes.
- **`POST /reset`:** no system path resets (suspension cancels). This is tenant against tenant, and per-principal ceilings multiply with the number of tenants.
  - The sharp edge: a throttled exit reset is "*always* ambiguous" (`PRV-22`), which leaves another tenant's install stuck in rescue.

**Why (a)**

- **The account lists carry everything refresh observes.**
  - `GET /server` returns `status`, `cancelled`, `ip`, `subnet` and `server_ipv6_net`, and no pagination is documented.
  - `GET /ip` and `GET /subnet` return `server_number` and `locked`, which covers machines whose `server_ip` is null.
- **The mechanism already exists.** The sweep "MUST write what it saw" (01:133), and `DOM-8`'s claim-time check settles every other machine's refresh from that.
- **Tenant cost:** three list reads per window per account. At most `STO-55`'s worker count can race before the first success lands. Neither depends on N or on the counting scope.
- **What remains:** while a list read fails, stale refreshes re-read `GET /server`, the sweep's own endpoint. Close tenant reads on `403` (`ADR-0036`'s shape) only if live testing shows requests after a `403` move Robot's window.
- **Not (b):** W would have to grow with the fleet (W ≥ 18N s).
- **Not (c), for now:** the `403`'s `interval` is the window's length, not the time left, and it arrives after the system read has already failed.

**Strongest "don't build":** if Robot counts per server, nothing breaks, and every harm is a delay that resolution recovers from. My answer: (a) is one sentence that holds whatever the counting rule, while settling the scope needs live counting.

**Defects**

1. 08:414 records only "cancellation is documented at 200 per hour". It leaves out `GET /server`, `GET /server/{n}`, `POST /reset` (50) and `/key`.
2. 08:416-418: the `[verify]` question covers orders only. It doesn't ask per-template versus per-server.
3. `ADR-0034`:78-79 lists "Robot's per-endpoint limits beyond orders" as not covered; Q20 closes this.
4. 01:149 and `ADR-0034`:94 bound the failure loop "against the tenant share", but after Q19 there is no share. 01:145 still says "subject to `PRV-46`".
5. Q19 isn't applied at `16f9db8` (02:1051, 00:382-383, `ADR-0034`:71, 10:3304). Q20 must not cite those lines.
6. Brief: there is no `PRV-50`. The owner is `PRV-5` (02:50).

**Edits**

- **`DOM-8`:** "On a driver whose account listing carries the observation, a stale refresh reads the listing and records every listed machine as `OPS-32` records a present one. A machine missing from it takes `OPS-32`'s direct read. A listing absence never writes gone. No listing write lands on a machine recorded gone or replaces a newer observation."
- **`PRV-35`:** Robot reads `locked` from `GET /ip` and `/subnet`, matched by `server_number`.
- **08:** a per-endpoint limits table and the extended `[verify]`.
- **`ADR-0034` Q20 amendment:** close "Not covered here" and record (b) and (c) as rejected.
- **Alarm:** `rate_limited` on a system read raises an alarm naming the account.
- **Lean** (`ProviderTraffic.lean`:47-70):
  - Add a fleet layer over `Cache` where one list read sets every listed machine, so the existing theorems keep proving.
  - Prove one list read per window for any N and any serial claim order.
  - Prove that absence from the list leaves gone-state unchanged.
  - Negative control: per-machine reads cost N.
- **CNF:** N machines with N·3600/W > 200 refresh inside one window.
  - Assert one read each of `GET /server`, `/ip` and `/subnet` when claims are serial (at most the worker count when concurrent), and zero `GET /server/{n}` for listed machines.
  - Assert `state_observed_at` equals the instant of the list read.
  - Assert a machine missing from the list gets one direct read and no gone-write from the list.
