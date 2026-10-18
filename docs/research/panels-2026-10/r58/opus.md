**Panel r58 · pv-tst · reviewer opus**

**1. Pick: A, with the drain bounded by rules that already exist.** The set already treats a cancellation as an outcome the worker writes down:
- `ADR-0022` lists the writers: "cancellation under `OPS-21` is an outcome the owning worker records".
- The worker algorithm (03:1681-1695) sends every non-success `execute` outcome to `classify`. Its only `exit()` is on a zero-row write.
- `ADR-0043`, settled today, says "An `OPS-21` cancellation of `execute` stays a cut-off `conflict`". C leaves that sentence with nothing to govern.

A needs no `OVR-19` parameter. The provider call is abandoned, not waited on. The record is one attempt at the settle transaction, and a store error then exits under `OPS-49`'s "A worker cancelled during the retry loop stops retrying and exits", leaving the row to `OPS-15`.

**2. Claims**
1. **Holds.** pv-qga already accepted this split: `CNF-361` says "a restart in that same window instead enters `needs_reconciliation`".
2. **Breaks as support for C.** `OPS-45` says who classifies a recorded row and who classifies an interrupted one. It doesn't say whether a cancellation must be recorded. Not create-only, agreed, and that is C's cost: a deploy that stops an install before its marker pages an operator ("interrupted rather than classified is `OPS-15`'s, whatever the markers hold"). pv-9j6 survives C, since any recorded `internal` failure before dispatch shows the same split.
3. **Holds, and predates this question.** "except for the create case" should cover every row that settles regardless of ambiguity. The install row says `failed` "for any failure at all", and `installRow` ignores the `Failure` argument. A rewrites that sentence anyway.
4. **Holds, as a cost of C**, plus it withdraws `ADR-0043`'s chosen sentence.
5. **Holds, and counts against C.** 05:143 has "a cancelled worker" whose connection "returns to the pool", so the set already pictures a cancelled worker in a process that keeps running.
6. **Holds only if "either way" means cancelled versus exhausted.** If it means the worker's outcome versus `OPS-15`'s, it is false, and was false before pv-qga: a refresh retrying `succeeded` meets "A `refresh` found `running` at startup MUST be settled `failed`". That text is off-limits, so I report it and don't propose an edit.
7. **Breaks.** A cancelled parent has a write available: "returned to `queued` with `available_at` advanced — the same write as `OPS-8`'s defer" (`OPS-49`).

**3. Engine B's conformance.** No text says the pseudocode is normative, so B can claim it is literally conforming: an exit "treated as an ambiguous outcome" fits `OPS-21`'s first sentence. But B conforms only if its exit ends the process. `OPS-15` says "nothing but a restart can leave a `running` row with no worker behind it", and `OPS-22`'s only exit without a write is when something else moved the row. The premise is weak, not refuted.

**4. Pairing.** Decide pv-tst together with pv-f7a. Under A every graceful stop writes a cut-off `conflict`, which needs a `WIR-9a` reason, and both beads edit the same sentences. Decide pv-9j6 separately; it doesn't depend on this.

**5. Edits A owes**
- `OPS-21`:
  - the MUST;
  - the one-attempt bound, quoting `OPS-49` rather than editing it;
  - the parent's defer;
  - an "except" clause that covers every row settling regardless of ambiguity.
- A comment on the worker algorithm's `execute` line.
- `CNF-361`: drop "assert nothing about one it does not" and the dated pv-tst note. Add a stop after step 8 is acknowledged that asserts one settle write before exit, `failed`, full release and no `OPS-27` search.
- A new item covering every kind: assert a recorded row for each `OPS-11` row, no `running` row while the process lives, the parent re-queued, and a refused record write ending in exit and then `OPS-15`.
- A new `ADR-0044` (the rule covers every kind, not just create), with dated pointers in `ADR-0043` and `ADR-0022`.
- A `WIR-9a` reason (pv-f7a).
- No Lean change: `cutOff` and `installRow` already model a recorded cut-off. No new `ci.yml` control.

**6. Planted edits**
- **Plant 1:** I added "A cancelled worker MUST record its outcome under `OPS-11` before the engine exits." All 7 gates passed (exit 0). The edit is wrong three ways: it has no bound, it gives the parent no outcome, and it contradicts `CNF-361`.
- **Plant 2:** I also dropped "recorded" from `OPS-21`'s second paragraph. The citations gate failed (exit 1): "10-conformance-checklist.md attributes to `OPS-21` a phrase `OPS-21` does not contain".

No CI control can catch a missing bound. The `CNF` items in Q5 have to: assert exactly one record attempt and no repeat after a store refusal. Both plants are reverted and the worktree is clean. `br` left an untracked `.beads/` state file.

**7. Advocates**
- **C, as its advocate:** "A graceful stop should drain: stop claiming and let in-flight work settle, as `API-58` says, 'allowed to settle rather than abandoned mid-order'. A stop that can't wait is a crash in all but name. One road (`OPS-15`), one test, one kind, and pv-f7a disappears. The money gap is microseconds wide."
- **B, as its advocate:** "Nothing forces a write on a kill, so A's line between 'cancelled' and 'killed' can't be tested at the exact moment it matters. `CNF-361` is already narrowed. One explicit sentence costs nothing and leaves any recorded outcome correct."
