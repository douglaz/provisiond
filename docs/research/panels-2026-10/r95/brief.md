# Panel P r95 — pv-kv2 adopted wording, owner items3/19 and Panel O settlement

Read this brief and notes.md whole. Review head H=`96a72898c7ace67790aec0bab3727eee858e2245` is an **unpushed local branch** one commit over master M=`6a3b6014f1f8b36fc21b902e507e74d8c5264e99` (PR64). Your own clone is detached M; `refs/remotes/review/pv-kv2` is H, fetched from the main checkout. Read specifications only there or by git show. Do not check out H or change any source or Git state. Do not read/enter main checkout; it is fetch-only for the launcher and off-limits to readers.

Read-only: no implementation, br, tracker, bead, branch, archive, source, PR, push, commit, checkout, reset, stash, clean, background work, subagents or other reader access. Temporary verification files only `/var/tmp/provisiond-panel-r95/tmp/<seat>/`. Do not read credentials/session/config locations (`~/.claude`, `~/.codex`, `~/.grok`, auth files, kubeconfig, browser profiles). Other panel/manager folders are read-only history; evidence copies are supplied here. No `lake build` or gate: manager runs full Nix gate separately. Deliver substantive final answer within3600s; aim <=3000 words plus exact alternative text and assertion inventory. No waiting on readers.

**apply notes.md rule 6 exactly as written; this prompt adds no void rule.**

## Plain problem and fixed policy

A worker first picks up an order after the customer is suspended. The owner chose to fail it before buying or charging. An order already past the last dispatch guard may still reach the provider; its resulting server must be accounted for and subject to cancellation. The package also fixes the lost-acknowledgement race and error ordering. Those policy choices are closed. The owner knowingly dropped the duty to publish the warning that pre-existing servers can keep running when cancellation fails. Do not restore that duty, mix A/D, or reopen items13/14.

The PR turn stopped because adopted sentences describe other requirements without those requirements' own words. A passing citation gate is not an exemption: its summary-verbs exclusion leaves prose review responsible. The question is exact wording that satisfies AGENTS while preserving **every** adopted assertion, including the money and late-evidence cases. Q-KEEP is eligible only with evidence the quotation rule does not apply here, such as this package defining its own new rule rather than asserting an existing owner's content. No such exemption is presumed.

The second question is where the correction belongs. The branch's bead is already closed. Correcting executable specs while leaving the executable Agent Brief inconsistent, or rewriting what was historically approved, has a record cost. Compare the exact landing choices below. This is launch-only r95; a split/unsettled result gets ONE r95b in a later turn, not here.

## Required whole-file evidence

Read `evidence/pr-stop-update.md` (whole 2026-11-02 16:00:16 UTC UPDATE), `evidence/pr-stop-report.md`, `evidence/pr-code-review.md`, `evidence/pr-standards-review.md`, `evidence/pr-spec-review.md`, `evidence/pr-stop-result.json`, `evidence/pr-exact-reconstruction.txt`, `evidence/pr-agent-brief.md`. Original read-only folder: `/var/tmp/provisiond-manager/pv-kv2-pr/`. Agent Brief copy is byte-identical to actual decoded comment860 at H.

Read owner items3/19 verbatim below, `evidence/Q4-D-original.md` whole (external r83b/Q4-D.md), `evidence/Q4-D-at-pin.md` whole (committed archive including Panel O's note), `evidence/r94-settled.md`, `evidence/r94-tally.md` and `evidence/r94b-tally.md` whole. Panel O settled Q-QUOTE-OPS43 plus L-NOTE 3–0; it corrected different attributions on this bead and granted no general exemption. Panel N r93's analogous Q-QUOTE/L-NOTE is precedent, not a ruling here; inspect its committed records if useful. Read complete source homes `evidence/OPS-11.md`, `evidence/OPS-27.md` and the quoted source spans from your own git objects at M. Every source payload must be byte-checked, not merely eyeballed. The lifecycle source homes OPS-11 and OPS-27 are unchanged M/H; API-58 and OPS-43 gain this very package at H.

The four standards findings are H lifecycle789–790 and818–819; API625 and670–671. `occurrences.md` inventories them **and** the implicit pre-step9 repeat, API58 flag summary, already quoted claims and coordinated new-rule references. Read it whole and independently search all six blocks: add any missed attribution with exact path:line and full replacement; do not silently confine review to four findings.

## Owner record, verbatim

3. **pv-kv2** — Q: "When a suspended customer's queued order is first picked up after the suspension, what should
   happen?" A: **"Stop before buying (Recommended)"**. Option text shown: "At pickup the worker sees the customer
   is suspended and fails the order before spending anything. Nothing is bought or charged. Panel D then settles
   the exact error and race guard. This is the 10-27 triage's pick; it wasn't put to a panel because it's a
   policy choice."
   - Story shown first: a customer queues a server order at 10:00, you suspend them at 10:01, a worker first
     picks the order up at 10:02; today's text lets it buy, charge the setup fee and first billing unit, then
     enqueue a cancellation that can itself fail.
   - Rejected: "Buy, charge, then cancel".
   - Decision homes (triage-1027 row): `API-58`, `OPS-43`; keep `OPS-27` for orders already dispatched. The
     refusal kind and race guard go to Panel D (r83).


19. **pv-kv2 (Panel D r83b Q4, unsettled after its one consensus round: D preferred and accepted 3–1 by fable +
    astra + sol, opus rejects; A preferred by opus, acceptance 2–2; D's 3–1 blocked by a verified rule-3 loss (the
    positive duty to publish the existing-fleet warning); no panel recommendation; grok missing, 402)** — Q: "pv-kv2
    public terms (panel unsettled): explain the 'approved before suspension' exception, or keep today's exact words and
    warning?" A: **"D: explain exception"**. Option text: "3–1 pick (fable, astra, sol). Terms say an order approved
    before suspension may still complete. Drops the required public warning that existing servers may keep running if
    cancellation fails (opus's objection)." Rejected: "A: keep current words". Meaning: adopt exactly
    /var/tmp/provisiond-panel-r83/r83b/Q4-D.md, unchanged, under item 3 "Stop before buying (Recommended)"; the owner
    knowingly accepts the loss of API-58's positive publication duty for the existing-fleet warning (opus's dissent on
    record). No A/D combination, repaired D or partial D. pv-kv2 → ready-for-agent with item 3's Q1 package plus
    Q4-D.md; items 13 (pv-gvc) and 14 (pv-bxh) stand and land with or after it.


Owner's wording rule: "For such wording questions, try to solve by getting a consensus of the panel". It settles only forms verified to change no behavior, requirement or check strength. A substantive departure goes to the owner. The previous r83b/r94b rounds do not consume this distinct wording question's one r95b allowance.

## Source evidence, exact

The fences preserve source bytes; displayed path:line belongs to M. Read complete homes independently, including qualifiers. Quotation checks remove only the Markdown list container indentation when comparing decoded executable blocks to their list-contained landing. No reflow tolerance is claimed for quotation payloads. An inherited OPS11 quotation wraps LF after “any” where source has a space; Q-QUOTE/Q-POINTER explicitly normalize it, Q-KEEP preserves/discloses it. Existing OPS49 quotation payloads and OPS43 acknowledgement payload remain Panel O's exact text. Do not silently normalize any other part.

### AGENTS quotation: AGENTS.md:29–32 at M

````text
**Quote the sentence.** A claim about what another requirement says carries that requirement's own
words. `` `WIR-30` says "The gate reads the copy the machine took at create" `` is checkable;
"`WIR-30` forbids resolving eligibility that way" is an assertion, and assertions of that shape were
false repeatedly on 2026-09-03 — `ddd3df0` and `254fc24` carry the cases and what each one cost.
````

### AGENTS completion: AGENTS.md:45–46 at M

````text
**Completion:** every sentence asserting what another requirement says carries its quote, and every
list or count names its source instead of restating it.
````

### OPS11 complete home: 03-operation-lifecycle.md:240–327 at M

````text
**OPS-11** On failure, the system MUST classify the error into `failed` or
`needs_reconciliation` using the operation kind and the error kind:

