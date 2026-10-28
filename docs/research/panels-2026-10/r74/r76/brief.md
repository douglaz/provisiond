# r76 — Panel A: exact repaired contracts, independent questions

You are an independent reader in your own clone under `/var/tmp/provisiond-panel-r74/r76/`, at `4662d85c7e67c2ebb4c5c8e1c98dc6e1c0efc239`. Read AGENTS.md and this round's notes.md. Do not touch `/home/user/projects/provisiond-spec`, its branches/tracker, manager brief, other readers' clones, remotes or production. No br commands, source edits, commits, agents or background tasks. Draft only in your own clone. This is a text/trace review; no database prototype or source application is required. Final answer under 3500 words, usable draft by minute 45, launcher timeout one hour.

All relative paths below are resolved from `/var/tmp/provisiond-panel-r74/r76/`, not your clone's working directory. Before deciding, **read all four complete r75 answers verbatim** in `../r75/{fable,opus,astra,sol}.md`, their `../r75/tally.md` and `../r75/check/tally-claim-audit.md`. These are evidence and manager hypotheses, not accepted conclusions. The original packages remain in `../r75/reader-proposals/`; original source excerpts in `../brief.md`. Independently check decisive claims against your clone and primary sources. Pinned PostgreSQL/docs snapshots with URLs/hashes are in `../r75/check/tally-primary/`; optional browsing is permitted. Do not mistake a source-grounded trace for a measured prototype.

Reader authorship: 1=fable, 2=opus, 3=astra, 4=sol. In r75, printed-package counted accepts were Q1 P3=2 and all others=0; Q2 all=0; Q3 B4=1 and others=0; Q4 T=2. These totals do not approve direction, cost or this round's new text. Fable's Q4 AMEND was called wording-only by its author; the tally treated its added fixture knowledge condition as behavioural under rule 1. Challenge that disposition if warranted. **Apply notes.md rule 6 exactly as written; this prompt adds no void rule.** The current user authorized this follow-up despite the inherited no-auto-round wording; no adoption or Run is authorized.

Settled owners: ADR-0045 quotes “I think we should just suppose synchronous replication”, “A: stop on time (Recommended)”, “B: check each new connection (Recommended)”. STO-7 says “MUST NOT release its connection before the reply arrives or the transport is found dead”, “MUST NOT cancel or terminate a primary backend while it waits for a standby”, and “it MUST NOT use a new store connection until one of the standbys”; its deposit check says “Before exposing a deposit destination read from the store, repeat the read-only flush-position check”. Those rules stand. STO-54, as amended by ADR-0047, says “the deployment MUST stop every engine and `api` process” and “MUST start neither component until the transaction that commits `STO-56`'s record (below) has been acknowledged”. That ordering stands. New control infrastructure, per-transaction reads, evidence/schema, unknown-history policy, reserve capacity and indefinite restart delay/outage remain owner choices after mechanics. Do not settle them by implementation analogy.

Operational record correction: r75/tally.md's closing “r76 is prepared and launched” is not a launch receipt. Main stopped preparation before launch. Only this round's STATE.md and unit receipts establish a quota hold or actual launch under the current >80%/unreadable rule.

## Q1 — pv-c7vg, P1 — P4C

Plain terms: replication can be switched off after a check. A poll cannot undo the next reply, so this candidate restricts who can change the deployment and bounds when new work stops after observable bypass/failure. It deliberately permits an already admitted transaction to finish.

Read **all of `q1-P4C.md`** as one UNREVIEWED coordinator assembly, based on P4 plus returned record-fixture repairs and explicit rendering. It is not P3, and neither P3's two accepts nor fable's preferred P4 repair votes carry over. Every new clause/fixture is declared behavioural. Compare the whole form to the returned objections, including opus's per-commit alternative. If that alternative is technically preferable say so; do not pretend a rejected incomplete A2 has become reviewed.

Challenge:

1. Does the sole authority/session/topology boundary actually support prevention of managed changes, with root/transient bypass explicitly limited? Another session's SHOW is not a busy-session inspection API. Command-line pinning protects global reloads, not all session settings.
2. Does request-start evidence expiry yield the printed **new-use** bounds with delayed/disconnected clients and busy COMMIT, without promising total completion/durable-report bounds? Review transactions admitted before expiry, COMMIT sent before/after it, api success suppression and already licensed provider actions.
3. Trace P3's residual-session objection against P4C's explicit scope: posture proof versus residual capacity. Does the candidate silently require a Q3 ledger or certify an unobservable session? Retaining known residual identity is not proof of its safe setting.
4. Trace every CNF-296/299 read, CNF-362 success/later-stop/refused recording case and formal StopRecord exit. A posture gate must not invent an immediate new exit. Check the exact success restrictions, not a healthy observer assumed without a fixture.
5. Audit missing collateral, OVR timing/alarm ownership, connection/observer resource assumptions and setting-verification cost. Base gate success is not operational coverage.

