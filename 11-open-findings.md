# 11 — Open findings

An independent structural audit read all twelve documents end to end on 2026-08-09 and
returned **21 findings, 5 of them critical**, with the verdict:

> **NO.** A competent engineer could not build this without asking the author questions.

A separate usability audit reached the same conclusion by a different route: the `core`,
`providers` and `rescue` documents are buildable on day one; every stall is in the API and
persistence surface.

This file tracks all of it. Items marked **FIXED** were resolved on 2026-08-09; **CLOSED
2026-08-11** marks those resolved by the design session that produced `docs/adr/`. The rest are
open and inherited by whoever picks this up.

## The three questions a builder must ask first — all three now answered

They are kept here rather than deleted, because a reader who was told these were blocking
deserves to see where each landed.

1. **Which deployment form and tenant model is authoritative?** → `ADR-0001` (single deployable)
   and `ADR-0002` (self-serve enrolment, registry required). Customer credentials are runtime-
   issued (`API-32`–`API-37`, `STO`'s `tenants` table); per-tenant spending ceilings were replaced as the *authorization* mechanism (`SEC-39`'s
   destruction and creation ceilings remain, as abuse bounds rather than spending authority)
   because
   `ADR-0002` replaced the whole idea with a prepaid balance.
2. **How is `needs_reconciliation` resolved without replaying the mutation?** → `OPS-27`–`OPS-33`.
   Resolution searches for a correlator the create wrote into the provider (`PRV-26`, `PRV-27`);
   attaching a discovered resource is `PRV-28`'s adopt path; `OPS-31` gives operator verbs for
   what cannot be resolved automatically.
3. **What is the complete deletion and billing contract?** → `PRV-13b`–`PRV-13e` for the reserve,
   `machine_attachments` and `STO-18` for the cleanup surface, `STO-17` for cross-tenant
   ownership, and `12-billing-and-ledger.md` for everything downstream of the money.

**A fourth question replaces them, and it is not a specification question.** Nothing in this set
has been validated against a running system, a real provider response, or a paying customer. The
design is now internally consistent and considerably more opinionated than it was — which raises,
rather than lowers, the value of the first real transaction.

## The review of the review — 2026-09-08

A read of the text `F40`–`F45` produced, by readers with no memory of writing it, hunting for
invented behaviour and for stale sentences the sweep missed. The deletion half held: the leases,
the machine lock, `machines.system_trigger_ids` and requeue survive only in withdrawal records.
The construction half did not, and the first finding is the one that matters.

**F46. CLOSED — the epoch was not a fence, and it failed the way the leases failed.** `OPS-47`
said "Every engine write to `operations` and `machines` MUST be guarded on `epoch = mine`", and
`operations.epoch` was "stamped by `STO-1`'s claim" — by the claiming process, from the value it
held. A worker checking that the row still carried its own number was checking a value it wrote
itself, so the term held by construction; `engine_epoch` was read once in the set, at increment,
and compared to nothing. Of `STO-3`'s four conditional writes only the worker's carried the term,
and the one doing the work was the startup pass, "guarded on `(id, status = running)`". So the
guard caught a process whose operations the successor had already swept, and a process that woke
past a restart and claimed a *fresh* operation passed every check and ran alongside the live
engine indefinitely. `ADR-0016`'s "the guard is what makes "exactly one" a property the store
checks rather than a deployment promise" was false as written — the same sentence `F40` records
against the leases, that "The promise was in prose and absent from the predicate."

Two things compounded it: `machines` carried no such column though `OPS-47` demanded the guard
there, leaving `OPS-42`'s fence unguarded; and `CNF-290`, BLOCKING, asked for a stale machine write
"carrying the previous `engine_epoch`" that no table could hold. **Closed by `ADR-0019`**: the
epoch is deleted, a second concurrent engine is stated as out of scope with the supervisor named as
the guarantee, and the engine takes a session-scoped lock at boot that refuses a second *start* and
is not a fence. `OPS-3`, `OPS-5`, `OPS-22`, `OPS-47`, `STO-1`, `STO-3`, `STO-51`, `CNF-197`,
`CNF-290`, `OVR-19`.

*The lesson is narrower than "check your predicates" and worth keeping in the vocabulary
(`CONTEXT.md`): a guard whose compared value has one writer, which is the thing being guarded,
is not a check and reads exactly like one.*

**Open, and not addressed here.** The same read produced findings this session did not act on. They
are recorded so the next one does not have to find them again. Three were decisions. One is
closed: `adopt` classified "Always `failed`" under `OPS-11` while `WIR-35` and `05-persistence.md`'s
`resolution` column admitted `observed`, `absent` and `abandoned` for it and `CNF-179` (BLOCKING)
tested them — **`F47`, closed by `ADR-0020`**. Another is closed: three places said transient
cases "are deferred rather than failed (`OPS-11`)" and `OPS-11` defers nothing, so a provider
throttle on a delete stalls an episode a human must clear — **`F48`, closed by retraction on
2026-09-09**. The third was `DOM-31` drawing
`stalled --> closed : abandoned` with no verb providing it — **`F49`, closed by `ADR-0021`** the
same day. The rest were
mechanical and were closed on 2026-09-08 without an ADR: `PRV-42`'s per-channel declaration now
lives in `PRV-44`'s `ordering_channels[].offer_is_resource`; `PRV-36`'s headline, `OPS-32`,
`LDG-74`, `PRV-42`, `CNF-277` and `CNF-237` read "effective" where they read "declared";
`release_attachment` is in `WIR-10b`'s result shapes, `OPS-45`'s scope and marker table and the
store's `resolution` set, and `API-65`/`WIR-52` give it the operator route `PRV-45` presupposed;
and `LDG-34` names the writers it actually serializes. Of the implementation-process review's three
untaken sections, §6.13 is `F47`; §6.14's first three resolutions closed 2026-09-09 when every
conformance item received its tier inline, and its last two — mutually exclusive launch items, and
a historical heading read as authoritative — are `F50`'s first and seventh items; §6.15 is `F51`,
closed 2026-09-12.