| Operation | Classification rule |
|---|---|
| refresh | Always `failed`. It is read-only; a failure changed nothing. *The row read "adopt, refresh" until `ADR-0020` withdrew adopt from v1.* |
| suspend_tenant | Never `needs_reconciliation`, and never `failed` as a whole. It is a parent whose per-machine children carry their own outcomes (`WIR-39`), and it settles `succeeded` once every child has either settled or **reached `needs_reconciliation`** — a child that reached that state counts as complete for the parent. `needs_reconciliation` is not itself settled (`OPS-3`); it is a state only evidence or an operator moves, so an unresolved child is a child-level fact, and blocking the parent on it would leave every suspended tenant's record permanently open. |
| rescue inventory | Same rows as `install`. It is **not** read-only in the relevant sense: it boots the machine into rescue, so an ambiguous failure can strand it there, and `PRV-22` makes an end-rescue failure always ambiguous. Classifying it with `refresh` would mark it `failed` while the machine sits in rescue. |
| install | `needs_reconciliation` for `network`, `timeout`, `provider`, `internal`, `conflict`, and `integrity` **once the write-started marker is set** (`OPS-45`). `failed` for the deterministic caller errors `invalid_request`, `not_found`, `unsupported`, `authentication` and `rate_limited` **where no rescue session was left open** (the paragraph below), **and for any failure at all while `OPS-45`'s two markers say the disk is untouched and no rescue session was left open** — including `integrity` before the connection, which is `RSC-3`'s host-key abort. An install that got further than that may have begun overwriting a disk, or may have left the machine in rescue; one that did neither, provably did neither. **`failed` past the write-started marker, where rescue exited cleanly, asserts that the install did not complete and nothing about the disk** (*2026-09-15, `pv-x8r`*): the deterministic caller kinds stay `failed` there because the engine knows what it did — an installer that rejected the layout it had begun partitioning for is a known outcome — and `needs_reconciliation` is the state for an outcome nobody knows (`CONTEXT.md`), whose only truthful verb here would be `abandoned`, which settles `failed` after a human looked. It does not mean `not_applied`, which `OPS-31` refuses there. What the disk holds is `OPS-45`'s marker's fact, rendered to the caller as `WIR-9a`'s `disk_effect`; the state does not carry it. |
| create | Any create failure the worker records before any step-9 request (before any per-order key upload or order request) MUST settle `failed`, whatever its kind. The boundary is the worker invoking the first step-9 per-order key upload or order call. It is the worker's position: this rule MUST NOT read `about_to_order_at`, nor any snapshot or cached copy of it. The settle write keeps the ordinary worker guard (`STO-3`; `OPS-6`: "every write that worker makes to the operation MUST carry `claim_number = mine`"), with no `about_to_order_at IS NULL` term. The error MUST keep its reported kind. For `network`, `timeout`, `internal`, `provider` with a 5xx or no upstream status, and a cut-off `conflict`, it MUST carry `retryable: true` on both the error and the operation view; a failure classified `failed` without this pre-step-9 rule keeps its stated `retryable`. An `OPS-21` cancellation of `execute` stays a cut-off `conflict`. The commitment is released in full under `LDG-32` ("A commitment MUST be closed, and its remaining amount released in full") and `LDG-39` ("**Never debited**; released with the commitment (`LDG-32`)"), with no setup-fee or first-unit debit. Settlement takes the `LDG-35` primitive, then follows `STO-3`: "The guarded status write precedes every money write in the transaction and short-circuits the rest". Where the create holds a resource-offer exclusion, it is freed under `STO-58`: "Its lifetime follows the winning create's outcome settlement". Before step 9 no provider mutation has been requested (`PRV-50`). From step 9 onward, including a key-upload failure or an order-call failure before any byte was sent: `needs_reconciliation` if the failure is *ambiguous*, otherwise `failed`. |
| power, reverse-DNS, delete, release attachment | Subject to the goal-state success rule, any failure the worker records while `OPS-45`'s write-started marker is unset, where no rescue session was opened or the one opened was closed without error, MUST settle `failed`, whatever its kind (`OPS-45`, which owns the rule), unless the mutation is known to have been accepted (`details.accepted` is `true`). Otherwise `needs_reconciliation` if the failure is *ambiguous*, otherwise `failed`. A release is a delete of a smaller thing (`PRV-45`) and classifies exactly as one. |

*Amended 2026-10-17 (`pv-k4l`; panels r56 and r56b, `docs/research/panels-2026-10/r56/` and `docs/research/panels-2026-10/r56/r56b/`): the restart settlement is outside this classification; see `OPS-15`: "A create found `running` at startup with `about_to_order_at` null MUST be settled `failed`, on a restart only."*

*Amended 2026-10-18 (`pv-qga`; panel r57, `docs/research/panels-2026-10/r57/`; `ADR-0043`): the restart exception reads the null column on a restart; the create row instead classifies a failure recorded by the worker, by position. After step 8 is acknowledged and before step 9 begins, a recorded failure settles `failed` with the column set. A restart in that same window takes the ordinary path (`OPS-15`: "the engine MUST move every `running` operation to `needs_reconciliation`"), since the column is set.*

*Amended 2026-10-23 (`pv-9j6`; panel r64b; owner decision “Yes, settle failed (Recommended)”; `ADR-0046`): made the last row read the write-started marker for recorded failures below goal-state success and except known-accepted mutations, with ambiguity in the fallback branch.*

**The table MUST be total, and seven kinds added later were missing.** `insufficient_balance`,
`not_activated`, `halted`, `gone`, `suspended`, — added 2026-09-02 — `ceiling_exceeded`
(`DOM-20`, `DOM-21`, `SEC-39`) and — added 2026-09-12 — `overloaded` (`STO-55`) are
**admission-only**: they are decided
before any driver call, they MUST NOT be emitted by a worker or a driver, and any pre-provider
occurrence classifies deterministically as `failed` for every operation kind. Nothing was
destroyed and nothing was ordered, so ambiguity cannot arise. Every kind in `DOM-17` MUST have a
defined classification for every operation kind. There is no implicit default, because the two possible defaults are both wrong:
defaulting to `failed` invites a caller to retry a mutation that may have happened, and
defaulting to `needs_reconciliation` pages a human for a typo. `CNF-31b` tests totality.

One case needs stating because two requirements appear to disagree. `PRV-22` says "Failure of end
rescue is *always* ambiguous". That does not conflict with the install row: an install whose
*rescue exit* fails has already done its work and reached the provider, so it is never a
deterministic caller error, and the install row classifies it `needs_reconciliation` regardless
of which error kind the driver reports. *Amended 2026-09-14: the same holds where the operation died
before reaching it. `OPS-45`'s second marker is one column, `false` for both, so the classification
cannot tell them apart, and the machine may be sitting in rescue either way — which is the fact the
marker records. The never-attempted exit was a third case until `RSC-18` was withdrawn, 2026-09-15.*

*Amended 2026-10-09 and 2026-10-10 (`ADR-0036`): `PRV-40` says to "refuse subsequent
creates on that account and channel before any provider call" and, for a queued
create closed at worker claim, to "settle the existing operation `failed`". These
are occurrences decided before provider acceptance, not an admission-only error
kind. `rate_limited` remains available to drivers and workers. See `API-7` for the
purchase-tail refusal.*

A failure is **ambiguous** when:

- the error kind is `network`, `timeout`, or `internal` — the request may have been
  received and acted on before the transport died; or
- the error kind is `conflict` *and* it arose from the worker being cut off mid-flight
  (`OPS-21`) rather than from a provider-reported state conflict; or
- the error kind is `provider` *and* the upstream status was 5xx, or no upstream status
  was recorded at all. A 4xx rejection of the mutating request itself means the provider did not
  accept that request; a 5xx means it may have acted and then failed to say so; or
- the operation's mutating request was accepted by the provider (`details.accepted: true`,
  `PRV-5`), whatever the later error kind or status.

**Amended 2026-10-08 (`ADR-0035`): acceptance is an additional ambiguity condition for the
create row and the last row.** A later `rate_limited`, `not_found`, `authentication`, or provider 4xx error MUST NOT
classify that accepted mutation `failed`. The goal-state success rule below still takes
precedence. The refresh, parent, install/rescue-inventory and admission-only rows are unchanged;
pre-provider admission has no accepted mutation. Unknown acceptance follows `PRV-5`'s
"MUST report `details.accepted: null` with the mutating request's own failure mapped as above",
never an implicit default.

The accepted dated cancellation read-back (`PRV-13`) is an evidence read after a successful
mutating response. Failure of that read alone does not enter this failure classifier; the
settlement for the known accepted date belongs to `PRV-13`. `PRV-13c` says "A failed
post-order read of any kind, `rate_limited` included, MUST NOT enter `OPS-11`'s classifier and
MUST NOT change the create's settlement." *Amended 2026-10-14 (`ADR-0037`, Q31).*
This exception does not reclassify unknown acceptance or a later failure of the mutating
request. *Clarified 2026-10-11
(`ADR-0037`, Q22).*

**AMENDED 2026-08-31 — "a 4xx means the provider did not act" is false, and believing it strands a
customer's money.** For a **goal-state mutation** — delete, power on, power off, end rescue — a
provider may reject the request precisely *because the goal state already holds*, and that rejection
means the opposite of failure. Measured: `DELETE /v2/images/{id}` against a resource already deleted
returns `422 "Can not delete an already deleted image."` Classified `failed` under the sentence
above, a delete that succeeded is recorded as a failure, and `LDG-32` then never closes the
commitment — the customer's satoshis stay reserved against a resource that is gone.

**A provider rejection whose meaning is "already in the target state" MUST classify `succeeded`.**
Which specific codes carry that meaning is a provider fact, so the mapping belongs in the driver
(`PRV-5` already owns translating provider responses) and MUST be recorded in
`08-provider-notes.md`, pinned to codes rather than to message text, and re-verified when the
provider's API changes. This table states the rule; it does not enumerate anyone's error codes.

````

### OPS27 complete home: 03-operation-lifecycle.md:555–655 at M

````text
**OPS-27** **AMENDED 2026-09-08 (`ADR-0017`) — one correlator, searched on every channel.** The
system MUST attempt automatic resolution before asking a human. Resolution searches the provider
for the operation's correlator (`PRV-26`, `PRV-27`) on **every ordering channel the driver
reaches** (`PRV-38`), takes the union of what those searches return, and reaches one of the four
outcomes below:

| Finding | Resolution | Effect on the commitment |
|---|---|---|
| Exactly one resource across every channel | **Resolved-observed.** Attach it and complete the operation as though it had succeeded. | Becomes the machine's running commitment (`OPS-36` where it was already released) |
| The provider's search is authoritative and returns nothing on any channel, and the negative window has elapsed — or a matched resource is read directly and is gone, past `PRV-36`'s window | **Resolved-absent.** No resource exists to attach — *"the mutation did not happen" until 2026-09-05, which the matched-and-gone case falsifies: the order landed and left nothing* | Closed and released in full (`LDG-32`); a charged fee per `LDG-39`'s absent row |
| More than one resource across every channel | **Unresolved — duplicate.** MUST NOT auto-attach either. Surface both for operator remediation (`OPS-38`). | Released per `OPS-33`; the duplicate is operator cost |
| Any one of the searches cannot be made authoritative — the provider cannot filter, the listing window has expired, or no verified correlator exists for the operation's ordering channel (`PRV-33`) | **Unresolved.** Escalate to an operator (`OPS-31`, `WIR-35`). | Released per `OPS-33`, which applies here too |

**Amended 2026-10-09 (`ADR-0040`): a lost-reply auction create uses the per-order fingerprint search across every ordering channel. The matched transaction supplies its delivered `server_number` for the confirming read. Offer-number equality is not assumed; an offer-number `not_found` cannot establish absence and a positive offer-number read alone cannot attribute the machine to this order.**

