**Verdict:** build nothing for v1. The auction sample settles the only attachment provisiond orders. The unsampled catalogue channel stays `[verify]` and doesn't block. Make (3) an enabling condition, keep (2)'s declared kinds, and keep (4)'s "immediate" as `08` evidence, not a rule.

## Why

- **Facts check out, except three.** The key line is step **6**, which closes `08:122`'s "`[verify]` (batch B, step 6)". The /64 was read once, at +20 s (lines 23–24), and was not in the per-minute watch. `reserve_location=false` is not in the summary.
- **Not established:**
  - The **standard catalogue channel**, which v1 sells (`01:188-195`; `ADR-0039:29` sells "Robot's default 1 Gbit dedicated servers"). There, `now` against a later earliest date "remains **[verify]**: it may reject or schedule" (`08:163`).
  - Provider-initiated termination.
  - Billing after the `404` (step 10).
- **Threat model for what's left:** accident, no adversary. The loss is one IPv4's rent per catalogue machine, with no end date and no detector. It happens only if the catalogue add-on (`RSC-45`, not channel-specific) behaves unlike the auction one. Not blocking matches Q18's own choice ("the owner chose to sell", `ADR-0037:165-170`). `08:353` leaves the standard channel "still unconfirmed with a real order". One such order (setup fee €59–€1349, `08:151`) settles both.
- **Strongest "don't build":** on the ordinary path the listing never runs on Robot (defect 1), and after the gone it finds nothing (server and IP `404`). Option A on today's Robot writes rows whose releases can only answer `404`. Each costs a Robot request, and a throttled one strands `LDG-32`'s commitment. It also needs an unstated mapping of that `404` to `OPS-11`'s goal state.
- **Strongest "build":** termination is unsampled, and zero rows cannot tell "listed, none" from "never listed".
- **Shape:** `ADR-0037` rejected "scoping the refusal to the kinds an order creates (no pre-create input says which)" (`:172`), so this can't be a sale check. Write it like Q18's "requires all three" (`:161`) and Q19's "Re-admitting such an offer requires" (`ADR-0034:119`): no driver orders a separately booked IP or subnet, and no `ADR-0039` re-admission sells Cloud or DigitalOcean, until option A exists.

## Defects

1. **The day-only rule has no machine owner.**
   - "A provider date given as a calendar day only … names the end of that day UTC" sits in `PRV-45` (`02:544-546`) and `WIR-35` (`13:900-901`). `PRV-13` says only "MUST surface the effective cancellation date" (`02:180`).
   - So an accepted Robot `now` delete returns 23:59:59Z, "a future date" (`DOM-19`, `01:118`), and settles scheduled (`03:1072`), unless the driver's own read already counts as evidence.
   - `PRV-36` makes a read evidence only past the declared bound, "marked **unmeasured** until twenty samples exist", and `08` records none for Robot.
   - That window decides between two branches:
     - *scheduled* (today's text): no extra read. `PRV-45` lists only "on every delete that succeeds with the resource gone" (`02:528`), so r38's gap is every ordinary Robot delete. The meter runs to the sweep under the earlier-of (`12:647`), which `LDG-74` accepts: "Billing stops at the observation instant" (`12:548`).
     - *gone*: wait out the bound, then re-read. That is `PRV-13c`'s read-and-branch, not a constant. It costs one more server read (Q20 spares those). The listing runs and finds nothing.
   - Keep *scheduled*. "Robot `now` is immediate" as a rule breaks `PRV-13c` (`02:489-492`: "cancellation immediacy … per-contract facts").
2. **Fable's defect is real in the wording and has no effect on behaviour.**
   - `03:1072` says "that tombstone is the gone-write of the last row", with the fence "Cleared by the tombstone".
   - Against it, `STO-18` (`05:357`): "MUST NOT be tombstoned while any `billable` attachment with a null `released_at` remains". And `ADR-0037:122-123`: "Stopping the meter is not tombstoning." `LDG-74`'s own words don't forbid it.
   - Every scheduled Robot delete reaches the row, but the last row closes first. `closed_absorbing` (`Tables.lean:454`) leaves `.tombstone` (`:449`) dead.
   - The same wording is at `01:242`, `13:894` and `Render.lean:59,117`.
3. **Stale "pending step 9":** `02:195`, `08:488`, `10:3460`, and research `:554`, `:595`, `:688`. `08:400,403` gain the 18 min 41 s delivery and a third V8 sample.

## Edits

- **`ADR-0037`, new Q21 amendment** (leave Q18's text as it is). It should record:
  - step 9 as observed;
  - Q18's "A surviving one is operator rent until its `cleanup: api` cancellation" as answered for auction;
  - the catalogue sample as owed and not blocking;
  - the enabling condition with option A's parts: rows from `STO-41`'s reads, release enqueued at the gone-write, `WIR-10a`'s `system_reason`, attachments in Lean.
  - Rejected: build now; list on every gone path; account pass; retain-until-discovery.
- **`02:195`:** keep the table. The add-on and the /64 are not the separately booked kinds it declares ("You may need to cancel these separately"). Replace "pending" with the observation.
- **`PRV-13` (`02:180`):** add "a day-only date names the end of that day (`PRV-45`)".
- **`08`:** record the observations, as evidence.
- **`03:1072`, `01:242`, `13:894`:** a scheduled episode closes, and its fence clears, at the last row's gone-write. Delete the tombstone edge.
- **Lean:** delete `Event.tombstone` (`Tables.lean:358,364,416,429,441,449`) and `Render.lean:59,117` in the same change as the Markdown; the regions gate checks the rendered row. No CNF ids.
- **`CNF-347`:** keep the descriptor assertions. Replace "pending live batch B step 9" with: an add-on IP and /64 that are absent after cancellation write no row. Add a case: an accepted Robot `now` delete answered with today's date settles `cancellation_scheduled` at 23:59:59Z and lists nothing. The next complete pass's direct re-read then closes the episode `resource_gone`, with the meter stopped at the observation.
