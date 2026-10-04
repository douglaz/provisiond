import Provisiond.Claim
/-! The closed tables: `OPS-11`'s classification, `OPS-3`'s resolution transitions and `OPS-48`'s
episode lifecycle over `DOM-31`'s states. Each is a total function whose `match` on a table's keys
carries no wildcard, so a kind, verb, state or event added without a row is a red build; a `_` here
stands only for an event's payload in a state where the set admits no transition on that event.
Totality over the finite domains is decided: `Kind.all` and its siblings enumerate a type, the
theorem that the enumeration is complete is by `cases`, and a `Decidable (∀ k, p k)` instance
built on it lets `decide` close a property over every input. Each type carries its own list and
completeness theorem because there is no `Fintype` without Mathlib (`ADR-0025`).

Every rule a dated amendment added is a field of the table's rule structure — `Rules`,
`ResolutionRows`, `Rows` — and its `current…` value carries them all (`ADR-0025`); the witnesses
hold each one's refused-with and admitted-without pair.

Not modelled: `OPS-11`'s `suspend_tenant` parent (its children settle, it does not; the function
says so with `none`), the goal-state answer on an install's rescue exit (the driver reads that as a
clean exit — `OPS-45`'s second marker — and the install's own outcome stands), `STO-19`'s
write-once resolution columns, and which provider codes mean "already in the target state", which
`OPS-11` says "is a provider fact, so the mapping belongs in the driver". -/

namespace Provisiond.Tables
open Provisiond.Claim

/-- A `Decidable (∀ x, p x)` from a complete enumeration. -/
def decidableForallOfList {α : Type} (all : List α) (mem : ∀ x, x ∈ all) (p : α → Prop)
    [DecidablePred p] : Decidable (∀ x, p x) :=
  decidable_of_iff (∀ x ∈ all, p x) ⟨fun h x => h x (mem x), fun h x _ => h x⟩

instance (priority := low) {p : Bool → Prop} [DecidablePred p] : Decidable (∀ b, p b) :=
  decidableForallOfList [true, false] (by decide) p

/-! ## The keys -/

/-- `WIR-10a`'s closed `kind` enum. -/
inductive Kind
  | createMachine | refresh | rescueInventory | power | install | reverseDns | deleteMachine
  | releaseAttachment | suspendTenant
  deriving DecidableEq, Repr

def Kind.all : List Kind :=
  [.createMachine, .refresh, .rescueInventory, .power, .install, .reverseDns, .deleteMachine,
   .releaseAttachment, .suspendTenant]

theorem Kind.mem_all (k : Kind) : k ∈ Kind.all := by cases k <;> decide

instance {p : Kind → Prop} [DecidablePred p] : Decidable (∀ k, p k) :=
  decidableForallOfList Kind.all Kind.mem_all p

/-- `DOM-17`'s closed set of error kinds, in the taxonomy table's order. The last seven are the
kinds `OPS-11` names as added after the table was written — "seven kinds added later were
missing". -/
inductive ErrorKind
  | invalidRequest | notFound | conflict | unsupported | authentication | rateLimited
  | provider | network | timeout | integrity | internal
  | insufficientBalance | notActivated | halted | gone | suspended | ceilingExceeded | overloaded
  deriving DecidableEq, Repr

def ErrorKind.all : List ErrorKind :=
  [.invalidRequest, .notFound, .conflict, .unsupported, .authentication, .rateLimited,
   .provider, .network, .timeout, .integrity, .internal,
   .insufficientBalance, .notActivated, .halted, .gone, .suspended, .ceilingExceeded, .overloaded]

theorem ErrorKind.mem_all (e : ErrorKind) : e ∈ ErrorKind.all := by cases e <;> decide

instance {p : ErrorKind → Prop} [DecidablePred p] : Decidable (∀ e, p e) :=
  decidableForallOfList ErrorKind.all ErrorKind.mem_all p

