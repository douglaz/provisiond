**B — one clarification at the owning `machines.declared_cancellation_bound` row (`05-persistence.md:261`; `LDG-33` points there).** The null reader is settled; copying an absent snapshot member is not.

Your worker argument overreaches. `OPS-23` says “Validation that was performed at the API boundary MUST be repeated” and “A field a previous-release `api` may not have written is a deterministic failure in the worker”. `API-7` includes refusal when “not sellable under `PRV-13b` or `PRV-31`”. `OPS-43`’s accepted-price fields therefore are not an exhaustive validation list. A missing newly required snapshot field cannot simply be declared irrelevant before dispatch (`05-persistence.md:384`).

After dispatch, the distinction matters. `OPS-27` says “Attach it and complete the operation as though it had succeeded”; `OPS-36` says “attach the machine, then immediately route it through the exhaustion path”; `WIR-35`’s synchronous `observed` “attaches a discovered resource”. Resolution transitions “are made by no worker” (`03-operation-lifecycle.md:95`). These are not new purchases subject to a fresh pre-dispatch refusal.

The sentence that fails to cover legacy attachment is “MUST be copied from the create’s `request_summary` offer snapshot” (`05-persistence.md:261`): an absent member supplies no value to copy. “A null value MUST contribute no earliest-date term” specifies reading null, not converting absence into null. The neighboring `billing_unit_seconds` and `install_strategies` null-reader rules establish the same distinction (`05-persistence.md:259–260`).

Proposed sentence at that column’s owner:

> For creates admitted before the bound was included in `request_summary`, an absent snapshot bound MUST be copied as null on every attachment path named here, and machine rows predating the column MUST retain null.

This addresses legacy writes without exempting queued creates from `OPS-23`.

Null is **pricing-equivalent to the accepted v1 bound**, not necessarily to actual provider liability: `PRV-31` refuses bounds “later than the provider’s local today”, while `LDG-33` includes the term “only if later than provider-local today”. Later automatic, late, or operator attachment cannot make that fixed accepted date future again. A subsequent lifting of the sale restriction does not change those historical dates.

Provider deviation does not invalidate that equivalence: a successfully read actual date replaces the fallback; an unsuccessful read leaves it unknown (`PRV-13c`). `ADR-0037` Q25 says “Cost past the declared bound is operator-borne”. Null differs from a **future accepted bound**, as the injected comparison explicitly demonstrates (`10-conformance-checklist.md:3715–3727`). `STO-13`’s “stop every component” prevents concurrent derivations; it neither reconstructs missing history nor removes pending operations.

“Specifications only” is verified (`README.md:6`); absence of deployments elsewhere remains owner-supplied information.

**Strongest case for the other side (written on request)**

A: nullable storage, mandatory attachment, and the explicit null-reader rule together make null the natural legacy interpretation (`05-persistence.md:261`, `OPS-27`). Since v1 pricing is unchanged, the proposed sentence merely documents an already inferable result.