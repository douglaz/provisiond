# r76 Panel A, reader 2 (opus)

**Scope.** Clone at `4662d85c7e67c2ebb4c5c8e1c98dc6e1c0efc239`. I made no source edits and used no br, agents or database.

**Gate.** `nix develop --command bash tools/check-all.sh` ran unpiped, with output redirected to a file. It exited 0 and all seven gates passed. My draft was in the untracked `.r76-draft/` at the time, and stays there.

**Reading.** I read in full the four r75 answers, the tally, the claim audit, notes.md and every r76 candidate. Every replaced anchor occurs exactly once in the pin after whitespace normalization: T1a–T6, both CNF-362 sentences, STO-54 step (1), 05:1656, CNF-295, both STO-55 sentences, CNF-290 and OPS-47. This is a trace review, not a prototype.

**Disclosure.** I wrote A2 and B2 in r74.

I applied notes.md rule 6 exactly as written; this prompt adds no void rule.

---

## Q1 — P4C

**1. Authority boundary**
- P4C prevents *managed* changes, meaning changes routed through the authority. A sole authority owns configuration, reloads, role and database defaults, deployed SQL (triggers, `SET LOCAL` functions), routing and credentials. It refuses unsafe changes while components serve.
- `synchronous_commit` is user-settable, so session safety rests on trusted component SQL. P4C says this: "parameter ACLs do not restrict user-settable GUCs".
- It uses no command-line pin. It disclaims bypass: "Administrative bypass remains outside prevention", and likewise a privileged change that is reversed between two observations.
- It rejects another session's SHOW as evidence.
- The result is a coherent trust contract, not an inspection API.

**2. New-use bounds**
- Evidence lapses at request start plus V. Late receipt cannot extend it, and disconnected components expire on their own.
- Suppose drift starts at time d. A round that starts by d+C and finishes by d+C+Q catches it. Any "safe" evidence was requested before d+C+Q, so it lapses by d+C+Q+V.
- Both printed bounds therefore hold, provided local monotonic enforcement works, which P4C states.
- COMMIT is not gated. A transaction admitted before expiry may send COMMIT after it. P4C says so and asserts no completion bound. That is correct, because no spec parameter bounds total transaction length.
- api success after refusal is suppressed. Provider actions already dispatched are disclaimed.
- STO-7's deposit check reads standby positions directly. Deposit exposure therefore survives an empty-standby-list bypass anyway.

**3. Residual session (decisive under the literal reading)**
- STO-7 paragraph 2 says "Busy-session evidence persists only while original session identity and enforced unchanged settings are established; otherwise it is unobservable".
- Paragraph 3 says "Unsafe or unobservable posture evidence MUST latch refusal".
- The trace runs through CNF-296. Its step "Exercise a contending engine write and assert `OPS-49`'s bounded retry and exit" leaves a waiting backend whose settings no live component can establish. The latch trips, and only an operator reset clears it.
- So CNF-296's "Then stall one only and assert an engine write and an `api` write each succeed" becomes unreachable within the drill. That is a checked CNF verdict lost.
- Another reading has the latch consume only the observer's configuration and topology evidence. The text does not choose between the two readings.
- P4C's carve-out ("A known residual backend alone is not evidence of unsafe …") says *not unsafe*. It does not say *not unobservable*.
- Its fixture line "retain its known backend identity while it remains" names no one who retains it. The successor cannot know its predecessor's process IDs without a durable record. That makes the line either a silent ledger of the kind Q3 proposes, or vacuous.
- Retained identity would not prove the backend's setting anyway. The sound argument is that such a backend receives no further statement from any component. Its COMMIT is already sent and governed by server posture.

**4. Reads and records**
- **CNF-296:** reads survive on retained admitted sessions, as P4C's restriction states. Standby loss alone never latches.
- **CNF-299:** a healthy scenario, so unaffected.
- **CNF-362:** the two replacements and the refusal control keep `StopRecord.finished_unrecorded_exit` (StopRecord.lean:432) intact.
  - Denied tries consume `storeBudget` or the bound.
  - The later-stop and superseded exits are unchanged, and no immediate exit is added.
- **"Inside `execute`" arms:** these "store working again" arms are unrestricted, but there is no flip. Under posture denial their asserted outcomes still match through `OPS-15` restart classification: marker committed gives `needs_reconciliation`, refused gives `failed`, and nothing is dispatched.

