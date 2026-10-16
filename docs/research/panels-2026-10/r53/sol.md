**B — `ready-for-agent`, for a narrow clarification.** Null pricing is specified; the missing-source write is not explicit (`05-persistence.md:261`).

**Pre-column rows:** “a null value MUST contribute no earliest-date term” settles reading null, rather than prescribing a migration/backfill. The nullable precedents likewise specify “read as empty” and “read as zero”; they do not establish an absent-snapshot copying convention (`05-persistence.md:259–261`).

**Worker validation:** Your inference from `OPS-43` is too strong. `OPS-23` requires boundary validation repeated “before the driver is called” and says: “A field a previous-release `api` may not have written is a deterministic failure in the worker, never a passed check” (`03-operation-lifecycle.md:1623–1628`). Its literal wording catches an old queued create; the price-field enumeration supplies no exemption (`OPS-43`). Reading the copy later does not establish permission to pass that check.

**Attachment:** The column row enumerates settle-time success, automatic resolving-observed, late attach, and synchronous operator `observed`, requiring “MUST be copied from the create’s `request_summary` offer snapshot” (`05-persistence.md:261`). That is the sentence needing clarification: it specifies no result when the member is absent.

For already-dispatched creates, applying worker validation at resolution is also wrong: “Resolution transitions out of `needs_reconciliation` are made by no worker” (`OPS-3`). `OPS-27` requires confirmation and the landed-order transaction; `OPS-36` says “attach the machine, then immediately route it through the exhaustion path.” Operator attachment “MUST make no post-order read and MUST store the date as null”—the **actual-date** column, not the declared-bound copy (`PRV-13c`; `WIR-35`).

**Exactness:** For the accepted v1 declared bound, your arithmetic holds: `PRV-31` refuses bounds “later than the provider’s local today”; `LDG-33` prices them “only if later than provider-local today.” Later attachment therefore adds no term, including operator attachment. Future declarations on a changed offer do not replace accepted terms: the copy is “never re-resolved afterwards” (`05-persistence.md:261`).

That equivalence concerns the **declared bound**, not actual liability. A successful deviation read records the actual date; an unread deviation remains unknown under either representation (`PRV-13c`). Q25 explicitly says “Cost past the declared bound is operator-borne” (`ADR-0037`, Q25). After future-bound sales become permissible, missing null can underprotect until that bound passes; `CNF-356` explicitly contrasts injected future and null copies. `STO-13`’s “MUST stop every component” addresses process skew, without defining missing-data repair.

Add at the owning identifier, `machines.declared_cancellation_bound` (`05-persistence.md:261`):

> When a previous release recorded no declared cancellation bound at admission, migration and any subsequent attach MUST leave this column null.

**Strongest case for the other side (written on request)**

Choose A: “specifications only” and “code that never compiled and never ran” undermine any present rollout need (`README.md:6,111–112`). Existing null semantics plus “Attach it” make null the natural interpretation, and v1 arithmetic removes its monetary consequence (`OPS-27`; `PRV-31`; `LDG-33`).