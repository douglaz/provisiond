# Settled pv-kv2 wording correction — Panel P r95

Q1 **Q-QUOTE**, Q2 **L-NOTE**: Opus, Astra and Sol each prefer and ACCEPT the supplied exact complete package, comment and matching appendix, 3–0 on both questions. Fable's limit line and Grok's HTTP402 are missing seats, not votes. Nothing is adopted by this tally.

Source pin M: `6a3b6014f1f8b36fc21b902e507e74d8c5264e99`.
Review head H: `96a72898c7ace67790aec0bab3727eee858e2245`.
Both read-only main refs still match. No moved-ref stop condition applies.

All three readers classify both picks WORDING-ONLY in behavior, requirements/owner-items3+19/Panel O meaning, and check strength. The independent audit agrees: every original D and Panel O assertion survives, no assertion or check is weakened, no A/D combination or positive existing-fleet warning-publication duty is restored. The owner's rule is “For such wording questions, try to solve by getting a consensus of the panel”. This exact settlement needs no owner question and no r95b. Full occurrence, assertion, provenance and quotation audit: `check/tally-evidence.md`; mechanical receipts: `check/tally-verification.json`.

## Exact replacement targets on H

Only the listed substrings change. These blocks are already landed: do not insert the six blocks again. Lifecycle substitutions preserve their three-space Markdown list container; API substitutions have no container prefix. The snippets below omit only that outer lifecycle container indentation. Every other byte is preserved.

| Replacement | File / H lines | Corresponding original decoded comment860 lines |
|---|---|---|
| 1 | `03-operation-lifecycle.md:789–790` | 49–50 |
| 2 | `03-operation-lifecycle.md:818–819` | 63–64 |
| 3 | `03-operation-lifecycle.md:823–824` | 68–69 |
| 4 | `04-api-contract.md:625` | 80 |
| 5 | `04-api-contract.md:670–671` | 95–96 |
| 6 | `03-operation-lifecycle.md:814–816` | 59–61 |
| 7 | `04-api-contract.md:632–633` | 87–88 |

`.beads/issues.jsonl:101`, pv-kv2, comment id860: replace only the decoded comment's corresponding substrings and authority line6. The master and H comments match. Preserve raw JSONL bytes outside that one text value, all other fields/comments/rows/order, and closed status. Re-resolve row/comment identity after any rebase; do not rewrite the JSONL wholesale.

`docs/research/panels-2026-10/r83/r83b/Q4-D.md`: replace no original line. Preserve existing lines1–125 including Panel O's L-NOTE, all7688 bytes, SHA-256 `b1a08789423da142a4bb0d2d87cdb92fe813c7460f80e545101bc74c20171682`, as an exact prefix. Append the matching dated note below: leading blank126, heading127, final line207. The original6606-byte D prefix is also unchanged. The appendix's reviewed r95 record dependency must land: archive `docs/research/panels-2026-10/r95/notes.md` and the reviewed settlement/record so `../../r95/notes.md` resolves. No metadata rewrite to evade that requirement; Panel O's settled record stays unchanged.

`10-conformance-checklist.md` has no wording change. The prospective copy and empty diff independently demonstrate this.

## Exact substring replacement 1

Old:

```text
Settle failed with full commitment
release and no setup-fee or first-unit debit under OPS-11's pre-step-9 create rule.
```

New, exactly:

```text
Settle failed with full commitment
release and no setup-fee or first-unit debit under OPS-11's pre-step-9 create rule; OPS-11 says "Any create failure the worker records before any step-9 request (before any per-order key upload or order request) MUST settle `failed`, whatever its kind." and “The commitment is released in full under `LDG-32` ("A commitment MUST be closed, and its remaining amount released in full") and `LDG-39` ("**Never debited**; released with the commitment (`LDG-32`)"), with no setup-fee or first-unit debit.”.
```

## Exact substring replacement 2

Old:

```text
on both error and operation view, then settle failed under OPS-11's pre-step-9 rule with full
release and no setup-fee or first-unit debit.
```

New, exactly:

```text
on both error and operation view, then settle failed under OPS-11's pre-step-9 rule with full
release and no setup-fee or first-unit debit; OPS-11 says "Any create failure the worker records before any step-9 request (before any per-order key upload or order request) MUST settle `failed`, whatever its kind." and “The commitment is released in full under `LDG-32` ("A commitment MUST be closed, and its remaining amount released in full") and `LDG-39` ("**Never debited**; released with the commitment (`LDG-32`)"), with no setup-fee or first-unit debit.”.
```