**5. Collateral**
- The OVR-19 rows are printed.
- **Omission:** latch durability across an observer restart is never exercised. "Resumption requires operator reset" implies it.
- **Cost:** the observer needs a fresh connection slot every C. The base already leaks residual slots ("hold slots outside this `max_connections` account"). A legitimate long stall can therefore starve the observer, and that latches into a manual reset.
- **Cost:** "verify applicable transaction settings before use" may mean a read per transaction, which is an owner choice.

**6. Per-commit alternative**
- For "an acknowledged commit is on a named standby", per-commit confirmation is technically stronger. It needs no trust boundary, has no window before detection, and survives root bypass.
- It gives no idle detection and no protection for read-only effects (`pv-v4gp`). Its global target can include later WAL.
- A2's printed defects stand, and no complete reviewed form exists, so it is not a candidate here.

| Form | Verdict |
|---|---|
| P4C | **AMEND, behaviour changed** |

**Q1-A1**
- Location: STO-7, second added paragraph.
- Before: "A known residual backend alone is not evidence of unsafe replication configuration or topology; this observer does not establish a residual-capacity bound."
- Replacement:
  > Busy-session evidence is required only for sessions a live component can still use. A backend left by an exited process, or on a transport its component has found dead, receives no further component statement; neither its existence nor its unestablished session evidence is posture evidence, safe or unsafe, and this observer does not establish a residual-capacity bound.
- **Behaviour changed.**

**Q1-A2**
- Location: CNF-296 addition, first paragraph.
- Before: "After a contending engine exits, retain its known backend identity while it remains; residual existence alone is not posture drift."
- Replacement:
  > After a contending engine exits, the harness records its waiting backend's identity for verification only; no component, observer or authority is required to retain it. Assert that neither that backend's existence nor its unestablished session evidence trips the posture latch.
- **Behaviour changed.**

**Preference:** NONE among acceptable printed forms. Amended P4C is unreviewed.

**Strongest argument:** prevention needs a boundary that controls changes, because a poll cannot retract a reply.

**Conditions:**
- an exclusive authority;
- trusted SQL;
- monotonic local enforcement;
- a functioning observer with budgeted slots.

**Omissions:**
- no fixture for latch persistence;
- no observer-restart trace.

**Owner costs:**
- the control plane;
- restricted administration;
- maintenance and observer-failure outages that need a manual reset;
- setting verification;
- api exit on refusal, which creates residuals.

---

## Q2 — UO and F (U2R)

**Proof**
- Let R be the last replayed commit or abort record, with timestamp s, and let e bound the source clock's error. R's true generation time is then at least s−e = b.
- Suppose commit C is acknowledged at t_a < b.
- C is inserted before it is acknowledged. R's timestamp is taken before R is inserted (xact.c:1446). So t_ins(C) < t_a < b ≤ t_gen(R) ≤ t_ins(R).
- WAL reservation order then gives LSN(C) < LSN(R). Any continuous prefix on matching ancestry that contains complete R therefore contains C.
- Abort records behave the same way.
- **No delay bound is needed, and no countertrace exists.**
- Opus's r75 sentence "A commit generated after that time is absent" is false:
  - R samples 10.
  - C samples 11, inserts, flushes and is acknowledged at 12.
  - R inserts at 13.
  - With s = 10, C survives.
- The upper bound is f. Every old-history acknowledgement comes before stopping and fencing. Those come before the incident transaction starts, which is at or before restore_instant + e_event.
- **[b,f] is correct.** b certifies only acknowledgements strictly before b.

**Formal check**
- `RestoreTrace.store` writes `restoreInstant := t.now` (:168). `afterCrash` loads `now` from it (:437), and `bootRestore` uses `t.now` (:541).
- No live prose consumes `restore_instant`; 05:1571 is withdrawn text.
- The insert transaction's `transaction_timestamp()` refines "now is the restore instant; time does not advance". Restore.lean:57 already separates step (3)'s instant from it "by however long steps (1) and (2) took".
- Both candidates keep the assignments and `step_three_writes_grace` (:548), and both disclaim model proof.
- A comment clarification is enough to keep the formal model in step. Neither candidate prints its exact text, which is editorial; behaviour is unchanged.

