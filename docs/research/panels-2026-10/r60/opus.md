**1. No conforming engine reaches the create case deterministically.** The create is older than the parent. `OPS-6` says the claim "MUST select the oldest `queued` operation whose availability time has passed". A create has no machine, so `OPS-8`'s index never refuses its claim. It has no defer path either: a closed channel settles it `failed` (`PRV-40`). `API-7` step 5b blocks anything newer than the parent. If the parent's step (4) races a claim of the create, step (4)'s write loses: the claimed child "must lose this race and settle as its own worker's write instead" (`STO-3`). `OPS-43`'s claim then reads the provider account's status and never the tenant's suspension, so the create orders. Stopping the worker pool, as `CNF-244` does, doesn't change the order. The only routes are a planted store state or a row lock that relies on how a particular engine's claim locks rows, and neither is deterministic across conforming engines. One correction to the brief: `OPS-27` doesn't cancel the create. It "enqueues a system cancellation" for the machine, the create settles `succeeded`, and its setup fee and first unit are debited.

**2. The power route is real.** `OPS-8` says "return the operation to `queued`", while `OPS-6` says it "never left `queued` and does not advance the number". `ADR-0022` settles the tension: "An index-refused claim never left `queued`". So the operation is "never claimed" (`claim_number` 0), and all three `API-58` quotes apply ("the tenant's own work"). The route is deterministic only because `OPS-8` mandates the short delay; without it the worker would keep re-selecting the older power operation and the parent would starve. Catches:
- the holding operation must not be yielded;
- a second worker must be free to claim the parent;
- the step-(3) cancellation is stuck behind the same holder, so the parent settles only after the hold is released;
- the hold must last until step (4) writes.

**3. Pick (a).** What's settled is the step and the quotes, not the kind of operation. A conformance item that no conforming engine can be set up for is a box anyone can tick.

**4. Not a hole in a stated guarantee, but there is a gap.**
- Step (2) covers only "a create claimed before the suspension landed".
- `SEC-45` asks only to "cancel its fleet in one operator action" and says nothing about dispatch.
- `OPS-27`'s attach clause is the designed backstop. `API-58` says "A create that has produced no machine yet passes the re-sweep's test, so settlement here is not the last guard", and `STO-3`'s race clause above settles the same outcome.

The gap: under `OPS-6`, the only create step (4) ever meets was claimed after the suspension landed, and neither step (2) nor step (4) names that create. What happens to it is defined: it dispatches and its machine is cancelled at attach, with the fee and first unit debited. No text says that was intended. The bead should ask the owner that, not ask for a guarantee that nothing dispatches.

**5. Gates.** The edit holds a power operation behind a running refresh on the same machine and checks `claim_number` 0 before suspending.
- My first version went red in `citations`: the gate attributed `OPS-6`'s quote to `OPS-8`. Splitting the sentence cleared it, and all gates then passed (exit 0).
- The plant was a bare swap to a power operation with the holding text removed. Every gate stayed green.
- `Claim.lean` models a refused claim as `(r, none)`, with no delay and no ordering. What would catch the plant is running the item against any conforming engine: the power operation gets claimed before the parent and succeeds.
- The final tree is byte-identical to the patch that passed.

**6. Against my pick.** `pv-1wn` is closed with a reason that names a create, and `API-58`'s case for `requested_by` staying `caller` is written about "the caller's own create". The `claim_number` check reads like an assertion `API-58` doesn't state. And swapping kinds only moves `pv-gvc`'s single-kind gap from power to create.