**A correlator match is proof that an order landed, not that the resource exists, and the first
row MUST be confirmed by a direct read before it attaches anything.** `08-provider-notes.md`
records, from a live order, that Hetzner Robot's transaction "still" reports `status: "ready",
server_number: N` after the server is gone — "the listing outlives the machine". So resolution
MUST follow a match with *get machine* (`PRV-12`) on the matched `external_id`. Where that read
finds the machine, the first row applies. **Where it returns `not_found` inside `PRV-36`'s
visibility window, the operation stays unresolved and resolution retries on its next pass** — a
Robot order reports `ready` with a server number before the server API lists the machine, and a
read inside that window is not evidence of absence. **Where it returns `not_found` past the
window, the operation resolves *absent* — the second row's outcome, reached without waiting for
`OPS-33`'s negative window, because a direct read past the visibility window is authoritative
where a listing was not**: no machine is attached and the commitment is released in full — with one addition to `LDG-39`, that a setup fee or prepaid first unit (*the unit since 2026-10-08,
`ADR-0033`*) the provider's own transaction shows was charged becomes the deficiency `LDG-39`'s
absent row names for it rather than being pretended away.
*Added 2026-09-05, and corrected the same day: a first form invented an "accepted-but-gone"
outcome, which had no value in `WIR-35`'s closed `resolution` set, no settled status, no `LDG-39`
row, and ignored the visibility window — so the ordinary Robot create resolved as gone and came
back as an `OPS-36` late attach carrying a wind-down deficiency. Without the read at all,
reconciliation attached, metered and fee-settled a ghost.*

**A create MUST NOT settle `succeeded` on the strength of the reply in hand alone.** Before the
terminal write the system MUST search the correlator across every ordering channel the driver
reaches (`PRV-38`) and MUST settle `succeeded` only where that search yields exactly one
resource, confirmed by the direct read above. **After acceptance, zero or many resources, a
failed search, or any non-authoritative search MUST leave the create in `needs_reconciliation`**;
a failed confirming read likewise cannot establish success or settle-time absence. Later
resolution follows the rows above. A create settles exactly one machine, so **more** than one is
`OPS-38`'s many-case: it
MUST NOT auto-attach either, and it goes to an operator (`OPS-31`), never to `succeeded`. An order
that lands *after* the search was taken is beyond what any settle-time search can see, and
`OPS-32`'s account sweep is the backstop for it. *Until 2026-09-05 the search was over several
attempts' correlators; `ADR-0014` removed the second attempt, and what has to be searched is
several channels, which `PRV-38` found was never covered.*

*Amended 2026-10-08 (`ADR-0035`): the settle-time outcomes above include every unsuccessful
search after acceptance. A matched order still in progress stays unresolved; `OPS-33` owns the
negative-window qualification.*

**A create whose order landed MUST be recorded in one transaction**, in the manner of `LDG-11`.
This is one rule with **three entry points** — successful settle-time verification after the
provider **accepting the order in its reply**,
`OPS-27` **resolving-observed** a create whose reply was lost, and `OPS-36`'s **late attach** of a
machine whose commitment `OPS-33` had already released — because each writes a set of effects a
partial commit of which is unrepairable. Those effects are: the terminal write on
the operation (`STO-19`'s write-once columns), the machine row, the **settlement of the setup fee
and of the prepaid first unit** (`ADR-0033`, 2026-10-08) — each a debit where a commitment is still
open, each an `LDG-66` operator deficiency where `OPS-33` has released it (`LDG-39`, amended
2026-09-02; neither is ever taken from available balance) — the clearing of any parked `LDG-67`
record, and the commitment decrement where a commitment
is still open (`LDG-31`). They MUST commit together, under `LDG-35`'s per-tenant serialization
because the debit reads the balance. **The late-attach entry point carries three further effects,
and they commit in that same transaction**: the attach itself; *either* the wind-down commitment
*or* the `LDG-66` operator deficiency, using `OPS-36` and `LDG-40` for the branch decision,
never neither and never both; and the enqueue of the cleanup cancellation, which opens the
machine's `delete` episode as it goes (`OPS-39`, `OPS-48`). A partial commit leaves a state
nothing in the record can repair: a machine whose fee is still parked bills that setup a second
time when the obligation is next read, a debit without the machine row charges a customer for a
machine no tenant owns, a machine row without its debit runs a create nobody paid for, and an
attach whose cancellation never reached the queue is an unfunded machine billing with nothing
scheduled to stop it.

*Amended 2026-10-14 (`ADR-0037`, Q31).*
*Amended 2026-10-15 (`pv-sgj`): the landed-order transaction's placement sentence gained its MUST keyword.*
*Amended 2026-10-15 (`ADR-0037`, Q34).*
At every entry point to the landed-order transaction above, that transaction MUST include
the column write with the machine row: `PRV-13c` says "The landed-order transaction MUST write the date of a successful read the committing pass holds, otherwise null, in `machines.earliest_cancellation_date` with the machine row".
`PRV-13c` says "The system MUST record the date of the committing pass's successful post-order read in `machines.earliest_cancellation_date`", "An accepted cancellation's response (`PRV-13`) that carries the per-machine date MUST supply it to that column" and "After the committing pass's failed post-order read, the column MUST remain null until such a response supplies the date".
`PRV-13c` says "once, when the create settles, after `OPS-27`'s confirming read".

*Amended 2026-10-04 (`pv-gip.27`, J1): the flowchart and atomic attach include `LDG-40`'s
no-rate branch, "open no commitment, regardless of available balance". Verification: `CNF-308`.*

**Where the machine's tenant is suspended at the moment of the attach, that same transaction also
enqueues a system cancellation** — `requested_by: system`, `system_reason: tenant_suspended`, under
the machine's `delete` episode, opening it or adding the reason to an episode this same transaction
opened (`OPS-39`, `OPS-48`) — the identical mechanism `API-58` step (3) uses on the fan-out and the
identical attach-then-route shape as `OPS-36`. This applies at **all three** entry points. It is needed
because `API-58`'s re-sweep stops once a pass finds no un-cancelled machine, and a create that has
not yet produced a machine passes that test: the parent settles `succeeded` — counting a
`needs_reconciliation` child as complete — and no later pass will ever look again. Without it, a
create resolving *observed* after that settlement attaches a funded, billing machine to a suspended
tenant and runs its whole runway, which is precisely the outcome `SEC-45`'s one-action suspension
must not depend on a human noticing. `OPS-36`'s attach-then-cancel does not cover it: that branch fires only
where `OPS-33` had already released the commitment, and here the commitment is still open and
becomes the machine's running commitment.

````

### API58 original flag: 04-api-contract.md:617–622 at M

````text
**API-58** **A funded tenant MUST be suspended, never deleted.** Suspension is an operator action
that (1) marks the tenant `suspended` **in the admission transaction, before the `202` is returned**,
so no further **tenant-authorized** write succeeds —
the maintenance actions of `API-7` step 2 remain reachable, because a suspended owner must still be
able to revoke a stolen credential (`API-56`, `CNF-209`), and an operator may retry a stalled
episode (`API-64`), which skips step 5b like every operator verb (`API-7`) — then (2)
````

### OPS43 original step8/9: 03-operation-lifecycle.md:801–823 at M

````text
8. Perform `API-63`'s conditional write on `STO-47`'s row, in the correlator transaction:
   "the worker MUST repeat the admission check as a conditional write on `STO-47`'s row guarded
   on `healthy`". It remains "the last write before the ordering call" (`API-63`).
   In this same transaction, on every ordering channel, including `correlator: none`, the worker
   MUST set `operations.about_to_order_at` to `COALESCE(about_to_order_at, <transaction time>)`
   guarded on `(id, status = running, claim_number = mine)` (`STO-3`; `OPS-6`:
   "every write that worker makes to the operation MUST carry `claim_number = mine`").
   The write MUST NOT be guarded on the column being null: a whole-transaction repeat after a
   lost reply affects one row and changes nothing. If this operation-row write affects zero rows,
   something else moved the operation: step 9 MUST NOT run and the worker MUST exit. This differs
   from the zero-row `STO-47` check above, of which `API-63` says "where it affects no row MUST
   fail the operation deterministically". A first attempt that fails that check commits no
   `about_to_order_at`. If an earlier step-8 transaction committed but its reply was lost, and an
   account-status write makes the account non-`healthy` before the whole-transaction repeat,
   the repeat can fail that check with the column already set. The create still settles `failed`
   under `OPS-11`'s create row: `OPS-11` says "Any create failure the worker records before any step-9 request (before any per-order key upload or order request) MUST settle `failed`, whatever its kind."
   Step 9 MUST begin only after step 8's transaction is acknowledged. A lost acknowledgement
   MUST take `OPS-49`'s "repeat the **whole transaction**" path, never speculative dispatch.
9. Perform the per-order key upload, then the order. Here **per-order key upload** means every
   temporary key registration required for this create (`PRV-9`: "the driver MUST register and
   attach them as temporary provider-side resources").

*Amended 2026-10-17 (`pv-k4l`; panels r56 and r56b, `docs/research/panels-2026-10/r56/` and `docs/research/panels-2026-10/r56/r56b/`): made step 8 write the column under the worker guard and await acknowledgement before step 9.*
````

### Citation gate scope: tools/check_citations.py:157–178 at M

````text
  UNQUOTED "`X` says/states/reads ..." with no quote at all is unverifiable by
           construction. Ratcheted against `citation-baseline.json` rather than
           failed outright, because such sentences already exist and a gate that
           fails a clean tree is a gate someone deletes. New ones are refused;
           the standing ones come down as their requirements are next edited.
           The count lives in that file and nowhere else -- a number written
           into prose is wrong the first time either end moves, which this set
           has now learned in `ADR-0003`, `ADR-0011` and `F16`.
           HISTORICAL and TEACHING retain their whole-chunk suppression here,
           including history inside a paired quotation.

Summary verbs are deliberately OUT OF SCOPE. "`OPS-12` forbids automatic retry"
is a correct, useful paraphrase, and most attributions in the set are of that
shape. Demanding a quote there would fire on legitimate prose, which is how a
checklist item ends up unsatisfiable by every conforming implementation
(`CNF-224`).

WHAT THIS DOES NOT CATCH, stated plainly because a gate's limits are part of its
contract: a wrong SUMMARY. "`WIR-30` forbids the server resolving eligibility
that way" reverses `WIR-30`'s meaning, uses a summary verb, and carries no
quote -- no lexical signal separates it from a correct summary. That one was the
worst defect of 2026-09-03 and it stays a review problem. Lean docstrings participate
````

## Occurrences

# r95 occurrence inventory at review head 96a72898c7ace67790aec0bab3727eee858e2245

The table below inventories requirement names and implicit retained-rule references within the six executable blocks. It is deliberately broader than the four reported summaries. A sentence that defines this package's own new policy may differ from a sentence asserting a retained source's content; each reader must decide with evidence. Line numbers identify the actual review head, not the master source pin. JSONL physical row is resolved below; decoded lines refer to comment860's text.

| Head location | Sentence/reference | Candidate handling and unresolved review point |
|---|---|---|
| 03-operation-lifecycle.md:789-790 | full commitment release/no debit under OPS-11 | Q-QUOTE adds exact classification and money sentences to this sentence; Q-POINTER retains local settlement/debit instructions plus bare ownership pointer |
| 03-operation-lifecycle.md:814-816 | API-58's admission-time suspension flag write; same-row contention | Extra summary candidate: Q-QUOTE adds API-58's exact flag words; Q-POINTER retains same-row rule plus bare flag pointer. Contention is the package's own new rule |
| 03-operation-lifecycle.md:816-819 | refusal and settle failed under OPS-11 | Q-QUOTE adds exact classification and money words; Q-POINTER retains local refusal/release/no-debit and pointer |
| 03-operation-lifecycle.md:820-824 | recorded failure under the same pre-step-9 rule; no null-column term | Implicit OPS-11 reference beyond four reported occurrences: Q-QUOTE adds exact classification and worker-guard words; Q-POINTER preserves the explicit pre-step-9 local instruction and pointer |
| 03-operation-lifecycle.md:824-827 | OPS-49 says quoted whole transaction and immediate retry; local serialization/refusal distinction; retained claim/ack guards | Already Panel O-corrected. Existing quotations retained; review exact payload after removing Markdown list container indentation. Explicit local commands retained |
| 04-api-contract.md:623-625 | OPS-43 tenant dispatch guard and potentially-dispatched classification; OPS-27 suspended-attach cancellation | Q-QUOTE adds complete exact OPS-27 suspension paragraph to this sentence. Q-POINTER uses machine ownership pointer. Guard/classification is the package's own new policy, not a claim it existed at master |
| 04-api-contract.md:625-627 | claim alone no purchase; tenant-suspended failure under OPS-43; guard prevents purchase | Retained in all supplied forms as coordinated new rule in this package, with reader required to assess whether any part is another unquoted retained attribution |
| 04-api-contract.md:627-630 | OPS-43 acknowledgement quote and potentially-dispatched residue | Existing exact quote and local classification retained, as settled by Panel O |
| 04-api-contract.md:631-633 | OPS-11 says quoted pre-step-9 classification | Q-QUOTE and Q-POINTER repair disclosed existing LF-after-any mismatch to source's space, no policy change claimed; Q-KEEP keeps original mismatch |
| 04-api-contract.md:669 | For claimed-create read/refusal/guard see OPS-43 | Already a bare ownership pointer; retained |
| 04-api-contract.md:670-671 | OPS-27 path including later evidence attachment after parent settles | Q-QUOTE adds entire suspension paragraph, including all entry points and post-parent-settlement rationale. Q-POINTER becomes bare scoped pointer; each reader must test for lost explicit strength |
| 04-api-contract.md:741-742 | stops authorization at OPS-43 guard; accounts for machines | Retained as package's own new disclosure rule; read owner item19 and test that no added positive existing-fleet publication duty is inferred |

The acceptance block contains no requirement identifier or attribution sentence: its assertions are owned by the adopted package. Its late attachment, release/no debit, origin, claim guard and negative provider-call assertions must all survive. No body text outside these six blocks is in scope. In particular the neighboring pre-existing API-58 attributions at :639ff and :673ff are not newly adopted blocks.

## decoded comment860 — matching lines (historical copies are not replacement targets)

```text
43: 1. In OPS-43 step 1, after the account-status refusal paragraph and before step 2, insert:
50: release and no setup-fee or first-unit debit under OPS-11's pre-step-9 create rule. Preserve
55: 2. In OPS-43 step 8, after the STO-47 conditional-write check and before the operations-row write, insert:
59: on its status not being suspended. This write and API-58's admission-time suspension flag write
63: on both error and operation view, then settle failed under OPS-11's pre-step-9 rule with full
68: worker's recorded failure under the same pre-step-9 rule; do not add a null-column term to
69: the settlement guard. OPS-49 says "the component MUST repeat the **whole
71:   serialization failure is repeated at once."; retry a serialization failure as a whole transaction and do not treat it as a tenant-status refusal. The operation-row claim guard and acknowledgement-before-
75: 3. In API-58 step (2), replace the complete span beginning `**fences work already in flight**` and ending `unrecorded and unbilled —`, immediately before `then (3)`, with:
78: **fences work already in flight** — a create that passed OPS-43's tenant dispatch guard before
80: abandoned mid-order; its machine follows OPS-27's suspended-attach cancellation. A claim by
82: OPS-43, and suspension winning the step-8 tenant guard also prevents purchase. A create past
84: OPS-43 says "Step 9 MUST begin only after step 8's transaction is acknowledged."; treat that residue as the potentially dispatched
87: OPS-11 says "Any create failure the worker records before any step-9 request (before any
91: 4. In API-58, immediately before “A create that has produced no machine yet”, insert:
94: For the claimed create's tenant-status read, refusal and dispatch race guard, see OPS-43.
95: Orders already potentially dispatched retain OPS-27's attach and suspended-tenant cancellation
99: 5. In API-58, replace the complete bold suspension-promise sentence and its following sentence, beginning `**A suspension is not a promise` and ending `on this one branch it is not.`, at pinned lines 731–734, with:
103: at OPS-43's tenant dispatch guard and accounts for every machine, including machines produced
152: > keep `OPS-27` for orders already dispatched.
```

## archived Q4-D at pin/head — matching lines (historical copies are not replacement targets)

```text
3: 1. In OPS-43 step 1, after the account-status refusal paragraph and before step 2, insert:
10: release and no setup-fee or first-unit debit under OPS-11's pre-step-9 create rule. Preserve
15: 2. In OPS-43 step 8, after the STO-47 conditional-write check and before the operations-row write, insert:
19: on its status not being suspended. This write and API-58's admission-time suspension flag write
23: on both error and operation view, then settle failed under OPS-11's pre-step-9 rule with full
28: worker's recorded failure under the same pre-step-9 rule; do not add a null-column term to
29: the settlement guard. A serialization failure is retried as a whole transaction under OPS-49
30: and is not a tenant-status refusal. The operation-row claim guard and acknowledgement-before-
34: 3. In API-58 step (2), replace the complete span beginning `**fences work already in flight**` and ending `unrecorded and unbilled —`, immediately before `then (3)`, with:
37: **fences work already in flight** — a create that passed OPS-43's tenant dispatch guard before
39: abandoned mid-order; its machine follows OPS-27's suspended-attach cancellation. A claim by
41: OPS-43, and suspension winning the step-8 tenant guard also prevents purchase. A create past
46: OPS-11 says "Any create failure the worker records before any step-9 request (before any
50: 4. In API-58, immediately before “A create that has produced no machine yet”, insert:
53: For the claimed create's tenant-status read, refusal and dispatch race guard, see OPS-43.
54: Orders already potentially dispatched retain OPS-27's attach and suspended-tenant cancellation
58: 5. In API-58, replace the complete bold suspension-promise sentence and its following sentence, beginning `**A suspension is not a promise` and ending `on this one branch it is not.`, at pinned lines 731–734, with:
62: at OPS-43's tenant dispatch guard and accounts for every machine, including machines produced
109: OPS-49 says "the component MUST repeat the **whole
119: OPS-43 says "Step 9 MUST begin only after step 8's transaction is acknowledged."; treat that residue as the potentially dispatched
```

## external Panel O settlement — matching lines (historical copies are not replacement targets)

```text
20: A serialization failure is retried as a whole transaction under OPS-49
27: OPS-49 says "the component MUST repeat the **whole
48: OPS-43 says "Step 9 MUST begin only after step 8's transaction is acknowledged."; treat that residue as the potentially dispatched
81: OPS-49 says "the component MUST repeat the **whole
91: OPS-43 says "Step 9 MUST begin only after step 8's transaction is acknowledged."; treat that residue as the potentially dispatched
102: The inserted OPS-49 payloads match lifecycle1927–1928 and1955–1956 byte for byte, including LF, indentation, emphasis and backticks; the OPS-43 payload matches lifecycle817 exactly and governs this create's step8/9 sequence. The discarded LDG-69 quotation has exact bytes but concerns OPS-42's funding/fence transaction. STO-55 distinguishes the primitive-only rule; API-63's repeated attribution does not expand LDG-69's scope.
104: The retained OPS-11 quotation has a pre-existing LF after “any” where its source has a space; checked and disclosed, not claimed byte-identical or normalized. Item5's retained locator and the historical item3 quotation have separate reflow differences. Historical Current behavior blocks match their named historical ref exactly. These unchanged differences do not change this wording question's premise; notes rule6 voids no vote.
106: The whole-transaction serialization retry and tenant-refusal distinction remain explicit local instructions from adopted Q4-D item2; OPS-49's quotations do not by themselves supply both. The potentially-dispatched classification and permission to settle remain explicit item3 policy from owner item19. OPS-43 supplies existing acknowledgement ordering; OPS-11 and OPS-27 supply retained pre-step9 and attachment context. No new policy is inferred from the quotations.
```

Tracker physical path: `.beads/issues.jsonl:101`, pv-kv2, comment id860. The same decoded executable blocks occur at master and head; bead is **closed** at head. Source body must stay coordinated even on a closed bead; this panel changes no tracker.

## Q1 — exact wording candidates

Pick one exact candidate per question. Read all three packages **in full** below. Complete prospective comment860 files are `options/Q-*-agent-brief.md`; complete prospective landed spec files are `options/Q-*/{03-operation-lifecycle.md,04-api-contract.md,10-conformance-checklist.md}`. These are review artifacts only. Check reverse substitutions leave every surrounding byte unchanged. Candidate blocks retain historical insertion instructions/locators; actual landing targets are the six blocks already on H, not fresh insertions. Do not re-add blocks.

Q-QUOTE retains all operative words and adds source words to each disputed attribution sentence, plus the implicit OPS11 reference and the API58 flag reference. OPS11's complete create row itself explicitly contains full release and no setup-fee/first-unit debit; do not assume those words are only an inference from another owner. OPS27's complete suspension paragraph includes all three attachment entry points and the after-parent-settlement rationale. Q4-D owns the new refusal/race/classification and its acceptance tests. Verify these tentative provenance descriptions; source truth and local policy must not be conflated.

Q-POINTER turns the relevant retained-rule attributions into bare scoped owner pointers, retaining explicit local refusal, financial and guard instructions. Whether the attach pointers preserve the original explicit strength is a question for readers, not a manager finding. No normative obligation may vanish merely to clear quotation review. Q-KEEP changes nothing and needs a demonstrated exemption for **every** challenged attribution; supported policy alone does not establish exemption.

### Q-QUOTE — complete executable package

**Complete alternative Q4-D — preferred and ACCEPT.** All unspecified pinned text remains unchanged.

1. In OPS-43 step 1, after the account-status refusal paragraph and before step 2, insert:

```text
Next read this operation's tenant status. Where the tenant is suspended, fail this existing
create with conflict, details.reason: "tenant_suspended", and retryable: false on both the error
and operation view. This read precedes channel closure and boundary validation. Make no provider
request, including List offers or a per-order key upload. Settle failed with full commitment
release and no setup-fee or first-unit debit under OPS-11's pre-step-9 create rule; OPS-11 says "Any create failure the worker records before any step-9 request (before any per-order key upload or order request) MUST settle `failed`, whatever its kind." and “The commitment is released in full under `LDG-32` ("A commitment MUST be closed, and its remaining amount released in full") and `LDG-39` ("**Never debited**; released with the commitment (`LDG-32`)"), with no setup-fee or first-unit debit.”. Preserve
requested_by and system_reason as originally recorded; do not emit the admission-only kind
suspended. This is a plain read; the dispatch guard below closes the race after it.
```

2. In OPS-43 step 8, after the STO-47 conditional-write check and before the operations-row write, insert:

```text
In this same transaction the worker MUST conditional-write the operation's tenants row guarded
on its status not being suspended. This write and API-58's admission-time suspension flag write
MUST contend on that same row; a plain read or a lock confined to the earlier claim-time check
is not a substitute; API-58 says "marks the tenant `suspended` **in the admission transaction, before the `202` is returned**". Where the tenant guard affects no row because suspension won, roll back
the step-8 transaction and record conflict, details.reason: "tenant_suspended", retryable: false
on both error and operation view, then settle failed under OPS-11's pre-step-9 rule with full
release and no setup-fee or first-unit debit; OPS-11 says "Any create failure the worker records before any step-9 request (before any per-order key upload or order request) MUST settle `failed`, whatever its kind." and “The commitment is released in full under `LDG-32` ("A commitment MUST be closed, and its remaining amount released in full") and `LDG-39` ("**Never debited**; released with the commitment (`LDG-32`)"), with no setup-fee or first-unit debit.”. No step-9 key upload or order may begin. A first
failed transaction commits neither about_to_order_at nor a correlator. A whole-transaction
repeat after a lost acknowledgement rechecks this guard too: if suspension now defeats it,
keep any previously committed about_to_order_at and correlator unchanged and settle the
worker's recorded failure under the same pre-step-9 rule; do not add a null-column term to
the settlement guard; OPS-11 says "Any create failure the worker records before any step-9 request (before any per-order key upload or order request) MUST settle `failed`, whatever its kind." and “The settle write keeps the ordinary worker guard (`STO-3`; `OPS-6`: "every write that worker makes to the operation MUST carry `claim_number = mine`"), with no `about_to_order_at IS NULL` term.”. OPS-49 says "the component MUST repeat the **whole
transaction** — never the last failed statement, and never the provider call (`OPS-12`)" and "A
  serialization failure is repeated at once."; retry a serialization failure as a whole transaction and do not treat it as a tenant-status refusal. The operation-row claim guard and acknowledgement-before-
