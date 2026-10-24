## Q1 (pv-buc)

**R: ACCEPT. E: ACCEPT. Pick: R.**

**Strongest reason.** The write E forbids is already fenced per row. `OPS-22` guards a worker's record "on that operation still being `running` under the worker's claim number", and a successor's `OPS-15` pass runs "at startup, before any claim" over every `running` row. A lost lock adds no danger a record could realise. E turns a bounded, guarded write into a crash, and on a `correlator: none` channel `PRV-33` then sends a create the worker verified to an operator.

**Misconfiguration trace: verified, with one addition.** Before E1 sees the loss it may claim queued rows after E2's pass. Under E those rows stay `running` under a live E2 that never sweeps them (`OPS-15`: "nothing but a restart can leave a `running` row with no worker behind it"), and each holds its machine through `STO-51`'s index, so E2's claims on it defer (`OPS-8`: "the conflicting work will finish") until E2 restarts. Under R, E1 records them. R fails safer in the owner's own case.

**Against my pick.** Under R the engine knowingly writes, for a deployment-chosen bound, to a store whose lock it lost, and detection is itself a keepalive parameter. `ADR-0019` names the limit so the lock does not "grow back"; scheduling the loss starts treating it as more than a boot check.

**The owner's question: none needed.**
- The check exists. `ADR-0019`: "`OPS-15`'s startup pass, `STO-3`'s `status = running` term and `OPS-22`'s 'log it loudly, leave the record alone, and exit' already handle a supervised restart end to end." Every row E1 held before E2's pass refuses E1's write; every row claimed after it has no E2 writer. Money follows the status write, which `STO-3` says "precedes every money write in the transaction and short-circuits the rest".
- A lock-held check on the record write is Form E renamed: R exists to write after the loss is known. It amends `OPS-47`'s "no write is guarded on it".
- A generation stamped by the startup pass and compared by the record is `ADR-0019`'s rejected "Fix the predicate", which "buys a defence for the case this ADR puts out of scope". Cost: a column, a guard term, a theorem, the epoch's second life.
- No check reaches the window before detection, where E1 claims and calls providers under both forms. Its length is `OVR-19`'s keepalive row.

**Non-blocking:** `OPS-47` keeps "hold it for its lifetime" while the engine outlives the loss. Replacement: "hold it until it begins to exit".

## Q2 (pv-9j6)

**M: ACCEPT. [P]: YES. [Q]: NO.**

- **[P] YES.** The Lean arm carries `!f.accepted` and `accepted_never_failed` quantifies over every marker pair, so without [P] the Markdown's "whatever its kind" states a rule its Lean home does not, and meets the acceptance amendment's "MUST NOT classify that accepted mutation `failed`" on an input only driver conformance (`PRV-5`) keeps unreachable. The create row needs no such words because "before any step-9 request" excludes acceptance by definition; an engine-written marker does not.
- **[Q] NO.** Both directions already have homes: marker set and ambiguous is `CNF-31b`'s pre-send case and `CNF-362`'s post-dispatch cases; marker unset is M's new `CNF-31b` sentence. `CNF-31a`'s stake is a repeated mutation; the unset direction pages an operator.

**Read whole: no contradiction.** `OPS-45`'s "This rule classifies a failure a worker recorded" matches M's "any failure the worker records". `OPS-23`'s quote "otherwise `failed`" and `CNF-31b`'s "`needs_reconciliation` if the failure is *ambiguous*, otherwise `failed`" survive as substrings, though `OPS-23`'s pre-dispatch failures now settle under the marker clause: retarget that pointer. ci.yml's goal-state flip stays at one error: the theorem fixes `goalStateHeld = false` and the witness uses a `conflict`. No control flips `markerRule`. `Rules.markerRule`'s doc comment names only the install row; add the last row.

## Brief errors

- "`STO-54` and `ADR-0045`'s 'A sent COMMIT is never abandoned'": the sentence is `STO-7`'s, at `05-persistence.md:151`, "**A sent COMMIT is never abandoned** (*added 2026-10-23, `ADR-0045`*)". A grep for "never abandoned" finds it nowhere else.
- No other claim failed verification. Every quote above was grepped at `b90783d`.
