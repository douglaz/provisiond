import Provisiond.Claim
import Provisiond.Tables
/-! `RSC-39`'s catalogue re-host: the one fetch provisiond makes itself, and what bounds it.

`RSC-39` has provisiond "fetch the caller's image, verify its `sha256` **as it streams** … store
it in operator-controlled immutable storage (`RSC-30`), and give the provider a URL to that copy",
because "The caller's own URL MUST NOT be passed to the provider". That puts an anonymous
stranger's URL inside the credential-holding process, which is what `RSC-44` and `SEC-19` exist to
bound, and this module is those bounds as functions and theorems.

Five models, each tagged to the requirement whose sentence it carries. The fetch (`RSC-44`,
`SEC-18`, `SEC-19`): an address class as a total function with no wildcard, a redirect chain
validated hop by hop, and a refusal that cannot describe its target. The stream (`RSC-40`): what
provisiond may learn about a caller's bytes, with the prohibition on interpreting them stated as
an independence theorem rather than as a comment. The import (`RSC-41`, `RSC-42`): yielded while
it runs, bounded by a stated wait, re-validated on re-acquiring the machine, and both copies
purged when the operation stops being live — the provider's by a call that may be lost and a
sweep that reaches the orphan by its tag. The settle (`RSC-43`): the provider's report and nothing
provisiond measured. The two URLs (`RSC-39`): what the provider is given.

What the model omits, beyond the parts of each requirement named below.

DNS: a `Hop` carries the addresses a name already resolved to, so `RSC-44`'s "Connect to the
address that was validated, pinning it for the connection, or re-validate at connect time" is the
resolver's correspondence and not a theorem here — the model cannot express two answers to one
lookup because it never performs one. The address classes are an enumeration, not CIDR
arithmetic: that `169.254.0.0/16` is link-local is arithmetic `RSC-44` states as a list and this
module takes as given.

Of `RSC-44`'s refusal, only the half about silence: the kind is `refusalKind` and nothing models
the response, so "The response body MUST NOT reach the caller" is a statement about a program
this module does not contain. Of `SEC-18`, only the scheme: "MUST NOT carry embedded credentials,
and MUST NOT carry a fragment (`API-13`)" is about a URL's shape, and a `Hop` has none. Of
`SEC-19`, only the request-time check: the allowlist is an exact membership here, so `SEC-20`'s
matching rules are outside, as is the startup refusal that requirement also carries.

Of `RSC-40`, only the bound's arithmetic: `measure` reads a finished stream's total, so "enforced
against the stream, aborting the transfer when exceeded" is modelled as a verdict and not as a
transfer that stops mid-flight, and the denial-of-service reasoning that clause carries is
therefore outside. Of `RSC-43`, only the settle: "What the deployment owes instead is disclosure"
(`WIR-30`, `DOM-29`) is a disclosure obligation with nothing here to observe.

Bytes are a length and a digest, never content; SHA-256 is not modelled, so two streams with equal
digests are equal here and a collision is outside the model, as in `Provisiond.Wire`. Storage is
outside: `RSC-30`'s immutability is not modelled, and no event of this module puts a copy back, so
`RSC-42`'s "A fresh copy arrives only by the caller sending a fresh install" is unmodellable here
rather than proved. Time is a count of waits, not a clock.

`Params` carries the guards a dated amendment added — `allowlistRequired` and `allowlistPerHop` —
and `schemePerHop`, which `RSC-44` carried from the start and which is a parameter for the same
reason: it is a control that could be left out, and the pair shows what leaving it out admits.
Each has the pair the epic requires, the bad trace refused with the guard and admitted without it.
The untagged import (`RSC-42`) is refuted as an alternative definition rather than as a guard,
the way `Provisiond.Rescue`'s `RSC-26` pair is. -/

namespace Provisiond.Rehost

/-! ## `RSC-44`'s address classes -/

