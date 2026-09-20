import Provisiond.Claim
import Provisiond.Tables
/-! `ADR-0025`'s M7: the rescue path as four models — `RSC-3`'s host-key trust decision, `RSC-26`'s
disk identity, `OPS-45`'s two markers on the claim model, and `RSC-19`'s recovery key. Each is its
own state, events and step, so a theorem about one cannot be cited for another, and each composes
on a module that already owns what it needs: `Claim.holds` for `STO-3`'s guard, `Tables.Markers`
and `Tables.installRow` for `OPS-11`'s classification, `Tables.Kind` for `WIR-10a`'s enum.
`OPS-45`'s pre-dispatch arming appears in both `Install.step` and `Session.step`, under the one
`secondMarkerBeforeSession` field, because each carries a different half of it: `Install`
carries the write under `STO-3`'s guard and its acknowledgment before the dispatch — "each
acknowledged by the store before the provider call it precedes is made" — while `Session` carries
the column as `OPS-15`'s pass renders it, which is what `WIR-9a`'s `rescue_exit` reads off.

Physical and cryptographic facts are **named hypotheses** on the theorems that need them
(`CONTEXT.md`, *Assumption*): that a stable identifier names one disk is
`resolves_only_the_named_disk`'s `huniq`, not a definition's silent assumption and not an `axiom` —
the project declares none.

`Params` lists the guards dated amendments added and the one design `RSC-19` refuses, each a field
so that removing it is a one-token change a witness theorem exercises; `ci.yml`'s controls flip
one each.

What the model omits: `RSC-6`'s canonicalization (a key here is its canonical `algorithm base64`
pair, reduced to an identity) and `RSC-7`/`RSC-8`'s known-hosts file; `RSC-9`'s deadline and
`PRV-19`'s polling, so the driver publishing keys is one event with no clock; which set is pinned
where both are supplied and they overlap, because `RSC-3` does not say and inventing one would put
a rule in `tools/formal/` that no requirement owns; `RSC-20`'s directory (absolute, owner-only,
encrypted storage) — a deployment fact, so what is persisted here is a key named by an operation
id and nothing about where it sits; the image fetch and `RSC-25`/`RSC-29`'s digest verification;
`RSC-22`/`RSC-23`'s layout validation, of which only the `drives[].identifier` resolution is here;
`OPS-49`'s bounded repeat and the worker guard's own terms (`Claim`); `OPS-11`'s classification
(`Tables`), which this projects into and does not re-model; the wire row (`Wire`); `RSC-39`–`RSC-44`
and the catalogue re-host (`pv-vwe.13`); a crash inside `STO-54`'s procedure (`Provisiond.Restore`
carries it) and
re-activating rescue on a machine already in rescue (`pv-lhj`), so no event here is a second
activation. One tenant, one machine, one engine (`OPS-47`) throughout.

Two conservatisms the models make visible rather than hide, and `OPS-45` states both. Of the first
marker: "it establishes that preservation is no longer proven, not that a byte landed" — a process
that dies between the write and the phase leaves a set marker over an untouched disk, which is
`marker_set_over_an_untouched_disk`. Of the second, written the same way: "`false` is the
conservative value as much as the open-session one: a process that dies between that write and the
dispatch leaves `false` over a machine that was never rebooted into rescue", which is
`false_over_a_machine_never_in_rescue`. The direction the column does foreclose is the paragraph's
"Null is the only value that means no session was opened", and that is `none_means_no_session`. -/

namespace Provisiond.Rescue
open Provisiond.Claim Provisiond.Tables

/-- An invariant every step keeps, every run keeps — `Restore.run_preserves` over the four state
types here. -/
theorem foldl_preserves {σ α : Type} (f : σ → α → σ) (I : σ → Prop)
    (hI : ∀ s a, I s → I (f s a)) (s : σ) (hs : I s) (as : List α) : I (as.foldl f s) := by
  induction as generalizing s with
  | nil => exact hs
  | cons a as ih => exact ih _ (hI s a hs)

/-! ## Trust: `RSC-3`, `RSC-4`, `RSC-5` -/

namespace Trust

/-- A host key as `RSC-6` compares them — "the `algorithm base64` pair" — reduced to its identity.
Canonicalization is that requirement's and is not modelled here. -/
structure HostKey where n : Nat deriving DecidableEq, Repr

/-- `RSC-3`'s third row, "They MUST overlap": the intersection of the two sets is non-empty. -/
def overlaps (caller driver : List HostKey) : Bool :=
  caller.any (fun k => driver.contains k)

/-- `RSC-3`'s five rows as five decisions. `pinOverlapping` is the both-supplied row that overlaps:
the requirement says "They MUST overlap" and does not say which set is then pinned, so the decision
carries the mode and the pinned set is not modelled. -/
inductive Decision
  | pinCaller
  | pinDriver
  | pinOverlapping
  | acceptNew
  | abortIntegrity
  deriving DecidableEq, Repr

/-- `RSC-3`: "The engine MUST NOT connect unless one of these is true" — the four rows that permit
a connection, against the abort. -/
@[req "RSC-3"]
def connects : Decision → Bool
  | .pinCaller | .pinDriver | .pinOverlapping | .acceptNew => true
  | .abortIntegrity => false

/-- `RSC-3`'s table, a total function of the caller's keys, the driver's published keys and the
explicit first-use opt-in. "Caller supplied expected host keys" is the first row, "Driver published
host keys and caller supplied none" the second, "Caller supplied keys *and* driver published keys"
the third — where "No overlap is an `integrity` failure, and the engine MUST abort before
connecting" — "Neither, and the caller explicitly opted into first-use trust" the fourth, and
"Neither, and no explicit opt-in" the fifth. The `match` carries no wildcard. -/
@[req "RSC-3"]
def decision (caller driver : List HostKey) (optIn : Bool) : Decision :=
  match caller, driver with
  | [], [] => if optIn then .acceptNew else .abortIntegrity
  | _ :: _, [] => .pinCaller
  | [], _ :: _ => .pinDriver
  | c :: cs, d :: ds => if overlaps (c :: cs) (d :: ds) then .pinOverlapping else .abortIntegrity

/-- Every key set over a two-key universe: enough to reach all five rows, with the both-supplied row
both overlapping and not. -/
def keySets : List (List HostKey) := [[], [⟨0⟩], [⟨1⟩], [⟨0⟩, ⟨1⟩]]

/-- The table is total and there is no sixth row: over every pair of key sets and both opt-in
values, the decision aborts on exactly the two rows `RSC-3` names — "Neither, and no explicit
opt-in", and both supplied with no overlap. Decided. -/
@[req "RSC-3"]
theorem aborts_on_exactly_two_rows :
    ∀ c ∈ keySets, ∀ d ∈ keySets, ∀ optIn : Bool,
      (decision c d optIn == .abortIntegrity) =
        ((c.isEmpty && d.isEmpty && !optIn) || (!c.isEmpty && !d.isEmpty && !overlaps c d)) := by
  decide

