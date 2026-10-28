# r79 D0 — fable (claude-fable-5-1, xhigh) — pv-3jw6 source timestamp error bound

Pin `3c214c147021a90d4ba5a74269b8bd4adc389670`, own detached clone. Final text is saved at `/var/tmp/provisiond-panel-r79/fable.draft.md` (sha256 `0230d25b…`). Verified myself: E-KEEP.md is byte-identical to `decisions/pv-3jw6.md:39–97`; E-TOTAL and E-SPLIT differ from it in exactly one line each, the first sentence of package line 51; bead comment 835 equals the committed Agent Brief; `q2-UO.md:17` holds the targeted sentence; the counterexample reproduces in exact rationals. Nothing was committed, no tracker was touched, no other folder was read or written.

## Votes

| Candidate | Vote | Classification of the edit |
|---|---|---|
| E-KEEP | **AMEND**, behaviour unchanged: replace line 51's first sentence with E-SPLIT's sentence or the one-symbol variant below | no edit; keeps a route whose named evidence does not entail the MUST it serves |
| E-TOTAL | **AMEND**, behaviour unchanged, exact replacement below | WORDING-REPAIR in intent; as printed "total error" is a two-sided magnitude with no reference event |
| E-SPLIT | **ACCEPT** as printed | WORDING-REPAIR within the owner's UO decision |

**Preference: E-SPLIT.** It is the only printed candidate whose named evidence is exactly the inequality the certificate needs. Nothing here authorizes adoption; a repaired E-TOTAL or my one-symbol variant needs its own read.

## Q1: the certificate inequality and the gap

Let g be the real instant the source generated R's timestamp, s the value actually used, and ins(R) ≥ g by "the timestamp was generated before insertion". A commit C acknowledged at real time t < g was inserted before t, hence before R, hence earlier in the WAL; a continuous prefix on matching ancestry that holds complete R holds C. So line 49's MUST, "A non-null b MUST certify that every source-history component commit acknowledged before b belongs to recovered committed history", holds for **every b ≤ g**, and b = s − e satisfies it exactly when **s − g ≤ e**. The quantity e must bound is the upward excess of s over g: one-sided, relative to the generation instant. That excess is clock error plus representation. Line 51 names only the first: "e bounds the source clock's error".

**Failure story:** consistent with the quoted package. All three named conditions of line 51 hold with e = 0, b = 10.001, and C acknowledged at 10.0007 is missing, so line 49 is violated. The minimal allowance is s − g = 0.0006, giving b = g, which the proof covers. So a false finite certificate was never permitted by the MUST, and the local recipe, followed as the route it is presented as, produces exactly that certificate. The gap is in the recipe, not the MUST.

**No existing definition resolves it.** Normative files define no e, CONTEXT.md has no clock vocabulary, and the only rounding rules are the ledger's satoshi rules under `LDG-28`. The wire contract fixes second precision for the wire only. `04-api-contract.md:1288` notes that clock reads "tie at millisecond resolution and step backwards under NTP" without an allowance. `Claim.lean:132` lists "timestamp precision" among assumptions "not proved here". The package's OVR-19 row is named "source/event clock-error evidence". The r76 notes from astra, sol and the claim audit are review intent that was never imported. Grammatically line 51's "only with evidence that" states necessary conditions, and the next sentence makes the implication the certificate, so E-KEEP is not false. It is the package's one worked route, and its named quantity is the wrong one.

**Provenance.** s is whatever the deployment captures. A PostgreSQL commit record carries an int64 microsecond value, which truncates downward, but a capture through a monitoring export or coarse text rendering can round to nearest or up. The representation term must be evidenced on the captured s. "Verified downward-only" is evidence a deployment supplies, not a fact the specification may assume.

## Candidate checks

Common to all three: the unknown contract, continuation reuse, the no-hold sentence, the f sentence, schema, CNF text and formal scope are byte-identical. None adds a startup hold, admissible-input restriction, conformance assertion or proof hypothesis. b only moves earlier under the repairs, so b ≤ f is preserved, and inconsistent evidence still routes to "report the error and unknown bounds". q is stated "finite nonnegative"; e is finite because "Known b and f MUST be finite".

| Case | E-KEEP | E-TOTAL | E-SPLIT |
|---|---|---|---|
| upward rounding | b > g, MUST violated | covered | covered by q |
| downward truncation | fine by itself | over-conservative by one unit if read as magnitude | q = 0 with evidence, same b as E-KEEP |
| nearest or coarse precision | fails by up to half a unit | covered | covered |
| perfect clock, e = 0 | the counterexample | fine | fine |
| precision evidence missing or invalid | not asked for; silent assumption possible | b unknown, no hold | b unknown, no hold |
| error sign and reference event | clock two-sided, implicit | unstated | e two-sided, q one-sided from the reading, reference stated |

## Classification

**E-SPLIT: WORDING-REPAIR.** Line 49 already requires the certificate, and line 69 already says "No unvalidated finite error value may be silently assumed." E-SPLIT names the second component the inequality needs. No MUST-valid outcome is disallowed, since a known-downward representation evidences q = 0 and recovers E-KEEP's b. No outcome is newly permitted, since the MUST always accepted any b ≤ g and the clock-only b in the upward case was never valid. Disclosed: one additional evidenced quantity in the evidence reference and the OVR-19 procedure, and a changed printed equation. No payload, assertion, fixture restriction, hold or hypothesis.

