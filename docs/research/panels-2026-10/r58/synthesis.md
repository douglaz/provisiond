# Panel r58 synthesis: triage of `pv-tst`, whether a cancelled `execute` must record its outcome, 2026-10-18

Readers: fable (claude-fable-5-1, xhigh), opus (claude-opus-5-5, xhigh), astra (gpt-6-astra, high) and sol
(gpt-6.1-sol, xhigh). Each had its own clone at master `c8b7cbc`. All four exited 0, with answers of
4.0-5.4 KB. Every `file:line` below was checked against `c8b7cbc`. The brief is `brief.md`. The plant
patches and logs that astra and sol link stay under `/var/tmp` and are not committed.

## The story

A create is claimed and runs `OPS-43`'s steps 1-8. Step 8 commits and is acknowledged, so
`about_to_order_at` is set. The engine is stopped, by a deploy for example, before the worker invokes
step 9. Nothing was ordered.

- **Engine A records the cancellation.** Under `OPS-11`'s create row (03:232) it is a cut-off `conflict`
  recorded before step 9, so the create settles `failed` and the commitment is released at once.
- **Engine B exits without a write.** On restart `OPS-15` (03:352-357) finds the row `running` with the
  column set, which "takes that ordinary path" (03:402-403) to `needs_reconciliation`. The correlator
  searches for an order nobody placed. The commitment stays held until `OPS-33`'s negative window. On
  Robot's standard channel the bounded search is "an **operator** search, not an automatic one"
  (03:1631-1632).

No sentence chooses between them. `OPS-21` (03:1706-1712) says "`execute` MUST be cancellable, and
cancellation MUST be treated as an ambiguous outcome, except for the create case below". Its second
paragraph covers only "a cancellation of `execute` recorded before step 9". PR #8's codex round 1 raised the
same P2 ("Specify whether cancellation must record the outcome", thread on 03:1712). PR #8 answered it by
narrowing `CNF-361` (10:1508-1510): "the cancellation cases cover only a cancellation the worker records;
assert nothing about one it does not".

## Triage checks (skill steps 1 and 3)

- **Verified.** Neither recording nor exiting is required or forbidden. The texts that bear on it:
  - `OPS-45`: "This rule classifies a failure a worker recorded; an operation interrupted rather than
    classified is `OPS-15`'s, whatever the markers hold" (03:1444-1446).
  - `OPS-49`: "A worker cancelled during the retry loop stops retrying and exits" (03:1764).
  - The worker algorithm (03:1681-1695) sends every non-success `execute` outcome to `classify`, and its
    only `exit()` follows a zero-row write. Nothing marks the algorithm normative.
  - `ADR-0022` (adr/0022:134-135): "cancellation under `OPS-21` is an outcome the owning worker records".
    This is the ADR's statement of the writer inventory ("The writer inventory is true today"), inside a
    rejected alternative's paragraph. It is a record, not a requirement.
- **No trigger is named.** The set names nothing that cancels a running `execute`. `API-58` says a create
  claimed before a suspension "MUST be allowed to settle rather than abandoned mid-order" (04:620-621).
  `05-persistence.md` pictures "a cancelled worker" whose connection is reset "before it returns to the
  pool" (05:143-145), that is, inside a process that keeps running. In practice the trigger is a stop.
- **Redundancy.** Nothing already says it: searched `OPS-5`, `OPS-15`, `OPS-16`, `OPS-21`, `OPS-22`,
  `OPS-45`, `OPS-47`, `OPS-49`, the worker algorithm, `05-persistence.md`, `API-58`, `OVR-19`, `ADR-0022`,
  `ADR-0042`, `ADR-0043` and the formal layer (`Tables.lean`, `Claim.lean`).
- **Prior rejection.** There is no `.out-of-scope/` directory. `ADR-0043` (pv-qga) settled the kind of a
  *recorded* cancellation (cut-off `conflict`, not `internal`) and left this question open.
- **It is not create-only.** The same record-or-exit split applies to:
  - install and rescue inventory before the write-started marker: a recorded failure is `failed`
    ("for any failure at all while `OPS-45`'s two markers say the disk is untouched", 03:231), while an
    interrupted one parks;
  - every other kind, for the error the row carries.
  A `suspend_tenant` parent is re-queued by `OPS-15` (03:418-421).

## Picks

