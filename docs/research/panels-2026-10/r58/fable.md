**Pick: A.** The record already treats a cancellation as something the worker records. The algorithm sends every `execute` outcome to `classify`; its only unrecorded exits are `OPS-49`'s. ADR-0022: "cancellation under `OPS-21` is an outcome the owning worker records". F47 lists "restart and ... `OPS-21`'s cancellation" as two paths. C would turn every graceful stop into a crash for every kind: an install cancelled before its marker is `failed` today ("for any failure at all while `OPS-45`'s two markers say the disk is untouched") and would park under "whatever the markers hold". A needs no new parameter: the settle write already runs under `OPS-49`'s "Store-retry bound" (00:401); a supervisor kill before it lands is the crash case.

**Q2.**
1. True, not an argument. The split is the design for every kind ("classifies a failure a worker recorded; an operation interrupted rather than classified is `OPS-15`'s"); deploys are graceful, and `OVR-18` calls the restart window "the accepted outage".
2. That sentence separates recorded from interrupted; nothing says a cancellation is an interruption, and ADR-0022 says the reverse. pv-9j6's delete "records a cut-off `conflict`", a recorded case.
3. No contradiction. "Ambiguous" is the failure's property (OPS-11's bullets); rows consume it: "`needs_reconciliation` if the failure is *ambiguous*, otherwise `failed`". The install row's "any failure at all" includes ambiguous ones, as for `network`; `Tables.installRow` never reads `ambiguous`. The create carve-out was the same redundancy.
4. Holds, at a cost: `cutOff` is a field of the six-field constructors (Witnesses.lean:3023, 3035, 3038) and `classify_total`'s binder; README: "Withdrawn wording is retained when deleting it would let someone re-lay a trap".
5. Correct, and it is C's cost: "`execute` MUST be cancellable" then means only "the process may die", withdrawing OPS-21 whole.
6. True and irrelevant: it compares two unrecorded exits (cancel-in-loop, exhaustion), not recorded against unrecorded.
7. OPS-49: a parent "MUST be returned to `queued` with `available_at` advanced — the same write as `OPS-8`'s defer, though nothing refused it". That is its recordable outcome; A names it.

**Q3.** B breaks no MUST sentence: OPS-22 binds how a worker records, not whether; OPS-5 admits "or the startup pass finds it". But OPS-21 calls cancellation "an ambiguous outcome", the thing `classify` consumes, and B is a restart only when the cancellation kills the process. The bead's "both read as conforming" holds against the sentences, not against the algorithm or ADR-0022.

**Q4.** Neither jointly; pv-tst first. A keeps the cut-off `conflict`, so pv-f7a stays live; C would moot it. pv-9j6 asks about any recorded pre-dispatch failure and is unchanged by either.

**Q5.**
- OPS-21: one sentence. A cancellation outside OPS-49's loop is an outcome the worker records and classifies under OPS-11 before the engine exits, bounded by OPS-49's retry bound only; a `suspend_tenant` parent takes OPS-49's defer. Keep the sentence CNF-361 quotes.
- CNF-361: replace "assert nothing about one it does not" with a cancel after step 8's acknowledgement asserting the settle lands before exit; control: cancel inside the loop, restart, `needs_reconciliation`.
- ADR-0043 dated amendment (it owns "`OPS-21` points at that create row for a recorded cancellation"); pointer in ADR-0022.
- Lean, ci.yml, CONTEXT.md: nothing. The tables model classifies recorded failures and carries no process property.

**Q6.** Planted "MUST be recorded and classified under `OPS-11` before the engine exits" with no bound: all seven gates PASS, exit 0. No gate reads a MUST's bound; the only catch is CNF-361's running-system case (hold the store, assert exit within OPS-49's bound). For C, deleting OPS-11's bullet reds citations: "Tables.lean quotes a phrase found in no document". That is a cost of C, not a control.

**Q7, as advocates.**
*B:* "The gap is one acknowledgement wide; most cancellations land in a driver call or the loop. A MUST untestable on a kill buys a CNF case, not money. Say both conform and stop."
*C:* "One path for every stop: no cut-off kind, no reason value, no drain, pv-f7a closes, a field and a witness go, and the restart path is already proven and sweeps."
