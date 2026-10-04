import Provisiond.Claim
import Provisiond.Runway
import Provisiond.Rate
import Provisiond.Tables
/-! `OPS-42`'s cancellation fence, composed on the claim model (`Provisiond.Claim`), `LDG-33`'s
derivation (`Provisiond.Runway`) and `OPS-48`'s episode table (`Provisiond.Tables`): one machine,
one tenant, one worker, one engine, and the transactions at the boundaries the requirements draw.
The worker's fence transaction is `OPS-41`'s re-check and `OPS-42`'s conditional write in one step
where `Params.recheckInsideFence` holds, and two steps with a gap between them where it does not —
the 2026-09-02 amendment, "without this the fence does not fence", is that parameter. `LDG-62`'s
extension is its own transaction; the provider call is made after the worker "releases it before
the provider call, which `LDG-69` forbids inside" (`OPS-42`), from the one phase the fence
transaction alone enters.

The re-check is `OPS-41`'s order (2026-10-02, `ADR-0029`), decided "inside the fence transaction
and on what that transaction reads, never on its claim snapshot": `Phase.holding` carries the
claim number and no rate, and `recheck` reads the world the transaction runs in. The machine
recorded gone or its episode closed settles first; then the tenant's **current** suspension state;
then a rate, at which `LDG-33` is re-derived; then, with no rate, the outage's deadline — before
it the claim defers through `Provisiond.Claim.defer`, and past it the worker makes the conditional
write on `STO-37`'s record. `World.rate` is optional, and the transaction's read of it can predate
a restoration. `OPS-41` says "`LDG-35`'s per-tenant primitive orders nothing against a
deployment-wide event". So the `fenceTxn` event carries the restoration that commits after the
transaction's read of no rate and before its conditional write, where there is one, and the write
is what loses to it; nothing the worker saw at its claim enters the decision. The episode is
`STO-52`'s row with its `reasons` set; the sweep, `API-58`'s fan-out and `LDG-64`'s bound canceller
all enqueue through `OPS-39`'s one rule, joining an open episode and opening none while one is
open. The gone-write is `ADR-0021`'s: it closes the open episode and clears the fence in one step,
from any open state.

The outage's rate, its record and its deadline are kept apart, by `ADR-0029`'s "The deadline is
computed from history, not read from a record". The rate is
`World.rate`. The record is the meter's. `STO-37` says "The row is the subject's, and the meter
opens it". So losing the rate —
`rateLost`, or a `pass` whose window yields none — opens no record, and `meterOpens` is an event of
its own: early in an outage, and for a machine the meter does not post for, there is no rate and
no record. The deadline is computed. `LDG-64` says "compute the outage's deadline from history, and
store it nowhere". The outage's start enters as a given input, the argument of the event that
loses the rate, as `rederive` is handed its date; the maximum tolerated outage is the setting in
force, `World.maxOutage`, which `setMaxOutage` changes mid-outage; and `World.deadline` adds the two
at each use, so no structure holds the sum. The model proves what the worker does given the
start, and nothing about the replay that produces it.

`Params` lists the guards dated amendments added to what this module models, each a field so
that removing it is a one-token change a witness theorem exercises (`ADR-0025`). Hard-wired, and
not guards on a rule but the rule: `LDG-62`'s test on the fence, which is the fence's own second
half; `OPS-41`'s 2026-09-09 scope, "**any** exposure-reducing cancellation" — the model never
scopes by reason; the deadline's arithmetic and the separation of the rate's loss from the meter's
record, which are `LDG-64`'s and `STO-37`'s account of what an outage is and withdraw no behaviour
a parameter could return to; and the places of the suspension read and of the rate read in
`OPS-41`'s order, which the 2026-10-02 amendment numbered and did not move.

Re-derivation consumes an optional per-currency acceptance order (`STO-49`); no observation is
`LDG-40`'s halt. The caller supplies the date computed by `LDG-33`; source aggregation, currency
selection and rate arithmetic are outside this transition. The rate the worker reads is
`Provisiond.Rate`'s: a `pass` event carries the prices inside the window as of that pass, as
`rederive` carries the date, and `LDG-58`'s lower median over them is the rate in force until the
next pass. `advance` moves wall clock and nothing else.

The original wall-clock gate composes `Provisiond.Claim.graceDefers` at the claim. The paused
portion is checked by `derive` only after the ordinary predicate would cancel (`OPS-41`,
2026-10-03). Both the direct rate read and the return observed through the conditional write use
that branch, with the returned currency history. A short deferral leaves the worker `idle`, the
row `queued`, the fence untouched and the episode open. Queue eligibility is not modelled; see
`Provisiond.Claim`'s omissions for the later-bound and later-suspension evidence (`pv-gip.36`).

For the 2026-10-02 paused grace, `World.rateHistory` is replay's effective completed outage
spans in natural time units, not a new persisted field. `rateRestored` appends an outage only
when returning from no rate; a thin `pass` does not close it. A trace assumes its rate-return
event occurs at the effective qualifying boundary. `Claim.rateTime` unions spans so overlap
cannot double-count absence. This abstracts currency replay, not subject `absorbed_until`, and
assumes no ordering of raw `observed_at` values. The model proves neither history retention nor
replay correctness nor incident closure; those remain obligations of `STO-49` and `STO-56`.

What the model omits: the first 2026-09-05 form of
the suspension exemption, keyed on the attempt's own reason; a second attempt enqueued while one is
in flight (the model holds one attempt, and every enqueue waits for it); `OPS-31`'s resolution
verbs on an `uncertain` episode (`Provisiond.Tables` has the rows); `LDG-62`'s sizing of the
commitment it grows — `extend` takes the satoshis as given — and its wire answers (`API-7` owns collection and ordering; `Provisiond.Admission`
checks that tail): every refusal here is the unchanged world, whichever test
made it; the `late_attach_cleanup` reason and `LDG-40`'s no-rate attach transaction (2026-10-04,
`pv-gip.27`); the two-clock replay of the outage's start over `STO-49`'s rows — what
a changed staleness bound or window does to the replayed start belongs to `STO-37` and `OVR-19`,
and history retention under a changed window remains outside this model (`pv-gip.28`);
no event moves the start
of an outage already open, a restore that loses the rows it is replayed from included (`LDG-64`:
"A restore that loses `STO-49` rows the start is replayed from moves it as well" — `restoreRecord`
is `STO-56`'s record and nothing of `STO-49`'s); a second machine, tenant or currency, so that
`LDG-59`'s per-currency rate, outage and bound are one currency's here; historical posting
insertion and posting closure without a new observation (`STO-37`, `LDG-64`); and the record's close
at the meter stop. The exit's close is not modelled: `LDG-38` says "The exit closes an open
subject outage row at that end". Here `goneWrite` and a settlement
with the resource gone leave `World.outageOpen` as it was, so a machine recorded gone can still
show an open record. No modelled outcome turns on it while `OPS-41`'s first step is
in the order: an attempt on a machine recorded gone is settled there, before the step that
contends on the record, and `meterOpens` and `outageBound` each stop at a machine recorded gone.
The provider's answer is classified as
`succeeded` on a reply, `failed` on a refusal and `needs_reconciliation` on a lost reply —
`OPS-11`'s table is `Provisiond.Tables`'s and is not repeated. A machine is "funded" where a rate
exists and re-deriving `LDG-33` at it puts the date strictly in the future; whole satoshis per
second throughout. -/

namespace Provisiond.Fence
open Provisiond.Claim Provisiond.Runway Provisiond.Tables

/-- What `machines.destroy_committed` holds. `attempt` is the column as it stood until 2026-09-08,
"the attempt's operation id"; the distinct identity types mean the withdrawn design has to be
written down to be modelled at all. -/
inductive Holder
  | episode (e : EpisodeId)
  | attempt (o : OperationId)
  deriving DecidableEq, Repr

structure Machine where
  /-- `reserved_sats`. -/
  commitment     : Nat
  /-- The stored date the sweep routes on (`05-persistence.md`'s index). -/
  runwayUntil    : Nat
  /-- `machines.destroy_committed`. -/
  fence          : Option Holder
  /-- The provider applied a delete. Monotone: nothing here restores a machine. -/
  destroyed      : Bool
  /-- `machines.state` recorded gone (`STO-48`), by the gone-write. Monotone. -/
  gone           : Bool
  deriving DecidableEq, Repr

/-- `OPS-39`'s stated reasons, those this model enqueues under. -/
inductive Reason
  | exhausted | tenantSuspended | rateOutageBound
  deriving DecidableEq, Repr

/-- `STO-52`'s row: the episode, its state, and "the reasons that contributed are retained as the
episode's `reasons` **set**" (`OPS-39`). -/
structure EpisodeRow where
  id      : EpisodeId
  state   : Episode
  reasons : List Reason
  deriving DecidableEq, Repr

/-- The cancellation the worker holds: its operation, its episode, and its row as the claim
model's guards see it. -/
structure Attempt where
  op  : OperationId
  ep  : EpisodeId
  row : Row
  deriving DecidableEq, Repr

/-- Settled, in `OPS-3`'s sense, or `needs_reconciliation`: no longer `queued` or `running`. -/
def Attempt.done (a : Attempt) : Bool :=
  a.row.status != .queued && a.row.status != .running

def freshRow : Row := { status := .queued, claim := ⟨0⟩, record := 0, revision := 0 }

inductive Holds
  | episodeId | attemptId
  deriving DecidableEq, Repr

/-- `OPS-41`'s abort predicate: the re-derived date (`abortDate`), or the withdrawn 2026-09-04
form `usable_sats > 0` (`abortSats`). -/
inductive AbortPredicate
  | date | sats
  deriving DecidableEq, Repr

/-- What the suspension exemption reads: "the tenant's current state" (`OPS-41`), or "the
episode's `reasons` set, which is deduplication history" — the form rewritten away on 2026-09-05. -/
inductive SuspensionKey
  | currentState | episodeReasons
  deriving DecidableEq, Repr

/-- The dated amendments this module carries, each a parameter so that removing it is a one-token
change a witness theorem exercises. `recheckInsideFence`: `OPS-42`, 2026-09-02, "`OPS-41`'s
re-check and this fence write MUST be one transaction". `fenceHolds`: `OPS-42`, 2026-09-08, "the
fence holds the episode, not the attempt". `fenceOnOpenEpisode`: `OPS-42`, 2026-09-09, the write
guarded "on that episode being open". `abortPredicate`: `OPS-41`, 2026-09-04, "The predicate is
the re-derived `runway_until`". `abortWritesDate`: `OPS-41`, 2026-09-05, "write that re-derived
`runway_until` to the machine row". `extendWritesDate`: `LDG-62`, 2026-09-05, the same write.
`suspensionKey`: `OPS-41`, 2026-09-05, "keyed on the tenant's current state ... and not on the
episode's `reasons` set". `outageWrite`: `OPS-41`, 2026-09-05, the conditional write on this
machine's `rate_outage` record, of which the requirement now holds that at the bound no rate "is
established by that conditional write, not by a read"; its off position takes the transaction's
read of no rate at its word. `ownIdClause`: `OPS-42`, 2026-09-02, the guard's second
disjunct, "`IS NULL` alone until 2026-09-02". `rateIsWindowMedian`: `LDG-58`, 2026-09-23
(`ADR-0027`), "The rate is the lower median of the rate observations for its currency —
`STO-49`'s rows, one per pass — whose `observed_at` lies inside the last window-length before the
pass that computed the rate"; its off position is the rule that stood before, one pass's
observation as the rate, under which one poisoned pass moved the date into the past. `graceAtClaim`:
`OPS-41`, 2026-09-25 (`ADR-0028`), "A claim made while a restore record is open and its
`grace_ends_at` is null or in the future defers, and writes no fence"; its off position is the
withdrawn placement, the grace read on the provider call after the claim has fenced — the trap
`ADR-0028` names, "A machine already fenced when the grace begins ... refuses `LDG-62`'s
extension for the whole grace" — reading the record's instant there, since no machine carries a
deadline. Their off positions retain withdrawn traps, not alternative current rules (`ADR-0026`).
`retryGuard`: `OPS-48`, 2026-09-09,
`retry` as "a conditional write on `(id, state = stalled)`".

The rules of 2026-10-02 (`ADR-0029`), each with its off position; where a wording was withdrawn,
it is quoted from the dated note that keeps it. `goneOrClosedFirst`: `OPS-41`'s first step,
"**The machine is recorded gone, or its episode is closed.**"; its off position is the order as
it stood before that day, which began at the suspension read and left a gone machine to the
no-rate branch —
`ADR-0029`: "Zero rows can also mean a machine genuinely gone, because the re-check runs before
the fence write". `noRateWaits`: `OPS-41`'s fourth step, "The claim defers: the operation is
returned to `queued` by `OPS-8`'s ordinary short delay, and no fence is written"; its off position
is the wording withdrawn in `OPS-41`'s note, "**Where there is no rate, the cancellation
proceeds.**", under which the conditional write is reached whatever the deadline.
`absentRecordProceeds`: `OPS-41`'s fifth step, "Where it affects no row and there is still no
rate, the machine carries no open record and the cancellation proceeds as well"; its off position
is the reading withdrawn in the same note, "the machine's own meter stopped (`LDG-74`), there is
nothing left to cancel, and it settles as the no-mutation case". `boundReachesAll`: `LDG-64`,
"The bound's cancellation reaches every machine not recorded gone priced in the outage's currency,
whether or not
the meter opened a `rate_outage` record for it"; its off position is the scope withdrawn in
`OPS-41`'s note, "A `rate_outage_bound` cancellation is enqueued only for a machine carrying such
a record". `sweepNeedsRate`: `LDG-16`, "The exhaustion sweep MUST route a machine where its stored
`runway_until` has passed and its currency has a rate (`LDG-59`) and it is not recorded gone,
and MUST NOT route it
otherwise"; its off position is the predicate withdrawn in `LDG-16`'s note, "MUST route a machine
where its stored `runway_until` has passed, and MUST NOT route it otherwise", which is also the
row withdrawn in `LDG-40`'s note, "**the exhaustion sweep** (MUST continue: it reduces
exposure)", and the sentence withdrawn in `LDG-65`'s, "**The exhaustion sweep continues during an
outage on the last derived `runway_until`**". `extendNeedsRate`: `LDG-40`, "With no rate for the
machine's currency, an extension of runway MUST halt as a create does"; no wording was withdrawn
for it — `LDG-40`'s note has only "The extension's row was added the same day" — and its off
position is the extension as this module modelled it until then, which grew the commitment with
no rate and skipped the date. `pauseFundingGrace` is the further 2026-10-02 amendment:
`OPS-41` says "An outage MUST pause that measure, neither spending the remaining grace nor
resetting what accumulated". Off restores the original wall-clock-only grace.
`pausedGraceInFence`: the 2026-10-03 placement in step 3 after re-derivation; off reinstates
`ad6e2d9`'s claim-time check and computed paused-end parking, the historical counterfactual. This
is separate from `graceAtClaim`, which controls the original wall-clock gate. `ADR-0029` records
both withdrawn traces. `rederiveFirst` controls the transaction entry: off checks paused
grace before entering the ordinary re-check, even for a funded machine. `OPS-41` says
"The worker re-derives and applies the predicate above **first**". -/
structure Params where
  recheckInsideFence   : Bool
  fenceHolds           : Holds
  fenceOnOpenEpisode   : Bool
  abortPredicate       : AbortPredicate
  abortWritesDate      : Bool
  extendWritesDate     : Bool
  suspensionKey        : SuspensionKey
  outageWrite          : Bool
  ownIdClause          : Bool
  rateIsWindowMedian   : Bool
  pauseFundingGrace    : Bool
  pausedGraceInFence   : Bool
  rederiveFirst        : Bool
  graceAtClaim         : Bool
  retryGuard           : Bool
  goneOrClosedFirst    : Bool
  noRateWaits          : Bool
  absentRecordProceeds : Bool
  boundReachesAll      : Bool
  sweepNeedsRate       : Bool
  extendNeedsRate      : Bool
  deriving DecidableEq, Repr

