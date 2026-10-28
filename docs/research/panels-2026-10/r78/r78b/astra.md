**S-STOP-R, all of S1–S4: ACCEPT. Final preference: S-STOP-R.**

Reviewed pin: `cebdc4f8f728f40d7fdf3c10ed094a1a7d2b8527`. This accepts the complete printed form. **No repairs required.** S3 already requires the actual landing date; this review invents none.

**apply notes.md rule 6 exactly as written; this prompt adds no void rule.** No verified brief error changes the premise. No blocking loss under rule 3 was found.

The strongest argument is that the new prefix exercises an existing, distinct route into the retry decision. The crash fixture passes through startup classification and operator resolution. A build could accidentally enable the correct null-fence retry decision only after that resolution and pass the old fixture. S-STOP-R requires the worker-recorded route too, including current suspension, without changing the decision or claiming Lean verifies the concrete stop-to-retry execution.

**Trace and classification.** A real sweep opens the episode and enqueues its first attempt; a worker claims it. The originating stop arrives during cancellable `execute`, before sending the first fence transaction. This fresh attempt has reached neither provider dispatch nor its marker write, with no accepted mutation or rescue session. The fixture requires successful acknowledgement rather than inferring it from survival or store availability.

`OPS-21` says “A cancellation of `execute` that the engine survives MUST be recorded before the engine exits” and “The record write MUST NOT be cancelled by the cancellation that stopped `execute`” (`03-operation-lifecycle.md:1784`, `:1811`). Its error is “a cut-off `conflict` with `details.reason: "cut_off"`”; `WIR-9a` includes that reason (`13-wire-contract.md:141`). No extra payload or retryability field appears.

The relevant `OPS-11` row says “any failure the worker records while `OPS-45`'s write-started marker is unset” and “MUST settle `failed`, whatever its kind” (`03-operation-lifecycle.md:248`). Its goal-state precedence, rescue condition and known-acceptance exclusion remain. The delete marker boundary is “the provider call is dispatched” (`:1477`), which this prefix has not reached. The result follows ADR-0046’s 2026-10-23 alignment together with the survived-stop obligation; the earlier stop amendment alone is not its complete chronology.

The settlement is `OPS-22`’s write, guarded on the operation still being “`running` under the worker's claim number” (`:1898`). Generation checking remains: `OPS-50` requires reading the generation row “`FOR SHARE` as its first statement” (`:1983`). Neither guard requires writing the cancellation fence. `OPS-48` maps failed to stalled, fence “**Unchanged**”, and says “An episode none of whose attempts reached the fence transaction holds null” (`:1292`, `:1303`). Failed/stalled/null fence/null marker/no provider call therefore follows without operator resolution. A fresh retry follows `API-64`, admissible “only on an episode in `stalled`” (`04-api-contract.md:1050`).

Other exits remain. `OPS-49` requires “the component MUST repeat the **whole transaction**”; a store error alone supplies no classified failure. `OPS-21` says “whichever ends first ends the record” of the independent bounds. Later stops, exhaustion, lost replies and supersession cannot substitute for this acknowledged-success prefix. They do not universally leave running rows: `OPS-50` says “an earlier attempt may already have committed with its reply lost”. Lock loss is distinct: `OPS-47` says “The loss is not a later stop”.

**Rules, examples, scope and acceptance criteria agree.** S1 now changes both the fan-out selector and suspended/null-fence table selector. Its general instruction and specific row require separate fresh instances of each prefix. The previous round’s behavioural selector objection is resolved.

The preserved decision rows retain distinct purposes:

- **Order A:** extension commits before the deciding fence transaction; the retry succeeds without mutation, closes funded, leaves a null fence and makes no provider call or cancellation-driven commitment release. This rejects unconditional retry bypass.
- **Order B:** observe the episode fence before submitting extension; require `409`/`cancellation_committed`, no refused-extension money effects, and a provider call. This rejects a missing extension fence.
- **Provider-failed fenced control:** favorable re-derivation leaves the fence; retry calls the provider. This rejects funding re-check on every retry.
- **Fenced/undispatched control:** independently establish a null original dispatch marker alongside a committed episode fence. This distinguishes that fence from the previous attempt’s marker.
- **Suspended/null-fence:** each prefix performs its own fan-out, then re-derives funded runway while suspension remains current. The deciding transaction still calls the provider rather than closing funded. `OPS-41` says “A retry reading the fence null decides from step 3 unless the tenant is suspended now.”

