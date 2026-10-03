import Provisiond.Tables
/-! The decided policy spaces: `API-7`'s admission pipeline, `SEC-39`'s ceilings, `LDG-20`'s
solvency halt and `LDG-40`'s matrix against rate availability.

These are not lifecycle transitions. Each is a table whose cells a requirement decided one at a
time, and each has been wrong in the direction that costs the most: a pipeline whose "steps
contained no ceiling check at all, so a builder following the pipeline literally shipped none of
this"; a halt whose previous version "halted sales and left funding open"; and the sentence both
money requirements end on, `LDG-20`'s "The operations that *reduce* exposure MUST never be gated by
the check that fires because exposure is too high." Written as total functions over enumerated
keys, with no wildcard, so halting the action that reduces exposure is a red build rather than a
review finding.

Three models. The pipeline (`API-7`, `WIR-34`, `API-55`, `API-56`): principal, tenant state,
listener and verb decide one outcome and whether the request consumed a ceiling slot. The ceilings
(`SEC-39`): which budget each verb counts against, and the two properties that make a ceiling a
control rather than a field. The matrices (`LDG-20`, `LDG-40`, `LDG-59`, `LDG-64`, `LDG-65`): what
a solvency failure and a rate outage do to each action, over an action space that includes the
system activities no caller reaches.

What the model omits, beyond the parts of each requirement named below.

Reads. `API-7`'s "Steps 1–5 are common to every authenticated write", so `Verb` enumerates the
authenticated writes and nothing else; `API-58`'s retained reads for a suspended tenant and
`API-43`'s allowlisted reads are outside it, as are the unauthenticated routes — `API-40` is where
the pre-tenant ones are reconciled, and it says "`API-7`'s ordering applies to authenticated
endpoints".

Steps 1, 3, 4 and 5. Authentication resolves a `Principal` here and is not itself modelled, so
`API-7`'s headline — "**Authentication MUST happen before request-body validation.**" — is the
shape of this function rather than a theorem in it: no cell reads a body. Step 3's key validation,
step 4's authorization of "the target resource by **existence** rather than by ownership for an
operator", and step 5's deserialization all decide on a resource this model does not carry. Step 5a
is one Boolean, `replay`: "an equal fingerprint under the same `(principal, key)` returns the
stored result", and what that stored result was is outside.

The tail. `API-7`'s per-class tail is where the halt and the rate gates are applied, and the two
matrices below are those gates; the commitment, the enqueue and the `202` belong to
`Provisiond.Fence` and `Provisiond.Ledger`. The create row's earlier refusal — "refuse
`conflict`/`state` where the named provider account is not `healthy`" — turns on a
provider-account row this model has none of.

The listener. `API-27` obliges a deployment to "expose *only* the customer-facing routes publicly,
keeping operator and reconciliation routes on a separate listener or network", which is a property
of a deployment's topology. What is modelled is `WIR-34`'s per-request half, and only for the
routes it names: a customer route's outcome does not key on the listener, which
`customer_routes_do_not_key_on_the_listener` states rather than hides.

The tenant override. `API-5`: "An admin token MAY act for another tenant by sending that header",
so an operator principal reaches a customer route naming a tenant; `Request.tenant` is that named
tenant, which is `API-7`'s "**whose** tenant steps 2 and 5b read". The non-admin operator token,
the header's validation (`API-6`) and its being "ignored, not rejected" for a customer token are
outside.

The counters. `SEC-39`'s ceilings are per principal and per interval; `atCeiling` is the answer a
counter gave, and the counter, the interval and `WIR-9a`'s `retry_after_ms` are not modelled.
`Outcome.slotSpent` is whether this request consumed one unit of that budget, which is all the
replay rule needs.

`LDG-20`'s "halt top-ups first" orders two responses in time; this is a matrix, so what it
carries is that minting is refused and crediting is not. The stress set itself — "the
provider-currency pair adverse by 15%, an inaccessible venue for seven days" — is the input to
`solvencyHalt`, not a term here. `LDG-58`'s median, `LDG-59`'s quorum and `LDG-60`'s exclusions are
the construction behind "no rate"; only its per-currency scope appears, in `rateAvailableFor`.

