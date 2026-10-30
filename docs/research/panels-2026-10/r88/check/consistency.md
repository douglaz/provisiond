**Result:** I found one contradiction inside a candidate form and two small inconsistencies in the notes. Everything else I checked agrees.

### 1. C-WITNESS's rule and its own drill disagree

The owner form only requires a record of what *might* happen:
> "it MUST obtain acknowledgement of an independently durable intent record identifying the affected incarnation and the possible waiting-backend effect."

It also says such a record can't settle the question:
> "an unclosed intent or an unsupported operator assertion cannot establish it"
> "With no known disqualifying condition, missing, failed, invalid, conflicting or incomplete historical evidence makes restart eligibility unknown."

The check form expects a *known* event to come out of those same records:
> "retain the authentic off-primary records and require the procedure itself to discover the fact through those records. Assert restore classification and no automatic promotion"

Nothing in the owner form requires any record to say that a waiting backend was actually cancelled or terminated. A deployment that keeps only intent records would get "unknown eligibility" in fixtures (a) and (b), not a known restore, so it fails the drill while following the rule. The practical result is the same either way: no automatic promotion, then an operator restore. The classification differs, though, and C-UNKNOWN's check treats that difference as testable: "Do not … label its unknown state as a known violation."

**Minimal correction (pick one):**
- **Owner form:** after "…possible waiting-backend effect." add: "When a cancellation or termination affects a waiting backend, the deployment MUST durably record that outcome under the same requirements."
- **Check form:** replace "Assert restore classification and no automatic promotion" with: "Assert restore classification where the records establish the event, otherwise unknown eligibility; in either case no automatic promotion and an operator notice."

Either fix changes what C-WITNESS requires, so the result is a new candidate that readers must review. It is not an editorial repair.

### 2. Notes: temp directory vs. allowed write location

> "TMPDIR is this panel's tmp"

vs.

> "write temporary checks only to this panel's tmp/<seat>" (brief: "only under `/var/tmp/provisiond-panel-r88/tmp/<your-seat>/`")

Temp files that tools create automatically would land in the shared `tmp/`, outside every seat's directory, and all seats would share it.
**Correction:** set each unit's TMPDIR to `tmp/<seat>`.

### 3. Notes: "majority" vs. rule 2

> "A majority can settle exact-form technical acceptability for later relay"

vs. rule 2:

> "at least three agree and more agree than disagree … If grok is down, it falls back to three of four"

With four seats these agree. If a seat drops after launch (rule 5: such outputs "are not votes"), 2 of 3 is a majority but doesn't meet rule 2.
**Correction:** change it to "Settlement under rule 2 can settle exact-form technical acceptability…".

### Checked, no contradiction found

- **NEITHER is a true no-change option.** Its printed owner and check blocks are byte-identical to the pinned `05-persistence.md:1652–1669` and `10-conformance-checklist.md:1184–1220` (`diff` showed no differences). So its "replace" instruction changes nothing, consistent with "No file changes." I did not diff the unchanged base text inside the C-WITNESS and C-UNKNOWN blocks.
- **Line references.** These all point to the quoted text:
  - `STO-7`: 179–209, 188, 205–206 and 232–243.
  - `STO-54`: 1654, 1664–1669, 1671–1691, 1693–1734 and 1731–1733.
  - Audit: 330–380, 371–380, 673–747 and 693–696.

  "No stated expiry or catch-up reset" sits on line 371, inside the cited 371–373. I spot-checked phrases rather than diffing every verbatim block.
- **Bead `pv-by1w`:** it is open, P3 and labelled `needs-triage`, and both quoted sentences are present. "File one triage bead (Recommended)" isn't in the bead record, but the brief attributes those words to the owner, not the bead.
- **Freshness:** since `c7be186`, `git diff` shows no changes to `05-persistence.md` or the audit. The checklist changes fall outside CNF-365, which supports "Later checklist edits were in other items."
- **Fixed boundaries vs. both candidates' wording:**
  - no expiry from elapsed time, catch-up or a new incarnation
  - unknown loss-report endpoints don't hold a restore
  - the operator-only restore boundary
  - the equal-report restart path is kept
  - no drift controller
  - a shutdown-caused termination can be a known restore condition

  Both candidates' text agrees with all of these. The only gap is item 1.
- **Notes vs. brief on authority:** they agree. Only the panel is approved, nothing is adopted, the wording exception doesn't apply, and the rule-6 sentence appears exactly as the notes require.
