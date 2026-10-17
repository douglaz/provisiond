# Panel r56 synthesis — triage of `pv-k4l`, a create interrupted before `OPS-43`'s step 8, 2026-10-17

Readers: fable (claude-fable-5-1, xhigh), opus (claude-opus-5-5, xhigh), astra (gpt-6-astra, high), sol
(gpt-6.1-sol, xhigh); clones at `96ce45c` (branch `post-pr6-notes`: master `1292174` plus PR #6's bead
comments). All exit 0. The brief waived the gates (a text question; green at `1292174`). Every `file:line`
below was checked against `96ce45c`.

## The story

A create is claimed, and steps 1-7 of `OPS-43` run (03:681-702). The engine restarts during step 4's List
offers read. Nothing was ordered and no key was uploaded, because step 9 holds every provider mutation
(03:706-708). On restart the create goes to an operator, and the commitment is held until `OPS-33`
releases it. On Robot that wait is "bounded by **operator response time**" (02:1036-1038). The spec
defines no graceful shutdown (no match for graceful/shutdown/drain in 03, 05 or 07).

## What the text forces today (4-0)

- **The story ends with an operator.**
  - `OPS-15`: "MUST move every `running` operation to `needs_reconciliation`" (03:348-349). Its only
    exceptions are `refresh` (03:375-380) and `suspend_tenant` (03:382-391).
  - `OPS-38`: "A create that recorded none has no count ... **Unresolved**" (03:627-628).
  - `OPS-27`'s last row: "Escalate to an operator", with "Released per `OPS-33`" (03:473).
  - `OPS-45` "does **not** reach `create`" (03:1334-1335).
  - This is the auction channel's outcome too: no fingerprint was recorded, so there is nothing to search
    (fable).
  - It is a proposed behaviour change, not a contradiction (sol).
- **Fact 4 holds: a `correlator: none` channel stores nothing defined.**
  - The descriptor's word is `correlator: operation_id | per_order_key | none` (02:79).
  - `PRV-26` presupposes a correlator: "Whichever it is, the kind and the value MUST be recorded"
    (02:869-870).
  - **It is worse than briefed (opus).** `PRV-9`'s per-order key is still uploaded on Robot's standard
    channel, and 05:382 says "`ssh_key_fingerprint` on Robot" with no channel scope. Step 8 may therefore
    write either a fingerprint or nothing; the text does not decide.
- **Fact 5 holds, and it reframes the bead (fable).** `API-63` already asserts the invariant pv-k4l needs:
  "a claimed create with no entry has not passed the conditional-write check and does not dispatch"
  (04:1423-1425).
  - Nothing guarantees that sentence on a `none` channel.
  - "A claimed create with an entry MUST be treated as potentially dispatched" (04:1428) stays true (opus).
  - Forcing the sentence's preconditions is owed to `API-63` whatever pv-k4l decides (fable).
- **Restore (fact 7), 4-0.** A `running` create with no step-8 record in a restored store may have ordered
  inside the lost interval. `OPS-15`'s restore paragraph says a row "may have settled at the provider
  inside the lost interval" (03:355-356). `STO-54`: a process that starts during an open restore record
  is "continuing that incident, not restarting" (03:369-370). `Witnesses.lean`'s `restore_breaks_soundness`
  (1189) is the formal statement.

## Claims of mine the readers broke

- **Fact 6 ("no text forces step 8's operation-row write to carry `STO-3`'s guard") is overstated**
  (astra, sol, fable; opus held it).
  - `OPS-6` already says "every write that worker makes to the operation MUST carry `claim_number = mine`
    (`STO-3`)" (03:165-166).
  - Ordering before the call is forced (fable). `PRV-26` says "recorded on the operation row ... before the
    order is sent" (02:869-872). `API-63` says "a termination can still commit between the write and the
    call" (04:1421-1422). `STO-55` forbids a transaction held "open across a provider ... call" (05:150;
    sol).
  - Durability is `synchronous_commit` `local` (05:1449-1451; fable, astra). That suffices against a crash
    and not against a restore.
  - **What is genuinely missing:**
    - the status term on step 8's write;
    - "zero rows affected means no step 9, exit" — `OPS-45`'s sentence for its markers, 03:1439-1441;
    - an explicit acknowledgement-before-dispatch rule. Only `OPS-45` states one: "each acknowledged by the
      store before the provider call it precedes is made" (03:1446-1447).