## Exact substring replacement 3

Old:

```text
worker's recorded failure under the same pre-step-9 rule; do not add a null-column term to
the settlement guard.
```

New, exactly:

```text
worker's recorded failure under the same pre-step-9 rule; do not add a null-column term to
the settlement guard; OPS-11 says "Any create failure the worker records before any step-9 request (before any per-order key upload or order request) MUST settle `failed`, whatever its kind." and “The settle write keeps the ordinary worker guard (`STO-3`; `OPS-6`: "every write that worker makes to the operation MUST carry `claim_number = mine`"), with no `about_to_order_at IS NULL` term.”.
```

## Exact substring replacement 4

Old:

```text
abandoned mid-order; its machine follows OPS-27's suspended-attach cancellation.
```

New, exactly:

```text
abandoned mid-order; its machine follows OPS-27's suspended-attach cancellation; OPS-27 says "**Where the machine's tenant is suspended at the moment of the attach, that same transaction also
enqueues a system cancellation** — `requested_by: system`, `system_reason: tenant_suspended`, under
the machine's `delete` episode, opening it or adding the reason to an episode this same transaction
opened (`OPS-39`, `OPS-48`) — the identical mechanism `API-58` step (3) uses on the fan-out and the
identical attach-then-route shape as `OPS-36`. This applies at **all three** entry points. It is needed
because `API-58`'s re-sweep stops once a pass finds no un-cancelled machine, and a create that has
not yet produced a machine passes that test: the parent settles `succeeded` — counting a
`needs_reconciliation` child as complete — and no later pass will ever look again. Without it, a
create resolving *observed* after that settlement attaches a funded, billing machine to a suspended
tenant and runs its whole runway, which is precisely the outcome `SEC-45`'s one-action suspension
must not depend on a human noticing. `OPS-36`'s attach-then-cancel does not cover it: that branch fires only
where `OPS-33` had already released the commitment, and here the commitment is still open and
becomes the machine's running commitment.".
```

## Exact substring replacement 5

Old:

```text
Orders already potentially dispatched retain OPS-27's attach and suspended-tenant cancellation
path, including later evidence-based attachment after the suspension parent has settled.
```

New, exactly:

```text
Orders already potentially dispatched retain OPS-27's attach and suspended-tenant cancellation
path, including later evidence-based attachment after the suspension parent has settled; OPS-27 says "**Where the machine's tenant is suspended at the moment of the attach, that same transaction also
enqueues a system cancellation** — `requested_by: system`, `system_reason: tenant_suspended`, under
the machine's `delete` episode, opening it or adding the reason to an episode this same transaction
opened (`OPS-39`, `OPS-48`) — the identical mechanism `API-58` step (3) uses on the fan-out and the
identical attach-then-route shape as `OPS-36`. This applies at **all three** entry points. It is needed
because `API-58`'s re-sweep stops once a pass finds no un-cancelled machine, and a create that has
not yet produced a machine passes that test: the parent settles `succeeded` — counting a
`needs_reconciliation` child as complete — and no later pass will ever look again. Without it, a
create resolving *observed* after that settlement attaches a funded, billing machine to a suspended
tenant and runs its whole runway, which is precisely the outcome `SEC-45`'s one-action suspension
must not depend on a human noticing. `OPS-36`'s attach-then-cancel does not cover it: that branch fires only
where `OPS-33` had already released the commitment, and here the commitment is still open and
becomes the machine's running commitment.".
```

## Exact substring replacement 6

Old:

```text
This write and API-58's admission-time suspension flag write
MUST contend on that same row; a plain read or a lock confined to the earlier claim-time check
is not a substitute.
```

New, exactly:

```text
This write and API-58's admission-time suspension flag write
MUST contend on that same row; a plain read or a lock confined to the earlier claim-time check
is not a substitute; API-58 says "marks the tenant `suspended` **in the admission transaction, before the `202` is returned**".
```

## Exact substring replacement 7

Old:

```text
OPS-11 says "Any create failure the worker records before any step-9 request (before any
per-order key upload or order request) MUST settle `failed`, whatever its kind."
```

New, exactly:

```text
OPS-11 says "Any create failure the worker records before any step-9 request (before any per-order key upload or order request) MUST settle `failed`, whatever its kind."
```

## Exact Agent Brief authority-line replacement

Old (decoded line6):