/-- The request `RSC-4` constrains. -/
structure Request where
  callerKeys    : List HostKey
  firstUseOptIn : Bool
  deriving DecidableEq, Repr

/-- `RSC-4`: "Caller-supplied keys and the first-use-trust opt-in MUST be mutually exclusive in the
request (`API-13`)." -/
@[req "RSC-4"]
def admissible (r : Request) : Bool := !(!r.callerKeys.isEmpty && r.firstUseOptIn)

/-- `RSC-4` exactly: a request is inadmissible where it carries both, since "Caller-supplied keys
and the first-use-trust opt-in MUST be mutually exclusive in the request (`API-13`)". Both
directions, so the predicate refuses nothing else. -/
@[req "RSC-4"]
theorem inadmissible_carries_both (r : Request) :
    admissible r = false ↔ r.callerKeys ≠ [] ∧ r.firstUseOptIn = true := by
  cases r with
  | mk keys optIn => cases keys <;> cases optIn <;> simp [admissible]

/-- `RSC-3`'s accept-new row is "Neither, and the caller explicitly opted into first-use trust", so
the table reaches it only where the caller supplied none — on every request, admissible or not.
`RSC-4`'s rule is the request's, and this is what the engine would still do if a caller smuggled
both past `API-13`. -/
@[req "RSC-3"]
theorem accept_new_only_without_caller_keys (r : Request) (driver : List HostKey)
    (h : decision r.callerKeys driver r.firstUseOptIn = .acceptNew) : r.callerKeys = [] := by
  cases hc : r.callerKeys with
  | nil => rfl
  | cons k ks => rw [hc] at h; cases driver <;> simp [decision] at h <;> split at h <;> simp_all

/-! ### `RSC-5`: a pinned connection is pinned for its life -/

/-- The trust a connection was established under. -/
inductive State
  | pinned
  | firstUse
  deriving DecidableEq, Repr

/-- The state a decision establishes. The abort establishes no connection and so no state. -/
@[req "RSC-3"]
def Decision.state : Decision → Option State
  | .pinCaller | .pinDriver | .pinOverlapping => some .pinned
  | .acceptNew => some .firstUse
  | .abortIntegrity => none

/-- A connection over its life: the trust it was established under, and the three inputs the
decision was taken from, so that re-deciding is definable and can be refuted. -/
structure Conn where
  trust      : State
  callerKeys : List HostKey
  driverKeys : List HostKey
  optIn      : Bool
  deriving DecidableEq, Repr

/-- The events `RSC-5` names: "not on retry, not on timeout, not when the driver returns an empty
key set later" — the third carries the set, which may be empty. -/
inductive Event
  | retry
  | timeout
  | driverPublishes (keys : List HostKey)
  deriving DecidableEq, Repr

/-- `RSC-5`: "A pinned connection MUST NEVER be silently downgraded to first-use trust". The
decision is taken once; a later key set is recorded and the trust is not re-taken. -/
@[req "RSC-5"]
def step (c : Conn) : Event → Conn
  | .retry => c
  | .timeout => c
  | .driverPublishes keys => { c with driverKeys := keys }

def run (c : Conn) (evs : List Event) : Conn := evs.foldl step c