/-- `OPS-11`: the kinds that "are **admission-only**: they are decided before any driver call, they
MUST NOT be emitted by a worker or a driver". -/
@[req "OPS-11"]
def ErrorKind.admissionOnly : ErrorKind → Bool
  | .invalidRequest | .notFound | .conflict | .unsupported | .authentication | .rateLimited
  | .provider | .network | .timeout | .integrity | .internal => false
  | .insufficientBalance | .notActivated | .halted | .gone | .suspended | .ceilingExceeded
  | .overloaded => true

/-! ## `OPS-11`, the classification -/

/-- The upstream status recorded on a `provider` error: `OPS-11`'s "5xx, or no upstream status was
recorded at all" against "a 4xx". -/
inductive Upstream
  | status4xx | status5xx | unrecorded
  deriving DecidableEq, Repr

instance {p : Upstream → Prop} [DecidablePred p] : Decidable (∀ u, p u) :=
  decidableForallOfList [.status4xx, .status5xx, .unrecorded] (by intro u; cases u <;> decide) p

/-- One failure as the classification reads it: the kind, and the facts `OPS-11`'s ambiguity list
and goal-state rule turn on. `cutOff` is a `conflict` that "arose from the worker being cut off
mid-flight (`OPS-21`)"; `goalStateHeld` is the driver's mapping of "a provider rejection whose
meaning is 'already in the target state'". Each is read only under the kind it qualifies. -/
structure Failure where
  kind          : ErrorKind
  cutOff        : Bool
  upstream      : Upstream
  goalStateHeld : Bool
  deriving DecidableEq, Repr

/-- `OPS-45`'s two markers: `write_started_at` set, and "no rescue session was opened or the one
that was opened was closed without error". `rescueClean` is the classifier's two-way reading of a
three-valued column — `true` for `rescue_exited_cleanly` null and `true`, `false` for its `false` —
which is why every kind that enters no rescue carries `true` in the witnesses. `WIR-9a`'s
`none`/`clean`/`unknown` is rendered from the column, not from this field. -/
structure Markers where
  writeStarted : Bool
  rescueClean  : Bool
  deriving DecidableEq, Repr

/-- The rules `OPS-11` gained by dated amendment. `goalStateRow`: "A provider rejection whose
meaning is 'already in the target state' MUST classify `succeeded`" (2026-08-31). `markerRule`:
`OPS-45`'s settlement, "`failed` ... for any failure at all while `OPS-45`'s two markers say the
disk is untouched and no rescue session was left open" (2026-09-02). -/
structure Rules where
  goalStateRow : Bool
  markerRule   : Bool
  deriving DecidableEq, Repr

/-- `OPS-11` as it stands: both rules present. -/
@[req "OPS-11"]
def currentRules : Rules := { goalStateRow := true, markerRule := true }

/-- `OPS-11`: "A failure is **ambiguous** when" the kind is `network`, `timeout` or `internal`;
`conflict` from a mid-flight cut-off; or `provider` with a 5xx or no recorded status. Every other
kind is deterministic, the admission-only seven because "Nothing was destroyed and nothing was
ordered, so ambiguity cannot arise". -/
@[req "OPS-11"]
def ambiguous (f : Failure) : Bool :=
  match f.kind with
  | .network | .timeout | .internal => true
  | .conflict => f.cutOff
  | .provider => f.upstream != .status4xx
  | .invalidRequest | .notFound | .unsupported | .authentication | .rateLimited | .integrity
  | .insufficientBalance | .notActivated | .halted | .gone | .suspended | .ceilingExceeded
  | .overloaded => false

/-- The install row's kind column, the marker clauses aside: "`needs_reconciliation` for
`network`, `timeout`, `provider`, `internal`, `conflict`, and `integrity`"; "`failed` for the
deterministic caller errors `invalid_request`, `not_found`, `unsupported`, `authentication` and
`rate_limited`"; and the admission-only seven, `failed` "for every operation kind". -/
@[req "OPS-11"]
def installKindRow : ErrorKind → Written
  | .network | .timeout | .provider | .internal | .conflict | .integrity => .needsReconciliation
  | .invalidRequest | .notFound | .unsupported | .authentication | .rateLimited => .failed
  | .insufficientBalance | .notActivated | .halted | .gone | .suspended | .ceilingExceeded
  | .overloaded => .failed

