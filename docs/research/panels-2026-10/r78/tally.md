# r78 tally — Panel C

Pin: `cebdc4f8f728f40d7fdf3c10ed094a1a7d2b8527`. Scope: pv-kwuf and pv-75w3. **apply notes.md rule 6 exactly as written; this prompt adds no void rule.** Neither question is void: no verified brief error changes either premise. Package defects and collateral omissions below are reported without inventing a broader void rule.

## Seats and counting

All five final answers are substantive: fable 10624 B, opus 11600 B, astra 14745 B, sol 16509 B, grok 17737 B; each exit is 0. No final is empty, a timeout, login failure or session/usage-limit response. Grok is present; no fallback applies. Final answers govern where drafts are more expansive. All drafts were compared with their finals, Codex `.out` files match finals apart from trailing whitespace, Claude/Grok `.err` files are empty, and Codex `.err` transcripts contain completed reviews. Corrected exploratory command errors do not make a missing seat. Exact artifact hashes and source-byte checks: `check/tally-evidence.json`.

The rule is the owner's sentence in notes.md rule 2: “a question is settled when at least three agree and more agree than disagree, and a tie comes to you. If grok is down, it falls back to three of four”. No verified blocking loss and no synthesized tie-break remain required. Rule 1 permits verified wording/quotation/citation-only repairs to count ACCEPT; behavioural repairs do not. Requested counterarguments are not votes.

## Q1 — pv-kwuf

One line per reader, with its actual pick, strongest argument and conditions:

| Reader | Marks and pick | Strongest actual argument | Conditions / counted result |
|---|---|---|---|
| fable | K-EXACT ACCEPT; K-FLOOR AMEND; pick K-EXACT | Exact milliseconds keep configured and effective duration identical, with one admissibility home. | FLOOR needs only its type-cell pointer repair quoted below; verified unchanged behaviour, counts ACCEPT. EXACT has no condition. |
| opus | Both ACCEPT; pick K-EXACT | EXACT needs no conversion and safely refuses precision that a startup wait does not need. | No conditions. Its observations about FLOOR's two values are explicitly non-conditional. |
| astra | Both ACCEPT; pick K-EXACT | EXACT avoids a separate normalization policy; its stricter input domain is a disclosed owner cost. | No conditions. Effective-setting conformance is not a production read-back protocol. |
| sol | Both AMEND; pick K-EXACT | EXACT keeps one admissibility rule; FLOOR buys fractional inputs with serialization and boundary-test costs. | R1 below for both, R2 below for FLOOR, quotation-only and verified; both count ACCEPT. |
| grok | Both ACCEPT; pick K-EXACT | EXACT keeps one number for lock retry and the two server settings. | No conditions; fractional refusal remains an owner policy cost. |

**Count:** K-EXACT 5 counted ACCEPT / 0 CANNOT ACCEPT; K-FLOOR 5 counted ACCEPT / 0 CANNOT ACCEPT. Explicit preference: K-EXACT fable, opus, astra, sol, grok (5); K-FLOOR none (0). Multiple acceptable packages do not create a tie: all explicit preferences agree. EXACT is the settled reviewed recommendation, with Sol's verified quotation-only R1. No runtime or formal mechanism is synthesized.

