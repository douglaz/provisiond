import Provisiond.Types
import Provisiond.Ledger
import Provisiond.Meter
/-! Funding and the tenant lifecycle: the money-in path from a deposit's two destinations to a
`topup` entry, the tenant that entry belongs to, the operator's re-attribution of it, and the
one metered subject whose increments the ledger pairs — composed on `Provisiond.Ledger`'s clamp
and `Provisiond.Meter`'s recurrence so that a `correction`'s effect on the meter is a theorem
about both.

The entries list is the ledger — `LDG-5`, "Balance is the sum of entries and nothing else" — and
`STO-46`'s `payments` rows stand beside it, one per settlement, written by the one step
`STO-30` requires: "A settled payment MUST credit its ledger entry and record the payment in
**one** transaction". `credit` is that step and `payments_match_topups` is what it buys: every
reachable state carries as many `payments` rows as `topup` entries.

Rail identity. `STO-46`'s `payment_ref` is "the payment's own identity at the rail — the payment
hash, or the outpoint", and `LDG-8` derives the `topup`'s idempotency key from it. `Params.keyFrom`
names what the key is derived from, with `STO-31`'s two prohibitions as its other values — "never
from the observation event, and never from the deposit, which may legitimately produce two
credits (`LDG-55`)". `Params.paymentRecordUnique` is `STO-46`'s row, 2026-09-02 (`LDG-43`'s
amendment of that date is what added it), whose `payment_ref` is "what makes a replayed
settlement a no-op (`STO-31`)": with it, no second `payments` row carries a reference already
recorded, whatever key the entry took. `credit_idempotent` is the rule. The two guards overlap on
an immediate replay, so each witness pins the other off to decide on its own: the ledger key
alone refuses the replay under `.payment` and admits it under `.observation`; the record alone
refuses it whatever the key, and refuses the re-scan that arrives after an attribution moved the
first credit — the case the ledger key cannot see, since the target tenant's ledger carries no key for it.
The `.deposit` key is the one the record does not save: the second rail's reference is new.

Expiry, in its two senses. `LDG-57`: "A deployment MUST watch only unexpired deposits'
addresses" — `Deposit.watched`, what `settle` (the watcher) reads. `LDG-51`: "Expiry ends
watching; the binding outlives it" — `lateOnchain` is a payment "brought to the operator's
attention" after expiry, credited through the same binding. `LDG-54`: "A Lightning invoice
enforces its own expiry: after it, the payment cannot be made" — so no late Lightning event
exists, and `lightning_paid_before_expiry` is the invariant.

The tenant. `API-34` reaps a pending tenant, and "a tenant MUST NOT be deleted while any deposit
of its own remains inside that window" — the deposit expiry plus the on-chain finality window —
which is `Params.reapWaitsForWindow`; "of its own" is read as a deposit that resolves to the
tenant (`Deposit.creditedTenant`), so that an attributed deposit's later payment is covered too,
and `API-42`'s "in flight" as inside that window. `API-58` says "A funded tenant MUST be
suspended, never deleted", so `reap` refuses an active one. `LDG-43`: a payment for a tenant that
no longer exists "MUST be recorded as unattributed and MUST NOT be silently dropped", and "A
payment is unattributed exactly when no live `tenants` row bears the identifier it was credited
to — a join, not a flag": `unattributed` is that join and `credit` appends the entry whatever the
join says. `STO-46`: "`DOM-1`'s never-reused identifier is what makes the join safe" — `World.retired`
keeps every reaped identifier and `enrol` refuses it. `LDG-52`: activation is on the "cumulative
credited balance".

Attribution. `WIR-42` credits "a deposit whose tenant was reaped" to a live tenant "by posting one
`correction` pair per settled payment", "each a negative entry naming the original credit it
corrects and a positive one to the named tenant, keyed on" "`correction:` followed by that
payment's reference". `Params.correctionPrefix` is the 2026-09-05 prefix: "Keyed on the bare payment
identity, the negative entry collided with the source tenant's own `topup`", and the model's
collision is a refused insert that rolls the transaction back. The target is persisted on the
deposit, so a payment settling afterwards "is credited to that tenant directly as an ordinary
`topup`" (`LDG-43`); a second call is idempotent per deposit.

The meter. `post` is one increment of the one subject, `World.subject`, closing at its end instant:
`Meter.postedDebit` computes it, `Ledger.clamp` splits it, `r` advances by the computed debit —
`LDG-38`: "`r` advances by `posted_debit_i` regardless, because the recurrence is stated over what
the meter computed and never mentions the entry at all" — and the overflow is a `Deficiency` record,
`STO-37`'s `clamp_overflow`, with `absorbed_seconds` zero (`LDG-66`). The entry's key is `usageKey`,
`LDG-8`'s "`(subject, billing period, kind, increment end)`", and `Params.usageKeyFrom` keeps the
withdrawn posting index as its other value. `World.mark` is `LDG-38`'s "greatest `increment end`
already posted", advanced with `r` whether or not an entry posts — `LDG-72`'s record, written
"without a ledger entry but with any deficiency `STO-45` requires where the increment rounds or
clamps to nothing" — and `Params.markDiscards` is its discard. The key refuses only an insert, so
the key and the mark overlap on a replay that writes an entry, and the key's witness pins the
discard off; the mark's witness takes cases the stated key admits: the replay of an increment that
wrote no entry, which left no key to collide with, and a re-meter ending below the mark, whose key
is new. `post_replay_discarded` is the rule and `mark_covers_every_key` is `LDG-72`'s one-sided
check. `clamp_never_touches_credit_past_the_mark` and `clamp_overflow_is_a_record_past_the_mark`
state the clamp theorems under premises that do not read the clamp's outcome.
`attribution_leaves_meter_untouched` and `correction_then_post_posts_the_same` are "A `correction`
leaves the meter's state untouched" on the composed model.

Omitted, and where: `LDG-35`'s serialization and the two-tenant lock order of an attribution
(`Provisiond.Ledger` carries the stale read); `LDG-7`'s two fee kinds, which pair like the usage
debit — `Kind` lists them, nothing here constructs them; `LDG-47`'s received-versus-requested
amount — `sats` here is the settled value; `LDG-48`'s confirmation depth, folded into the
settlement event; `LDG-52`'s rail floor; `LDG-56`'s disclosure; `WIR-42`'s `operator_ref` and its
`409` on a second tenant, which the model refuses silently; `LDG-66`'s "provider-native amount
and currency (`LDG-2`)" and rate on the deficiency record — `Deficiency` carries the satoshi
figure and the absorbed time only; `LDG-38`'s 2026-09-04 clause, "The subject's billability and its
stop boundary MUST be re-read inside the same `LDG-35` serialization that appends, and the increment
clipped to them" — `post` takes the increment's exact charge, so there are no seconds to clip, and
`LDG-74`'s stop is `Provisiond.Reconcile`'s `World.meterStoppedAt`, in a module that posts no money
and that this one does not import; the subject's own commitment opening and close
(`Provisiond.Ledger`); a second subject; `LDG-68`'s period boundary (`Provisiond.Period`), and
with it `LDG-38`'s "new period's `meter_totals` row starts with `r = 0`"; `API-34`'s cap, "A pending
tenant's deposit expiry MUST be capped at its remaining signup time-to-live" — `mint` accepts any
expiry; `API-58`'s `suspended` state — `Status` is pending or active; the attribution of a live
tenant's deposit, which `WIR-42` does not describe and the model refuses; and every provider-side
fact. -/

