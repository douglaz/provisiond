1. **Pick (a).** Proving no dispatch establishes safety; it does not repair an invalid request. A restart should not erase a known blocker. [OPS-43](/var/tmp/provisiond-panel-r56c/sol/03-operation-lifecycle.md:774) gives an unsellable-offer refusal “`retryable: false` on both the error and the operation view.”

2. **No specified normal path found.** The examined writes do not produce it:
   - `OPS-43`’s offer refusal records its error and “The operation settles `failed`”.
   - `OPS-8` defers “`running` back to `queued` with `available_at` advanced”, specifying no error write.
   - `OPS-49` retries whole transactions with the outcome “retained in memory”; a failed settlement does not explain a separately committed error.

   Keep `CNF-358`’s case, explicitly identified as injected robustness coverage for [OPS-16](/var/tmp/provisiond-panel-r56c/sol/03-operation-lifecycle.md:428): “MUST NOT overwrite an error already recorded on the operation”. Ordinary reachability is unnecessary for testing that contract.

3. **No kind-based restart override.** Copy the recorded boolean for `invalid_request`, `rate_limited`, and `internal` alike. Kind alone does not establish whether repeating unchanged is sensible; the reason and circumstances matter.

4. **Claims 1 and 3 stand.** `OPS-16` “fills in an error only where none exists”; [WIR-9b](/var/tmp/provisiond-panel-r56c/sol/13-wire-contract.md:218) makes the view “authoritative” and says “the envelope’s MUST equal it”.

   **Claim 2 overclaims.** [DOM-17](/var/tmp/provisiond-panel-r56c/sol/01-domain-model.md:652)’s “safe and sensible” defines semantics, not view/error equality. Moreover, a recorded `false` does not identify which conjunct failed. Equality is an explicit policy choice, not a consequence proved by that sentence.

   **Claim 4 survives as a writer-inventory conclusion**, not a demonstrated invariant forbidding `running` plus error.

5. **Advocating (b):** The recorded error preserves history; the operation view supplies current guidance. A saved `false` may reflect uncertainty about dispatch. The restart now proves no mutation occurred, making that prohibition stale. Keep the diagnostic intact while setting the authoritative view to `true`, giving callers a uniform recovery path after this restart settlement.

Both unpiped gate runs exited **0**. No tracked edits.