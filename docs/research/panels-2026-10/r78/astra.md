Saved the complete review to [astra.draft.md](/var/tmp/provisiond-panel-r78/astra.draft.md).

Reviewed pin: `cebdc4f8f728f40d7fdf3c10ed094a1a7d2b8527`.

**apply notes.md rule 6 exactly as written; this prompt adds no void rule**.

| Question | Whole candidate | Vote | Preference |
|---|---|---|---|
| Q1 | K-EXACT | **ACCEPT** | **K-EXACT** |
| Q1 | K-FLOOR | **ACCEPT** | |
| Q2 | S-STOP | **AMEND** | **NONE** |

Neither question’s premise is void. I found no verified loss of an existing normative obligation, conformance verdict or theorem. S-STOP’s objection is inconsistent selection of its newly required fixtures. My proposed repairs are not panel-reviewed packages.

**Q1 — both packages prevent the disabling conversion.**

PostgreSQL documents integer rounding after unit conversion, integer millisecond settings, and zero disabling both timeouts. The supplied receipt is **PostgreSQL 17.9**: it supports the reported conversions and gives the accepted range as `0 ms .. 2147483647 ms`. I did not rerun that executable. As additional source evidence, I inspected **REL_18_6** setting declarations: both use `GUC_UNIT_MS` with bounds zero and `INT_MAX`. This is source inspection, not an 18.6 parser experiment or elapsed-time measurement. No checked evidence establishes a version-dependent difference in those declarations. [Units documentation](https://www.postgresql.org/docs/18/config-setting.html#CONFIG-SETTING-NAMES-VALUES), [timeout documentation](https://www.postgresql.org/docs/18/runtime-config-client.html#GUC-STATEMENT-TIMEOUT), [18.6 declarations](https://raw.githubusercontent.com/postgres/postgres/REL_18_6/src/backend/utils/misc/guc_tables.c).

K-EXACT requires the source duration to equal an accepted positive millisecond integer. K-FLOOR rejects durations below 1ms and applies their downward-rounded millisecond integer. Both refuse 400us and 600us. K-EXACT refuses 1500us; K-FLOOR accepts it and requires effective settings of 1ms. Those are different deployment contracts, explicitly disclosed by the brief.

Let M denote the settings’ common maximum in milliseconds. K-EXACT admits whole-millisecond durations from 1 through M. K-FLOOR admits finite durations satisfying `1 ≤ floor(t/ms) ≤ M`, including a fractional tail above M milliseconds but below M+1 milliseconds. That consequence follows from the printed rule. Wrapping an oversized value into range, converting overflow to zero, or accepting a non-finite input would violate it. The proposed outside-range whole-millisecond test is refused by both packages.

Equivalent spellings describe durations; they do not require forwarding the original string. For example, 1000us and 0.001s denote 1ms. K-EXACT’s unchanged OPS-15 sentence requires both settings to be “set to `OVR-19`’s Startup-lock wait bound”; serialization that changes the admitted duration would violate that requirement. K-FLOOR explicitly owns conversion in its replacement sentence and forbids forwarding 1500us for PostgreSQL to round upward.

OVR-19 already requires startup to “validate every startup-validated row and refuse to run on a missing or out-of-range value.” The type cell therefore owns rejection. A second numeric validation rule in OPS-15 is unnecessary. CNF-369 is the existing demonstration point, expanded with independent rejection attempts and effective-setting observations while preserving its held-share assertions.

Validation acceptance at 1ms does not promise successful startup under contention. The candidate correctly distinguishes those observations. Checking effective settings is a conformance obligation, not a newly mandated production read-back protocol.

Neither package requires a new formal transition or definition: no existing formal duration conversion owns this PostgreSQL serialization. Conversely, passing Lean establishes nothing about an implementation parser’s precision.

The protected operation is the generation replacement statement, including its lock wait. PostgreSQL documents `lock_timeout` per acquisition and notes that an equal `statement_timeout` generally triggers first. That does not remove the existing obligation to configure both. Neither candidate weakens OPS-15’s fatal handling of “any store error, including a lost reply on its commit”.

The standby limitation remains material. STO-7 says “A standby wait has no server-side timeout”. A SyncRep holder can block the generation replacement statement until that statement times out; a generation transaction reaching its own standby commit wait receives no new elapsed-time bound from these packages. Neither changes replication, generation ordering, startup-lock ownership or lost-reply treatment.

**Preference:** K-EXACT is the cheaper complete form already offered. It keeps the configured duration equal to the applied duration and avoids a separate normalization policy. Its stricter input contract remains an owner policy choice.

**Requested counterargument, not a vote:** K-FLOOR preserves usable fractional inputs at or above 1ms without applying a longer timeout than requested. Refusing 1500us provides no additional protection against a disabled timeout. If fractional configuration matters, the conversion obligation may be worthwhile. My K-FLOOR vote remains ACCEPT.

**Q2 — the survived-stop premise is supported, but the package is internally inconsistent.**

OPS-21 says “A cancellation of `execute` that the engine survives MUST be recorded before the engine exits”, subject to its stated exits. It also says “The record write MUST NOT be cancelled by the cancellation that stopped `execute`.” The originating stop is therefore distinct from a later stop during recording and from an ordinary store error.

The supported trace is:

1. A real sweep enqueues the cancellation; the worker claims and holds it.
2. An originating stop arrives during cancellable `execute`, before sending the first fence transaction.
3. The guarded record is acknowledged within the bounds, without supersession or a later stop.
4. The original attempt settles failed; its open episode becomes stalled; fence and marker remain null.
5. An operator’s fresh retry follows the existing ordered decision.

OPS-11’s delete row, at `03-operation-lifecycle.md:248`, covers “any failure the worker records while `OPS-45`’s write-started marker is unset” and requires it to “MUST settle `failed`, whatever its kind”, subject to the row’s rescue, known-accepted and goal-state conditions. At this fresh pre-fence boundary no provider mutation has been dispatched or accepted. OPS-45 places the delete marker when “the provider call is dispatched”.

OPS-21 specifies “a cut-off `conflict` with `details.reason: "cut_off"`”. WIR-9a’s conflict reason alternatives include `"cut_off"` (`OPS-21`) at `13-wire-contract.md:141`. No additional retryability or payload fields follow.

OPS-48’s relevant row is exactly:

> `failed` — deterministic; the provider did not act → `stalled` → **Unchanged**

Its explanation says “An episode none of whose attempts reached the fence transaction holds null.” The stop record can therefore settle failed/stalled without writing the cancellation fence. It is guarded settlement, not a dispatch transaction.

The fixture does not erase recording exits. OPS-22 requires the operation still be “`running` under the worker’s claim number”; zero affected rows cause exit. OPS-50 says “A refused generation check ends recording without another attempt”. OPS-21 says “whichever ends first ends the record” of its two bounds. A later stop may leave a sent transaction’s outcome unknown. Startup-lock loss itself does **not** necessarily prevent recording: OPS-47 says “The loss is not a later stop”.

OPS-49 still requires “the component MUST repeat the **whole transaction**”. A store error alone is not this classified-failure trigger. The retained crash route separately exercises OPS-15’s “MUST NOT move them back to `queued`” and subsequent operator resolution. Both routes remain necessary to distinguish survival from interrupted recovery.

The formal boundary is sound. `Fence.failBeforeFence` matches holding plus an attempt and invokes `finish w n a .failed .failed`. `finish` uses the claim write and episode transition; `applyRow` preserves the failed row’s fence. `Witnesses.interrupted_retry_prefix_witness` already includes sweep→claim→failBeforeFence and asserts stalled/null fence. `Fence.extension_first` uses the admitted extension’s null fence directly. No theorem needs weakening.

StopRecord’s schedule and Fence’s lifecycle are not composed. The Fence event accepts the durable outcome as input. The proposed limitation text correctly avoids claiming a composed cancellation proof or running-service evidence.

The defect is in S1’s retained instructions. Its new paragraph requires the suspended/null-fence case on **each prefix**, while the preserved suspension fan-out paragraph and table row explicitly select **route 1**. An implementer following the specific table can omit the new survived-stop suspension case. S3 also leaves the preceding exhaustive statement that established routes “are crash and restore”.

**Requested counterargument, not a vote:** The new “each prefix” instruction could be interpreted as overriding the older references. All expected outcomes are otherwise supported. Nevertheless, the complete fixture instructions should agree explicitly. Q2 preference remains NONE.

**Exact proposed repairs to S-STOP**

**R1 — behaviour changed: fixture selection.** Extend S1’s edit scope at `10-conformance-checklist.md:2475`.

Before:

> **Suspension fan-out:** from the route-1 prefix, suspend the tenant.

Replacement:

> **Suspension fan-out:** from a fresh instance of each selected prefix—route 1 and the survived-stop prefix—suspend the tenant.

**R2 — behaviour changed: fixture selection.** Same item, suspended/null-fence table row, line 2488.

Before:

> Use the route-1 prefix and suspension fan-out above.

Replacement:

> Exercise this row separately from each selected prefix, using its suspension fan-out above.

These preserve the existing observations while making the added coverage operative. They are not wording-only acceptance.

**R3 — behaviour unchanged: obsolete exhaustive description.** `docs/adr/0032-revival-is-an-operator-decision.md:30`.

Before:

> The established null-fence stalled routes are crash and restore through

Replacement:

> The crash and restore null-fence stalled routes run through

Keep the following quotation, restore argument and rejected alternatives.

**R4 — behaviour unchanged: source quotation.** S2’s proposed first sentence.

Before:

> `OPS-21` supplies the survived-stop pre-fence failure route; `CNF-312` owns its conformance prefix.

Replacement:

> For the survived-stop pre-fence route, `OPS-21` says "A cancellation of `execute` that the engine survives MUST be recorded before the engine exits"; `CNF-312` owns its conformance prefix.

Keep the model-composition limitation.

**R5 — behaviour unchanged: source quotation.** Replace these respective proposed sentences:

S3 before:

> A store error alone remains the `OPS-49` whole-transaction path.

S1 before:

> A store error alone remains `OPS-49`'s retry path, not a separate worker-recorded failure.

Replacement for each:

> For store errors, `OPS-49` says "the component MUST repeat the **whole transaction**".

Keep the surrounding fixture constraints.

**R6 — behaviour unchanged: quoted owner in formal explanation.** S4’s proposed module introduction, first sentence.

Before:

> `failBeforeFence` admits a worker-recorded failure before fencing, including the survived-stop route specified by `OPS-21`.

Replacement:

> `failBeforeFence` admits a worker-recorded failure before fencing, including a survived stop: `OPS-21` says "A cancellation of `execute` that the engine survives MUST be recorded before the engine exits".

Retain the following limitation sentences. Replace S4’s proposed declaration docstring:

Before:

> Worker-recorded failure before fencing, including `OPS-21`'s survived-stop route. Stop delivery and bounded recording are outside this model; `OPS-49` store errors alone are not classified by this event.

Replacement:

> Worker-recorded failure before fencing, including a survived stop: `OPS-21` says "A cancellation of `execute` that the engine survives MUST be recorded before the engine exits". Stop delivery and bounded recording are outside this model. For store errors, `OPS-49` says "the component MUST repeat the **whole transaction**"; that retry is not classified by this event.

No declaration, guard, theorem or witness changes. No CNF identifier enters formal files. Owner quotations and repository before-text anchors were checked directly.

**Brief errors and retained safeguards**

No verified brief error changes either premise under rule 6. The quoted stale assertions—OPS-41’s unspecified injection point, CNF-312’s route-1-only conclusion, ADR-0032’s “no current clause”, and Fence’s corresponding module/docstring statements—are the advertised Q2 defect, not misquoted evidence that voids the question.

S1’s incomplete replacement scope and S3’s retained exhaustive sentence are package errors supporting my AMEND vote. Neither Q1 vote relies on them.

No safeguard needs deletion. The store-error warning’s purpose survives through OPS-49. Crash recovery, no startup requeue, marker acknowledgement, generation/claim guards, bounded exits, current-suspension precedence, fenced controls, restore limitations and extension ordering remain. No checked verdict is lost.

**Checks and limits**

Both required unpiped `nix develop --command bash tools/check-all.sh` runs passed with exit 0 on the unchanged pin. One intervening final-gate invocation lost its output-session handle; its result was not counted and the gate was repeated. Final Git checks showed no source changes.

Other checks included the full notes, source anchors, declarations, quotation assertions, supplied parser receipt and official PostgreSQL sources. Initial filename mistakes produced read/search errors and were corrected; these were not gate failures.

Not run: candidate application or candidate gates, parser rerun, live database tests, timing measurements, implementation conformance, standalone CI mutation controls or a composed model proof.

Only the reader draft was written outside normal gate artifacts. No tracker writes, delegation, production contact, branch changes or adoption occurred. Owner policy choice and implementation authorization remain outstanding.