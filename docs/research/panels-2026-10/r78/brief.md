# r78 — Panel C draft: startup timeout and survived-stop coverage

**LAUNCH AUTHORIZED BY MAIN, 2026-10-28.** This file has not been panel-reviewed. Main authorizes this five-reader round only. No adoption, tracker write, source implementation or follow-on is implied.

Review pin: **cebdc4f8f728f40d7fdf3c10ed094a1a7d2b8527**, master after PR #30 (pv-6350). Read this brief and /var/tmp/provisiond-panel-r78/notes.md whole. Each reader has an independent detached clone of this pin under this folder. Resolve panel artifacts under /var/tmp/provisiond-panel-r78/, not under your clone. The main checkout is occupied by the pv-c7vg drain: never inspect/mutate it, its branches or shared tracker. Do not run br, commit, push, change branches, contact production or read credential/session/config stores including ~/.grok, ~/.claude or ~/.codex. Work only in your own clone and your own ../<reader>.draft.md. No delegation or background work. Every unit must use MemoryMax=16G, MemorySwapMax=0, OOMPolicy=continue and timeout 3600. Save a substantive draft by minute 45; return a final answer in this turn, about 1600 words plus exact repairs/evidence.

Five seats: fable claude-fable-5-1 xhigh; opus claude-opus-5-5 xhigh; astra gpt-6-astra high; sol gpt-6.1-sol xhigh; grok grok-4.7 xhigh. Treat the questions separately. Give ACCEPT / AMEND / CANNOT ACCEPT on every whole candidate, then one explicit preference among acceptable candidates or NONE per question. Exact location, before/replacement and changed/unchanged behaviour are required for AMEND. A new minimum, rounding rule, runtime obligation, conformance assertion, fixture restriction or model mechanism is behavioural; it is not normalized to wording-only. A direction vote is not package acceptance. Report requested counterarguments separately from votes.

**apply notes.md rule 6 exactly as written; this prompt adds no void rule.** The owner's threshold and unchanged no-verified-blocker rule apply. Separately check internal consistency: do the rules, examples, acceptance criteria and scope agree? A policy/cost choice still goes to the owner; ready-for-agent requires existing owner authorization. No synthesis or repair becomes reviewed just because one reader proposes it.

## Q1 — pv-kwuf: prevent a positive wait becoming a disabled timeout

Plain terms: an operator writes a very small positive wait. The database converts it to zero, which switches the timeout off. Startup can then wait without the configured protection. Which exact input/serialization rule should prevent that, and which existing startup check demonstrates the refusal?

The source type currently admits any finite positive duration; the startup clause uses the same bound for both database timeouts. This is a numeric/validation question, not authority to change the generation protocol, startup lock, synchronous replication or lost-reply exit.

### Checked evidence and its limits

PostgreSQL's official [configuration units documentation](https://www.postgresql.org/docs/18/config-setting.html#CONFIG-SETTING-NAMES-VALUES) describes conversion followed by integer rounding. Its [statement and lock timeout documentation](https://www.postgresql.org/docs/18/runtime-config-client.html#GUC-STATEMENT-TIMEOUT) identifies integer milliseconds and zero as disabling the timeout; see also [lock_timeout](https://www.postgresql.org/docs/18/runtime-config-client.html#GUC-LOCK-TIMEOUT).

A local parser-only probe, with no database server started or contacted, used **PostgreSQL 17.9**: both settings read back 400us → 0, 600us → 1, 1500us → 2, 1ms → 1, and zero → 0; negative input was refused. Raw receipt: /var/tmp/provisiond-panel-r78/check/timeout-probe.json. The bead reports a prior 18.6 probe; this preparation did not repeat on that version. These facts establish conversion risk, not an elapsed-time or live-service bound. Do not infer whole-transaction/commit/synchronous-standby timeout coverage from statement_timeout: inspect STO-7 and OPS-15's existing caveats. No proposed candidate has been executed.

### Pinned sources

**00-overview.md:359–369 at the pin:**