The re-derivation row carries the halt and not its second clause: "the halt MUST NOT itself trigger
exhaustion" is about re-derivation and the sweep predicate, carried by `Provisiond.Fence`'s
`rederive` (the no-observation branch writes nothing) and `World.routed` (the stored date, and a
rate for the machine's currency); a second copy here would be a second normative home for one
rule. The same holds of the outage's clock: `OPS-41`'s order turns on `LDG-64`'s deadline, which
`Provisiond.Fence` carries; this matrix answers for the outage before that deadline, and
`RateAnswer.atTheBound` for the one answer the deadline changes. The order's first step is
`Provisiond.Fence`'s as well: this model has no machine to record gone and no episode to close, so
a system cancellation's row answers for an attempt that step does not settle.

`Guards` carries the rules a dated amendment added or withdrew, one field each, and `current` is
the set as it stands. Each has the pair the epic requires: the bad trace refused with the guard and
admitted without it, in `Provisiond.Witnesses`. -/

namespace Provisiond.Admission
open Provisiond.Tables

/-! ## The keys -/

/-- `API-5`: "Each token maps to exactly one **principal** and an admin flag." A customer token's
principal "is exactly one tenant"; "**the operator token's principal is the operator, which is no
tenant at all**"; and the recovery credential authenticates one route (`WIR-38`), which is
authenticated "never by the spending token". -/
inductive Principal
  | customer | recovery | operator
  deriving DecidableEq, Repr

def Principal.all : List Principal := [.customer, .recovery, .operator]

theorem Principal.mem_all (p : Principal) : p ∈ Principal.all := by cases p <;> decide

instance {q : Principal → Prop} [DecidablePred q] : Decidable (∀ p, q p) :=
  Tables.decidableForallOfList Principal.all Principal.mem_all q

/-- The `tenants` row's status enum (`05-persistence.md`), which `WIR-13` reports as
`{"status": "pending" | "active" | "suspended"}`. Which tenant it is, is `API-7`'s question:
"steps 2 and 5b test a TENANT, and an operator principal has none of its own". -/
inductive TenantState
  | pending | active | suspended
  deriving DecidableEq, Repr

def TenantState.all : List TenantState := [.pending, .active, .suspended]

theorem TenantState.mem_all (t : TenantState) : t ∈ TenantState.all := by cases t <;> decide

instance {q : TenantState → Prop} [DecidablePred q] : Decidable (∀ t, q t) :=
  Tables.decidableForallOfList TenantState.all TenantState.mem_all q

/-- `API-27`'s two: the public surface, and the "separate listener or network" the operator and
reconciliation routes are kept on. -/
inductive Listener
  | customer | operator
  deriving DecidableEq, Repr

instance {q : Listener → Prop} [DecidablePred q] : Decidable (∀ l, q l) :=
  Tables.decidableForallOfList [.customer, .operator] (by intro l; cases l <;> decide) q

/-- The authenticated writes of `API-7`'s tail table, one constructor each. The first ten are the
tenant's own; `revoke` is `WIR-38`'s recovery route; the rest are `WIR-34`'s operator-only list,
whose abuse verbs are the operator's five — "opening, closing, transmitting, revising a deadline
and recording a restriction". `attributeDeposit` is `WIR-42`'s attribute, spelled out because
`attribute` is a Lean keyword. -/
inductive Verb
  | create | power | install | reverseDns | refresh | rescueInventory | deleteMachine
  | deposit | extendRunway | abuseStatement
  | revoke
  | retry | suspend | resume | resolve | attributeDeposit | releaseAttachment
  | assignProviderAccount | recordStatus | recordNetworkRestriction | reviseDeadline
  | abuseOpen | abuseClose | abuseRecordTransmission
  deriving DecidableEq, Repr

def Verb.all : List Verb :=
  [.create, .power, .install, .reverseDns, .refresh, .rescueInventory, .deleteMachine,
   .deposit, .extendRunway, .abuseStatement,
   .revoke,
   .retry, .suspend, .resume, .resolve, .attributeDeposit, .releaseAttachment,
   .assignProviderAccount, .recordStatus, .recordNetworkRestriction, .reviseDeadline,
   .abuseOpen, .abuseClose, .abuseRecordTransmission]

theorem Verb.mem_all (v : Verb) : v ∈ Verb.all := by cases v <;> decide

instance {q : Verb → Prop} [DecidablePred q] : Decidable (∀ v, q v) :=
  Tables.decidableForallOfList Verb.all Verb.mem_all q

/-! ## `WIR-34`, `API-55` and `API-56`: which listener serves a verb, and which credential reaches
it -/

/-- `WIR-34`'s list — resolve, suspend, resume, attribute, the abuse-case verbs,
address-resolution, record-network-restriction and revise-deadline, assign-provider-account,
record-status, the episode routes and the attachment routes — "MUST be served only on the operator
listener (`API-27`)". Everything else is the customer surface, `revoke` included: `WIR-38` is not
in that list, which "is read as closed". No wildcard, so a verb added without a listener is a
missing case. -/
@[req "WIR-34"]
def Verb.listener : Verb → Listener
  | .create | .power | .install | .reverseDns | .refresh | .rescueInventory | .deleteMachine
  | .deposit | .extendRunway | .abuseStatement | .revoke => .customer
  | .retry | .suspend | .resume | .resolve | .attributeDeposit | .releaseAttachment
  | .assignProviderAccount | .recordStatus | .recordNetworkRestriction | .reviseDeadline
  | .abuseOpen | .abuseClose | .abuseRecordTransmission => .operator

/-- Step 1, and only the credential's half of it: does this secret authenticate *this route*?

`API-55` makes the recovery credential's confinement a server-side rule — "the recovery credential
authenticates the revocation route and nothing else" — and says what a misplaced one gets: "A
request presenting it anywhere else — a create, an install, a delete, a read — MUST be rejected as
unauthenticated, exactly as an unknown secret would be". `WIR-38` is the mirror: that route is authenticated "by the **recovery
credential**, never by the spending token", which `API-56` reaches from the other side — "the
spending token MUST NOT be able to do either".

That refusal runs before `WIR-34`'s `404` and discloses nothing it protects, because it is the same
answer on every route in the set, customer and operator alike.

The operator arm does not read the verb: `API-5` says "the operator token's principal is the
operator", a credential the deployment supplies, and nothing makes its authentication depend on
which route it is presented to. What it may *reach* is the next question, and that one is decided
per route. -/
@[req "API-55"]
def authenticates : Principal → Verb → Bool
  | .recovery, v => v == .revoke
  | .customer, v => v != .revoke
  | .operator, _ => true

/-! ## `SEC-39`'s ceilings -/

/-- The budgets `SEC-39` names: "machines destroyed per interval, machines created per interval,
images written per interval, **rescue entries per interval** and **power cycles per interval**,
plus a spend ceiling where the deployment prices its own resources", and for an operator principal
"retries (`API-64`), resolutions, suspensions, provider-account re-assignments **and
provider-account status recordings**". Whether a deployment prices its own resources is a
deployment fact and not a key here, so the `spend` rows below name the budget rather than assert it
is configured. -/
inductive Ceiling
  | machinesDestroyed | machinesCreated | imagesWritten | rescueEntries | powerCycles | spend
  | retries | resolutions | suspensions | reassignments | statusRecordings
  deriving DecidableEq, Repr

/-- Which budgets a verb counts against, as a total function with no wildcard. The two verbs that
move balance carry `spend`, "where the deployment prices its own resources".

`entersRescue` is the install's own fact, because the rescue ceiling is not keyed on the operation:
"The ceiling is on *rescue entries* rather than on the operation, so it covers the inventory pass
and every rescue-entering install together — the two ways a machine gets rebooted into another
operating system." `RSC-19`'s strategies divide there — an install "whose strategy enters no rescue
— `provider_native` and `provider_catalogue`" reboots nothing into anything, and charging it a
rescue entry would spend a budget on a machine that never left its own operating system.

An empty row is a verb this set states no ceiling for, which is not the same as a verb that may
never have one: `SEC-39` states its two lists "at minimum", so a deployment may count more than
this table names. -/
@[req "SEC-39"]
def Verb.ceilings (entersRescue : Bool) : Verb → List Ceiling
  | .create => [.machinesCreated, .spend]
  | .deleteMachine => [.machinesDestroyed]
  | .install => if entersRescue then [.imagesWritten, .rescueEntries] else [.imagesWritten]
  | .rescueInventory => [.rescueEntries]
  | .power => [.powerCycles]
  | .extendRunway => [.spend]
  | .retry => [.retries]
  | .resolve => [.resolutions]
  | .suspend => [.suspensions]
  | .assignProviderAccount => [.reassignments]
  | .recordStatus => [.statusRecordings]
  | .reverseDns | .refresh | .deposit | .abuseStatement | .revoke | .resume | .attributeDeposit
  | .releaseAttachment | .recordNetworkRestriction | .reviseDeadline | .abuseOpen | .abuseClose
  | .abuseRecordTransmission => []

/-- Whether this verb is counted at all. Read at the strategy that charges least, since a verb
counted only when it enters rescue is still a counted verb. -/
def Verb.counted (v : Verb) : Bool := !(v.ceilings false).isEmpty

/-- `SEC-39`: "**a ceiling is something the caller cannot set for itself.** Any control the caller
supplies in its own request is advisory." The deployment's stated integer is the limit whatever the
request carries; `a_caller_cannot_set_its_own_ceiling` is that, and the caller's number is the
argument it discards. -/
@[req "SEC-39"]
def effectiveLimit (deployment : Nat) (_callerSupplied : Option Nat) : Nat := deployment

/-- The one thing that lifts a limit: "a stated override path for a genuine incident", recorded as
"the uncapped thing". `none` is uncapped. -/
@[req "SEC-39"]
def limitUnder (override : Bool) (deployment : Nat) : Option Nat :=
  if override then none else some deployment

/-! ## `API-7`'s pipeline -/

/-- The rules `API-7` gained or lost by dated amendment, one field each.

`listenerSplit` (`WIR-34`): an operator route answers `404` to a customer-authenticated request.
`operatorSkipsTenantSteps` (2026-09-04): "**Every operator verb skips 2 and 5b**, whether or not it
names a tenant." `stepTwoReadsSuspension`: the withdrawn wording, "reject unless the tenant is
active", which "made 5b unreachable and defeated its stated reason for existing".
`maintenanceCarveOut`: step 2's "revoke (`API-56`), resolve and resume are authorized by
principal rather than by tenant state". `statementWhileSuspended` (2026-08-16): "**The
abuse-statement write (`WIR-43`) is a maintenance action and MUST remain reachable while
suspended**". `ceilingStep` (2026-09-02): step
5c exists. `replayBeforePolicy`: 5b and 5c sit after 5a, which `API-7` states once for both — 5c
"sits **after** 5a and 5b for the same reasons those sit where they do".

`sweepRoutesNothingWithoutRate` (`LDG-40`, 2026-10-02, `ADR-0029`): the sweep's row of the rate
matrix, "**the exhaustion sweep** (MUST route no machine priced in that currency: `LDG-16` holds
the predicate, and a funding cancellation already queued waits as `OPS-41` orders)". Its off
position is the row `LDG-40`'s note of that day withdrew, "**the exhaustion sweep** (MUST
continue: it reduces exposure)", of which the note has: "Continuing cancelled machines whose
stored date passed during the outage". -/
structure Guards where
  listenerSplit            : Bool
  operatorSkipsTenantSteps : Bool
  stepTwoReadsSuspension   : Bool
  maintenanceCarveOut      : Bool
  statementWhileSuspended  : Bool
  ceilingStep              : Bool
  replayBeforePolicy       : Bool
  haltMintsOnly            : Bool
  cancelUnsettledInvoices  : Bool
  exposureExemptUnderHalt  : Bool
  sweepRoutesNothingWithoutRate : Bool
  deriving DecidableEq, Repr

