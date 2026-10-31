# r88 / pv-by1w — opus seat

**Final: C-UNKNOWN.** I'd accept C-UNKNOWN and NEITHER. I cannot accept C-WITNESS as printed. I offer no repaired form for counting.

**Checks I made.** The clone is at 3109b5b and clean. I diffed the three forms in `tmp/opus/`:
- NEITHER's owner and check blocks match `05-persistence.md:1652–1669` and `10-conformance-checklist.md:1184–1220` byte for byte.
- Both amendments only insert text: after line 1669, and before CNF-365's closing citation.
- The bead in `.beads/issues.jsonl` matches `check/bead.json`.
- No Lean declaration is touched. `WalHistory.lean` does not model wait history.

I ran no gate and no Lean job.

## 1. Votes

**C-WITNESS — CANNOT ACCEPT as written.**
- **Reason:** the row asks for "cancellation and abrupt-shutdown coverage", and the form leaves that part empty. It says "Uncontrolled process death, host crash, immediate shutdown and power loss MUST leave an identifiable unresolved coverage interval unless independent evidence excludes a waiting-backend cancellation or termination throughout that interval." It never says what evidence could do that excluding.
- **Why nothing could:** records kept off the primary cannot tell a clean crash apart from an unrecorded release followed by host loss. Such a release could be:
  - a raw fast shutdown;
  - a privileged signal, which the form says the procedure "MUST cover";
  - the postmaster-death branch of the wait loop. The pinned archive notes this path: r63d/fable.md, "the only remaining routes to a visible, unreplicated commit short of postmaster death". The audit does not examine it.
- **Result:** after an unplanned loss, a clean certificate is either impossible, or it rests on an "established" non-bypass that the form never defines and its check never tests. CNF-365's kept arm, "Kill the primary … takes `OPS-15`'s restart branch", then depends on that undefined exclusion.

**C-UNKNOWN — ACCEPT.**
- **Reason:** its refusal rule is exact and fails safe, it keeps the three states apart, and its check closes the false pass in today's CNF-365. The rule: "Classify a known disqualifying condition under the existing restore rule even if another fact is unknown. Otherwise restart eligibility is unknown if at least one applicable restart condition cannot be established."
- I accept it with the costs in §6, which are larger than the brief says.

**NEITHER — ACCEPT.**
- **Reason:** keeping the text loses no checked verdict, and the rule is correct about facts. A promotion after the event "is a restore", and "an automatic failover promotes only as a restart".
- The knowability gap is a consequence nobody tests, not a contradiction (rule 3).

## 2. Traces from the same surviving reports

**Common state:** old components stopped; P lost with its disks and logs; S1 and S2 report equal ends on the old timeline over the same actual history; no open incident. Rows A, C and D give a procedure identical inputs.

| History | NEITHER | C-UNKNOWN | C-WITNESS |
|---|---|---|---|
| **A.** Clean, evidence complete | Automatic restart allowed (either standby) | Restart once negative evidence is established | Restart with a complete valid certificate. After an unplanned loss, only through the undefined exclusion |
| **B1.** Forbidden individual termination, known | No automatic promotion; operator restore ("each made known") | Known disqualifier → refuse; operator restore | Through the gate: the intent records only a "possible effect", so the result is known or unknown, refused either way. **Bypassing the gate:** no record exists; an issuer relying on non-bypass certifies clean → automatic restart → violation. No check arm covers this |
| **B2.** Permitted fast-shutdown termination, known | Same as B1 (no exception in the classification arm) | Same, "including a shutdown-induced termination permitted by the shutdown exception" | Intent before the signal → known or unresolved → refuse |
| **C.** Event happened, evidence lost or hidden | Same inputs as A. Promoting violates in fact; refusing complies. The text gives no instruction and the check does not test this | Unknown → refuse, report, no automatic restore; operator restores or waits | Unknown → refuse |
| **D.** No event in fact, evidence missing | Promoting complies in fact (by luck); refusing also complies | Unknown → refuse (availability cost) | Unknown → refuse |
| **E.** Operator restore, both endpoints unknown | Null endpoints; restore proceeds | Same, stated explicitly | Endpoints do not block it, but the promoted incarnation cannot serve until its evidence record is written |

