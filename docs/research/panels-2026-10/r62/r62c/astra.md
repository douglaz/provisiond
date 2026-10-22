Reviewed `07bac41` + `applied-fable.patch`.

- **a1: ACCEPT** — S1 precisely scopes the pointer rule to the caller-supplied stage.
- **a2: ACCEPT** — Names `details.field`, covers mixed known/unknown failures, and preserves the quoted phrase.
- **a3: CANNOT ACCEPT** — A withdrawal containing unknown `aaa` and `operator_ref` selects `/aaa`; the unconditional `/operator_ref` assertion contradicts “the least escaped pointer”.
  
  Exact replacement in `WIR-47`: replace “a withdrawal body containing `operator_ref`” with “a withdrawal body whose only rejected field is `operator_ref`”. Other a3 edits stand.
- **b: ACCEPT** — The exception permits implemented ordering code behind a withheld capability without relaxing the declaration requirement for other capabilities.
- **c1: ACCEPT** — Exercises admission precedence, stored replay, claim refusal, retryability, and financial cleanup.
- **c2: ACCEPT** — Keeping the driver path callable makes the fixture detect a missing outer capability gate.
- **c3: ACCEPT** — Exercises pointer selection and distinct caller/system failure outcomes, including retryability and cleanup.

**STAGE: S1.**

**(d): bead** — Mixed-writer precedence is a separate product decision; these fixtures isolate the writers.

**Brief errors:** None found.

Citation gate exited **0**. The full gate was started, then interrupted during Lean compilation to honor the no-wait instruction; no formal-pass claim.