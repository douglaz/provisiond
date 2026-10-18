# Panel r57 synthesis — triage of `pv-qga`, a create failure before any provider mutation, 2026-10-18

Readers: fable (claude-fable-5-1, xhigh), opus (claude-opus-5-5, xhigh), astra (gpt-6-astra, high), sol
(gpt-6.1-sol, xhigh). Each had a clone at master `a1dd00f`. All four exited 0, with answers of 3.4-4.6 KB.
Every reader ran the gates; baseline exit 0. Every `file:line` below was checked against `a1dd00f`. The
brief is `brief.md`. The raw plant patches and logs that astra and sol link stay under `/var/tmp` and are not
committed.

## The story

A create is claimed. At `OPS-43` step 4 the List offers read times out. No key was uploaded and no order
was sent. `OPS-11` (03:263-266) calls a failure ambiguous when "the error kind is `network`, `timeout`, or
`internal`", with no mutation qualifier. Its create row (03:232) is "`needs_reconciliation` if the failure
is *ambiguous*, otherwise `failed`". So the create parks, the correlator searches for an order nobody
placed, and the customer's commitment stays held until `OPS-33`'s window ends.

Kill the process at the same instant instead, and `OPS-15`'s restart exception (03:384-408) settles the
create `failed` and releases the commitment at once (`CNF-358`, 10:1458). A recorded timeout fares worse than
a crash.

## Triage checks (skill steps 1 and 3)

- **Verified.** In a scratch clone, `decide` proves
  `classify currentRules .createMachine ⟨.timeout, false, .unrecorded, false, false⟩ ⟨false, true⟩ =
  some .needsReconciliation`. The same holds for `.network`, while `.refresh` with the same failure is
  `failed`. `rejected_order_witness` (Witnesses.lean:3008) already pins a create's `network` failure with
  `accepted` false as `needsReconciliation`.
- **The text that requires the parking:**
  - `CNF-31a` (10:194-195): "A create failing with a provider 5xx, a network error, or a timeout is
    `needs_reconciliation`, including without known acceptance".
  - `CNF-31b` (10:212-213): "a pre-send `network` failure yields `needs_reconciliation` despite
    `details.accepted: false`".
  - `CNF-323` (10:3426): "a pre-send `network` failure remains ambiguous despite accepted false".
- **Redundancy.** Nothing settles this already. I searched `OPS-11`, `OPS-43`, `OPS-15`, `OPS-45`, `PRV-5`,
  `CNF-31a/b`, `ADR-0035`, `ADR-0042`, `Tables.lean` and `Witnesses.lean`. `OPS-43`'s "its owning
  classification governs disposition" (03:757) hands step 4 to `OPS-11`. Three passages argue the same
  shape:
  - `OPS-11`'s refresh row: "a failure changed nothing" (03:228).
  - `PRV-13c`'s failed post-order read, which "MUST NOT enter `OPS-11`'s classifier" (03:285-287).
  - `OPS-43`'s price gate: "it fails before anything is bought, so nothing ambiguous is created"
    (03:812).
  - `F47` calls the general pattern "uncertainty manufactured by classification rather than by anything
    the provider did" (11:102-103).
- **Prior rejection.** There is no `.out-of-scope/` directory. `ADR-0035`'s Q11 amendment rejected
  "settling a pre-send `network` failure as `failed` (a behaviour change beyond the question)"
  (adr/0035:108-109). That case is the **order** request failing before any byte was sent, which happens
  after step 8. The recommendation below keeps that rejection.
- **The kinds at issue** are only the ones ambiguous by kind: `network`, `timeout`, `internal`, `provider`
  with a 5xx or no status, and a cut-off `conflict`. A deterministic kind at steps 1-8 is already `failed`.

## Picks