/-- The install row, which `rescue inventory` shares: under `markerRule`, `failed` for any kind
while the markers clear the machine, and — `OPS-11`'s `PRV-22` case — `needs_reconciliation`
"regardless of which error kind the driver reports" where the rescue exit failed; otherwise the
kind column. `OPS-11`'s paragraph on that case: "the same holds where the operation died before
reaching it" — the marker "is one column, `false` for both". Without the rule, the row as it stood
before `OPS-45`: the kind column alone. -/
@[req "OPS-11"]
def installRow (r : Rules) (m : Markers) (e : ErrorKind) : Written :=
  if r.markerRule && !m.writeStarted && m.rescueClean then .failed
  else if r.markerRule && !m.rescueClean then .needsReconciliation
  else installKindRow e

/-- The last row — "`needs_reconciliation` if the failure is *ambiguous*, otherwise `failed`". -/
@[req "OPS-11"]
def mutationRow (f : Failure) : Written :=
  if ambiguous f then .needsReconciliation else .failed

/-- `OPS-11`'s goal-state row, for "a **goal-state mutation** — delete, power on, power off": a
`provider` rejection the driver mapped as "already in the target state". -/
@[req "OPS-11"]
def goalState (r : Rules) (f : Failure) : Bool :=
  r.goalStateRow && f.kind == .provider && f.goalStateHeld

/-- `OPS-11`'s table, one arm per `WIR-10a` kind. `none` is the `suspend_tenant` row: "Never
`needs_reconciliation`, and never `failed` as a whole", a parent whose children carry the outcomes.
A release "classifies exactly as" a delete, and rescue inventory has the "Same rows as `install`". -/
@[req "OPS-11"]
def classify (r : Rules) (k : Kind) (f : Failure) (m : Markers) : Option Written :=
  match k with
  | .refresh => some .failed
  | .suspendTenant => none
  | .install | .rescueInventory => some (installRow r m f.kind)
  | .power | .deleteMachine | .releaseAttachment =>
      some (if goalState r f then .succeeded else mutationRow f)
  | .createMachine | .reverseDns => some (mutationRow f)

/-- "Every kind in `DOM-17` MUST have a defined classification for every operation kind. There is
no implicit default": over every kind, failure and marker pair, the one row without an outcome is
the parent's. Decided over the whole domain. -/
@[req "OPS-11"]
theorem classify_total :
    ∀ (k : Kind) (e : ErrorKind) (c : Bool) (u : Upstream) (g : Bool) (w : Bool) (x : Bool),
      k ≠ .suspendTenant →
        (classify currentRules k ⟨e, c, u, g⟩ ⟨w, x⟩).isSome = true := by decide

/-- The admission-only seven: "any pre-provider occurrence classifies deterministically as `failed`
for every operation kind", under every fact about the failure. Pre-provider is the markers clear —
nothing dispatched, no rescue opened; a worker or driver "MUST NOT" emit these kinds, so the table
is not asked about them past that point. -/
@[req "OPS-11"]
theorem admission_only_failed :
    ∀ (k : Kind) (e : ErrorKind) (c : Bool) (u : Upstream) (g : Bool),
      e.admissionOnly = true → k ≠ .suspendTenant →
        classify currentRules k ⟨e, c, u, g⟩ ⟨false, true⟩ = some .failed := by decide

/-- `refresh` "Always `failed`. It is read-only; a failure changed nothing." -/
@[req "OPS-11"]
theorem refresh_always_failed (r : Rules) (f : Failure) (m : Markers) :
    classify r .refresh f m = some .failed := rfl

/-- The install row in both directions: with the write-started marker set, a kind its
`needs_reconciliation` list names is never `failed`; short of the marker with a clean exit, no
kind at all is `needs_reconciliation`. -/
@[req "OPS-11"]
theorem install_marker_directions :
    ∀ (e : ErrorKind) (c : Bool) (u : Upstream) (g : Bool),
      (installKindRow e = .needsReconciliation →
        classify currentRules .install ⟨e, c, u, g⟩ ⟨true, true⟩ ≠ some .failed) ∧
      classify currentRules .install ⟨e, c, u, g⟩ ⟨false, true⟩ ≠ some .needsReconciliation := by
  decide