step-9 rules remain required.
```

3. In API-58 step (2), replace the complete span beginning `**fences work already in flight**` and ending `unrecorded and unbilled —`, immediately before `then (3)`, with:

```text
**fences work already in flight** — a create that passed OPS-43's tenant dispatch guard before
the suspension landed is potentially dispatched and MUST be allowed to settle rather than
abandoned mid-order; its machine follows OPS-27's suspended-attach cancellation; OPS-27 says "**Where the machine's tenant is suspended at the moment of the attach, that same transaction also
enqueues a system cancellation** — `requested_by: system`, `system_reason: tenant_suspended`, under
the machine's `delete` episode, opening it or adding the reason to an episode this same transaction
opened (`OPS-39`, `OPS-48`) — the identical mechanism `API-58` step (3) uses on the fan-out and the
identical attach-then-route shape as `OPS-36`. This applies at **all three** entry points. It is needed
because `API-58`'s re-sweep stops once a pass finds no un-cancelled machine, and a create that has
not yet produced a machine passes that test: the parent settles `succeeded` — counting a
`needs_reconciliation` child as complete — and no later pass will ever look again. Without it, a
create resolving *observed* after that settlement attaches a funded, billing machine to a suspended
tenant and runs its whole runway, which is precisely the outcome `SEC-45`'s one-action suspension
must not depend on a human noticing. `OPS-36`'s attach-then-cancel does not cover it: that branch fires only
where `OPS-33` had already released the commitment, and here the commitment is still open and
becomes the machine's running commitment.". A claim by
itself does not authorize purchase: a create that first reads the tenant suspended fails under
OPS-43, and suspension winning the step-8 tenant guard also prevents purchase. A create past
the guard can still be between the acknowledged transaction and its provider call, because
OPS-43 says "Step 9 MUST begin only after step 8's transaction is acknowledged."; treat that residue as the potentially dispatched
case. Never fail or release such an uncertain order through the never-claimed administrative
write. This does not override a deterministic failure the worker actually records before step 9:
OPS-11 says "Any create failure the worker records before any step-9 request (before any per-order key upload or order request) MUST settle `failed`, whatever its kind." —
```

4. In API-58, immediately before “A create that has produced no machine yet”, insert:

```text
For the claimed create's tenant-status read, refusal and dispatch race guard, see OPS-43.
Orders already potentially dispatched retain OPS-27's attach and suspended-tenant cancellation
path, including later evidence-based attachment after the suspension parent has settled; OPS-27 says "**Where the machine's tenant is suspended at the moment of the attach, that same transaction also
enqueues a system cancellation** — `requested_by: system`, `system_reason: tenant_suspended`, under
the machine's `delete` episode, opening it or adding the reason to an episode this same transaction
opened (`OPS-39`, `OPS-48`) — the identical mechanism `API-58` step (3) uses on the fan-out and the
identical attach-then-route shape as `OPS-36`. This applies at **all three** entry points. It is needed
because `API-58`'s re-sweep stops once a pass finds no un-cancelled machine, and a create that has
not yet produced a machine passes that test: the parent settles `succeeded` — counting a
`needs_reconciliation` child as complete — and no later pass will ever look again. Without it, a
create resolving *observed* after that settlement attaches a funded, billing machine to a suspended
tenant and runs its whole runway, which is precisely the outcome `SEC-45`'s one-action suspension
must not depend on a human noticing. `OPS-36`'s attach-then-cancel does not cover it: that branch fires only
where `OPS-33` had already released the commitment, and here the commitment is still open and
becomes the machine's running commitment.".
```

5. In API-58, replace the complete bold suspension-promise sentence and its following sentence, beginning `**A suspension is not a promise` and ending `on this one branch it is not.`, at pinned lines 731–734, with:

```text
**A suspension is not a promise that the fleet is gone. It stops new purchase authorization
at OPS-43's tenant dispatch guard and accounts for every machine, including machines produced
by orders already potentially dispatched.** The terms and operator documentation MUST explain
that an order authorized for dispatch before suspension may still reach the provider and
complete afterwards, and that its resulting machine is subject to cancellation. They MUST NOT
promise that suspension recalls such an order or that cancellation has already succeeded.
```


**Acceptance criteria:**

6. In CNF-202, after the additional Q1 store cases if adopted, otherwise before its amendment note, append:

```text
Independently admit an otherwise valid create while the tenant is active, with a healthy provider
account and open ordering channel. Keep it unclaimed, commit suspension, then let a worker claim
the create before the suspension fan-out can fail it. Assert failed, conflict with
details.reason: "tenant_suspended", retryable: false on both error and operation view, no provider
request, no purchase or setup-fee/first-unit debit, full commitment release, original origin
stamp, and no admission-only suspended error.