**F47. CLOSED — adopt was specified two ways, could not size its own commitment, and had no v1
scenario.** Found by the `F46` read; taken up 2026-09-08 with two independent reviews of one
brief, by Codex and by a fresh Claude reader, before anything was decided. Both confirmed the
provider half of adopt is a read (`PRV-28` "get-machine (`PRV-12`) followed by writing a local
row") and found no scenario in which the provider's state after an adopt is unknowable. Both found
the same things the brief had missed: `OPS-15` sent an interrupted adopt — and an interrupted
refresh — to `needs_reconciliation`, so the union's verbs were reachable by restart and by
`OPS-21`'s cancellation, uncertainty manufactured by classification rather than by anything the
provider did; `LDG-32` named no failed adopt, so an adopt the provider refused froze its
commitment with no verb to release it; `PRV-31` said the adopted machine's date "is read before
its commitment opens" while `LDG-11` and `API-7`'s tail opened it at enqueue; and the commitment
could not be sized at enqueue at all, because `PRV-13b` needs a rate and a date that an adopted
machine, having no offer, could only get from the read. Both recommended a synchronous operator
adopt that reads first. The decision went one step further: checked against the providers' own
API documents, an adopted machine's cost is readable on Hetzner Cloud and DigitalOcean, is a list
price at best on Robot, and does not exist anywhere in Robot's API for an auction server — and the
three scenarios that wanted adopt were each something else (a hand-bought machine, dismissed; a
re-rent, which is `ADR-0006`'s inventory; a home lab, which is a driver of its own). `ADR-0020`
withdraws adopt from v1 with its whole surface and records the synchronous shape as what it returns
in. `OPS-15` gains the refresh exception the same review exposed.

*The reviews' change inventories, kept for the return:* the asynchronous repair would have touched
`OPS-1`, `OPS-15`, `OPS-21`, `OPS-31`, `OPS-35`, `OPS-45`, `API-7`, `STO-3`, `LDG-12`, `LDG-32`,
`LDG-36`, `WIR-35`, `CNF-29`, `CNF-179`, `CNF-253`, `CNF-258`, `CNF-288`; the synchronous one
`API-7`, `API-11`, `API-13`, `API-28`, `API-48`, `API-58`, `API-63`, `STO-23`, `SEC-32`, `SEC-39`
(no adopt ceiling was ever named), `LDG-11`, `LDG-12`, `LDG-32`, `LDG-36`, `WIR-10`, `WIR-10a`,
`WIR-10b`, `WIR-18`, `WIR-35`, `CNF-61`, `CNF-179`, `CNF-258`, `CNF-288`, plus `OVR-9`'s
credential-free trait for the read and `LDG-69`, which says "While it is held, an implementation
MUST NOT wait on" anything outside the transaction, the provider read included.

**F48. CLOSED by retraction — "the transient cases are deferred rather than failed (`OPS-11`)" was
false in three places, and the deferral it named is not specified.** Found by the `F46` read; taken
up 2026-09-09. `OPS-48`, `API-64` and `ADR-0017`'s retry bullet each said a transient provider
failure on a cancellation attempt is deferred, citing `OPS-11`. `OPS-11` sorts a failure into
`failed` or `needs_reconciliation`, or `succeeded` where a rejection reports the goal state; it
defers nothing. `rate_limited` is on neither of its ambiguity
lists, so a throttled delete settles `failed`, `OPS-48` moves the episode to `stalled`, and an
operator's `retry` is the only way out. The only deferral in the set is `OPS-8`'s return-to-`queued`
on an index refusal, and nothing routes a throttle there.

The first decision was to specify the mechanism: one rule at the worker returning any
`rate_limited` outcome to `queued` with `available_at` set, on every operation kind, bounded by the
`attempts` counter. It was put to two independent reviews of one brief — Codex and a fresh Claude
reader — before anything was written, and both rejected it as decided, for the same reasons:

- **A 429 says one request was not processed; every operation is several requests.** A Robot create
  is an order then a poll (`PRV-11`), so a throttled poll after an accepted order would re-run and
  place a second order — `DEF-17` reopened, one day after `ADR-0014` and `ADR-0017`. A Robot delete
  reads the cancellation first and `PRV-45` lists attachments after success, so even the
  single-mutation kinds are not single-request. Rescue kinds are worse: a throttle after activation
  re-activates, mints a second per-operation key (`RSC-10`), and orphans a session whose cleanup
  token lives only in memory — `DOM-11`: "A rescue session carries a live credential. It MUST NOT
  be persisted". The eligibility that would make deferral safe is "no
  mutating request of this operation has been sent", which is a fact only the driver has (`PRV-5`),
  and no requirement obliges a driver to report it.
- **The bound was shaped for the wrong throttle.** `DOM-20`'s "clears in milliseconds under the
  deployment's own control" describes this deployment's limits on its callers. Robot's are 20 orders
  a day and 200 cancellations an hour (`PRV-40`); a handful of short waits expires inside one quota
  window and stalls anyway, and capping a provider's retry-after downwards sends a request before the
  provider said to. The bound would have to be wall-clock, added to `PRV-13b`'s reserve term — which
  prices machine *hold*, and a queued wait releases the machine while billing continues.
- **The counter does not mean what the brief assumed.** `OPS-6` increments `attempts` on a claim;
  nothing says an index-refused claim is one. Nothing else reads the column. *(As of 2026-09-12
  the column is `claim_number`, `OPS-6` says a refused claim "does not advance the number",
  `STO-3` reads it on every worker write, `STO-3` names six guarded writes and the defer is one,
  and the inventory below for a measured provider-throttle deferral predates all of that —
  `ADR-0022`, `F51`. The rejection itself stands.)*
- **The text forbids a re-run record.** `OPS-45`: "a record is no longer re-run (`ADR-0017`)"; the
  markers are write-once; `STO-3` names four guarded writes and running→queued is not one;
  `CNF-288`'s tail says of create, install, power and reverse DNS that "none of those kinds has a
  second attempt by any path", and `CNF-31a` and `CNF-201` assert `failed` where a deferral would
  intervene; `API-58` and
  `API-63` speak of work "queued, never claimed", which a deferred operation is not.
- **The sentences stay false under any bounded rule**, because an exhausted throttle reaches
  `stalled` regardless.

Two things one reviewer alone found are kept: Robot's documented rate-limit response may be a
`403` rather than a `429` (unverified against the API, and `08-provider-notes.md` pins no throttle
code for any provider), in which case a status-mapped driver never emits `rate_limited` on the one
provider the mechanism was written for; and `OPS-26`'s "nothing automatic will look at it again"
was itself overbroad, since `OPS-48`'s third row lets the exhaustion sweep close a `stalled` episode
it finds funded. The second is corrected alongside, with `CNF-271`'s "no timer ever moves a
`stalled` episode" narrowed to an unfunded machine.

**Decision: retract.** The three sentences now say the opposite, truthfully: a throttled attempt
stalls its episode like any other `failed` one. No deferral is specified, under the set's own rule
that a mechanism depending on provider behaviour is "derived from measurement rather than assumed"
(`OPS-33`'s window) — nobody has measured what a throttle looks like on Robot or Hetzner Cloud down
to the status code. The operational cost is accepted and bounded: a fleet-sized throttle is a
mass-cancellation event, `SEC-39` already gives operator retries an incident override, and `OPS-26`
lists the stalled episodes.

*The shape both reviewers converged on, kept for when it is measured:* a **driver** obligation in
`PRV-5` to emit `rate_limited` only where no mutating request of the operation has been sent, with a
throttle after one mapped as `PRV-11`'s shape with identifiers; a **worker** rule returning that kind
alone to `queued`, as a fifth `STO-3` guarded write on `(id, status = running)`; a **wall-clock**
deadline per operation on `OVR-19`, honoured over any retry-after that fits inside it, counted into
`wind_down_cost`; the throttle codes **pinned per provider** in `08-provider-notes.md`; and
`retryable: false` on the caller's view while the operation waits. *The change inventory the reviews
produced:* `OPS-3`'s diagram edge, `OPS-5`, `OPS-6`, `OPS-8`, `OPS-11` (the install row's
`rate_limited` entry and refresh's "Always `failed`"), `OPS-12`'s "no backoff loop", `OPS-45`'s
"no longer re-run", `OPS-48`'s table (a non-settling row), `STO-3`, `05-persistence.md` (`attempts`,
`available_at`, `write_started_at`), `PRV-5`, `PRV-11`, `PRV-13b`, `PRV-40` (requests, not
admissions, spend the budget), `PRV-44` (a cancellation limit beside `order_budget`), `OVR-19`,
`DOM-20`, `API-51`, `API-53`, `API-58`/`API-63`'s "never claimed", `SEC-39`'s per-entry ceiling
under a re-run, `DEF-17`, `ADR-0014`, the glossary's Operation/Attempt/Retry, and `CNF-27`,
`CNF-31a`/`b`, `CNF-32`, `CNF-201`, `CNF-220`, `CNF-271`, `CNF-283`, `CNF-288`.

**F49. CLOSED by `ADR-0021` — `DOM-31` drew an exit from `stalled` that nothing provided, and
behind it a terminated account's episodes stayed open forever.** Found by the `F46` read; taken up
2026-09-09 with the same two-review shape as `F47` and `F48`. The diagram's
`stalled --> closed : abandoned` had no verb: `abandoned` is `OPS-31`'s resolution of an attempt in
`needs_reconciliation`, the exit from `uncertain`, and a `stalled` episode's attempt is `failed`.
Both reviewers confirmed deleting the edge orphans nothing — every other `abandoned` in the set is
the resolution row, which stays — and both rejected the brief's claim that "funding the machine is
the other honest exit": `LDG-62` refuses an extension while the fence is set, so a customer cannot
fund a fenced machine at all, and `CNF-272`'s "resume the tenant, fund the machine, retry the
episode, and assert the machine survives" could not be executed as written. That was the strongest
case for an `abandon` verb, and it dissolved on `OPS-41`: a suspension cancels regardless of
funding, the re-check under a fresh attempt reads the tenant's *current* state, so `retry` after a
resume finds a machine that still has runway, aborts without a provider call, and closes the episode
`funded`. The word "fund" is removed from that step of `CNF-272`. The fresh read of the diff found
that `OPS-41`'s scope sentence still listed three reasons while its 2026-09-05 paragraph keyed the
exemption on the tenant's current state "not on the reason the operation was enqueued under" — the
two could not both hold, `CNF-272` already asserted the later one, and the scope is amended to every
exposure-reducing cancellation. The residual — a provider
that refuses indefinitely, a machine out of runway, a customer who wants to pay — is stated in
`OPS-42` as accepted, with no verb.

Both reviewers found the same second thing. `API-63` records every machine of a terminated account
gone, and `OPS-39` said "A tombstoned machine keeps any episode that is still open", so an episode
open at the recording sat `stalled` in `OPS-26`'s listing forever — the outcome `API-63`'s own text
called "a different failure", reached for the pre-existing episodes rather than the new ones. The
same hole sat behind `LDG-74`'s evidence write. `ADR-0021` keys the close on the machine's
gone-write, in any open state, with the guards the reviews named: the close is permanent, so a later
`OPS-31` resolution of a retained attempt changes the attempt and not the episode; the trigger is
never the account's status, so `OPS-36`'s late attach under a terminated account still goes
`stalled` — `API-63`: "That is the honest end for it"; `API-63` fails queued, never-claimed system cancellations as it fails creates; and `DOM-19` and
`STO-8a`, which held a scheduled machine until its date passed, admit the earlier, evidenced end.

*Kept from the reviews:* "retry finds it already gone" is a real path (`OPS-11`'s goal-state rule,
`OPS-48`'s first row) but is pinned to no provider's code for a machine delete in
`08-provider-notes.md` — only DigitalOcean's image delete is — and never returns that answer on a
dead account; `OPS-41`'s outage branch, which settles a machine whose meter stopped "as the
no-mutation case", no longer closes the episode `funded` by accident, because the meter stop *is*
the gone-write and the permanence rule makes the later settlement an attempt-only change; and
`STO-3` lists four guarded writes while `API-63`'s administrative `failed` on a queued create — and
now on a queued system cancellation, guarded on `status = queued` and `requested_by = system` —
are guarded writes `STO-3` does not list. The same read found `retry`'s state change and `OPS-42`'s
fence write unguarded against a gone-write committing between read and write; both now are. A
second narrow read of the `OPS-41` scope change found that `OPS-48`'s sweep-close row applied the
funding predicate with no suspension exemption, so a rate rise could un-fence a suspended tenant's
stalled machine and leave it running with nothing accounting for it; the row now carries the
exemption.

**F50. OPEN — the tier tags are a faithful copy of prose that was wrong in places.** On 2026-09-09
every checkbox item in `10-conformance-checklist.md` received its tier inline, copied from the
assignment paragraphs as they stood; `tools/check_ids.py` prints the count and refuses an untiered
item, and that closed the first three of the implementation-process review's §6.14 resolutions; its
fourth and fifth are items 1 and 7 below. The one departure from the prose
is `CNF-180`, which line 220 called "**before production** rather than blocking" — not a tier — and
which is tagged BLOCKING. Two independent readers built the mapping from the text and agreed on
every item; each also raised tier judgments, and the copy acted on none of them. They are recorded
here and nowhere else. Re-tiering an item is an edit to its tag with the reason added to its
assignment paragraph, not a second copy of the tier. Line numbers are the checklist's unless named.

1. **`CNF-187` and `CNF-238` demand opposite commitment states, and both are BLOCKING.** `CNF-187`
   (line 1047): "A machine deleted while a billable attachment survives keeps its commitment open
   and keeps metering that attachment; the commitment closes only when the last billable resource
   stops". `CNF-238` (line 1686): a delete against an already-deleted resource "classifies
   `succeeded` and its commitment closes (`LDG-32`)". `LDG-32` settles it — "Attachments keep the
   commitment open, and metering follows them" (`12-billing-and-ledger.md` line 298) — so `CNF-238`
   needs the last-billable-resource qualifier `CNF-187` already carries.
2. **Three graduation triggers are already true by the set's own text**, and each item is tagged
   PRE-SCALE because that is what the prose says. `CNF-34` "becomes blocking the moment anything but
   the API writes the store" (line 81–82), and the meter sits in `ledger` and "Posts debits and
   decrements commitments" (`00-overview.md` line 288). `CNF-193` "graduates the moment on-chain
   funding is enabled in production" (line 209), and `LDG-46` says a funding request "MUST return
   *both* a Lightning destination and an on-chain destination" (`12-billing-and-ledger.md` line
   1162). `CNF-245` "graduates when a second provider account exists" (line 2152), and `CNF-111`,
   BLOCKING, requires that "Tenants are distributed across more than one provider account" (line
   2050).
3. **PRE-SCALE items both readers read as BLOCKING under the rule at lines 31–55.** `CNF-174`
   (line 1973: "the raw token appears in no log line, URL, or operation record" — an escaped
   secret) and `CNF-189` (line 1056: the enrolment secrets "are stored hashed only" — the same
   family). Named by one reader each: `CNF-210`, `CNF-102`, `CNF-122`, `CNF-127`, `CNF-130` — whose
   own paragraph at lines 166–169 says "It is recorded here so that whoever re-tiers `CNF-99`
   re-examines this one in the same pass", written the same day `F30` promoted `CNF-99`, and no
   later pass has re-examined it — `CNF-235`, `CNF-252` and `CNF-270`.
4. **`CNF-288` asks for a state two kinds cannot reach.** Line 969: "For every operation kind,
   drive an operation to `failed` and to `needs_reconciliation`". `OPS-11`'s table
   (`03-operation-lifecycle.md` lines 186–187) has refresh "Always `failed`" and `suspend_tenant`
   "Never `needs_reconciliation`, and never `failed` as a whole".
5. **`PRV-34` names a withdrawn item as placing orders.** `02-provider-contract.md` line 678:
   "`CNF-180` and `CNF-280` place real orders"; `CNF-280` is a withdrawal marker (line 904).
6. **Two rationale paragraphs sit against the wrong item.** The assignment prose at lines 2006–2031
   follows `CNF-173` (line 2001) with no heading between them, so `tools/check_coverage.py` credits
   every citation in it to `CNF-173`. And the rationale for `CNF-236` at line 2097 — "a running
   total that has silently drifted from the entries" — describes a reconstruction test that the
   item at line 1707, "checked by range, not by reconstruction", no longer runs.
7. **`F17`'s "still open" on `CNF-58` and `CNF-65` was stale.** The promotion at line 86 applied on
   2026-08-13 and both tags read BLOCKING; that part of `F17` is closed in place below.

**F51. CLOSED 2026-09-12 — §6.15's four production-operability gaps are decided and their rules
have landed: `OPS-49` and the claim number (`ADR-0022`), `STO-54` (`ADR-0023`), `STO-12`/`STO-13`
(`ADR-0024`) and `STO-55`, each in its own commit.**
`ADR-0015` listed "backup and point-in-time recovery, connection pool sizing, migrations against a
live database, and the failure mode where the store is reachable but slow" as surface the set did
not specify, and `impl-report-01.md` §6.15 repeated it. Taken up 2026-09-10 to 2026-09-12 in one
session, each gap put to two independent readers of one brief before anything was decided —
Codex (`gpt-6-astra`, xhigh) paired with a fresh Claude reader, Fable or Opus. Every pair
reversed or reshaped the recommendation it was given; the reversals are in the ADRs. Three ADRs,
accepted when their amendments landed; the fourth gap is a requirement. After the landing, two
memoryless readers hunted the diff and found a contradiction on lock timeouts, a claim term
missing from the guard's repeat branch, the retry scope leaking to `api`, a deferred parent the
restore rule did not hold, and a dozen stale or overstated sentences; all are fixed in the
landing's last commit, and the ADRs carry the two amendments.

1. **The slow store — `ADR-0022`.** A store error is a bounded whole-transaction retry, then the
   engine exits. "Too slow" is `statement_timeout`; the client deadline is never shorter than
   `STO-7`'s server timeouts, so the only lost reply is a dead transport. Every worker write is
   idempotent under repeat — the settle guard admits the row it already produced, on `OPS-42`'s
   fence's own shape — and carries its **claim number**, because `OPS-8`'s defer lets one
   `running` row belong to two executions of one process and a retried defer would pull the second
   back to `queued` with every `STO-3` guard passing. `operations.attempts` becomes
   `operations.claim_number` across two releases; the glossary's **Attempt** was already the
   episode's word (`OPS-2`, `CNF-288`) and the column counted claims.
2. **Backup and restore — `ADR-0023`.** A restore is a recovery incident, never a restart: at
   `T − Δ` the engine *performs* destructive actions — a lost extension routes a paid machine into
   `LDG-14`, a revoked token comes back live, a `queued` create that already ordered orders again, a
   `suspend_tenant` parent re-runs a reversed fan-out. The procedure freezes the sweeps before the
   startup lock, escalates create, install and rescue inventory to `needs_reconciliation`, bumps
   every credential generation, and classifies the restore as a backward date move so `LDG-16`'s
   `exhausted_since` grace applies — a "funding quiet period" was proposed and withdrawn for it.
   Asynchronous replication with WAL archiving and a recovery-point alarm; `SET LOCAL
   synchronous_commit = on` only inside the deposit mint and `STO-30`'s credit, the two writes with
   no second truth. Synchronous commit everywhere was rejected because PostgreSQL has no server-side
   timeout for the standby wait, which would make `ADR-0022`'s lost reply the steady state on every
   write. `deposits.derivation_index` had no allocation rule and skips forward on restore.
3. **Migrations — `ADR-0024`.** The startup lock is on a connection outside the pool and an
   advisory lock conflicts only with its own key, so it excludes nothing from a migration. The
   migrator is the deployable's own entry point, run before any component of the release while the
   previous engine and `api` keep serving, under its own transaction-scoped lock on a distinct key.
   Expand-only is a rule about columns: a new `status` value written by the new engine is `STO-10`'s
   hard error on every old `api` read, so the release that adds a value does not write it, a new
   column is nullable until backfilled, a constraint must already hold, and a rename is a contract
   step one release later. A change to a predicate both components evaluate on shared rows —
   `LDG-33` first, where a skew destroys a paid disk with no schema change — is a stop-everything
   release, named as such. Rollback is the previous binary against the current schema up to a
   contract step.
4. **Pool sizing — `STO-55`, beside `STO-7`, no ADR** (a pool size is configuration, so the
   hard-to-reverse test fails, and both readers said so; `LDG-65` is the precedent). The engine's pool is one connection per worker plus one per periodic
   component; each `api` replica's is one per admitted request plus its periodic rows; the sum with
   the lock connection, the migrator and an operator reserve fits `max_connections` less the
   reserved slots, and the engine checks its own share at startup. The rule that makes the
   arithmetic true is the load-bearing part, and it did not exist: **a component holds at most one
   transaction at a time and never holds one across a provider, rail or rescue-host call** — a sweep
   iterating a cursor on one connection while writing on another deadlocks a pool sized this way on
   its first pass, and `LDG-69`'s prohibition was scoped to the primitive alone. A request that
   obtains no connection within a stated bound is refused before any transaction begins, so
   `API-11` sees nothing to replay; the status is `overloaded`, a new admission-only kind, since
   `API-50` promises an obedient caller is never `rate_limited` for rate. Concurrent
   synchronous-commit transactions per replica are capped so a stalled standby cannot occupy the
   pool. A `lock_timeout` on `LDG-35`'s primitive or `STO-52`'s index rolls back, releases the
   connection, and repeats the whole transaction with the provider result retained, against the same
   store-retry bound — `ADR-0022` first said a lock timeout does "not consume the bound" and never
   what the worker then does, which read literally is an unbounded loop on a held primitive; the
   ADR is amended. A `suspend_tenant` parent waiting on children is returned to `queued` with
   `available_at` advanced, the same write as `OPS-8`'s defer, never held in a worker slot — and
   `STO-54` therefore holds a `queued` unsettled parent for confirmation on a restore as well as a
   `running` one. The three `ledger` components of `OVR-17` are placed in the engine process,
   decided here because the pool is sized by counting them. A transaction-mode pooler may front the pools only with
   `STO-7`'s settings applied to the role, and never carries `OPS-47`'s lock connection. Found
   beside it: **the engine's worker count and `LDG-37`'s metering cadence are on no register**,
   against `OVR-19`'s own rule; both are added, and lag past one cadence interval is alarmed.

The second paragraph of §6.15 — account-level notices, repeat-offence policy, case-ended signals —
was already answered: "Still deliberately absent" above, and `STO-39`'s "repeat-offence policy
(which remains deliberately absent)". Closed by citation.

## The implementation-process review — 2026-09-06, closed 2026-09-07

An implementation-readiness review (`impl-report-01.md`, kept at the root as the record) read the
whole set as a builder would and named fifteen blockers. Twelve were checked against the current
text before anything was decided; ten held, one was false, and one was misdescribed. §6.13, §6.14
and §6.15 were not taken up (the count here read twelve until 2026-09-08); §6.13 is the `adopt`
classification, `F47`, closed the same day by `ADR-0020`; §6.14's per-item tier metadata landed
2026-09-09 — every checkbox item carries its tier inline, `tools/check_ids.py` refuses one that does
not, and `F50` holds what the faithful copy preserved and the two of its five resolutions still
open; §6.15's production-operability decisions are `F51` — three ADRs and one requirement,
decided and landed 2026-09-12. Six decisions
followed, three of them ADRs. The findings below are numbered in the order the review listed them,
not in the order they were resolved, because two of them turned out to be the same defect.

**F40. CLOSED — the worker's lease guard could not fail on the condition it existed for.**
`OPS-3` and `OPS-22` both said a worker's write "MUST be conditional on that worker still holding
the lease" and both delegated to `STO-3`, whose predicate was `(id, status = running, claimant = me)`
— no term read `lease_expires_at`. A worker whose lease had expired but which `OPS-14`'s sweeper had
not yet reached wrote a terminal state that landed; a second operation could take the machine lock
under `OPS-9` the instant the first's lease expired, while the first's stale write still passed. No
requirement stated behaviour at equality-at-expiry, and no generation or fencing token existed
anywhere in the set. **The remedy on the table was a fencing token; the remedy taken was removing
the second writer** (`ADR-0016`): the engine is one supervised process, the leases, heartbeat,
sweep cadence and machine lock are deleted, and the restart window is the accepted outage.
`OPS-47`, `STO-51`, `OVR-18`, `CNF-290`. **The epoch that `ADR-0016` fenced with reproduced this
finding's own shape and is deleted by `ADR-0019` — see `F46`.** The closure holds: what the lease
defect needed was one writer, and there is one.

**F41. CLOSED — the account sweep had no lease and no monotonic guard under replicas.** `OPS-32`
was thorough about evidence quality and silent about single-flight execution; `STO-48`'s
`state_observed_at` named two writers and did not order them; `API-63` confirmed the second writer
was unserialized against the sweep. True as found, and **it does not arise under `ADR-0016`**: one
engine runs one sweep. Recorded so nobody re-derives replicas as the fix for `F40` and reopens this.

**F42. CLOSED — a failed system cancellation was deleted by retention while the fence still named
it, and the defect was the model, not the retention job.** `OPS-44`'s table kept the episode entry
and `destroy_committed` set on a `failed` cancellation; recovery was "requeue of that same
operation"; `STO-14` deleted settled operations after a configured age with `needs_reconciliation`
as its only exemption; `CNF-212` ran a sweep "after retention has deleted the first sweep's
operation row" while `CNF-271` required "an operator requeue of that same operation". Both passed
inside the window; past it the machine billed forever behind a permanent `conflict`. The first
remedy proposed was a retention exemption for referenced rows. **The one taken is `ADR-0017`**: the
episode — a word the lifecycle document used forty times without a row — is an entity with five
states; `failed` is a terminal fact about one *attempt*; "known, and not done" belongs to the
episode; recovery is an operator `retry` on the episode. `DOM-31`, `STO-52`, `OPS-48`, `API-64`,
`WIR-51`, `CNF-291`. `STO-14` is unchanged.

**F43. CLOSED — `OPS-46` left requeue one kind, and fourteen requirements still described the
others.** `API-7` built two pipeline steps around an "ordering requeue"; `OPS-20` was kept alive
"because `adopt_machine` remains requeueable"; `PRV-13` and `LDG-62` named requeue as a
commitment-growth path; `LDG-39` cleared a parked setup fee on it; `OPS-45` cleared markers on it
across "the five dispatch kinds"; `PRV-40` charged it to the order budget; `OPS-27` still had a requeue
appending to a correlator list `PRV-26` had already made singular; `CNF-279`, `CNF-283` and
`CNF-260` tested requeues that could not happen; `WIR-28`'s fixture carried the
`acknowledge_duplicate_purchase` its own prose, thirteen lines below, forbade sending; and `ADR-0014`'s
consequence bullet still enumerated five admissible kinds with no amendment note. **Closed by
`ADR-0017` deleting requeue**: with the one surviving kind's recovery an episode verb, requeue has
no kinds, and every sentence above is deleted rather than patched. `OPS-4`'s requeue branch,
`OPS-18`, `OPS-20`, `OPS-34`, `OPS-46`, `API-19` and `WIR-28` are withdrawn.

**F44. CLOSED — the descriptor was three fields and eight declarations had no carrier.** *Describe
capabilities* returned an account id, a kind and a capability set. `PRV-31`, `PRV-33`, `PRV-36`,
`PRV-38`, `PRV-40`, `RSC-45` and `PRV-13a` each said a driver "MUST declare" something, three of
them routed to `08-provider-notes.md`, which calls itself illustrative. `PRV-36`'s "MUST be widened
by any observed sample that exceeds it" was unimplementable by a constant in driver source: the
gap between the exceeding sample and the redeploy is a window in which a lost create reply resolves
`absent` and a second machine is bought. `PRV-13a`'s "MUST expose cleanup" named no method, so
`machine_attachments` was a fully specified table nothing populated. **`ADR-0018`**: the descriptor
is typed and immutable (`PRV-44`); a measured window is `max(declared, max(observed))` over
store-held samples (`STO-53`); attachments get list and release under `delete_machine` (`PRV-45`);
`CNF-292`.

**F45. CLOSED — the rest, each with one obvious fix.** Recorded together because none needed a
decision beyond confirming it:

- *Who owns the transaction* (`LDG-11`, `STO-23`, `STO-35`, `API-63` compose one transaction across
  four modules' rows; "the store" was named in `05` and assigned to no module; "repository"
  appeared nowhere). A seventh module, `store`, owns migrations, the pool, the transaction handle
  and every primitive `05` says the store MUST provide; `OVR-9` records that the partition is the
  current assignment and that two things are not tentative — the credential edge and that one
  module hands out the transaction.
- *`OVR-4` versus `API-48`*: `OVR-4` said "Every write operation MUST be asynchronous" with no
  carve-out; `API-48` owned the exception list, said "exactly" three entries, and was amended eight
  times below itself to fourteen. `OVR-4` now carves out `API-48`'s closed set; `API-48` is one
  list.
- *`PRV-7` forbade a driver to "return" a rescue password* while `DOM-11`, `PRV-17` and `RSC-11`
  all assume the engine receives one in-process. "Return" is scoped to a result, error, log or
  persisted record.
- *`PRV-4` forbade implementing an operation without a capability* while `PRV-3` mandates
  get-machine and `DOM-10`'s own table has a `none` row. Scoped to operations with a capability
  entry; the three capability-less methods are named.
- *Install details*: identifier normalization and the fingerprint's canonical form were silent
  (`RSC-46` now states both, the fingerprint reusing `WIR-3`'s RFC 8785 rule); `RSC-28`'s digest
  scope admitted compressed or decompressed bytes (it is the bytes as fetched, for every strategy);
  `RSC-22`'s image path was unstated.
- *Wire*: `WIR-9`'s nested error carried a `correlation_id` `WIR-10b` did not list (removed —
  the view's top-level one is the correlation id); `WIR-16`'s cursor had no stated home (top level,
  like every collection); no collection stated an order (fixed in `WIR-32`); `WIR-41` and
  `WIR-42` returned `200` with no body (a tenant projection; the credited balance view); `WIR-48`'s
  shape was ambiguous (`WIR-29`'s wrapped form); `refresh` was missing from `WIR-35`'s closed
  resolution union; `WIR-4a` put `Access-Control-Allow-Origin` on the preflight only, so the
  browser-wasm caller `WIR-4` names could not read a single response (`WIR-4` now requires it on
  every customer-listener response). **The review's abuse-statement status conflict was false**:
  `WIR-43` and the endpoint-class table both say `201`.
- *The parameter register* the review said was missing existed twice — `LDG-42` for money, an
  unnumbered checklist section for operations — with one item on both, eight on neither, and
  `LDG-68` citing `LDG-42` while absent from it. `OVR-19` is the one register; a parameter is on it
  or it is not a parameter, and startup validates every mandatory row.

*What the review got right that this set had not: a green gate is evidence of internal hygiene,
not of buildability, and the blockers were concentrated exactly where a plausible guess buys a
second server or destroys the wrong disk. What it got wrong is instructive too — two of its twelve
were checked against the text and did not hold, which is the base rate `README.md` already warns
about, now measured on a reviewer instead of on the authors.*

## Closed by measurement — 2026-09-04

**F37. `PRV-34`'s free-verification claim was false, and only `CNF-180`'s hedge survived contact.**
`PRV-34` said test mode meant "the entire dedicated ordering path — request shape, authorization,
the transaction listing, and the correlator round-trip of `PRV-32` — can be exercised against the
**live** API without a setup fee or a server."

**A `test=true` transaction is not listed.** Placed against `/order/server/transaction` on
2026-09-04: `201 CREATED`, `status: "cancelled"`, the correlator echoed in the response body — and
then `404 NOT_FOUND "no transactions found"` from both the listing and `/transaction/{id}` for the
transaction just created. Test mode exercises the **order** half and none of the **resolution**
half, which is the only half `PRV-32` exists for, because Robot resolution *is* matching a
fingerprint in that listing.

`CNF-180` already carried the hedge — "If simulated transactions do not appear in the listing, one
real order closes the remaining half" — so the checklist survived intact and the prose did not.
`PRV-34`, `PRV-32` and `08-provider-notes.md` are amended.

**What the real orders then settled.** Two auction orders (about €0.16 in total, both cancelled
immediately) confirmed the correlator round-trip *and* the property `F36` turns on: two distinct
fingerprints each matched **exactly one** transaction. `OPS-13` requires that "Resolution uses the
entry of the attempt **whose correlator matched**", and on Hetzner Robot two attempts genuinely
carry distinguishable correlators — an observation now, not an argument. **`F36`'s surface is
therefore Hetzner Cloud and DigitalOcean alone**, and on those two the setup fee is `0`, so it is
an install-safety problem rather than a money one. `CNF-280` is the new item that keeps a driver
honest about the discrimination, which `CNF-180` alone never tested.

*This is the fourth provider premise in this set to fail on contact — `F1`'s correlator premise,
`PRV-30`'s `comment` field, `PRV-26`'s create-only scope, and now this. Unlike the first three it
was not findable by reading a client library: the documentation says `test` means the order "will
not be processed", which is entirely consistent with the transaction never existing. Three audits
and two cross-model reviews read the claim without doubting it. It took eight cents.*

## Open — found 2026-09-05

**F38. CLOSED 2026-09-06 — `target` withdrawn from the comparison, `request_summary` enumerated.**
The word is withdrawn from `OPS-34`, whose check is now `kind` and `machine` — two columns, and
enough, because `OPS-46` left one requeueable kind whose payload is a single literal (`WIR-22`).
`CONTEXT.md` records that **target means the disk** and forbids a third sense. The deeper half is
`STO-50`: `request_summary` is now a **closed enumeration**, because "what was attempted" standing
beside a purged `request` is a hole in `ADR-0005`'s purge rather than a note about it — a purge is
enforced by what survives, not by what is removed. `CNF-289` is BLOCKING and asserts it against the
stored record rather than the API surface, since `API-21` already hides `request` and a summary that
quietly retained the payload would pass every surface test.

*The finding as recorded 2026-09-05:* `OPS-34`'s requeue
equivalence check runs over "kind, machine, provider account, **target**", `OPS-13` reasons from the
same four, and `CNF-221` tests them by name — but `target` is defined nowhere, is not a column in
`05-persistence.md`, and is not in `CONTEXT.md`. Meanwhile `WIR-20` and `RSC-26`/`RSC-27` use
`target` for **the disk about to be overwritten**, and `API-17b` uses it for the thing a verb
authorizes against, stating that "Creation … is the only operation that has no target to authorize
against." Read through `API-17b`, a create's `target` is null and the check collapses to kind plus
provider account.

**`ADR-0014` removes the create case rather than defining the word, and the word is still
undefined for every kind that remains.** The deeper defect is the relation, not the noun: `OPS-34`
demands equivalence "in every respect the summary records" while `OPS-13` makes the offer snapshot
"evidence, not a comparison field", so which retained facts participate is unstated — and
`request_summary`'s own opening description is "what was attempted", which nothing enumerates. The
remedy is a per-kind table of comparison fields, not a fourth meaning for one word.

**F39. `OPS-46`'s admissible set was hand-enumerated against a test that cannot be applied, and it
admitted two kinds that fail it.** Found 2026-09-06, one day after `OPS-46` was written, by
following its own reasoning to the kinds it granted instead of the one it withheld.

`OPS-46` admits "kinds whose payload the operation record fully determines". **That test is
unanswerable today**: `05-persistence.md` enumerates `request_summary`'s contents for a create and
for no other kind, and everything else is "what was attempted", which nothing defines (`F38`). The
enumeration was therefore a guess dressed as a derivation.

- **`install` fails provably.** `WIR-20`'s body carries the image `source.url` and `sha256`,
  `authorized_keys`, the `layout`/`target` naming the disk to overwrite, `post_install_script`,
  `acknowledge_destruction` and the `trust` object — and `STO-9` purges "signed image URLs, SSH
  keys, and up to 1 MiB of post-install script" by name. It was withheld for the right reason and
  the reason was understated: this is worse than the create case, because the operator would choose
  the bytes written to a customer's disk and the host-key decision `SEC-22` requires the *caller* to
  make.
- **`adopt_machine` fails provably, and was granted.** `WIR-18` carries `runway_seconds`; `LDG-36`
  makes adopt "place a commitment and pass the same authorization check as create". An operator
  requeue therefore chooses how much of the customer's balance to commit — `ADR-0014`'s own
  argument, on a kind that ADR admitted in the act of making it.
- **`power` and `reverse_dns` were granted on presumption.** Nothing says their payloads survive,
  `WIR-19`'s action distinguishes `on` from `hard_reset`, and `WIR-21`'s `ptr` is a customer-chosen
  hostname of the kind `ADR-0005` purges.

**Amended rather than left open**: `OPS-46` now admits only the exposure-reducing cancellation,
which `API-7` had already identified as the load-bearing case — "a suspended tenant's failed
cancellation must stay requeueable or its machine bills forever" — whose payload is one literal, and
which is the only kind **no caller will re-issue**, being system-triggered under `OPS-39`. Every
other kind is the caller's own action on a machine the caller owns, costs nothing to repeat, and is
re-issued by calling the endpoint again.

*The lesson is not that the enumeration was careless. `OPS-46` opens "requeue is admissible only for
kinds whose payload the operation record fully determines, and `create_machine` is not one of them"
— a test, followed by an answer that no available record could have produced. A derivation and a
guess read identically once both are written down, and only the guess needs `F38` discharged before
anyone can check it. `F38` was already open when this one was written.*

## Closed by decision — 2026-09-05

**F36. Resolution cannot identify which attempt landed when the correlator is the operation UUID,
and two requirements assume it can.** → **`ADR-0014`**. A create can no longer be requeued, so a
create has exactly one attempt, one correlator, one offer snapshot and one setup fee, and "the entry
of the attempt whose correlator matched" has nothing left to disambiguate.

*The finding was narrowed twice before it was closed. A live probe on 2026-09-04 (`F37`) established
that Hetzner Robot's per-order key does discriminate attempts, which removed Robot from the surface
and left Hetzner Cloud and DigitalOcean — where the setup fee is zero, so what remained was an
install-safety problem rather than a money one. The remedy considered at that point was a
fail-closed intersection of `install_strategies`. It was overtaken: the mechanism that produced
multiple attempts turned out not to be defensible on its own terms.*

**The original finding, retained because the reasoning is the record:**

`OPS-13` states the mechanism twice: `request_summary` "holds a list aligned one-to-one with
`correlator_value`", and "Resolution uses the entry of the attempt **whose correlator matched**".
`PRV-26` then covered the opposite case — a list holding one value however many attempts were
made — in wording `ADR-0014` and `ADR-0017` have since deleted.

**Both are true, and together they leave the selection undefined on two of the three launch
drivers.** Hetzner Cloud and DigitalOcean take a free caller-controlled field, so every attempt of a
requeued create carries the *same* correlator; a search that matches it selects no particular
attempt, and there is nothing for "the entry of the attempt whose correlator matched" to name. Only
Hetzner Robot, where `PRV-32`'s per-order key differs per attempt, has the discriminator the rule
assumes. `WIR-35`'s operator `observed` verb does not close it either: it carries an `external_id`
and no attempt index.

**What rides on it.** `machines.install_strategies` is a safety gate whose absence authorizes a
disk-wiping install (`05-persistence.md`), and `LDG-39` debits the matched attempt's at-cost setup
fee — so the wrong snapshot is both a destroyed disk and a wrong charge. `CNF-257` is BLOCKING and
tests that a create whose *earlier* attempt landed attaches that attempt's snapshot, which is a
behaviour with no mechanism behind it wherever the correlators are identical.

*Found by a cross-model review of `DOM-30`, which had asserted the mechanism as settled while
describing something else. The set has been here before: `F1` closed on a correlator premise nobody
had checked, and `PRV-30` and `PRV-26`'s create-only scope were the two that failed on inspection.
This is the third — and unlike those, it is not a provider fact but an interaction between two of
our own requirements.*

## Critical — closed 2026-08-11

**F1. `needs_reconciliation` had no resolution path.** → `OPS-27`–`OPS-33`. The mechanism turned
out to depend on a fact nobody had checked: that every provider offers a caller-controlled field a
create can write an operation id into. **That premise was partly false, and it took until
2026-08-13 to find out.** Hetzner Cloud, Cherry and DigitalOcean do (`08-provider-notes.md`);
**Hetzner Robot does not** — its only candidate field, the order `comment`, routes the order to
manual processing (`PRV-30`, `F29` confirmed), so it is unusable. Where a correlator exists,
resolution is an exact lookup rather than a heuristic match on hostname and timing (`OPS-29`
forbids the latter); where it does not, resolution is an **operator** action (`PRV-33`) and
`OPS-29` still forbids guessing. `OPS-33` bounds how long a customer's balance stays frozen by an
unresolved record either way — a cost that did not exist when this finding was written, and the
reason the no-correlator branch is survivable at all.

*Both auditors had named this the highest-value remaining edit, and advised writing it from the
transcript of a real ambiguous outcome rather than from imagination. That advice was not followed,
on the reasoning that the correlator design made the mechanism verifiable from provider APIs rather
than from experience — **and the Robot case is what that shortcut cost**: the field was verifiable
in principle and nobody verified it, so a mechanism the design leaned on for its most expensive
product survived three audits before failing. **The negative window in `OPS-33` is still a guess**,
and it is the part a real transaction would calibrate.*

**F2. The registry branch of `DOM-1a` was not buildable.** → `API-4` split. Operator credentials
stay environment-supplied and static; customer credentials are runtime-issued (`API-32`–`API-37`)
against a `tenants` table (`STO-21`). The self-serve product this set was extracted for is now
specifiable.

**F5. Deletion semantics were incomplete.** → `machines` gains effective and earliest
cancellation dates plus the full reserve tuple; `machine_attachments` models what keeps billing
after deletion; `STO-18` forbids tombstoning while a billable attachment survives, which is where
`STO-8` and `PRV-13a` are finally reconciled.

## Critical — open

**F23. CLOSED 2026-08-12 with `F19` — `13-wire-contract.md` exists.** Thirty-two `WIR`
requirements: conventions (I-JSON, JCS for idempotency, reject-unknown-on-write), the error
envelope with a machine-readable `details` table, the operation and machine views, and a body for
every endpoint — including `extend-runway`, which `LDG-62` created and no surface row carried
until this document forced the enumeration.

**Panel-reviewed and revised 2026-08-13.** A three-model panel (Fable, Opus, Codex) returned ~30
findings, six critical; the reconciled fix pass produced `WIR-1a`, `WIR-4a`, `WIR-5a`, `WIR-9a`,
`WIR-9b`, `WIR-10a`, `WIR-10b`, `WIR-33`–`WIR-37` and amended most of the rest. **The largest
consequence was not a wire fix but an auth reversal:** the panel's six P0s were concentrated in
the Ed25519 signing scheme (`WIR-6`), and re-examining why it existed showed it guarded a
non-extractable asset at the cost of the most interop-fragile construct in the set — so `API-39`
was reversed to a hashed bearer token and `WIR-6`–`WIR-8` withdrawn. The surviving panel fixes:
CORS preflight (`WIR-4a` — without it the browser client could not make one request), the
method+target idempotency fingerprint (`WIR-3`), the complete install body (`WIR-20`), the
operator resolution endpoint `OPS-31` had always mandated with no route (`WIR-35`), principal-
scoped ids (`WIR-36`), and the operator-listener separation (`WIR-34`). *Original:* Enrolment added
endpoints, the create request gained a runway field (`PRV-13d`), and machines gained
caller-readable runway (`LDG-15`) — none with a request or response body. See `F19`. **This is
now the largest single gap in the set.**

*Worse on 2026-08-12.* Funding added a request that carries an amount and a response that must
name a rail, a destination and an expiry (`API-44`) — with no body for either. This is the one
endpoint where an implementer's invention is not merely incompatible but dangerous: a caller that
reads the requested amount back out of the response and treats it as credited has re-created the
`LDG-47` defect on the client side, and nothing in a checklist the *server* passes will catch it.

**F24. CLOSED by being right.** It warned that nothing decided on 2026-08-11 had been reviewed by
anyone but its author, and that confidence should be no higher than it was before the previous
audit. Two independent audits on 2026-08-12 returned **NO** with roughly forty distinct findings
between them, six confirmed by both models separately. The warning was correct and the money
model was, as predicted, the worst part.

## The second audit — 2026-08-12

**The root defect: the hold was the wrong primitive.** A hold is a card-payments idea — authorize
once, capture once, against a discrete purchase of known size. Machine time is continuous
consumption. Twelve requirements placed, gated, subtracted, raised and released a hold; **none
made it shrink as the machine was used**, so the ordinary happy path drove the available balance
negative one hour into the first machine's life. Six further findings were downstream of the same
mistake, and the tell was that `PRV-13b` consumed an `accrued_unbilled_usage` term that no
requirement produced — the author knew a meter must exist, wrote it into the formula, and never
specified it.

`12-billing-and-ledger.md` was rewritten around a **commitment that decays as it is consumed**
(`LDG-30`–`LDG-36`), and the consumption half — the meter (`LDG-37`–`LDG-39`), the rate source
(`LDG-40`–`LDG-41`), and the funding path (`LDG-42`–`LDG-44`) — now exists.

**Fixed 2026-08-12.** Available going negative in normal operation; nothing releasing a
reservation on `failed`, `succeeded` or delete (the only statement of it lived in `CONTEXT.md`,
which declares itself non-normative); the setup fee reserved rather than debited, making a
create-delete loop cost the operator a setup fee per iteration and the tenant almost nothing;
the double-count between `LDG-9` and `LDG-5`–`LDG-7`; no serialization on the authorization read,
so two concurrent creates spend one balance; **no money-in path at all** — sixteen endpoints and
none took money, while `CNF-94` was BLOCKING and tested a payment notification with no endpoint;
one satoshi defeating the enrolment time-to-live; `DOM-17` having no way to say *insufficient
balance*, so four BLOCKING items asserted a rejection the taxonomy could not express; `OPS-32`
reporting 100% of Robot and adopted machines as unclaimed forever; `OPS-27` and `OPS-33` giving
opposite MUSTs for the same trigger; `OPS-36`'s missing late-arrival branch; requeue and
idempotency comparison both broken by the payload purge; `API-7`'s normative step list containing
no authorization check at all; `STO-21` forbidding what enrolment requires; the `commitments`
table not existing while `CNF-96` tested writes to it.

**The correlator claim was overstated and is corrected.** `PRV-26` writes the *create* operation's
id; a cancellation is a different operation with nothing written provider-side. That premise had
been used to shrink `wind_down_cost`, so a reconciliation error was propagating into systematic
under-reserving across the fleet. `PRV-29` now states the real rule — non-create mutations resolve
by reading provider state for a known `external_id` — and `wind_down_cost` is reduced only where a
driver can distinguish *rejected*, *accepted-pending*, *scheduled* and *complete*.

**Settled, then re-settled:** customer authentication was a caller-supplied public key
(`API-39`, both audits) — reversed 2026-08-13 to a hashed bearer token after the wire-contract
panel showed the signing scheme guarded a non-extractable asset at outsized interop cost. See the
`F23` closure below.

## Open after the second audit

**F25. CLOSED 2026-08-13 by operator decision — and not the decision the finding expected.** The
finding framed this as needing counsel: `LDG-17` requires holding satoshis equal to the float,
`LDG-19` required *publishing* that invariant, and `ADR-0004` §4 forbids describing balances as
"held", "backed", "reserved" or "segregated" — a published one-to-one asset-to-claim ratio being
what safekeeping looks like from outside whatever the contract says.

**The operator resolved it without a lawyer, on plainness rather than law: say nothing.** Any
public statement here requires the reader to hold two apparently opposed ideas at once — the
operator is fully reserved, *and* the customer holds only a contractual claim — and every shorter
phrasing collapses toward the banned custody words. A statement a reader will misunderstand is
worse than silence.

**What it costs is recorded rather than glossed:** publishing was the only mechanism converting a
later solvency breach into actionable misrepresentation, and that protection is now gone; a
customer's recourse on operator failure is unsecured creditor status. `ADR-0004`'s consequence
bullet asserting the opposite is reversed in place.

**`LDG-19a` guards the obvious misreading:** silence about the *ratio* is not silence about the
*arrangement*. The terms MUST still state that a balance is an unsecured claim, because saying
nothing at all lets a customer assume safeguarding — the same misrepresentation reached by
omission. Publish no assurance; publish the disclaimer. Nothing internal changes: `LDG-17`,
`LDG-18` and `LDG-20` all stand, so **the operator remains fully reserved and simply declines to
advertise it.**

*This leaves the refund question `ADR-0003` nominates as the first item for counsel — no longer
second to anything.*

**F26. CLOSED 2026-08-12** by `PRV-31`: a driver declares a per-offer worst-case cancellation
bound before any order, the commitment is sized to it at create, and the machine's actual date —
read after ordering — lowers `protected_sats` at the first re-derivation, lengthening runway
rather than resizing the commitment (`PRV-31`, `ADR-0011`). An offer with no declared
bound is not sellable on prepaid terms. `CNF-166` tests it. *The narrowing that made this a
bounded edit rather than a structural one came from a document already in this set:* `PRV-13c` says
the per-machine constraint is learned after ordering; `LDG-12` forbids the provider call before
the commitment exists. But `08-provider-notes.md` records that current Robot dedicated servers
carry **no minimum term** and that a newly ordered machine's `earliest_cancellation_date` is
normally *today*, so a create rarely lands on the exception branch at all; and `PRV-13c` names
**adoption** as that branch's main road, where the machine already exists and `PRV-28` made
adopt a get-machine plus a local write — the note said the constraint was therefore read *before*
the commitment was opened, which `F47` found false as written, and `ADR-0020` has since withdrawn
adopt. What remains is a create at a provider whose offer does not disclose its term. That wants
a driver-declared pre-create bound per offer, with *no declared bound MUST NOT be sold on prepaid
terms*; it is a bounded edit, not a structural one. **Recorded so the next reader does not
re-derive the alarm from the finding's original wording.**

**F27. CLOSED 2026-08-12 — and the interviewee's question dissolved it rather than any of the
interviewer's three proposed fixes.** The finding said `PRV-13e`'s throttle contradicts
`ADR-0003`'s "matched at all times"; three design rounds went into how fast commitments should
widen (symmetric cap, asymmetric grow-fast-shrink-slow, a repricing-race scenario). The user's
objection — *every authorization prices at the current rate, so nothing can be overcommitted at
stale prices* — unravelled the premise: usage debits at spot, so a fixed satoshi commitment
simply drains faster after a crash, and **the price move belongs to the customer's runway date,
not to the operator's coverage**. `ADR-0011` records the resulting model: fixed commitment,
floating `runway_until`, no automatic widening ever (`LDG-33`, `LDG-16`, `PRV-13e` all AMENDED;
`LDG-62` runway extension as an authorized caller write; `LDG-63` the scheduled-cancellation
exception). The freeze-attack surface three questions were spent on does not exist in the final
design, because nothing automatic remains to trigger. `ADR-0003`'s claim now carries a footnote
naming its two bounded exceptions instead of an absolute it never delivered.

**F28. CLOSED 2026-08-12, both halves, by decisions rather than mechanisms.** The B2B half: the
operator decided **not to chase jurisdictional consumer-law compliance** — the regimes differ
everywhere and cannot all be satisfied by a seller who deliberately knows nothing about the
buyer. The control is terms clarity: **no refunds, ever, stated unmistakably** (`ADR-0004` §5
AMENDED, with the declined checkbox alternatives recorded). The residual withdrawal exposure is
knowingly operator-borne and joins `F25`'s lawyer list as context. The adoption half dissolved on
inspection: under self-serve, machines exist only in the operator's accounts, so a customer has
nothing to adopt — **adoption is operator-only** (`API-18` AMENDED), the entitlement problem
disappears with the customer-facing feature that carried it, and the challenge token leaves v1
scope.

**F29. CLOSED 2026-08-13 — CONFIRMED TRUE, and the design loses the field.** Hetzner does state
that supplying the order `comment` sends standard and auction orders to **manual processing**. The
claim survived three audits as `[verify]`; the operator confirmed it. `comment` is now prohibited
outright (`PRV-30`) — not merely as a correlator — because a caller-controlled field that changes
how the provider handles the request is not a free field.

**What it costs.** Robot loses its exact recovery stamp, and Robot is the product where a lost
reply is most expensive: a duplicate order means a second physical server and a second
non-refundable setup fee. `PRV-32` nominates a substitute — a **per-order throwaway SSH key**,
whose fingerprint is a caller-chosen stamp and which `PRV-9` already requires the driver to
create, so uniqueness is free — and **both of its falsification conditions were checked the same
day and held**:

- *the transaction listing returns the key* — **verified in two independent client libraries.**
  `hrobot-rs` deserializes `#[serde(rename = "authorized_key")] authorized_keys:
  Vec<InitialProductSshKey>` with a `fingerprint` field; `appscode/go-hetzner` independently
  declares `Transaction.AuthorizedKey` → `AuthorizedKey.Fingerprint`. Standard and auction-market
  transactions both carry it;
- *a distinct key per order changes no handling* — `authorized_key[]` is structured data and one
  arm of the order's mandatory authorization choice (the other is `password`), not free text. Only
  `comment` carries a processing caveat, and a differing value in a structured field has no
  mechanism by which to summon a human.

**The Robot correlator therefore survives, by a different field than the design assumed.**

**If it fails, `PRV-33` governs and the guarantee holds anyway:** an ambiguous Robot create
resolves to an **operator**, never to a timing-based guess. `OPS-29`'s prohibition on heuristic
matching is not relaxed by the correlator being unavailable — the temptation runs precisely the
other way, and a wrong match hands one customer another customer's physical server. The visible
consequence, stated rather than hidden: for such a provider the `OPS-33` negative window is
bounded by operator response time, and the commitment is still released on it (`OPS-33`), so a
customer's satoshis are never held hostage to how fast a human looks.

**Two further facts came out of actually reading the clients**, and one of them is worth more
than the finding that prompted it:

- **Robot orders have a `test` mode** (`PRV-34`). `test=true` simulates the purchase and returns a
  `Cancelled` transaction. The entire dedicated ordering path — the most expensive thing to get
  wrong in this specification, and the one `CNF-147` could previously only test by buying a
  server — is exercisable against the live API for free. It also creates a new blocking item
  (`CNF-182`): the flag must **default to test**, or an accidental conformance run buys a machine.
- **This document had misattributed `API-15`'s design.** A note claimed Hetzner's own order
  request carries a field named `i_want_to_spend_money_to_purchase_a_server`, offered as evidence
  that the provider independently arrived at explicit purchase acknowledgement. That identifier is
  `hrobot-rs`'s *Rust field name*; the wire parameter is plain `test`. The claim is corrected in
  place in `08-provider-notes.md`.

*The methodological lesson is the one worth keeping, and it now has three instances rather than
one: the whole correlator design rested on a provider fact nobody had checked (`F1`); the
disqualifying detail was documented in a client library the whole time; and a flattering claim
about the provider turned out to be about a library author. **A caller-controlled field is only a
correlator if writing to it is free**, absence of a documented side effect is not evidence
(`PRV-30`), and reading the client source is cheaper than every audit that missed this.*

*Re-scoped by `ADR-0010`, and in the direction that matters.* Robot is now the flagship product
rather than one of several, which raises the stakes — but the launch set also contains two
providers this does not touch. **So `F29` blocks the Robot driver, not the launch**, and the
verification belongs before that driver is written rather than before anything ships. Had v1 been
Robot-only, this unverified claim would have been a single point of failure for the entire
product.

**F30. CLOSED 2026-08-12.** The rewrite had landed in two files and stopped; the sweep is now
done. The rename reached `PRV-13b`'s formula (`commitment_sats = …`), `operations.commitment_id`,
`SEC-46`, `00`'s withdrawn-non-goal note and the checklist's four remaining money uses. The one
substantive defect is fixed in place: **`PRV-13e` is AMENDED** — a higher re-derivation re-sizes
the machine's single commitment via `LDG-34`'s conditional write; the withdrawn "an additional
hold is placed" would have reintroduced the double-count `LDG-9` was amended to remove.
**`ADR-0011` later went further and withdrew the resize itself**, so `PRV-13e` now recomputes
`runway_until` and nothing resizes a commitment automatically — this paragraph records the
intermediate state, not the final one. The
missing tests exist (`CNF-160`–`CNF-165`: the meter's idempotent debit-plus-decrement, billable
`stopped` and `cancellation_scheduled`, the setup-fee debit, per-tenant serialization under load,
`OPS-36`'s late arrival, `OPS-38`'s many-case), and the five mis-tiered items are promoted with
the reasoning recorded in the checklist's tier-corrections note (`CNF-99`, `CNF-77`, `CNF-24`,
`CNF-113`, `CNF-115`). Blocking set 113.

## The funding decision — 2026-08-12

**`ADR-0008` chose two rails, and a deposit is one object payable over either — the payer picks.**
*(An earlier phrasing here, "Lightning primary, on-chain fallback", is the first draft that ADR
withdrew within the hour.)* `LDG-42` had required a
funding path and then named three candidate rails without picking one, so the endpoint, the
finality rule, the fee-bearer and the tenant binding were all unwritten while `ADR-0002` made the
money path v1-blocking.

The mechanism worth recording is that **attribution comes from the destination, not the payer**
(`LDG-49`). A funding request mints a destination bound to one tenant, and the credit is posted
against that binding — which satisfies `ADR-0005`'s collect-nothing posture and `LDG-42`'s
attribution requirement with the *same* mechanism instead of trading one against the other.
Authentication is structural on both rails: settlement is read from the operator's own node, so
there is no inbound notification to forge and `LDG-42`'s minting risk is designed out rather than
defended against.

**The first draft of that decision was withdrawn within the hour, and the correction is the
interesting part.** It had the operator select the rail at mint — Lightning unless the amount
exceeded inbound capacity, then on-chain. That forced a liquidity guess that can be stale by the
time the customer pays, and it made the operator's guess load-bearing in precisely the case where
being wrong costs most.

**A deposit is now one object — an amount and an expiry — with two destinations, and the payer
chooses** (`LDG-46`). The consequence that matters is not the ergonomics: it is that **expiry now
applies on-chain too**, which is the only available bound on an obligation that is otherwise
permanent. Minting a deposit is free, so anything attached to one forever is something an attacker
mints without limit; with an expiry, the active watch set is bounded by *mint rate × expiry
window* regardless of anyone's patience (`LDG-57`). A whole line of defensive design — restricting
addresses to already-funded tenants, which would have put friction on the largest customer's first
payment — became unnecessary and was recorded in `ADR-0008` as rejected rather than dropped.

`LDG-46`–`LDG-57`, `API-43`–`API-46`, `STO-29`–`STO-32` and `CNF-116`–`CNF-131` are the result.
**The blocking set moves from 73 to 86**, and thirteen of the sixteen new items are BLOCKING for
one structural reason: money-in is the only path in this specification where a bug *creates*
satoshis rather than moving them, after which `LDG-17` reports solvency against a float that is
partly fictional.

Three consequences are open rather than settled.

**The deployment parameters are unset.** The confirmation depth, the per-rail floors, the deposit
expiry and the channel-balance treatment are all things `LDG-42` now requires be stated, and this
set does not state them. The expiry is the one to think hardest about: it is simultaneously the
customer's deadline, the operator's disclosure and the bound on the watch set, so short-to-save-
work and long-to-be-generous are both wrong in ways that hit different people.

**One hazard has no mechanism behind it, only words.** An expired address still accepts payments
nobody is looking for. `LDG-54` requires the disclosure and `CNF-131` tests it, but a disclosure
is not a control, and this is the single place in the funding design where a customer can lose
money by doing something that looks correct.

**The on-chain rail hands the operator a payer's address whether it wants one or not.**
`ADR-0005` still forbids retaining it, and that discipline is harder here than on Lightning
because the information arrives unbidden rather than being asked for.

## The abuse-surface grill — 2026-08-16

**F34 is CLOSED**, and `F35` with it. The surface deferred on 2026-08-15 was designed by
interview and is now specified: `DOM-23`–`DOM-26`, `STO-39`–`STO-42`, `API-59`–`API-60`,
`WIR-43`–`WIR-45`, `SEC-54`, `LDG-71`, `CNF-222`–`CNF-230`, and `ADR-0012` for the decision the
rest hangs from — **the operator is the only party that speaks to either side, and nothing is
relayed in either direction.**

**Three of the seven answers dissolved machinery rather than sizing it**, which is the pattern this
project keeps producing:

- **No allegation taxonomy.** The case carries the operator's own prose. Once ingestion is a person
  transcribing a notice, provider-neutrality is produced by the rewrite, and a class set invented
  before three real notices would put its own traffic in `other`. The rule that survived is
  narrower and more useful: *structured what the agent must compute, prose what it must
  understand* — the deadline and the machine id are fields, the allegation is text.
- **No second deadline.** F34 had called for two, the tenant's earlier than the provider's. Only
  the tenant's is stored (`STO-39`); the provider's stays in the operator's inbox. "Two deadlines
  and only one is real" is then true by construction, and a date the tenant must never see cannot
  leak from a field that does not exist.
- **No `DOM-7` state for a blocked machine** — the conclusion held, though the reason first given
  for it was wrong twice over. `DOM-27` owns it now: a restricted machine is still `running` or
  `off`, `DOM-7` is single-valued, and collapsing them destroys the state `LDG-37` reads to decide
  billability. See below for what the original reason claimed.

**One new defect was found while checking whether `SEC-45` was satisfiable, and it was the most
serious thing in the session.** `SEC-45` claimed resolution was *"answerable from `machines`
(`public_ips`, …)"*. It was not: `public_ips` is current state overwritten by every refresh
(`DOM-8`), so an address plus an **instant** had nothing to bind to. Providers reissue addresses
within days and the ordinary sequence is that the customer deletes the machine *before* the notice
arrives — so resolving against current state names whichever tenant holds the address today, opens
a case against an innocent customer, and invites them to explain a machine that was never theirs.
**A wrong accusation and a cross-tenant disclosure, performed by the operator, by following the
rule.** `STO-41` adds the observation history and `SEC-54` requires the answer be a candidate set;
`CNF-222`/`CNF-223` test both directions. *Note that every design which relays the provider's
notice hides this defect, because the provider's own records do the resolving — owning the channel
is what exposed it.*

**Two decisions went against the recommendation and both are the record's, not the reviewer's.**
The tenant's statement is **free text**, not a structured cause-and-remediation pair: closed sets
guessed in advance fit nothing, and the operator reads every reply at v1 volume anyway. And
forwarding a statement verbatim is the **operator's per-case call** rather than categorically
forbidden — sometimes the customer's own account is the most credible thing to send. The
half-measure objection was answered by making the decision an artifact: composing is the default,
`sent_verbatim: true` is an explicit recorded act naming the statements it covered, and the tenant
can see that it happened (`WIR-44`).

**Still deliberately absent.** Nothing here handles an account-level notice (one that names no
single machine), repeat-offence policy across cases, or any provider signal that a case has ended —
there is none, so `DOM-24` makes closing an operator act. The first notice handled end to end will
say more about all three than further editing would.

### The two-reviewer pass on the same day

Codex (`gpt-5.6-sol`, xhigh) and Opus reviewed the change against the full set. **Both returned
"not buildable as written"** — 28 findings and 14 — and converged, independently, on the same
defects. Neither disputed any of the seven decisions; every finding was about their specification.

**The worst one was the same defect this change was written to fix, one layer down.** `SEC-45` had
named a capability the schema did not have; `STO-41` replaced it with a capability *the runtime
does not exercise* — the history was bound to "the refresh that already maintains `public_ips`",
and **nothing in this set refreshes a machine on a schedule** (`OPS-14`'s sweeper moves expired
operation leases; refresh is a caller-initiated write). For the ordinary machine — created, then
left alone — the table would hold one row or none, the notice's instant would fall in no window,
and `SEC-54` would return the empty set that `CNF-223` calls correct. Every conformance item in
this change passed, on a fixture that happened to call refresh. `STO-41` now binds the write to
every path that writes `public_ips`, and `CNF-222` runs on a machine that was never refreshed.

Applied from that pass: the append-only rule and the purge were a literal contradiction (`STO-40`);
the retention clock was a citation to `STO-14`, which reaches settled operations and nothing else
(`STO-43` now states it, and `DOM-25`'s headline was narrowed from "nothing fires on a timer",
which forbade the retention timer `ADR-0005` requires); `/v1/address-resolution` was in the surface
table with no wire contract (`WIR-46`); `WIR-34`'s operator-route list was not amended, which is
the closed-list drift the change had carefully avoided in `API-48`; the new writes had no
idempotency rule, so an agent's retry would append a second permanent statement to a list nothing
may delete; `WIR-9a`'s conflict-reason union was closed and lacked `case_closed`; a machine can
have two open cases and the machine view embedded one; `STO-39` carried a `provider_account` both
reviewers asked to delete; `CONTEXT.md` still described an allegation *class* the design had
abolished; the `sent_verbatim: true` fixture was not verbatim; and `ADR-0012`'s own summary —
*"nothing is relayed in either direction"* — was false in one direction by its own decision.

**`CNF-224` was impossible and would have failed every conforming implementation.** It asserted the
provider's *name* was absent from the customer surface, while `WIR-11`'s machine fixture carries
`provider_account: "hetzner-cloud-1"` and `WIR-29` returns the account kind. The ban is on the
notice — reference, link, wording, third parties — never on the fact that Hetzner hosts the
machine. Overreach in a rule of this kind is not harmless: it is the half that gets discovered by
being unbuildable, after the half that matters has already been weakened to make it pass.

**Cleared on inspection:** the `API-48` amendment is correct, `API-54` is not violated (the
`last_seen` write belongs to a refresh operation, not a `GET`), and `LDG-71` does not conflict with
`LDG-13`, `LDG-33`, `LDG-37` or `DOM-19`.

### The adjudication that followed, and the claim it destroyed

One defect from that pass needed a decision rather than a fix: `consequence` was written once at
open, and the provider's block lands *after* the deadline — so at the moment the machine goes dark,
the frozen text still read "the provider **may** block". Three options went to both models: an
amend verb alone, an amend verb plus a `machine_blocked` boolean on the case, or plus a
`billing_continues` boolean.

**Both rejected all three and returned the same fourth answer independently: the structured fact
belongs on the machine, not on the case.** Their reasons differ and both are kept. A machine may
have two cases open at once (`STO-39`), so a case-level flag lets two rows answer one physical
question. An account-level action (`SEC-41`) darkens every machine and opens *no* case, leaving the
disclosure structurally unmeetable. And the signal's real job is not to prompt an agent but to
**stop** one: an agent seeing `running` plus a draining runway plus timeouts concludes the machine
is sick, and reaches for reset, rescue and install — which `CONTEXT.md` defines as destructive by
definition. Without this field the design invites a customer's disk to be wiped in an attempt to
fix a network block no reinstall can lift.

**The claim that did not survive:** `LDG-71` had just been trimmed to say the machine keeps billing
"because nothing knows it is blocked", and the `DOM-7` exclusion rested on the block being an
operator's email rather than provider truth. A web-searching reviewer checked. **Hetzner Cloud
exposes `blocked` per address family on the server object and Robot exposes `locked` per IP**, both
separate from lifecycle status (`PRV-35`, `[verify]`). A driver can read this today. The other
reviewer, without web access, had predicted exactly this — that the rationale was "contingent on a
provider fact and evaporates the day someone reads the hcloud docs" — and it had already been
copied into three documents. **The conclusion survived on a durable argument (orthogonality: a
restricted machine is still `running`, and `DOM-7` is single-valued); the reason was replaced and
the copies collapsed to one.**

Also settled: `warned_consequence` is written once and never edited — it states what the notice
threatened, the machine's field states what is true, and two fields answering different questions
cannot contradict each other. Only `respond_by` moves, appending its prior value (`STO-44`),
because a caller planned against the original date and a record showing only the extension cannot
say whether the tenant got the time it was told it had. A provider that escalates has sent a new
notice, which is a new case — so nothing else needs to move. **Accepted cost:** an operator typo in
`warned_consequence` is permanent.

**Deleted in the same pass**, all three named by both reviewers: the constant sentence "the machine
stays allocated and keeps consuming runway while blocked" from the `warned_consequence` fixture —
true of every case that will ever exist, which is the exact argument that killed
`billing_continues`; `CNF-228`'s "the case's `consequence` states the drain", a conformance item
that tested whether English said a thing; and two of the three copies of the `DOM-7` rationale.

## The engineering review — 2026-08-15

Read `03`, `05` and `12` as **build instructions** rather than for internal consistency, which is
what sixteen prior passes had done. The distinction matters: none of what follows is a
contradiction between two passages, which is why every one of those passes walked past it.

**Seven items were closed in place** — `ledger_entries` had no column list at all (`STO-38`); the
*billing period* was load-bearing in five requirements and defined in none (`LDG-68`); nothing
bounded `LDG-35`'s serialization to its own transaction (`LDG-69`); `OPS-36`'s survival path was
defeated by the cancellation its own transaction enqueues (`OPS-41`); `wind_down_cost` omitted the
time a cancellation waits for the machine lock (`PRV-13b`); `SEC-45` rested on a false premise
about abuse handling; and nothing said which of three stated forms of "the balance" authorizes a
purchase (`LDG-70`). `CNF-214`–`CNF-221` test them, and `CNF-221` closes the gap that `OPS-34` —
the requirement that made requeue implementable after `ADR-0005` — had no conformance item at all.

**One finding was raised and refuted, and the refutation is worth more than the finding.** The
review asserted a live lock-order inversion between the per-machine lock and the per-tenant money
serialization. Two independent reviewers refuted it on the same reading: `OPS-8` binds the lock to
an operation that *names* a machine, and a create's `machine_id` is set only on completion
(`05-persistence.md`), so a create holds no machine lock and `OPS-27`'s money transaction never
nests inside one. What survived was the *absence of a boundary rule*, now `LDG-69` — and the
observation that today's safety is accidental, resting on `LDG-25` pricing privileged operations
at zero so that `operation_fee_debit` is defined, paired, and posted by nothing.

**F34 — there is no way to answer an abuse notice, and the design removed every channel. CLOSED
2026-08-16** — see the grill session above; `ADR-0012` and `DOM-23`.
Correcting `SEC-45` established what the obligation actually is — relay an allegation to a tenant,
take back a statement, and answer the provider as its counterparty — and the specification has no
surface for either direction. `ADR-0005` collects nothing, so there is no email and no contact;
`12-billing-and-ledger.md` states the consequence directly in another context: *"a caller that is
software will act on a number long before it would act on an email, and there is no email."*

The decided shape, not yet specified: a **provider-neutral** abuse case on the tenant's read
surface (machine, allegation class, deadline, consequence), a tenant-submitted statement as an
ordinary API write, and operator review before anything reaches the provider. **The provider's own
case reference and statement link MUST NOT be relayed** — that link is a single-use bearer
credential whose use *concludes the deadline*, confirmed against a real notice, and handing it to
an autonomous caller lets a poll loop end the operator's window in the first second. This is
`SEC-39`'s reasoning arriving somewhere new.

Two obligations fall out that nothing currently carries: the tenant-facing cutoff must sit
**earlier** than the provider's by however long operator analysis takes, so there are two
deadlines and only one is real; and the statement is caller-supplied free text, which is where
`13-wire-contract.md`'s existing rule applies — *"not a name, an email, or a transcript"* — or the
abuse channel becomes the one door identity walks through.

*Deferred deliberately, then taken up the next day.* The reasoning for deferring — a new product
surface in a v1 that `ADR-0006` makes pass-through, no external customer to validate against, and a
shape that changed with every answer — held right up until the design was walked branch by branch,
at which point three of its parts turned out not to need building at all.

**F35 — a provider-locked machine keeps billing and has no state. CLOSED 2026-08-16 by `LDG-71`:
it keeps billing, the case must say so, and delete stays available.** The provider's routine
remedy is to **lock** the offending server, not terminate it. A locked machine is still allocated,
still charged for, and unreachable by its owner — so `LDG-33` keeps draining `runway_until` for
compute the customer cannot use, and `LDG-13` eventually cancels it for exhaustion having billed
the whole way. `DOM-7` has no state for it, `LDG-37` has no rule for whether it is billable, and
the machine view gives its owner no way to tell this apart from a machine that is merely broken.
Note the tension before deciding: the *provider* is still charging the operator, so making it
non-billable moves a real cost onto the operator for a condition the customer caused.

## The skeptical audit — 2026-08-14

Six review passes each *added* text. Nobody had asked what should come out, so a skeptical audit
was run against the opposite question: what here is **not** required for correctness, security or
data safety? It returned **25 candidates**, and its closing observation is the one worth keeping:

> six review passes each added text to fix contradictions that earlier added text created — the
> duplication classes are not just bloat, they are the mechanism generating the defects the
> passes keep finding.

That is correct, and it is visible in this file's own history: `SEC-46` restated `LDG-32`, drifted,
and shipped an amendment claiming to have applied while the requirement said the opposite.

**Accepted and applied.** `OVR-10`'s separate-service form (settled by `ADR-0001`, kept alive as a
live option for weeks, and the reason `API-30`/`SEC-40`/`CNF-66`–`CNF-68` exist); `DOM-1a`'s
no-registry branch (settled by `ADR-0002`); `DOM-12` (folded into `DOM-11`, which forbids the
persistence its round-trip rule described); `custom_ipxe` (deferred by the `DOM-22` precedent — no
launch driver declares it); `LDG-38`'s restatement of the meter key (which had drifted to the
withdrawn form in the same document that withdrew it); and a scope note on `07-security-
requirements.md` making it cite rather than restate rules owned elsewhere.

**Rejected, with reasoning.** `API-53`'s operation `revision` — the audit called it cuttable for a
pre-SDK product, but it is one integer that arbitrates genuinely out-of-order polls, and the
caller is software polling concurrently by design (`API-49`). Removing it would trade a field for
a stale-read class that no other requirement covers. This is the loop's first rejection, and it is
recorded here rather than left as silence, because six passes with zero rejections was itself a
signal worth answering.

**Held for the operator, not applied — CLOSED 2026-09-02.** Cutting `API-33`'s enrolment issuance
delay. The audit is
right that its original justification evaporated — it existed to protect the single moment a
server-generated token crossed the wire, and `API-33` now mints both secrets in the enrolment
response — so what remains is friction against a naive script that `API-36`'s rate limit,
`API-41`'s global ceiling and `API-34`'s time-to-live already bound. But removing it deletes
`issuable_at` and everything keyed to it, which changes the enrolment product rather than tidying
it. **F33.**

*Closed by the 2026-09-02 review, which found the two halves had been half-applied and were
contradicting each other: `API-33`'s 2026-08-31 amendment moved the delay in front of the
pending-tenant slot and said so, but the admission token it introduced had no route, no field and no
place on the surface table — so `WIR-12`'s `{}` body and `WIR-2`'s rejection of unknown fields made
**every enrolment unsatisfiable** — while `issuable_at` survived as a column, a response field and
two gates, leaving two delays in a set that described one. Both halves are now applied: the token
has `POST /v1/enrol/token` (`WIR-49`) and an `admission_token` field, and `issuable_at` is withdrawn
with everything keyed to it. The operator's hesitation was right about the cost and the finding
should not have been left open across two reviews while the requirement asserted it was closed.*

## The fourth audit — 2026-08-13, and the verdict was NO again

Two independent reviewers (Fable; Codex, running three parallel passes) read the full set after
the wire contract, the auth reversal and `ADR-0011` landed. **Both returned "not buildable as-is"
— 42 findings from one, 37 from the other, roughly 35 distinct blocking issues after
deduplication.** The convergence matters more than the count: they agreed, independently, on where
the set was weakest.

**The root defect was the same class as the last two: an entry kind the pairing rule forgot.**
`PRV-13b` put the setup fee inside the commitment; `LDG-39` debited it; nothing decremented the
commitment when it was debited — so on the *ordinary funded dedicated create* the ledger sum fell,
the reservation did not, and `available` went negative by exactly the fee, violating `LDG-10`.
**That is the 2026-08-12 hold double-count, reintroduced through `setup_fee_debit` while the
rewrite that fixed it was still the newest text in the file.** `CNF-162` tested the debit and
never the decrement.

**The most serious finding was one neither I nor two prior audits had seen: a path to destroying
the wrong disk.** A caller names `/dev/sdX` before any inventory exists, device ordering can
differ across boots and between rescue and the installed system, and nothing forced an abort on
mismatch. Every requirement in `06-rescue-install.md` could be satisfied while the customer's data
was destroyed. `RSC-26`/`RSC-38` now bind the target to a serial or WWN plus an inventory
fingerprint, re-verified immediately before disk I/O.

**And one finding corrected my own reasoning, on which a decision had already been made.** The
2026-08-13 auth reversal argued that a stolen customer credential "can only burn the victim's
prepaid balance — nothing extracts". **A customer credential also authorizes `install` and
`delete`.** The asset is the customer's data and running machines, not a prepaid card. That does
not disturb `API-39`'s choice of bearer tokens — a stolen key authorizes exactly the same
destruction — but it demolishes the conclusion drawn from it, that revocation earned nothing.
`API-55`/`API-56` add a recovery credential, and rotation authorized by the spending token is now
explicitly **forbidden**: a thief would rotate first and lock the owner out permanently.

**Fixed 2026-08-13** — in six batches, each committed separately: the setup-fee double-count and
its missing refund path; the absent `runway_until` formula (the obvious reading spent the
wind-down reserve, guaranteeing the operator was short at cancellation on *every* ordinary
exhaustion); per-tick rounding making price depend on metering cadence; rate-outage accounting
(`LDG-64`); debits exceeding the commitment; billable attachments outliving it; commitments
released on mere provider *unreachability*; `API-7`'s universal pipeline opening purchase
commitments on reboots and blocking deletion during a rate outage; the token-delivery model that
could strand a funded tenant on one lost HTTP response; enrolment idempotency as a global
unauthenticated namespace handing out other callers' capabilities; the three tables nobody defined
(`STO-34`–`STO-36`); provider-account assignment, which no requirement produced; tenant
suspension; `needs_reconciliation` being simultaneously terminal and expected to transition;
`OPS-36` seizing balance automatically; system cancels without deduplication and blocked by caller
ceilings; `WIR-20`'s missing provider-published host-key variant, which was silently downgrading
every Robot install to first-use trust.

**F32. CLOSED 2026-08-31 — answered by measurement, and the answer was half of each.** The question
was whether DigitalOcean offers an SSH-reachable rescue. **The reachability was never the blocker;
automated activation is.** The recovery environment exists, runs `sshd` and imports the droplet's
creation-time keys — but booting into it is a control-panel action. Two independent documentation
passes agreed, one grepping the published OpenAPI specification and finding no occurrence of
`recovery`, `rescue` or `iso` in any droplet context, and a live probe returned
`404 "The specified action type is not available."` for both `enable_recovery` and `recovery`
against an unlocked, active droplet. That is positive evidence of absence, which is what `PRV-30`'s
lesson demands of a claim in this direction.

So the driver declares no rescue capability. **But the differentiator survives there by another
route**, established by walking the whole custom-image path against the live API: import from a URL,
poll to available, build or rebuild, delete. `ADR-0013` makes that a second install feature —
`DOM-28`, `RSC-39`–`RSC-43` — because the promises differ: the provider converts the bytes, exposes
no checksum field, imposes its own guest requirements, and offers no way back into a machine that
comes up wrong.

**What was learned on the way is worth more than the finding.** The same test destroyed a documented
constraint the design would otherwise have inherited: DigitalOcean's product pages say a rebuild
must stay within one operating-system family, and **the API does not enforce it** — one droplet went
Ubuntu → Fedora → a custom Alpine image in under two minutes, every action reporting `completed`.
`PRV-13c` forbids encoding a provider's commercial terms as constants, and its first real test
arrived early: the term was not encodable because it was not true.

Two further facts came out of the same run and are recorded in `08-provider-notes.md` as measured:
droplet deletion is **eventually consistent** on the read path (`204`, then `200 "active"` eight
seconds later), which produced `PRV-36`; and image deletion is **not idempotent** and disagrees with
the read path (`422` from `DELETE`, `404` from `GET`, same id, same instant), which corrected
`OPS-11`'s claim that a 4xx means the provider did not act.

*`F29`'s methodological lesson now has a fourth instance, and this time the shortcut was not taken:
the provider fact was checked before the driver was written rather than after three audits.*

## Two holes found while checking the surface — 2026-08-12

Looking at `04-api-contract.md`'s surface table to answer a different question turned up two
things neither audit caught, because both audits read the requirements and the table is not one.

**There was no way to read a balance.** Under `ADR-0002` a prepaid balance is the entire spending
authority, and no endpoint returned it. A caller — software, with no human — could learn its own
solvency only by attempting a create and being rejected with `insufficient_balance`. That turns an
ordinary question into a failed write and pushes an autonomous agent toward **retrying purchases
to discover whether it can afford one**, which is the tiering rule's question (3) answered yes for
a provider mutation. `API-47` fixes it; `CNF-150` is BLOCKING.

**The surface table was a day behind the requirements, twice.** Enrolment shipped 2026-08-11 and
funding on 2026-08-12, each with mandated endpoints that appeared nowhere in the table — and each
exempted itself from `API-1`'s `202`-and-an-operation rule in its own paragraph. `API-48` now
states the synchronous set once and closes it. `CNF-149` runs the diff in both directions.

*This is `F19` in miniature and the same root cause: the wire surface is maintained by hand in
prose, so it drifts silently every time a decision adds an endpoint.*

## Completion — 2026-08-12

**How the caller learns an operation finished was never specified**, and the question was put to
a three-model panel (Fable, Opus, Codex) after the interviewer's own recommendation — a cursored
change feed — was challenged. **All three independently rejected it for v1** and converged on the
same answer: polling with server-chosen pacing, written as `API-49`–`API-54`, `STO-33`, `DOM-21`,
`CNF-152`–`CNF-158`. No ADR, by the rate-source precedent: the transport is cheap to reverse
behind the endpoint; what is expensive — the pacing contract, the rate-limit invariant, the
retention horizon — landed as requirements.

The shared reasoning is worth one paragraph because it corrects a framing error. The durable
operation record already *is* the completion guarantee — `OVR-4` made every outcome a persistent
row, so a missed event is impossible by construction, and every push mechanism would re-deliver
what the store already promises. And the list endpoint already gives one request per interval
regardless of fleet size, so the feed's headline benefit existed before the feed. What was
actually missing was the half nobody had written: who sets the polling cadence (`API-49`), what
the rate limit promises a compliant poller (`API-50`), and what an autonomous caller may do with
`needs_reconciliation` (`API-51` — re-issuing under a fresh key is a second purchase, and the
panel unanimously called this the most expensive way for "finding out" to go wrong).

**Rejected, with the reasons recorded:** SSE (browser `EventSource` could not carry the signed
headers `API-39` then required — now moot since auth is a bearer token, but `EventSource` still
cannot set `Authorization`; a held stream caches an authorization decision, so a suspended tenant keeps
streaming after `SEC-45`'s suspension); long-poll (its naive implementation — parked handlers
polling the store on a timer — rebuilds `DEF-11` with customers as the trigger); webhooks (the
process holding every provider credential initiating outbound connections to caller-chosen hosts
is an SSRF primitive and an egress path out of `OVR-10a`'s boundary — this holds even if
server-side integrators appear, so their appearance does not reopen the question); the change
feed (deferred, not refused — `STO-6` now carries the note on what its cursor requires, because
that primitive silently breaks on a server engine).

**The panel also found two defects the question wasn't about.** A pending tenant could not
observe its own activation — the funnel's happy path ended in probe-by-purchase (`API-52`,
`CNF-155` BLOCKING). And a poll past the retention horizon answered "never existed," inviting a
re-send (`DOM-21`'s `gone`, `STO-33` aligning the two horizons `STO-14` and `STO-25` had left
free to cross).

