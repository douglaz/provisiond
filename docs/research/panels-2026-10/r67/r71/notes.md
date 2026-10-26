# r71 notes (panel E: one whole-form preservation candidate). 2026-10-26

Outcome rules fixed before launch. Base and clones: `c5f897c32f7894d77a544528872176f241394d0d`.
Shared brief: `docs/research/panels-2026-10/r67/r71/brief.md` (28,418 bytes). Reuse r70/tally.md's verified
findings; do not re-verify them. This session prepares and launches only; it does not tally or run rloop.

## Settled (not re-voted)

Owner ruling recorded in `/var/tmp/provisiond-manager/owner-q1-sync-2026-10-23.md`: Q1 pv-tcs
**Stored listing (Recommended)**; Q2 pv-ytv **K1–K6 and K-d (Recommended)**, exactly the original r69
K-d at brief.md:361–362, without the later fixture AMEND. Q2 needs no further read.

Main's 2026-10-26 reading of the recorded specification settles r70 precedence as **PRESERVATION**,
subject to the owner's overrule. CNF-278, c5f897c 10:2789–2792, includes "a create naming it is `409`
`state`" and "Assert the refusal on **all three** unhealthy statuses"; CNF-307 10:1225–1226 includes
"termination makes the envelope `retryable: false`". Complete source context is in brief.md. The owner's
stored-listing ruling did not ask to change those checks. Target: every CNF-278 and CNF-307 verdict at
c5f897c stays unchanged under the repaired form. Stop on a later overrule note from main.

## Exact candidate and authorship

The whole S1–S6 is an **unreviewed combined candidate**. Source: r70 brief.md/parts/candidate.json.
Reader texts stay reader texts; combining them is not a whole-form approval.

- Inherited reader text: original S1, S3–S5 and original S6, sol (archived Reader 4). S2's exact DOM-9
  row is common astra/sol (Readers 3/4); its caller sentence is opus (Reader 2). S6 retains archived
  Reader 4/sol's coverage append. Timing, credential-stop scope and explicit engine-process placement
  stay intact. r70's assembly is reused byte for byte except for the three edits below.
- New reader replacements: opus's exact S1 and S6 text at r70 tally.md:75–97. S1's pre-tail freshness
  refusal is healthy-only; S6's stale fixture explicitly healthy. These change r70 behaviour.
- New coordinator text, S1c, after that S1 replacement: **For an account whose status in that snapshot
  is not `healthy`, the tail reads its stored listing regardless of age, or an empty offers set if no
  listing is stored.** This alone completes the missing source definition. No new coordinator S6 text,
  CNF-278/CNF-307 narrowing, other S option, placement replacement or Q2 repair is imported.

Absent row => empty set => existing offer refusal follows state; a stale row is used as-is, so a
present sellable offer produces no age-generated offer refusal. Source: API-7's whole absence and
ordering clauses in brief.md and check/traces.md. The traces distinguish an empty-source unsellable
combination from a sellable singleton account fault and ask the panel to challenge that distinction.

## Outcome rules (r63 rules 1-7 form; rule 3 = the gate)

There is one question: the complete S1–S6 candidate under the owner's stored-listing direction.
1. Each reader votes ACCEPT, AMEND or CANNOT ACCEPT on the whole candidate. Every AMEND explicitly marks
   "behaviour unchanged" or "behaviour changed", names its span and supplies exact before/replacement text.
   - "Behaviour unchanged" counts as ACCEPT only after verification that no behaviour stated by the printed
     candidate changes: a wording, quotation or citation repair. Added conformance assertions, normative
     exceptions and payload changes do not ride merely on an author's mark.
   - Changed, unmarked or failed-check AMENDs count as CANNOT ACCEPT, preserving their exact text; they block
     only under rule 3. Four independent readers, one counted vote each; no snippet take/leave tally.
2. At least 3 of 4 counted ACCEPT with no verified blocking CANNOT ACCEPT makes the complete candidate
   a **reviewed form that goes into the Run**, under the owner's ruling. Only verified wording repairs
   may ride. No unread manager combination is substituted, recommended or applied as reviewed.
3. **The gate.** CANNOT ACCEPT blocks only for a loss that changes a checked verdict:
   - a CNF assertion or Lean theorem flipped, made unreachable or made vacuous (id/theorem name); or
   - a MUST/SHOULD (file and requirement id) with a trace that breaks it.
   An explicitly listed assertion amendment is not an unlisted loss; an omitted flip is. An objection
   without this evidence is recorded, not blocking, and still affects the counted ACCEPT threshold.
   A verified strict AGENTS.md quotation defect is a wording repair with the owner's verbatim words,
   reported but not blocking. Coverage is explicitly checked and reported; it is not silently added
   to this enumerated loss gate. A red preparation coverage check stops launch under the owner's instruction.