| | fable | opus | astra | sol |
|---|---|---|---|---|
| Option | **A** | **A** | **A** | **A** |
| What bounds the record | `OPS-49`'s existing "Store-retry bound" (00:401); "A needs no new parameter" | one attempt at the settle transaction; a store error then exits under `OPS-49`; "no `OVR-19` parameter" | a new validated drain bound in `OVR-19` | a new finite drain bound, registered and validated in `OVR-19` |
| A cancelled `suspend_tenant` parent | takes `OPS-49`'s defer | takes `OPS-49`'s defer | "A cancelled parent defers" | "Parent cancellation retains restart recovery" |
| Decide with pv-f7a | no, pv-tst first; "A keeps the cut-off `conflict`, so pv-f7a stays live" | **yes** | **yes** | **yes**, suggests reason `execution_cancelled` |
| Decide with pv-9j6 | no | no | no | no |
| ADR home | dated amendment of `ADR-0043`, pointer in `ADR-0022` | new `ADR-0044`, pointers in 0043 and 0022 | new ADR, README index, pointers from 0022 and 0043 | new ADR, pointers from 0022 and 0043, README index |
| Lean / `ci.yml` | nothing | nothing | a cancellation/drain model composing `Claim`/`Tables`, witnesses, `ci.yml` controls | the same |

Strongest argument for A, from each reader:

- **fable:** "The record already treats a cancellation as something the worker records." C "would turn every
  graceful stop into a crash for every kind". An install cancelled before its marker is `failed` today and
  would park.
- **opus:** the set already treats a cancellation as an outcome the worker writes down (`ADR-0022`, the
  worker algorithm, and `ADR-0043`'s own "An `OPS-21` cancellation of `execute` stays a cut-off
  `conflict`", which C leaves "with nothing to govern").
- **astra:** "Avoid discarding evidence that releases a customer's commitment."
- **sol:** "The worker's knowledge that step 9 never began remains useful even though a crash loses it."

## Claims of mine the readers broke

The manager's lean was **C** (a cancellation is an interruption: write nothing, exit, and let `OPS-15`
classify). **All four rejected it.**

- **Stake: "Before step 8 commits, A and B differ only in the kind".** Broken (astra, sol). Under B the
  release also waits until the engine restarts. astra: "Before step 8, outcomes converge only after restart;
  release timing still differs."
- **Option A "probably within a stated drain bound (an `OVR-19` parameter)".** Split 2-2. fable and opus say
  the existing `OPS-49` bound or a single attempt suffices; astra and sol want a new registered bound.
- **Claim 1 (A cannot remove the split; a crash still parks).** Holds, all four. It is not an argument for C.
  - fable: "True, not an argument."
  - astra: it "does not justify discarding live knowledge".
- **Claim 2 (`OPS-45` already draws the line; pv-9j6 is the same split).** **Broken as support for C,
  4-0.** Its "not create-only" half holds (opus: "Not create-only, agreed").
  - `OPS-45` says who classifies a recorded row and who classifies an interrupted one. Nothing in it says a
    cancellation is an interruption.
  - pv-9j6's own example "records a cut-off `conflict`", so it is a recorded case. Its disagreement is
    between two classifications of the same recorded failure.
- **Claim 3 (`OPS-21`'s "except for the create case" contradicts the install row).** Holds 3-1.
  - opus, astra and sol call the contradiction real. astra adds the refresh row's "Always `failed`"
    (03:228). opus: the "except" should cover "every row that settles regardless of ambiguity".
  - fable disagrees: "ambiguous" is the failure's property and the rows consume it. The install row's "any
    failure at all" includes ambiguous ones, and `Tables.installRow` never reads `ambiguous`. On that
    reading the create carve-out "was the same redundancy".
- **Claim 4 (under C no cut-off `conflict` exists and pv-f7a closes).** Holds as a cost of C, conditionally.
  - It withdraws `ADR-0043`'s chosen sentence.
  - `cutOff` sits in the six-field `Failure` constructors (Witnesses.lean:3023, 3035, 3038).
  - Deleting `OPS-11`'s bullet turns the citations gate red (fable's plant).
  - astra and sol: pv-f7a closes only if every recordable cut-off is gone. A C scoped to shutdown would leave
    it alive.
- **Claim 5 (C requires a cancellation to end the process).** Holds, and counts against C. opus: 05:143
  pictures a cancelled worker in a process that keeps running.
