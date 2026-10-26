**Vote: CANNOT ACCEPT** on the complete S1–S6 + M1–M7 candidate at `c5f897c32f7894d77a544528872176f241394d0d`.

The age-after-collection repair preserves the examined refusal cases. However, **CNF-99 and CNF-299 contain omitted success assertions that the new age refusal defeats**. These are rule-3 losses; neither is a listed amendment.

**1. Blocker: CNF-99, `10-conformance-checklist.md:721–724`.**

Exact before:

```text
**A sub-quorum pass with
      a fresh window**: with a window that produces a rate, run one pass below `LDG-59`'s quorum and
      assert that creates and re-derivations proceed at the rate in force, that no `LDG-40` halt
      fires and no `LDG-64` outage opens, and that the next accepting pass recomputes the rate.
```

Counterexample: keep the rate window productive through the sub-quorum pass. Use a healthy account, a stored sellable offer older than the offer-listing age, open channel, sufficient balance, available rate, no solvency halt, and no other refusal. The create now receives `502 provider`, retryable true, without admission writes. It does not proceed as asserted.

“Fresh window” here qualifies the rate-observation window, not the stored offer listing. The coordinator inventory’s classification of CNF-99 misses this direct success assertion.

Proposed replacement — **behaviour changed**, narrowing only this create-success fixture:

```text
**A sub-quorum pass with
      a fresh window**: for the create-success assertion in this case, use a stored listing
      containing the named sellable offer, with its `read_at` no older than the offer-listing
      age (`OVR-19`) at the admitting transaction. With a window that produces a rate, run
      one pass below `LDG-59`'s quorum and assert that creates and re-derivations proceed at
      the rate in force, that no `LDG-40` halt fires and no `LDG-64` outage opens, and that
      the next accepting pass recomputes the rate.
```

**2. Blocker: CNF-299, `10-conformance-checklist.md:1093–1099`.**

Exact before:

```text
Saturate one replica's
      write checkouts and assert the next write, under a key never sent before, is refused
      `overloaded`, 503, with `retry_after_ms`, that `STO-35` holds no receipt for that key, that
      the same key re-sent after capacity returns succeeds as a first send, and that a read still
      succeeds under the separate read budget; then repeat with a key whose first send committed
      before its reply was lost, and assert the re-send after the refusal returns the existing
      operation (`API-11`).
```

Counterexample: choose create as the next write. Its first attempt receives the prescribed overload refusal. Restore checkout capacity while its otherwise eligible stored listing is stale. The same-key retry now receives `502 provider`/true, rather than succeeding as a first send. The already-committed replay control is unaffected.

This item is absent from the coordinator’s create/purchase inventory: its generic “write” includes a create without spelling that verb.

Proposed replacement — **behaviour changed**, qualifying only the first-send retry success:

```text
Saturate one replica's
      write checkouts and assert the next write, under a key never sent before, is refused
      `overloaded`, 503, with `retry_after_ms`, that `STO-35` holds no receipt for that key, and
      that a read still succeeds under the separate read budget. After capacity returns,
      for the successful first-send retry of a create, publish a stored listing containing
      the named sellable offer, with its `read_at` no older than the offer-listing age
      (`OVR-19`) at the admitting transaction; resend the same key and assert it succeeds as
      a first send. Then repeat with a key whose first send committed before its reply was
      lost, and assert the re-send after the refusal returns the existing operation (`API-11`).
```

Both before-spans match base and the applied candidate exactly. These proposals were **not applied** to the reviewed candidate.

**Refusal and barrier assessment.**

The decisive S1 sentence is:

> If the tail has collected no refusal and the stored listing has a `read_at` older than the stated offer-listing age (`OVR-19`) at the admitting transaction, the create MUST be refused `provider` (`01-domain-model.md`'s error taxonomy) with `retryable: true` before any admission write, committing nothing.

Any collected base refusal makes that antecedent false. I independently checked the coordinator JSON’s complete create product against the ordered-entry, retryability, skipped-check and evaluation predicates: 2,304 unique create projections and 64 extension controls. This checks the source projections, **not implementation conformance**.

| Obligation | Result |
|---|---|
| D1 | Stale unsellable/absent offer retains `400 offer_not_sellable`, false retryability, priced-check suppression and no hidden amounts, with either cap choice. |
| D2 | Stale sellable/channel/solvency/no-rate retains channel headline and pacing, ordered independent entries, and rate skips. |
| D3 | Account, offer, channel, solvency and rate entries retain their applicable order. Skip reasons remain account/offer/rate within each present check; the offer entry makes the envelope false. |
| D4 | Healthy + sellable + available rate + omitted cap evaluates balance and leaves `not_checked: []`. Short balance still yields `402`; sufficient balance then permits the new age refusal. No D4 success amendment is needed. |
| D5 | Clearing other faults while retaining stale data yields `502 provider`/true without a receipt. M1’s fresh-listing retry succeeds. |
| Every unhealthy branch | Across fresh/stale/no-row and all enumerated offer/channel/solvency/rate/cap combinations, state remains first. Stale sellable data does not invent an offer refusal. Termination, or recoverable status plus unsellable/absent offer, makes the envelope false. |
| Healthy no row | Empty stored offers produce `400 offer_not_sellable`/false; independent faults and ordered skips remain collectible. Live provider sellability does not replace the empty input. |
| Otherwise eligible stale create | Applicable priced checks finish, then `502 provider`/true occurs without admission writes or provider calls. Equality with the age limit does not trigger this refusal. |

Early refusals and stored replays finish before this new check. Extensions acquire no listing-age condition. The account/resource conditional-write protections remain necessary for creates that reach admission; refusing stale data earlier does not authorize a write past them.

For CNF-278’s already-admitted claim setups, admission can occur fresh before the induced termination or account-status event. S1 adds no claim-time age check. The existing claim input remains explicit in OPS-43:

> The inputs are the descriptor the worker runs with (`PRV-44`: "The descriptor is a typed, immutable value") and one current driver List offers result taken at claim.

I found no additional verified loss in the complete CNF-278 barrier passage or CNF-307’s other controls. I do not claim a Lean theorem failure; no Lake/full formal check was run.

**M1–M7: individually necessary and sufficient for their stated assertion scopes, collectively incomplete.**

| Amendment | Base assertion and changed verdict |
|---|---|
| M1, CNF-307 | “Clear recoverable faults and resend the exact request and key: admission succeeds, proving refusal left no replay receipt.” Stale retry becomes `502`; the explicit fresh retry restores success without narrowing the refusal combinations. |
| M2, CNF-138 | “Assert that an EUR create and `extend-runway` are admitted, a deposit mints, no unsettled invoice is cancelled, and the deposit read reports `gate: null` and `lightning.cancelled: false`.” Only the create acquires the age refusal; M2 qualifies it. |
| M3, CNF-315 | “Create against an offer with a non-zero unit: the commitment includes `first_unit` at the customer rate and the setup fee at cost.” Stale creates open no commitment. The amendment’s scope includes the later commitment controls, including zero-unit, while leaving the insufficient-balance refusal unqualified. |
| M4, CNF-163 | “Two concurrent creates against a balance that can fund exactly one result in one commitment and one `insufficient_balance` — under load, not by code review.” Stale contenders can both refuse provider and leave no winner. Freshness at both admission snapshots restores the intended race. |
| M5, CNF-166 | “An otherwise sellable offer with a bound no later than provider-local today and a sellable traffic bound is admitted and opens a commitment sized to that bound.” Staleness defeats admission; M5 qualifies this positive control. |
| M6, CNF-343 | “Both read an open snapshot; at the admitting conditional-write barrier exactly one wins, and the loser receives an ordinary HTTP `409 conflict`/`state` error with `retryable: false`, no `details.refusals`, no synthesized pacing or `Retry-After`, and no commitment, balance change, operation or receipt.” Staleness prevents reaching the winning write. M6 expressly qualifies both contenders. |
| M7, CNF-343 | “A catalogue product admits independent creates.” Stale independent creates instead refuse provider; M7 supplies the necessary condition. |

I distinguish these direct success assertions from already-admitted setups and CNF-340’s existential “can reach purchase admission.” Neither distinction rescues CNF-99 or CNF-299.

**Quotation repairs — all behaviour unchanged; none resolves the blockers.**

The inherited excerpts match their source words, but the printed candidate does not quote the complete owner sentences. Printing complete sources elsewhere in the brief does not repair the candidate.

**Q1 — S2, STO-60, `05-persistence.md`, PRV-50 attribution.**

Before:

```text
`PRV-50` says "The driver's List offers MUST be read-only".
```

Replacement:

```text
`PRV-50` says “The driver's List offers MUST be read-only under `PRV-12`'s guarantee: "Get machine MUST be read-only and free of side effects".”
```

**Q2 — S3, OPS-51, `03-operation-lifecycle.md`, PRV-41 attribution.**

Before:

```text
`PRV-41` says “A driver MUST therefore treat an `authentication` failure as terminal for that credential, MUST NOT re-attempt it on a schedule, and MUST surface it for an operator”.
```

Replacement:

```text
`PRV-41` says “A driver MUST therefore treat an `authentication` failure as terminal for that credential, MUST NOT re-attempt it on a schedule, and MUST surface it for an operator (`OPS-26`).”
```

**Q3 — S6, CNF-166, `10-conformance-checklist.md`, OPS-43 citation span.**

Before:

```text
(`OPS-43`: "where the provider's price has risen past what the reserve covers")
```

Replacement, preserving the owner’s whole sentence and operative conditions:

```text
(`OPS-43`: “After the sale re-test passes, and before any per-order key upload or other provider mutation, the worker MUST re-read the offer's current price from that same List offers result **in the provider's own currency** and compare it with the native price the commitment was sized from — **carried on the operation's `request_summary`, which MUST hold the accepted recurring price, its currency and its period, and the accepted setup fee and prepaid first unit, the unit with its `billing_unit.seconds`** (`LDG-2`, `LDG-67`; *the unit and its seconds added 2026-10-08, `ADR-0033`, because the machine's row copies the seconds for its first seed, `LDG-38`, `05-persistence.md`*; *the fields are named so a worker restarted before claim can perform this comparison at all*; *named 2026-09-05 — a first form cited a native figure on the commitment row, which carries only `reserved_sats`*) — and **fail the operation deterministically — before any provider mutation — where the provider's price has risen past what the reserve covers**: `conflict`, `details.reason: "price_moved"`, the shortfall in `details`, telling the caller to re-submit, and `retryable: true` on both the error and the operation view (`WIR-9b`).”)
```

These restore quotations only; they add no fixture, payload or normative exception.

**Strongest argument, separate from the vote.**

The candidate repairs the refusal precedence but does not complete the disclosed success amendments. CNF-99 directly asserts that creates proceed under its rate fixture. A healthy, stale, otherwise eligible create satisfies that fixture yet must now refuse. A fresh witness cannot discharge that unqualified assertion under this round’s stated rules.

**Counterargument — written on request; not a vote.**

The core policy is coherent: existing collected faults retain precedence, stale otherwise eligible creates refuse, and fresh creates remain possible. One could read CNF-99 as asserting only rate-gate permissiveness and instantiate CNF-299 with a nonpurchase write. Those readings would avoid the counterexamples. However, they narrow the printed assertions without a listed amendment, which this round explicitly disallows.

**Application and coverage receipt.**

- Scratch copy: `/var/tmp/provisiond-panel-r72/astra/.r72-scratch`.
- All candidate operations applied uniquely with whitespace-normalized anchors. M1–M7 before-spans match base verbatim; the supplied source-context blocks also match.
- Command, unpiped: `python3 tools/check_coverage.py`.
- **Complete candidate: exit 0; 74 ratcheted uncovered; baseline 74, byte-identical to base.** SEC/WIR reported separately: 32 uncovered.
- Base independently checked: **exit 0; 74 ratcheted uncovered**.
- Application failure disclosed: the first literal-byte attempt stopped at S6’s line-wrapped anchor. Its partial-copy coverage returned **exit 1/76**. I rebuilt the scratch copy from base, applied the entire candidate, and obtained the complete-candidate result above. No application failure remains.
- `TMPDIR` retained. No full gates/Lake, provider API, delegation, background work, commits or pushes.
- The inventory errors are review findings, not changed-premise errors requiring a void tally.

Final: CANNOT ACCEPT.