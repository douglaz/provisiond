**1. My pick is B, with a different boundary.** OPS-11's install row already has this shape: "`failed` … for any failure at all while `OPS-45`'s two markers say the disk is untouched" (03:231). B puts the same clause on create, in the same owner. The refresh row already overrides OPS-21; F47 calls the alternative "uncertainty manufactured by classification" (11:102). C is too narrow: a cancellation can land at any of steps 1–8, not only at step 4's read.

**2. Breaking the claims**
- **Claim 1: yes, the worker's position and the column can disagree.**
  - Step 8 commits, its reply is lost, and a termination lands before the `OPS-49` repeat. That repeat's `STO-47` write affects no row, so the worker must "fail the operation deterministically". The result is `failed` with the column **set**, although 03:747-748 says "a create that fails that check commits no `about_to_order_at`".
  - A cancellation in that window can't know whether step 8 committed.
  - Fix: either bound the rule at "before step 8's transaction is sent", or keep OPS-15's `about_to_order_at IS NULL` term inside the settle write, with zero rows taking the ordinary path.
- **Claim 2:** a cancellation is not a driver error. WIR-9a's `conflict` row requires a `reason`, and none of its twelve values fits a cut-off (13:137). Use OPS-15's restart-style `internal` error naming the cancellation instead.
- **Claim 3:** it leaves out `STO-58`, which says the exclusion's "lifetime follows the winning create's outcome settlement" (05:844). OPS-15 and CNF-358 both name it.
- **Claim 4:** the new fact can't go in `Markers`, because OPS-45 says "The column is not a marker". The rule must also apply only when `accepted` is false; my plant 3 shows why.
- **Claim 6:** "whatever its kind" and claim 2 partly decide `pv-p1y` ("step-7 failure has no classification") and `pv-xer` ("Claim-time create failures state no retryable"). The fix should say so.

**3. Edits the fix owes** (the manager missed those marked ★)
- Requirements: OPS-11's create row; ★OPS-21 needs a carve-out; ★OPS-45's scope sentence and note (03:1384, 03:1393, "only its null, read by that restart pass … settles anything"); ★OPS-43's sentence at 03:747-748; the "includes" clauses in LDG-39 and LDG-32.
- CNF: CNF-31a, CNF-31b, and ★CNF-323 (10:3426, "a pre-send `network` failure remains ambiguous"). Add a new item: every ambiguous kind at step 4, and a cancellation at each of steps 1–8, on both channels. It asserts `failed`, `retryable: true`, a full release, the freed exclusion and no step-9 request, plus the lost-reply-then-cancel case.
- ADR: amend `ADR-0042`, which owns "ordered nothing", and add a dated pointer in ADR-0035's rejected bullet (:109), as pv-k4l did at :61.
- Lean and ci.yml: a new `Rules` field with a matching `Failure` fact, a theorem, and a witness that pins cut-off `conflict` both ways. Add a row to ci.yml's Tables list (~L365).

**4. Planted wrong edits**
- Plants 1 and 2, run together: in Lean, `.conflict => f.cutOff` changed to `false` for every kind; in OPS-11's create row, a Markdown "column read" settling `failed`. All seven gates passed, exit 0, and the log shows Tables was rebuilt. No theorem pins the cut-off `conflict` anywhere.
- Plant 3, settling every create `failed`: the Lean build fails at Tables.lean:222, `accepted_never_failed`.
- The negative controls should catch three things: the rule removed, the rule applied after step 8, and the cut-off case dropped.
- I reverted all plants. The baseline gate exits 0.

**5. Other kinds: no.** Robot's delete "MUST NOT issue `GET /server/{n}/cancellation` as a pre-read" (02:229-230). Power has none (PRV-14). Reverse DNS compares "with the machine's recorded value" (PRV-25). Release attachment has none. Begin rescue's read (02:702) belongs to install, which OPS-45's markers already settle `failed`. No separate bead is needed.

**6. The status-quo advocate's case.** ADR-0035 rejected exactly this: "settling a pre-send `network` failure as `failed`". It also says "The engine cannot see inside the driver's call". B classifies on position the worker holds in memory and never records. One ordering bug, such as a key upload before step 8, turns a dispatched order into `failed`, a full release and `retryable: true`. The agent then re-buys at once against a provider that is already timing out: the duplicate OPS-27 exists to prevent, ending as an operator deficiency. The status quo's worst case costs the customer liquidity until OPS-33, and a resolved-absent create is released in full. For a P3, those unequal costs favour parking.
