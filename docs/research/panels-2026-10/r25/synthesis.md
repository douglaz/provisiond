# Panel r25 synthesis — provider traffic overage (2026-10-07)

Readers: sol, astra (codex xhigh), fable, opus (claude xhigh); clones at ff4b4cc. All exit 0.
Citations verified.

## Verdict: 4–0 against metering bytes (a), charging with margin (b), and accept-and-alarm (d).
## Split 2–2 on what to do instead.

- sol, astra: **sell only offers with no overage liability** — Robot's default 1 Gbit unlimited;
  withhold Hetzner Cloud and DigitalOcean (and Robot 10 Gbit) until a provider-enforced cap or a
  funding design exists. Narrows ADR-0010's launch scope. Reason: a counter read cannot bound a
  prepaid loss — counters have no documented freshness, and usage can outrun the commitment before a
  reading arrives.
- fable, opus: **(c) reshaped — the included allowance is a disclosed loss limit**, shaped like
  LDG-64's rate-outage bound ("The bound is the operator's own loss limit … MUST be disclosed before
  purchase (`WIR-30`'s offer)", 12:1358-1366): each offer declares a `traffic_bound` (`unlimited`, or
  the allowance less headroom); a machine past it gets an exposure-reducing cancellation (a new
  `traffic_allowance` reason beside `rate_outage_bound`); an offer whose residual (egress between the
  last reading and destroy) fails ADR-0033's "priced, not amplified" test is not sold. opus: Singapore
  never passes; EU passes only with a tight sweep or a headroom. Disk destroyed at the bound, or
  power-off plus a refusal of power_on if the owner wants the disk kept.

Reconcilable: opus's eligibility test already excludes any offer whose residual cannot be bounded; the
two camps differ only on whether Cloud/DO counter freshness is good enough today. Unverified: Hetzner
Cloud counter freshness (undocumented); Robot counts "only after disconnecting a TCP connection"
(fable); DigitalOcean per-droplet data is a Mbps time series and its allowance is pooled per team.

## Why (a) died

- Precedent gone: ADR-0033:43 (decided yesterday) — "`ADR-0006`'s at-cost rule is for a fee the
  customer gets nothing for"; the customer receives the bytes. At cost is still "a second thing to
  meter" ADR-0007 rejected.
- Unbuildable on DigitalOcean: pooled allowance ("pooled cumulatively across all Droplets at the team
  level"), per-droplet data only as Mbps; any attribution is a policy.
- The clamp: run the commitment to the floor, then blast; every traffic debit clamps (ADR-0033:57's
  own argument). A reserve cures it only with a byte ceiling, which no provider publishes.
- Source dies with the server: no final reading after the gone-write (ADR-0037).

## Defects in my framing (verified)

1. "No rule on traffic" is wrong: PRV-13b already says "MUST be able to bound its own exposure before
   taking money" — every metered-egress offer breaks it today; 02:193 ("committing the customer price
   also covers the operator's exposure") and 02:374 ("at most `setup_fee + one period cap`") are false
   under overage; SEC-41 already names "egress controls".
2. 1 Gbit/s is not a Hetzner figure: "you can expect about 300-500 Mbits" (no guarantee); a
   third-party benchmark measured cpx11 at ~3 Gbit/s (fable). Both directions uncertain.
3. EU is the mildest case: US locations include at least 1 TB, AP at least 0.5 TB — overage starts
   above ~3.1 Mbit/s (US) and ~1.5 Mbit/s (Singapore) sustained. A small website or a Tor relay
   crosses it; no attacker needed.
4. DigitalOcean: $0.01/GiB, pooled per team, accrued per second; a fresh $4 Droplet contributes
   nothing yet can send 500 GiB in ~72 min (fable: ~500× per cycle). Up to $100–200/day at 1–2 Gbps.
5. Proration and pooling of Hetzner's allowance are undocumented; the invoice is the authority.
6. My $0.28/day for cpx11 was not reproducible from current list prices (sol, astra).

## Edits (union, either branch)

PRV-13b (traffic counts as exposure; qualify 02:193 and 02:374); PRV-44 (`traffic_bound` per offer:
`unlimited` or allowance-with-headroom; PRV-31's "no declared bound MUST NOT be sold on prepaid
terms" carries over); PRV-13c (read allowance and price, never encode); DOM-9/WIR-30 disclosure;
LDG-75 (post-reading egress as an accepted gap); ADR-0010 (scope, if narrowed); 08-provider-notes
facts; CNF items. If (c): OPS-32 records counters; OPS-39/STO-52 reason `traffic_allowance`; LDG-14 a
disclosed trigger; CONTEXT.md (exposure-reducing, not a funding cancellation); Fence.lean `Reason`
gains `trafficAllowance` with an enqueue theorem. If no-exposure only: Admission.purchaseTail refusal.