/-- The design `RSC-5` refuses, definable so that it can be refuted rather than assumed: the trust
re-decided on each event from the driver's *current* set. Generous to the alternative — an abort
leaves the trust where it was rather than tearing the connection down. -/
def redecide (c : Conn) (e : Event) : Conn :=
  let c' := step c e
  match (decision c'.callerKeys c'.driverKeys c'.optIn).state with
  | some s => { c' with trust := s }
  | none => c'

def runRedecided (c : Conn) (evs : List Event) : Conn := evs.foldl redecide c

/-- `RSC-5`, over every event sequence: from `pinned` the trust is never `firstUse` — not on retry,
not on timeout, not when the driver returns an empty key set later. -/
@[req "RSC-5"]
theorem pinned_never_downgrades (c : Conn) (h : c.trust = .pinned) (evs : List Event) :
    (run c evs).trust = .pinned :=
  foldl_preserves step (fun c' => c'.trust = State.pinned)
    (fun c' e h' => by cases e <;> simpa [step] using h') c h evs

end Trust

/-! ## Disk identity: `RSC-26` -/

namespace Disk

/-- A stable identifier: `RSC-26`'s first bullet has `RSC-38`'s pass return the inventory with
"**stable identifiers** — serial and WWN", and the model reduces one to its identity. -/
structure Identifier where n : Nat deriving DecidableEq, Repr

/-- One block device in an inventory. The identifier is an `Option` and two devices may carry the
same one, because `RSC-26` says "duplicate or empty serials are real on consumer and virtualised
disks". The path is what the rescue environment named it by on this reading, which `RSC-26` calls
"an ordering artefact that can differ across boots". -/
structure Device where
  identifier : Option Identifier
  path       : String
  deriving DecidableEq, Repr

/-- The report `RSC-38`'s pass returns, of which that requirement says only that "its report MUST
carry the same `inventory_fingerprint` an install will be checked against": the device set, and the
fingerprint `RSC-26`'s first bullet calls "an opaque `inventory_fingerprint` over the whole device
set". `RSC-46` makes it a hash of that set, so two device sets do not share one; what it is computed
over is that requirement's and is not modelled here. -/
structure Inventory where
  devices     : List Device
  fingerprint : Nat
  deriving DecidableEq, Repr

/-- `RSC-26` requires an install request to carry both "the chosen device's stable identifier and
the `inventory_fingerprint` it was chosen from (`WIR-20`)". -/
structure Request where
  identifier  : Identifier
  fingerprint : Nat
  deriving DecidableEq, Repr

/-- What the resolution yields. Every refusal is one value: `RSC-26` says "abort with `integrity` —
before writing a single byte" of all of them. -/
inductive Resolution
  | resolved (device : Device)
  | abortIntegrity
  deriving DecidableEq, Repr

/-- "The identifier is authoritative; the path is derived": the path a write uses is a projection
of the device the identifier resolved to, and is never an input to the resolution. -/
@[req "RSC-26"]
def Resolution.path : Resolution → Option String
  | .resolved d => some d.path
  | .abortIntegrity => none

/-- The devices a stable identifier names in one inventory. -/
def matching (inv : Inventory) (id : Identifier) : List Device :=
  inv.devices.filter (fun d => d.identifier == some id)

/-- `RSC-26`: "The worker MUST re-read the inventory immediately before any disk I/O" and
"abort with `integrity` — before writing a single byte — if the fingerprint differs, if the named
identifier is absent, or if the inventory fails to parse", and "An identifier that does not resolve
to exactly one device MUST abort `integrity` before any write". The inventory this reads is its own
input and not the one the request was chosen from; `none` is the one that "fails to parse". -/
@[req "RSC-26"]
def resolve (req : Request) : Option Inventory → Resolution
  | none => .abortIntegrity
  | some inv =>
    if inv.fingerprint == req.fingerprint then
      match matching inv req.identifier with
      | [d] => .resolved d
      | [] => .abortIntegrity
      | _ :: _ :: _ => .abortIntegrity
    else .abortIntegrity

/-- The design `RSC-26` refuses, definable so that it can be refuted: picking the first match "is
the same coin-flip over which disk gets destroyed that naming `/dev/sda` was". -/
def resolveFirst (req : Request) : Option Inventory → Resolution
  | none => .abortIntegrity
  | some inv =>
    if inv.fingerprint == req.fingerprint then
      match matching inv req.identifier with
      | [] => .abortIntegrity
      | d :: _ => .resolved d
    else .abortIntegrity

/-- "Zero matches is the stale-inventory case". -/
@[req "RSC-26"]
theorem zero_matches_aborts (req : Request) (inv : Inventory)
    (h : matching inv req.identifier = []) : resolve req (some inv) = .abortIntegrity := by
  simp only [resolve]; split <;> simp [h]

/-- "more than one is the dangerous case" — two or more matches abort rather than choosing. -/
@[req "RSC-26"]
theorem duplicate_identifier_aborts (req : Request) (inv : Inventory) (a b : Device)
    (rest : List Device) (h : matching inv req.identifier = a :: b :: rest) :
    resolve req (some inv) = .abortIntegrity := by
  simp only [resolve]; split <;> simp [h]

/-- `RSC-26` aborts "if the fingerprint differs": the request carries the fingerprint it was
chosen from, and the resolution reads a fresh inventory's own. -/
@[req "RSC-26"]
theorem changed_fingerprint_aborts (req : Request) (inv : Inventory)
    (h : inv.fingerprint ≠ req.fingerprint) : resolve req (some inv) = .abortIntegrity := by
  simp [resolve, h]

/-- "or if the inventory fails to parse (`RSC-34` keeps the raw capture)". -/
@[req "RSC-26"]
theorem unparsed_inventory_aborts (req : Request) : resolve req none = .abortIntegrity := rfl

/-- A stale request against a re-ordered inventory never resolves to a different disk than the
identifier names. **Assumption** (`CONTEXT.md`): `huniq` is the physical fact that a stable
identifier is unique to a disk — a WWN is the disk's and the provider's, and nothing in this model
establishes it. Re-ordering is free here: the theorem holds for every inventory, in any order,
whose devices satisfy the hypothesis. -/
@[req "RSC-26"]
theorem resolves_only_the_named_disk (req : Request) (inv : Inventory) (disk : Device)
    (huniq : ∀ d ∈ inv.devices, d.identifier = some req.identifier → d = disk)
    (found : Device) (h : resolve req (some inv) = .resolved found) : found = disk := by
  have hm : matching inv req.identifier = [found] := by
    simp only [resolve] at h
    split at h
    · split at h <;> simp_all
    · simp at h
  have hmem : found ∈ matching inv req.identifier := by rw [hm]; simp
  rw [matching, List.mem_filter] at hmem
  exact huniq found hmem.1 (by simpa using hmem.2)

end Disk

/-! ## The dated amendments

One field per line, because `ci.yml`'s controls match that shape. -/

/-- The guards `OPS-45` and `RSC-19` gained by dated amendment, and the one design `RSC-19` refuses.
`coalesceWrite`: `OPS-45`, 2026-09-12, `ADR-0022` — "The write sets the marker only where it is
null", by "`COALESCE(write_started_at, now)` under the worker guard, never a guard on the marker
being null".
`markerBeforePhase`: `OPS-45`, reworded 2026-09-15 — the marker is written "at the moment a phase
begins that could have altered the machine, and before that phase runs", so it "establishes that
preservation is no longer proven, not that a byte landed". `secondMarkerBeforeSession`: `OPS-45`,
2026-09-16 — "**false, written before begin rescue (`PRV-15`) is dispatched**". `partialCleanupMovesNothing`:
`OPS-45` — "**A driver's report that it cleaned up after a partial activation (`PRV-18`) does not
move this marker**". `persistAtActivation` is not a guard but the design `RSC-19`'s 2026-09-15
paragraph refuses, and it stands `false`: persisting the key from activation is what would cost
`DOM-11`'s exception "a root credential on disk for the whole of every install". -/
structure Params where
  coalesceWrite              : Bool
  markerBeforePhase          : Bool
  secondMarkerBeforeSession  : Bool
  partialCleanupMovesNothing : Bool
  persistAtActivation        : Bool
  deriving DecidableEq, Repr

/-- The rules as they stand. -/
@[req "OPS-45"]
def current : Params := {
    coalesceWrite              := true,
    markerBeforePhase          := true,
    secondMarkerBeforeSession  := true,
    partialCleanupMovesNothing := true,
    persistAtActivation        := false }

/-! ## `OPS-45`'s two markers, on the claim model -/

namespace Install

/-- The four rows of `01-domain-model.md`'s strategy table, under *Image sources and installation
strategies*, where "a *strategy* says how to get it onto the disk"; `DOM-13` pairs each with the
image sources it admits, and `OPS-45`'s own table dates the first marker by them. -/
inductive Strategy
  | rootfsViaRescue | rawDisk | providerNative | providerCatalogue
  deriving DecidableEq, Repr

/-- The rows of `OPS-45`'s table: "This requirement governs the kinds that act on a machine that
already exists — install, rescue inventory, power, reverse DNS, delete and release attachment
(`PRV-45`) — and nothing else", with install split by strategy because the table dates it that
way. -/
inductive Governed
  | install (strategy : Strategy)
  | power | reverseDns | deleteMachine | releaseAttachment
  | rescueInventory
  deriving DecidableEq, Repr

def Governed.all : List Governed :=
  [.install .rootfsViaRescue, .install .rawDisk, .install .providerNative,
   .install .providerCatalogue, .power, .reverseDns, .deleteMachine, .releaseAttachment,
   .rescueInventory]

theorem Governed.mem_all (g : Governed) : g ∈ Governed.all := by
  cases g with
  | install s => cases s <;> decide
  | _ => decide

instance {p : Governed → Prop} [DecidablePred p] : Decidable (∀ g, p g) :=
  decidableForallOfList Governed.all Governed.mem_all p

/-- `WIR-10a`'s kind a governed row belongs to. -/
def Governed.kind : Governed → Kind
  | .install _ => .install
  | .power => .power
  | .reverseDns => .reverseDns
  | .deleteMachine => .deleteMachine
  | .releaseAttachment => .releaseAttachment
  | .rescueInventory => .rescueInventory

/-- `OPS-45`'s scope, as a total function of `WIR-10a`'s enum. It "does **not** reach `create`:
there is no machine yet"; "Nor does it reach `suspend_tenant`, which mutates no provider
(`OPS-11`)"; and a `refresh` is not among the kinds it names. -/
@[req "OPS-45"]
def governs : Kind → Bool
  | .install | .rescueInventory | .power | .reverseDns | .deleteMachine
  | .releaseAttachment => true
  | .createMachine | .suspendTenant | .refresh => false

/-- The scope and the table agree: a kind `OPS-45` governs is a kind with a row, and no other kind
has one. Decided over `WIR-10a`'s enum. -/
@[req "OPS-45"]
theorem governs_iff_a_row_exists :
    ∀ k : Kind, governs k = Governed.all.any (fun g => g.kind == k) := by decide

/-- When `OPS-45`'s table sets the first marker. -/
inductive MarkerPoint
  | installerStarted | firstByte | rebuildDispatched | callDispatched | never
  deriving DecidableEq, Repr

/-- `OPS-45`'s table of when the first marker is set, one row per governed kind, no wildcard:
`rootfs_via_rescue` at "the provider's OS installer is started"; `raw_disk` at "the first byte is
written to the target device (`RSC-28`)"; `provider_native`/`provider_catalogue` when "the
provider's rebuild call is dispatched"; power, reverse DNS, delete and release attachment when "the
provider call is dispatched"; rescue inventory **never** — "it writes nothing to a disk by
construction, so its whole classification turns on the second marker below". -/
@[req "OPS-45"]
def markerPoint : Governed → MarkerPoint
  | .install .rootfsViaRescue => .installerStarted
  | .install .rawDisk => .firstByte
  | .install .providerNative | .install .providerCatalogue => .rebuildDispatched
  | .power | .reverseDns | .deleteMachine | .releaseAttachment => .callDispatched
  | .rescueInventory => .never

/-- The `never` row is rescue inventory's and no other's. Decided. -/
@[req "OPS-45"]
theorem never_is_rescue_inventory_alone :
    ∀ g : Governed, (markerPoint g == .never) = (g == .rescueInventory) := by decide

/-- `OPS-45`, where the first marker "means **the destructive phase was allowed to begin**" rather
than that "a request was dispatched", "which is a fact about this process and not about the
machine" — and, by `RSC-26`, exactly the strategies that name a disk: "This binds every strategy
that names a disk, not only `raw_disk`". -/
@[req "OPS-45"]
def writesToDisk : Governed → Bool
  | .install .rootfsViaRescue | .install .rawDisk => true
  | .install .providerNative | .install .providerCatalogue => false
  | .power | .reverseDns | .deleteMachine | .releaseAttachment => false
  | .rescueInventory => false

/-- One execution of one governed operation. `row` and `mine` are `STO-3`'s guard's inputs; the two
columns carry `Wire.Row`'s spelling and types (`05-persistence.md`), because they are the same two
columns and a third spelling would be a second home. `diskWritten` is the model's fact about the
machine, which no column carries — `Restore.Op.applied` is the same device. -/
structure World where
  row                 : Claim.Row
  mine                : ClaimNumber
  governed            : Governed
  /-- `RSC-26`'s request: the chosen identifier and the fingerprint it was chosen from. -/
  request             : Disk.Request
  /-- The path this execution resolved, derived from the device the identifier named. -/
  target              : Option String
  /-- `RSC-26`'s abort, before any write. -/
  aborted             : Bool
  writeStartedAt      : Option Nat
  rescueExitedCleanly : Option Bool
  /-- The first marker's write was acknowledged by the store (`StoreOutcome.committed true`). -/
  markerAcked         : Bool
  /-- The `false` write before the dispatch was acknowledged. -/
  armAcked            : Bool
  /-- The phase `OPS-45`'s table dates began. -/
  phaseRan            : Bool
  /-- The destructive phase touched the disk. The model's fact, not a column. -/
  diskWritten         : Bool
  /-- `PRV-15`'s begin rescue was dispatched. -/
  sessionDispatched   : Bool
  /-- `STO-3`: a worker that has been overtaken "exits". -/
  exited              : Bool
  /-- The process died. -/
  died                : Bool
  /-- The instant a write takes; one per store write, so a marker that moved would show. -/
  now                 : Nat
  deriving DecidableEq, Repr

/-- The execution is over: `STO-3`'s overtaken worker "exits", the process died, or `RSC-26`'s
abort ended it — "abort with `integrity` — before writing a single byte" and "before any write",
which leaves no later write and no second resolution to make. Every step by which this execution
writes a column, resolves or runs a phase reads this first. The two that do not are the two that
are not this execution's: `.overtaken` is another execution's claim (`OPS-6`) and `.crash` is the
process dying, and both are admitted after the stop. Which is why
`abort_admits_no_write_and_no_resolution` fixes `diskWritten` and `target` and nothing else. -/
def World.stopped (w : World) : Bool := w.exited || w.died || w.aborted

def World.tick (w : World) : World := { w with now := w.now + 1 }

/-- `Claim.workerGuard`'s first branch — `STO-3`'s "(id, status = running, claim_number = mine)" —
as a marker write takes it; `OPS-45` says such a write "is guarded like any other worker write
(`STO-3`)". The claim term is `Claim.holds`, `ADR-0022`'s, and is not re-modelled. The write is not
a `Claim.WorkerWrite` because that structure's `written` field is a `Claim.Written`, which has no
value for a write that leaves the row `running` (`Claim.Written.status_ne_running`), and amending
`Claim.lean` is out of scope — that is where the second home would be when `STO-3` next moves. -/
@[req "STO-3"]
def World.guarded (w : World) : Bool :=
  w.row.status == .running && Claim.holds Claim.current w.row w.mine

/-- `COALESCE(write_started_at, now)`, and nothing at all on the `never` row. That branch is not
redundant with `.markerWrite`'s early return on the same row: `.phase` reaches it as well, on the
branch taken with `markerBeforePhase` off, and it is what keeps
`rescue_inventory_never_sets_the_marker` true for every `Params`. -/
def World.coalesced (w : World) : Option Nat :=
  if markerPoint w.governed == .never then w.writeStartedAt else some (w.writeStartedAt.getD w.now)

/-- What the first marker's write reports. `OPS-45`: the write "MUST report whether it affected a
row — a worker that has been overtaken MUST NOT record that it began writing; it exits". With
`COALESCE` a repeat after a lost reply "affects a row and moves nothing" — and it does so on
`World.guarded`, the first branch, which the repeat still satisfies because this write leaves the
status `running`, so the value it reports is `Claim.WriteResult.moved`. `STO-3`'s own second branch,
whose value is `Claim.WriteResult.repeated`, is not what a repeat takes here: it compares a status
this write does not move. The null-guarded write `ADR-0022` refused "would affect no row and read as
overtaken". -/
@[req "OPS-45"]
def markerResult (p : Params) (w : World) : Claim.WriteResult :=
  if w.guarded then
    match w.writeStartedAt with
    | none => .moved
    | some _ => if p.coalesceWrite then .moved else .zeroRows
  else .zeroRows

inductive Event
  /-- `RSC-26`'s re-read, "immediately before any disk I/O", against a fresh inventory. -/
  | resolveTarget (fresh : Option Disk.Inventory)
  /-- The first marker's write, under the guard. -/
  | markerWrite (outcome : StoreOutcome)
  /-- The phase `OPS-45`'s table dates. `survives = false` is the process dying inside it. -/
  | phase (survives : Bool)
  /-- `COALESCE(rescue_exited_cleanly, false)`, before the begin-rescue dispatch. -/
  | armExit (outcome : StoreOutcome)
  /-- `PRV-15`'s begin rescue. -/
  | beginRescue
  /-- `PRV-18`'s report that the driver cleaned up after a partial activation. -/
  | partialCleanupReported
  /-- `true` on the end-rescue success. -/
  | endRescueSuccess (outcome : StoreOutcome)
  /-- Another execution claims the row, which advances the number (`OPS-6`). -/
  | overtaken
  /-- The process dies. -/
  | crash
  deriving DecidableEq, Repr

/-- The step. Every store write is guarded; every provider call follows the write that precedes it,
"each acknowledged by the store before the provider call it precedes is made". One ordering it
omits: the `rootfsViaRescue` phase is admitted with `sessionDispatched` still `false`, because the
session-to-phase ordering — that installer runs inside the rescue session the dispatch opened — is
not modelled here, and no requirement in this module's scope states it. -/
@[req "OPS-45"]
def step (p : Params) (w : World) : Event → World
  | .resolveTarget fresh =>
    if w.stopped || w.target.isSome then w
    else
      match Disk.resolve w.request fresh with
      | .resolved d => { w with target := some d.path }
      | .abortIntegrity => { w with aborted := true }
  | .markerWrite outcome =>
    if w.stopped || markerPoint w.governed == .never then w
    else
      match markerResult p w with
      | .zeroRows => { w with exited := true }
      | .moved | .repeated =>
        match outcome with
        | .refused => w.tick
        | .committed acked =>
          World.tick { w with writeStartedAt := w.coalesced, markerAcked := w.markerAcked || acked }
  | .phase survives =>
    if w.stopped then w
    else if writesToDisk w.governed && w.target.isNone then w
    else if p.markerBeforePhase && !w.markerAcked then w
    else
      let ran : World :=
        { w with phaseRan := true, diskWritten := w.diskWritten || writesToDisk w.governed }
      if !survives then { ran with died := true }
      else if p.markerBeforePhase then ran.tick
      else World.tick { ran with writeStartedAt := ran.coalesced, markerAcked := true }
  | .armExit outcome =>
    if w.stopped || !p.secondMarkerBeforeSession then w
    else if !w.guarded then { w with exited := true }
    else
      match outcome with
      | .refused => w.tick
      | .committed acked =>
        World.tick { w with rescueExitedCleanly := some (w.rescueExitedCleanly.getD false),
                            armAcked := w.armAcked || acked }
  | .beginRescue =>
    if w.stopped || w.sessionDispatched then w
    else if p.secondMarkerBeforeSession && !w.armAcked then w
    else World.tick { w with sessionDispatched := true }
  | .partialCleanupReported =>
    if w.stopped || !w.sessionDispatched || p.partialCleanupMovesNothing then w
    else { w with rescueExitedCleanly := some true }
  | .endRescueSuccess outcome =>
    if w.stopped || !w.sessionDispatched then w
    else if !w.guarded then { w with exited := true }
    else
      match outcome with
      | .refused => w.tick
      | .committed _ => World.tick { w with rescueExitedCleanly := some true }
  | .overtaken => { w with row := { w.row with claim := ⟨w.row.claim.n + 1⟩ } }
  | .crash => { w with died := true }

def run (p : Params) (w : World) (evs : List Event) : World := evs.foldl (step p) w

/-- A claimed execution of one governed kind, before any of it has run. -/
def begin (governed : Governed) (request : Disk.Request) : World :=
  { row := { status := .running, claim := ⟨1⟩, record := 0, revision := 1 }, mine := ⟨1⟩,
    governed := governed, request := request, target := none, aborted := false,
    writeStartedAt := none, rescueExitedCleanly := none, markerAcked := false, armAcked := false,
    phaseRan := false, diskWritten := false, sessionDispatched := false, exited := false,
    died := false, now := 1 }

/-- `OPS-45`'s two columns as `OPS-11`'s classifier reads them (`Tables.Markers`). The first is the
column's presence. The second is the classifier's two-way reading of a three-valued column: `null`
and `true` both project clean, because `OPS-45` asks whether "no rescue session was opened or the
one that was opened was closed without error" and `null` is the first of those while `true` is the
second; only `false` — "standing while the session is open, where the exit fails and where the
operation dies before reaching it" — answers no. This projection is the seam with `Tables`; the
classification itself is `OPS-11`'s and is not re-modelled here. -/
@[req "OPS-45"]
def markers (w : World) : Markers :=
  { writeStarted := w.writeStartedAt.isSome, rescueClean := w.rescueExitedCleanly != some false }

/-- `OPS-45`'s deterministic branch: "An operation settles `failed` — deterministically, with no
operator and no reconciliation — when the write-started marker is unset *and* either no rescue
session was opened or the one that was opened was closed without error." -/
@[req "OPS-45"]
def classifiedUntouched (m : Markers) : Bool := !m.writeStarted && m.rescueClean

/-- The seam: the projection reaches `installRow`'s deterministic `failed` branch on exactly the
markers `OPS-45`'s sentence names, whatever the error kind — including `integrity`, which is
`RSC-3`'s host-key abort. -/
@[req "OPS-11"]
theorem untouched_is_the_deterministic_failed_branch (m : Markers) (e : ErrorKind)
    (h : classifiedUntouched m = true) : installRow currentRules m e = .failed := by
  simp only [classifiedUntouched, Bool.and_eq_true, Bool.not_eq_true'] at h
  simp [installRow, currentRules, h.1, h.2]

/-! ### Nothing clears them -/

/-- `OPS-45`: "**The markers are per operation, and nothing clears them**", and of the first
"**Write-once, and nothing clears it**" — the `write_started_at` row carrying those words credits
`OPS-45` for them. A set marker keeps its value over every trace — `COALESCE` reads the column it
would write. -/
@[req "OPS-45"]
theorem first_marker_is_write_once (p : Params) (w : World) (t : Nat)
    (h : w.writeStartedAt = some t) (evs : List Event) :
    (run p w evs).writeStartedAt = some t :=
  foldl_preserves (step p) (fun w' => w'.writeStartedAt = some t)
    (fun w' e h' => by
      cases e <;>
        simp only [step, World.coalesced, World.tick] <;>
        (repeat' split) <;>
        simp_all)
    w h evs

/-- `OPS-45`: nothing clears the second marker either — once written it never returns to `null`,
"the only value that means no session was opened". -/
@[req "OPS-45"]
theorem second_marker_never_returns_to_null (p : Params) (w : World)
    (h : w.rescueExitedCleanly ≠ none) (evs : List Event) :
    (run p w evs).rescueExitedCleanly ≠ none :=
  foldl_preserves (step p) (fun w' => w'.rescueExitedCleanly ≠ none)
    (fun w' e h' => by
      cases e <;>
        simp only [step, World.tick] <;>
        (repeat' split) <;>
        simp_all)
    w h evs

/-- `OPS-45`: "`false` moves to `true` and never back." -/
@[req "OPS-45"]
theorem clean_exit_never_moves_back (p : Params) (w : World)
    (h : w.rescueExitedCleanly = some true) (evs : List Event) :
    (run p w evs).rescueExitedCleanly = some true :=
  foldl_preserves (step p) (fun w' => w'.rescueExitedCleanly = some true)
    (fun w' e h' => by
      cases e <;>
        simp only [step, World.tick] <;>
        (repeat' split) <;>
        simp_all)
    w h evs

/-- `OPS-45`: "Null is the only value that means no session was opened". With the arming write
before the dispatch, a null second marker over any trace means no session was opened. The other
direction is not a theorem, and `OPS-45` says so rather than leaving it out: "`false` is the
conservative value as much as the open-session one: a process that dies between that write and the
dispatch leaves `false` over a machine that was never rebooted into rescue", which is
`false_over_a_machine_never_in_rescue`. -/
@[req "OPS-45"]
theorem none_means_no_session (p : Params) (hp : p.secondMarkerBeforeSession = true) (w : World)
    (h1 : w.sessionDispatched = false) (h2 : w.armAcked = false) (evs : List Event) :
    (run p w evs).rescueExitedCleanly = none → (run p w evs).sessionDispatched = false :=
  (foldl_preserves (step p)
    (fun w' => (w'.armAcked = true → w'.rescueExitedCleanly ≠ none) ∧
               (w'.rescueExitedCleanly = none → w'.sessionDispatched = false))
    (fun w' e h' => by
      cases e <;>
        simp only [step, World.tick] <;>
        (repeat' split) <;>
        simp_all)
    w ⟨by simp [h2], fun _ => h1⟩ evs).2

/-! ### The phase is admitted after the marker, and after the resolution -/

/-- `RSC-26`: the destructive phase is admitted only after a resolution succeeded in this same
execution — "The worker MUST re-read the inventory immediately before any disk I/O", and the path
is that resolution's projection. Over every trace. -/
@[req "RSC-26"]
theorem no_write_without_resolution (p : Params) (w : World) (h : w.diskWritten = false)
    (evs : List Event) :
    (run p w evs).diskWritten = true → (run p w evs).target ≠ none :=
  foldl_preserves (step p) (fun w' => w'.diskWritten = true → w'.target ≠ none)
    (fun w' e h' => by
      cases e <;>
        simp only [step, World.tick] <;>
        (repeat' split) <;>
        simp_all <;>
        (try (intro hd; rcases hd with hd | hd <;> simp_all)))
    w (by simp [h]) evs

/-- `RSC-26`'s abort ends the operation: it aborts "before writing a single byte" and "before any
write", so from an aborted world no trace touches the disk and none resolves a target. The abort is
absorbing through `World.stopped`, which every step that writes a column, resolves or runs a phase
reads first. -/
@[req "RSC-26"]
theorem abort_admits_no_write_and_no_resolution (p : Params) (w : World) (h : w.aborted = true)
    (evs : List Event) :
    (run p w evs).diskWritten = w.diskWritten ∧ (run p w evs).target = w.target :=
  (foldl_preserves (step p)
    (fun w' => w'.aborted = true ∧ w'.diskWritten = w.diskWritten ∧ w'.target = w.target)
    (fun w' e h' => by
      cases e <;>
        simp only [step, World.stopped, World.tick] <;>
        (repeat' split) <;>
        simp_all)
    w ⟨h, rfl, rfl⟩ evs).2

/-- `OPS-45`: the marker is written "before that phase runs", so an execution whose phase ran — the
destructive one, or the dispatch — has the first marker set in every later state. -/
@[req "OPS-45"]
theorem phase_implies_marker_set (p : Params) (hp : p.markerBeforePhase = true) (w : World)
    (h0 : w.phaseRan = false) (h1 : w.markerAcked = false) (evs : List Event) :
    (run p w evs).phaseRan = true → (run p w evs).writeStartedAt ≠ none :=
  (foldl_preserves (step p)
    (fun w' => (w'.markerAcked = true → w'.writeStartedAt ≠ none) ∧
               (w'.phaseRan = true → w'.writeStartedAt ≠ none))
    (fun w' e h' => by
      cases e <;>
        simp only [step, World.coalesced, World.tick] <;>
        (repeat' split) <;>
        simp_all)
    w ⟨by simp [h1], by simp [h0]⟩ evs).2

/-- The acceptance the epic states: an operation whose destructive phase ran is never classified
untouched. Projected into `Tables.Markers` it never reaches `installRow`'s deterministic `failed`
branch, whatever error kind the driver reports. -/
@[req "OPS-45"]
theorem written_disk_is_never_classified_untouched (p : Params) (hp : p.markerBeforePhase = true)
    (governed : Governed) (request : Disk.Request) (evs : List Event)
    (h : (run p (begin governed request) evs).diskWritten = true) :
    classifiedUntouched (markers (run p (begin governed request) evs)) = false := by
  have hphase : (run p (begin governed request) evs).phaseRan = true := by
    revert h
    exact (foldl_preserves (step p) (fun w' => w'.diskWritten = true → w'.phaseRan = true)
      (fun w' e h' => by
        cases e <;>
          simp only [step, World.tick] <;>
          (repeat' split) <;>
          simp_all)
      (begin governed request) (by simp [begin]) evs)
  have := phase_implies_marker_set p hp (begin governed request) rfl rfl evs hphase
  simp only [classifiedUntouched, markers, Bool.and_eq_false_iff, Bool.not_eq_false']
  left
  exact Option.isSome_iff_ne_none.mpr this

/-- `OPS-45`'s `never` row: rescue inventory "writes nothing to a disk by construction", so no
trace of one sets the first marker, and "its whole classification turns on the second marker". -/
@[req "OPS-45"]
theorem rescue_inventory_never_sets_the_marker (p : Params) (w : World)
    (h : w.governed = .rescueInventory) (evs : List Event) :
    (run p w evs).writeStartedAt = w.writeStartedAt :=
  foldl_preserves (step p)
    (fun w' => w'.governed = .rescueInventory ∧ w'.writeStartedAt = w.writeStartedAt)
    (fun w' e h' => by
      cases e <;>
        simp only [step, World.coalesced, World.tick] <;>
        (repeat' split) <;>
        simp_all [markerPoint])
    w ⟨h, rfl⟩ evs |>.2

/-- `OPS-45`, of a worker's write of either marker: it "MUST report whether it affected a row — a
worker that has been overtaken MUST NOT record that it began writing; it exits". `STO-3` owns the
guard this reads, which `World.guarded`'s tag says. -/
@[req "OPS-45"]
theorem overtaken_worker_records_nothing (p : Params) (w : World) (o : StoreOutcome)
    (h : w.guarded = false) (hs : w.stopped = false)
    (hn : markerPoint w.governed ≠ .never) :
    (step p w (.markerWrite o)).writeStartedAt = w.writeStartedAt ∧
    (step p w (.markerWrite o)).exited = true := by
  simp [step, markerResult, h, hs, hn]

/-- What connects `Install.Event.overtaken` to the sentence above, and what makes `World.guarded`'s
claim term load-bearing: the overtaking advances the row's claim number (`OPS-6`), the guard's
claim term then fails, and the marker write that follows records nothing and exits — "a worker that
has been overtaken MUST NOT record that it began writing; it exits". Delete the term from
`World.guarded`, or make `.overtaken` a no-op, and this is the declaration that goes red.
**Assumption** (`CONTEXT.md`): `hc` is `STO-3`'s claim term, named on the signature as
`Claim.lean`'s own theorems name it (`Claim.stale_write_inert`'s `hg`) rather than evaluated here.
The term is `ADR-0022`'s parameter and `ci.yml` flips it to prove one witness red; a `decide` of
`Claim.current`'s field in this module would be a second red on that control, and this property
holds under the guard's own term either way. -/
@[req "OPS-45"]
theorem overtaken_unguards (p : Params) (w : World) (o : StoreOutcome) (h : w.guarded = true)
    (hc : Claim.current.claimTerm = true) (hs : w.stopped = false)
    (hn : markerPoint w.governed ≠ .never) :
    (step p w .overtaken).guarded = false ∧
    (step p (step p w .overtaken) (.markerWrite o)).writeStartedAt = w.writeStartedAt ∧
    (step p (step p w .overtaken) (.markerWrite o)).exited = true := by
  obtain ⟨hstatus, hclaim⟩ : w.row.status = .running ∧ w.row.claim = w.mine := by
    simpa [World.guarded, Claim.holds, hc] using h
  have hne : ({ n := w.mine.n + 1 } : ClaimNumber) ≠ w.mine := fun hm =>
    Nat.succ_ne_self w.mine.n (congrArg ClaimNumber.n hm)
  have hg : (step p w .overtaken).guarded = false := by
    simp [step, World.guarded, Claim.holds, hc, hstatus, hclaim, hne]
  have hs' : (step p w .overtaken).stopped = false := by simpa [step, World.stopped] using hs
  have hn' : markerPoint (step p w .overtaken).governed ≠ .never := by simpa [step] using hn
  exact ⟨hg, by simpa [step] using overtaken_worker_records_nothing p _ o hg hs' hn'⟩

end Install

/-! ## Rescue exit and the recovery key: `RSC-19` -/

namespace Session

/-- `RSC-10`: "The rescue keypair MUST be generated per operation and MUST NOT be reused." The key
is tagged by the operation it was generated for, so two operations' keys are two values. -/
structure RecoveryKey where
  operation : OperationId
  deriving DecidableEq, Repr

/-- `RSC-10`, as the tagging makes it: no two operations share a key. -/
@[req "RSC-10"]
theorem keys_are_per_operation (a b : OperationId) (h : a ≠ b) :
    RecoveryKey.mk a ≠ RecoveryKey.mk b := by
  intro hk; exact h (congrArg RecoveryKey.operation hk)

/-- What `RSC-19` permits to be written: "**The key is the only part of the session that may be
written**". A provider-supplied rescue password "is **never** persisted — it is the provider's to
reset", and this type has no field for one, which is how the model says never. The file is "named
by the operation id"; `RSC-20`'s directory is a deployment fact and is not modelled. -/
structure Persisted where
  key : RecoveryKey
  deriving DecidableEq, Repr

/-- `WIR-9a`'s `rescue_exit`, whose wire spelling of the first value is `none`; it is `noSession`
here so that it does not read as `Option.none`. -/
inductive RescueExit
  | noSession | clean | unknown
  deriving DecidableEq, Repr

/-- `RSC-19`'s error details. "The record carries neither the key nor its path: the location is the
directory joined to an id every operator surface already shows" — this type has no field for
either. -/
structure ErrorDetails where
  rescueExit    : RescueExit
  rescueAddress : Option String
  rescuePort    : Option Nat
  deriving DecidableEq, Repr

/-- One operation's rescue session. `rescueExitedCleanly` is `OPS-45`'s second marker on this
operation's row, in `Wire.Row`'s spelling; `uncertain` is `RSC-19`'s branch condition, "activation
failed ambiguously, or the exit failed". `uncertain` is sticky, and deliberately: an ambiguous
activation followed by a successful exit renders `clean` with the key still on disk, which is
`RSC-21`'s operator's to remove "once recovery is complete", so
`cleanup_unreachable_while_ambiguous` keys on this field and not on the rendered exit. -/
structure World where
  operation            : OperationId
  address              : String
  port                 : Nat
  keyOnDisk            : Option Persisted
  /-- `PRV-21`'s temporary provider-side credential, registered at activation and found "by its
  operation-id tag" where the call never reached it (`PRV-9`). -/
  credentialRegistered : Bool
  rescueExitedCleanly  : Option Bool
  dispatched           : Bool
  /-- The one end-rescue call this operation makes. -/
  exitAttempted        : Bool
  uncertain            : Bool
  /-- The `needs_reconciliation` record was closed: recovery is complete (`RSC-21`). -/
  resolved             : Bool
  status               : Claim.Status
  /-- The engine died. -/
  dead                 : Bool
  deriving DecidableEq, Repr

/-- `WIR-9a`: "`none` only where no rescue session was opened, `clean` where the driver's end-rescue
call returned success, `unknown` where it failed or the operation died before reaching it —
`OPS-45`'s second marker, rendered as `disk_effect` renders the first." `OPS-15`'s pass renders it
from the column, which is why `false` precedes the session. `RSC-19` requires `unknown` on its own
branch; the three values and their conditions are `WIR-9a`'s. -/
@[req "WIR-9a"]
def rescueExit (w : World) : RescueExit :=
  match w.rescueExitedCleanly with
  | none => .noSession
  | some true => .clean
  | some false => .unknown

/-- `RSC-19`: the error details "MUST carry `rescue_exit: "unknown"` with the rescue address and
port (`WIR-9a`)"; `WIR-9a` carries the address and port with `unknown` alone. -/
@[req "RSC-19"]
def details (w : World) : ErrorDetails :=
  match rescueExit w with
  | .unknown => { rescueExit := .unknown, rescueAddress := some w.address,
                  rescuePort := some w.port }
  | .clean => { rescueExit := .clean, rescueAddress := none, rescuePort := none }
  | .noSession => { rescueExit := .noSession, rescueAddress := none, rescuePort := none }

inductive Event
  /-- `OPS-45`'s `false`, before the dispatch. -/
  | armExit
  /-- `PRV-15`'s begin rescue. `ambiguous` is the activation that "failed ambiguously" (`RSC-19`). -/
  | beginRescue (ambiguous : Bool)
  /-- A command run over the session's connection. -/
  | remoteCommand
  /-- `PRV-21`'s end rescue. `succeeded = false` is `PRV-22`'s failure, "*always* ambiguous". -/
  | endRescue (succeeded : Bool)
  /-- The engine crashes: "An engine crash persists nothing". The step writes
  `needs_reconciliation` itself, standing in for a write `RSC-19` credits elsewhere — "`OPS-15`
  moves the operation to `needs_reconciliation`" — which is the startup pass's, `Restore.lean`'s
  subject, and is not modelled here. -/
  | crash
  /-- `OPS-32`'s sweep removes the tagged provider-side credential (`PRV-21`, `PRV-18`, `PRV-9`). -/
  | sweepRemovesCredential
  /-- The operator removes a persisted recovery key (`RSC-21`). -/
  | operatorRemovesKey
  /-- The operator closes the record: recovery is complete. -/
  | recoveryComplete
  deriving DecidableEq, Repr

/-- The step. `RSC-19`'s branch writes the key on the uncertain paths and on no other; the crash
writes nothing; `RSC-21`'s removal is the operator's and waits for recovery. -/
@[req "RSC-19"]
def step (p : Params) (w : World) : Event → World
  | .armExit =>
    if w.dead || !p.secondMarkerBeforeSession then w
    else { w with rescueExitedCleanly := some (w.rescueExitedCleanly.getD false) }
  | .beginRescue ambiguous =>
    if w.dead || w.dispatched then w
    else if p.secondMarkerBeforeSession && w.rescueExitedCleanly == none then w
    else
      { w with dispatched := true, credentialRegistered := true,
               uncertain := w.uncertain || ambiguous,
               keyOnDisk := if p.persistAtActivation || ambiguous then some ⟨⟨w.operation⟩⟩
                            else w.keyOnDisk }
  | .remoteCommand => w
  | .endRescue succeeded =>
    if w.dead || !w.dispatched || w.exitAttempted then w
    else if succeeded then
      { w with exitAttempted := true, rescueExitedCleanly := some true,
               credentialRegistered := false }
    else
      { w with exitAttempted := true, uncertain := true, keyOnDisk := some ⟨⟨w.operation⟩⟩ }
  | .crash => { w with dead := true, status := .needsReconciliation }
  | .sweepRemovesCredential => { w with credentialRegistered := false }
  | .operatorRemovesKey => if w.resolved then { w with keyOnDisk := none } else w
  | .recoveryComplete => { w with resolved := true }

def run (p : Params) (w : World) (evs : List Event) : World := evs.foldl (step p) w

/-- A session about to be opened for one operation: no key written, no credential registered, the
operation running. -/
def begin (operation : OperationId) (address : String) (port : Nat) : World :=
  { operation := operation, address := address, port := port, keyOnDisk := none,
    credentialRegistered := false, rescueExitedCleanly := none, dispatched := false,
    exitAttempted := false, uncertain := false, resolved := false, status := .running,
    dead := false }

/-- `RSC-19`: the key is written on the uncertain branch and nowhere else — never at activation,
never on a clean exit. Over every trace, with the refused design off. -/
@[req "RSC-19"]
theorem key_persisted_only_when_uncertain (p : Params) (hp : p.persistAtActivation = false)
    (operation : OperationId) (address : String) (port : Nat) (evs : List Event) :
    (run p (begin operation address port) evs).keyOnDisk ≠ none →
    (run p (begin operation address port) evs).uncertain = true :=
  foldl_preserves (step p) (fun w => w.keyOnDisk ≠ none → w.uncertain = true)
    (fun w e h => by
      cases e <;>
        simp only [step] <;>
        (repeat' split) <;>
        simp_all)
    (begin operation address port) (by simp [begin]) evs

/-- "An engine crash persists nothing": once the process is dead no trace puts a key on disk.
The operator's `RSC-21` removal is admitted after the crash and only takes a key away. -/
@[req "RSC-19"]
theorem dead_engine_persists_nothing (p : Params) (w : World) (hd : w.dead = true)
    (h0 : w.keyOnDisk = none) (evs : List Event) : (run p w evs).keyOnDisk = none :=
  (foldl_preserves (step p) (fun w' => w'.dead = true ∧ w'.keyOnDisk = none)
    (fun w' e h => by
      cases e <;>
        simp only [step] <;>
        (repeat' split) <;>
        simp_all)
    w ⟨hd, h0⟩ evs).2

/-- `RSC-19`: on a crash "the provider-side credential `PRV-21` would have removed stays
registered", until `OPS-32`'s sweep removes it by tag. -/
@[req "PRV-21"]
theorem crash_leaves_the_credential_registered (p : Params) (w : World) (hd : w.dead = true)
    (hc : w.credentialRegistered = true) (evs : List Event)
    (h : Event.sweepRemovesCredential ∉ evs) :
    (run p w evs).credentialRegistered = true := by
  induction evs generalizing w with
  | nil => exact hc
  | cons e es ih =>
    simp only [List.mem_cons, not_or] at h
    exact ih (w := step p w e)
      (by cases e <;> simp_all [step] <;> (repeat' split) <;> simp_all)
      (by cases e <;> simp_all [step] <;> (repeat' split) <;> simp_all) h.2

/-- The acceptance the epic states, and `RSC-19`'s own rule: while rescue exit is ambiguous and the
record is not resolved, no event the engine runs takes the persisted key away. The only removal is
the operator's, and `RSC-21` admits it "once recovery is complete". -/
@[req "RSC-21"]
theorem cleanup_unreachable_while_ambiguous (p : Params) (w : World)
    (hu : w.uncertain = true) (hk : w.keyOnDisk = some ⟨⟨w.operation⟩⟩)
    (hr : w.resolved = false) (evs : List Event) (h : Event.recoveryComplete ∉ evs) :
    (run p w evs).keyOnDisk = some ⟨⟨w.operation⟩⟩ ∧ (run p w evs).uncertain = true ∧
      (run p w evs).resolved = false := by
  induction evs generalizing w with
  | nil => exact ⟨hk, hu, hr⟩
  | cons e es ih =>
    simp only [List.mem_cons, not_or] at h
    have hop : (step p w e).operation = w.operation := by
      cases e <;> simp_all [step] <;> (repeat' split) <;> simp_all
    have hstep : (step p w e).keyOnDisk = some ⟨⟨(step p w e).operation⟩⟩ ∧
        (step p w e).uncertain = true ∧ (step p w e).resolved = false := by
      rw [hop]; cases e <;> simp_all [step] <;> (repeat' split) <;> simp_all
    have hrun := ih (w := step p w e) hstep.2.1 hstep.1 hstep.2.2 h.2
    rw [hop] at hrun
    exact hrun

/-- `RSC-21`: a key is removable "once recovery is complete", and the operator's removal is what
removes it. The model refuses nothing forever. -/
@[req "RSC-21"]
theorem operator_removes_once_recovered (p : Params) (w : World) (k : Persisted)
    (hk : w.keyOnDisk = some k) (hr : w.resolved = false) :
    (run p w [.operatorRemovesKey]).keyOnDisk = some k ∧
    (run p w [.recoveryComplete, .operatorRemovesKey]).keyOnDisk = none := by
  simp [run, step, hk, hr]

end Session

end Provisiond.Rescue
