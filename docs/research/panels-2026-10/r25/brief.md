# Panel brief: provider traffic overage (2026-10-07)

You are one of four independent reviewers. The working directory is a throwaway clone of the
specification repository `provisiond-spec` at commit `ff4b4cc` (numbered Markdown requirements, ADRs
in `docs/adr/`, glossary `CONTEXT.md`, Lean in `tools/formal/`). Read `AGENTS.md` first. Do not edit
tracked files; you may write scratch files, run arithmetic and the gates, and fetch public provider
documentation. Search the Markdown with whitespace normalised. This owner repeatedly shows my framing
wrong with a first-principles question and dissolves machinery rather than tuning it; check this
framing too, and verify every fact I state before relying on it.

Settled today (do not re-litigate): ADR-0033 (first billing unit prepaid at the customer rate),
ADR-0034 (request budget with system reserve), ADR-0035, ADR-0036, ADR-0037 (wind-down sized to the
gone-write), ADR-0038. Threat-model context: `/var/tmp/provisiond-panel-r19/synthesis.md` (X2).

## The threat

- Hetzner Cloud billing FAQ (https://docs.hetzner.com/cloud/billing/faq): "We only bill for outgoing
  traffic"; "If you exceed the traffic included in your package, we will bill you for the over-usage
  in blocks of 100MB"; notifications at 75% and 100%, and "Any traffic used beyond the included amount
  is billed as usual, even if a notification reaches you late or does not arrive at all".
- Live account pricing (`GET /v1/pricing`, read-only, today; account currency USD): `cpx11` and `cx23`
  include 21990232555520 bytes (20 TiB) per month in fsn1/nbg1/hel1 at `price_per_tb_traffic` 1.20;
  `ccx63` in `ash` includes 8 TiB. Server object: `outgoing_traffic` "Outbound Traffic for the current
  billing period in bytes", `included_traffic` "Free Traffic for the current billing period in bytes".
- Hetzner Robot traffic page (https://docs.hetzner.com/robot/general/traffic/): "All root servers have
  a dedicated 1 GBit uplink by default and with it unlimited traffic"; 10 Gbit uplinks include 20 TB.
- DigitalOcean: not checked by me.
- The spec has no rule on traffic (grep it). `ADR-0007`: margin on "machine time only"; one multiplier;
  no second price list. `ADR-0006`: setup fees pass through at cost.
- My arithmetic: at 1 Gbit/s ≈ 10.8 TB/day outbound, 20 TiB lasts ~2 days, then ≈ $13/day overage
  against a customer paying ≈ $0.28/day for `cpx11`.

## Options put to the owner

- (a) Pass overage through at cost (ADR-0006's precedent): meter `outgoing_traffic` against
  `included_traffic`, debit bytes beyond it at the provider's price, no margin.
- (b) Charge traffic with margin (reopens ADR-0007).
- (c) Stop the machine at its allowance (route to cancellation).
- (d) Accept and alarm.
My recommendation: (a); the open part is how it reaches the reserve and runway.

## What I want from you

1. Verify the threat: Hetzner Cloud port speed and whether 1 Gbit/s outbound is achievable on cpx11;
   whether included traffic is prorated for a server that lives part of a month and whether it is per
   server or pooled per project; the 100 MB block; DigitalOcean's bandwidth model (pooled per team?
   overage price?). Recompute the amplification honestly, including whether it needs an attacker.
2. Where is (a) wrong? Source and freshness of `outgoing_traffic` (cache semantics, DOM-8, the sweep);
   which billing period it resets on (Hetzner's vs LDG-68's calendar month); the increment/meter
   interaction (LDG-38's seed/exit, ADR-0033's prepaid unit), the reserve (PRV-13b, LDG-33's runway —
   traffic is not time, so how does a runway date account for it?), the clamp (LDG-31), quarantine,
   outages (ADR-0029: no rate → no charge?), pooled allowances, a provider-terminated machine, the
   final reading after the gone-write. Does at-cost pass-through really avoid ADR-0007's "second price
   list"? Which entry kind (LDG-7)?
3. Third shapes, smaller ones especially: e.g. sell only offers with no overage exposure; a per-offer
   traffic ceiling enforced by stopping egress (is there a provider control?); powering off rather
   than deleting at the allowance; bounding exposure through the reserve without metering bytes;
   treating it as an LDG-75 accepted gap plus SEC-42 terms.
4. The strongest "don't build this", quantified.
5. Formal layer: what (a) would touch (Meter, Funding, Runway, Ledger).

## Output

At most 900 words, no preamble: verdict (a), (b), (c), (d) or a named other in one line; why in one
paragraph; every defect in my framing with `file:line` or source URL; the requirement ids and
declarations the chosen answer edits.