**F31 — opened and closed the same day.** Whether system-initiated mutations mint tenant-visible
operation records. → `OPS-39`: **yes, for provider mutations** — exhaustion cancels and late-
attach cleanup go through the queue (lock, lease, `needs_reconciliation` and all, because an
ambiguous cancel is ambiguous regardless of who asked) and appear in the tenant's list as
`requested_by: system` with a reason. Pure balance events mint nothing; the ledger is already
that record. The deciding observation: these mutations need the queue's safety machinery
*anyway* — an exhaustion cancel outside it is a blind mutation against a customer machine — so
tenant visibility was the only genuinely open part, and hiding a machine's destruction from its
owner's history had nothing arguing for it. `CNF-159` is BLOCKING.

## The launch set — 2026-08-12

**`ADR-0010` settles `D3`**, the launch-set question, open since the first session and never asked: v1 ships **Hetzner
Cloud, Hetzner Robot and DigitalOcean** — both machine shapes across two unrelated companies
(`OVR-14`–`OVR-16`).

The reason this was worth deciding rather than deferring is that **almost every difficult
requirement in this set exists for the dedicated shape**, and a cloud-only launch runs none of
them. The setup fee committed before the order and debited on acceptance, the reserve covering a cancellation date,
`cancellation_scheduled`, `PRV-13c`'s exception branch, `ADR-0006`'s pass-through — all written,
all unexercised. Specifications turn out to be wrong precisely in the parts that never ran.

