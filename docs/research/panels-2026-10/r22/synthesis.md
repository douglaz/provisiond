# Panel r22 synthesis — should `billing_stop_window` exist? (2026-10-06)

Readers: sol, astra (codex xhigh), fable, opus (claude xhigh); clones at e43f42c. All exit 0.
Citations verified against the files.

## Verdict: withdraw it, 4–0 — but NOT replaced by "billing stops at acceptance" (3–1; fable alone
## kept acceptance, per result, for the immediate shape).

- No path writes a `billing_stop` sample: STO-53's writers are "when a resolution (OPS-27)
  establishes when a resource became visible, and when an ordinary mutation's effect is first read
  back" (05:481-483), both visibility. `Reconcile.Windows` has only visibility and negative.
- What wind-down funds is the CUSTOMER's meter, which stops at the gone-write: LDG-74 "Billing stops
  at the observation instant" (12:510), LDG-38's exit rule, OPS-48's "succeeded, resource gone". So
  the latency term is dispatch → recorded gone = PRV-36's effective window, already declared and
  sampled. Whatever the provider bills after that is the operator's (ADR-0033's residual). (opus;
  sol, astra converge)
- "Dispatch → accepted" would UNDER-reserve: the meter debits through `deleting` until the gone-write
  and LDG-31's clamp turns the gap into an operator deficiency — the 02:217-227 trap ("used to shrink
  a number every machine's reserve depends on"). (opus, sol, astra)
- No provider puts the stop at HTTP acceptance: Hetzner Cloud's delete returns an action that can
  fail; Robot ties billing to existence; 02:264 already says "An action reporting `completed` does
  not establish that billing stopped". ADR-0035's `accepted` is a Boolean on errors, not a timestamp.
  Declaring "stops at acceptance" as a constant breaches PRV-13c's "cancellation immediacy".

## Defects in my framing (verified)

1. Withdrawing F18's twenty-sample procedure dangles PRV-36, which borrows it: "under `PRV-13b`'s
   procedure — the worst observed request-to-observation latency over at least twenty real
   mutations" (02:811-813). Keep the procedure; PRV-36 owns it. (opus)
2. OVR-19 has no provider-call deadline row (only rescue, migration and store timeouts), so the happy
   path of any wind-down composition is unbounded. (fable)
3. "Invoices only, in whole units" is false for DigitalOcean (per second; invoice items carry
   `end_time`). LDG-75's true-up is per account/currency/month, not a per-machine audit. (all)
4. The post-gone residual is not only Hetzner's unit: Robot add-ons bill "per day or part thereof";
   DigitalOcean's destroy tail is seconds after the 204. Name both in LDG-75's accepted gaps. (fable,
   opus)
5. Robot IPs and subnets accept a future `cancellation_date` (scheduled shape on an attachment), but
   PRV-45 writes `released_at` on any success (02:438). (opus)

## Converged edits (a′)

- PRV-44 / PRV-13b: drop `billing_stop_window`; split PRV-13b's "measured worst-case delay" into the
  time until the customer's meter stops (PRV-36's effective window) and the remainder the operator
  absorbs (ADR-0033's declared unit). 02:229's "measured confirmed-cancellation latency" →
  "PRV-36's effective window".
- STO-53: drop the `billing_stop` kind AND the `kind` column (one value left; PK `(operation_id)`).
- PRV-36: owns the twenty-sample procedure; its "still owed" sentence → dated trap record.
- PRV-29: the third fact stays; its evidence is rewritten — machine: the gone-write; attachment:
  `released_at`; scheduled shape: the effective date.
- PRV-45: a release whose result carries a future effective date writes no `released_at`.
- OVR-19: a provider-call deadline row (bounds wind-down's happy path).
- LDG-75: accepted gaps name the unit remainder, Robot add-on days, DigitalOcean's destroy tail.
- CNF-292 clause dropped; ADR-0018 line 28 amended; F18 dated note; 08-provider-notes 5, 248,
  305-308; README note on the dropped column; research §3 and live batches A10/B10/C7 become checks
  of the billing unit and grid, not latency.
- Lean: none.
