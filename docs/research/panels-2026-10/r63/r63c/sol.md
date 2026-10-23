**S′: ACCEPT.**

**F′: ACCEPT.**

S2’s timestamp premise matches PostgreSQL: “If recovery has completed then this will remain static at the time of the last transaction applied during recovery.” ([Documentation](https://www.postgresql.org/docs/current/functions-admin.html#FUNCTIONS-RECOVERY-INFO))

F6’s revised `stepTwoMarked → safe` invariant accommodates fresh, unapplied queued work while preserving the `secondOrder = false` conclusion.

**Brief errors:** None found.