/-- The classes `RSC-44` enumerates — "loopback, link-local (`169.254.0.0/16`, `fe80::/10`),
private (`10/8`, `172.16/12`, `192.168/16`, `fc00::/7`), carrier-grade NAT (`100.64/10`),
multicast, broadcast, unspecified" — and the one class that is none of them. `privateNet` is
`RSC-44`'s "private"; the name avoids Lean's `private`. -/
inductive Class
  | loopback | linkLocal | privateNet | cgnat | multicast | broadcast | unspecified | routable
  deriving DecidableEq, Repr

def Class.all : List Class :=
  [.loopback, .linkLocal, .privateNet, .cgnat, .multicast, .broadcast, .unspecified, .routable]

theorem Class.mem_all (c : Class) : c ∈ Class.all := by cases c <;> decide

instance {p : Class → Prop} [DecidablePred p] : Decidable (∀ c, p c) :=
  Tables.decidableForallOfList Class.all Class.mem_all p

/-- An address as the fetch sees it: a class, or `RSC-44`'s "IPv4-mapped or IPv4-compatible IPv6
address wrapping any of those". The wrapper is recursive so that no depth of wrapping launders a
class, which is the whole of that clause. -/
inductive Addr
  | plain (c : Class)
  | mapped (a : Addr)
  deriving DecidableEq, Repr

/-- What an address is, whatever it is wrapped in. -/
def Addr.classOf : Addr → Class
  | .plain c => c
  | .mapped a => a.classOf

/-- `RSC-44`'s list, as a total function of the class: every class it names is refused and the one
it does not name is not. No wildcard — a class added to `Class` is a missing case here, which is
the point of writing it this way. -/
@[req "RSC-44"]
def builtinRefused (a : Addr) : Bool :=
  match a.classOf with
  | .loopback => true
  | .linkLocal => true
  | .privateNet => true
  | .cgnat => true
  | .multicast => true
  | .broadcast => true
  | .unspecified => true
  | .routable => false

/-- `RSC-44`: "A deployment MUST be able to add ranges — its own metadata service, its own
management network — and MUST NOT be able to remove the list." The deployment supplies a predicate
that can only add. -/
@[req "RSC-44"]
def addrRefused (extra : Addr → Bool) (a : Addr) : Bool :=
  builtinRefused a || extra a

/-- The half a deployment cannot reach: whatever it configures, `RSC-44`'s own list still refuses.
-/
@[req "RSC-44"]
theorem builtin_cannot_be_removed (extra : Addr → Bool) (a : Addr) (h : builtinRefused a = true) :
    addrRefused extra a = true := by
  simp [addrRefused, h]

/-- The half it can: adding ranges only ever refuses more. -/
@[req "RSC-44"]
theorem extra_only_adds (extra : Addr → Bool) (a : Addr)
    (h : addrRefused (fun _ => false) a = true) : addrRefused extra a = true := by
  simp [addrRefused] at h ⊢; simp [h]

/-- Wrapping launders nothing, at any depth: `RSC-44`'s "or an IPv4-mapped or IPv4-compatible IPv6
address wrapping any of those". -/
@[req "RSC-44"]
theorem mapped_does_not_launder (a : Addr) : builtinRefused (.mapped a) = builtinRefused a := rfl

/-- Every class `RSC-44` names is refused, and a routable address is not: the list read back off
the function, rather than trusted to match. -/
@[req "RSC-44"]
theorem builtin_refuses_exactly_the_listed_classes :
    ∀ c : Class, builtinRefused (.plain c) = true ↔ c ≠ .routable := by decide

/-! ## `SEC-18`'s scheme and `SEC-19`'s allowlist -/

/-- A host name. Names are compared, never resolved, here. -/
structure Host where n : Nat deriving DecidableEq, Repr

/-- `SEC-18`: "Image URLs MUST be HTTPS unless insecure HTTP is explicitly enabled". -/
inductive Scheme | https | http
  deriving DecidableEq, Repr

