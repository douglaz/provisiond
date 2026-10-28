I'll read the panel notes and the pinned package first, then judge E-KEEP, E-TOTAL, and E-SPLIT against the owner's UO decision.Notes are in. Next I’ll read the three candidate packages and the pinned certificate text they edit.The three packages differ by one sentence. I’ll check that sentence against the certificate, the counterexample, and the pin’s own definitions.The quotes and the counterexample check out. I’ll record the verdict, then the exact sentence repair.The draft is longer than the requested length. I’ll tighten it and keep the votes, the repair, and the evidence.**Votes.** E-KEEP: AMEND. E-TOTAL: AMEND. E-SPLIT: CANNOT ACCEPT. Preference: NONE.

**Classifications.** Printed E-TOTAL: UNRESOLVED. Printed E-SPLIT: BEHAVIOUR-CHANGE. The repair below is an unreviewed WORDING-REPAIR of the quoted inclusion MUST. It is not a reviewed candidate and does not authorize application.

Pin `3c214c147021a90d4ba5a74269b8bd4adc389670` matches this clone. The brief's pin-labelled quotes hash-match `check/source-verification.json`. The rendered packages differ only in the first sentence of the replay-timestamp paragraph. No rule 6 void.

## Certificate

Quoted MUST: "A non-null b MUST certify that every source-history component commit acknowledged before b belongs to recovered committed history." Publication narrows that guarantee to "commits acknowledged strictly before b."

This construction meets that MUST only when b is at or before the real generation instant g of the stored timestamp. Astra, `r74/r76/astra.md:70`, states the lemma as "certified `b=s−e≤g`." Opus, `r74/r76/opus.md:105`, infers it from clock error alone: "let e bound the source clock's error. R's true generation time is then at least s−e = b." That inference treats s as the clock reading. It is false when representation puts s ahead of the clock. Astra line 74 and sol line 122 say precision and rounding belong in the evidence. Those lines are review intent, not a definition of e. No adopted or normative sentence puts precision, quantization or rounding inside e, and none forbids upward rounding of this timestamp. `Restore.lean` has no theorem about e. Every candidate leaves its declarations alone.

The failure story meets the printed E-KEEP evidence and breaks the MUST. Recomputed from `check/counterexample.json`: g = 25001/2500, R is inserted at 20001/2000, lost commit C is inserted at 50003/5000 and acknowledged at 100007/10000, s = 10001/1000, e = 0. Then b = 10001/1000, and 100007/10000 < 10001/1000, so C's acknowledgement is strictly before b while C sits outside the prefix. Generation-before-insertion and the prefix condition hold. s−g = 3/5000. An allowance of at least 3/5000 yields b ≤ g, and C is then not strictly before b. With q = 1/1000, b = 10 ≤ g. A later finite f still satisfies b≤f, so that check does not save the bad lower bound. The hole is in the local grant. The MUST remains the inclusion property.

## E-KEEP — AMEND

Printed sentence, `docs/research/panels-2026-10/r74/decisions/pv-3jw6.md:51` and `check/E-KEEP.md:13`:

> The last replayed commit-or-abort record's timestamp s can supply b=s−e only with evidence that e bounds the source clock's error, the timestamp was generated before insertion, and the recovered continuous prefix on matching ancestry contains that complete record.

"Can supply … only with" grants b=s−e when those three items are evidenced. The next sentence names the earlier-acknowledgement implication as the certificate. It adds no representation evidence and does not retract the grant. Nothing in the package then searches for the lost acknowledgement. The printed sentence is a misleading sufficient recipe. E-KEEP is not accepted as printed, and no clarification is read back into it.

The rest of UO stands: unknown endpoints, no extra startup hold, reused continuation values, a separate event clock, and the same formal scope. The owner already chose that policy.

## E-TOTAL — AMEND

Printed classification: **UNRESOLVED**.

The sentence keeps b=s−e and requires e to bound "the source timestamp's total error, including source-clock error and timestamp precision, quantization and rounding." On the best reading, e=0 is not evidence in the checked story, a downward-only representation may contribute zero, and no hold is added. That reading only blocks a discharge the MUST already rejects.

The printed words are not accepted. They never say the error is how far s is ahead of real generation. "Total error" also reads as a two-sided magnitude. A proof that s is at most e ahead of g, with no finite bound on how far s falls behind g, discharges the MUST, because downward error only moves b earlier. A two-sided reading refuses that proof, which is an admissible-input restriction the MUST does not contain. The words do not say e is nonnegative or in s's time frame. A negative allowance moves b forward. "Including precision" can be read as a mandatory quantum when the evidenced upward change is zero. Mere finite precision is not upward error. The printed sentence is not a proved wording repair and not a proved behaviour change.

## E-SPLIT — CANNOT ACCEPT

Printed classification: **BEHAVIOUR-CHANGE**.

The formula becomes b=s−e−q. q is a finite nonnegative upper bound on the upward difference between s and the source-clock reading at generation. In the checked story, q = 1/1000 and e = 0 give b = 10 ≤ g. Missing q uses the unchanged unknown path. No default q=0 and no new hold appear.

The MUST is discharged by one finite nonnegative e ≥ s−g plus the existing prefix conditions. E-SPLIT refuses a combined generation-time bound unless it is factored into clock error and representation error. That combined bound is a valid certificate, and the operator-supplied sentence does not carry it: that sentence is an earlier operator-supplied bound, not this replay construction. The new quantity and the new equation are an accepted-input restriction. A conservative label does not make the restriction editorial.

