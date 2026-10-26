# r70 notes (panel E: scoped whole-form S read). 2026-10-26

Outcome rules fixed before launch. Base and reader clones: `c5f897c32f7894d77a544528872176f241394d0d`.
Shared brief: `docs/research/panels-2026-10/r67/r70/brief.md`. Source scope: r69 tally.md,
"What a subsequent scoped read must read", "If S is selected". Reuse its verified findings, not re-verify them.

## Settled (not re-voted)

Owner ruling (2026-10-26; `/var/tmp/provisiond-manager/owner-q1-sync-2026-10-23.md`): Q1 pv-tcs
"Stored listing (Recommended)"; Q2 pv-ytv "K1–K6 and K-d (Recommended)". Q2 is the exact r69 K1–K6
and original K-d at brief.md:361–362, without opus's fixture AMEND. It needs no further read and goes into
the Run. Q1's cost/latency direction is settled; the exact S combination still needs this whole-form read.

The **unreviewed combined candidate** is printed S1–S6, preserving S1's admitting-transaction timing,
printed S3's credential-stop scope and printed S4's "running in the engine process", with only the exact
common S2 DOM-9 row repair, exact opus caller-clarification sentence and exact archived R4 S6 coverage
append. No S-a/b/c/d or failed-BU S4 replacement. The S6 append adds assertions; earlier takes do not
review their combination. Build provenance: parts/build.py, parts/candidate.{md,json}.

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

check/assembly-check.py and its .out/.exit prove exact assembly, source anchor applicability, source
quotations with fixed-string rg after whitespace normalization, no model names in the brief, and the
STO-60 whole-sentence rule. New proposed words are labelled proposals, not attributed to the base.
check/strict-quoting.md records the attribution dispositions for every proposed span. A missing quote,
inapplicable span or red candidate coverage check stops before quota/launch; no silent repair of the tally.
check/coverage.log/.exit and coverage-result.json record the exact combined candidate applied in check/scratch
and the unpiped coverage check with its uncovered count; the baseline is not changed. Verified r69 source
mechanics and earlier experiments are reused. Required full gates run unpiped before and after this work.
No real spec, bead, commit, remote or memory file is changed.

## Launch settings

Copy r69 launch.sh, run-claude.sh and run-codex.sh changing only paths and unit names from r69 to r70.
Export PATH="$HOME/.npm-global/bin:$PATH" before launch; launch.sh passes it through -E PATH.
panel-r70-fable: claude-fable-5-1 xhigh; panel-r70-opus: claude-opus-5-5 xhigh;
panel-r70-astra: gpt-6-astra high; panel-r70-sol: gpt-6.1-sol xhigh.
Every unit: MemoryMax=16G, MemorySwapMax=0, OOMPolicy=continue. TMPDIR=/var/tmp/provisiond-panel-r70/tmp.
Answers <seat>.md; exit files <seat>.exit; timeout 3600. Confirm each unit active with caps and PATH.
Quota: `timeout 60 claude -p "/usage" </dev/null`; stop only at session or any week line >=95%.
After preparation finishes, the **only** edit to this notes.md is the quota section required below.
Launch evidence goes under check/; append one UPDATE line to the top RESUME bullet of the manager brief,
recording the owner ruling and r70. Return immediately with the exact wait command, without tallying.

## Preparation results (fixed before quota/launch)

- Assembly/quote checker exit 0: preserved S1/S3/S4/S5, exact three repairs only; 15/15 source
  quote/before-string checks match c5f897c by rg; seven unique application anchors; no model names.
- Exact combined candidate coverage exit 0: 74 ratcheted uncovered, baseline 74 unchanged.
  Evidence: check/assembly-check.{py,out,exit}, check/quotations.json, check/candidate-applied.diff,
  check/coverage.{log,exit}, check/coverage-result.json. Brief size: 12,288 bytes.
- Strict attribution dispositions: check/strict-quoting.md. No prescribed-text mismatch or preparation
  stop condition was found. Initial unpiped repository check-all exit 0, all seven gates PASS; its
  terminal receipt is recorded in check/gate-before.summary. Final gate receipt: check/gate-after.{log,exit}.

## Quota (checked before launch)

Checked 2026-10-26 02:08:25 UTC with `timeout 60 claude -p "/usage" </dev/null`; exit 0.

- Current session: 66% used · resets Oct 26, 6:10am (UTC)
- Current week (Fable): 21% used · resets Oct 27, 2am (UTC)

The command omitted the all-models week line. No displayed session or week reading reaches the 95% stop line; launch proceeds.
Raw evidence: check/quota.{out,err,exit}, check/quota-at.txt.