```text
**Owner decision:** “D: explain exception” (`owner-decisions-1030.md`, item 19). Historical adopted form: `docs/research/panels-2026-10/r83/r83b/Q4-D.md`. Executable form: the Desired behavior / key interfaces and Acceptance criteria blocks below, with the 2026-10-31 Panel O r94 wording correction.
```

New, exactly:

```text
**Owner decision:** “D: explain exception” (`owner-decisions-1030.md`, item 19). Historical adopted form: `docs/research/panels-2026-10/r83/r83b/Q4-D.md`. Executable form: the Desired behavior / key interfaces and Acceptance criteria blocks below, with the 2026-10-31 Panel O r94 wording correction and the 2026-11-02 Panel P r95 wording correction.
```

## Complete settled executable package

The following is the supplied reviewed Q-QUOTE package, byte-for-byte; its historical insertion instructions identify the package homes. Apply only the substring targets above to the already-landed text. Its SHA-256 is `81c6937e4d0f5fbf112bd68e8d2da908adb94cdf3c2fa626af38fcb1d52b648b`. The assertion audit refers to the numbered items in this exact package.

**Complete alternative Q4-D — preferred and ACCEPT.** All unspecified pinned text remains unchanged.

1. In OPS-43 step 1, after the account-status refusal paragraph and before step 2, insert:

```text
Next read this operation's tenant status. Where the tenant is suspended, fail this existing
create with conflict, details.reason: "tenant_suspended", and retryable: false on both the error
and operation view. This read precedes channel closure and boundary validation. Make no provider
request, including List offers or a per-order key upload. Settle failed with full commitment
release and no setup-fee or first-unit debit under OPS-11's pre-step-9 create rule; OPS-11 says "Any create failure the worker records before any step-9 request (before any per-order key upload or order request) MUST settle `failed`, whatever its kind." and “The commitment is released in full under `LDG-32` ("A commitment MUST be closed, and its remaining amount released in full") and `LDG-39` ("**Never debited**; released with the commitment (`LDG-32`)"), with no setup-fee or first-unit debit.”. Preserve
requested_by and system_reason as originally recorded; do not emit the admission-only kind
suspended. This is a plain read; the dispatch guard below closes the race after it.
```

2. In OPS-43 step 8, after the STO-47 conditional-write check and before the operations-row write, insert:

```text
In this same transaction the worker MUST conditional-write the operation's tenants row guarded
on its status not being suspended. This write and API-58's admission-time suspension flag write
MUST contend on that same row; a plain read or a lock confined to the earlier claim-time check
is not a substitute; API-58 says "marks the tenant `suspended` **in the admission transaction, before the `202` is returned**". Where the tenant guard affects no row because suspension won, roll back
the step-8 transaction and record conflict, details.reason: "tenant_suspended", retryable: false
on both error and operation view, then settle failed under OPS-11's pre-step-9 rule with full
release and no setup-fee or first-unit debit; OPS-11 says "Any create failure the worker records before any step-9 request (before any per-order key upload or order request) MUST settle `failed`, whatever its kind." and “The commitment is released in full under `LDG-32` ("A commitment MUST be closed, and its remaining amount released in full") and `LDG-39` ("**Never debited**; released with the commitment (`LDG-32`)"), with no setup-fee or first-unit debit.”. No step-9 key upload or order may begin. A first
failed transaction commits neither about_to_order_at nor a correlator. A whole-transaction
repeat after a lost acknowledgement rechecks this guard too: if suspension now defeats it,
keep any previously committed about_to_order_at and correlator unchanged and settle the
worker's recorded failure under the same pre-step-9 rule; do not add a null-column term to
the settlement guard; OPS-11 says "Any create failure the worker records before any step-9 request (before any per-order key upload or order request) MUST settle `failed`, whatever its kind." and “The settle write keeps the ordinary worker guard (`STO-3`; `OPS-6`: "every write that worker makes to the operation MUST carry `claim_number = mine`"), with no `about_to_order_at IS NULL` term.”. OPS-49 says "the component MUST repeat the **whole
transaction** — never the last failed statement, and never the provider call (`OPS-12`)" and "A
  serialization failure is repeated at once."; retry a serialization failure as a whole transaction and do not treat it as a tenant-status refusal. The operation-row claim guard and acknowledgement-before-
step-9 rules remain required.
```

3. In API-58 step (2), replace the complete span beginning `**fences work already in flight**` and ending `unrecorded and unbilled —`, immediately before `then (3)`, with:

```text
**fences work already in flight** — a create that passed OPS-43's tenant dispatch guard before
the suspension landed is potentially dispatched and MUST be allowed to settle rather than
abandoned mid-order; its machine follows OPS-27's suspended-attach cancellation; OPS-27 says "**Where the machine's tenant is suspended at the moment of the attach, that same transaction also
enqueues a system cancellation** — `requested_by: system`, `system_reason: tenant_suspended`, under
the machine's `delete` episode, opening it or adding the reason to an episode this same transaction
opened (`OPS-39`, `OPS-48`) — the identical mechanism `API-58` step (3) uses on the fan-out and the
identical attach-then-route shape as `OPS-36`. This applies at **all three** entry points. It is needed
because `API-58`'s re-sweep stops once a pass finds no un-cancelled machine, and a create that has
not yet produced a machine passes that test: the parent settles `succeeded` — counting a
`needs_reconciliation` child as complete — and no later pass will ever look again. Without it, a
create resolving *observed* after that settlement attaches a funded, billing machine to a suspended
tenant and runs its whole runway, which is precisely the outcome `SEC-45`'s one-action suspension
must not depend on a human noticing. `OPS-36`'s attach-then-cancel does not cover it: that branch fires only
where `OPS-33` had already released the commitment, and here the commitment is still open and
becomes the machine's running commitment.". A claim by
itself does not authorize purchase: a create that first reads the tenant suspended fails under
OPS-43, and suspension winning the step-8 tenant guard also prevents purchase. A create past
the guard can still be between the acknowledged transaction and its provider call, because
OPS-43 says "Step 9 MUST begin only after step 8's transaction is acknowledged."; treat that residue as the potentially dispatched
case. Never fail or release such an uncertain order through the never-claimed administrative
write. This does not override a deterministic failure the worker actually records before step 9:
OPS-11 says "Any create failure the worker records before any step-9 request (before any per-order key upload or order request) MUST settle `failed`, whatever its kind." —
```

4. In API-58, immediately before “A create that has produced no machine yet”, insert:

```text
For the claimed create's tenant-status read, refusal and dispatch race guard, see OPS-43.
Orders already potentially dispatched retain OPS-27's attach and suspended-tenant cancellation
path, including later evidence-based attachment after the suspension parent has settled; OPS-27 says "**Where the machine's tenant is suspended at the moment of the attach, that same transaction also
enqueues a system cancellation** — `requested_by: system`, `system_reason: tenant_suspended`, under
the machine's `delete` episode, opening it or adding the reason to an episode this same transaction
opened (`OPS-39`, `OPS-48`) — the identical mechanism `API-58` step (3) uses on the fan-out and the
identical attach-then-route shape as `OPS-36`. This applies at **all three** entry points. It is needed
because `API-58`'s re-sweep stops once a pass finds no un-cancelled machine, and a create that has
not yet produced a machine passes that test: the parent settles `succeeded` — counting a
`needs_reconciliation` child as complete — and no later pass will ever look again. Without it, a
create resolving *observed* after that settlement attaches a funded, billing machine to a suspended
tenant and runs its whole runway, which is precisely the outcome `SEC-45`'s one-action suspension
must not depend on a human noticing. `OPS-36`'s attach-then-cancel does not cover it: that branch fires only
where `OPS-33` had already released the commitment, and here the commitment is still open and
becomes the machine's running commitment.".
```

5. In API-58, replace the complete bold suspension-promise sentence and its following sentence, beginning `**A suspension is not a promise` and ending `on this one branch it is not.`, at pinned lines 731–734, with:

```text
**A suspension is not a promise that the fleet is gone. It stops new purchase authorization
at OPS-43's tenant dispatch guard and accounts for every machine, including machines produced
by orders already potentially dispatched.** The terms and operator documentation MUST explain
that an order authorized for dispatch before suspension may still reach the provider and
complete afterwards, and that its resulting machine is subject to cancellation. They MUST NOT
promise that suspension recalls such an order or that cancellation has already succeeded.
```


**Acceptance criteria:**

6. In CNF-202, after the additional Q1 store cases if adopted, otherwise before its amendment note, append:

```text
Independently admit an otherwise valid create while the tenant is active, with a healthy provider
account and open ordering channel. Keep it unclaimed, commit suspension, then let a worker claim
the create before the suspension fan-out can fail it. Assert failed, conflict with
details.reason: "tenant_suspended", retryable: false on both error and operation view, no provider
request, no purchase or setup-fee/first-unit debit, full commitment release, original origin
stamp, and no admission-only suspended error.

Separately let the worker's early tenant read see active, then commit suspension before the
step-8 tenant guard. Assert the same refusal, allowing only preceding non-mutating reads,
no step-9 request, and no first-transaction about_to_order_at or correlator commit. Race the
tenant dispatch guard against suspension in both orders. Where the guard wins and its transaction
commits and is acknowledged, suspend before the provider call and assert the attempt is treated
as potentially dispatched and allowed to settle, with a system cancellation in the machine's
attach transaction if the tenant remains suspended. Exercise late evidence attachment after
the suspension parent has settled as well.

Lose step 8's acknowledgement, suspend before the whole-transaction repeat, and assert
deterministic pre-step-9 failure, unchanged previously committed about_to_order_at and correlator,
full release and no speculative dispatch. Retain the worker claim guard in every settlement.
Run these barriers on auction and standard-channel (correlator: none) descriptors and on a
provider using per-order temporary keys.

Independently combine an unhealthy provider account with a suspended tenant and assert the
account-status refusal wins. Combine a healthy account, suspended tenant and closed ordering
channel and assert tenant_suspended wins. Assert no provider request in either case.
```



## Exact dated archive appendix

The outer fence contains the complete reviewed appendix, including its leading LF and final newline. SHA-256 `0b07135f64edafa09a0a3fd96e25828bbc618bff4eea4c00b2355d1b6a67bd85`.

````text

## Wording correction — 2026-11-02 (Panel P r95)

The text above, including Panel O’s 2026-10-31 appendix, is retained as the historical record.
The pv-kv2 specification and executable Agent Brief use the following additional replacements
under the owner’s 2026-10-28 wording rule; all other text is retained.

Replacement 1, for the matching executable passage (including Panel O’s substitution where applicable):

```text
Settle failed with full commitment
release and no setup-fee or first-unit debit under OPS-11's pre-step-9 create rule; OPS-11 says "Any create failure the worker records before any step-9 request (before any per-order key upload or order request) MUST settle `failed`, whatever its kind." and “The commitment is released in full under `LDG-32` ("A commitment MUST be closed, and its remaining amount released in full") and `LDG-39` ("**Never debited**; released with the commitment (`LDG-32`)"), with no setup-fee or first-unit debit.”.
```

Replacement 2, for the matching executable passage (including Panel O’s substitution where applicable):

```text
on both error and operation view, then settle failed under OPS-11's pre-step-9 rule with full
release and no setup-fee or first-unit debit; OPS-11 says "Any create failure the worker records before any step-9 request (before any per-order key upload or order request) MUST settle `failed`, whatever its kind." and “The commitment is released in full under `LDG-32` ("A commitment MUST be closed, and its remaining amount released in full") and `LDG-39` ("**Never debited**; released with the commitment (`LDG-32`)"), with no setup-fee or first-unit debit.”.
```

Replacement 3, for the matching executable passage (including Panel O’s substitution where applicable):

```text
worker's recorded failure under the same pre-step-9 rule; do not add a null-column term to
the settlement guard; OPS-11 says "Any create failure the worker records before any step-9 request (before any per-order key upload or order request) MUST settle `failed`, whatever its kind." and “The settle write keeps the ordinary worker guard (`STO-3`; `OPS-6`: "every write that worker makes to the operation MUST carry `claim_number = mine`"), with no `about_to_order_at IS NULL` term.”.
```

Replacement 4, for the matching executable passage (including Panel O’s substitution where applicable):

```text
abandoned mid-order; its machine follows OPS-27's suspended-attach cancellation; OPS-27 says "**Where the machine's tenant is suspended at the moment of the attach, that same transaction also
enqueues a system cancellation** — `requested_by: system`, `system_reason: tenant_suspended`, under
the machine's `delete` episode, opening it or adding the reason to an episode this same transaction
opened (`OPS-39`, `OPS-48`) — the identical mechanism `API-58` step (3) uses on the fan-out and the
identical attach-then-route shape as `OPS-36`. This applies at **all three** entry points. It is needed
because `API-58`'s re-sweep stops once a pass finds no un-cancelled machine, and a create that has
not yet produced a machine passes that test: the parent settles `succeeded` — counting a
`needs_reconciliation` child as complete — and no later pass will ever look again. Without it, a
create resolving *observed* after that settlement attaches a funded, billing machine to a suspended
tenant and runs its whole runway, which is precisely the outcome `SEC-45`'s one-action suspension
must not depend on a human noticing. `OPS-36`'s attach-then-cancel does not cover it: that branch fires only
where `OPS-33` had already released the commitment, and here the commitment is still open and
becomes the machine's running commitment.".
```

