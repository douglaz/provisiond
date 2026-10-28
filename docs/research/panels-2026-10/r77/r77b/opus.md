# r77b Panel B Q1: opus (claude-opus-5-5, xhigh)

**Neither package is acceptable as printed. I vote AMEND on both, and my final preference is NONE.** Both fail on the same defect in the shared C5 retry rule. If a supersession's reply is lost, the plain reading refuses every retry, so neither component can ever start lawfully. Apart from that I found no verified blocking loss in either package.

My clone is at pin `1fc54e8`, its tracked files are unchanged, and nothing was committed. Scratch is in the untracked `.panel-opus/`. This answer is also saved in `../opus.draft.md`.

## Votes

| Package | Mark |
|---|---|
| Y-PROV-R | **AMEND**: R2 (behaviour changed) and W1 (wording only, behaviour unchanged, verified) |
| Y-WIDE-R | **AMEND**: the same R2 and W1 |
| **Final preference** | **NONE**: no package is acceptable as printed |

- **Direction, not acceptance:** I favour **Y-PROV-R once R2 is applied**. That repaired form still needs its own complete-form read.
- **Why AMEND:** C5's lost-reply rule doesn't say which "predecessor" a retry compares against (trace in §2). The brief says "If the new exception is unsafe or underspecified, vote AMEND/CANNOT ACCEPT".
- **Owner choices:** W versus P, the already-reconciling status scope, the legacy concealment and the new supersession grace are still the owner's policy and cost choices.

## 1. Status scope (check 1)

**The source does not justify including `needs_reconciliation` rows on rollback grounds.** Their markers are final in any backup:
- OPS-3 says "Resolution transitions out of `needs_reconciliation` are made by no worker", and its permitted transitions are "exactly" five resolutions, all to `succeeded` or `failed`.
- OPS-4 says a re-issue is "a fresh operation, never this record moved back to `queued`".
- So no write that a restore could roll back ever reaches those columns.

Including them therefore hides facts that are true. For example, CNF-300's failed-rescue-exit row loses `disk_effect: "none"` after a later actual restore.

The change is **disclosed, not hidden**, so I count it as a policy cost rather than a blocker:
- C2's trailing note, C6's second paragraph and the table's last row all state it.
- CNF-300's own trace contains no restore, so its checked verdict doesn't change.
- It can never produce the lie CNF-302 guards against, because the hidden value is always `unknown`, never `none`.

It does sit awkwardly with Y-PROV's own principle that an open incident "does not itself invalidate markers of newly admitted work". R1 below is an optional, unreviewed alternative for the owner.

## 2. Traces (check 2)

- **Initialization before every startup.** C2 puts the write in "the acknowledged transaction that establishes the restore record". STO-54's lead-in says the deployment "MUST start neither component until the transaction that commits `STO-56`'s record (below) has been acknowledged". Nothing starts first.
- **Promotions.**
  - STO-54 says a restore-classified promotion "is a restore: the procedure below runs on it, and `STO-56`'s record is committed into the promoted store before either component is started". C2's "actual store restore" reaches it through that sentence.
  - A lossless promotion "comes up under `STO-5`'s restart rule, unless a restore record (`STO-56`) is open there". It loses no acknowledged commit, so it correctly gets neither initialization nor supersession.
- **Process successor.** C2 says it "MUST NOT repeat this initialization" and "never supersedes" the open incident. Y-PROV keeps the bit unchanged; Y-WIDE sets it on the open-incident transition, as it declares.
- **Actual restore over an open incident R.** Today's text contradicts itself here, and C5 resolves that.
  - STO-54 says "a process that starts while a restore record is open is continuing that incident". So a backup holding R with step (3) marked would resume with step (2) already marked.
  - A `queued` create that ordered in the lost window would then not be quarantined, which is "a second order".
  - Meanwhile STO-56's "One row per restore" and its partial unique index forbid a second open row.
