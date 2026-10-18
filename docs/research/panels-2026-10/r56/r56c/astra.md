1. **Pick (a).** A restart does not repair a defective request. `OPS-43` requires an unsellable-offer refusal to carry “`retryable: false` on both the error and the operation view.” Proving that nothing was ordered does not make that offer purchasable. Preserving the recorded guidance is the stronger default.

2. **No specified production path found.** `OPS-43` says “The operation settles `failed`”; `PRV-40` says “settle the existing operation `failed`”; `OPS-49` keeps “the provider’s outcome retained in memory” during transaction retries. `OPS-8` describes “`running` back to `queued` with `available_at` advanced.” None specifies an error-only persistence step leaving this create running. Keep `CNF-358`’s recorded-error case, explicitly identified as an injected preservation test: `OPS-16`’s “MUST NOT overwrite an error already recorded” remains worth testing independently of reachability.

3. **No kind-based override.** Preserve the recorded boolean rather than introducing `internal ⇒ true` or `rate_limited ⇒ true`. Kind alone does not establish why repeating was judged inappropriate. A contextual exception would need an explicit rule distinguishing a permanent request defect from uncertainty that the null-column check resolves.

4. **Claims 1 and 3 stand; 2 overclaims; 4 needs qualification.**  
   Claim 1: `OPS-16` says “MUST NOT overwrite an error already recorded”; `WIR-10b` includes “`kind`/`message`/`retryable`/`details`” in that object.  
   Claim 3: `WIR-9b` says the view is “authoritative and the envelope’s MUST equal it”; that does not equate view and embedded error.  
   Claim 2: `DOM-17` says “safe and sensible,” but false does not distinguish *unsafe* from *insensible*. Resolving safety uncertainty could change that conjunction. Equality is a defensible policy, not a deduction from this sentence.  
   Claim 4 is supported as a search result, not an impossibility proof: absence of a specified producer does not itself prohibit an implementation from persisting an error before settlement.

5. **Advocating (b):** The view should express the best current knowledge; the embedded error preserves historical knowledge. The restart check establishes that this purchase never began. Let that new fact remove a conservative retry prohibition caused by uncertainty, while preserving the original error intact. Copying a historical false can strand an otherwise repeatable request. This argument is strongest for uncertainty, weakest for known request defects.

Both unpiped gate runs exited **0**. No tracked files changed.