**S': ACCEPT.** **F': ACCEPT.**

Every span the two forms edit matches the text at `dc5d40d`. The current PostgreSQL docs (26.2.8.1) have option B's two sentences word for word. For `pg_last_xact_replay_timestamp()` they say: "If recovery has completed then this will remain static … When the server has been started normally without recovery, the function returns `NULL`." So S2's "before it is first restarted, where it is not null" is right. F7's queued delete can be claimed, because `STO-51`'s index covers only `status = 'running'`.

Notes (none of them blocking):

1. **S8 doesn't say the first create is claimed before the standby is cut off.** If the claim comes after the cut, the standby holds that create `queued` and step (2) quarantines it. Every assertion still passes, but the test never reaches `OPS-15`'s create exception, which is the clause S4 changes. Suggested text: "claim one create, then cut the standby off the replication stream; let it commit step 8 and order".
2. **F6's new invariant (`stepTwoMarked → safe`) holds only if the new provider-application event applies `running` rows only.** Fresh work is admitted `queued`. If the event can mark a `queued` irreversible row as applied, the next claim sets `secondOrder` (`Restore.lean:440`). Suggested text: "and apply claimed (`running`) work at the provider".
3. S2 says "keep the supervisor (`OPS-47`) … from connecting", but the supervisor never connects to the store. `OPS-47:136-137` calls it "an external supervisor that restarts it". The clause that follows already covers the engine it restarts.

**Brief errors:** none found. I checked `00:338/405`, `05:147/149-150/1474`, `Restore.lean:440/506/703`, `03:158-159` (the `OPS-5` quote), `03:1686-1688`, `04:668` and `CONTEXT.md:184/186`. I also checked the 3-1, 2-2 and 4-0 counts, who raised what, and F8 being opus's note against `r63b/tally.md`.
