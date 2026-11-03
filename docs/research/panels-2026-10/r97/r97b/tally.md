# Panel R r97b — final consensus tally, no settlement

Pin M=`2e2cd94637112f20538eb26b141672fedf0ba455`; approved C′ pin O=`3109b5b44eae17e288cf52aaa976993bd8c5626c`. Both origin/master and pv-9ecf are still M. No moved-ref stop applies. This new tally supersedes the launch-status descriptions for the result; STATE.md remains unchanged because this turn's write fence excludes it.

**apply notes.md rule 6 exactly as written; this prompt adds no void rule.**

Q2d, Q2e and Q4 each remain split 2–1 on final preference after the sole consensus round. No question settles. Three agreements remain necessary with Grok and Fable missing. All present readers accept both alternatives in each split; notes rule 2 requires preserving explicit preferences where multiple forms qualify, without an invented tie-break. r97 already used that distinction. Acceptance does not select one here. No new synthesized form is proposed. The next step is two owner questions, combining Q2d/e because they split the same way; **there is no r97c**.

## Actual seats

| Reader | Exit / bytes | Classification |
|---|---|---|
| Fable | 1 / 158 | Missing: “You've reached your Fable limit.” |
| Opus | 0 / 7944 | Substantive |
| Astra | 0 / 7616 | Substantive |
| Sol | 0 / 6903 | Substantive |
| Grok | No full reader | Missing: recorded preflight HTTP 402 Payment Required |

All final answers and diagnostics were read. Answer SHA receipts and diagnostic hashes are in check/r97b-verification.json. Codex stdout matches the final answer except terminal LF. Earlier preparation acknowledgements under check/nonvoting-first-launch are not votes. The manifest's answer hashes refer to the original r97 answers embedded verbatim, not these new r97b answers; those hashes and the current brief/notes hashes match.

## Final preference, strongest argument and conditions

| Question | Reader | Pick | Strongest argument; conditions |
|---|---|---|---|
| Q2d | Fable | MISSING | Limit line; no vote |
| Q2d | Opus | Q-KEEP | Own prospective “create MUST reject” identifies the wire-owned field; no compliance defect requiring changed approved bytes. POINTER accepted; QUOTE rejected as awkward/misplaced, not a rule-3 loss |
| Q2d | Astra | Q-KEEP | Existing ownership identification is adequate; changes from r97 POINTER after accepting the other side's function argument. POINTER/QUOTE also accepted |
| Q2d | Sol | Q-POINTER | Explicit “wire owner: `WIR-17`” makes the pointer clearer; changes from r97 KEEP. KEEP's non-application is established; KEEP/QUOTE accepted |
| Q2d | Grok | MISSING | HTTP 402; no vote |
| Q2e | Fable | MISSING | Limit line; no vote |
| Q2e | Opus | Q-KEEP | Own carry MUST already says “which the wire contract owns”; no need to replace that clause with a label. POINTER accepted; QUOTE rejected editorially |
| Q2e | Astra | Q-KEEP | The ownership clause already communicates the field's home; cumulative authorizations retained. Changes from r97 POINTER; POINTER/QUOTE accepted |
| Q2e | Sol | Q-POINTER | Explicit owner label clarifies the same function while retaining both authorizations. Changes from r97 KEEP; KEEP/QUOTE accepted |
| Q2e | Grok | MISSING | HTTP 402; no vote |
| Q4 | Fable | MISSING | Limit line; no vote |
| Q4 | Opus | L-NOTE | Qualification beside the old executable-looking form follows landed r96 precedent and warns against restoring the old CNF-34. Changes from r97 BRIEF; exact appendix only, no duplicate note; BRIEF accepted |
| Q4 | Astra | L-NOTE | Local qualification separates approval from execution; acknowledges changed whole-file hash, historical equality failure and rules-file link. Exact supplied appendix only, no duplicate note; BRIEF accepted |
| Q4 | Sol | L-BRIEF | Corrected authority/history labels plus the r97 archive suffice, while preserving both original archive hashes and recorded equality. Changes from r97 NOTE; exact NOTE accepted with its disclosed costs |
| Q4 | Grok | MISSING | HTTP 402; no vote |

