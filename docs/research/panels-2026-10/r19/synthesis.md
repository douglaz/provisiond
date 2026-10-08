# Panel r19 synthesis — threat model for provider rounding and shared provider budgets (2026-10-06)

Readers: sol, astra (codex xhigh, first run); fable, opus (claude xhigh, relaunched 16:52 after a
session-limit failure). Clones at 40c00cb. Brief: brief.md. Citations below verified against files.

## M1 (money amplification under A) — split 2–2

- **sol, astra: A + an aggregate exposure budget per provider account** (+ SEC-39 per-principal
  ceiling). The minimum is "an incomplete cure": not grid-independent cost recovery (wall-clock or
  month boundary → two units; 61 min costs 2p, earns 1.22p), reopens pricing/reserve/exceptions.
- **fable: charge the first provider unit when the order lands** (LDG-39's lifecycle, like the setup
  fee); per-offer `{seconds, native_floor}` in PRV-44; reserve term in PRV-13b; PRV-13d floor ≥ unit;
  LDG-38 seeds at the unit's end. No exit can degrade it (debited at acceptance).
- **opus: a minimum per machine, at cost, as its own entry kind, reserved in PRV-13b.** Without the
  reserve term it is A again: at the runway floor the commitment can be < one unit and LDG-31's clamp
  turns the minimum into an operator deficiency, a path the attacker can choose.
- Ratio verified: (U − (1+m)t)/((1+m)t) = 49 at 60 s, ≈300 at 10 s (m = 20%); t can be seconds
  (seed at "first write that records it billable", 12:862; exit at the recorded instant, 12:879).
- Precedent both minimum-readers cite: LDG-39 (12:1096-1098) refused a reversible setup-fee
  reservation because "a create-then-delete cycle costs the tenant nothing and the operator the whole
  fee"; ADR-0011 itself notes the free tail "permits create-and-delete within an interval".
- My synthesis point: an aggregate exposure budget is itself a shared budget — exhausting it refuses
  every tenant's create (astra: "accept reduced admission under attack"), i.e. it converts M1 into a
  D-class denial. A minimum leaves nothing shared to exhaust.

## Pre-existing defects found (independent of the M1 decision)

- **D2r (all four; opus "cannot wait"):** `refresh` / reverse-DNS loop on one machine. No commitment
  (04:247), not on SEC-39's list (07:209-214; Admission.lean:233 maps them to []), API-29 per-tenant
  limit only SHOULD (04:1154). Drains Hetzner Cloud's 3600 req/h per Project. A throttled delete is
  `failed`, "nothing in this set returns it to `queued`", episode stalls for an operator (03:1064-1070);
  an interrupted sweep records no absence (03:1292-1296). Funded-out machines keep billing the operator.
- **T1/R1 (fable, opus):** a 429 on the poll after an accepted order is a 4xx, not on OPS-11's
  ambiguity list (03:248-256; PRV-11 covers only a poll *timeout*) → create `failed`, commitment
  released, machine alive. F48 (11:139-148) concedes "every operation is several requests" and no
  requirement obliges the driver to report whether a mutating request was sent.
- **Sybil price unregistered (fable, opus):** API-35's "configured minimum" has no number and is absent
  from OVR-19 (00:350-400); every per-principal ceiling multiplies by it.
- **D1 (all):** PRV-40 says "the whole deployment" (02:879) while OVR-19 says "per ordering account"
  (00:380); whether provider-rejected orders count against the 20/day is [verify] (opus).
- **X2 (astra only, unverified):** provider traffic overage on included-traffic products is unmetered.
- **D5 (fable, conditional):** long free installs can occupy every engine worker; OPS-24 fairness SHOULD.
- **D3:** resource limit is per Hetzner *customer*, rate limit per *project* (opus) → SEC-43's
  separate accounts must be separate customers. Mitigation: alarm + limit request (all).
- **D4:** owned by SEC-41/43/44/45; churn-specific trigger unproven (all).

## Mitigations proposed (convergent)

- D2r: add refresh + reverse-DNS to SEC-39; PRV-44 `request_budget {limit, per}` per account/project,
  spent before any provider call, with stated headroom (OVR-19) for system cancellations (OPS-39),
  resolution (OPS-27) and the sweep (OPS-32). (opus, fable, sol, astra)
- T1: OPS-11 create row / PRV-5: a throttle after the operation's mutating request was sent is
  ambiguous (needs_reconciliation), never `rate_limited`. (fable, opus)
- D1: PRV-40 per ordering account; count rejected requests; operator reserve; per-tenant share sized
  together with API-35's minimum — or alarm only until there is Robot demand (opus "don't build").
- D3/D4/D5: no new mechanism; alarms, SEC-41 recorded risk, OPS-24 SHOULD→MUST only if hold confirmed.

## Defects in my framing (all verified)

1. SEC-41 does not say "darkens every machine" — that is 01:324 (DOM-27 text); SEC-41 says "one
   abusive tenant can terminate every tenant" (07:177).
2. "Past U/(1+m), margin covers it" is false: 61 min costs 2 units vs 1.22 paid; guaranteed only past 1/m.
3. t = 1 minute is not a floor; seconds are reachable (ratio ≈300).
4. Prices were USD (account currency, `GET /v1/pricing` → `USD`), not EUR.
5. D1's €1.60 is the operator's cost; the attacker pays seconds or nothing.
6. D2's bucket replenishes 1/s (not an hour lockout); `refresh` drains it more cheaply than churn.
7. SEC-39's interval has a default (one hour); only the integers lack one.