| | fable | opus | astra | sol |
|---|---|---|---|---|
| Shape | **B** | **B**, with a different boundary | **B**, with an explicit `OPS-49` carve-out | **B**, with an explicit store-error exclusion |
| Boundary | "before any step-9 request" | "before step 8's transaction is sent", or keep `about_to_order_at IS NULL` in the settle write | known to precede step 8's commit; `OPS-49`'s exits kept | step-8 failures go to `OPS-49`, which exits |
| Extra null guard on the settle write | not proposed | one of opus's two fixes | "No additional null settlement guard is needed" | "Keep the ordinary settlement guard" |
| Kind of a cancellation before step 9 | stays `conflict` (cut-off); "not become `internal`" | `internal` naming the cancellation | keep driver kinds (no view on the cancellation) | "include cut-off `conflict`" |
| `retryable` on newly cleared kinds | `true` (claim 2 "holds") | `true` | `true` | `true` |
| ADR home | new `ADR-0043`, pointers in 0042 and 0035 | amend `ADR-0042`, pointer in 0035:109 | amend `ADR-0035`, keep Q11's order case | new ADR, README index, pointers from 0035 and 0042 |
| Other last-row kinds share it | no; separate bead on `OPS-45` (below) | no | no | no |

The strongest argument for B, which all four make:
- **fable:** "The set already has this shape once: the install row's '`failed` ... for any failure at all
  while `OPS-45`'s two markers say the disk is untouched'". A re-defines "ambiguous" for five kinds, and C
  makes 03:757 "self-referential for step 4".
- **opus:** the same install-row precedent, plus `F47`'s "uncertainty manufactured by classification". C
  is too narrow, because a cancellation can land at any of steps 1-8.
- **astra:** "C creates another classification owner; A unnecessarily changes other operation kinds."
- **sol:** "its home is `OPS-11`: 'On failure, the system MUST classify'". C's analogy fails because
  `PRV-13c` "MUST NOT change the create's settlement", while this amendment chooses one.

## Claims of mine the readers broke

1. **"The boundary is step 8's commit, known by position" (all four).** The worker observes an
   acknowledgement, not a commit. `OPS-43` says "Step 9 MUST begin only after step 8's transaction is
   acknowledged" (03:749), and `CNF-360` (10:1487) tests "Commit step 8 and drop its reply". After a lost
   reply the column is set while the worker still stands at step 8.
   - **opus's path:** step 8 commits, the reply is lost, and a termination lands before `OPS-49`'s repeat.
     The repeat's `STO-47` write affects no row, so the worker must "fail the operation deterministically".
     The create settles `failed` with the column **set**. That falsifies 03:747-748: "a create that fails
     that check commits no `about_to_order_at`". It is a `pv-k4l` residual, and pv-qga's edit owes it.
   - Nothing is ordered in any of these paths, so `failed` stays true. In the window between sending step
     8 and its acknowledgement, the worker can record only a deterministic `STO-47` refusal, already
     `failed`. A store error or a cancellation inside `OPS-49`'s loop exits without classifying:
     `OPS-49` says "A worker cancelled during the retry loop stops retrying and exits" (03:1749). So
     fable's "before any step-9 request" and opus's "before step 8's transaction is sent" give the same
     outcome on every failure the worker records. The wording should say step 9, not the commit.
   - No reader found a create defer. sol: "No create-defer counterexample found". A running create's
     `machine_id` is null until completion (05:390), so `OPS-8`'s index never refuses it.
2. **"`retryable: true`; the error keeps the driver's kind."** `retryable` holds 4-0. A cancellation is not
   a driver error, though, and two readers disagree on its kind:
   - opus: `WIR-9a`'s `conflict` row needs a `reason` ("Minimum keys", 13:124), and none of its twelve
     values fits a cut-off (13:137, verified).
   - fable: `internal` is "Defect in this system" (01:588), so the cancellation must not become `internal`.
   - The missing reason is pre-existing: it reaches every cut-off `conflict` today, including the ones that
     park. It is filed separately (below).
