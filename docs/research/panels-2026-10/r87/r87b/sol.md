**Final: Q1 O**

I prefer exact printed O: report the refusal and stop immediately, leaving deployment to invoke `migrate` again. It preserves the complete boundary and fixtures without requiring peer-runner status.

| Exact form | Verdict |
|---|---|
| **A** | **ACCEPT**, less preferred because of its additional information obligation. |
| **B** | **CANNOT ACCEPT**: its printed recovery fixture conflicts with its expiration rule. |
| **C** | **CANNOT ACCEPT** as the complete timing answer; it permits arbitrary finite delay before exit. |
| **D** | **CANNOT ACCEPT** as resolution of the missing outcome. Preserving that gap is an available owner scope choice. |
| **F** | **ACCEPT**, exactly as printed, including “as the authority returned it”. |
| **O** | **ACCEPT**, exactly as printed; preferred. |

F and O are separate acceptances. My final preference is O alone; this answer supplies no panel tally.

I read notes.md whole and verified this clone’s HEAD as `3109b5b44eae17e288cf52aaa976993bd8c5626c`. No source, Git state, tracker or panel records were changed. No gates, builds, subagents or follow-on work were run.

**Diagnostics.** A’s “whether another migration runner is active or scheduled” has no defined information source in the pin. [STO-55](05-persistence.md:285) binds grants to “component/attempt identity”, but also says “Timeout, transport loss, process exit and rollout completion never release a grant”. A retained migrator grant therefore cannot establish a live peer.

That does **not** prove A impossible. A deployment could supply scheduler and process-status information outside the protected database. STO-55’s “The enforcement construction is the deployment’s” leaves implementation choices open, although it does not itself define that diagnostic source. I accept A’s added obligation; I prefer avoiding its cost and ambiguity.

F and O independently remove that field. F requires the reported reason to come from the refusal response: a credential-free reason code or text can satisfy “as the authority returned it”. O permits a faithful normalized explanation without that provenance wording. Neither needs peer-liveness inference. I accept both without a textual repair.

**B’s blocking conflict and my corrected prior judgment.** B’s proposed STO-55 rule says:

> “If no confirmed reservation is obtained before the bound expires, `migrate` MUST report exhaustion and exit non-zero.”

Its proposed CNF-57 recovery fixture says:

> “with verified capacity release before expiry … continuation without first exiting”

Take the specified ten-second episode. Refusal starts it at zero; the runner enters backoff or awaits an authority response. Capacity is verifiably released at 9.9 seconds. At ten seconds no reservation has been confirmed. The rule requires exhaustion and exit; the recovery fixture requires continuation without that exit. The packet supplies neither a response guarantee nor a backoff cadence that excludes this trace.

The bound protects a finite post-refusal waiting episode, including further calls and backoff without reset. Disabling expiration to satisfy recovery would defeat that protection and flip the exhaustion assertion. This conflict concerns B’s **new** normative rule and **new** checked verdict; no existing theorem or conformance assertion needs weakening.

“Confirmed usable reservation” also needs care. [STO-7](05-persistence.md:192) says a connection whose check has not passed is “a failed connection attempt: the connection is closed unused”. B excludes “transport or connection checks after a grant” from its bound. Grant confirmation must therefore not silently be treated as proof that the subsequent connection passes those checks. This terminology issue is additional to the decisive fixture conflict.

I withdraw r87 Sol’s **B ACCEPT** and its statement that no candidate contradicted its fixture. I am not counting an unprinted repair as B.

**C’s narrower contract.** C says “exit non-zero for deployment retry”. A runner can receive refusal, deliberately sleep for an arbitrary finite interval, emit no diagnostic, and then exit non-zero. C’s printed exit assertion passes. Naming deployment as the retrier does not supply an elapsed bound or exclude that sleep.

This is a coherent weaker contract if intentionally chosen. I reject it as the complete answer to Q1’s timing and reporting question, rather than alleging a lost baseline safety obligation. I do not import A’s “at once” into C.

**Execution traces and fixture meaning.**

- **First acquisition:** admission refuses before dialing. A/F/O require the diagnostic and immediate nonzero exit; B starts its bounded waiting episode; C requires the nonzero outcome without promptness; D supplies no explicit migration-specific outcome. Fixture (a) observes the denied attempt, absence of dial/SQL and completion, and the selected invocation outcome.

- **Second runner denied before connection:** runner one already holds the migration key. Runner two is refused its own physical connection, so it cannot request that SQL key. Fixture (b) exercises this admission failure independently of the admitted runner. A/F/O exit; B waits under its episode rule; C exits without a timing guarantee.

- **Reconnect after recorded version V:** V has committed and been recorded; transport then fails before the next migration. The replacement request is refused. [STO-55](05-persistence.md:290) says “transport loss, process exit and rollout completion never release a grant”, so the old charge survives. Fixture (c) checks that V remains recorded and refusal records no further completion. After verified release, the separate deployment invocation in A/F/O inspects history and skips V. B instead permits same-process continuation following timely confirmation; its printed recovery assertion has the conflict above.

