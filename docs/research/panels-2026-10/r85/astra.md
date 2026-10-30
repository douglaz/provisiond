Reviewed the exact r85 forms against **3109b5b44eae17e288cf52aaa976993bd8c5626c**, including all of `notes.md`. No files or Git/tracker state changed; no gates, builds or subagents ran. These are votes on the printed proposals, not on an implementation or an unread combination.

**Q1 — Preference: A**

| Form | Vote |
|---|---|
| Q1-A | **ACCEPT — preferred** |
| Q1-B | **ACCEPT** |
| Q1-C | **ACCEPT** |
| Q1-D | **ACCEPT** |

A gives callers useful precision through one general rule at the existing owner. It distinguishes an invalid element from an invalid collection without adding a response key or validation stage.

The settled rule is [WIR-9a](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/13-wire-contract.md#L134): “Where one validation step rejects several fields … the least escaped pointer, compared by unsigned UTF-16 code units.” That specifies ordering; it does not uniquely determine whether a combination rejects its container or members. A/B/D introduce substantive field-selection obligations. C deliberately retains discretion.

My boundary evaluations are:

| Request defect | A | B | D |
|---|---|---|---|
| F1’s conflicting trust alternatives | `/trust/accept_unpinned` | `/trust` | A’s result |
| Required `trust` absent, or `trust: {}` | `/trust` | `/trust` | `/trust` |
| F2’s invalid strategy, otherwise valid | `/strategy` | `/strategy` | `/strategy` |
| Invalid strategy plus truly unknown top-level `aaa` | `/aaa` | `/aaa` | `/aaa` |
| F3’s invalid resolution, otherwise valid | `/resolution` | `/resolution` | `/resolution` |
| F4’s invalid key element | `/ssh_public_keys/1` | `/ssh_public_keys` | A’s result |
| Array-wide bound failure with otherwise valid keys | `/ssh_public_keys` | `/ssh_public_keys` | `/ssh_public_keys` |
| Invalid `layout.drives[0].identifier` | `/layout/drives/0/identifier` | `/layout/drives` | No new selection rule |
| Rejected provider-options members `a/b` and `a~b` | `/provider_options/a~0b` | Same | Same |

For the nested-object case, [API-13](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/04-api-contract.md#L974) already says a non-string or empty-after-normalization `layout.drives[].identifier` “MUST be refused `invalid_request` before enqueue.” The new choice is where to point.

Under A, simultaneous array-wide and element failures contribute both pointers; the array pointer wins because it is their prefix. That ancestor is justified by its own failed constraint. Under B, an invalid element of an inner array selects that inner array; “never recursively through containing arrays” prevents promotion to every enclosing array.

The invalid-discriminator rule does not suppress unrelated defects. For F2 plus `aaa`, the set contains `/strategy` and `/aaa`; recognized variant members do not become unknown merely because strategy selection failed. The same reasoning applies to F3 plus an independent unknown member.

The existing escaped-order assertion remains intact: [CNF-342](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/10-conformance-checklist.md#L4305) expressly asserts `/provider_options/a~0b`. None of these forms changes that result.

**Why the alternatives remain acceptable:**

- **B** is coherent and gives a caller the collection or combination it must repair, at the cost of element-level precision.
- **C** is defensible if portability of that precision is not a requirement. A valid container pointer remains machine-readable. C does not authorize arbitrary pointers or abandoning the existing sorting rule; it leaves the disputed rejected-set granularity unresolved.
- **D** resolves the demonstrated cases while openly retaining discretion elsewhere.

No additional consumer edit is required. [WIR-2](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/13-wire-contract.md#L28) already says the field “MUST be selected under `WIR-9a`.” The printed standalone pointer, `For details.field, see WIR-9a`, at the specified landing points is sufficient; duplicating the selection algorithm there would create another owner.

Coverage is not universal. The printed conformance addition does not expressly exercise empty-but-present trust, an invalid discriminator combined with an unknown field, nested object/array cases, or simultaneous array-wide and element failures. D also does not newly fix the zero-recognized-alternative case `trust: {"aaa": 1}`: its empty-object sentence does not cover that nonempty object. These are limitations, not contradictions in its stated narrower scope.

**Requested counterargument, not my vote:** A spends specification complexity on diagnostic precision that may not affect a caller’s recovery strategy. Its general rules constrain schemas beyond the demonstrated examples, while their conformance coverage remains narrow. D is the strongest narrower alternative; C avoids standardizing precision callers may not need. A also does not supply a complete algorithm for deciding every possible constraint’s independence.

**Packet errors:** I found no verified premise-changing error for Q1. C’s lack of portable parent/member/element selection is accurately disclosed.

**Q2 — Preference: B**

| Form | Vote |
|---|---|
| Q2-A | **ACCEPT** |
| Q2-B | **ACCEPT — preferred** |
| Q2-C | **ACCEPT** |
| Q2-D | **CANNOT ACCEPT** |

B exposes a concrete correction the caller must make and returns `retryable: false` while that known caller defect remains. Correcting the location does not repair the generated name, but it removes a necessary obstacle. A caller error need not assert that it is the only defect.

The unresolved base text is [PRV-47](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/02-provider-contract.md#L166): a rejected caller value “fails `invalid_request`,” whereas a rejected system-written value “fails `internal`.” The singular error shape in [WIR-9](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/13-wire-contract.md#L122) is “exactly `kind`/`message`/`retryable`/`details`.” Neither origin sentence selects the operation’s one error when both origins are rejected.

For the supplied paired fixture, the concrete trace is:

1. API admission and the worker’s boundary checks pass: the location is a syntactically valid string.
2. The preceding claim checks pass, including the permitted List offers read.
3. Step 7 rejects the location and generated temporary-key name.
4. No key upload or order call occurs.

The proposed errors are consistent with their respective new rules:

| Fixture | A | B | C |
|---|---|---|---|
| Caller-only | `invalid_request`, false, caller pointer | Same | Same |
| System-only | `internal`, true, no field | Same | Same |
| Both defects | `internal`, true, no field | `invalid_request`, false, caller pointer | `internal`, true, no field; caller stage skipped |

Every row carries `accepted: false`. [PRV-5](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/02-provider-contract.md#L44) requires: “A failure before any byte of the mutating request was sent MUST report `details.accepted: false`.”

Settlement does not depend on this category choice. [OPS-11’s create row](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L249) says pre-step-9 failures “MUST settle `failed`, whatever its kind,” and preserves the reported kind. Its explicit `internal` retryability is true; caller-validation `invalid_request` retains false. The exact fixtures preserve error/view agreement, no mutation, full commitment release, no setup-fee or first-unit debit, and release of any held exclusion.

Those retry flags authorize no automatic service retry. [DOM-17](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/01-domain-model.md#L655) says retryability is “never authorization for an automatic service retry” and “MUST NOT be used by the system to retry automatically.”

A and C obey the specific worker-failure row, but lose caller-actionable information: after receiving their mixed error, the caller has no field identifying the location defect. Fixing the system defect alone still does not make this fixture’s unchanged location valid. Their `true` must not be treated as a promise that another unchanged request will succeed.

C additionally requires observable staging. Its order assertion matters: matching A’s final error is insufficient to satisfy C if caller validation ran despite the failed system stage. That is an implementation constraint, not editorial wording.

D has no coherent disposition for the stipulated case where the same step rejects both origins. An implementation can avoid encountering the conflict through short-circuit evaluation, but that does not resolve this case, and D prescribes no such staging. Treating the result as implementation-defined requires an unstated rule choosing which origin sentence wins. Unlike Q1-C’s diagnostic granularity, the competing requirements here prescribe different kinds and retry flags for one error.

No additional response field is needed. A category rule such as A/B, or explicit staging such as C, suffices.

**Requested counterargument, not my vote:** B hides a known service defect behind a caller error. An automated caller may repair the location, create another operation, and only then discover `internal`; monitoring based on returned kinds may also undercount the system defect. A reports the condition the caller cannot repair. C achieves that outcome while making evaluation order explicit. B’s loss is diagnostic visibility, not a mutation or release guarantee.

**Packet errors:** I found no verified premise-changing error for Q2. The historical suggestion that internal should win is not an adopted decision and is not a basis for these votes.

**Q3 — Preference: A**

| Form | Vote |
|---|---|
| Q3-A | **ACCEPT — preferred** |
| Q3-B | **CANNOT ACCEPT as resolution of the timing question** |
| Q3-C | **ACCEPT** |

A puts the timing obligation unambiguously at its owner and covers both successful and rejecting repeated checks. C also resolves the disputed present-value case while preserving the existing missing-field rule.

[OPS-23](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L2032) already says a present invalid field “fails as its writer’s bullet above says … and settles as these missing-field failures do.” Kind, retryability and settlement are therefore not open here.

Timing is less explicit. The next paragraph begins “These missing-field failures,” and later says “these checks MUST run before either `OPS-45` marker is written.” The broad reading is persuasive, especially when combined with the promised settlement, but the pronoun is not an unambiguous statement about every present-value check.

B’s fixture is useful and rejects the illustrated bad execution. Nevertheless, its only newly explicit present-value timing language would reside in the selected conformance cases while the owner retains the disputed referent. I cannot accept that as completing this timing clarification. This is an adequacy objection, **not** a claim that B loses an existing checked verdict or contradicts the marker rules.

For the common fixture, the conforming trace is:

- Admit a valid install with acknowledgement true.
- Change only the stored acknowledgement to false.
- Begin worker validation with both marker columns null and trusted restore provenance.
- Reject before either marker write: `invalid_request`, `/acknowledge_destruction`, `retryable: false`, `failed`, no driver call, `disk_effect: none`, `rescue_exit: none`.

The attempted countertrace writes `rescue_exited_cleanly = false` before validating, then rejects before dispatch. Absence of dispatch cannot erase that marker’s conservative meaning. [OPS-45](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L1500) says the column “does not separate that row from one whose session is still open” and that false moves to true “and never back.”

The pinned formal definitions corroborate that distinction:

- [Rescue.rescueExit](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/tools/formal/Provisiond/Rescue.lean#L972) maps `some false` to `unknown`.
- [Tables.installRow](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/tools/formal/Provisiond/Tables.lean#L168) takes an unclean rescue marker to `needsReconciliation`.

Thus the marker-first execution cannot satisfy the fixture by merely returning the desired error. A/C forbid its ordering; the common fixture must detect that violation without clearing the marker or fabricating `none`. This reasoning does not specify a recovery path for an already nonconforming row.

The conditional api-written-field case correctly retains `conflict`/`incomplete_record`, `retryable: true`, and identical ordering assertions. No concrete api-written install field is supplied or invented.

The provenance qualification is material: [WIR-9a](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/13-wire-contract.md#L218) requires unknown rendering when provenance is “`true` or transitionally `null`, whatever the marker columns hold.” The fixture’s explicit false avoids overriding that rule. No proposal moves observation-dependent host-key, inventory or image checks ahead of their observations.

**Requested counterargument, not my vote:** The existing settlement promise plus immutable marker interpretation already makes the rejecting marker-first trace untenable. On that reading, B supplies the missing regression coverage without another normative sentence. C is also narrower than A and avoids broad wording that future authors might mistakenly apply to checks outside OPS-23.

**Packet errors:** I found no verified premise-changing error for Q3. The brief correctly separates the settled writer-based disposition from the disputed timing referent.

Applying **notes.md rule 6 exactly as written**, I found no verified brief error requiring any question’s tally to be voided. These are independent votes on each printed whole form; they do not approve a merged amendment.