/-- The fence as it stands, with every guard it composes from `OPS-41`, `LDG-62`, `LDG-58`,
`OPS-48`, `LDG-16`, `LDG-40` and `LDG-64` present; tagged to the fence's own requirement. One field
per line: `ci.yml`'s controls flip one each. -/
@[req "OPS-42"]
def current : Params := {
    recheckInsideFence   := true,
    fenceHolds           := .episodeId,
    fenceOnOpenEpisode   := true,
    abortPredicate       := .date,
    abortWritesDate      := true,
    extendWritesDate     := true,
    suspensionKey        := .currentState,
    outageWrite          := true,
    ownIdClause          := true,
    rateIsWindowMedian   := true,
    pauseFundingGrace    := true,
    pausedGraceInFence   := true,
    rederiveFirst        := true,
    graceAtClaim         := true,
    retryGuard           := true,
    goneOrClosedFirst    := true,
    noRateWaits          := true,
    absentRecordProceeds := true,
    boundReachesAll      := true,
    sweepNeedsRate       := true,
    extendNeedsRate      := true }

/-- What this attempt writes into the fence column. -/
def Params.holder (p : Params) (a : Attempt) : Holder :=
  match p.fenceHolds with
  | .episodeId => .episode a.ep
  | .attemptId => .attempt a.op

/-- The abort predicate in force, on what the re-check read. -/
def Params.abort (p : Params) (commitment prot rate : Nat) : Bool :=
  match p.abortPredicate with
  | .date => abortDate commitment prot rate
  | .sats => abortSats commitment prot rate

/-- Where the worker is. `holding`: claimed, `OPS-8`'s hold on the machine, before the fence
transaction. It carries the claim number and nothing the worker read at the claim: `OPS-41`'s
order is decided "inside the fence transaction and on what that transaction reads, never on its
claim snapshot". `readUnfenced`: the split variant's phase between a read that let the
cancellation through and its write, with the date the read derived. `fenced`: the fence written —
the only phase a provider call leaves from. `noMutation`: `OPS-41`'s abort, with the re-derived
date where the re-check derived one, to be settled `succeeded`. `dispatched`: the provider call
made, holding its reply or its loss. -/
inductive Phase
  | idle
  | holding (mine : ClaimNumber)
  | readUnfenced (mine : ClaimNumber) (date : Option Nat)
  | fenced (mine : ClaimNumber)
  | noMutation (mine : ClaimNumber) (date : Option Nat)
  | dispatched (mine : ClaimNumber) (reply : Option Bool)
  deriving DecidableEq, Repr

structure World where
  m           : Machine
  /-- The tenant's available balance. -/
  balance     : Nat
  now         : Nat
  /-- `LDG-59`'s rate, whole satoshis per second, and `none` while "there is no rate" (`LDG-64`). -/
  rate        : Option Nat
  /-- `STO-56`'s restore record where one is open, with the instant `Provisiond.Restore` wrote,
  or null before step (3); `none` where no record is open. -/
  restore     : Option RestoreRecord := none
  /-- Effective completed currency outages, a replay abstraction, not new runtime storage. -/
  rateHistory : Claim.RateHistory := []
  /-- The interval used for step (3)'s single end write. -/
  interval    : Nat := 60
  /-- `protected_sats`. -/
  prot        : Nat
  /-- The tenant's current suspension state (`API-58`, `WIR-41`). -/
  suspended   : Bool
  /-- Whether this machine carries an open `rate_outage` deficiency record: `STO-37`'s row,
  open while `absorbed_until IS NULL`, opened by the meter (`meterOpens`) and by nothing else
  here. -/
  outageOpen  : Bool
  /-- The start of the outage, read while there is no rate: a fact of history, given by the event
  that lost the rate and independent of whether this machine carries a record. `STO-37` defines
  it and the replay that produces it is not modelled. -/
  outageStart : Nat
  /-- The maximum tolerated rate outage (`LDG-64`), as the setting in force: `OVR-19`'s register
  holds it, and `setMaxOutage` is the restart that loads another value. -/
  maxOutage   : Nat
  episode     : Option EpisodeRow
  attempt     : Option Attempt
  phase       : Phase
  nextId      : Nat
  deriving DecidableEq, Repr

def World.episodeOpen (w : World) : Bool := w.episode.any (·.state.isOpen)

/-- The outage's deadline, a function of the given start and the setting in force, computed at
each use. `LDG-64` says "compute the outage's deadline from history, and store it nowhere". It is
"the outage's start plus the maximum tolerated outage". Of the two terms the maximum is the one
this model lets change; see `OVR-19` for the setting rule. The start is given, with no event
that replays it under other parameters. -/
@[req "LDG-64"]
def World.deadline (w : World) : Nat := w.outageStart + w.maxOutage

/-- `OPS-41`'s fourth and fifth steps turn on whether "the deadline has passed", and `LDG-64`:
"An instant reached has passed". -/
@[req "OPS-41"]
def World.deadlinePassed (w : World) : Bool := w.deadline ≤ w.now

/-- `LDG-16`: "The exhaustion sweep MUST route a machine where its stored `runway_until` has
passed and its currency has a rate (`LDG-59`) and it is not recorded gone, and MUST NOT route it
otherwise." This definition checks date and rate, with the rate clause under
`sweepNeedsRate`; `sweep` carries the not-gone clause. The off position keeps the date check
without the rate, the predicate `LDG-16`'s note withdrew on 2026-10-02.
`LDG-16` says of the grace that it "is no clause of this predicate". -/
@[req "LDG-16"]
def World.routed (w : World) (p : Params) : Bool :=
  w.m.runwayUntil ≤ w.now && (!p.sweepNeedsRate || w.rate.isSome)

/-- `PRV-13e`: what re-derivation "recomputes is `runway_until`, not the commitment". The optional
observation is the acceptance order (`STO-49`) the pass consumed in the machine's currency; `none`
is the halted pass, which writes nothing — `LDG-40`: "the halt MUST NOT itself trigger
exhaustion". The existing cancellation fence is preserved. -/
@[req "PRV-13e"]
def rederive (w : World) (newDate : Nat) (observation : Option Nat) : World :=
  match observation with
  | none => w
  | some _ => { w with m := { w.m with runwayUntil := newDate } }

/-- `LDG-40`: "the halt MUST NOT itself trigger exhaustion". Without an observation re-derivation
is the identity, regardless of the proposed date. -/
@[req "LDG-40"]
theorem no_observation_changes_nothing (w : World) (newDate : Nat) :
    rederive w newDate none = w := rfl

/-- The rate lost, with the outage's start as history gives it. The start is an argument and not
the model's clock: the replayed start can precede the instant the loss is noticed, and what
replays it is not modelled. An outage already open keeps its start — a second no-rate input is
the same outage, and nothing here restarts it. No record is opened. `STO-37` says "The row is the
subject's, and the meter opens it". -/
@[req "LDG-64"]
def loseRate (w : World) (start : Nat) : World :=
  match w.rate with
  | none => w
  | some _ => { w with rate := none, outageStart := start }

/-- The rate restored, at `r`: `LDG-64`'s "close the absorbed window at the observation with
which `LDG-58`'s window produces a rate again", the record's `absorbed_until` "written with that
observation's instant, by that observation's own write". The window that produced `r` is not
carried here; `pass` is the event that carries one. -/
@[req "LDG-64"]
def rateRestored (w : World) (r : Nat) : World :=
  { w with rate := some r, outageOpen := false,
           rateHistory := if w.rate.isNone then (w.outageStart, w.now) :: w.rateHistory
                          else w.rateHistory }

/-- `LDG-58`: "Each pass that accepts an observation computes the rate over the window as of that
pass, and the rate holds until the next such pass". The prices inside the window as of this pass
are given, in acceptance order, as `rederive` is given its date; under `rateIsWindowMedian` the
rate is `Provisiond.Rate.atPass`'s over them, and under the withdrawn rule it is the pass's own
observation, the newest. A pass whose window yields a rate is `rateRestored`'s write, and one
whose window yields none is `loseRate`'s, with the start it is given: either way of losing the
rate treats the outage's start alike. Neither opens `STO-37`'s record — that is the meter's
(`meterOpens`) — so a thin pass leaves no rate and no record, which is the state `ADR-0029` was
written for. -/
@[req "LDG-58"]
def pass (p : Params) (w : World) (window : List Nat) (start : Nat) : World :=
  match (if p.rateIsWindowMedian then Rate.atPass window else window.getLast?) with
  | some r => rateRestored w r
  | none => loseRate w start

/-! ## The events -/

/-- `OPS-39`: an episode is "opened once, and found open by every subsequent sweep until it
closes", so an enqueue against a machine whose episode is open joins it — the reason is added to
the set and nothing is enqueued, "the index, not a claim, is what makes the second sweep enqueue no
duplicate cancellation". Otherwise the episode is opened `attempting` "with its first attempt
enqueued in the same transaction" (`OPS-48`), once the previous attempt is done. -/
@[req "OPS-39"]
def enqueue (w : World) (r : Reason) : World :=
  if w.episodeOpen then
    { w with episode := w.episode.map fun ep => { ep with reasons := ep.reasons.insert r } }
  else if w.phase == .idle && w.attempt.all Attempt.done then
    let ep : EpisodeId := ⟨w.nextId⟩
    { w with episode := some { id := ep, state := .attempting, reasons := [r] },
             attempt := some { op := ⟨w.nextId + 1⟩, ep := ep, row := freshRow },
             nextId := w.nextId + 2 }
  else w