/-- The pipeline and the two matrices as they stand. `stepTwoReadsSuspension` is the withdrawn
reading and is the one field that is off. -/
@[req "API-7"]
def current : Guards := {
    listenerSplit            := true,
    operatorSkipsTenantSteps := true,
    stepTwoReadsSuspension   := false,
    maintenanceCarveOut      := true,
    statementWhileSuspended  := true,
    ceilingStep              := true,
    replayBeforePolicy       := true,
    haltMintsOnly            := true,
    cancelUnsettledInvoices  := true,
    exposureExemptUnderHalt  := true,
    sweepRoutesNothingWithoutRate := true }

/-- One authenticated write as the pipeline reads it. `tenant` is the tenant steps 2 and 5b test —
the principal's own, or the one an operator names. `admin` is `API-5`'s flag: "Each token maps to
exactly one **principal** and an admin flag", and it is what decides whether the override header is
honoured. `replay` is step 5a's equal fingerprint under the same `(principal, key)`; `atCeiling` is
the answer `SEC-39`'s counter gives at 5c and `override` whether its "stated override path for a
genuine incident" is in force; `acknowledged` is `API-14`'s destructive acknowledgement, which the
pipeline never reads. -/
structure Request where
  principal    : Principal
  listener     : Listener
  verb         : Verb
  tenant       : TenantState
  admin        : Bool
  replay       : Bool
  atCeiling    : Bool
  override     : Bool
  acknowledged : Bool
  deriving DecidableEq, Repr

/-- What the pipeline answers. `replayed` is 5a's "returns the stored result", which is neither an
admission nor a refusal: the tail does not run again. A refusal carries a `DOM-17` kind, since
`API-24` says "`kind` MUST come from the closed set in `DOM-17`" and "Handlers MUST NOT choose
statuses independently." -/
inductive Verdict
  | admitted
  | replayed
  | refused (kind : ErrorKind)
  deriving DecidableEq, Repr

/-- The answer, and whether this request consumed one unit of `SEC-39`'s budget. -/
structure Outcome where
  verdict   : Verdict
  slotSpent : Bool
  deriving DecidableEq, Repr

/-- `WIR-34`: an operator route "MUST return `404` — never `authentication` — to a
customer-authenticated request, so their existence is not customer-observable", and it is served on
the operator listener only. The recovery credential never reaches this step: `API-55` has already
refused it as unauthenticated anywhere but its own route. -/
@[req "WIR-34"]
def hidden (g : Guards) (r : Request) : Bool :=
  g.listenerSplit && r.verb.listener == Listener.operator &&
    (r.listener == Listener.customer || r.principal != Principal.operator)

/-- `API-7`'s carve-out is per verb, not per principal: "**Every operator verb skips 2 and 5b**,
whether or not it names a tenant", because "The carve-out is about the principal having no tenant
**of its own**, and nothing more." -/
@[req "API-7"]
def skipsTenantSteps (g : Guards) (v : Verb) : Bool :=
  g.operatorSkipsTenantSteps && v.listener == Listener.operator

/-- Step 2's maintenance actions: "revoke (`API-56`), resolve and resume are authorized by
principal rather than by tenant state, and gating them on an activated tenant would leave a
suspended or pending tenant unable to replace a stolen credential — locking the owner out at
exactly the moment the mechanism exists for." -/
@[req "API-7"]
def Verb.maintenance : Verb → Bool
  | .revoke | .resolve | .resume => true
  | .create | .power | .install | .reverseDns | .refresh | .rescueInventory | .deleteMachine
  | .deposit | .extendRunway | .abuseStatement | .retry | .suspend | .attributeDeposit
  | .releaseAttachment | .assignProviderAccount | .recordStatus | .recordNetworkRestriction
  | .reviseDeadline | .abuseOpen | .abuseClose | .abuseRecordTransmission => false

/-- `API-43`'s pending allowlist, restricted to the writes: "**`POST /v1/deposits`** — mint a
funding destination" and "**`POST /v1/recovery/revoke`** (`API-56`)", amended 2026-09-02 to read
"unconditionally, with the `issuable_at` qualifier withdrawn". Its two reads are outside this
model. -/
@[req "API-43"]
def Verb.pendingAllowed : Verb → Bool
  | .deposit | .revoke => true
  | .create | .power | .install | .reverseDns | .refresh | .rescueInventory | .deleteMachine
  | .extendRunway | .abuseStatement | .retry | .suspend | .resume | .resolve | .attributeDeposit
  | .releaseAttachment | .assignProviderAccount | .recordStatus | .recordNetworkRestriction
  | .reviseDeadline | .abuseOpen | .abuseClose | .abuseRecordTransmission => false

