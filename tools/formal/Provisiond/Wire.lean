import Provisiond.Types
import Provisiond.Tables
/-! The wire's three pure functions: `API-12`'s canonical form and `WIR-3`'s fingerprint preimage
over it; `API-21`'s and `STO-50`'s projections from the stored row into the operation view and the
purge-surviving summary; `DOM-6`'s redaction. And `SEC-8`'s indistinguishability as a theorem on
the one lookup every tenant-scoped endpoint routes through.

Lean knows nothing about HTTP. A `Json` value is what `WIR-1a`'s parser produced — a duplicate
member was already refused, a number is already an integer, whitespace is already gone — so
`API-12`'s "whitespace" clause is the parse and not a theorem here; that a request's bytes parse to
the `Json` the model canonicalizes, that the request target is `WIR-5a`'s origin-form string, and
that `Response.notFound` is rendered as `WIR-9`'s `404` envelope are the parser's and the
transport's correspondence, which no theorem here takes as a hypothesis: it is outside the model,
and the omissions below list it. SHA-256 is not
modelled: `Preimage` is the three fields `WIR-3` concatenates, with the body carried as its
canonical value in place of the digest of it, so two preimages are equal exactly when the hash's
inputs are, and a collision is outside the model. Member order is `String`'s order — code-point
lexicographic — where JCS orders by UTF-16 code units; the two agree below `U+10000`, and every
theorem below holds for any total order.

A projection is an explicit function from the row type to the view type, field by field, so a
column added to `Row` reaches the wire only by an edit to `operationView`; `request` is the private
column, and each projection's independence from it is a theorem. The summary carries `STO-50`'s
closed list and one more field, `attempted`, which is the open bucket the summary was before
2026-09-06 and which `Params.closedSummary` empties.

What the model omits: the parse and the transport, above; `API-10`'s `(principal, key)` scoping — `onKeyReuse` is handed the request
stored under the same pair; `API-38`'s digest persisted past the purge, which is `preimage`
computed at submission and compared later; `WIR-11`'s machine view beyond the two columns
`SEC-8`'s lookup needs; `WIR-3`'s "empty-body digest" — every `Request` here carries a body, so a
request without one is not a value of the type; `DOM-6`'s "floor, not a ceiling"; and timing,
headers and every observable beyond the response value. -/

namespace Provisiond.Wire
open Provisiond.Claim (Status)
open Provisiond.Tables (Kind)

/-! ## `WIR-1a`'s value and `API-12`'s canonical form -/

mutual
/-- `WIR-1a`'s profile, parsed: "every JSON number MUST be an integer", so `num` carries an `Int`;
members are an ordered list, because canonicalization is what removes the order. -/
inductive Json
  | null
  | bool (b : Bool)
  | num (n : Int)
  | str (s : String)
  | arr (xs : Elems)
  | obj (kvs : Members)
inductive Elems
  | nil
  | cons (x : Json) (xs : Elems)
inductive Members
  | nil
  | cons (key : String) (val : Json) (rest : Members)
end

deriving instance DecidableEq for Json
deriving instance Repr for Json

def Elems.toList : Elems → List Json
  | .nil => []
  | .cons x xs => x :: xs.toList

def Elems.ofList : List Json → Elems
  | [] => .nil
  | x :: xs => .cons x (ofList xs)

def Members.toList : Members → List (String × Json)
  | .nil => []
  | .cons k v r => (k, v) :: r.toList

def Members.ofList : List (String × Json) → Members
  | [] => .nil
  | (k, v) :: r => .cons k v (ofList r)

theorem Elems.toList_ofList (l : List Json) : (ofList l).toList = l := by
  induction l with
  | nil => rfl
  | cons x xs ih => simp [ofList, toList, ih]

theorem Members.toList_ofList (l : List (String × Json)) : (ofList l).toList = l := by
  induction l with
  | nil => rfl
  | cons kv r ih => obtain ⟨k, v⟩ := kv; simp [ofList, toList, ih]

/-- Insertion sort, structural so that `decide` runs it; `List.mergeSort` is well-founded and the
kernel does not unfold it. -/
def insertBy {α : Type} (le : α → α → Bool) (x : α) : List α → List α
  | [] => [x]
  | y :: ys => if le x y then x :: y :: ys else y :: insertBy le x ys

def sortBy {α : Type} (le : α → α → Bool) : List α → List α
  | [] => []
  | x :: xs => insertBy le x (sortBy le xs)

/-- JCS's member order: by key alone. -/
def keyLe (a b : String × Json) : Bool := decide (a.1 ≤ b.1)

