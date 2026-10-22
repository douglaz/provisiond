**Panel B answer (fable), at `07bac41`.**

**Q1 (pv-p3k) — AMEND A.** Keep A's kind, `retryable: false`, position and non-collection. Pin where "declare" lives, or `DOM-15`, `CNF-18` and `WIR-29` ("`capabilities` are the descriptor's fields, rendered") break against an account that renders `provision_bare_metal` yet answers `unsupported`. Replacement `DOM-16`:

```
Ordering capabilities (`provision_virtual`, `provision_bare_metal`) for providers that bill per
order MUST be conditional on an explicit per-account `allow_orders` configuration flag: the
descriptor (`PRV-44`) of an account whose flag is false does not declare them, and `WIR-29`
renders that account's `capabilities` accordingly, so a misconfigured deployment cannot spend
money. This is in addition to, not instead of, the per-request purchase acknowledgement (`API-15`).
```

`PRV-10` gains A's text unchanged. `retryable: false`: the caller's fix is `OVR-2`'s discovery read, not a resend, and no `unsupported` anywhere is retryable. Position after 5c is right: a replay must return its stored result (5a) before a refusal from changed startup configuration. Under B or C `details.capability` has nothing to hold, because the capability stays declared. Touches `DOM-16`, `PRV-10`, `API-15`, `CNF-55`, `CNF-19`. **Owner**: SHOULD to MUST retires a permitted engine shape.

**Q2 (pv-009) — AMEND A**, adding step 3's internal order, which A leaves unstated:

```
3. Repeat boundary validation under `OPS-23`: "Validation that was performed at the API boundary
   MUST be repeated in the worker before the driver is called". This includes `PRV-10`'s "explicit
   purchase acknowledgement", `PRV-8`'s "at least one SSH public key", the missing-field checks
   defined in `OPS-23`, and `DOM-10`'s gates on the create's ordering capability (`PRV-10`'s "the
   account is configured to allow ordering") and on `list_offers`, each failing as `PRV-10` states
   for the configuration half. These checks run in the order listed; the first failing one stops
   the rest.
```

Gates last mirrors admission (step 5 validation, then the gate after 5c). Traces: `credentials_rejected` plus no `list_offers` fails at step 1, `conflict`/`state`, `retryable: true`. Closed channel plus no `list_offers` fails at step 2, `rate_limited`. Several step-3 failures: the first listed wins, so a missing price field beats the gate (`incomplete_record`, `true`). `retryable` for the gate equals Q1's, `false`. B gives identical outcomes with a second gate sentence; C would let `unsupported` outrank the status read. Touches `OPS-43`, `OPS-23`, `CNF-342`. **Mechanics.**

**Q3 (pv-gpw) — AMEND A.** Structure accepted: one by-writer rule in `OPS-23`, `PRV-47` citing it, `CNF-342` asserting per writer. Engine-written kind `internal`: accept. Its `retryable: false` contradicts `OPS-11`'s create row, "For `network`, `timeout`, `internal`, `provider` with a 5xx or no upstream status, and a cut-off `conflict`, it MUST carry `retryable: true`". Vote `true`, owned there. Replacement lead sentence and new bullet:

```
For create, install, power and delete, a required field that is missing, a present value this
repeated validation rejects, or a value `PRV-47`'s driver validation rejects at `OPS-43`'s step 7,
MUST fail by who wrote it:
…
- A value the worker or driver itself writes at claim — `PRV-9`'s operation id as a temporary
  key's "provider-side name or tag", a generated correlator key — fails `internal` (`DOM-17`:
  "Defect in this system"); the caller wrote nothing it can fix. `OPS-11`'s create row gives its
  `retryable`: “For `network`, `timeout`, `internal` … it MUST carry `retryable: true` on both the
  error and the operation view”.
```

`PRV-47`'s sentence becomes:

```
A value this validation rejects fails by its writer under `OPS-23`: a caller-supplied one "fails
`invalid_request` naming the field, with `retryable: false` on both the error and the operation
view"; one the worker or driver wrote fails `internal`.
```

Touches `OPS-23`, `PRV-47`, `OPS-43` step 7, `CNF-342`, `CNF-34`. **Mechanics.**

**Q4 (pv-ss4) — AMEND A.** "Code-unit order" names no encoding. Reuse `WIR-3`'s RFC 8785 order and put the key in `WIR-9a`'s table, its per-kind home. New row:

```
| `invalid_request` naming a field (`WIR-2`, `OPS-23`, `PRV-47`) | `field`: an RFC 6901 JSON Pointer into the request body (`"/acknowledge_purchase"`, `"/provider_options/location"`). Where one check rejects several, the least pointer in UTF-16 code-unit order, the order RFC 8785 (`WIR-3`) gives member names |
```

`WIR-2`: "naming the first unknown field" becomes "naming the unknown field with the least pointer in `WIR-9a`'s order". A claim-time check recovers the order: the worker reads the stored `request`, which `05-persistence.md` purges to `request_summary` only by age, and the order is a function of the JSON, not of document position, which `WIR-1a` and `WIR-3` never give. An engine-written value carries no key: the row is scoped to `invalid_request`, and Q3 makes it `internal`. Touches `WIR-9a`, `WIR-2`, `OPS-23`, `PRV-47`, `CNF-34`, `CNF-175`, `CNF-342`. **Mechanics.**

**Q5 (pv-7j3) — ACCEPT A**, `state`. The sentence is a narrower copy of `STO-36`, "A row MUST NOT be written naming a `provider_account` whose `STO-47` status is anything but `healthy`", and the synchronous refusal of a non-healthy account is already `WIR-29`'s "`conflict` with `details.reason: "state"`". `account_terminated` is a recorded reason on swept operations only; B would make one reason both a `409` and a recorded one and reopen `CNF-248`. The Run should widen the clause to `STO-36`'s rule, quoting it. Touches `WIR-48`. **Mechanics.**

**Q6.** One Run for pv-p3k, pv-009, pv-gpw and pv-ss4, since all four edit `OPS-43` step 3, `OPS-23`, `PRV-47`, `WIR-9a` and `CNF-342`; pv-7j3 is one clause and can be the Run's first commit or land alone.

**Against my picks (written on request).**
- Q1: pv-xer's analogy. An operator can flip the flag back, exactly as an unreachable account "can recover", and `unsupported` is the one kind the set now gives two meanings: driver shape and operator policy.
- Q2: `DOM-10` says gate "before the driver is called", and step 4 is that call. B puts the gate on the call it protects and survives pv-tcs deciding admission reads no driver.
- Q3: a deterministic driver rejection fails identically on every resend, so `true` invites the loop `SEC-39` exists to stop; `false` is honest and costs one `OPS-11` carve-out.
- Q4: RFC 6901 escaping and UTF-16 ordering are machinery no current fixture needs; C with a free `message` covers every listed case today.
- Q5: `terminated` is write-once, and `state` hides a permanence the caller cannot learn from a `409` without a second read.

**Brief errors.** No quoted fact is wrong. Two omissions change answers, and one tag is misattributed:
- `OPS-11`'s create row already fixes `internal` at `retryable: true` before step 9, which Q3-A contradicts. `grep -n "internal\`, \`provider\` with a 5xx" 03-operation-lifecycle.md`.
- `STO-36` already forbids assigning any non-`healthy` account, and `STO-47` notes `WIR-48` "refused only `terminated`". `grep -n "anything but" 05-persistence.md`.
- Lean's `TailRefusal.rank` is tagged `API-7`; only `retryable` carries `WIR-9a`. `grep -n -B1 "def TailRefusal" tools/formal/Provisiond/Admission.lean`.

Gates were not run: no edit touched Lean or a `CNF` quote in this clone.
