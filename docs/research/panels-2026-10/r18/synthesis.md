# Panel r18 synthesis — who pays the rest of a provider's started billing unit (2026-10-06)

Readers: fable (claude-fable-5-1), opus (claude-opus-5-5), astra (gpt-6-astra), sol (gpt-6-sol), all
xhigh, clones at 40c00cb. Brief: brief.md. All four exit 0, both gate runs green where run.

## Verdict: A, 4–0 — the operator absorbs the remainder; the customer keeps exact elapsed seconds.

My recommendation (B) was rejected by every reader, independently.

## Why B fails (verified against the files)

- Provider grid unknown: creation-anchored vs wall-clock vs ceil(monthly aggregate) — Hetzner's docs
  are silent; at the monthly cap the provider charges nothing more, so B bills rounding never applied.
- Breaks decided exits: quarantine "MUST post no usage debit" (12:1017), outage charges "the customer
  nothing" (12:1308), clamp turns the excess into a deficiency (12:275), provider-terminated machine
  stops at the observation instant (12:510).
- Contradicts ADR-0011's 2026-10-03 exit-closure decision (ADR-0011:85-90 rejected "a minimum charge
  of one meter interval [that] overcharges partial use") and Lean: Funding.lifecycle_coverage,
  unmarked_lifecycle_coverage, release_follows_close, Witnesses.exit_closes_each_tail (W:2060).
- C fixes none of that; "charge at entry" breaks the seed (posts nothing); per-span minimum is
  ADR-0011's rejected shape.

## Defects in my framing

1. "Fifty minutes nobody is charged for" — loss is (1 − (1+m)·t) units; 10 min at 20% = 0.8 unit.
2. "The provider's price IS one hour" — ignores the monthly cap (Hetzner) and the 672 h cap
   (DigitalOcean, bundled-plan CPU Droplets only; v5 Droplets have none).
3. "Target market" — ADR-0007's "bursty and unattended" sits inside a rejected alternative;
   ADR-0010 makes Robot the product, where PRV-40 caps orders at 20/day per endpoint (P:875).
4. Research note: DO "minimum binds only under a minute" is false — the $0.01 floor binds up to an
   hour below $0.60/h; batch C step 7's invoice lines read the floor and carry no latency.
5. Research note: "the reserve's wind-down term needs the rounding unit" is false under A — a term
   nothing debits is released unused (LDG-32, 12:297).

## Pre-existing defects found (independent of A/B)

- STO-53's `billing_stop` sample is "when the engine first observed its effect" (05:477) — visibility
  or absence — while PRV-36 says visibility and billing-stop "MUST NOT be conflated" (02:831). The only
  billing-stop evidence is an invoice in whole units. (fable, opus, sol)
- LDG-37 does not say whether `deleting` is billable (opus); grep finds no `deleting` in 12-billing.
- LDG-75's "Accepted accounting gaps" (12:1950) does not list provider rounding; accrual understates
  the payable until invoiced (fable, astra, opus).
- SEC-39's create ceiling has no default integer (07:209-212), so the per-tenant rounding loss is
  bounded only by a stated deployment integer (all four).

## Edit list under A (union; disagreements marked)

- PRV-13b + dated F18 note: separate latency from the unit; no unit term in the reserve. (all)
- STO-53 / billing_stop_window: redefine as dispatch → gone observation (opus) or drop (fable). OPEN.
- Unit's home: PRV-44 field (fable; astra if engine-consumed) vs 08-provider-notes only, since under A
  nothing reads it and CNF-18 demands a code path (opus; sol "only if the engine will use it"). OPEN —
  turns on whether LDG-75's accrual estimates the remainder.
- LDG-75: name the gap. (fable, astra, opus)
- ADR-0007 consequence or a new ADR rejecting B and C. (all name one)
- LDG-37: elapsed seconds only; whether `deleting` is billable. (opus, astra)
- SEC-39: its create ceiling is the rounding bound. (opus)
- Research §3 + live batches A and C: grid test (create hh:50, delete hh+1:10; one across a month
  end); DO floor makes batch C step 7 uninformative. (fable, opus)
