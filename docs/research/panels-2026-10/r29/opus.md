**Q13: use the sum, D + W (D is the provider-call deadline, W the effective visibility window). When no reply comes, also add one resolution or sweep interval.** The sum isn't a free choice; it follows once the window's start point is fixed.

`STO-53` measures each sample from dispatch to observation. So W contains a normal reply time plus the lag L between the provider accepting and the change showing up. Acceptance can happen as late as D.
- **Lag is real but measured only once:** DigitalOcean showed "`404` by the next poll" after a `204` (`08:304-306`).
- **Hetzner Cloud:** the delete "immediately removes the Server", so its lag may be near zero.
- **Robot:** the lag after `cancellation_date=now` has never been measured.

On any provider with lag, a reply at D−ε puts the gone-write at about D+L ("Billing stops at the observation instant", `LDG-74`). The maximum, max(D,W)=D, then falls short by L, which is at most W. The sum costs W more than the maximum, about 30 s of burn. It exceeds the true bound only by the normal reply time.

**This is also a correctness hole.** `PRV-36` starts the window at dispatch: "`OPS-27`'s resolution MUST NOT take its first read before the window has elapsed" (`02:896`).
- With D>W, a timed-out mutation is read at once. If the provider accepted it late and it is still lagging, "Beyond the window, a read still showing the pre-mutation state resolves the mutation as *not applied*" (`02:899`).
- `OPS-32`'s window is "measured from the dispatch of the create" (`03:1349`). A create that replies at D−ε can be recorded gone, which is `OPS-32`'s own 2026-09-04 defect.
- **Fix, in `PRV-36` only:** the window runs from the end of the call's wait, meaning its reply or the deadline's expiry.

D+W then bounds the earliest read that counts as evidence, not the gone-write itself. No parameter in the register (`00:358-415`) sets how often resolution runs. So a timed-out delete is recorded gone only by a resolution pass with no stated timing, or by `OPS-32`'s sweep. Either register a resolution cadence or add the sweep interval. The sum covers one slow call; a provider slow on every call falls to the catastrophe bound (`02:425`).

**Q14: the effective date stops the meter, and ADR-0037 already decided it. Readings (i) and (iii) are the same rule; (ii) contradicts settled text.**
- Decision 3: "for a scheduled cancellation, its effective date" (`0037:45`). Decision 4: "until then they bill" (`0037:47`). `PRV-29` repeats it (`02:311-313`). None of these is limited to machines.
- `LDG-38` rules out (ii): "never its later gone observation" (`12:955`).
- The real defect is that the decision wasn't applied everywhere. `LDG-32` (`12:326-327`) and `LDG-38` (`12:952-953`) still say `released_at`, and ADR-0037's Edits owed (`0037:71`) leaves them out.

**The meter needs no writer at the date.** `LDG-38` re-reads the stop boundary inside the serialization and clips to it (`12:627`, `12:637-638`), as it already does for machines.
- **The date must be stored**, and `machine_attachments` has no column for it (`05:331-339`). That is a schema edit, following `DOM-19`'s "stored alongside the state" (`01:122`).
- **Wire carrier:** extend `WIR-35`'s `effective_cancellation_date` (`13:868`) to `release_attachment`.
- **"Future" stops mattering:** the boundary is the earlier of the date and `released_at`.
- **Not ADR-0028's withdrawn pattern** ("clock read no row write orders", `0028:39`): the date is written once, and no worker waits on it.

**The bookkeeping does need a writer.** `released_at` gates `STO-18`'s tombstone (`05:341`) and `LDG-32`'s commitment close.
- **Machines:** `OPS-32` writes it after the date; "nothing tombstones by timer" (`03:1063`).
- **Attachments:** there is no automatic writer, so what is left of the commitment stays reserved (`12:331`).

