# r66c tally (panel D, pv-buc, Fence G). 2026-10-24 17:05Z

All four exited 0. Answers: fable.md, opus.md, astra.md, sol.md. Rules: notes.md (set before launch). Master `d78085a`.
Claims checked with `git show d78085a:<file>` and postgresql.org/docs/18 (quotes below).

## Verified brief errors (Q1's story only; none touch Q2 or Q3)

1. **Two shapes, not three** (opus, astra, sol). Story "In place ... so E's lock connection drops" holds only for a
   physical restore. `STO-51` is "a **session-scoped advisory lock** on a fixed key, released when its session ends"
   (05:89-90); pg_restore "connects to that database and restores archive contents directly into the database", and
   `--data-only` restores "Table data, large objects, and sequence values". A logical reload into the running server
   leaves E's lock session up: a third shape, E sees no loss and keeps writing at g. Same qualification applies to
   r66b's trace (b).
2. **"Nothing makes a surviving E read it again"** (sol). `OPS-41` (03:950-951): "A worker claiming **any**
   exposure-reducing cancellation MUST read the restore record (`STO-56`) at each such claim". Does not close the
   window (before the record commits there is nothing to read).
3. Appendix (r66b text, brief.md:312) quotes "*Before the first claim*"; 05:1542 has "*Before the first claim:*"
   (fable, opus). Grep-level only.
- Recorded, not counted: astra's "AGENTS.md:4 alone does not prove no build exists" (the owner's answer is the
  authority; D4 rests on it); opus's Appendix truncation of the row-lock quote (harmless, not checked).

**Void rule applied to Q1:** errors 1-2 are verified premise errors, so Q1's reader counts are void. The drafts do
not rest on them: every draft treats the logical-reload shape (opus (d) + scoped barrier; astra "Scope"; sol's
reason; fable's chain is method-independent), and error 2 changes no draft. The owner question below uses the
corrected three-shape story. If main reads the rule strictly, Q1 is (b): one correction, same drafts.

## Q1. App-side restore check (drafting; outcome (c), owner question)

| | fable: write chain | opus: start instant | astra: session witness | sol: none sound |
|---|---|---|---|---|
| Mechanism | table of (generation, seq); engine remembers highest acked seq; each checked tx reads that row (missing = backwards, exit), each write inserts next | `pg_postmaster_start_time()` read beside the generation in G's first statement; equality on the pair | separate session holds 4 advisory locks = random 128-bit signature; each checked tx reads `pg_locks` for them (retained PID, DB OID) | no engine-local check covers an unrestricted restore; keep barrier |
| New state | 1 table, 2 cols; 1 row per engine write for the whole process life ("No writer but the advance ... deletes") | none (engine memory holds the instant) | 1 connection, 4 locks, new exit | none |
| Per tx | 1 index read + 1 insert (foldable) | 1 server value in the existing statement | `pg_locks` scan in every checked tx | none |
| CNF / Lean | `CNF-370` delta, `CNF-371`; Lean docstring (or a pair if `ADR-0025`:118 binds) | `CNF-370` replaced (5 cases); maybe one witness pair | `CNF-370` delta, `CNF-371`, `CNF-366` delta; new param + theorem pair + `StopRecord` event + disjunct | F3 unchanged |
| Spans | ~9 | ~8 (+`STO-56` with S2) | ~20 (+ `STO-55`, `OVR-19`, span 20, `OPS-21` lists) | `STO-59` reword |
| Rating | medium | small | medium | (large for a complete one) |
| Barrier still needed | no (its claim) | yes, Reader Z's, scoped to restores that start no server | yes, Reader Z's | yes, Reader Z's |

### Checks against d78085a and PostgreSQL

- **Opus.** "Returns the time when the server started" (functions-info); archive recovery is "Stop the server, if
  it's running." ... "Start the server." (continuous-archiving): verified, so a physical restore, another server
  and a promoted standby all report a different instant. Outside the store, survives as claimed. Its self-reported
  cost verified as real: after **any** PostgreSQL restart, R's stop records are refused and `OPS-15` classifies the
  rows, so pv-buc's create-settle example ends `needs_reconciliation`, partly undoing R as r66b accepted it 4-0.
  `CNF-366` kills a backend (Appendix), not the postmaster: unaffected. `CNF-365` (10:1110) "crash the primary,
  restart it in place": its flush assertion stays reachable. S2 (api) changes `STO-7` (05:164 "whether the restart
  was in place or after a crash"): api exits at its first write after any restart. Crash-reinit start time is
  undocumented (page silent); either reading only adds false positives, never a stale write. Gap: logical reloads
  (including drop-and-recreate) and storage reverts under a live server. **Sound within its declared scope.**
- **Astra.** Session advisory lock "is held until explicitly released or the session ends"; `pg_locks` "provides a
  global view of all locks in the database cluster"; and "could have some impact on database performance if this
  view is very frequently accessed": all verified. Outside the store, survives as claimed. Covers what opus covers
  plus logical restores that end sessions or recreate the database (`DROP DATABASE` without FORCE "will fail" while
  anyone is connected; FORCE terminates them; a recreated database has a new OID). Gap: a data-only reload that
  keeps the sessions. Same headline cost as opus on a restart, plus a witness-only connection loss exits with no stop
  records. Its item 3 ("intentional additional unavailability") understates this: R already exits on a restart, so
  the extra cost is the lost records and the witness-only exits. **Sound within its declared scope.**
- **Fable.** Engine memory survives as claimed. Its claims hold, but **it does not close the brief's own story**:
  its `CNF-370`(b) admits an idle survivor, which is F3's setup (worker held, no write after the backup), and sol's
  trace (an api write lost by the restore, then E claims into the rewound state) gets through. Its "no barrier"
  leans on span 19's ordering, which binds only components being *started*. Misconfiguration: an idle survivor
  writes until the record commits, and forever if it is omitted. Item 5's "exact refusal for every restore method"
  overstates its own item 4. Not unsound under rule 2: the gap is declared.
- **Sol** counts under rule 3 against an *unrestricted* check: `STO-54` says "A store restored from backup" with no
  restriction on method. Its trace refutes fable's idle case. It does not make opus or astra unsound, because both
  declare the gap and keep the barrier for it.

### Grouping

No convergence on one design. Opus and astra are one family (server-lifetime state outside the store) with the same
hole (logical reload into a running server) and both keep Reader Z's barrier for it. Fable stands alone (engine
memory). Sol proposes no check. Converged: all four reword `STO-59`'s "written twice" in substance (restoring bytes
is not a write; trace (c)); the three who keep a barrier all pick Reader Z's text (opus scoped); all four keep the
promotion stop rule (05:1507-1508); only opus's S2 checks api, and writes only.
**Smallest and sound: opus.** Unsound: none under rule 2. Fable is sound but partial; astra is dominated on cost.

