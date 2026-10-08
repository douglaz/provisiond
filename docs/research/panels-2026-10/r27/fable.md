**Verdict:** amend — dissolve the fallback instead of scoping it: `accepted` stays Boolean, the `internal`/`null` sentence is deleted, and ADR-0035 gets a dated note saying what its sentence named.

**Why.** The conflict is real and behavioural, not wording: `API-24` (04:1124) derives HTTP status from kind, so a connection reset becomes 500 "Defect in this system" (01:557) instead of 502 "Transport failure reaching the provider" (01:555), and that status plus kind is the only evidence `OPS-13` leaves an operator. Nothing else branches on it: `retryable` is false either way (13:204), `WIR-9a` defines no keys for `network`/`timeout`/`internal`, `OPS-27` keys on the correlator, `OPS-31` on verbs, and `classify` treats both alike (`rejected_order_witness`, Witnesses.lean:2531). But the owner's narrowing specifies nothing. For a conforming driver, "cannot tell acceptance" happens only when it has no interpretable reply to the mutating request: transport died (`network`), deadline (`timeout`), unreadable status (`network`), SDK exception with no status (`provider`, unrecorded). Every deterministic kind comes from a reply the driver received and can attribute, so acceptance is known there. The residual the rule reserves for `internal` is empty; the only driver reaching it has lost track of its own request, which is `DOM-17`'s `internal` already. That is what ADR-0035:36 named — its r20 origin reads "Without it, the driver reports `internal`" (r20/opus.md:32), a driver with no fact to report, and r22 reads the field as "a Boolean" (r22/astra.md:13). The tri-state and "MUST NOT substitute `false`" are cf3c32a's additions, not the ADR's.

**Cases** (dissolved rule; kind / `accepted` / `OPS-11`):

| Trace | kind | accepted | outcome |
|---|---|---|---|
| Connect/DNS failure, nothing sent | `network` | false | `needs_reconciliation` (by kind, over-cautious, pre-existing) |
| Body sent, reset before reply | `network` | false | `needs_reconciliation` |
| Timeout awaiting the reply | `timeout` | false | `needs_reconciliation` |
| 4xx to the mutating request | `provider`/`not_found`/`authentication`/`rate_limited`/`conflict` | false | `failed`; goal-state 4xx → `succeeded` |
| 5xx to the mutating request | `provider`, status 5xx | false | `needs_reconciliation` |
| 2xx the driver cannot parse (`SEC-4`, 07:39) | `internal` | **true** | `needs_reconciliation`, `OPS-27` search |
| Later request fails after acceptance: poll timeout (`PRV-11`), key cleanup (`PRV-9`), confirming read, `PRV-45` listing | that request's kind | true | `needs_reconciliation` via acceptance |

Every row is decided. Under the owner's rule the five `false` rows read `null`; under cf3c32a's literal text rows 1, 2, 3, 5 and 7 read `internal`, because 02:40-42 allows `false` only "where the driver establishes that request was not accepted", which a 5xx never does.

**Defects in the framing.**
- 02:44-45 versus 10:184-185: cf3c32a's own `CNF-31a` asserts "a network error, or a timeout is `needs_reconciliation`, including without known acceptance", a report its `PRV-5` forbids. The commit disagrees with itself; the Manager was right that it is not a wording repair.
- The 5xx row shows `null` would be the common value on ambiguous errors, not an exception: `null` ⇔ ambiguous kind. Tables.lean:92-93 already admits the model "does not model the wire's null separately". A tri-state that the only reader collapses is redundant; `false` = "no success reply to the mutating request" is literally true on a reset.
- "No implicit default enters `OPS-11`" (ADR:36) is about outcome, not evidence. `ambiguous r f = (acceptanceRule && accepted) || kindAmbiguous` (Tables.lean:133-136): `accepted` only ever adds ambiguity, so `false` cannot misclassify. That is provable and is the theorem that replaces the fallback.
- The ADR sentence was not "too broad"; it described a defect. A precedence clause for a rule with an empty domain is machinery.
- Strongest "don't build": no reader consumes the unknown value. `OPS-11` and `LDG-39` key on `true`. Delete `null` and the fallback; the gate stays green (HEAD passes today; no theorem mentions null).

**Edits.**
- `PRV-5` 02:38-48: Boolean; true iff the provider answered the mutating request with success; false otherwise, a lost reply keeping its failure's kind. Delete 02:44-45. Keep "Known acceptance MUST remain `true`" and Robot's 403.
- `OPS-11` 03:265-266: replace the "Unknown acceptance follows" sentence with "a lost reply is ambiguous by kind".
- `ADR-0035`:36: dated note — "cannot tell" names a driver with no reply status, `DOM-17`'s `internal`; line 55 already states the transport rule; the field is Boolean.
- `CNF-31a` stands. `CNF-31b` 10:199-201: drop the `internal` fallback. `CNF-322` 10:3057-3059: assert `false` on a reset and a 5xx, `true` on an unparseable 2xx, never `null`. `CNF-323` 10:3070-3071: "transport failure and a 5xx remain ambiguous with `accepted` false".
- Lean: Tables.lean:92-93 docstring loses the null sentence; add `@[req "OPS-11"] theorem accepted_false_is_neutral : ambiguous r {f with accepted := false} = ambiguous {r with acceptanceRule := false} f`; `rejected_order_witness` Witnesses.lean:2531-2533 third conjunct becomes `provider`/`status5xx`/false. `Failure`, `classify`, `classify_total`, `admission_only_failed`, `accepted_never_failed`, `accepted_read_failure_witness`, Reconcile: unchanged under every reading — the override lives in the driver mapping, outside `classify`, which is itself evidence it was never a classifier rule.
