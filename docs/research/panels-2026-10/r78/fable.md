Nothing further is needed: the draft is saved, the clone is clean, and both gate runs are logged. Final answer follows.

# r78 — fable (claude-fable-5-1, xhigh)

Pin verified: my clone is at cebdc4f8f728f40d7fdf3c10ed094a1a7d2b8527 and clean before and after work. Every pinned excerpt in the brief matches the pin at the stated lines. Draft saved at `/var/tmp/provisiond-panel-r78/fable.draft.md`.

## Q1 — pv-kwuf

**Marks.** K-EXACT **ACCEPT** (behavioural, as declared). K-FLOOR **AMEND** (one wording repair, behaviour unchanged). **Preference: K-EXACT.**

**Premise verified.** OVR-19 types the bound "finite, positive duration"; OPS-15 sets both timeouts to it verbatim; PostgreSQL stores whole milliseconds and zero disables. The brief's 17.9 receipt matches its text. My own parser-only probe on the nix-store PostgreSQL 17.9 (no server started, both settings identical) is new evidence:

| input | stored | input | stored |
|---|---|---|---|
| 500us | 0 | 0.5ms | 0 |
| 1.5ms | 2 | 2500us | 2 |
| 3500us | 4 | 1000us / 0.001s / bare 1 | 1 |
| 2147483647ms | accepted | 2147483648ms, 24.9d, 25d, inf | refused, "invalid value" |

Rounding is half-to-even, so exactly 0.5 ms also disables the timeout. The bead's "under 0.5 ms" understates. The premise is strengthened, not changed. PostgreSQL 18 was not re-run here.

**K-EXACT.** One home, the OVR-19 cell; OPS-15 untouched, so the configured and effective values are identical and PostgreSQL's rounding never enters. OVR-19 already says "Startup MUST validate every startup-validated row and refuse to run on a missing or out-of-range value", so no second runtime rule appears. No Lean declaration formalizes OVR-19's register or the advance timeouts. Restore.lean's two OPS-15 tags are the sweep, so only prose and conformance change. "Finite" plus "accepted by both OPS-15 timeout settings" covers overflow and non-finite input, and the CNF addition tests the over-range case. One nit, not a repair: "minimum 1 ms" restates "positive whole number of milliseconds". Costs, reported separately: fractional inputs such as 1.5ms are refused, a policy choice for the owner; asserting the effective settings "on the advance's connection" needs server statement logging or engine evidence.

**K-FLOOR repair.** The package is internally consistent, and its 1500us expectation matches the evidence. But the cell restates OPS-15's new rounding rule, two normative copies of one conversion, the SEC-46 drift class AGENTS.md names.

- Location: 00-overview.md:410, K-FLOOR's type cell.
- Before: `finite duration at least 1 ms whose downward-rounded whole-millisecond value is accepted by both `OPS-15` timeout settings; also the generation advance's `statement_timeout` and `lock_timeout` (`OPS-15`)`
- Replacement: `finite duration at least 1 ms whose whole-millisecond value, as `OPS-15` sets it, is accepted by both timeout settings; also the generation advance's `statement_timeout` and `lock_timeout` (`OPS-15`)`
- Behaviour unchanged. OPS-15 stays the sole home of "rounding down".

**What the timeouts guard.** The advance statement's share-lock wait and execution. Neither candidate changes what they cannot guard: the commit's standby wait, since STO-7 says "A standby wait has no server-side timeout", and a lost commit reply, which OPS-15's "On that timeout or any store error, including a lost reply on its commit" exit covers. The generation and lost-reply exits are untouched in both.

**Requested counterargument against K-EXACT.** Config layers often carry durations as decimal seconds. K-EXACT refuses values PostgreSQL itself accepts and rounds up, stricter than the store with no safety gain above 1 ms, while K-FLOOR keeps them with a never-disabling shortening under 1 ms. Reply: sub-millisecond precision has no use for a startup timeout, and exactness deletes a conversion step that would have two homes.

## Q2 — pv-75w3

**Mark.** S-STOP **AMEND**: one exact-location repair and two wording repairs. **Preference: S-STOP as amended.** The printed package is not accepted as-is under rule 1.

**Premise verified.** OPS-21, amended 2026-10-18, says "A cancellation of `execute` that the engine survives MUST be recorded before the engine exits, for every operation kind". OPS-11's last row says "any failure the worker records while `OPS-45`'s write-started marker is unset, where no rescue session was opened or the one opened was closed without error, MUST settle `failed`, whatever its kind". OPS-48's row "`failed` — deterministic; the provider did not act" gives `stalled` with the fence Unchanged, and "An episode none of whose attempts reached the fence transaction holds null". OPS-45's delete marker row is set when "the provider call is dispatched". So the five stale passages were true on 2026-10-05 and false since 2026-10-18. A store error alone stays distinct: OPS-21 says "Its store-error exit also classifies nothing".

