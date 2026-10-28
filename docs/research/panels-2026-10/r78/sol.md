Saved the review to [sol.draft.md](/var/tmp/provisiond-panel-r78/sol.draft.md).

Reviewed pin: `cebdc4f8f728f40d7fdf3c10ed094a1a7d2b8527`. **apply notes.md rule 6 exactly as written; this prompt adds no void rule**.

| Question | Whole candidate | Vote |
|---|---|---|
| Q1 | K-EXACT | **AMEND**, verified quotation-only repair R1; behaviour unchanged by repair; counts ACCEPT under rule 1 |
| Q1 | K-FLOOR | **AMEND**, verified quotation-only repairs R1/R2; behaviour unchanged by repairs; counts ACCEPT under rule 1 |
| Q2 | S-STOP | **AMEND**, behavioural fixture repair R3 and quotation repairs R4; does not count ACCEPT of the printed package |

**Q1 preference: K-EXACT. Q2 preference: NONE.** I support survived-stop coverage, but that direction vote does not accept S-STOP as printed. The repairs below are proposals, not a panel-reviewed union. Neither question is void under rule 6. These are one reader’s votes; the owner’s threshold, unchanged no-verified-blocker rule and authorization boundary remain applicable.

**Q1.** The conversion risk is real. PostgreSQL documents integer timeout settings in milliseconds, zero disabling each, and conversion before integer rounding. ([Units](https://www.postgresql.org/docs/18/config-setting.html#CONFIG-SETTING-NAMES-VALUES), [timeouts](https://www.postgresql.org/docs/18/runtime-config-client.html#GUC-STATEMENT-TIMEOUT).) The supplied receipt identifies PostgreSQL **17.9**: both settings report 400us→0, 600us→1, 1500us→2 and 1ms→1; −1ms is refused with range 0..2147483647ms. I inspected that evidence; I did not rerun it.

New evidence here is source inspection, not measurement: PostgreSQL **REL_18_6** declares both settings with `GUC_UNIT_MS` and limits `0, 0, INT_MAX`. This agrees with the receipt’s range. ([Upstream source](https://github.com/postgres/postgres/blob/REL_18_6/src/backend/utils/misc/guc_tables.c).) I have no newly executed 18.6 parser result, empirical version comparison or elapsed-time service measurement.

EXACT permits exact integral milliseconds in the settings’ intersection: with the checked range, 1..2147483647ms. FLOOR permits finite d≥1ms when floor(d/ms) is accepted. Thus 1500us is refused by EXACT and becomes 1ms under FLOOR. FLOOR also permits a fraction above the maximum whole millisecond if its floor remains accepted; a whole-millisecond value above the maximum is refused. That matches its printed type.

Both reject zero, negative and non-finite values; overflow cannot become an admitted zero. Validation must establish the mathematical range before narrowing. Equivalent spellings such as 1000us and 0.001s satisfy EXACT: it does not require an integer lexical token.

The validation owner already exists: `OVR-19` says “Startup MUST validate every startup-validated row and refuse to run on a missing or out-of-range value”. Tightening its row suffices; another startup MUST in `OPS-15` would duplicate the home. EXACT needs no new normalization rule. FLOOR needs its explicit serialization sentence because PostgreSQL rounding is not floor. Observing effective settings in conformance is a test obligation, not a production read-back protocol.

`CNF-369` is the existing refusal check: its held-share case asserts “the engine logs loudly and exits non-zero having claimed nothing”, unchanged generation and a subsequently successful holder commit. The additions exercise parameter refusal before advance and distinguish 1ms validation acceptance from contested-statement success. Preserve the held-share case independently.

Neither package requires a new numeric Lean definition: the current formal layer does not define this bound’s precision or serialization. Tags on other clauses do not formalize this numeric clause.

`OPS-15` retains “On that timeout or any store error, including a lost reply on its commit, the engine MUST log loudly and exit non-zero having claimed nothing”. Statement timeout limits the replacing statement; lock timeout limits each acquisition, and at equal values statement timeout can fire first. Neither adds an end-to-end startup, transaction or commit deadline.

`STO-7` says “A standby wait has no server-side timeout”. A SyncRep share holder blocking UPDATE and the advance’s own standby commit wait are different waits. Generation guards, startup locking, synchronous replication, acknowledgement ordering, fatal lost replies and supervisor retry survive.

EXACT is the cheaper complete normative form: one admissibility rule plus focused checks. FLOOR is mechanically sound but buys fractional input acceptance with a conversion obligation and shorter effective timeout. Both introduce real minimum/precision policy and conformance obligations relative to the pin. Those are declared behavioural amendments, not wording repairs or permission to implement. R1/R2 address collateral ADR quotations only.

The 1ms case is an admissible boundary, not a claim that startup will complete at that setting. Refusal tests and successful-setting observations answer different questions. A stricter operational minimum, a client deadline covering COMMIT or an added setting-read protocol would each be another behavioural choice; none is needed to repair positive-to-disabled conversion. Keeping that boundary avoids presenting parser evidence as an operational startup guarantee.

**Q2.** The trace is enqueue→claim/hold→originating stop before sending the fence transaction→shielded guarded record→failed/stalled/null fence→operator retry as a fresh attempt.

A store error alone supplies no classified failure: `OPS-49` says “the component MUST repeat the **whole transaction**” and, on exhaustion, “the engine MUST exit non-zero”.

The decisive `OPS-11` delete row says:

> any failure the worker records while `OPS-45`’s write-started marker is unset, where no rescue session was opened or the one opened was closed without error, MUST settle `failed`, whatever its kind

Its exception is “unless the mutation is known to have been accepted (`details.accepted` is `true`)”. The selected pre-fence attempt has neither acceptance nor rescue session. `OPS-45` sets the delete marker when “the provider call is dispatched”; the original marker remains null.

`OPS-21` supplies “The recorded error is a cut-off `conflict` with `details.reason: "cut_off"`”; `WIR-9a`’s conflict-reason union includes `"cut_off"` at `13-wire-contract.md:141`. Ordinary cut-off ambiguity does not override the pre-dispatch exception.

`OPS-48` maps “`failed` — deterministic; the provider did not act” to `stalled`, fence “**Unchanged**”, and clarifies “An episode none of whose attempts reached the fence transaction holds null.” The record therefore needs no cancellation-fence write. `OPS-22` requires the operation still be “`running` under the worker’s claim number”; `OPS-50` separately requires the generation share-read/equality check. Neither requires setting the cancellation fence.

S1 selects acknowledgement within the bounds, no later stop and no superseding generation. Survival and an available store alone would not prove timely acknowledgement. `OPS-21` says “whichever ends first ends the record” of the independent bounds, and requires “the record MUST classify against the markers its own transaction reads”. Later stop, exhaustion, generation refusal and lost acknowledgement retain their distinct exits and durable-write caveats. Lock loss itself is not a later stop: `OPS-47` says “The loss is not a later stop”. S1 avoids inferring an in-flight fence transaction’s outcome by stopping before sending it.

The retry tail must retain the existing discriminators. `OPS-41` says “A retry reading the fence null decides from step 3 unless the tenant is suspended now.” An extension committed first funds the null-fence retry and produces the no-mutation result. A retry that fences first refuses the later extension without moving its money. A previously fenced, undispatched attempt still supplies the episode fence despite its null dispatch marker. A currently suspended tenant still bypasses funding with a null fence and favorable rate. These outcomes depend on the deciding transaction, not enqueue order, historical suspension reasons or the previous attempt’s marker.

I inspected `failBeforeFence`: `.holding n, some a` calls `finish w n a .failed .failed`; `finish` uses the worker guard, and `applyRow` preserves the failure row’s fence. The existing `interrupted_retry_prefix_witness` evaluates the abstract failure prefix to stalled/null-fence. `extension_first` retains its null-fence, retry and suspension hypotheses.

S4 truthfully describes a durable result admitted by the larger trace set. It proves neither stop delivery, bounded recording, their composition with Fence, dispatch-marker history nor running-service behaviour. No composition or theorem weakening is needed for that limited explanatory edit.

S-STOP’s defect is **fixture inconsistency**, not an invalid premise. S1 requires the suspended/null-fence row under both prefixes; the retained fan-out paragraph and table cell explicitly select route 1. Executing the promised survived-stop suspended test needs additional edits. R3 changes fixture selection and is behavioural under rule 1.

Preserve the crash/no-requeue route, fenced controls, current suspension precedence, extension/fence order and restore limitation. The removed store-error warning prevented inventing a worker-classified store failure; S1 preserves that substance and R4 restores its quotation. I found no lost existing CNF verdict or weakened theorem. Added conformance coverage is not executed runtime evidence.

**Brief errors and rule 6.** The verified inconsistency is S1’s two-prefix instruction versus its retained route-1 selectors. It changes coverage instructions, not Q2’s premise; **Q2 is not void**.

Q1 omits collateral refresh of ADR-0047’s current type quotation; FLOOR also changes its quoted `OPS-15` sentence. That is quotation drift, not disproof of the conversion premise; **Q1 is not void**.

The pinned “no current ordering clause” passages are accurately quoted obsolete source, not current claims I endorse. No other broken factual claim was established. The prior 18.6 probe remains unverified here; the 17.9 receipt is correctly identified. No vote relies on calling 17.9 an executed 18.6 result.

**Requested counterargument against K-EXACT — not a vote:** FLOOR preserves more inputs, explicitly avoids upward rounding and needs one deterministic conversion. Rejecting 1.5ms is a usability policy, not a safety necessity. Compatibility could justify FLOOR if the owner accepts its implementation and boundary-test costs.

**Requested counterargument against Q2 NONE — not a vote:** S1’s two-prefix instruction could supersede the later route-1 references. The intended result and model event are sound; the repair is small. But the package supplies no such precedence, and fixture-selector changes are behavioural under these rules.

**Exact repairs.** R1, R2 and R4 leave runtime/proof behaviour unchanged. R3 changes conformance fixtures. None was applied.

**R1 — both Q1 packages; ADR-0047:73–75; quotation-only, behaviour unchanged.**

Before:

```text
`OVR-19` types
the bound “finite, positive duration” and requires startup to “refuse to run on a missing or
out-of-range value”.
```

Replacement:

```text
For the bound's current type, see
`OVR-19`'s Startup-lock wait bound row. `OVR-19` requires startup to “refuse to run on a missing or
out-of-range value”.
```

Retain the following zero-refusal/startup-lock statements. The refusal quote and unique before-anchor were verified.

**R2 — K-FLOOR only; ADR-0047:67–68; quotation-only, behaviour unchanged.**

Before:

```text
`OPS-15` owns the advance statement's timeouts: “Its replacing statement MUST run with
`statement_timeout` and `lock_timeout` both set to `OVR-19`'s Startup-lock wait bound.”
```

Replacement:

```text
For the advance statement's timeout serialization, see `OPS-15`.
```

Retain the PostgreSQL explanation and fatal-exit quotation. The old quote matches the pin and differs from FLOOR’s replacement.

**R3 — S-STOP; CNF-312:2475 and :2488; behaviour changed.**

Before:

```text
**Suspension fan-out:** from the route-1 prefix, suspend the tenant.
```

Replacement:

```text
**Suspension fan-out:** on separate fresh instances of each prefix, route 1 and the survived-stop prefix, suspend the tenant.
```

Before, in the suspended/null-fence table cell:

```text
Use the route-1 prefix and suspension fan-out above.
```

Replacement:

```text
For each prefix, use its suspension fan-out above.
```

Retain every subsequent assertion. Both anchors were verified unique. This expands fixture selection to both prefixes.

**R4 — S-STOP quotation repairs; behaviour unchanged.**

S1’s new CNF paragraph, before:

```text
A store error alone remains `OPS-49`'s retry path, not a separate worker-recorded failure.
```

Replacement:

```text
A store error alone remains `OPS-49`'s retry path, not a separate worker-recorded failure: "the component MUST repeat the **whole transaction**".
```

S2’s OPS-41 replacement, before:

```text
`OPS-21` supplies the survived-stop pre-fence failure route; `CNF-312` owns its conformance prefix. The model does not compose stop delivery or bounded recording with this lifecycle.
```

Replacement:

```text
For the survived-stop record see `OPS-21`: "A cancellation of `execute` that the engine survives MUST be recorded before the engine exits"; for the pre-fence conformance prefix see `CNF-312`. The model does not compose stop delivery or bounded recording with this lifecycle.
```

S3’s new ADR paragraph, before:

```text
A store error alone remains the `OPS-49` whole-transaction path.
```

Replacement:

```text
For store errors, see `OPS-49`: "the component MUST repeat the **whole transaction**".
```

S4’s first new module-introduction sentence, before:

```text
`failBeforeFence` admits a worker-recorded failure before fencing, including the survived-stop route specified by `OPS-21`.
```

Replacement:

```text
`failBeforeFence` admits a worker-recorded failure before fencing, including a survived-stop record; see `OPS-21`: "A cancellation of `execute` that the engine survives MUST be recorded before the engine exits".
```

Retain its remaining model-boundary sentences. S4’s declaration docstring, before:

```text
Worker-recorded failure before fencing, including `OPS-21`'s survived-stop route. Stop delivery and bounded recording are outside this model; `OPS-49` store errors alone are not classified by this event.
```

Replacement:

```text
Worker-recorded failure before fencing, including a survived-stop record; see `OPS-21`: "A cancellation of `execute` that the engine survives MUST be recorded before the engine exits". Stop delivery and bounded recording are outside this model; store errors alone are not classified by this event (for the store-error path, see `OPS-49`).
```

Both requirement quotes were verified as exact whitespace-normalized substrings of their owners. Keep the actual-landing-date instruction; this review invents no landing date.

**Checks and limits.** Initial and final unpiped `nix develop --command bash tools/check-all.sh` runs both exited **0**, all gates PASS, including Lean/axiom policy. The clone remains clean at the pin. Those gates checked the unchanged pin, not proposed packages.

I checked source anchors, surrounding lifecycle/ADR/model boundaries, repair quotation strings, the supplied receipt, official documentation and upstream 18.6 source. Substantive work used the required capped scopes and environment. Exceptions were the initial read-only `pwd` and a failed draft-write command with incorrect shell quoting; neither changed source. The corrected draft was saved with a protected heredoc.

Exploratory searches named nonexistent wire/storage/gate files; corrected searches succeeded. The first draft write failed; no gate failed. GitHub’s rendered-source search lacked the symbols; its raw upstream source supplied them.

No candidate was installed or executed. No fresh parser/server probe, runtime CNF exercise, composed proof or separate CI negative-control matrix ran. No tracker command, source edit, branch change, commit, push, delegation, production contact or credential/config-store inspection occurred.