/-- `pv-x8r`'s decision (2026-09-15): past the write-started marker with a clean rescue exit, the
deterministic caller kinds stay `failed` — "the engine knows what it did", and `failed` "asserts
that the install did not complete and nothing about the disk". The arm is pinned so that a later
amendment sending them to `needs_reconciliation` is a red build naming this theorem. -/
@[req "OPS-11"]
theorem deterministic_after_write_failed :
    ∀ e, installKindRow e = .failed → e.admissionOnly = false →
      installRow currentRules ⟨true, true⟩ e = .failed := by decide

/-! ## `OPS-3`, the resolution transitions -/

/-- The resolution verbs, as `OPS-31` gives them: "`observed` names an `external_id` that a create
produced; `absent` says nothing was created"; `applied` and `not_applied` "are the non-create
shapes of `observed` and `absent`"; and `abandoned` "remains for the case nobody can establish". -/
inductive Verb
  | observed | absent | applied | notApplied | abandoned
  deriving DecidableEq, Repr

def Verb.all : List Verb := [.observed, .absent, .applied, .notApplied, .abandoned]

theorem Verb.mem_all (v : Verb) : v ∈ Verb.all := by cases v <;> decide

instance {p : Verb → Prop} [DecidablePred p] : Decidable (∀ v, p v) :=
  decidableForallOfList Verb.all Verb.mem_all p

/-- `OPS-3`: "`succeeded` and `failed` are the terminal states." -/
inductive Terminal
  | succeeded | failed
  deriving DecidableEq, Repr

/-- The rows `OPS-3` gained by dated amendment: "The two non-create rows were added 2026-09-02
with `OPS-45`" — `applied` and `not_applied`, without which a non-create's only verb was
`abandoned`. -/
structure ResolutionRows where
  nonCreateVerbs : Bool
  deriving DecidableEq, Repr

/-- `OPS-3` as it stands. -/
@[req "OPS-3"]
def currentResolution : ResolutionRows := { nonCreateVerbs := true }

/-- `OPS-3`: "The permitted transitions are exactly" the five rows out of `needs_reconciliation`,
keyed on the verb and whether the operation is a create. `none` is a verb the row does not admit,
"a verb `OPS-4` forbids". -/
@[req "OPS-3"]
def resolve (rows : ResolutionRows) (create : Bool) : Verb → Option Terminal
  | .observed => if create then some .succeeded else none
  | .absent => if create then some .failed else none
  | .applied => if !create && rows.nonCreateVerbs then some .succeeded else none
  | .notApplied => if !create && rows.nonCreateVerbs then some .failed else none
  | .abandoned => some .failed

/-- The function's image, decided: the five rows of `OPS-3`'s list, the `abandoned` row "(any
kind)" appearing once per shape. Every `(create, verb)` pair with an outcome is here and no other
is. -/
@[req "OPS-3"]
theorem resolve_rows :
    ([true, false].flatMap fun c => Verb.all.filterMap fun v => (resolve currentResolution c v).map ((c, v, ·))) =
      [(true, .observed, .succeeded), (true, .absent, .failed), (true, .abandoned, .failed),
       (false, .applied, .succeeded), (false, .notApplied, .failed),
       (false, .abandoned, .failed)] := by decide

/-- `OPS-31`: the create-shaped verbs have no meaning on a machine that "**already exists**", and
the non-create pair none on a create: each shape admits exactly three verbs. -/
@[req "OPS-3"]
theorem resolve_shapes :
    ∀ v, ((resolve currentResolution true v).isSome ↔ v ≠ .applied ∧ v ≠ .notApplied) ∧
         ((resolve currentResolution false v).isSome ↔ v ≠ .observed ∧ v ≠ .absent) := by
  decide

/-! ## `OPS-48`, the episode lifecycle over `DOM-31`'s states -/

