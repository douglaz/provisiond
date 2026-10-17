**Gate:** at `16eaff1` the gates exit 0. I edited no tracked file.

**1. I pick (a), because (b) cannot be satisfied.** `WIR-9` says the envelope's error object "is the object `WIR-10b` embeds in an operation view". `WIR-9b` says "the operation view's `retryable` (`WIR-10`) is authoritative and the envelope's MUST equal it". `OPS-16` keeps that object at `false`, so the view must be `false` too.

(b) also cannot be rendered. `05-persistence.md`'s `operations` table has no `retryable` column, and the pass writes no error, column or marker. The row is therefore identical to a claim-time `offer_not_sellable` failure.

**2. No real path reaches this state.**
- Creates never defer. `OPS-8` defers only where "another running operation holds the machine", and a create's `machine_id` is "set on completion for create".
- The refusals in steps 1–7, `price_moved` included, settle `failed` in one guarded write.
- `API-58`'s write is guarded on "`status = queued`".

What remains is `OPS-23`'s "edited in the store". Keep the case, but label the error as injected. `CNF-30` already tests `OPS-16`, so this repeat adds only the view assertion.

**3. No.** The recorded error's own flag already carries `WIR-9a`'s value for its kind. A rule split by kind would be a second copy of that table.

**4. Claims:**
- **Claim 3 is false.** A non-2xx response "is exactly" `{error, correlation_id}`, so the only envelope `retryable` is the one inside `error`. `WIR-9b` therefore binds the view to the embedded error, which is the opposite of what the claim says.
- **Claim 2 overreaches.** `DOM-17`'s subject is the error: "Every error MUST carry … a boolean `retryable`". `API-20` lists the view's field as "`retryable` (`API-51`)".
- **Claim 4 is true.** Its defer premise is moot, because a create never defers.
- **Claim 1 holds.** `WIR-10b` puts `retryable` inside the error.

**Two defects at `16eaff1`:**
- At 03:388, "the restart says nothing new about whether 'repeating the *same request* is safe and sensible'" contradicts claim 2's "nothing was ordered (safe)". Suggested wording: "the restart can show the request safe, never sensible."
- `CNF-29` (10:177-178) still asserts, unscoped, "the restart-naming `internal` error, `retryable: true` on error and operation view". `d4e9bc5` missed it; it should point at `OPS-15` instead of restating the rule.

**5. The case for (b):** The view speaks for the operation, and the restart is what settled it. The restart also established the only fact that matters here: nothing was ordered, and the commitment was released in full. Whatever wrote an error on a create that was still `running` did not settle it, so that error is an interim note. `OPS-16` keeps it as evidence, not as the verdict.

`WIR-9b` calls the view "authoritative" so that it can overrule the inner error, as `needs_reconciliation`'s "always `retryable: false`" overrules a `rate_limited` error. Under (a), the caller's guidance comes from an artifact no specified path writes. Any stray state an engine leaves there would make a caller abandon a purchase that would succeed. (b) gives one outcome per restart and one assertion to test.
