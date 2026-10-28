# r79 Q1 — opus (claude-opus-5-5, xhigh)

apply notes.md rule 6 exactly as written; this prompt adds no void rule.

**Q1 answer.** The certificate needs an *upward-only* allowance measured from the record's real generation or insertion instant. That allowance covers clock error plus any upward rounding. It does not need a two-sided "total" error.

UO's certificate already forbids a clock-only b that rounds up, so spelling the allowance out stays within UO only in a form that changes no admissible outcome. Both printed repairs change one.

**Votes:** E-KEEP **ACCEPT** (unconditional) · E-TOTAL **AMEND** · E-SPLIT **ACCEPT**. **Preference: E-KEEP.** Classifications: E-TOTAL **BEHAVIOUR-CHANGE** · E-SPLIT **BEHAVIOUR-CHANGE (narrow, conservative)**. Counterarguments are in their own labelled section and are not votes.

Pin checked: `git rev-parse HEAD` = `3c214c147021a90d4ba5a74269b8bd4adc389670`. Line 51 of `docs/research/panels-2026-10/r74/decisions/pv-3jw6.md` matches E-KEEP's sentence. The three candidate files differ from one another only at line 13 (`diff`). Gate receipts `check/gate-before.exit` and `check/gate-after.exit` = 0. I edited nothing in the clone.

## 1. The certificate inequality

Definitions:
- g: the real instant at which R's timestamp is generated.
- c(g): the source clock's reading at g.
- s: the timestamp actually used.
- ins(R): R's WAL insertion.

The package's certificate says "A non-null b MUST certify that every source-history component commit acknowledged before b belongs to recovered committed history". If C is acknowledged at a < b, C's commit record was inserted before a. So if b ≤ ins(R), C precedes R in the WAL. "the recovered continuous prefix on matching ancestry contains that complete record", so C is recovered.

**The exact requirement is b ≤ ins(R).** The package's route is b ≤ g < ins(R), using "the timestamp was generated before insertion". With b = s − allowance, the inequality is one-sided. It only requires that s not exceed g by more than the allowance:

  s − g = (c(g) − g) + (s − c(g)) ≤ e_ahead + q, where q ≥ sup max(0, s − c(g)).

Downward error never hurts b. Sign matters, and the reference point is generation (or insertion), not commit or acknowledgement time.

**The failure story is consistent with the local recipe, not with the package.** `python3 -I tmp/opus-chk/chk.py` (exact `Fraction`) reproduces `check/counterexample.json`:
- s = 10.001, e = 0, so b = 10.001 > ack(C) = 10.0007, and C is missing.
- With q = 0.001, b = 10.000 ≤ g = 10.0004.

The local sentence lists three conditions, and the story meets all of them. But the sentence says "can supply b=s−e **only with** evidence that …", which states necessary conditions, not sufficient ones. Its next sentence says "The earlier-acknowledgement implication is the certificate". The package also says "A bound without valid evidence is unknown".

So the story's b breaks the overarching MUST. No reading of E-KEEP *permits* it. The gap is that the local recipe is jointly insufficient but reads like a complete recipe.

**No existing definition settles precision.** I searched the normative files for clock-error, skew, precision, quantization, rounding and millisecond/microsecond wording.
- `API-53` ("clock reads tie at millisecond resolution") and `WIR-1` ("at second precision") are about the API and the wire. Neither defines e for this source.
- astra.md:74, sol.md:122 and tally-claim-audit.md:33 show the panel meant to cover rounding, but they are explanations, not requirements.

The Manager's finding stands.

## 2. Rounding cases (resolution r, using the quantities above)

| case | allowance actually needed | E-KEEP (MUST governs) | E-TOTAL (natural two-sided reading) | E-SPLIT |
|---|---|---|---|---|
| floor / truncation (post-epoch) | e | b = s − e valid with floor evidence | e ≥ e_clk + r: **tighter valid b disallowed** | q = 0 only with evidence; b = s − e |
| nearest | e + r/2 | e must absorb r/2 | same | q = r/2 |
| ceiling | e + r | e must absorb r | same | q = r |
| coarse capture (e.g. a second-precision rendering) | e + up to 1 s | same | same | q up to 1 s |
| perfect clock, e = 0 | q | literal recipe gives b = s, which the MUST forbids | b = s − r | b = s − q |
| precision evidence missing or invalid | — | unknown | unknown | unknown |

