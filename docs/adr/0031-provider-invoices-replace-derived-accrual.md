# Provider invoices replace derived accrual

**Status:** accepted (2026-10-04, `pv-gip.39`).

`LDG-75` owns accounting and its estimate gaps, `STO-57` the append-only record, `API-66` and
`API-67` the operator surface, and `WIR-53`/`WIR-54` its wire shape. `LDG-31` owns the native
clamp split; `LDG-40` owns halt transitions. Conformance is `CNF-309`, `CNF-310`, `CNF-311`.

The former unresolved-deficiency feed confused a cost the operator bore with a debt still owed.
An outage row never had a resolution event, so paid costs remained liabilities forever. The
invoice is the useful external authority; local recorded costs can only estimate it. There is no
reason to require integration before recording that fact. This decision requires neither importer
nor provider payment execution.

The accepted working-capital cost is about one invoice cycle. Business money bridges payment and
the later satoshi draw. This keeps unverifiable bank balances out of an otherwise observable
asset side. Omitting unknown cost until an invoice is an explicit estimate limitation in `LDG-75`.

Rejected: E, dropping the payable term, which would free coverage before provider costs are paid;
counting business cash (astra), an operator assertion without the rail evidence; stored accrual
rows (astra/sol), a second writer and second copy of existing cost; staleness/overdue/variance alarms
(fable), which confuse paid-but-unrecorded bills with unpaid ones; a per-account block (astra/sol),
which makes customers pay for delayed operator bookkeeping. A deficiency-resolution flag is not
a payment record. No due-date mechanism or general accounting ledger is introduced.

## Per-cause verification

The classification lives in `LDG-75`; these are its producer checks, not a second rule table.

- `LDG-31`: "Where a debit exceeds the commitment's remaining amount" and "the remainder is
  recorded as an **operator deficiency**". This is an incurred debit split; the native partition
  keeps the ledger's covered cost and the deficiency's remainder disjoint.
- `LDG-64`: "meter in the provider's own currency" and "charge the customer nothing for that
  window". The provider cost has no customer entry; `absorbed_seconds` prevents a later debit.
- `LDG-39`, observed: "Once `OPS-33` has released that commitment, the fee is an operator
  deficiency". Absent: "the provider's own transaction shows the order landed and a fee was
  charged for a machine that is nonetheless gone". Both identify an actual fee without a customer
  entry. Its abandoned row says "the operator gave up establishing whether the order landed";
  that recorded fee obligation remains an estimate until the invoice, not evidence of payment.
- `LDG-63`: "so it covers cost through that date". This is forward coverage; metering subsequently
  supplies the actual customer entry and any clamp remainder, not another copy of the reservation.
- `SEC-46`: "Where exposure must be carried without confirmation". `LDG-74` says "the meter
  **continues**"; entries and incurred deficiencies supply actual charges
  while the account is unreachable, until the stop rule, with gaps answered by the invoice.
- `OPS-36`: "it is bounded by the wind-down floor" and "where it does not, no commitment is
  opened at all". The floor is exposure, not elapsed usage. Where later entries or incurred
  deficiencies carry cost they supply it; cost with no such posting waits for the invoice under
  the accepted gap. No new meter path is invented to turn the floor into a charge.

`STO-37`'s deficiency `resolved_at` is removed: excluding the floor makes that timestamp
unnecessary to prevent double counting, before or after a caller funds the machine. `LDG-62`'s
writer and the corresponding checklist assertions go with it. `absorbed_until` remains the
outage-window boundary. The operation-resolution timestamp is a different field and is retained.

## Month coverage (2026-10-04, Q10)

`LDG-75`: "Recording order is irrelevant: an uninvoiced month stays accrued even when later
months have invoices." The archived draft's latest-invoice cutoff lost January when February
arrived first and assigned September usage posted in October to the wrong invoice. UTC month
membership uses the service period already on entries; it avoids arbitrary range boundaries,
gap/overlap rules and a refusal to record out-of-order invoices. The per-month outage split and
close writer belong to `LDG-75` and `STO-37`; `LDG-40` owns incomplete checks.

`STO-57`: "No reference is freed by a void." A void withdraws a fact while preserving the import
guard. A corrected re-recording gets a distinct reference, with the original reference retained
as evidence. Rejected: the draft's opposite-sign correction protocol and invoice revisions;
neither made withdrawal of coverage clear. `LDG-75`: "A negative invoice alone covers nothing".
That keeps a credit note arriving first from erasing the cost it adjusts. A documentless month
can instead be authoritatively covered by a zero invoice.

`API-66`: "This serialization protects the reported number, not an order-dependent B." Concurrent
invoices must not both report replacing the same month's accrual, and replay must keep each
committed result. The contract needs no additional prescribed lock primitive. The accepted gaps
and working-capital cost have their normative home in `LDG-75`, not a second accounting rule here.

`Provisiond.Payables` proves arithmetic over supplied balances/rates/completeness; it does not
prove invoice derivation, month attribution, void processing, persistence or close-write timing.
The implementation obligations are the conformance items above. `Provisiond.Ledger.nativeSplit`
and its guard witnesses cover the native partition; the retained halt uses
`Provisiond.Admission.nextHalt`.