/-- Step 2: "**reject a tenant that has never been activated** — a `pending` tenant fails
`not_activated` (`API-35`), **except** the `API-43` allowlist and the **maintenance actions**".
"**This step is the issuance check and nothing else: it MUST NOT look at suspension.**" and "A
`suspended` tenant passes it and is rejected at 5b instead" — which is why the suspension arm is
the withdrawn reading under its own parameter. -/
@[req "API-7"]
def stepTwo (g : Guards) (r : Request) : Option ErrorKind :=
  if skipsTenantSteps g r.verb || (g.maintenanceCarveOut && r.verb.maintenance) then none
  else if r.tenant == TenantState.pending && !r.verb.pendingAllowed then some .notActivated
  else if g.stepTwoReadsSuspension && r.tenant == TenantState.suspended then some .suspended
  else none

/-- Step 5b: "**reject with `suspended`** if the tenant is suspended and this is not a maintenance
action (`API-58`, `DOM-20`). **This is the only step that rejects for suspension**". The
abuse-statement write is one of those actions from 2026-08-16, under its own parameter: without it
"the operator's escalation for silence is what guarantees the silence". -/
@[req "API-7"]
def stepFiveB (g : Guards) (r : Request) : Option ErrorKind :=
  if skipsTenantSteps g r.verb then none
  else if r.tenant == TenantState.suspended &&
      !(g.maintenanceCarveOut && r.verb.maintenance) &&
      !(g.statementWhileSuspended && r.verb == Verb.abuseStatement) then some .suspended
  else none

/-- Step 5c: "**enforce `SEC-39`'s per-principal ceilings** and reject `ceiling_exceeded`
(`DOM-17`)". Added 2026-09-02, because "**no step of this pipeline checked it**" — "so a
builder following these steps literally shipped no ceilings at all while the requirement and its
test both existed".

`API-7` then closes the list: "**The exemptions are these, and no others.**" `OPS-39`'s is the
system cancellation, which "enqueues directly and never traverses this pipeline" and is no `Verb`
here at all, so "the exemption bites here only on the other one: `SEC-39`'s stated override path
for a genuine incident is the operator's, recorded as the uncapped thing" — `limitUnder` is where
that is uncapped, and this is the step that reads it. -/
@[req "API-7"]
def stepFiveC (g : Guards) (r : Request) : Option ErrorKind :=
  if g.ceilingStep && !r.override && r.verb.counted && r.atCeiling then some .ceilingExceeded
  else none

/-- The surface itself, under the disclosure rule rather than in front of it. `WIR-34`'s routes are
"**Operator-only routes**", so no tenant-side credential is authorized for one; the refusal is
`authentication`, which is precisely the answer that requirement then forbids being *returned* —
"MUST return `404` — never `authentication`". `hidden` is what stands in front of this, and the
pair is why the disclosure rule is a parameter: with it off, this is the answer the caller sees. -/
@[req "WIR-34"]
def authorized (p : Principal) (v : Verb) : Bool :=
  v.listener == Listener.customer || p == Principal.operator

/-- `API-5`'s override, which is the only way a principal with "no tenant at all" acts on a customer
route: "An admin token MAY act for another tenant by sending that header (`WIR-33`); a non-admin
token MUST NOT, and the header MUST be ignored rather than honoured for it." -/
@[req "API-5"]
def namesATenant (r : Request) : Bool :=
  r.principal != Principal.operator || r.verb.listener == Listener.operator || r.admin

/-- `API-7`'s pipeline over the four keys. The order is the requirement's: step 1's credential
(`API-55`), then the route's visibility (`WIR-34`), then step 2, then 5a, then 5b, then 5c. A
request that reaches 5c and is not refused there consumes one unit of its budget; under
`replayBeforePolicy` a replay never reaches it, which is 5c's stated reason for sitting where it
does — "a replay must return its stored result rather than spend a slot it already spent, and a
suspended tenant is refused before its budget is consulted".

`none` is the one cell this set does not decide, and it is written rather than guessed, the way
`Provisiond.Tables.classify` writes `OPS-11`'s parent row: a non-admin operator token on a customer
route. `API-5` says of that token only that the override header "MUST be ignored rather than
honoured for it", which leaves a request naming no tenant at all while steps 2 and 5b are the steps
that "test a TENANT". `the_one_undecided_cell` enumerates it, so the silence is a theorem rather
than a default. -/
@[req "API-7"]
def admit (g : Guards) (r : Request) : Option Outcome :=
  if !authenticates r.principal r.verb then
    some { verdict := .refused .authentication, slotSpent := false }
  else if hidden g r then some { verdict := .refused .notFound, slotSpent := false }
  else if !authorized r.principal r.verb then
    some { verdict := .refused .authentication, slotSpent := false }
  else if !namesATenant r then none
  else
    match stepTwo g r with
    | some k => some { verdict := .refused k, slotSpent := false }
    | none =>
      if g.replayBeforePolicy && r.replay then
        some { verdict := .replayed, slotSpent := false }
      else
        match stepFiveB g r with
        | some k => some { verdict := .refused k, slotSpent := false }
        | none =>
          match stepFiveC g r with
          | some k => some { verdict := .refused k, slotSpent := false }
          | none =>
            some { verdict := if r.replay then .replayed else .admitted,
                   slotSpent := g.ceilingStep && r.verb.counted }

/-! ## `LDG-20`'s halt and `LDG-40`'s rate matrix -/

/-- What the two matrices decide about, which is more than the callable verbs: the exhaustion
sweep's cancellation is enqueued by a sweep and "never traverses this pipeline" (`API-7`,
`OPS-39`), and the re-derivation, the solvency check and the meter have no caller at all.

The system's cancellations are kept apart by the condition that queued them, which is the
glossary's distinction (`CONTEXT.md`, **Funding cancellation**): a funding cancellation is "An
exposure-reducing cancellation whose condition is that the machine may be unfunded: its runway's
exhaustion, or a late-attach cleanup", and "The outage bound's cancellation and a suspended
tenant's are exposure-reducing but are not funding cancellations". That condition is what the
attempt was enqueued under, and no cell of either matrix reads it: what the worker does with a
claimed cancellation is `OPS-41`'s order, which "holds for every exposure-reducing cancellation,
whatever reason the attempt was enqueued under". They are separate constructors so that
`the_enqueue_reason_decides_nothing_without_a_rate` is a statement that can fail, and not a
property of a type with one inhabitant. -/
inductive Action
  | caller (v : Verb)
  | fundingCancellation
  | suspensionCancellation
  | boundCancellation
  | rederivation
  | exhaustionSweep
  | solvencyCheck
  | metering
  deriving DecidableEq, Repr

def Action.all : List Action :=
  Verb.all.map Action.caller ++
    [.fundingCancellation, .suspensionCancellation, .boundCancellation, .rederivation,
     .exhaustionSweep, .solvencyCheck, .metering]

theorem Action.mem_all (a : Action) : a ∈ Action.all := by
  cases a with
  | caller v => cases v <;> decide
  | _ => decide

instance {q : Action → Prop} [DecidablePred q] : Decidable (∀ a, q a) :=
  Tables.decidableForallOfList Action.all Action.mem_all q