- **What each removed close guard protected, against the new incident N's full procedure.**
  - ADR-0028 gives the guard's reason: "the record MUST NOT be closed before `grace_ends_at` has passed — an early close would end the grace by making the record no longer open."
  - Supersession closes R and opens N in one transaction. OPS-41 says "while a restore record is open and its `grace_ends_at` is null or in the future the claim MUST defer". So deferral has no gap.
  - N's grace ends one interval after its own step (3), which is later than R's end.
  - Rate-present grace restarts at N's step (3) and needs a full interval, at least as much as R had left. Continuing R's measure would also read STO-49 history that the second restore lost.
  - The gone-or-fenced condition is still "evaluated at the close", and the account sweep must pass twice after the new lost window.
  - N's step (2) again holds every unsettled `suspend_tenant` parent "found `running`, or `queued` and unsettled".
  - A machine fenced in the backup was fenced outside R's deferral, so "a machine already fenced when the grace begins gets no extension" takes away nothing R gave.

  **No removed guard protects anything N fails to preserve,** provided parent confirmations and complete-pass counts are scoped to the incident. Neither is specified anywhere today, so the same hazard already exists for two ordinary restores in a row; it isn't new here. No CNF assertion flips, because CNF-295's and CNF-308's refused-close runs contain no second restore.
- **Second supersession.** This forms a chain: a third incident names N, or, restored from an older backup, names R in a store where N never existed. Both are fine.
- **Lost establishment reply: the defect.**
  - C5 tells the operator to retain only the incident id and restore instant and "reuse both on a lost-reply retry". It then says "A mismatch in the id's restore instant or predecessor MUST be refused with both components stopped".
  - Nothing the operator retained supplies a predecessor to compare. The only other source is what the retry reads from the store.
  - Trace: the restored store holds open R. Establishment commits, closing R, opening N with R as its predecessor, and setting provenance. The reply is lost.
  - The retry reads the open incident and finds N itself. Setting aside the record it is matching, it finds no other open incident. N records R as its predecessor, so the values mismatch and the retry is refused.
  - The lead-in still requires acknowledgement before any component starts, and C5 accepts only "the initial establishment or its matching no-op repeat". Neither ever arrives.
  - The result fails closed: it is a liveness defect, not a safety one. It hits exactly the case C5 adds the rule for, and C6's "A lost transaction reply must not produce two open incidents" doesn't test it. R2 repairs it.
- **Closure and purge.** The column "MUST NOT be cleared … including at incident closure or payload purge". WIR-9a says "Neither incident closure nor an ordinary restart … changes the provenance used for rendering". This holds under both packages.
- **Staged upgrade.**
  - C1 follows STO-13: "such a column is nullable in the release that adds it and tightened after a backfill in a later one".
  - Rows that a previous-release `api` admits during the rollout are null, get backfilled true, and so are hidden permanently. C1's "every existing … row" covers them; I record that as a cost.
  - During the rollout, old and new `api` render the same null row differently. That is a read-side inconsistency, not one of the write hazards STO-13 lists under "a change to a predicate or derivation both components evaluate on shared rows".
  - Note: a backup taken before the migration needs `migrate` to run before establishment can write either new column. Neither package says so.

## 3. Fields, table and conformance (check 3)

- All six table rows and the rescue-inventory cells follow each package's own rule.
- Address and port accompany every `unknown`. RSC-19 says the error "MUST carry `rescue_exit: "unknown"` with the rescue address and port".
- Under Y-WIDE that includes fresh case (a) and inventory rows with a null marker, on machines never rebooted into rescue. CNF-302's pre-dispatch kill already accepts this ("the column is **false** over a machine that was never rebooted into rescue"), so there is precedent and no contradiction.
- Other operation kinds gain no new wire key, and `request_summary` stays a closed list (STO-50).

**Formal model.** No paired Lean edit is needed. This is a coverage gap, not a contradiction.
- `Rescue.rescueExit` (`@[req "WIR-9a"]`) renders from the column alone and quotes WIR-9a's second paragraph, which C4 leaves untouched.
- No tagged declaration renders the replaced restore paragraph or models STO-56 closure. `Restore.Record` has no `closed_at`, and `step_three_writes_grace` is unchanged.
- No other file quotes the replaced WIR-9a or STO-54 text. The one near-reference is CNF-302's "renders both keys `unknown`", which stays true under both packages.