3. **"Money: `LDG-39`/`LDG-32` with includes clauses."** This omitted three things:
   - `STO-58`: the exclusion's "lifetime follows the winning create's outcome settlement" (05:844; opus,
     astra, sol).
   - `STO-3`'s "precedes every money write in the transaction" (05:29; astra, sol).
   - fable: the includes clauses are needed, since "a `timeout` is not a 'rejection'".
4. **"Lean: `Failure` (or `Markers`) gains a fact."** This was understated.
   - It cannot go in `Markers`: `OPS-45` says "The column is not a marker" (03:1393; opus).
   - A free Boolean admits the impossible pair "before step 9" ∧ `accepted` (all four). Exclude it in the
     arm (`&& !f.accepted`), or with a guard hypothesis plus the witness `ADR-0025` requires.
   - `classify_total`, `admission_only_failed` and `accepted_never_failed` change binders. Witnesses.lean
     has 9 `classify` call sites and 5 five-tuple literals (fable; counts verified).
5. **"C rejected"** holds. fable adds that C also contradicts r56's "It is a *classified* failure, so it
   belongs with `pv-qga`" (r56 synthesis:82).
6. **"pv-p1y and pv-xer out of scope"** holds as scope, but B decides part of them. `PRV-47` rejects
   "without any provider mutation for that create" (02:160), so a step-7 failure of an ambiguous kind now
   settles `failed`. pv-p1y keeps only its missing kind (opus, astra, sol), and opus says the same of
   pv-xer's `retryable`. The brief should say so.

## Edits owed (union; ★ = missed by the manager's brief)

- `OPS-11`: the create row, with the boundary at step 9, `retryable: true` for newly cleared kinds, and
  money and exclusion by reference. Its 03:234 note gets a pointer.
- ★`OPS-21`: a carve-out from "cancellation MUST be treated as an ambiguous outcome" for a create before
  step 9, keeping `OPS-49`'s cancel-and-exit path (all four).
- `OPS-43`: the settlement paragraph (03:772-789) gets a pointer. ★03:747-748 needs correcting for the
  lost-reply-then-termination path (opus).
- ★`OPS-45`: the scope sentence and note (03:1384-1393). "rather than from anything the engine can record
  about itself" and "only its null, read by that restart pass ... settles anything" become false or
  incomplete (all four).
- ★A read-only guarantee for List offers. No sentence gives one today: `PRV-12` covers Get machine (02:179)
  and `PRV-45` List attachments (02:648). B's premise needs one (fable, verified). This needs a new `PRV`
  id, the next free one.
- `LDG-32` (12:312) and `LDG-39` (12:1264): includes clauses. `STO-58` freed; `STO-3`/`LDG-35` order.
- CNF:
  - `CNF-31a` and `CNF-31b` scoped to failures after step 9 begins; ★`CNF-323` too (opus, sol).
  - New `CNF-361`: every ambiguous kind at step 4, and a cancellation at each of steps 1-8, on both
    channels. Assert `failed`, `retryable: true` on the error and the view, the reported kind, a full
    release with no fee or unit debit, the exclusion freed, no step-9 request, and no `OPS-27` search.
  - Controls in `CNF-361`: the same timeout on the order request still parks; a stale-null snapshot after
    dispatch must not authorise `failed` (astra, sol); the lost-reply-then-termination path.
- ADR: see the queue. `ADR-0035`'s rejected Q11 bullet (adr/0035:108-109) gets a dated pointer that keeps
  the order-request case. The README ADR index gets a row if the ADR is new (sol).
- Lean (`Tables.lean`, `Witnesses.lean`):
  - a new `Rules` switch and a `Failure` fact for "before step 9", constrained against `accepted`;
  - a theorem that every create failure before step 9 is `failed`, whatever its kind;
  - a witness pinning cut-off `conflict` both ways;
  - the binder updates.
  - ★ci.yml: a row in the rule-flip loop (.github/workflows/ci.yml:362-366), requiring that the new
    witness be refuted (all four).