/-- `DOM-31`: "Close reasons: `resource_gone`, `funded`, `abandoned`, `kept`." -/
inductive CloseReason
  | resourceGone | funded | abandoned | kept
  deriving DecidableEq, Repr

instance {p : CloseReason → Prop} [DecidablePred p] : Decidable (∀ r, p r) :=
  decidableForallOfList [.resourceGone, .funded, .abandoned, .kept] (by intro r; cases r <;> decide) p

/-- `DOM-31`: "States: `attempting`, `uncertain`, `stalled`, `scheduled`, `closed`", a close
carrying its reason. -/
inductive Episode
  | attempting | uncertain | stalled | scheduled | closed (reason : CloseReason)
  deriving DecidableEq, Repr

def Episode.all : List Episode :=
  [.attempting, .uncertain, .stalled, .scheduled,
   .closed .resourceGone, .closed .funded, .closed .abandoned, .closed .kept]

theorem Episode.mem_all (s : Episode) : s ∈ Episode.all := by
  cases s with
  | closed r => cases r <;> decide
  | _ => decide

instance {p : Episode → Prop} [DecidablePred p] : Decidable (∀ s, p s) :=
  decidableForallOfList Episode.all Episode.mem_all p

def Episode.isOpen : Episode → Bool
  | .attempting | .uncertain | .stalled | .scheduled => true
  | .closed _ => false

/-- How the current attempt settled, as `OPS-48`'s first column keys it: `succeeded` with the
resource gone, `succeeded` "recording that no mutation was required", `succeeded` scheduled,
`failed`, `needs_reconciliation`. -/
inductive Settled
  | gone | noMutation | scheduled | failed | needsReconciliation
  deriving DecidableEq, Repr

/-- What happens to an open episode: its attempt settles; its attempt is resolved under a verb,
`dated` being `WIR-35`'s `effective_cancellation_date` on `applied`; `retry`; operator `keep`; the machine's gone-write; and the
transaction that tombstones a scheduled machine at its effective date — a gone-write of its own,
since nothing tombstones by timer and `LDG-74` allows "A machine still present after its date". -/
inductive Event
  | settled (s : Settled)
  | resolved (v : Verb) (dated : Bool)
  | retry
  | keep
  | goneWrite
  | tombstone
  deriving DecidableEq, Repr

def Event.all : List Event :=
  [.gone, .noMutation, .scheduled, .failed, .needsReconciliation].map Event.settled ++
  (Verb.all.flatMap fun v => [.resolved v true, .resolved v false]) ++
  [.retry, .keep, .goneWrite, .tombstone]

theorem Event.mem_all (e : Event) : e ∈ Event.all := by
  cases e with
  | settled s => cases s <;> decide
  | resolved v d => cases v <;> cases d <;> decide
  | _ => decide

instance {p : Event → Prop} [DecidablePred p] : Decidable (∀ e, p e) :=
  decidableForallOfList Event.all Event.mem_all p

/-- The rows `OPS-48` and `DOM-31` gained or lost by dated amendment, all `ADR-0021` (2026-09-09).
`goneWriteRow`: "the machine is recorded gone ... in any open state, `scheduled` included" closes
it.
`abandonFromStalled`: the edge `DOM-31`'s diagram drew, `stalled --> closed : abandoned`, which
"had no provider" and is deleted — `true` restores it. -/
structure Rows where
  goneWriteRow        : Bool
  abandonFromStalled  : Bool
  deriving DecidableEq, Repr

/-- `OPS-48` as it stands. -/
@[req "OPS-48"]
def currentRows : Rows :=
  { goneWriteRow := true, abandonFromStalled := false }

/-- A close, with the fence cleared in the same transaction. -/
def close (r : CloseReason) : Episode × Bool := (.closed r, true)