/-- The system's own cancellations, `OPS-39`'s "Exposure-reducing system cancellations": the
actions a worker claims and decides by `OPS-41`'s order. The exhaustion sweep is not one — it
enqueues a cancellation and is not itself claimed. No wildcard. -/
@[req "OPS-39"]
def Action.systemCancellation : Action → Bool
  | .fundingCancellation | .suspensionCancellation | .boundCancellation => true
  | .caller _ | .rederivation | .exhaustionSweep | .solvencyCheck | .metering => false

/-- `LDG-20`: the operations that "*reduce* exposure". `API-7`'s tail names them one at a time —
delete and cancel "**bypass the rate and solvency gates entirely** — these reduce exposure"; the
release "**no commitment and no spending gate** — it reduces exposure, on the delete row's
reasoning"; the retry the same, "the attempt reduces exposure, on the delete row's reasoning". The
system's own cancellations are `OPS-39`'s "Exposure-reducing system cancellations", each of
them, and the exhaustion sweep is what enqueues the first. `LDG-40`'s row for the sweep said as
much of it until 2026-10-02; what `ADR-0029` withdrew is that it continues with no rate
(`underNoRate`), not which way it moves exposure.

Suspend is not one of them, though it is the largest reduction any verb causes: `API-58` has it
"enqueues a system cancellation per machine (`OPS-39`)", so the reduction is those cancellations'
row and not the parent's. It is not bill-increasing either, so the halt permits it regardless.

No wildcard: an action added without an exposure direction is a missing case. -/
@[req "LDG-20"]
def Action.reducesExposure : Action → Bool
  | .fundingCancellation | .suspensionCancellation | .boundCancellation | .exhaustionSweep => true
  | .caller v =>
    match v with
    | .deleteMachine | .releaseAttachment | .retry => true
    | .create | .power | .install | .reverseDns | .refresh | .rescueInventory | .deposit
    | .extendRunway | .abuseStatement | .revoke | .suspend | .resume | .resolve
    | .attributeDeposit | .assignProviderAccount | .recordStatus | .recordNetworkRestriction
    | .reviseDeadline | .abuseOpen | .abuseClose | .abuseRecordTransmission => false
  | .rederivation | .solvencyCheck | .metering => false

/-- `LDG-20`: the "bill-increasing" operations. `LDG-9`'s create is one — the spending authority
check "is the only authorization a create receives" — and `LDG-62`'s extension is the other:
"Extending runway is a caller write, authorized like a purchase." Everything else on the customer
surface is not: `API-7`'s tail says of power, install, reverse-DNS, refresh and rescue inventory
that they carry "**No commitment**: they are not purchases, and they pass no spending gate". -/
@[req "LDG-20"]
def Action.billIncreasing : Action → Bool
  | .caller v =>
    match v with
    | .create | .extendRunway => true
    | .power | .install | .reverseDns | .refresh | .rescueInventory | .deleteMachine | .deposit
    | .abuseStatement | .revoke | .retry | .suspend | .resume | .resolve | .attributeDeposit
    | .releaseAttachment | .assignProviderAccount | .recordStatus | .recordNetworkRestriction
    | .reviseDeadline | .abuseOpen | .abuseClose | .abuseRecordTransmission => false
  | .fundingCancellation | .suspensionCancellation | .boundCancellation | .rederivation
  | .exhaustionSweep | .solvencyCheck | .metering => false

/-- The top-up, which is `LDG-20`'s first clause and `API-7`'s deposit row: a deposit "**mints a
destination and writes NO ledger entry**", and it is "**refused `halted` while `LDG-20`'s solvency
halt is in force**" — "that halt stops top-ups *first*, and minting a destination invites exactly
the payment it forbids". -/
@[req "LDG-20"]
def Action.mintsDestination : Action → Bool
  | .caller v =>
    match v with
    | .deposit => true
    | .create | .power | .install | .reverseDns | .refresh | .rescueInventory | .deleteMachine
    | .extendRunway | .abuseStatement | .revoke | .retry | .suspend | .resume | .resolve
    | .attributeDeposit | .releaseAttachment | .assignProviderAccount | .recordStatus
    | .recordNetworkRestriction | .reviseDeadline | .abuseOpen | .abuseClose
    | .abuseRecordTransmission => false
  | .fundingCancellation | .suspensionCancellation | .boundCancellation | .rederivation
  | .exhaustionSweep | .solvencyCheck | .metering => false

/-- The money that arrives anyway, on either rail: "**Keep crediting everything that still
arrives, on both rails.** Refusing or holding an arrived payment is `LDG-43`'s forbidden outcome".
Crediting has no caller — a settlement is observed, not requested — so it is modelled as the
arrival function below rather than as an `Action`. The rail is a parameter of that function and is
discarded on purpose: "on both rails" is then a property of the function rather than an assumption
about it. -/
inductive Rail
  | lightning | onchain
  deriving DecidableEq, Repr

instance {q : Rail → Prop} [DecidablePred q] : Decidable (∀ x, q x) :=
  Tables.decidableForallOfList [.lightning, .onchain] (by intro x; cases x <;> decide) q

/-- `LDG-20` under a failing solvency check. `none` proceeds; a refusal is `halted`, the kind
`DOM-20` added for it. The exposure-reducing row comes first so that its parameter decides nothing
else: with `exposureExemptUnderHalt` off, a delete is refused because exposure is too high, which
is the failure `LDG-20` names. Minting is refused whatever the parameters say — that is the halt
itself, not a guard on it. -/
@[req "LDG-20"]
def underHalt (g : Guards) (a : Action) : Option ErrorKind :=
  if a.reducesExposure then (if g.exposureExemptUnderHalt then none else some .halted)
  else if a.billIncreasing || a.mintsDestination then some .halted
  else none

/-- `LDG-20` as amended 2026-08-31, whose headline reads "halt top-ups" halts minting, and only
minting. An
arrived payment is credited during a halt on either rail, because "`LDG-47`/`LDG-51` require
crediting whatever arrives" and refusing it "is `LDG-43`'s forbidden outcome". Without the
parameter the halt is the withdrawn wholesale one and the stranger's money is refused. -/
@[req "LDG-20"]
def creditArrival (g : Guards) (_rail : Rail) : Option ErrorKind :=
  if g.haltMintsOnly then none else some .halted

/-- What a destination already handed out does when the halt is declared. `LDG-20`: "**Cancel
unsettled Lightning invoices on unexpired deposits.** This is closeable and closing it is safe: the
rail is atomic … This is an explicit exception to `LDG-55`". The on-chain rail has no such
mechanism — "an on-chain address forever (`LDG-54`)" — and the deployment MUST "**State that the
on-chain rail cannot be halted**". `true` is payable. -/
@[req "LDG-20"]
def destinationAfterHalt (g : Guards) (rail : Rail) (settled expired : Bool) : Bool :=
  match rail with
  | .onchain => true
  | .lightning => !(g.cancelUnsettledInvoices && !settled && !expired)

