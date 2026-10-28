**Votes: E-KEEP ACCEPT; E-TOTAL AMEND; E-SPLIT ACCEPT. Preference: E-KEEP.** SPLIT acceptance is acceptance of a disclosed behavioural proposal, requiring owner authorization before application.

Reviewed pin: `3c214c147021a90d4ba5a74269b8bd4adc389670`, including every complete rendered candidate. I applied notes.md rule 6 exactly as written; no premise-changing brief error was verified, so Q1’s tally is not void.

Let `g` be the real timestamp-generation instant, `c` the source-clock reading then, and `s` the represented timestamp, all expressed in matching units and frame. The controlling [prospective STO-54 contract](https://github.com/douglaz/provisiond/blob/3c214c147021a90d4ba5a74269b8bd4adc389670/docs/research/panels-2026-10/r74/decisions/pv-3jw6.md#L49) is:

> A non-null b MUST certify that every source-history component commit acknowledged before b belongs to recovered committed history.

For the generation-order proof, `b≤g` suffices: a commit acknowledged at `a<b` has its commit record inserted before `a<b≤g<insert(R)`, hence within the continuous matching prefix containing R. R may be an abort; timestamp order need not equal WAL order.

Consequently, that proof needs `e≥s−g`. This bounds the timestamp’s **forward error relative to real generation**. An absolute error bound suffices but demands more than necessary. SPLIT works because `c−g≤e` and `s−c≤q` imply `s−e−q≤g`. A bound only on lateness, `g−c`, has the wrong sign.

The supplied failure trace satisfies:

`g=10.0004 < insert(R)=10.0005 < insert(C)=10.0006 < ack(C)=10.0007 < b=10.001`.

Its upward representation error is exactly `0.0006`; perfect clock error zero does not cover it. Total forward allowance `0.0006` gives `b=g`; SPLIT’s `q=0.001` gives `b=10`. I independently checked these inequalities with exact rationals.

The trace satisfies the local clock/prefix conditions but **violates the overarching MUST**. The sentence says “only with evidence”; it does not explicitly make its list sufficient. Its retained tail says “The earlier-acknowledgement implication is the certificate”. E-KEEP therefore never authorizes this false finite report.

I found no adopted explicit definition already incorporating representation into `e`. Prior readers’ precision explanations establish review intent, not another normative definition. WIR-1’s “at second precision” supplies neither this source timestamp’s rounding direction nor its error certificate.

**E-KEEP:** acceptable when read as a complete package. Its local sentence risks being mistaken for a sufficient recipe; the optional wording repair below would reduce that risk. That concern does not remove the controlling certificate obligation or establish a blocking loss under rule 3.

**E-TOTAL:** supports the intended generation-order proof if “total error” means error relative to real generation. Its reference and direction remain implicit, however, and an ordinary absolute-error reading unnecessarily demands evidence about downward error. With perfect clock, `g=10.0004` and downward `s=10`, E-KEEP permits `e=0,b=10`; absolute-total error requires `e≥0.0004`, making the named construction produce `b≤9.9996`. The exact directional amendment below addresses this.

There is a stronger reason **both printed edits change behaviour**, even under a one-sided interpretation of TOTAL. Modify the supplied example so that `insert(R)=10.0011`, the missing commit is inserted at `10.0012`, and acknowledged at `10.0013`. Retained insertion evidence can now certify the original `b=s=10.001,e=0`: every acknowledgement before b follows a commit-record insertion before R. The original local conditions and inclusion MUST all hold.

Nevertheless, either repaired construction requires a positive representation allowance and moves its b back to at most `g=10.0004`. The general inclusion certificate does **not** entail `b≤g`; stronger insertion evidence can certify a later b. Thus these edits restrict the previously admissible evidence for the named construction. An independently certified operator fallback may preserve the same numerical endpoint, but that does not make the new construction’s proof restriction editorial.

**E-SPLIT:** acceptable as a safe, disclosed alternative requiring the owner. It states the relevant representation direction precisely. Its additional q evidence and changed equation can widen a previously valid reported interval and add evidence bookkeeping. Separately adding worst-case component bounds may also be more conservative than joint aggregate evidence. These are costs, rather than hidden baseline losses.

For boundary cases:

- Upward and nearest rounding require evidence covering the actual maximum upward difference. Downward-only representation permits `q=0` when evidenced.
- Coarse precision increases the possible allowance; finite precision alone establishes no rounding direction.
- Missing or invalid representation evidence cannot certify an endpoint through the repaired recipe. Independent inclusion proofs remain relevant.
- Overflow, incompatible units, non-finite arithmetic and inconsistent endpoints cannot produce certified fields: the shared contract says “Known b and f MUST be finite and satisfy b≤f” and “Inconsistent endpoint evidence is invalid; report the error and unknown bounds rather than an apparent finite interval.”
- `[b,f]` remains appropriate because the general lower certificate covers acknowledgements strictly before b.

The shared application says:

> Missing reporting evidence does not hold incident creation, the existing restore procedure or component startup once its existing prerequisites are satisfied.

It also says “Continuations reuse the persisted endpoints and evidence unchanged.” These outcomes survive every candidate. No promotion-eligibility change, startup hold or continuation recomputation follows.

The owner’s option was “Record the window when it's proven; otherwise record "unknown" with the reason and let recovery proceed.” That does not automatically authorize stronger proof restrictions: application line 22 specifies “with the verified `defined below` → `defined above` repair only.”

No OVR-19 collision follows. The package directs “Add human STO-54-owned rows”; [OVR-19](https://github.com/douglaz/provisiond/blob/3c214c147021a90d4ba5a74269b8bd4adc389670/00-overview.md#L360) describes human rows as “procedures the deployment records rather than values the process reads”. Representation assumptions belong in retained endpoint evidence, without adding a startup-validated q parameter.

The unchanged event upper bound needs the opposite signed inequality: for real transaction start h and stored timestamp r, `h≤r+e_event`. An adjacent clock-only failure is possible with last acknowledgement `20.0002`, components stopped `20.0003`, incident start `20.0004`, downward stored `r=20`, and `e_event=0`. The shared MUST rejects `f=20`:

> A non-null f MUST certify that no component acknowledged an old-history commit after f.

This adjacent explanatory issue remains outside the proposed repairs; it does not uniquely defeat one candidate.

Formal synchronization explicitly says “Interval/certificate publication remains outside this model's scope.” The retained event assignments and [step_three_writes_grace](https://github.com/douglaz/provisiond/blob/3c214c147021a90d4ba5a74269b8bd4adc389670/tools/formal/Provisiond/Restore.lean#L548) remain independent. No Lean declaration, theorem hypothesis or explicit checklist assertion changes. A fixture relying on a changed construction needs its corresponding evidence or an allowed fallback/unknown arm. No new standalone rounding test is implied.

**Exact AMEND to E-TOTAL.** Location: prospective `05-persistence.md`, STO-54 insertion, first sentence corresponding to pinned application `docs/research/panels-2026-10/r74/decisions/pv-3jw6.md:51`. Do not edit the archive.

Before:

> The last replayed commit-or-abort record's timestamp s can supply b=s−e only with evidence that e bounds the source timestamp's total error, including source-clock error and timestamp precision, quantization and rounding, the timestamp was generated before insertion, and the recovered continuous prefix on matching ancestry contains that complete record.

Replacement:

> The last replayed commit-or-abort record's timestamp s can supply b=s−e only with evidence that e is a finite upper bound on s−g, where g is the real timestamp-generation instant expressed in the same time frame and units as s and s−g includes source-clock and timestamp precision, quantization and rounding effects, the timestamp was generated before insertion, and the recovered continuous prefix on matching ancestry contains that complete record.

Every subsequent sentence and other operation stays byte-identical. **Behaviour changed** relative to TOTAL’s absolute-error reading: one-sided evidence becomes sufficient. Relative to adopted UO, it still restricts this construction to `b≤g`, so remains **BEHAVIOUR-CHANGE requiring the owner**. This replacement is not a panel-reviewed package.

**Optional cheaper third form W — AMEND, behaviour unchanged relative to UO.** Same prospective location.

Before:

> The last replayed commit-or-abort record's timestamp s can supply b=s−e only with evidence that e bounds the source clock's error, the timestamp was generated before insertion, and the recovered continuous prefix on matching ancestry contains that complete record.

Replacement:

> The last replayed commit-or-abort record's timestamp s can supply b=s−e only with evidence that e bounds the source clock's error, the timestamp was generated before insertion, and the recovered continuous prefix on matching ancestry contains that complete record; these conditions do not replace the inclusion certificate above, which also governs when timestamp precision, quantization or rounding moves s forward.

All other bytes stay unchanged. **WORDING-REPAIR:** the addition states the existing MUST’s applicability. It imposes no `b≤g`, separate evidence quantity or new test; it rejects the bad trace and retains the valid delayed-insertion trace. W is adequate to clarify that clock evidence alone is insufficient. It is optional to my KEEP acceptance and remains unreviewed by the panel.

**Requested counterargument for KEEP, separate from votes:** the general MUST and retained inclusion-proof sentence already reject the false report; replacing them with a stronger construction can spend owner authority without improving the required safety property.

**Requested counterargument for the smallest explicit repair, separate from votes:** the plausible clock-only recipe invites implementation mistakes despite the overarching MUST. W directs readers to the controlling certificate without introducing another duty.

Evidence: source hashes and comment 835 matched; KEEP matched the operative package; TOTAL and SPLIT changed only their printed sentence. Both required unpiped `nix develop --command bash tools/check-all.sh` runs exited **0**. The arithmetic probes were hypothetical, not database measurements or Lean proofs. Tracked files remain clean. The substantive [draft](/var/tmp/provisiond-panel-r79/sol.draft.md) is saved. No premise-changing brief error or contradiction among the rules, examples and criteria was verified.

| Whole candidate | Vote |
|---|---|
| E-KEEP | **ACCEPT** |
| E-TOTAL | **AMEND** — printed form not accepted |
| E-SPLIT | **ACCEPT** — disclosed behavioural proposal requiring owner authorization |

**Final preference: E-KEEP.**

**Separate classifications:** E-TOTAL — **BEHAVIOUR-CHANGE requiring owner**. E-SPLIT — **BEHAVIOUR-CHANGE requiring owner**. Directional TOTAL amendment — **BEHAVIOUR-CHANGE relative to UO**. Optional W — **WORDING-REPAIR, behaviour unchanged relative to UO**.

No adoption, tracker mutation, implementation, next round or PR action is authorized by this review.