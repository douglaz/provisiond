I'll review the r78 Panel C brief against the pinned sources and notes.md, then write the grok draft with marks on each candidate.The notes and pin folder are in place. Next I’ll check the pinned sources, the timeout probe, and the Q2 lifecycle text before marking the candidates.The pin matches the clone. I am checking the fence transition and the suspension wording, then I will write the draft.Draft saved at `grok.draft.md`. Pin `cebdc4f8f728f40d7fdf3c10ed094a1a7d2b8527`. No adoption, implementation, or follow-on.

**apply notes.md rule 6 exactly as written; this prompt adds no void rule.** No verified brief error changes either premise.

## Q1 — pv-kwuf

**K-EXACT: ACCEPT.**
**K-FLOOR: ACCEPT.**
**Preference: K-EXACT.**

Both packages stop a positive Startup-lock wait bound from becoming a disabled timeout. K-EXACT is the complete form that keeps one number.

The register cell is the only home of the range. `OVR-19` already says startup refuses a missing or out-of-range value (`00-overview.md:361–363`). Today the cell admits any finite positive duration (`00-overview.md:410`), and `OPS-15` sets both `statement_timeout` and `lock_timeout` to that same bound (`03-operation-lifecycle.md:383–384`). Zero, negative, and non-finite values are already out of range. The hole is a positive value PostgreSQL stores as 0, and 0 disables the timeout.

Receipt `/var/tmp/provisiond-panel-r78/check/timeout-probe.json`, parser only, **PostgreSQL 17.9**, no server started: both settings, `400us` → `0`, `600us` → `1`, `1500us` → `2`, `1ms` → `1`, `0` → `0`. `-1ms` is refused. Each FATAL line states the range `0 ms .. 2147483647 ms`. That is the converter's stored integer, not an elapsed-time or live-service bound. This seat did not re-probe: no `postgres` binary was on `PATH`. The preparation's 18.6 bead result was not opened (tracker is off limits) and is not evidence here. `ADR-0047` cites PostgreSQL 18 for "zero disables" and for lock scope. It does not record this microsecond grid. No version difference is established. No candidate was executed.

`400us` is the probed input that disables protection. `600us` and `1500us` do not. K-EXACT refuses every fractional millisecond, including those two, and states that it does. That is a stricter input domain than the zero sentinel, and it is declared. It is a policy cost for the owner, not a broken package. Minimum 1 ms is inside "positive whole number of milliseconds"; the words agree. Equivalent spellings of an exact whole millisecond (`1000us`, `1ms`) stay legal under the type cell. The cell does not name `2147483647`. "Accepted by both `OPS-15` timeout settings" means those two GUCs' acceptance range, which the 17.9 error text states, not the separate pooled store-timeouts row. One out-of-range whole-millisecond sample in `CNF-369` is enough to force a refusal. A production read-back is not added. The new "effective settings are 1 ms" line is a conformance observation of the existing `OPS-15` MUST, on an independent attempt. Validation acceptance is explicitly not the held-share success case. The held-share exit, unchanged generation, and later session commit stay.

`OPS-15`'s loud, non-zero, no-claim exit, including a lost reply on the commit, stays in both packages. So does the liveness sentence: a `SyncRep` holder has no server-side timeout (`STO-7`, quoted at `03-operation-lifecycle.md:388–390`). Neither package bounds standby commit. `statement_timeout` bounds the replacing statement's wait for share locks. It does not bound a synchronous-standby flush. Share holders that keep turning over can still hold the advance until that same exit. The supervisor restart remains the retry. `OPS-49` still does not cover this exit.

The same register row is `OPS-47`'s lock-retry bound: "retry for the stated bound (`OVR-19`)" (`03-operation-lifecycle.md:145–147`). K-EXACT narrows that input too, and the retry duration stays equal to both GUC values. K-FLOOR keeps a fractional duration at or above 1 ms for the retry and sets the GUCs to the floored millisecond. For `1500us` the retry waits 1.5 ms and both timeouts are 1 ms. The package says this split on purpose: the register validates, `OPS-15` serializes. After the type-cell rewrite, no MUST still requires identity. The collateral is real and should be visible to the owner. It is why I prefer K-EXACT, not why K-FLOOR fails. K-FLOOR's `CNF-369` change matches its rule: `1500us` is accepted, both effective settings are 1 ms, and the unconverted string must not be handed to PostgreSQL to become 2. Floor of any accepted value is at least 1 ms, so the floor itself cannot write the disable sentinel. `600us` stays refused because it is below 1 ms; its floor would be 0.

