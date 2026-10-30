# r85 Panel F: opus seat

I applied notes.md rule 6 exactly as written. I made no source, Git or tracker changes. The only file I wrote is a scratch script in `tmp/opus/`. All quotes below come from my clone at `3109b5b`.

## Q1: pv-y1zy

### 1. Vote

- **Final preference: Q1-A′**, a distinct form defined below.
- **A: CANNOT ACCEPT as printed.**
- **B: CANNOT ACCEPT as printed.**
- **C: CANNOT ACCEPT.**
- **D: CANNOT ACCEPT as printed.**

My only objection to printed A is the admission path its CNF paragraph uses. I accept A's normative row and paragraph, its four consumer pointers and its q1-fixtures.json unchanged. B and D share the same objection. If that path were fixed I would accept B or D, but I would still prefer A′.

**Q1-A′** is A's WIR-9a row and paragraph, A's four consumer pointers, and a byte-identical q1-fixtures.json. Only the CNF-342 paragraph changes. At the same landing point it reads:

```text
      Add field-selection cases F1–F4 from docs/research/panels-2026-10/r85/q1-fixtures.json,
      using otherwise valid fixture context. Send each printed request, and each repeat
      below, with one added top-level member zzz: 1, which `WIR-2` rejects in the same
      validation step and which sorts after every pointer asserted here, so that `WIR-2`'s
      "The field named in `details.field` MUST be selected under `WIR-9a`, including when the
      same validation step also rejects known fields" applies. Assert the machine-readable
      error fields in each fixture's A object: F1 rejects both trust members and names
      /trust/accept_unpinned; F2 names /strategy without inventing variant-member errors;
      F3 names /resolution; F4 names /ssh_public_keys/1. Repeat F1 with an independent
      unknown top-level member aaa and assert /aaa; repeat with trust absent and assert
      /trust. For array length failure use 65 otherwise valid keys and assert /ssh_public_keys.
      No request enqueues an operation or mutates the provider. Retain the existing escaped
      pointer ordering cases. (`WIR-9a`, `WIR-2`, `WIR-20`, `WIR-35`, `API-13`)
```

I checked the ordering in my scratch script. `/zzz` sorts after `/trust/accept_unpinned`, `/trust`, `/strategy`, `/resolution`, `/ssh_public_keys/1` and `/ssh_public_keys`, so every asserted result is unchanged. The `aaa` repeat still selects `/aaa`.

### 2. Why A′, with traces

**The defect in the printed fixtures.** The packet says F1–F4 are "admission errors before any operation is enqueued." None of them carries an unknown field. The row that requires `details.field` is "`invalid_request` naming a field (`WIR-2`, `OPS-23`, `PRV-47`)" (13:134):

- `WIR-2` reaches admission only for unknown fields.
- `OPS-23` is the worker.
- `PRV-47` is the driver.

A's own rules also take F1–F4 out of `WIR-2`:

- F1 is a group violation.
- In F2 and F3, "a member recognized by at least one variant is not unknown solely because the discriminator is invalid."
- F4, trust-absent and the 65-key case are plain `API-13`/`WIR-17` rejections.

The set shows that `invalid_request` at admission does not always carry `details.field`:

- `API-14` says "Absent or false MUST fail `400`" and names no key.
- `WIR-35` says a form outside its kind's set "is `invalid_request`" and names no key.
- `API-40` requires an admission `invalid_request` "with no `details.field`" in one case.

So the printed CNF paragraph would fail an implementation that conforms to every owner it cites. The paragraph would become the first home of an unstated rule: details.field on every admission body rejection. In r62, widening the scope of `details.field` went to the owner ("Wide: all four ops"), so that decision is not this fixture's to make. A′ sends every case through `WIR-2`'s existing MUST and leaves scope as it is.

**Why A rather than B.** WIR-9a exists because "routing a value through `message` … forces an agent to parse English". Its own examples name leaves, such as `"/provider_options/location"`, not `/provider_options`.

- With 64 keys and one bad element, B says only `/ssh_public_keys`. The agent cannot tell which key is bad without reading prose.
- A says `/ssh_public_keys/1`.

For F1, A always names `/trust/accept_unpinned`, because `accept_unpinned` sorts before `expected_host_keys` and `use_provider_keys`. Removing that member leaves a pinned policy.

**Requested test cases.** Pointers are compared by UTF-16 code units; I checked each ordering in the scratch script.

| Case | A | B | D | C |
|---|---|---|---|---|
| `trust: {}` | `/trust` | `/trust` | `/trust` | open |
| `trust: {"bogus":1}` | `/trust` (set {`/trust`, `/trust/bogus`}) | `/trust` | open: not an "empty trust object" | open |
| F2 + `aaa` | `/aaa` | `/aaa` | `/aaa` | open |
| F2 + `zzz` | `/strategy` | `/strategy` | `/strategy` | open |
| `layout.drives[0].identifier: null` (an `API-13` row) | `/layout/drives/0/identifier` | `/layout/drives` | open | open |
| 65 keys with key 3 bad | `/ssh_public_keys` (the prefix sorts first) | `/ssh_public_keys` | `/ssh_public_keys` | — |
| Escaped-order case (`a/b` and `a~b`) | `/provider_options/a~0b` | same | same | same (unchanged) |