**E-TOTAL: WORDING-REPAIR in intent, AMEND as printed.** "Bounds the source timestamp's total error" is by ordinary reading a magnitude bound and names no reference event. In the known-downward case it moves the route to b = s − e_clock − one unit, where b = s − e_clock was MUST-valid. The MUST still admits the latter by an independent inclusion proof, so the package forbids nothing, but the route is needlessly conservative and ambiguous.

**E-KEEP: no edit, AMEND.** Not CANNOT ACCEPT: no CNF assertion or Lean theorem changes and the MUST forbids the false result. The substantive objection is that the only worked route names an insufficient quantity and the OVR-19 label repeats it.

## Adjacent, flagged and not repaired

1. **Symmetric gap on f.** Line 53 supplies f = restore_instant + e_event from "a verified upper error bound on the incident transaction's event clock". f must be at or after the real transaction start; a downward truncation or slow clock makes the representation read early, so e_event must cover the downward excess including representation. Unchanged in all candidates. Not blocking: f's MUST binds identically and the unknown path applies.
2. **OVR-19 label.** Line 69's "source/event clock-error evidence" does not name representation. STO-54 owns the meaning, so not blocking, but an applier must not silently reword line 69.
3. **Formal.** No CNF identifier in `tools/formal/`; no theorem touched. `RestoreTrace.store` at Restore.lean:164–168, `afterCrash` at 435–437, `bootRestore` at 541 and `step_three_writes_grace` at 548 are unchanged under all candidates.
4. **Pre-existing anchor drift.** The package's "At 05:1656" sentence sits at `05-persistence.md:1659–1660` at this pin. Line 114's fresh-master anchor check already covers it. Not a premise error; no vote rests on it.

## Exact repairs

Location for both: the first sentence of package line 51, in `docs/research/panels-2026-10/r74/decisions/pv-3jw6.md:51` and bead comment 835, landing in the STO-54 insertion after `05-persistence.md:1562` and before step (1). The archived `q2-UO.md:17` stays verbatim.

**AMEND E-KEEP → E-SPLIT's sentence.** Before: the E-KEEP sentence. After: the E-SPLIT sentence exactly as printed in check/E-SPLIT.md. Behaviour unchanged, as classified above. The result is byte-identical to E-SPLIT.

**AMEND E-TOTAL, one-symbol variant. My synthesis, unreviewed.** Before:

> The last replayed commit-or-abort record's timestamp s can supply b=s−e only with evidence that e bounds the source timestamp's total error, including source-clock error and timestamp precision, quantization and rounding, the timestamp was generated before insertion, and the recovered continuous prefix on matching ancestry contains that complete record.

After:

> The last replayed commit-or-abort record's timestamp s can supply b=s−e only with evidence that e bounds the source clock's error plus any upward difference between s and that clock's reading at timestamp generation introduced by precision, representation, quantization or rounding, the timestamp was generated before insertion, and the recovered continuous prefix on matching ancestry contains that complete record.

Behaviour unchanged, by the same argument as E-SPLIT: one-sided representation term, reference event stated, no newly permitted or disallowed MUST-valid outcome, no hold or assertion. It folds q into e: one symbol, no equation change, and the OVR-19 label stays nearer the truth. It is adequate and cheaper, and it is not reviewed because I wrote it.

## Counterarguments, requested, not votes

**For keeping E-KEEP.** "Only with evidence that" lists necessary conditions and the next sentence makes the implication the certificate. Line 69 already forbids silently assuming any finite error value, and representation error is an error value. The dominant source, an int64 microsecond commit timestamp, truncates downward, so q = 0 in practice. The package was accepted 4–0 and owner-approved, and every wording touch costs a round while the bead sits ready.

**For the smallest explicit repair.** The one-symbol variant makes the route's single quantity exactly the one the inequality needs, with no second variable, no equation change and no pressure to relabel OVR-19. E-SPLIT's extra symbol buys only that q = 0 is shown separately rather than inside e.

## Brief and rules consistency

No contradiction found between notes.md, the brief's scope and the answer criteria. Rule 6 applied as written: no premise error. Non-premise observations: the "05:1656" anchor drift, and the brief's "at least 0.0006" is exactly s − g and yields b = g, which the proof covers. The grok MCP server failed to connect in my unit, which is irrelevant to this seat.

## Final table

| Candidate | Verdict | Behaviour mark of the edit |
|---|---|---|
| E-KEEP | AMEND → E-SPLIT's sentence or the one-symbol variant | no edit; route mis-describes the certified quantity |
| E-TOTAL | AMEND, exact replacement above | WORDING-REPAIR in intent; as printed over-conservative and unreferenced |
| E-SPLIT | ACCEPT | WORDING-REPAIR within UO |

**Preference: E-SPLIT.** Classification verdicts: E-SPLIT WORDING-REPAIR; E-TOTAL WORDING-REPAIR with a defect, AMEND; E-KEEP no edit. No panel majority authorizes a new owner policy. All three keep the owner's "Record the window when it's proven; otherwise record 'unknown' with the reason and let recovery proceed."
