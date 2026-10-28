# pv-oehp — proposed ready-for-agent brief

Draft only. This file has not been posted and changes no tracker state. The body between the
Agent Brief markers is the proposed bead comment. Local provenance stays outside that comment.

<!-- AGENT_BRIEF_BEGIN -->
## Agent Brief

**Category:** enhancement. **Readiness:** ready to apply B4* as reviewed, with its conditional
deployment obligations disclosed, after the ordinary fresh-master checks and live-Run hold.

**Owner answer, verbatim (2026-10-28):**

> B4* as reviewed (Recommended)

**Problem and desired behavior:** Bound physical connection attempts across crashes, dead
transports, restarts and rollout overlap with durable admission before dialing. Apply B4*'s
consumer antecedent and full contract together.

**Landing sites:** `STO-55` in `05-persistence.md`; `OPS-47` and `OPS-49` in
`03-operation-lifecycle.md`; `OVR-18` and `OVR-19` in `00-overview.md`; `CNF-57`, `CNF-290`,
`CNF-296`, `CNF-299`, `CNF-362` and the new residual-capacity drill in
`10-conformance-checklist.md`. Allocate the new drill **`CNF-372`**: this is the next unused
identifier in the reviewed base and the read-only live checklist at draft time. Recheck on fresh
master before allocation; if it has been consumed, assign the next free identifier and update
this mapping before starting the Run. The declaration of C and A is owned by `STO-55`.
After the rule edits, amend `ADR-0045`'s residual-availability paragraph to a decision/pointer
record; keep the actual capacity argument at `STO-55`.

**Exact consumer antecedent supplied to the r76 readers:** Replace the entire `STO-55` sentence
“Every consumer then has a connection when it needs one and nothing starves the exposure-reducing
components behind the workers.” with:

<!-- CONSUMER_ANTECEDENT_BEGIN -->
> Pool sizing reserves consumer checkouts within a running process; opening or replacing a database connection also requires deployment admission.
<!-- CONSUMER_ANTECEDENT_END -->

**Exact reviewed B4* package to execute:**

<!-- REVIEWED_TEXT_BEGIN -->
~~~markdown
STO-55: use the consumer-sentence replacement above. Replace “During a stall, backends left waiting by an exited process or a dead transport hold slots outside this `max_connections` account (`pv-oehp`).” with:

> Every physical connection attempt by component pools, reconnects, rollout incarnations, startup-lock holders, migrators and waiting runners MUST receive a distinct durable reservation before dialing from one serialized authority outside the protected store. Ingress MUST prohibit bypass and redial under one reservation. Bind grants to component/attempt identity and database boot identity, and to backend PID and `backend_start` when known. Unknown bindings remain charged. Timeout, transport loss, process exit and rollout completion never release a grant.
>
> Unreleased grants MUST fit component capacity C. Bounded observer/operator/other-client allowances A include their residual and uncertain attempts. C+A MUST fit usable capacity after server reservations, with background/server resource pools budgeted separately. Keep separate read/write checkout budgets.
>
> Release requires fencing every delayed arrival/retry and fresh privileged direct-primary evidence, read in a fresh transaction, that the bound backend ended. Leaving SyncRep is insufficient. Unidentified attempts remain charged until fenced server-incarnation termination proves absence. Observer failure denies growth and retains charges.
>
> Accounting loss closes ingress. Recovery requires fenced conservative reconstruction or stopped components and verified primary shutdown before a fresh account; either path fences all old grants and delayed attempts. Existing admitted sessions may continue. Exhaustion alarms, refuses growth and delays replacements.
>
> Startup acquisition refusal exits for supervisor retry; api returns overloaded before any transaction; worker/periodic acquisition refusal is an OPS-49 store error. Stop-record refusals consume existing bounds and send no SQL. No individual SyncRep backend may be cancelled or terminated to make room; primary shutdown remains STO-7’s exception.

OPS-47: replace “supervisor that restarts it and never runs two” with “supervisor that retries startup subject to STO-55 admission and never runs two”.

OPS-49 adds:

> An attempt denied by STO-55 admission is a store error for this loop and sends no SQL.

OVR-18 adds admission/accounting alarms. OVR-19 registers STO-55-owned C, allowances, resource ceilings and authority/reconstruction procedures.

CNF-290: replace “release the first and assert the second then starts” with:

> with sufficient STO-55 admission available, release the first and assert the second then starts; repeat with exhausted admission and assert delayed startup until verified capacity release

CNF-57/296/299 successful-service fixtures retain adequate reservations and live independent read sessions. CNF-362 successful-recording fixtures require admitted recording capacity; refused admission exercises existing exhaustion bounds.

New drill:

> Precheck engine and multiple api pools; freeze standbys, send disjoint writes and identify waiting PIDs. Stop the engine through its recording bound, lose api database transports, and overlap a rollout. Preserve one admitted read session if asserting read success. Verify old PIDs survive outside live pools.
>
> Keep replacement checks enabled; hold check replies/disconnect detection so replacement backends remain while attempts fail unused. Accumulate verified residuals and unreleased grants to exhaustion; assert no extra dial, alarm, bounded refusal and reserved observer access. Exercise delayed handshakes, PID reuse, competing issuers, observer failure and lost accounting. Restore progress, fence attempts and prove backend termination before release and restart. Never release merely because `wait_event` changed.

This preserves STO-7’s “other than by shutting the primary down” exception and OPS-21’s “MUST wait at least the Stop-record bound”. Costs: reserves, durable admission infrastructure, restart delay and possible shutdown for unreconstructable accounting.
~~~
<!-- REVIEWED_TEXT_END -->

**Disclosed deployment obligation:** The deployment must actually bound observer, operator and
other-client occupancy A, including residual and uncertain attempts, and budget the separate
server/background resources. A declared allowance by itself does not ensure a fresh observer can
connect when that allowance or resources are consumed. The new drill's “reserved observer access”
is a deployment/verification obligation, not a guarantee already supplied by PostgreSQL reserve
roles. If observation is unavailable, use the reviewed failure behavior: “Observer failure denies
growth and retains charges.” This approval leaves the enforcement construction to the deployment;
it does not add same-before-dial accounting for A or a new protected-observer mechanism.

**Other disclosed obligations/costs:** Operate a serialized durable authority outside the store,
enforce ingress and per-physical-attempt reservations, fence delayed attempts, retain unknown
charges, use fresh privileged observations, and handle authority loss conservatively. Reserves,
indefinite replacement/startup delay and primary shutdown for unreconstructable accounting are
accepted costs. Positive service/recording fixtures require the package's actual admission and
read-session resources. The existing recording-success premise in `CNF-361` is “a store that works
for the record”; it receives no additional fixture restriction in this package.

**Acceptance:** Preserve the mapping from physical backends to distinct unreleased grants and the
budget inequality, including pre-authentication attempts. Check every acquisition/refusal consumer
and conformance companion in the package. A passing document gate certifies neither a deployed
authority nor observer access. Keep `STO-7`'s “other than by shutting the primary down” exception
and `OPS-21`'s “MUST wait at least the Stop-record bound”. Apply neither B3R nor the strengthened
replacement that adds a new A-accounting mechanism or extra negative-access fixture.

**Execution and completion:** Before applying, verify every replacement anchor against freshly
pulled master and the quoted decision against its decision record. Preserve the exact approved
package; report a substantive conflict instead of resolving it by an unreviewed synthesis.
Run `nix develop --command bash tools/check-all.sh` unpiped before and after the actual change.
Land the requirements and checklist edits before writing their amendment/decision record. Keep
arguments with their requirement owners and use pointers elsewhere. Change a formal declaration
only when its actual meaning changes; preserve theorems and keep checklist identifiers out of
formal sources. Close this bead through the tracker only after verification, flush its record,
and verify closure in committed JSONL. Add no attribution disclaimer or coauthor trailers.
<!-- AGENT_BRIEF_END -->

## Local provenance — do not post to the tracker

Decision source: `/var/tmp/provisiond-manager/owner-decisions-1028-panelA.md`. Review base: `4662d85c7e67c2ebb4c5c8e1c98dc6e1c0efc239`.
`r76/tally.md` Q3 counts fable/opus/sol ACCEPT and astra behavioural AMEND. The lone dissent
was checked in `r76/check/tally-claim-audit.md`; the owner chose the reviewed conditional form,
not astra's additions. The consumer antecedent is copied from `r76/brief.md`, not inferred from
an extracted block. The package beginning `STO-55:` is byte-for-byte the reviewed candidate;
only its historical UNREVIEWED title is omitted. No behavioural repair is applied.
Original candidate SHA-256: `798e26f7ac485244ab58b96d6cfb352ad8acd808401b2ee0f0bf1a891d296b1f`. Package SHA-256: `c3d2109d170d9c3b98fb16756cf43963878e4fa89ba11397d084ab11e4c65d82`.
The option shown to the owner is preserved here, outside the proposed public comment, verbatim:

> Panel pick, 3–1. Durable tickets taken before each connection and released only after it's provably dead. astra's point about enforcing the other-client limit stays a disclosed deployment obligation.

The answer and neutral deployment-obligation paragraph are already in the ready-to-post brief.

This turn authorizes drafts only. No Run, tracker mutation, source application, branch operation
or PR follows from this file. Live pv-6350 must leave the checkout before any later drain starts.