**Trace.** Sweep opens the episode and enqueues; claim; stop delivered while execute is cancellable and before the fence transaction is sent; the worker classifies under OPS-11's last row; the record is OPS-22's guarded write with OPS-50's generation read first, carrying cut-off `conflict` and `details.reason: "cut_off"`; it lands within the Stop-record bound with a working store and no later stop; the episode is `stalled`, the fence null, `write_started_at` null, zero provider calls; the engine exits after the record; an API-64 retry reaches OPS-41 step 2, which says "A retry reading the fence null decides from step 3 unless the tenant is suspended now". The record runs without the fence because the fence is written only inside OPS-41/42's transaction "Before any provider mutation", and nothing orders it before a cut-off record. Later stop, bound expiry, store-retry exhaustion and superseded exits all leave the row `running` for OPS-15, which is route 1's shape; S1 correctly excludes them.

**Model.** Fence.lean imports Claim, Runway, Rate and Tables; StopRecord.lean imports Claim and Tables. Neither imports the other, so "does not compose" is true. At phase `holding`, failBeforeFence calls `finish` with Settled.failed and Written.failed, which applyRow turns into a stalled episode with the fence unchanged. The durable survived-stop result is already in the trace set, and six theorems carry the case. No theorem needs weakening and no composition is needed for what S-STOP claims. No Markdown region binds to Provisiond.Fence, and the new docstrings carry no quoted span.

**Repairs.**

1. **S1 location is not exact.** At the pin the OPS-45 quote is the last sentence of the Route-1 prefix paragraph at 10-conformance-checklist.md:2449–2450, not a paragraph's start. The second paragraph ends at 2459–2460 with "Instrument the deciding fence transaction's read/commit boundary: retry enqueue alone establishes neither transaction order.", which is Orders A and B's stated method, not route-1 selection. Replace line 2449 through 2458 (ending "The fenced rows use their own prefixes below.") with S1's two paragraphs, with a paragraph break before **Survived-stop prefix:**, and keep 2459–2460 as the closing sentence of S1's second paragraph. Behaviour unchanged relative to the package's declared change.
2. **S3 erases history.** It replaces the paragraph holding the owner's comment-194 quote while saying "Do not erase the historical decision". The repo appends dated amendments, as ADR-0021 line 45 and ADR-0044 line 125 do. Keep ADR-0032 lines 43–51 verbatim. After line 51 insert a paragraph opening "*Amended <landing date> (`pv-75w3`): the paragraph above predates `OPS-21`'s 2026-10-18 amendment (`ADR-0044`).*" followed by S3's printed text. Extend the Status line from "2026-10-05 (`pv-gip.43`, Q14)." to "2026-10-05 (`pv-gip.43`, Q14); amended <landing date> (`pv-75w3`)." Wording only.
3. **S4 intro misdescribes the event.** "the failure's durable outcome is an input here" is false: the event takes no outcome and fixes failed/stalled, assuming the record landed. Replace that clause with "the record is taken as landed, with the attempt `failed` and the episode `stalled` by `OPS-48`'s table, and the Stop-record bound and its exits are `Provisiond.StopRecord`'s". Wording only, no CNF id in tools/formal. The printed docstring replacement is truthful and kept.

**No blocking loss.** Route 1, the fenced prefixes, the decision table, the discriminating controls and every theorem and hypothesis are untouched. "Do not inject a store error as a separate failed route" survives as "A store error alone remains `OPS-49`'s retry path". OPS-23's citation leaves CNF-312, but OPS-23 keeps four other items and the coverage gate stays green. Cost, reported separately: Orders A, B and the suspended row now run from two prefixes.

**Requested counterargument against S-STOP.** CNF-362 already requires a survived-stop record for every kind, with a delete "cut off before their write-started marker write settle `failed`"; one sentence adding the null-fence assertion there is cheaper than doubling three CNF-312 rows. Reply: CNF-312's subject is the retry decision after a null-fence stall. Only driving Orders A and B from the survived-stop prefix catches a build that keys step 2 on an operator-resolution record, which route 1 alone would pass.

## Brief errors, checks and evidence

**Brief errors.** None voids a premise under rule 6. S1's "two paragraphs beginning with the OPS-45 quote" is wrong about the layout and affects only S1's exactness. The bead's "under 0.5 ms" understates, since exactly 0.5 ms also disables. All pinned ranges and quotations verified, including OPS-45's "This rule classifies a failure a worker recorded" at 03-operation-lifecycle.md:1509–1510, which is line-wrapped.

**Checks run.** Pin and cleanliness; every pinned excerpt; the citation, coverage, obligations and regions gate logic; coverage impact; the Fence and StopRecord imports and failBeforeFence's six theorem cases; the PostgreSQL 17.9 probe above. The full unpiped gate in my clone passed twice with exit 0: K-EXACT plus S-STOP as printed, Lean built cold in about four and a half minutes; then K-FLOOR as printed plus S-STOP with repairs 1 to 3, with Fence and Witnesses rebuilt. Logs are under `/var/tmp/provisiond-panel-r78/tmp/` as `fable-gate-kexact-sstop.log` and `fable-gate-kfloor-sstop-amended.log`. The clone was restored after each run.

**Not run.** PostgreSQL 18; any runtime conformance; the repaired K-FLOOR cell as text, which is plain cell prose the gates do not read; no new proof. No implementation or next round is approved by this read.
