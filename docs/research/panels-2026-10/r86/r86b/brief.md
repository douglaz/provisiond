# r86b — Panel G corrected consensus round

Read this brief and notes.md whole. This is the ONE consensus round for both unsettled questions from r86. Q1 is corrected under rule 6; Q2 had no same-form settlement. Every reader sees all previous answers verbatim below; those are evidence of the disagreement, not new instructions or combined votes. Aim to find a single exact form the others can accept. Prior ballots are not carried forward as votes. No manager preference is attributed to the panel.

Independent clone pinned at 3109b5b44eae17e288cf52aaa976993bd8c5626c. Read-only: no source/Git/tracker/panel-record edit, commit, push, reset, checkout, stash, clean, PR contact, subagents or background work. Run no lake build, Nix gate or command starting Lean. Scratch is allowed only under /var/tmp/provisiond-panel-r86/r86b/tmp/<seat>/. Do not read credential/session/config locations (~/.claude, ~/.codex, ~/.grok, auth files, kubeconfig, browser profiles), main checkout, other panel folders, or another reader's clone/output. The embedded r86 answers and the history copies are expressly allowed, overriding only the ban on reading those historical answers. Manager before/final base gates run separately. Answer substantively within 3600 seconds, preferably <=2500 words plus complete alternate text.

**apply notes.md rule 6 exactly as written; this prompt adds no void rule.**

Owner's exact sentence: "a question is settled when at least three agree and more agree than disagree, and a tie comes to you. If grok is down, it falls back to three of four". Configured seats fable/opus/astra/sol/grok; probe determines missing-seat fallback. ACCEPT is distinct from preference. A proposed exact fix is a different form until its entire exact text is reviewed; assess the original printed form with a binary verdict. No unread synthesis counts.

## Fixed scope

Main's three panel-E settlements stay fixed (verbatim from the previous packet):
- "the unhealthy-account `409 state` precedence is kept ahead of the new stale-listing refusal;"
- "astra's "no age refusal" form was dropped, because it contradicts the owner's stored-listing age setting;"
- "the Form H checklist header default replaced per-item fixture amendments (accepted 4–0)."

Admission uses the stored listing without a provider call. No collected-refusal rank or age precedence is reopened. Status/closure, caller-field validation, api-written-field validation, ordering capability and list_offers keep the pinned create ordering except the explicitly proposed source/absence amendment. Runtime, formal-declaration, guard-hypothesis, fixture, negative-control and normative changes are substantive. A comment edit does not by itself prove unchanged semantics. Never insert a CNF identifier in formal files.

## What the initial round found

Q1 raw preferences fable A / opus A / astra B / sol A, with all accepting A, are VOID under existing rule 6 because the omitted OVR-2 changes the premise. Q2 preferences fable A-prime / opus A / astra B / sol B do not settle a single exact form. These are historical tallies only. The complete answers below carry every reader's arguments and conditions.

Q1 correction: OVR-2, 00-overview.md:22–24 at the pin:

````text
**OVR-2** Capability MUST be discoverable at runtime (`GET /v1/providers`). Clients
MUST NOT be required to infer support from a provider's name, and the server MUST NOT
accept an operation a provider has not declared support for. See `DOM-10`.
````

OPS-1, 03-operation-lifecycle.md:17–18:

````text
**OPS-1** Every mutating request MUST create or return a durable operation record before
any provider call is made, and MUST respond `202 Accepted` with that record.
````

A valid unsupported hard reset admitted as an operation then failed by the worker is the concrete conflict. Original B expressly enqueues it; the earlier story and C rationale falsely treated this as open latitude. B's complete text is retained to review that conflict, not to authorize an OVR-2 weakening. Corrected C0 is literal no edit preserving OVR-2, without claiming phase freedom. Is A's detailed placement/ordering needed, or is the existing obligation sufficient? For A's API-64 path, resolve whether its printed "after ... admissibility checks" can coexist deterministically with admissibility's guarded write before the first enqueue/state write. An unresolved implementation concern is not a vote condition unless you say so.

Astra's funded null-fence retry trace is real as an A/B difference, but B's new request still faces OVR-2. Distinguish admission of a new request from a previously accepted/system-enqueued attempt's no-call success. Preserve restore deferral, funded/gone no-call success, the cancellation fence, PTR capability-before-equality, install markers and survived-stop classification. The base already forbids replacing those MUST outcomes; original brief language suggesting otherwise was wrong. New local error precedence is an amendment, not proven universal old behavior.

Q2 exact disagreements to resolve:
1. Fable applied original A/B in scratch and their removed API-7 wording breaks Lean docstring citations. A-prime repairs those docstrings; the two cited forms below additionally restore selected OPS-43 quotations. Original and repaired exact forms have separate ballots. No full candidate Lean build is claimed.
2. Astra/sol trace orderingDeclared=false, no listing/unsellable, otherwise early checks pass: existing createPurchaseTail/createAdmission yields early unsupported at every age. A instead skips selection for absence and collects the tail. The model docstring says the Boolean means declaration of the create's capability and separately excludes machine-kind selection from its scope. Does A-prime/A-cited's true-for-absence documentation change a formalized obligation or lawfully define the previously outside-model selection? Read the theorem before weakening anything. A failed proof may not be cleared by silently changing a hypothesis or the meaning of the input. If a substantive declaration amendment is necessary, neither printed comment-only repair contains it; say so and provide a complete exact alternative if you can. Do not merely assert either the formal objection or its dismissal.
3. Fable/opus trace B's descriptor virtual/only provision_virtual, live/stored offer bare_metal, and gates that pass without provision_bare_metal. That offer violates B's new "Every offer returned ... MUST have that machine kind" duty. Decide explicitly whether this is outside the conforming input contract or a remaining breach of DOM-10's independently required outer gate; do not call the violating driver conforming. B also requires before-enable mixed-account rejection and retained-identity immutability without naming detection/history mechanisms. Describe capabilities has no network I/O; STO-21 names operational state but supplies no existing machine-kind-history record. Is the printed contract implementable/testable as specified, or incomplete? A missing new runtime assertion alone is not rule-3 proof.
4. Accept B's domain/configuration cost deliberately, or A's absent-offer precedence/formal cost explicitly; launch-driver homogeneity proves neither choice. Retained A kind, live mismatch, corrupt/missing fields, no-List-offers withdrawal, collected refusal ranks and old-listing behavior must be checked.

## Pinned source evidence

### Pinned evidence for Q1

`01-domain-model.md:515–542` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`:

````text
**DOM-10** Every operation with a capability MUST be gated on it before the
driver is called, **including create**; the driver methods with no capability entry are the ones
`PRV-4` names. There MUST be no operation whose only gate is
a driver-internal check. A capability check failure MUST return an "unsupported" error
naming the provider account and the capability, with `retryable: false` on both the error and the operation view where there is one.

Mapping from operation to required capability:

| Operation | Required capability |
|---|---|
| create machine, `kind = virtual` | `provision_virtual` |
| create machine, `kind = bare_metal` | `provision_bare_metal` |
| refresh | none — every driver MUST implement machine lookup |
| power on/off/reboot | `power_control` |
| hard reset | `hard_reset` |
| install, `provider_native` + `catalog` | `native_rebuild` |
| list offers | `list_offers` |
| rescue inventory | `rescue_ssh` (`RSC-38` boots rescue to read the inventory) |
| install, `rootfs_via_rescue` | `install_rootfs_via_rescue` |
| install, `raw_disk` | `install_raw_disk_via_rescue` |
| install, `provider_catalogue` | `install_via_provider_catalogue` |
| reverse DNS | `reverse_dns` |
| delete | `delete_machine` |
| release attachment | `delete_machine` — a driver that can delete a machine can release what it left behind (`PRV-45`) |

*Amended 2026-10-22 (`pv-009`, `pv-p3k`; panel r62, `docs/research/panels-2026-10/r62/`; owner decision 2026-10-22): every capability check failure carries `retryable: false`, which is how the `pv-p3k` ruling "MUST, not retryable" reaches `API-7`'s step 5d and `OPS-43`'s claim-time gates.*

**DOM-22** Three edits to the capability model on 2026-08-12, closing the rest of `F10`:
````
`04-api-contract.md:232–258` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`:

````text
    anything is enqueued.
    **The exemptions are these, and no others.** `OPS-39` exempts exposure-reducing **system**
    cancellations, because a tenant that hit its destruction limit would otherwise keep machines it
    cannot pay for at the operator's expense — though that sweep enqueues directly and never
    traverses this pipeline, so the exemption bites here only on the other one: `SEC-39`'s stated
    override path for a genuine incident is the operator's, recorded as the uncapped thing.
    **`API-64`'s retry is not exempt**: it counts against `SEC-39`'s operator retry ceiling, and
    the operator is a program (`SEC-39`), so a loop retrying a deterministic rejection is exactly
    what the ceiling is for (`ADR-0017`).
5d. **gate a create on its ordering capability** under `DOM-10` (`PRV-10`, `DOM-16`). A refusal stops here and is not collected by the tail.

The tail then depends on what the endpoint does:

| Class | Tail |
|---|---|
| **create** | evaluate the rich purchase tail below; on admission, commitment + operation in one transaction (`LDG-11`, `LDG-35`), then `202` |
| **power, install, reverse-DNS, refresh, rescue inventory** | enqueue an operation, then `202`. **No commitment**: they are not purchases, and they pass no spending gate |
| **retry** | operator-only (`API-64`, `WIR-51`); synchronous, `200` with the episode view; the episode's state change, the enqueue of a fresh `delete_machine` attempt and the idempotency record commit in one transaction (`WIR-24`); **no commitment and no spending gate** — the attempt reduces exposure, on the delete row's reasoning |
| **suspend** | operator-only; enqueue one cancellation per machine, then `202` (`API-58`) |
| **release attachment** | operator-only (`API-65`, `WIR-52`); on an `api` row enqueue one `release_attachment`, then `202`; on a `manual` row synchronous `200`, writing `released_at` (`API-48`); **no commitment and no spending gate** — it reduces exposure, on the delete row's reasoning |
| **revoke** | operator or recovery-credential principal (`API-56`, `WIR-38`); synchronous, `200`, no provider mutation (`API-48`) |
| **keep** (*added 2026-10-04, `pv-gip.11`*) | operator-only, synchronous `200` (`API-68`, `WIR-55`); **no commitment and no spending gate**; admission follows this pipeline, with no retry-ceiling treatment |
| **resume, resolve** | **operator-only** (`WIR-41`, `WIR-35`, `WIR-34`); synchronous, `200`, no provider mutation (`API-48`). The recovery credential reaches **neither** — `API-55` confines it to `API-56`, and a recovered-after-theft credential that could resume its own tenant or resolve an uncertain provider mutation would undo the suspension that answered the theft |
| **delete, cancel** | enqueue an operation, then `202`, and **bypass the rate and solvency gates entirely** — these reduce exposure, and refusing them because exposure is too high is the failure `LDG-20` already forbids |
| **deposit** | synchronous; allowed while pending; **refused `halted` while `LDG-20`'s solvency halt is in force** — that halt stops top-ups *first*, and minting a destination invites exactly the payment it forbids; otherwise **mints a destination and writes NO ledger entry** — a deposit is not money until it settles (`LDG-47`) — plus an idempotency record, in one transaction; `200` |
| **extend-runway** | evaluate the rich purchase tail below; on admission, the guarded extension (`LDG-62`) and idempotency record commit together (`WIR-24`); synchronous `200` |
| **abuse-case writes** | the tenant's statement (`WIR-43`) and the operator's five verbs (`API-60`, `API-61`) — synchronous, **no commitment, no spending gate, no provider mutation**; `201` on create and on a statement, `200` on the rest; each carries `Idempotency-Key` under `WIR-24`'s one-transaction rule. The statement write is a maintenance action and stays reachable while suspended (step 5b) |
````
`03-operation-lifecycle.md:2018–2051` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`:

````text
**OPS-23** Validation that was performed at the API boundary MUST be repeated in the
worker before the driver is called. The record may have been written by an older version
of the service, or edited in the store. Validation is cheap; a wrong install is not. **A field a
previous-release `api` may not have written is a deterministic failure in the worker, never a
passed check** (added 2026-09-12, `ADR-0024`): a create admitted without `OPS-43`'s accepted-price
fields fails before dispatch rather than dispatching at whatever the offer says now.

For create, install, power and delete, a missing required field MUST fail as follows:

- A field the `api` itself writes when it admits the operation fails `conflict`, with
  `details.reason: "incomplete_record"` and `retryable: true` on both the error and the operation
  view. The accepted-price fields above are such fields; the worker-written correlator is not.
- A field the caller must supply fails `invalid_request` naming the field, with
  `retryable: false` on both the error and the operation view.

A field that is present but fails this repeated validation fails as its writer's bullet above says, on both the error and the operation view, and settles as these missing-field failures do.

These missing-field failures settle `failed` under `OPS-11`. On a create they come at `OPS-43`'s
step 3, and `OPS-11` says "Any create failure the worker records before any step-9 request (before any per-order key upload or order request) MUST settle `failed`, whatever its kind."
Power and delete take its last row's "any failure the worker records while `OPS-45`'s write-started marker
is unset", and its install row gives `failed`
"for any failure at all while `OPS-45`'s two markers say the disk is untouched and no rescue
session was left open". On a create, the commitment is
released in full under `LDG-39`'s "Deterministic rejection before acceptance" case, whose fee
and first-unit outcome is "**Never debited**; released with the commitment (`LDG-32`)".
Install, power and delete release no commitment here. On an install, these checks MUST run
before either `OPS-45` marker is written: its rescue marker is "**false, written before begin
rescue (`PRV-15`) is dispatched**". The install settles `failed` with `disk_effect: "none"`
and `rescue_exit: "none"` (`WIR-9a`: "`none` where this operation is established to have written
nothing to the target disk" and "`none` only where no rescue session was opened"). A release
that adds a required field MUST state whether the caller supplies it or the `api` writes it
at admission.

The worker's claim-time absence check and sale re-test at `OPS-43`'s step 5, "Check for the named
````
`03-operation-lifecycle.md:744–754` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`:

````text
**OPS-40** **A signed image URL is validated against the queue's latency, twice** (`F20`).
`OPS-2` persists a request so it can be executed after restarts and deferrals; `SEC-21` wants the
signed URLs inside it short-lived. The two meet as follows: at **accept**, a request carrying a
signed URL MUST be rejected unless the URL's expiry exceeds the deployment's stated worst-case
admission-to-start bound; at **claim**, a worker MUST fail the operation deterministically —
before any provider mutation and before rescue is entered — if the URL cannot outlive the
install's stated worst-case duration, with an error kind and message telling the caller to
re-submit with a fresh URL. An expiry mid-stream after that gate is an ordinary install failure
under `OPS-11`'s classification. **The gate exists because the alternative is entering rescue and
beginning a destructive write fed by a URL that is already doomed.** No refresh mechanism inside the
record is needed, because the caller re-submits with a fresh URL — which this requirement already
````
`02-provider-contract.md:716–723` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`:

````text

**Input** — `external_id`, and a rescue access request carrying a key name and a
freshly generated single-use public key.
**Output** — a rescue session (`DOM-11`).
**Capability** — `rescue_ssh`.

**PRV-15** Begin rescue MUST both activate the rescue environment *and* initiate the
reboot or reset needed to enter it. The rescue engine waits for SSH; it does not reboot.
````
`02-provider-contract.md:851–858` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`:

````text
**PRV-25** The caller-supplied IP MUST have been verified by the control plane to belong
to the machine before the driver is called (`API-16`). The driver MUST still encode it
into the request path safely (`PRV-6`).

After the ordinary authorization, capability and `API-16` validation, the worker MUST compare
the requested PTR value with the machine's recorded value for that address under `OPS-8`'s
serialization. An identical established value MUST settle `succeeded` without a provider call.
Result shape: `WIR-10`. A missing or unknown value is not equality.
````
`03-operation-lifecycle.md:1076–1111` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`:

````text
reads, never on its claim snapshot.** The order holds for every exposure-reducing cancellation,
whatever reason the attempt was enqueued under, and the first step that applies decides.
Enqueue reason does not substitute for step 2's origin test:

1. **The machine is recorded gone, or its episode is closed.** The worker makes no provider call and
   settles the attempt `succeeded` with a result recording that no mutation was required (`OPS-48`;
   a close is permanent). **It writes no `runway_until`**: the date the no-mutation case above
   writes is a re-derived one, and this step re-derives nothing.
2. **The attempt was enqueued by `API-64` retry and `destroy_committed` already holds its
   episode's id, read in this transaction, or the tenant is suspended now.** The funding
   re-check does not apply and the cancellation proceeds, regardless of the current rate.
   A retry reading the fence null decides from step 3 unless the tenant is suspended now.
   The fence read is the pre-existing value, never a fence this decision just wrote.
   Step 1 and the restore claim gate above remain ahead of this decision. The durable origin
   stamp is specified at `API-64`; the suspension paragraph below governs that exemption.
   *Amended 2026-10-05 (`pv-gip.43`, Q14, `ADR-0032`); supersedes the unconditional
   retry exemption of 2026-10-04.*
3. **A rate exists for the machine's currency** (`LDG-59`). The worker re-derives and applies the
   predicate above **first**. If funded, it performs the no-mutation abort and settlement above,
   including the re-derived date write, fence clearing and episode closure where applicable.
   **Only if the predicate would cancel**, and a restore record is open, its original
   `grace_ends_at` has passed, and the currency has accumulated less than one re-derivation
   interval of rate-present time since step (3), the worker MUST return the attempt to `queued`
   by `OPS-8`'s ordinary short delay. The paused check reads the restore record and currency
   history on this transaction's reads, including the returned rate it sees, never the claim's
   rate snapshot. It writes no new fence, makes no provider call, and neither settles the attempt
   nor closes its episode. Otherwise it proceeds to the existing fence and cancellation path.
   *Amended 2026-10-03 (`ADR-0029`): the paused check moved here from the claim. Withdrawn:
   "After that wall-clock end, while a rate exists and a funding cancellation has unspent grace,
   the claim MUST return the attempt to `queued` with `available_at` equal to
   `now + (one re-derivation interval − accumulated rate-present time)`, the paused end computed
   at this claim." The ordinary short delay replaces that availability.*
4. **There is no rate, and the outage's deadline has not passed** (`LDG-64` holds how the deadline
   is computed). The claim defers: the operation is returned to `queued` by `OPS-8`'s ordinary
   short delay, and no fence is written.
5. **There is no rate, and the deadline has passed.** This is `LDG-64`'s bound. The worker MUST, in
````
`04-api-contract.md:1050–1062` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`:

````text
**API-64** **ADDED 2026-09-08 (`ADR-0017`) — a stalled episode is retried by an operator, and by
nothing else.** `POST /v1/episodes/{id}/actions/retry` (`WIR-51`) is **operator-only** (`WIR-34`)
and is admissible only on an episode in `stalled` (`DOM-31`): it moves the episode to `attempting`
**by a conditional write guarded on `(id, state = stalled)`** and enqueues a fresh `delete_machine`
attempt under it, both in one transaction, and answers `200`
with the episode view. In any other state — including where that write affects no row because a
gone-write closed the episode after the operator read it (`OPS-48`, `ADR-0021`) — it is refused
`409` `conflict` with `details.reason: "state"`. It is idempotent under `WIR-24`'s one-transaction rule — the state change, the enqueue and
the idempotency record commit together — and it counts against `SEC-39`'s operator retry ceiling
(`API-7` step 5c). **A `stalled` episode is never retried by a timer** (`OPS-48`): the attempt
settled `failed` because the provider rejected it and did not act, and repeating a deterministic
rejection automatically is the loop `OPS-39` exists to prevent. *Amended 2026-10-08 (`ADR-0035`):* throttle classification follows `OPS-11`'s
"the operation's mutating request was accepted by the provider" condition, and episode effects
````
`04-api-contract.md:1102–1117` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`:

````text
**API-65** **ADDED 2026-09-08 — the operator's half of `PRV-45`, which had no route.**
`GET /v1/machines/{id}/attachments` (`WIR-52`) is **operator-only** (`WIR-34`) and lists the
machine's `machine_attachments` rows. `POST /v1/machines/{id}/attachments/{attachment_id}/actions/release`
(`WIR-52`) is **operator-only** and admissible only on a row whose `released_at` is null; otherwise
it is refused `409` `conflict` with `details.reason: "state"`. On a row whose `cleanup` is `api` it
enqueues one `release_attachment` operation with `requested_by: operator` and answers `202` with
the operation view — the same kind, and the same driver call, the delete's terminal transaction
enqueues on its own. On a row whose `cleanup` is `manual` there is no driver call to make: it
writes `released_at` and answers `200` with the row, minting no operation, and is in `API-48`'s
list for that reason. A release the delete's terminal transaction enqueues carries the delete's own
`requested_by` and `system_reason`, so `WIR-10a`'s set gains no member for it. The `202` form is
idempotent as any operation is (`API-11`); the `200` form, returning no operation, commits the
`released_at` write and its idempotency record together under `WIR-24`'s one-transaction rule.
For the release's exit write, see `LDG-38`.
`PRV-45`'s `released_at` write is what opens `STO-18`'s tombstone gate; a stored effective date
alone leaves it closed. `LDG-74` owns the later tombstone. *Amended 2026-10-09 (`ADR-0037`, Q14).*
````
`03-operation-lifecycle.md:945–966` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`:

````text
keeps its open episode, and a terminated account's episodes sat `stalled` in `OPS-26`'s listing
forever.*

**Exposure-reducing system cancellations MUST be exempt from `SEC-39`'s per-principal destruction
ceiling.** That ceiling exists to bound what a runaway *caller* can destroy; applying it to the
system's own exhaustion cancels means a tenant that hit its destruction limit keeps running
machines it cannot pay for, with the operator paying. Pacing MAY delay such a cancellation
briefly; nothing may deny it. The wait `OPS-41`'s order gives a cancellation while its machine's
currency has no rate is a delay and not a denial: it ends at the rate's return or at `LDG-64`'s
bound (*added 2026-10-02, `ADR-0029`*).

**System-initiated provider mutations MUST be operations, and the tenant MUST see them.** Exhaustion cancelling a machine (`LDG-14`), `OPS-36`'s attach-then-cancel, and any other
mutation the deployment performs on a tenant's machine without a caller request MUST go through
this queue — the atomic claim (`OPS-5`), per-machine serialization (`OPS-8`), settled states,
`needs_reconciliation` included, because a cancel
whose outcome cannot be established is ambiguous no matter who requested it — and MUST appear in the
tenant's operation list marked `requested_by: system` with a stated reason (`exhausted`,
`late_attach_cleanup`, `tenant_suspended`, `rate_outage_bound`; *`account_lost` was in this list
until 2026-09-05 with nothing that enqueued it — `SEC-46` cancels nothing on an unreachable or
rejected credential and has nothing left to cancel on a termination*). Without this,
`GET /v1/operations` is not the history of
a tenant's fleet, and the hole sits exactly where the most alarming event does: the machine that
````
`03-operation-lifecycle.md:1290–1314` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`:

````text
`failed` does not close the episode**: `failed` is a fact about the attempt, and the episode is
still open, still billing, and waiting on a decision. The transitions are exactly these, keyed on
how the current attempt settled — by the worker, by `OPS-27`'s evidence, or by `OPS-31`/`OPS-45`'s
operator verb — and on the operator verbs on the episode (`API-64`, `API-68`):

<!-- formal: Provisiond.Render.ops48Table -->
| The attempt settled | The episode | `machines.destroy_committed` (the fence, `OPS-42`; exposure-reducing cancellations only) |
|---|---|---|
| `succeeded`, resource gone — including `OPS-11`'s goal-state row | `closed`, `close_reason: resource_gone`, in the terminal transaction | **Cleared**, same transaction |
| `succeeded` recording that no mutation was required (`OPS-41`'s abort) | `closed`, `close_reason: funded`, in the terminal transaction: the condition has ended, and a later lapse opens a fresh episode | **Cleared**, same transaction |
| `succeeded`, **scheduled** — the provider accepted a dated cancellation and the machine remains present (`DOM-19`, `STO-8a`, `PRV-13`) | `scheduled`; the later evidenced gone-write uses the last row, whether before or after the effective date. The date alone does not close it. Tombstoning follows only when `STO-18` permits. | **Unchanged** |
| `failed` — deterministic; the provider did not act | `stalled` | **Unchanged** |
| `needs_reconciliation` | `uncertain`, until the attempt is resolved (`OPS-27`, `OPS-31`) and one of the rows below applies | **Unchanged** |
| Resolved `applied`, the resource gone (`OPS-45`) | `closed`, `close_reason: resource_gone`, in the resolution transaction | **Cleared**, same transaction |
| Resolved `applied` **with an `effective_cancellation_date`** (`WIR-35`) — the operator established the provider *scheduled* it | `scheduled`, as the third row | **Unchanged** |
| Resolved `not_applied` — the machine is still there | `stalled` | **Unchanged** |
| Resolved `abandoned` — nobody established what happened | `closed`, `close_reason: abandoned`, in the resolution transaction | **Cleared**, same transaction, so a later sweep may open a fresh episode and fence again |
| `retry` (`API-64`) on a `stalled` episode | `attempting`, with a fresh attempt enqueued in the same transaction as the state change; admissible in no other state; the attempt follows `OPS-41`'s ordered decision | **Unchanged**: the new attempt contends on the same episode id |
| `keep` (`API-68`) on a `stalled` episode | `closed`, `close_reason: kept`, in the keep transaction; admissible in no other state | **Cleared**, same transaction |
| No attempt settled — **the machine is recorded gone** (`ADR-0021`): the write of `machines.state` to gone with `machines.state_observed_at` (`STO-48`), by any of `LDG-74`'s triggers — a refresh, a driver read during any operation, `OPS-32`'s complete pass — or by `API-63`'s termination; in any open state, `scheduled` included. Where that write and an attempt's terminal write are one transaction, as a delete's own "already gone" answer is, they are one close under the first row | `closed`, `close_reason: resource_gone`, in the transaction that records the gone state | **Cleared**, same transaction |
<!-- /formal -->

**Unchanged** preserves the actual fence value. An episode none of whose attempts reached
the fence transaction holds null. *Token clarified 2026-10-05 (`pv-gip.43`, Q14, `ADR-0032`);
no lifecycle outcome changes.*
````
### Pinned evidence for Q2

`04-api-contract.md:241–242` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`:

````text
5d. **gate a create on its ordering capability** under `DOM-10` (`PRV-10`, `DOM-16`). A refusal stops here and is not collected by the tail.