**Existing verdicts.** Grep finds no existing assertion of an indexed pointer or a container pointer. The asserted pointers in the set are:

- `/acknowledge_purchase` and `/acknowledge_destruction`
- `/operator_ref`
- `/provider_options/location` and `/provider_options/a~0b`

None of these changes under A or B. No Lean declaration is tagged `WIR-2`, `PRV-47` or `OPS-23`. The `WIR-9a` tags are `rescueExit` and `TailRefusal.retryable`, which these forms don't touch. `RSC-4`'s `admissible` and `inadmissible_carries_both` keep their quoted sentence. The new pointer paragraph lands after them.

**Settled versus new.**

- Already settled: the ordering itself, and `WIR-2`'s MUST.
- New: the set-selection rule, plus test cases on the `WIR-2` path.

**Consumer change.** A′ needs none beyond A's pointers. Those are navigation only. `WIR-2` already says "MUST be selected under `WIR-9a`".

**Combinations A/A′ still leaves uncovered:**

1. **Invalid discriminator plus a variant member that is invalid in every variant that knows it.** Example: F2 + `"layout": 5`. Is `/layout` in the set or not? `/layout` sorts before `/strategy`, so the answer changes the result. "Other independent failures" is undefined.
2. **Cross-field rules other than exactly-one groups.** `API-13`'s "strategy/image pairing | per `DOM-13`" could select `/source/type`, `/strategy` or both. `RSC-23`'s "a RAID level … when software RAID is enabled" has the same problem.
3. **Indices.** Pointers order as text, so with elements 2 and 10 both bad, A names `/ssh_public_keys/10`. That is deterministic, but it is not the lowest index.

**Why not C.** With `WIR-2` engaged (F1 + `zzz`, or a stored record re-checked under `OPS-23`), C lets three engines return `/trust`, `/trust/accept_unpinned` or `/trust/expected_host_keys`. All three can cite the row. That is the "two implementations diverge without either noticing" that `WIR-2` exists to prevent, and no conformance item could assert anything about it.

### 3. Requested counterargument (not my vote)

C is defensible in one respect: kind and `retryable` are identical across all those engines, and every candidate pointer lands inside the offending subtree. A adds an algebra to a wire table that still has the gaps listed above, so each new group or array shape may need another bead. B's container is also arguably more truthful for a combination defect, where no single member is "wrong."

D carries the least new obligation. But it leaves `API-13`'s own `layout.drives[].identifier` row and the expected-host-key element rule open.

### 4. Brief errors

- **The admission-path fixture premise (above).** This does not void the vote: the set ambiguity is real on the `WIR-2` and `OPS-23` paths. My CANNOT ACCEPT on printed A, B and D rests on it.
- **Minor:** the packet's "assert exactly their machine-readable fields" must not be read as forbidding extra `details` keys. WIR-9a lists "Minimum keys", and the CNF text itself is fine.

## Q2: pv-xzre

### 1. Vote

- **Final preference: Q2-B.**
- **A: CANNOT ACCEPT.**
- **B: ACCEPT.**
- **C: CANNOT ACCEPT.**
- **D: CANNOT ACCEPT.**

### 2. Why B, with a trace

`DOM-17` (01:655–657) says "`retryable` describes whether repeating the *same request* is safe and sensible".

Trace for the paired fixture:

1. `location: "fixture-rejected-location"` is deterministically rejected by the driver rule.
2. Repeating the same body will fail at step 7 for that value on every attempt, even after an operator fixes the generated-name defect.
3. A and C require `retryable: true` on exactly that request. That is safe but not sensible.
4. B's `false` matches `DOM-17`, and it matches `PRV-47`'s existing caller value.

B also obeys `OPS-11`'s create row: "a failure classified `failed` without this pre-step-9 rule keeps its stated `retryable`". `invalid_request` is not in the row's forced-true list (`network`, `timeout`, `internal`, provider 5xx, cut-off `conflict`).

The set's only existing mixed-retryability rule points the same way. `WIR-9b`'s tail rule says the envelope is "true iff every refusal entry's `retryable` is true", and Lean's `envelopeRetryable` is `refusals.all`. That rule does not govern this case, but it is the set's precedent.

No form implies an automatic retry. `DOM-17` says retryable is "never authorization for an automatic service retry", and every fixture settles `failed`.

**What the caller can fix:**

- Under B, it fixes `/provider_options/location`, resubmits, and then gets `internal` with `retryable: true` (the system-only result).
- Under A or C, it can fix nothing it has been told about. It retries a request that cannot succeed.

**Settled versus new.**

