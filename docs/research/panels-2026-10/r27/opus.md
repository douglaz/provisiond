**Verdict: amend.** Keep `PRV-5`'s mapping. Replace the leftover `internal` rule with: unknown acceptance reports the mutating request's own failure. No override, no new `OPS-11` rule, no Lean change.

**Why.** The conflict is real and wider than stated. On the trace, 02:32 ("transport failures to `network`") and 02:44 ("MUST report `internal`") both apply. A 5xx answer to the order also collides with 02:33 ("non-2xx responses to `provider`").

It changes what goes on the wire, not any decision. For `network`, `timeout` and `internal` alike:
- classification is one arm (Tables.lean:135; install row 03:226);
- `retryable` is "**always** `retryable: false`" (13:204);
- no `WIR-9a` keys apply;
- `LDG-39` and `OPS-27`/`OPS-31` read outcome, correlator and state;
- no HTTP status is sent: mutations return "`202 Accepted` with an operation view" (04:59).

Only the `kind` string and conformance change. `internal` means "Defect in this system" (01:557), so a provider outage points operators at our code.

Acceptance is unknown only when the mutating request got no definite answer: a 4xx is a rejection (03:256-257), a 2xx is acceptance. `PRV-5`'s existing mapping already gives every such failure an ambiguous kind. A fallback matters only if a driver reports a *later* request's failure instead, so forbid that. `ADR-0035`:55 agrees: "A connection that dies mid-request is already ambiguous by kind."

**Cases** (✗ = contradicts the line)

| Case | accepted | cf3c32a | Brief | Proposed |
|---|---|---|---|---|
| Transport failure before any byte | `false` (02:40) | `network` | `null` ✗02:40 | `network`, `false` (over-caution predates this change) |
| Reset after the body was sent | `null` | `internal` ✗02:32 | `network` | `network` |
| Timeout waiting for the reply | `null` | `internal` ✗02:32 | `timeout` | `timeout` |
| 5xx | `null` | `internal` ✗02:33 | implied `provider` | `provider` + status |
| 4xx | `false` | mapped kind | same | same → `failed` / goal-state `succeeded` |
| Unreadable reply, no status | `null` | `internal` | **undecided** | `internal` (no mapping applies) |
| 2xx, body unparseable | `true` | unmapped | unmapped | `internal` |
| Later failure after acceptance (poll, 404/429/401/403, cleanup) | `true` (02:45-46) | mapped | transport→`null` ✗02:45-46 | mapped |
| Later failure after an unknown mutating request | `null` | `internal` | `internal` | that request's own failure |

All end in `needs_reconciliation` except the 4xx row. Every case is decided.

**Item 3.** `ADR-0035` never says `null`. The tri-state and "MUST NOT substitute `false`" come from cf3c32a. The only reader of the field is `OPS-11`'s `details.accepted: true` (03:258). Once `null` comes only with ambiguous kinds, it changes no classification, and Tables.lean:91-93's Bool is exact. `OPS-11` must not read `null`, because such a rule would only ever agree with the kind rule.

The other option is a Boolean that is true only on a success answer. That would lose rows 1 vs 2: "nothing reached the provider" vs "it may have". That is `OPS-13` evidence, and `OPS-11` would need it if `false` ever cleared transport ambiguity. Owner's call. I'd keep `null`.

**Item 4.** Replace 02:44-45 with: "A driver that cannot determine acceptance MUST report `details.accepted: null` with the mutating request's own failure mapped as above, `internal` only where no mapping applies; it MUST NOT report a later request's failure in its place, omit the field or substitute `false`." Strongest don't-build: no override, no `null` rule in `OPS-11`, no change to the Lean type.

**Framing defects**
1. "network/timeout … with `details.accepted: null`" is wrong in two places. Before any byte is sent it is `false` (02:40). After acceptance, "Known acceptance MUST remain `true` on every later error" (02:45-46).
2. It leaves out the 5xx collision (02:33).
3. "`internal` only where … would otherwise classify deterministically (a 4xx)" covers almost nothing. A 4xx answer to the mutating request is a known rejection (03:256-257). The rule only picks which error to report (last row) and leaves the unreadable reply undecided.
4. The `ADR-0035` edit is an amendment, not a clarification: it changes the wire kind and `CNF-322`. The Manager is right that this is not "mere wording".
5. `Tables` does not model `PRV-5`'s mapping, so it is not a reader that differs.
6. The checklist carries both readings. `CNF-31a` (10:184-185) has "a provider 5xx, a network error, or a timeout … including without known acceptance". `CNF-322` (10:3058) has "kind `internal`".

**Edits**
- `PRV-5` 02:44-45, as above.
- `OPS-11` 03:265-266: re-quote it.
- `ADR-0035`:36: dated amendment.
- `CNF-322` 10:3058: `null` with the mutating request's own kind; add the 5xx and unreadable-reply cases.
- `CNF-31b` 10:200-201 and `CNF-323` 10:3071: replace "the `internal` fallback" with "unknown acceptance".
- `CNF-31a`: unchanged.
- Lean: only the `Failure` docstring (Tables.lean:92) and `rejected_order_witness`'s docstring and third conjunct (Witnesses.lean:2520-2528; retarget to `.timeout`). No change to `classify_total`, `admission_only_failed`, `accepted_never_failed` or ci.yml's `acceptanceRule` control.

Gates are green at `4830cd0` (`tools/check-all.sh`, EXIT 0). I edited no tracked files; a copy of this answer is at `/tmp/r27-opus-review.md`.