- **Already connected and waiting for the SQL lock:** this is outside physical-admission refusal. [STO-12](05-persistence.md:1532) requires a “transaction-scoped advisory lock on a fixed key distinct from `STO-51`’s”. The separate admitted-pair fixture detects treating this wait as an admission-refusal exit. B additionally checks that the admission timer does not start merely because of that wait. Existing CNF-57’s assertion that “the engine’s startup lock is untouched” remains.

- **Exhaustion while the previous release serves:** charged reservations can exhaust new admission while retained engine and `api` sessions remain usable. [STO-55](05-persistence.md:308) explicitly permits “Existing admitted sessions may continue”. The fixtures retain adequate admitted sessions and make the required standby available, then assert actual engine and `api` write success. They test service continuity alongside refusal, rather than merely process survival.

For A/F/O, one admission call alone does **not** prove prompt exit: a runner could sleep after that call. The printed “without an internal admission wait/retry” assertion must actually check for such waiting, through execution observation or instrumentation. “At once” excludes deliberate waiting; it supplies no numerical end-to-end latency guarantee.

B’s exhaustion branch checks elapsed time from first refusal across calls and backoff, diagnostics and validation. Its recovery branch cannot establish the printed policy consistently. C checks exit and subsequent reinvocation, but cannot reject the finite-delay trace. D adds no outcome fixture; that absence is not a contradiction.

**Preserved protections and wording-exception dimensions.** I found no existing normative obligation or checked verdict removed, made unreachable or made vacuous.

[STO-55](05-persistence.md:285) requires every attempt to receive a “distinct durable reservation before dialing”; release requires “fencing every delayed arrival/retry and fresh privileged direct-primary evidence”. Runner exit cannot substitute for that evidence. The proposed fixtures retain uncertain charges and require verified release before later progress.

[STO-7](05-persistence.md:178) protects sent COMMIT: short of process exit, a deadline or cancellation “MUST NOT release its connection before the reply arrives or the transport is found dead”. A/F/O introduce no COMMIT or standby deadline; B explicitly excludes those waits. The protected backend rule remains: “No individual `SyncRep` backend may be cancelled or terminated to make room”.

The service fixtures expressly use a concurrently migratable release. They do not replace [STO-13](05-persistence.md:1595)’s exceptional backfill order, “and only then permit the first new-release component to start”. Nor may migration refusal inherit [OPS-49](03-operation-lifecycle.md:1925)’s loop, whose population is “a worker, or … a periodic component running in the engine process”.

The dimensions are distinct:

| Dimension | Assessment |
|---|---|
| **Behavior** | A/F/O require immediate failure; B permits bounded internal recovery; C specifies failure without promptness; D preserves the existing gap. |
| **Normative requirements** | A/F/O add reporting and the explicit successful-completion boundary. A adds peer status; F adds reason provenance. B additionally introduces and validates a registered duration. C adds explicit migration scope. D changes none. |
| **Check strength** | A/F/O add immediate-failure diagnostics and independent refusal cases. B adds timing, validation and recovery assertions, including its conflict. C adds outcome/resumption coverage without promptness. D changes none. |

Textual inspection of [Migration.lean](tools/formal/Provisiond/Migration.lean:53), the [backfill theorem](tools/formal/Provisiond/Restore.lean:655), corresponding witnesses and the migration negative control found no affected declaration, hypothesis or represented population. Their migration-shape and conservative-backfill properties remain intact. This is inspection, not a build result.

**Requested counterargument for no change — not my vote.** Initial acquisition by either runner can plausibly be read under STO-55’s “Startup acquisition refusal exits for supervisor retry”. Admission prevents unauthorized dialing, schema checks prevent serving an insufficient schema, exhaustion is alarmed, and version tracking supports resumption. Reconnect can remain blocked safely while previous-release admitted sessions serve. The owner could intentionally leave invocation timing and reporting to deployment tooling.

That argument supports safety and an intentional scope choice. It does not establish a reconnect outcome: reconnect after V is recorded is not plainly startup, and [OPS-47](03-operation-lifecycle.md:135)’s “external supervisor that retries startup” concerns the engine. D therefore leaves the bead’s outcome gap open.

**Rule 6.** I found no verified brief error changing the question’s premise, so no tally is voided. B’s candidate conflict and the corrected prior Sol reasons are reported errors, not a new void condition.

Panel-launch approval authorizes none of these policy choices. D is unchanged across the dimensions above but still requires owner approval as an intentional scope decision.

**For pv-3zzo, approve exact Q1 O’s amendments to STO-55, STO-13 and CNF-57, so a refused updater reports why and stops immediately, leaving deployment to invoke it again?**