/-- `OPS-48`'s table: the episode after the event, and whether `machines.destroy_committed` was
cleared in that transaction. "The transitions are exactly these" — an event the state's rows do not
key on changes nothing, and a closed episode is changed by nothing: "A close is permanent, and the
rows above apply to an open episode only". The scheduled row closes "`close_reason:
resource_gone`, in the transaction that tombstones the machine at the effective date", `STO-8a`'s
"'Succeeds' means the resource is gone". -/
@[req "OPS-48"]
def episodeStep (rows : Rows) (s : Episode) (e : Event) : Episode × Bool :=
  let stay := (s, false)
  let goneRow := if rows.goneWriteRow then close .resourceGone else stay
  match s with
  | .closed r => (.closed r, false)
  | .attempting =>
    match e with
    | .settled .gone => close .resourceGone
    | .settled .noMutation => close .funded
    | .settled .scheduled => (.scheduled, false)
    | .settled .failed => (.stalled, false)
    | .settled .needsReconciliation => (.uncertain, false)
    | .resolved _ _ => stay
    | .retry => stay
    | .keep => stay
    | .goneWrite => goneRow
    | .tombstone => stay
  | .uncertain =>
    match e with
    | .settled _ => stay
    | .resolved .applied false => close .resourceGone
    | .resolved .applied true => (.scheduled, false)
    | .resolved .notApplied _ => (.stalled, false)
    | .resolved .abandoned _ => close .abandoned
    | .resolved .observed _ => stay
    | .resolved .absent _ => stay
    | .retry => stay
    | .keep => stay
    | .goneWrite => goneRow
    | .tombstone => stay
  | .stalled =>
    match e with
    | .settled _ => stay
    | .resolved .abandoned _ => if rows.abandonFromStalled then close .abandoned else stay
    | .resolved .applied _ => stay
    | .resolved .notApplied _ => stay
    | .resolved .observed _ => stay
    | .resolved .absent _ => stay
    | .retry => (.attempting, false)
    | .keep => close .kept
    | .goneWrite => goneRow
    | .tombstone => stay
  | .scheduled =>
    match e with
    | .settled _ => stay
    | .resolved _ _ => stay
    | .retry => stay
    | .keep => stay
    | .goneWrite => goneRow
    | .tombstone => close .resourceGone

/-- `ADR-0021`: "A close is permanent." Decided about the table: under every row set and every
event, a closed episode is unchanged and clears nothing. -/
@[req "OPS-48"]
theorem closed_absorbing :
    ∀ (g a : Bool) (r : CloseReason) (e : Event),
      episodeStep ⟨g, a⟩ (.closed r) e = (.closed r, false) := by decide

/-- "Nothing else clears `destroy_committed`": the fence is cleared in a step exactly when that step
closes an open episode, under every row set. -/
@[req "OPS-48"]
theorem fence_cleared_iff_closes :
    ∀ (g a : Bool) (s : Episode) (e : Event),
      (episodeStep ⟨g, a⟩ s e).2 = true ↔
        (s.isOpen = true ∧ (episodeStep ⟨g, a⟩ s e).1.isOpen = false) := by decide

/-- `retry` "on a `stalled` episode" reopens `attempting`, and is "admissible in no other state":
everywhere else it changes nothing. -/
@[req "OPS-48"]
theorem retry_only_from_stalled :
    ∀ s, episodeStep currentRows s .retry = (if s = .stalled then .attempting else s, false) := by decide

/-- `ADR-0021`: the gone-write "closes its open episode `resource_gone` and clears the fence, in
that transaction", from every open state. -/
@[req "OPS-48"]
theorem gone_closes_and_clears :
    ∀ s, s.isOpen = true → episodeStep currentRows s .goneWrite = (.closed .resourceGone, true) := by
  decide

/-- Only the ordinary no-mutation settlement closes `funded` (2026-10-04, `ADR-0032`). -/
@[req "OPS-48"]
theorem funded_only_from_its_rows :
    ∀ s e, s.isOpen = true → (episodeStep currentRows s e).1 = .closed .funded →
      e = .settled .noMutation := by decide

/-- The operator keep transition is confined to stalled episodes. -/
@[req "API-68"]
theorem keep_only_from_stalled :
    ∀ s, episodeStep currentRows s .keep =
      (if s = .stalled then (.closed .kept, true) else (s, false)) := by decide

end Provisiond.Tables
