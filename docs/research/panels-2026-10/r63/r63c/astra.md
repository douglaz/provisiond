**S′: ACCEPT.**

**F′: ACCEPT.**

S′ covers the named standby despite per-transaction durability settings. Its timestamp procedure matches PostgreSQL’s statement: “If recovery has completed then this will remain static”. [Recovery information functions](https://www.postgresql.org/docs/current/functions-admin.html#FUNCTIONS-RECOVERY-INFO-TABLE)

F′ separates the durable step-(2) mark from each process’s startup pass. The revised `World.safe` invariant accommodates fresh, unapplied creates while preserving the `secondOrder = false` conclusion; the successor sweep and parent-return changes match the settled behavior.

**Brief errors:** None found.