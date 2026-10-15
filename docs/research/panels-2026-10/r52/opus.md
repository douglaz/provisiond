The bot's finding is real. Your two-line fix (a) can't be carried out from what the store holds, so I recommend a different wording fix (d). I also found one more defect of the same weight. The gate at `74ad5f7` passed when run unpiped (exit 0). I changed no tracked files. The report is also saved at `panel-r52-opus.md` in the clone, and the gate output at `gate-out.txt`. Both are untracked.

**1. Is the finding real? Yes.** After the crash, `OPS-15` moves the create to `needs_reconciliation` (03:348). `OPS-49` says "the outcome in hand is thrown away" (03:1585). `OPS-27` then repeats the confirming read and settles at entry point two (03:515-518), where `CNF-356` requires the read. Nothing in the store says whether a read was made before the crash. So 02:601 ("MUST NOT … read … again") and 02:604 ("MUST record a successful post-order read's date") cannot both be met. A restore produces the same contradiction even after the commit (03:348, 03:358).

The exposure is the same as Q31 already accepted for a failed read, but it is not zero. The read exists to catch a deviating contract (ADR-0037:389, "Only this read learns of a deviating contract"), and "cost beyond it after a provider deviation is operator-borne" (12:1992-1993).

**2. Comparing the fixes.** The test for each is whether recovery can apply the rule using only what the store holds.
- **(a) fails that test.** Recovery can't tell a lost result from a read never made. Making (a) work needs either a record, which turns it into (b), or a blanket rule that interrupted creates skip the read. Either way it throws away a successful read that found a deviating date, and it misses the restore case. Q31's "a failed read of any kind" (ADR-0037:376) doesn't cover a read that succeeded, so (a) needs an owner decision.
- **(b)** has its own crash window between writing the attempt record and making the read. Its "attempted, no result" state still falls back to (a) or (c).
- **(c)** costs at most one extra read per create in flight at the crash. That is bounded by `STO-55`'s stated worker count (05:160) and, after a restore, by `ADR-0036`'s per-endpoint daily cap. Recovery already spends a `GET /server/{n}` on the same counter for each such create (10:3635).
- **(d), my pick:** use the rule the spec already has, where an outcome that was never committed never happened (`OPS-49`). Tie the no-repeat rule to the machine row the store holds. Q31 says "once, when the create settles" (ADR-0037:374), and a pass that didn't commit settled nothing. This changes Q31's count of "one per delivered order" (ADR-0037:380), so the owner should confirm it in one line.

**3. One more defect.** The operator's `observed` verb "attaches a discovered resource (`OPS-27`)" (13:885). It is "**Synchronous**" (13:953) and makes no confirming read. Yet 02:593-594's "MUST read … once, when the create settles, after `OPS-27`'s confirming read" binds that settlement. And 03:540-541 demands "its date or the null after a failed read", neither of which this path has.

**The edits, all in one pass:**
- **02:601:** replace with "The pass whose landed-order transaction commits makes one read and does not retry it. Where the store holds the machine row, a resolution pass, a refresh and the sweep MUST NOT read its cancellation constraint." Keep the `PRV-13` pointer.
- **02:594:** add "a settlement with no confirming read (`WIR-35`) makes none."
- **03:541:** replace with "the date of a successful read the transaction holds, otherwise null".
- **`CNF-356`:** kill the engine before commit, once after a successful read and once after a failed read. Assert one read at resolution, the date or null written with the machine row, and no read after settlement. Assert that operator `observed` writes null.
- **ADR-0037:** one clarification line.

**4. Recommendation.** Fix all of this now, in one pass. Merge on the next clean gate once the owner confirms the Q31 line.

**5. Strongest case for the other side (written on request).** Merge now and record a follow-up bead. The crash window is an outage that already raises an alarm (`OVR-18`). A lost date only matters with a deviating contract, which v1 has never seen (10:3642 prices the ordinary case at zero). Fix (a) keeps "Assert exactly one `GET /server/{n}/cancellation` for each create" (10:3645) as an absolute a test can check. Fix (d) changes a count the owner decided, and it puts new text in front of a bot that has found a P1 in every new sentence.
