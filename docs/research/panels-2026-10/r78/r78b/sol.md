**S-STOP-R: ACCEPT. Final preference: S-STOP-R.** This accepts the complete S1–S4 package, including its declared behavioural expansion of conformance coverage. No repair or additional condition is required. This is one reader’s vote, not implementation authorization.

Reviewed pin: `cebdc4f8f728f40d7fdf3c10ed094a1a7d2b8527`. Saved [sol.draft.md](/var/tmp/provisiond-panel-r78/r78b/sol.draft.md).

**apply notes.md rule 6 exactly as written; this prompt adds no void rule.** No verified error changes this question’s premise.

**Strongest actual argument.** The acknowledged survived-stop record reaches the same failed/stalled/null-fence decision boundary through a different real lifecycle. Testing only crash recovery can miss an implementation that applies the retry rule only after operator resolution. The new prefix exercises that distinction without adding runtime classification. The suspension selectors now consistently require both prefixes, and the complete-item replacement retains the deciding transaction’s read/commit instrumentation literally. These resolve the substantive r78 objections.

**The selected trace is supported.** A sweep opens the episode and enqueues its attempt together: `OPS-48` says “with its first attempt enqueued in the same transaction”. The worker claims it; the originating stop arrives during cancellable `execute`, before sending the first fence transaction. This excludes a fence write whose reply merely disappeared. It requires executable fault placement, not a manually constructed stalled row.

`OPS-21` says “A cancellation of `execute` that the engine survives MUST be recorded before the engine exits” and “The record write MUST NOT be cancelled by the cancellation that stopped `execute`”. Its record uses `OPS-22`, whose settlement guard requires the operation still be “`running` under the worker’s claim number”. The separate generation check remains: `OPS-50` requires the transaction to “read `STO-59`’s row `FOR SHARE` as its first statement”. S1 selects acknowledgement within both existing bounds, without a later stop or superseding generation. Store availability alone would not establish timely acknowledgement.

The classifier is the aligned current rule, not an inference dated solely to the original stop amendment. `OPS-11`’s last row covers “any failure the worker records while `OPS-45`’s write-started marker is unset” and requires it to “MUST settle `failed`, whatever its kind”. Its goal-state priority, rescue condition and known-acceptance exclusion remain. At this fresh pre-fence boundary no mutation was dispatched or accepted and no rescue session opened. `OPS-45`’s delete marker row says “the provider call is dispatched”. The original marker therefore remains null.

The error already exists: `OPS-21` supplies “a cut-off `conflict` with `details.reason: "cut_off"`”, and `WIR-9a` includes `"cut_off"` in conflict reasons. No extra payload or retryability assertion appears. `OPS-48` maps the failed attempt to stalled with fence “**Unchanged**” and explains “An episode none of whose attempts reached the fence transaction holds null.” The acknowledged settlement therefore produces failed/stalled/null-fence/null-marker/no-provider-call without operator resolution.

The retry is a fresh attempt: `API-64` says it “enqueues a fresh `delete_machine` attempt”. `OPS-41` supplies the decision: “A retry reading the fence null decides from step 3 unless the tenant is suspended now.”

| Selected case or control | Assessment |
|---|---|
| Order A, both prefixes | The extension commits before the deciding transaction. The funded abort gives succeeded/no mutation, closed/funded, null fence and no provider call. Cancellation does not release its commitment; independent metering remains allowed. |
| Order B, both prefixes | The unfunded deciding transaction commits its fence first. The later extension receives 409/cancellation_committed without attributable money movement or commitment growth; deletion proceeds. |
| Suspended/null fence, both prefixes | Each fan-out joins the existing episode and failed attempt. The retry reads current suspension; favorable re-derivation does not cause a funding abort, and the provider is called. |
| Fenced/provider-failed control | Retains the committed episode fence despite favorable funding; retry calls the provider again. |
| Fenced/undispatched control | Retains the episode fence while the previous attempt’s marker is null. It catches using that marker as the retry exemption. |

The suspension observations have an owner: `API-58` says the pass “MUST NOT enqueue”, must “append `tenant_suspended` to that episode’s `reasons` set”, and “name its `current_operation_id` in `cancellations`”. The driving instruction, fan-out selector and suspended table row now agree. Fenced controls retain their separate prefixes. Restore scope remains inspected, with the existing claim gate preceding the ordered decision; S1 claims no restore rehearsal.

