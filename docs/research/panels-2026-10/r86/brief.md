# r86 — triage-1027 Panel G: capability placement and create kind

Read this brief and `/var/tmp/provisiond-panel-r86/notes.md` whole. Your independent clone is pinned to **origin/master 3109b5b44eae17e288cf52aaa976993bd8c5626c**. This is a launch-only reading round on Q1 (`pv-5pmu`) and Q2 (`pv-e45e`). No candidate has been applied. No question was dropped: the pinned owners quoted below retain both gaps. The original triage rows and committed bead records are in `check/verification.md`, supplied as historical evidence, not as authority over the pinned requirements.

Read-only: do not change source, Git state, tracker or panel records; do not commit, push, checkout, reset, stash, clean, contact a PR or start subagents/background work. **Run no lake build, Nix gate, or other command that starts Lean.** The manager runs the before/final gates separately. Temporary verification files may be written only under `/var/tmp/provisiond-panel-r86/tmp/` in your reader-specific subdirectory. Do not read credential/session/config locations (`~/.claude`, `~/.codex`, `~/.grok`, authentication files, kubeconfig, browser profiles), other readers' output/clones, the main checkout, or other panel folders. The excerpts in this packet and pinned files in your own clone are the evidence. Return a substantive final answer within the 3600-second launcher limit; aim for <=2200 words plus any exact replacement. Do not wait on other readers.

**apply notes.md rule 6 exactly as written; this prompt adds no void rule.**

The owner's settling sentence, verbatim: "a question is settled when at least three agree and more agree than disagree, and a tie comes to you. If grok is down, it falls back to three of four".

## Fixed scope and earlier decisions

The task is the Panel G grouping in `/var/tmp/provisiond-manager/triage-1027/table.md:80`: "Q1 `pv-5pmu` non-create admission/claim placement; Q2 `pv-e45e` the source of create kind before either ordering gate. Respect PR #26's stored-listing policy and all three panel-E settlements."
The rows ask the questions but choose no candidate. Forms Q1-A and Q2-A are concrete ways to answer those questions; no preference is attributed to triage.

Main's three panel-E settlements, verbatim from `/var/tmp/provisiond-manager/HANDOFF.md:201–204`:
- "the unhealthy-account `409 state` precedence is kept ahead of the new stale-listing refusal;"
- "astra's "no age refusal" form was dropped, because it contradicts the owner's stored-listing age setting;"
- "the Form H checklist header default replaced per-item fixture amendments (accepted 4–0)."

These constrain every candidate. Admission uses a stored listing, with no new provider call. No candidate changes the purchase-tail refusal ranks or moves the age refusal ahead of a collected refusal. Claim-time status, closure, validation, ordering-capability and `list_offers` precedence is retained. The existing unsupported error remains owned by `DOM-10`, not copied as a second taxonomy. The exact existing create checks are quoted below. Candidates are substantive proposals, not claims that their added rules already exist. Do not weaken an existing test silently: identify any verdict a candidate changes, and whether that is required to answer the question.

## Q1 — non-create operations: reject before accepting, when executing, or specify no extra phase?

### Plain-terms failure story

A customer asks to hard-reset a machine. The current provider configuration lacks that ability. One service rejects the request immediately; another returns an operation id and rejects it only when a worker takes it. A worker restarted with changed provider configuration also needs a rule for a previously accepted request. A system cancellation has no HTTP admission request, and may discover that the customer has already paid to keep the machine; rejecting it for missing provider support before checking that fact could replace an already-defined no-call success with a failure. These are placement and precedence choices, not a new error category.

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

Use the exact same `API-7` and `OPS-23` pointer insertions printed under Q1-A. No create gate moves. This is narrower than Q1-A in admission obligations, while still settling the worker's phase and ordering.

### Complete candidate Q1-C — no change

Make no source, checklist, descriptor or persistence edit for `pv-5pmu`. Keep `DOM-10`, `API-7` and `OPS-23` exactly as quoted. The mandatory outer pre-driver capability check remains; the set adds no requirement to reject a non-create at HTTP admission and no new ordering among its local checks. This is a real minimal option only if leaving that phase choice to implementations is acceptable. Do not count it as having specified a deterministic cross-implementation failure order.

### Q1 question

For each Q1-A, Q1-B and Q1-C, return ACCEPT or CANNOT ACCEPT on its exact whole form, and a separate final preference. Cover power and hard reset, each install strategy and the rescue_ssh prerequisite, rescue inventory, reverse DNS, delete/cancel, operator retry and both attachment-release origins. Distinguish a request from a system-enqueued child. Check the cancelled-before-dispatch, restored-grace, renewed-funding, same-PTR and marker cases against the actual owners. Does an added gate bypass a successful no-call branch, turn a defer into a terminal failure, or move a local validation refusal? If you need a different form, print every exact substitution/insertion; a sketch or merged unread repair is a distinct unsettled form.

## Q2 — the create's machine kind before the ordering-capability gate

### Plain-terms failure story

A customer names an offer id, without specifying whether it buys a virtual or dedicated machine. A provider account could offer both. To reject an unsupported purchase before accepting it, the service must know which of those abilities this offer needs. The present steps check that ability before their described offer read. If the offer is absent, there is no offer kind to read. At execution the same ordering problem occurs before the live list read. The choice is where that kind comes from, what an absent offer does first, and whether the contract explicitly excludes mixed-kind accounts.

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

A no-change Q2 form has not been drafted as a solution: the quoted passages supply no total existing kind source for the mixed/absent cases. If you believe no change is defensible, quote the exact existing total source and refusal order or explicitly propose leaving the gap unresolved; do not substitute the provider's `kind` for the offer's machine kind.

### Q2 question

For Q2-A and Q2-B, return ACCEPT or CANNOT ACCEPT on each exact whole form and a separate final preference. Verify present/absent/no stored listing, healthy/unhealthy, old/fresh listing, both provisioning capabilities/one/neither, mixed-kind account, restart before claim, missing/corrupt retained kind (A), and live offer absence or kind change. Preserve CNF-55's no-List-offers refusal for a queued create whose ordering capability was withheld. Would A's absent-offer path violate a prior owner ruling beyond the explicitly named fixture/phase amendment? Would B add an unjustified domain restriction? Is there a complete narrower form that preserves both mixed-account support and the early refusal without inventing an unowned source?

## Return shape and adversarial pass

Give Q1 and Q2 separate explicit final picks and exact-form acceptance tables. Follow notes.md counting rules. For any alternative, print the full exact landing text and substitutions, not a sketch. Trace at least one concrete failure sequence per disputed form, with the relevant quoted requirement and path:line at the pin. Separate a requested counterargument from your own vote.

Ask where the brief is actively wrong, whether a smaller form is sufficient, and give the strongest argument on request for leaving each gap alone. If a form deletes or bypasses a guard, name what it protected and any tested or normative verdict lost. Cross-check the two chosen forms together: Q1 governs non-create only; Q2 governs create only, while API-7's existing replay/security/ceilings and the stored-listing decisions remain ahead of their stated tails. A manager synthesis no reader has accepted as a whole will need another round. Do not implement the candidates, run builds, or edit tracker state.