> 
> **OVR-19** **A parameter is on this register or it is not a parameter.** Every value the set
> says a deployment MUST state is listed here, with the requirement that mandates it. Startup MUST
> validate every startup-validated row and refuse to run on a missing or out-of-range value; the rows
> marked human are procedures the deployment records rather than values the process reads.
> 
> *Amended 2026-10-08 (`ADR-0034`): refresh freshness is registered below. Amended
> 2026-10-09 (`ADR-0036`): the order declaration is per account and channel, and the
> activation funding minimum is registered. Amended 2026-10-12 (`ADR-0037`, Q28):
> refresh freshness has a two-sweep minimum. Amended 2026-10-18 (`pv-tst`; panels r58 and r58b, `docs/research/panels-2026-10/r58/` and `docs/research/panels-2026-10/r58/r58b/`; `ADR-0044`): registered the Stop-record bound. Amended 2026-10-23 (`pv-s4m`; panel r63, `docs/research/panels-2026-10/r63/`; owner decisions Q1 “I think we should just suppose synchronous replication”; S1 “Three servers (Recommended)”; S2′ “A: stop on time (Recommended)”; `ADR-0045`): registered the standby names and pooled-connection keepalives; removed the synchronous-commit concurrency cap. Amended 2026-10-24 (`pv-buc`; panel r66e, `docs/research/panels-2026-10/r66/r66e/`; owner decisions “Yes, R (Recommended)” and “Adopt; one combined Run”; `ADR-0047`): typed the Startup-lock wait bound as a finite, positive duration and named it as the generation advance's two timeouts.*

**00-overview.md:408–412 at the pin:**

> | Negative-resolution window, per provider | `OPS-33` | duration | yes |
> | Tenant-to-account assignment policy | `API-57`, `SEC-43` | policy over assignable accounts | yes |
> | Startup-lock wait bound | `OPS-47`, `OPS-15` | finite, positive duration; also the generation advance's `statement_timeout` and `lock_timeout` (`OPS-15`) | yes |
> | Startup-lock connection keepalives | `OPS-47` | durations | yes |
> | Store-retry bound | `OPS-49` | duration | yes |

**03-operation-lifecycle.md:378–395 at the pin:**

