**Verdict:** (b), narrowed: keep Q23a's tail, record the counter as shared and the threat as an outside consumer of the credential, take the cancellation pre-read off the delete path, require the refresh window to be at least twice the sweep interval, and put one Robot-403 alarm in `PRV-5`. Do not fund the tail. Gate at `935b316`: all pass, exit 0.

**Facts checked.** Every live fact holds. Two qualifications. The recovery data fits a fixed window from the first request and a sliding one equally well, since the 199-read loop ran 16:05 to 16:06 and the slots from 15:58 to 16:02 expiring by 17:02 also explains the 404. Record the bound as "blind for at most one interval after the first counted read", which holds either way. The cancel's parameters are not in the summary. I assume batch B step 9's `cancellation_date=now&reserve_location=false`.

**Tenant paths, reads per hour on the shared counter:**
- Refresh. Your "zero while the sweep succeeds" is true only when the window exceeds the interval plus a pass duration. `DOM-8` allows a window equal to the interval and calls an observation "at or beyond the window" stale (`01-domain-model.md:146-147`). Any pass landing a second late reopens one read per machine per window: 3600/W per looping machine. At a 5-minute window, 17 paid machines exhaust the counter. At 60 seconds, four.
- Create. One confirming read (`03-operation-lifecycle.md:494-497`). Retries only on `not_found` inside the window, which Robot rarely produces: `ready` and `200` landed in the same second. Capped at 20 orders a day per channel.
- Delete. Two shared reads on the planned path: the pre-read of `GET /server/{n}/cancellation`, which the live test shows is on the same counter, plus `PRV-13`'s read-back. Bounded by machines held and `SEC-39`'s destruction ceiling, not by orders a day. 100 held machines deleted in one hour blind the account once. The order cap stops it being sustained.
- Resolution reads and sweep re-reads are bounded by creates and by machines missing from the list. A tenant multiplies neither.
- Rescue, power and reverse-DNS use `/boot`, `/reset` and the rDNS endpoints. Only `PRV-12`'s "called opportunistically after other actions" (`02-provider-contract.md:170-171`) could put them on `/server`. It is a MAY.
- Blind-hour refresh loops cost nothing. Rejected requests did not delay recovery under either window model.

**A blinded hour breaks nothing else, with one exception:**
- `LDG-74`'s residual grows by at most interval plus sweep, and `12-billing-and-ledger.md:586-589` already says the interval "is not a wall-clock maximum when the sweep yields to `rate_limited`". Metered, not provider-billed. On an exhausted commitment it is `clamp_overflow`. Q23a's threat model stands: Robot still destroyed at +1 s.
- `STO-18` and `LDG-32` wait, because the attachment observation needs "a complete account pass" (`03-operation-lifecycle.md:1394-1396`). No money moves.
- Q26's guard clears on any observation, so keys linger an hour. Q21's precondition is unbuilt.
- The exhaustion delete lands: `POST` answered 200 while every `/server` GET was 403. The failed read-back settles scheduled with its fence, `LDG-62` stays refused, the machine is gone. The exception is the pre-read: a 403 before acceptance is `failed` and "stalls the episode" (`03-operation-lifecycle.md:1121-1122`), leaving the machine billing the operator until an operator retries. That is the only place a blinded counter reaches operator money, and the live test removes it.
- A throttled `POST`, on its own 200 an hour, still stalls. Same threat, pre-existing residual, now alarmed.

The realistic threat is sustained, not an hour: a dashboard polling `/server` every 15 seconds spends 240 an hour. Then every read-back fails, every `now` cancellation meters to the Berlin day's end, and `LDG-74` never fires for a terminated machine. Nothing today tells the operator. The alarm is the one control that names the cause.

**Defects:**
- `08-provider-notes.md:418` and `docs/research/provider-verify-2026-10.md:697-703`: the pre-read is still the planned path. Answered 2026-10-12.
- `01-domain-model.md:143-147` and `docs/adr/0034-…md:146-149`: a window equal to the interval reopens one read per machine per window.
- `08-provider-notes.md:462,471`: the `/cancellation` GET row shares the `/server` read counter. The `[verify]` is partly answered: shared across server numbers and across `GET /server`, `/server/{n}`, `/server/{n}/cancellation`; `GET /ip`, `GET /boot/{n}/rescue` and `POST …/cancellation` separate; account versus webservice user versus IP not separated.
- `docs/adr/0037-…md:248-249`: the Q23a conditional is now true and owes its revisit in writing.
- `docs/adr/0034-…md:94-95`: "against the tenant share, never the reserve". No reserve exists under Q19, and on Robot a refused read spends nothing.
- `docs/adr/0034-…md:174-176`: Q20b's "the live test also checks" is answered.

**Edits:**
- Robot driver, under `PRV-13`: no `GET /server/{n}/cancellation` before a cancel; send `reserve_location=false` explicitly; the reservation-possible branch stays `[verify]`. Update the 08 row, batch B step 9 and ADR-0034's Q20b note.
- `DOM-8`: "no shorter than twice the account-sweep interval"; startup refuses less. One late pass then costs no read. Note it under ADR-0034 Q20.
- `PRV-5` (`02-provider-contract.md:50`): every Robot `403 RATE_LIMIT_EXCEEDED` raises the monitorable alarm naming the account and path. `PRV-40`'s and `PRV-22`'s alarms become citations of it. Three alarms become one rule.
- `PRV-12`, Robot: no opportunistic `/server` read after power, rescue or rDNS. The sweep observes.
- ADR-0037, a dated Q23a amendment: counter shared; tenant paths as above; threat is an outside consumer of the credential; the tail stays accepted; `LDG-74` and `PRV-13` unchanged.
- Next live step, read-only and free: a second `#ws+` user on the account; exhaust with one, probe with the other. If the counter is per user, the outside-consumer threat dissolves into "provisiond's credential is used by nothing else".

**Don't build:** a local read budget or reserve. ADR-0034 Q19 already found "A local count cannot hold a reserve" against traffic outside provisiond, and this counter is exactly that case. Nor (c): funding the tail holds back every Robot customer's runway for a charge on a destroyed machine, and nothing learned today changes Q23a's threat model. Robot still destroys at +1 s, and the cancel still lands.