**What the customer owes:** metered seconds up to the effective date, at the attachment's rate. The provider's part-day after that is an `LDG-75` gap the operator absorbs (Decision 5). The reserve for this belongs in `LDG-33`'s "cost through any effective cancellation date" (`12:345`). Because the date is only learned after ordering, it needs a bound declared per attachment kind at create, as `PRV-31` does for machines. Without one, a month-end date hits `LDG-31`'s clamp.

**Third shapes, each with its strongest "don't build"**
1. **The operator completes it** through `API-65`, using a listing over the new column. `LDG-74` already does this for a machine "still present after its date" (`12:548`). *Don't:* it pages someone on the normal path.
2. **`OPS-32` re-reads attachments that carry a date.** *Don't:* it needs a new driver call to read one attachment, because *list attachments* takes the machine's `external_id` (`02:471`).
3. **The meter's first tick past the date records the exit.** *Don't:* it turns the meter into something that writes state.
4. **Drivers always send `now`.** *Don't:* Decision 4 says the dated case exists.

**My pick: writer 1 for v1.** The meter is clipped at the date, so the customer is never overcharged; only the reserve waits for the operator rota. Move to writer 2, with its new driver read, once a live driver actually returns a date.

**Defects in your framing**
- **"Nothing ever writes `released_at`" is false.** Account termination writes it (`04:1327-1328`). `API-65` re-enqueues the release on a row whose `released_at` is null (`04:1070-1073`). After the date, the release answers that the attachment is already gone (`02:488-489`), once the driver pins Robot's response code as that goal state (`OPS-11`).
- **"`LDG-32`'s tombstone gate"** belongs to `STO-18` (`05:341`).
- **"Name the writer"** conflates the meter, which needs none, with the gate, which does.
- **"Detection interval"** (`02:275`) has no row in the register; the metering cadence is the actual input (`12:499`). `PRV-13d`'s floor inherits whatever composition is chosen (`02:338-339`).

**Record items: both are real**
- **`API-65` (`04:1081`):** "Either is what opens…" is false for a release that returns a date with a 202. Replace it with a pointer to `PRV-45`'s `released_at` write, quoting `STO-18`: "A machine MUST NOT be tombstoned while any `billable` attachment with a null `released_at` remains". This fix doesn't depend on Q14.
- **`ADR-0035` (lines 43, 72):** append an amendment in the same form as its Q11 one (`:83`), citing Decision 4. Add `ADR-0035` to `ADR-0037`'s Status (`:3`) and to its Edits owed.

**Edits**
- **Q13:**
  - `PRV-13b` (`02:274-277`): name each term by its register row and state the sum.
  - `PRV-36`: the window's start point.
  - `OPS-32` (`03:1349`).
  - `OVR-19`: turn `00:417-419` into a pointer and add a resolution-cadence row.
  - `CNF-329`: cover a reply at D−ε plus lag, and a timed-out call.
  - `CNF-292`.
- **Q14:**
  - `machine_attachments` (new date column), `PRV-45`, `LDG-32`, `LDG-38`, `LDG-33`, and `PRV-13b`'s `billable_attachments`.
  - `WIR-35`, `WIR-52` (`13:845`), `API-65`.
  - `ADR-0035`, plus a note in `ADR-0037`.
  - `CNF-328` (`10:3124-3133`): replace "asserts no transition" with `CNF-277`'s step of advancing the clock past the date (`10:2044-2046`).
- **Formal:**
  - **Q14 needs no change:** `Funding.exitSubject` already takes the boundary as a parameter (`Funding.lean:1515`).
  - **Q13's sum needs no change:** no declaration computes wind-down.
  - **The start-point fix touches three declarations:** `Reconcile.World.dispatchedAt` ("both windows start here", `:154`), `pastWindow` (`:178`) and `absence_sound` (`:353`).

I made no tracked edits. `tools/check-all.sh` passes all seven gates at `0b28621` (exit 0). A copy of this answer is in `docs/research/panels-2026-10/r29/opus-r29-answer.md`.