````
`04-api-contract.md:262–289` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`:

````text
**Rich purchase tails (create and extend-runway only; amended 2026-10-04, `ADR-0030`).** After steps 1–5d, the tail MUST
collect every applicable refusal once, from one read-only snapshot inside the existing `LDG-35`
transaction, without an extra lock, ceiling slot, write or provider call. On create, the offers the check reads are the provider account's stored offer listing (`05-persistence.md`, `offer_listings`), read in that snapshot, and the tail prices the commitment and takes the offer snapshot from it. On create, the tail reads the stored listing regardless of age, or an empty offers set if no listing is stored. If the tail has collected no refusal and the stored listing has a `read_at` older than the stated offer-listing age (`OVR-19`) at the admitting transaction, the create MUST be refused `provider` (`01-domain-model.md`'s error taxonomy) with `retryable: true` before any admission write, committing nothing. Every offer-derived input used to size the commitment or populate `request_summary` comes from the named offer in that same stored listing, including recurring price, currency, period, setup fee, `install_strategies`, and any offer-reported billing unit or cancellation bound. Descriptor-declared inputs come from the descriptor the `api` runs with. See `PRV-44`, `PRV-13b` and `05-persistence.md`. `details.refusals`
(`WIR-9a`) MUST be ordered: the request's own resource refusal (`conflict`/`state` for create
against a provider account not `healthy`, or `conflict`/`cancellation_committed` for extension);
then, on create only, `invalid_request`/`offer_not_sellable` when the named offer is
not sellable under `PRV-13b` or `PRV-31`, or absent from the offers the check reads;
then, on create only, `rate_limited` when the offer's account and ordering channel
are closed under `PRV-40`;
`halted`/`solvency`; `halted`/`rate_unavailable`; the commitment-cap refusal (`WIR-17`, `WIR-24`);
`insufficient_balance`. See `ADR-0030` for the order's rationale and `LDG-40` for halt retention.
An offer absent from the offers the check reads is an unsellable offer for every rule in this
tail, including cap and balance suppression and the `WIR-9a` `offer_not_sellable` refusal and
`not_checked` entries. No additional lookup is made for this verdict.
Both halted entries may appear; no duplicate
means no repeated refusal/check, not unique kind strings. The cap and balance checks MUST NOT
run without a rate, nor for create against an unhealthy account or unsellable offer:
`WIR-30` says "an account whose
`STO-47` status is not `healthy` `404`s on this route too". `WIR-9a` owns `not_checked`,
including cap presence, reasons and ordering. Each refusal is exactly
`WIR-9`'s inner error object, with no nested refusal list. Entry 0 is the headline: HTTP status,
`kind`, `message` and per-kind details MUST match it; top-level details additionally carry the
aggregate keys. Only top-level `retryable` may differ, under `WIR-9b`. Pacing belongs to the
headline: its `details.retry_after_ms` and `Retry-After` follow the existing per-kind rules and
`WIR-4`; each entry keeps its own required pacing. No maximum is taken and a subordinate
entry MUST NOT supply pacing to a headline kind that does not require it. A refused tail MUST
commit nothing and write no `STO-35` receipt (`WIR-3`), so clearing faults and resending the same
request/key evaluates afresh. Admission retains the conditional-write guards in `API-63`,
````
`03-operation-lifecycle.md:765–800` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`:

````text
**Sale re-test at claim.** At claim (`OPS-5`), before any provider mutation, the worker MUST
re-test the create's named offer for sale under `PRV-13b` and `PRV-31`, applying `API-7`'s
create-tail verdict: "`invalid_request`/`offer_not_sellable` when the named offer is
not sellable under `PRV-13b` or `PRV-31`, or absent from the offers the check reads".
The inputs are the descriptor the worker runs with
(`PRV-44`: "The descriptor is a typed, immutable value") and one current driver List offers
result taken at claim. Date bounds MUST resolve against provider-local today at the time of
the check.

The worker MUST order the following steps as listed:

1. Read the provider account's stored status (`STO-47`). This is a plain read, not a
   conditional-write guard; the guard remains the conditional write at step 8. If the status
   is not `healthy`, fail `conflict`, with `API-63`'s “`details.reason: "account_terminated"`
   where the status is `terminated` and `"state"` for the two recoverable statuses, since
   presenting an unreachable account as a permanent termination is false, and with
   `retryable: false` for `"account_terminated"` and `retryable: true` for `"state"` on both the
   error and the operation view”. Make no
   provider request and release the commitment in full under `LDG-39`'s "Deterministic rejection
   before acceptance" case.
