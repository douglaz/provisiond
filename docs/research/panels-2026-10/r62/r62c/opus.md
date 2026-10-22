**a1: CANNOT ACCEPT.** The row's first cell cites `OPS-23` for all four operations, but the tie-break covers only create's stage. A stored install missing both `trust` and `acknowledge_destruction` has no rule. Replace the parenthetical with: "(an `API-7` step, `OPS-23`'s repeated check of caller-supplied fields, or `PRV-47`'s validation)"

**a2: ACCEPT.** It names the key, states the mixed case outright, and keeps the phrase `WIR-47` quotes.

**a3: CANNOT ACCEPT.** The `CNF-233` text is fine. `WIR-47`'s new sentence is a false universal: `{"status":"unknown","operator_ref":"x","evidence":"y"}` yields `"/evidence"`. `API-40` reports `WIR-2` without quoting it, against AGENTS.md's "Quote the sentence".
- `WIR-47`: "a withdrawal body whose only rejected field is `operator_ref` returns `invalid_request` with `details.field: "/operator_ref"` (`WIR-9a`)."
- `API-40`: "`WIR-2` says "The field named in `details.field` MUST be selected under `WIR-9a`" of a rejected unknown body field;"

**b: ACCEPT.** `PRV-4` holds the exception and `DOM-15` points at it. I reproduced the gate result on opus's form: 1 new unquoted attribution.

**c1: ACCEPT.** The 5a replay, 5d before the tail, step 3 before step 4, and the 501 all match `API-7`, `OPS-43` and `DOM-17`.

**c2: ACCEPT.** It reuses `CNF-19`'s permissive-driver fixture, and its outcomes match `OPS-11`'s create row.

**c3: CANNOT ACCEPT.** An arbitrary pair can't catch an implementation that sorts raw keys or unescaped pointers (`DEF-16`). Replace the two-value sentence with: "Add a stored create carrying provider-options members `a/b` and `a~b`, both rejected by the driver, and assert `details.field: "/provider_options/a~0b"`, the least escaped pointer in `WIR-9a`'s order; unescaped, `a/b` sorts first." The system-written half matches `OPS-11`.

**STAGE: S1** (moot under my a1 text). Only the caller-supplied stage fails `invalid_request`. The api-written stage fails `conflict`/`incomplete_record` and names no field.

**(d) Bead.** Both outcomes settle `failed` with no mutation and a full release. They differ only in kind and `retryable`, and no CNF item reaches the case.

**Scope/product:** none.

**Gates:** with all my replacements applied, the six non-formal gates exit 0. The formal build was not run.

**Manager note:** `check_citations` verifies a quote only when "says" directly follows the ID. I falsified a quote in each shape: only the "says"-first one failed.

**Brief errors:** none. I checked a3's line numbers with `git show HEAD:<f> | sed -n <n>p` and reproduced the `DOM-15` gate claim.
