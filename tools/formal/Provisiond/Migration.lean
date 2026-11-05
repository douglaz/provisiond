import Provisiond.Req
/-! The migration plan as a type (`STO-12`, `STO-13`, `ADR-0048`). The standalone branch
represents an actual statement the platform refuses in a transaction; ordinary offline indexes
are permitted in the transactional branch. The historical contradiction is recorded in `F52`.

PostgreSQL's rule is not Lean's to establish (`ADR-0025`): it is the `refuses` parameter of every
declaration, and `postgres` is the value the set assumes, named so a signature shows the
dependence. Resumability — `IF NOT EXISTS`, the `INVALID` drop — and the session-scoped lock are
not modelled: they are the standalone migration's obligations, not its shape. -/

namespace Provisiond.Migration

/-- A migration statement as the transaction rule sees it: an index build using or omitting
`CONCURRENTLY`, or any other statement. -/
inductive Statement
  | createIndex (concurrently : Bool)
  | other
  deriving DecidableEq, Repr

/-- The assumed platform rule rejects actual concurrent index builds inside a transaction.
An assumption named as a value, not a theorem; see `STO-12`. -/
def postgres : Statement → Bool
  | .createIndex concurrently => concurrently
  | .other => false

/-- `STO-12`: a migration is "one migration per transaction", or — `standaloneRule`, added
2026-09-12 under `ADR-0024` — "A statement PostgreSQL refuses inside a transaction block is its
own migration, run outside one", and "Such a migration contains that one statement and nothing
else". The transactional constructor carries the proof that the platform refuses none of its
statements; the standalone one holds one statement, and only where the rule exists. -/
@[req "STO-12"]
inductive Migration (refuses : Statement → Bool) (standaloneRule : Bool)
  | transactional (stmts : List Statement) (ok : ∀ s ∈ stmts, refuses s = false)
  | standalone (stmt : Statement) (refused : refuses stmt = true) (rule : standaloneRule = true)

/-- The statements a migration holds. -/
def Migration.holds {refuses : Statement → Bool} {standaloneRule : Bool} :
    Migration refuses standaloneRule → Statement → Prop
  | .transactional stmts _, s => s ∈ stmts
  | .standalone stmt _ _, s => stmt = s

/-- `F52`'s second defect is unrepresentable: no migration under any platform holds, inside a
transaction, a statement that platform refuses there. -/
@[req "STO-12"]
theorem transactional_holds_nothing_refused {refuses : Statement → Bool} {standaloneRule : Bool}
    (stmts : List Statement) (ok : ∀ s ∈ stmts, refuses s = false) (s : Statement)
    (h : (Migration.transactional (standaloneRule := standaloneRule) stmts ok).holds s) :
    refuses s = false := ok s h

/-- An actual concurrent index requires the standalone branch, independently of table size.
`STO-12`: "A statement PostgreSQL refuses inside a transaction block is its own migration,
run outside one". -/
@[req "STO-12"]
theorem concurrent_index_is_standalone {standaloneRule : Bool} (m : Migration postgres standaloneRule)
    (h : m.holds (.createIndex true)) :
    ∃ stmt refused rule, m = .standalone stmt refused rule := by
  cases m with
  | transactional stmts ok =>
    have hRefused := ok _ h
    simp [postgres] at hRefused
  | standalone stmt refused rule => exact ⟨stmt, refused, rule, rfl⟩

/-- Removing the standalone branch leaves no home for an actual concurrent index under the
assumed PostgreSQL transaction rule. Ordinary offline indexes do not have this restriction. -/
@[req "STO-12"]
theorem no_home_without_standalone_rule (m : Migration postgres false)
    (h : m.holds (.createIndex true)) : False := by
  obtain ⟨_, _, rule, _⟩ := concurrent_index_is_standalone m h
  exact Bool.false_ne_true rule

end Provisiond.Migration