Separately let the worker's early tenant read see active, then commit suspension before the
step-8 tenant guard. Assert the same refusal, allowing only preceding non-mutating reads,
no step-9 request, and no first-transaction about_to_order_at or correlator commit. Race the
tenant dispatch guard against suspension in both orders. Where the guard wins and its transaction
commits and is acknowledged, suspend before the provider call and assert the attempt is treated
as potentially dispatched and allowed to settle, with a system cancellation in the machine's
attach transaction if the tenant remains suspended. Exercise late evidence attachment after
the suspension parent has settled as well.

Lose step 8's acknowledgement, suspend before the whole-transaction repeat, and assert
deterministic pre-step-9 failure, unchanged previously committed about_to_order_at and correlator,
full release and no speculative dispatch. Retain the worker claim guard in every settlement.
Run these barriers on auction and standard-channel (correlator: none) descriptors and on a
provider using per-order temporary keys.

Independently combine an unhealthy provider account with a suspended tenant and assert the
account-status refusal wins. Combine a healthy account, suspended tenant and closed ordering
channel and assert tenant_suspended wins. Assert no provider request in either case.
```



### Q-POINTER — complete executable package

**Complete alternative Q4-D — preferred and ACCEPT.** All unspecified pinned text remains unchanged.

1. In OPS-43 step 1, after the account-status refusal paragraph and before step 2, insert:

```text
Next read this operation's tenant status. Where the tenant is suspended, fail this existing
create with conflict, details.reason: "tenant_suspended", and retryable: false on both the error
and operation view. This read precedes channel closure and boundary validation. Make no provider
request, including List offers or a per-order key upload. Settle failed with full commitment
release and no setup-fee or first-unit debit. For classification and settlement, see OPS-11. Preserve
requested_by and system_reason as originally recorded; do not emit the admission-only kind
suspended. This is a plain read; the dispatch guard below closes the race after it.
```

2. In OPS-43 step 8, after the STO-47 conditional-write check and before the operations-row write, insert:

```text
In this same transaction the worker MUST conditional-write the operation's tenants row guarded
on its status not being suspended. This write and the suspension flag write
MUST contend on that same row; a plain read or a lock confined to the earlier claim-time check
is not a substitute. For the admission-time suspension flag, see API-58. Where the tenant guard affects no row because suspension won, roll back
the step-8 transaction and record conflict, details.reason: "tenant_suspended", retryable: false
on both error and operation view, then settle failed with full
release and no setup-fee or first-unit debit. For classification and settlement, see OPS-11. No step-9 key upload or order may begin. A first
failed transaction commits neither about_to_order_at nor a correlator. A whole-transaction
repeat after a lost acknowledgement rechecks this guard too: if suspension now defeats it,
keep any previously committed about_to_order_at and correlator unchanged and settle the
worker's recorded failure as a pre-step-9 failure; do not add a null-column term to
the settlement guard. For classification and settlement, see OPS-11. OPS-49 says "the component MUST repeat the **whole
transaction** — never the last failed statement, and never the provider call (`OPS-12`)" and "A
  serialization failure is repeated at once."; retry a serialization failure as a whole transaction and do not treat it as a tenant-status refusal. The operation-row claim guard and acknowledgement-before-
step-9 rules remain required.
```

3. In API-58 step (2), replace the complete span beginning `**fences work already in flight**` and ending `unrecorded and unbilled —`, immediately before `then (3)`, with:

```text
**fences work already in flight** — a create that passed OPS-43's tenant dispatch guard before
the suspension landed is potentially dispatched and MUST be allowed to settle rather than
abandoned mid-order; for its machine, see OPS-27. A claim by
itself does not authorize purchase: a create that first reads the tenant suspended fails under
OPS-43, and suspension winning the step-8 tenant guard also prevents purchase. A create past
the guard can still be between the acknowledged transaction and its provider call, because
OPS-43 says "Step 9 MUST begin only after step 8's transaction is acknowledged."; treat that residue as the potentially dispatched
case. Never fail or release such an uncertain order through the never-claimed administrative
write. This does not override a deterministic failure the worker actually records before step 9:
OPS-11 says "Any create failure the worker records before any step-9 request (before any per-order key upload or order request) MUST settle `failed`, whatever its kind." —
```

4. In API-58, immediately before “A create that has produced no machine yet”, insert:

```text
For the claimed create's tenant-status read, refusal and dispatch race guard, see OPS-43.
For orders already potentially dispatched, including later evidence-based attachment after
the suspension parent has settled, see OPS-27.
```

5. In API-58, replace the complete bold suspension-promise sentence and its following sentence, beginning `**A suspension is not a promise` and ending `on this one branch it is not.`, at pinned lines 731–734, with:

```text
**A suspension is not a promise that the fleet is gone. It stops new purchase authorization
at OPS-43's tenant dispatch guard and accounts for every machine, including machines produced
by orders already potentially dispatched.** The terms and operator documentation MUST explain
that an order authorized for dispatch before suspension may still reach the provider and
complete afterwards, and that its resulting machine is subject to cancellation. They MUST NOT
promise that suspension recalls such an order or that cancellation has already succeeded.
```


**Acceptance criteria:**

6. In CNF-202, after the additional Q1 store cases if adopted, otherwise before its amendment note, append:

```text
Independently admit an otherwise valid create while the tenant is active, with a healthy provider
account and open ordering channel. Keep it unclaimed, commit suspension, then let a worker claim
the create before the suspension fan-out can fail it. Assert failed, conflict with
details.reason: "tenant_suspended", retryable: false on both error and operation view, no provider
request, no purchase or setup-fee/first-unit debit, full commitment release, original origin
stamp, and no admission-only suspended error.

Separately let the worker's early tenant read see active, then commit suspension before the
step-8 tenant guard. Assert the same refusal, allowing only preceding non-mutating reads,
no step-9 request, and no first-transaction about_to_order_at or correlator commit. Race the
tenant dispatch guard against suspension in both orders. Where the guard wins and its transaction
commits and is acknowledged, suspend before the provider call and assert the attempt is treated
as potentially dispatched and allowed to settle, with a system cancellation in the machine's
attach transaction if the tenant remains suspended. Exercise late evidence attachment after
the suspension parent has settled as well.