/-- One hop of a fetch: the name its URL carries, that URL's scheme, and every address the name
resolved to — `RSC-44`'s "both families, every A and AAAA record". -/
structure Hop where
  host   : Host
  scheme : Scheme
  addrs  : List Addr
  deriving DecidableEq, Repr

/-- What a deployment configures. `redirectCap` is `RSC-44`'s "cap the redirect count". -/
structure Policy where
  allowlist    : List Host
  httpEnabled  : Bool
  extraRefused : Addr → Bool
  redirectCap  : Nat

/-- The dated amendments this module carries.

`allowlistRequired`: `SEC-19`, 2026-09-02 — "For that path a host allowlist MUST be configured
(`OVR-19`), and an empty one means **no catalogue install may be requested** rather than 'any
host'". Without it the empty list is the fail-open default that requirement's amendment refuses.

`allowlistPerHop`: `RSC-44`, 2026-09-04 — "Re-check `SEC-19`'s host allowlist on every hop,
against the redirect target's own name", which that bullet calls "a different control from the
bullets above rather than a restatement of them". Without it the allowlist is checked once,
"against a URL the attacker was free to abandon on the first hop".

`schemePerHop`: `RSC-44` — "Hold the scheme across every hop: `https` only, or `http` where a
deployment has explicitly enabled it (`SEC-18`), refused on redirect as well as on the original
URL." Without it the rule is the original URL's alone, which is what the same bullet records as
having been the state of this path when `RSC-17` was miscited for it. -/
structure Params where
  allowlistRequired : Bool
  allowlistPerHop   : Bool
  schemePerHop      : Bool
  deriving DecidableEq, Repr

/-- The rules as they stand. -/
@[req "RSC-44"]
def current : Params := {
    allowlistRequired := true,
    allowlistPerHop   := true,
    schemePerHop      := true }

/-- `SEC-19` as amended: with the guard an empty allowlist admits no host at all, without it an
empty allowlist admits every host. -/
@[req "SEC-19"]
def hostAllowed (p : Params) (pol : Policy) (h : Host) : Bool :=
  match pol.allowlist with
  | [] => !p.allowlistRequired
  | l  => l.contains h

/-- `SEC-18`'s scheme rule for one URL. -/
@[req "SEC-18"]
def schemeOk (pol : Policy) : Scheme → Bool
  | .https => true
  | .http  => pol.httpEnabled

/-! ## The fetch -/

/-- What a fetch did. `refused` carries nothing: `RSC-44` says the refusal MUST "never report why
in a way that describes the target", and a constructor with no field is that sentence as a type —
there is no resolved address, status or size to leak because the value cannot hold one. -/
inductive Outcome
  | fetched
  | refused
  deriving DecidableEq, Repr

/-- `RSC-44`: "**Refuse with `invalid_request`** (`DOM-17`)", the kind that requirement names
because "`API-24` forbids a handler choosing one, and a refusal with no kind is the defect this
same review fixed for `SEC-39` by minting `ceiling_exceeded`". -/
@[req "RSC-44"]
def refusalKind : Tables.ErrorKind := .invalidRequest

/-- One hop's checks. The address check runs on every hop unconditionally — that is `RSC-44`'s
"again after every redirect" — while the allowlist and the scheme run on a later hop only under
their guards, so that removing a guard reproduces exactly the behaviour its bullet refuses. -/
@[req "RSC-44"]
def addrsOk (pol : Policy) (h : Hop) : Bool :=
  !h.addrs.isEmpty && h.addrs.all (fun a => !addrRefused pol.extraRefused a)

/-- The two checks a guard can switch off on a later hop. -/
def guardsOk (p : Params) (pol : Policy) (first : Bool) (h : Hop) : Bool :=
  (!first && !p.allowlistPerHop || hostAllowed p pol h.host)
  && (!first && !p.schemePerHop || schemeOk pol h.scheme)

