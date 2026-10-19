The text conflicts rather than cleanly authorizing two conforming engines. X clashes with `OPS-21`’s “MUST be recorded before the engine exits” and its exception “bounded abandonment and later-stop exits below”; Y clashes with `OPS-49`’s “A worker cancelled during the retry loop stops retrying and exits.” Both readings are defensible. **Specify X.**

Owner decision 2 settles the intended policy: “`OPS-49`’s retry loop and its exits stay as settled”; the Agent Brief adds “Do not otherwise change the loop or its exits.” `OPS-21` needs an explicit exception for the original stop arriving inside an existing retry loop.

**First attempt:** yes, the database attempt may finish. “`execute` MUST be cancellable” does not prescribe instantaneous rollback; I found no sentence settling that granularity. Recording remains required within the bound measured from the stop. Finishing the transaction must not authorize the following mutation.

Install shares the stop policy, but not necessarily the outcome. `OPS-11` requires the markers to “say the disk is untouched and no rescue session was left open”; `OPS-45` says “the columns are authoritative” and “nothing clears them”. A committed write-started marker or false rescue marker can therefore park a recorded cancellation despite no subsequent mutation. A lost reply does not establish that markers stayed unset.

Minimal edits:

- `OPS-21`: replace its exception phrase with “subject to the retry-loop cancellation exit in `OPS-49` and the bounded abandonment and later-stop exits below.”
- `OPS-49`: add “For a write inside `execute`, this exit applies when a store error has already started that write’s retry loop before the stop.”
- `OPS-21`: add “A stop during the first attempt of a write inside `execute` MUST take the recording path even if that attempt later errors. That attempt MAY finish within the Stop-record bound, but MUST NOT advance to the mutation that write precedes.”

Exercise these boundaries in `CNF-361`/`CNF-362`, including marker commits and lost replies.

Gate gap: [changing the checklist](/var/tmp/provisiond-panel-r58c/astra/r58c-plant.patch) to require recording **inside** step 8’s retry loop passed every gate. `StopRecord.trace` receives an already-chosen record; it does not distinguish the preceding execution-loop boundary. Baseline and restored final runs also [exited 0](/var/tmp/provisiond-panel-r58c/astra/r58c-gate-status.txt). Tracked files are unchanged.

The strongest argument for Y is the owner’s “Any stop the engine survives MUST record the outcome before the engine exits.” No order was invoked; a transient store error should not freeze that purchase. An explicit owner clarification that A supersedes the preserved execution-loop exit would change my mind.