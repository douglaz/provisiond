**Verdict:** Reading (1), as a one-phrase repair of `PRV-13c`: round 1 introduced the start-based test, and the end-based test is what `PRV-13c`'s own rationale already requires. No threshold tune, nothing new to build.

**Why.** Three sentences name the instant the earliest-date cost runs to, and since `3b717a0` they disagree:

- `02-provider-contract.md:551-554` (`PRV-13c`): "Branch to the exception path when the stored permitted-from instant is materially in the future". The diff from `918af0e` shows the prior text was "when it is materially in the future"; the Implementer inserted the start.
- `02-provider-contract.md:288` (`PRV-13b`): the reserve term is "exception branch only".
- `12-billing-and-ledger.md:352` (`LDG-33`): "cost through any future permitted-from date to its provider-local day end", no branch qualifier.

`PRV-13c` says what "material" is for: "anything nearer is indistinguishable from the ordinary exhaustion path and needs no exception". What must be nearer than one period plus wind-down is the cost horizon, and Q23c made that horizon the day end. Read the end and the three agree. For a day-only date the threshold then never bites: a start after now puts the end over twenty-four hours out, so "exception" means "a day after the provider's today", with no second threshold.

Near-midnight understates it. Any purchase inside the threshold before a provider-local midnight, with tomorrow as the earliest day, hits it, always by a full day of cost. Under reading (2) the result is a false exhaustion, not an under-reserve: `LDG-33` protects a day the reserve never held, `usable_sats` reaches zero, `runway_until` drops to the mark, `LDG-16` routes after the first paid unit, and an `OPS-41` re-check before that midnight re-derives the same zero and proceeds. Robot rejects or schedules `now` at the earliest day (`08-provider-notes.md:169-171`), the machine is `cancellation_scheduled` through the day end, and what absorbs it is `LDG-63` (`12-billing-and-ledger.md:1983-1991`): "re-derivation MUST top the commitment from available", shortfall "operator-borne". A funded machine is cancelled and its owner's balance seized for a day they did not buy. That is the Manager's "what funds it", and why (2) is unacceptable.

First principles. End-of-day pricing is right as a bound: the only specified way to stop a machine before its earliest day is "on rejection, fall back to scheduling at the earliest permitted date" (`08-provider-notes.md:169-171`, a MUST living in an evidence file, pre-existing), and a day-dated cancellation ends at the day end under `PRV-13`; `PRV-31` returns the difference to runway once the day passes. Reachability: Robot's docs say "You can only cancel immediately" (`docs/research/provider-verify-2026-10.md:320-321`), three live deliveries returned today (`08-provider-notes.md:410`), and `CNF-147` reaches the branch only by injection (`10-conformance-checklist.md:1366-1367`). The brief's `CNF-147` quote is stale: "no launch product reaches the branch by default" was removed by `4a3c023`; the surviving sentence is `LDG-38`'s "It cannot arise in v1" (`12-billing-and-ledger.md:998-1000`). Making the set empty by fiat means withdrawing a branch the owner kept ("the branch stays specified because the read-and-branch shape is what makes a machine with an inherited contract safe when it returns", `PRV-13c`) or a sale gate against future bounds. Both exceed the phrase that fixes the test, and a specified, tested branch must be coherent while dormant.

**Defects.**
1. `02-provider-contract.md:551-553`: the branch test reads the start.
2. `12-billing-and-ledger.md:1001`: `LDG-38` quotes `PRV-13c` as "branch to the exception path when it is **materially in the future**"; `3b717a0` changed the source, so the quotation no longer matches.
3. `10-conformance-checklist.md:2113-2118`: `CNF-275` asserts only a date "a week out"; nothing pins start-inside, end-outside.

**Edits.**
- `PRV-13c` (`02:551`): "Branch to the exception path when the instant the cost runs to, `PRV-13`'s priced-through day end, is materially in the future; for a day-only date that is any date after the provider's today."
- `LDG-38` (`12:1001`): requote.
- `CNF-275`: one sentence. At `2026-10-30T22:30:00Z`, earliest day October 31, isolated Europe/Berlin: start thirty minutes away, end `2026-10-31T22:59:59Z`, exception branch, term reserved from the declared bound at create. `CNF-63` is the driver conversion item; the fixture belongs with the threshold.
- `ADR-0037`: a Q25 line naming `3b717a0`'s start wording as the error.
- `PRV-31`, `LDG-33`, `PRV-13b` unchanged. `LDG-33`'s unscoped term then differs from the reserve only for an explicit-timestamp date inside the threshold, bounded by the threshold, which `PRV-13c` calls indistinguishable.

**Don't build.** A "wait for the permitted-from instant, then cancel `now`" path. It saves at most a day of customer cost on a branch no launch product reaches, mirrors the "fund the rest of the provider day on every purchase" option Q23c rejected, and needs a waiting cancellation with its own evidence rules. Also no post-order resize, no second threshold, no new sale gate.

Gates not rerun: no tracked file edited; the Manager reports green at `12a1c89`.