mutual
/-- `API-12`'s "canonical serialization", as the value `WIR-3`'s JCS serializes: every object's
members sorted by key, recursively. -/
@[req "API-12"]
def Json.canonical : Json → Json
  | .null => .null
  | .bool b => .bool b
  | .num n => .num n
  | .str s => .str s
  | .arr xs => .arr xs.canonical
  | .obj kvs => .obj (Members.ofList (sortBy keyLe kvs.canonical.toList))
def Elems.canonical : Elems → Elems
  | .nil => .nil
  | .cons x xs => .cons x.canonical xs.canonical
def Members.canonical : Members → Members
  | .nil => .nil
  | .cons k v r => .cons k v.canonical r.canonical
end

/-- What `Members.canonical` does to a member. -/
def canonMember (kv : String × Json) : String × Json := (kv.1, kv.2.canonical)

theorem Elems.toList_canonical : ∀ xs : Elems, xs.canonical.toList = xs.toList.map Json.canonical
  | .nil => rfl
  | .cons x xs => by simp [Elems.canonical, toList, Elems.toList_canonical xs]

theorem Members.toList_canonical : ∀ m : Members, m.canonical.toList = m.toList.map canonMember
  | .nil => rfl
  | .cons k v r => by simp [Members.canonical, toList, Members.toList_canonical r, canonMember]

/-! ### The sort's three facts -/

theorem perm_insertBy {α : Type} (le : α → α → Bool) (x : α) (l : List α) :
    (insertBy le x l).Perm (x :: l) := by
  induction l with
  | nil => exact List.Perm.refl _
  | cons y ys ih =>
    simp only [insertBy]
    split
    · exact List.Perm.refl _
    · exact (List.Perm.cons y ih).trans (List.Perm.swap x y ys)

theorem perm_sortBy {α : Type} (le : α → α → Bool) (l : List α) : (sortBy le l).Perm l := by
  induction l with
  | nil => exact List.Perm.refl _
  | cons x xs ih => exact (perm_insertBy le x _).trans (List.Perm.cons x ih)

theorem pairwise_insertBy {α : Type} (le : α → α → Bool)
    (htrans : ∀ a b c, le a b = true → le b c = true → le a c = true)
    (htotal : ∀ a b, (le a b || le b a) = true) (x : α) (l : List α)
    (h : l.Pairwise (fun a b => le a b = true)) :
    (insertBy le x l).Pairwise (fun a b => le a b = true) := by
  induction l with
  | nil => simp [insertBy]
  | cons y ys ih =>
    rw [List.pairwise_cons] at h
    simp only [insertBy]
    split
    · rename_i hxy
      rw [List.pairwise_cons]
      refine ⟨fun z hz => ?_, List.pairwise_cons.mpr h⟩
      rcases List.mem_cons.mp hz with rfl | hz
      · exact hxy
      · exact htrans _ _ _ hxy (h.1 z hz)
    · rename_i hxy
      have hyx : le y x = true := by
        have := htotal x y
        simp only [Bool.or_eq_true] at this
        rcases this with h' | h'
        · exact absurd h' hxy
        · exact h'
      rw [List.pairwise_cons]
      refine ⟨fun z hz => ?_, ih h.2⟩
      rcases List.mem_cons.mp ((perm_insertBy le x ys).mem_iff.mp hz) with rfl | hz
      · exact hyx
      · exact h.1 z hz

theorem pairwise_sortBy {α : Type} (le : α → α → Bool)
    (htrans : ∀ a b c, le a b = true → le b c = true → le a c = true)
    (htotal : ∀ a b, (le a b || le b a) = true) (l : List α) :
    (sortBy le l).Pairwise (fun a b => le a b = true) := by
  induction l with
  | nil => simp [sortBy]
  | cons x xs ih => exact pairwise_insertBy le htrans htotal x _ ih

theorem sortBy_of_pairwise {α : Type} (le : α → α → Bool) (l : List α)
    (h : l.Pairwise (fun a b => le a b = true)) : sortBy le l = l := by
  induction l with
  | nil => rfl
  | cons x xs ih =>
    rw [List.pairwise_cons] at h
    simp only [sortBy, ih h.2]
    cases xs with
    | nil => rfl
    | cons y ys => simp [insertBy, h.1 y (List.mem_cons_self ..)]

theorem map_insertBy {α : Type} (le : α → α → Bool) (f : α → α)
    (hf : ∀ a b, le (f a) (f b) = le a b) (x : α) (l : List α) :
    (insertBy le x l).map f = insertBy le (f x) (l.map f) := by
  induction l with
  | nil => rfl
  | cons y ys ih => simp only [insertBy, List.map, hf]; split <;> simp [ih]