Each driver earns its place differently: **Robot is the product**, **Cloud is the cheap machine**
that keeps the conformance checklist affordable to run and is the fallback if `F29` is true, and
**DigitalOcean is the proof the driver contract abstracts anything at all** — two drivers against
one company's API house style can share assumptions neither author notices.

**The cost is stated rather than minimised: three drivers before the first customer**, which is
more work than any alternative considered and is undertaken with nothing yet validated against a
real transaction. That trade — breadth of proof over speed to a first sale — is the opposite of
the one the *fourth question* at the top of this file argues for, and a reader should notice the
tension rather than have it smoothed over.

Two open findings are re-scoped by it. `F29` now blocks the Robot driver rather than the launch.
And `F10`'s dead capability branches stop being theoretical: three genuinely different capability
sets is the first configuration where `OVR-2`'s runtime discovery does real work (`OVR-16`).

## The rate — 2026-08-12

`LDG-40` had required that a rate source "MUST be named" and none was, leaving the last
load-bearing external dependency in the money path unspecified. It is now a **median of at least
three independent sources** with per-source staleness, outlier exclusion, and a quorum below which
there is no rate at all (`LDG-58`–`LDG-61`).

**Two consequences are worth separating from the choice itself**, because they are the parts that
are not cheap to change later:

- **There is no fallback to the last known rate** (`LDG-59`). A stale rate is not a degraded rate;
  it is a number that was true once being used to price a purchase, which is the exact condition
  `LDG-40` already made create halt for. `CNF-141` is the item that catches an implementation
  degrading quietly to a single surviving source.
- **A wrong rate reaches the customer's disk.** Every other external dependency here can at worst
  cost the operator money or stop the service; this one understates the satoshi, makes solvent
  customers look exhausted, and `LDG-14` then cancels the machine and destroys it (`LDG-41`).

**No ADR was written, deliberately.** The trade-off was real and the alternatives — one named
exchange, a published index, or abandoning the rate by pricing in satoshis — were considered. But
the *choice* is cheap to reverse behind `LDG-40`'s interface, and an ADR for a reversible decision
trains a reader to skim the ones that matter. What is expensive to reverse is the halt matrix and
the no-fallback rule, and those are requirements.

**`LDG-58`'s independence rule cannot be enforced by code.** Two front-ends onto one order book
are one source, and nothing at runtime can tell. `CNF-143` is a configuration review, stated as
such rather than dressed as a test.

## Key custody — 2026-08-12

**`ADR-0009` makes the process unable to spend the float**, which is the first requirement in this
set that makes half of `F13` untrue. Deriving addresses (`ADR-0008`) meant holding key material,
which turned that finding from an abstraction into a specific key on a specific disk — and the
answer available here is not available to most businesses that hold customer money: **this one may
never need to spend on-chain at all**, because `ADR-0004` forbids paying anyone out and provider
invoices are settled with the operator's ordinary money.

