**Verdict:** (a), plus (b)'s alarm on the sweep only; not (c). Two conditions: the repairs below land first, and one live probe runs. If refused reads delay Robot's recovery, a `PRV-40`-shaped closure on the `/server` reads is pre-committed.

**Facts checked.** Live lines 19–26 and 32–39 hold. Corrections:
- **Recovery timing:** it falls in (16:57:12, 17:02:12]. That fits a fixed window from 15:58:53. It fits a rolling window equally well if the ready-polls before 16:02 aged out. So "403'd requests did not extend it" is not shown.
- **Blind duration:** "Up to an hour" holds for one burst. A consumer that keeps reading blinds the sweep indefinitely.
- **`/boot`:** a separate counter is shown only for `GET /boot/{n}/rescue` (live:24).
- **Creates:** orders are 20/day *per channel* (`02-provider-contract.md:1082-1083`). A create polls the transaction endpoint (`08-provider-notes.md:122-123`), which nobody probed during the block. "One read per create" is `[verify]`.
- **The cancel:** `reserve_location` is not logged on the no-pre-read cancel (live:25).

**Tenant paths.** Your reading fails in four places. The harm crosses tenants: tenant A blinds the counter, tenant B's read-back fails, and B is metered to the end of the Berlin day.
1. **Equal window and interval.** `DOM-8` allows a window equal to the sweep interval: "no shorter than" (`01-domain-model.md:143-144`). Each pass writes after its list returns, so every row is briefly stale once per pass, and a looping refresh reads in that gap. At a 60 s interval that is up to 60 reads/h per looping machine, plus the sweep's own 60. About three tenants exhaust the counter while the sweep "succeeds". `ADR-0034:147-148`'s "at no provider call whatever the fleet size" fails at equality.
2. **Opportunistic reads.** `PRV-12` says get-machine "is called opportunistically after other actions" (`02-provider-contract.md:170-171`). `DOM-8`'s window doesn't cover these calls. Each power or rDNS action can therefore add a `/server` read, capped only per principal, and "Fresh tenants defeat shares" (`ADR-0034:63`).
3. **Q10's failed-read loop.** `ADR-0034:92-95` accepted this loop "from the tenant share" (`01-domain-model.md:152-154`). Q19 deferred that share, so on Robot the loop spends the account's counter. If Robot counts refused requests in a rolling window, one looping machine keeps an outside burst's blind open indefinitely. This is what the probe has to settle.
4. **Attachment visits.** `OPS-32` visits attachments of "every machine still retained by `STO-18`, including a machine already recorded gone" (`03-operation-lifecycle.md:1392-1393`), and names no Robot endpoint. I read that as every non-tombstoned machine on every pass. If it maps to `GET /server/{n}` at a 60 s interval, the sweep alone exhausts the counter at three machines.

Read-backs, sweep re-reads and `OPS-27` reads cost one per mutation or candidate, so they are bounded.

**What else a blinded sweep breaks**
- `LDG-74` already concedes the tail is "not a wall-clock maximum when the sweep yields to `rate_limited`" (`12-billing-and-ledger.md:587-589`). The stored date caps a cancelled machine's meter. A machine Hetzner terminated has no cap.
- `STO-18` and Q26's guard fail safe: the key stays, and that caller's next create is refused before any money moves. `PRV-49` is not enabled.
- Operator money is exposed in two places: a lost-reply cancel waiting for its `OPS-27` read, and late machines `OPS-32` cannot report.

**"The cancel is not blocked"** changes the delete path, not Q23a. `08-provider-notes.md:418` still plans a `GET /server/{id}/cancellation` pre-read, and that read was refused (live:22). With the pre-read, a funding or exhaustion delete during a block fails before acceptance. `OPS-48` then applies: "A throttle refusing the mutation before acceptance is `failed` and stalls the episode" (`03-operation-lifecycle.md:1121-1122`). The machine bills the operator until someone looks.

**First principles:** anyone exhausting the counter from outside provisiond holds the account's credential, and can already POST a cancellation on every server. Leaving leak 3 aside until the probe answers, this is the operator's own estate harming itself, not a tenant threat.

**Edits**
- **Delete path** (`08-provider-notes.md:418,436`, `provider-verify-2026-10.md:696-709`, `ADR-0034:174-176`): Robot's delete posts `cancellation_date=now&reserve_location=false` with no pre-read. This was observed with `reservation_possible: false`; the reservation-possible branch stays `[verify]`.
- **Counter facts** (`08-provider-notes.md:459-475`): `GET /server`, `/server/{n}` and `/server/{n}/cancellation` share one counter across servers. One user and one IP were used, so whether the scope is the account, the user or the IP is not separated. The POST cancel, `GET /ip` and `GET /boot/{n}/rescue` were unaffected. Window shape and whether refused requests count are `[verify]`.
- **`DOM-8` and `ADR-0034` Q20:** the window must be longer than the sweep interval plus the provider-call deadline. That closes the per-pass gap.
- **`PRV-12`:** an opportunistic read takes `DOM-8`'s freshness check.
- **Attachments (`OPS-32` and 08):** Robot lists and gets attachments via `GET /ip` and `GET /subnet`, never `/server/{n}`. Both carry the server association (live:23, `provider-verify-2026-10.md:597-599`).
- **Alarm (`OPS-32:1447`):** a pass that yields to `rate_limited` raises a monitorable alarm naming the account, like `PRV-40` and `CNF-353`. Add one CNF.
- **`ADR-0037`:** amend Q23a's last bullet with the above. The probe: read every 10 s through a block and see whether recovery moves.

**Strongest "don't build":** a local `/server` read budget. Q19 already said "A local count cannot hold a reserve", and outside consumers make any local count blind. Option (c) funds a tail the stored date already caps.

*Disclosure: a grep for runner logs printed fragments of other reviewers' files. I found the pre-read problem before that grep, and I opened none of their files.* No tracked files were edited. A backup copy of this review is at `.scratch-q23a-review.md`, untracked. I did not run the gates.
