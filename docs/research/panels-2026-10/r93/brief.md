# Panel N r93 — pv-5pmu owner item 16: exact wording and archive treatment

Read this brief and `/var/tmp/provisiond-panel-r93/notes.md` whole. This is a launch-only reading round. Your own clone is detached at master **3d1fca55e64056e5ad6bc9ac3edcc308ecf04073** (PR #55); its fetched `origin/pr53` is **fde983c1794e8d4727f22bc87d1d6ee7f407eca5**, the PR #53 text under review. These are different refs. Source quotations must match master at the pin, byte for byte, including line breaks and indentation. No question was dropped: master has not applied the adopted Q1-A paragraphs.

Read-only: do not change source, Git state, tracker or panel records; do not commit, push, checkout, reset, stash, clean, contact a PR, run br, or start subagents/background work. No `lake build` or gates: the manager runs gates in a separate clone, and this shared host permits at most two lake builds. Temporary verification files may be written only under `/var/tmp/provisiond-panel-r93/tmp/<your-seat>/`. Do not read credential/session/config locations (`~/.claude`, `~/.codex`, `~/.grok`, authentication files, kubeconfig, browser profiles), other readers' outputs/clones, the main checkout, other worktrees, or unrelated material. Spec reads must use your own reader clone or `git show` in it. Historical evidence supplied below is permitted. Return a substantive final answer within 3600 seconds; aim for <=2400 words plus exact replacement text and the assertion map. Do not wait for other readers.

**apply notes.md rule 6 exactly as written; this prompt adds no void rule.**

Only pv-5pmu's adopted wording and its historical/executable copies are in scope. PR #53's other beads are out of scope. No text is applied, no tracker is changed and no PR is contacted this turn. A split or unsettled result gets ONE consensus round r93b in a later turn; do not launch it.

## The problem in plain terms

An approved instruction says that a repeated request returns its saved answer before a later support check, and that marking a manually released item needs no support check. Its two explanations cite existing rules without quoting them. A reviewer has stopped the preparation PR on that writing defect. We need exact text that preserves every approved instruction, and a place to record the correction without pretending the owner originally approved different words.

## Authority and stop evidence

The owner adopted exactly the original Q1-A, not a manager synthesis:

```text
16. **pv-5pmu (Panel G r86b Q1, picks 4–0 A, acceptance 4–0, owner approval of the added order)** — Q: "Panel G Q1
    (pv-5pmu): adopt A, the panel's exact wording for when support is checked and which error wins, or leave the text
    as it is?" A: **"Approve A (Recommended)"**. Option text: "Picked 4–0, accepted 4–0. All four readers (fable, opus,
    astra, sol) picked A: it settles the fence placement, the error order and the recheck order, which today's general
    rules don't spell out together. Exact form: r86b/Q1-A.md. Amends DOM-10, with pointers in API-7 and OPS-23."
    Rejected: "Keep text unchanged (C0)". Meaning: adopt exactly /var/tmp/provisiond-panel-r86/r86b/Q1-A.md (per
    r86b/owner-questions.md §1, pin 3109b5b). pv-5pmu → ready-for-agent with that package as its brief.

```

Read `/var/tmp/provisiond-panel-r93/evidence/owner-questions-original.md` §1 whole, `/var/tmp/provisiond-panel-r93/evidence/Q1-A-original.md` whole, and `/var/tmp/provisiond-panel-r93/evidence/agent-brief-original.md` whole. Verify the archive and Agent Brief against `git show fde983c1794e8d4727f22bc87d1d6ee7f407eca5:docs/research/panels-2026-10/r86/r86b/Q1-A.md` and the pv-5pmu row of `git show fde983c1794e8d4727f22bc87d1d6ee7f407eca5:.beads/issues.jsonl`; do not inspect the other beads. The archive equals the external r86b original byte for byte.

Read the merge stop's entire dated UPDATE and all its evidence files: `/var/tmp/provisiond-panel-r93/evidence/merge-stop-update.md`, `finding-reply.md`, `inline-comments.json`, `threads.json`, `stop-result.json` in that same folder. These are copies of the sources the current instruction names; no external action is requested. Finding URL: https://github.com/douglaz/provisiond/pull/53#discussion_r4429828636 . Its unresolved status is not a vote on a candidate. The quoted evidence reply uses display reflow; verify the actual quote bytes against the pin, not that reflow.

Owner's 2026-10-28 wording rule, from manager-brief.md PR handling:

> "For such wording questions, try to solve by getting a consensus of the panel"

The accompanying scope is: "when the finding touches only the WORDING of owner-adopted text (no behaviour, requirement or check-strength change), run the five-reader panel on the exact options and act on a settled result without asking." If a pick changes meaning or strength, name it: that change requires the owner. This turn only launches r93.

## Pinned source passages

The following blocks reproduce source bytes, not paraphrases. Consult surrounding text in your own clone where needed. AGENTS.md lines 29–32 must be read against the actual pin.

### `AGENTS.md:29–32` at `3d1fca55e64056e5ad6bc9ac3edcc308ecf04073`

```text
**Quote the sentence.** A claim about what another requirement says carries that requirement's own
words. `` `WIR-30` says "The gate reads the copy the machine took at create" `` is checkable;
"`WIR-30` forbids resolving eligibility that way" is an assertion, and assertions of that shape were
false repeatedly on 2026-09-03 — `ddd3df0` and `254fc24` carry the cases and what each one cost.
```

### `AGENTS.md:34–38` at `3d1fca55e64056e5ad6bc9ac3edcc308ecf04073`

```text
**Cite the owner.** One rule, one home; everywhere else points at it.
`07-security-requirements.md`'s scope note holds the argument, and `SEC-46` is the standing example
of a second copy drifting until an amendment shipped claiming to have applied while the requirement
said the opposite. **Arguments have owners too** — re-explaining a rule in a second document is how
a second normative copy gets written, because you cannot explain a rule without restating it.
```

### `AGENTS.md:45–46` at `3d1fca55e64056e5ad6bc9ac3edcc308ecf04073`

```text
**Completion:** every sentence asserting what another requirement says carries its quote, and every
list or count names its source instead of restating it.
```

### `00-overview.md:22–24` at `3d1fca55e64056e5ad6bc9ac3edcc308ecf04073`

```text
**OVR-2** Capability MUST be discoverable at runtime (`GET /v1/providers`). Clients
MUST NOT be required to infer support from a provider's name, and the server MUST NOT
accept an operation a provider has not declared support for. See `DOM-10`.
```

### `01-domain-model.md:515–541` at `3d1fca55e64056e5ad6bc9ac3edcc308ecf04073`

```text
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

```

### `04-api-contract.md:207–214` at `3d1fca55e64056e5ad6bc9ac3edcc308ecf04073`

```text
4. authorize the target resource against the tenant;
5. deserialize and validate the body;
5a. **compute the request fingerprint and check it** (`WIR-3`): an equal fingerprint under the
    same `(principal, key)` returns the stored result, a different one fails `conflict`. This step
    needs the parsed body, which is why it cannot live at step 3;
5b. **reject with `suspended`** if the tenant is suspended and this is not a maintenance action
    (`API-58`, `DOM-20`). **This is the only step that rejects for suspension** — step 2 passes a
    suspended tenant through on purpose. It sits *after* 5a deliberately: a write replayed from
```

### `04-api-contract.md:1102–1115` at `3d1fca55e64056e5ad6bc9ac3edcc308ecf04073`

```text
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
```

### `03-operation-lifecycle.md:2018–2034` at `3d1fca55e64056e5ad6bc9ac3edcc308ecf04073`

```text
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

```

## Adopted Q1-A, whole

Historical original from PR head `fde983c1794e8d4727f22bc87d1d6ee7f407eca5:docs/research/panels-2026-10/r86/r86b/Q1-A.md`. Do not treat the original's unquoted assertions as compliant merely because this packet displays them as history.

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



## Q1 — which exact replacement text?

Pick one complete candidate. Each pair replaces only the replay sentence and the manual-release clause, leaving the API-64 retry clause and all other Q1-A bytes unchanged. Read the full derived forms `/var/tmp/provisiond-panel-r93/Q-QUOTE.md`, `Q-POINTER.md`, and `Q-KEEP.md`; they make the complete reviewed form explicit. A new proposal is a distinct form: print its exact full replacements and do not claim other readers reviewed it.

### Q-QUOTE

Replay replacement, in full:

```text
API-7 step 5a says "an equal fingerprint under the
    same `(principal, key)` returns the stored result, a different one fails `conflict`."; a replay returned there never reaches this check.
```

Manual-release replacement, in full:

```text
API-65 says "On a row whose `cleanup` is `manual` there is no driver call to make: it
writes `released_at` and answers `200` with the row, minting no operation,"; a manual attachment release takes no capability check under this timing rule.
```

Each source attribution carries its source words. The final manual-release capability-check clause is expressly this timing rule, not an API-65 quotation. Assess whether the retained last paragraph and admitted operation scope supply that clause without inventing a new rule.

### Q-POINTER

Replay replacement, in full:

```text
For replay handling, see API-7 step 5a.
```

Manual-release replacement, in full:

```text
For manual attachment release, see API-65.
```

These are bare subject/owner pointers. They assert no replay or manual-release behavior; assess preservation through the unchanged timing after steps 1–5c, API-7 step 5a, and Q1-A's final "this timing rule adds no gate
to refresh, a manual attachment release, or the capability-less methods named by PRV-4." Do the pointers plus those retained rules preserve the explicit replay bypass and no-capability-check assertions?

### Q-KEEP

Replay replacement, in full:

```text
A replay returned by API-7 step 5a never reaches
this check.
```

Manual-release replacement, in full:

```text
API-65's manual release has no driver operation and takes no capability check.
```

Conditional option only: leave both strings unchanged and answer the bot with evidence ONLY if you demonstrate that AGENTS.md lines 29–32 do not apply here. Supported factual content alone does not demonstrate that exemption. Print the exact proposed reply if you choose it. No reply will be posted this turn.

## Q2 — where does the fix land?

Pick one landing candidate independently of Q1 and assess its record integrity. For Q-QUOTE or Q-POINTER, each landing applies the exact chosen Q1 pair once in the Agent Brief's Desired behavior block; every other existing Agent Brief byte stays unchanged unless the following explicit authority-line replacement applies. Nothing in a historical quotation of the former wording is silently corrected. Q-KEEP makes each landing a no-op, contingent on proving its exemption; explain whether Q2 then has any meaningful vote.

The existing Agent Brief authority line is:

```text
**Owner decision:** “Approve A (Recommended)” (`owner-decisions-1030.md`, item 16). Adopted exact form: `docs/research/panels-2026-10/r86/r86b/Q1-A.md`.
```

For each correcting landing below, replace that authority line exactly with:

```text
**Owner decision:** “Approve A (Recommended)” (`owner-decisions-1030.md`, item 16). Historical adopted form: `docs/research/panels-2026-10/r86/r86b/Q1-A.md`. Executable form: the Desired behavior / key interfaces block below, with the 2026-10-31 Panel N r93 wording correction.
```

- **L-BRIEF — Agent Brief only.** Apply the chosen Q1 pair and authority-line replacement only in pv-5pmu's Agent Brief. Retain the archived Q1-A byte for byte, without a note. Is this sufficient to keep both the historical approval and executable instruction honest, including the still-flagged archive on PR #53?
- **L-BOTH — Agent Brief and archived form.** Apply the chosen Q1 pair and authority-line replacement in the Agent Brief; apply the same exact pair in `docs/research/panels-2026-10/r86/r86b/Q1-A.md`. Add no dated note and leave the archive's title unchanged. Does silently changing the approved-form archive misrepresent the panel/owner record?
- **L-NOTE — Agent Brief plus dated archive note.** Apply the chosen Q1 pair and authority-line replacement in the Agent Brief; preserve every original archived Q1-A byte and append the complete dated note matching Q1: `/var/tmp/provisiond-panel-r93/note-Q-QUOTE.md` or `note-Q-POINTER.md`. Read both note variants whole. They are exact candidate appendices, including the complete replacements, source pin, review head and record pointer. A later apply turn may use such a note only after the form is settled and verified wording-only. Does this keep the approved historical record honest while making the operative correction unambiguous, and does retaining the historical offending sentences remain acceptable under AGENTS?

All landing candidates are prospective; no chosen text, note or panel result is committed this turn. The note's `../../r93/notes.md` assumes a later authorized archive of this panel under the existing month directory; assess this dependency and do not claim that file exists on the PR yet.

## Required answer

1. State **Q1 final pick** and separately ACCEPT / CANNOT ACCEPT for every exact Q1 form. Print your picked pair in full. Explain exactly where "takes no capability check" comes from: item 16's own timing rule or an identified other source. API-65 does not contain those words. Identify where your pick preserves that assertion, without calling it an API-65 quote. If your pick is conditional, state the condition and whether it is proved.
2. State **Q2 final pick** and separately ACCEPT / CANNOT ACCEPT for each exact landing. Give the chosen note in full if L-NOTE. Say which choice keeps the record of what the panel and owner actually approved honest.
3. For EACH pick separately, say WORDING-ONLY or MEANING CHANGE; assess behavior, requirement and check strength independently. Does the owner's 2026-10-28 exception settle it after consensus, or must it go to the owner? Historical-record integrity is part of this assessment. Do not conflate owner item 16's substantive original adoption with this correction.
4. Verify EVERY quotation you rely on byte for byte against the named pin or named historical original. Report exact source path:line and whether embedded newlines/indentation match; never silently reflow a quote then call it byte-identical. API-7 and API-65 source text and AGENTS are identical between the master pin and review head; verify this too. State failures explicitly.
5. Verify that your complete pick weakens NO assertion of Q1-A. Name each assertion and give its exact landing (unchanged span, replacement, pinned owning requirement, or archive provenance). Cover all paragraphs and API-7/OPS-23 pointers, existing mapping/error retention, admission timing and scope, replay bypass, operator retry, manual no-check, suspend children, worker/system enqueue scope, validation/failure precedence and classification, cancellation fence/no-call/defer/retry behavior, rescue/inventory/PTR/mapping, refresh/capability-less exclusions and no create-gate move. If a pointer loses an explicit assertion despite equivalent runtime behavior, disclose and judge that loss. Do not declare "nothing lost" without the map. If removing an assertion, name what it protects and any checked/normative verdict changed.
6. Give the strongest case against your picks, explicitly labelled requested counterargument rather than vote. Report any false premise or internal contradiction in this brief and whether it changes your reasoning. Do not weaken a disputed requirement to clear the finding. End with `Final: Q1=<label>; Q2=<label>; Q1=<WORDING-ONLY/MEANING CHANGE>; Q2=<WORDING-ONLY/MEANING CHANGE>`.