Replacement 5, for the matching executable passage (including Panel O’s substitution where applicable):

```text
Orders already potentially dispatched retain OPS-27's attach and suspended-tenant cancellation
path, including later evidence-based attachment after the suspension parent has settled; OPS-27 says "**Where the machine's tenant is suspended at the moment of the attach, that same transaction also
enqueues a system cancellation** — `requested_by: system`, `system_reason: tenant_suspended`, under
the machine's `delete` episode, opening it or adding the reason to an episode this same transaction
opened (`OPS-39`, `OPS-48`) — the identical mechanism `API-58` step (3) uses on the fan-out and the
identical attach-then-route shape as `OPS-36`. This applies at **all three** entry points. It is needed
because `API-58`'s re-sweep stops once a pass finds no un-cancelled machine, and a create that has
not yet produced a machine passes that test: the parent settles `succeeded` — counting a
`needs_reconciliation` child as complete — and no later pass will ever look again. Without it, a
create resolving *observed* after that settlement attaches a funded, billing machine to a suspended
tenant and runs its whole runway, which is precisely the outcome `SEC-45`'s one-action suspension
must not depend on a human noticing. `OPS-36`'s attach-then-cancel does not cover it: that branch fires only
where `OPS-33` had already released the commitment, and here the commitment is still open and
becomes the machine's running commitment.".
```

Replacement 6, for the matching executable passage (including Panel O’s substitution where applicable):

```text
This write and API-58's admission-time suspension flag write
MUST contend on that same row; a plain read or a lock confined to the earlier claim-time check
is not a substitute; API-58 says "marks the tenant `suspended` **in the admission transaction, before the `202` is returned**".
```

Replacement 7, for the matching executable passage (including Panel O’s substitution where applicable):

```text
OPS-11 says "Any create failure the worker records before any step-9 request (before any per-order key upload or order request) MUST settle `failed`, whatever its kind."
```

Source pin: `6a3b6014f1f8b36fc21b902e507e74d8c5264e99`.
Review head: `96a72898c7ace67790aec0bab3727eee858e2245`.
Panel record: `../../r95/notes.md`.
````

## Prospective files and validation limits

Every file below is constructed from H's bytes with only these exact substitutions. Each has a matching `.diff` against H; the brief diff compares decoded comment860. The archive diff appends only. Recovery by reversing the tracked substitutions reproduces H byte-for-byte. These are local review artifacts, not edits to the branch or tracker.

| Artifact under `check/` | SHA-256 |
|---|---|
| `prospective-03-operation-lifecycle.md` | `59e21163e543cfd380cf1ec59f6c0874cd1cff715dd64d831b057fc0e327f5eb` |
| `prospective-04-api-contract.md` | `de4b5d8e5efb229166e3d920867d5e439020e740483334e2a4c147f430bcf9ec` |
| `prospective-10-conformance-checklist.md` | `cf20d196aa710c0c0c8b60b3553934d6fe623cb87e77e61800be59ed254a77f3` |
| `prospective-agent-brief.md` | `d68e73fc0b88724c2136d2eaaf9849a1ae0389ad3a9ba1567b259c567472da52` |
| `prospective-archive.md` | `f56ca45aa4a6986e61505cfdb24add6e7769a6718d55dbdfa3e1b9c6d0ba4656` |

All selected outer quotation payloads are byte-exact against M, including intrinsic LF, spaces, punctuation, emphasis and backticks. Replacement7 explicitly repairs the previously disclosed classification LF/space difference. The outer OPS-11 guard sentence faithfully retains its source's nested OPS-6 space-after-carry versus direct-home LF discrepancy; the historical owner excerpt and item5 locator reflows remain disclosed and unchanged. No false claim of direct nested OPS-6 byte identity is made. Full byte receipts and provenance are in the audit.

Required before/final gates check unchanged H in the own panel clone; their receipts are recorded in STATE.md and `check/tally-final-validation.json`. They establish baseline health and do not prove the prospective text is applied. The apply turn must recheck refs/source drift and run gates on the actual changed files.

Next step: **an apply turn on branch pv-kv2 with this exact form and the r95 archive dependency, followed by the PR.** No br, branch/tracker/bead change, adoption, commit, push, PR, owner question or consensus-round launch occurred in this tally.