2. Read the stored channel closure (`PRV-40`: "the worker MUST read the stored closure for that
   account and ordering channel when it claims the operation (`OPS-5`), before any provider
   request, including a per-order key upload").
3. Repeat boundary validation under `OPS-23`: "Validation that was performed at the API boundary
   MUST be repeated in the worker before the driver is called". This includes `PRV-10`'s
   "explicit purchase acknowledgement", `PRV-8`'s "at least one SSH public key", the missing-field
   checks defined in `OPS-23`, and `DOM-10`'s gate on the create's ordering capability, which is
   `PRV-10`'s "the account is configured to allow ordering". The checks on caller-supplied fields
   run first, then the checks on fields the `api` wrote at admission, then the capability gate.
4. Gate on `list_offers` under `DOM-10`, then obtain the current driver List offers result.
5. Check for the named offer's absence from that result, applying the create-tail verdict quoted
   above; if present, re-test the named offer for sale on that result and the running descriptor.
6. Compare its price using that same List offers result, as below. An unsellable offer gets no
   price comparison.
7. Run `PRV-47`'s driver validation: "the driver MUST validate every value it forwards to the
   provider, including provider options". For the rejection's error, see `PRV-47`.
````
`10-conformance-checklist.md:340–357` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`:

````text
- [ ] **CNF-55** — Create against an order-billed provider is rejected without both the
      per-request purchase acknowledgement and the account-level opt-in. On an account whose
      `allow_orders` is false, assert `GET /v1/providers` lists it without its ordering
      capability, and that a create carrying `acknowledge_purchase: true` is refused at `API-7`'s
      step 5d: HTTP `501`, `unsupported`, `details.provider_account` and `details.capability`
      naming the account and that capability, `retryable: false`, and, with a balance too low for
      the create, no `details.refusals` or `details.not_checked` and no operation or commitment.
      A same-key, same-body replay of a create admitted before the flag was turned off returns its
      stored result. Admit a complete resource-offer (`offer_is_resource`) create with
      `allow_orders` true, and assert this create's exclusion for its provider account, ordering
      channel and offer id is held at admission (`PRV-42`, `STO-58`). While it is still queued
      and unclaimed, restart with only that flag changed to false, and assert the worker
      refuses it at `OPS-43`'s step 3 with the same kind, `details`
      and `retryable: false` on both the error and the operation view, `failed`, the commitment
      released in full with no setup-fee or first-unit debit, this create's settlement freeing
      that same held resource-offer exclusion (`STO-58`), and no provider request, including
      no List offers read. (`API-15`, `PRV-10`, `DOM-10`, `DOM-16`, `API-7`, `OPS-43`, `WIR-9a`,
      `WIR-9b`, `LDG-39`)
````
`10-conformance-checklist.md:135–154` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`:

````text
      *Amended 2026-10-22 (`pv-p3k`; panel r62, `docs/research/panels-2026-10/r62/`; owner decision 2026-10-22): applied the reviewed ordering-capability change.*

- [ ] **CNF-19** — Create is refused when the provider has not declared the matching
      provision capability — with the driver's internal ordering flag set to permissive,
      so the test proves the outer gate exists. (`DOM-10`, `DEF-10`)
- [ ] **CNF-364** — **The claim-time List offers read is gated on `list_offers`.** Admit a
      complete resource-offer (`offer_is_resource`) create on an account that declares
      `list_offers` and the ordering capability. Assert this create's exclusion for its provider
      account, ordering channel and offer id is held at admission (`PRV-42`, `STO-58`).
      While it is still queued and unclaimed, restart with a descriptor for that account that
      removes only `list_offers`, keeping the ordering capability declared and the driver's
      List offers code path answering, so the test proves the gate exists, as `CNF-19` does. Assert the worker
      refuses the create at `OPS-43`'s step 4: `unsupported` with `details.provider_account`
      naming the account and `details.capability: "list_offers"`, `retryable: false` on both the
      error and the operation view, no `details.refusals` or `details.not_checked`, `failed`, the
      commitment released in full with no setup-fee or first-unit debit, this create's settlement
      freeing that same held resource-offer exclusion (`STO-58`), and no List offers read,
      per-order key upload or order request. (`DOM-10`, `OPS-43`, `OPS-11`, `LDG-39`, `WIR-9a`,
      `WIR-9b`)
      *Amended 2026-10-22 (`pv-009`; panel r62, `docs/research/panels-2026-10/r62/`): applied the reviewed claim-time capability gate and refusal checks.*
````
`13-wire-contract.md:641–660` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`:

````text
**WIR-17** **AMENDED** `POST /v1/machines` — create:

```json
{
  "provider_account": "hetzner-robot-1",
  "offer": "market:12345",
  "region": "fsn1",
  "hostname": "worker-1",
  "image": null,
  "ssh_public_keys": ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIexamplekeyxxxxxxxxxxxxxxxxxxxxxxxx"],
  "user_data": null,
  "labels": {"team": "batch"},
  "runway_seconds": 2592000,
  "max_commitment_sats": 90000,
  "acknowledge_purchase": true,
  "provider_options": {}
}
```

This create uses `WIR-30`'s `"market:12345"` Robot default-uplink offer; the
````
`13-wire-contract.md:1034–1050` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`:

````text
**WIR-30** **AMENDED** `GET /v1/providers/{account}/offers` — customer prices only (`LDG-26`), an
unassigned account `404`s (`WIR-36`), and **an account whose `STO-47` status is not `healthy` `404`s
on this route too** — *added 2026-09-04, because the health filter went onto the collection route
alone and this one is reachable by any caller that remembers an account name, serving a full price
list that `WIR-29`'s create refusal then rejects at purchase*:

```json
{"offers": [{
  "id": "market:12345", "name": "Auction dedicated server", "kind": "bare_metal", "regions": ["fsn1"],
  "recurring_price": {"amount_sats": 90, "period": "hour"},
  "setup_fee_sats": 0,
  "first_unit_sats": 90,
  "billing_unit_seconds": 3600,
  "min_runway_seconds": 3600,
  "quoted_at": "2026-08-12T13:59:00Z", "binding": false,
  "max_rate_outage_seconds": 21600,
  "traffic_bound": "unlimited",
````
`02-provider-contract.md:71–84` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`:

````text
### Describe capabilities

**Input** — none.
**Output** — the descriptor (`PRV-44`).

Pure and synchronous; it MUST NOT perform network I/O. It is called on every capability
check and on every `GET /v1/providers`.

**PRV-44** The descriptor is a typed, immutable value: `account`, `kind`, `capabilities`,
`ordering_channels` (each with `correlator: operation_id | per_order_key | none`, `PRV-32`,
`PRV-33`, `PRV-38`, `offer_is_resource: true | false` (whether the offer names one machine, `PRV-42`), and
`order_budget: {limit, per}`, `PRV-40`), `evidence_sources` per mutation kind in descending strength (`PRV-36`),
`visibility_window` `{declared_seconds, sample_size, measured_on | unmeasured}` (`PRV-36`),
`cancellation_bound` per offer (`PRV-31`) — which MAY be reported on the offer instead —
````
`05-persistence.md:559–582` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`:

````text
**STO-50** **ADDED 2026-09-06 (`F38`) — `request_summary` is a closed enumeration, and anything not
on the list MUST NOT be written to it.** Its opening description is "what was attempted", which
names no field, and an open-ended summary standing beside a purged `request` is a hole in the purge
rather than a note about it: **`ADR-0005` is enforced by what survives, not by what is removed**, so
a bucket that admits anything admits exactly the material `STO-9` above lists as the reason the
purge exists. The contents are:

- **Always** — the operation's kind, its machine where it has one, the resolved provider account
  (`OPS-35`), and what `OPS-13` requires: what was attempted, and any provider-side identifiers
  that were created.
- **For a create** — the correlator, the offer snapshot and the at-cost setup fee enumerated on the
  `request_summary` row above, and since 2026-10-08 the prepaid first unit beside the fee
  (`ADR-0033`). The offer snapshot also includes the declared cancellation bound, as specified
  on the `request_summary` row. *Amended 2026-10-16 (`ADR-0037`, `pv-tsb`).*
- **For the kinds `OPS-45` governs** (*it names six; this said "five" until 2026-09-16*) — the two markers, `write_started_at` and `rescue_exited_cleanly`,
  copied from their columns as that row already requires.

**Nothing else.** In particular the summary MUST NOT carry a caller-chosen hostname, SSH public
keys, user data, a post-install script, a signed image URL, a disk layout, or a spending cap —
whether or not a given field looks harmless alone. *`PRV-26` already forbids a correlator encoding
"a hostname the customer chose", and there is no reason the record beside it should be laxer than
the value written into the provider.*

*This is what `F38` was really about: "every respect the summary records" pointed at a list nobody
````
`10-conformance-checklist.md:30–32` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`:

````text
seed under a unit of some seconds is `CNF-318`'s.

**Stored offer listings in the items below** (2026-10-26): An item that asserts or relies on a create being admitted or succeeding, including a create used to show a release, without specifying the stored listing's age, runs on a stored listing that contains the named offer and has a `read_at` no older than the stated offer-listing age at the admitting transaction (see `OVR-19`). This default qualifies only the admission or success assertion and any create used to reach it; an item asserting a refusal without specifying the stored listing's age asserts it whatever that age. For the stale-listing refusal case, see `CNF-166`.
````

## Formal source at the pin

tools/formal/Provisiond/Admission.lean:15

````text
The pipeline (`API-7`, `WIR-34`, `API-55`, `API-56`): principal, tenant state,
listener and verb decide one outcome and whether the request consumed a ceiling slot.
The create-only step 5d is modelled in `createPurchaseTail`, outside `admit`, which stops at
5c; `createAdmission` composes it with collection and the listing-age decision.
`API-7` says "A refusal stops here and is not collected by the tail." The ceilings
(`SEC-39`): which budget each verb counts against, and the two properties that make a ceiling a
````

tools/formal/Provisiond/Admission.lean:317

````text
`orderingCapabilityGuard` (`API-7`, 2026-10-22, `pv-p3k`): `API-7` says
"**gate a create on its ordering capability**". Off, a create without that declaration reaches
the purchase tail.

````

tools/formal/Provisiond/Admission.lean:1180

````text
/-- Step 5d composed before the create's tail (`API-7`, `DOM-10`). The supplied Boolean answers
whether the account declares the create's ordering capability. Machine-kind selection and
descriptor construction are outside this model. Only creates enter this function; the shared
steps 1–5c and extend-runway's tail are separate. -/
@[req "API-7"]
def createPurchaseTail (g : Guards) (orderingDeclared : Bool) (account : AccountStatus.Status)
    (offerSellable channelClosed halted rate capPresent cap balance : Bool) : CreateTailResult :=
  if g.orderingCapabilityGuard && !orderingDeclared then
    { refusal := some .unsupported, tail := none }
  else
    { refusal := none, tail := some (purchaseTail g true account offerSellable channelClosed
        false halted rate capPresent cap balance) }

/-- With step 5d enabled, an undeclared ordering capability refuses the create as unsupported
and produces no tail result, regardless of the tail's snapshot inputs (`API-7`, `DOM-10`). -/
@[req "API-7"]
theorem undeclared_ordering_stops_before_tail (g : Guards)
    (h : g.orderingCapabilityGuard = true) (account : AccountStatus.Status)
    (o c s r q p b : Bool) :
    createPurchaseTail g false account o c s r q p b =
      { refusal := some .unsupported, tail := none } := by
  simp [createPurchaseTail, h]

/-! ## Composed create admission

`API-7`: "On create, the tail reads the stored listing regardless of age, or an empty offers set
if no listing is stored." The supplied sale verdict includes the named offer's absence, including
an empty offers set. There is no separate no-row refusal or presence policy here. -/

/-- Age and limit are coherent durations in the same units from the admitting snapshot.
No timestamp subtraction, clock or database read is performed by this model. -/
@[req "API-7"]
def listingStale (age limit : Nat) : Bool := decide (limit < age)

@[req "API-7"]
theorem listing_stale_iff (age limit : Nat) :
    listingStale age limit = true ↔ limit < age := by simp [listingStale]

@[req "API-7"]
theorem listing_age_equality_is_fresh (limit : Nat) :
    listingStale limit limit = false := by simp [listingStale]

/-- Apply age only to an empty, successfully collected result; retain that collection alongside
any added refusal. The result contains no write continuation or wire serialization. -/
@[req "API-7"]
def afterListingAge (g : Guards) (age limit : Nat) (result : CreateTailResult) : CreateTailResult :=
  match result.refusal, result.tail with
  | none, some tail =>
      if tail.refusals.isEmpty then
        if g.listingAgeGuard && listingStale age limit then
          { refusal := some .provider, tail := some tail }
        else result
      else result
  | _, _ => result

/-- Direct composition over the existing step-5d and collection function. All sale and age
inputs refer to the same admitting snapshot; supplying them coherently is not proved here. -/
@[req "API-7"]
def createAdmission (g : Guards) (orderingDeclared : Bool) (account : AccountStatus.Status)
    (offerSellable channelClosed halted rate capPresent cap balance : Bool)
    (age limit : Nat) : CreateTailResult :=
  afterListingAge g age limit
    (createPurchaseTail g orderingDeclared account offerSellable channelClosed
      halted rate capPresent cap balance)

/-- Every pre-collection refusal survives at every age, with no collection introduced. -/
@[req "API-7"]
theorem age_preserves_early_refusal (g : Guards) (age limit : Nat) (kind : ErrorKind) :
    afterListingAge g age limit { refusal := some kind, tail := none } =
      { refusal := some kind, tail := none } := by rfl

@[req "API-7"]
theorem age_preserves_step_5d (g : Guards) (h : g.orderingCapabilityGuard = true)
    (a : AccountStatus.Status) (o c s r q p b : Bool) (age limit : Nat) :
    createAdmission g false a o c s r q p b age limit =
      { refusal := some .unsupported, tail := none } := by
  simp [createAdmission, createPurchaseTail, afterListingAge, h]

````

ADR-0025 guard-hypothesis amendment, lines 175–196:

````text
## Amendment — 2026-10-14: which guard hypotheses are not a weakening (owner decision Q32)

The guard bullet above makes every guard a parameter with a refused/admitted pair, and `ci.yml`'s rows flip
`current` and require exactly one red: "Fence.lean's own theorems take each guard as a hypothesis and stay
green". Nothing said whether adding such a hypothesis to an existing theorem is the weakening `AGENTS.md`
describes ("weakening a statement to make a proof pass is a semantic change like any other"). The allowance
lived in run instructions and ticket comments, and three ledger theorems on this branch carried one they did
not need. A four-reader panel weighed it (`docs/research/panels-2026-10/r49/`); all four amended with changes.

**Decision.**
- A theorem quantified over a parameter record takes the fields it needs as hypotheses, so that a `ci.yml` row
  reds only its own witness. The set's claim is the theorem at `current`, so a hypothesis `current` satisfies is
  not a weakening. This covers every field, dated or not, and a field whose `current` value is `false`.
- A guard hypothesis added to an **existing** theorem must be one without which the statement is false. Its
  docstring names the hypothesis and cites the witness that refutes the statement without it: usually the
  guard's own admitted-without witness, otherwise a short `decide` refutation in `Witnesses.lean`.
- Removing an unneeded hypothesis is always allowed.
- Adding any other hypothesis to an existing theorem, or narrowing its conclusion, is the weakening
  `AGENTS.md` describes.

Tooling cannot enforce the second point: every hypothesis is referenced by its proof, so Lean reports none
unused, and a CI row that deletes a hypothesis goes red on true statements too. The witness is the evidence.
````

## Complete candidates for this round

All source substitutions are relative to the pin. Inline code formatting may follow the existing document convention, but no word, quotation, owner, declaration or obligation may change under a formatting excuse. The original Q1-A/B and Q2-A/B are printed in full; a changed rationale is labeled. Q2-A-prime is fable’s distinct reader form. Q2-A-cited and Q2-B-cited are manager-prepared, unreviewed whole forms submitted NOW, not prior settlements. Their additional edits repair quotations/docstrings and claim no resolution of the disputed formal semantics, domain restriction or enforcement concern.

### Complete candidate Q1-A — admission and claim, with system enqueue kept distinct

This form adds the following paragraphs after the existing mapping table in `DOM-10` (before its amendment note); existing mapping rows and error sentence stay as quoted:

```text
For power on, power off, reboot, hard reset, every install strategy, rescue inventory,
reverse DNS, delete/cancel and API-cleanable attachment release, a caller or operator
request MUST pass the capability check before admission enqueues the operation. This check
runs after API-7's steps 1–5c and all endpoint-local admission validation and admissibility
checks, immediately before the enqueue transaction's first write. It uses the descriptor
running in api and makes no provider request. A failed check enqueues no operation and
makes no endpoint-state or money write. A replay returned by API-7 step 5a never reaches
this check. An API-64 operator retry checks delete_machine before its state-change/enqueue
transaction; API-65's manual release has no driver operation and takes no capability check.
A suspend parent takes no per-machine capability check at admission: its cancellation
children are gated at claim as below.

Every operation in the preceding paragraph MUST also pass the capability check in the
worker using the descriptor running there, including operations enqueued without an HTTP
request, API-64 retry attempts and attachment releases enqueued by a successful delete.
The check runs after claim and per-machine serialization, before the operation's first
driver call and before either OPS-45 marker is written. Repeated validation checks caller-
supplied fields first, api-written admission fields second, then the other applicable
local validation, including machine install eligibility and OPS-40's signed-URL check;
the capability check follows. The first failing check stops subsequent checks. A capability
refusal is classified by OPS-11 and carries DOM-10's existing unsupported result. This
paragraph introduces no commitment, rate or solvency check for a non-purchase.

For an exposure-reducing cancellation, OPS-41's restore claim gate and ordered fence-
transaction decision run before this capability check. A no-call success or defer returned
by that decision takes no capability check. A decision that proceeds to cancellation MUST
pass the capability check after the fence transaction is acknowledged and before any
driver call or write-started marker. Capability failure follows the existing failed-attempt
and episode disposition; it does not authorize another automatic attempt or clear a fence.
An internally enqueued operation takes no capability check at enqueue. API-7's operator
retry ceiling and OPS-39's system-ceiling exemption retain their existing scope.

The capability is the operation's entry in the mapping table. A rescue-based install checks
its strategy capability first and rescue_ssh second, before beginning rescue; an inventory
checks rescue_ssh. PRV-25's identical-PTR success remains after its capability check. No
capability is inferred from an install-eligibility list, and this timing rule adds no gate
to refresh, a manual attachment release, or the capability-less methods named by PRV-4.
```

In `API-7`, insert after step 5d and before "The tail then depends on what the endpoint does:":

```text
For the non-create tails, capability-check placement and precedence belong to DOM-10.
```

In `OPS-23`, append before its amendment notes:

```text
For non-create capability-check placement and its order relative to this validation,
OPS-40 and OPS-41, see DOM-10.
```

No create gate moves under Q1-A. For a refusal before any rescue dispatch, the existing classifier and markers retain their quoted meanings. The added early admission check does change an unsupported request's observable phase; assess that explicitly.

### Complete candidate Q1-B — claim only for non-create, including caller/operator requests

Insert the following paragraphs at the same `DOM-10` insertion point instead of Q1-A's paragraphs:

```text
For power on, power off, reboot, hard reset, every install strategy, rescue inventory,
reverse DNS, delete/cancel and API-cleanable attachment release, the required capability
check runs in the worker at claim, not at admission. API admission retains its validation,
admissibility and ceiling checks and enqueues an otherwise valid request even when the
running api descriptor lacks that operation's capability. This includes API-64 operator
retry and API-65's API-cleanable release. A suspend parent takes no per-machine capability
check at admission. A manual attachment release has no driver operation or capability check.

Every operation in the preceding paragraph MUST pass the capability check using the
worker's running descriptor after claim and per-machine serialization, before its first
driver call and before either OPS-45 marker is written. This includes operations enqueued
without an HTTP request and attachment releases enqueued by a successful delete. Repeated
validation checks caller-supplied fields first, api-written admission fields second, then
the other applicable local validation, including machine install eligibility and OPS-40's
signed-URL check; the capability check follows. The first failing check stops subsequent
checks. A capability refusal is classified by OPS-11 and carries DOM-10's existing
unsupported result. This paragraph introduces no commitment, rate or solvency check for
a non-purchase.

For an exposure-reducing cancellation, OPS-41's restore claim gate and ordered fence-
transaction decision run before this capability check. A no-call success or defer returned
by that decision takes no capability check. A decision that proceeds to cancellation MUST
pass the capability check after the fence transaction is acknowledged and before any
driver call or write-started marker. Capability failure follows the existing failed-attempt
and episode disposition; it does not authorize another automatic attempt or clear a fence.
An internally enqueued operation takes no capability check at enqueue. API-7's operator
retry ceiling and OPS-39's system-ceiling exemption retain their existing scope.

The capability is the operation's entry in the mapping table. A rescue-based install checks
its strategy capability first and rescue_ssh second, before beginning rescue; an inventory
checks rescue_ssh. PRV-25's identical-PTR success remains after its capability check. No
capability is inferred from an install-eligibility list, and this timing rule adds no gate
to refresh or the capability-less methods named by PRV-4.
```

Use the exact same `API-7` and `OPS-23` pointer insertions printed under Q1-A. No create gate moves. This historical candidate expressly admits missing support; assess its conflict with the newly included OVR-2. It is not an authorized exception to OVR-2.

### Complete candidate Q1-C0 — literal no source edit, corrected rationale

Make no source, checklist, descriptor, persistence, formal or gate edit for pv-5pmu. Preserve every existing obligation, including OVR-2's "the server MUST NOT accept an operation a provider has not declared support for", DOM-10's "before the driver is called" and "There MUST be no operation whose only gate is a driver-internal check", and OPS-23's "Validation that was performed at the API boundary MUST be repeated in the worker before the driver is called". This does not grant an implementation permission to admit known missing support. Do not claim the set has fixed all local-check or conditional-write/capability-refusal precedence merely because the admission prohibition exists. Leave any such residual detail unresolved. No new normative text lands.

### Complete candidate Q2-A — read the admission snapshot early and retain the kind

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
3. Repeat boundary validation under OPS-23. This includes PRV-10's explicit purchase
   acknowledgement, PRV-8's at least one SSH public key, the missing-field checks defined
   in OPS-23, and validation of request_summary's machine_kind as virtual or bare_metal.
   machine_kind is api-written admission data for OPS-23's missing/present-invalid-field
   rules. Check caller-supplied fields first, then api-written admission fields, then gate
   on DOM-10's matching ordering capability selected by that persisted machine_kind,
   using the descriptor the worker runs with. No current offer read supplies this gate.
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

### Complete candidate Q2-B — explicitly require one machine kind per provider account

This narrower form excludes a mixed-kind account instead of adding a retained kind field. In `PRV-44`, replace "`account`, `kind`, `capabilities`," with exactly:

```text
`account`, `kind`, `machine_kind: virtual | bare_metal`, `capabilities`,
```

Immediately after `PRV-44`'s descriptor field list, insert:

```text
machine_kind is the one machine kind this provider account can sell, independent of the
provider's kind field and independent of which provisioning capabilities are currently
withheld. Every offer returned for the account MUST have that machine kind. A mixed-kind
account or a descriptor without one valid machine_kind MUST be rejected as invalid deployment
configuration before api or engine enables that account; the deployment MUST NOT guess from
the declared capability set. machine_kind MUST NOT change for a retained provider-account
identity; selling another machine kind requires a distinct provider-account identity.
```

Replace `API-7` step 5d with exactly:

```text
5d. Gate a create on DOM-10's ordering capability selected by the running descriptor's
    machine_kind under PRV-44, including when the named offer is absent from the stored
    listing or no listing is stored. A refusal stops here and is not collected by the tail.
```

Replace `OPS-43` step 3 with exactly:

```text
3. Repeat boundary validation under OPS-23: validation performed at the API boundary MUST
   be repeated before the driver is called. This includes PRV-10's explicit purchase
   acknowledgement, PRV-8's at least one SSH public key and OPS-23's missing-field checks.
   Check caller-supplied fields first, then api-written admission fields, then gate on
   DOM-10's ordering capability selected by the worker's running descriptor's machine_kind
   under PRV-44. No offer read supplies this gate.
```

Append to `CNF-19` after its complete existing sentence:

```text
Use a descriptor with machine_kind virtual, then bare_metal. Withhold its matching
provisioning capability and assert API-7 step 5d names that capability, including with an
absent named offer or no stored listing; declaring only the other provisioning capability
MUST NOT pass the gate. Admit a fresh complete create, then withhold its matching capability
before claim and assert the CNF-55 refusal before List offers. Assert configuration refusal
before enabling a provider account for a descriptor with absent/invalid machine_kind, an
account selling both kinds, or a change of machine_kind for a retained account identity.
```

All other source and checklist text stays unchanged; no request_summary field is introduced. Existing `CNF-55` phase/refusal assertions and purchase-tail ranks stay as pinned. This form adds a real restriction on future provider-account shapes and configuration, rather than asserting that the present set already excludes a mixed account. Assess that scope cost. The descriptor is an operational contract, not a provider HTTP input.

### Complete candidate Q2-A-prime — read the admission snapshot early and retain the kind

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
3. Repeat boundary validation under OPS-23. This includes PRV-10's explicit purchase
   acknowledgement, PRV-8's at least one SSH public key, the missing-field checks defined
   in OPS-23, and validation of request_summary's machine_kind as virtual or bare_metal.
   machine_kind is api-written admission data for OPS-23's missing/present-invalid-field
   rules. Check caller-supplied fields first, then api-written admission fields, then gate
   on DOM-10's matching ordering capability selected by that persisted machine_kind,
   using the descriptor the worker runs with. No current offer read supplies this gate.
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


Additionally perform all the following exact Lean docstring substitutions (fable's complete addition, verbatim):

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

### Complete candidate Q2-A-cited — read the admission snapshot early and retain the kind

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

### Complete candidate Q2-B-cited — explicitly require one machine kind per provider account

This narrower form excludes a mixed-kind account instead of adding a retained kind field. In `PRV-44`, replace "`account`, `kind`, `capabilities`," with exactly:

```text
`account`, `kind`, `machine_kind: virtual | bare_metal`, `capabilities`,
```

Immediately after `PRV-44`'s descriptor field list, insert:

```text
machine_kind is the one machine kind this provider account can sell, independent of the
provider's kind field and independent of which provisioning capabilities are currently
withheld. Every offer returned for the account MUST have that machine kind. A mixed-kind
account or a descriptor without one valid machine_kind MUST be rejected as invalid deployment
configuration before api or engine enables that account; the deployment MUST NOT guess from
the declared capability set. machine_kind MUST NOT change for a retained provider-account
identity; selling another machine kind requires a distinct provider-account identity.
```

Replace `API-7` step 5d with exactly:

```text
5d. Gate a create on DOM-10's ordering capability selected by the running descriptor's
    machine_kind under PRV-44, including when the named offer is absent from the stored
    listing or no listing is stored. A refusal stops here and is not collected by the tail.
```

Replace `OPS-43` step 3 with exactly:

```text
3. Repeat boundary validation under `OPS-23`: "Validation that was performed at the API boundary
   MUST be repeated in the worker before the driver is called". This includes `PRV-10`'s
   "explicit purchase acknowledgement", `PRV-8`'s "at least one SSH public key", and the
   missing-field checks in `OPS-23`. Check caller-supplied fields first, then api-written
   admission fields, then gate on `DOM-10`'s ordering capability selected by the worker's
   running descriptor's `machine_kind` under `PRV-44`, which is `PRV-10`'s "the account is
   configured to allow ordering". No offer read supplies this gate.
```

Append to `CNF-19` after its complete existing sentence:

```text
Use a descriptor with machine_kind virtual, then bare_metal. Withhold its matching
provisioning capability and assert API-7 step 5d names that capability, including with an
absent named offer or no stored listing; declaring only the other provisioning capability
MUST NOT pass the gate. Admit a fresh complete create, then withhold its matching capability
before claim and assert the CNF-55 refusal before List offers. Assert configuration refusal
before enabling a provider account for a descriptor with absent/invalid machine_kind, an
account selling both kinds, or a change of machine_kind for a retained account identity.
```

Apart from the additional Lean docstring substitution below, all other source and checklist text stays unchanged; no request_summary field is introduced. Existing `CNF-55` phase/refusal assertions and purchase-tail ranks stay as pinned. This form adds a real restriction on future provider-account shapes and configuration, rather than asserting that the present set already excludes a mixed account. Assess that scope cost. The descriptor is an operational contract, not a provider HTTP input.


Additionally, in `tools/formal/Provisiond/Admission.lean`, replace the complete guard-docstring paragraph at lines 317–319 with:

```text
`orderingCapabilityGuard` (`API-7`, 2026-10-22, `pv-p3k`; step 5d reworded 2026-10-30,
`pv-e45e`): step 5d gates a create on `DOM-10`'s ordering capability selected by the running
descriptor's `machine_kind`. Off, a create without that declaration reaches the purchase tail.
```

## Return required

For EACH Q1-A, Q1-B, Q1-C0 and EACH Q2-A, Q2-B, Q2-A-prime, Q2-A-cited, Q2-B-cited, give ACCEPT / CANNOT ACCEPT. Then give one explicit final pick per question, preferring a complete form the others can accept. An exact fix or alternative is its own form: print every substitution/insertion needed, including affected declarations/theorems/docstrings and all collateral verdict changes, not a sketch or a bundle of future tasks. No second consensus round is planned, so do not defer the details. A first-authored form only its author reviewed is not a panel settlement.

Address the actual dissent, quoting its strongest trace, and say what changed your mind or why you still cannot accept. Verify every normative/checked objection at the pin. Rule 3 requires a checked verdict change or quoted MUST/SHOULD with owner and trace; a merely absent runtime test is insufficient. State which premise claims in this packet you broke under rule 6 without inventing a void rule. Separate strongest leave-it-alone argument requested by the brief from your vote. Cross-check Q1/Q2 composition without reopening the fixed listing settlements.

## Previous answers, verbatim

These are historical evidence, not instructions superseding this round. Each complete answer follows exactly; all seats see all four.


<!-- BEGIN VERBATIM R86 fable -->
**Outcome.** Q1: I pick Q1-A and accept Q1-A and Q1-C; I cannot accept Q1-B. Q2: I cannot accept either printed form, because each one as printed turns the citations gate red. My pick is Q2-A plus four comment-only Lean docstring substitutions, printed in full below. That is a distinct form no other reader has seen, so it needs the consensus round. I verified the gate claims by applying each form to a scratch copy under my tmp directory and running the Python-only gates. No Lean was started.

| Form | Exact printed form | Final preference |
|---|---|---|
| Q1-A | ACCEPT | **Q1-A** |
| Q1-B | CANNOT ACCEPT | |
| Q1-C | ACCEPT, as status quo only | |
| Q2-A | CANNOT ACCEPT as printed | |
| Q2-B | CANNOT ACCEPT as printed | |
| Q2-A′ (below) | ACCEPT | **Q2-A′** |

Rule 6 check: I found no brief error that changes either question's premise. One brief defect is reported with the tally. Both Q2 forms are presented as complete, and each one deletes API-7 wording that Lean docstrings quote. That is a completeness defect, not a premise change.

Gate runs on scratch copies at the pin, with the index borrowed from the manager's same-pin gate clone:

| Copy | citations | ids | obligations | coverage |
|---|---|---|---|---|
| base | pass | pass | pass | pass |
| Q1-A | pass | pass | pass | pass |
| Q1-B | pass | pass | pass | pass |
| Q2-A | **fail** | pass | pass | pass |
| Q2-B | **fail** | pass | pass | pass |

The fixtures gate cannot run outside the Nix shell on this host. No candidate touches a JSON fixture or a Lean-rendered region, so I expect no effect there. The regions and formal gates are the manager's.

## Q1

**What the owners already fix.** DOM-10 at 01-domain-model.md:515 says "before the driver is called", and SEC-15 at 07-security-requirements.md:84 repeats it. The driver is called by the worker, and system children have no admission request, so a worker-path gate is already implied for every kind. What is unspecified is the admission phase and the order among local checks. DEF-10 at 09-known-defects.md:78 cites the old worker file, so the historical implementation gated at claim.

**Per operation, under Q1-A.** Power and hard reset take `power_control` or `hard_reset` at admission and claim; PRV-14 stays defense in depth. Each install strategy takes its DOM-10 row, then `rescue_ssh` for rescue-based strategies, after WIR-30's eligibility refusal and OPS-40's accept-time check. Rescue inventory takes `rescue_ssh` before the rescue marker is written, which keeps CNF-302's `rescue_exited_cleanly` null at 10-conformance-checklist.md:3049. Reverse DNS takes `reverse_dns` after API-16 validation and before the PTR compare, which is PRV-25's own order at 02-provider-contract.md:855. A caller delete and an operator release on an `api` row take `delete_machine` at admission; API-65's manual row calls no driver and takes none. API-64 retry takes it before its guarded write. Suspend children, sweep cancellations and the releases a delete enqueues take it at claim only.

**No-call branches and defers hold.** I traced an exhaustion cancellation on a machine funded since routing: OPS-41 step 3 at 03-operation-lifecycle.md:1093 aborts with no provider call and settles `succeeded`, and both Q1 texts exempt that path. The restore-grace defer at 03-operation-lifecycle.md:998 runs before the fence and before the check. A machine recorded gone takes step 1 and never reaches the check. The same-PTR success stays behind its capability check as PRV-25 already orders. Local validation refusals keep their rank in both phases, so no validation refusal moves and no defer becomes terminal.

**The cost Q1-A accepts.** A decision that proceeds past the fence and then fails the capability check settles `failed`, and OPS-48's row at 03-operation-lifecycle.md:1301 leaves the episode `stalled` with the fence unchanged. That is the existing disposition of any deterministic provider rejection after fencing, and the operator's keep or retry clears it. Placing the check before the fence would bypass the no-call success the brief warns about, so this placement is the right one.

**Why Q1-B cannot be accepted.** Q1-B does not merely omit an admission gate. It says admission "enqueues an otherwise valid request even when the running api descriptor lacks that operation's capability". The descriptor is "Pure and synchronous" at 02-provider-contract.md:76, so the refusal is knowable at admission, and the set rejects every other admission-knowable fault before enqueue. API-13 at 04-api-contract.md:962 says "MUST be enforced before an operation is enqueued". WIR-30 at 13-wire-contract.md:1062 says an ineligible strategy "MUST be rejected as `invalid_request` before the operation is enqueued, exactly as an invalid pairing is". OPS-40 checks "twice". Trace: an operator retries a stalled episode on an account that no longer declares `delete_machine`. Under Q1-B the guarded write moves the episode to `attempting`, the attempt is claimed, the fence transaction runs, the check fails, the attempt settles `failed` and the episode returns to `stalled` with the fence now set. Under Q1-A the retry answers `501` and writes nothing. Q1-B contradicts no quoted MUST. My objection is to the design, and it is not a rule 3 loss.

**Q1-C.** Nothing breaks if it lands. CNF-201 and CNF-302 are satisfiable in either phase. I accept it as the status quo and nothing more. It does not answer the bead, and conformance items keep being unable to assert a phase for a non-create refusal.

**Strongest case for leaving Q1 alone, on request.** Non-create admission moves no money. Capability sets change only across a restart. DOM-10 already forces a worker gate for system children, so an implementation that also gates at admission is conformant today. Nine endpoint classes gain an admission step for a problem that has never bitten.

## Q2

**Both printed forms break the citations gate.** Admission.lean quotes three API-7 sentences in docstrings. Its line 19 quotes "A refusal stops here and is not collected by the tail." Its line 318 quotes "gate a create on its ordering capability". Its line 1205 quotes the stored-listing sentence. The gate's EXISTS rule requires every Lean docstring quote to appear in the corpus. Applying Q2-A as printed produced two unverifiable attributions and three Lean quotes found nowhere. Applying Q2-B produced one of each. The before-gate log shows this gate passing at the pin, so either form as printed cannot land under AGENTS.md. No declaration, theorem or guard changes under either form. `createPurchaseTail` takes a supplied Boolean, and `Summary.offerSnapshot` is an opaque string, so the retained field needs no Lean change. Comment-only docstring substitutions clear the gate for both forms, verified on the scratch copies. Both Q2 forms also replace OPS-43 step 3's three verified quotations with paraphrase. That is a quality regression under the "Quote the sentence" rule, not a gate failure.

**Q2-A on substance.** The offer owns the kind in this set. The offer entity at 01-domain-model.md:166 carries `kind`, WIR-30's fixture carries it per offer, and DOM-10's rows select by the create's kind. Reading that kind from the stored listing in the tail's own snapshot adds no provider call and no guess. The brief flags the precedence change correctly. Trace: an `allow_orders: false` account, a named offer absent from the stored listing, a balance too low. At the pin CNF-55 at 10-conformance-checklist.md:343 asserts `501` at 5d, without saying whether its offer is present. Under Q2-A that case takes the tail and answers `400` `offer_not_sellable` with `not_checked` entries. The `501` survives for a present offer, including on an old listing, which matches the Lean theorem `age_preserves_early_refusal`. The owner's pv-p3k ruling was "MUST, not retryable", and both refusals stay non-retryable. The three panel-E settlements stand: Q2-A touches neither the tail's rank list nor the age sentence, and its CNF-55 insertion specifies presence, which the header default at 10-conformance-checklist.md:32 leaves open for refusal items. The restart case holds: step 3 gates on the retained kind with no List offers read, as CNF-55 requires. A missing or corrupt retained kind takes OPS-23's `incomplete_record`, since the kind is api-written like the accepted-price fields. A live kind change at step 5 refuses before any mutation and releases the commitment and exclusion. Mixed-kind accounts work.

**Q2-B on substance.** Beyond the gate failure, Q2-B has a hole. Its only guard against drift is a driver MUST, "Every offer returned for the account MUST have that machine kind", with no engine-side check and no checklist assertion after enabling. Trace: a descriptor with `machine_kind: bare_metal` declaring only `provision_bare_metal`; a later refresh stores a virtual offer under the same credential; a create names it. Step 5d passes on `provision_bare_metal`, the tail prices it, step 3 passes, steps 4 and 5 find it present and sellable, and the worker orders a virtual machine. DOM-10's row at 01-domain-model.md:525, "create machine, `kind = virtual`" requires `provision_virtual`, goes unenforced. Under Q2-A the same create answers `501` naming `provision_virtual`. Q2-B also adds a descriptor field, a configuration refusal and an account-identity rule to exclude a provider shape the set models as possible, which is a domain restriction wider than the question.

**Narrower form.** I found none that keeps mixed accounts, keeps the early refusal and invents no source. Gating absent offers on "neither provisioning capability declared" names no capability for `details.capability`. Re-deriving the kind at claim from the live listing moves the gate after step 4 and loses CNF-55's no-List-offers refusal. Q2-A's retained field follows the accepted-price precedent at 05-persistence.md:523.

**Strongest case for leaving Q2 alone, on request.** The bead itself records that every v1 driver sells one kind per account, so both divergence points are latent. Against it: the set already gives two conformant engines different answers for `details.capability`, which CNF-55 asserts.

**Cross-check of Q1-A with Q2-A′.** Q1-A inserts text only, touches no create step, and both Q2 forms keep step 5d create-only. API-7's steps 1 to 5c, replay at 5a and the ceilings at 5c stay ahead of every tail. Q1-A's claim order and Q2-A′'s step 3 order agree: caller-supplied first, api-written second, capability last. The stored-listing policy and both ordering gates are untouched by Q1-A.

## Q2-A′, exact form

Every Markdown substitution and insertion of Q2-A, exactly as the brief prints them, plus these four substitutions in `tools/formal/Provisiond/Admission.lean`. Each touches a docstring only.

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

For the record only, and not my vote: Q2-B becomes gate-clean with one substitution at lines 317–319.
```text
`orderingCapabilityGuard` (`API-7`, 2026-10-22, `pv-p3k`; step 5d reworded 2026-10-30,
`pv-e45e`): step 5d gates a create on `DOM-10`'s ordering capability selected by the running
descriptor's `machine_kind`. Off, a create without that declaration reaches the purchase tail.
```

Landing note for every printed form: the brief's code blocks drop the backticks the documents put around identifiers and field names. I read the forms with the repository's backtick convention restored and treat that as formatting, not a semantic change.

<!-- END VERBATIM R86 fable -->

<!-- BEGIN VERBATIM R86 opus -->
# r86 Panel G: opus reader answer

I read the pinned clone at `3109b5b`. I edited nothing, ran no gate or Lean, and wrote no temporary files. I applied notes.md rule 6 exactly as written.

## Votes

| Form | Acceptance | |
|---|---|---|
| Q1-A | **ACCEPT** | **Final Q1 pick: Q1-A** |
| Q1-B | **ACCEPT** | |
| Q1-C | **CANNOT ACCEPT** | |
| Q2-A | **ACCEPT** | **Final Q2 pick: Q2-A** |
| Q2-B | **CANNOT ACCEPT** (blocking trace below) | |

I propose no alternative form.

## Q1: where non-create operations check capability

### The cases, checked against their owners
- **Power and hard reset.** Both A and B check after `OPS-23`'s repeated validation and before the provider call. `OPS-45` sets the marker "when the provider call is dispatched", so the check comes before any marker. Under `OPS-11`'s last row a failure there settles `failed`. A also refuses at admission with `DOM-10`'s 501.
- **Install strategies and `rescue_ssh`.** `DOM-10`'s table maps each strategy to its own capability. Begin rescue separately carries "**Capability** — `rescue_ssh`" (`02:720`), so the A/B order (strategy capability, then `rescue_ssh`, then begin rescue) only spells out what `DOM-10` already implies.
  - `CNF-302` (`10:3050`) drives "a `rescue_ssh` capability refusal (`DOM-10`)" and asserts `rescue_exited_cleanly` **null**. Both forms put the check "before either OPS-45 marker is written", so that verdict holds.
  - Under A, that `CNF-302` path is reached by a restart between admission and claim. It stays reachable, and its `OPS-40` alternative is unchanged.
- **Rescue inventory.** `rescue_ssh` only, checked before the rescue marker. `CNF-201` is unaffected.
- **Reverse DNS.** `PRV-25` (`02:855`) says "After the ordinary authorization, capability and `API-16` validation, the worker MUST compare…". Both forms keep the identical-PTR success after the capability check. `CNF-334`'s "Retain the capability check" (`10:4238`) is unaffected.
- **Caller delete/cancel.** This is not an exposure-reducing cancellation (`CONTEXT.md:478`: "the set's umbrella for the system's own destruction paths"). It has no no-call branch at claim.
- **System children (exhaustion, suspend fan-out, outage bound).** Both forms gate them only at claim, after `OPS-41`'s restore gate and ordered decision.
  - Gone or closed episode (`03:1080`, "The worker makes no provider call and settles the attempt `succeeded`"): no capability check, success kept.
  - Restored grace (`03:1001`, "the claim MUST defer"): no capability check. The defer stays a defer.
  - Renewed funding (step 3): no-call success kept.
  - So no added gate overrides a no-call success or turns a defer into a terminal failure.
  - The suspend parent gets no per-machine check, which matches `04:713` ("`unsupported` on an account that never declared `delete_machine`" as a child-level outcome).
- **Cancelled before dispatch.** `API-58` step (4) and the queued system cancellations an account termination fails both settle a never-claimed operation. Neither reaches a claim-time check, under either form.
- **Operator retry (`API-64`).** A checks at admission and at claim. B checks only at claim, after `OPS-41` step 2.
- **Attachment release, both origins.**
  - Operator `api` row: A checks at admission and claim; B at claim.
  - Release enqueued by a delete's terminal transaction: claim only, under both.
  - `manual` row: no check, under both.
- **Local validation.** Both forms put capability after all admission-side checks (`API-13`, `API-14`, `API-16`, `WIR-30` eligibility, `OPS-40` at accept) and after worker-side validation. No validation refusal moves behind or ahead of anything it currently precedes.

### Traces for the disputed points

**1. Q1-A refuses some retries a claim could have closed (affects only A).**
- A stalled episode has a null fence. For example, an earlier attempt failed `incomplete_record` before the fence transaction, and the account was later restarted without `delete_machine`.
- The tenant tops up. The operator retries.
- Under A: 501 at admission.
- Under B: the retry is admitted. Step 2 says "A retry reading the fence null decides from step 3" (`03:1087`). Step 3 finds the machine funded and settles a no-call `succeeded`, closing the episode `funded`.
- Under A the operator still has `API-68` keep (close reason `kept`; the fence is cleared and the runway re-derived). No `CNF` or Lean theorem asserts the retry route.
- I count this as a narrow difference, not a blocking loss. It is an operator request the account cannot execute, which is the case 5c says a ceiling exists for.

**2. A fenced stall with no provider call (both A and B).**
- Both forms check capability "after the fence transaction is acknowledged".
- A delete-incapable exhaustion attempt therefore fences, fails, and leaves the episode `stalled` with the fence unchanged (`03:1301`, "`failed` — deterministic; the provider did not act | `stalled` | **Unchanged**").
- `LDG-62` (`03:1233`) then refuses the tenant's extension until the operator keeps.
- This matches `OPS-42`'s 2026-10-04 settlement ("keep supplies that explicit decision"). Under `PRV-13b` (`02:299`, "an API path to stop the cost"), an account without `delete_machine` cannot have sold the machine, so the case needs a capability withdrawn after the sale.
- It is a design cost, not a MUST conflict.

**3. Q1-C leaves the phase to each implementation.**
- A hard reset on an account without `hard_reset`: one build answers 501 at once, another answers `202` and then fails the operation `unsupported`. Both conform to "before the driver is called" (`01:515–516`).
- An install whose capability was withdrawn and whose signed URL can no longer outlive the install: the failure kind differs by build (`OPS-40`'s error or `unsupported`).
- That is a client-visible split in a wire contract, and it is exactly what `pv-5pmu` asks to settle. It isn't a rule-3 loss, because nothing changes; my objection is that it doesn't answer the question.

### Why A over B
- A extends the create's two-phase design (5d at admission plus `OPS-43` step 3 at claim, owner ruling "MUST, not retryable") to every request, and keeps system children claim-only.
- B *forbids* the early refusal ("enqueues an otherwise valid request even when the running api descriptor lacks…"). So B is not only narrower: it bans a cheap, pure check that Q1-C permits.
- A's admission check runs after 5c (as 5d does), so it sits outside the Lean `admit` model, which covers steps 1–5c (`refusals_are_within_the_five_kinds`). No theorem changes.

### Wording points (not conditions on my vote)
- **`API-64` precedence.** A puts the check after "admissibility checks" but before "its state-change/enqueue transaction". `API-64`'s admissibility *is* that conditional write (`04:1052`).
  - So A effectively requires reading the episode state first.
  - A build that relies on the conditional write alone would answer 501 where another answers 409, for a non-stalled episode on a delete-incapable account.
  - No checklist verdict depends on this.
- **No Lean step for this path.** The fence model has no step for "failed after the fence without a provider call". `providerDelete false (some false)` reproduces the same world state, so `fenced_waits_for_the_provider` and `destroyed_only_by_provider_from_fenced` still hold. This applies to A and B alike.

## Q2: where a create's machine kind comes from

### Q2-A against every case asked
| Case | Result under Q2-A |
|---|---|
| Offer present; capability declared, fresh listing | 5d passes; tail; admitted, with `machine_kind` retained |
| Offer present; capability undeclared (fresh or old listing) | 5d 501 naming the offer kind's capability, before the tail. Same rank as today (Lean `age_preserves_step_5d`) |
| Offer present, declared, old listing, nothing collected | Existing stale-listing `provider` refusal, unchanged |
| Offer absent, or no stored listing | 5d skipped; the tail collects `offer_not_sellable`. Every such create is refused (`04:273`: "an unsellable offer for every rule in this tail"), so nothing is admitted ungated. Cap and balance are suppressed; no provider call |
| Unhealthy account plus absent offer | 409 `state` headline ahead of `offer_not_sellable` (panel-E settlement 1 holds) |
| Mixed account, both or one capability | Gate follows each offer's kind; the converse case is also tested |
| Mixed account, neither capability | Present offer: 501. Absent offer: 400 |
| Restart before claim, capability withdrawn | Step 3 gates on the retained kind, before List offers. `CNF-55`'s "no List offers read" is preserved |
| Retained kind missing or corrupt | `OPS-23`'s api-written rule: `conflict`/`incomplete_record`, `retryable: true`, before any provider request. Q2-A says the `api` writes the field, which satisfies `OPS-23`'s "MUST state whether the caller supplies it or the `api` writes it" |
| Live offer absent at claim | Existing step-5 refusal |
| Live offer's kind has changed | New step-5 `offer_not_sellable`: no price comparison, no mutation, full release, exclusion freed |

**Observable flip (disclosed, required to answer the question).**
- Today `CNF-55`'s 5d refusal (501, no refusals list) holds whether or not the named offer is in the stored listing.
- Under Q2-A, an absent offer on an account whose `allow_orders` is false gets `400 offer_not_sellable` with `refusals`/`not_checked` instead.
- Q2-A amends `CNF-55` and `CNF-19` to say the offer is present.
- This is forced. `DOM-10` requires naming "the capability", and for an absent offer the only ways to name one are the inferences the brief forbids.

**No owner ruling is violated.**
- `pv-p3k`'s ruling was about strength and retryability; both are kept for present offers.
- Admission still reads the stored listing with no provider call. 5d reads the same listing the tail uses, so `04:274–275`'s "No additional lookup is made" stays true.
- The age refusal is not moved.
- The per-item `CNF-55` qualification is about whether the offer is present, which the Form H header default (it governs listing age) doesn't reach. It doesn't replace that header.

### Q2-B: blocking loss
`DOM-10` (`01:515–518`) says "Every operation with a capability MUST be gated on it before the driver is called, **including create**" and "There MUST be no operation whose only gate is a driver-internal check". Its table (`01:526`) maps "create machine, `kind = bare_metal`" to `provision_bare_metal`.

Trace:
1. A descriptor declares `machine_kind: virtual` and only `provision_virtual`.
2. The driver's List offers returns a `bare_metal` offer, either as a bug or because the provider added a product line. `STO-60` stores that result.
3. Q2-B's 5d gates on `provision_virtual` and passes. The tail finds the offer present and admits the create.
4. At claim, step 3 passes on `provision_virtual` and step 5 finds the offer present. The order goes out.
5. Result: a bare-metal machine bought with no `provision_bare_metal` gate. The only barrier was Q2-B's new driver duty, "Every offer returned for the account MUST have that machine kind". That is the driver-internal reliance `DEF-10` names ("gated only by each driver's internal ordering flag"), which `CNF-19` exists to rule out.
6. Under Q2-A, 5d reads the offer's own kind and refuses naming `provision_bare_metal`.

Q2-B's added `CNF-19` text also demands checks nothing in the form can perform:
- **Mixed-kind detection.** It requires a configuration refusal "before enabling" for "an account selling both kinds". The descriptor is static, and Describe capabilities "MUST NOT perform network I/O" (`02:76`). The form names no read that could see the offers.
- **Kind changes.** It also requires refusing "a change of machine_kind for a retained account identity". The form persists no prior value, and `STO-21` (`05:684`) requires such state to "live in named tables".
- So that test has no defined mechanism to exercise.

Two further costs:
- **Scope.** All three v1 drivers (`ADR-0010`) sell one kind per account. A later dual-kind provider would need two account identities on one credential.
- **Second copy of `OPS-23`.** Q2-B's step 3 restates `OPS-23`'s MUST in unquoted words and drops "in the worker". That is the second-copy pattern AGENTS.md warns against.

### Is there a smaller complete form?
I found none. At admission, the only source the set already owns that exists before the tail is the stored listing's named offer. At claim, refusing before List offers needs a stored kind, and `request_summary` (a closed list under `STO-50`) is the owned record of accepted terms. Dropping step 5's kind-mismatch check would reopen `DOM-10`'s table gap at claim.

## Brief errors (rule 6)
None changes a question's premise, and none of my votes rests on one.
- The brief calls Q1-B "narrower than Q1-A". It also adds a prohibition that Q1-C does not have.
- The failure story implies that today a capability refusal could replace a no-call success. At the pin that would already be non-conforming: `03:1080` and `03:1001` say MUST, and `DOM-10` only says "before the driver is called". What is genuinely open is the admission phase, the order among local failures, and whether the check comes before or after the fence.
- Both Q2 forms' `OPS-43` step 3 rewrites drop three gate-checked quotations: `OPS-23`'s colon quote, `PRV-8`'s "at least one SSH public key" and `PRV-10`'s "the account is configured to allow ordering". Restating claims about other requirements without quoting them falls short of AGENTS.md's completion rule. No test pins those quotes, and `PRV-10` (`02:162`) still points at step 3. This is editorial, and I am not conditioning my vote on it.
- Lean `createPurchaseTail`'s docstring (`Admission.lean:1181–1194`) stays true under Q2-A, but `orderingDeclared` must then be read as "5d passes", which is true for an absent offer. A one-line docstring follow-up is advisable. No theorem or witness changes: `undeclaredOrderingCreate` uses a sellable, present offer.

## Cross-check of Q1-A with Q2-A
- Q1-A's text covers only non-create operations and leaves `DOM-10`'s create rows alone. Q2-A changes only 5d, the tail opening and `OPS-43` steps 3 and 5.
- Q1-A's `API-7` pointer follows the rewritten 5d. In `OPS-23`, the two inserts sit side by side.
- Replay, suspension and ceilings (5a–5c) stay ahead in both. `CNF-55`'s replay case is preserved.
- No purchase-tail rank moves, and panel-E's three settlements hold.

## Requested counterargument (not my vote)
- **Leave Q1 alone.** Every risky order (no-call success, defer, same-PTR, markers) is already pinned by existing MUSTs. What remains is error phase and kind among outcomes that are all `failed`, non-retryable and touch neither the provider nor money. The bead is P3, and `PRV-13b` keeps delete-incapable sold machines out of normal operation.
- **Leave Q2 alone.** Every launch driver is single-kind, so the two engines `pv-e45e` contrasts can't diverge on any v1 configuration. The issue is P4 and latent. A dual-kind driver's ADR could decide it with real provider facts, instead of adding a persisted field and a fixture flip now.

<!-- END VERBATIM R86 opus -->

<!-- BEGIN VERBATIM R86 astra -->
**Final picks: Q1-B and Q2-B.** These are votes for the printed forms, without repairs or combinations.

I read `notes.md` whole and verified HEAD at `3109b5b44eae17e288cf52aaa976993bd8c5626c`. **apply notes.md rule 6 exactly as written; this prompt adds no void rule**. I found no premise-changing brief error requiring either question’s tally to be voided. The Q2-A omission below affects that candidate’s completeness, not the existence of Q2.

This is one reader’s ballot. Grok’s absence is not a vote; settlement remains the owner’s three-of-four fallback.

**Q1**

| Exact form | Verdict | Assessment |
|---|---|---|
| Q1-A | ACCEPT | Specifies both phases, with a substantive admission-policy cost, including operator retries. |
| Q1-B | ACCEPT | Preferred: specifies execution ordering while preserving admission access to cancellation decisions. |
| Q1-C | ACCEPT | Defensible explicit implementation latitude; it does not establish deterministic cross-implementation ordering. |

My preference is **Q1-B** because the worker has to check its own running descriptor anyway, and the cancellation decision can legitimately eliminate the need for provider support.

Applying the unchanged mapping in [DOM-10](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/01-domain-model.md#L522), A and B cover the requested operations as follows:

| Operation | Required checks under A/B |
|---|---|
| Power on/off/reboot; hard reset | `power_control`; `hard_reset`, respectively |
| `provider_native` + `catalog` install | `native_rebuild` |
| `rootfs_via_rescue` install | `install_rootfs_via_rescue`, then `rescue_ssh` |
| `raw_disk` install | `install_raw_disk_via_rescue`, then `rescue_ssh` |
| `provider_catalogue` install | `install_via_provider_catalogue` |
| Rescue inventory | `rescue_ssh` |
| Reverse DNS | `reverse_dns` |
| Delete/cancel; operator retry | `delete_machine`, subject to the cancellation-specific ordering |
| API-cleanable attachment release | `delete_machine`, for both operator requests and delete-enqueued releases |
| Manual attachment release; refresh | No added capability gate |

The rescue prerequisite does not imply an additional power or hard-reset gate: [PRV-15](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/02-provider-contract.md#L722) says begin rescue “MUST both activate the rescue environment *and* initiate the reboot or reset needed to enter it.”

For A, caller/operator requests receive admission and worker checks; internally enqueued children receive only the worker check. For B, both origins receive the worker check only. A suspension parent does not acquire per-machine admission checks in either form.

**Concrete phase difference.** Submit a valid hard-reset request while the API descriptor lacks `hard_reset`. A refuses without creating an operation. B accepts the operation; a worker still lacking the capability records `unsupported`, non-retryable, before dispatch. If the worker’s restarted descriptor now supplies it, B permits execution. C leaves this phase choice open. The base’s [DOM-10](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/01-domain-model.md#L515) says “before the driver is called,” not “before admission”; A’s earlier refusal is a new observable obligation, not an existing requirement discovered in the text.

**Validation precedence.** A/B expressly prioritize caller-field validation, API-written-field validation, other local validation, then capability. Thus a malformed request or expired signed URL together with missing support receives the validation refusal first. This resolves previously unspecified combinations; it should not be described as preserving every implementation’s former first error. [OPS-23](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L2018) requires validation repeated “before the driver is called”; [OPS-40](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L744) requires the claim-time URL failure “before any provider mutation and before rescue is entered.”

Machine eligibility remains separate: [DOM-13](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/01-domain-model.md#L401) says “The gate reads the machine’s own copy of that list.” Neither candidate turns an eligibility entry into a capability declaration. Catalogue installation also retains [RSC-41](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/06-rescue-install.md#L503)’s later obligation: “On re-acquiring the machine the operation MUST re-validate before the rebuild.”

**Cancellation precedence.** Consider an exhaustion cancellation already queued when support disappears:

- Renewed funding: [OPS-41](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L978) requires the worker to “make no provider call, settle the operation `succeeded`” when the re-derived runway is future. A/B take this branch without checking capability.
- Open restore grace: [OPS-41](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L996) says the claim “defers, and writes no fence.” Missing support does not replace that defer with failure.
- Gone machine or closed episode: [OPS-41](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L1080) says “settles the attempt `succeeded`”; A/B preserve that no-call branch.
- Proceeding cancellation: capability follows the acknowledged fence transaction. Failure stalls the attempt’s episode without clearing its fence, matching [OPS-48](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L1300)’s `failed` row: “`stalled`” and “**Unchanged**.”

A’s important additional cost is **operator retry admission**. Start with a never-fenced stalled episode, fund the machine, then retry while `delete_machine` is unavailable. A refuses before enqueue, so no worker reaches the funded no-call success. B allows that decision. This is a real restriction on access to the success path, even though A preserves its order once an attempt reaches execution. I accept A as an explicit admission-policy choice, not as observationally equivalent to B. I do not claim this alone falsifies [CNF-312](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/10-conformance-checklist.md#L2558), whose fixture specifies “no other admission refusal.”

**Same PTR and markers.** [PRV-25](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/02-provider-contract.md#L855) places comparison “After the ordinary authorization, capability and `API-16` validation.” Missing support therefore still prevents identical-PTR success; A/B do not newly delete that success’s prerequisite.

Capability refusal before rescue leaves the rescue marker null and produces `failed` with `rescue_exit: none`, preserving [CNF-302](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/10-conformance-checklist.md#L3049). A survived stop before dispatch remains a different error: [OPS-21](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L1805) says “The recorded error is a cut-off `conflict`.” The new checks do not authorize replacing that stop record with `unsupported`, setting markers early, or changing crash recovery.

The strongest argument for C is that the existing outer pre-driver gate already protects dispatch, while mandatory admission rejection adds little protection and prevents requests from benefiting from changed worker configuration. That is a policy argument for leaving placement open—not evidence that deterministic placement already exists.

**Q2**

| Exact form | Verdict | Assessment |
|---|---|---|
| Q2-A | CANNOT ACCEPT | Its disclosed absent-offer change also conflicts with an unchanged formal admission verdict; the complete form supplies no corresponding formal amendment. |
| Q2-B | ACCEPT | Preferred among the complete printed forms. Preserves early refusal by adding an explicit, consequential account-shape restriction. |

**Q2-A’s additional collateral change.** The relevant omission is in [Admission.lean](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/tools/formal/Provisiond/Admission.lean#L1180). Its input is explicitly whether the account declares the create’s ordering capability. `undeclared_ordering_stops_before_tail` proves an unsupported refusal with no tail “regardless of the tail’s snapshot inputs.” [The composition’s documentation](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/tools/formal/Provisiond/Admission.lean#L1203) explicitly includes offer absence and an empty offers set. `age_preserves_step_5d`, at line 1252, preserves that result at every age.

Concrete counterexample:

1. Neither provisioning capability is declared.
2. The account is healthy; no stored listing exists.
3. Other early checks pass.
4. The existing formal composition, with `orderingDeclared = false` and `offerSellable = false`, returns `unsupported`, with no tail.
5. Q2-A skips the capability check and returns the collected `offer_not_sellable` result.

Neither provisioning capability being declared makes the Boolean false whichever machine kind might be selected; this does not require guessing one from the offer ID. Passing `true` merely to reach the tail would change the documented meaning of the input.

This is broader than the explicitly disclosed CNF-55 fixture qualification. It changes a checked verdict and needs a substantive formal amendment. [AGENTS.md](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/AGENTS.md#L12) requires “Change the declaration and the Markdown together.” A’s exact landing text does not do that. I inspected these definitions; I did not run Lean.

This finding does **not** establish that the absent-offer policy is intrinsically wrong. Nor does it contradict the fixed panel-E settlements: A preserves collected-refusal ranking and keeps age after collection. It establishes that A is not complete as printed. I am not voting for an unprinted repair.

Apart from that blocker, A’s proposed behavior is coherent:

- Present offer: select its kind from the same stored snapshot, independent of age; only the matching provisioning capability matters.
- Absent offer/no listing: skip selection; collect absence, with unhealthy account first when applicable; suppress cap/balance.
- Restart: use retained kind before List offers. Missing/corrupt kind receives [OPS-23](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L2027)’s API-written-field result, `conflict`/`incomplete_record`, retryable.
- Live absence or changed kind: reject after List offers without price comparison or mutation. The mismatch rejection is an additional safety rule.
- Mixed account: supported without interpreting provider `kind` as machine kind.

**Q2-B’s behavior and cost.**

| Situation | B’s outcome |
|---|---|
| Matching capability absent; other capability present or neither present | Early unsupported refusal, including absent offer/no listing |
| Matching capability present; either alone or with both declared | Pass ordering gate; evaluate the existing tail |
| Healthy, fresh, present sellable offer | Eligible for admission if remaining checks pass |
| Unhealthy account, or absent offer, after passing ordering gate | Existing collected refusals and suppression |
| Old listing | Existing collected refusals retain precedence; stale refusal applies only after otherwise successful collection |
| Queued create; matching capability withheld before claim | Step-3 unsupported refusal, before List offers |
| `list_offers` withheld instead | Existing step-4 refusal |
| Live offer absent | Existing step-5 absent-offer refusal |
| Mixed account, invalid descriptor kind, retained identity changes kind | Configuration rejected before enabling |
| Live offer changes kind | Violates B’s explicit provider-output contract; B adds no separate runtime mismatch error |

Thus B preserves [CNF-55](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/10-conformance-checklist.md#L340)’s “no provider request, including no List offers read,” and [CNF-364](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/10-conformance-checklist.md#L140)’s distinct List-offers gate. Claim-time status and closure remain ahead of validation and capability because B replaces only step 3.

B’s restriction is **not already implied** by the current domain. [The provider-account definition](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/01-domain-model.md#L49) describes configured credentials and a stable identity; it does not require one machine kind. I accept B’s explicit restriction as the cost of a total early source, but not on the argument that current launch drivers happen to be single-kind. It is unnecessary in principle: A demonstrates another design direction, though its exact patch is incomplete.

No supplied narrower form preserves mixed-account support, an unconditional absent-offer early refusal, and a total owned kind source. Achieving that combination would require another complete proposal. The strongest argument for leaving Q2 alone is limited launch exposure; it supplies neither a total source nor a resolved refusal order.

**Combined choice:** Q1-B governs non-create execution; Q2-B governs create selection. Neither relocates replay/security/ceilings, purchase-tail refusal ranks, or stored-listing age handling. No source, tracker, Git state, or panel record was changed; no builds, gates, subagents, or background work ran.
<!-- END VERBATIM R86 astra -->

<!-- BEGIN VERBATIM R86 sol -->
My final preferences are **Q1-A** and **Q2-B**. **Q1 needs a corrected re-ask under notes.md rule 6**: the brief omits an existing admission obligation that changes its premise. The assessments below are my individual answers, not a panel settlement.

I verified HEAD as `3109b5b44eae17e288cf52aaa976993bd8c5626c`, read notes.md and the supplied historical verification packet, and made no changes or build invocations.

**Q1 exact-form assessments**

| Form | Assessment |
|---|---|
| Q1-A | **ACCEPT** |
| Q1-B | **CANNOT ACCEPT** |
| Q1-C | **CANNOT ACCEPT as the offered phase-discretion resolution** |
| Final preference | **Q1-A**, subject to the corrected re-ask |

The premise-changing omission is **OVR-2**: “the server MUST NOT accept an operation a provider has not declared support for.” [00-overview.md:22](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/00-overview.md#L22). The HTTP acceptance interpretation is supported by **OPS-1**’s “MUST respond `202 Accepted` with that record.” [03-operation-lifecycle.md:17](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L17).

Concrete Q1-B counterexample: an authenticated, otherwise valid hard-reset request names a provider account without `hard_reset`. B expressly enqueues it despite that missing capability, returns `202`, and later fails it in the worker. That violates OVR-2 before the otherwise-correct worker refusal occurs. This is a quoted normative blocking loss, not a missing new test.

Consequently, the question cannot treat admission refusal and claim-only refusal as equally permitted by the pinned set. **Rule 6 requires voiding Q1’s tally and re-asking with OVR-2 included.** My objections to B and C rest on this verified omission.

C’s literal no-edit action preserves OVR-2 and causes no new regression. I cannot accept its advertised resolution—leaving admission versus execution to implementations—because that freedom is already constrained. A corrected no-change argument acknowledging OVR-2 would be a different answer; I am not submitting it as an alternative form.

A supplies useful placement and precedence while retaining the outer gate required by **DOM-10**: “There MUST be no operation whose only gate is a driver-internal check.” [01-domain-model.md:515](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/01-domain-model.md#L515).

The operation coverage below follows DOM-10’s mapping table at that location:

| Operation | Assessment of A’s proposed treatment |
|---|---|
| Power on/off/reboot; hard reset | `power_control` and `hard_reset`, respectively; admission check and worker recheck use their running descriptors. |
| `provider_native` + `catalog` | `native_rebuild`; no rescue prerequisite is invented. |
| `rootfs_via_rescue`; `raw_disk` | Their respective strategy capability, then `rescue_ssh`, before rescue. No separate power/reset capability is inferred: PRV-15 says begin rescue must “initiate the reboot or reset needed to enter it.” [02-provider-contract.md:722](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/02-provider-contract.md#L722) |
| `provider_catalogue` | `install_via_provider_catalogue`; the added check does not eliminate yielding during import. RSC-41 still requires import and polling “while **yielded**” and revalidation upon reacquisition. [06-rescue-install.md:503](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/06-rescue-install.md#L503) |
| Rescue inventory | `rescue_ssh`; refusal precedes its rescue marker. |
| Reverse DNS | `reverse_dns`, after local validation and before equality settlement. |
| Delete/cancel | `delete_machine`; exposure-reducing attempts retain the special ordered path discussed below. |
| Operator retry | Admission checks `delete_machine`; its fresh attempt repeats the worker gate if cancellation actually proceeds. |
| Attachment release | An operator’s API-cleanable request checks before admission and at claim. A delete-enqueued release checks at claim, without an enqueue gate. A manual release checks neither. A release does not inherit cancellation’s no-call exemption merely because its machine is gone. |

A changes the explicitly described API tail by adding a pre-enqueue refusal. A service returning `202` for already-known missing support, however, was already inconsistent with OVR-2. A also newly fixes local-check precedence: caller fields, API-written fields, other applicable validation, then capability. It preserves earlier validation refusals rather than replacing them with `unsupported`.

For an operator retry of a funded, null-fence episode with missing delete support, A rejects admission before a worker could close the episode through a funding abort. That observable difference must be disclosed. It concerns a new operator request; it does not replace an accepted system attempt’s required claim-time success.

The critical worker paths remain intact:

- **Restore grace:** OPS-41 says a claim under null/future grace “defers, and writes no fence.” A’s capability check follows that decision, so missing support cannot turn this defer into terminal failure. [03-operation-lifecycle.md:997](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L997)
- **Gone/closed and renewed funding:** OPS-41’s first applicable step decides; its gone/closed branch “settles the attempt `succeeded`,” and its funded branch performs the “no-mutation abort.” Both bypass A’s capability check. The paused-grace and no-rate deferrals likewise remain deferrals. [03-operation-lifecycle.md:1075](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L1075)
- **Proceeding cancellation:** only after an acknowledged fence transaction can missing support fail the attempt. OPS-48’s deterministic-failure row gives `stalled` and fence “**Unchanged**”; A preserves that disposition and authorizes no timer retry. [03-operation-lifecycle.md:1295](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L1295)
- **Stopped before dispatch:** CNF-312’s survived-stop prefix still requires “`failed` with cut-off `conflict`” before the fence; its crash prefix still requires startup `needs_reconciliation`. Capability placement does not replace either prefix. [10-conformance-checklist.md:2558](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/10-conformance-checklist.md#L2558)
- **Same PTR:** PRV-25 places equality comparison “After the ordinary authorization, capability and `API-16` validation.” A preserves the supported no-call success; missing capability remains a refusal. [02-provider-contract.md:855](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/02-provider-contract.md#L855)
- **Install markers:** OPS-45 requires rescue `false` “before begin rescue … is dispatched.” A refuses before that write, preserving CNF-302’s capability-refusal outcome: `failed`, `rescue_exit: "none"` and a null rescue marker. [03-operation-lifecycle.md:1493](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L1493), [10-conformance-checklist.md:3049](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/10-conformance-checklist.md#L3049)

A keeps system enqueue distinct, including suspension children and delete-generated attachment releases. It adds no non-purchase money gate.

**Q2 exact-form assessments**

| Form | Assessment |
|---|---|
| Q2-A | **CANNOT ACCEPT as the complete printed form** |
| Q2-B | **ACCEPT** |
| Final preference | **Q2-B** |

A’s stored-kind design handles present offers and queued restarts coherently. Its absent-offer exception nevertheless changes a formalized verdict beyond the expressly named CNF-55 fixture amendment.

The checked model defines the supplied Boolean as whether the provider account declares the create’s ordering capability. Its theorem **`undeclared_ordering_stops_before_tail`** returns `{ refusal := some .unsupported, tail := none }` for **every** tail input. [tools/formal/Provisiond/Admission.lean:1180](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/tools/formal/Provisiond/Admission.lean#L1180). The same file expressly includes offer absence and no stored listing in those supplied sale inputs: “There is no separate no-row refusal or presence policy here.” [Admission.lean:1203](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/tools/formal/Provisiond/Admission.lean#L1203). **`age_preserves_step_5d`** preserves that early result at every age. [Admission.lean:1251](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/tools/formal/Provisiond/Admission.lean#L1251)

Concrete trace: a healthy provider account declares neither provisioning capability, and no listing is stored. A skips the ordering check and reaches collected `offer_not_sellable`; the pinned formal composition returns early `unsupported` without collection. With an unhealthy account, A instead makes the account refusal the collected headline.

This does not permit a purchase or spend money. It **does bypass the early-refusal guard’s checked precedence**. A needs a substantive presence-aware model amendment and corresponding theorem changes. AGENTS.md requires “Change the declaration and the Markdown together.” [AGENTS.md:14](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/AGENTS.md#L14). The printed form supplies none. Reinterpreting `orderingDeclared` as automatic success for absence would also change its documented meaning.

Thus A’s absent path has an additional formal collateral change, beyond its disclosed fixture/phase amendment. I do not classify this candidate incompleteness as another premise-changing error that voids Q2.

A’s remaining proposed outcomes are sound in isolation: retained-kind loss/corruption becomes the API-written `incomplete_record` failure before provider requests; capability withdrawal remains before List offers; live absence fails after the read; opposite live kind newly fails before price comparison or mutation. That consistency refusal is a substantive addition needed to avoid dispatching using a different kind from the one whose capability was checked.

B preserves the existing early result using an explicit new source. Its proposed descriptor restriction is a real domain cost, which I accept deliberately—not an existing prohibition inferred from launch drivers.

| Case | B’s proposed result |
|---|---|
| Present offer; both capabilities | Select only the capability matching descriptor `machine_kind`; proceed to the existing tail. |
| Only matching capability | Same gate result. |
| Only the other capability, or neither | Early `unsupported` naming the matching capability. |
| Absent offer/no stored listing | The same capability gate still runs; after it passes, ordinary absent-offer collection applies. |
| Unhealthy account | Missing capability still stops before collection; otherwise the account refusal leads the tail. |
| Old listing | Missing capability still refuses early. After a passing gate, collected refusals retain precedence; an otherwise clean stale purchase gets the existing retryable `provider` refusal. |
| Mixed-kind account; invalid/missing descriptor kind; changed kind under retained identity | Configuration refusal before enabling that provider account. |
| Restart before claim with matching capability withheld | Step 3 refuses before List offers, preserving CNF-55. |
| Live offer absent | Existing step-5 refusal and pre-order release apply. |
| Live offer changes kind | A successful opposite-kind List offers result is forbidden by B’s proposed PRV-44 contract. B does not specify A’s dedicated mismatch error for a driver breaching that contract. |

The pinned claim ordering remains “caller-supplied fields … then … fields the `api` wrote … then the capability gate,” followed by “Gate on `list_offers`.” [03-operation-lifecycle.md:788](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L788). B changes the kind source without moving those gates, status or channel closure.

B also retains the stored-listing policy and header default. API-7’s age refusal applies only “If the tail has collected no refusal”; neither an unhealthy-account refusal nor an absent-offer refusal is displaced by age. [04-api-contract.md:264](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/04-api-contract.md#L264).

**Requested counterarguments, separate from my votes:** For leaving Q1 alone, the strongest argument is that OVR-2’s admission obligation, DOM-10’s pre-driver obligation and OPS-23’s repetition obligation already establish the essential safety requirements; detailed non-create failure ordering could remain unspecified. For leaving Q2 alone, the strongest argument is avoiding persistence/configuration expansion for a latent launch-driver case. That leaves the general contract gap unresolved; it supplies no total mixed-account or absent-offer kind source.

I see no complete smaller form preserving mixed-account support **and** unconditional capability-first absence behavior using only the quoted existing sources. It must amend absence precedence, add an owned total kind source, or restrict provider-account shape. I submit no alternative landing text.

Together, **Q1-A + Q2-B** apply to separate operation classes. Their API changes compose without moving replay, security or ceilings, and without changing purchase-tail ranks or the stored-listing age decision. My acceptability sets are **Q1 `{A}`**, pending the corrected re-ask, and **Q2 `{B}`**. No other reader’s vote or panel settlement is inferred.
<!-- END VERBATIM R86 sol -->
