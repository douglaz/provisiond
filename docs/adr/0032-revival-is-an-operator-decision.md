# Revival is an operator decision

**Status:** accepted (2026-10-04, `pv-gip.11`, owner decisions Q11/Q12).

A decision to delete deserves care before it is made. A provider hiccup followed by a favorable
rate is no new decision to keep a machine. Automatic revival made that accident choose for the
operator, while overloading retry with revival made the operator's intent ambiguous.

The rule homes are `OPS-41`, `OPS-48`, `API-64` and `API-68`; the wire home for keep is
`WIR-55`. This decision supersedes `ADR-0021`'s retry-as-withdrawal argument and its accepted
no-exit residual, preserving its gone-write and permanent-close reasoning.

Rejected alternatives from the Q11 panel: closing in re-derivation (Opus/Sol) would let price
maintenance reverse the deletion decision; a second sweep population (Astra) would add a second
lifecycle scanner for the same automatic reversal. Q12 also rejects retry that revives: an
operator asking to retry deletion should not unknowingly keep the machine. An explicit keep
records that choice without pretending it pays for the machine.
