**Q1 — S-final: ACCEPT. F-final: CANNOT ACCEPT. Pick S-final.**

F1 calls the driver before an operation exists. Unamended `OPS-35` ([03-operation-lifecycle.md:30](https://github.com/douglaz/provisiond/blob/c5f897c32f7894d77a544528872176f241394d0d/03-operation-lifecycle.md#L30)) says: “The provider account MUST be resolved and written to the operation record **before** any driver call.” Trace: valid create → successful admission List offers → tail rejects insufficient balance → no operation ever exists. F10 exempts this read from `OPS-1`, but leaves that `OPS-35` MUST broken. The operations schema also retains the quotation “before any driver call”.

S avoids that conflict. Its publication obligation can coexist with `API-54`’s “A read MUST NOT take a write transaction” by serving catalogue GETs from stored listings. A GET that instead performs and publishes a successful driver read would fail `CNF-157`: “No `GET` takes a write transaction”. S does not require that GET implementation.

Options:

- S-a: **take**.
- S-b: **leave**; retain separate persistence and refresh owners.
- S-c: **leave**; retain the explicit input list.
- S-d: **leave**; no checked loss established, and its universal premise is false.
- F-a: **take Reader 3**.
- F-b: **leave**; F requires no listing-persistence write.
- F-c: **take Reader 3**.
- F-d: **leave**.
- F-e: **leave**; retain the explicit sale-test sentence.
- F9: **take**.
- F10: **take**, but it does not repair `OPS-35`.

Coordinator points:

1. **Claim-scoped:** the named assertions concern the worker’s refusal; an earlier admission read does not flip them.
2. **No such admission assertion found.** `CNF-364` explicitly starts with an account that “declares `list_offers` and the ordering capability”.
3. **No claim-time no-write loss found.** Publication after a successful read precedes step 8; failures before that read publish nothing.

F5 also needs a quotation correction, independently of F’s blocking loss.

**F5 wording AMEND — behaviour unchanged.** Replace its first replacement text, `` `API-7` tail before any provider mutation ``, with:

> tail before any provider mutation (`API-7`: “`rate_limited` when the offer's account and ordering channel are closed under `PRV-40`”)

**Against my pick:** S adds periodic work, durable listing state, freshness configuration and stale-data refusals. Admission can reserve an obsolete price and fail later. Fresh admission gives customers a more current purchase decision.

**Q2 — K-final: ACCEPT.**

Options:

- K-a: **leave**; retain the explicit generated throwaway key and caller-key distinction.
- K-b: **leave**.
- K-c: **take Reader 3**.
- K-d: **leave**; the fixture does not exclude an in-progress matched transaction. `OPS-33` says “the negative window MUST NOT run against a matched order that is still in progress”.

The retained-key trace works: generate the distinct per-order key → record its fingerprint at step 8 → retain that fingerprint on the delivered machine → reap the settled operation. The sweep finds the provisioning machine through its fingerprint and retains every registration tagged with that operation, including distinct caller keys. `PRV-9` explicitly says: “Every temporary key tagged with that operation id, including a caller key distinct from Robot's correlator key, has the same eligibility.”

**Yes, K3 settles the precedence for this trace.** Its added channel condition reaches “has no count”; the remaining sentence explicitly selects the no-verified-correlator row and says “it is **Unresolved**”. A fingerprint match therefore cannot supply the cardinality needed for automatic attachment. Independently, `PRV-33` says “attaching a discovered machine to a tenant MUST be an operator action”.

**Against K-final:** The pair’s presence remains easy to mistake for verified matching authority. K3 and the new lost-reply test must accompany the recording change; the fingerprint alone cannot authorize attachment.

**Brief errors**

- **F’s “full list” is incomplete:** it omits `OPS-35` and the operations-schema quotation identified above. F10 does not remove this conflict.
- **S-d overstates “no read ever stores its listing” and “every create … indefinitely”.** Counterexample: populate the row while `list_offers` is declared, then restart without that capability while retaining ordering capability. S2 deletes nothing; S1 still admits against the fresh retained row. The perpetual-refusal claim holds for an account lacking a usable stored row, not every such account.
- The supplied replacement anchors each matched once after normalizing Markdown line wrapping.

No gates, `lake`, provider APIs or delegation were used. No tracked files were changed.