- **Shape (c)'s "the window is seconds" is the wrong measure (fable, opus).**
  - The crash window is seconds; the *hold* it causes is operator-bounded (02:1036-1038).
  - Collisions are correlated (opus). When store retries run out, "the engine MUST exit non-zero"
    (03:1668), which parks every create that is mid-claim at once.

## Gaps found beyond the brief

- **An asynchronous standby promotion (opus, verified).**
  - The posture is "asynchronous streaming replication" (05:1443).
  - `STO-5` covers "process restart" (05:70) and excludes "A restore from backup" (05:71). `STO-54` is
    "A store restored from backup" (05:1436).
  - No text classifies a promotion that lost committed `local` writes (grep "promot": nothing in the
    requirements). A promotion can lose a committed step 8 after the order went out.
  - So any settle-on-absence rule must not fire on a store that lost committed writes. Whether promotion
    is a restore *generally* is pre-existing and wider than pv-k4l: it also reaches `queued` creates.
- **Migration (astra, sol).** Rows claimed before the new record existed must not read as "never
  dispatched" through a column default (`STO-13`, 05:1368-1370).
- **`OPS-21` (opus).** "cancellation MUST be treated as an ambiguous outcome" (03:1645-1646). A cancelled
  `execute` before step 8 reaches the same operator outcome without a restart. It is a *classified*
  failure, so it belongs with `pv-qga`, not here.
- **The startup pass would write money for the first time (opus).** Today it settles no create. The new
  exception releases a commitment, so it takes `LDG-35`'s primitive (sol: "atomically with commitment
  release (`STO-3`, `LDG-35`)"). The fee's home is the create's own record (`LDG-67`, 12:1809).

## Reader citations corrected here

- fable "03:470" for `OPS-27`'s absent row: the row is 03:471.
- fable "`restart_never_reorders` (595)": the theorem is at `Restore.lean:596`.
- fable's `OPS-3` "A transition made by a worker" is at 03:88, as "transition made *by a worker*".
- astra's "`OPS-4`: 'a fresh operation'" is `OPS-4` at 03:130; the same phrase also appears at 03:28
  (`OPS-2`).
- All other cited lines matched:
  - `Restore.lean` `Op` 66-70 and `passOp` 336-341;
  - 01:653 (`DOM-17`'s "safe and sensible");
  - 03:145, 03:262-265, 03:1336-1337;
  - 05:267, 05:301, 05:380;
  - 10:205 (`CNF-31b`), 10:2468-2469;
  - 12:1809;
  - `CONTEXT.md` 148 (Marker) and 308 (correlator);
  - adr/0035:59-61 and :107.

## Picks

| | fable | opus | astra | sol |
|---|---|---|---|---|
| Shape | (b) `correlator_kind` written on every channel, `none` on a `PRV-33` channel | (a) new column `operations.order_armed_at` | (a) a dedicated write-once create dispatch marker | (b) `('none', NULL)` = entry without a verified correlator |
| Home | `OPS-15`, restart only | `OPS-15`, restart only | `OPS-15`, off for an open restore incident | `OPS-15`, restart only |
| Outcome | `failed`, `internal` naming the restart, `retryable: true` | same | same; `OPS-16` keeps an earlier error | same; `OPS-16` keeps an earlier error |
| `OPS-11` | not a classification (03:1385-1387) | same; the exception must say so | the exception takes precedence, stated | precedence stated in `OPS-11` |
| `LDG-39` | "Deterministic rejection before acceptance" | same; `STO-58`'s exclusion freed | same | same, row extended to name this case |
| `API-63` | 04:1426-1427 rewritten; 04:1423 true on every channel | the test keys on `order_armed_at` | the test keys on the marker | non-null `correlator_kind`, `none` included, means potentially dispatched |
| ADR | new short ADR plus a pointer in 0035's bullet | new ADR (amends `ADR-0016`'s pass) plus a dated pointer at adr/0035:59 | amend `ADR-0035` | amend `ADR-0035`; no new ADR |
| `pv-qga` | decide together; two beads; pv-qga depends on pv-k4l | decide together; two homes; pv-qga depends on pv-k4l | decide together; two beads; no dependency | decide together; two beads; no hard dependency |
| (c) wontfix | no | no | no | no |