4. If fewer than 3 counted ACCEPT, or a verified gated loss remains, the form does not go into the Run.
   Report votes, exact repairs and verified dissent. Convergent repairs need a scoped whole-form read;
   a non-converging behavioural or scope decision returns to the owner with exact alternatives. The
   stored-listing direction and Q2 remain settled; no fresh-read substitution or automatic new panel.
5. A clause drawing non-converging AMENDs in two successive valid reads is deleted only if no reader names
   normative content lost under rule 3. This round authorizes no automatic deletion; record proposed
   deletions explicitly and do not construct an unread combination from them.
6. A verified brief error that changes a question's premise **voids that question's tally only**; re-ask it
   corrected. Other brief errors are reported with the tally, identifying any vote whose reason rests on one.
7. Counterarguments "written on request" are not votes. Relay votes first, labelled counterarguments after.

## Preparation and checks

The stop conditions are an inapplicable source span, an unmatchable quote, a red exact-candidate
coverage result, or inability to find text preserving the target verdicts. Stop before quota/launch
on any of them; no silent change to the r70 reader text. No such condition was found in preparation.

check/assembly-check.py proves exact r70 assembly plus exactly the opus S1/S6 replacements and S1c,
printed/JSON identity, unique anchors, fixed-string rg quote matches from c5f897c and the unchanged
CNF-278/CNF-307 bytes. check/strict-quoting.md records the attribution review. check/traces.md gives
coordinator source traces for every CNF-278/CNF-307 case group and all r70 dissent witnesses, with the
source words. Its descriptive trace-cases.json is not an implementation test or a formal proof.
No historical r70 experiment or verified mechanics are re-verified. New-candidate application and
coverage are checked independently. Full required repository gates run unpiped before/after.

## Preparation results (fixed before quota/launch)

- Exact assembly/quote check: exit 0; both exact reader replacements; only one coordinator sentence;
  seven unique applications; 23 source quote/anchor/context checks pass. Brief has no model names.
- Coverage: actual unpiped exact applied candidate run exit 0, 74 ratcheted uncovered, baseline 74
  byte-identical. Receipt: check/coverage-result.json, coverage.log/.exit, candidate-applied.diff.
- Traces: check/traces.md, trace-cases.json; CNF-278 16 case groups, CNF-307 14 groups, 1,600 descriptive
  tail combinations, 31 trace source-block grep checks pass. These are coordinator predictions for
  panel falsification, not independent proof or votes. The explicit 10:1253–1255 stale/sellable case
  retains state/solvency ordering and its account-health skips; no-row termination stays false.
- Initial repository full gate exit 0, all seven gates PASS (check/gate-before.log/.exit).
  Final repository full gate receipt: check/gate-after.log/.exit. Candidate structural coverage does
  not certify the full suite against the candidate. No spec/tracker/commit/remote/memory is changed.

## Launch settings

Copy r70 launch.sh, run-claude.sh, run-codex.sh with only r70→r71 paths and unit names changed;
check/launcher-copy.diff records the changes. Export PATH="$HOME/.npm-global/bin:$PATH" before launch;
launch.sh passes PATH through -E PATH. TMPDIR=/var/tmp/provisiond-panel-r71/tmp, outside /tmp.

- panel-r71-fable: claude-fable-5-1 xhigh
- panel-r71-opus: claude-opus-5-5 xhigh
- panel-r71-astra: gpt-6-astra high
- panel-r71-sol: gpt-6.1-sol xhigh

Every unit: MemoryMax=16G, MemorySwapMax=0, OOMPolicy=continue. Confirm active/running and all caps.
Clone HEADs fixed at c5f897c and clean before launch; answers <seat>.md, exits <seat>.exit; timeout 3600.
Quota command: `timeout 60 claude -p "/usage" </dev/null`; record exact reading under the heading below.
Stop only if the session or any displayed week line is >=95%. An omitted week line is recorded as omitted.
After preparation, the only edit to notes.md is the quota section. Launch evidence goes in check/.
Append one UPDATE to the top RESUME bullet recording settled preservation and r71; return immediately
with the exact exit-file wait command. No new panel, tally, Run or owner question is authorized here.

## Quota (checked before launch)

Checked 2026-10-26 06:39:54 UTC with `timeout 60 claude -p "/usage" </dev/null`; exit 0.

- Current session: 14% used · resets Oct 26, 11:10am (UTC)
- Current week (Fable): 28% used · resets Oct 27, 2am (UTC)

The command omitted the all-models week line. No displayed session or week line reaches 95%; launch proceeds.
Raw evidence: check/quota.out/.err/.exit, quota-at.txt; decision: check/quota-decision.json.