Read/commit instrumentation survives literally; enqueue order is no substitute. The fan-out observations follow `API-58`’s “MUST NOT enqueue”, “append `tenant_suspended` to that episode's `reasons` set”, and “name its `current_operation_id` in `cancellations`” (`04-api-contract.md:685`). Existing timer, keep and fenced/resume controls remain selected by their checklist owners.

Restore remains inspected, not rehearsed here. The retained claim-gate quotation says “defers, and writes no fence”; the paused funding check is reached “Only if the predicate would cancel”. No restore exception or additional restore-conformance claim appears.

**Formal boundary.** `Fence.failBeforeFence` still matches holding plus an attempt and calls `finish w n a .failed .failed`. `finish` uses the claim write; `applyRow` uses `Tables.episodeStep`, whose attempting/settled-failed row yields stalled without clearing the fence. `interrupted_retry_prefix_witness` already checks the crash/resolution shape and abstract failure’s stalled/null-fence shape. `extension_first` retains its hypotheses, including null fence, funding at the deciding rate and current suspension handling.

`StopRecord.working_store_records` separately checks acknowledged recording under running-row, claim-ownership and positive-budget hypotheses. Fence and StopRecord are not composed. S2 and S4 explicitly preserve that boundary. The Fence event assumes a landed record and fixes failed; it takes no arbitrary outcome argument and still admits failures beyond this specified route.

No executable declaration, hypothesis, guard, witness or theorem changes. No CNF identifier enters formal files. A composed proof is unnecessary for the limited claims this form makes.

**Removed statements and safeguards.** “Drive route 1 alone” guarded against inventing an injection point; the concrete pre-send stop and acknowledged record now justify the declared expansion. The removed OPS-23/OPS-45 ordering discussion prevented treating generic validation or marker classification as a pre-fence trigger. Those owners remain unchanged; the new trigger has its own owner.

The store-error warning survives with quotations. S2/S4 retire the claim that no specified route exists while retaining the larger trace set and non-composition limits. S3 preserves the entire old scope paragraph, including “Covers all three routes”, under an explicit historical label. Its earlier crash/restore description becomes non-exhaustive. The fence-decision argument and rejected alternatives survive. No checked verdict is removed, made unreachable or made vacuous.

**Costs and authority.** Additional runs are the rows named by S1’s two-prefix instruction, with unchanged expected outcomes. Real pre-send stop injection, acknowledgement/deadline evidence, fresh-instance setup, restart orchestration and deciding-transaction instrumentation require implementation and test work. Prose and Lean supply none of that machinery.

The form stays within ADR-0032’s fence-keyed policy and ADR-0046’s marker classification; no new runtime policy decision is needed. Acceptance recommends the declared conformance cost. It does not authorize implementation, a Run or another round.

**Requested strongest counterargument — not my vote.** `CNF-362` already checks that a delete cut off before its marker settles failed, while the crash fixture exercises the same stalled/null-fence retry state. Extending only the prefix assertion, or running fewer retry tails, could cost less if implementation architecture demonstrably prevents route-dependent behaviour. That architecture has not been established here. The selected tails catch different mistakes; state equivalence does not prove an implementation uses only that state. My vote remains ACCEPT.

**Brief audit and evidence.** No broken current-brief claim was established. Before snapshots match the pin; S1’s advertised edit scope is accurate; historical-owner and larger-trace statements survive. Rule 6 does not void this question or alter this vote. Prior answers were treated as opinions, not acceptance by proxy. Owner quotations were checked against the retained ADR; raw tracker comments were not accessed.

I read the complete brief, notes, r78 tally and all five prior finals. Source files match `git show` at the pin, and supplied snapshots match their source spans. In-memory diffs confirmed S1–S3’s changes. S4’s anchors are unique; removing comments before and after substitution leaves identical executable text. Quotation checks accounted for whitespace, emphasis and nested quotation typography.

Initial and final unpiped `nix develop --command bash tools/check-all.sh` both exited **0**, every gate PASS. Both checked the unchanged pin; neither executed candidate conformance fixtures. No gate failed. Incorrect exploratory guesses for an ADR filename and two specification filenames produced read/search errors, then were corrected.

Not run: candidate application, runtime fixtures, implementation tests, a new/composed proof or the standalone CI mutation-control matrix. The detached clone remains clean at the pin. No tracker commands, branch changes, commits, pushes, subagents, production access or credential/session/config reads occurred.

Saved: [astra.draft.md](/var/tmp/provisiond-panel-r78/r78b/astra.draft.md).