# A lost auction order is resolved by its fingerprint, and a temporary key outlives an unsettled operation

**Status:** accepted (2026-10-09, owner decision Q16 of the provider-research grill; `pv-ucs.9`); amended 2026-10-11 (Q24).

## Context

`pv-ucs.9` applies the provider research (`docs/research/provider-verify-2026-10.md`). An rloop Manager
blocked it on two questions, and a four-reader panel (`docs/research/panels-2026-10/r31/`) settled them.

**Auction identity.** `PRV-42` resolved a lost-reply auction create by reading the server whose number
equals the offer id, called the correlator unnecessary, and mapped a read that found nothing past
`PRV-36`'s window to resolved-absent. It also said that the identity holds "by rule rather than by
coincidence is `[verify]` before a driver depends on it". The research's guard (V8) checks the number only
when the read finds a server. A Robot order can sit `in process` with no documented bound. `OPS-33`'s
protection covers "a matched order that is still in progress", and an identity read never matches an
order. So a slow order reads absent past the window, its commitment is released, and the server then
arrives on the operator's account. A positive identity read does not prove the server came from this
order either.

**Temporary keys.** `PRV-9` says a driver "MUST NOT remove them until the provider has actually consumed
the key material". `OPS-32`'s sweep deletes a tagged key "whose operation is not `running`". Startup moves
every `running` operation to `needs_reconciliation`, and `ADR-0035` sends every failure after acceptance
there. So after a crash the sweep deleted keys a provider might still use, which is `DEF-6` arriving
through the sweep. `CNF-303` required it.

## Decision

1. **A lost-reply auction create is resolved like any other create.** `OPS-27`'s search by the order's
   per-order fingerprint, across every ordering channel, finds the order. The delivered `server_number`
   is read from the matched transaction, and `OPS-27`'s confirming read follows. A read of the offer's
   number that finds nothing is not evidence of absence. `PRV-42`'s identity resolution, its table and
   its "the correlator is unnecessary" are withdrawn. `ADR-0036`'s one create in flight per offer stays:
   `offer_is_resource` means the offer names one machine. Nothing depends on the offer id equalling the
   server number, which remains an observation.
2. **A temporary key is deleted only once its operation has settled or vanished, and no machine it
   produced still reads `provisioning`.** `PRV-9` owns the rule, and `OPS-32`'s sweep cites it.
   - A failure before acceptance deletes the key.
   - A failure after acceptance sits in `needs_reconciliation`, "Resolution-pending, not terminal", and
     keeps its key until resolution settles it.
   - A key whose operation record is gone is deleted, since an unrecorded machine is never attached.

   The provider's consumption timings (`08-provider-notes.md`, V2, V18, V19) stay `[verify]` until the
   live batches. They could only justify deleting earlier.

## Considered and rejected

- The research's positive-only guard (V8): it never runs on the negative branch, where the harm is.
- Deleting a key on provider evidence of consumption only: it needs per-provider consumption polling in
  the sweep, for a timing the live tests have not yet measured.
- "Settled" alone: an operation can settle by attaching a machine that is still deploying.

## Consequences

- A caller's key held by an unresolved operation blocks that caller's next create on the same account,
  because providers reject a duplicate fingerprint. Holding keys longer stretches a collision that
  already exists. It is named, not solved here.
- An auction order still unmatched after Robot's 30-day listing horizon goes to `OPS-31`, after `OPS-33`
  has released its commitment.
- Edits owed (`pv-ucs.9`):
  - `PRV-42` and `OPS-27`.
  - `PRV-9` (the rule) and `OPS-32`. Drop "not `running`" and the Robot exception, and correct "Its
    private half died with the process", which is false for a create's key: it is the caller's.
  - `DEF-6`, `CNF-285` and `CNF-303`. `CNF-303` must show that a crashed create's key survives.
  - The research note's V8 consequence and its written inquiry 3.
  - `08-provider-notes.md`.
  - `Provisiond.Rescue.Session.step`'s `sweepRemovesCredential` event gains the guard, with a theorem.

## Amendment — 2026-10-11: the sweep is the one deleter of a settled operation's key (owner decision Q24)

A branch review found that nothing requires deleting a successful create's temporary key. Decision 2 says
only when a key may be deleted, and `OPS-32` says a key "is deleted by the sweep only when" `PRV-9` permits
it. A three-reader panel (`docs/research/panels-2026-10/r42/`) settled it.

- **`OPS-32`'s sweep is the only deleter of a settled operation's key, and it MUST delete one once
  Decision 2 permits it.** Robot deletes a key by its fingerprint (`DELETE /key/{fp}`) and has no
  conditional delete. A second deleter can therefore race the sweep:
  1. The sweep selects operation A's key.
  2. The other deleter removes it.
  3. Operation B registers the same public key.
  4. The sweep deletes B's registration.

  With one deleter, B's registration is refused (`409 KEY_ALREADY_EXISTS`) while A's key exists.
- **The cost is accepted.** The same caller's next create on that account is refused before any order is
  sent, so no money moves, until the sweep deletes the key. A create overlapping another create's flight is
  refused under either choice.
- **A driver deletes only a key its own operation registered.** On a failure before the provider accepts
  the order, it deletes that key. It never deletes after a duplicate-key refusal or a lost
  registration reply, when the fingerprint may belong to another operation.
- The Consequence "A caller's key held by an unresolved operation blocks that caller's next create"
  widens: any surviving registration of that key blocks it, until the sweep deletes it. Hetzner Cloud
  and Robot document the refusal; it has not been reproduced live.

Rejected: a prompt deletion after a successful create, with the sweep as fallback (it reopens the
fingerprint race, which no ownership check closes on Robot); reusing an already-registered identical key
(one registration serving several operations needs shared ownership and a per-account lock).
