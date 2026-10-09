# Panel r29 synthesis — pv-ucs.6's owner questions Q13 and Q14 (2026-10-09)

Readers: sol, astra (codex xhigh), fable, opus (claude xhigh); clones at 0b28621 (fbe613a = pv-ucs.6's
unaccepted implementation). All exit 0.

## Q13 — wind-down's latency: 4–0 that my "maximum" under-reserves.

Why (all four): `STO-53` samples run dispatch → observed effect, so the window W is end-to-end, not
"lag after the reply". A provider can accept as late as the deadline D and the change can still lag
after that (DigitalOcean showed "`404` by the next poll" after a `204`). A reply at D−ε then a gone
observation at D+L means max(D, W) falls short. And after a lost reply, `PRV-36`'s "`OPS-27`'s resolution
MUST NOT take its first read before the window has elapsed" makes the evidence read a second, sequential
provider call with its own deadline (fable, astra).

Shapes, convergent: one end-to-end allowance owned by `PRV-13b` that names every sequential term —
the mutation call's wait (D), the visibility lag after it (W), the time until resolution reads (a cadence
the register lacks today), and that read's own wait (D) — with detection, machine-wait and margin as
before. (sol: one enforceable dispatch-to-gone-write allowance; astra: max for overlapping terms plus
named sequential work; fable: max(D, W) + one read bounded by D, self-correcting through STO-53 samples;
opus: D + W + a resolution cadence.)

Correctness hole (opus; verified wording): `PRV-36` starts the window at dispatch. With D > W, a timed-out
mutation is read at once; if the provider accepted it late and it still lags, "Beyond the window, a read
still showing the pre-mutation state resolves the mutation as *not applied*" — a wrong resolution.
`OPS-32`'s create window has the same shape ("measured from the dispatch of the create"). Fix: the
window runs from the end of the call's wait (its reply or the deadline's expiry). Formal: `Reconcile`'s
`dispatchedAt`, `pastWindow`, `absence_sound`.

Gaps: no register row for the resolution cadence or the "detection interval" (opus); `OVR-19`'s sentence
is a second normative copy → pointer (fable, opus).

## Q14 — a scheduled attachment release: 4–0 the effective date stops the customer's meter.

- ADR-0037 already decided it: Decision 3 names "for a scheduled cancellation, its effective date",
  not limited to machines; `LDG-38` rules out metering to a later observation ("never its later gone
  observation"). What is missing is applying it to attachments (opus).
- Store the effective date on `machine_attachments` (no column today); the meter clips to the earlier of
  the date and `released_at` on its next tick inside the serialization — no writer at the date, no
  running operation, not ADR-0028's withdrawn clock guard (all four). Drop "future" from `PRV-45`'s rule
  (fable).
- `released_at` stays evidence of actual cleanup and keeps `STO-18`'s tombstone gate ("Stopping the
  machine's meter is not tombstoning it"); my "the tombstone gate opens on it" merged two decisions.
- Writer for `released_at`: extend `OPS-32`'s account sweep to scheduled attachments (sol, astra, fable)
  vs the operator through `API-65` for v1 (opus: the sweep needs a new single-attachment driver read).
- Reserve: the date is learned after ordering, so a month-end date needs a per-attachment-kind bound
  declared at create, as `PRV-31` does for machines, or it hits `LDG-31`'s clamp (opus).
- Customer owes the attachment's rate through the effective date; the provider's part-day after it is an
  operator gap (`LDG-75`).

## Record items (both real, all four)

`API-65`'s "Either is what opens `STO-18`'s tombstone gate" is false for a scheduled release → point to
`PRV-45`'s `released_at` write. `ADR-0035`'s unconditional "A release that resolution finds applied writes
`released_at`" → a dated amendment citing ADR-0037 Decision 4; add ADR-0035 to ADR-0037's status line.