theorem map_sortBy {α : Type} (le : α → α → Bool) (f : α → α)
    (hf : ∀ a b, le (f a) (f b) = le a b) (l : List α) :
    (sortBy le l).map f = sortBy le (l.map f) := by
  induction l with
  | nil => rfl
  | cons x xs ih => simp only [sortBy, List.map, map_insertBy le f hf, ih]

theorem keyLe_trans (a b c : String × Json) (h₁ : keyLe a b = true) (h₂ : keyLe b c = true) :
    keyLe a c = true := by
  simp only [keyLe, decide_eq_true_eq] at *
  exact String.le_trans h₁ h₂

theorem keyLe_total (a b : String × Json) : (keyLe a b || keyLe b a) = true := by
  simp only [keyLe, Bool.or_eq_true, decide_eq_true_eq]
  exact String.le_total a.1 b.1

theorem keyLe_canonMember (a b : String × Json) : keyLe (canonMember a) (canonMember b) = keyLe a b := rfl

/-- Sorting the members of an object twice is sorting them once. -/
theorem sortBy_sortBy (l : List (String × Json)) :
    sortBy keyLe (sortBy keyLe l) = sortBy keyLe l :=
  sortBy_of_pairwise keyLe _ (pairwise_sortBy keyLe keyLe_trans keyLe_total l)

/-! ### Idempotence -/

mutual
/-- Canonicalizing a canonical value changes nothing: `API-12`'s "spurious conflicts" cannot come
from the stored side having been canonicalized once and the incoming side twice. -/
@[req "API-12"]
theorem Json.canonical_canonical : ∀ j : Json, j.canonical.canonical = j.canonical
  | .null | .bool _ | .num _ | .str _ => rfl
  | .arr xs => by simp [Json.canonical, Elems.canonical_canonical xs]
  | .obj kvs => by
    have ih := Members.canonical_canonical kvs
    simp only [Json.canonical]
    congr 1
    rw [Members.toList_canonical, Members.toList_ofList, ← map_sortBy keyLe canonMember
      keyLe_canonMember, sortBy_sortBy, map_sortBy keyLe canonMember keyLe_canonMember,
      ← Members.toList_canonical, ih]
theorem Elems.canonical_canonical : ∀ xs : Elems, xs.canonical.canonical = xs.canonical
  | .nil => rfl
  | .cons x xs => by simp [Elems.canonical, Json.canonical_canonical x, Elems.canonical_canonical xs]
theorem Members.canonical_canonical : ∀ m : Members, m.canonical.canonical = m.canonical
  | .nil => rfl
  | .cons k v r => by
    simp [Members.canonical, Json.canonical_canonical v, Members.canonical_canonical r]
end

/-! ### Key order -/

/-- Distinct keys make a member its key's: `WIR-1a`'s "A body MUST reject a duplicate object
member" is what makes canonical order a function of the member set. -/
theorem eq_of_key_eq {α β : Type} (l : List (α × β)) (hnodup : (l.map Prod.fst).Nodup)
    (a b : α × β) (ha : a ∈ l) (hb : b ∈ l) (hk : a.1 = b.1) : a = b := by
  induction l with
  | nil => simp at ha
  | cons c cs ih =>
    rw [List.map_cons, List.nodup_cons] at hnodup
    obtain ⟨hc, hcs⟩ := hnodup
    rcases List.mem_cons.mp ha with ha | ha <;> rcases List.mem_cons.mp hb with hb | hb
    · rw [ha, hb]
    · exact absurd (List.mem_map.mpr ⟨b, hb, by rw [← hk, ha]⟩) hc
    · exact absurd (List.mem_map.mpr ⟨a, ha, by rw [hk, hb]⟩) hc
    · exact ih hcs ha hb

theorem map_fst_canonMember (l : List (String × Json)) :
    (l.map canonMember).map Prod.fst = l.map Prod.fst := by
  rw [List.map_map]; rfl

