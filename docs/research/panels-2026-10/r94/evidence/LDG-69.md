**LDG-69** **AMENDED 2026-09-08 (`ADR-0016`) — the machine lock is deleted; the rule binds the hold
`OPS-8` defines instead.** A deployment MUST hold `LDG-35`'s primitive for the duration of one
database transaction and no longer. While it is held, an implementation MUST NOT wait on a running
operation's hold on its machine (`OPS-8`), the completion of a child operation (`API-58`,
`WIR-39`), or any provider call.

**The permitted order is one-way: a running operation's hold on its machine (`OPS-8`) → a short
tenant-serialized transaction.** A worker whose operation holds the machine MAY enter the
serialization for a bounded read or write; **a transaction under the serialization MUST NOT acquire
or wait on a machine.** One direction cannot form a cycle, and `OPS-8` makes taking a machine
try-and-defer rather than wait, so nothing blocks on it either.

*The clause withdrawn on 2026-08-31 forbade a worker holding the machine from entering the primitive
at all, and then ordered the case it had just forbidden. Two independent reviewers found the
contradiction. It was written when nothing needed the nesting; `OPS-41` was added a week later and
is exactly a machine-holding worker that must read commitment state another transaction writes
under this primitive.*

**And the order alone does not make `OPS-41` correct** — which is the sharper half, and both
reviewers reached it independently. The window that matters is **between the read and the provider
call**, not inside the transaction: this requirement rightly forbids a provider call under the
serialization, so the worker must release it before mutating, and `LDG-62` can commit in the gap.
Entering the serialization changes nothing about that. `OPS-41`'s correctness rests on the fence
`OPS-42` specifies, not on this ordering.

**AMENDED 2026-09-02 — but the fence needs the nesting this requirement permits, so the permission
is now load-bearing rather than theoretical.** `OPS-42` requires `OPS-41`'s funding read and the
fence write to be **one** transaction under this primitive, taken by a worker whose operation already
holds the machine: without that, the extension commits between the read and the write, the fence
column is still null when the worker writes it, and the machine is destroyed anyway. So the
permitted direction above is exactly what the fence is built on, and the prohibition that matters is
the other clause: **the provider call happens after that transaction commits**, never inside it.