No new formal definition and no Lean change. K-EXACT needs no second runtime sentence. K-FLOOR adds a serialization obligation beside the register. That second home is declared and consistent. It is not the cheaper form.

What these timeouts still do not do: they do not make startup wait out a dead standby, they do not change generation fencing, and they do not turn a lost commit reply into success. Refusing the bad value before the generation advance (`OVR-19`'s existing order, now with a tighter range) prevents the statement from running with the timeout off. It does not add a new exit.

**Requested counterargument against K-EXACT.** The defect on the 17.9 probe is a positive duration that stores as 0. `600us` stores as 1 and `1500us` stores as 2. K-EXACT refuses both. A deployment that already wrote a fractional millisecond at or above 1 ms is rejected even though PostgreSQL would have armed a positive timeout. K-FLOOR admits that input and only shortens the armed timeout by less than 1 ms. If the owner wants the smallest change that closes the sentinel, exactness is stricter than the bug. That cost choice is the owner's. It does not make K-EXACT internally false.

Unreviewed, not a vote and not a package: a type cell of only "finite duration at least 1 ms", with `OPS-15` still passing that duration through, also stays above every probed zero result. It still depends on the server's rounding and on the serializer not emitting a sub-millisecond string. I do not prefer it over K-EXACT.

## Q2 — pv-75w3

**S-STOP: AMEND.**
**Preference: NONE.**

The printed package is not accepted. The direction is right: `OPS-21` already orders a survived stop, and the "no current ordering clause" sentences are stale. A direction is not package acceptance. The repair below is a proposal. It is not a reviewed package and it authorizes nothing.

Trace, under the fixture's own conditions (working store, record acknowledged inside both bounds, no later stop, no superseding generation, no open restore deferral). Sweep enqueues the cancellation and opens the episode (`OPS-39` / `OPS-48`). The worker claims it. `OPS-41` reads the restore record at claim, before the fence transaction; with no open grace the claim does not defer. Execute is in progress and the first fence transaction has not been sent. `OPS-42` is that transaction: `OPS-41`'s re-check and `machines.destroy_committed` are one transaction, and it is before any provider mutation. The dispatch marker is later. `OPS-45`'s delete row sets `write_started_at` when "the provider call is dispatched" (`03-operation-lifecycle.md:1477`). Stopping before the fence is sent is stopping before that marker write.

`OPS-21` (`03-operation-lifecycle.md:1784–1798`): a cancellation of `execute` that the engine survives MUST be recorded before exit. The record is the guarded `OPS-22` write, a cut-off `conflict` with `details.reason: "cut_off"` (`WIR-9a`, `13-wire-contract.md:141`). The fence write is a different statement. The record can commit without setting `destroy_committed`. The in-flight exception is not this fixture: nothing has been sent, so there is no server-decided fence transaction to let finish.

Classification, delete row of `OPS-11` (`03-operation-lifecycle.md:248`): any failure the worker records while `OPS-45`'s write-started marker is unset, and no rescue session was opened, MUST settle `failed`, whatever its kind, unless `details.accepted` is true. `OPS-45` (`03-operation-lifecycle.md:1506–1510`): the operation settles `failed`, deterministically, with no operator and no reconciliation, when the write-started marker is unset and no rescue session was opened. This rule classifies a failure a worker recorded. The cut-off is that failure. It is not `OPS-15`'s interrupted row.

`OPS-48` (`03-operation-lifecycle.md:1292` and `1303–1304`): `failed` — deterministic; the provider did not act — moves the episode to `stalled` and leaves the fence **Unchanged**. An episode none of whose attempts reached the fence transaction holds null. So the original attempt is `failed`, the error is `conflict` / `cut_off`, the episode is `stalled`, `destroy_committed` is null, `write_started_at` is null, and no provider call ran. `episodeStep` agrees: `.settled .failed` from `.attempting` is `(.stalled, false)`, and `applyRow` clears the fence only when that boolean is true (`Fence.lean:451–461`, `516–519`).

A fresh `API-64` retry is admissible on `stalled` and follows `OPS-41`. Orders A and B already start from a failed, stalled, null-fence attempt. Feeding them the survived-stop end state does not change their observations. `CNF-362` (`10-conformance-checklist.md:1676–1677`) already requires this delete, cut off before the marker write, to settle `failed` with `cut_off`. S-STOP's new claim is the episode, the null fence, and the decision table. Those agree with `CNF-362`. They do not rewrite it.

The crash prefix stays: kill, `needs_reconciliation`, episode `uncertain`, operator `not_applied`, then the same failed/stalled/null-fence shape, and no requeue (`OPS-15`). A store error alone stays `OPS-49`: repeat the whole transaction, and on exhaustion exit non-zero with no worker classification. A later stop, an exhausted Stop-record or Store-retry bound, a lost reply, or a superseded generation is a different exit. The fixture says so. Suspension still wins over a null-fence funding abort on the retry (`OPS-41` step 2). Extension-before-retry and fence-before-extension stay in the table. Fenced rows keep their own prefixes. No retryability field is added. No `CNF` identifier is put in `tools/formal/`.

`failBeforeFence` (`Fence.lean:985–988`) fires only in `.holding`, which is before `fenceTxn`, and calls `finish` with `.failed` / `.failed`. The witness `interrupted_retry_prefix_witness` (`Witnesses.lean:355–360`) already has that run at `stalled` with a null fence. The transition does not model stop delivery, bounds, or a cut-off reason. The durable outcome is an input. The larger trace set remains: any holding attempt, not only a survived stop. Theorems, hypotheses, and witnesses are untouched. S4's comment matches that event. It does not compose StopRecord with Fence, and it does not need to. The requirement tag stays `OPS-45`. That tag is the classification owner; `OPS-21` is the trigger. Keeping the tag is right.

The printed package contradicts itself on the suspended row. S1 says to drive Orders A and B and the suspended/null-fence row on route 1 and on the survived-stop prefix. The fan-out and the table were not in the replaced span, and they still say route 1 only:

`10-conformance-checklist.md:2475`: "from the route-1 prefix, suspend the tenant."

`10-conformance-checklist.md:2488`: "Use the route-1 prefix and suspension fan-out above."

A checklist reader can satisfy the table without ever suspending after the survived-stop record. That drops the row the item uses to catch a null-fence funding path that ignores current suspension. The end state is the same shape either way, so this is a coverage hole in the printed words, not a different decision rule. It is still a behavioural miss against S1's own sentence. Wording-only acceptance is not available.

The replacement's end boundary is "route-1-only fixture selection" (`10-conformance-checklist.md:2457`). These following lines sit in the same paragraph and must stay, or the read/commit instrumentation disappears:

> Instrument the deciding fence transaction's read/commit boundary:
> retry enqueue alone establishes neither transaction order.

### Repair (proposal, not reviewed)

Location 1: `10-conformance-checklist.md`, `CNF-312` suspension fan-out.

Before:

> **Suspension fan-out:** from the route-1 prefix, suspend the tenant.

Replacement:

> **Suspension fan-out:** from the route-1 prefix, and separately from the survived-stop prefix after that prefix's recorded failure, suspend the tenant.

Behaviour changed against the printed fan-out sentence: the same fan-out is required after the survived-stop prefix. Route-1 steps and assertions are unchanged. No operator resolution is added to the survived-stop arm.

Location 2: same item, table row `Suspended, null fence`.

Before:

> Use the route-1 prefix and suspension fan-out above.

Replacement:

> On separate fresh instances, use the route-1 prefix and, separately, the survived-stop prefix, each with the suspension fan-out above.

Behaviour changed against the printed cell: the row runs twice. On each instance the observations are unchanged (null fence, current suspension, provider call, no funding-abort close to `funded`).

Location 3: keep the two instrument lines quoted above, immediately after S1's replacement. Behaviour unchanged.

No other printed sentence needs a repair for this vote. S2, S3, and S4 may stand if this checklist contradiction is fixed. I do not accept them as a reviewed package in this round.

Deleted text and what it protected. "Drive route 1 alone" forbade an unspecified pre-fence injection and a store-error route. The store-error ban is kept. The crash route is kept. Dropping "alone" is the declared new prefix. "`OPS-45` orders no such failure before this fence write" was true of `OPS-45` and false as a claim that no clause orders one. `OPS-21` orders the record. `OPS-45` still only classifies a failure a worker recorded; an interrupted, unclassified row remains `OPS-15`'s. Deleting the sentence does not let a crash settle `failed` by the marker rule. "`OPS-23` establishes no such ordering" remains true and is not a rule this package needs to repeat. ADR-0032's "keyed on the fence, not the route" is kept. Comment 194 remains cited earlier in that ADR (`docs/adr/0032-revival-is-an-operator-decision.md:23–24`). The replaced paragraph's "over-approximation" sentence moves to S2 and S4. No Lean verdict becomes false, unreachable, or vacuous. `interrupted_retry_prefix_witness` still proves the crash-and-resolve shape and the `failBeforeFence` shape. Neither is a running-service test.

Residual, not a separate repair: `OPS-41`'s note still says the model admits "abstract pre-fence failure" in the sentence before S2's replacement (`03-operation-lifecycle.md:1187–1190`). S2's next sentence says the model does not compose stop delivery. Read together, "abstract" means the model, not the spec. The landing record must use the real landing date, as the candidate already says.

**Requested counterargument against NONE.** The contradiction is two leftover cross-references. S1's driving sentence already names the suspended row on both prefixes, and the classification does not depend on which prefix produced the stalled null fence. Holding the whole package for that cross-reference leaves the stale "no current clause orders a worker-recorded failure before the fence" paragraph in `CNF-312` and ADR-0032, which is the prose this question exists to correct. A later reader can treat the driving sentence as controlling and the table cell as an oversight.

That counterargument is not a vote. I do not ACCEPT the printed package.

## Rule 6

No broken factual claim voids Q1 or Q2.

Checked and matching: the pin; `OVR-19`'s cell and preamble; `OPS-15`'s timeout, exit, and liveness sentences; `CNF-368` and `CNF-369`; `OPS-21`'s record and cut-off sentences; `OPS-11`'s delete row; `OPS-45`'s delete marker and deterministic-failure paragraph; `OPS-48`'s `failed` row and the null-fence gloss; `WIR-9a`'s `cut_off` reason; `CNF-312`'s route-1 prefix, the two stale paragraphs, the fan-out, and the suspended row; ADR-0032's comment-194 paragraph and the rejected alternatives that follow it; `failBeforeFence`, `finish`, `applyRow`, and `interrupted_retry_prefix_witness`. The probe JSON matches the brief's 17.9 grid. The FATAL text in that receipt, which the brief does not quote, states `0 ms .. 2147483647 ms`.

Not a false claim: the brief does not say the bound is used only as the two GUCs. It is also `OPS-47`'s retry bound. That omission does not change the zero-disable premise. Both candidates edit the shared cell, so both touch that retry's domain.

Unchecked, not found false: PostgreSQL 18.6 behaviour; the documentation URLs (web search is off); the bead text of the earlier 18.6 probe; owner comment 194's raw wording beyond the ADR. No rule-6 void follows from an unchecked source.

## Checks run

- `git rev-parse HEAD` and `git log -1`: `cebdc4f8f728f40d7fdf3c10ed094a1a7d2b8527`.
- Read `notes.md` whole.
- Read the probe JSON and the pinned spans above, plus `OPS-47`, `STO-7`, `ADR-0047`'s timeout paragraph, `CNF-290`'s lock-retry pointer, `CNF-362`'s pre-marker delete line, and `Fence.lean` / `Tables.lean` / `Witnesses.lean` around `failBeforeFence`.
- `command -v postgres`: not found. No new parser measurement.
- Not run: candidate text as a patch, `tools/check-all.sh`, Lean, a server, `br`, any other checkout, credential or session stores.

No implementation and no next round is approved.