**Strongest case for EXACT:** one validated duration is used unchanged, avoiding PostgreSQL rounding and a new conversion duty. **Strongest case for FLOOR (requested counterargument, no reader's final pick):** 1.5 ms can safely become 1 ms, so refusing it adds a compatibility cost without extra protection from zero. Neither choice adds a standby-commit bound. Both narrow the shared startup-lock retry input domain as well as the advance's inputs. Testing effective settings requires instrumentation or server-side evidence; it is not a timing proof.

### Verified wording repairs that count

Sol R1, both packages, `docs/adr/0047-lock-loss-records-and-startup-generation-fences.md:73`:

Before:
```
`OVR-19` types
the bound “finite, positive duration” and requires startup to “refuse to run on a missing or
out-of-range value”.
```
Replacement:
```
For the bound's current type, see
`OVR-19`'s Startup-lock wait bound row. `OVR-19` requires startup to “refuse to run on a missing or
out-of-range value”.
```
The before anchor is unique and exact at the pin; the surviving refusal quote is exact after whitespace normalization. This removes a stale copied type and changes no behaviour. This is the only wording repair accompanying the recommended EXACT form.

Sol R2, FLOOR only, the same ADR:67:

Before:
```
`OPS-15` owns the advance statement's timeouts: “Its replacing statement MUST run with
`statement_timeout` and `lock_timeout` both set to `OVR-19`'s Startup-lock wait bound.”
```
Replacement:
```
For the advance statement's timeout serialization, see `OPS-15`.
```
The old quote matches the pin and would drift under FLOOR. The pointer changes no timeout duty.

Fable, FLOOR only, OVR-19 type cell: replace the printed FLOOR cell with:
> finite duration at least 1 ms whose whole-millisecond value, as `OPS-15` sets it, is accepted by both timeout settings; also the generation advance's `statement_timeout` and `lock_timeout` (`OPS-15`)

The printed OPS-15 serialization still explicitly rounds down. This is a verified pointer substitution, preserving FLOOR's accepted values and effective settings. It does not become part of EXACT.

### Q1 evidence audit

- `00-overview.md:361`: OVR-19 says “Startup MUST validate every startup-validated row and refuse to run on a missing or out-of-range value”. Its shared row is at :410. `03-operation-lifecycle.md:145` gives OPS-47 “retry for the stated bound (`OVR-19`)”; :383 gives OPS-15's literal equality to that bound. Thus both input-domain changes also affect lock retry, without changing lock ownership or generation protocol.
- `10-conformance-checklist.md:1661`: CNF-369's held-share assertion is “the engine logs loudly and exits non-zero having claimed nothing”, with unchanged generation and the holder's later successful commit. The printed additions preserve it and distinguish validation acceptance at 1 ms from contested-startup success. The generic parameter refusal duty is also in the checklist's Before production section; no current per-value refusal fixture is being claimed.
- The supplied `check/timeout-probe.json` is parser-only PostgreSQL 17.9: both settings reproduce the printed 400us→0, 600us→1, 1500us→2 and 1ms→1 grid, and show the range 0..2147483647 ms. Fable/Opus add parser-only half-to-even and boundary observations. They are not 18.6 executions or elapsed-time tests. Official [unit conversion documentation](https://www.postgresql.org/docs/18/config-setting.html#CONFIG-SETTING-NAMES-VALUES), [timeout documentation](https://www.postgresql.org/docs/18/runtime-config-client.html#GUC-STATEMENT-TIMEOUT), and [REL_18_6 setting declarations](https://raw.githubusercontent.com/postgres/postgres/REL_18_6/src/backend/utils/misc/guc_tables.c) independently confirm conversion/rounding, zero disabling, millisecond units and the integer limits. 18.6 source inspection is distinct from a parser run.
- EXACT admits duration values equal to positive whole milliseconds in both settings' range, including equivalent unit spellings. FLOOR admits finite d with d≥1 ms and 1≤floor(d/ms)≤M, including a fractional tail above M ms but below M+1 ms. A whole-ms over-range input fails both. No fixed maximum is being added to the spec independently of its settings.
- `05-persistence.md:170`: STO-7 says “The client-side deadline on any store call MUST NOT be shorter than the server-side timeouts above” and “A standby wait has no server-side timeout”. `OPS-15` retains “On that timeout or any store error, including a lost reply on its commit”. A SyncRep holder blocking the replacing statement differs from the advance's own commit waiting for a standby. Neither package claims to bound the latter.
- No existing Lean declaration formalizes this parameter's numeric precision or serialization. Relevant OVR-19 and OPS-15 tags model other properties. Fable's incidental claim of only two OPS-15 tags in Restore is inaccurate (see the declarations in Restore.lean); that count is not evidence for the numeric claim and changes no vote.
- Opus's argument against a cheaper pass-through rule correctly notes 1.5 ms may become 2 ms, but STO-7 alone does not forbid that design: a sufficiently long client deadline could satisfy it. EXACT's preference rests on avoiding conversion and identity drift, not a proof that every cheaper rule violates STO-7.

**Next:** ready for the owner, not ready-for-agent. Input compatibility and the added conformance observations are policy/cost choices, without a prior owner decision choosing exact precision. Put the exact printed K-EXACT plus verified Sol R1 to the owner; amend OVR-19/CNF-369 and the ADR pointer if approved. OPS-15's timeout, fatal exit and lost-reply text remain unchanged in that form.

## Q2 — pv-75w3

| Reader | Actual mark and pick | Strongest actual argument | Conditions / counted result |
|---|---|---|---|
| fable | S-STOP AMEND; prefers S-STOP as amended | The durable stop result already lies in Fence's trace set; retry coverage catches code incorrectly keyed on resolution route. | Exact span, preserved historical ADR paragraph/date annotation, and fixed-outcome model description; wording-only after verification, 1 counted conditional ACCEPT under rule 1. This does not accept any later synthesis. |
| opus | S-STOP AMEND; NONE as printed | Retained route-1 selectors contradict promised survived-stop suspension coverage; literal whole-paragraph replacement could also remove transaction-order instrumentation. | R-S1 is behavioural fixture selection, so no counted ACCEPT. Also requires exact span, quoted store-error warning, owner quote retention and fixed-outcome wording. |
| astra | S-STOP AMEND; NONE | The specific retained table/fan-out can omit the new stop-derived suspended case. | Two behavioural selector repairs; also remove obsolete exhaustive ADR wording and repair owner quotations. No counted ACCEPT. |
| sol | S-STOP AMEND; NONE | The new two-prefix driving instruction does not override retained route-1-only fixture instructions by any stated precedence. | Behavioural fixture repair R3, plus source-quotation repairs. No counted ACCEPT. |
| grok | S-STOP AMEND; NONE | The same leftover selectors can pass without exercising current suspension after a survived stop. | Behavioural selector repairs and preservation of read/commit instrumentation. No counted ACCEPT. |

**Count:** S-STOP 1 conditional counted ACCEPT after verified wording-only repairs (fable), 4 behavioural AMEND / no counted ACCEPT (opus, astra, sol, grok), 0 CANNOT ACCEPT. Agreement 1 / disagreement 4 on the package after rule-1 counting. Raw unconditional acceptance of the printed bytes is 0. Explicit preferences: fable amended S-STOP, the other four NONE. There are not three agreeing complete-form acceptances, so no settlement and no owner tie-break. A combined repair is unreviewed.

### Checked trace and minority review in full

The same pinned owners support every reader's direction:

1. The fixture uses a real sweep and claim, with no admission/restore deferral. OPS-48 says the episode is opened “with its first attempt enqueued in the same transaction”. Stop delivery occurs during cancellable execute and before **sending** the fence transaction; it does not rely on an unknown in-flight reply.
2. OPS-21 says “A cancellation of `execute` that the engine survives MUST be recorded before the engine exits” and “The record write MUST NOT be cancelled by the cancellation that stopped `execute`”. S1 requires acknowledgement within both bounds and excludes later stop/supersession. Survival and store availability alone would not promise timely acknowledgement.
3. OPS-11's last row at :248 says “any failure the worker records while `OPS-45`'s write-started marker is unset” and “MUST settle `failed`, whatever its kind”, subject to goal-state success, rescue cleanliness and known acceptance. Fresh pre-fence cancellation dispatched no mutation and opened no rescue session. OPS-45's marker row says “the provider call is dispatched”. Thus the selected failure is failed with null marker.
4. OPS-21 supplies “a cut-off `conflict` with `details.reason: "cut_off"`”. WIR-9a at :141 lists `"cut_off"` under conflict. OPS-22 supplies the claim/status guard and OPS-50 the generation check. Neither writes the cancellation fence; OPS-42's mutation transaction is distinct.
5. OPS-48's failed row is stalled with fence “**Unchanged**”; it explains “An episode none of whose attempts reached the fence transaction holds null.” Thus failed/stalled/null-fence/null-marker/no-provider-call is supported, without operator resolution.
6. OPS-41 step 2 says “A retry reading the fence null decides from step 3 unless the tenant is suspended now.” Orders A/B must instrument the deciding transaction's reads/commit, and the currently suspended row must still call the provider rather than close funded. The fenced/undispatched control distinguishes an episode fence from the previous attempt's dispatch marker.
7. `Fence.failBeforeFence` matches holding plus an attempt and invokes `finish w n a .failed .failed`. `finish` uses the worker write and `applyRow`; `Tables.episodeStep` maps attempting/settled-failed to stalled without clearing the fence. The witness `interrupted_retry_prefix_witness` already evaluates sweep/claim/failBeforeFence to stalled/null. Six existing case proofs include the event. `extension_first` retains its null-fence, rate, funding and suspension hypotheses. No code/theorem/guard change is needed.
8. StopRecord and Fence are not composed: their imports and `StopRecord.working_store_records` prove the separate recording boundary; Fence takes the landed failed result abstractly. No running-service, stop-scheduling, bounded-record/Fence composition or dispatch-marker proof follows.

Fable is the lone reader willing to accept after wording-only repairs. Its entire durable-result trace above is verified. Its span repair preserves the instrumentation; its historical annotation makes the retained old paragraph explicitly historical; replacing “input” with a record assumed landed fixes the explanatory ambiguity without changing an event. Those are wording-only and count under rule 1. However, fable did not address the untouched suspension selectors at CNF-312:2475 and :2488. The other four readers' trace is verified: the general new instruction says both prefixes while those specific retained instructions still say “from the route-1 prefix” and “Use the route-1 prefix”. Following the specific row can omit the new survived-stop suspension case. This is a declared-new-coverage inconsistency, not an invented baseline loss; its repair is behavioural under rule 1. Fable's counted conditional acceptance therefore does not settle the package or make its repairs panel-reviewed.

### Other factual corrections and safeguards

- Fable dates the now-unambiguous failed classification to 2026-10-18 alone. OPS-21's bounded survived-stop duty is from that date, but OPS-11's last-row alignment and pointers were adopted 2026-10-23 by ADR-0046 (“A delete cut off before dispatch exposed the disagreement”). Correct this chronology; fable's present-pin trace remains sound and its wording-only historical annotation does not depend on that mistaken date.
- Several readers loosely say later stop, timeout or generation refusal “leave the row running”. This is not universal: OPS-21 says the sent transaction's fate is the server's, and OPS-50 says “an earlier attempt may already have committed with its reply lost”. Only a row still running reaches startup recovery. Astra/Sol explicitly preserve this caveat. No counted vote depends on universal running persistence; S1 excludes these exits.
- “The durable outcome is an input” is defensible abstraction language, but the event has no outcome argument and fixes failed. The next form should say the event assumes the record landed, with its fixed failed outcome, and retain the larger trace set and non-composition limits.
- ADR-0032:30 says established routes “are crash and restore”; :43 quotes owner comment 194 “Covers all three routes”. Retain the owner's historical words, label the old scope historical, and remove the earlier sentence's exhaustive form. This changes no fence-keyed policy or rejected alternative.
- S1's “two paragraphs beginning with the OPS-45 quote” misdescribes the layout: that quote is the end of route 1's paragraph. Replacing whole paragraphs could delete the two lines beginning “Instrument the deciding fence transaction's read/commit boundary”. Opus's potential blocking-loss trace is correct **if that literal span were chosen**: API enqueue order is not transaction order. The other explicit end anchor points before the instrumentation. The next form pins both endpoints, retaining the two lines byte for byte. No lost verdict is assumed from the ambiguous instructions alone.
- No safeguard is deleted: store errors alone retain OPS-49's “the component MUST repeat the **whole transaction**”; crash/no-requeue, stop-record exits, generation/claim guards, marker acknowledgement, suspension precedence, fenced controls and extension ordering remain. OPS-23's independent validation ordering is not an injection trigger. Model code/proofs and all guards remain unchanged.

### Brief claims broken; rule 6 disposition

Q1: omitted shared OPS-47 input-domain effect and ADR-0047 quotation maintenance; neither changes the conversion premise. The bead's earlier “under 0.5 ms” is too narrow on 17.9 (500us also rounds to zero); the brief's actual measured grid and version are accurate.

Q2: incorrect paragraph-boundary description; incomplete selector scope despite claiming consistent examples/criteria; obsolete exhaustive ADR sentence; ambiguous fixed-outcome description; missing source quotations in proposed S2/S4 and store-error summaries. These are package/layout/quotation errors, not disproof of the survived-stop premise. The author-consistency PASS in check/source-verification.json is disproved by the retained selectors. No question is void. No final vote is recharacterized because of a requested counterargument.

**Next:** prepare and, after fresh quota/login clearance, launch a five-seat r78b read of one complete S-STOP-R package fixing the verified issues. All combined repairs need that read. Existing owner decisions cover the marker classification and fence-keyed retry policy; a later settlement may qualify as mechanical ready-for-agent only after checking its exact form stays within those decisions. This tally authorizes no implementation, tracker write or Run.

## Verification and boundary

All source files named in check/tally-evidence.json match git-show bytes at the pin. Initial independent unpiped full Nix gate in check/spec: `check/gate-tally-before.exit` = 0. Final gate receipt and follow-up launch status are recorded in STATE.md. Gate success is baseline validation, not runtime execution of either candidate. No new runtime test, parser run or composed proof was performed by the tally manager. Reader-reported gate experiments do not replace those limits.

All writes are in this panel folder. No main-checkout worktree/branch/tracker command, manager-brief write, production access, commit, push or account switch was performed.
