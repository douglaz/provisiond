I vote **DROP-FOR-ROBOT, with the date read at delete time**. I saved the report as an untracked scratch file, `panel-q31-opus.md`, in the clone. No tracked files were changed. I didn't run the gates, since I edited nothing they check. Report follows (598 words):

---

**Corrections to the brief.**
- `CNF-356` doesn't test this read. It only says "Retain the post-order … deviation cases of `CNF-147`" (`10:3609`).
- In session 2 the cancellation GET was refused with a 403 (`r45/live-session2.txt:22`). The same-day date came from the cancellation POST's response (`:26`).
- "Same day, both" is from the 2026-09-04 orders (`08:419`).

**1. What happens today when the read fails.** The spec doesn't say. Nothing writes `machines.earliest_cancellation_date`: the column says only "**read** not assumed" (`05:268`), and `PRV-13c` says only "order, then **read**" (`02:578`).
- **If the read runs inside the accepted create:**
  - `PRV-5` says "Known acceptance MUST remain `true` on every later error" (`02:49`).
  - `PRV-40` says a throttle after acceptance "remains subject to `OPS-11`'s acceptance rule" (`02:1149`).
  - So during a blinded hour, every delivered create goes to `needs_reconciliation`. `OPS-11`'s exception for failed reads covers only `PRV-13`'s read-back (`03:281`).
  - Resolution needs "a direct read before it attaches anything" (`03:475`), which hits the same blinded counter.
- **If the read runs anywhere else:** no retry is specified, the column stays null, and `LDG-33`'s term is zero (`12:352`). That is a drop by accident.

**2. Worst case each way.**
- **(a) Keep.**
  - Orders are capped at 20/day per channel, with no hourly pacing (`ADR-0036`). Across the two machine channels (`server`, `server_market`) that allows about 40 reads in one hour, roughly 20% of the 200/h counter.
  - Each read follows an order whose first unit the tenant paid for (`ADR-0036`, Context). The four paths in Q28's threat model (`ADR-0037:331`) cost the tenant nothing.
  - It competes with refreshes, the sweep's list read, the delete read-back and resolution. Rescue (`/boot`), attachments (`03:1403`) and the cancellation POST use other counters.
- **(b) Drop.**
  - `PRV-31` forbids resizing the commitment (`02:553-556`), so the read can only move satoshis from runway into `protected_sats`.
  - The most it saves is min(usable commitment, cost through the date) per machine whose date deviates.
  - Under "30 days to the end of the month" (`08:178`), the tail can reach about 59 days, so up to two monthly caps (`08:146`).
  - No sampled machine has deviated.
  - The delete still catches a deviation. Its accepted response carries `earliest_cancellation_date` (`live-session2.txt:26`).
    - `PRV-13` stores the effective date, and protection runs to "the **later** of the two" (`12:385`).
    - `LDG-63` tops up from available funds and surfaces any shortfall "as a named deficiency" (`12:1989-1991`).
  - Invoices arrive a cycle late (`ADR-0031`), and the sweep reads no cancellation fields.

**3. A third option.** Nothing beyond moving the read. The reserve in `02:583` exists only as `protected_sats` (`02:584`), inside a commitment that can't grow. Its whole effect is therefore the min() above. The cancellation POST provisiond already sends prices the tail.

**4. Vote: DROP-FOR-ROBOT.** The term is still read, from the accepted cancellation's effective date, so `PRV-13c`'s ban on constants still holds. Text it would change:
- `PRV-13` (`02:227`): withdraw "That separate post-order read remains required."
- `PRV-13c` (`02:578`): add "On Robot, `PRV-13`'s accepted effective date is the per-machine read; no post-order GET."
- `CNF-147` and `CNF-356`: move the deviation case to the cancellation response.

The branch where Robot rejects `now` is still `[verify]` (`08:178-180`) and needs a source for the date. Today's text doesn't supply one either, because nothing writes the column. To be workable, KEEP would also need to say where the read runs and add a failure-absorbing rule like the one at `03:281`.

**5. Strongest case for the other side (written on request).**
- Only the post-order read learns of a deviation while the customer's committed satoshis can still pay for it. By the time of the delete, that money has been spent as runtime.
- If Robot rejects `now`, "scheduling at the earliest permitted date" needs a stored date. Without one, the driver either reads a counter that may be blinded or stalls (`03:1120-1122`).
- KEEP plus a failure-absorbing rule fixes the failure problem: the column stays null, `PRV-5`'s alarm fires, and the failure stays outside `OPS-11`. At most about 20% of one hour's counter, all on paid orders, it costs little.
