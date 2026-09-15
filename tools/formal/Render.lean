import Lean
import Provisiond
/-! `lake exe render` — prints `Provisiond.Render.regions`, one JSON object per marked region, for
`tools/check_regions.py` (`ADR-0025`). -/

open Lean

def main : IO UInt32 := do
  for r in Provisiond.Render.regions do
    IO.println (Json.mkObj [("decl", r.decl), ("kind", r.kind), ("text", r.text)]).compress
  return 0
