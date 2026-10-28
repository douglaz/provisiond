# r78: opus reader (claude-opus-5-5, xhigh)

**apply notes.md rule 6 exactly as written; this prompt adds no void rule.**

I read pin `cebdc4f8f728f40d7fdf3c10ed094a1a7d2b8527` in my own clone, and restored the clone after each test. The full answer, with every line reference, is in `/var/tmp/provisiond-panel-r78/opus.draft.md`.

## Votes

| Question | Package | Mark | Preference |
|---|---|---|---|
| Q1 pv-kwuf | K-EXACT | **ACCEPT** | **K-EXACT** |
| Q1 pv-kwuf | K-FLOOR | **ACCEPT** (notes below; none are conditions) | — |
| Q2 pv-75w3 | S-STOP, all of S1–S4 | **AMEND** (R-S1 to R-S5) | **NONE** as printed. I'd prefer S-STOP with R-S1 to R-S5, but that form needs its own complete read. |

No brief error changes either question's premise, and no vote rests on a brief error.

## Q1: stopping a tiny wait from becoming "no timeout"

**The premise holds.** I re-ran the parser-only check on PostgreSQL 17.9 (no server started) and read the local 17.9 docs:
- **Zero:** the docs say a zero value disables the timeout.
- **Rounding:** fractional values round to the nearest integer. Ties go to the even number, so 500us also becomes 0 and 2500us becomes 2. The bead's "under 0.5 ms" understates the problem: everything up to and including 0.5 ms disables the timeout.
- **Range and odd inputs:** the accepted range is 0 to 2147483647 ms (about 24.8 days). 2147483648ms and 25d are refused, and so are infinity, inf and NaN.
- **Version:** I did not check PostgreSQL 18.

**K-EXACT, ACCEPT.**
- **Home:** the rule lives in one place, the register cell, and OVR-19 already makes startup refuse an out-of-range value.
- **OPS-15:** unchanged, and still literally true, because the timeouts equal the configured bound.
- **Values:** every accepted value reaches PostgreSQL as a whole number from 1 ms up, so neither rounding nor zero can happen.
- **Lean:** no proof models this setting, so nothing formal changes.

**K-FLOOR, ACCEPT.** It also never produces zero. Notes, none of them conditions:
- The register cell still says the bound is "also" the two timeouts, while OPS-15 now sets them to the rounded-down value. That is imprecise rather than contradictory, and restating the rounding in the cell would give the rule a second home.
- It adds a conversion duty.
- One parameter ends up with two effective values: the startup-lock retry (OPS-47) uses the exact bound, and the generation advance uses the rounded-down one.

**A side effect neither form mentions.**
- **What's affected:** the same register cell is also OPS-47's lock-retry bound, so both forms narrow what operators may set there.
- **No real loss:** a bound above PostgreSQL's range already fails every startup today, at the advance, so refusing it at validation only moves that exit earlier.
- **Scope:** the brief says Q1 is "not authority to change … startup lock". This narrows the lock's input range, not the lock protocol, so I don't count it as a blocker.

**Would something cheaper work? No.** "At least 1 ms, passed straight through" lets 1.5 ms become 2 ms. The server timeout would then be longer than the stated bound, which works against STO-7's rule on client deadlines. K-EXACT is already the cheapest complete form.

**Which existing check shows the refusal?** No conformance item tests refusal for individual register rows; the general duty sits in the checklist's *Before production* section. CNF-369 is the only item that uses this bound, so appending there is reasonable.

**Cost of observation.** Checking the "effective timeout settings" needs a way to see them, such as statement logging, a wire capture or engine instrumentation. K-FLOOR's 1 ms vs 2 ms assertion can't be checked by timing alone.

**Why K-EXACT.** It needs a single rule and no conversion. It only refuses sub-millisecond precision on a startup wait, and that refusal is loud and stops startup safely. Which inputs to accept is a policy choice for the owner.

## Q2: a survived stop before the fence

**I traced the whole route and it holds.**
1. The sweep enqueues the cancellation and a worker claims it.
2. A stop arrives before the first fence transaction is sent. OPS-21 requires that stop to be recorded.
3. The record is the normal guarded write. Its error is the cut-off conflict with reason `cut_off`, which WIR-9a lists.
4. OPS-11's last row says a failure recorded while the write-started marker is unset "MUST settle `failed`". That marker is only set once the provider call is dispatched, so it is still unset.
5. OPS-48 turns a `failed` attempt into a `stalled` episode with the fence unchanged, here still empty.
6. A later retry finds an empty fence and decides by funding, unless the tenant is suspended.

At no point does the record need to write the fence.

**Other exits are correctly kept out of this fixture.** A later stop, losing to a newer engine, running out the stop-record bound or running out the store-retry bound each leaves the row `running` for the next startup, which is the crash path. A store error alone classifies nothing.

**The old text is now false.** CNF-312, ADR-0032 and Fence.lean all say nothing establishes a worker-recorded failure before the fence. That stopped being true on 2026-10-23 (ADR-0046).

**What the Lean models do and don't cover.**
- **Each half:** the Lean model's `failBeforeFence` event fixes the outcome as `failed`. The table and stop-record models prove the recording half separately.
- **Composition:** nothing combines the two, and S-STOP doesn't claim it does.
- **Theorems:** six existing theorems already cover this event, and S4 changes no definition or theorem.