Lightning cannot go cold, so it is bounded instead (`SEC-49`) and the ceiling *is* the blast
radius, stated as a number. `SEC-48`–`SEC-53` and `CNF-132`–`CNF-137` follow. The blocking set
moves to **92**.

**The luckiest interaction in the set is worth naming**, because it is the reason a manual refill
is affordable: `ADR-0008` gives every deposit both destinations, so exhausted inbound capacity
degrades funding from *fast* to *slow* rather than from *working* to *down*. Without the second
rail, `SEC-51` would make an operator's sleep into a sales outage — and an operator who cannot
sell while asleep will quietly re-introduce the hot key this decision removed. `CNF-136` exists to
catch that pressure before it becomes a change.

**Two things got worse, not better.** The risk moved from compromise to **custody**, and custody
is not smaller by default — losing the cold key destroys the float with no attacker involved, no
insurance and nobody to appeal to, which is why `SEC-53` requires the recovery procedure to have
been *executed* rather than written. And the watch-only material is now a privacy secret of
unusual concentration: an extended public key discloses every deposit address ever derived, so
leaking it publishes the operator's whole payment history with customers linked to each other —
`ADR-0005`'s prohibited outcome reached with nothing stolen (`SEC-52`).

## Critical — closed 2026-08-11 (second pass)