**Tally:**

- **4-0:**
  - fix it;
  - home it in an `OPS-15` startup exception, restart only;
  - settle `failed`/`internal`/`retryable: true`, released under `LDG-39`'s "Deterministic rejection before
    acceptance" row;
  - it is not an `OPS-11` classification;
  - the fix escapes `ADR-0035`'s rejected alternative, which is about a *set* marker;
  - decide pv-qga together with it, as two beads.
- **2-2:**
  - shape: (a) opus, astra; (b) fable, sol;
  - ADR home: new ADR (fable, opus) or amend `ADR-0035` (astra, sol);
  - whether pv-qga depends on pv-k4l: yes (fable, opus) or no (astra, sol).

## Soundness conditions (union; no reader dissented from any)

"No step-8 record" proves "no provider mutation" only if:

1. **On every channel.** Step 8 writes the record on every channel, including `correlator: none`.
2. **Write-once.** Nothing clears it, and it survives the payload purge.
3. **Before step 9.** Step 9 (key upload included) starts only after step 8's transaction is acknowledged.
   A lost acknowledgement leads to `OPS-49`'s whole-transaction repeat, never to a speculative dispatch.
4. **Guarded.** Step 8's operation-row write carries `STO-3`'s worker guard: status `running` plus
   `OPS-6`'s claim term. Zero rows affected means no step 9, and the worker exits.
5. **Tested inside the write.** The startup pass tests "record absent" inside its own conditional write,
   together with the commitment release under `LDG-35`, not in a read before it.
   - If startup wins, the worker's step-8 write affects no row.
   - If the worker wins, the record blocks the settlement.