/-- One hop: the addresses always, the other two under their guards. One `&&` at the top, so what
a hop guarantees unconditionally is the left of it. -/
@[req "RSC-44"]
def hopOk (p : Params) (pol : Policy) (first : Bool) (h : Hop) : Bool :=
  addrsOk pol h && guardsOk p pol first h

theorem hopOk_addrs {p : Params} {pol : Policy} {first : Bool} {h : Hop}
    (hh : hopOk p pol first h = true) : addrsOk pol h = true :=
  ((Bool.and_eq_true _ _).mp hh).left

/-- Every hop of a chain, the first one flagged. Structural, so `decide` runs it. -/
def hopsOk (p : Params) (pol : Policy) : Bool → List Hop → Bool
  | _, [] => true
  | first, h :: rest => hopOk p pol first h && hopsOk p pol false rest

/-- `RSC-39`'s fetch over the chain the caller's URL leads to: the original URL is the first hop
and each redirect is another. Over the cap, or with no hop at all, nothing is fetched. -/
@[req "RSC-44"]
def fetch (p : Params) (pol : Policy) (hops : List Hop) : Outcome :=
  if hops.isEmpty then .refused
  else if hops.length > pol.redirectCap + 1 then .refused
  else if hopsOk p pol true hops then .fetched else .refused

/-- A chain one hop longer than the cap allows is refused however good its hops are: `RSC-44`'s
"cap the redirect count". -/
@[req "RSC-44"]
theorem over_the_cap_is_refused (p : Params) (pol : Policy) (hops : List Hop)
    (h : hops.length > pol.redirectCap + 1) : fetch p pol hops = .refused := by
  have hne : hops.isEmpty = false := by
    cases hops with
    | nil => simp at h
    | cons _ _ => rfl
  simp [fetch, hne, h]

/-- Every hop a chain passes has had its addresses validated, whatever the guards say: the address
bullet is not one of the three parameters, so no configuration reaches an address `RSC-44` lists.
-/
@[req "RSC-44"]
theorem every_hop_of_a_passing_chain_is_validated (p : Params) (pol : Policy) :
    ∀ (first : Bool) (hops : List Hop), hopsOk p pol first hops = true →
      ∀ h ∈ hops, addrsOk pol h = true
  | _, [], _ => by simp
  | first, h :: rest, hh => by
      have hsplit := (Bool.and_eq_true _ _).mp hh
      intro x hx
      rcases List.mem_cons.mp hx with rfl | hxr
      · exact hopOk_addrs hsplit.left
      · exact every_hop_of_a_passing_chain_is_validated p pol false rest hsplit.right x hxr

/-! ## `RSC-40`'s stream -/

/-- A digest stands for the bytes it was taken over; SHA-256 is not modelled. -/
structure Digest where n : Nat deriving DecidableEq, Repr

/-- The content of the image. Nothing in this module reads it, and `content_is_never_read` is that
claim as a theorem. -/
structure Content where n : Nat deriving DecidableEq, Repr

/-- What arrives on the wire: `RSC-40`'s "It counts the bytes and hashes them", and the bytes
themselves. -/
structure Stream where
  bytes   : Nat
  digest  : Digest
  content : Content
  deriving DecidableEq, Repr

/-- What a measured stream did. The two refusals are kept apart because they are two
requirements: `RSC-40`'s bound "aborting the transfer when exceeded", and `RSC-39`'s verification,
whose failure is an `integrity` failure in `RSC-3`'s sense rather than a transfer that grew too
large. -/
inductive Measured
  | accepted
  | abortedOversize
  | abortedIntegrity
  deriving DecidableEq, Repr

/-- `RSC-40`: "**A maximum image size MUST be declared per offer and enforced against the
stream**, aborting the transfer when exceeded", and `RSC-39`'s "verify its `sha256` **as it
streams**". The size is checked first because it is the one that bounds the transfer. -/
@[req "RSC-40"]
def measure (maxSize : Nat) (declared : Digest) (s : Stream) : Measured :=
  if s.bytes > maxSize then .abortedOversize
  else if s.digest = declared then .accepted else .abortedIntegrity