## 4. Brief claims (check 4)

**apply notes.md rule 6 exactly as written; this prompt adds no void rule.**
- Every pinned excerpt I re-read matches the source, and I found no premise error.
- One printing defect: C5's before-string "and closed_at, nullable." drops the source's backticks (the source reads `` and `closed_at`, nullable. ``). C4's formatting instruction covers C4 only. W1 fixes this; it is wording only and I verified it against `05-persistence.md:1375`.
- No vote of mine rests on a brief error.

## 5. Requested counterargument (not a vote)

Against Y-PROV:
- Its safety depends on one bulk write, in one transaction, being run on every restore path: a backup restore, a restore-classified promotion, a supersession, and the pre-migration-backup edge case.
- One missed write renders `none` from a rolled-back null marker, "the one lie the column exists to prevent" (CNF-302).
- Y-WIDE's write at each transition gives quarantined and pass-moved rows a second chance to be marked. It also matches WIR-9a's body literally ("the post-restore startup pass moved").

## Exact repairs

**W1 (both packages; quotation only; behaviour unchanged; verified).**
- **Location:** C5, the STO-56 field list.
- **Before (as printed):** "and closed_at, nullable."
- **After:** the source string, "and `closed_at`, nullable."
- Write identifiers in inline code, as C4 instructs.

**R2 (both packages; behaviour changed: adds an operator obligation, defines the comparison, and adds a conformance assertion; unreviewed until its own complete-form read).** Location: C5, the paragraph after "Actual-restore supersession".
- **First sentence.**
  - Before: "The operator MUST select and retain one new incident id and restore instant per actual restore before attempting establishment, and reuse both on a lost-reply retry."
  - After: "The operator MUST select and retain one new incident id and restore instant per actual restore, and record the id of the open incident it found in the restored store, or none, before attempting establishment, and reuse all three on a lost-reply retry."
- **Mismatch sentence.**
  - Before: "A mismatch in the id's restore instant or predecessor MUST be refused with both components stopped."
  - After: "Where a record with that id exists, its restore instant and `supersedes_incident_id` MUST equal the retained instant and recorded predecessor, and the repeat is then the guarded no-op above; where none exists, the open incident found MUST equal the recorded predecessor. Any mismatch MUST be refused with both components stopped."
- **C6, third paragraph.** After "A lost transaction reply must not produce two open incidents or silently continue using predecessor step marks.", add: "Commit a supersession, lose its reply, and repeat it with the retained values: assert the repeat is the acknowledged guarded no-op and the components may then start."
- **Unchanged:** supersession itself, the ordinary close rule, both provenance rules and every table cell.

**R1 (optional, unreviewed, behaviour changed; not a condition of my vote).**
- **C2, before:** "whose status is queued, running or needs_reconciliation". **After:** "whose status is queued or running".
- **C6, second paragraph:** replace the four sentences from "Separately construct CNF-300's" through "a row already awaiting resolution." with: "Separately construct CNF-300's unresolved failed-rescue-exit row without a prior restore, back it up and actually restore it: it remains needs_reconciliation, its flag stays false, and it still renders none / unknown." Keep the rest of that paragraph.
- **Table:** change the last row to "none / unknown" in both columns, and drop the brief's trailing C2 scope note.

## Checks

- **Run:**
  - Confirmed the pin and that tracked files are unchanged.
  - Read every cited span, plus OPS-3/4, OPS-41, STO-13, STO-49, RSC-19, ADR-0028, CNF-295 and CNF-308.
  - Searched for every quotation of the replaced text, and for `@[req]` tags on WIR-9a, STO-54, STO-56, OPS-15, OPS-45 and STO-13.
- **Failed:** the start gate (`nix develop --command bash tools/check-all.sh`) hit my 600 s tool limit during the Lean build, at module 41 of 58, with other builds running at the same time. I have no gate result. I did not re-run it, because the clone is unmodified and a baseline pass would say nothing about the packages.
- **Not run:** the amended packages applied to the clone and passed through the gates, runtime conformance, and any migration latency measurement.

No implementation approval follows from this read.