> 
> The engine's first write transaction after taking `STO-51`'s lock MUST contain only the
> replacement of `STO-59`'s startup generation (`OPS-50`'s exception). `OPS-50` says "Except for `OPS-15`'s generation-advance transaction". Its commit MUST be
> acknowledged before the engine begins any other write transaction, the remainder of the pass, or
> any worker or periodic component. The engine makes no write before that transaction. Its
> replacing statement MUST run with `statement_timeout` and `lock_timeout` both set to `OVR-19`'s
> Startup-lock wait bound. That statement waits on every open `FOR SHARE` of the row (`OPS-50`),
> so every earlier engine's write either committed before it, and is swept here, or is refused
> after it. On that timeout or any store error, including a lost reply on its commit, the engine
> MUST log loudly and exit non-zero having claimed nothing; this exit is not `OPS-49`'s retry,
> which covers workers and periodic components. **Liveness:** a `SyncRep` holder (`STO-7`: "A
> standby wait has no server-side timeout"), or share holders that keep turning over, can hold the
> advance until that exit, which `OVR-18` alarms; the supervisor's restart is the retry.
> `OPS-49` says "Where a store call by a worker, or by a periodic component running in the engine
> process (`OVR-17`), errors or times out". `OPS-50` says "hold that lock until it commits" and
> "Where the values differ, the transaction MUST roll back". `OVR-18` says "its startup exit on
> the generation advance's timeout (`OPS-15`)".

**10-conformance-checklist.md:1655–1664 at the pin:**

> - [ ] **CNF-368** — With no engine holding `STO-51`'s lock, open a store session outside the
>       pool, with `idle_in_transaction_session_timeout` and `statement_timeout` disabled, that
>       reads `STO-59`'s row `FOR SHARE` and claims a `queued` operation, its transaction left
>       open. Start an engine: assert its generation write waits; commit the session; assert the
>       engine's sweep moves the claimed row to its `OPS-15` startup state.
> 
> - [ ] **CNF-369** — As `CNF-368`, but hold the session past the Startup-lock wait bound: assert
>       the engine logs loudly and exits non-zero having claimed nothing, `STO-59`'s value is
>       unchanged, and the session's commit then succeeds.

### Whole candidate K-EXACT

1. In OVR-19's **Startup-lock wait bound** type cell replace:
   > finite, positive duration; also the generation advance's `statement_timeout` and `lock_timeout` (`OPS-15`)
   with:
   > finite duration expressible exactly as a positive whole number of milliseconds accepted by both `OPS-15` timeout settings, minimum 1 ms; also the generation advance's `statement_timeout` and `lock_timeout` (`OPS-15`)
   This register cell owns the admissible range/precision. OVR-19 already orders startup validation; do not duplicate the numeric rule in OPS-15. Equivalent unit spellings are allowed when their duration is an exact whole millisecond.
2. Keep OPS-15's existing timeout-setting and loud/nonzero/no-claim exit sentences unchanged. No new retry or read-back protocol is added.
3. Append to CNF-369:
   > On independent startup attempts, supply a missing bound, zero, a negative duration, a non-finite duration, 400 microseconds, 600 microseconds, 1500 microseconds, and a whole-millisecond duration outside either store setting's accepted range. Assert startup refuses each with a non-zero exit before the generation advance, with no generation change, claim or provider call. With a bound of exactly 1 millisecond, assert validation accepts it and both effective timeout settings on the advance's connection are 1 millisecond; validation acceptance does not require the contested generation advance to succeed. Preserve this item's held-share timeout case and its existing exit/generation/session-commit assertions.

This changes accepted deployment inputs: all fractional milliseconds are refused, including ones PostgreSQL would round to a positive value. It adds runtime conformance checks, not a promise about an implementation's representation type.

### Whole candidate K-FLOOR

1. Instead use this OVR-19 type cell:
   > finite duration at least 1 ms whose downward-rounded whole-millisecond value is accepted by both `OPS-15` timeout settings; also the generation advance's `statement_timeout` and `lock_timeout` (`OPS-15`)
2. In OPS-15 replace its timeout-setting sentence:
   > Its replacing statement MUST run with `statement_timeout` and `lock_timeout` both set to `OVR-19`'s Startup-lock wait bound.
   with:
   > Its replacing statement MUST run with `statement_timeout` and `lock_timeout` both set to the whole-millisecond value obtained by rounding `OVR-19`'s Startup-lock wait bound down.
   Preserve the following error/timeout exit and supervisor retry. The register owns validation; this sentence owns serialization. No read-back protocol is added.
3. Use K-EXACT's CNF-369 addition, except remove 1500 microseconds from the refused inputs; add:
   > With a bound of 1500 microseconds, assert validation accepts it and both effective timeout settings on the advance's connection are 1 millisecond. The unconverted value must not be passed to PostgreSQL to round to 2 milliseconds.

This deliberately admits fractional durations at or above 1 ms but applies a shorter whole-millisecond timeout. It adds a conversion obligation and changes precision, rather than claiming PostgreSQL's own rounding always respects the requested number. Minimum, normalization and expected effective settings are one whole package.

### Q1 adversarial checks

Verify the range, units, minimum and zero-disables premise; name any difference between versions actually checked. Is refusing values already covered by OVR-19, so adding a second runtime rule would create another home? Does either form require a new formalized definition, or only conformance/parameter prose? Check maximum/overflow/non-finite inputs and equivalent unit spellings. Explain what the existing timeout guards and cannot guard; no proposed change may silently weaken the generation/lost-reply exits or claim a standby-commit bound the store does not give. Is a cheaper complete form sufficient? Give its exact words if AMEND, not acceptance of an unread repair. Report any stronger data/tool measurement as new evidence with its real version, not proof that this draft already did it.

## Q2 — pv-75w3: a survived stop can settle a cancellation before fencing

Plain terms: a worker has picked up a deletion but has not written the promise to delete yet. The engine receives a stop, survives long enough to record it, and the store works. Must that record produce a failed attempt with the machine still unfenced, and should the retry checks exercise that route as well as a crash followed by operator resolution?

The issue is stale reachability/coverage prose after the survived-stop requirement, rather than a request to change fencing, cancellation classification or revival policy. A store error by itself still follows whole-transaction retry and is not a worker-classified failure. A survived stop is a separate trigger. Check this distinction against OPS-21 before accepting the premise.

### Pinned sources

**03-operation-lifecycle.md:1784–1810 at the pin:**

> **OPS-21** `execute` MUST be cancellable. A cancellation of `execute` that the engine survives
> MUST be recorded before the engine exits, for every operation kind, subject to the bounded
> abandonment, later-stop and superseded (`OPS-50`) exits below. “Survives” means the process
> outlives the stop. A kill or crash records nothing; at the next start, `OPS-15` says "the engine
> MUST move every `running` operation to `needs_reconciliation`", subject to its exceptions. A
> stop that arrives while a store transaction inside `execute` is in flight or repeating under
> `OPS-49`, such as `OPS-43`'s step-8 transaction or an `OPS-45` marker write, is the cancellation
> being recorded. A transaction already sent MAY finish, since `OPS-49` says "the server decides
> every statement's fate before the client does"; the worker MUST NOT repeat it or begin anything
> it precedes, and makes the record. The worker MUST NOT pursue the record past the Stop-record
> bound (`OVR-19`), and the engine MUST NOT wait for it past that bound.
> 
> The worker classifies a recorded cancellation under `OPS-11` and makes its record write: the
> guarded write of `OPS-22`, except for a parent, whose record write is the defer below. The
> recorded error is a cut-off `conflict` with `details.reason: "cut_off"` (`WIR-9a`), for every
> kind whose record write is the guarded one, whether the row settles `failed` or enters
> `needs_reconciliation`.
> A provider call abandoned mid-flight whose failure enters `OPS-11`'s classifier is exactly the uncertainty this design exists to represent.
> For a create, a cancellation of `execute` recorded before step 9 is the exception, under the
> create row. `OPS-11` says "Any create failure the worker records before any step-9 request (before any per-order key upload or order request) MUST settle `failed`, whatever its kind."
> The other classification pointers are `OPS-11`'s install row, "while `OPS-45`'s two markers say
> the disk is untouched and no rescue session was left open", rescue inventory's "Same rows as
> `install`", the last row's "any failure the worker records while `OPS-45`'s write-started marker is unset", and
> refresh's "Always `failed`". The kind's row owns the outcome, including where
> it reads ambiguity.
> Where the row reads `OPS-45`'s markers, the record MUST classify against the markers its own transaction reads, since a marker write whose reply was lost may have committed.

**03-operation-lifecycle.md:1181–1193 at the pin:**

> V2 exclusion of all `API-64` attempts from funding. The general abort-and-settle shape remains
> unconditional. Verification: `CNF-312` and `CNF-272`.*
> 
> *Model verification amended 2026-10-05 (`pv-gip.43`):
> `Provisiond.Fence.extension_first` uses the admitted extension's null fence directly to exclude
> the guarded retry exemption. It covers ordinary and retried attempts without assuming either
> reachability or a previously fenced episode. The enlarged lifecycle admits interruption,
> resolution and abstract pre-fence failure; the former RetryFenceInv and retry_has_episode_fence
> are withdrawn, falsified by sweep, claim, interrupt, resolve notApplied, retry with an open
> episode and null fence. Pre-fence failure is an over-approximation, not a specified injection
> point. The proof establishes no full crash/restore procedure, queue scheduling, database
> serialization, provider behavior or running-service conformance.*

**10-conformance-checklist.md:2435–2458 at the pin:**

> - [ ] **CNF-312** — **Interrupted cancellation before its fence (2026-10-05, `pv-gip.43`, Q14).**
>       Exercise `OPS-41` step 2 and `OPS-42` ordering on independent instances with an
>       available rate, a healthy provider account and no other admission refusal. Each starts
>       unfunded with an active tenant; the suspended row below changes that tenant's state.
>       For Orders A and B, provide sufficient available balance and choose an extension that
>       funds the machine at the deciding rate. The other rows use a favorable rate and
>       re-derivation to fund it, without an extension.
>       **Route 1 prefix:** let the sweep enqueue the cancellation and the worker claim it, then
>       kill the worker before its fence transaction. Restart: `OPS-15` requires "move every
>       `running` operation to `needs_reconciliation`" and "MUST NOT move them back to `queued`".
>       Assert that operation state and episode `uncertain`. Resolve `not_applied` as operator:
>       assert the attempt `failed`, episode `stalled`, null `destroy_committed`, null
>       `write_started_at`, and zero provider calls throughout the prefix. Drive the actual
>       lifecycle; manually seeded stalled rows and startup requeue do not satisfy this case.
>       `OPS-45` says "This rule classifies a failure a worker recorded"; it orders no such failure
>       before this fence write.
> 
>       `OPS-23`'s "before the driver is called" establishes no such ordering either. Therefore
>       drive route 1 alone. Do not inject a store error as a separate
>       failed route: `OPS-49` requires "repeat the **whole transaction**" and on bound exhaustion
>       "the engine MUST exit non-zero".
>       Orders A and B and the suspended/null-fence row each start from a fresh instance of
>       that route-1 stalled/null-fence prefix. The fenced rows use their own prefixes below.
>       Instrument the deciding fence transaction's read/commit boundary:

**docs/adr/0032-revival-is-an-operator-decision.md:43–52 at the pin:**

> Owner comment 194 says "Covers all three routes", including worker-recorded pre-fence
> failure. The fence-keyed rule covers that condition if such an ordering is ever specified;
> no current clause orders a worker-recorded failure before the fence write: `OPS-45` says "This rule classifies a failure a worker recorded";
> its interruption rule applies "whatever the markers hold". `OPS-23` requires validation
> "before the driver is called", which does not order it before the fence. Store failures instead
> follow `OPS-49`'s "repeat the **whole transaction**" and, on exhaustion, "the engine MUST exit
> non-zero". Thus this amendment specifies no separate route-3 injection. The model deliberately
> admits abstract pre-fence failure as an over-approximation; `CNF-312` drives the established crash
> route only. In every case the rule is keyed on the fence, not the route.

**tools/formal/Provisiond/Fence.lean:90–100 at the pin:**

> What the model omits: the first 2026-09-05 form of
> the suspension exemption, keyed on the attempt's own reason; a second attempt enqueued while one is
> in flight (the model holds one attempt, and every enqueue waits for it); full crash and restore
> procedures. `interrupt` models only interruption while holding, before the fence transaction;
> `resolve` admits the non-create verbs only from a needs-reconciliation attempt and preserves
> closed episodes. It omits evidence gathering, scheduled resolution and database publication.
> `failBeforeFence` over-approximates worker-recorded pre-fence failure: no current ordering
> clause establishes that injection point. Proofs cover this larger trace set, which supplies
> no implementation conformance fixture. Also omitted: `LDG-62`'s sizing of the
> commitment it grows — `extend` takes the satoshis as given — and its wire answers (`API-7` owns collection and ordering; `Provisiond.Admission`
> checks that tail): every refusal here is the unchanged world, whichever test

**tools/formal/Provisiond/Fence.lean:982–991 at the pin:**

> /-- Abstract worker-recorded failure before fencing. This is an over-approximation, not an
> established injection point; OPS-49 store failures are not classified by this event. -/
> @[req "OPS-45"]
> def failBeforeFence (w : World) : World :=
>   match w.phase, w.attempt with
>   | .holding n, some a => finish w n a .failed .failed
>   | _, _ => w
> 
> /-- OPS-31 non-create resolution, only for a needs-reconciliation attempt. An old attempt may
> settle after its episode closed; applyRow preserves that close. Evidence and receipts are omitted. -/

### Whole candidate S-STOP

S1. Preserve CNF-312's real crash/restart/operator-resolution route, its fenced controls and its extension/fence decision table. Replace only the obsolete two paragraphs beginning with the OPS-45 quote after route 1 and ending with route-1-only fixture selection with:

> **Survived-stop prefix:** on a fresh independent instance with the same funding, account and tenant conditions, enqueue and claim the cancellation, then deliver a stop while `execute` is cancellable and before the first fence transaction is sent. Keep the engine alive and the store working until its stop record is acknowledged within the stated bounds, with no later stop or superseding generation. Assert the original attempt settles `failed` with cut-off `conflict` and `details.reason: "cut_off"`, the episode is `stalled`, `destroy_committed` and `write_started_at` remain null, and no provider call occurred. No crash, startup classification, operator resolution or manually seeded stalled row substitutes for this prefix. For stop classification and recording, see `OPS-21` and `OPS-11`.
>
> Drive Orders A and B and the suspended/null-fence row on separate fresh instances of each prefix: route 1 and the survived-stop prefix. The fenced rows retain their own prefixes below. A store error alone remains `OPS-49`'s retry path, not a separate worker-recorded failure. Keep the record store available within both stated bounds; this is a recording-success fixture, not abandonment or a lost-reply/later-stop case.

The selected boundary is before **sending** the first fence transaction, not merely before its reply. A refused in-flight fence transaction can be examined separately; accepting this candidate adds no new fixture for that more complex boundary. The Stop-record transaction still performs its ordinary generation/claim guards. Do not add retryability or payload fields outside the existing owners' requirements.

S2. In OPS-41's verification note replace:
> Pre-fence failure is an over-approximation, not a specified injection point.
with:
> `OPS-21` supplies the survived-stop pre-fence failure route; `CNF-312` owns its conformance prefix. The model does not compose stop delivery or bounded recording with this lifecycle.

S3. Replace ADR-0032's paragraph beginning “Owner comment 194 says” through “In every case the rule is keyed on the fence, not the route.” with this current amendment record, preserving the rejected alternatives:
> *Amended on landing for `pv-75w3`:* `OPS-21` says "A cancellation of `execute` that the engine survives MUST be recorded before the engine exits". `CNF-312` owns the survived-stop pre-fence prefix alongside its crash prefix. For classification see `OPS-11`; for the record and its bounded exits see `OPS-21`; for extension/retry ordering see `OPS-41` and `OPS-42`. A store error alone remains the `OPS-49` whole-transaction path. The decision remains keyed on the fence, not the route.

Use the actual landing date in that amendment record. Do not erase the historical decision/rejected alternatives or duplicate its argument elsewhere.

S4. Update the formal declaration's explanatory text together with OPS-41/ADR-0032. In Fence.lean's module introduction replace the passage beginning “`failBeforeFence` over-approximates” and ending “implementation conformance fixture.” with:
> `failBeforeFence` admits a worker-recorded failure before fencing, including the survived-stop route specified by `OPS-21`. It does not model stop delivery, bounded recording or their composition with this lifecycle; the failure's durable outcome is an input here. Implementation observations remain conformance obligations.

Replace failBeforeFence's docstring with:
> Worker-recorded failure before fencing, including `OPS-21`'s survived-stop route. Stop delivery and bounded recording are outside this model; `OPS-49` store errors alone are not classified by this event.

Keep the existing requirement tag, transition definition, hypotheses, theorem statements and witnesses unchanged. No `CNF` identifier goes in tools/formal/. Read the existing event before judging whether those doc changes truthfully describe it. This is no new proof or integration of StopRecord and Fence. If the two models must be composed to justify this form, vote AMEND and give the exact required boundary; do not claim that coverage already exists.

### Q2 adversarial checks

Trace enqueue → claim/hold → originating stop before sending fence → guarded bounded record → failed/stalled/null fence and null marker → fresh retry, with no provider side effect. Quote the exact OPS-11/OPS-48 row and WIR-9a cut-off mapping that make the assertions true. Can the record run without setting the cancellation fence? If a startup lock/generation loss, later stop or exhausted bound prevents recording, distinguish that exit from this working-store/no-later-stop fixture. Preserve no-requeue after crash, store-error retry, marker acknowledgement, current suspension precedence and extension/fence order. Does the current Fence event already cover the durable result without weakening a theorem? A theorem about a larger trace set is not a running-service test or a composed cancellation proof. Inspect the now-specified trigger before retaining “no current ordering clause” as fact. Name any deleted safeguard's purpose and any checked/normative verdict lost. Runtime conformance and new proof are not supplied by this preparation.

## Answer/handoff

For Q1 give marks on K-EXACT and K-FLOOR plus a preference or NONE. For Q2 give a mark on the entire S-STOP package and preference S-STOP or NONE. Check the whole package, not only its chosen direction. Quote exact before/replacement for every AMEND and mark changed/unchanged behaviour. Give the strongest actual argument and conditions, then a labelled requested counterargument against your preference. List every broken factual claim in this brief and whether it changes that question's premise under rule 6. List checks actually run, failures and not-run checks. No implementation or automatic next round is approved.