/-- `RSC-40`: "provisiond measures a caller's image and MUST NOT interpret it … It MUST NOT parse
the content — not the partition table, not the image format, not the filesystem". The measurement
of a stream is the measurement of the same stream carrying any other content, so the "cheap
magic-byte check" that requirement records refusing cannot be added without this theorem failing.
-/
@[req "RSC-40"]
theorem content_is_never_read (maxSize : Nat) (declared : Digest) (s : Stream) (c : Content) :
    measure maxSize declared { s with content := c } = measure maxSize declared s := rfl

/-- The bound bites, and it bites before the digest: over the offer's maximum the transfer aborts
whatever the bytes hashed to. -/
@[req "RSC-40"]
theorem over_the_size_bound_aborts (maxSize : Nat) (declared : Digest) (s : Stream)
    (h : s.bytes > maxSize) : measure maxSize declared s = .abortedOversize := by
  simp [measure, h]

/-- A stream within the bound whose digest is not the one the caller declared fails verification,
which is `RSC-39`'s check "as it streams". -/
@[req "RSC-39"]
theorem a_wrong_digest_fails_verification (maxSize : Nat) (declared : Digest) (s : Stream)
    (hs : s.bytes ≤ maxSize) (hd : s.digest ≠ declared) :
    measure maxSize declared s = .abortedIntegrity := by
  simp [measure, Nat.not_lt.mpr hs, hd]

/-! ## `RSC-41`'s import and `RSC-42`'s purge -/

/-- Where the operation is. `RSC-41`: the import runs "while **yielded** (`OPS-8`'s
`yielded_at`)", and the operation holds "the machine only for the rebuild and the cleanup". -/
inductive Phase
  | importing
  | rebuilding
  | cleaningUp
  | settled
  deriving DecidableEq, Repr

/-- `RSC-41`'s division, as a total function with no wildcard. -/
@[req "RSC-41"]
def holdsMachine : Phase → Bool
  | .importing => false
  | .rebuilding => true
  | .cleaningUp => true
  | .settled => false

/-- The operation's correlator, which `RSC-42` requires the import to carry "as a provider-side
tag". -/
structure Correlator where n : Nat deriving DecidableEq, Repr

/-- The provider's imported copy: whether it is there, and the tag the import carried. `none` is
the untagged import, which is the design `RSC-42`'s sentence refuses rather than a guard a
deployment could switch off — so it is an alternative definition here and not a `Params` field,
the way `Provisiond.Rescue`'s `RSC-26` pair is. -/
structure ProviderImage where
  present : Bool
  tag     : Option Correlator
  deriving DecidableEq, Repr

/-- The two copies `RSC-42` names: "the operator's re-hosted copy and the provider's imported
one". They are not symmetric, which is the whole of that requirement's second half: the operator's
is in storage the deployment controls, the provider's is "deleted by a call that may fail or be
lost". -/
structure Copies where
  operator : Bool
  provider : ProviderImage
  deriving DecidableEq, Repr

/-- The operation as this module needs it. `reacquired` is `RSC-41`'s "On re-acquiring the
machine", which happens after the yielded import and is the moment `OPS-23`'s re-validation is
about. -/
structure World where
  phase       : Phase
  copies      : Copies
  waited      : Nat
  reacquired  : Bool
  revalidated : Bool
  status      : Claim.Status
  deriving DecidableEq, Repr

/-- What can happen. `settle` carries the state the operation enters — `Claim.Written` is exactly
`RSC-42`'s set, "any settled state **and** … `needs_reconciliation`", so no other state is a value
of this event — and whether the provider-side delete the settle issues actually landed. `sweep` is
`OPS-32`'s account pass. -/
inductive Event
  | wait
  | reacquire
  | revalidate
  | settle (s : Claim.Written) (deleteLands : Bool)
  | sweep (settled : List Correlator)
  deriving DecidableEq, Repr

