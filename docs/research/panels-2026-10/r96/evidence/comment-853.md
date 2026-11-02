## Agent Brief

**Category:** bug
**Summary:** Specify the guarded suspension release transaction and its independent store cases.

**Owner decision:** “B: say it explicitly (Recommended)” (`owner-decisions-1030.md`, item 13). Adopted exact form: `docs/research/panels-2026-10/r83/check/settled-Q1-B.txt`.

**Current behavior:**

`04-api-contract.md:626` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`:

```text
then (3) enqueues a system cancellation per machine (`OPS-39`) — then (4) **transitions the tenant's own work — `requested_by: caller`, never a system
cancellation — that is already
`queued` but never claimed straight to `failed`, carrying the reason in the operation's `error`:
`conflict`, with `details.reason: "tenant_suspended"`** (`WIR-9a`, `WIR-10b`) — it
has touched no provider, so cancelling it needs no operation, and it does **not** carry the error
kind `suspended`, which `OPS-11` classifies as admission-only and forbids a worker to emit: that
kind stays an admission-time rejection of a *caller's* write (`DOM-20`).
```

**Desired behavior / key interfaces:**

In API-58, immediately after the sentence ending "that kind stays an admission-time rejection of a *caller's* write (`DOM-20`).", insert:

Where step (4) fails a create deterministically, the same guarded transaction MUST close its
commitment and release the remaining amount in full; see LDG-32, "the create fails deterministically".
It MUST make no setup-fee or first-unit debit. The administrative status write MUST precede the
release and short-circuit it when it affects no row, after the transaction's generation check
and the tenant's LDG-35 primitive.


**Acceptance criteria:**

At the end of CNF-202, before its existing amendment note, append:

Separately exercise the suspension fan-out's administrative write directly through the store,
on independent fixtures. These are store cases, not a claim that normal queue ordering leaves
an eligible create unclaimed. For each caller-requested operation kind in WIR-10's operation-kind
set that can be queued for this tenant, seed a never-claimed queued operation, a suspended tenant
and this suspension's unsettled parent. Run the write and assert one affected row, failed,
conflict with details.reason: "tenant_suspended", requested_by unchanged as caller,
system_reason null, and no provider request. For a create seed an open commitment with a nonzero
reserve, a nonzero setup fee and prepaid first unit; assert full release and no setup-fee or
first-unit debit. LDG-32 says "the create fails deterministically".

Vary one guard term at a time on fresh fixtures: requested_by system on a queued cancellation;
requested_by operator on a queued API-64 retry; status running under a real claim; tenant active;
and this suspension's parent already settled while the tenant is suspended. In each case assert
zero affected rows, the operation and its origin/error unchanged, and no commitment or provider
effect from this administrative write. Keep the other guard terms satisfied in each fixture.
Include a stale old-parent write after resume and a fresh suspension: the old settled parent
cannot authorize the write under the new suspension.

Race a real claim against the administrative write in both orders. Administrative failure first
prevents the claim. Claim first prevents the administrative failure, preserves the returned
claim number, and leaves settlement to that worker. A claimed create first picked up while the
tenant is suspended follows OPS-43's tenant-status refusal, not a purchase; it is not required
to succeed merely because its claim defeated the administrative write. Preserve the existing
held-power scenario above as the scheduling case; do not replace it with a normally eligible
create.

**Out of scope / retained / rejected:**

`owner-decisions-1030.md`, item 19:

> items 13 (pv-gvc) and 14 (pv-bxh) stand and land with or after it.

`owner-decisions-1030.md`, item 13:

> without the newly discovered deferred-operation guard fix.

`docs/research/panels-2026-10/r83/owner-questions.md:13`:

```text
Do not add the newly discovered deferred-operation guard fix to this approval.
```

`docs/research/panels-2026-10/r83/owner-questions.md:13`:

```text
Land with or after pv-kv2's still-pending exact mechanics, under the owner's item-3 "Stop before buying (Recommended)" decision.
```

`owner-decisions-1030.md`, item 13:

> Rejected: "A: tests only", "C: fewer tests".

**Drift since the panel pin:**

- `04-api-contract.md:626` at `3109b5b44eae17e288cf52aaa976993bd8c5626c` and `04-api-contract.md:626` at `832a2197aec28e63bd6d0bf70996171cd0dbd6f7`: unchanged (the complete landing-site file is byte-identical).
- `10-conformance-checklist.md:2252` at `3109b5b44eae17e288cf52aaa976993bd8c5626c` and `10-conformance-checklist.md:2252` at `832a2197aec28e63bd6d0bf70996171cd0dbd6f7`: unchanged (the complete landing-site file is byte-identical).

PR #51 is included in this base; its merged tip is `832a2197aec28e63bd6d0bf70996171cd0dbd6f7`.