**UO**
- It persists nullable b and f, plus a non-null evidence reference. Continuations reuse them unchanged.
- It has a separate e_event and provenance. It captures the observation before restart, or identifies the record in retained WAL.
- Inconsistent evidence becomes unknown.
- It adds no hold, and the ADR-0047 ordering is untouched.
- Its CNF-365 null arm excludes "retained fallback proof".
- The fixture list includes CNF-358's Restore control and the seed rows. I audited every checklist mention of "restore" and found no further arm:
  - CNF-138, 202, 241, 277, 278, 306, 310 and 311 are unrelated.
  - CNF-288 and 312 are pointers.
- **Verified wording repair** (behaviour unchanged; counts ACCEPT under rule 1). UO inserts its definition *before* step (1), but its step-(1) replacement says "the possible-loss report defined below". Change "defined below" to "defined above".

**F**
- Its finite hold is sound by the same proof.
- **Defect 1.** "Report possible loss within (b,f]" asserts that a commit acknowledged exactly at b survived. F's own certificate covers only commits "acknowledged before b".
- **Defect 2.** "U2's new CNF-365 restore drill" is referenced, not printed. Its arm "switch segment removed before capture: no record, no component start" contradicts F's own fallbacks:
  - "recover the identified record from retained WAL";
  - "An earlier fallback b requires the same inclusion proof".

  Any retained or archived record with evidence releases the hold, and the assertion then fails.
- The drill's first arm says "last replayed transaction's time", which misnames the observation. It also asserts nothing about `loss_end_at`.

**F-A1**
- Before: "Report possible loss within (b,f], whose duration bounds possible loss rather than measuring it."
- Replacement: "Report possible loss within [b,f], whose duration bounds possible loss rather than measuring it."
- **Behaviour changed** (report payload).

**F-A2**
- Before: "and U2’s new CNF-365 restore drill"
- Replacement: "and the CNF-365 restore drill below". Append within CNF-365:
  > Promote, as an operator's restore, the standby with the unavailable report; assert `lost_window_starts_at` is its last replayed commit-or-abort record's timestamp less the allowance and `loss_end_at` is the record's `restore_instant` plus the allowance. Repeat with that store restarted, its switch segment removed before capture, and no retained or archived WAL record supplying an evidenced lower bound: no record, no component start.
- **Behaviour changed.**

| Form | Verdict |
|---|---|
| UO | **ACCEPT** (one verified wording repair) |
| F | **AMEND, behaviour changed** |

**Allocation.** Both candidates omit U4's gate. Two things stay as they are and are still not enforced against an undersized gap, a defect that already exists:
- the no-reissue rule (05:924, "Allocated strictly increasing and never re-issued");
- CNF-297's single fixture.

The omission avoids a new mechanism and changes no obligation. It needs its own bead.

**Preference:** UO, the only acceptable printed form. On mechanics, both work once F is amended.

**Strongest argument:** nothing automated consumes the bounds. The bump, quarantine and skip do not depend on the window, so a hold buys a human report at the price of an outage.

**Conditions:**
- the observation is captured before restart, or the record is identified in retained WAL;
- clock bounds are verified, with provenance;
- evidence is retained outside the failed domain.

**Omissions:**
- migration of an open row that predates the change (UO's non-null reference, F's non-null bounds);
- exact text of the formal comment;
- 05:1643's "lost window" wording, which stays true.

**Owner costs:**
- UO: nullable schema, evidence references, clock and capture discipline, and routine "unknown" reports.
- F: the same, plus a possibly indefinite outage.

**Tradeoff:** honest unknowns with availability (UO), or a guaranteed finite interval (F).

---

## Q3 — B3R and B4*

**Common invariant.** Every controlled backend maps to its own unreleased one-backend grant, so actual controlled backends ≤ unreleased grants ≤ C. Both forms rest on the same rules:
- **Grants:** a grant is durable before the dial.
- **One physical attempt:** a grant covers one *physical* attempt, with no redial. libpq host or SSL fallback therefore needs its own grant or is denied.
- **Unknown attempts:** they stay charged.
- **One issuer:** a single serialized issuer with no fallback. Controller failover stays inside it, and the competing-issuer drills exercise it.
- **Binding:** grants bind the boot identity plus PID and `backend_start`.
- **Release:** it needs fenced delayed capabilities and fresh evidence that the backend ended.
- **Lost count:** if the count is lost, it fails closed.
- **SyncRep:** leaving SyncRep is never a release.
- **Incarnations:** "server-incarnation termination" must mean every incarnation that could have accepted the attempt before fencing. That is the only safe reading, and both texts permit it.