- Settled: the single-origin kinds, `details.accepted: false` (`PRV-5`: "before any byte … MUST report `details.accepted: false`"), and no mutation with full release.
- New: the mixed-origin precedence, and "An internal validation error MUST NOT carry `details.field`".

**Why not C.**

- It gives the same mixed result as A, so it has the same `DOM-17` problem. It also makes that ignorance mandatory.
- "No mixed-origin validation step is permitted" has nowhere to put a check whose failure depends on both origins together. Example: a provider limit on the number of tags or keys when caller labels or keys are forwarded alongside the driver's reserved correlator label, or `PRV-32`'s throwaway key. This structure is my hypothetical, not a quoted provider limit.
- Its stage-order observation can only be seen by instrumenting the driver. With a fixture driver, it observes the fixture.

**Why not D.** The two sentences' consequents conflict on a reachable input. The only coherent reading is that the validator short-circuits, so only one value is "rejected". Even with `CNF-342` requiring that all caller rejections be collected ("both rejected by the driver"), whether a system rejection is found first depends on implementation order. So D leaves kind and `retryable` **implementation-defined**.

### 3. Requested counterargument (not my vote)

B hides a system defect on the wire whenever the caller's input is also bad. Error-kind metrics count it as a caller error until callers fix their input, and the caller needs two round trips. It also implies, without saying so, that "fix your input and it works", which is false here.

A's case is the triage's: "a caller fix cannot clear a defect".

Neither form can report both facts without a new `details` key, which the packet rules out. That is the loss neither A nor B avoids, and there is no narrower form that keeps both facts without such a key.

Uncovered by A, B and C: a single rejection caused jointly by caller and system values (the count-limit example).

### 4. Brief errors

The packet calls C "narrower"; in obligation it is broader, since it adds a staging MUST. This does not change my vote. I found no premise errors. I verified the paired fixture's body, key encoding and `details.accepted`.

## Q3: pv-hups

### 1. Vote

- **Final preference: Q3-A.**
- **A: ACCEPT.**
- **B: ACCEPT.**
- **C: ACCEPT.**

### 2. Why A, and the marker-first trace

**The trace.** An install is admitted with `acknowledge_destruction: true`, and the store is then edited to `false`. A marker-first engine writes `rescue_exited_cleanly = false`. Its repeated check then rejects the value before begin-rescue is dispatched.

1. `OPS-23` says a present-value failure "settles as these missing-field failures do".
2. That install settlement is "The install settles `failed` with `disk_effect: "none"` and `rescue_exit: "none"`". It uses the same verb, so the renderings are part of "settles."
3. `WIR-9a` gives "`none` only where no rescue session was opened". Lean `rescueExit` maps `some false => .unknown`.
4. `OPS-45` says "`false` moves to `true` and never back", and "Null is the only value that means no session was opened".
5. So the marker-first engine cannot produce the promised settlement. It would have to clear the marker or render `none` from `false`, and both contradict the quoted owners.
6. `OPS-11`'s "failed … where no rescue session was left open" also cannot be read from a `false` column. `CNF-302`'s crash at the same point lands in `needs_reconciliation` with `rescue_exit: "unknown"`.

**What this means for each form.** The whole text already requires validation before either marker is written, so B's fixture has an owner, and A's span change does not alter behavior. But the requirement is only reached through other requirements. "These checks" sits in a paragraph that opens "These missing-field failures", which is the referent the bead's Reading B uses.

A fixes that at the rule's home, as "one rule, one home" asks. C splits timing across two sentences ("MUST run" for missing fields, "MUST finish" for present values). B leaves the misleading referent in place.

**Preservation.** No normative text or tool quotes either replaced span (I grepped outside `docs/research`), so no citation gate breaks. Kind and `retryable` stay writer-based, because "as its writer's bullet above says" is untouched in every form. The fixture keeps `invalid_request`, `/acknowledge_destruction` and `false`.

**Settled versus new.**

- Settled: the ordering, by entailment.
- New: A's or C's explicit wording, and the fixture.

### 3. Requested counterargument (not my vote)

B is the minimal form, and the entailment above makes it sufficient. A's "every check … MUST finish" also binds checks that pass and api-written fields, which is wider than the bead. That is harmless in practice, since nothing can know in advance that a check will pass, but it is still a wider MUST than needed.

An adjacent gap none of the three forms covers: `CNF-302` asserts a null column for `OPS-40`'s claim-time URL gate and `DOM-10` refusals. The only normative "before either marker" sentence is `OPS-23`'s, and `OPS-40` says only "before rescue is entered." That is out of scope here.

### 4. Brief errors

None that affect my vote. Two minor wording points in the common fixture:

- The "instrument a proposed execution" sentence asserts how strong the oracle must be, not a property of the implementation under test. It is redundant with "both markers still null", which already catches the marker-first engine.
- Its last sentence repeats `CNF-34`'s following "Complete-record controls … proceed."