/-- `LDG-20`: "An HTLC that settles concurrently with the cancel **was** received and MUST be
credited", which `LDG-48` reaches by "an accepted-but-unsettled HTLC is not a payment" — the
cancelled invoice is the unsettled one, and settlement is what distinguishes them. -/
@[req "LDG-20"]
def arrivalIsCredited (g : Guards) (rail : Rail) (settled : Bool) : Bool :=
  settled && (creditArrival g rail == none)

/-- The answers the matrix gives: `LDG-40`'s across its rows, the one `LDG-64` added with the
fifth, and the two `ADR-0029` gave the outage — the sweep that routes nothing, and the funding
cancellation that waits. -/
inductive RateAnswer
  | halts | continues | failsClosed | metersNative | routesNothing | waits
  deriving DecidableEq, Repr

/-- What an answer becomes once the outage's deadline has passed, still with no rate. Only the
wait has a clock in it: `OPS-39` says it "ends at the rate's return or at `LDG-64`'s bound", and
past the deadline `OPS-41`'s fifth step lets the cancellation through. Every other answer stands
for as long as there is no rate. No wildcard. -/
@[req "OPS-39"]
def RateAnswer.atTheBound : RateAnswer → RateAnswer
  | .waits => .continues
  | .halts => .halts
  | .continues => .continues
  | .failsClosed => .failsClosed
  | .metersNative => .metersNative
  | .routesNothing => .routesNothing

/-- `LDG-40`'s matrix "when no rate is available": "**create** (MUST halt: it is a purchase priced
at an unknown rate), **re-derivation** (MUST halt rather than under-reserve, and the halt MUST NOT
itself trigger exhaustion), **the exhaustion sweep** (MUST route no machine priced in that
currency: `LDG-16` holds the predicate, and a funding cancellation already queued waits as
`OPS-41` orders), and **the solvency check** (MUST fail closed)", with "**The fifth row — metering
— was missing, and it is the one that costs money**" answered by `LDG-64`: "**meter in the
provider's own currency**" for the duration, never as a deferred satoshi debit. Without
`sweepRoutesNothingWithoutRate` the sweep's answer is the withdrawn row's, `continues`.

The extension is `LDG-40`'s own sentence: "With no rate for the machine's currency, an extension
of runway MUST halt as a create does".

The system's cancellations, claimed while there is no rate and before the outage's deadline;
`RateAnswer.atTheBound` is the same matrix past it. `t` is the tenant's state as the worker's
re-check reads it, and it decides the row; the reason the attempt was enqueued under decides
nothing. `OPS-41`'s order "holds for every exposure-reducing cancellation, whatever reason the
attempt was enqueued under, and the first step that applies decides", and its exemption is "keyed
on the tenant's current state, not on the reason the operation was enqueued under". A tenant
suspended now is the second step, "The funding re-check does not apply and the cancellation
proceeds": the cancellation continues, a funding one and the bound's included. Under any other
tenant it waits — the fourth step, "The claim defers" — a suspension's cancellation whose tenant
has since been resumed included; `OPS-39`'s name for the wait is "a delay and not a denial". The
bound's is enqueued at the deadline, so one claimed before it takes the operator raising the
maximum after it was enqueued; past the deadline it is `LDG-65`'s "A machine that reaches
`LDG-64`'s bound is cancelled there". `the_enqueue_reason_decides_nothing_without_a_rate` is the
claim that no cell here keys on the reason, and `Provisiond.Fence.recheck` is the order itself.

Every other row discards `t`. A caller verb's tenant is the pipeline's question (`admit`), and a
verb that reaches this matrix has passed it; the verbs continue because they open no commitment
and pass no spending gate, so no rate is consulted. No wildcard. -/
@[req "LDG-40"]
def underNoRate (g : Guards) (t : TenantState) (a : Action) : RateAnswer :=
  match a with
  | .exhaustionSweep => if g.sweepRoutesNothingWithoutRate then .routesNothing else .continues
  | .rederivation => .halts
  | .solvencyCheck => .failsClosed
  | .metering => .metersNative
  | .fundingCancellation | .suspensionCancellation | .boundCancellation =>
    match t with
    | .suspended => .continues
    | .pending | .active => .waits
  | .caller v =>
    match v with
    | .create | .extendRunway => .halts
    | .power | .install | .reverseDns | .refresh | .rescueInventory | .deleteMachine | .deposit
    | .abuseStatement | .revoke | .retry | .suspend | .resume | .resolve | .attributeDeposit
    | .releaseAttachment | .assignProviderAccount | .recordStatus | .recordNetworkRestriction
    | .reviseDeadline | .abuseOpen | .abuseClose | .abuseRecordTransmission => .continues

/-- The billing currencies a deployment prices in. `LDG-59`: "there is one rate, one quorum, one
outage and one bound for each currency the deployment bills in, a subject's rate is its offer's
currency". Two is enough to state that, and `STO-49` gained the dimension for the same reason. -/
inductive Currency
  | eur | usd
  deriving DecidableEq, Repr

instance {q : Currency → Prop} [DecidablePred q] : Decidable (∀ c, q c) :=
  Tables.decidableForallOfList [.eur, .usd] (by intro c; cases c <;> decide) q

/-- `LDG-59`: "a USD quorum loss halts nothing priced in EUR". The outage is per currency and the
subject's own currency is what is read. -/
@[req "LDG-59"]
def rateAvailableFor (outage : Currency → Bool) (subject : Currency) : Bool := !outage subject

/-! ## What the pipeline decides -/

/-- `API-24`: "`kind` MUST come from the closed set in `DOM-17`", and "Handlers MUST NOT choose
statuses independently." Over every principal, tenant state, listener, verb, admin flag, replay,
ceiling answer and override, the pipeline refuses with no kind outside these five. That each of the
five is actually reached is the witnesses' half, not this one's. -/
@[req "API-7"]
theorem refusals_are_within_the_five_kinds :
    ∀ (p : Principal) (l : Listener) (v : Verb) (t : TenantState) (a y c o : Bool),
      (match (admit current ⟨p, l, v, t, a, y, c, o, true⟩).map Outcome.verdict with
       | some (.refused e) =>
         e == .notFound || e == .authentication || e == .notActivated || e == .suspended ||
           e == .ceilingExceeded
       | _ => true) = true := by decide

/-- `API-5`'s flag is what the operator's reach onto a customer route turns on, and the cell where
that requirement stops — "the header MUST be ignored rather than honoured for it" — is the only one
this set leaves undecided. Enumerated in both directions, so a later amendment that decides it, or
one that leaves a second cell undecided, is a red build. -/
@[req "API-5"]
theorem the_one_undecided_cell :
    ∀ (p : Principal) (l : Listener) (v : Verb) (t : TenantState) (a y c o k : Bool),
      (admit current ⟨p, l, v, t, a, y, c, o, k⟩).isNone =
        (p == .operator && v.listener == Listener.customer && !a &&
          authenticates p v) := by decide