- **Claim 6 (`OPS-49`'s "`OPS-15` gives the same answer either way" still holds).** Holds in scope only:
  - fable: true but irrelevant, since it compares two unrecorded exits;
  - astra and sol: true only for identical durable state.
  - opus: false if "either way" means the worker's outcome against `OPS-15`'s, and false before pv-qga too. A
    refresh whose `succeeded` write is retrying meets `OPS-15`'s "A `refresh` found `running` at startup MUST
    be settled `failed`". The sentence was off-limits in the brief, so opus proposed no edit.
- **Claim 7 (under A a `suspend_tenant` parent has no recordable outcome).** Split 2-2.
  - Broken (fable, opus): `OPS-49` already gives a parent a write, "returned to `queued` with `available_at`
    advanced — the same write as `OPS-8`'s defer, though nothing refused it" (03:1767-1769).
  - Holds against an unqualified A (astra, sol): astra, "Yes against unqualified A", fixed by "explicit
    guarded deferral"; sol, "A needs an explicit parent exception".
- **The bead's premise that engine B conforms.** Weak, 4-0, but not refuted.
  - No MUST sentence forbids B. fable: "`OPS-22` binds how a worker records, not whether", and `OPS-5`
    admits "or the startup pass finds it".
  - Against B: the algorithm and `ADR-0022` both assume recording. opus: B conforms only if its exit ends
    the process.

## Edits owed under A (union; the shape is still open)

- **`OPS-21`:**
  - The MUST: a cancellation outside `OPS-49`'s loop that the process survives is recorded and classified
    under `OPS-11` before the engine exits. All four agree.
  - The bound on that record. Still open: `OPS-49`'s bound, one attempt, or a new `OVR-19` parameter.
  - The parent's defer (fable, opus, astra), or the parent's restart recovery (sol).
  - Widen "except for the create case" to every row that settles whatever the ambiguity: install and rescue
    inventory before the marker, and refresh (opus, astra, sol).
  - Keep the phrase `CNF-361` quotes, "a cancellation of `execute` recorded before step 9 is the exception".
    opus's plant shows dropping "recorded" turns the citations gate red.
- **The worker algorithm (03:1681):** a comment on the `execute` line (opus, astra, sol).
- **`CNF-361`:**
  - Replace "assert nothing about one it does not" and the dated pv-tst note.
  - New case: a stop after step 8 is acknowledged makes one settle write before exit, and the create is
    `failed`, fully released, with no `OPS-27` search.
  - Control (fable): a cancel inside the loop, then a restart, gives `needs_reconciliation`.
- **A new CNF item covering every kind** (opus):
  - a recorded row for each `OPS-11` row;
  - no `running` row while the process lives;
  - the parent re-queued;
  - a refused record write that ends in exit and then `OPS-15`.
  astra and sol also list `CNF-31a`/`CNF-31b` cancellation cases, `CNF-294` lost-reply cases, `CNF-272`'s
  parent deferral, and bound-validation conformance if a new bound is registered.
- **`WIR-9a`:** the cut-off `conflict`'s reason value, plus a fixture. This is pv-f7a. sol suggests
  `execution_cancelled`.
- **An ADR:** a new one (opus, astra, sol), or a dated amendment of `ADR-0043` (fable). Either way, pointers
  from `ADR-0022` and `ADR-0043`, plus the README index.
- **`OVR-19`:** a register row, only if the bound is a new parameter (astra, sol).
- **Lean and `ci.yml`:**
  - fable and opus: none, since `cutOff` and `installRow` already model a recorded cut-off.
  - astra and sol: a cancellation model composing `Claim` and `Tables`, with its import, paired witnesses,
    and `ci.yml` mutations that remove the recording or the bound.
- **`OPS-49`'s "either way" bullet (03:1764-1765):** in scope as wording, per opus's reading above.

## Planted edits

- **An unbounded "MUST be recorded ... before the engine exits" in `OPS-21`.** All four planted it, and every
  gate passed (exit 0). No gate reads a MUST's bound. Only a running-system CNF case can catch it (fable,
  opus): hold the store, then assert one attempt and an exit within the bound.
- **opus:** dropping "recorded" from `OPS-21`'s second paragraph turns the citations gate red: "10-conformance-checklist.md
  attributes to `OPS-21` a phrase `OPS-21` does not contain".
- **fable (for C):** deleting `OPS-11`'s cut-off bullet turns the citations gate red: "Tables.lean quotes a
  phrase found in no document". That is a cost of C, not a control.

## Pairing

- **pv-f7a:** decide together, 3-1 (opus, astra, sol). Under A, every graceful stop writes a cut-off
  `conflict`, which has no `WIR-9a` reason, and the two beads edit the same sentences. fable would decide
  pv-tst first, but agrees that A keeps pv-f7a live.
