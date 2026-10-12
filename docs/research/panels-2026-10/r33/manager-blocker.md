STATUS: blocked

Selected `pv-ucs.7`, the first unclosed ticket in the caller's required order. Renewed its
`in_progress` claim through `br`; follow-up is comment 293 on that ticket. Do not select
`pv-ucs.9` or another bead on this Run. No implementation brief was issued.

The remaining owner question is which instant a positive operator restriction exposes as
`network_restriction.observed_at`. Q15 answers the previous blocker completely; this report does
not reopen the decision that `unknown` always renders null source and time.

## Passages requiring clarification

Read against HEAD `f1e690efe93c440796b9a28245f42982f5edcf70`, using current requirement locations,
not the ticket's historical line numbers:

- `13-wire-contract.md`, **WIR-47**, currently says:
  > Recording a restriction takes `{"status": "disabled", "observed_at": "2026-08-13T02:40:00Z"}` and
  > returns `200` with the machine view.

  `01-domain-model.md`, **DOM-27**, describes the timestamp as:
  > and when it was observed (`STO-44`, `WIR-47`).

  The old enum and refusal are explicitly being amended. The existing request nevertheless
  supplies an observation instant; its replacement timestamp semantics need to be explicit.

- `docs/adr/0038-a-network-restriction-is-positive-evidence-from-either-source.md`, Decision 2,
  describes the operator record as:
  > (when it was recorded, and the notice it came from)

  It also says:
  > Its `source` is
  > the positive one (`provider_api` where both are) and its `observed_at` is that source's.

  Its accepted Q15 clarification says:
  > Storage holds four nullable columns: the provider's reading and its time, and the operator's record
  > time and its `operator_ref`.

  These passages can mean a server recording instant, but do not specify whether the existing
  operator-supplied instant becomes the stored record time, or is replaced by the server clock.

- `docs/research/panels-2026-10/r30/synthesis.md`, final paragraph:
  > Opus: `WIR-47`'s body carries an operator-supplied `observed_at` while
  > the column is `operator_recorded_at` — say which renders.

- Owner comment 291 on `pv-ucs.7` repeats this obligation:
  > WIR-47 owns the render rule (and says which instant renders for the operator: its body's operator-supplied observed_at vs the recorded time)

  It identifies the distinction but does not select an instant. The panel's provenance verdict
  and the owner's adoption of Q15 settle source selection and null rendering, not this distinction.

## Different observable readings

Take a machine with no positive provider reading. The operator observes a restriction at
`2026-10-09T20:00:00Z`, then records it at `2026-10-09T22:00:00Z`.

| Reading | Persisted `operator_recorded_at` | Rendered `observed_at` beside `restricted` / `operator_notice` |
|---|---|---|
| Retain the existing operator-supplied observation time | `2026-10-09T20:00:00Z` | `2026-10-09T20:00:00Z` |
| Use the server's recording time | `2026-10-09T22:00:00Z` | `2026-10-09T22:00:00Z` |

Both use the accepted storage shape and select the positive operator source. They expose
materially different evidence ages and imply different treatment of the request's existing
`observed_at`. Choosing between them is wire behavior, not a gate-tooling or wording choice.
It must not be left to the Implementer or settled by advisory votes.

## Requested clarification and recommendation

Specify the value written to `operator_recorded_at` and rendered as `observed_at` for an operator
positive, and whether the record request still carries its existing `observed_at` field.

Recommend the server's recording instant, following ADR-0038's “when it was recorded” wording:
remove the request's observation-time member from the specified record body and explicitly define
the response as the recording instant. This recommendation is not an adopted amendment. An owner
choice to retain the supplied observation instant is also implementable within the accepted storage
shape, but would need an explicit definition of that column's meaning.

After clarification, resume this ticket and cover the case where observation and recording occur
at different instants. Preserve the accepted Q15 behavior and the rest of the ticket's edit list;
r24's “else last read” and unchanged `CNF-250` instruction remain superseded.

## Consultation and work record
