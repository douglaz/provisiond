I reviewed Q31 through `74ad5f7`: **FAIL — blocker.** The finding is real, but your two-line fix resolves only half of it.

**Crash trace.** `OPS-27` requires the date/null write “with the machine row” in the landed-order transaction (03-operation-lifecycle.md:540). The read necessarily precedes it: `STO-55` forbids holding a transaction “across a provider, rail or rescue-host call”; `LDG-69` likewise excludes waiting on provider calls under tenant serialization.

Before commit, neither machine nor date survives. `OPS-15` says startup “MUST move every `running` operation to `needs_reconciliation`.” Recovery then follows `OPS-27`: “Attach it and complete the operation as though it had succeeded,” after search and confirmation; after commitment release, `OPS-36` supplies late attachment. An interrupted resolution remains unresolved. These paths reach the post-order-read decision again, but cannot distinguish never-attempted from attempted-and-lost.

Nothing already settles that distinction. `OPS-49` retains outcomes “in memory” and explicitly says “the outcome in hand is thrown away” on retry exhaustion (03-operation-lifecycle.md:1578). `OPS-45`’s existing marker “does **not** reach `create`.” Thus `PRV-13c`’s “MUST NOT be retried” conflicts operationally with “MUST record a successful post-order read’s date” without an additional protocol.

**Fix comparison.**

- **(a)** Absorbing a lost result is consistent with Q31’s “a failed read of any kind.” I would treat that loss policy as a clarification, not a new economic decision. But it supplies no recovery discriminator: how does recovery know this read happened? Skipping every recovered create also skips never-attempted reads required at `OPS-27`’s settlement entry points.
- **(b)** A durable attempt claim can enforce at-most-once dispatch. A result journal alone cannot: a crash can precede its write. Even claim-plus-result needs an explicit outcome for interruption between dispatch and result persistence—the policy in (a).
- **(c)** “Exactly one re-read” also needs durable accounting across repeated crashes. If enforced, it adds at most one constraint GET per machine; otherwise restart loops are unbounded per order. `ADR-0036`’s order cap does not bound recovery attempts. These GETs share the observed account counter with machine reads (08-provider-notes.md:478); Q31 explicitly notes “no hourly pacing.”
- **(d)** Smallest protocol preserving Q31: combine (a) with one durable consumed-attempt marker, written before dispatch; interrupted attempts consume that opportunity, including interruption before dispatch. Keep the result in memory until the existing settlement transaction. No separate result journal. Alternatively, allowing recovery repeats removes that marker but changes Q31’s “one per delivered order” promise and needs an owner decision.

**Additional defects.** None independently established at comparable weight in the requested sweep. `CNF-147` is unchanged against the branch base; `CNF-356`’s “exactly one” assertion needs crash cases covering the chosen protocol (10-conformance-checklist.md:3645). That is this blocker’s verification gap, not another finding.

**Recommendation:** fix before merging, then merge after focused re-review and clean gates. Prefer (a) plus the minimal marker if strict one-shot behavior remains required. Both required gate runs passed; tracked files remain unchanged.

**Strongest case for the other side (written on request)**

The marker protects request accounting for an observation whose loss Q31 already accepts. Recovery already repeats `OPS-27`’s confirming reads against the same shared counter. The owner could reasonably relax the cross-crash call-count promise, preserve ordinary failure absorption, and avoid another durable protocol. That challenges the invariant itself rather than repairing its machinery.