- **pv-9j6:** decide separately, 4-0. It survives every option, because a recorded pre-dispatch `timeout` or
  `internal` shows the same `OPS-45`/`OPS-11` disagreement.

## Found in passing (not filed)

- **The install/refresh tension in `OPS-21`'s "except" clause** (claim 3) is folded into pv-tst. Under A or
  B, the `OPS-21` rewrite widens the clause. Under C the clause disappears.
- **`OPS-49`'s "either way" (opus, claim 6):** wording, fixed in pv-tst's change if `OPS-49`'s bullet is
  touched.

## Reader citations corrected here

- fable attributes "the accepted outage" to `OVR-18`. The sentence is in `OPS-47`'s note (03:154): "The
  restart window is the accepted outage, and it is alarmed (`OVR-18`)".
- fable, opus, astra and sol cite `ADR-0022`'s "cancellation under `OPS-21` is an outcome the owning worker
  records" as the set's position. It is real (adr/0022:134-135), but it is the ADR's description of the
  writer inventory inside a rejected alternative, not a requirement.

## Strongest case for the other options (written on request, not the readers' positions)

- **For B:**
  - fable: "The gap is one acknowledgement wide; most cancellations land in a driver call or the loop. A
    MUST untestable on a kill buys a CNF case, not money. Say both conform and stop."
  - opus: "Nothing forces a write on a kill, so A's line between 'cancelled' and 'killed' can't be tested at
    the exact moment it matters."
  - astra: "Let runtimes choose whether shutdown drains; startup supplies conservative recovery, and the
    negative window bounds retention."
  - sol: "Permit both safe shutdown strategies; avoid mandatory shutdown writes and accept temporary
    commitment retention."
- **For C:**
  - fable: "One path for every stop: no cut-off kind, no reason value, no drain, pv-f7a closes, a field and
    a witness go, and the restart path is already proven and sweeps."
  - opus: "A graceful stop should drain ... A stop that can't wait is a crash in all but name. One road
    (`OPS-15`), one test, one kind, and pv-f7a disappears. The money gap is microseconds wide."
  - astra: "Treat interruptions uniformly, eliminate optional cleanup writes and cutoff reasons, and reuse
    startup recovery."
  - sol: "Reuse restart recovery, avoid cancellation shielding, and retire the cut-off error surface."

## Manager's recommendation

**Option A, 4-0.** This is every reader's pick, not a manager synthesis. The manager's lean C is withdrawn.
Category **`bug`**, on pv-qga's precedent: two conforming engines leave a different balance held. State
stays `needs-triage` until the owner picks.

The shape inside A is not settled. Three points split, and r58b takes them before any owner question on
them:
- the bound: `OPS-49`'s existing bound, a single attempt, or a new `OVR-19` parameter (2-2);
- the parent: defer, or restart recovery (3-1);
- the scope: new ADR or amendment (3-1), and Lean/`ci.yml` or none (2-2).

pv-f7a's reason value then goes to the owner in the same change, since three of four would decide it
together.

A's size is unsettled. fable and opus put it at one `OPS-21` sentence plus `CNF` cases. astra and sol add an
`OVR-19` bound, a Lean model and `ci.yml` controls. A's money benefit lands only when the stop waits for the
record write. A stop that times out and kills the process is a crash, and a crash parks under every option.

## Queued for the owner

1. A, B or C (asked 2026-10-18).
2. Under A: pv-f7a's reason value for a cut-off `conflict` (for example sol's `execution_cancelled`), after
   r58b.

## Next steps for a fresh manager

- Branch `pv-tst-triage` (off master `c8b7cbc`, not pushed) holds this record and a triage comment on
  pv-tst.
- After the owner picks:
  - **A:** run r58b on the three splits above, with clones at the branch tip. Then ask pv-f7a's reason value.
    Write pv-tst's agent brief (`AGENT-BRIEF.md`) covering pv-f7a's edit. Set pv-tst `bug` +
    `ready-for-agent`; pv-f7a is closed by the same change or depends on it.
  - **B:** `OPS-21` says either conforms and that an exit is `OPS-15`'s. Widen the "except" clause.
    `CNF-361` stays narrowed. Amend `ADR-0043`. pv-f7a stays open.
  - **C:** reopen the scope with the panel first. All four readers argued against it, and it withdraws
    `ADR-0043`'s owner-chosen sentence.
- pv-9j6 is triaged separately whatever the pick.
