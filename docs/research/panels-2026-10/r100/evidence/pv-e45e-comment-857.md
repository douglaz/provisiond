## Agent Brief

**Category:** bug
**Summary:** Select and retain each named offer’s machine kind for ordering-capability checks.

**Owner decision:** “A: yes, kind per offer” (`owner-decisions-1030.md`, item 17). Adopted exact form: `docs/research/panels-2026-10/r86/r86b/Q2-A-cited.md`.

**Current behavior:**

`04-api-contract.md:241` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`:

```text
5d. **gate a create on its ordering capability** under `DOM-10` (`PRV-10`, `DOM-16`). A refusal stops here and is not collected by the tail.
```

`03-operation-lifecycle.md:788` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`:

```text
3. Repeat boundary validation under `OPS-23`: "Validation that was performed at the API boundary
   MUST be repeated in the worker before the driver is called". This includes `PRV-10`'s
   "explicit purchase acknowledgement", `PRV-8`'s "at least one SSH public key", the missing-field
   checks defined in `OPS-23`, and `DOM-10`'s gate on the create's ordering capability, which is
   `PRV-10`'s "the account is configured to allow ordering". The checks on caller-supplied fields
   run first, then the checks on fields the `api` wrote at admission, then the capability gate.
```

**Desired behavior / key interfaces:**

Replace `API-7` step 5d with exactly:

```text
5d. For create, open the existing LDG-35 admission transaction and read the provider account's
    stored offer listing in the same read-only snapshot the rich purchase tail will use,
    regardless of listing age; no stored listing means an empty offers set. If the named
    offer is present, take its kind and gate on DOM-10's matching ordering capability using
    the descriptor api runs with. A capability refusal stops here and is not collected by
    the tail. If the offer is absent, run no ordering-capability check and infer no kind from
    the provider account, capability set, offer-id spelling or caller input; continue to the
    ordinary tail's absent-offer verdict. No provider call or admission write is made here.
    On admission, retain the named offer's kind as machine_kind in the create's
    request_summary offer snapshot in the same transaction as the operation and commitment.
```

Replace the rich-purchase tail's opening (from "**Rich purchase tails" through "no listing is stored.") with exactly:

```text
**Rich purchase tails (create and extend-runway only; amended 2026-10-04, ADR-0030).**
After steps 1–5d, the tail MUST collect every applicable refusal once, from one read-only
snapshot inside the existing LDG-35 transaction, without an extra lock, ceiling slot, write
or provider call. For create this is the same transaction and snapshot opened at step 5d;
the tail uses the same stored offer listing and named-offer lookup and prices the commitment
and takes the offer snapshot from them. For extend-runway the transaction and snapshot
are opened for the tail as before.
```

Keep the immediately following age-refusal sentence and remaining tail verbatim. An absent named offer therefore takes the already-quoted collected unsellable refusal; an unhealthy account can still be its headline. A present named offer's capability refusal remains before the tail, including when that stored listing is old. No age check moves to 5d.

Replace `OPS-43` step 3 with exactly:

```text
3. Repeat boundary validation under `OPS-23`: "Validation that was performed at the API boundary
   MUST be repeated in the worker before the driver is called". This includes `PRV-10`'s
   "explicit purchase acknowledgement", `PRV-8`'s "at least one SSH public key", and the
   missing-field checks in `OPS-23`. Validate `request_summary`'s `machine_kind` as `virtual`
   or `bare_metal`. The `api` writes `machine_kind` at admission; for missing or invalid
   fields, see `OPS-23`. Check caller-supplied fields first, then api-written admission
   fields, then gate on `DOM-10`'s matching ordering capability selected by that persisted
   `machine_kind`, using the descriptor the worker runs with. No current offer read supplies
   this gate.
```

Replace `OPS-43` step 5 with exactly:

```text
5. Check for the named offer's absence from that result, applying the create-tail verdict
   quoted above. If present but its kind differs from request_summary's machine_kind,
   settle failed with invalid_request, details.reason: "offer_not_sellable" and
   retryable: false on both the error and the operation view, before any provider mutation;
   do not substitute the current kind or its capability. Otherwise re-test the named offer
   for sale on that result and the running descriptor. An absent offer or kind mismatch
   gets no price comparison, per-order key upload or order request; the same existing
   pre-step-9 settlement releases the commitment and any resource-offer exclusion.
```

In `OPS-23`, insert after its paragraph defining the claim-time absence/sale-retest exception:

```text
The offer-kind consistency check at OPS-43 step 5 uses the same exception: it runs on
step 4's current List offers result, after that read and before any provider mutation.
```

In the `operations.request_summary` row of `05-persistence.md`, replace the exact words "the **offer snapshot** (`offer_id`, the offer's `install_strategies` as accepted," with:

```text
the **offer snapshot** (`offer_id`, `machine_kind` (`virtual` or `bare_metal`, copied from the
named offer at admission under API-7), the offer's `install_strategies` as accepted,
```

In `STO-50`'s "For a create" bullet, append this exact sentence:

```text
The enumerated offer snapshot includes machine_kind as defined on the request_summary row.
```


**Acceptance criteria:**

In `CNF-55`, insert immediately after its opening sentence (ending "account-level opt-in."):

```text
For the ordering-capability refusals below, the stored listing contains the named offer
with its explicit kind; run the admission refusal on both a fresh and an old listing.
The admitted create's request_summary retains that kind as machine_kind.
```

Append to `CNF-19`, after its current first sentence:

```text
Use one account whose stored listing contains both a virtual offer and a bare_metal offer.
With only provision_virtual declared, assert that a create of the bare_metal offer refuses
at API-7 step 5d naming provision_bare_metal, and that the virtual offer passes that gate;
reverse the declared provisioning capability and assert the converse. When the named offer
is absent, assert no guessed ordering-capability refusal: run the normal collected tail,
with an unhealthy-account refusal ahead of offer_not_sellable when both apply, no cap or
balance check, and no admission provider call. Repeat with no stored listing. For a present
named offer, assert a capability refusal before tail collection whatever listing age; with
its capability declared, the stored listing older than the stated offer-listing age, and no
collected refusal, assert the existing stale-listing refusal.
Admit with a fresh named offer, then remove the matching ordering capability before claim:
assert the CNF-55 pre-List-offers refusal using the retained machine_kind. Separately omit
or corrupt that api-written field and assert OPS-23's incomplete_record result, before any
provider request. With valid retained kind and capabilities, return a live offer of the
opposite kind at OPS-43 step 4; assert step 5's kind-mismatch refusal, no price comparison or
provider mutation, full commitment release and release of any resource-offer exclusion.
With the live offer absent, assert the existing absent-offer refusal after the list read.
```

The first instruction above refers to `CNF-19`'s sentence as quoted in the evidence; insert after the complete existing checklist item's sentence. These are proposed changes to the test's fixtures and assertions, not claims that the old test already proves the kind source. In particular, Q2-A explicitly qualifies `CNF-55`'s capability-refusal fixture by named-offer presence and introduces an absent-offer skip at step 5d; flag the observable precedence change and assess it rather than claiming every old refusal is preserved. It does not change the stored-listing header default. No caller `kind` field is added, and the snapshot retains no new customer secret.


Additionally perform all the following exact Lean docstring substitutions:

Line 19, replace:
```text
`API-7` says "A refusal stops here and is not collected by the tail."
```
with:
```text
`API-7` says "A capability refusal stops here and is not collected by the tail."
```

Lines 317–319, replace:
```text
`orderingCapabilityGuard` (`API-7`, 2026-10-22, `pv-p3k`): `API-7` says
"**gate a create on its ordering capability**". Off, a create without that declaration reaches
the purchase tail.
```
with:
```text
`orderingCapabilityGuard` (`API-7`, 2026-10-22, `pv-p3k`; step 5d reworded 2026-10-30,
`pv-e45e`): step 5d gates a create on the ordering capability selected by the named offer's kind
in the stored listing, and takes no gate for an offer absent from it. Off, a create without that
declaration reaches the purchase tail.
```

Lines 1181–1182, replace:
```text
whether the account declares the create's ordering capability. Machine-kind selection and
descriptor construction are outside this model.
```
with:
```text
whether the account declares the ordering capability selected by the named offer's kind in the
stored listing; for an offer absent from that listing step 5d takes no gate and the Boolean is
supplied `true`. Offer-kind selection and descriptor construction are outside this model.
```

Lines 1205–1206, replace:
```text
`API-7`: "On create, the tail reads the stored listing regardless of age, or an empty offers set
if no listing is stored." The supplied sale verdict
```
with:
```text
`API-7`'s step 5d reads the stored listing "regardless of listing age; no stored listing means an
empty offers set". The supplied sale verdict
```


**Out of scope / retained / rejected:**

`docs/research/panels-2026-10/r86/r86b/Q2-A-cited.md:109`:

```text
It does not change the stored-listing header default. No caller `kind` field is added, and the snapshot retains no new customer secret.
```

`owner-decisions-1030.md`, item 17:

> Rejected: "B: no, kind per account".

`owner-decisions-1030.md`, item 17:

> the changed missing-offer formal case needs a substantive formal amendment

The open formal objection remains on record at `docs/research/panels-2026-10/r86/r86b/owner-questions.md:25` and `docs/research/panels-2026-10/r86/owner-decisions.md`, item 17. The exact form is unchanged; no manager repair is adopted.

**Drift since the panel pin:**

- `04-api-contract.md:241` at `3109b5b44eae17e288cf52aaa976993bd8c5626c` and `04-api-contract.md:241` at `832a2197aec28e63bd6d0bf70996171cd0dbd6f7`: unchanged (the complete landing-site file is byte-identical).
- `04-api-contract.md:262` at `3109b5b44eae17e288cf52aaa976993bd8c5626c` and `04-api-contract.md:262` at `832a2197aec28e63bd6d0bf70996171cd0dbd6f7`: unchanged (the complete landing-site file is byte-identical).
- `03-operation-lifecycle.md:788` at `3109b5b44eae17e288cf52aaa976993bd8c5626c` and `03-operation-lifecycle.md:788` at `832a2197aec28e63bd6d0bf70996171cd0dbd6f7`: unchanged (the complete landing-site file is byte-identical).
- `03-operation-lifecycle.md:795` at `3109b5b44eae17e288cf52aaa976993bd8c5626c` and `03-operation-lifecycle.md:795` at `832a2197aec28e63bd6d0bf70996171cd0dbd6f7`: unchanged (the complete landing-site file is byte-identical).
- `03-operation-lifecycle.md:2051` at `3109b5b44eae17e288cf52aaa976993bd8c5626c` and `03-operation-lifecycle.md:2051` at `832a2197aec28e63bd6d0bf70996171cd0dbd6f7`: unchanged (the complete landing-site file is byte-identical).
- `05-persistence.md:523` at `3109b5b44eae17e288cf52aaa976993bd8c5626c` and `05-persistence.md:523` at `832a2197aec28e63bd6d0bf70996171cd0dbd6f7`: unchanged (the complete landing-site file is byte-identical).
- `05-persistence.md:569` at `3109b5b44eae17e288cf52aaa976993bd8c5626c` and `05-persistence.md:569` at `832a2197aec28e63bd6d0bf70996171cd0dbd6f7`: unchanged (the complete landing-site file is byte-identical).
- `10-conformance-checklist.md:340` at `3109b5b44eae17e288cf52aaa976993bd8c5626c` and `10-conformance-checklist.md:340` at `832a2197aec28e63bd6d0bf70996171cd0dbd6f7`: unchanged (the complete landing-site file is byte-identical).
- `10-conformance-checklist.md:137` at `3109b5b44eae17e288cf52aaa976993bd8c5626c` and `10-conformance-checklist.md:137` at `832a2197aec28e63bd6d0bf70996171cd0dbd6f7`: unchanged (the complete landing-site file is byte-identical).
- `tools/formal/Provisiond/Admission.lean:19` at `3109b5b44eae17e288cf52aaa976993bd8c5626c` and `tools/formal/Provisiond/Admission.lean:19` at `832a2197aec28e63bd6d0bf70996171cd0dbd6f7`: unchanged (the complete landing-site file is byte-identical).
- `tools/formal/Provisiond/Admission.lean:317` at `3109b5b44eae17e288cf52aaa976993bd8c5626c` and `tools/formal/Provisiond/Admission.lean:317` at `832a2197aec28e63bd6d0bf70996171cd0dbd6f7`: unchanged (the complete landing-site file is byte-identical).
- `tools/formal/Provisiond/Admission.lean:1181` at `3109b5b44eae17e288cf52aaa976993bd8c5626c` and `tools/formal/Provisiond/Admission.lean:1181` at `832a2197aec28e63bd6d0bf70996171cd0dbd6f7`: unchanged (the complete landing-site file is byte-identical).
- `tools/formal/Provisiond/Admission.lean:1205` at `3109b5b44eae17e288cf52aaa976993bd8c5626c` and `tools/formal/Provisiond/Admission.lean:1205` at `832a2197aec28e63bd6d0bf70996171cd0dbd6f7`: unchanged (the complete landing-site file is byte-identical).

PR #51 is included in this base; its merged tip is `832a2197aec28e63bd6d0bf70996171cd0dbd6f7`.

