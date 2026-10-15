# Grill 2026-10-12 (after PR #2): live Robot sessions 2 and 3, owner decisions

Q27 (grill Q5) ACCEPTED 2026-10-12 — Robot rescue host-key pinning:
- Observed (sessions 2/3): the activation response and GET /boot/{n}/rescue carry host_key [] (before
  and after boot); GET /boot/{n}/rescue/last publishes the booted session's host keys (SHA256 base64
  fingerprints, ECDSA/ED25519/RSA) with boot_time, available by the time port 22 opens (~60 s after
  the reset); they matched SSH exactly; whether keys are fresh per boot is unverified (`ADR-0041`); the activation is
  consumed at boot (active -> false within 30 s).
- Rule: the Robot driver's begin-rescue returns no host keys; PRV-19 refresh reads the last-rescue
  record and populates host keys only when its boot_time is later than the session's reset; connect
  only to a server presenting a key with one of those SHA256 fingerprints; keys absent within the
  deadline fail closed — never first-use trust on Robot. 08-provider-notes' "published in the rescue
  activation response and in a 'last rescue' lookup [observed]" is corrected.

Q28 (grill Q6) ACCEPTED 2026-10-12 — Q23a revisited after the shared read counter (panel r45, 4 readers):
- Observed (session 2): ~200 GET /server/{n} in an hour -> 403 RATE_LIMIT_EXCEEDED (max_requests 200,
  interval 3600) also for another server, GET /server and GET /server/{n}/cancellation; GET /ip and
  GET /boot/{n}/rescue unaffected; POST /server/{n}/cancellation accepted (200); reads recovered ~1 h after
  the first request (recovery between 16:57 and 17:02; fixed vs rolling window not separated; refused
  requests did not visibly extend this block). One user, one IP: account vs IP scope not separated (Robot
  documents a single webservice user per account, so user == account in practice).
- Q23a's money decision STANDS (no funding of the tail; no local read budget/reserve). Its threat-model
  text is rewritten: the counter is account-wide across the /server read family; tenants can contribute via
  refreshes at the sweep boundary (window == interval), opportunistic reads after actions, deletes of a held
  fleet (2 shared reads each with the pre-read), and failed-read refresh loops; outside users of the
  credential too; a blind sweep also cannot find an unrecorded running server (operator cost, OPS-33
  release-before-attach) — recorded.
- Repairs: (1) ONE alarm rule: every Robot 403 RATE_LIMIT_EXCEEDED raises a monitorable alarm naming the
  account and request path (home PRV-5; PRV-40's and PRV-22's alarms cite it). (2) Robot delete: no
  GET /server/{n}/cancellation pre-read; POST cancellation_date=now&reserve_location=false; the
  reservation-possible branch stays [verify]. (3) DOM-8: the refresh window MUST be at least twice the
  account-sweep interval (startup refuses less) — ADR-0034 Q20 "at no provider call whatever the fleet
  size" qualified. (4) PRV-12: no opportunistic /server read on Robot outside DOM-8's freshness check.
  (5) OPS-32 on Robot: attachments listed/read via GET /ip and GET /subnet, never GET /server/{n}.
  (6) 08-provider-notes: the limits table and [verify] rows updated with the observed scope.
- Probe: whether the counter is per source IP (a second source address) — checked if free; not blocking.
- PROBE RESULT (session 4, 2026-10-12 19:08Z, read-only): after ~200 IPv4 GET /server, IPv6 GET /server was
  refused at once (403 RATE_LIMIT_EXCEEDED) — the /server read counter is per account (one webservice user),
  NOT per source IP. The baseline IPv6 read counted toward the same 200.
