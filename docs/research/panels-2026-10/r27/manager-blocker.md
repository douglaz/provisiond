## Owner clarification required

The concrete trace is an order POST whose body was sent, followed by a connection reset before any reply. The driver cannot determine whether the provider accepted the mutation.

The conflicting passages are:

- `02-provider-contract.md`, `PRV-5`, lines 32–33: “A driver MUST map provider transport failures to `network`, provider timeouts to `timeout`”.
- The new `PRV-5` amendment, lines 44–45: “A driver that cannot determine acceptance MUST report `internal` with `details.accepted: null`; it MUST NOT omit the field or substitute `false` for unknown acceptance.”
- `docs/adr/0035-a-failure-after-the-provider-accepted-a-mutation-is-ambiguous.md`, Decision: “A driver that cannot tell reports `internal`, which is already ambiguous. No implicit default enters `OPS-11`.”
- The same ADR's rejected-dispatch rationale: “A connection that dies mid-request is already ambiguous by kind.”

Two readings give different observable contracts:

1. **Unknown-acceptance fallback overrides transport mapping.** Emit `internal` with `accepted: null` on the trace above. Qualify the old transport mapping and align conformance with the override.
2. **Existing ambiguous transport kinds retain their mapping.** Emit `network` (or `timeout`) with `accepted: null`; narrow the fallback so it prevents an otherwise deterministic classification without replacing an already-ambiguous transport kind. Clarify the ADR/requirement precedence and align conformance accordingly.

Both readings reach `needs_reconciliation`, but they return different driver/wire error kinds and require different conformance behavior. Opus identified the collision and recommended the second reading as a wording repair. I accept the defect and reject the claim that the Manager can settle that reading as mere wording: it narrows the ADR's explicit fallback. An adviser vote cannot clarify a specification owner decision.

**Recommended clarification:** preserve the established `network`/`timeout` distinctions with explicit unknown acceptance, and have the owner state exactly when `internal` overrides the ordinary mapping, including the other already-ambiguous cases. This is a recommendation only. The answer must be applied consistently to `PRV-5`, its citations, `CNF-31a`, `CNF-322`, and `CNF-323`. No behavioral interpretation has been adopted here.

No Consultation was run: this is a specification behavior question, not an implementation choice. All four Reviewers supplied reports; none was marked `REVIEWER FAILED` or `REVIEWER NOT RUN`.