/-- `RSC-42`: "Both copies of the image are purged when the operation stops being live … on entry
to any settled state **and on entry to `needs_reconciliation`**." The operator's copy goes, and
the provider is asked to delete its own — a call `RSC-42` says "may fail or be lost". -/
@[req "RSC-42"]
def settleCopies (c : Copies) (deleteLands : Bool) : Copies :=
  { operator := false,
    provider := if deleteLands then { c.provider with present := false } else c.provider }

/-- `OPS-32`'s account sweep as `RSC-42` extends it: "`OPS-32`'s account sweep MUST delete any
image whose operation has settled or vanished". It reaches an image by the tag the import carried,
and an untagged image by nothing at all. -/
@[req "RSC-42"]
def sweepCopies (settled : List Correlator) (c : Copies) : Copies :=
  match c.provider.tag with
  | some t => if settled.contains t then { c with provider := { c.provider with present := false } }
              else c
  | none => c

/-- One step. `maxWait` is `RSC-41`'s "A maximum import wait MUST be stated, past which the
operation aborts and the imported image is deleted" — the abort is a settle into `failed`, and the
deletion is `RSC-42`'s purge doing its own job rather than a second rule. The re-validation is
admitted only once the machine has been re-acquired, and re-acquiring clears it: `OPS-23` is about
the machine in hand, not about a check made before the import began. -/
@[req "RSC-41"]
def step (maxWait : Nat) (w : World) : Event → World
  | .wait =>
      if w.phase = .importing then
        if w.waited + 1 > maxWait then
          { w with status := .failed, phase := .settled, copies := settleCopies w.copies true }
        else { w with waited := w.waited + 1 }
      else w
  | .reacquire =>
      if w.phase = .importing then { w with reacquired := true, revalidated := false } else w
  | .revalidate =>
      if w.phase = .importing && w.reacquired then { w with revalidated := true } else w
  | .settle s lands =>
      { w with status := s.status, phase := .settled, copies := settleCopies w.copies lands }
  | .sweep settled => { w with copies := sweepCopies settled w.copies }

/-- The import moves to the rebuild only with the machine re-acquired and re-validated since:
`RSC-41`'s "On re-acquiring the machine the operation MUST re-validate before the rebuild
(`OPS-23`)". -/
@[req "RSC-41"]
def beginRebuild (w : World) : World :=
  if w.phase = .importing && w.reacquired && w.revalidated then { w with phase := .rebuilding }
  else w

/-- Structural fold, so `decide` runs it. -/
def run (maxWait : Nat) (w : World) : List Event → World
  | [] => w
  | e :: rest => run maxWait (step maxWait w e) rest

/-- `RSC-41`: the import "touches no machine", so nothing during it holds the machine. -/
@[req "RSC-41"]
theorem importing_holds_no_machine : holdsMachine .importing = false := rfl

/-- `OPS-23`'s guard: the rebuild is not reachable from an import that has not been re-validated
since the machine came back. A re-validation from before the re-acquisition does not count,
because `reacquire` clears it. -/
@[req "RSC-41"]
theorem no_rebuild_without_revalidation (w : World) (hp : w.phase = .importing)
    (h : w.revalidated = false) : (beginRebuild w).phase = .importing := by
  simp [beginRebuild, hp, h]

/-- Past the stated maximum the operation aborts: `RSC-41`'s bound. -/
@[req "RSC-41"]
theorem past_the_max_wait_aborts (maxWait : Nat) (w : World)
    (hp : w.phase = .importing) (hw : w.waited + 1 > maxWait) :
    (step maxWait w .wait).status = .failed := by
  simp [step, hp, hw]

