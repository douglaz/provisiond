Prefer A: when admission refuses the migration connection, report why and return failure immediately so deployment controls the next invocation. B is also coherent, but deliberately buys an internal waiting period and a new deployment parameter.

**Final: Q1 A**

- **A ACCEPT** — preferred, exactly as printed.
- **B ACCEPT** — a valid alternative policy, exactly as printed.
- **C CANNOT ACCEPT** — it specifies the exit status but leaves delay before exit unspecified.
- **D CANNOT ACCEPT** — as a resolution of pv-3zzo. Keeping the outcome unspecified is possible as an intentional scope decision, but would leave the bead open.

These are review judgments, not adoption.

**Traces and fixture effectiveness**

| Situation | Outcome and what the printed fixtures detect |
|---|---|
| Initial acquisition | A reports refusal and exits non-zero without an internal admission wait/retry. B reports waiting, retries with backoff, then either obtains a reservation within the episode bound or reports exhaustion and exits non-zero. C requires non-zero exit but provides no explicit timing. D adds no outcome. The A fixture distinguishes immediate refusal handling from internal retry; B exercises both exhaustion and recovery before expiry; C checks eventual exit only. |
| Second runner denied before connection | The admitted runner holds the migration key; the second runner cannot yet request that key. A exits; B waits for admission within its bound; C eventually exits. The independent fixtures correctly distinguish this refusal from SQL lock contention. Merely launching two connected runners would not exercise it. |
| Reconnect after a recorded migration | Version V is already recorded, the transport fails, and admission refuses the replacement attempt before the next migration. A exits; B starts a refusal episode; C requires non-zero exit. The fixtures check preservation of V and absence of a completion caused by refusal. Later progress inspects history through the normal runner, rather than assuming the lost transport erased V. |
| Already-connected SQL lock wait | This is outside the refusal policy. [STO-12](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/05-persistence.md#L1529) requires a migration key “distinct from `STO-51`’s”; existing CNF-57 checks that one runner “waits on `STO-12`’s key while the engine’s startup lock is untouched.” A–C retain that case and add an explicit admitted-pair comparison. B’s admission episode has ended on obtaining the reservation; waiting for the SQL key does not start its timer. |
| Exhaustion while the previous release serves | The fixtures retain admitted read/write sessions and make a required standby available. Exhaustion blocks additional physical attempts without making the service assertions impossible merely by withholding every connection or every standby. [STO-55](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/05-persistence.md#L307) expressly permits: “Existing admitted sessions may continue.” A–C can therefore exercise refusal and successful previous-release writes in the same fixture. |

A’s “at once, without an internal admission wait/retry” is observable as the absence of another admission call or an admission-backoff phase after refusal. It does not require inventing a numeric response-time parameter.

B is executable within its stated scope. Its episode includes later admission calls and backoff, so a subsequent call cannot silently extend the deadline. An implementation must arrange expiration even if that call remains pending, while retaining any uncertain grant. The printed tests exercise repeated refusals, a single unreset bound, recovery before expiry, invalid settings and exhaustion diagnostics. No particular backoff cadence is necessary to distinguish those outcomes.

B does **not** bound the first authority call before any refusal, post-grant connection checking, SQL execution, SQL lock waits or total migration runtime. Those are explicit limits of this package, not promises its fixtures establish.

C’s counterexample is simple: receive refusal, wait an arbitrarily long finite period, then exit non-zero. Its proposed sentence and fixture do not expressly reject that trace. An internal retry that succeeds and returns success would conflict with its required refusal outcome; the remaining loophole is delay before the required failure. Rejecting C on that basis identifies an incomplete new timing contract, not a lost baseline obligation.

D adds no distinguishing fixture. The absence of a migration-specific test is not itself a contradiction in the unchanged base.

**Deletion, weakening and preserved protections**

A and B are insertions. They delete no existing sentence or fixture. C replaces the refusal block but retains its original startup, API, worker/periodic, stop-record and backend-protection sentences verbatim, adding migration scope between them.

The protection audit is:

- **Outcome and timing:** A’s refusal sentence excludes internal admission waiting and retry; its later-invocation sentence assigns retry to deployment. B instead explicitly substitutes a bounded migration policy for the generic startup outcome. That is a substantive behavioral choice: refusal can be followed by successful continuation within the same invocation under B, while A requires exit.
- **Bounds and observability:** B’s parameter, validation, episode-start, elapsed-time and non-reset sentences prevent an endlessly renewed refusal loop. Its OVR-19 row gives that parameter a registered home. A and B’s diagnostic sentences make the blocked release and acquisition stage identifiable without credentials. C adds neither protection.
- **Database effects and resumability:** A and B’s no-dial/no-SQL and completion sentences prevent a denied attempt from executing or being recorded as a completed migration, while preserving earlier completed versions. Their deployment-retry pointers use the existing version/serialization owner. [STO-12](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/05-persistence.md#L1534) requires the lock across “inspecting the history, applying a migration and recording its completion.”
- **Release boundary:** A and B add the explicit successful-completion condition before new components start. C adds only a pointer. The existing [STO-13](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/05-persistence.md#L1555) ordering remains: migrations run “before any component of a release starts.” C’s conformance start-order assertion therefore has an existing normative basis; it is not contradicted merely because C adds no new boundary sentence.
- **Check strength:** The CNF-57 additions distinguish the entry-point policies and preserve the existing release, connected-runner, concurrent-index and backfill cases. None makes an existing assertion unreachable or vacuous.

The retained accounting constraint is decisive for reconnect and timeout traces. [STO-55](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/05-persistence.md#L285) requires a “distinct durable reservation before dialing” and states: “Timeout, transport loss, process exit and rollout completion never release a grant.” A denial need not allocate a grant. Previously issued or uncertain grants remain charged; neither runner exit nor B’s expiration establishes backend absence. The printed fixtures correctly require the existing fencing and backend-absence evidence before release.

Startup-lock independence is preserved by the distinct-key requirement quoted above. The admitted-pair lock test remains reachable because exhaustion fixtures are independent of it.

The standby protection also remains. [STO-7](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/05-persistence.md#L178) states that a sent COMMIT’s connection “MUST NOT” be released before its reply or dead-transport detection, short of process exit. A excludes sent-COMMIT and standby deadlines; B expressly excludes those waits and prohibits cancellation or grant release by its timer. Neither authorizes eviction: STO-55 retains “No individual `SyncRep` backend may be cancelled or terminated to make room.”

The fixtures’ previous-release service assertions apply to a release permitted to migrate concurrently. They do not erase [STO-13’s backfill exception](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/05-persistence.md#L1595), which requires stopping previous components and “only then” permitting the first new component after backfill. The shared-predicate stop-everything order also remains unchanged.

No formal declaration or hypothesis needs changing. [Migration.lean](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/tools/formal/Provisiond/Migration.lean#L1) concerns migration shape and the standalone home for concurrent index builds. The [backfill declarations](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/tools/formal/Provisiond/Restore.lean#L646) concern population and conservative restart classification. None carries an admission-refusal outcome. I found no affected theorem, changed existing conformance verdict, or lost quoted normative obligation. No formal build was run.

**Requested counterargument for no change — not my vote**

The strongest argument for D reads “Startup acquisition refusal exits for supervisor retry” broadly: migration acquisition is preparation for deployment startup, so it already exits; deployment can provide retry scheduling and reporting without more requirements.

That reading is plausible for initial acquisition, but the text does not expressly extend “startup” to migrator reconnect or a runner denied before obtaining its own connection. STO-13’s “before any component of a release starts” does not supply that equivalence. Nor can the retry policy be imported from [OPS-49](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L1925), whose subject is “a worker, or by a periodic component running in the engine process.”

**Premise check and owner question**

The pinned JSONL matches the packet bead, and the STO-55/STO-13 owner spans match the filing baseline. I found no premise-changing brief error and no candidate contradicting its own fixture. Under notes.md rule 6, I therefore identify no basis to void this question.

The owner question is: **Adopt exact r87 Q1 A, requiring immediate diagnostic failure and a later deployment invocation, or exact r87 Q1 B, keeping the migrator alive to retry within a validated deployment-stated bound?** I recommend A. B’s waiting/resource cost and new parameter require an explicit owner choice; panel-launch approval did not make it.

No source, tracker or panel records were edited; no gates or builds were run.