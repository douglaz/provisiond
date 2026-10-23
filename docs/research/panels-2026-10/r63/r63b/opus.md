**S: CANNOT ACCEPT.**

S loses `03-operation-lifecycle.md:408-409`. That clause says the create exception "does not fire … nor on a store that may have lost committed writes". S narrows it to "an asynchronous standby". But the deployment has one replica: the standby `OVR-19` names. The set calls it synchronous: `00-overview.md:338` says "a stalled synchronous standby" and `:405` says "Synchronous standby name". Yet `05-persistence.md:147` says "`synchronous_commit` is `local` on every connection and `on` inside exactly two transactions".

Trace:
1. A create commits step 8 under `local`. The named standby hasn't received the write.
2. The primary dies and that standby is promoted.
3. The set itself calls this standby synchronous, so it isn't "an asynchronous standby". No record is written and the boot counts as a restart.
4. The create is `running` with its column null. It settles `failed` and its commitment is released while the provider holds the order. That is `ADR-0042`'s case, and the deleted clause guarded against it.

Replacement for S2's bold sentence only: "**The promotion of any standby is a restore, `OVR-19`'s synchronous standby and a planned switchover included**, since `STO-7` makes only two transactions wait for it, and the procedure below runs whether or not the promotion lost a write." S1, S5 and S8 get the same change: "an asynchronous standby" becomes "a standby".

**D: OMIT.** It puts a MUST on both components that rests on an unverified signal (25.3.6 doesn't say a promotion creates a timeline, and `pg_control_checkpoint()` can lag after a fast promotion), to catch a breach S2 already forbids.

**F: ACCEPT.** Checked:
- `OPS-5`'s quote is at `03-operation-lifecycle.md:158-159`.
- The source spans for F2, F3 and F4 match: `:371-372`, `:420-421` and `04-api-contract.md:668-669`.
- In `Restore.lean`, `afterCrash` (`:413`) keeps `passDone`. So `quarantine_before_first_claim`'s doc ("a successor that comes up while the record is open repeats the pass before it claims") is false today.
- No admit event exists in `Event`. F6 is right on both counts.

Not blocking: the worker pseudocode comment at `03-operation-lifecycle.md:1687` ("after a restore they wait") still has F3's old wording. It also says queued irreversible kinds are quarantined whenever an incident is open, which conflicts with F7's create queued after step (3). Both should be updated alongside F3.

**Brief errors**
- D: the brief gives Opus's objection as "D covers only the engine". `/var/tmp/provisiond-panel-r63/opus.md:13` reads "D covers only the engine, and `api` is where the hole is". That was aimed at an engine-only form. The merged D covers `api`, so the objection doesn't apply to it; my OMIT rests on the reason above.