**Three separate states.** Actual event (columns B and C), what the procedure knows (B versus C/D), and unknown report endpoints (E) stay distinct in both amendments.

**Clean/equal control:**
- NEITHER: passes as today.
- C-UNKNOWN: passes only if the deployment can produce the negative evidence.
- C-WITNESS: likewise, and after the "Kill the primary" arm only through the undefined exclusion.

## 3. Attack on C-WITNESS

- **Ordering:** sound for signals that go through the gate. "A failed or unacknowledged intent write MUST prevent that controlled signal."
- **Abrupt loss:** treating it as unresolved by default is correct, but nothing can resolve it. Unplanned failover therefore never restarts automatically unless the issuer asserts non-bypass. What the mechanism can actually certify is planned, gated, drained stops, where an operator is present anyway.
- **If the evidence service fails:**
  - "Before a primary incarnation first serves component work, the deployment MUST establish an independently durable record". This makes the service a hard dependency of every primary incarnation: every restart in place, and the promoted store of an operator-authorized restore.
  - That is a hold on the restore path. `STO-54:1731–1733` forbids that kind of hold for reporting evidence, and the brief's cost list does not mention it.
  - The gate also blocks fast shutdown while the service is down. ADR-0023 says PostgreSQL "offers only a fast shutdown or a configuration reload as the way out" of a stall, and STO-7 forbids the reload. Immediate shutdown is still allowed.
- **Privileged bypass:** the owner text requires covering "privileged administration". The check's list ("Remove or corrupt records, leave an intent unclosed, interrupt coverage, substitute…") has no bypass arm, and root can always bypass. So "clean" means trusting the issuer.
- **Wrong ancestry:** "Matching timeline labels or larger numerical positions alone do not establish that binding." That is correct, but no binding method is given. This is the same unstated premise as the base.
- **Unclosed intent:** a possible-effect intent resolves only "with authenticated, continuously covered evidence". Under load, any routine fast-shutdown restart leaves one. Resolving it needs a drain-then-signal procedure the form does not state.
- **No expiry, carried forward:** the form "removes neither a known historical condition nor an uncovered interval" and carries uncertainty "across incarnation changes on which a later restart depends". So one abrupt crash and in-place restart can leave a permanent unknown for that primary's tenure. CNF-365's own crash-and-restart-in-place drill is one such crash.
  - Two things are undefined: what "on which a later restart depends" covers, and whether a restore ends it.
  - History from before adoption has no evidence at all.

**Conclusion:** the form is a real contract for the integrity and ordering of controlled records. The original problem — the negative fact — is moved behind an issuer the form doesn't define.

## 4. Attack on C-UNKNOWN; NEITHER's obligation

**C-UNKNOWN:**
- **Positive case:** clean history can be established by "an authenticated source and complete event coverage, or an independently enforced no-event invariant with established coverage and non-bypass", "verifiable without the lost primary or its logs". A design that records events through a gate can reach it. It carries the same unavoidable non-bypass gap as C-WITNESS, but it fails safe and mandates no mechanism.
- **Drift controller:** not required. Paragraph 1 accepts "a trusted deployment invariant whose uninterrupted coverage establishes the fact", which covers STO-7's trusted replication duty, and paragraph 2 disclaims a controller.
- **Asymmetry:** paragraph 2 asks that the no-event invariant be "independently enforced". So STO-7's trusted ban on individual termination is not enough, while the drift duty is. That stretches beyond the drift trust posture; both amendments share this, and it is the owner's call.
- **Reset:** none. "Time, new incarnation identifiers, equal reports or later catch-up do not expire that condition." The inheritance horizon is undefined, as in C-WITNESS.
- **Endpoint bar:** none. "Unknown possible-loss reporting endpoints on an operator-authorized restore are separate".
- **Hidden cost:** operator-started restarts are lost too ("operator belief alone cannot reclassify unknown as established"). CNF-365's restart arms then require "establish complete trustworthy negative evidence", so conformance needs that capability. "A deployment unable to supply the negative evidence may use the operator boundary below" holds for one incident, not for a conforming deployment.
- **Kept sentence:** "until both standbys report or an operator decides" no longer tells the whole story, but the new MUST governs. It is not a contradiction.