/-- `API-12`: "key ordering and whitespace do not produce spurious conflicts". Two objects with the same
members in any order — the same set, no key twice — canonicalize to one value. -/
@[req "API-12"]
theorem canonical_key_order_insensitive (kvs kvs' : Members)
    (hperm : kvs.toList.Perm kvs'.toList) (hnodup : (kvs.toList.map Prod.fst).Nodup) :
    (Json.obj kvs).canonical = (Json.obj kvs').canonical := by
  simp only [Json.canonical, Members.toList_canonical]
  congr 2
  have hperm' := hperm.map canonMember
  apply List.Perm.eq_of_pairwise (le := fun a b => keyLe a b = true)
  · intro a b ha hb hab hba
    have hk : a.1 = b.1 := by
      simp only [keyLe, decide_eq_true_eq] at hab hba
      exact String.le_antisymm hab hba
    have ha' := (perm_sortBy keyLe _).mem_iff.mp ha
    have hb' := hperm'.mem_iff.mpr ((perm_sortBy keyLe _).mem_iff.mp hb)
    exact eq_of_key_eq _ (by rw [map_fst_canonMember]; exact hnodup) a b ha' hb' hk
  · exact pairwise_sortBy keyLe keyLe_trans keyLe_total _
  · exact pairwise_sortBy keyLe keyLe_trans keyLe_total _
  · exact ((perm_sortBy keyLe _).trans hperm').trans (perm_sortBy keyLe _).symm

mutual
/-- Two values that differ by the order of some objects' members, at any depth: `obj` reorders
one object's members (no key twice, `WIR-1a`), and the other constructors carry a reorder down
into an array or into members' values. -/
inductive Json.Reorder : Json → Json → Prop
  | refl (j : Json) : Json.Reorder j j
  | obj (kvs kvs' : Members) (hperm : kvs.toList.Perm kvs'.toList)
      (hnodup : (kvs.toList.map Prod.fst).Nodup) : Json.Reorder (.obj kvs) (.obj kvs')
  | arr {xs xs' : Elems} (h : Elems.Reorder xs xs') : Json.Reorder (.arr xs) (.arr xs')
  | inside {kvs kvs' : Members} (h : Members.Reorder kvs kvs') : Json.Reorder (.obj kvs) (.obj kvs')
inductive Elems.Reorder : Elems → Elems → Prop
  | nil : Elems.Reorder .nil .nil
  | cons {x x' : Json} {xs xs' : Elems} (hx : Json.Reorder x x') (hxs : Elems.Reorder xs xs') :
      Elems.Reorder (.cons x xs) (.cons x' xs')
inductive Members.Reorder : Members → Members → Prop
  | nil : Members.Reorder .nil .nil
  | cons (k : String) {v v' : Json} {r r' : Members} (hv : Json.Reorder v v')
      (hr : Members.Reorder r r') : Members.Reorder (.cons k v r) (.cons k v' r')
end

mutual
/-- `API-12` at every depth: one reorder anywhere leaves the canonical form unchanged, and since
equality composes, so does any sequence of them. -/
@[req "API-12"]
theorem Json.canonical_eq_of_reorder : ∀ {j j' : Json}, Json.Reorder j j' → j.canonical = j'.canonical
  | _, _, .refl _ => rfl
  | _, _, .obj kvs kvs' hperm hnodup => canonical_key_order_insensitive kvs kvs' hperm hnodup
  | _, _, .arr h => by simp only [Json.canonical, Elems.canonical_eq_of_reorder h]
  | _, _, .inside h => by simp only [Json.canonical, Members.canonical_eq_of_reorder h]
theorem Elems.canonical_eq_of_reorder : ∀ {xs xs' : Elems}, Elems.Reorder xs xs' →
    xs.canonical = xs'.canonical
  | _, _, .nil => rfl
  | _, _, .cons hx hxs => by
    simp only [Elems.canonical, Json.canonical_eq_of_reorder hx, Elems.canonical_eq_of_reorder hxs]
theorem Members.canonical_eq_of_reorder : ∀ {m m' : Members}, Members.Reorder m m' →
    m.canonical = m'.canonical
  | _, _, .nil => rfl
  | _, _, .cons k hv hr => by
    simp only [Members.canonical, Json.canonical_eq_of_reorder hv, Members.canonical_eq_of_reorder hr]
end

/-! ## `WIR-3`'s fingerprint -/

/-- `WIR-4a`'s three: "`Access-Control-Allow-Methods: GET, POST, OPTIONS`". -/
inductive Method
  | get | post | options
  deriving DecidableEq, Repr

/-- `WIR-5a`: "the origin-form path with its query when one is present ..., the path alone when
none is (`/v1/machines`, never a trailing `?`)". -/
@[req "WIR-5a"]
def requestTarget (path : String) (query : Option String) : String :=
  match query with
  | none => path
  | some q => path ++ "?" ++ q

/-- One request under a `(principal, key)`: the parts `WIR-3` fingerprints. -/
structure Request where
  method : Method
  target : String
  body   : Json
  deriving DecidableEq, Repr

/-- The dated amendments this module carries. `endpointInPreimage`: `WIR-3`, 2026-08-13 (the
requirement says `AMENDED` without a date; `6fe6ab6` is the commit), "Method and target are part
of the fingerprint" — before it the canonical form was of "a body" alone.
`closedSummary`: `STO-50`, 2026-09-06, "`request_summary` is a closed enumeration, and anything
not on the list MUST NOT be written to it". -/
structure Params where
  endpointInPreimage : Bool
  closedSummary      : Bool
  deriving DecidableEq, Repr

/-- The rules as they stand, tagged to the fingerprint's requirement though `closedSummary` is
`STO-50`'s. One field per line: `ci.yml`'s controls flip one each. -/
@[req "WIR-3"]
def current : Params := {
    endpointInPreimage := true,
    closedSummary      := true }

/-- The three fields before the hash; the body's digest stands for the canonical body, so
`Preimage` equality is hash-input equality. Without the endpoint, the method and target fields are
constant. -/
structure Preimage where
  method : Option Method
  target : Option String
  body   : Json
  deriving DecidableEq, Repr

/-- `WIR-3`'s preimage, "`{uppercase method}\n{request target per WIR-5a}\n{lowercase-hex SHA-256
of the JCS body, or the empty-body digest}`", as its three fields. -/
@[req "WIR-3"]
def preimage (p : Params) (r : Request) : Preimage :=
  { method := if p.endpointInPreimage then some r.method else none,
    target := if p.endpointInPreimage then some r.target else none,
    body   := r.body.canonical }

/-- `API-11`'s two outcomes for a reused key. -/
inductive KeyReuse
  | replay
  | conflict
  deriving DecidableEq, Repr

/-- `API-11`: "Re-sending the same key with a byte-equivalent request MUST return the existing
operation. Re-sending it with a different request MUST fail `409 Conflict`", with `API-12`
deciding equivalence over the canonical form and `WIR-3` over the fingerprint: "Any fingerprint
that is not byte-equal to the stored one, under the same `(principal, key)`, is a `409 conflict`
..., never a replay". -/
@[req "API-11"]
def onKeyReuse (p : Params) (stored incoming : Request) : KeyReuse :=
  if preimage p stored = preimage p incoming then .replay else .conflict

/-- `API-12` on `API-11`: a body that differs from the stored one in member order alone replays. -/
@[req "API-12"]
theorem reordered_body_replays (p : Params) (r : Request) (kvs kvs' : Members)
    (hperm : kvs.toList.Perm kvs'.toList) (hnodup : (kvs.toList.map Prod.fst).Nodup) :
    onKeyReuse p { r with body := .obj kvs } { r with body := .obj kvs' } = .replay := by
  simp [onKeyReuse, preimage, canonical_key_order_insensitive kvs kvs' hperm hnodup]

/-- `WIR-3`: "the same idempotency key reused against a different machine or endpoint would replay
the first call's result instead of conflicting" — with the endpoint in the preimage, a different
target conflicts whatever the body. -/
@[req "WIR-3"]
theorem different_target_conflicts (p : Params) (hp : p.endpointInPreimage = true)
    (stored incoming : Request) (h : stored.target ≠ incoming.target) :
    onKeyReuse p stored incoming = .conflict := by
  simp [onKeyReuse, preimage, hp, h]

/-- The same for the method. -/
@[req "WIR-3"]
theorem different_method_conflicts (p : Params) (hp : p.endpointInPreimage = true)
    (stored incoming : Request) (h : stored.method ≠ incoming.method) :
    onKeyReuse p stored incoming = .conflict := by
  simp [onKeyReuse, preimage, hp, h]

/-! ## `DOM-6`'s redaction -/

/-- Structural, so `decide` runs it; core's `List.isInfixOf` is internal. -/
def isInfixOf (p : List Char) : List Char → Bool
  | [] => p.isPrefixOf []
  | c :: cs => p.isPrefixOf (c :: cs) || isInfixOf p cs

/-- `DOM-6`: "Any object key whose lowercased form contains `password`, `secret`, or `private_key`,
or equals `token`, `api_key`, `authorization`, or `credential`". -/
@[req "DOM-6"]
def sensitiveKey (k : String) : Bool :=
  let cs := k.toList.map Char.toLower
  isInfixOf "password".toList cs || isInfixOf "secret".toList cs
    || isInfixOf "private_key".toList cs
    || cs == "token".toList || cs == "api_key".toList || cs == "authorization".toList
    || cs == "credential".toList

/-- `DOM-6`'s "redaction marker". -/
def marker : Json := .str "[REDACTED]"

mutual
/-- `DOM-6`: a sensitive key's value "MUST have its value replaced with a redaction marker,
recursively through objects and arrays". -/
@[req "DOM-6"]
def Json.redact : Json → Json
  | .null => .null
  | .bool b => .bool b
  | .num n => .num n
  | .str s => .str s
  | .arr xs => .arr xs.redact
  | .obj kvs => .obj kvs.redact
def Elems.redact : Elems → Elems
  | .nil => .nil
  | .cons x xs => .cons x.redact xs.redact
def Members.redact : Members → Members
  | .nil => .nil
  | .cons k v r => .cons k (if sensitiveKey k then marker else v.redact) r.redact
end

mutual
/-- No sensitive key holds anything but the marker, at any depth. -/
def Json.clean : Json → Bool
  | .null | .bool _ | .num _ | .str _ => true
  | .arr xs => xs.clean
  | .obj kvs => kvs.clean
def Elems.clean : Elems → Bool
  | .nil => true
  | .cons x xs => x.clean && xs.clean
def Members.clean : Members → Bool
  | .nil => true
  | .cons k v r => (if sensitiveKey k then decide (v = marker) else v.clean) && r.clean
end

mutual
/-- `DOM-18`: redacted "before it is stored or returned" — redacting on the way out what was
redacted on the way in changes nothing. -/
@[req "DOM-18"]
theorem Json.redact_redact : ∀ j : Json, j.redact.redact = j.redact
  | .null | .bool _ | .num _ | .str _ => rfl
  | .arr xs => by simp [Json.redact, Elems.redact_redact xs]
  | .obj kvs => by simp [Json.redact, Members.redact_redact kvs]
theorem Elems.redact_redact : ∀ xs : Elems, xs.redact.redact = xs.redact
  | .nil => rfl
  | .cons x xs => by simp [Elems.redact, Json.redact_redact x, Elems.redact_redact xs]
theorem Members.redact_redact : ∀ m : Members, m.redact.redact = m.redact
  | .nil => rfl
  | .cons k v r => by
    simp only [Members.redact, Members.redact_redact r]
    split
    · simp [marker]
    · simp [Json.redact_redact v]
end

mutual
/-- What `Json.redact` leaves is clean. -/
@[req "DOM-6"]
theorem Json.clean_redact : ∀ j : Json, j.redact.clean = true
  | .null | .bool _ | .num _ | .str _ => rfl
  | .arr xs => by simp [Json.redact, Json.clean, Elems.clean_redact xs]
  | .obj kvs => by simp [Json.redact, Json.clean, Members.clean_redact kvs]
theorem Elems.clean_redact : ∀ xs : Elems, xs.redact.clean = true
  | .nil => rfl
  | .cons x xs => by simp [Elems.redact, Elems.clean, Json.clean_redact x, Elems.clean_redact xs]
theorem Members.clean_redact : ∀ m : Members, m.redact.clean = true
  | .nil => rfl
  | .cons k v r => by
    simp only [Members.redact, Members.clean, Members.clean_redact r, Bool.and_true]
    split <;> simp [Json.clean_redact v]
end

/-! ## The stored row and its projections -/

/-- What the `request` column holds, by `STO-9`: "signed image URLs, SSH keys, and up to 1 MiB of
post-install script", and the rest of `STO-50`'s list — "a caller-chosen hostname, SSH public
keys, user data, a post-install script, a signed image URL, a disk layout, or a spending cap". -/
structure Payload where
  hostname    : String
  sshKeys     : List String
  userData    : Option String
  postInstall : Option String
  imageUrl    : Option String
  diskLayout  : Option String
  spendingCap : Option Nat
  deriving DecidableEq, Repr

/-- `WIR-10a`: "`requested_by` ∈ {`caller`, `system`, `operator`}". -/
inductive RequestedBy
  | caller | system | operator
  deriving DecidableEq, Repr

/-- The `operations` row, as the columns the two projections read. `request` is the private
column: the table's `request` row says "live operations only", and `STO-9` "It MUST NOT be
returned by the API". -/
structure Row where
  id                  : OperationId
  tenant              : TenantId
  idempotencyKey      : String
  kind                : Kind
  status              : Status
  machine             : Option MachineId
  providerAccount     : Option String
  request             : Option Payload
  providerIds         : List String
  correlator          : Option String
  offerSnapshot       : Option String
  setupFeeSats        : Option Nat
  writeStartedAt      : Option Nat
  rescueExitedCleanly : Option Bool
  result              : Json
  error               : Json
  revision            : Nat
  retryable           : Bool
  requestedBy         : RequestedBy
  systemReason        : Option String
  episode             : Option EpisodeId
  committedSats       : Option Nat
  createdAt           : Nat
  updatedAt           : Nat
  correlationId       : String
  deriving DecidableEq, Repr

/-- `OPS-3`: "`succeeded` and `failed` are the terminal states." -/
def isTerminal : Status → Bool
  | .succeeded | .failed => true
  | .queued | .running | .needsReconciliation => false

/-- `WIR-10`'s keys, `API-20`'s list. -/
structure OperationView where
  id              : OperationId
  kind            : Kind
  tenant          : TenantId
  status          : Status
  terminal        : Bool
  revision        : Nat
  retryable       : Bool
  requestedBy     : RequestedBy
  systemReason    : Option String
  episodeId       : Option EpisodeId
  machineId       : Option MachineId
  providerAccount : Option String
  idempotencyKey  : String
  committedSats   : Option Nat
  result          : Json
  error           : Json
  pollAfterMs     : Option Nat
  createdAt       : Nat
  updatedAt       : Nat
  correlationId   : String
  deriving DecidableEq, Repr

/-- `API-20`'s view from the row, one field at a time; `pacing` is `API-49`'s value, carried
"only while non-terminal" (`WIR-10`). Nothing here reads `request`. -/
@[req "API-21"]
def operationView (pacing : Nat) (r : Row) : OperationView :=
  { id := r.id, kind := r.kind, tenant := r.tenant, status := r.status,
    terminal := isTerminal r.status, revision := r.revision, retryable := r.retryable,
    requestedBy := r.requestedBy, systemReason := r.systemReason, episodeId := r.episode,
    machineId := r.machine, providerAccount := r.providerAccount,
    idempotencyKey := r.idempotencyKey, committedSats := r.committedSats,
    result := r.result, error := r.error,
    pollAfterMs := if isTerminal r.status then none else some pacing,
    createdAt := r.createdAt, updatedAt := r.updatedAt, correlationId := r.correlationId }

/-- `API-21`: "The operation view MUST NOT include the stored request payload." The view of a row
is the view of the same row with the payload purged — whatever the payload held. -/
@[req "API-21"]
theorem view_independent_of_request (pacing : Nat) (r : Row) (x : Option Payload) :
    operationView pacing { r with request := x } = operationView pacing r := rfl

/-- `API-22`: result and error "MUST be redacted ... before they are stored, not merely before
they are rendered" — the write is where `DOM-6` runs. -/
@[req "API-22"]
def storeResult (r : Row) (result error : Json) : Row :=
  { r with result := result.redact, error := error.redact }

/-- What the store holds is clean, and the view renders the stored value with no redaction of its
own (`operationView` copies `result` and `error`), so what reaches the wire was clean at rest. -/
@[req "API-22"]
theorem stored_is_clean (r : Row) (result error : Json) :
    (storeResult r result error).result.clean = true ∧
    (storeResult r result error).error.clean = true :=
  ⟨Json.clean_redact result, Json.clean_redact error⟩

/-- `STO-50`'s closed enumeration: "the operation's kind, its machine where it has one, the
resolved provider account (`OPS-35`), and what `OPS-13` requires: what was attempted, and any
provider-side identifiers that were created"; "For a create — the correlator, the offer snapshot
and the at-cost setup fee"; "the two markers, `write_started_at` and `rescue_exited_cleanly`".
`attempted` is "what was attempted" as the open bucket it was until 2026-09-06: "an open-ended
summary standing beside a purged `request` is a hole in the purge". -/
structure Summary where
  kind                : Kind
  machine             : Option MachineId
  providerAccount     : Option String
  providerIds         : List String
  correlator          : Option String
  offerSnapshot       : Option String
  setupFeeSats        : Option Nat
  writeStartedAt      : Option Nat
  rescueExitedCleanly : Option Bool
  attempted           : Option Payload
  deriving DecidableEq, Repr

/-- `STO-50`'s `request_summary` from the row. With the enumeration closed, "what was attempted"
is the kind and the machine already listed and the bucket is empty; without it, the bucket is the
payload — "a bucket that admits anything admits exactly the material `STO-9` above lists as the
reason the purge exists". -/
@[req "STO-50"]
def summary (p : Params) (r : Row) : Summary :=
  { kind := r.kind, machine := r.machine, providerAccount := r.providerAccount,
    providerIds := r.providerIds, correlator := r.correlator, offerSnapshot := r.offerSnapshot,
    setupFeeSats := r.setupFeeSats, writeStartedAt := r.writeStartedAt,
    rescueExitedCleanly := r.rescueExitedCleanly,
    attempted := if p.closedSummary then none else r.request }

/-- `STO-50`: "the summary MUST NOT carry a caller-chosen hostname, SSH public keys, user data, a
post-install script, a signed image URL, a disk layout, or a spending cap". With the enumeration
closed, the summary of a row is the summary of the row with its payload purged. -/
@[req "STO-50"]
theorem summary_independent_of_request (p : Params) (hc : p.closedSummary = true) (r : Row)
    (x : Option Payload) : summary p { r with request := x } = summary p r := by
  simp [summary, hc]

/-- `ADR-0005`'s purge, `STO-9`: "it MUST be purged when the operation reaches any settled state,
and on entry to `needs_reconciliation`". -/
@[req "STO-9"]
def purge (r : Row) : Row := { r with request := none }

/-- The two projections read nothing the purge removes: each is the same before and after it. -/
@[req "STO-9"]
theorem projections_survive_purge (p : Params) (hc : p.closedSummary = true) (pacing : Nat)
    (r : Row) : operationView pacing (purge r) = operationView pacing r ∧
      summary p (purge r) = summary p r :=
  ⟨view_independent_of_request pacing r none, summary_independent_of_request p hc r none⟩

/-! ## `SEC-8`: the tenant-scoped lookup -/

/-- The observable: `WIR-9`'s `404` envelope, or `200` with the view. -/
inductive Response (α : Type)
  | notFound
  | ok (body : α)
  deriving DecidableEq, Repr

/-- A stored record with the tenant it belongs to. -/
structure Owned (α : Type) where
  owner  : TenantId
  record : α
  deriving DecidableEq, Repr

/-- `API-17`: "Every machine-scoped endpoint MUST resolve the machine *within the caller's tenant*
and MUST return `404` — not `403` — when it does not exist there." One function; `machineLookup`
and `operationLookup` are its two callers, and there is no other path from an id to a body. -/
@[req "API-17"]
def scopedLookup {α β : Type} (caller : TenantId) (found : Option (Owned α)) (project : α → β) :
    Response β :=
  match found with
  | none => .notFound
  | some o => if o.owner = caller then .ok (project o.record) else .notFound

/-- `SEC-8`: "a machine outside the tenant MUST be indistinguishable from one that does not exist".
For every caller, every foreign record and every projection, the response to the foreign record is
the response to no record. -/
@[req "SEC-8"]
theorem foreign_indistinguishable_from_absent {α β : Type} (caller : TenantId) (o : Owned α)
    (h : o.owner ≠ caller) (project : α → β) :
    scopedLookup caller (some o) project = scopedLookup caller none project := by
  simp [scopedLookup, h]

/-- The machine row's two columns the customer surface names and the two it hides: `WIR-11`,
"`external_id` and raw provider metadata are **absent** on the customer surface". -/
structure MachineRow where
  id         : MachineId
  name       : String
  externalId : String
  metadata   : Json
  deriving DecidableEq, Repr

structure MachineView where
  id   : MachineId
  name : String
  deriving DecidableEq, Repr

/-- `WIR-11`'s view, "`external_id` and raw provider metadata are **absent** on the customer
surface": the projection reads neither. -/
@[req "WIR-11"]
def machineView (m : MachineRow) : MachineView := { id := m.id, name := m.name }

/-- The view of a machine row is the view of the same row with both provider columns replaced. -/
@[req "WIR-11"]
theorem machineView_independent_of_provider_fields (m : MachineRow) (e : String) (j : Json) :
    machineView { m with externalId := e, metadata := j } = machineView m := rfl

/-- `SEC-8`: "Machine lookup MUST be tenant-scoped" — the machine endpoints' path from an id to a
body, through `scopedLookup`. -/
@[req "SEC-8"]
def machineLookup (caller : TenantId) (found : Option (Owned MachineRow)) : Response MachineView :=
  scopedLookup caller found machineView

/-- `API-17a`: "The same rule applies to operations ... `GET /v1/operations/{id}` MUST resolve
within the caller's tenant and return `404` otherwise". -/
@[req "API-17a"]
def operationLookup (pacing : Nat) (caller : TenantId) (found : Option (Owned Row)) :
    Response OperationView :=
  scopedLookup caller found (operationView pacing)

end Provisiond.Wire
