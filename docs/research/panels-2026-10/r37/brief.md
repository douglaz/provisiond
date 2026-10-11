# Panel brief: Robot's per-endpoint request limits in v1 (Q20), 2026-10-10

You are one of four independent reviewers. The working directory is a throwaway clone of the
specification repository `provisiond-spec` at commit `16f9db8` (branch `pv-ucs-impl`). Read `AGENTS.md`
first. Do not edit tracked files; write scratch files only inside this clone (never `/tmp`); you may run
the gates (`nix develop --command bash tools/check-all.sh`, unpiped). Search the Markdown with
whitespace normalised. This owner repeatedly shows my framing wrong with a first-principles question and
dissolves machinery rather than tuning it; check this framing too, and verify every fact I state.

## Context

Read `docs/research/panels-2026-10/r36/synthesis.md` and the owner's decision
`docs/research/panels-2026-10/r37/q19.txt`: `ADR-0034` Decision 3 (a declared request budget with a system
reserve) is DEFERRED until a shared-bucket (Cloud) offer is sellable; Decisions 1-2 and Q10 stay (refresh
answered from cache inside `OVR-19`'s freshness window, counting successful observations only; a
reverse-DNS ceiling). Do not propose rebuilding a generic budget. v1 sells only Robot offers
(`ADR-0039`). Robot's order endpoints are `PRV-40`/`ADR-0036`'s (20 per day, closed by Robot's own
`403 RATE_LIMIT_EXCEEDED`). `ADR-0034` lists "Robot's per-endpoint limits beyond orders" as "Not covered
here".

Robot's webservice reference (https://robot.hetzner.com/doc/webservice/en.html, retrieved 2026-10-10)
gives per-endpoint limits, among them: `GET /server`, `GET /server/{server-number}`, `POST
/server/{server-number}`, `GET`/`POST`/`DELETE /server/{server-number}/cancellation`: "200 requests per
1 hour"; `GET /order/server*/transaction*`: 500/hour; `/boot/...` rescue and linux: 500/hour; `POST
/reset/{server-number}`: "50 requests per hour"; `GET /ip`, `GET /ip/{ip}`: 5000/hour;
`/ip/{ip}/cancellation`: 200/hour. Exceeding answers `403` `RATE_LIMIT_EXCEEDED` (`PRV-50`... check the
owner; `02-provider-contract.md:50` maps it to `rate_limited`). Verify whether a limit is per webservice
user, per account or per source IP.

opus (r36) found: at a 60-second freshness window one machine's refresh loop costs up to 60
`GET /server/{n}` reads an hour, so four machines' loops exceed 200, and the system's own direct reads
(`OPS-32`'s sweep re-read, `PRV-42`'s confirmation read, `OPS-27` resolution) use the same endpoint.

## Questions

1. **The traffic map.** For v1 on Robot, which provisiond paths spend which endpoint (refresh, create
   and its resolution, delete including the pre-read of `GET /server/{n}/cancellation` for
   `reserve_location`, the account sweep, rescue/install `RSC-*` including resets, attachment release,
   reverse-DNS)? Which can a tenant drive repeatedly, and which does the system need to reduce exposure
   or gather evidence?
2. **Is the threat real?** Can one tenant, or several, exhaust an endpoint a system path needs? At what
   cost to the attacker (each machine is a paid Robot server; machine count grows at most at the order
   budget)? Include `POST /reset` at 50/hour if any tenant verb reaches it.
3. **The smallest shape that protects the system path**, if one is needed. Candidates, none preferred:
   (a) answer refresh from one account-wide `GET /server` list per window, shared by every machine, so
   tenant reads cost at most one list per window whatever the machine count (does that list carry what
   a refresh must observe?); (b) a per-driver freshness window sized against the limit; (c) close
   tenant-driven reads of an endpoint on Robot's own `403` until its interval passes (`ADR-0036`'s shape);
   (d) accept the residual as priced to the attacker and alarmed. Or something smaller.
4. The strongest "don't build this", and what the Lean model and CNF items must show for your answer.

## Output

At most 900 words, no preamble: a one-line verdict; the traffic map (compact); why; every defect with
`file:line`; the edits.