q measures s against the clock reading. The sum is safe only when e also bounds how fast that reading is against real generation. "Bounds the source clock's error" still does not say that. The upward allowance q protects can sit inside one e. This vote accepts no candidate that keeps q, and it deletes q from no accepted package.

## Unreviewed repair

AMEND text for E-KEEP and E-TOTAL. One seat. Not reviewed. No application.

Location: prospective STO-54 insertion, first sentence of the replay-timestamp paragraph only (`pv-3jw6.md:51`, `check/E-KEEP.md:13`, `check/E-TOTAL.md:13`). Archived `r74/r76/q2-UO.md` stays verbatim. Every later sentence stays byte-identical.

Before, E-KEEP: the sentence in the E-KEEP section.

Before, E-TOTAL:

> The last replayed commit-or-abort record's timestamp s can supply b=s−e only with evidence that e bounds the source timestamp's total error, including source-clock error and timestamp precision, quantization and rounding, the timestamp was generated before insertion, and the recovered continuous prefix on matching ancestry contains that complete record.

Replacement:

> The last replayed commit-or-abort record's timestamp s can supply b=s−e only with evidence that: e is a finite nonnegative upper bound, in the same time frame as s, on how far s is ahead of the real time at which that timestamp was generated, and that bound accounts for source-clock error and for any upward change introduced by timestamp precision, representation, quantization or rounding; the timestamp was generated before insertion; and the recovered continuous prefix on matching ancestry contains that complete record.

**Behaviour unchanged** against the quoted MUST, the unknown-endpoint rule, continuation reuse, and the rule that missing reporting evidence does not hold startup. The equation stays b=s−e. No schema, fixture, conformance assertion, Lean declaration, or startup hold is added. An evidenced upward change of zero stays admissible. The clock-only grant is withdrawn where the evidence does not upper-bound how far s is ahead of generation.

Classification: **WORDING-REPAIR** within UO. This sentence is the discharge of "every source-history component commit acknowledged before b." The checked story meets the printed grant while an acknowledgement strictly before b remains outside the prefix. Requiring e to upper-bound that lead is the guarantee the publication sentence already states. The repair forbids no b the MUST allows and permits no b the MUST forbids. If a later tally treats every newly written proof hypothesis as behavioural by itself, this sentence is that boundary. Printed E-TOTAL and E-SPLIT still are not wording repairs.

## Adversarial sweep

Upward rounding is the checked failure. Downward rounding can have an upward change of zero, so e may be only the fast-clock allowance. Nearest and coarse precision require e to cover the evidenced maximum upward movement, with no mandated algorithm and no default quantum. A perfect clock, e=0, is valid only when that upward change is evidenced not to be positive. Missing or invalid precision evidence skips this construction: null is persisted, and startup is not held. b≤f is necessary and does not certify the lower endpoint. Source and event provenance stay distinct. The event-clock sentence is the same in every candidate.

Adjacent, not a vote: f=restore_instant+e_event, from "an upper error bound on the incident transaction's event clock," has the mirror hole. A slow event clock or a downward-rounded `restore_instant` can put f before the true transaction start, while fencing excludes old-history acknowledgements only after that true start. No candidate changes the sentence. It is not repaired here.

Adjacent, not a combined rewrite: OVR-19 still says "source/event clock-error evidence," CNF-295 still says "unavailable source/event clock bounds," and CNF-365 still says "verified prefix/clock evidence." None of them says a clock-only number suffices. The STO-54 MUST remains the certificate.

Shared package fact, not a premise change: every candidate says "At 05:1656." At this pin, "the report naming `T − Δ` is what tells the operator the clock moved" begins at `05-persistence.md:1659`. The execution section already says to verify anchors. No vote depends on 1656.

No CNF identifier enters `tools/formal/`. No theorem is weakened. `Restore.lean:39–43` still leaves publication outside the model.

## Counterarguments (not votes)

**For keeping the adopted wording.** The MUST already forbids a non-null b that fails inclusion, and "only with" can be read as necessary evidence rather than a sufficient proof. The implication sentence then blocks the story without redefining e. Astra and sol are not norms. A precision edit changes an owner-accepted sentence and can look like a new duty.

The three listed conditions hold in the checked story, and the implication is the consequence the clock-error sentence offers. Opus's proof, on the side that accepted UO, states the false step in those words. A reader who follows the sentence publishes the bad b and treats the MUST as satisfied.

**For printed E-TOTAL as the smallest repair.** One phrase, the same equation, no new symbol, no hold, no fixture. It places precision, quantization and rounding inside e, as astra, sol and the tally already described, and leaves the inequality to the MUST.

That is the right size and the wrong predicate. "Total error" does not say "how far s is ahead of generation," and the two-sided reading is an extra restriction. The repair above is the smaller adequate predicate. Writing it does not review it.

## Rule 6 and preference

No verified brief error changes the premise. The owner-decision quote, the UO package, current STO-54 and STO-56, the glossary, the Lean comment, and the three r76 precision passages match the pin hashes. The counterexample inequalities hold. The stale 1656 anchor is not a void.

Preference: **NONE.** No printed candidate is ACCEPT. The repair is unreviewed. A direction majority would not authorize a new owner policy. This seat claims none.

| Candidate | Vote | Classification |
|---|---|---|
| E-KEEP | AMEND | printed grant fails the MUST; unreviewed repair is WORDING-REPAIR, behaviour unchanged vs that MUST |
| E-TOTAL | AMEND | printed form UNRESOLVED |
| E-SPLIT | CANNOT ACCEPT | BEHAVIOUR-CHANGE |
| Preference | NONE | |