/-- `SEC-39`'s opening: "An autonomous caller sets the flag from a template on every request; it
becomes a constant, and the safety property it was carrying quietly disappears while the field is
still present and still `true`." No cell of the pipeline reads it. -/
@[req "SEC-39"]
theorem acknowledgement_is_not_a_control :
    ∀ (p : Principal) (l : Listener) (v : Verb) (t : TenantState) (a y c o : Bool),
      admit current ⟨p, l, v, t, a, y, c, o, true⟩ =
        admit current ⟨p, l, v, t, a, y, c, o, false⟩ := by
  decide

/-- `SEC-39`: "**a ceiling is something the caller cannot set for itself.** Any control the caller
supplies in its own request is advisory." Whatever the request carries, the limit is the
deployment's. -/
@[req "SEC-39"]
theorem a_caller_cannot_set_its_own_ceiling (deployment : Nat) (supplied : Option Nat) :
    effectiveLimit deployment supplied = deployment := rfl

/-- `SEC-39`: the override is "recorded as the uncapped thing", and `API-7` 5c makes it the only
exemption that reaches this pipeline. So it is the only thing that admits a counted verb standing
at its limit. -/
@[req "SEC-39"]
theorem only_the_override_is_uncapped (g : Guards) (r : Request) :
    (∀ n : Nat, limitUnder true n = none ∧ limitUnder false n = some n) ∧
      (r.override = true → stepFiveC g r = none) ∧
      (g.ceilingStep = true → r.override = false → r.verb.counted = true →
        r.atCeiling = true → stepFiveC g r = some ErrorKind.ceilingExceeded) := by
  refine ⟨fun n => ⟨rfl, rfl⟩, fun h => ?_, fun h1 h2 h3 h4 => ?_⟩ <;>
    simp_all [stepFiveC]

/-- `SEC-39`'s two lists are stated "at minimum", so this table is a floor and not a prohibition —
but every budget it names is counted by some verb. A `Ceiling` constructor no verb reaches would be
a control with no writer. -/
@[req "SEC-39"]
theorem every_ceiling_is_counted_by_some_verb :
    ∀ c : Ceiling, Verb.all.any (fun v => (v.ceilings true).contains c) = true := by
  intro c; cases c <;> decide

/-- `SEC-39`'s rescue ceiling is on the entry, not the operation: the inventory pass always counts
one, an install counts one exactly when its strategy enters rescue, and no other verb counts one at
all. -/
@[req "SEC-39"]
theorem the_rescue_ceiling_counts_entries :
    ∀ (v : Verb) (e : Bool),
      ((v.ceilings e).contains .rescueEntries) =
        (v == .rescueInventory || (v == .install && e)) := by decide

/-- `API-7`, 2026-09-04: "**Every operator verb skips 2 and 5b**, whether or not it names a
tenant." Under the parameter, neither step reads the tenant an operator verb names, so neither can
refuse for its state. -/
@[req "API-7"]
theorem operator_verbs_skip_two_and_five_b (g : Guards) (r : Request)
    (hg : g.operatorSkipsTenantSteps = true) (hv : r.verb.listener = Listener.operator) :
    stepTwo g r = none ∧ stepFiveB g r = none := by
  simp [stepTwo, stepFiveB, skipsTenantSteps, hg, hv]

/-- `API-7`: step 2 "MUST NOT look at suspension" and "A `suspended` tenant passes it and is
rejected at 5b instead", which is "**This is the only step that rejects for suspension**". -/
@[req "API-7"]
theorem only_five_b_refuses_for_suspension (g : Guards) (r : Request)
    (hg : g.stepTwoReadsSuspension = false) : stepTwo g r ≠ some ErrorKind.suspended := by
  simp [stepTwo, hg]

/-- `API-7`'s two reasons for 5a coming first, as one property: a replay returns its stored result
and consumes nothing, whatever the tenant's state and whatever its budget says. -/
@[req "API-7"]
theorem a_replay_returns_its_stored_result (g : Guards) (r : Request)
    (hg : g.replayBeforePolicy = true) (hr : r.replay = true) (hv : hidden g r = false)
    (hp : authenticates r.principal r.verb = true) (ha : authorized r.principal r.verb = true)
    (ht : namesATenant r = true) (h2 : stepTwo g r = none) :
    admit g r = some { verdict := .replayed, slotSpent := false } := by
  simp [admit, hv, hp, ha, ht, h2, hg, hr]

/-- `WIR-34`: "MUST return `404` — never `authentication`", so no operator route's existence is
customer-observable, on either listener. `authorized` is the refusal standing behind it, and that
is the answer this rule exists to replace. -/
@[req "WIR-34"]
theorem operator_routes_are_not_customer_observable (g : Guards) (r : Request)
    (hg : g.listenerSplit = true) (hv : r.verb.listener = Listener.operator)
    (hp : r.principal = Principal.customer) :
    admit g r = some { verdict := .refused .notFound, slotSpent := false } := by
  have ha : authenticates r.principal r.verb = true := by
    have : r.verb ≠ Verb.revoke := by
      intro h; rw [h] at hv; exact absurd hv (by decide)
    simp [authenticates, hp, this]
  have h : hidden g r = true := by simp [hidden, hg, hv, hp]
  simp [admit, ha, h]

/-- The listener is read for `WIR-34`'s routes and for no others: a customer route answers the same
on either, because no requirement in this set makes that cell decisive. `API-27`'s topology
obligation is a deployment property, not a per-request one. -/
@[req "WIR-34"]
theorem customer_routes_do_not_key_on_the_listener :
    ∀ (p : Principal) (v : Verb) (t : TenantState) (a y c o k : Bool),
      v.listener = Listener.customer →
        admit current ⟨p, .customer, v, t, a, y, c, o, k⟩ =
          admit current ⟨p, .operator, v, t, a, y, c, o, k⟩ := by decide

/-! ## What the matrices decide -/

/-- `LDG-20`'s closing sentence, decided over the whole action space: "The operations that *reduce*
exposure MUST never be gated by the check that fires because exposure is too high." -/
@[req "LDG-20"]
theorem exposure_reducing_is_never_halted (g : Guards) (hg : g.exposureExemptUnderHalt = true) :
    ∀ a : Action, a.reducesExposure = true → underHalt g a = none := by
  intro a ha
  simp [underHalt, ha, hg]

/-- `OPS-41`: "The order holds for every exposure-reducing cancellation, whatever reason the
attempt was enqueued under, and the first step that applies decides". Over every setting of the
guards, every tenant state and every pair of actions: two system cancellations get one answer
with no rate, whatever each was enqueued under, and that answer is the tenant's state at the
re-check — continues where the tenant is suspended now, waits otherwise. An amendment that keys a
cell on the reason again is a red build. No wildcard. -/
@[req "OPS-41"]
theorem the_enqueue_reason_decides_nothing_without_a_rate (g : Guards) (t : TenantState) :
    ∀ a b : Action, a.systemCancellation = true → b.systemCancellation = true →
      underNoRate g t a = underNoRate g t b ∧
      underNoRate g t a = (match t with
        | .suspended => .continues
        | .pending | .active => .waits) := by
  intro a b ha hb
  cases a <;> cases b <;> cases t <;> simp_all [Action.systemCancellation, underNoRate]

