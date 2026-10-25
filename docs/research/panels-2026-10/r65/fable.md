**R (merged): ACCEPT.** **E (completed): ACCEPT.** Neither flips a `CNF` assertion or a Lean theorem; E deliberately weakens `finished_unrecorded_exit` by one disjunct, which `ADR-0046` must say, since `ADR-0044` says "No existing theorem is weakened."

**Pick: R.** Strongest reason is S5, the case the lock exists for. `OPS-15` says "nothing but a restart can leave a `running` row with no worker behind it", and under E the rows E1 claimed after E2's pass are exactly that: `running` under a live E2 that never sweeps them, each holding its machine until E2 restarts. R records them within the Stop-record bound. S1–S4 add `ADR-0044`'s rejected-C rationale: in every one the process and the store can complete the record.

**The merge:** right, one word wrong. "the cancellation rules below" is false: the classification paragraph (cut-off `conflict`, `OPS-11`) sits above the insertion; only the two named rules are below. Drop "below":

> For a worker still in `execute`, this requirement's cancellation rules apply, including the stop that “MUST NOT cancel `execute`” and the parent's defer, which “records no error”; for one whose `execute` has returned, its settle write records it; it ends no record already pending.

Non-blocking: between the loss and exit the engine neither holds the lock nor is exiting, so "hold it until it begins to exit" reads better as "hold it until it is lost or the engine begins to exit" (`STO-51` likewise).

**Against my pick:** E keeps `OPS-47`'s lock a one-question boot check and never lets a lockless engine write for a whole Stop-record bound beside a successor already past its startup pass. R's gains are detours (S1, S2) or rare (S3, S4), bought with four requirement edits and a six-case `CNF`.

**Fence G: sound YES.** PostgreSQL 18, `FOR SHARE`: "A shared lock blocks other transactions from performing `UPDATE`, `DELETE`, `SELECT FOR UPDATE` or `SELECT FOR NO KEY UPDATE` on these rows", and `FOR NO KEY UPDATE` "is also acquired by any `UPDATE` that does not acquire a `FOR UPDATE` lock", so the takeover's advance waits for E1's in-flight transactions and every later E1 transaction refuses. It reaches E1's claims and writes that begin after the advance commits, never a provider request already sent, and nothing before the pass. The second writer separates it from the self-stamped epoch, but it is `ADR-0019`'s "a column, a counter and a guard term" by shape. Cost: one hot row share-locked in every engine transaction, a takeover that waits on E1's open transactions, and reopened `ADR-0019`.

**Fence A: sound NO.** Every record it refuses is guarded already by `OPS-22`'s claim number and status, so the only records it blocks are correct ones (S5's, which E2 then strands), and after a blip E1's own unreaped session refuses it, turning R into E in S1. Cost: a second checkpoint against "once, at boot", for no write it prevents that the guards would not.

**S3 check (requested):** no rule names a parked dated cancellation; `OPS-45` routes it: "resolution then proceeds by `PRV-29`/`PRV-36`'s provider evidence where the driver can produce it, falling back to `OPS-31`'s `applied`/`not_applied`/`abandoned` where it cannot." `PRV-29` makes the four-state separation a MUST for Robot-style providers, and `WIR-35`'s `applied` "on a `delete_machine` MUST carry `effective_cancellation_date`", so a conforming driver resolves it with no person; a driver without that evidence source needs one. On Robot with `cancellation_date=now` the machine is gone within a second (`08-provider-notes.md`), so a read past the window resolves it anyway.

**Brief errors**
- No r64 or r64b record exists at `b90783d`: `docs/research/panels-2026-10/` and its README end at r63. The 4-0 tally and the two blocking readers are unverifiable from the clone.
- E's Lean list is incomplete: `finished_unrecorded_exit`'s inner `selection` lemma has three `rcases h with ack | bound | store | later | redelivery` splits whose `Or.inr` chains assume five disjuncts. With six, `redelivery` binds a disjunction; `simpa` may still close it, but the brief lists only the `cases e` arms. `money_posts_at_most_once`'s docstring also says "both stop events".
- "'Below' is right" is half right, as above.
- Every other quote in the brief (`OPS-47`, `OPS-21`, `OPS-49`, `OPS-15`, `OPS-22`, `OPS-27`, `STO-3`, `STO-7`, `STO-51`, `PRV-13`, `PRV-13c`, `PRV-29`, `CNF-362`, `CNF-365`, `ADR-0019`, `ADR-0044`, `OVR-19`'s rows) grepped true, including corrections 1–8. `CNF-366` and `ADR-0046` are the next free ids.
