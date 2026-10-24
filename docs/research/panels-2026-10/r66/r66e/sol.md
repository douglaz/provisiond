## 1. ACCEPT

I reviewed the whole r66e combined text—Form R and Fence G, for `pv-buc`—against `d78085a`. **ACCEPT**, with one nonblocking wording correction below. I found no conforming trace that admits a stale engine write, refuses a write that should pass, or defeats a required stop record.

G’s decisive wording is that every covered transaction reads the generation “**as its first statement**” and must “**hold that lock until it commits**.” PostgreSQL documents that “A shared lock blocks other transactions from performing `UPDATE`.” The advance therefore cannot commit past a transaction still holding that shared lock. Conversely, a later transaction encounters the replacement generation and takes the specified rollback-and-exit path. This reasoning follows the documented lock conflict, rather than relying on the startup advisory lock being a fence. ([PostgreSQL 18, §13.3.2](https://www.postgresql.org/docs/18/explicit-locking.html#LOCKING-ROWS))

The startup sequencing closes the corresponding sweep race. The proposal requires the advance’s commit to be acknowledged before “the remainder of the pass” or another write transaction begins. An earlier holder’s committed operation is consequently visible to the later sweep; an earlier engine cannot subsequently commit another covered write under its previous generation. Putting the generation read before the tenant primitive also avoids introducing the proposed generation/tenant lock-order cycle: the advancing transaction holds only the generation row.

The timeout cases remain distinguishable. `CNF-369` holds the shared lock so the replacing statement cannot complete; its unchanged-generation assertion fits that fixture. A lost acknowledgement **after** the advance committed can instead leave a changed generation. The proposal permits that outcome while requiring startup to exit “having claimed nothing.” It does not incorrectly promise that every failed startup leaves the generation unchanged.

R answers the bead’s ambiguity directly. Its operative distinction is “**The loss is not a later stop**.” A record already pending continues under its original bound; the loss neither resets that bound nor supplies another abandonment event. With no record pending, R sends the worker through the existing cancellation, absorbed-read, after-return settlement, or parent-defer rules. Its “subject to its exits” qualification and span 23’s additions make that recording obligation compatible with G’s immediate superseded exit.

The lost-reply case is also preserved explicitly: “**an earlier attempt may already have committed with its reply lost**.” Ending further attempts on a generation refusal therefore does not imply that the operation remains `running`, or that money must be posted again. That preserves the alternative carried by `StopRecord.exit_store`, rather than replacing it with an unconditional “nothing was recorded” assertion.

The restore scope is coherent on the owner’s stated terms. Span 26 requires every engine and `api` process to stop before restoration and prohibits starting either until the restore-record transaction is acknowledged. The counterexample requiring a surviving process to write between restoration and that transaction violates this new MUST. `CNF-370` exercises the supported sequence, and the revised freshness language distinguishes reinstating backup contents from choosing a generation. I find no remaining restore-window blocker within that scope.

**Nit — the executive summary retains the opposite description.** It says “nothing refuses its writes” at [executive-summary.md:252](https://github.com/douglaz/provisiond/blob/d78085a89edfaa09d012bc6c8bc4ef94edd360ec/executive-summary.md#L252). The combined amendments do not include that sentence.

**Acceptance gate:** this changes no `CNF` assertion, Lean theorem, or MUST/SHOULD, and supplies no stale-write trace. It is a wording correction that may ride into the Run.

Replace the sentence beginning “Two engines are out of scope” with:

> `OPS-47` retains “a deployment obligation”; `OPS-50` now requires that “Where the values differ, the transaction MUST roll back, and the engine MUST log loudly that it was superseded and exit non-zero at once, beginning no other transaction.” `ADR-0047` records the decision and its limits.

## 2. Contradictions

**Yes.** There is one unamended current description, plus reversals the combined text expressly records.

**Unamended executive summary.** The combined `OPS-50` says:

> “Where the values differ, the transaction MUST roll back, and the engine MUST log loudly that it was superseded and exit non-zero at once, beginning no other transaction.”

The surrounding text says:

> “nothing refuses its writes, because the epoch that claimed to was comparing a value against itself”

—[executive-summary.md:252](https://github.com/douglaz/provisiond/blob/d78085a89edfaa09d012bc6c8bc4ef94edd360ec/executive-summary.md#L252). Those descriptions cannot both remain current. The replacement above resolves this without changing behavior.

**The rejected claim guard is deliberately adopted.** The combined text says G “reverses `ADR-0019`’s rejection” of guarding the claim. The existing ADR says:

> “Rejected because it buys a defence for the case this ADR puts out of scope, and keeps a column, a counter and a guard term alive to do it.”

—[ADR-0019:80](https://github.com/douglaz/provisiond/blob/d78085a89edfaa09d012bc6c8bc4ef94edd360ec/docs/adr/0019-the-epoch-was-not-a-fence-and-the-supervisor-is-the-guarantee.md#L80). Span 13’s dated note and `ADR-0047` identify the reversal; this is an acknowledged amendment.

**Transaction entry changes deliberately.** New `OPS-50` requires the generation read “as its first statement.” Existing `ADR-0022` says:

> “The guarded status write is the transaction’s first statement”

—[ADR-0022:82](https://github.com/douglaz/provisiond/blob/d78085a89edfaa09d012bc6c8bc4ef94edd360ec/docs/adr/0022-a-store-error-is-a-bounded-retry-and-every-worker-write-carries-its-claim-number.md#L82). Span 18 supplies the dated superseding note, and span 10 changes `STO-3`’s lock order.

**The stop-record theorem’s exit set deliberately broadens.** The combined text says it “weakens `finished_unrecorded_exit` by one disjunct.” Existing `ADR-0044` says:

> “No existing theorem is weakened.”

—[ADR-0044:95](https://github.com/douglaz/provisiond/blob/d78085a89edfaa09d012bc6c8bc4ef94edd360ec/docs/adr/0044-a-survived-stop-records-execute-within-a-bound.md#L95). `ADR-0047` explicitly records this departure. The historical sentence can remain historical; it cannot describe the new amendment.

I found no additional unresolved normative contradiction meeting the brief’s blocking gate.

## Brief errors

**No factual error established.** The quoted amendment anchors I checked agree with `d78085a`. In particular, the existing restore procedure already says its record is written “before either component is started” ([05-persistence.md:1556](https://github.com/douglaz/provisiond/blob/d78085a89edfaa09d012bc6c8bc4ef94edd360ec/05-persistence.md#L1556)), and `STO-56` records `steps_completed` as “0 to 3” ([05-persistence.md:1336](https://github.com/douglaz/provisiond/blob/d78085a89edfaa09d012bc6c8bc4ef94edd360ec/05-persistence.md#L1336)).

`br` was unavailable, so I read `pv-buc` from `.beads/issues.jsonl`. Earlier-round tallies were not independently established from this clone and did not determine this verdict. No gate or `lake` was run; no tracked file was changed. This accepts the proposed text, without claiming that its unbuilt Lean amendments have been proved.