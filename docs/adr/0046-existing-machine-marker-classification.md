# Existing-machine failures before the write-started marker settle `failed`

**Status:** accepted (2026-10-23, the owner's decision: "Yes, settle failed (Recommended)";
`pv-9j6`; panel r64b).

## Context

`OPS-45` says an operation on an existing machine "settles `failed` — deterministically, with
no operator and no reconciliation — when the write-started marker is unset" and "either no
rescue session was opened or the one that was opened was closed without error". The last row
of `OPS-11` previously said "`needs_reconciliation` if the failure is *ambiguous*, otherwise
`failed`". A delete cut off before dispatch exposed
the disagreement: `OPS-21` says "The recorded error is a cut-off `conflict`", and `OPS-11`'s
ambiguity definition includes "the error kind is `conflict` *and* it arose from the worker being
cut off mid-flight".

The marker argument belongs to `OPS-45`: "The engine knows whether it started writing, and
that knowledge MUST be recorded and used before anyone asks a human." This decision aligns
the classification row with that owner.

## Decision

Adopt panel r64b's classification with the last row's acceptance exclusion, without the
optional `CNF-31a` clause asserting both directions. `OPS-11`'s last row owns the classification
pointer: "Subject to the goal-state success rule, any failure the worker records while
`OPS-45`'s write-started marker is unset" and "MUST settle `failed`, whatever its kind". Its
acceptance exclusion is "unless the mutation is known to have been accepted (`details.accepted`
is `true`)". `OPS-45` remains the rule's owner.

`OPS-21` owns the transaction's marker read: "Where the row reads `OPS-45`'s markers, the record
MUST classify against the markers its own transaction reads, since a marker write whose reply
was lost may have committed." The classification pointers and conformance cases follow the
amended row; the persistence description drops its duplicate classification claim.

## Considered and rejected

- **Narrow `OPS-45` and the persistence description instead.** This was the bead's "If it does
  not" reading. The owner chose "Yes, settle failed (Recommended)"; the existing marker rule
  stays with its owner.
- **An optional `CNF-31a` clause asserting both directions.** Panel r64b rejected this option
  (0–4); the last row's acceptance exclusion was accepted (4–0). The existing `CNF-31a` stays
  unchanged.
