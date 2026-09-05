# A create cannot be requeued; a second purchase is the customer's decision

**Status:** accepted (2026-09-05)

`OPS-20` let an operator requeue a `create_machine` operation, placing a second physical order
against the customer's balance. **That verb is withdrawn for creates.** A create that failed, or
whose outcome cannot be established, ends through `OPS-31`'s resolution verbs; the next purchase is
a fresh create submitted by the caller, which the set already calls "a second purchase, not a
retry" (`API-51`).

## Why: the operator cannot re-place the customer's order, and has nobody to ask

`OPS-34` requires a requeue to carry "a fresh payload supplied by the **operator**". For a create,
that payload cannot be the customer's:

- `STO-9` purges the request — "signed image URLs, **SSH keys**, and up to 1 MiB of post-install
  script" — **on entry to `needs_reconciliation`**, which is the state requeue exists to leave.
- `request_summary`, the record `OPS-34` says the check runs against, retains none of `hostname`,
  `ssh_public_keys`, `user_data`, `runway_seconds` or `max_commitment_sats`.
- `ADR-0002` gives the customer "no identity, no email", so **there is nobody to ask for them**.
- `PRV-8` requires a create to carry at least one SSH key.

The operator must therefore supply *their own* key, hostname, runway and cap. The machine that
arrives is one **the customer holds no credential on and did not configure** — bought with the
customer's satoshis. That is not the customer's order re-placed. It is a different machine.

**`OPS-34` already refused this and nobody read it that way.** Its second bullet: "Where the summary
cannot establish equivalence, requeue MUST be refused and `OPS-31`'s resolution verbs are the only
road." A create's summary cannot establish equivalence for any field that matters, so the bullet
already disposes of every create requeue. This decision makes explicit what that sentence implied.

## Considered options

**Define `OPS-34`'s undefined `target` as the offer identifier, and keep the verb.** Rejected. It
binds the *product* and leaves the *cap* unbound — `OPS-20` re-prices and tops the commitment up
"from available balance by `LDG-62`'s mechanism", sized from the operator's fresh
`runway_seconds`, with `WIR-17`'s `max_commitment_sats` gone. `OPS-36` already condemned that exact
shape in words: "sized from a `runway_seconds` the payload purge deleted, ignoring the
`max_commitment_sats` cap the original create may have set. That is precisely the surface
`ADR-0011` abolished, reappearing through reconciliation." Binding the offer does not fix it, and
the customer still cannot log in.

**Keep the verb and retain the payload so a faithful replay is possible.** Rejected: it reverses
`ADR-0005`, which purges caller secrets precisely because a `needs_reconciliation` record is
retained until an operator resolves it. Trading the privacy posture for an operator convenience is
the wrong direction, and the material at risk is the customer's SSH keys.

**Do nothing and leave `target` undefined.** Rejected. Read through `API-17b` — "Creation … is the
only operation that has no target to authorize against" — a create's `target` is null, so the
equivalence check collapses to kind plus provider account and a requeue may change offer, region
and size freely. The most textually supported reading is the most dangerous one.

## Consequences

- **`F36` closes by deletion.** With one attempt per create there is one correlator, one offer
  snapshot and one setup fee, so "the entry of the attempt whose correlator matched" has nothing to
  disambiguate. The per-attempt lists in `PRV-26`, `OPS-13`, `05-persistence.md` and `LDG-67` go
  with it.
- **`ADR-0002` is not what forbids this, and the record should not pretend otherwise.** A
  `cx32`→`cx42` requeue passes `LDG-9`'s "`available ≥ required_commitment`", so it satisfies
  `ADR-0002` as written. `ADR-0002` governs whether money may *move*; what it may *buy* is governed
  by the customer's request, and that is what the purge destroys. **The principle recorded here is
  new: an operator may not choose what a customer's balance buys.**
- **Recovery gets slower for one tenant, deliberately.** A tenant whose whole balance sits behind an
  ambiguous Robot standard order — no verified correlator (`PRV-33`), an `in process` state with no
  documented bound, a committed setup fee between €59 and €1349 — must now wait for an operator verb
  or `OPS-33`'s window before buying again. `OPS-33` already made that trade: "Where the two are in
  tension, the operator takes the visible loss."
- **What does not change.** `OPS-36`'s late attach still handles a first order that lands after
  release; resolution still needs an exact-one attachment guard, because `API-51` makes duplicate
  purchases reachable across separate operations without any requeue; and `PRV-40`'s daily ordering
  quota is spent by a fresh create exactly as it was by a requeue.
- **Requeue survives with a scope it can satisfy** — the kinds whose payload the operation record
  fully determines: exposure-reducing cancellation, power, reverse DNS, end-rescue, and adopt, whose
  target is an `external_id` the record holds. **Install is not among them** and has the identical
  defect: `RSC-42` has a requeue "carry a fresh payload (`OPS-34`) and re-upload" image bytes the
  operator does not have. That is recorded as an open finding rather than decided here.