## Planted edits

| Reader | Plant | Result |
|---|---|---|
| fable | `OPS-11` create row: "`failed` for every kind where `about_to_order_at` is null when the worker records the failure" | all seven gates green (`gate-planted.out`, exit 0) |
| opus | Lean `.conflict => f.cutOff` → `false`, plus a Markdown column-read rule | all seven gates green |
| opus | settle every create `failed` | red at `accepted_never_failed` (Tables.lean:218) |
| astra | a cached-null rule reading the claim-time record | baseline, mutant and restored all exit 0 |
| sol | a create row settling `failed` after a preceding null-column read | 0 / 0 / 0 |

The manager re-ran opus's cut-off plant: see "Manager's re-check" below. What this shows:
- No gate reads the prose rule.
- The only Lean pin near this rule is `accepted_never_failed`.
- Nothing pins the cut-off `conflict` arm (`cutOff` appears only at Tables.lean:136).
- The controls the fix owes: the new theorem, a cut-off witness, the ci.yml flip, and `CNF-361`'s
  stale-null and post-boundary cases.

## Do delete, power, reverse DNS or release share the defect? No, 4-0

None makes a required provider read before its mutation:
- Robot's delete "MUST NOT issue `GET /server/{n}/cancellation` as a pre-read" (02:230).
- Reverse DNS compares with "the machine's recorded value" (`PRV-25`), a store read.
- `PRV-45`'s List attachments runs after "every delete that succeeds with the resource gone".
- Power and release open with the mutation.
- Begin rescue's read belongs to install, which `OPS-45`'s markers already settle.

astra and sol: a driver-internal pre-read, if one is ever shown, deserves its own bead.

## Found in passing (filed)

1. **`pv-9j6`: `OPS-45`'s marker settlement for power, reverse DNS, delete and release is in neither
   `OPS-11`'s last row nor `Tables.classify` (fable, verified).**
   - `OPS-45` governs those kinds (03:1380-1381). It sets their marker when "the provider call is
     dispatched" (03:1403) and says "An operation settles `failed` ... when the write-started marker is
     unset" (03:1432-1434).
   - `05-persistence.md` says a null `write_started_at` "makes the failure deterministic rather than
     ambiguous (`OPS-11`)" (05:400; fable cited 05:396).
   - But `OPS-11`'s last row (03:232) names no marker, and `classify` sends those kinds to `mutationRow`,
     ignoring `Markers` (Tables.lean:185-186).
   - So a cancellation before dispatch parks under `OPS-11` and the model, but settles `failed` under
     `OPS-45`. Pre-existing.
2. **`pv-f7a` (related to pv-qga): a cut-off `conflict` has no `WIR-9a` reason (opus, verified).** `OPS-11` names "`conflict` *and* it
   arose from the worker being cut off mid-flight (`OPS-21`)". `WIR-9a`'s `conflict` row requires a
   `reason` and lists twelve values, none for a cut-off. This hits every kind today, whatever pv-qga
   decides.

## Reader citations corrected here

- fable's "03:229" for the install row is 03:231 (03:229 is `suspend_tenant`).
- fable's "05:396" for the `write_started_at` sentence is 05:400.
- opus's "Tables.lean:222" for `accepted_never_failed`: the theorem spans 218-221.

## Strongest case for the other side (written on request — not the readers' positions)

All four wrote the status-quo case on request. None voted for it.

- **fable:** "The owner declined exactly this on 2026-10-08". "The worker's 'position' is a belief about a
  driver no requirement binds to read-only behaviour." The stakes are asymmetric: "parking costs one held
  commitment until `OPS-33`; a wrong `failed` is an orphan machine the operator pays for."
- **opus:** "B classifies on position the worker holds in memory and never records. One ordering bug, such
  as a key upload before step 8, turns a dispatched order into `failed`, a full release and `retryable:
  true`", followed by an immediate re-buy: "the duplicate `OPS-27` exists to prevent".