Give ACCEPT / AMEND / CANNOT ACCEPT on **P4C printed as one form**, then explicit final preference P4C or NONE among acceptable printed forms. Print the smallest complete replacement if it cannot be accepted; mark every repair.

## Q2 — pv-3jw6, P2 — UO versus finite U2R

Plain terms: a restored database may lack work acknowledged before failure. Starting recovery at 14:00 does not prove all work through 14:00 survived. Both candidates keep that event separate from the history report. One permits honestly unknown endpoints; the other keeps the service stopped until a finite interval is proved.

Read **all of `q2-UO.md` and `q2-F-sol.md`**. UO is an UNREVIEWED coordinator replacement, including new nullable endpoint/evidence handling. F is sol's exact UNREVIEWED U2R returned in r75, with extraction hashes in check/proposal-extraction.json; its completeness is a review question, including the inherited drill reference below. Do not silently merge them. UO introduces more than fable's original single nullable field; accept/reject its whole schema/certificate/unknown policy explicitly. F is finite-only, not acceptance of unknown-permitted U.

Challenge:

1. Check tagged RestoreTrace.store, afterCrash and bootRestore; keep their execution event distinct from b/f. Is a retained event assignment plus the printed documentation clarification sufficient formal synchronization for each proposal's new exact SQL event definition? A successful Nat theorem does not prove timestamp semantics. Preserve step_three_writes_grace.
2. Verify the inclusion proof for a replayed complete commit **or abort** record. Timestamp generation precedes insertion. Does b=s−clock_error certify every earlier acknowledged commit without claiming timestamp order equals WAL order? Does it need an additional delay bound, and if so give the precise countertrace? Also check endpoint equality and timestamp precision: UO now reports [b,f] because its certificate covers acknowledgements strictly before b; F's exact returned text still prints (b,f]. Opus's returned “A commit generated after that time is absent” is false under an interleaving; neither candidate may inherit it silently.
3. Trace source/event clocks, upper fencing evidence, ancestry, holes, null observations, unavailable old primary, backup restore and interruption. A filename or bare LSN is not a certificate. Evidence production/capture/retention is an operational obligation, not an existing deployment fact.
4. Check endpoint persistence, changing clock allowances during continuation, missing evidence policy and schema seeds. Audit all actual restore arms and seeded open records. CNF-358's Restore control says “restore that backup with an open restore record and start the engine” (10:1540–1543); its restart arms remain distinct. The candidate's named fixture list is not claimed exhaustive.
5. The undersized-gap counterexample is valid and pre-existing: the schema says “Allocated strictly increasing and never re-issued” (05:924); CNF-297 says “exceeds every index a rolled-back row held”. These candidates omit U4's allocation-evidence gate. Does that omission change an existing obligation, or merely avoid an additional enforcement mechanism? Do not waive no-reissue or smuggle in a separate allocation mechanism as wording.

F's reference “U2’s new CNF-365 restore drill” has this exact antecedent in `../r75/reader-proposals/q2-opus.md`:

> Promote, as an operator's restore, the standby with the unavailable report; assert `lost_window_starts_at` is its last replayed transaction's time less the allowance; repeat with that store restarted and its switch segment removed before capture: no record, no component start.

Opus's r75 answer challenges the no-record arm and returns the exact addition “and no retained or archived WAL holding that record” (**behaviour changed**). These are predecessor/repair context, not an adopted union with F. U2R references the drill without printing its whole replacement. Check whether that reference plus U2R's new bounds supplies a consistent complete fixture; if a further restriction or replacement is necessary, return AMEND rather than silently accepting a repaired F.

Give ACCEPT / AMEND / CANNOT ACCEPT independently on UO and F, then a final preference among acceptable complete printed forms or NONE. Judge mechanics separately from owner preference for reporting unknown versus indefinite outage. If both are technically acceptable say so and state the tradeoff; no unread hybrid.

## Q3 — pv-oehp, P3 — B3R versus B4*

Plain terms: a vanished process can leave a database backend consuming a slot. A replacement must not spend that slot again until it is known free. The candidates use external durable grants and accept restart delay when capacity is exhausted.

Read **all of `q3-B3R-sol.md` and `q3-B4star-astra.md`**, exact UNREVIEWED r75 replacements, independently. Their extraction hashes are recorded. B4* says “use the consumer-sentence replacement above”; that antecedent is outside its extracted block. Astra's exact replacement in `../r75/astra.md` is:

> Pool sizing reserves consumer checkouts within a running process; opening or replacing a database connection also requires deployment admission.

Read that sentence as B4*'s referenced replacement of STO-55's “Every consumer then has a connection when it needs one and nothing starves the exposure-reducing components behind the workers”. It is not B3R's different replacement. No union is proposed. The original role-limit alternative and opus's full dissent remain in the required r75 answers; carry its no-external-journal cost argument faithfully, and test whether its accepted weaker pre-authentication class can meet the question's invariant.

Challenge:

1. Prove one physical backend maps to one unreleased grant: before-dial durability, driver fallback/multihost redial, unidentified attempts, controller failover, accounting loss, PID/boot reuse and delayed-arrival fencing. “One library connect call” is not a physical-attempt bound. Leaving SyncRep is not absence. Fresh observations must not reuse a cached activity transaction.
2. Include lock holders, migrators, waiting runners, operator/observer residuals, server-internal resource pools and admission ingress. Is privileged observation actually available under the explicitly stated resource assumptions? PostgreSQL reserve roles alone do not prove protection against pre-limit occupancy.
3. Trace C1 in full if defending it: failing new-connection checks after the freeze forbid successful use, but pre-flush replacement **before** the freeze and failed-check physical residue still exist. Do not lose that guard. Opus's deferred pg_sleep trigger is before HOLD_INTERRUPTS; it is not a demonstrated pause in the interrupt-held pre-flush segment. Use honest test instrumentation or retained server legs with withheld check replies and exact PID verification. No new database experiment is required.
4. A transport cut need not remove every independent read session. Name preserved read sessions; make no read-success guarantee after every admitted read session is lost. Audit STO-55's consumer sentence, OPS-47 restart, CNF-290 healthy versus exhausted admission, CNF-57/296/299 and CNF-362 stop-record success. CNF-290 says “release the first and assert the second then starts”; it states no immediate-start deadline. Fable/opus preserve that healthy-capacity case; the disputed issue is complete exhausted-admission semantics. Exact additional fixture restrictions are behavioural.
5. Check startup acquisition refusal, worker/periodic store errors, api overloaded-before-transaction and recording bounds. No SyncRep cancellation or new immediate exit. Both capacity safety and availability limitations must be explicit; no automatic owner cost approval.

Give ACCEPT / AMEND / CANNOT ACCEPT separately on B3R and B4*, then one preference among acceptable printed forms or NONE. If neither works, return a complete exact replacement rather than a summary of edits.

## Q4 — pv-1i3n, P3 — T-known

Plain terms: after an idle night two replicas can contain the same complete history. Either could then start without invalidating customer tokens. Equality must not erase an open recovery incident or a known earlier unsafe event.

Read **all of `q4-T-known.md`**, the complete r75 T1–T6 assembly with opus's exact one-sentence known-violation fixture restriction. That restriction is explicitly behaviour changed. No Q1 mechanism or general knowledge qualification is added to STO-54's classification rule. All other package text and guards stand. This revised whole package is UNREVIEWED.

Trace valid ties promoting each standby; unequal greater/behind; unavailable reports; different timelines; known prior unsafe commits and known waiter cancellation; open incident before/after step (3); old-process stopping/fencing and other-standby streaming. Distinguish engine startup generation from tenant credential generation. Equality authenticates neither reports nor hidden history. Does the restricted injected fixture exercise existing classification without requiring an unproposed historical detector? Does anything beyond the declared equality/control/pointer changes enter? Verify exact anchors.

Give one ACCEPT / AMEND / CANNOT ACCEPT for T-known **as a whole**, and state whether this exact form is technically ready for the owner to choose equality policy. “Follow-up ticket” was not that approval. A necessary extra fixture restriction is behavioural even when it is consistent with current guards.

## Required ending

For each independent question: acceptance table, explicit preferred printed complete form or NONE, strongest argument, exact conditions and owner costs. AMEND must quote location, before/replacement and behaviour unchanged/changed. A new exception, payload, fixture restriction, conformance assertion or mechanism is behavioural. Do not count preference for an unread repair as acceptance. A collateral loss must name the checked CNF/theorem or quote the MUST/SHOULD owner and concrete trace; new declared obligations/fixture changes are reviewed as amendments, not automatically hidden losses. Cover omissions and costs separately.

Answer “Does this brief or my proposed combination contradict itself?” Identify every manager claim broken and whether its error changes one question's premise under rule 6. State cross-question effects without adopting a union. End with a short **strongest requested counterargument, not my vote** per question. No source application, tracker edit, Run or owner decision is authorized.
