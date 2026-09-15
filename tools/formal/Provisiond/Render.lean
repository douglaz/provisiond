import Provisiond.Tables
import Provisiond.Meter
import Provisiond.Ledger
/-! The marked regions (`ADR-0025`): what a region between `<!-- formal: <decl> -->` and
`<!-- /formal -->` in a document must contain, computed from the declaration named. `lake exe
render` prints them and `tools/check_regions.py` holds each document to them.

Two kinds. A `render` region is pure computation — a worked table, a diagram — and the gate
compares it byte for byte and can rewrite it (`--write`). A `match` region is a table whose cells
carry prose and citations the declaration does not; the gate keeps only the tokens the
declaration determines (a state, a close reason, the fence column's verdict) and diffs those, so a
row's rationale is free and its outcome is not. The first column of a `match` table is the row's
key, and its tokens are a required subsequence rather than an exact set. -/

open Std

namespace Provisiond.Render
open Provisiond.Tables

/-- A marked region: the declaration it renders, its kind, and its text. -/
structure Region where
  decl : String
  kind : String
  text : String

/-! ## `OPS-48`'s table -/

/-- A state as `DOM-31` spells it. -/
def Episode.name : Episode → String
  | .attempting => "attempting"
  | .uncertain => "uncertain"
  | .stalled => "stalled"
  | .scheduled => "scheduled"
  | .closed _ => "closed"

/-- A close reason as `DOM-31` spells it. -/
def CloseReason.name : CloseReason → String
  | .resourceGone => "resource_gone"
  | .funded => "funded"
  | .abandoned => "abandoned"

/-- The episode column's tokens for a resulting state. -/
def episodeTokens : Episode → String
  | .closed r => s!"`closed`, `close_reason: {CloseReason.name r}`"
  | s => s!"`{Episode.name s}`"

/-- The fence column's verdict: cleared in this transaction, or not. -/
def fenceToken : Bool → String
  | true => "**Cleared**"
  | false => "**Stays set**"

/-- `OPS-48`'s rows in the table's order: the first column's required tokens, and the `(state,
event)` steps the row states — two where a row folds a later transition into itself (the scheduled
row and its tombstone), one per open state where a row applies to all of them. -/
def ops48Rows : List (String × List (Episode × Event)) :=
  [ ("`succeeded`", [(.attempting, .settled .gone)]),
    ("`succeeded`", [(.attempting, .settled .noMutation)]),
    ("`stalled`", [(.stalled, .sweepFunded false)]),
    ("`succeeded`", [(.attempting, .settled .scheduled), (.scheduled, .tombstone)]),
    ("`failed`", [(.attempting, .settled .failed)]),
    ("`needs_reconciliation`", [(.attempting, .settled .needsReconciliation)]),
    ("`applied`", [(.uncertain, .resolved .applied false)]),
    ("`applied`", [(.uncertain, .resolved .applied true)]),
    ("`not_applied`", [(.uncertain, .resolved .notApplied false), (.uncertain, .resolved .notApplied true)]),
    ("`abandoned`", [(.uncertain, .resolved .abandoned false), (.uncertain, .resolved .abandoned true)]),
    ("`retry`", [(.stalled, .retry)]),
    ("**the machine is recorded gone**",
      [(.attempting, .goneWrite), (.uncertain, .goneWrite), (.stalled, .goneWrite),
       (.scheduled, .goneWrite)]) ]

/-- Every `(state, event)` step the rows state. -/
def ops48Pairs : List (Episode × Event) := ops48Rows.flatMap (·.2)

/-- "The transitions are exactly these": every step that changes an open episode or clears the
fence is a row of the table ... -/
@[req "OPS-48"]
theorem ops48_rows_cover :
    ∀ (s : Episode) (e : Event), s.isOpen = true → episodeStep currentRows s e ≠ (s, false) →
      (s, e) ∈ ops48Pairs := by decide

/-- ... and every row changes something. -/
@[req "OPS-48"]
theorem ops48_rows_change :
    ∀ p ∈ ops48Pairs, episodeStep currentRows p.1 p.2 ≠ (p.1, false) := by decide

/-- One row: the key, then the episode and fence tokens of its steps, each once. -/
def ops48Row (r : String × List (Episode × Event)) : String :=
  let results := r.2.map fun (s, e) => episodeStep currentRows s e
  let episode := " ".intercalate (results.map (episodeTokens ·.1)).eraseDups
  let fence := " ".intercalate (results.map (fenceToken ·.2)).eraseDups
  s!"| {r.1} | {episode} | {fence} |"

/-- `OPS-48`'s transition table, body rows only: the header carries the columns' citations. -/
@[req "OPS-48"]
def ops48Table : Region :=
  { decl := "Provisiond.Render.ops48Table", kind := "match",
    text := "\n".intercalate (ops48Rows.map ops48Row) }

/-! ## `DOM-31`'s diagram -/

/-- An edge's label: the event, as `DOM-31`'s diagram names it. -/
def Event.label : Event → String
  | .settled .gone => "attempt succeeded, resource gone"
  | .settled .noMutation => "no mutation required, funded"
  | .settled .scheduled => "attempt succeeded, future date"
  | .settled .failed => "attempt failed"
  | .settled .needsReconciliation => "attempt needs_reconciliation"
  | .resolved .applied false => "resolved applied, gone"
  | .resolved .applied true => "resolved applied, dated"
  | .resolved .notApplied _ => "resolved not_applied"
  | .resolved .abandoned _ => "resolved abandoned"
  | .resolved .observed _ | .resolved .absent _ => "not a cancellation verb"
  | .retry => "operator retry, API-64"
  | .sweepFunded _ => "sweep finds it funded, tenant not suspended"
  | .goneWrite => "machine recorded gone"
  | .tombstone => "tombstoned at its effective date"

/-- Every state change `episodeStep` makes from an open state, one edge each, in the enumerations'
order. -/
def dom31Edges : List String :=
  (Episode.all.filter Episode.isOpen).flatMap fun s =>
    Event.all.filterMap fun e =>
      let s' := (episodeStep currentRows s e).1
      if s' == s then none
      else some s!"    {Episode.name s} --> {Episode.name s'} : {Event.label e}"

/-- `DOM-31`'s state diagram, rendered from `OPS-48`'s table. -/
@[req "DOM-31"]
def dom31Diagram : Region :=
  { decl := "Provisiond.Render.dom31Diagram", kind := "render",
    text := "\n".intercalate
      (["```mermaid", "stateDiagram-v2", "    direction LR",
        "    [*] --> attempting : sweep opens it, first attempt enqueued"] ++
       dom31Edges.eraseDups ++ ["    closed --> [*]", "```"]) }