**F22. The conformance checklist covered nothing decided on 2026-08-11.** → `CNF-76`–`CNF-115`,
covering enrolment and credentials, correlators and reconciliation, the ledger, ownership and
deletion, and blast radius. **23 of the 40 are BLOCKING**, taking the blocking set from 50 to 73.

That number is the finding's real content and it is left visible rather than buried: choosing
self-serve enrolment and a prepaid balance did not add features, it added a money system whose
correctness gates launch. A reader deciding whether that trade was worth making now has the
price in front of them.

## Critical — fixed 2026-08-09

**F3. Operations had no tenancy rule.** `API-17` covered only machine-scoped endpoints, so
`/v1/operations` and `/v1/operations/{id}` could expose another tenant's operation, provider
account, result and error. Pagination was specified; isolation was not. → **`API-17a`.**

**F4. Any tenant could create against any provider account.** Create is the only verb with no
target to authorize against, and neither account assignment nor spending authority existed.
`allow_orders` plus an acknowledgement prevents accidents, not unauthorized spending — which
directly contradicted `DOM-3`. → **`API-17b`.**

## High — open

**F6. Re-scoped 2026-08-12: gates the Cherry driver, which `ADR-0010` left out of v1.** The only
password-only rescue in the notes is Cherry's; Robot rescue is key-based and Hetzner Cloud
accepts keys, so no launch-set driver hits this. The interface gap is real and stands for
whenever Cherry ships: begin-rescue always
receives an ephemeral public key, and `PRV-17` forbids accepting-then-ignoring it. No
alternative access-request variant exists, so a password-rescue provider cannot conform.