## Acceptability remains distinct

| Exact form | First picks | ACCEPT | CANNOT ACCEPT |
|---|---|---|---|
| Q2d KEEP | Opus, Astra | Opus, Astra, Sol | — |
| Q2d POINTER | Sol | Opus, Astra, Sol | — |
| Q2d QUOTE | — | Astra, Sol | Opus |
| Q2e KEEP | Opus, Astra | Opus, Astra, Sol | — |
| Q2e POINTER | Sol | Opus, Astra, Sol | — |
| Q2e QUOTE | — | Astra, Sol | Opus |
| Q4 NOTE + exact supplied appendix, no duplicate note | Opus, Astra | Opus, Astra, Sol | — |
| Q4 BRIEF | Sol | Opus, Astra, Sol | — |

Each present reader accepts authority-replacement.txt. NOTE means exactly the 695-byte supplied appendix, dated 2026-11-02; no date/link repair, added duplicate note or other synthesis is included. Requested contrary arguments are not votes. Every pick separately receives WORDING-ONLY classifications for behavior, items 4+24/C′ requirements/meaning, and check strength. Independent verification agrees for both alternatives in each split; this does not create a missing third final preference.

## Verification, dissent and rule 6

Detailed evidence: check/wording-verification.md; executable raw-byte checks: check/r97b-verify-inherited.py and check/build-owner-options.py; receipts: check/r97b-inherited-verification.json and check/r97b-verification.json. Both original forms match approved SHA `be350270318a2752992a9cb199a2a56879249be99f36e7af430bcfe8a1d47a32` and comment 861 embeds that form. AGENTS.md 29–32 and 45–46 are checked directly at M. The complete source/summary/assertion inventory is r97/check/tally-evidence.md, explicitly rechecked here against the pin. The newly supplied exact quotation bytes match M or historical 7116e90 (verified as b278433's parent). Every prospective brief is reconstructed from M's comment text with only the supplied substitutions; inverse substitutions restore the pinned bytes exactly. All historical Current behavior text remains unchanged.

KEEP/POINTER retain paid-create scope, explicit top-level acknowledgement, wire ownership, account opt-in and cumulative authorizations, including PRV-10's “Both, not either.” and API-15's “in addition to”. The writing-rule distinction follows AGENTS' “One rule, one home; everywhere else points at it.”, rather than an inheritance or lexical-gate exemption. No extra owner question is needed for substantive scope: the choice is wording only.

Sol's lone Q4 dissent is verified in full: the archive receipt names the original complete-file SHA, the validator contains “actual==original.read_bytes()”, and NOTE changes one file to `ebf5de10cdebba5297239ac528d6c81c61f86e5e15e7baff97f9cb5c4ae0928d` while its duplicate stays original. Replaying that comparison against the new files would fail. The historical validator actually uses external /var/tmp paths; it is not invoked by CI or check-all. NOTE's original bytes stay an exact prefix. Its link points to r97/notes.md (rules, not selected replacements), and r97 must be archived; the corrected brief carries the actual execution text. These costs were disclosed in the packet. The landed r96 adjacent note and notes.md link exist at M. Neither choice changes a normative obligation, implementation conformance assertion, Lean theorem or negative control.

Verified false current-reader claim: Opus says “Every gate reads only root *.md and docs/adr/*.md”. Formal builds read Lean; citations also reads Lean docstrings. The relevant narrower claim is true: the gates exclude research archives and do not invoke the historical archive validator. This overstatement does not change the premise or require voiding a vote. All readers' relevant preservation claims were checked, not inferred from green gates. No current reader claims a rule-3 blocking loss.

Other non-void qualifications are preserved: NOTE's reviewed date is 2026-11-02 although r97b concludes on 2026-11-03; no r97 archive yet exists at M; the note links rules rather than selected text; the old drift table compares 832a219 rather than M; comment 861's historical quote has an external consistency link where the archived source uses a pinned permalink. No open preference rests on a false whole-paragraph byte-identity claim, invented hourly-block provenance or outdated retention table. These do not change the question's premise. **Rule 6 voids no question.**

Current CNF-34 remains exactly M, retaining PR60's complete insertion. All its separate-create/install/error-view/settlement assertions remain, as do CNF-342's “complete, valid resource-offer” domain, unconditional wire acknowledgement, complete CNF-55/hourly payload, original exclusion/low-balance/replay/worker checks and CNF-364's authorizations and gate demonstration. No retained block or runtime fixture is weakened, no Lean declaration/guard/proof is changed, and nothing beyond items 4 and 24 is added to pv-9ecf. Original approval material is historical comparison, not a restoration instruction.

## Exact options ready for the owner's answers

check/owner-option-index.md maps the two independent answers to the complete prospective settled-pv-9ecf.md text in each file below. Each option includes the exact decoded comment, executable handoff, pinned line targets, selected landing directive and exact archive appendix/result when applicable. Companion brief/form/archive files and diffs against M are in check/. The four combinations merely assemble independently reviewed exact substitutions; no new wording choice is synthesized or selected. The corrected brief, not an old copied form, must instruct the Run. None is adopted by this turn.

| Full prospective option file | SHA-256 |
|---|---|
| keep-note | `51422fb0b6fc0abe4a34283478ca0d7ed56a9459012ee7e50fb1770f88d10817` |
| keep-brief | `737bc476ab51ff86cbf3e59be040b755469c8a2bf758feacfb2dba649b14455d` |
| pointer-note | `9e29052bd31cf8a607a967fd971b70181d1f4b1274b998fb46c002416a81c276` |
| pointer-brief | `6f11fbaf5bebbf5a75f516caaa5581ae5839b624d3a1e3da497a46c6751a2fe7` |

No root settled-pv-9ecf.md, hash or final prospective-agent-brief/archive is issued because the all-questions-settled condition is false. The existing root r97 answers/tally/check remain unchanged. Nothing is written to the real tracker, branch, bead, main checkout, other panels or pre-existing units. No br, push, provider request, model reviewer call or Run is started. The only units started by this tally are its capped baseline/final gates in its own check/tally-repo; no other unit is altered.

## Owner questions, quoted whole

Both field phrasings preserve the rule; readers split over clearer ownership. **Keep both approved field phrases, or make their ownership explicit?** **Keep the approved phrases (Recommended)** (Opus, Astra); **Make field ownership explicit** (Sol).
Both archive choices preserve meaning; readers split over a local warning. **Add the dated archive note, or change the brief only?** **Add dated archive note (Recommended)** (Opus, Astra); **Change the brief only** (Sol).
Opus: KEEP/KEEP—each states its own rule and points to the field’s home; NOTE—warn beside the old form, following precedent. Verified false: his claim that every gate reads only root Markdown/ADRs; gates also read Lean, but exclude research archives.
Astra: KEEP/KEEP—ownership already clear; NOTE—qualify execution beside approval, accepting the changed hash and historical equality result.
Sol: POINTER/POINTER—explicit ownership is clearer; BRIEF—preserve both archive hashes. All accept both alternatives; Fable limit and Grok 402 are missing. IDs: pv-9ecf, items 4 and 24, /var/tmp/provisiond-panel-r97/r97b/.

## Gates and next step

Both full unpiped `nix develop --command bash tools/check-all.sh` invocations passed 0/0 in this turn’s own check/tally-repo, detached at M. The shell and formal toolchain were required, with complete redirected logs and actual exit codes. Baseline admission observed one other host lake build; final admission observed zero. Each invocation was capped at MemoryMax=16G, MemorySwapMax=0, OOMPolicy=continue with null stdin; launch cap receipts are in check/tally-gate-*-caps.txt. These are baseline-source gates, not evidence that prospective implementation conformance fixtures ran. Final refs remain M/M. Readable quotas: Claude all-models week 85%, Current session absent (no hold), Fable 100% exempt; Codex active proton 45%. No non-exempt reading exceeds 95%, and Codex is below 100%.

Fixed context stays r97's Q1 R-MASTER, Q2a/b/c Q-QUOTE, Q3 S-OUT. Next: main asks the two questions above, one at a time. After both answers, use the matching exact option, then an apply turn makes the preparation commit on branch pv-9ecf, followed by the Run turn. No r97c, automatic settlement, owner scope change or tracker adoption by this turn.
