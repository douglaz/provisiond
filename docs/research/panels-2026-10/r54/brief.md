# Panel brief: triage of bead pv-hsm (what `OPS-23`'s repeated sale check reads before dispatch), 2026-10-16

You are one of four independent reviewers. The working directory is a throwaway clone of the
specification repository `provisiond-spec` at `6853d62` (branch `pv-d21-triage`: master `02ed28a` plus the
panel r53 record in `docs/research/panels-2026-10/r53/`). Read `AGENTS.md` first. Do not edit tracked files;
write scratch files only inside this clone (never `/tmp` or `/var/tmp`). This is a text question; you need not
run the gates (green at `02ed28a`). Never call a provider API. This owner often shows my framing wrong with a
first-principles question; check this framing too, and verify every fact below before relying on it.

## Settled and off-limits

- `pv-d21` is closed `wontfix` as **unreachable** (owner, panel r53): rows written before
  `machines.declared_cancellation_bound` existed, and a create whose snapshot an older `api` wrote without the
  bound. Do not reopen it or propose rules for an absent snapshot member.
- `PRV-31`'s v1 sale rule (bound no later than provider-local today, 02:547-549) and `ADR-0037` Q25 ("Cost past
  the declared bound is operator-borne") stand.

## The bead (pv-hsm, P3, from r53's opus)

"`OPS-23` says 'Validation that was performed at the API boundary MUST be repeated in the worker before the
driver is called.' `API-7`'s create tail refuses 'when the named offer is not sellable under `PRV-13b` or
`PRV-31`', so the worker repeats that sale check. No sentence says what the repeated check reads: the create's
`request_summary` offer snapshot, or the driver's current offer listing and descriptor." Its story: a create is
admitted at 10:00 from an offer whose bound is provider-local today; at 10:05, before claim, the provider
re-lists the offer with a one-month minimum term (or a traffic term `PRV-13b` would refuse). A snapshot re-check
dispatches the order; a live re-check fails it with `offer_not_sellable`. Both are conformant today.

## Facts I rely on (verify each)

1. `OPS-23` 03:1623-1628; `API-7`'s sale refusal 04:266-267; `PRV-31` 02:544-549 and 02:563-566, including
   "This does not move a provider failure or a term learned after ordering into admission."
2. `PRV-13b`'s traffic sale rule 02:278-282; 02:575: "The driver MUST report an allowance offer's
   `traffic_bound` from current provider terms in List offers".
3. `OPS-43` 03:663-683: before any ordering call the worker re-reads the offer's current price and compares it
   with the snapshot; it names its own operation error (`conflict`, `details.reason: "price_moved"`) because a
   first form named none (03:684-689).
4. `PRV-42` 02:1232-1235: "the driver MUST confirm that the named offer is still listed before sending the
   order request; a missing offer MUST NOT be ordered. This is a dispatch check"; `ADR-0036`:44.
5. The `request_summary` row (05:384): the snapshot holds `offer_id`, `install_strategies`, the recurring price,
   currency and period, and the declared cancellation bound. **No traffic bound.** So a snapshot re-check can
   serve `PRV-31` only, unless a field is added.
6. `OPS-11` 03:232-238 makes `insufficient_balance`, `halted` and others admission-only ("MUST NOT be emitted
   by a worker"), so `OPS-23` cannot mean "repeat every boundary check". 04:950-952 heads `API-13`'s field
   table with "Validation happens at the boundary *and* again in the worker (`OPS-23`)". r53's opus
   (`r53/opus.md`:13) replied: "Neither 04:950-952 nor `CONTEXT.md` limits what 'validation' covers."
7. `details.refusals` and `not_checked` belong to the purchase tail (13:140-150); a worker-side
   `offer_not_sellable` has no defined operation-error shape.
8. 03:316-325: the install gate reads the machine's copy, not the offer, because "the offer is a live listing
   that may have been re-priced, changed or withdrawn in the meantime".

## My reading (attack it)

Category `bug`: two conformant engines give the customer different outcomes. I lean to (A) below, homed in
`OPS-43`, because the exposure the sale rules guard is created at ordering, the worker already reads the live
offer there, and the snapshot cannot serve `PRV-13b`.

## What I need from you

1. **Redundancy.** Does the text at `6853d62` already settle this? In particular: does `PRV-42`'s "still
   listed" (provider feed, or provisiond's `DOM-9` listing of sellable offers, 01:188-189?) already require a
   live sale re-test at dispatch? Does `OPS-23` reach the purchase tail at all (fact 6)? Quote the sentence
   either way.
2. **Pick one:** (A) **live**: re-test `PRV-13b` and `PRV-31` against the descriptor and the offer as listed at
   claim; unsellable fails before any provider mutation. (B) **snapshot**: re-test the create's snapshot only;
   a re-listing after admission is ordered, its cost operator-borne. (C) **admission-only**: state that the sale
   check is decided once at admission and `OPS-23` does not repeat it. (D) other or combined.
3. For your pick: the identifier it lands on (one rule, one home), a draft sentence, the operation error (kind,
   `details.reason`, `OPS-11` classification) and the `CNF` item. Is the live read the same provider call as
   `OPS-43`'s price read and `PRV-42`'s listing check, and does List offers carry the offer-reported bound and
   traffic bound, or is a further call needed?
4. Who pays what, under each option, in the bead's story with a one-month minimum term, and with an
   allowance-bearing re-listing? How long can the admission-to-claim window actually be?
5. Then, labelled "Strongest case for the other side (written on request)", the best argument against your
   pick. It is not your position.

Under 600 words. Cite `file:line` or identifiers for every claim.