/-- `OPS-48`'s row applied to the machine's episode `ep`: the state after the event, and the fence
"**Cleared**, same transaction" exactly where the row says (`episodeStep`'s second component). -/
def applyRow (w : World) (ep : EpisodeRow) (ev : Tables.Event) : World :=
  { w with episode := some { ep with state := (episodeStep currentRows ep.state ev).1 },
           m := { w.m with fence := if (episodeStep currentRows ep.state ev).2 then none
                                    else w.m.fence } }

/-- The exhaustion sweep: `LDG-14`'s "At end of runway the machine MUST be cancelled", routed on
`LDG-16`'s predicate: `World.routed` checks the stored date and rate; `sweep` adds the clause
"and it is not recorded gone". Its other row
is `OPS-48`'s sweep-close: the sweep "finds the machine of a `stalled` episode funded under
`OPS-41`'s predicate ... **and its tenant not suspended** at that read" and closes it `funded`,
clearing the fence; a `stalled` episode has no attempt in flight, which the guard states. That row
took a rate before 2026-10-02 and is unchanged. -/
@[req "LDG-16"]
def sweep (p : Params) (w : World) : World :=
  match w.episode, w.rate with
  | some ep, some r =>
    if ep.state == .stalled && w.phase == .idle && w.attempt.all Attempt.done
        && p.abort w.m.commitment w.prot r then
      applyRow w ep (.sweepFunded w.suspended)
    else if w.routed p && !w.m.gone then enqueue w .exhausted else w
  | _, _ => if w.routed p && !w.m.gone then enqueue w .exhausted else w

/-- `LDG-16`: "While the currency has no rate the sweep routes nothing priced in it". With no rate
the sweep is the identity: it enqueues nothing and opens no episode, whatever the stored date. -/
@[req "LDG-16"]
theorem sweep_routes_nothing_without_a_rate (p : Params) (hg : p.sweepNeedsRate = true)
    (w : World) (hr : w.rate = none) : sweep p w = w := by
  unfold sweep
  split
  · simp_all
  · simp [World.routed, hg, hr]

/-- `OPS-41`'s paused measure, on the fence transaction's inputs. The current funding branch
supplies the rate and excludes suspension before reaching this check. No new state is stored. -/
@[req "OPS-41"]
def pausedGrace (p : Params) (w : World) : Bool :=
  match w.restore.bind (·.graceEndsAt) with
  | none => false
  | some t => p.pauseFundingGrace && t ≤ w.now &&
      Claim.rateTime w.rateHistory (t - w.interval) (w.now - (t - w.interval)) < w.interval

/-- Any finite outage pattern with a full interval accumulated finishes the paused portion.
This proves the measure, not eventual return, replay, retention or incident closure. -/
@[req "OPS-41"]
theorem grace_finishes_after_accumulated_interval (p : Params) (w : World) (t : Nat)
    (record : w.restore = some ⟨some t⟩)
    (elapsed : w.interval ≤ Claim.rateTime w.rateHistory (t - w.interval)
      (w.now - (t - w.interval))) : pausedGrace p w = false := by
  simp [pausedGrace, record, show ¬ Claim.rateTime w.rateHistory (t - w.interval)
    (w.now - (t - w.interval)) < w.interval by omega]

@[req "OPS-41"]
theorem paused_grace_guarded (p : Params) (w : World) (t : Nat)
    (hp : p.pauseFundingGrace = true) (record : w.restore = some ⟨some t⟩) (wall : t ≤ w.now)
    (remaining : Claim.rateTime w.rateHistory (t - w.interval)
      (w.now - (t - w.interval)) < w.interval) : pausedGrace p w = true := by
  simp [pausedGrace, hp, record, wall, remaining]

@[req "OPS-41"]
theorem paused_grace_unguarded (p : Params) (w : World)
    (hp : p.pauseFundingGrace = false) : pausedGrace p w = false := by
  unfold pausedGrace; split <;> simp [hp]

/-- Historical `ad6e2d9` placement only: a returned rate at the claim parks an unfunded or funded
attempt before re-derivation. The current placement never takes this branch (`ADR-0029`). -/
def legacyPausedClaim (p : Params) (w : World) : Bool :=
  !p.pausedGraceInFence && !w.suspended && w.rate.isSome && pausedGrace p w

/-- The withdrawn computed paused end, retained solely to execute the placement counterfactual.
The current branch writes only the original wall-clock end or the ordinary short delay. -/
def claimAvailableAt (p : Params) (w : World) : Option Nat :=
  if legacyPausedClaim p w then
    w.restore.bind fun r => r.graceEndsAt.map fun t =>
      w.now + (w.interval - Claim.rateTime w.rateHistory (t - w.interval)
        (w.now - (t - w.interval)))
  else Claim.graceAvailableAt w.restore

def claimGraceDefers (p : Params) (w : World) : Bool :=
  Claim.graceDefers w.restore w.now || legacyPausedClaim p w

/-- `OPS-8` composed with `OPS-41`'s wall-clock claim gate; the placement counterfactual alone
adds the withdrawn paused check here. -/
@[req "OPS-8"]
def claimStep (p : Params) (w : World) : World :=
  match w.phase, w.attempt with
  | .idle, some a =>
    match Claim.claim true a.row with
    | (r, some n) =>
      if p.graceAtClaim && claimGraceDefers p w then
        { w with attempt := some { a with
            row := Claim.defer Claim.current r n (claimAvailableAt p w) } }
      else { w with attempt := some { a with row := r }, phase := .holding n }
    | (_, none) => w
  | _, _ => w

/-- `OPS-41`: a claim under the grace "defers, and writes no fence" — the worker is `idle`, the
row is `queued` again with the claim gate's availability, and the fence is what it was. -/
@[req "OPS-41"]
theorem grace_defers_without_fence (p : Params) (hg : p.graceAtClaim = true) (w : World)
    (a : Attempt) (hph : w.phase = .idle) (ha : w.attempt = some a) (hq : a.row.status = .queued)
    (hd : claimGraceDefers p w = true) :
    (claimStep p w).phase = .idle ∧ (claimStep p w).m.fence = w.m.fence ∧
    ∃ a', (claimStep p w).attempt = some a' ∧ a'.row.status = .queued ∧
      a'.row.availableAt = claimAvailableAt p w := by
  simp [claimStep, hph, ha, hg, hd, Claim.claim, hq, Claim.defer, Claim.holds, Claim.current]

/-- Once grace no longer defers, the actual composed claim enters the ordinary worker.
No rate or funding snapshot is carried into that worker phase. -/
@[req "OPS-41"]
theorem claim_after_grace (p : Params) (w : World) (a : Attempt)
    (hph : w.phase = .idle) (ha : w.attempt = some a) (hq : a.row.status = .queued)
    (hd : claimGraceDefers p w = false) :
    (claimStep p w).phase = .holding ⟨a.row.claim.n + 1⟩ := by
  simp [claimStep, hph, ha, hq, hd, Claim.claim]

/-- Any finite replay pattern with a full interval accumulated releases the composed claim,
not just an arithmetic helper. Validity is the single end written by the restore procedure. -/
@[req "OPS-41"]
theorem accumulated_grace_releases_claim (p : Params) (w : World) (a : Attempt) (t : Nat)
    (hph : w.phase = .idle) (ha : w.attempt = some a) (hq : a.row.status = .queued)
    (record : w.restore = some ⟨some t⟩) (valid : w.interval ≤ t)
    (started : t - w.interval ≤ w.now)
    (elapsed : w.interval ≤ Claim.rateTime w.rateHistory (t - w.interval)
      (w.now - (t - w.interval))) :
    (claimStep p w).phase = .holding ⟨a.row.claim.n + 1⟩ := by
  apply claim_after_grace p w a hph ha hq
  have ht := Claim.rateTime_le w.rateHistory (t - w.interval) (w.now - (t - w.interval))
  have wall : ¬ w.now < t := by omega
  simp [claimGraceDefers, Claim.graceDefers, record, legacyPausedClaim, pausedGrace, wall,
    show ¬ Claim.rateTime w.rateHistory (t - w.interval) (w.now - (t - w.interval)) < w.interval by omega]

/-- What the fence transaction decides. `noMutation`: `OPS-41`'s abort, with the re-derived date
where one was derived. `proceed`: on to `OPS-42`'s fence write, with that date. `defer`: the
short deferral in step 3 or 4; neither settles. -/
inductive Verdict
  | noMutation (date : Option Nat)
  | proceed (date : Option Nat)
  | defer
  deriving DecidableEq, Repr

/-- `OPS-41`'s first step: "**The machine is recorded gone, or its episode is closed.**" The
episode is the attempt's own (`operations.episode_id`), so an attempt whose episode is no longer
the machine's is under a closed one. -/
@[req "OPS-41"]
def settledFirst (w : World) (a : Attempt) : Bool :=
  w.m.gone || !(w.episode.any fun ep => ep.id == a.ep && ep.state.isOpen)

/-- `OPS-41`'s exemption: "where the machine's tenant IS suspended at the moment of the re-check,
read in the same fence transaction", or — the withdrawn key — the episode's `reasons` set. -/
@[req "OPS-41"]
def exempt (p : Params) (w : World) : Bool :=
  match p.suspensionKey with
  | .currentState => w.suspended
  | .episodeReasons => w.episode.any (·.reasons.contains .tenantSuspended)

/-- `OPS-41`'s common funding decision: re-derive first, then short-defer only an unfunded
machine with unspent paused grace. The return observed by step 5 uses this same branch. -/
@[req "OPS-41"]
def derive (p : Params) (w : World) (r : Nat) : Verdict :=
  if p.abort w.m.commitment w.prot r then
    .noMutation (some (w.now + runwaySeconds w.m.commitment w.prot r))
  else if p.pausedGraceInFence && pausedGrace p w then .defer
  else .proceed (some (w.now + runwaySeconds w.m.commitment w.prot r))

/-- `OPS-41`'s order, on what the fence transaction reads, "and the first step that applies
decides". (1) The machine recorded gone or its episode closed: no mutation, and no date — "**It
writes no `runway_until`**". (2) The tenant suspended now: "The funding re-check does not apply
and the cancellation proceeds". (3) A rate: `derive`. (4) No rate and the deadline not passed:
the claim defers. (5) No rate and the deadline passed, "`LDG-64`'s bound": the conditional write
on this machine's open `rate_outage` record. `restored` is the restoration, where there is one,
that commits after this transaction read no rate and before that write: it closed the record, so
the write "affects no row and a rate is now in force" and the worker re-derives at it. With no
such restoration, an open record is a row affected and the cancellation proceeds; and no record
is "no row and there is still no rate", where it "proceeds as well" under `absentRecordProceeds`
and settles as the no-mutation case under the withdrawn reading.

For a machine with no record the write contends with nothing, and `OPS-41` leaves that case as it
is: "**One case is left unordered, and it is accepted**". Both orders are traces here and neither
is chosen. `restored` on such a machine is the return the worker's read after the write sees, and
it re-derives; a `rateRestored` event straight after the transaction is the return it does not
see, and the cancellation has proceeded.

The guards in the order they are read: without `goneOrClosedFirst` the order begins at the
suspension read; without `noRateWaits` the write is reached whatever the deadline; without
`outageWrite` the transaction's read of no rate is taken at its word and the cancellation
proceeds on it. -/
@[req "OPS-41"]
def recheck (p : Params) (w : World) (a : Attempt) (restored : Option Nat) : Verdict :=
  if p.goneOrClosedFirst && settledFirst w a then .noMutation none
  else if exempt p w then .proceed none
  else match w.rate with
    | some r => derive p w r
    | none =>
      if p.noRateWaits && !w.deadlinePassed then .defer
      else if !p.outageWrite then .proceed none
      else match restored with
        | some r => derive p (rateRestored w r) r
        | none => if w.outageOpen || p.absentRecordProceeds then .proceed none else .noMutation none

/-- The world a fence transaction commits against: the one it read, or — where it read no rate
and a restoration committed before the transaction did — that world with the rate restored and
the record closed. `OPS-41` says "`LDG-35`'s per-tenant primitive orders nothing against a
deployment-wide event". Nothing of the tenant's moves: the machine row, the balance, the episode
and the suspension are what the transaction read. -/
@[req "OPS-41"]
def midTxn (w : World) (restored : Option Nat) : World :=
  match restored, w.rate with
  | some r, none => rateRestored w r
  | _, _ => w

/-- `OPS-42`'s conditional write, "guarded on `destroy_committed IS NULL` *or* `destroy_committed`
already holding this operation's episode id" — "**and on that episode being open**" under
`fenceOnOpenEpisode`: one row where it admits, zero rows otherwise. -/
@[req "OPS-42"]
def fenceAdmits (p : Params) (w : World) (a : Attempt) : Bool :=
  (w.m.fence == none || (p.ownIdClause && w.m.fence == some (p.holder a))) &&
  (!p.fenceOnOpenEpisode || w.episode.any fun ep => ep.id == a.ep && ep.state.isOpen)

/-- The write itself, where the re-check said proceed: the fence set and the worker `fenced`, or
"another actor won the race and the worker MUST abort the cancellation". -/
def writeFence (p : Params) (w : World) (n : ClaimNumber) (a : Attempt) (d : Option Nat) : World :=
  if fenceAdmits p w a then
    { w with m := { w.m with fence := some (p.holder a) }, phase := .fenced n }
  else { w with phase := .noMutation n d }

/-- The fence transaction: `OPS-41`'s re-check "in the same serialized transaction that writes
`OPS-42`'s fence". An abort is `noMutation` with no fence written. A deferral is `OPS-8`'s defer —
`Provisiond.Claim.defer`, with no `available_at` instant, since a short delay carries none in that
model — and leaves the worker `idle`, the row `queued`, the episode and the fence as they were,
with no settlement (`OPS-41`). Under `recheckInsideFence`
a machine the re-check lets through takes the write in the same step; without it the transaction
is the read alone, and the write is `fenceWrite`'s later step. -/
@[req "OPS-41"]
def fenceTxn (p : Params) (w : World) (restored : Option Nat) : World :=
  match w.phase, w.attempt with
  | .holding n, some a =>
    match recheck p w a restored with
    | .defer =>
      { midTxn w restored with
          attempt := some { a with row := Claim.defer Claim.current a.row n }, phase := .idle }
    | .noMutation d => { midTxn w restored with phase := .noMutation n d }
    | .proceed d =>
      if p.recheckInsideFence then writeFence p (midTxn w restored) n a d
      else { midTxn w restored with phase := .readUnfenced n d }
  | _, _ => w

/-- The order control at the fence transaction's entry. With the guard off, a rate-present
funding claim can short-defer before re-derivation; the ordinary ordered transaction is
never reached on that path. The original claim gate and the paused placement guard are unchanged.
The counterfactual preserves the gone/closed and suspension precedence. -/
def fundingOrderTxn (p : Params) (w : World) (restored : Option Nat) : World :=
  match w.phase, w.attempt with
  | .holding n, some a =>
    if !p.rederiveFirst && !(p.goneOrClosedFirst && settledFirst w a) &&
        !exempt p w && w.rate.isSome && p.pausedGraceInFence && pausedGrace p w then
      { midTxn w restored with
          attempt := some { a with row := Claim.defer Claim.current a.row n }, phase := .idle }
    else fenceTxn p w restored
  | _, _ => fenceTxn p w restored

/-- The counterfactual entry either reaches the ordered transaction or short-defers without
changing the machine, balance, episode or id counter. -/
theorem fundingOrderTxn_cases (p : Params) (w : World) (restored : Option Nat) :
    fundingOrderTxn p w restored = fenceTxn p w restored ∨
    ((fundingOrderTxn p w restored).phase = .idle ∧
      (fundingOrderTxn p w restored).m = w.m ∧
      (fundingOrderTxn p w restored).balance = w.balance ∧
      (fundingOrderTxn p w restored).episode = w.episode ∧
      (fundingOrderTxn p w restored).nextId = w.nextId) := by
  unfold fundingOrderTxn midTxn rateRestored
  (repeat' split) <;> simp_all

/-- The split variant's second transaction: the fence write, deciding on what an earlier
transaction read. It exists only where the read and the write are split; under
`recheckInsideFence` there is no such step. -/
@[req "OPS-42"]
def fenceWrite (p : Params) (w : World) : World :=
  match p.recheckInsideFence, w.phase, w.attempt with
  | false, .readUnfenced n d, some a => writeFence p w n a d
  | _, _, _ => w

/-- `LDG-62`: in its own transaction, "conditional-write the machine row guarded on
`machines.destroy_committed IS NULL`", failing `conflict` where it affects no row — "opening or
growing no commitment and moving no balance" — and refused for a suspended tenant, which "`API-7`
step 5b refuses" (`OPS-41`). With no rate it halts under `extendNeedsRate` — `LDG-40`: "With no
rate for the machine's currency, an extension of runway MUST halt as a create does" — and every
refusal is the unchanged world, so no order between them is stated. Where it is admitted it grows
the commitment from available under "`LDG-10`'s no-negative rule" and, under `extendWritesDate`,
writes the re-derived `runway_until`. Without `extendNeedsRate` it grows the commitment with no
rate and writes no date, since `LDG-33` "recomputes the date only when a rate exists"
(`LDG-65`). -/
@[req "LDG-62"]
def extend (p : Params) (w : World) (sats : Nat) : World :=
  if w.m.fence != none || w.suspended || w.balance < sats then w
  else
    let c := w.m.commitment + sats
    match w.rate with
    | some r =>
      if p.extendWritesDate then
        { w with m := { w.m with commitment := c, runwayUntil := w.now + runwaySeconds c w.prot r },
                 balance := w.balance - sats }
      else { w with m := { w.m with commitment := c }, balance := w.balance - sats }
    | none =>
      if p.extendNeedsRate then w
      else { w with m := { w.m with commitment := c }, balance := w.balance - sats }

/-- The provider call, outside every serialization (`LDG-69`), from `fenced` and nowhere else.
With `graceAtClaim` off, the withdrawn wall-clock placement: the
call waits on the record's instant, after the claim has already fenced, so the fence "refuses
`LDG-62`'s extension for the whole grace" (`ADR-0028`). `applied` is the provider's fact and
`reply` what came back (`ProviderOutcome`, flattened). -/
@[req "OPS-41"]
def providerDelete (p : Params) (w : World) (applied : Bool) (reply : Option Bool) : World :=
  match w.phase with
  | .fenced n =>
    if !p.graceAtClaim && Claim.graceDefers w.restore w.now then w
    else
      { w with m := { w.m with destroyed := w.m.destroyed || applied }, phase := .dispatched n reply }
  | _ => w

/-- How the reply settles the attempt: `OPS-48`'s first column and `STO-3`'s written state. -/
def ofReply : Option Bool → Settled × Written
  | some true => (.gone, .succeeded)
  | some false => (.failed, .failed)
  | none => (.needsReconciliation, .needsReconciliation)

/-- The terminal transaction: `STO-3`'s guarded write on the row, and `OPS-48`'s row on **this
attempt's** episode (`operations.episode_id`) with the fence cleared exactly where that row says.
A settlement with the resource gone is a gone-write of its own — `OPS-48`: "Where that write and
an attempt's terminal write are one transaction, as a delete's own 'already gone' answer is, they
are one close under the first row" — so it records the machine gone. An attempt whose episode is
no longer the machine's "changes the attempt and not the episode" (`OPS-48`), and so does one
under a closed episode, since `episodeStep` is `closed_absorbing`. -/
def finish (w : World) (n : ClaimNumber) (a : Attempt) (s : Settled) (wr : Written) : World :=
  let row := workerWrite Claim.current a.row { written := wr, record := 0, mine := n }
  match w.episode with
  | some ep =>
    if ep.id == a.ep then
      applyRow { w with attempt := some { a with row := row }, phase := .idle,
                        m := { w.m with gone := w.m.gone || s == .gone } } ep (.settled s)
    else { w with attempt := some { a with row := row }, phase := .idle,
                  m := { w.m with gone := w.m.gone || s == .gone } }
  | none => { w with attempt := some { a with row := row }, phase := .idle,
                     m := { w.m with gone := w.m.gone || s == .gone } }

/-- `OPS-41`'s abort write: "write that re-derived `runway_until` to the machine row". -/
def writeAbortDate (w : World) (d : Nat) : World := { w with m := { w.m with runwayUntil := d } }

/-- Settlement, from the abort or from the provider's answer. The abort also does what `OPS-41`
says of the funded case under `abortWritesDate` — the date write — so the sweep does not route
the same machine on the next pass; the lost-race abort settles "as `OPS-41` requires" (`OPS-42`)
and is read here as the same terminal transaction, writing the date the re-check derived where it
derived one. -/
@[req "OPS-48"]
def settle (p : Params) (w : World) : World :=
  match w.phase, w.attempt with
  | .noMutation n d, some a =>
    match p.abortWritesDate, d with
    | true, some d => writeAbortDate (finish w n a .noMutation .succeeded) d
    | _, _ => finish w n a .noMutation .succeeded
  | .dispatched n reply, some a => finish w n a (ofReply reply).1 (ofReply reply).2
  | _, _ => w

/-- `retry` (`API-64`), as `OPS-48`'s row has it: "on a `stalled` episode", "with a fresh attempt
enqueued in the same transaction as the state change; admissible in no other state" — under
`retryGuard`, "a conditional write on `(id, state = stalled)`", which is what makes a retry
racing a gone-write lose; without it, a plain write of `attempting`. -/
@[req "OPS-48"]
def retry (p : Params) (w : World) : World :=
  match w.phase, w.attempt, w.episode with
  | .idle, some a, some ep =>
    if a.done && (!p.retryGuard || ep.state == .stalled) then
      { w with episode := some { ep with state := (episodeStep currentRows .stalled .retry).1 },
               attempt := some { op := ⟨w.nextId⟩, ep := ep.id, row := freshRow },
               nextId := w.nextId + 1 }
    else w
  | _, _, _ => w

/-- The gone-write (`ADR-0021`): "the write of `machines.state` to gone with `state_observed_at`
(`STO-48`), by any of `LDG-74`'s triggers ... or by `API-63`'s termination", which "closes its
open episode `resource_gone` and clears the fence, in that transaction" — `OPS-48`'s row: "in any
open state, `scheduled` included". What the trigger observed is not modelled; the event is the
write. -/
@[req "OPS-48"]
def goneWrite (w : World) : World :=
  match w.episode with
  | some ep => applyRow { w with m := { w.m with gone := true } } ep .goneWrite
  | none => { w with m := { w.m with gone := true } }

/-- `API-58`'s suspension: the tenant's state, and its fan-out, which enqueues a
`tenant_suspended` cancellation — joining "an already-open exhaustion episode" (`OPS-41`). -/
@[req "API-58"]
def suspend (w : World) : World := enqueue { w with suspended := true } .tenantSuspended

/-- `WIR-41`'s resume: the tenant's state, and nothing else. -/
@[req "WIR-41"]
def resume (w : World) : World := { w with suspended := false }

/-- The rate lost: `LDG-59`'s window yielding "**no rate**", by staleness or by thinness at a
pass. It is not a pass below the quorum, of which `LDG-59` says "A pass below the quorum accepts
no observation and recomputes nothing, and the rate in force holds". `start` is the outage's start
as history gives it (`loseRate`). The machine's record is not opened here: `STO-37` says "The row
is the subject's, and the meter opens it"; `meterOpens` models the live-outage opening. -/
@[req "LDG-64"]
def rateLost (w : World) (start : Nat) : World := loseRate w start

/-- The meter opening this machine's `rate_outage` record. `STO-37` says "The row is the
subject's, and the meter opens it". This event models the still-live subject with no rate;
historical insertion and exit closure are outside the model, as the omissions state. A
world in which this event never happens is the machine `STO-37` describes: "a subject the meter
has not posted for since the outage began has no row". -/
@[req "STO-37"]
def meterOpens (w : World) : World :=
  if w.rate == none && !w.m.gone then { w with outageOpen := true } else w

/-- The restart that loads another maximum tolerated outage. `OVR-19` has it read "at the value in
force when `LDG-64`'s deadline is computed, for an outage already open too", so the deadline of an
open outage moves with it and nothing else is touched. -/
@[req "OVR-19"]
def setMaxOutage (w : World) (bound : Nat) : World := { w with maxOutage := bound }

/-- `LDG-64`'s bound canceller: "cancel machines at that bound if no rate has returned", a
`rate_outage_bound` cancellation, once the deadline has passed. The not-gone guard is part of
`LDG-64`'s population below. Under `boundReachesAll` it reaches the machine with a record or
without — `LDG-64`: "The bound's cancellation reaches every machine not recorded gone priced
in the outage's currency, whether or not the meter
opened a `rate_outage` record for it" — and without that guard only a machine carrying one, the
scope `OPS-41`'s note withdrew. -/
@[req "LDG-64"]
def outageBound (p : Params) (w : World) : World :=
  if w.rate == none && w.deadlinePassed && !w.m.gone && (p.boundReachesAll || w.outageOpen) then
    enqueue w .rateOutageBound
  else w

/-- `LDG-64`: the bound's cancellation "reaches every machine not recorded gone priced in the
outage's currency,
whether or not the meter opened a `rate_outage` record for it". With no rate and the deadline
passed, on a machine not recorded gone, the canceller's step is `enqueue`'s under
`rate_outage_bound`, whatever the record. What that step then does is `enqueue`'s and not this
theorem's: it opens an episode, joins one already open, or changes nothing while an attempt under
a closed episode has yet to settle. -/
@[req "LDG-64"]
theorem bound_reaches_a_machine_without_a_record (p : Params) (hg : p.boundReachesAll = true)
    (w : World) (hr : w.rate = none) (hd : w.deadlinePassed = true) (hgone : w.m.gone = false) :
    outageBound p w = enqueue w .rateOutageBound := by
  simp [outageBound, hr, hd, hg, hgone]

inductive Event
  | advance (seconds : Nat)
  | rederive (newDate : Nat) (observation : Option Nat)
  /-- A pass accepting an observation: the prices inside the window as of that pass, and the
  outage's start as history gives it, read only where the window yields no rate. -/
  | pass (window : List Nat) (start : Nat)
  /-- `STO-56`'s record as `Provisiond.Restore` wrote it: opened with the instant null, the
  instant written at step (3), or closed (`none`). -/
  | restoreRecord (r : Option RestoreRecord)
  | sweep | claim
  /-- The fence transaction, with the restoration that commits between its read of no rate and
  its conditional write, where there is one. -/
  | fenceTxn (restored : Option Nat := none)
  | fenceWrite
  | extend (sats : Nat)
  | providerDelete (applied : Bool) (reply : Option Bool)
  | settle | retry | goneWrite | suspend | resume
  | rateLost (start : Nat) | rateRestored (r : Nat) | meterOpens | setMaxOutage (bound : Nat)
  | outageBound
  deriving DecidableEq, Repr

def step (p : Params) (w : World) : Event → World
  | .advance seconds => { w with now := w.now + seconds }
  | .rederive date observation => rederive w date observation
  | .pass window start => pass p w window start
  | .restoreRecord r => { w with restore := r }
  | .sweep => sweep p w
  | .claim => claimStep p w
  | .fenceTxn restored => fundingOrderTxn p w restored
  | .fenceWrite => fenceWrite p w
  | .extend s => extend p w s
  | .providerDelete a r => providerDelete p w a r
  | .settle => settle p w
  | .retry => retry p w
  | .goneWrite => goneWrite w
  | .suspend => suspend w
  | .resume => resume w
  | .rateLost start => rateLost w start
  | .rateRestored r => rateRestored w r
  | .meterOpens => meterOpens w
  | .setMaxOutage bound => setMaxOutage w bound
  | .outageBound => outageBound p w

def run (p : Params) (w : World) : List Event → World
  | [] => w
  | e :: es => run p (step p w e) es

/-! ## Both commit orderings -/

theorem extend_guard (w : World) (sats : Nat) (hs : w.suspended = false) (hf : w.m.fence = none)
    (hb : sats ≤ w.balance) : (w.m.fence != none || w.suspended || w.balance < sats) = false := by
  simp [hf, hs, Nat.not_lt.mpr hb]

/-- An admitted extension grows the commitment by what it took from available and writes the
re-derived date (`LDG-62`, 2026-09-05: "an extension that grew the commitment and wrote no date
left the stored one in the past"). -/
@[req "LDG-62"]
theorem extend_admitted (p : Params) (hd : p.extendWritesDate = true) (w : World) (r : Nat)
    (hr : w.rate = some r) (hs : w.suspended = false) (sats : Nat) (hf : w.m.fence = none)
    (hb : sats ≤ w.balance) :
    (extend p w sats).m.commitment = w.m.commitment + sats ∧
    (extend p w sats).balance = w.balance - sats ∧
    (extend p w sats).m.runwayUntil = w.now + runwaySeconds (w.m.commitment + sats) w.prot r := by
  simp [extend, extend_guard w sats hs hf hb, hr, hd]

/-- `LDG-62`: "The halted extension opens or grows no commitment and moves no balance". With no
rate an extension changes nothing at all, whatever the fence, the tenant's state and the balance
would have answered. -/
@[req "LDG-62"]
theorem extend_halts_without_a_rate (p : Params) (hg : p.extendNeedsRate = true) (w : World)
    (hr : w.rate = none) (sats : Nat) : extend p w sats = w := by
  unfold extend
  split
  · rfl
  · simp [hr]

/-- What an extension leaves alone, admitted or refused, whatever the rate and the date rule. -/
theorem extend_frame (p : Params) (w : World) (sats : Nat) :
    (extend p w sats).phase = w.phase ∧ (extend p w sats).attempt = w.attempt ∧
    (extend p w sats).suspended = w.suspended ∧ (extend p w sats).prot = w.prot ∧
    (extend p w sats).now = w.now ∧ (extend p w sats).m.fence = w.m.fence ∧
    (extend p w sats).episode = w.episode ∧ (extend p w sats).rate = w.rate ∧
    (extend p w sats).outageOpen = w.outageOpen ∧ (extend p w sats).nextId = w.nextId ∧
    (extend p w sats).m.destroyed = w.m.destroyed ∧ (extend p w sats).m.gone = w.m.gone ∧
    (extend p w sats).outageStart = w.outageStart ∧
    (extend p w sats).maxOutage = w.maxOutage := by
  unfold extend; (repeat' split) <;> simp

/-- What a restoration committing inside a fence transaction leaves alone: everything but the
rate and the record. -/
theorem midTxn_frame (w : World) (restored : Option Nat) :
    (midTxn w restored).m = w.m ∧ (midTxn w restored).balance = w.balance ∧
    (midTxn w restored).phase = w.phase ∧ (midTxn w restored).attempt = w.attempt ∧
    (midTxn w restored).episode = w.episode ∧ (midTxn w restored).nextId = w.nextId ∧
    (midTxn w restored).outageStart = w.outageStart ∧
    (midTxn w restored).maxOutage = w.maxOutage := by
  unfold midTxn rateRestored; (repeat' split) <;> simp

/-- Where the transaction read a rate there is no such restoration to commit. -/
theorem midTxn_of_rate (w : World) (r : Nat) (hr : w.rate = some r) (restored : Option Nat) :
    midTxn w restored = w := by
  unfold midTxn; split <;> simp_all

theorem fenceAdmits_midTxn (p : Params) (w : World) (restored : Option Nat) (a : Attempt) :
    fenceAdmits p (midTxn w restored) a = fenceAdmits p w a := by
  obtain ⟨hm, -, -, -, he, -⟩ := midTxn_frame w restored
  simp [fenceAdmits, hm, he]

/-- A fence transaction whose re-check aborts: no fence written, the worker `noMutation` with
the date the re-check derived. -/
theorem fenceTxn_abort (p : Params) (w : World) (n : ClaimNumber) (a : Attempt)
    (restored : Option Nat) (d : Option Nat) (hph : w.phase = .holding n)
    (ha : w.attempt = some a) (hre : recheck p w a restored = .noMutation d) :
    fenceTxn p w restored = { midTxn w restored with phase := .noMutation n d } := by
  simp [fenceTxn, hph, ha, hre]

/-- `OPS-42`: "Extension first: the worker's read sees the new commitment, `OPS-41` applies, and
it makes no provider call at all." With the read inside the fence transaction, an extension the
store admitted before it is what the re-check reads; where that grown commitment funds the
machine at the rate the transaction reads, it decides no mutation, writes no fence, and the
provider call is inert. The rate is the world's and not a claim snapshot's — `OPS-41`: "never on
its claim snapshot" — and a machine recorded gone or under a closed episode is settled by the
first step with no mutation either, so neither is a hypothesis. -/
@[req "OPS-42"]
theorem extension_first (p : Params) (w : World)
    (n : ClaimNumber) (r : Nat) (a : Attempt) (hph : w.phase = .holding n) (hr : w.rate = some r)
    (ha : w.attempt = some a) (hs : w.suspended = false)
    (hk : p.suspensionKey = .currentState) (sats : Nat) (hf : w.m.fence = none)
    (hb : sats ≤ w.balance)
    (hfunded : p.abort (w.m.commitment + sats) w.prot r = true) (restored : Option Nat) :
    ∃ d, (fenceTxn p (extend p w sats) restored).phase = .noMutation n d ∧
    (fenceTxn p (extend p w sats) restored).m.fence = none ∧
    (fenceTxn p (extend p w sats) restored).m.commitment = w.m.commitment + sats ∧
    ∀ applied reply,
      providerDelete p (fenceTxn p (extend p w sats) restored) applied reply =
        fenceTxn p (extend p w sats) restored := by
  have hc : (extend p w sats).m.commitment = w.m.commitment + sats := by
    unfold extend; simp only [extend_guard w sats hs hf hb, hr]; (repeat' split) <;> simp_all
  obtain ⟨hph', ha', hs', hprot', hnow', hf', -, hr', -⟩ := extend_frame p w sats
  have hmid := midTxn_of_rate (extend p w sats) r (hr'.trans hr) restored
  have hre : ∃ d, recheck p (extend p w sats) a restored = .noMutation d := by
    unfold recheck
    split
    · exact ⟨_, rfl⟩
    · simp [exempt, hk, hs', hs, hr'.trans hr, derive, hc, hprot', hfunded]
  obtain ⟨d, hre⟩ := hre
  have hft := fenceTxn_abort p (extend p w sats) n a restored d (hph'.trans hph) (ha'.trans ha) hre
  rw [hmid] at hft
  refine ⟨d, by rw [hft], ?_, ?_, ?_⟩
  · rw [hft]; simpa using hf'.trans hf
  · rw [hft]; simpa using hc
  · intro applied reply; rw [hft]; simp [providerDelete]

/-- `LDG-62`'s refusal: with the fence set, an extension changes nothing — no commitment, no
balance, no date. -/
@[req "LDG-62"]
theorem extend_refused_under_fence (p : Params) (w : World) (h : Holder) (hf : w.m.fence = some h)
    (sats : Nat) : extend p w sats = w := by
  simp [extend, hf]

/-- `OPS-42`: "Fence first: the extension is refused, and the customer keeps its satoshis." A fence
transaction whose re-check lets the cancellation through and wins the write leaves the fence
holding this attempt, and every extension after it is `extend_refused_under_fence`'s: the
commitment and the balance are what the re-check read. -/
@[req "OPS-42"]
theorem fence_first (p : Params) (hp : p.recheckInsideFence = true) (w : World)
    (n : ClaimNumber) (a : Attempt) (restored : Option Nat) (d : Option Nat)
    (hph : w.phase = .holding n) (ha : w.attempt = some a)
    (hproceed : recheck p w a restored = .proceed d)
    (hadmit : fenceAdmits p w a = true) (sats : Nat) :
    (fenceTxn p w restored).phase = .fenced n ∧
    (fenceTxn p w restored).m.fence = some (p.holder a) ∧
    extend p (fenceTxn p w restored) sats = fenceTxn p w restored ∧
    (fenceTxn p w restored).m.commitment = w.m.commitment ∧
    (fenceTxn p w restored).balance = w.balance := by
  obtain ⟨hm, hbal, -⟩ := midTxn_frame w restored
  have hft : fenceTxn p w restored =
      { midTxn w restored with m := { w.m with fence := some (p.holder a) }, phase := .fenced n } := by
    simp [fenceTxn, hph, ha, hp, hproceed, writeFence, fenceAdmits_midTxn, hadmit, hm]
  refine ⟨by simp [hft], by simp [hft], ?_, by simp [hft], by simp [hft, hbal]⟩
  exact extend_refused_under_fence p _ (p.holder a) (by simp [hft]) sats

/-! ## The wait -/

/-- `OPS-41`'s fourth step: "The claim defers: the operation is returned to `queued` by `OPS-8`'s
ordinary short delay, and no fence is written." Over every world: a fence transaction on a
machine not recorded gone, its episode open, its tenant not suspended, with no rate and the
deadline not passed, writes nothing to the machine row — no fence and no date — leaves the
episode as it was, returns the row to `queued` with no `available_at` instant, and the worker to
`idle`. That is one fence transaction before the deadline, and so a part of `LDG-65`'s "Nothing
is cancelled on a date that passes while there is no rate" and not the whole of it: that sentence
is about the outage from end to end, the sweep's half of it is
`sweep_routes_nothing_without_a_rate`, and no theorem here runs the wait across claims. Whether a
restoration commits behind the transaction changes none of it; the next fence transaction reads the rate. The
row is the one the claim left, `running` under this worker's number. -/
@[req "OPS-41"]
theorem no_rate_waits (p : Params) (hk : p.suspensionKey = .currentState)
    (hwait : p.noRateWaits = true) (w : World) (n : ClaimNumber) (a : Attempt)
    (hph : w.phase = .holding n) (ha : w.attempt = some a)
    (hrun : a.row.status = .running) (hmine : a.row.claim = n) (hgone : w.m.gone = false)
    (hopen : (w.episode.any fun ep => ep.id == a.ep && ep.state.isOpen) = true)
    (hs : w.suspended = false) (hr : w.rate = none) (hd : w.deadlinePassed = false)
    (restored : Option Nat) :
    (fenceTxn p w restored).m = w.m ∧ (fenceTxn p w restored).episode = w.episode ∧
    (fenceTxn p w restored).phase = .idle ∧
    ∃ a', (fenceTxn p w restored).attempt = some a' ∧ a'.row.status = .queued ∧
      a'.row.availableAt = none := by
  have hre : recheck p w a restored = .defer := by
    simp [recheck, settledFirst, hgone, hopen, exempt, hk, hs, hr, hwait, hd]
  obtain ⟨hm, -, -, -, he, -⟩ := midTxn_frame w restored
  simp [fenceTxn, hph, ha, hre, hm, he, Claim.defer, Claim.holds, Claim.current, hrun, hmine]

/-- The converse of `no_rate_waits`, over every world, including an open restore incident.
A re-check defers only in the no-rate wait or in the applicable funding derivation (directly or
through step 5's returned rate). `derive_defers_iff` gives that added case its paused-grace
meaning. Exemption and the gone/closed first step still precede every deferral. This is a
property of one re-check, not a claim that a clocked wait eventually ends. -/
@[req "OPS-39"]
theorem defer_only_without_a_rate_before_the_deadline (p : Params) (w : World) (a : Attempt)
    (restored : Option Nat) (h : recheck p w a restored = .defer) :
    exempt p w = false ∧ (p.goneOrClosedFirst = true → settledFirst w a = false) ∧
    ((w.rate = none ∧ w.deadlinePassed = false ∧ p.noRateWaits = true) ∨
      (∃ r, w.rate = some r ∧ derive p w r = .defer) ∨
      (w.rate = none ∧ (p.noRateWaits = true → w.deadlinePassed = true) ∧
        p.outageWrite = true ∧ ∃ r, restored = some r ∧
          derive p (rateRestored w r) r = .defer)) := by
  unfold recheck at h
  split at h
  · simp at h
  · rename_i hfirst
    split at h
    · simp at h
    · rename_i hex
      refine ⟨by simpa using hex, fun hg => by simpa [hg] using hfirst, ?_⟩
      split at h
      · rename_i r hr
        exact .inr (.inl ⟨r, hr, h⟩)
      · rename_i hr
        split at h
        · rename_i hwait
          simp only [Bool.and_eq_true, Bool.not_eq_true'] at hwait
          exact .inl ⟨hr, hwait.2, hwait.1⟩
        · rename_i hwait
          split at h
          · simp at h
          · rename_i hout
            refine .inr (.inr ⟨hr, fun hw => by simpa [hw] using hwait,
              by simpa using hout, ?_⟩)
            split at h
            · exact ⟨_, rfl, h⟩
            · split at h <;> simp at h

/-- Exactly the added funding deferral: the ordinary predicate did not abort, the placement is
in the transaction, and the paused protection applies. In particular a funded machine never waits. -/
@[req "OPS-41"]
theorem derive_defers_iff (p : Params) (w : World) (r : Nat) :
    derive p w r = .defer ↔ p.abort w.m.commitment w.prot r = false ∧
      p.pausedGraceInFence = true ∧ pausedGrace p w = true := by
  unfold derive; (repeat' split) <;> simp_all

/-- A supplied claim at the bound proceeds regardless of unfinished rate-time or historical
enqueue reasons. This does not establish queue eligibility; see the module omissions. The original wall-clock end must have passed. The second
conjunct is the ordinary ordered re-check on the claimed world: no grace was carried there. -/
@[req "OPS-41"]
theorem bound_not_held_by_paused_grace (p : Params) (w : World) (a : Attempt) (t : Nat)
    (hph : w.phase = .idle) (ha : w.attempt = some a) (hq : a.row.status = .queued)
    (record : w.restore = some ⟨some t⟩) (wall : t ≤ w.now)
    (hr : w.rate = none) (bound : w.deadlinePassed = true)
    (hg : settledFirst w a = false) (hk : p.suspensionKey = .currentState)
    (hab : p.absentRecordProceeds = true) :
    (claimStep p w).phase = .holding ⟨a.row.claim.n + 1⟩ ∧
    recheck p w a none = .proceed none := by
  constructor
  · apply claim_after_grace p w a hph ha hq
    simp [claimGraceDefers, Claim.graceDefers, legacyPausedClaim, record, hr, show ¬ w.now < t by omega]
  · simp [recheck, hg, exempt, hk, hr, bound, hab]

/-- Current suspension also releases the composed claim at the original wall-clock end,
with any rate history or episode reasons. -/
@[req "OPS-41"]
theorem suspension_ignores_paused_grace (p : Params) (w : World) (a : Attempt) (t : Nat)
    (hph : w.phase = .idle) (ha : w.attempt = some a) (hq : a.row.status = .queued)
    (record : w.restore = some ⟨some t⟩) (wall : t ≤ w.now) (hs : w.suspended = true) :
    (claimStep p w).phase = .holding ⟨a.row.claim.n + 1⟩ := by
  apply claim_after_grace p w a hph ha hq
  simp [claimGraceDefers, Claim.graceDefers, legacyPausedClaim, record, hs, show ¬ w.now < t by omega]

/-- `OPS-41`'s first step: the worker "makes no provider call and settles the attempt `succeeded`
with a result recording that no mutation was required", and "**It writes no `runway_until`**".
Over every world: on a machine recorded gone, or under a closed episode, the fence transaction
writes no fence and carries no date, and the settlement that follows leaves the stored date what
it was. -/
@[req "OPS-41"]
theorem gone_or_closed_settles_without_a_date (p : Params) (hg : p.goneOrClosedFirst = true)
    (w : World) (n : ClaimNumber) (a : Attempt) (hph : w.phase = .holding n)
    (ha : w.attempt = some a) (h : settledFirst w a = true) (restored : Option Nat) :
    (fenceTxn p w restored).phase = .noMutation n none ∧
    (fenceTxn p w restored).m = w.m ∧
    (settle p (fenceTxn p w restored)).m.runwayUntil = w.m.runwayUntil := by
  have hre : recheck p w a restored = .noMutation none := by simp [recheck, hg, h]
  obtain ⟨hm, -, -, hatt, -⟩ := midTxn_frame w restored
  have hft := fenceTxn_abort p w n a restored none hph ha hre
  refine ⟨by rw [hft], by rw [hft]; simpa using hm, ?_⟩
  rw [hft]
  simp only [settle, hatt, ha]
  unfold finish applyRow
  (repeat' split) <;> simp_all

/-- While an outage is open its start is what history gave, and its deadline moves with the
setting alone: across every event of this model but the restart that loads another maximum, a
world with no rate keeps the start and the deadline it had. `LDG-64`: "With unchanged parameters
any writer computes the same instant". The model's events change no replay parameter and lose no
`STO-49` row — the module's omissions name both — so this is that sentence's case and says
nothing of the two that move the start. A second no-rate input — `rateLost` again, or another
thin `pass` — restarts nothing: it falls inside the one interval `STO-37` dates the start from,
"the earliest instant of each maximal interval throughout which the window yielded no rate".
What ends the outage is a rate, and the next loss is the next
outage's start: `LDG-64`'s "Each outage has its own start and so its own deadline". -/
@[req "LDG-64"]
theorem open_outage_keeps_its_start (p : Params) (w : World) (hr : w.rate = none) (e : Event)
    (he : ∀ b, e ≠ .setMaxOutage b) :
    (step p w e).outageStart = w.outageStart ∧ (step p w e).deadline = w.deadline := by
  have key : (step p w e).outageStart = w.outageStart ∧ (step p w e).maxOutage = w.maxOutage := by
    cases e with
    | advance seconds => simp [step]
    | rederive d obs => simp only [step]; unfold rederive; (repeat' split) <;> simp_all
    | pass window start =>
      simp only [step]; unfold pass rateRestored loseRate; (repeat' split) <;> simp_all
    | restoreRecord r => simp [step]
    | sweep => simp only [step]; unfold sweep enqueue applyRow; (repeat' split) <;> simp_all
    | claim => simp only [step]; unfold claimStep; (repeat' split) <;> simp_all
    | fenceTxn restored =>
      obtain ⟨-, -, -, -, -, -, h1, h2⟩ := midTxn_frame w restored
      simp only [step]; unfold fundingOrderTxn fenceTxn writeFence; (repeat' split) <;> simp_all
    | fenceWrite => simp only [step]; unfold fenceWrite writeFence; (repeat' split) <;> simp_all
    | extend s =>
      obtain ⟨-, -, -, -, -, -, -, -, -, -, -, -, h1, h2⟩ := extend_frame p w s
      exact ⟨h1, h2⟩
    | providerDelete a r => simp only [step]; unfold providerDelete; (repeat' split) <;> simp_all
    | settle =>
      simp only [step]; unfold settle writeAbortDate finish applyRow; (repeat' split) <;> simp_all
    | retry => simp only [step]; unfold retry; (repeat' split) <;> simp_all
    | goneWrite => simp only [step]; unfold goneWrite applyRow; (repeat' split) <;> simp_all
    | suspend => simp only [step]; unfold suspend enqueue; (repeat' split) <;> simp_all
    | resume => simp [step, resume]
    | rateLost start => simp [step, rateLost, loseRate, hr]
    | rateRestored r => simp [step, rateRestored]
    | meterOpens => simp only [step]; unfold meterOpens; (repeat' split) <;> simp_all
    | setMaxOutage b => exact absurd rfl (he b)
    | outageBound => simp only [step]; unfold outageBound enqueue; (repeat' split) <;> simp_all
  exact ⟨key.1, by simp [World.deadline, key.1, key.2]⟩

/-! ## Destruction only after a fence transaction whose re-check let it through -/

/-- The `destroyed` flag flips in one step only: a provider call that applied, from `fenced`. -/
@[req "OPS-41"]
theorem destroyed_only_by_provider_from_fenced (p : Params) (w : World) (e : Event)
    (h : (step p w e).m.destroyed = true) (hw : w.m.destroyed = false) :
    ∃ n reply, e = .providerDelete true reply ∧ w.phase = .fenced n := by
  cases e with
  | advance seconds => exfalso; simp [step, hw] at h
  | rederive d obs => exfalso; unfold step rederive at h; (repeat' split at h) <;> simp_all
  | pass window start =>
    exfalso; unfold step pass rateRestored loseRate at h; (repeat' split at h) <;> simp_all
  | restoreRecord r => exfalso; simp [step, hw] at h
  | providerDelete applied reply =>
    simp only [step] at h
    unfold providerDelete at h
    split at h
    · rename_i n hph
      split at h
      · simp [hw] at h
      · cases applied
        · simp [hw] at h
        · exact ⟨n, reply, rfl, hph⟩
    · simp [hw] at h
  | sweep => exfalso; unfold step sweep enqueue applyRow at h; (repeat' split at h) <;> simp_all
  | claim => exfalso; unfold step claimStep at h; (repeat' split at h) <;> simp_all
  | fenceTxn restored =>
    exfalso; obtain ⟨hm, -⟩ := midTxn_frame w restored
    unfold step fundingOrderTxn fenceTxn writeFence at h; (repeat' split at h) <;> simp_all
  | fenceWrite =>
    exfalso; unfold step fenceWrite writeFence at h; (repeat' split at h) <;> simp_all
  | extend s =>
    exfalso; obtain ⟨-, -, -, -, -, -, -, -, -, -, hd, -⟩ := extend_frame p w s
    rw [step, hd] at h; simp_all
  | settle =>
    exfalso; unfold step settle writeAbortDate finish applyRow at h
    (repeat' split at h) <;> simp_all
  | retry => exfalso; unfold step retry at h; (repeat' split at h) <;> simp_all
  | goneWrite => exfalso; unfold step goneWrite applyRow at h; (repeat' split at h) <;> simp_all
  | suspend => exfalso; unfold step suspend enqueue at h; (repeat' split at h) <;> simp_all
  | resume => exfalso; simp [step, resume] at h; simp_all
  | rateLost start =>
    exfalso; unfold step rateLost loseRate at h; (repeat' split at h) <;> simp_all
  | rateRestored r => exfalso; simp [step, rateRestored] at h; simp_all
  | meterOpens => exfalso; unfold step meterOpens at h; (repeat' split at h) <;> simp_all
  | setMaxOutage b => exfalso; simp [step, setMaxOutage] at h; simp_all
  | outageBound =>
    exfalso; unfold step outageBound enqueue at h; (repeat' split at h) <;> simp_all

/-- Under `current`'s one-transaction rule, `fenced` is entered by the fence transaction alone,
from `holding`, on a machine whose re-check let it through — `OPS-41`: "after claiming the machine
(`OPS-8`) and before any provider mutation, re-read that machine's commitment and its
`runway_until` — in the same serialized transaction that writes `OPS-42`'s fence" — and it leaves
the fence holding this attempt. The re-check is the transaction's own, on the world it ran in and
the restoration, if any, that committed behind its read: nothing of the claim enters. With
`destroyed_only_by_provider_from_fenced` and `recheck_proceeds`: destruction only after a fence
transaction whose re-check read the tenant suspended, or a rate at which the machine is unfunded,
or no rate with the deadline passed. -/
@[req "OPS-41"]
theorem fenced_only_by_fence_txn (p : Params) (hp : p.recheckInsideFence = true) (w : World)
    (e : Event) (n : ClaimNumber) (h : (step p w e).phase = .fenced n)
    (hw : w.phase ≠ .fenced n) :
    ∃ restored, e = .fenceTxn restored ∧ w.phase = .holding n ∧
    ∃ a, w.attempt = some a ∧ (∃ d, recheck p w a restored = .proceed d) ∧
      (step p w e).m.fence = some (p.holder a) := by
  cases e with
  | advance seconds => exfalso; exact hw (by simpa [step] using h)
  | rederive d obs => exfalso; unfold step rederive at h; (repeat' split at h) <;> simp_all
  | pass window start =>
    exfalso; unfold step pass rateRestored loseRate at h; (repeat' split at h) <;> simp_all
  | restoreRecord r => exfalso; exact hw (by simpa [step] using h)
  | fenceTxn restored =>
    obtain ⟨hm, -, hmph, -⟩ := midTxn_frame w restored
    simp only [step] at h ⊢
    have entry : fundingOrderTxn p w restored = fenceTxn p w restored := by
      rcases fundingOrderTxn_cases p w restored with entry | entry
      · exact entry
      · simp [entry.1] at h
    rw [entry] at h ⊢
    unfold fenceTxn at h ⊢
    split at h
    · rename_i n' a hph ha
      split at h
      · simp at h
      · simp at h
      · rename_i d hre
        simp only [hp, ↓reduceIte] at h ⊢
        unfold writeFence at h ⊢
        split at h
        · simp at h; subst h
          exact ⟨restored, rfl, hph, a, ha, ⟨d, hre⟩, by simp [*]⟩
        · simp at h
    · exact absurd h hw
  | sweep => exfalso; unfold step sweep enqueue applyRow at h; (repeat' split at h) <;> simp_all
  | claim => exfalso; unfold step claimStep at h; (repeat' split at h) <;> simp_all
  | fenceWrite =>
    exfalso; unfold step fenceWrite writeFence at h; (repeat' split at h) <;> simp_all
  | extend s => exfalso; rw [step, (extend_frame p w s).1] at h; exact hw h
  | providerDelete a r =>
    exfalso; unfold step providerDelete at h; (repeat' split at h) <;> simp_all
  | settle =>
    exfalso; unfold step settle writeAbortDate finish applyRow at h
    (repeat' split at h) <;> simp_all
  | retry => exfalso; unfold step retry at h; (repeat' split at h) <;> simp_all
  | goneWrite => exfalso; unfold step goneWrite applyRow at h; (repeat' split at h) <;> simp_all
  | suspend => exfalso; unfold step suspend enqueue at h; (repeat' split at h) <;> simp_all
  | resume => exfalso; simp [step, resume] at h; exact hw h
  | rateLost start =>
    exfalso; unfold step rateLost loseRate at h; (repeat' split at h) <;> simp_all
  | rateRestored r => exfalso; simp [step, rateRestored] at h; exact hw h
  | meterOpens => exfalso; unfold step meterOpens at h; (repeat' split at h) <;> simp_all
  | setMaxOutage b => exfalso; simp [step, setMaxOutage] at h; exact hw h
  | outageBound =>
    exfalso; unfold step outageBound enqueue at h; (repeat' split at h) <;> simp_all

theorem derive_proceeds (p : Params) (hab : p.abortPredicate = .date) (w : World) (r : Nat)
    (d : Option Nat) (h : derive p w r = .proceed d) :
    abortDate w.m.commitment w.prot r = false := by
  unfold derive at h
  split at h
  · simp at h
  · simpa [Params.abort, hab] using ‹¬p.abort w.m.commitment w.prot r = true›

/-- What a re-check that lets the cancellation through has read, under `current`'s keys (each a
hypothesis, so that a flipped key reddens its witness and not this theorem): the tenant suspended
now; or a rate at which the machine is unfunded — the transaction's own read, or, past the
deadline, the rate of a restoration the transaction saw ahead of its conditional write; or no
rate with the deadline passed and no restoration it saw. That last says nothing of a rate
returning at that instant unseen, which for a machine with no record `OPS-41` leaves unordered
and accepts. `OPS-41`: "Where there is no rate, the cancellation proceeds" is withdrawn, and with
it the reading that no rate alone lets a cancellation through.

Changed 2026-10-02. The no-rate disjunct gained the deadline. And it lost a conjunct: until
then it held `w.outageOpen = true` as well, and it no longer says anything of the record.
`OPS-41`'s fifth step forced that: "Where it affects no row and there is still no rate, the
machine carries no open record and the cancellation proceeds as well". A cancellation let
through at the bound has an open record or none. It also gained the hypothesis `hwait`,
`noRateWaits` on: with that rule off, no rate proceeds at any instant, deadline or not. -/
@[req "OPS-41"]
theorem recheck_proceeds (p : Params) (hk : p.suspensionKey = .currentState)
    (hab : p.abortPredicate = .date) (hout : p.outageWrite = true) (hwait : p.noRateWaits = true)
    (w : World) (a : Attempt) (restored : Option Nat) (d : Option Nat)
    (h : recheck p w a restored = .proceed d) :
    w.suspended = true ∨
    (∃ r, (w.rate = some r ∨ (w.rate = none ∧ w.deadlinePassed = true ∧ restored = some r)) ∧
      abortDate w.m.commitment w.prot r = false) ∨
    (w.rate = none ∧ w.deadlinePassed = true ∧ restored = none) := by
  unfold recheck at h
  split at h
  · simp at h
  · split at h
    · left; simpa [exempt, hk] using ‹exempt p w = true›
    · split at h
      · rename_i r hr
        exact .inr (.inl ⟨r, .inl hr, derive_proceeds p hab w r d h⟩)
      · rename_i hr
        split at h
        · simp at h
        · rename_i hdl
          have hdp : w.deadlinePassed = true := by simpa [hwait] using hdl
          simp only [hout, Bool.not_true, Bool.false_eq_true, ↓reduceIte] at h
          split at h
          · rename_i r
            exact .inr (.inl ⟨r, .inr ⟨hr, hdp, rfl⟩, derive_proceeds p hab (rateRestored w r) r d h⟩)
          · exact .inr (.inr ⟨hr, hdp, rfl⟩)

/-- Between the fence write and the provider call the machine row, the balance and the worker stay
put: with the fence set and the worker `fenced`, every event but the provider call, gone-write
and re-derivation leaves them as they are — the sweep enqueues nothing,
joining the open episode at most, the extension is refused, the settlement has nothing to settle,
a pass moves the rate and the restore record is written beside the row.
The gone-write is the one write that moves the fence under a fenced worker, by `ADR-0021`'s design, and `gone_clears_and_closes_together` says
what it does. Re-derivation is excluded from this whole-row frame: what `PRV-13e` says it
"recomputes is `runway_until`, not the commitment". It can change the date, but not the
cancellation fence. -/
@[req "OPS-42"]
theorem fenced_waits_for_the_provider (p : Params) (w : World) (n : ClaimNumber) (h : Holder)
    (hph : w.phase = .fenced n) (hf : w.m.fence = some h) (e : Event)
    (he : ∀ applied reply, e ≠ .providerDelete applied reply) (hg : e ≠ .goneWrite)
    (hr : ∀ date observation, e ≠ .rederive date observation) :
    (step p w e).m = w.m ∧ (step p w e).balance = w.balance ∧ (step p w e).phase = w.phase := by
  cases e with
  | advance seconds => simp [step]
  | rederive d obs => exact absurd rfl (hr d obs)
  | pass window start =>
    simp only [step]; unfold pass rateRestored loseRate; (repeat' split) <;> simp
  | restoreRecord r => simp [step]
  | providerDelete a r => exact absurd rfl (he a r)
  | goneWrite => exact absurd rfl hg
  | sweep => unfold step sweep enqueue applyRow; (repeat' split) <;> simp_all
  | claim => simp [step, claimStep, hph]
  | fenceTxn restored => simp [step, fundingOrderTxn, fenceTxn, hph]
  | fenceWrite => unfold step fenceWrite; (repeat' split) <;> simp_all
  | extend s => simp [step, extend, hf]
  | settle => simp [step, settle, hph]
  | retry => simp [step, retry, hph]
  | suspend => unfold step suspend enqueue; (repeat' split) <;> simp_all
  | resume => simp [step, resume]
  | rateLost start => simp only [step]; unfold rateLost loseRate; split <;> simp
  | rateRestored r => simp [step, rateRestored]
  | meterOpens => simp only [step]; unfold meterOpens; split <;> simp
  | setMaxOutage b => simp [step, setMaxOutage]
  | outageBound => unfold step outageBound enqueue; (repeat' split) <;> simp_all

/-! ## The episode: a set fence names it, a close is permanent -/

/-- The machine's open episode's id, where it has one. -/
def World.openEpisodeId (w : World) : Option EpisodeId :=
  match w.episode with
  | some ep => if ep.state.isOpen then some ep.id else none
  | none => none

/-- `OPS-42`'s fence is "`machines.destroy_committed` set to its episode's id" and `OPS-48` clears
it "exactly when the episode closes ... and by no other path" (`05-persistence.md`), so a set fence
names an open episode with the same id. Stated as a decidable predicate on a world. -/
def fenceNamesOpenEpisode (w : World) : Bool :=
  match w.m.fence with
  | none => true
  | some (.attempt _) => false
  | some (.episode e) => w.openEpisodeId == some e

/-- Every episode this world has minted has an id below the counter. -/
def idsFresh (w : World) : Bool :=
  w.episode.all fun ep => ep.id.n < w.nextId

/-- An initial world: no fence, no episode. -/
def Init (w : World) : Prop := w.m.fence = none ∧ w.episode = none

/-- Both invariants together, which is what one step has to preserve. -/
def Inv (w : World) : Prop := fenceNamesOpenEpisode w = true ∧ idsFresh w = true

/-- A world that differs only outside the fence, the episode and the counter keeps `Inv`. -/
theorem inv_same (w w' : World) (hf : w'.m.fence = w.m.fence) (he : w'.episode = w.episode)
    (hn : w'.nextId = w.nextId) (hw : Inv w) : Inv w' := by
  unfold Inv fenceNamesOpenEpisode World.openEpisodeId idsFresh at hw ⊢
  rw [hf, he, hn]; exact hw

theorem episodeStep_closed (r : CloseReason) (ev : Tables.Event) :
    episodeStep currentRows (.closed r) ev = (.closed r, false) :=
  closed_absorbing true true false r ev

theorem episodeStep_keeps_open (s : Episode) (ev : Tables.Event) (hs : s.isOpen = true)
    (hc : (episodeStep currentRows s ev).2 = false) :
    (episodeStep currentRows s ev).1.isOpen = true := by
  cases hno : (episodeStep currentRows s ev).1.isOpen with
  | true => rfl
  | false =>
    have h2 : (episodeStep currentRows s ev).2 = true :=
      (fence_cleared_iff_closes true true false s ev).mpr ⟨hs, hno⟩
    rw [hc] at h2
    exact absurd h2 Bool.false_ne_true

theorem fence_none_of_not_open (w : World) (hw : fenceNamesOpenEpisode w = true)
    (hnot : w.episodeOpen = false) : w.m.fence = none := by
  unfold fenceNamesOpenEpisode World.openEpisodeId at hw
  unfold World.episodeOpen at hnot
  split at hw
  · assumption
  · simp at hw
  · exfalso
    cases hE : w.episode <;> simp [hE] at hw hnot
    simp [hnot] at hw

theorem applyRow_inv (w : World) (ep : EpisodeRow) (ev : Tables.Event) (hep : w.episode = some ep)
    (hw : Inv w) : Inv (applyRow w ep ev) := by
  obtain ⟨hw, hi⟩ := hw
  constructor
  · unfold fenceNamesOpenEpisode World.openEpisodeId at hw ⊢
    simp only [applyRow, hep] at hw ⊢
    split at hw
    · rename_i hf; simp [hf]
    · simp at hw
    · rename_i e hf
      cases hc : (episodeStep currentRows ep.state ev).2
      · simp only [Bool.false_eq_true, ↓reduceIte, hf]
        split at hw
        · rename_i hopen
          simp [episodeStep_keeps_open ep.state ev hopen hc]
          simpa using hw
        · simp at hw
      · simp
  · unfold idsFresh at hi ⊢; simp only [applyRow, hep] at hi ⊢; simpa using hi

theorem applyRow_closed (w : World) (ep : EpisodeRow) (ev : Tables.Event) (r : CloseReason)
    (hc : ep.state = .closed r) : (applyRow w ep ev).episode = some ep := by
  cases ep with
  | mk id st rs => simp only at hc; subst hc; simp [applyRow, episodeStep_closed]

theorem enqueue_inv (w : World) (r : Reason) (hw : Inv w) : Inv (enqueue w r) := by
  obtain ⟨hw, hi⟩ := hw
  unfold enqueue
  split
  · constructor
    · unfold fenceNamesOpenEpisode World.openEpisodeId at hw ⊢
      cases hE : w.episode <;> simp [hE] at hw ⊢ <;> exact hw
    · unfold idsFresh at hi ⊢; cases hE : w.episode <;> simp [hE] at hi ⊢; exact hi
  · split
    · rename_i hnot _
      have := fence_none_of_not_open w hw (by simpa using hnot)
      exact ⟨by simp [fenceNamesOpenEpisode, this], by simp [idsFresh]⟩
    · exact ⟨hw, hi⟩

theorem enqueue_closed (w : World) (r : Reason) (hnot : w.episodeOpen = false) :
    (enqueue w r).episode = w.episode ∨
    (enqueue w r).episode = some { id := ⟨w.nextId⟩, state := .attempting, reasons := [r] } := by
  unfold enqueue
  simp only [hnot, Bool.false_eq_true, ↓reduceIte]
  split <;> simp

theorem writeFence_inv (p : Params) (hh : p.fenceHolds = .episodeId)
    (ho : p.fenceOnOpenEpisode = true) (w : World) (n : ClaimNumber) (a : Attempt)
    (d : Option Nat) (hw : Inv w) : Inv (writeFence p w n a d) := by
  unfold writeFence
  split
  · rename_i hadmit
    unfold fenceAdmits at hadmit
    simp only [ho, Bool.not_true, Bool.false_or, Bool.and_eq_true] at hadmit
    refine ⟨?_, (inv_same w _ rfl rfl rfl hw).2⟩
    unfold fenceNamesOpenEpisode World.openEpisodeId
    simp only [Params.holder, hh]
    cases hE : w.episode <;> simp_all
  · exact inv_same w _ rfl rfl rfl hw

theorem claimStep_frame (p : Params) (w : World) :
    (claimStep p w).m.fence = w.m.fence ∧ (claimStep p w).episode = w.episode ∧
    (claimStep p w).nextId = w.nextId := by
  unfold claimStep; (repeat' split) <;> simp

theorem providerDelete_frame (p : Params) (w : World) (applied : Bool) (reply : Option Bool) :
    (providerDelete p w applied reply).m.fence = w.m.fence ∧
    (providerDelete p w applied reply).episode = w.episode ∧
    (providerDelete p w applied reply).nextId = w.nextId := by
  unfold providerDelete; (repeat' split) <;> simp

theorem finish_inv (w : World) (n : ClaimNumber) (a : Attempt) (s : Settled) (wr : Written)
    (hw : Inv w) : Inv (finish w n a s wr) := by
  unfold finish
  split
  · rename_i ep hep
    split
    · exact applyRow_inv _ ep _ (by simpa using hep) (inv_same w _ rfl rfl rfl hw)
    · exact inv_same w _ rfl rfl rfl hw
  · exact inv_same w _ rfl rfl rfl hw

/-- One step preserves both invariants, under the two guards the first needs: the fence holds the
episode id (`fenceHolds`) and the write is guarded on that episode being open
(`fenceOnOpenEpisode`). -/
theorem inv_step (p : Params) (hh : p.fenceHolds = .episodeId) (ho : p.fenceOnOpenEpisode = true)
    (w : World) (hw : Inv w) (e : Event) : Inv (step p w e) := by
  cases e with
  | advance seconds => exact inv_same w _ rfl rfl rfl hw
  | rederive d obs =>
    simp only [step]; unfold rederive; (repeat' split) <;> exact inv_same w _ rfl rfl rfl hw
  | pass window start =>
    simp only [step]; unfold pass rateRestored loseRate
    (repeat' split) <;> first | exact hw | exact inv_same w _ rfl rfl rfl hw
  | restoreRecord r => exact inv_same w _ rfl rfl rfl hw
  | sweep =>
    simp only [step]; unfold sweep
    split
    · rename_i ep r hep hr
      split
      · exact applyRow_inv w ep _ hep hw
      · split
        · exact enqueue_inv w _ hw
        · exact hw
    · split
      · exact enqueue_inv w _ hw
      · exact hw
  | claim =>
    obtain ⟨h1, h2, h3⟩ := claimStep_frame p w
    exact inv_same w _ h1 h2 h3 hw
  | fenceTxn restored =>
    obtain ⟨hm, -, -, -, he, hn, -⟩ := midTxn_frame w restored
    have hmid : Inv (midTxn w restored) := inv_same w _ (by rw [hm]) he hn hw
    simp only [step]
    rcases fundingOrderTxn_cases p w restored with entry | entry
    · rw [entry]
      unfold fenceTxn
      split
      · split
        · exact inv_same _ _ rfl rfl rfl hmid
        · exact inv_same _ _ rfl rfl rfl hmid
        · split
          · exact writeFence_inv p hh ho _ _ _ _ hmid
          · exact inv_same _ _ rfl rfl rfl hmid
      · exact hw
    · exact inv_same w _ (by rw [entry.2.1]) entry.2.2.2.1 entry.2.2.2.2 hw
  | fenceWrite =>
    simp only [step]; unfold fenceWrite
    split
    · exact writeFence_inv p hh ho w _ _ _ hw
    · exact hw
  | extend s =>
    obtain ⟨-, -, -, -, -, hf, he, -, -, hn, -⟩ := extend_frame p w s
    exact inv_same w _ hf he hn hw
  | providerDelete a r =>
    obtain ⟨h1, h2, h3⟩ := providerDelete_frame p w a r
    exact inv_same w _ h1 h2 h3 hw
  | settle =>
    simp only [step]; unfold settle
    split
    · split
      · exact inv_same _ _ rfl rfl rfl (finish_inv w _ _ _ _ hw)
      · exact finish_inv w _ _ _ _ hw
    · exact finish_inv w _ _ _ _ hw
    · exact hw
  | retry =>
    simp only [step]; unfold retry
    split
    · rename_i a ep hph ha hep
      split
      · obtain ⟨hw, hi⟩ := hw
        constructor
        · unfold fenceNamesOpenEpisode World.openEpisodeId at hw ⊢
          simp only [hep] at hw ⊢
          split at hw <;> simp_all [episodeStep, Episode.isOpen]
        · unfold idsFresh at hi ⊢; simp only [hep] at hi ⊢; simp at hi ⊢; omega
      · exact hw
    · exact hw
  | goneWrite =>
    simp only [step]; unfold goneWrite
    split
    · rename_i ep hep
      exact applyRow_inv _ ep _ (by simpa using hep) (inv_same w _ rfl rfl rfl hw)
    · exact inv_same w _ rfl rfl rfl hw
  | suspend =>
    simp only [step]; unfold suspend
    exact enqueue_inv _ _ (inv_same w _ rfl rfl rfl hw)
  | resume => exact inv_same w _ rfl rfl rfl hw
  | rateLost start =>
    simp only [step]; unfold rateLost loseRate
    split <;> first | exact hw | exact inv_same w _ rfl rfl rfl hw
  | rateRestored r => exact inv_same w _ rfl rfl rfl hw
  | meterOpens =>
    simp only [step]; unfold meterOpens
    split <;> first | exact hw | exact inv_same w _ rfl rfl rfl hw
  | setMaxOutage b => exact inv_same w _ rfl rfl rfl hw
  | outageBound =>
    simp only [step]; unfold outageBound
    split
    · exact enqueue_inv w _ hw
    · exact hw

theorem inv_run (p : Params) (hh : p.fenceHolds = .episodeId) (ho : p.fenceOnOpenEpisode = true)
    (w : World) (hw : Inv w) (es : List Event) : Inv (run p w es) := by
  induction es generalizing w with
  | nil => exact hw
  | cons e es ih => exact ih (step p w e) (inv_step p hh ho w hw e)

theorem inv_init (w : World) (h0 : Init w) : Inv w :=
  ⟨by simp [fenceNamesOpenEpisode, h0.1], by simp [idsFresh, h0.2]⟩

/-- A set fence names an open episode with the same id, over every state reachable from an
initial world, under `OPS-42`'s two guards: `fenceHolds = .episodeId` (2026-09-08) and
`fenceOnOpenEpisode` (2026-09-09). Each guard's witness shows the invariant broken without it. -/
@[req "OPS-42"]
theorem fence_names_open_episode (p : Params) (hh : p.fenceHolds = .episodeId)
    (ho : p.fenceOnOpenEpisode = true) (w0 : World) (h0 : Init w0) (es : List Event) :
    fenceNamesOpenEpisode (run p w0 es) = true :=
  (inv_run p hh ho w0 (inv_init w0 h0) es).1

/-- One step on a closed episode: it is untouched, or superseded by a fresh one opened
`attempting` under the counter's next id. Nothing puts a closed episode back in an open state. -/
theorem closed_step (p : Params) (hg : p.retryGuard = true) (w : World) (ep : EpisodeRow)
    (hep : w.episode = some ep) (r : CloseReason) (hc : ep.state = .closed r) (e : Event) :
    (step p w e).episode = some ep ∨
    ∃ r', (step p w e).episode = some { id := ⟨w.nextId⟩, state := .attempting, reasons := [r'] } := by
  have hnot : w.episodeOpen = false := by simp [World.episodeOpen, hep, hc, Episode.isOpen]
  cases e with
  | advance seconds => left; exact hep
  | rederive d obs => left; simp only [step]; unfold rederive; (repeat' split) <;> exact hep
  | pass window start =>
    left; simp only [step]; unfold pass rateRestored loseRate; (repeat' split) <;> exact hep
  | restoreRecord r => left; exact hep
  | sweep =>
    simp only [step]; unfold sweep
    split
    · rename_i ep' r' hep' hr
      rw [hep] at hep'; obtain rfl := Option.some.inj hep'
      split
      · rename_i hst; simp [hc] at hst
      · split
        · rcases enqueue_closed w .exhausted hnot with h | h
          · left; rw [h, hep]
          · right; exact ⟨_, h⟩
        · left; exact hep
    · split
      · rcases enqueue_closed w .exhausted hnot with h | h
        · left; rw [h, hep]
        · right; exact ⟨_, h⟩
      · left; exact hep
  | claim => left; rw [step, (claimStep_frame p w).2.1]; exact hep
  | fenceTxn restored =>
    left; obtain ⟨-, -, -, -, he, -⟩ := midTxn_frame w restored
    simp only [step]; unfold fundingOrderTxn fenceTxn writeFence; (repeat' split) <;> simpa [he] using hep
  | fenceWrite =>
    left; simp only [step]; unfold fenceWrite writeFence; (repeat' split) <;> simpa using hep
  | extend s =>
    left; obtain ⟨-, -, -, -, -, -, he, -⟩ := extend_frame p w s
    rw [step, he]; exact hep
  | providerDelete a rp => left; rw [step, (providerDelete_frame p w a rp).2.1]; exact hep
  | settle =>
    left
    have hfin : ∀ n a s wr, (finish w n a s wr).episode = some ep := by
      intro n a s wr
      unfold finish
      split
      · rename_i ep' hep'
        rw [hep] at hep'; obtain rfl := Option.some.inj hep'
        split
        · exact applyRow_closed _ ep _ r hc
        · simpa using hep
      · simpa using hep
    simp only [step]; unfold settle
    split
    · split
      · unfold writeAbortDate; simpa using hfin _ _ _ _
      · exact hfin _ _ _ _
    · exact hfin _ _ _ _
    · exact hep
  | retry =>
    left; simp only [step]; unfold retry
    split
    · rename_i a ep' hph ha hep'
      rw [hep] at hep'; obtain rfl := Option.some.inj hep'
      split
      · rename_i hst; simp [hc, hg] at hst
      · exact hep
    · exact hep
  | goneWrite =>
    left; simp only [step]; unfold goneWrite
    split
    · rename_i ep' hep'
      rw [hep] at hep'; obtain rfl := Option.some.inj hep'
      exact applyRow_closed _ ep _ r hc
    · simpa using hep
  | suspend =>
    simp only [step]; unfold suspend
    rcases enqueue_closed { w with suspended := true } .tenantSuspended
        (by simpa [World.episodeOpen] using hnot) with h | h
    · left; rw [h]; exact hep
    · right; exact ⟨_, h⟩
  | resume => left; simpa [step, resume] using hep
  | rateLost start =>
    left; simp only [step]; unfold rateLost loseRate; split <;> exact hep
  | rateRestored r' => left; simpa [step, rateRestored] using hep
  | meterOpens => left; simp only [step]; unfold meterOpens; split <;> exact hep
  | setMaxOutage b => left; exact hep
  | outageBound =>
    simp only [step]; unfold outageBound
    split
    · rcases enqueue_closed w .rateOutageBound hnot with h | h
      · left; rw [h, hep]
      · right; exact ⟨_, h⟩
    · left; exact hep

/-- `ADR-0021`: "A close is permanent." Over every reachable state, an episode that is closed is
never changed under its id by any event: what carries that id afterwards is the same row. A
later episode is a fresh row under a fresh id, so a stale attempt settling under the old one
"changes the attempt and not the episode" (`OPS-48`). Needs `retryGuard`, the 2026-09-09
conditional write: a plain `retry` write reopens a closed episode (`retry_guard_witness`). -/
@[req "OPS-48"]
theorem closed_absorbing_in_lifecycle (p : Params) (hh : p.fenceHolds = .episodeId)
    (ho : p.fenceOnOpenEpisode = true) (hg : p.retryGuard = true) (w0 : World) (h0 : Init w0)
    (es : List Event)
    (ep : EpisodeRow) (hep : (run p w0 es).episode = some ep) (r : CloseReason)
    (hc : ep.state = .closed r) (e : Event) (ep' : EpisodeRow)
    (hep' : (step p (run p w0 es) e).episode = some ep') (hid : ep'.id = ep.id) : ep' = ep := by
  have hfresh := (inv_run p hh ho w0 (inv_init w0 h0) es).2
  rcases closed_step p hg _ ep hep r hc e with h | ⟨r', h⟩
  · rw [h] at hep'; exact (Option.some.inj hep').symm
  · rw [h] at hep'
    obtain rfl := Option.some.inj hep'
    simp only [idsFresh, hep, Option.all_some] at hfresh
    simp only at hid
    rw [← hid] at hfresh
    simp at hfresh

/-- A stale attempt — one whose episode is not the machine's — cannot take the fence: under the
open-episode term its write affects no row, and it aborts. -/
@[req "OPS-42"]
theorem stale_attempt_refused (p : Params) (ho : p.fenceOnOpenEpisode = true) (w : World)
    (a : Attempt) (ep : EpisodeRow) (hep : w.episode = some ep) (hne : ep.id ≠ a.ep) :
    fenceAdmits p w a = false := by
  simp [fenceAdmits, ho, hep, hne]

/-- Nor can its settlement touch the episode or the fence: `finish` writes `OPS-48`'s row on the
attempt's own episode, and where that is not the machine's, the row is not there to write. -/
@[req "OPS-48"]
theorem stale_attempt_settles_alone (w : World) (n : ClaimNumber) (a : Attempt) (s : Settled)
    (wr : Written) (ep : EpisodeRow) (hep : w.episode = some ep) (hne : ep.id ≠ a.ep) :
    (finish w n a s wr).episode = w.episode ∧ (finish w n a s wr).m.fence = w.m.fence := by
  simp [finish, hep, hne]

/-- `ADR-0021`: the gone-write "closes its open episode `resource_gone` and clears the fence, in
that transaction", from every open state, and records the machine gone. -/
@[req "OPS-48"]
theorem gone_clears_and_closes_together (w : World) (ep : EpisodeRow) (hep : w.episode = some ep)
    (hopen : ep.state.isOpen = true) :
    (goneWrite w).m.fence = none ∧
    (goneWrite w).episode = some { ep with state := .closed .resourceGone } ∧
    (goneWrite w).m.gone = true := by
  have := gone_closes_and_clears ep.state hopen
  simp [goneWrite, applyRow, hep, this]

/-- `OPS-48`: under the conditional write, `retry` is "admissible in no other state" than
`stalled` — on any other episode, or with no episode, it changes nothing. -/
@[req "OPS-48"]
theorem retry_only_from_stalled_in_lifecycle (p : Params) (hg : p.retryGuard = true) (w : World)
    (h : ∀ ep, w.episode = some ep → ep.state ≠ .stalled) : retry p w = w := by
  unfold retry
  split
  · rename_i a ep _ _ hep
    have := h ep hep
    simp [this, hg]
  · rfl

end Provisiond.Fence
