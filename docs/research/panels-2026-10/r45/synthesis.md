# Panel r45 synthesis — Q23a after Robot's server-read counter proved account-wide (Q28), 2026-10-12

Readers: fable, opus (claude xhigh), astra, sol (codex xhigh); clones at 935b316 (master). All exit 0.
Live records in this directory: `live-session2.txt` (read-limit exhaustion, rescue V10/V11, cancel without
pre-read), `live-session3.txt` (rescue host keys, decided as Q27 → `ADR-0041`), `live-session4.txt`
(IP-scope probe, run after the panel), `rescue-ssh-session2.txt`.

## Agreed (4–0)

- Do not fund Q23a's tail; build no local `/server` read budget or reserve (Q19: "A local count cannot
  hold a reserve").
- The brief's "no tenant path" reading was wrong: refreshes at the sweep boundary (`DOM-8` allows a window
  equal to the interval and calls an observation "at or beyond the window" stale — astra proved 60 reads
  per machine per hour in a scratch Lean probe), `PRV-12`'s opportunistic reads, deletes of a held fleet
  (two shared reads each with the cancellation pre-read; deletes are not capped by the order limit), and
  Q10's failed-read loops.
- **Remove the cancellation pre-read** (`08-provider-notes`): with it, a blinded counter fails an exposure
  delete before acceptance → `OPS-48` stall while the machine bills the operator; the live POST succeeded
  during the block. Post `cancellation_date=now&reserve_location=false`; the reservation-possible branch
  stays unverified.
- **Alarm** a refused Robot read: fable/astra/sol — one rule at `PRV-5` for every Robot `403
  RATE_LIMIT_EXCEEDED`, naming account and path (`PRV-40`/`PRV-22` cite it); opus — on a sweep pass that
  yields to `rate_limited`.
- "Up to an hour" bounds one burst only; a sustained outside reader blinds the sweep indefinitely
  (`LDG-74` already says the interval "is not a wall-clock maximum").

## Also (2–3 readers)

- Window strictly longer than the interval: at least twice it (fable) or interval plus the provider-call
  deadline (opus); astra qualifies `ADR-0034`'s "at no provider call whatever the fleet size".
- No opportunistic `/server` read on Robot outside `DOM-8`'s check (fable, opus).
- Robot attachments via `GET /ip` and `GET /subnet`, never `/server/{n}` (opus).
- A blind sweep cannot find an unrecorded running server — operator cost after `OPS-33`'s release (sol);
  reassess `PRV-49`'s "no adversary can cause" before relying on sweep discovery for survivors.
- Recovery timing fits a fixed or a rolling window; whether refused requests count is not shown (fable,
  opus). Per user versus per IP: a second webservice user is not documented (the owner questioned it); the
  per-IP question was then probed over IPv6 — refused at once, so the counter is per account.

Owner decision Q28 (`ADR-0037`'s amendment of 2026-10-12): Q23a's money decision stands; threat model
restated; no pre-read; one alarm rule at `PRV-5`; window ≥ 2× the sweep interval; no opportunistic Robot
reads; Robot attachments via `/ip` and `/subnet`.