**What the deleted sentences protected.**
- "Drive route 1 alone" guarded against an unspecified injection point; S1's explicit boundary now does that job.
- The OPS-23/OPS-45 reasoning becomes moot.
- The "over-approximation" claim is replaced, and the caveat that the models aren't combined is kept.
- "Proofs cover this larger trace set" can go, since no theorem changes.
- The "do not inject a store error" instruction is lost under S1 (R-S3).
- The "Instrument …" sentence is at risk (R-S2).

**Still preserved:** no requeue after a crash, store-error retry, current-suspension precedence, the extension/fence order and the fenced controls.

**Why AMEND:**
- **R-S1:** S1 runs the suspended row on both prefixes, but the lines it leaves untouched still say "from the route-1 prefix" and "Use the route-1 prefix".
- **R-S2:** taken literally, "two paragraphs" also deletes the "Instrument …" sentence, which is what pins down Order A versus Order B. Without it, those assertions can pass on a fixture that only orders API calls. That is a **blocking loss** if the literal span is applied; pinning the span fixes it.
- **R-S3:** S1 replaces the quoted instruction not to inject a store error with an unquoted summary.
- **R-S4:** S3 deletes the owner's words, "Covers all three routes". Those words are what bring this route under the existing decision.
- **R-S5:** S4 says the failure's outcome "is an input here", but the event takes no input and hard-codes `failed`.

## Exact repairs

**R-S1** (`10-conformance-checklist.md`; fixture text; behaviour changed against the base, matching what S1 already declares)
- **`:2475`, before:** `**Suspension fan-out:** from the route-1 prefix, suspend the tenant.`
- **`:2475`, after:** `**Suspension fan-out:** from each null-fence prefix (route 1 and the survived-stop prefix), on its own instance, suspend the tenant.`
- **`:2488`, before:** `| Suspended, null fence | Use the route-1 prefix and suspension fan-out above.`
- **`:2488`, after:** `| Suspended, null fence | Use each null-fence prefix and its suspension fan-out above.` The rest of the cell is unchanged.

**R-S2** (S1's span; behaviour unchanged against the base). The replaced span runs from `:2449`, which begins "`OPS-45` says …", to `:2457`, "The fenced rows use their own prefixes below." Lines `:2458–2459` stay word for word after S1's second paragraph and apply to both prefixes:
> Instrument the deciding fence transaction's read/commit boundary:
> retry enqueue alone establishes neither transaction order.

**R-S3** (S1, second paragraph; behaviour unchanged against the base)

Before:
> A store error alone remains `OPS-49`'s retry path, not a separate worker-recorded failure.

Replacement (the base's own sentence, kept):
> Do not inject a store error as a separate failed route: `OPS-49` requires "repeat the **whole transaction**" and on bound exhaustion "the engine MUST exit non-zero".

**R-S4** (S3, ADR-0032 `:43–51`; wording only, behaviour unchanged). Keep this sentence word for word, directly before S3's record:
> Owner comment 194 says "Covers all three routes", including worker-recorded pre-fence failure.

**R-S5** (S4, `Fence.lean:96–98`, explanatory text only; behaviour unchanged)

Before:
> the failure's durable outcome is an input here.

Replacement:
> the event assumes that record landed with the attempt `failed`.

S4's other replacement, the event's own description at `:982–983`, is accurate as printed.

## Internal consistency

- **Q1 inputs:** the accepted and refused inputs in each CNF addition match that form's register cell.
- **Q1 scope:** the only tension is the lock-retry narrowing above.
- **Q2 span:** S1 has two span descriptions that disagree (R-S2), and its fixture selection disagrees with the text it keeps (R-S1).
- **Q2 ADR:** ADR-0032's untouched sentence naming only crash and restore as the null-fence routes becomes incomplete after S3. That's non-blocking because the dated record follows it.

## Requested counterarguments (not votes)

**Against K-EXACT.** Both forms prevent the disabled timeout, so K-EXACT's extra refusals add no safety. It turns a tiny precision slip, such as `2.0000001s` produced by config tooling, into a failed startup, and it narrows the lock-retry setting without saying so.

**Against S-STOP.** The new prefix ends in the same state as route 1: stalled episode, empty fence, unset marker. So repeating Orders A and B and the suspended row on it only catches a build that decides by route, which ADR-0032 already forbids ("keyed on the fence, not the route"). The prefix's own assertions plus one Order would catch that more cheaply.

## Brief claims checked (rule 6)

- **Q1:** the quotes, probe values and 17.9 doc claims all hold. The only omission is the lock-retry side effect. Premise unchanged; nothing voided.
- **Q2:** the quotes hold, with two imprecisions. The `failed` outcome dates from ADR-0046, not the original survived-stop change (ADR-0044). S1's span description is ambiguous. Premise unchanged; nothing voided.

## Checks

- **Run:**
  - The full gate (`nix develop --command bash tools/check-all.sh`, unpiped) passed with exit 0 on four trees:
    - K-EXACT plus S-STOP;
    - K-FLOOR plus S-STOP;
    - the pristine pin;
    - K-FLOOR plus S-STOP plus all my repairs.
  - The repaired-tree run kept one extra ADR sentence that I later removed from R-S4. It doesn't need a re-run, because the gate doesn't check quotes inside ADRs.
  - CI's negative controls don't touch any of the edited text.
  - The launcher's gate receipts in `check/` are not my runs.
- **Scratch files:** probe data, scripts and gate logs are under `tmp/opus-*`, and the Lean build cache (`.lake`) is in my clone, where git ignores it.
- **Not run:**
  - PostgreSQL 18.
  - Any live server, timing or standby test.
  - Runtime conformance.
  - Any new or combined proof.
  - The literal-span version of S1, which the gate couldn't tell apart anyway.
- **Failures:** none.