**C1 (not defended)**
- A failed check after the freeze is "closed unused" (05:194–196), but the physical backend is still created.
- The r63h replacements made before local flush remain, and so does the residue of failed checks.
- Both forms keep STO-7's check.

**B2 dissent (mine, carried faithfully)**
- Role counts cover residual authenticated backends. They need no external journal, add no availability dependency and need no reconstruction shutdown.
- But PGPROC allocation precedes authentication and the role and reserve checks (postinit.c:704/900–951). Redial loops therefore occupy slots before they are refused.
- Its weaker class bounds authenticated occupancy only. It does not meet "must not spend that slot again until it is known free".

**B3R**
- Strengths:
  - Allowances get "the same before-dial accounting", so occupancy by observers before authentication is enforced, not just declared.
  - Its observation clause states its resource assumption and freezes otherwise.
  - OPS-47 says "may delay startup indefinitely".
  - CNF-290 keeps the healthy arm.
  - Reads are promised only on retained sessions.
  - The drill is honest: withheld check replies, retained server legs, verified PIDs, and a pause before local flush done with test instrumentation rather than pg_sleep.
- **Defect,** by the standard r75 applied to CNF-362. B3R gates "physical growth" on admission and says that when observation fails it will "freeze releases and admissions". With PostgreSQL working but observation failed, a record write that needs a new physical connection is denied. That covers a lazily grown pool or a replacement connection.
  - The record exhausts its bound. "The engine exits only after the record lands" (10:1681) then fails within the scope of "with a working store".
  - CNF-57's "start N−1 binaries … assert they serve" and "one waits on `STO-12`'s key" likewise need admission.
  - B3R prints neither restriction. It also leaves undefined how the engine responds to refusal at startup (brief item 5).

**B3R-A1**
- Location: after B3R's "CNF-296/299: add …" edit, insert a new edit.
- Replacement:
  > CNF-57/362: successful-service and successful-recording cases retain deployment admission for every physical connection they open. Append to CNF-362: "With PostgreSQL working but `STO-55` admission denying every record attempt's physical connection, assert no SQL is sent, existing exhaustion bounds end recording, the row remains `running`, and restart recovery applies."
- **Behaviour changed.**

**B3R-A2**
- Location: B3R's OPS-47 replacement.
- Before: "exhausted admission may delay startup indefinitely."
- Replacement:
  > exhausted admission may delay startup indefinitely. Startup acquisition refusal exits non-zero having claimed nothing, for supervisor retry; `api` refuses `overloaded` before any transaction under `STO-55`'s checkout bound.
- **Behaviour changed.**

**Editorial for B3R (behaviour unchanged)**
- "fresh authoritative evidence" should read "…, read in a fresh transaction".
- The OVR-19 rows should read "no — outside the process", per OVR-19's definition.
- The drill can be appended to CNF-296.

**B4\***
- It is explicit everywhere B3R is silent:
  - startup exit for supervisor retry, api overloaded, worker store error and Stop-record routing;
  - the fresh-transaction read;
  - CNF-57/296/299/362 restrictions;
  - an honest drill based on withheld check replies.
- **Weakness:** its "Bounded observer/operator/other-client allowances A" has no before-dial mechanism. "Reserved observer access" therefore rests on a declared bound, not enforced ingress.
  - Component accounting is unaffected.
  - Observer failure fails safe ("denies growth and retains charges").
- Its startup exit comes before any claim, so StopRecord is unaffected.
- OPS-47 omits "indefinitely". CNF-290's "delayed startup until verified capacity release" carries the same unbounded delay anyway.

| Form | Verdict |
|---|---|
| B3R | **AMEND, behaviour changed** |
| B4* | **ACCEPT** |

**Preference:** B4*, the only acceptable printed form.

**Strongest argument:** every physical backend maps to a durable charge that only fenced termination releases, and every consumer path is printed.

**Conditions:**
- complete ingress control;
- one physical attempt per grant;
- the declared allowance A actually respected;
- fresh privileged observation;
- the authority failing closed.

**Omissions:**
- B4* leaves allowance enforcement to the declared bound.
- Neither form lets a fenced enumeration show that an unidentified attempt is absent, so only a primary restart releases one.

