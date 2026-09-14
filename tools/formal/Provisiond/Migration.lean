import Provisiond.Req
/-! `STO-12`'s migration plan as a type, the formal home of `F52`'s second defect: `STO-12`
required one migration per transaction, `STO-13` required `CONCURRENTLY` index builds on the large
tables, and PostgreSQL refuses `CREATE INDEX CONCURRENTLY` inside a transaction block. `ADR-0024`
gave `STO-12` a second kind of migration; here the two kinds are the two constructors, and the
transactional one cannot hold a statement the platform refuses.

PostgreSQL's rule is not Lean's to establish (`ADR-0025`): it is the `refuses` parameter of every
declaration, and `postgres` is the value the set assumes, named so a signature shows the
dependence. Resumability — `IF NOT EXISTS`, the `INVALID` drop — and the session-scoped lock are
not modelled: they are the standalone migration's obligations, not its shape. -/

namespace Provisiond.Migration

/-- A migration statement as the transaction rule sees it: an index build, on one of `STO-13`'s
large tables or not, `CONCURRENTLY` or not; or any other statement. -/
inductive Statement
  | createIndex (largeTable concurrently : Bool)
  | other
  deriving DecidableEq, Repr

/-- The platform fact `F52` found: "`CREATE INDEX CONCURRENTLY` cannot run in a transaction
block". An assumption named as a value, not a theorem. -/
def postgres : Statement → Bool
  | .createIndex _ concurrently => concurrently
  | .other => false

/-- `STO-13`: "index builds on `operations`, `ledger_entries` and `machines` MUST be
`CONCURRENTLY`". -/
@[req "STO-13"]
def concurrentOnLarge : Statement → Bool
  | .createIndex largeTable concurrently => !largeTable || concurrently
  | .other => true

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

/-- Under PostgreSQL and `STO-13`, a large-table index build is in a standalone migration and
nowhere else: `STO-13`'s "A `CONCURRENTLY` build cannot run inside a transaction, so it is its own
migration under `STO-12`'s non-transactional rule". -/
@[req "STO-13"]
theorem large_index_is_standalone {standaloneRule : Bool} (m : Migration postgres standaloneRule)
    (concurrently : Bool) (h : m.holds (.createIndex true concurrently))
    (sto13 : concurrentOnLarge (.createIndex true concurrently) = true) :
    ∃ stmt refused rule, m = .standalone stmt refused rule := by
  cases m with
  | transactional stmts ok =>
    have := ok _ h
    simp [concurrentOnLarge] at sto13
    simp [postgres, sto13] at this
  | standalone stmt refused rule => exact ⟨stmt, refused, rule, rfl⟩

/-- `STO-12` as it stood until 2026-09-12 — no standalone rule — together with `STO-13` admits no
migration at all for a large-table index build: the contradiction `F52` records, as a theorem
about the parameter. -/
@[req "STO-12"]
theorem no_home_without_standalone_rule (m : Migration postgres false) (concurrently : Bool)
    (h : m.holds (.createIndex true concurrently))
    (sto13 : concurrentOnLarge (.createIndex true concurrently) = true) : False := by
  obtain ⟨_, _, rule, _⟩ := large_index_is_standalone m concurrently h sto13
  exact Bool.false_ne_true rule

end Provisiond.Migration