6. **Restart only.** It never fires during an open restore incident (`STO-54`) or on a store that lost
   committed writes (opus's promotion gap).
7. **Migration.** Rows claimed before the record existed stay conservative.

It is not a fence against the cut-off second engine `OPS-47` puts out of scope (03:138-141): "The lock
is not a fence" (03:146).

## Strongest case for the other side (written on request — not the readers' positions)

- **fable (for (c)):** "The proof is a timing invariant over `OPS-43`'s step order, which moved twice this
  week (pv-hsm, pv-14b). The next move of step 8 voids it silently ... Wrong once, the cost is `LDG-13`'s
  unfunded machine with a customer's key on it. (c) costs one page and a delay the operator can see and
  price."
- **opus (for (c)):** "Today's rule fails safe whenever an assumption breaks: a restore nobody recorded,
  an adapter that sends before the commit returns, a promotion nobody called a restore. The fix turns
  each of these into a quiet `failed` with the money released and an orphan order at the provider."
- **astra (for (b)):** "`API-63` already gives the correlator entry dispatch significance. Defining `none`
  as an explicit entry could complete that existing representation without another column."
- **sol (for (a)):** "`CONTEXT.md` defines a correlator as what a create 'writes or leaves behind at the
  provider.' A local `none` sentinel overloads that concept, complicating searches and copies."

## Manager's recommendation (pending the owner)

**Shape (a), a dedicated create marker.** This is opus's package. astra shares the shape and the home but
splits on the ADR and the pv-qga dependency. It is not a synthesis outside the votes. Every shape-level
choice is 2-2, so the owner may ask for a round r56b first.

Why (a) over (b):

- The correlator pair is read as a provider fact:
  - `CONTEXT.md` 308 defines the correlator as "Whatever a create writes or leaves behind at the provider";
  - `OPS-38` counts "every correlator the operation recorded" (03:625-626);
  - `PRV-26` requires it "opaque and unique per operation" (02:866);
  - the machine row copies the pair (05:267), and an index serves reconciliation lookup (05:301).
- Under (b), every reader of the pair must special-case `none`.
- The set's own history warns against one column carrying two meanings. `OPS-45` (03:1402-1405) records
  that "a single column carrying two meanings was read as carrying the first one everywhere".
- Under (a), the step-8 content of a `none` channel's pair stops mattering for dispatch, because
  `API-63`'s test moves to the marker.

**Where it lands**, if the owner picks (a):

- **`05-persistence.md`, `operations` table:** a new nullable timestamp, written once with `COALESCE` in
  step 8's transaction and null on every other kind. opus's name is `order_armed_at`; the name is open.
- **`OPS-43` step 8:** the marker write, the status guard, zero rows ⇒ no step 9, and acknowledgement
  before step 9.
- **`OPS-15`:** a new create exception after the `refresh` paragraph:
  - restart only; off during an open `STO-54` incident and on a store that lost committed writes;
  - settles `failed` with `internal` naming the restart and `retryable: true`;
  - `OPS-16` preserved;
  - commitment released under `LDG-39`'s "Deterministic rejection before acceptance" and `LDG-32`;
  - `STO-58`'s exclusion freed.
- **`STO-3`:**
  - the startup-pass bullet (05:42-45) gains "`failed` for a create whose marker is null", with the null
    test in the guard;
  - the worker-write list gains step 8's write.
- **`API-63` (04:1423-1428):** the entry test becomes the marker.
- **`OPS-45`:** a dated pointer in the scope sentence (03:1334-1337). The new rule falsifies its "rather
  than from anything the engine can record about itself" (03:1336-1337).
- **`OPS-11`:** a pointer that the startup exception is not a classification (03:1385-1387).
- **`LDG-39`:** the deterministic row names this case.
- **`CONTEXT.md` Marker (148).**
- **`Restore.lean`:**
  - `passOp` (336-341) gets a create branch under `!f.isRestore`;
  - `Op` (66-70) gets a recorded field;
  - `restart_never_reorders` (596) is re-proved.
- **A new CNF next to `CNF-290`**, in `CNF-302`'s kill-timing shape:
  - kill before step 8 commits, then restart: expect `failed` and released;
  - kill after step 8 commits: expect `needs_reconciliation`;
  - both an auction-channel and a standard-channel descriptor;
  - a restore control that expects `needs_reconciliation`.
- **A new ADR, `ADR-0042` (next free),** with a dated pointer in `ADR-0035`'s rejected bullet
  (adr/0035:59-61) saying it rejected a *set* marker and not this null case. This is opus's and fable's
  pick; astra and sol would amend `ADR-0035`.

**`pv-qga`:** decide together; keep two beads; pv-qga depends on pv-k4l.

- Shipped alone, pv-k4l makes an *interruption* during step 4 settle `failed`, while a *timeout* of the
  same read still parks under `OPS-11` (03:262-264) and `CNF-31b` (10:205).
- If pv-qga settles `failed`, this marker is its evidence. pv-qga then owes `CNF-31b`, `OPS-11`'s create
  row, `Tables.lean` and `ADR-0035`'s Q11 rejection (adr/0035:107), and it adds `OPS-21`'s cancelled
  `execute`.

**Category `bug`; state `ready-for-agent` once the owner decides.** `API-63`'s "a claimed create with no
entry ... does not dispatch" (04:1423-1424) is not guaranteed on Robot's standard channel (4-0). That is a
false statement inside a requirement, and the fix repairs it. Earlier, before the panel, the manager leaned
`enhancement`.

**Queued for the owner after the shape:**

1. new ADR or an `ADR-0035` amendment (2-2);
2. the pv-qga dependency (2-2);
3. whether the standby-promotion gap gets its own bead (pre-existing; reaches `queued` creates too);
4. the category.

## Round r56b: where the record lives, 2026-10-17

The owner asked for a second round before deciding the shape. The brief and the four answers are in
`r56b/`. The same readers ran at the same models and efforts, on fresh clones at `96ce45c` (gates green
there, exit 0). The round was meant to be blind:

- the brief stated the round-one split as 2-2 without naming who picked what;
- the clones held neither this synthesis nor the r56 answers (both uncommitted) and had no remote;
- the brief said to read nothing outside the clone.

That did not make the main working tree unreadable. A grep of the four transcripts finds no read of it or of
`r56/` (the codex `.err` streams and the Claude session logs). Each side's strongest r56 arguments were
written as claims A1-A3 (column) and B1-B3 (`none`) to break. Each reader wrote its pick's edit in its clone, then planted a
plausible bad later edit and ran `tools/check-all.sh` both times. All four exit 0. Their scratch diffs
stayed machine-local. Every gate result below was checked against the readers' own logs, and every
`file:line` against `96ce45c`.

### Picks

| | fable | opus | astra | sol |
|---|---|---|---|---|
| Shape | **1** (r56: 2) | **1** | **1** | **1** (r56: 2) |
| Column name | `correlator_transaction_at` | `order_cleared_at` | `about_to_order_at` | `create_order_ready_at` |
| Deciding claim | A3 | A3 | A3 | A1 |
| ADR | new `ADR-0042`, "Amends `0016`" | same | same (r56: amend 0035) | same (r56: amend 0035) |
| pv-qga blocks on pv-k4l | no (r56: yes) | no (r56: yes); link as related | no | no |
| Expects pv-qga to settle | `failed` | `failed` | `failed` | `failed` |

**Tally:**

- **4-0:**
  - option 1, a dedicated column;
  - a new `ADR-0042` that amends `ADR-0016`, plus a dated pointer in `ADR-0035`'s rejected bullet
    (adr/0035:59-61). All four call it independent of the shape. opus cites `ADR-0035`'s own "## Amendment —
    2026-10-09 … (from ADR-0037)" as the pattern;
  - no blocking dependency between pv-qga and pv-k4l. A live worker knows it reached no mutation, and only
    the restart path needs a durable record.

Every reader moved on at least one question since r56: fable and sol on the shape, astra and sol on the
ADR, and fable and opus on pv-qga. The column name is open; the four names differ, and r56's was `order_armed_at`.

### What decided it: A3

On Robot's standard channel the pair's content at step 8 is unsettled today:

- `PRV-32`: "MUST declare no correlator and `PRV-33` governs" (02:963-964);
- `PRV-9`'s key is uploaded on every Robot channel;
- 05:382 says "`ssh_key_fingerprint` on Robot" with no channel scope.

Option 2 must legislate that content. It either drops the fingerprint as operator evidence or records a
kind that `OPS-38` counts "over every correlator the operation recorded" (fable). opus states the failure
mode: an author who "fixes" 05:382 to null settles dispatched orders `failed`. Under option 1 the gap stays,
but it no longer decides money. sol was decided by A1 instead: `PRV-26`'s "It MUST be opaque and unique per
operation" (02:866).

### Claims broken

- **B1** ("one record, not two that must agree"):
  - broken (opus): the column and the pair record different facts. 05:382 makes the pair "what the create
    wrote into the provider", and `PRV-33` puts the absence in the descriptor, so on a `none` channel the
    two cannot disagree;
  - broken as an equivalence (astra);
  - stands in part (fable): two records in one transaction is the set's normal shape;
  - stands (sol): the shared transaction enforces it.
- **B2** ("`none` is the descriptor's own word"):
  - broken (fable, opus): the stored kinds are "`operation_uuid` where a free field exists,
    `ssh_key_fingerprint` on Robot" (05:382), not the descriptor's `operation_id | per_order_key | none`
    (02:79). `PRV-26` closes the list: "Nothing else." (02:868);
  - stands (astra, sol).
- **B3** ("option 1 still leaves the pair undefined"):
  - broken (fable): undefined under both shapes, and a channel that "MUST declare no correlator" has nothing
    to record;
  - stands in part (opus): the `PRV-26` gap predates option 1. opus also says no `COALESCE` is needed,
    because ordering the release meets condition 7;
  - stands (astra, sol): option 1 still owes a `PRV-26` clarification and `API-63`'s new test.
- **A1** partly broken (astra): the machine pair and its index need no sentinel handling if the sentinel
  never reaches machines. No reader picked option 2, so nobody else attacked A1-A3.

### What would change each mind

- **fable:** a sentence in 05:382 or `PRV-26` that already fixes the pair's value on a `correlator: none`
  channel.
- **opus:** a quote in `PRV-9`, `PRV-32` or `PRV-33` that settles what a `none` channel stores at step 8, plus
  a CNF item asserting the pair is non-null after step 8 on every channel.
- **astra:** an existing rule that keeps the unverified fingerprint independently of the pair, plus an
  explicit exclusion of `('none', NULL)` from every automatic correlator reader.
- **sol:** a checked three-state contract for the pair, with reader tests proving `none` never reaches lookup
  or machine rows and that fingerprints survive independently.

None of these exists at `96ce45c`.

### The plants

Every reader's own edit passed the gates (exit 0). opus, astra and sol put the rule into Lean; fable did not.

| Reader | Planted bad edit | Result |
|---|---|---|
| fable | folds the create into the `refresh` sentence; the record "survives a restore" and the pass reads it on either boot | exit 0, **nothing red** |
| opus | moves the write from step 8 to step 9's dispatch | exit 1, **citations red**: "2 Lean docstring quote(s) found nowhere" (gate-plant.log:102) |
| astra | the column "MUST be cleared with `request` on the payload purge" | exit 0, **nothing red** |
| sol | drops the migration backfill, in Markdown and Lean | exit 1, **formal red**: `claimed_legacy_create_stays_unresolved` refuted |

Both reds came from checks the reader's own edit had added:

- opus's two missing quotes are its own new Lean docstrings: "the same transaction sets the create's
  order_cleared_at" and "step 9 must not begin before this transaction's commit is acknowledged"
  (gate-plant.log:98-101). opus reasons, without running it, that editing only the 05 row would stay green.
- sol's refuted theorem is one sol added in its own edit.

In both red runs every other gate passed. So none of the four bad edits meets a check that exists at
`96ce45c`. The fix's brief should therefore require:

- a Lean restart-only arm in `passOp`, with a restore-trace theorem and its guard witness in `ci.yml`'s list
  (fable, opus). Today `Restore.lean:341` reads `| .running, _ => { o with status := .needsReconciliation }`,
  and `Fence.lean`'s `interrupt` (977-979) does the same;
- a migration theorem (sol);
- a CNF item that the column survives the payload purge, which is outside the Lean model (astra).

### Found in passing

- **`README.md`'s ADR index stops at `0025` (README:96)**, while `docs/adr/` runs to `0041` (fable, opus;
  verified). Not filed: it is an index, not a requirement.