**NEITHER — the exact remaining obligation:**
- Automatic failover may promote only when the promotion really is a restart, including that P never "had a waiting backend cancelled or terminated" — shutdown included, with no expiry. Otherwise only an operator starts it, as a restore.
- From identical survivors alone, rows A and C cannot both be handled while keeping the clean restart. The deployment needs knowledge kept off the primary, or prevention: stop components and drain waiters before any graceful shutdown of the primary, and record that off-host.
- Refusing avoids a violation, but recovery then rests on an operator who cannot know either. A cautious restore of a promotion that was actually clean is only implied, by "unless a restore record (`STO-56`) is open there". It is not stated anywhere.

## 5. Verdicts changed, false passes, brief errors

- **Lean:** nothing changes.
- **Current CNF-365 false pass:** "each made known to the deployment's procedure" passes a deployment that would promote in row C. Both amendments add an arm for hidden evidence.
- **Restart arms (both amendments):** the verdicts are unchanged, but the arms now need an evidence precondition. Under C-WITNESS, the "Kill the primary" arm depends on the undefined exclusion.
- **C-WITNESS check, bypass:** with no bypass arm, its positive control and the base restart arms pass on an issuer whose non-bypass was never tested. "provide a complete valid certificate" can be read as the test handing over the certificate. That would test reading certificates, not issuing them.
- **C-WITNESS fixture (a):** "Assert known restore classification only where the retained records validly establish the event; otherwise assert unknown". It passes either way: weak but consistent.
- **Cosmetic:** both amendments move CNF-365's closing citation into its own paragraph.
- **Brief errors** (neither voids anything under rule 6, and none of my votes rests on them):
  1. The C-UNKNOWN cost "automatic availability is lost whenever…" is understated: any restart, operator-started ones included, and conformance on the restart arms need the evidence capability.
  2. C-WITNESS's costs leave out that the evidence path becomes a precondition for every primary incarnation to serve.
  
  The quoted line ranges checked out.
- **Strongest case against my pick:** C-UNKNOWN trades an unmeasured hypothesis plus a misconfiguration trace ("No compliant restart loss of an acknowledged commit is established") for a certain loss of availability. It demands evidence for the forbidden individual path while the owner trusts drift. And its "established … non-bypass" is as undefined as C-WITNESS's.

## 6. Costs, owner decisions, edits outside the blocks

**Costs:**
- **NEITHER:** nothing new. The knowability gap stays unstated in the owner text, and deployments must supply the knowledge themselves.
- **C-UNKNOWN:** no service is prescribed, but any restart needs negative evidence kept off the primary. Without it, every failover becomes an operator restore, even when nothing acknowledged was lost. Each restore brings:
  - the listener down and "exactly five things are frozen";
  - "every `queued` create, install and rescue inventory is moved to `needs_reconciliation`";
  - the step-(3) credential-generation bump;
  - the grace period, plus operator work and longer outages.
- **C-WITNESS:**
  - an authenticated, tamper-evident service outside P's failure domain;
  - incarnation and ancestry binding;
  - interception of every signal path;
  - a hard dependency for the primary to serve at all, and a gate on shutdown;
  - an indefinite unknown after an abrupt loss. It still does not solve the unplanned case.

**Owner policy decisions needed before either amendment:**
1. **What counts as termination.** Does a waiter ended without commit cleanup — crash, SIGKILL, immediate shutdown, power loss — count as "cancelled or terminated"? What about release on postmaster death? The audit says only "An immediate shutdown is not this wait-release/reader schedule."
2. **Trust.** May trusted gate coverage and non-bypass establish the negative? Is the ban on individual termination trusted the way drift is?
3. **Horizon.** What does "inherited … on which … depends" cover? Does a restore end it? How is a database that already exists at adoption treated? The forms supply no reset, and I invent none.

**Edits outside the blocks:**
- No Lean change.
- An adoption record after the rule.
- "Primary incarnation" has no `CONTEXT.md` entry.
- C-WITNESS's "MUST name the trusted issuer … failure domains" has no `OVR-19` row.
- Neither amendment gives its operator notice an `OVR-18` hook.

These are identified, not drafted. I recommend no combination. A narrower variant that asks for evidence only for the permitted shutdown paths would be a new form and needs its own read.