/-! ## `LDG-38`'s worked examples -/

/-- Comma-separated rationals and integers, for a cell. -/
def rats (xs : List Rat) : String := ", ".intercalate (xs.map toString)
def ints (xs : List Int) : String := ", ".intercalate (xs.map toString)

/-- One row: the exact charges in order, each period's stream starting at `r = 0`. -/
def meterRow (label : String) (periods : List (List Rat)) : String :=
  let posted := periods.map (Meter.debits · 0)
  let total := (posted.map List.sum).sum
  let credit := Meter.creditAfter (periods.getLast?.getD []) 0
  s!"| {label} | {" ∣ ".intercalate (periods.map rats)} | {" ∣ ".intercalate (posted.map ints)} | {total} | {credit} |"

/-- `LDG-38`'s recurrence worked: `F52`'s reset in both directions, and the rate rise at the half
hour, split and unsplit. -/
@[req "LDG-38"]
def ldg38Examples : Region :=
  { decl := "Provisiond.Render.ldg38Examples", kind := "render",
    text := "\n".intercalate
      [ "| | exact charges, in order (∣ is a period boundary, where `r` restarts at 0) | posted debits | Σ posted | `r` after |",
        "|---|---|---|---:|---:|",
        meterRow "carrying the credit" [[2/5, 2/5]],
        meterRow "resetting it at the period boundary" [[2/5], [2/5]],
        meterRow "7 sat/h rising to 14 at the half hour, the hour split there" [[7/2, 7]],
        meterRow "the same hour unsplit, at the rate in force at its end" [[14]] ] }

/-! ## `LDG-31`'s worked table -/

/-- Whole satoshis with thousands separators, as the ledger document writes them. -/
def commas (n : Int) : String :=
  let rec go : List Char → List Char
    | a :: b :: c :: d :: rest => a :: b :: c :: ',' :: go (d :: rest)
    | l => l
  (if n < 0 then "−" else "") ++ String.ofList (go (toString n.natAbs).toList.reverse).reverse

/-- One row of `LDG-31`'s table: the balances after the event. -/
def ledgerRow (b : Ledger.Balances) (label : String) (e : Ledger.Event) : Ledger.Balances × String :=
  let b' := Ledger.step b e
  (b', s!"| {label} | {commas b'.sum} | {commas b'.reserved} | {commas b'.available} |")

/-- `LDG-31`'s table: a top-up, a commitment, an hour consumed, the machine deleted. -/
@[req "LDG-31"]
def ldg31Table : Region :=
  let rows : List (String × Ledger.Event) :=
    [ ("`topup` +72,000", .topup 72000),
      ("commitment opened, 72,000", .openCommitment 72000),
      ("one hour consumed: `usage_debit` −100, commitment → 71,900", .usageDebit 100),
      ("machine deleted, commitment closed", .closeCommitment) ]
  let (_, lines) := rows.foldl (fun (b, acc) (label, e) =>
    let (b', line) := ledgerRow b label e
    (b', acc ++ [line])) (({ sum := 0, reserved := 0 } : Ledger.Balances), ([] : List String))
  { decl := "Provisiond.Render.ldg31Table", kind := "render",
    text := "\n".intercalate
      (["| event | Σ entries | reserved | available |", "|---|---:|---:|---:|"] ++ lines) }

/-- Every region a document may carry. A region emitted and rendered nowhere is a red gate. -/
def regions : List Region := [ops48Table, dom31Diagram, ldg38Examples, ldg31Table]

end Provisiond.Render
