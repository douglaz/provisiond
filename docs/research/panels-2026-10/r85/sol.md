Read the full brief and notes.md; verified HEAD is `3109b5b44eae17e288cf52aaa976993bd8c5626c`. My preferences are **Q1-A, Q2-B and Q3-A**, evaluated separately as printed.

For Q1, my final preference is **Q1-A**.

| Exact form | Vote |
|---|---|
| Q1-A | ACCEPT |
| Q1-B | ACCEPT |
| Q1-C | ACCEPT |
| Q1-D | ACCEPT |

The strongest reason for A is precise, portable diagnostics without another request or error field. [WIR-9a:134](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/13-wire-contract.md#L134) currently orders pointers “[w]here one validation step rejects several fields”; ordering does not determine whether the rejected field is an object, its member or an array element. A supplies that missing selection policy at the existing owner.

C remains defensible as a deliberately permissive diagnostic contract. A valid parent pointer can identify useful input without promising the same selector across implementations. My acceptance of C does **not** mean it resolves the reported portability gap. D is an acceptable narrower repair, with the limits it expressly states. B is coherent but gives less precise locations.

The concrete traces are:

| Request fault, with other checks passing | A | B | D |
|---|---|---|---|
| F1’s conflicting trust members | `/trust/accept_unpinned` | `/trust` | A’s result |
| Required trust absent, or present as `{}` | `/trust` | `/trust` | `/trust` |
| F2’s invalid strategy alone | `/strategy` | `/strategy` | `/strategy` |
| Invalid strategy plus truly unknown top-level `aaa` | `/aaa` | `/aaa` | `/aaa` |
| F3’s invalid resolution | `/resolution` | `/resolution` | `/resolution` |
| F4’s invalid key element | `/ssh_public_keys/1` | `/ssh_public_keys` | A’s result |
| Otherwise valid key array exceeding its bound | `/ssh_public_keys` | `/ssh_public_keys` | `/ssh_public_keys` |

For the invalid-discriminator trace, `target` and `trust` do not become unknown merely because strategy selection failed. `aaa` independently remains unknown and wins the escaped-pointer comparison. These are new selection obligations under A/B/D, rather than results already uniquely established by the pin.

For nested object elements, take an otherwise valid rootfs request with `layout.drives[0].identifier = null`. [API-13:974](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/04-api-contract.md#L974) explicitly requires such a value to be “refused `invalid_request` before enqueue.” A selects `/layout/drives/0/identifier`; B promotes to `/layout/drives`; C and D do not settle that distinction.

For nested arrays, a driver rejection of a member at `/provider_options/rows/0/0/x` selects that member under A. B promotes once to the directly enclosing array, `/provider_options/rows/0`, without promoting again to `/provider_options/rows`. That follows B’s expressly bounded promotion rule.

If an array simultaneously violates its length bound and contains an invalid element, A includes the independently failed array pointer and element pointer. The array pointer wins because it is their shorter common prefix. This does not violate A’s prohibition on adding an ancestor **solely** because a descendant failed.

The existing escaped-order case is preserved: `/provider_options/a~0b` sorts before `/provider_options/a~1b`. Decimal array indices are also compared as pointer text: `/ssh_public_keys/10` precedes `/ssh_public_keys/2`. I checked these comparisons locally without running repository gates.

No additional consumer edit is required. [WIR-2:28](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/13-wire-contract.md#L28) already says:

> “The field named in `details.field` MUST be selected under `WIR-9a`, including when the same validation step also rejects known fields.”

The printed standalone owner pointers at WIR-20, WIR-35, API-13 and RSC-4 are sufficient. Repeating A’s selection algorithm there would create competing homes.

The exact fixture file and CNF addition are acceptable. Their admission errors appropriately omit install-operation marker details and driver-only acceptance details.

**Requested counterargument, not my vote:** A establishes a broad diagnostic policy to repair demonstrated cases that D could address narrowly. Member-level pointers can suggest that one member is uniquely culpable when either conflicting member could be removed. B’s container describes the combination directly, while C avoids imposing further validator structure.

The printed fixtures do not cover nested object members, nested arrays, simultaneous array-wide and element failures, or groups outside trust. A/B specify outcomes for those categories; the fixture addition does not demonstrate universal coverage. I found no premise-changing brief error for Q1.

For Q2, my final preference is **Q2-B**.

| Exact form | Vote |
|---|---|
| Q2-A | ACCEPT |
| Q2-B | ACCEPT |
| Q2-C | ACCEPT |
| Q2-D | CANNOT ACCEPT |

The strongest reason for B is that the known caller defect remains actionable regardless of the generated-name defect. Returning `/provider_options/location` with `retryable: false` accurately identifies input that must change. It does not promise that correcting that input alone will make the create succeed.

The concrete worker trace is:

1. Admit the complete, type-valid request.
2. Pass the earlier worker checks and permitted List offers read.
3. At step 7, reject the caller’s location and generated temporary-key name.
4. Return the single error selected by the chosen policy.
5. Settle `failed`, perform no key upload or order request, release the commitment fully without either debit, and free any held resource-offer exclusion.

[OPS-43:799](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L799) places “Run `PRV-47`’s driver validation” before step 9. [PRV-47:166](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/02-provider-contract.md#L166) requires rejection “without any provider mutation for that create, including a per-order key upload or order request.” Those outcomes are preserved by A/B/C.

Their exact paired fixtures are acceptable:

- Caller-only: `invalid_request`, `/provider_options/location`, `retryable: false`.
- System-only: `internal`, `retryable: true`, no `details.field`.
- Mixed under B: the caller-only error.
- Mixed under A: the system-only error.
- Mixed under C: the system stage returns that internal error before caller validation begins.

Each driver error retains `accepted: false`. [PRV-5:45](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/02-provider-contract.md#L45) says a failure before any mutating-request byte “MUST report `details.accepted: false`.” The generated name is neither disclosed nor pretended to occupy a request-body pointer.

The retry flags obey the existing worker row once the category is selected. [OPS-11:249](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L249) says pre-step-9 failures “MUST settle `failed`, whatever its kind” and requires `retryable: true` for the listed kinds, including `internal`. A/C therefore retain true; B selects `invalid_request` and retains false. I do not import purchase-tail aggregation into this separate driver-validation error.

True does not authorize automatic repetition. [DOM-17:655](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/01-domain-model.md#L655) explicitly says the flag “MUST NOT be used by the system to retry automatically.”

What the caller can fix differs:

- Under B, it can correct the named location. It cannot repair the generated-name defect and may encounter that internal failure next.
- Under A/C, the response exposes no caller field to correct. Service intervention is needed for the reported defect; the caller defect remains undisclosed.
- None promises that one reported correction removes every defect.

A is acceptable as an explicit service-defect precedence policy. C is acceptable as an explicit staging requirement, although its observable order is additional architecture rather than necessary wire behavior.

I cannot accept D for the posed case where one validation actually rejects both origins. Its sentences demand `invalid_request`/false for the caller rejection and `internal`/true for the system rejection, while [WIR-9:122](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/13-wire-contract.md#L122) describes one inner error object with one `kind` and `retryable`. An unstated first-failure convention can avoid discovering both defects, but it does not resolve the stipulated mixed rejection. D supplies no coherent winner; obtaining implementation-defined kind/retryability would require that additional convention.

**Requested counterargument, not my vote:** B hides a known service defect behind a caller error. The caller can spend another operation discovering that its correction was insufficient, and monitoring based on returned kinds may miss the internal defect. A reports the defect the caller cannot remedy; C ensures that result without requiring a mixed-category arbiter.

Conversely, A’s true flag is less useful when unchanged caller input is already known to fail, and C introduces mandatory staging and skips caller diagnostics. These are policy losses, not changes to the preserved money or mutation outcomes. No new error field or validation stage is necessary: B resolves the category choice using the existing shape.

I found no premise-changing brief error for Q2. Internal precedence remains a proposal, not an owner ruling.

For Q3, my final preference is **Q3-A**.

| Exact form | Vote |
|---|---|
| Q3-A | ACCEPT |
| Q3-B | CANNOT ACCEPT |
| Q3-C | ACCEPT |

I do **not** find the current timing referent unambiguous. [OPS-23:2033](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L2033) extends disposition to a present invalid field through “settles as these missing-field failures do.” The following paragraph starts “These missing-field failures” before eventually saying “these checks MUST run before either `OPS-45` marker is written.” Reading “these checks” as all repeated validation is natural; reading it as the missing-field checks is also grammatically available. Settlement equivalence alone is not an explicit timing statement.

A resolves that referent at the existing timing owner and requires completion before either write. C also resolves the present-value case and is acceptable, though it leaves the timing obligation expressed in separate passages.

I cannot accept B as the complete repair because its fixture makes the disputed timing explicit while leaving the owner’s referent unresolved. This is an ownership and clarity objection, not a claim that absent coverage proves a contradiction in the unchanged pin.

For the trusted-provenance fixture, the conforming trace is:

```text
admit acknowledge_destruction = true
stored value becomes false
worker reads it; marker columns are null
finish repeated validation → reject
no marker write; no driver call
failed; invalid_request; retryable false
field /acknowledge_destruction
disk_effect none; rescue_exit none
```

The writer-based result is already settled. [OPS-23:2030](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L2030) gives a caller field “`invalid_request` naming the field” with “`retryable: false`”; its present-value sentence applies that writer’s bullet. An actual api-written install field, if a release names one, retains `conflict`/`incomplete_record` and true. The conditional fixture correctly invents none.

The attempted execution is:

```text
markers null
write rescue_exited_cleanly = false
repeat validation → reject false acknowledgement
begin-rescue never dispatched
```

It violates A/C’s explicit ordering and must fail the printed conformance assertion. No dispatch is needed to expose the problem. [OPS-45:1500](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L1500) says false can remain over a machine “never rebooted into rescue” and that “the column does not separate that row from one whose session is still open.”

The retained witness [false_over_a_machine_never_in_rescue](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/tools/formal/Provisiond/Witnesses.lean#L3627) specifically has false, no dispatch and a crash. The ordinary renderer maps false to unknown in [Session.rescueExit](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/tools/formal/Provisiond/Rescue.lean#L971). Clearing the marker or synthesizing none would discard that conservatism. A/C require neither.

The fixture’s `restore_markers_untrusted = false` matters. [WIR-9a:218](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/13-wire-contract.md#L218) requires unknown rendering for true or transitional null provenance “whatever the marker columns hold.” The proposed fixture does not change that override or specify recovery for an already nonconforming marker-first execution.

**Requested counterargument, not my vote:** The current paragraph can reasonably be read as already covering all repeated validation, making B sufficient. A also uses broader wording than C, so its scope must remain checks repeated under OPS-23, without moving observation-dependent checks ahead of their observations. C is the narrower available textual amendment.

Applying notes.md rule 6 exactly, I found no verified brief error changing any question’s premise and request no void tally. These votes concern the separate printed forms, including their fixtures and landing points. No combined amendment was reviewed, no files or Git/tracker state were changed, and no gates or Lean builds were run.