open Std

namespace Provisiond.Funding

structure DepositId where n : Nat deriving DecidableEq, Repr
/-- `STO-46`'s `payment_ref`: the payment hash, or the outpoint. -/
structure PaymentRef where n : Nat deriving DecidableEq, Repr
/-- An entry's position in the ledger: `LDG-6`'s stable id. -/
structure EntryId where n : Nat deriving DecidableEq, Repr
/-- Never constructed here: it exists so that `Subject` cannot collapse to a machine id — `LDG-8`
and `STO-38`, quoted on `Subject`. -/
structure AttachmentId where n : Nat deriving DecidableEq, Repr

/-- `LDG-8`'s *subject*, "the machine or an individual billable attachment": never the tenant it
bills, and never its machine for an attachment — `STO-38`, "A deployment MUST NOT substitute
`machine_id` for the subject". -/
inductive Subject
  | machine (m : MachineId)
  | attachment (a : AttachmentId)
  deriving DecidableEq, Repr

/-- `LDG-46`: "the payer selects it at payment time". -/
inductive Rail
  | lightning
  | onchain
  deriving DecidableEq, Repr

inductive Status
  | pending
  | active
  deriving DecidableEq, Repr

structure Tenant where
  id     : TenantId
  status : Status
  deriving DecidableEq, Repr

/-- `STO-29`'s row: never deleted, and `attributedTo` is `WIR-42`'s persisted target. -/
structure Deposit where
  id           : DepositId
  tenant       : TenantId
  expiresAt    : Nat
  attributedTo : Option TenantId
  deriving DecidableEq, Repr

/-- `LDG-7`'s closed list; the two fee kinds are never constructed here (the module docstring). -/
inductive Kind
  | topup
  | usageDebit
  | setupFeeDebit
  | operationFeeDebit
  | correction
  deriving DecidableEq, Repr

