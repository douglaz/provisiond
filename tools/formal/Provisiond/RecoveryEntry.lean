import Provisiond.Req

/-! Recovery entry checking interpretation (`ADR-0048`). `STO-54`: "Every promotion or
replacement of authoritative history MUST enter the recovery-incident procedure, including a
promotion expected to preserve every acknowledged commit." Loss is deliberately not an input:
zero acknowledged loss does not bypass entry. `STO-54`: "A process successor that finds an open
incident MUST continue it using the persisted step marks." `STO-56`: "no predecessor step mark
satisfies a new step". This module classifies events only; it proves no physical fencing,
replication configuration, bootstrap, step execution or provider behavior. -/

namespace Provisiond.RecoveryEntry

inductive Event
  | processRestart
  | primaryRestartSameHistory
  | promotion
  | historyReplace
  deriving DecidableEq, Repr

inductive Entry
  | startIncident
  | continueIncident
  | supersedeIncident
  | restart
  deriving DecidableEq, Repr

@[req "STO-54"]
def classify (event : Event) (incidentOpen : Bool) : Entry :=
  match event, incidentOpen with
  | .processRestart, false | .primaryRestartSameHistory, false => .restart
  | .processRestart, true | .primaryRestartSameHistory, true => .continueIncident
  | .promotion, false | .historyReplace, false => .startIncident
  | .promotion, true | .historyReplace, true => .supersedeIncident

/-- A lossless promotion still enters recovery; history replacement has the same entry. -/
@[req "STO-54"]
theorem lossless_promotion_enters :
    classify .promotion false = .startIncident ∧
    classify .historyReplace false = .startIncident := by decide

@[req "STO-54"]
theorem same_history_open_continues :
    classify .processRestart true = .continueIncident ∧
    classify .primaryRestartSameHistory true = .continueIncident := by decide

@[req "STO-54"]
theorem same_history_closed_restarts :
    classify .processRestart false = .restart ∧
    classify .primaryRestartSameHistory false = .restart := by decide

@[req "STO-56"]
theorem new_event_supersedes :
    classify .promotion true = .supersedeIncident ∧
    classify .historyReplace true = .supersedeIncident := by decide

@[req "STO-54"]
theorem no_promotion_as_restart (incidentOpen : Bool) :
    classify .promotion incidentOpen ≠ .restart := by
  cases incidentOpen <;> decide

end Provisiond.RecoveryEntry
