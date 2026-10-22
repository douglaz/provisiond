Vote **1**: retain every device; return `identifier: null` when neither WWN nor serial exists. Observing B should not require inventing an identity. This preserves `RSC-26`’s “over the whole device set”.

Costs and mixed-machine trace, assuming rescue install is otherwise eligible:

1. **Null:** caller sees A(WWN), B(null); can install A; fingerprint covers exactly A+B. My edit touches `WIR-10b/40`, `RSC-26/33/46`, `WIR-20`, `API-13`, `CNF-47` and Lean reporting. `RSC-38`’s “same `inventory_fingerprint`” remains satisfied. `DOM-10/13/30` stay unchanged.
2. **Omit:** caller sees A and can install A. Hashing A+B commits to unseen B; hashing only A loses change detection for B. Costs: `WIR-10b/40`, `RSC-33/38`, a filtered report model, and `RSC-26/46` if coverage changes. Full-set hashing still needs absent-key ordering; `WIR-20` can stay.
3. **Refuse:** no inventory/hash; this operation cannot prepare A’s install. Costs: `WIR-40/10b`, `RSC-26/33/38`, error/lifecycle semantics and Lean refusal modeling. Reusing `WIR-30`/`DOM-13/30`’s strategy list requires a new inventory-eligibility rule; `DOM-10`’s capability row can remain. Refusing only all-anonymous machines leaves mixed B unresolved.

Missing rescue strategies are a conservative signal for known ineligibility, not an equivalence with identifier absence. `DOM-10`’s row is “rescue inventory | `rescue_ssh`”. `WIR-30` says “The gate reads the copy the machine took at create”. No static-only option 3 covers `RSC-26`’s machine “bought under a listed strategy”. A separately specified runtime refusal after inventory collection could.

Baseline `RSC-46`’s “sorted by identifier” defines neither null placement nor ties. My amendment uses normalized preferred WWN/serial, null first, then canonical projection bytes; preserves multiplicity. Empty/ASCII-whitespace-only inventory values become absent. Identical projections need no distinguishable order.

The triage rationale is incomplete: `RSC-26`’s “Zero matches is the stale-inventory case” concerns a supplied identifier. A null device cannot be named. Lean already has optional `Device.identifier` and required `Request.identifier`. Baseline `WIR-20` says “a drive serial or WWN” but does not explicitly classify null/empty failures. I specify `invalid_request` before enqueue for missing/null/non-string/normalized-empty identifiers in both request locations; well-formed unmatched identifiers still abort `integrity`.

The field gap belongs here: add separate `wwn` and `serial` beside preferred `identifier`, making absence and fingerprint inputs explicit.

**CNF-47 draft:** “Return A and B with explicit nullable identity fields; recompute the full-set fingerprint; install A; removing/resizing B aborts `integrity` without writes. Exercise all-anonymous machines, blanks, ordering ties, repeated projections and malformed request identifiers.” Leave `CNF-192/206` intact.

[Gate evidence](/var/tmp/provisiond-panel-r61/sol/panel-r61-results.txt): baseline, corrected proposal, bad fixture and restored proposal exited **0**. Substituting `/dev/sda` for B’s null passes existing gates; the separate semantic check rejects it (**1**). Executing amended `CNF-47`, or integrating equivalent fixture checks, would catch it. Initial stale-quotation failures were corrected. Edits remain; the mutant is restored.

**Strongest argument against my pick:** string-only decoders must change; `WIR-2`’s “clients MUST ignore unknown response fields” does not protect known-field type changes. Anonymous disks with identical hashed attributes remain indistinguishable.