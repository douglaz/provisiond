# r75 — Panel A: compare exact returned contracts; confirm the complete tie package

You are an independent reader in your assigned clone under `/var/tmp/provisiond-panel-r74/r75/`, pinned to master 4662d85c7e67c2ebb4c5c8e1c98dc6e1c0efc239. Read AGENTS.md and this round's notes.md. Do not touch `/home/user/projects/provisiond-spec`, its branches/tracker, the manager brief, other readers, remotes or production. No br commands, source edits or commits requested. Draft notes may be written only in your own clone; a scratch application inside your clone is optional if you explicitly restore tracked files. No agents or background tasks. Final answer under 3500 words; usable draft by minute 45; launcher timeout one hour.

All paths below are under this round directory unless explicitly relative to its parent. Read `../tally.md` and `../check/tally-claim-audit.md` before deciding. They are the tally manager's findings, **not accepted conclusions**: challenge their traces and claims as hard as the candidates. Original r74 brief and exact source excerpts are `../brief.md`; current sources are your clone at the pin. `reader-proposals/<reader>-full.md` preserves every complete r74 answer including its introduction, factual dependencies and requested counterarguments. Per-question extracts are exact bytes, with extraction hashes in `check/proposal-extraction.json`. Use Reader 1=fable, Reader 2=opus, Reader 3=astra, Reader 4=sol for authorship; prior direction totals are not votes on this round's exact packages.

Apply the notes' independent-question procedure. Later tally instruction: **apply notes.md rule 6 exactly as written; this prompt adds no void rule**. Do not import Panel E H/U history or a blanket brief-error void rule. Proposals deliberately amend obligations; an absent new test is not itself a contradiction in the unchanged base. A collateral checked-CNF/Lean/MUST/SHOULD loss needs its named assertion/owner quote and concrete trace. Preserve every stated trust/availability condition and identify unverified PostgreSQL dependencies. Prefer primary source code/docs to assumptions; no costly prototype is required.

Settled: ADR-0045's owner choices “I think we should just suppose synchronous replication”, “A: stop on time (Recommended)”, “B: check each new connection (Recommended)”; STO-7's deposit-read check and SyncRep cancellation prohibition; ADR-0047's stopped-components restore ordering. Quote their owners in any proposed matching changes. Do not alter these as routine fixes. New control infrastructure, hot-path round trips, finite/unknown recovery reporting, restart delay and reserve capacity are owner decisions after technical review.

## Q1 — pv-c7vg, P1

Plain terms: an administrator turns off replication after a connection was checked. A commit can then succeed before the next poll. We need an honest detection/refusal contract, or a stronger enforceable prevention boundary, including the pooler case.

Read all four complete Q1 packages:

- **V1**, Reader 1: `reader-proposals/q1-fable.md` — per-commit replication verification, no monitor/latch.
- **A2**, Reader 2: `reader-proposals/q1-opus.md` — transaction identity/settings, post-commit verification, external posture record; keep its conditional fallback distinct.
- **P3**, Reader 3: `reader-proposals/q1-astra.md` — controlled change authority plus expiring-evidence refusal.
- **P4**, Reader 4: `reader-proposals/q1-sol.md` — controlled authority/observer, permission expiry, bounded refusal and operator reset.

r74 picks: V1, A2, P3, P4 respectively. Each is a different package. None is presumed accepted. Read the exact returned clauses, fixtures, scope, costs and conditions, not just this summary.

Specific disputed traces to test neutrally:

1. PostgreSQL's empty-list reload wakes waiters with WAIT_COMPLETE; verify the source cited in ADR-0045 and the tally. Does each proposal protect only a component acknowledgement or all external consequences it claims? What happens before any next commit or while idle? Is deployment-wide bounded detection supplied?
2. A post-reply current flush target may include later writers' WAL. Does a healthy single/concurrent-writer test distinguish pass, extra standby wait, failed read and warning? V1's rule repeats; its fixture expects a warning event. Can those exact words coexist? No unreviewed repair counts ACCEPT.
3. Transaction pooling may assign the same backend repeatedly, or release it after COMMIT before a confirmation query. Does identity checking establish the uninterrupted PostgreSQL session the proof requires? Distinguish an existing direct TCP connection from a retained connection already fronted by a pooler.
4. Can P3/P4 actually establish all session settings and topology without another session's SHOW pretending to inspect them? Define the trusted control boundary and persistent versus transient/bypass drift. Do permission expiry and refusal remain valid with disconnected components, delayed observations and a healthy busy COMMIT?
5. Trace existing sent-COMMIT retention, stop records, CNF-296's independent read and CNF-362's working-store success. Require exact collateral amendments when new admission refusal changes those fixtures; do not add arbitrary immediate stop-record exits. State owner costs separately.

For each V1/A2/P3/P4: ACCEPT / AMEND / CANNOT ACCEPT as printed, then one final preference among acceptable packages or NONE. If no exact package works, provide the smallest **complete exact replacement** of one package and label it unreviewed; do not call agreement on P or per-commit direction convergence on wording.

## Q2 — pv-3jw6, P2

Plain terms: the promoted store may hold less history than the lost primary. A replacement starting at 14:00 does not prove all history through 14:00 survived. The record needs honest event time, surviving-history evidence and a specified missing-evidence action.

Read all four exact Q2 packages:

- **U1**, Reader 1: `reader-proposals/q2-fable.md` — retain event meaning in restore_instant, nullable history_end_at, unknown permitted, no startup hold.
- **U2**, Reader 2: `reader-proposals/q2-opus.md` — retain event meaning, new finite lost_window_starts_at plus clock allowance; no record/startup without evidence.
- **E3**, Reader 3: `reader-proposals/q2-astra.md` — redefine restore_instant as a certified finite history boundary; no evidence holds record/startup.
- **U4**, Reader 4: `reader-proposals/q2-sol.md` — separate recovery_started_at and nullable history-boundary restore_instant; unknown may continue, but derivation-allocation evidence gates step (3).

r74 picks were U1/U2/E3/U4, not acceptance of one U. The field definitions, unknown-history policies and allocation guard are explicit independent differences; no manager merger is proposed.

Review tagged RestoreTrace.store, afterCrash, bootRestore and Restore.step_three_writes_grace, plus STO-54/STO-56 and all real consumers. In the current formal home event now and history delta are separate. Exact SQL timestamp assignment is still a proposed definition. A changed field meaning needs synchronized formal changes even if existing proofs over arbitrary Nat still happen to compile. Do not reuse a nullable history boundary as an execution clock.

Compare evidence soundness: last replayed commit/abort timestamp plus clock assumptions; ordered trusted-time/insert-position certificate; externally retained named-restore-point certificate. Name what each proves about *acknowledged* commits and continuity/ancestry, clocks, nulls, holes and the unavailable old primary. Do not assume a bare LSN or filename is wall-clock evidence. Trace known boundary, missing boundary, interrupted procedure and backup restore. Keep step-(3) grace independent and stopped-components/acknowledged record ordering intact.

U4 adds a distinct allocation mechanism. At the pin 05:924 says “Allocated strictly increasing and never re-issued”; CNF-297 says “exceeds every index a rolled-back row held”. Is the undersized-gap counterexample valid, pre-existing, and actually within this bead's necessary scope? Review the added gate exactly; do not silently adopt it or waive the existing obligation. List all recovery-success fixture restrictions required by an evidence hold. Identify owner outage/schema/evidence costs.

For each U1/U2/E3/U4: ACCEPT / AMEND / CANNOT ACCEPT, then one final preference or NONE. A finite-only U is not an acceptance of an unknown-permitted U. If a repair is needed, print the complete exact replacement and its scope rather than assembling a hybrid silently.

## Q3 — pv-oehp, P3

Plain terms: a process can disappear while its database backend stays. A replacement connection consumes another slot. A budget must count both across the whole deployment, or explicitly accept exhaustion and operator recovery.

Read all four exact Q3 packages:

- **C1**, Reader 1: `reader-proposals/q3-fable.md` — startup-only primary SyncRep count plus own pool; no external reservations.
- **B2**, Reader 2: `reader-proposals/q3-opus.md` — server per-role CONNECTION LIMIT and residual allowances; explicitly unverified race/pre-auth/reserve dependencies.
- **B3**, Reader 3: `reader-proposals/q3-astra.md` — durable serialized physical-attempt permits outside PostgreSQL, charged unknowns, fenced release.
- **B4**, Reader 4: `reader-proposals/q3-sol.md` — external one-attempt reservations, allowance/residual accounting and explicit consumer-availability narrowing.

r74 C1/B2/B3/B4 direction picks do not establish one common B mechanism. Verify the lone C1 dissent **in full**: the new-connection guard prevents use after a flushed frozen target. Historical r63h trace 1 instead loses transports before local flush and passes replacements on the earlier target before a later freeze. The tally's counterexample repeats reconnects within one live incarnation, so fixed rollout overlap is not a bound. Test it rather than accepting/rejecting it by label. A new physical backend can exist while performing a connection check it will fail.

For B2 distinguish conservative concurrent role-limit refusal from an alleged over-admission race. Inspect the actual source ordering: PGPROC allocation precedes role-limit checks; do transient/unidentified attempts threaten the claimed invariant or recovery reserve? Include lock/migrator/background/admin paths and all allowances explicitly. For B3/B4 prove one backend maps to one charged grant, no redial/bypass, lost state fails closed, and a delayed attempt cannot arrive after release. Leaving SyncRep is not backend disappearance. Observer access itself must stay bounded and available under explicit resource assumptions.

Give a fixture that actually reaches residuals with engine exit, multiple api replicas, dead transports and rollout overlap, preserving the connection check. Request cancellation alone is not enough. Include accounting loss, observer failure, delayed handshakes, PID reuse, exhaustion and verified recovery. Do not assert surviving api reads after killing/cutting every relevant read session. Separate capacity bound from continued-service claims.

Check exact changes needed to STO-55's “Every consumer then has a connection when it needs one”, OPS-47's supervisor guarantee, CNF-290's restart success, CNF-296/299 independent reads and stop-record bounds. Intended holds are amendments; unlisted fixture changes remain findings. For each C1/B2/B3/B4 give ACCEPT / AMEND / CANNOT ACCEPT and one final preference or NONE, with resource/infrastructure/restart-delay cost separate.

## Q4 — pv-1i3n, P3

Plain terms: after an idle night both replicas may have the identical end of the same history. If every other safety condition holds, either contains the same acknowledged work. Treating that as a restore unnecessarily invalidates customer tokens; an already open recovery incident still has to continue.

r74 T policy was unanimous, but companion pointers and the literal positive fixture were not one reviewed package. Read **all** of `q4-T-complete.md` as one explicitly unreviewed coordinator assembly. It contains exact T comparisons, the common maximal-prefix rationale, a bare STO-5 pointer, aligned CNF-365 initial fixture, explicit no-open-record positive fixture, exception controls and a formal-comment repair. No Q1/Q2/Q3 mechanism is imported.

Give ACCEPT / AMEND / CANNOT ACCEPT on T1–T6 **as one whole form**, with exact repairs and behaviour marks. Trace each standby promoted on a valid tie; unequal same-history greater and behind choices; unavailable reports; equal numbers on different timelines; prior posture violation; open record before and after step (3); old-process stopping/fencing and other-standby streaming. Check that token-generation and engine startup-generation behavior stay distinct. Do not invent a proof that historical reports/posture are trustworthy merely from equality. Determine whether anything beyond the declared equality/test/pointer changes is introduced. State whether the exact form is ready for the owner to choose equality policy; “Follow-up ticket” alone is not approval.

## Required answer ending

For each independent question give the acceptance table, one explicit preferred complete package or NONE, strongest argument and exact conditions. Name any changed checked verdict with source quote and trace. Preserve original and newly proposed AMEND text and behaviour marks. Then answer “Does this brief or my proposed combination contradict itself?” Report every manager factual claim you broke and whether it changes one question's premise under rule 6. State cross-question interactions without silently adopting a union. Finish with a short strongest **requested counterargument, not my vote** per question. Do not treat the owner costs as already accepted.