/-- The tenant's state is read by the system cancellations' rows and by no other: every other
action's answer with no rate is the same under every tenant state. -/
@[req "LDG-40"]
theorem only_a_system_cancellation_reads_the_tenant_state (g : Guards) (t t' : TenantState) :
    ∀ a : Action, a.systemCancellation = false → underNoRate g t a = underNoRate g t' a := by
  intro a ha
  cases a <;> simp_all [Action.systemCancellation, underNoRate]

/-- `OPS-39`: "Pacing MAY delay such a cancellation briefly; nothing may deny it." What this
proves is a property of the table and of nothing with a clock in it: over the whole action space,
every tenant state and whatever the guards, no action that reduces exposure, the sweep apart, is
answered with a halt — each continues or waits — and the wait's answer past the deadline
(`RateAnswer.atTheBound`) is `continues`. This model has no rate that returns and no deadline
that passes, so that the wait in fact ends is not this theorem's.
`Provisiond.Fence.defer_only_without_a_rate_before_the_deadline` proves, over every world, that a
re-check defers only with no rate and the deadline not passed, or through the applicable
`derive` branch's paused deferral, including a return seen in step 5. `Provisiond.Fence.derive_defers_iff`
characterizes that added case; nothing else in the ordered re-check waits. This is a property
of one re-check, not proof that a clocked wait eventually ends. `Provisiond.Witnesses` runs the wait to its end both
ways (`returned_rate_decides_on_the_predicate_witness`, `the_wait_ends_at_the_bound_witness`).
The sweep is not a cancellation and `OPS-39`'s sentence is not about it; its row is the next
theorem's.

Changed with the matrix's tenant-state argument (`underNoRate`): the statement ranges over that
state as well, and says of each what it said before. -/
@[req "OPS-39"]
theorem a_cancellation_is_delayed_never_denied_for_want_of_a_rate (g : Guards) (t : TenantState) :
    ∀ a : Action, a.reducesExposure = true → a ≠ .exhaustionSweep →
      (underNoRate g t a = .continues ∨ underNoRate g t a = .waits) ∧
      (underNoRate g t a).atTheBound = .continues := by
  intro a ha hs
  cases a with
  | caller v => cases v <;> simp_all [Action.reducesExposure, underNoRate, RateAnswer.atTheBound]
  | exhaustionSweep => exact absurd rfl hs
  | fundingCancellation => cases t <;> simp [underNoRate, RateAnswer.atTheBound]
  | suspensionCancellation => cases t <;> simp [underNoRate, RateAnswer.atTheBound]
  | boundCancellation => cases t <;> simp [underNoRate, RateAnswer.atTheBound]
  | rederivation => simp [Action.reducesExposure] at ha
  | solvencyCheck => simp [Action.reducesExposure] at ha
  | metering => simp [Action.reducesExposure] at ha

/-- What each action that reduces exposure does with no rate, under `LDG-40`'s landed row and
before the outage's deadline: a system cancellation waits unless its tenant is suspended now, the
sweep routes nothing, and everything else — a system cancellation under a suspended tenant
included — continues. The cases are exclusive, so an amendment that moves an action from one to
another is a red build.

Changed with the matrix's tenant-state argument. The statement used to name which cancellations
wait by constructor — the funding one and the bound's — and so by the reason each was enqueued
under; it names them by the tenant's state now, because `OPS-41`'s exemption is "keyed on the
tenant's current state, not on the reason the operation was enqueued under". It no longer says
that a suspension's cancellation continues whatever the tenant's state, nor that a funding one
or the bound's waits under a suspended tenant: each contradicts that sentence. -/
@[req "LDG-40"]
theorem exposure_reducing_waits_or_continues_without_a_rate (g : Guards)
    (hg : g.sweepRoutesNothingWithoutRate = true) (t : TenantState) :
    ∀ a : Action, a.reducesExposure = true →
      (a.systemCancellation = true ∧ t ≠ .suspended ∧ underNoRate g t a = .waits) ∨
      (a = .exhaustionSweep ∧ underNoRate g t a = .routesNothing) ∨
      ((a.systemCancellation = false ∨ t = .suspended) ∧ a ≠ .exhaustionSweep ∧
        underNoRate g t a = .continues) := by
  intro a ha
  cases a with
  | caller v =>
    cases v <;> simp_all [Action.reducesExposure, Action.systemCancellation, underNoRate]
  | exhaustionSweep => simp [underNoRate, hg, Action.systemCancellation]
  | fundingCancellation => cases t <;> simp [underNoRate, Action.systemCancellation]
  | suspensionCancellation => cases t <;> simp [underNoRate, Action.systemCancellation]
  | boundCancellation => cases t <;> simp [underNoRate, Action.systemCancellation]
  | rederivation => simp [Action.reducesExposure] at ha
  | solvencyCheck => simp [Action.reducesExposure] at ha
  | metering => simp [Action.reducesExposure] at ha

/-- `LDG-20`'s first clause against its second, in one statement: minting a destination is refused
while an arrival on either rail is credited. -/
@[req "LDG-20"]
theorem minting_is_refused_and_an_arrival_is_credited (g : Guards) (hg : g.haltMintsOnly = true) :
    underHalt g (.caller .deposit) = some ErrorKind.halted ∧
      ∀ rail : Rail, creditArrival g rail = none := by
  refine ⟨by simp [underHalt, Action.reducesExposure, Action.billIncreasing,
                   Action.mintsDestination], ?_⟩
  intro rail
  simp [creditArrival, hg]

/-- `LDG-20`: the on-chain rail "cannot be halted" — an address already handed out stays payable
however the halt is configured, which is the accepted residual that requirement records. -/
@[req "LDG-20"]
theorem the_on_chain_rail_cannot_be_halted (g : Guards) (settled expired : Bool) :
    destinationAfterHalt g .onchain settled expired = true := rfl

/-- `LDG-40` and `LDG-64`'s two rows that are not a halt: the solvency check "MUST fail closed",
and the meter runs natively rather than posting a deferred satoshi debit. Changed with the
matrix's tenant-state argument (`underNoRate`): the statement ranges over that state, and each row
answers the same under every one. -/
@[req "LDG-40"]
theorem the_two_rows_that_do_not_halt (g : Guards) :
    ∀ t : TenantState,
      underNoRate g t .solvencyCheck = .failsClosed ∧ underNoRate g t .metering = .metersNative :=
  fun _ => ⟨rfl, rfl⟩

/-- `OPS-39`: the exposure-reducing cancellation is "never blocked by a caller's ceiling", and
`API-7` says why it cannot be — "that sweep enqueues directly and never traverses this pipeline".
No verb produces any of them. -/
@[req "OPS-39"]
theorem no_verb_reaches_the_system_cancellation :
    ∀ v : Verb, Action.caller v ≠ Action.fundingCancellation ∧
      Action.caller v ≠ Action.suspensionCancellation ∧
      Action.caller v ≠ Action.boundCancellation := by decide

end Provisiond.Admission