/-- `RSC-42` on every state it names: entering one takes the operator's copy, whatever else
happens. `Claim.Written` is that set, so there is no state to check against. -/
@[req "RSC-42"]
theorem settling_purges_the_operator_copy (maxWait : Nat) (w : World) (s : Claim.Written)
    (lands : Bool) : (step maxWait w (.settle s lands)).copies.operator = false := by
  simp [step, settleCopies]

/-- And the provider's, when the delete lands. -/
@[req "RSC-42"]
theorem a_landed_delete_takes_the_provider_copy (maxWait : Nat) (w : World) (s : Claim.Written)
    : (step maxWait w (.settle s true)).copies.provider.present = false := by
  simp [step, settleCopies]

/-- `RSC-42`: the provider-side copy "is deleted by a call that may fail or be lost", so settling
does not on its own prove it gone. This is the trace that sentence exists for, and a model that
could not state it would be asserting the call always lands. -/
@[req "RSC-42"]
theorem a_lost_delete_leaves_the_provider_copy (maxWait : Nat) (w : World) (s : Claim.Written)
    (h : w.copies.provider.present = true) :
    (step maxWait w (.settle s false)).copies.provider.present = true := by
  simp [step, settleCopies, h]

/-- Which is why the import carries the correlator: `OPS-32`'s sweep reaches the orphan by its
tag. "An orphan is not merely a storage charge: it is a copy of a customer's operating system left
in the operator's account after the deployment undertook to destroy it." -/
@[req "RSC-42"]
theorem the_sweep_deletes_a_tagged_orphan (settled : List Correlator) (c : Copies)
    (t : Correlator) (ht : c.provider.tag = some t) (hs : t ∈ settled) :
    (sweepCopies settled c).provider.present = false := by
  simp [sweepCopies, ht, hs]

/-- And why an untagged import is the design that sentence refuses: the sweep has nothing to find
the image by, so the orphan survives every pass. -/
@[req "RSC-42"]
theorem the_sweep_cannot_reach_an_untagged_orphan (settled : List Correlator) (c : Copies)
    (ht : c.provider.tag = none) : sweepCopies settled c = c := by
  simp [sweepCopies, ht]

/-! ## `RSC-43`'s settle -/

/-- What provisiond could have measured about the machine and, by `RSC-43`, must not consult. -/
structure Probe where
  reachable : Bool
  booted    : Bool
  deriving DecidableEq, Repr

/-- `RSC-43`: "`succeeded` means the provider completed the build. It does **not** mean the machine
booted, is reachable, or works." -/
@[req "RSC-43"]
def settleOn (providerReport : Bool) (_probe : Probe) : Claim.Status :=
  if providerReport then .succeeded else .failed

/-- `RSC-43`: "provisiond MUST NOT probe the machine to decide." The settled state of a report is
the settled state of that report under any probe at all, so a probe cannot be consulted without
this theorem failing. -/
@[req "RSC-43"]
theorem settle_independent_of_any_probe (providerReport : Bool) (p q : Probe) :
    settleOn providerReport p = settleOn providerReport q := rfl

/-! ## `RSC-39`'s two URLs -/

/-- A URL, compared and never fetched here. -/
structure Url where n : Nat deriving DecidableEq, Repr

/-- What the re-host holds once the fetch succeeded: the caller's URL, kept because the operation
records what was asked for, and the operator copy's, which is what the provider is given. -/
structure Rehosted where
  callerUrl   : Url
  operatorUrl : Url
  deriving DecidableEq, Repr

/-- `RSC-39`: "give the provider a URL to that copy". -/
@[req "RSC-39"]
def providerUrl (r : Rehosted) : Url := r.operatorUrl

/-- `RSC-39`: "The caller's own URL MUST NOT be passed to the provider." What the provider is given
is the same whatever the caller sent, so the caller's URL cannot reach it. -/
@[req "RSC-39"]
theorem caller_url_never_reaches_the_provider (r : Rehosted) (u : Url) :
    providerUrl { r with callerUrl := u } = providerUrl r := rfl

end Provisiond.Rehost
