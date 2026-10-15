# Panel brief: Q23a after Robot's server-read counter proved account-wide (grill Q6), 2026-10-12

You are one of four independent reviewers. The working directory is a throwaway clone of the
specification repository `provisiond-spec` at master `935b316` (PR #2 merged). Read `AGENTS.md` first. Do
not edit tracked files; write scratch files only inside this clone (never `/tmp`); you may run the gates
(`nix develop --command bash tools/check-all.sh`, unpiped). Search the Markdown with whitespace normalised.
This owner repeatedly shows my framing wrong with a first-principles question and dissolves machinery rather
than tuning it; check this framing too, and verify every fact I state. The owner rejects absorbing an
operator loss without a threat model.

## New live facts (2026-10-12, `docs/research/panels-2026-10/r45/live-session2.txt`; read it)

On a real Robot account (one test auction server plus one unrelated pre-existing production server):
- After ~200 `GET /server/{test}` in an hour, Robot answered `403 RATE_LIMIT_EXCEEDED` (`max_requests
  200, interval 3600`) to `GET /server/{test}`, to `GET /server/{other server}`, to `GET /server` (the
  account list) and to `GET /server/{test}/cancellation`. `GET /ip` and `GET /boot/{n}/rescue` still
  answered `200`. `POST /server/{test}/cancellation` (the cancel itself) answered `200`.
- Reads recovered ~1 h after the session's FIRST request; 403'd requests during the block did not extend
  it (a 5-minute read-only probe saw `403` until ~16:57 and `404` at 17:02 for the cancelled server).
- So the `/server` read family shares one counter per account (or per webservice user / source IP —
  not separated; one user and one IP were used), not per server. The cancel mutation is not blocked.
- Other session facts (rescue host keys only in `/rescue/last` after boot; duplicate-key 409; rescue
  accepts password login) are in `docs/research/panels-2026-10/r45/decisions-q27-q28.md` and the live file; not this
  question.

## Context to read

ADR-0037 whole, especially the Q22 and Q23a amendments (Q23a: "A tenant can induce a failed read only if
Robot's server-read counter is shared, which is unverified and settled by the live test. If it is shared,
this is revisited."). ADR-0034's Q20 and Q20b amendments (refresh answered from the account sweep; the
window no shorter than the sweep interval; Robot reset limit alarmed). `PRV-13` (the read-back after a
dated cancel), `OPS-32`, `DOM-8`, `LDG-74`, `LDG-31`, `LDG-66`, and 08-provider-notes' Robot limits table.

## The question

Q23a accepted, with a threat model, the tail after a failed cancellation read-back (customer metered to the
sweep or the stored date's end; an uncollectable `clamp_overflow` on a destroyed server, not operator
money). Now the counter is account-wide. My reading: a tenant cannot drive ~200 `/server` reads an hour
through provisiond while the sweep succeeds (refresh is answered from the sweep since Q20; creates/deletes
cost one read each and are capped by 20 orders/day; rescue uses `/boot`, a separate counter), but anything
else on the account (operator tooling, a second deployment, anyone with the webservice user) can exhaust
it, blinding the sweep and the read-back for up to an hour, after which stale refreshes also read and fail.
Options: (a) keep Q23a, record the counter as account-wide and the threat as an outside account user;
(b) (a) plus an alarm whenever a provisiond Robot read is refused `rate_limited`; (c) reopen Q23a and fund
the tail. Check my reading: can a tenant exhaust the counter through any provisiond path (stale-sweep
refresh loops under Q10's "a failed read moves nothing and the next refresh reads again"; OPS-27
resolution reads; delete read-backs; the sweep's own direct re-reads)? Does a blinded sweep break anything
else (LDG-74's billing residual, STO-18 tombstones, Q26's provisioning guard, Q21's precondition)? Does
"the cancel is not blocked" change any decision (OPS-48 stalls, the exhaustion delete)?

## Output

At most 800 words, no preamble: a one-line verdict; why (with the tenant-path analysis); every defect with
`file:line`; the edits; the strongest "don't build".