**F10. CLOSED 2026-08-12** (`DOM-22`): `remote_console` withdrawn (non-goal with no operation
behind it), `attach_iso` and the `iso` image source withdrawn from v1 (no driver operation ever
specified, no launch provider exposes it), `list_offers` added so `OVR-2`'s discovery rule holds
for the offers endpoint. The `adopt_existing` half had already closed via `PRV-28`. *Original
text:* `adopt_existing` is
resolved: `PRV-28` states that adoption is get-machine plus a local write, so the missing driver
operation was never needed and a reader looking for it should not add one. **Still open:**
`remote_console` has no operation while console proxying is a non-goal; `attach_iso` gates an
install pairing with no provider operation behind it; list-offers has no capability at all,
contradicting `OVR-2`.

**F13. The single-process credential boundary is not proven by its own tests** — *and `ADR-0001`
raised the stakes rather than lowering them.* Provider secrets originate in the process
environment, which customer-facing code can read without ever referencing the private credential
type; `CNF-71`/`CNF-72` prove *type visibility*, not inability to read the environment or inspect
shared process state. The single-deployable decision is now final, so this is the only structural
defence, and it does not yet hold.

**Half of it closed 2026-08-12.** The "and the float" clause is no longer true by design:
`ADR-0009` makes the process watch-only, so a full compromise costs the machines and whatever sits
under `SEC-49`'s channel ceiling rather than every satoshi ever deposited. The blast radius is now
a number the operator chooses. `CNF-132` deliberately tests *reachability* rather than type
visibility, because repeating `CNF-71`'s mistake here would prove nothing about the money.

**The credential half is also closed** — though the mechanism changed: `API-39` first chose
caller-supplied keys, then reversed (2026-08-13) to a **hashed** bearer token. Either way the
store holds no usable customer secret, which is the mitigation this finding called cheapest and
untaken; hashing gets it without a signing protocol.

**The last piece closed 2026-08-12: `OVR-10c`.** Credentials are read once at startup by the
owning module and scrubbed from the process environment, so after initialization the only copy
lives inside the owning type and an environment dump from the public surface discloses nothing.
`CNF-173` (BLOCKING) tests it by reading the environment at runtime rather than reviewing the
scrub call — the type-visibility mistake `CNF-71` made, not repeated. What survives of `F13` is
implementation proof, which is where a specification finding is supposed to end.

**F17. Tier assignments change under honest application of the rule** — *partially closed.*
`ADR-0001` chose the single-component form, so `CNF-71`–`CNF-74` apply and `CNF-66`–`CNF-68` do
not; that blocker is resolved. **Still open:** `CNF-65` is BLOCKING because autonomous deletion
can leave unbounded billable attachments, and `CNF-58` is BLOCKING if an unknown stored state can
become `queued` and repeat a mutation. Neither has been re-tiered, and `F22` means the new
requirements have no tier at all. *Closed 2026-09-09: both were promoted on 2026-08-13 — the
checklist's "PROMOTED TO BLOCKING 2026-08-13" paragraph — and the tags on the items read BLOCKING;
this sentence was stale for four weeks, which is `F50` (7).*

## High — fixed 2026-08-09

**F7. Install failure classification was neither total nor consistent.** `authentication` and
`rate_limited` were absent from both install outcomes, and `PRV-22` appeared to contradict the
install row. → `OPS-11` table made total, the `PRV-22` interaction stated explicitly, `CNF-31`
split into `CNF-31a` (misclassification causes a repeated mutation) and `CNF-31b` (totality).

**F11. "Every non-`GET` endpoint MUST return `202`"** contradicted mandatory `400`, `401`,
`409`. → `API-1` now says every *accepted, valid* write.

**F14. `API-30` contradicted itself** — registry deployments "MAY treat the options as
advisory," then an unconditional "MUST do one." → rewritten, and it now states what a registry
does *not* buy: it proves an override names an existing tenant, never that it names the
*right* one.

**F16. Tier arithmetic was wrong.** `CNF-31` appeared in two tiers; the blocking list held 50
items while the prose said "roughly 44"; `CNF-62` was DEFERRED while the area sort called its
parent PRE-SCALE; `CNF-60` was PRE-SCALE while `API-21` was DEFERRED. → all corrected.

**F21. Stale citations after the day's edits.** `OPS-13` cited `RSC-17` instead of `RSC-19`;
`API-30`, `CNF-67` and `SEC-40` still said "amend `DOM-1`" after `DOM-1a` superseded it; the
README claimed no provider fact was web-verified while `08` carries a dated verified claim.
→ all corrected.

## High — closed 2026-08-11

**F8. Idempotency had no retention boundary.** → `STO-25`. Either retention preserves the
`(tenant, key)` pair beyond the operation it guarded, or `API-11`'s promise gets an explicit
expiry stated to callers. The unstated third option — silently performing the mutation a second
time — is now named as the duplicate purchase it is.

**F9. Mandatory data was absent from the normative schema.** → `operations` gains
`correlation_id` (`API-28`) and the resolution columns; `operation_requeues` gains `reason` and
`previous_error` (`STO-20`), without which `OPS-19`'s audit trail is overwritten by the next
attempt.

**F15. Global uniqueness of an external machine was required but not enforceable.** → `STO-17`.
The stated constraint included `tenant_id` and so permitted exactly the duplicate it was meant to
prevent; two tenants adopting one machine would each have been authorized to destroy the other's
server.

**Part of F18** — `PRV-13b`'s FX haircut. The formula now applies one haircut to the conversion
rather than trailing an ambiguous multiplier after the sum, and states that no volatile-asset
haircut applies at all, because `ADR-0003` matched the ledger's denomination to the asset.

## Medium — open

**F12. CLOSED 2026-08-12.** The conflict resolved on a capability fact: for iPXE (and the now-
withdrawn ISO mode) this system never touches the bytes, so `SEC-16`'s "every custom image" was
demanding an attestation nothing could check. `SEC-16` AMENDED to `DOM-14`'s scope — digests for
what the system writes — with the out-of-reach cases stated as out of reach rather than implied
covered.

**F18. CLOSED 2026-08-12.** Each vague MUST now carries units and a procedure in place:
"measured" = worst observed over ≥20 real deletions, recorded with sample size and date, with a
declared conservative bound until then (`PRV-13b`); "materially in the future" = beyond one
re-derivation period plus wind-down (`PRV-13c`); `SEC-39`'s interval defaults to one hour with
stated integer ceilings; `SEC-42`'s "enforce what it can" = checkable at request time from held
data, everything else explicitly a terms obligation; `RSC-30`'s storage = content-addressed or
version-pinned; `API-26`'s range = 1–200 default 50 (`WIR-32`). `PRV-13b`'s haircut ambiguity
had already been fixed with `F18`'s earlier half. *Original:* "measured worst-case delay," "materially in
the future" (`PRV-13c`), ceilings "per interval" (`SEC-39`), "enforce what it can" (`SEC-42`),
"a sane range" (`API-26`), "controlled, immutable storage" (`RSC-30`). No units, thresholds,
measurement procedure or pass/fail boundary. `PRV-13b`'s formula also leaves ambiguous whether
the FX haircut multiplies the whole reserve or only part of it.

**F19. CLOSED 2026-08-12 — see `F23`.** *Original:* In ~2,600 lines there is exactly one JSON example —
the error envelope. No request or response body for any endpoint. The idempotency header is
required by `API-8` and never named; likewise the tenant-override header and the destructive
and purchase acknowledgement fields. `CNF-21` tests "byte-equivalent body" against a contract
nobody wrote, so every implementer invents one and the checklist blesses it. `API-13` also
omits `PRV-8`'s minimum-one-key create rule. **Two competent implementations will not
interoperate.**

**F20. CLOSED 2026-08-12** by `OPS-40`: minimum URL validity checked at accept against the
stated admission-to-start bound, a deterministic pre-destructive gate at claim, mid-stream expiry
classified as an ordinary install failure, and requeue's fresh payload (`OPS-34`) as the refresh
path. *Original:* `OPS-2` persists the
request; `SEC-21` wants short URL lifetimes. A URL can expire between enqueue, restart,
deferral and execution, and there is no refresh or caller-replacement mechanism.

## How to read the fixed/open split

The 2026-08-09 batch were the *cheap* items — self-contradictions and stale references from a day
of heavy editing, plus two security holes clear enough to close without a product decision.

**The 2026-08-11 batch is different, and carries its own warning.** Those items were closed by
making product decisions (`docs/adr/`), and a decision resolves a *specification* gap without
producing any evidence that the decision is right. `F1` is the clearest case: it is closed
because a mechanism now exists and is verifiable against real provider APIs — but `OPS-33`'s
negative window, the number that decides how long a customer's money stays frozen, is still a
guess, and no amount of internal consistency will calibrate it.

Note also the direction of travel in `F22` and `F23`: **this session created open findings faster
than a careless reader would notice**, because a hundred new requirements arrived with no
conformance items and no wire format. A specification that grows faster than its checklist is
getting less testable, not more finished.

What has genuinely changed is the *kind* of uncertainty. Before, the set could not describe its
own product. Now it can, and the open questions are about whether the described product is
correct — which is the question a first real transaction answers and no further editing will.