### Owner question (TL;DR, ready to relay)

**Story.** E is running. A backup is taken. The operator restores it, but E is never stopped. Before the restore
record lands, E writes, for example cancelling a machine whose runway extension the restore just erased. Three ways
it happens: a physical restore restarts PostgreSQL, a restore onto another server behind the same address, or a
logical reload into the running server (E notices nothing).

**Options (smallest first). Misconfiguration case for each: the restore opens the store early or skips the record.**
1. **Start instant** (small, ~8 spans, no new tables). G's existing check also compares PostgreSQL's start time.
   Misconfigured: refuses the survivor after a physical restore, another server or a promotion; not after a logical
   reload, so the deployment rule stays for that case. Cost: after **any** PostgreSQL restart, in-flight stop records
   are refused, so an interrupted create ends `needs_reconciliation` instead of `succeeded`. Option: the same check
   in api (api exits at its first write after any restart).
2. **Write chain** (medium, ~9 spans, a table growing one row per engine write). Misconfigured: refuses only a
   survivor that had a write acknowledged after the backup. An idle survivor writes until the record lands, forever
   if it is skipped.
3. **Session witness** (medium, ~20 spans, an extra connection, a lock-table read in every write, the biggest Lean
   change). Misconfigured: like 1, and also refuses logical reloads that drop sessions or recreate the database; not
   a data-only reload. Cost: as 1, and any blip on the extra connection also exits without stop records.
4. **No app-side check; keep the deployment rule** (Reader Z's text). Misconfigured: the survivor writes into the
   rewound store until the record lands, forever if it is skipped.

**Readers:** 1 / 1 / 1 / 1 proposed. 3 of 4 keep the deployment rule alongside any check (Reader Z's text).
**Recommendation:** 1 (no new state; covers every restore that restarts or replaces the server), deployment rule
scoped to logical reloads. Whichever is picked needs a reading round of its exact text before the Run (no reader
read another's text).

## Q2. F1-F9 confirmation: outcome (a)

4-0 ACCEPT on every item (fable, opus, astra, sol); no CANNOT ACCEPT; no contradiction found. W-1, W-2 applied.
Non-blocking notes, wording only:
- opus, F3: cites `STO-56` for the fresh value, but span 19 puts the MUST in `STO-54`;
- fable: F3 leaves the Appendix's "[took: Reader 1's (B5)]" note stale;
- opus, F1: 03:1877 names two exits but is not a closed list;
- astra and sol: F3 does not fix `STO-59`'s "written twice" (Q1's rewording does).

## Q3. Drop of D1-D4: outcome (a)

4-0 none found beyond D1-D4. Each searched the Appendix for `STO-13` and "Q3", and `d78085a`. `STO-13`'s "Rollback is
the previous binary against the current schema" and the about-to-order "rollback past this release is
inadmissible" are independent (sol, opus, astra). D4: fable keep (add the owner's dated quote), opus keep, astra
change (rewording), sol nothing. Neither astra nor sol shows D4 false with a quote, so **D4 is kept** per
notes.md. Fable's and astra's rewordings go to the Run text as wording.