- **astra:** "Accept temporary commitment retention rather than invite duplicate orders through a mistaken
  early-failure exception" (`API-51`'s "a second purchase").
- **sol:** `OPS-11`'s own warning, "defaulting to `failed` invites a caller to retry a mutation that may
  have happened".

The answers to this case are the List offers read-only sentence and the controls in `CNF-361`: a stale null
must not authorise `failed`, and a failure after step 9 begins must still park.

## Manager's recommendation (pending the owner)

**Shape B, as fable's and sol's answers shape it.** Each of those two answers is this combination in full,
so this is not a synthesis outside the votes:
- In `OPS-11`'s create row, a create failure the worker records **before step 9 begins** (before any
  per-order key upload or order request) settles `failed`, whatever its kind. It keeps its reported kind
  and gets `retryable: true` on the error and the view where the kind was previously ambiguous. The
  commitment is released in full (`LDG-32`, `LDG-39` includes clauses; `STO-3`/`LDG-35` order), and the
  exclusion is freed (`STO-58`).
- The settle write keeps its ordinary guard, with no `about_to_order_at IS NULL` term. `OPS-49`'s
  store-error and cancel-in-retry exits are unchanged: they classify nothing.
- `OPS-21`'s cancellation before step 9 is included, keeping its cut-off `conflict` kind. Its missing reason
  goes to the new `WIR-9a` bead.
- After step 9 begins, nothing changes: `ADR-0035`'s Q11 rejection and the order-request case in
  `CNF-31b`/`CNF-323` stand.
- A new `ADR-0043`, with dated pointers in `ADR-0035` (Q11 bullet) and `ADR-0042`.
- Every item under "Edits owed".

Category **`bug`**. `CNF-31a`, `CNF-31b` and `CNF-323` mandate the parking, and two conformant engines
differ on the customer's held balance. State **`ready-for-agent`** once the owner decides. Lean changes
are in scope.

**Out of scope:**
- pv-009, pv-xer and pv-s5b;
- pv-p1y's missing kind, though B settles its status;
- step 9's key-upload and pre-send order failures (Q11);
- the two beads filed here.

**Where opus differs:** a cancellation becomes `internal`; the boundary is "before step 8's transaction
is sent" or the settle write carries an `IS NULL` term; `ADR-0042` is amended. **Where astra differs:**
`ADR-0035` is amended rather than a new ADR written.

## Manager's re-check

In a fresh clone at `a1dd00f` the manager changed Tables.lean:136 from `| .conflict => f.cutOff` to
`| .conflict => false` and ran `tools/check_formal.sh`. It exited 0: Tables rebuilt, and "869 tagged
declarations, 0 outside the axiom policy". This confirms opus's finding. Nothing in the formal layer pins
the cut-off `conflict` arm, so pv-qga's witness is the first control on it.

## Queued for the owner

1. **The shape (asked first):** B as recommended above, or opus's variants, or the status quo.
2. Inside B, only if the owner wants them as separate calls: the cancellation's kind (fable and sol keep
   cut-off `conflict`; opus says `internal`), and the ADR home (new ADR, 2: fable and sol; amend
   `ADR-0042`, 1: opus; amend `ADR-0035`, 1: astra).

## Next steps for a fresh manager

- On the owner's answer, label pv-qga `bug` and `ready-for-agent`, remove `needs-triage`, and post the
  agent brief (template in the triage skill's AGENT-BRIEF.md) as a new comment. It is built from
  "Manager's recommendation" and "Edits owed" above, with the owner's answer folded in.
- Then commit on `pv-qga-triage`, and implement through an rloop Run: opus Manager, sol 6.1 Implementer,
  with `TMPDIR` outside `/tmp`.
- The pointer comment already on pv-qga names this file. `pv-9j6` and `pv-f7a` are new needs-triage P3
  beads.