Lose step 8's acknowledgement, suspend before the whole-transaction repeat, and assert
deterministic pre-step-9 failure, unchanged previously committed about_to_order_at and correlator,
full release and no speculative dispatch. Retain the worker claim guard in every settlement.
Run these barriers on auction and standard-channel (correlator: none) descriptors and on a
provider using per-order temporary keys.

Independently combine an unhealthy provider account with a suspended tenant and assert the
account-status refusal wins. Combine a healthy account, suspended tenant and closed ordering
channel and assert tenant_suspended wins. Assert no provider request in either case.
```



### Q-KEEP — complete executable package

**Complete alternative Q4-D — preferred and ACCEPT.** All unspecified pinned text remains unchanged.

1. In OPS-43 step 1, after the account-status refusal paragraph and before step 2, insert:

```text
Next read this operation's tenant status. Where the tenant is suspended, fail this existing
create with conflict, details.reason: "tenant_suspended", and retryable: false on both the error
and operation view. This read precedes channel closure and boundary validation. Make no provider
request, including List offers or a per-order key upload. Settle failed with full commitment
release and no setup-fee or first-unit debit under OPS-11's pre-step-9 create rule. Preserve
requested_by and system_reason as originally recorded; do not emit the admission-only kind
suspended. This is a plain read; the dispatch guard below closes the race after it.
```

2. In OPS-43 step 8, after the STO-47 conditional-write check and before the operations-row write, insert:

```text
In this same transaction the worker MUST conditional-write the operation's tenants row guarded
on its status not being suspended. This write and API-58's admission-time suspension flag write
MUST contend on that same row; a plain read or a lock confined to the earlier claim-time check
is not a substitute. Where the tenant guard affects no row because suspension won, roll back
the step-8 transaction and record conflict, details.reason: "tenant_suspended", retryable: false
on both error and operation view, then settle failed under OPS-11's pre-step-9 rule with full
release and no setup-fee or first-unit debit. No step-9 key upload or order may begin. A first
failed transaction commits neither about_to_order_at nor a correlator. A whole-transaction
repeat after a lost acknowledgement rechecks this guard too: if suspension now defeats it,
keep any previously committed about_to_order_at and correlator unchanged and settle the
worker's recorded failure under the same pre-step-9 rule; do not add a null-column term to
the settlement guard. OPS-49 says "the component MUST repeat the **whole
transaction** — never the last failed statement, and never the provider call (`OPS-12`)" and "A
  serialization failure is repeated at once."; retry a serialization failure as a whole transaction and do not treat it as a tenant-status refusal. The operation-row claim guard and acknowledgement-before-
step-9 rules remain required.
```

3. In API-58 step (2), replace the complete span beginning `**fences work already in flight**` and ending `unrecorded and unbilled —`, immediately before `then (3)`, with:

```text
**fences work already in flight** — a create that passed OPS-43's tenant dispatch guard before
the suspension landed is potentially dispatched and MUST be allowed to settle rather than
abandoned mid-order; its machine follows OPS-27's suspended-attach cancellation. A claim by
itself does not authorize purchase: a create that first reads the tenant suspended fails under
OPS-43, and suspension winning the step-8 tenant guard also prevents purchase. A create past
the guard can still be between the acknowledged transaction and its provider call, because
OPS-43 says "Step 9 MUST begin only after step 8's transaction is acknowledged."; treat that residue as the potentially dispatched
case. Never fail or release such an uncertain order through the never-claimed administrative
write. This does not override a deterministic failure the worker actually records before step 9:
OPS-11 says "Any create failure the worker records before any step-9 request (before any
per-order key upload or order request) MUST settle `failed`, whatever its kind." —
```

4. In API-58, immediately before “A create that has produced no machine yet”, insert:

```text
For the claimed create's tenant-status read, refusal and dispatch race guard, see OPS-43.
Orders already potentially dispatched retain OPS-27's attach and suspended-tenant cancellation
path, including later evidence-based attachment after the suspension parent has settled.
```

5. In API-58, replace the complete bold suspension-promise sentence and its following sentence, beginning `**A suspension is not a promise` and ending `on this one branch it is not.`, at pinned lines 731–734, with:

```text
**A suspension is not a promise that the fleet is gone. It stops new purchase authorization
at OPS-43's tenant dispatch guard and accounts for every machine, including machines produced
by orders already potentially dispatched.** The terms and operator documentation MUST explain
that an order authorized for dispatch before suspension may still reach the provider and
complete afterwards, and that its resulting machine is subject to cancellation. They MUST NOT
promise that suspension recalls such an order or that cancellation has already succeeded.
```


**Acceptance criteria:**

6. In CNF-202, after the additional Q1 store cases if adopted, otherwise before its amendment note, append:

```text
Independently admit an otherwise valid create while the tenant is active, with a healthy provider
account and open ordering channel. Keep it unclaimed, commit suspension, then let a worker claim
the create before the suspension fan-out can fail it. Assert failed, conflict with
details.reason: "tenant_suspended", retryable: false on both error and operation view, no provider
request, no purchase or setup-fee/first-unit debit, full commitment release, original origin
stamp, and no admission-only suspended error.

Separately let the worker's early tenant read see active, then commit suspension before the
step-8 tenant guard. Assert the same refusal, allowing only preceding non-mutating reads,
no step-9 request, and no first-transaction about_to_order_at or correlator commit. Race the
tenant dispatch guard against suspension in both orders. Where the guard wins and its transaction
commits and is acknowledged, suspend before the provider call and assert the attempt is treated
as potentially dispatched and allowed to settle, with a system cancellation in the machine's
attach transaction if the tenant remains suspended. Exercise late evidence attachment after
the suspension parent has settled as well.

Lose step 8's acknowledgement, suspend before the whole-transaction repeat, and assert
deterministic pre-step-9 failure, unchanged previously committed about_to_order_at and correlator,
full release and no speculative dispatch. Retain the worker claim guard in every settlement.
Run these barriers on auction and standard-channel (correlator: none) descriptors and on a
provider using per-order temporary keys.

