Amend — preserve the cause kind; make explicit `accepted: null` an ambiguity condition for last-row mutations.

The conflict is real and changes the observable contract. `PRV-5` requires transport failures to map to `network`, then requires unknown acceptance to “report `internal`” ([02-provider-contract.md:32](https://github.com/douglaz/provisiond/blob/4830cd02890fa37aea205dd8cd0e2b4e8a1f9876/02-provider-contract.md#L32)). Narrowing the latter changes an accepted decision, not merely wording. Your recommendation repairs transport diagnosis but retains an unnecessary conversion elsewhere: uncertainty about acceptance does not establish a system defect. Keep cause and acceptance knowledge separate; add explicit null to the acceptance condition, preserving goal-state precedence and existing operation-specific rows.

The table evaluates **your proposed rule**, for last-row mutations. `NR` means `needs_reconciliation`.

| Case | Report under your rule | Outcome |
|---|---|---|
| Transport failure before any mutation bytes sent, established by driver | `network`, `false` | NR: false does not override transport ambiguity |
| Body sent; connection reset before reply | `network`, `null` | NR |
| Timeout waiting for mutation reply | `timeout`, `null` | NR |
| Mutation’s own ordinary 4xx rejection | Specific mapped kind or `provider`, `false` | `failed`; established goal state instead succeeds |
| 5xx, acceptance unknown | `provider`, `null`, **if** your exception covers every already-ambiguous case | NR |
| Reply cannot be parsed | Underspecified: usable status may establish acceptance/rejection despite unreadable body; otherwise null. Acceptance alone cannot select the parsing-error kind | Not fully decided |
| Later poll/key-cleanup error after accepted order | Ordinary mapped kind, `true`, including `timeout` | NR; acceptance survives the later failure |
| Otherwise deterministic error with acceptance genuinely unknown | `internal`, `null` | NR; my amendment retains the original kind |

Defects and limits in the framing:

- **Same settlement does not mean same contract.** The taxonomy calls `internal` “Defect in this system,” versus `network` “Transport failure reaching the provider,” with HTTP mappings 500/502 ([01-domain-model.md:553](https://github.com/douglaz/provisiond/blob/4830cd02890fa37aea205dd8cd0e2b4e8a1f9876/01-domain-model.md#L553)). Operators would investigate different causes. Those mappings concern HTTP errors; an operation’s embedded error does not itself determine its poll’s HTTP status.
- **Retryability is not inferred from this distinction.** Its controlling precedence is `WIR-9b`: “`needs_reconciliation` and `gone` are **always** `retryable: false`” ([13-wire-contract.md:200](https://github.com/douglaz/provisiond/blob/4830cd02890fa37aea205dd8cd0e2b4e8a1f9876/13-wire-contract.md#L200)). `WIR-9a` supplies “keys … per kind,” so converting a known throttle or authentication failure also obscures useful structured diagnosis ([13-wire-contract.md:123](https://github.com/douglaz/provisiond/blob/4830cd02890fa37aea205dd8cd0e2b4e8a1f9876/13-wire-contract.md#L123)).
- **“Already ambiguous” is not solely a kind property.** The list includes `provider` with “5xx, or no upstream status,” and `conflict` from being “cut off mid-flight” ([03-operation-lifecycle.md:251](https://github.com/douglaz/provisiond/blob/4830cd02890fa37aea205dd8cd0e2b4e8a1f9876/03-operation-lifecycle.md#L251)). Preserve these too. Conversely, “already in the target state” must succeed ([03-operation-lifecycle.md:281](https://github.com/douglaz/provisiond/blob/4830cd02890fa37aea205dd8cd0e2b4e8a1f9876/03-operation-lifecycle.md#L281)).
- **Acceptance belongs to the operation’s mutation, not the failing request.** “Known acceptance MUST remain `true` on every later error” ([02-provider-contract.md:45](https://github.com/douglaz/provisiond/blob/4830cd02890fa37aea205dd8cd0e2b4e8a1f9876/02-provider-contract.md#L45)). Parsing failure is therefore not automatically unknown acceptance. Nor does `false` authorize deterministic settlement of a network failure.
- **Resolution does not branch on network versus internal.** `OPS-27` searches “the operation’s correlator”; `OPS-31` requires “who resolved it and on what evidence” ([03-operation-lifecycle.md:440](https://github.com/douglaz/provisiond/blob/4830cd02890fa37aea205dd8cd0e2b4e8a1f9876/03-operation-lifecycle.md#L440), [03-operation-lifecycle.md:1137](https://github.com/douglaz/provisiond/blob/4830cd02890fa37aea205dd8cd0e2b4e8a1f9876/03-operation-lifecycle.md#L1137)). The prescribed resolution route stays the same; diagnosis changes.
- **The Manager’s edit inventory misses `CNF-31b`**, which explicitly says “exercise unknown acceptance through the `internal` fallback” ([10-conformance-checklist.md:197](https://github.com/douglaz/provisiond/blob/4830cd02890fa37aea205dd8cd0e2b4e8a1f9876/10-conformance-checklist.md#L197)).

The strongest “don’t build this”: do not encode the same uncertainty in both nullable metadata and a fabricated cause. Null is redundant for classification on already-ambiguous causes, but distinguishes unknown from established non-acceptance. Let the existing field carry that distinction directly; add no dispatch machinery.

Under either Manager reading, `cf3c32a`’s executable `Failure`, `ambiguous`, `classify`, totality proofs and witnesses need no semantic change: its Boolean “does not model the wire’s null separately” ([Tables.lean:88](https://github.com/douglaz/provisiond/blob/4830cd02890fa37aea205dd8cd0e2b4e8a1f9876/tools/formal/Provisiond/Tables.lean#L88)). The preservation reading changes that explanatory comment. Neither reading’s driver mapping is proved.

My amendment edits `PRV-5`, `OPS-11`, and dated `ADR-0035`; updates `CNF-31a`, `CNF-31b`, `CNF-322`, `CNF-323`, and extends `CNF-327`. In `Provisiond.Tables`, make `Failure.accepted` explicit tri-state; extend `ambiguous`; update `classify_total`, `admission_only_failed`, `install_marker_directions`, and `accepted_never_failed`. `classify` retains its branches. Update `host_key_abort_witness`, `already_deleted_witness`, `accepted_read_failure_witness`, `rejected_order_witness`; add an unknown-acceptance witness and a negative control removing only null’s protection.

Reviewed `4830cd0` and `cf3c32a`. Both gate runs and the scratch Lean probe passed; tracked files remain unchanged.