# Panel C owner questions (r63 → r63b → r63c), 2026-10-23

Voted text: /var/tmp/provisiond-panel-r63c/forms-final.md (S' = Q1, F' = Q2). Tallies: r63/, r63b/, r63c/ tally.md.

## Q1 (pv-s4m): is switching to the backup database a restore?

**TL;DR.** 10:00:00, a customer buys a server; the main database writes "ordered"; the backup is a second behind.
10:00:01, the main dies and we switch to the backup. The rule says "don't treat that as a restart", but nothing
tells the engine, so it boots as after a restart, marks the purchase failed and refunds it while the provider keeps
the server. Fix: every switch, planned or not, runs the restore procedure, and nothing connects until the restore
is recorded.

- **A (recommended, 4-0 in r63c).** Promoting any standby is a restore, a planned switchover included. Lands on
  `STO-5/54/56`, `OPS-15` (clause deleted), `CONTEXT.md`, `Restore.lean`, new `ADR-0045`, new `CNF-365`.
  An earlier draft drew 3-1 over the word "asynchronous"; r63c deleted it.
- **B (rejected 4-0 in r63).** A planned switchover shown to have lost nothing counts as a restart. It spares
  planned switchovers the outage, the quarantine and the forced API-token reset. Same ids, plus an exception in
  `STO-54`.

## Q2 (pv-n98): what a restarted engine re-checks mid-restore

**TL;DR.** Mid-restore, a power-off is in progress and the engine crashes. The new engine sees "quarantine done",
skips its startup sweep, and the power-off stays "in progress" forever, so a delete on that machine never starts.
Fix: sweep in-progress jobs at every startup; only the quarantine is one-time. The panel rated this mechanics 4-0.

- **A (recommended, 4-0 in r63c).** That fix. Once the freeze lifts, a suspend-tenant job found in progress goes
  back to the queue (4-0 in r63). Lands on `OPS-15`, `STO-54` step (2), `API-58`, `Restore.lean`, `CNF-295`, and
  `03`'s worker pseudocode.
- **B / C (rejected 4-0 in r63).** Change only the formal model's reading, or reset its "pass done" flag.

## Q3: one Run or two?

**TL;DR.** A scheduling choice, so there's no worked example. Astra and sol: both beads edit the same startup
branch and need one rehearsal. Opus: Q2 doesn't depend on Q1 and could land first.

- **A (recommended, 3-1 in r63).** One Run on `panel-c` for pv-s4m and pv-n98, then one PR: pv-eiql, the panel
  records and the Run.
- **B.** Two Runs: pv-n98 first.

## Full lands-on lists (from forms-final.md)

- Q1: `STO-5` note; `STO-54` new bullet; `STO-56` "restored or promoted store"; `OPS-15` clause ", nor on a store
  that may have lost committed writes, such as a promoted asynchronous standby" deleted; `CONTEXT.md` **Restore**
  plus `:186` "may lose"; `Restore.lean` module doc; `ADR-0045` (amends `ADR-0042`; records B and D as rejected);
  `CNF-365`.
- Q2: `OPS-15` record, restore and parent paragraphs; `API-58`; `STO-54` step (2); `Restore.lean`
  (`stepTwoMarked`, `World.safe` invariant, admission/apply events, `Params.passEveryStartup`,
  `successor_sweeps_running`, witness, `ci.yml` control); `CNF-295`; `03:1686-1688` comment.

## Review points for the Run instruction (unvoted, behaviour unchanged)

- S2's "MUST keep the supervisor (`OPS-47`) and every `api` process from connecting" names something that never
  connects (fable, opus; `OPS-47`: "an external supervisor that restarts it"). Deleting "the supervisor (`OPS-47`)
  and" would leave a restarted engine covered only by the descriptive "only a process started after that commit
  connects". So the smallest fix uses the preceding sentence's own phrase: "the supervisor (`OPS-47`) and every
  `api` process" becomes "every engine and `api` process".
- `Restore.lean`'s provider-application event applies `running` rows only (fable, opus). The gate fails otherwise.
- `CNF-365`: claim the first create before cutting the standby off, so the test reaches the create exception
  (opus, one reader).

## Candidate bead (not filed)

- astra (r63): a second loss while a restore record is already open, such as a promotion mid-incident. The
  successor continues with the quarantine marked done, so a create admitted after step (3) and lost again can
  order twice. This is beyond pv-s4m. It would be a needs-triage bead if the owner wants it.