The same outcomes hold in every column:
- "Missing reporting evidence does not hold incident creation".
- Continuations reuse the persisted values.
- A larger subtraction only moves b earlier, so it cannot break b ≤ f.
- s, e and q must share the source clock's units and real-time frame.

**Asymmetric clock evidence (E-SPLIT's narrowing).** Suppose the clock reads between g − M and g + a with M ≥ a + q, and "e bounds the source clock's error" is read as a two-sided magnitude bound.
- E-KEEP allows b = s − M: e = M bounds the error, and the certificate holds because M ≥ a + q.
- E-SPLIT's equation forces b = s − M − q.

With M = 0.005, a = 0.001, q = 0.001, `chk.py` gives s − 0.005 against s − 0.006. That is one valid, tighter E-KEEP outcome that E-SPLIT disallows. With symmetric clock evidence, or a one-sided reading of "error", the two are identical.

**E-TOTAL's reference event is not stated.** "the source timestamp's total error" does not say what the error is measured against. Measured against R's acknowledgement, the result is unsound:
- s = 10.001, ack(R) = 10.0012, e = |s − ack(R)| = 0.0002.
- That gives b = 10.0008 > ins(R) = 10.0005, while ack(C) = 10.0007 < b.

The sentence's "generated before insertion" points toward generation, but it does not fix the reference. That alone justifies AMEND.

## 3. Classification

- **E-TOTAL: BEHAVIOUR-CHANGE.** The quoted reason is "e bounds the source timestamp's total error, including … timestamp precision". Precision is a width, not a direction, so floor representation now has to charge r.
  - The floor-case b = s − e is valid under E-KEEP's certificate with evidence of floor representation. E-TOTAL disallows it.
  - If the direction is evidenced but the resolution is not, E-TOTAL turns a known b into unknown.
  - It permits no false outcome under the generation reference, but its missing reference permits an unsound reading (§2).
- **E-SPLIT: BEHAVIOUR-CHANGE (narrow, conservative).** It is sound: s − e − q ≤ c(g) − e ≤ g. Every E-SPLIT outcome is valid under E-KEEP (take e′ = e + q).
  - The reverse fails in the asymmetric case above, so the printed equation "b=s−e−q" disallows a valid outcome. That makes it an admissible-input restriction, not editorial.
  - The cost is at most q of tightness, and only under asymmetric clock evidence.
  - It adds no hold, no conformance assertion, no proof hypothesis and no fixed precision. "No default q=0" matches "No unvalidated finite error value may be silently assumed".

## 4. Collisions and adjacent issues (all three candidates, unchanged; flagged, not repaired)

- **OVR-19.** "rows for source/event clock-error evidence and the endpoint capture, validation and retention procedure". E-SPLIT's q has no named row of its own. It fits under "capture, validation" and "identify clock/provenance assumptions". This drift does not block. E-TOTAL redefines e as total error while OVR-19 and "Source and event clocks may have different error bounds; record their provenance" still call it a clock bound. That is a naming mismatch, and it does not block either.
- **The f side mirrors the b side.** f = restore_instant + e_event requires f ≥ the transaction's real start. A floor-rounded or truncated restore_instant moves that the wrong way, and "upper error bound on the incident transaction's event clock" names only the clock. "A non-null f MUST certify …" still governs, as on the b side.
  - Making only b explicit (E-TOTAL, E-SPLIT) invites a reading that f needs no representation allowance.
  - This needs its own reviewed question. It does not block any candidate, because none changes the f side.
- **Persisted or published representation of b and f.** If the column or report precision rounds b up, or f down, the certificate fails after a correct computation. No candidate addresses this; the MUST still binds the stored values.
- **CNF-365.** "verified prefix/clock evidence and assert the incident stores certified bounds" would pass a clock-only implementation under upward rounding in every candidate. This is a coverage note, not a contradiction (rule 3).
- **Formal.** No candidate changes the formal model: `Restore.lean`'s scope keeps "the published window" out of the model, and the package states "Interval/certificate publication remains outside this model's scope". No CNF identifier and no theorem change.

## 5. AMEND for E-TOTAL (unreviewed; equivalent to E-MIN below)

Path: `check/E-TOTAL.md:13`, the prospective STO-54 insertion, first sentence.
- Before: `only with evidence that e bounds the source timestamp's total error, including source-clock error and timestamp precision, quantization and rounding, the timestamp was generated before insertion, and`
- After: `only with evidence that e bounds the source clock's error, the timestamp was generated before insertion, s−e is no later than the real instant of that insertion even where precision, quantization or rounding placed s after the source clock's reading, and`

Behaviour compared with printed E-TOTAL: **changed**. It restores the floor-case b and removes the unanchored reading. Compared with E-KEEP: **unchanged** (claimed below).

## 6. The cheaper third form the brief requests: E-MIN (an AMEND-form proposal; one seat's, unreviewed)

My E-KEEP vote is an unconditional ACCEPT. E-MIN is not a condition on it.

Path: STO-54 insertion, application brief line 51, first sentence; `check/E-KEEP.md:13`. Replace that sentence with:

> The last replayed commit-or-abort record's timestamp s can supply b=s−e only with evidence that e bounds the source clock's error, the timestamp was generated before insertion, s−e is no later than the real instant of that insertion even where precision, quantization or rounding placed s after the source clock's reading, and the recovered continuous prefix on matching ancestry contains that complete record.

Every other sentence and instruction stays byte-identical.

**Classification: WORDING-REPAIR (claimed).**
- **Sufficiency (§1).** If b ≤ ins(R), any commit acknowledged before b was inserted before R. It is therefore inside the prefix that "contains that complete record".
- **Necessity.** R is "The last replayed commit-or-abort record", so no commit record inserted after R was replayed. If b > ins(R), a commit inserted and acknowledged inside (ins(R), b) would be missing. The s-path's evidence (clock bound, generation before insertion, prefix inclusion) cannot exclude such a commit. Under E-KEEP the s-path therefore certifies b only when s−e ≤ ins(R) is evidenced, which is E-MIN's clause.
- So E-MIN's admissible set equals E-KEEP's s-path set, including the floor case and the asymmetric case.
- It adds no quantity, no equation change, no OVR-19 row, no hold and no test.

## Counterarguments (requested; not votes)

- **For keeping the adopted wording.** "only with" plus "The earlier-acknowledgement implication is the certificate" plus "A bound without valid evidence is unknown" already forbid the story's b.
  - Every explicit repair either fixes an equation that narrows valid outcomes (E-SPLIT, E-TOTAL) or restates the MUST.
  - **Strongest point:** making only the b side explicit invites an a-contrario reading that f, "restore_instant+e_event", needs no allowance for downward representation (§4). That applies to E-TOTAL, E-SPLIT and E-MIN alike. E-KEEP leaves both endpoints under their symmetric MUSTs.
  - The owner approved UO "as written" with the one repair only.
  - This argument does not stretch as far as AGENTS.md's "re-explaining a rule in a second document". Every repair sits in the rule's own paragraph, so none creates a second copy.
- **For the smallest explicit repair.** The recipe sentence is the one an implementer computes from. CNF-365's "prefix/clock evidence" would not catch a clock-only b.
  - A spec that is correct only through a following sentence fails exactly as AGENTS.md records local paraphrases failing.
  - E-MIN closes that trap without changing a single admissible outcome, so it needs no owner choice.

## Brief consistency

I found no contradiction. "A verified total allowance of at least 0.0006" puts b at or before generation, which is sufficient. An allowance of 0.0005 already reaches ins(R), but the brief claims only sufficiency, so this is not an error. 05:1656 is now at line 1660, and the brief keeps historical line numbers by design. No vote rests on a brief error.

## Final

| candidate | vote | classification |
|---|---|---|
| E-KEEP | ACCEPT | baseline (no repair) |
| E-TOTAL | AMEND (§5; behaviour changed vs printed) | BEHAVIOUR-CHANGE |
| E-SPLIT | ACCEPT | BEHAVIOUR-CHANGE (narrow, conservative) |
| E-MIN (unreviewed AMEND) | — | WORDING-REPAIR (claimed) |

**Preference: E-KEEP.** It is safe under the governing MUSTs and stays within the owner's UO decision. It narrows no outcome and leaves no a-contrario reading on f. Its q-free evidence fits OVR-19's rows as printed.

E-SPLIT is sound and acceptable, but it is a narrow behaviour change that would need the owner. It makes only b explicit, and its q has no OVR-19 row of its own. Those costs outweigh what its explicit recipe buys.

E-MIN is unreviewed, and so is the f-side question. No panel majority authorizes the narrowing.