**Formal boundary.** I inspected `failBeforeFence`, `finish`, `applyRow`, `Tables.episodeStep`, `interrupted_retry_prefix_witness`, `extension_first` and `StopRecord.working_store_records`.

The failure event matches holding plus an attempt and calls `finish w n a .failed .failed`. `finish` uses the claim-model worker write; `applyRow` uses the table, whose attempting/settled-failed case returns stalled without clearing the fence. The existing witness evaluates the abstract failure prefix to stalled/null fence. `extension_first` retains its null-fence, rate, funding, suspension and policy-guard hypotheses without requiring reachability.

`StopRecord.working_store_records` separately assumes a running row, claim ownership and positive budgets and evaluates an acknowledged store event. It does not connect its schedule to Fence. S2/S4 expressly disclaim composition and take the landed failed record at the abstraction boundary. Their claims need no new composed theorem. The larger abstract failure trace set remains. An in-memory comparison confirmed S4 changes only block comments, preserves the tagged definition literally and introduces no CNF identifier.

**Removed statements and retained protection.** The old CNF tail’s `OPS-45`/`OPS-23` discussion prevented treating classification or pre-driver validation as proof of an ordered pre-fence failure. Those owners remain unchanged; the survived-stop boundary supplies the selected injection. Removing “drive route 1 alone” is the declared coverage expansion. The store-error warning and read/commit instrumentation remain.

S2/S4 replace the obsolete assertion that no specified injection exists while retaining over-approximation and proof limits. S3 preserves the old paragraph, its owner quotation “Covers all three routes”, and rejected alternatives under an explicit historical annotation. Its earlier crash/restore description is now non-exhaustive. I found no changed, unreachable or vacuous baseline verdict and no lost MUST/SHOULD under rule 3.

The other exits survive. `OPS-49` still requires “the component MUST repeat the **whole transaction**” and, on exhaustion, “the engine MUST exit non-zero”. `OPS-21` says of its independent bounds “whichever ends first ends the record”. `OPS-50` warns “an earlier attempt may already have committed with its reply lost”. These exits do not universally imply a running row and cannot substitute for S1’s acknowledged-success prefix. `OPS-47` retains “The loss is not a later stop”.

**Exact repairs: none.** Rules, examples, scope and acceptance criteria agree. The actual-landing-date substitution is already instructed; this review invents no date.

**Requested strongest counterargument — not my vote.** `CNF-362` already exercises stopped deletes before their marker write. Repeating the retry cases after an equivalent durable state adds execution cost and catches code that wrongly depends on lifecycle provenance. That is a real prioritization argument. It does not make this coverage redundant: stop recording, recovery resolution and their retry handoffs are different integration paths. My preference remains S-STOP-R.

**Brief errors and rule-6 effect.** S3’s snapshot is described as the “exact original”, but `check/adr0032-before.md` is 4908 bytes versus 4907 at the pin: one extra terminal newline. Its text matches. This artifact-description error changes no premise and voids no tally; my vote does not depend on its byte identity. I established no other broken current brief claim. Raw tracker comments were not consulted; historical owner words were checked against the pinned ADR and preserved candidate text.

**Policy and costs.** This stays within ADR-0032’s fence-keyed decision and ADR-0046’s marker classification. The success boundary and fixture selection are declared behavioural conformance changes, without new runtime duties, fields, retryability, serialization or proof mechanisms.

Costs include additional executions of the selected rows, deterministic stop-before-send placement, record/marker/fence observations, transaction-order instrumentation and restart orchestration as needed. Prose and Lean supply none of that apparatus. No new classification or fence policy decision is needed. Adoption of this coverage and its execution cost remains with the owner.

**Checks and limits.** Initial and final unpiped `nix develop --command bash tools/check-all.sh` both exited **0**, all gates PASS, including Lean and axiom policy. They checked the unchanged pin, not execution of these fixtures. No candidate was applied; no runtime fixture, composed proof or standalone CI mutation matrix ran.

An initial diff probe assumed the next identifier was CNF-313, and one search used nonexistent API/ledger filenames; both were corrected. No gate failed. Memory caps matched the request. Codex prepended bundled PATH entries; gate/probe commands explicitly restored npm-global first and panel TMPDIR.

The clone remains clean and detached at the pin. No source edits, tracker writes, branch changes, commits, pushes, delegation, production access or credential/session/config reads occurred. No adoption, Run or further round follows.