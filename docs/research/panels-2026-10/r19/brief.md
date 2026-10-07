# Panel brief: a threat model for provider billing rounding and shared provider budgets (2026-10-06)

You are one of four independent reviewers. The working directory is a throwaway clone of the
specification repository `provisiond-spec` at commit `40c00cb` (numbered Markdown requirements,
ADRs in `docs/adr/`, glossary `CONTEXT.md`, Lean in `tools/formal/`, beads readable with
`br show <id>` if `br` is on PATH). Read `AGENTS.md` first. Do not edit tracked files; you may
write scratch files, run arithmetic (python3), and fetch public provider documentation to test a
claim. Search the Markdown with whitespace normalised. This owner repeatedly shows my framing wrong
with a first-principles question and dissolves machinery rather than tuning it; check this framing
too, and verify every fact I state below before relying on it.

## How we got here

A previous four-reader round (`/var/tmp/provisiond-panel-r19/r18-synthesis.md`, read it) asked who
pays the rest of a provider's started billing unit when a machine leaves billable (Hetzner Cloud and
Robot round partial hours up; DigitalOcean bills per second with a 60 s / $0.01 floor). All four
said **A: the operator absorbs it; the customer keeps exact elapsed seconds**, and rejected charging
the remainder at every exit (unknown provider grid, monthly cap, breaks quarantine/outage/provider-
terminated exits, contradicts `ADR-0011`'s 2026-10-03 exit closure and four Lean declarations).
Treat that rejection of "remainder at every exit" as settled unless the threat model below changes
an argument it rested on.

The owner then refused A as stated: "I don't think we can just absorb the loss without a good threat
model. for instance, could an adversary make us lose money or cause a denial of service?" Your job is
that threat model and its mitigations.

## My draft threat model (check every line)

**Attacker.** Anonymous (`ADR-0005`), self-serve. Funds one tenant with `API-35`'s minimum
cumulative credit; the balance cannot be withdrawn (`ADR-0004`) but stays spendable. Loops: create a
machine, delete it as soon as it is billable, repeat.

- **M1 — money amplification (caused by A).** Per cycle the operator pays one provider unit `U·p`
  and the customer pays `(1+m)·t·p` for lifetime `t`. At `t` = 1 minute and `m` = 20% the attacker
  pays about 2% of what the operator loses: every satoshi deposited can cost the operator ~49. Live
  Hetzner Cloud prices (read-only `GET /v1/server_types`, today, net per hour): cheapest `cpx11`
  €0.0096–0.0328, dearest `ccx63` €1.61–1.96, so about €1.60 lost per one-minute cycle on `ccx63`.
  Rate bounds: `SEC-39`'s per-principal "machines created per interval" ceiling, a "stated integer"
  with no default, multiplied by tenants; and the provider API limit (D2).
- **D1 — Robot order budget exhaustion.** `PRV-40`: 20 orders/day per order endpoint, "shared
  across every tenant"; the deployment refuses creates once spent. Nothing allocates it per tenant;
  `SEC-31`/`OPS-24` fairness covers the queue, not this budget. Even at a full hour per order the
  attacker denies every Robot sale for a day for about €1.60.
- **D2 — Hetzner Cloud API rate limit.** Hetzner Cloud's OpenAPI (`https://docs.hetzner.cloud/
  cloud.spec.json`, `info.description`, "Rate Limiting"): "The default limit is 3600 requests per hour
  and per Project." Churn spends it; nothing in the set counts it. Exhaustion `429`s every tenant and
  also the operator's own exhaustion-sweep deletes and reconciliation reads, so funded-out machines
  keep running on the operator's money.
- **D3 — account resource limit.** Same document: `403 resource_limit_exceeded`, "Error when
  exceeding the maximum quantity of a resource for an account." Held machines (paid at list + margin)
  fill it and every other tenant's create fails.
- **D4 — provider abuse action on the whole account.** Rapid create/delete resembles IP cycling;
  whether Hetzner acts on it is undocumented. `SEC-41`: an account-level action "darkens every machine
  in the account" (check the exact words).

## Mitigations on the table

- **For M1: a minimum charge of one provider unit per machine** — a machine whose billable life is
  shorter than one unit pays the shortfall, at the customer rate, in the exit's closing increment;
  longer lives keep exact seconds (their end remainder stays operator-absorbed, and exploiting it
  requires living past `U/(1+m)`, where margin covers it). Claimed grid-independent: under any
  provider grid a sub-unit machine costs the operator at least one unit. Two r18 readers called any
  minimum "the shape `ADR-0011` rejected" ("overcharges partial use"); one said a provider-unit
  minimum differs from the meter-interval minimum it rejected.
- **For M1, alternative: A + a mandatory default for `SEC-39`'s create ceiling.** Caps rate, keeps
  the ratio.
- **For D1–D3: per-tenant shares of shared provider budgets**, or reserving part of each budget for
  the operator's own destructive and reconciliation paths. Not yet designed.

## What I want from you

1. **Verify the threat model.** Is each threat real in this set as written? Cite lines. Correct my
   arithmetic, including the shortest achievable billable life (where does billable start and end —
   `LDG-38`'s seed, `LDG-74`), and what the attacker's capital really is (is a commitment the size of
   a full reserve tied up per concurrent machine? does it bound concurrency?).
2. **Find the threats I missed.** Think as the attacker against this specific set: other loops
   (`SEC-39`'s other ceilings — installs, rescue entries, power cycles, image writes; attachments;
   creates that land in `needs_reconciliation` and consume `OPS-33` windows or operator attention;
   enrolment `API-41`; deposits/Lightning; abuse that gets the operator's provider account locked —
   `SEC-43`/`SEC-44`). Separate "attacker spends their money to hurt the operator" from "attacker
   spends little to deny others". Name what already defends each one, with the requirement's words.
3. **Rank** every threat by (cost to operator or other tenants) ÷ (cost to attacker), and say which
   exist today regardless of the billing decision.
4. **For each threat worth acting on, the smallest mitigation** that closes or bounds it, what it
   breaks (ADRs, Lean declarations in `tools/formal/`, decided exits), and whether it is per-tenant,
   per-deployment or per-provider-account. Prefer a mitigation that already has a home in the set.
5. **M1 specifically:** minimum charge vs A + ceiling vs a named other. Is the minimum really
   grid-independent (wall-clock grid, month boundary, monthly cap, DigitalOcean's money floor)? Does
   it conflict with `ADR-0011`'s recorded reasons, `Funding.lifecycle_coverage`,
   `Witnesses.exit_closes_each_tail`, `LDG-38`'s seed rule? Can an attacker steer into an exit where
   it degrades to A (quarantine, outage, provider-terminated)?
6. **Argue the strongest "don't build this"** for the whole set of mitigations: which threats are
   better handled by stated deployment parameters, terms of service, or an operator alarm than by
   new mechanism?

## Output

At most 1200 words, no preamble: a threat table (id, one-line story, attacker cost, victim cost,
exists today?, severity); missing threats; per-threat recommended mitigation with the requirement
ids it edits; your M1 verdict in one line; every defect in my framing with `file:line`.