Independently combine an unhealthy provider account with a suspended tenant and assert the
account-status refusal wins. Combine a healthy account, suspended tenant and closed ordering
channel and assert tenant_suspended wins. Assert no provider request in either case.
```



## Q2 — exact landing choices, conditional on your Q1 pick

**L-SPEC:** Apply only your selected Q1 substitutions to the six landed spec blocks on pv-kv2. Leave comment860 and the historical archive byte-identical. No tracker status change. For Q-KEEP this is no edit.

**L-SYNC:** Apply those exact spec substitutions and the complete selected `options/<Q1>-agent-brief.md` to pv-kv2 comment860, updating only that decoded comment text; leave every other row/field/comment/status byte unchanged. Keep the archived r83/r83b/Q4-D.md including Panel O's appendix unchanged. Bead remains closed. For Q-KEEP there is no executable change or authority-line update.

**L-NOTE:** Apply L-SYNC and append the exact matching `note-<Q1>.md` below to `docs/research/panels-2026-10/r83/r83b/Q4-D.md`, **after** Panel O's L-NOTE appendix. Every byte already in the archive remains an exact historical prefix. Archive r95's reviewed record/notes so `../../r95/notes.md` resolves; do not silently rewrite this dependency. Panel O's settled file and every external panel folder remain unchanged. Bead remains closed. For Q-KEEP its matching draft is a conditional review record, not an exemption finding; a reader voting KEEP must supply its exact evidence-bearing final note, otherwise that combination is not a complete reviewed form.

For L-SYNC/L-NOTE and changed Q1, the exact authority line changes from:

```text
**Owner decision:** “D: explain exception” (`owner-decisions-1030.md`, item 19). Historical adopted form: `docs/research/panels-2026-10/r83/r83b/Q4-D.md`. Executable form: the Desired behavior / key interfaces and Acceptance criteria blocks below, with the 2026-10-31 Panel O r94 wording correction.
```
to:
```text
**Owner decision:** “D: explain exception” (`owner-decisions-1030.md`, item 19). Historical adopted form: `docs/research/panels-2026-10/r83/r83b/Q4-D.md`. Executable form: the Desired behavior / key interfaces and Acceptance criteria blocks below, with the 2026-10-31 Panel O r94 wording correction and the 2026-11-02 Panel P r95 wording correction.
```

### L-NOTE appendix matching Q-QUOTE (complete, including leading blank)

````text

## Wording correction — 2026-11-02 (Panel P r95)

The text above, including Panel O’s 2026-10-31 appendix, is retained as the historical record.
The pv-kv2 specification and executable Agent Brief use the following additional replacements
under the owner’s 2026-10-28 wording rule; all other text is retained.

Replacement 1, for the matching executable passage (including Panel O’s substitution where applicable):

```text
Settle failed with full commitment
release and no setup-fee or first-unit debit under OPS-11's pre-step-9 create rule; OPS-11 says "Any create failure the worker records before any step-9 request (before any per-order key upload or order request) MUST settle `failed`, whatever its kind." and “The commitment is released in full under `LDG-32` ("A commitment MUST be closed, and its remaining amount released in full") and `LDG-39` ("**Never debited**; released with the commitment (`LDG-32`)"), with no setup-fee or first-unit debit.”.
```

Replacement 2, for the matching executable passage (including Panel O’s substitution where applicable):

```text
on both error and operation view, then settle failed under OPS-11's pre-step-9 rule with full
release and no setup-fee or first-unit debit; OPS-11 says "Any create failure the worker records before any step-9 request (before any per-order key upload or order request) MUST settle `failed`, whatever its kind." and “The commitment is released in full under `LDG-32` ("A commitment MUST be closed, and its remaining amount released in full") and `LDG-39` ("**Never debited**; released with the commitment (`LDG-32`)"), with no setup-fee or first-unit debit.”.
```

Replacement 3, for the matching executable passage (including Panel O’s substitution where applicable):

```text
worker's recorded failure under the same pre-step-9 rule; do not add a null-column term to
the settlement guard; OPS-11 says "Any create failure the worker records before any step-9 request (before any per-order key upload or order request) MUST settle `failed`, whatever its kind." and “The settle write keeps the ordinary worker guard (`STO-3`; `OPS-6`: "every write that worker makes to the operation MUST carry `claim_number = mine`"), with no `about_to_order_at IS NULL` term.”.
```

Replacement 4, for the matching executable passage (including Panel O’s substitution where applicable):

```text
abandoned mid-order; its machine follows OPS-27's suspended-attach cancellation; OPS-27 says "**Where the machine's tenant is suspended at the moment of the attach, that same transaction also
enqueues a system cancellation** — `requested_by: system`, `system_reason: tenant_suspended`, under
the machine's `delete` episode, opening it or adding the reason to an episode this same transaction
opened (`OPS-39`, `OPS-48`) — the identical mechanism `API-58` step (3) uses on the fan-out and the
identical attach-then-route shape as `OPS-36`. This applies at **all three** entry points. It is needed
because `API-58`'s re-sweep stops once a pass finds no un-cancelled machine, and a create that has
not yet produced a machine passes that test: the parent settles `succeeded` — counting a
`needs_reconciliation` child as complete — and no later pass will ever look again. Without it, a
create resolving *observed* after that settlement attaches a funded, billing machine to a suspended
tenant and runs its whole runway, which is precisely the outcome `SEC-45`'s one-action suspension
must not depend on a human noticing. `OPS-36`'s attach-then-cancel does not cover it: that branch fires only
where `OPS-33` had already released the commitment, and here the commitment is still open and
becomes the machine's running commitment.".
```

Replacement 5, for the matching executable passage (including Panel O’s substitution where applicable):

```text
Orders already potentially dispatched retain OPS-27's attach and suspended-tenant cancellation
path, including later evidence-based attachment after the suspension parent has settled; OPS-27 says "**Where the machine's tenant is suspended at the moment of the attach, that same transaction also
enqueues a system cancellation** — `requested_by: system`, `system_reason: tenant_suspended`, under
the machine's `delete` episode, opening it or adding the reason to an episode this same transaction
opened (`OPS-39`, `OPS-48`) — the identical mechanism `API-58` step (3) uses on the fan-out and the
identical attach-then-route shape as `OPS-36`. This applies at **all three** entry points. It is needed
because `API-58`'s re-sweep stops once a pass finds no un-cancelled machine, and a create that has
not yet produced a machine passes that test: the parent settles `succeeded` — counting a
`needs_reconciliation` child as complete — and no later pass will ever look again. Without it, a
create resolving *observed* after that settlement attaches a funded, billing machine to a suspended
tenant and runs its whole runway, which is precisely the outcome `SEC-45`'s one-action suspension
must not depend on a human noticing. `OPS-36`'s attach-then-cancel does not cover it: that branch fires only
where `OPS-33` had already released the commitment, and here the commitment is still open and
becomes the machine's running commitment.".
```

Replacement 6, for the matching executable passage (including Panel O’s substitution where applicable):

```text
This write and API-58's admission-time suspension flag write
MUST contend on that same row; a plain read or a lock confined to the earlier claim-time check
is not a substitute; API-58 says "marks the tenant `suspended` **in the admission transaction, before the `202` is returned**".
```

Replacement 7, for the matching executable passage (including Panel O’s substitution where applicable):

```text
OPS-11 says "Any create failure the worker records before any step-9 request (before any per-order key upload or order request) MUST settle `failed`, whatever its kind."
```

Source pin: `6a3b6014f1f8b36fc21b902e507e74d8c5264e99`.
Review head: `96a72898c7ace67790aec0bab3727eee858e2245`.
Panel record: `../../r95/notes.md`.
````

### L-NOTE appendix matching Q-POINTER (complete, including leading blank)

````text

## Wording correction — 2026-11-02 (Panel P r95)

The text above, including Panel O’s 2026-10-31 appendix, is retained as the historical record.
The pv-kv2 specification and executable Agent Brief use the following additional replacements
under the owner’s 2026-10-28 wording rule; all other text is retained.

Replacement 1, for the matching executable passage (including Panel O’s substitution where applicable):

```text
Settle failed with full commitment
release and no setup-fee or first-unit debit. For classification and settlement, see OPS-11.
```

Replacement 2, for the matching executable passage (including Panel O’s substitution where applicable):

```text
on both error and operation view, then settle failed with full
release and no setup-fee or first-unit debit. For classification and settlement, see OPS-11.
```

Replacement 3, for the matching executable passage (including Panel O’s substitution where applicable):

```text
worker's recorded failure as a pre-step-9 failure; do not add a null-column term to
the settlement guard. For classification and settlement, see OPS-11.
```

Replacement 4, for the matching executable passage (including Panel O’s substitution where applicable):

```text
abandoned mid-order; for its machine, see OPS-27.
```

Replacement 5, for the matching executable passage (including Panel O’s substitution where applicable):

```text
For orders already potentially dispatched, including later evidence-based attachment after
the suspension parent has settled, see OPS-27.
```

Replacement 6, for the matching executable passage (including Panel O’s substitution where applicable):

```text
This write and the suspension flag write
MUST contend on that same row; a plain read or a lock confined to the earlier claim-time check
is not a substitute. For the admission-time suspension flag, see API-58.
```

Replacement 7, for the matching executable passage (including Panel O’s substitution where applicable):

```text
OPS-11 says "Any create failure the worker records before any step-9 request (before any per-order key upload or order request) MUST settle `failed`, whatever its kind."
```

Source pin: `6a3b6014f1f8b36fc21b902e507e74d8c5264e99`.
Review head: `96a72898c7ace67790aec0bab3727eee858e2245`.
Panel record: `../../r95/notes.md`.
````

### L-NOTE appendix matching Q-KEEP (complete, including leading blank)

````text

## Wording review — 2026-11-02 (Panel P r95)

No wording change. This option is eligible only if the panel establishes that AGENTS.md’s quotation rule does not apply to every challenged sentence. The exact finding and exemption evidence must be archived with the panel record; no exemption is asserted by this draft.
````

## Required answer

1. First preferences: `Q1: <exact form>` and `Q2: <landing>`. Separately ACCEPT/CANNOT ACCEPT every supplied Q1 form and every Q2 landing, stating conditions. If none passes, supply a complete exact alternative package, matching full replacement snippets and archive note, not a sketch or an unreviewed synthesis. Distinct forms remain distinct.
2. Inventory every summary attribution of OPS11, OPS27 or another requirement in the six blocks with H path:line; include comment860 decoded line and archival counterparts. Separate genuine retained-source claims, already-quoted claims, bare pointers, and this package's own new rules; quote the evidence for each distinction. Check no occurrence was missed.
3. For **both picks** separately classify behavior, requirements/owner items3+19/Panel O meaning, and check strength as WORDING-ONLY or SUBSTANTIVE with evidence. Give the exact source bytes for every quotation and verify each against M (including embedded emphasis/backticks/LF/indentation). Report inherited differences instead of claiming identity. Explain provenance of every beyond-snippet clause and how your pick carries it: release/no debit, refusal kinds and retryability, post-parent late evidence, all entry points, lost acknowledgement, guarded settlement, and dispatch classification.
4. Name **each assertion** of original Q4-D and Panel O settlement and the exact surviving sentence/location in your pick, covering: account-first then tenant-before-channel/boundary ordering; no List offers/key/provider request on early refusal; conflict/tenant_suspended/false on error+view; original origin/admission-only exclusion; plain early read; same-row conditional tenant guard vs API58 suspension; no plain-read substitute; zero-row rollback+failure+full release/no debit; no step9; no first failed commit of timestamp/correlator; lost-ack repeat rechecks, retains prior columns, no null guard; whole-transaction immediate serialization retry distinct from refusal; claim guard and acknowledged-before-step9; past-guard potential dispatch allowed to settle; claim alone insufficient; guarded-but-not-called residue; uncertain no administrative fail/release while actual recorded pre-step9 failure still fails; cancellation at attach with suspended predicate; later evidence attach after parent settles; exact item5 public exception/disclaimer without restored existing-fleet warning duty; **every** item6 conformance assertion, channel/correlator/per-order-key coverage and error precedence. No weaker assertion, no A/D mixture, no publication duty restored, no pv-gvc/pv-bxh expansion.
5. Explain which landing keeps history honest while keeping executable spec/brief consistent on a closed bead. Name the changed bytes and unchanged historical prefix. Give the strongest case against your picks labelled COUNTERARGUMENT, distinct from your vote. State any contradiction within this brief independently of correctness; apply notes.md rule6 exactly as written.

Final line: `Final: Q1=<exact form>; Q2=<landing>; behavior=<...>; requirements=<...>; check-strength=<...>; owner-needed=<yes/no with reason>.`