- **Standby promotion (opus).** opus's edit made every promotion of the asynchronous standby a full `STO-54`
  restore incident. That closes the pre-existing gap above, and opus says it may deserve its own bead.
  Already queued for the owner.

### Reader citations corrected here

- **fable "05:259-261":** "in the same transaction as `offer_id`" is 05:261 and belongs to
  `declared_cancellation_bound`. 05:259-260 say "copied from" the offer or snapshot. The point, two related
  records written together, survives on 05:261.
- **fable "`Restore.lean` 335":** that line is the `@[req "OPS-15"]` tag; the `.running, _` arm is 341.
- **Matched:**
  - 02:866-868, 02:963-964, 02:1025-1026 (`PRV-33`'s "declares the absence as that channel's
    `correlator: none`"), 05:382, 03:382 ("`suspend_tenant` is the other exception"), 03:1386;
  - README:90 (`0019`, "Amends `0016`");
  - `Fence.lean` 977-979, `ci.yml` 685;
  - `ADR-0035`'s 2026-10-09 amendment heading.
  - `0042` is free in `docs/adr/` and the index.

### Manager's recommendation after r56b

- **Option 1, as recommended above, now 4-0.**
- **The ADR:** `ADR-0042` amending `ADR-0016`, 4-0.
- **pv-qga:** no blocking dependency, 4-0. **This reverses my r56 recommendation**, "pv-qga depends on
  pv-k4l". Decide the two together and link them as related.

Still queued for the owner after the shape:

1. the column name;
2. whether the standby-promotion gap gets its own bead;
3. the category (`bug`).

## Owner decision (2026-10-17)

1. **Shape: option 1, a new column `operations.about_to_order_at`**. It is written in `OPS-43` step 8's
   transaction and read only in its null case by a new `OPS-15` restart exception. This is r56b's 4-0
   pick; the name is the owner's choice of astra's proposal.
2. **ADR:** a new `ADR-0042`, which amends `ADR-0016`, with a dated pointer in `ADR-0035`'s rejected bullet
   (r56b 4-0).
3. **pv-qga:** linked to pv-k4l as related, not blocking (r56b 4-0).
4. **Standby promotion:** under the owner's standing rule it is a behaviour gap, so it gets its own
   needs-triage bead.
5. **Category:** `bug`. pv-k4l is `ready-for-agent`, with its agent brief in the bead's comment.
6. **The README ADR index** is brought up to `0041` in this change, in scope.