/-- `LDG-8`'s idempotency key, "unique within the tenant", as the thing it is derived from.
`payment` is the rule; `observation` and `deposit` are `STO-31`'s two "never"s; `correction` is
`WIR-42`'s prefixed key; `usage` is the `usage_debit`'s, "`(subject, billing period, kind,
increment end)`"; `postingIndex` is that key's withdrawn form (`UsageKeySource.postingIndex`). -/
inductive Key
  | payment (ref : PaymentRef)
  | observation (n : Nat)
  | deposit (d : DepositId)
  | correction (ref : PaymentRef)
  | usage (subject : Subject) (period : Nat) (kind : Kind) (incrementEnd : Nat)
  | postingIndex (n : Nat)
  deriving DecidableEq, Repr

/-- `LDG-6`'s entry, with `LDG-43`'s `deposit_id` and `LDG-5`'s "naming the entry it corrects". -/
structure Entry where
  tenant   : TenantId
  kind     : Kind
  sats     : Int
  key      : Key
  deposit  : Option DepositId
  corrects : Option EntryId
  deriving DecidableEq, Repr

/-- `STO-46`'s row: the rail "discovered, not assigned", the settled value, the entry it
produced, and the tenant credited "at the time", "which a later attribution MUST NOT rewrite". -/
structure Payment where
  ref            : PaymentRef
  deposit        : DepositId
  rail           : Rail
  sats           : Int
  entry          : EntryId
  creditedTenant : TenantId
  observedAt     : Nat
  deriving DecidableEq, Repr

/-- `STO-37`'s `clamp_overflow` record: the satoshi remainder the clamp wrote off, and the
absorbed time, "zero for every cause but `rate_outage`" (`LDG-66`). Not an entry. -/
structure Deficiency where
  clampedSats     : Int
  absorbedSeconds : Nat
  deriving DecidableEq, Repr

inductive KeySource
  | payment
  | observation
  | deposit
  deriving DecidableEq, Repr

/-- What a `usage_debit`'s key is derived from. -/
inductive UsageKeySource
  /-- `LDG-8`: "The key is derived from the thing being billed, never from a count of what has
  already been posted". -/
  | incrementEnd
  /-- The withdrawn form, retained for the trap behind it — `LDG-8`: "A 'posting index' counted
  from the ledger was the withdrawn form, and it cannot deduplicate at all: a second run reads one
  more prior debit, derives the next index, and its insert succeeds — double-charging the tenant
  and double-decrementing the commitment." Here the index is the entry count. -/
  | postingIndex
  deriving DecidableEq, Repr

/-- The rules this module carries as parameters. `keyFrom`: `LDG-8`, `STO-31`. `correctionPrefix`:
`WIR-42`, 2026-09-05. `paymentRecordUnique`: `STO-46`, 2026-09-02, `payment_ref` "not null,
unique". `reapWaitsForWindow`: `API-34`'s floor, "The TTL MUST exceed the deposit expiry" "plus
the maximum on-chain finality window", "and a tenant MUST NOT be deleted while any deposit of its
own remains inside that window". `usageKeyFrom`: `LDG-8`, the `usage_debit`'s key. `markDiscards`:
`LDG-38`, "an increment whose end instant is at or before that mark MUST be discarded, not
posted" — the discard only; the mark is recorded either way. -/
structure Params where
  keyFrom             : KeySource
  correctionPrefix    : Bool
  paymentRecordUnique : Bool
  reapWaitsForWindow  : Bool
  usageKeyFrom        : UsageKeySource
  markDiscards        : Bool
  deriving DecidableEq, Repr

/-- The rules as they stand. One field per line: `ci.yml`'s controls flip one each. -/
@[req "LDG-8"]
def current : Params := {
    keyFrom             := .payment,
    correctionPrefix    := true,
    paymentRecordUnique := true,
    reapWaitsForWindow  := true,
    usageKeyFrom        := .incrementEnd,
    markDiscards        := true }

structure World where
  now           : Nat
  /-- `API-34`'s "maximum on-chain finality window", a deployment parameter. -/
  finality      : Nat
  /-- `LDG-44`'s activation minimum. -/
  activationMin : Int
  tenants       : List Tenant
  /-- `DOM-1`: "never reused" — every identifier `reap` retired. -/
  retired       : List TenantId
  deposits      : List Deposit
  payments      : List Payment
  entries       : List Entry
  deficiencies  : List Deficiency
  /-- The one metered subject and its one open billing period, the tenant it bills, what remains
  of its open commitment, `LDG-38`'s rounding credit `r`, and its high-water mark, `none` before
  its first increment. -/
  subject        : Subject
  period         : Nat
  tenant         : TenantId
  remaining      : Int
  roundingCredit : Rat
  mark           : Option Nat
  deriving DecidableEq, Repr

/-- A live `tenants` row bears the identifier. -/
def World.live (w : World) (t : TenantId) : Bool := w.tenants.any (·.id = t)

def World.findDeposit (w : World) (d : DepositId) : Option Deposit := w.deposits.find? (·.id = d)

/-- `LDG-49`: "the credit MUST be posted against that binding" — the tenant a payment at this
deposit is credited to, "the deposit's `attributed_tenant_id` where one is set", "otherwise the
deposit's own tenant" (`STO-46`, `WIR-42`). Reads no clock. -/
@[req "LDG-49"]
def Deposit.creditedTenant (d : Deposit) : TenantId := d.attributedTo.getD d.tenant

/-- `LDG-57`: the watch set is the unexpired deposits. -/
@[req "LDG-57"]
def Deposit.watched (d : Deposit) (now : Nat) : Bool := decide (now < d.expiresAt)

/-- `API-34`: inside the window, "the deposit expiry" "plus the maximum on-chain finality window". -/
@[req "API-34"]
def Deposit.inWindow (d : Deposit) (w : World) : Bool := decide (w.now < d.expiresAt + w.finality)

/-- `LDG-5`: one tenant's balance is the sum of its entries. -/
@[req "LDG-5"]
def sumFor (t : TenantId) (es : List Entry) : Int :=
  (es.filter (fun e => decide (e.tenant = t))).map (·.sats) |>.sum

/-- `LDG-17`'s float, as the ledger carries it: every tenant's entries summed. -/
def float (es : List Entry) : Int := (es.map (·.sats)).sum

/-- `LDG-9`, for the one subject: its tenant's entries less the one open commitment. -/
@[req "LDG-9"]
def World.available (w : World) : Int := sumFor w.tenant w.entries - w.remaining

/-- `LDG-8`: "unique within the tenant". -/
def hasKey (w : World) (t : TenantId) (k : Key) : Bool :=
  w.entries.any (fun e => e.tenant = t && e.key = k)

/-- `LDG-43`'s join: "no live `tenants` row bears the identifier it was credited to". -/
@[req "LDG-43"]
def World.unattributed (w : World) (e : Entry) : Bool := !w.live e.tenant

/-- The `topup`'s key, from what the parameter says. -/
@[req "LDG-8"]
def topupKey (p : Params) (w : World) (d : DepositId) (ref : PaymentRef) : Key :=
  match p.keyFrom with
  | .payment => .payment ref
  | .observation => .observation w.entries.length
  | .deposit => .deposit d

/-- The `usage_debit`'s key, from what the parameter says. -/
@[req "LDG-8"]
def usageKey (p : Params) (w : World) (incrementEnd : Nat) : Key :=
  match p.usageKeyFrom with
  | .incrementEnd => .usage w.subject w.period .usageDebit incrementEnd
  | .postingIndex => .postingIndex w.entries.length

/-- `LDG-72`'s high-water check: "The mark MUST be **at least** the greatest `increment end`
encoded in any `usage_debit` idempotency key for that `(subject, billing period)`". -/
@[req "LDG-72"]
def World.markCovers (w : World) : Prop :=
  ∀ e ∈ w.entries, ∀ n, e.key = .usage w.subject w.period .usageDebit n →
    ∃ m, w.mark = some m ∧ n ≤ m

/-- `LDG-52`: "activation MUST occur atomically the moment that cumulative total reaches it". -/
@[req "LDG-52"]
def activate (w : World) (t : TenantId) : World :=
  { w with tenants := w.tenants.map fun tn =>
      if tn.id = t && decide (w.activationMin ≤ sumFor t w.entries) then { tn with status := .active }
      else tn }

/-- `STO-30`'s one transaction: the `topup` and its `payments` row, or — the key already on the
tenant's ledger, or the reference already recorded — neither. `LDG-47`: `sats` is what arrived. -/
@[req "STO-30"]
def credit (p : Params) (w : World) (d : Deposit) (ref : PaymentRef) (rail : Rail) (sats : Int) :
    World :=
  let t := d.creditedTenant
  let k := topupKey p w d.id ref
  if hasKey w t k || (p.paymentRecordUnique && w.payments.any (·.ref = ref)) then w else
  let e : Entry := { tenant := t, kind := .topup, sats := sats, key := k, deposit := some d.id,
                     corrects := none }
  let pm : Payment := { ref := ref, deposit := d.id, rail := rail, sats := sats,
                        entry := ⟨w.entries.length⟩, creditedTenant := t, observedAt := w.now }
  activate { w with entries := w.entries ++ [e], payments := w.payments ++ [pm] } t

/-- `WIR-42`'s pair for one settled payment. -/
def correctionPair (p : Params) (d : DepositId) (target : TenantId) (pm : Payment) : List Entry :=
  let k := if p.correctionPrefix then Key.correction pm.ref else Key.payment pm.ref
  [ { tenant := pm.creditedTenant, kind := .correction, sats := -pm.sats, key := k,
      deposit := some d, corrects := some pm.entry },
    { tenant := target, kind := .correction, sats := pm.sats, key := k,
      deposit := some d, corrects := some pm.entry } ]

/-- `WIR-42`: the pairs for every settled payment of the deposit, "all committed in one
transaction under deposit-level idempotency", the target persisted on the deposit. A key
collision is a refused insert, and the transaction with it. -/
@[req "WIR-42"]
def attribution (p : Params) (w : World) (d : Deposit) (target : TenantId) : World :=
  if !w.live target || w.live d.tenant || d.attributedTo.isSome then w else
  let pairs := (w.payments.filter (·.deposit = d.id)).flatMap (correctionPair p d.id target)
  if pairs.any (fun e => hasKey w e.tenant e.key) then w else
  activate { w with entries := w.entries ++ pairs,
                    deposits := w.deposits.map fun x =>
                      if x.id = d.id then { x with attributedTo := some target } else x } target

/-- `post` refuses the increment whole: `markDiscards` discards it, or the entry it writes carries a
key already on the tenant's ledger. An increment that writes no entry inserts no key to collide. -/
@[req "LDG-38"]
def refuses (p : Params) (w : World) (incrementEnd : Nat) (exact : Rat) : Bool :=
  p.markDiscards && w.mark.any (incrementEnd ≤ ·) ||
    (Ledger.clamp w.remaining (Meter.postedDebit exact w.roundingCredit)).1 != 0 &&
      hasKey w w.tenant (usageKey p w incrementEnd)

/-- One increment of the subject, closing at `incrementEnd`: `LDG-38`'s debit, `LDG-31`'s clamp,
the deficiency for the overflow, `r` advanced by what was computed, and the mark to the greatest
end posted, whether or not an entry posts. Where it `refuses`, nothing is written and nothing
moves — no entry, no decrement, no deficiency, `r` and the mark where they were — as `credit`
refuses. -/
@[req "LDG-38"]
def post (p : Params) (w : World) (incrementEnd : Nat) (exact : Rat) : World :=
  let posted := Meter.postedDebit exact w.roundingCredit
  let (entry, overflow) := Ledger.clamp w.remaining posted
  if refuses p w incrementEnd exact then w else
  { w with entries := w.entries ++ (if entry = 0 then [] else
              [{ tenant := w.tenant, kind := .usageDebit, sats := -entry,
                 key := usageKey p w incrementEnd, deposit := none, corrects := none }]),
           remaining := w.remaining - entry,
           deficiencies := w.deficiencies ++ (if overflow = 0 then [] else
              [{ clampedSats := overflow, absorbedSeconds := 0 }]),
           roundingCredit := Meter.nextCredit exact w.roundingCredit,
           mark := some (max (w.mark.getD 0) incrementEnd) }

inductive Event
  | advance (d : Nat)
  | enrol (t : TenantId)
  /-- `LDG-46`: one deposit, for a live tenant, with its expiry. -/
  | mint (d : DepositId) (t : TenantId) (expiresAt : Nat)
  /-- The watcher observed a settlement at a watched deposit. -/
  | settle (d : DepositId) (ref : PaymentRef) (rail : Rail) (sats : Int)
  /-- `LDG-51`: an on-chain payment at an expired deposit, "brought to the operator's attention". -/
  | lateOnchain (d : DepositId) (ref : PaymentRef) (sats : Int)
  /-- `API-34`'s time-to-live reached the tenant. -/
  | reap (t : TenantId)
  /-- `WIR-42`. -/
  | attribution (d : DepositId) (t : TenantId)
  /-- `LDG-38`: one increment of the subject, its end instant and its exact charge. -/
  | post (incrementEnd : Nat) (exact : Rat)
  deriving DecidableEq, Repr

def step (p : Params) (w : World) : Event → World
  | .advance n => { w with now := w.now + n }
  | .enrol t =>
    if w.live t || w.retired.contains t then w
    else { w with tenants := w.tenants ++ [{ id := t, status := .pending }] }
  | .mint d t expiresAt =>
    if !w.live t || (w.findDeposit d).isSome then w
    else { w with deposits := w.deposits ++ [{ id := d, tenant := t, expiresAt := expiresAt,
                                               attributedTo := none }] }
  | .settle d ref rail sats =>
    match w.findDeposit d with
    | some dep => if dep.watched w.now then credit p w dep ref rail sats else w
    | none => w
  | .lateOnchain d ref sats =>
    match w.findDeposit d with
    | some dep => credit p w dep ref .onchain sats
    | none => w
  | .reap t =>
    match w.tenants.find? (·.id = t) with
    | some tn =>
      if tn.status = .pending &&
         (!p.reapWaitsForWindow || !w.deposits.any fun d => d.creditedTenant = t && d.inWindow w)
      then { w with tenants := w.tenants.filter (·.id ≠ t), retired := w.retired ++ [t] } else w
    | none => w
  | .attribution d t =>
    match w.findDeposit d with
    | some dep => attribution p w dep t
    | none => w
  | .post incrementEnd exact => post p w incrementEnd exact

def run (p : Params) (w : World) (evs : List Event) : World := evs.foldl (step p) w

/-! ## What each step leaves alone -/

theorem activate_live (w : World) (t t' : TenantId) : (activate w t').live t = w.live t := by
  simp only [activate, World.live, List.any_map]
  congr 1; funext tn; simp only [Function.comp]; split <;> rfl

theorem credit_deposits (p : Params) (w : World) (d : Deposit) (ref : PaymentRef) (rail : Rail)
    (sats : Int) : (credit p w d ref rail sats).deposits = w.deposits := by
  simp only [credit]; split <;> rfl

theorem credit_live (p : Params) (w : World) (d : Deposit) (ref : PaymentRef) (rail : Rail)
    (sats : Int) (t : TenantId) : (credit p w d ref rail sats).live t = w.live t := by
  simp only [credit]; split
  · rfl
  · exact activate_live ..

theorem inWindow_credit (p : Params) (w : World) (d : Deposit) (ref : PaymentRef) (rail : Rail)
    (sats : Int) (dep : Deposit) :
    dep.inWindow (credit p w d ref rail sats) = dep.inWindow w := by
  simp only [credit]; split <;> rfl

theorem attribution_live (p : Params) (w : World) (d : Deposit) (t t' : TenantId) :
    (attribution p w d t').live t = w.live t := by
  simp only [attribution]; split
  · rfl
  · split
    · rfl
    · exact activate_live ..

theorem inWindow_attribution (p : Params) (w : World) (d : Deposit) (t : TenantId)
    (dep : Deposit) : dep.inWindow (attribution p w d t) = dep.inWindow w := by
  simp only [attribution]; split
  · rfl
  · split <;> rfl

/-! ## Lemmas on the lists -/

theorem findDeposit_id (w : World) (d : DepositId) (dep : Deposit)
    (h : w.findDeposit d = some dep) : dep.id = d := by
  unfold World.findDeposit at h; simpa using List.find?_some h

theorem findDeposit_mem (w : World) (d : DepositId) (dep : Deposit)
    (h : w.findDeposit d = some dep) : dep ∈ w.deposits := by
  unfold World.findDeposit at h; exact List.mem_of_find?_eq_some h

theorem sumFor_append (t : TenantId) (xs ys : List Entry) :
    sumFor t (xs ++ ys) = sumFor t xs + sumFor t ys := by
  simp [sumFor, List.filter_append, List.map_append, List.sum_append]

theorem float_append (xs ys : List Entry) : float (xs ++ ys) = float xs + float ys := by
  simp [float, List.map_append, List.sum_append]

theorem sumFor_activate (w : World) (t t' : TenantId) :
    sumFor t (activate w t').entries = sumFor t w.entries := rfl

/-! ## The pairing, on the composed model -/

/-- `LDG-31` on the composed model: an increment, however it clamps, leaves the subject's
`available` unchanged — the entry and the decrement are the same clamped number. -/
@[req "LDG-31"]
theorem post_leaves_available_unchanged (p : Params) (w : World) (incrementEnd : Nat)
    (exact : Rat) : (post p w incrementEnd exact).available = w.available := by
  simp only [post, World.available, Ledger.clamp]
  split
  · rfl
  · simp only [sumFor_append]; split <;> simp [sumFor] <;> omega

/-- `LDG-38`'s recurrence through the clamp: on every world where `post` does not refuse the
increment, the credit after it is the recurrence's, and the commitment's remainder appears nowhere
in it. Whether `post` refuses can itself turn on the remainder — the key conflict counts only where
the clamped entry is not zero — so this premise reads the clamp's outcome;
`clamp_never_touches_credit_past_the_mark` states the conclusion under premises that do not. -/
@[req "LDG-38"]
theorem clamp_never_touches_credit (p : Params) (w : World) (incrementEnd : Nat) (exact : Rat)
    (h : refuses p w incrementEnd exact = false) :
    (post p w incrementEnd exact).roundingCredit = Meter.nextCredit exact w.roundingCredit := by
  simp [post, h]

/-- The clamp's remainder is a record and not an entry: for an increment `post` does not refuse,
what the subject was debited plus what the deficiency records is the computed debit, the remainder
absorbed no time (`LDG-66`), and the commitment never goes below zero. `h` reads the clamp's
outcome, as it does for `clamp_never_touches_credit`; `clamp_overflow_is_a_record_past_the_mark` is
the version whose premises do not. -/
@[req "LDG-66"]
theorem clamp_overflow_is_a_record (p : Params) (w : World) (incrementEnd : Nat) (exact : Rat)
    (h : refuses p w incrementEnd exact = false) (hr : 0 ≤ w.remaining) (hx : 0 ≤ exact)
    (hc : w.roundingCredit < 1) :
    let posted := Meter.postedDebit exact w.roundingCredit
    let w' := post p w incrementEnd exact
    sumFor w.tenant w'.entries - sumFor w.tenant w.entries
      - ((w'.deficiencies.drop w.deficiencies.length).map (·.clampedSats)).sum = -posted ∧
    (∀ df ∈ w'.deficiencies.drop w.deficiencies.length, df.absorbedSeconds = 0) ∧
    0 ≤ w'.remaining := by
  have hp := Meter.postedDebit_nonneg exact w.roundingCredit hx hc
  simp only [post, Ledger.clamp, h, Bool.false_eq_true, ite_false, sumFor_append,
             List.drop_append_of_le_length (Nat.le_refl _), List.drop_length, List.nil_append]
  refine ⟨?_, ?_, ?_⟩
  · split <;> split <;> simp_all [sumFor] <;> omega
  · intro df h; split at h <;> simp_all
  · omega

/-- Under the stated key, on a world carrying `World.markCovers` — the invariant
`mark_covers_every_key` preserves on every step — an increment ending past the mark is not refused,
whatever the commitment has left: the discard needs an end at or before the mark, and a held key
for this end would put the mark at or past it. -/
theorem not_refused_past_the_mark (p : Params) (hk : p.usageKeyFrom = .incrementEnd) (w : World)
    (hm : w.markCovers) (incrementEnd : Nat) (exact : Rat)
    (hn : w.mark.all (· < incrementEnd) = true) : refuses p w incrementEnd exact = false := by
  have hd : w.mark.any (incrementEnd ≤ ·) = false := by
    cases h : w.mark with
    | none => rfl
    | some m => simp only [h, Option.all_some, decide_eq_true_eq] at hn; simp; omega
  have hh : hasKey w w.tenant (usageKey p w incrementEnd) = false := by
    simp only [hasKey, usageKey, hk, List.any_eq_false, Bool.and_eq_true, decide_eq_true_eq]
    rintro e he ⟨-, hke⟩
    obtain ⟨m, hmk, hle⟩ := hm e he incrementEnd hke
    simp only [hmk, Option.all_some, decide_eq_true_eq] at hn
    omega
  simp [refuses, hd, hh]

/-- `LDG-38`: "`r` advances by `posted_debit_i` regardless" — `clamp_never_touches_credit` for
every remainder. The premises are the stated key, `World.markCovers` (the invariant
`mark_covers_every_key` preserves on every step) and an increment ending past the mark; none
mentions the commitment, so the credit after the increment is the recurrence's however the clamp
splits it. -/
@[req "LDG-38"]
theorem clamp_never_touches_credit_past_the_mark (p : Params)
    (hk : p.usageKeyFrom = .incrementEnd) (w : World) (hm : w.markCovers) (incrementEnd : Nat)
    (exact : Rat) (hn : w.mark.all (· < incrementEnd) = true) :
    (post p w incrementEnd exact).roundingCredit = Meter.nextCredit exact w.roundingCredit :=
  clamp_never_touches_credit p w incrementEnd exact
    (not_refused_past_the_mark p hk w hm incrementEnd exact hn)

/-- `clamp_overflow_is_a_record` for every non-negative remainder: its premises but `h`, and in
`h`'s place those of `clamp_never_touches_credit_past_the_mark`. `hr` is the one premise that
mentions the remainder, and it asks only its sign, never what the clamp leaves of it. -/
@[req "LDG-66"]
theorem clamp_overflow_is_a_record_past_the_mark (p : Params)
    (hk : p.usageKeyFrom = .incrementEnd) (w : World) (hm : w.markCovers) (incrementEnd : Nat)
    (exact : Rat) (hn : w.mark.all (· < incrementEnd) = true) (hr : 0 ≤ w.remaining)
    (hx : 0 ≤ exact) (hc : w.roundingCredit < 1) :
    let posted := Meter.postedDebit exact w.roundingCredit
    let w' := post p w incrementEnd exact
    sumFor w.tenant w'.entries - sumFor w.tenant w.entries
      - ((w'.deficiencies.drop w.deficiencies.length).map (·.clampedSats)).sum = -posted ∧
    (∀ df ∈ w'.deficiencies.drop w.deficiencies.length, df.absorbedSeconds = 0) ∧
    0 ≤ w'.remaining :=
  clamp_overflow_is_a_record p w incrementEnd exact
    (not_refused_past_the_mark p hk w hm incrementEnd exact hn) hr hx hc

/-! ## Credit and record are one transaction -/

/-- `STO-30`: every reachable state carries as many `payments` rows as `topup` entries — the step
that writes one writes the other, and no other step writes either. -/
@[req "STO-30"]
theorem payments_match_topups (p : Params) (w : World) (e : Event)
    (h : w.payments.length = (w.entries.filter (·.kind = .topup)).length) :
    (step p w e).payments.length = ((step p w e).entries.filter (·.kind = .topup)).length := by
  cases e with
  | advance n => exact h
  | enrol t => simp only [step]; split <;> exact h
  | mint d t x => simp only [step]; split <;> exact h
  | settle d ref rail sats =>
    simp only [step]
    split
    · split
      · simp only [credit]; split
        · exact h
        · simp [activate, List.filter_append, h]
      · exact h
    · exact h
  | lateOnchain d ref sats =>
    simp only [step]
    split
    · simp only [credit]; split
      · exact h
      · simp [activate, List.filter_append, h]
    · exact h
  | reap t => simp only [step]; split <;> (try split) <;> exact h
  | attribution d t =>
    simp only [step]
    split
    · simp only [attribution]
      split
      · exact h
      · split
        · exact h
        · simp only [activate, List.filter_append, List.length_append, h]
          have : ∀ ps : List Payment, ∀ (p : Params) (d : DepositId) (t : TenantId),
              ((ps.flatMap (correctionPair p d t)).filter (·.kind = .topup)).length = 0 := by
            intro ps p d t
            induction ps with
            | nil => rfl
            | cons x xs ih => simp [List.flatMap_cons, correctionPair, ih]
          simp [this]
    · exact h
  | post incrementEnd exact =>
    simp only [step, post, Ledger.clamp]
    split
    · exact h
    · simp only [List.filter_append, List.length_append, h]; split <;> simp

/-! ## Rail identity -/

/-- `STO-31`: "Watching for settlement MUST be idempotent and MUST tolerate replay from the rail",
with the key derived from the payment: crediting the same settlement twice is crediting it once,
on every world. -/
@[req "STO-31"]
theorem credit_idempotent (p : Params) (hp : p.keyFrom = .payment) (w : World) (d : Deposit)
    (ref : PaymentRef) (rail : Rail) (sats : Int) :
    credit p (credit p w d ref rail sats) d ref rail sats = credit p w d ref rail sats := by
  simp only [credit, topupKey, hp]
  split
  · simp [*]
  · simp [activate, hasKey, List.any_append]

/-- The same, through the watcher: a replayed settlement is a no-op. -/
@[req "STO-31"]
theorem settle_idempotent (p : Params) (hp : p.keyFrom = .payment) (w : World) (d : DepositId)
    (ref : PaymentRef) (rail : Rail) (sats : Int) :
    step p (step p w (.settle d ref rail sats)) (.settle d ref rail sats) =
      step p w (.settle d ref rail sats) := by
  cases hd : w.findDeposit d with
  | none => simp [step, hd]
  | some dep =>
    by_cases hw : dep.watched w.now = true
    · have hd' : (credit p w dep ref rail sats).findDeposit d = some dep := by
        simp only [credit]; split
        · exact hd
        · simpa [activate, World.findDeposit] using hd
      have hn : (credit p w dep ref rail sats).now = w.now := by
        simp only [credit]; split <;> rfl
      simp only [step, hd, hw, ite_true, hd', hn, credit_idempotent p hp]
    · simp [step, hd, hw]

/-! ## Expiry: watching ends, the binding does not -/

/-- `LDG-57`: the watcher credits nothing at an expired deposit — the settlement is not observed. -/
@[req "LDG-57"]
theorem settle_only_while_watched (p : Params) (w : World) (d : DepositId) (dep : Deposit)
    (hd : w.findDeposit d = some dep) (h : dep.watched w.now = false)
    (ref : PaymentRef) (rail : Rail) (sats : Int) :
    step p w (.settle d ref rail sats) = w := by
  simp [step, hd, h]

/-- `LDG-51`: "A payment arriving at an expired deposit's address, for a live tenant, MUST be
credited if it is observed at all" — the late payment is credited through the binding, which
`Deposit.creditedTenant` reads with no clock, to the tenant the deposit names. -/
@[req "LDG-51"]
theorem late_payment_credited_through_binding (p : Params) (hp : p.keyFrom = .payment) (w : World)
    (d : DepositId) (dep : Deposit) (hd : w.findDeposit d = some dep) (ref : PaymentRef)
    (sats : Int) (hk : hasKey w dep.creditedTenant (.payment ref) = false)
    (hr : w.payments.any (·.ref = ref) = false) :
    (step p w (.lateOnchain d ref sats)).entries =
      w.entries ++ [{ tenant := dep.creditedTenant, kind := .topup, sats := sats,
                      key := .payment ref, deposit := some d, corrects := none }] := by
  simp [step, hd, credit, topupKey, hp, hk, hr, activate, findDeposit_id w d dep hd]

/-- `LDG-54`: "after it, the payment cannot be made" — every Lightning payment on record was
observed before its deposit expired, and every step keeps it so. -/
@[req "LDG-54"]
theorem lightning_paid_before_expiry (p : Params) (w : World) (e : Event)
    (h : ∀ pm ∈ w.payments, pm.rail = .lightning →
      ∃ dep ∈ w.deposits, dep.id = pm.deposit ∧ pm.observedAt < dep.expiresAt) :
    ∀ pm ∈ (step p w e).payments, pm.rail = .lightning →
      ∃ dep ∈ (step p w e).deposits, dep.id = pm.deposit ∧ pm.observedAt < dep.expiresAt := by
  cases e with
  | advance n => simpa [step] using h
  | enrol t => simp only [step]; split <;> simpa using h
  | mint d t x =>
    simp only [step]; split
    · exact h
    · intro pm hpm hl
      obtain ⟨dep, hdep, hid, hlt⟩ := h pm (by simpa using hpm) hl
      exact ⟨dep, by simp [hdep], hid, hlt⟩
  | settle d ref rail sats =>
    simp only [step]
    split
    · rename_i dep hd
      split
      · rename_i hw
        simp only [credit]; split
        · exact h
        · intro pm hpm hl
          simp only [activate, List.mem_append, List.mem_singleton] at hpm
          rcases hpm with hpm | rfl
          · exact h pm hpm hl
          · exact ⟨dep, findDeposit_mem w d dep hd, rfl, by simpa [Deposit.watched] using hw⟩
      · exact h
    · exact h
  | lateOnchain d ref sats =>
    simp only [step]
    split
    · simp only [credit]; split
      · exact h
      · intro pm hpm hl
        simp only [activate, List.mem_append, List.mem_singleton] at hpm
        rcases hpm with hpm | rfl
        · exact h pm hpm hl
        · simp at hl
    · exact h
  | reap t => simp only [step]; split <;> (try split) <;> simpa using h
  | attribution d t =>
    simp only [step]
    split
    · rename_i dep hd
      simp only [attribution]
      split
      · exact h
      · split
        · exact h
        · intro pm hpm hl
          obtain ⟨dep', hdep', hid, hlt⟩ := h pm hpm hl
          refine ⟨if dep'.id = dep.id then { dep' with attributedTo := some t } else dep', ?_, ?_, ?_⟩
          · exact List.mem_map_of_mem hdep'
          · split <;> exact hid
          · split <;> exact hlt
    · exact h
  | post incrementEnd exact => simp only [step, post]; split <;> exact h

/-! ## The tenant -/

/-- `API-58`: "A funded tenant MUST be suspended, never deleted" — the reap refuses an active
tenant. -/
@[req "API-58"]
theorem reap_refuses_active (p : Params) (w : World) (t : TenantId) (tn : Tenant)
    (hf : w.tenants.find? (·.id = t) = some tn) (ha : tn.status = .active) :
    step p w (.reap t) = w := by
  simp [step, hf, ha]

/-- `API-34`: "a tenant MUST NOT be deleted while any deposit of its own remains inside that
window" — with the guard, the reap of a tenant one of whose deposits is inside its window is
refused. -/
@[req "API-34"]
theorem reap_waits_for_window (p : Params) (hp : p.reapWaitsForWindow = true) (w : World)
    (t : TenantId) (dep : Deposit) (hdep : dep ∈ w.deposits) (hct : dep.creditedTenant = t)
    (hw : dep.inWindow w = true) :
    step p w (.reap t) = w := by
  simp only [step]
  split
  · have : w.deposits.any (fun d => d.creditedTenant = t && d.inWindow w) = true := by
      simp only [List.any_eq_true]; exact ⟨dep, hdep, by simp [hct, hw]⟩
    simp [hp, this]
  · rfl

/-- `API-42`: "A tenant MUST NOT be deleted while a payment attributable to it is in flight" — the
invariant `API-34`'s floor buys: every deposit inside its window resolves to a live tenant, on
every world where it did before. `in_window_settlement_attributed` is what it says about a
settlement. -/
@[req "API-42"]
theorem in_window_deposit_has_live_tenant (p : Params) (hp : p.reapWaitsForWindow = true)
    (w : World) (e : Event)
    (h : ∀ dep ∈ w.deposits, dep.inWindow w = true → w.live dep.creditedTenant = true) :
    ∀ dep ∈ (step p w e).deposits, dep.inWindow (step p w e) = true →
      (step p w e).live dep.creditedTenant = true := by
  cases e with
  | advance n =>
    intro dep hdep hw
    simp only [step] at hdep hw ⊢
    exact h dep hdep (by simp only [Deposit.inWindow] at hw ⊢; simp at hw ⊢; omega)
  | enrol t =>
    simp only [step]; split
    · exact h
    · intro dep hdep hw
      have := h dep hdep hw
      simp only [World.live, List.any_append] at this ⊢; simp [this]
  | mint d t x =>
    simp only [step]; split
    · exact h
    · rename_i hm
      have hlt : w.live t = true := by revert hm; cases w.live t <;> simp
      intro dep hdep hw
      simp only [List.mem_append, List.mem_singleton] at hdep
      rcases hdep with hdep | rfl
      · exact h dep hdep hw
      · exact hlt
  | settle d ref rail sats =>
    simp only [step]
    split
    · split
      · intro dep hdep hw
        rw [credit_deposits] at hdep
        rw [inWindow_credit] at hw
        rw [credit_live]
        exact h dep hdep hw
      · exact h
    · exact h
  | lateOnchain d ref sats =>
    simp only [step]
    split
    · intro dep hdep hw
      rw [credit_deposits] at hdep
      rw [inWindow_credit] at hw
      rw [credit_live]
      exact h dep hdep hw
    · exact h
  | reap t =>
    simp only [step]
    split
    · split
      · rename_i hc
        intro dep hdep hw
        have hw' : dep.inWindow w = true := hw
        simp only [hp, Bool.not_true, Bool.false_or, Bool.and_eq_true, decide_eq_true_eq,
                   Bool.not_eq_true', List.any_eq_false] at hc
        have hlive := h dep hdep hw'
        have hne : dep.creditedTenant ≠ t := by
          intro heq; have := hc.2 dep hdep; simp [heq, hw'] at this
        simp only [World.live, List.any_eq_true, List.mem_filter] at hlive ⊢
        obtain ⟨tn, htn, hid⟩ := hlive
        exact ⟨tn, ⟨htn, by simp at hid; simp [hid, hne]⟩, hid⟩
      · exact h
    · exact h
  | attribution d t =>
    simp only [step]
    split
    · rename_i dep0 hd
      intro dep hdep hw
      rw [attribution_live]
      rw [inWindow_attribution] at hw
      simp only [attribution] at hdep
      split at hdep
      · exact h dep hdep hw
      · rename_i hg
        have hlt : w.live t = true := by revert hg; cases w.live t <;> simp
        split at hdep
        · exact h dep hdep hw
        · simp only [activate, List.mem_map] at hdep
          obtain ⟨dep', hdep', rfl⟩ := hdep
          by_cases hid : dep'.id = dep0.id
          · simp only [hid, ite_true] at hw ⊢
            exact hlt
          · simp only [hid, ite_false] at hw ⊢
            exact h dep' hdep' hw
    · exact h
  | post incrementEnd exact => simp only [step, post]; split <;> exact h

/-- On a world carrying the invariant, a settlement at a deposit inside its window is credited to
a live tenant, and the tenant is live after the credit. -/
@[req "API-42"]
theorem in_window_settlement_attributed (p : Params) (w : World)
    (h : ∀ dep ∈ w.deposits, dep.inWindow w = true → w.live dep.creditedTenant = true)
    (d : DepositId) (dep : Deposit) (hd : w.findDeposit d = some dep) (hw : dep.inWindow w = true)
    (ref : PaymentRef) (rail : Rail) (sats : Int) :
    w.live dep.creditedTenant = true ∧
    (credit p w dep ref rail sats).live dep.creditedTenant = true := by
  have := h dep (findDeposit_mem w d dep hd) hw
  exact ⟨this, by rw [credit_live]; exact this⟩

/-- `LDG-43`: a late payment for a tenant that no longer exists "MUST be recorded as unattributed
and MUST NOT be silently dropped" — the entry is appended, and the join says unattributed. -/
@[req "LDG-43"]
theorem late_payment_recorded_unattributed (p : Params) (hp : p.keyFrom = .payment) (w : World)
    (d : DepositId) (dep : Deposit) (hd : w.findDeposit d = some dep) (ref : PaymentRef)
    (sats : Int) (hk : hasKey w dep.creditedTenant (.payment ref) = false)
    (hr : w.payments.any (·.ref = ref) = false)
    (hdead : w.live dep.creditedTenant = false) :
    let w' := step p w (.lateOnchain d ref sats)
    w'.entries.length = w.entries.length + 1 ∧
    ∀ e ∈ w'.entries.drop w.entries.length, w'.unattributed e = true := by
  have hl : (step p w (.lateOnchain d ref sats)).live dep.creditedTenant = false := by
    simp only [step, hd]; rw [credit_live]; exact hdead
  simp only [late_payment_credited_through_binding p hp w d dep hd ref sats hk hr,
             List.length_append, List.length_singleton, List.drop_append_of_le_length (Nat.le_refl _),
             List.drop_length, List.nil_append, List.mem_singleton, forall_eq, World.unattributed]
  exact ⟨trivial, by simp [hl]⟩

/-! ## Attribution -/

/-- `WIR-42`: the pairs sum to nothing — "it is a ledger transfer, not a flag", and `LDG-17`'s
float is what it was. On every world, whether the call applied or not. -/
@[req "WIR-42"]
theorem attribution_conserves_float (p : Params) (w : World) (d : Deposit) (t : TenantId) :
    float (attribution p w d t).entries = float w.entries := by
  simp only [attribution]
  split
  · rfl
  · split
    · rfl
    · simp only [activate, float_append]
      have : ∀ ps : List Payment,
          float (ps.flatMap (correctionPair p d.id t)) = 0 := by
        intro ps; induction ps with
        | nil => rfl
        | cons x xs ih =>
          rw [List.flatMap_cons, float_append, ih]
          simp only [correctionPair, float, List.map_cons, List.map_nil, List.sum_cons, List.sum_nil]
          omega
      simp [this]

/-- `WIR-42`: "one `correction` pair per settled payment", each negative entry "naming the original
credit it corrects" — where the call applies (a live target, a reaped source, no target persisted
yet, no key collision) the entries it appends are two per payment of the deposit, every one a
`correction` carrying the deposit and naming that payment's own entry. -/
@[req "WIR-42"]
theorem attribution_names_each_credit (p : Params) (w : World) (d : Deposit) (t : TenantId)
    (hg : (!w.live t || w.live d.tenant || d.attributedTo.isSome) = false)
    (hc : ((w.payments.filter (·.deposit = d.id)).flatMap (correctionPair p d.id t)).any
            (fun e => hasKey w e.tenant e.key) = false) :
    (attribution p w d t).entries =
      w.entries ++ (w.payments.filter (·.deposit = d.id)).flatMap (correctionPair p d.id t) ∧
    ((w.payments.filter (·.deposit = d.id)).flatMap (correctionPair p d.id t)).length =
      2 * (w.payments.filter (·.deposit = d.id)).length ∧
    ∀ e ∈ (w.payments.filter (·.deposit = d.id)).flatMap (correctionPair p d.id t),
      e.kind = .correction ∧ e.deposit = some d.id ∧
      ∃ pm ∈ w.payments.filter (·.deposit = d.id),
        e.corrects = some pm.entry ∧ (e.sats = -pm.sats ∨ e.sats = pm.sats) := by
  refine ⟨by simp only [attribution, hg, hc, Bool.false_eq_true, ite_false]; rfl, ?_⟩
  generalize w.payments.filter (·.deposit = d.id) = ps
  induction ps with
  | nil => simp
  | cons x xs ih =>
    obtain ⟨hl, hm⟩ := ih
    constructor
    · simp only [List.flatMap_cons, List.length_append, List.length_cons, hl, correctionPair,
                 List.length_nil]
      omega
    · intro e he
      simp only [List.flatMap_cons, List.mem_append, correctionPair, List.mem_cons,
                 List.not_mem_nil, or_false] at he
      rcases he with (rfl | rfl) | he
      · exact ⟨rfl, rfl, x, List.mem_cons_self .., rfl, Or.inl rfl⟩
      · exact ⟨rfl, rfl, x, List.mem_cons_self .., rfl, Or.inr rfl⟩
      · obtain ⟨h1, h2, pm, hpm, h3⟩ := hm e he
        exact ⟨h1, h2, pm, List.mem_cons_of_mem _ hpm, h3⟩

/-- `WIR-42`: "Attribution MUST be idempotent per deposit" — with the target persisted, a second
call, to any tenant, appends nothing. -/
@[req "WIR-42"]
theorem attribution_idempotent_per_deposit (p : Params) (w : World) (d : Deposit)
    (h : d.attributedTo.isSome = true) (t : TenantId) :
    attribution p w d t = w := by
  simp [attribution, h]

/-- `LDG-43`: "a payment settling after that call is credited to that tenant directly as an
ordinary `topup` — no correction pair". -/
@[req "LDG-43"]
theorem settle_after_attribution_is_a_topup (p : Params) (hp : p.keyFrom = .payment) (w : World)
    (d : Deposit) (t : TenantId) (ha : d.attributedTo = some t) (ref : PaymentRef) (rail : Rail)
    (sats : Int) (hk : hasKey w t (.payment ref) = false)
    (hr : w.payments.any (·.ref = ref) = false) :
    (credit p w d ref rail sats).entries =
      w.entries ++ [{ tenant := t, kind := .topup, sats := sats, key := .payment ref,
                      deposit := some d.id, corrects := none }] := by
  simp [credit, topupKey, hp, Deposit.creditedTenant, ha, hk, hr, activate]

/-- "A `correction` leaves the meter's state untouched" (`LDG-38`): an attribution, applied or
refused, moves neither `r`, the mark nor the commitment's remainder — `LDG-72`: "A `correction`
does **not** touch this record". -/
@[req "LDG-38"]
theorem attribution_leaves_meter_untouched (p : Params) (w : World) (d : Deposit) (t : TenantId) :
    (attribution p w d t).roundingCredit = w.roundingCredit ∧
    (attribution p w d t).mark = w.mark ∧ (attribution p w d t).remaining = w.remaining := by
  simp only [attribution]; split
  · exact ⟨rfl, rfl, rfl⟩
  · split
    · exact ⟨rfl, rfl, rfl⟩
    · exact ⟨rfl, rfl, rfl⟩

/-- An attribution writes no `usage_debit` key: every one it could collide with is where it was. -/
theorem attribution_hasKey_usage (p : Params) (w : World) (d : Deposit) (t x : TenantId)
    (s : Subject) (period : Nat) (k : Kind) (n : Nat) :
    hasKey (attribution p w d t) x (.usage s period k n) = hasKey w x (.usage s period k n) := by
  simp only [attribution]; split
  · rfl
  · split
    · rfl
    · simp only [hasKey, activate, List.any_append, Bool.or_eq_left_iff_imp]
      intro hc
      simp only [List.any_eq_true, List.mem_flatMap, correctionPair] at hc
      obtain ⟨e, ⟨pm, _, he⟩, hk⟩ := hc
      simp only [List.mem_cons, List.not_mem_nil, or_false] at he
      rcases he with rfl | rfl <;> split at hk <;> simp at hk

/-- The same, composed: "the next increment posts `ceil(exact − r)` exactly as it would have" — the
increment after a correction leaves the same credit and debits the subject the same amount as
the increment without it, under the stated key. `hk` is the statement's scope, not a weakening:
the world is arbitrary, and under the posting index the key `post` derives is the entry count,
which an attribution that posts a pair changes, so the two posts derive different keys — and a
world holding one and not the other can refuse one post and admit the other. -/
@[req "LDG-38"]
theorem correction_then_post_posts_the_same (p : Params) (hk : p.usageKeyFrom = .incrementEnd)
    (w : World) (d : Deposit) (t : TenantId) (incrementEnd : Nat) (exact : Rat) :
    let w₁ := post p (attribution p w d t) incrementEnd exact
    let w₂ := post p w incrementEnd exact
    w₁.roundingCredit = w₂.roundingCredit ∧ w₁.remaining = w₂.remaining ∧
    sumFor w.tenant w₁.entries - sumFor w.tenant (attribution p w d t).entries =
      sumFor w.tenant w₂.entries - sumFor w.tenant w.entries := by
  obtain ⟨hc, hm, hr⟩ := attribution_leaves_meter_untouched p w d t
  have hs : (attribution p w d t).subject = w.subject ∧ (attribution p w d t).period = w.period ∧
      (attribution p w d t).tenant = w.tenant := by
    simp only [attribution]; split
    · exact ⟨rfl, rfl, rfl⟩
    · split <;> exact ⟨rfl, rfl, rfl⟩
  obtain ⟨hs, hp, ht⟩ := hs
  simp only [post, refuses, usageKey, hk, hc, hm, hr, hs, hp, ht, attribution_hasKey_usage,
             Ledger.clamp]
  split <;> simp_all [sumFor_append]; omega

/-! ## The increment key and the high-water mark -/

/-- An increment either is refused whole or leaves the mark at least its own end. -/
theorem post_refused_or_marked (p : Params) (w : World) (incrementEnd : Nat) (exact : Rat) :
    post p w incrementEnd exact = w ∨
      (post p w incrementEnd exact).mark = some (max (w.mark.getD 0) incrementEnd) := by
  simp only [post, Ledger.clamp]; split
  · exact Or.inl rfl
  · exact Or.inr rfl

/-- With the discard, an increment ending at or before the mark is refused whole, on every
world. -/
theorem post_discarded (p : Params) (hp : p.markDiscards = true) (w : World) (incrementEnd : Nat)
    (exact : Rat) (h : w.mark.any (incrementEnd ≤ ·) = true) : post p w incrementEnd exact = w := by
  simp [post, refuses, hp, h]

/-- `LDG-38`: "an increment whose end instant is at or before that mark MUST be discarded, not
posted" — with the discard, a replayed increment is a no-op on every world, whatever key the first
posting took and whether or not it wrote an entry. -/
@[req "LDG-38"]
theorem post_replay_discarded (p : Params) (hp : p.markDiscards = true) (w : World)
    (incrementEnd : Nat) (exact : Rat) :
    step p (step p w (.post incrementEnd exact)) (.post incrementEnd exact) =
      step p w (.post incrementEnd exact) := by
  simp only [step]
  rcases post_refused_or_marked p w incrementEnd exact with h | h
  · rw [h]; exact h
  · exact post_discarded p hp _ incrementEnd exact (by simp [h]; omega)

/-- `LDG-72`'s one-sided check is kept by every step: an increment leaves the mark at least its
own end whether or not it writes an entry, and no other step writes a `usage_debit` key or moves
the mark. Under the posting index the key an increment writes encodes no end, so there the step
adds nothing for the check to cover. -/
@[req "LDG-72"]
theorem mark_covers_every_key (p : Params) (w : World) (e : Event) (h : w.markCovers) :
    (step p w e).markCovers := by
  have hcredit : ∀ (dep : Deposit) ref rail sats, (credit p w dep ref rail sats).markCovers := by
    intro dep ref rail sats
    unfold World.markCovers at h ⊢
    simp only [credit]; split
    · exact h
    · intro e he n hn
      simp only [activate, List.mem_append, List.mem_singleton] at he
      rcases he with he | rfl
      · exact h e he n hn
      · simp only [topupKey] at hn; split at hn <;> simp at hn
  cases e with
  | advance n => exact h
  | enrol t => simp only [step]; split <;> exact h
  | mint d t x => simp only [step]; split <;> exact h
  | settle d ref rail sats =>
    simp only [step]; split
    · split
      · exact hcredit _ _ _ _
      · exact h
    · exact h
  | lateOnchain d ref sats =>
    simp only [step]; split
    · exact hcredit _ _ _ _
    · exact h
  | reap t => simp only [step]; split <;> (try split) <;> exact h
  | attribution d t =>
    unfold World.markCovers at h ⊢
    simp only [step]; split
    · simp only [attribution]; split
      · exact h
      · split
        · exact h
        · intro e he n hn
          simp only [activate, List.mem_append] at he
          rcases he with he | he
          · exact h e he n hn
          · simp only [List.mem_flatMap, correctionPair] at he
            obtain ⟨pm, _, he⟩ := he
            simp only [List.mem_cons, List.not_mem_nil, or_false] at he
            rcases he with rfl | rfl <;> split at hn <;> simp at hn
    · exact h
  | post incrementEnd exact =>
    unfold World.markCovers at h ⊢
    simp only [step, post, Ledger.clamp]; split
    · exact h
    · intro e he n hn
      simp only [List.mem_append] at he
      rcases he with he | he
      · obtain ⟨m, hm, hle⟩ := h e he n hn
        exact ⟨_, rfl, by simp [hm]; omega⟩
      · split at he
        · simp at he
        · simp only [List.mem_singleton] at he
          subst he
          simp only [usageKey] at hn
          split at hn
          · simp only [Key.usage.injEq] at hn
            exact ⟨_, rfl, by omega⟩
          · simp at hn

end Provisiond.Funding