**Collateral (both forms, disclosed, no verdict flip):**
- STO-55's "nothing starves the exposure-reducing components behind the workers" narrows to reservation within each process.
- OVR-18's "the restart window is the accepted outage" becomes unbounded under exhaustion.

**Owner costs:**
- the durable authority and ingress;
- reserves;
- indefinite restart delay;
- primary restart to reclaim unidentified charges;
- reconstruction shutdown.

Capacity is conditionally safe; service is not guaranteed.

---

## Q4 — T-known

| Form | Verdict |
|---|---|
| T1–T6 whole | **ACCEPT** |

**Traces**
- **Valid tie.** STO-54 says "both hold a prefix of one WAL sequence" (05:1540–1541). Either standby therefore holds every acknowledged commit, and T4/T5 restart either one.
- **Greater or behind.** The greater may restart; the behind one needs an operator restore.
- **Unavailable or other-timeline report.** These never take the equality path.
- **Known prior unsafe commit, or a known cancelled waiter.** These are restore-class under STO-54's existing list ("after the primary committed without one of them … or had a waiting backend cancelled or terminated"). Automatic failover "promotes only as a restart", so it leaves the store without a primary.
- **The restriction.** "each made known to the deployment's procedure" exercises that existing classification by injecting knowledge, with no detector. ADR-0045's "nothing in provisiond sees it" makes the unrestricted form unreachable.
- **Open record.** The incident continues (05:1544–1545). A marked step does not run again; an unmarked step (3) still bumps.
- **Unchanged text.** Stopping, fencing and other-standby streaming are retained verbatim.
- **Two generations.** OPS-15's startup generation is distinct from the tenant credential generation, and T5 asserts both.
- **Scope.** Nothing enters beyond the equality rule, the controls, the pointer and the comment.
  - T6 touches no declaration.
  - Every "further ahead" occurrence is covered: 05:96/1541/1551, 10:1106/1108 and Restore.lean:30.

**Fable's r75 disposition.** The tally was right. The knowledge condition excludes traces where a violation actually happened but is unknown. That is a fixture restriction, so it is behavioural under rule 1.

**Readiness.** The form is technically ready for the owner to choose equality policy, if the panel threshold is met. "Follow-up ticket" was not that choice.

**Preference:** T-known.

**Strongest argument:** max(F,F)=F, so invalidating tokens on a valid tie buys nothing.

**Conditions:**
- truthful same-history reports;
- no open record;
- old processes stopped and fenced;
- the other standby streaming.

**Omissions:** none found.

**Owner cost:** trusting equal reports, which equality does not authenticate.

---

## Does this brief or my proposed combination contradict itself?

**No premise is broken, and no tally is void.** I found five brief or record errors:
1. **Quota rule.** The brief cites the "current >80%/unreadable rule". STATE.md records an owner amendment ("until 100%") and a launch at 83% of the Codex weekly quota. The brief's rule would have held that launch. This is operational, and no vote rests on it.
2. **Launch claim.** The r75 tally's "prepared and launched" was premature. `check/launch-1028-launch.exit` = 0 and STATE.md ("r76 LAUNCHED", 01:38:55Z) now establish the launch.
3. **Line reference.** The CNF-297 quote is at 10:1082–1084, not 1081. Trivial.
4. **Q1 premise confirmed.** P4C reintroduces the residual ambiguity the tally meant to remove, through the wording "retain its known backend identity".
5. **My r75 drill.** The pg_sleep correction applies to it. B3R and B4* do not depend on that drill.

**Cross-question effects (no union adopted)**
- Q1 refusal exits create Q3 residuals.
- Q1's observer needs a place in Q3's allowance. B3R enforces one; B4* declares one.
- Q3 exhaustion can starve Q1's observer and trip its latch.
- Q1's recorded violations could supply Q4's "made known".
- An open Q2 incident overrides a Q4 tie.
- Combined Q1/Q3 gates need both admissions and add no immediate exit.

## Strongest requested counterargument, not my vote

- **Q1:** amended P4C still lets a bypass acknowledgement license a provider order before detection. Per-commit confirmation closes that for one round trip and needs no control plane.
- **Q2:** "unknown" may become routine. F's hold forces the evidence discipline that makes reports auditable.
- **Q3:** a durable admission authority is a new single point of failure guarding an availability-only class. Role limits plus primary shutdown need no new infrastructure.
- **Q4:** a broken reporter's false tie looks valid, and a restore costs only a credential bump.
