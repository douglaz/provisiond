# r69 notes (panel E corrected confirmation: pv-tcs, pv-ytv). 2026-10-25

**PREPARATION STOP RESOLVED BY MAIN.** The S4 correction candidate now quotes STO-60's whole sentence exactly
as S2 has it, with main's wording-only correction noted at the candidate. See "Preparation stop" below.

Outcome rules fixed before launch. Base and reader clones: `c5f897c32f7894d77a544528872176f241394d0d`.
One shared brief: docs/research/panels-2026-10/r67/r69/brief.md. Source specification for this round:
docs/research/panels-2026-10/r67/r68/tally.md, whole, especially "What the corrected round reads (not launched)"
and "Brief and reader errors ledger". Its verified mechanics and source evidence are reused, not re-verified.
Both r68 question tallies are VOID; raw picks and option counts are disclosure, not approvals to follow.

Forms: Q1 **S-final S1–S6** and **F-final F1–F10**, exactly as printed in r68, with options and separately
labelled reader proposals; no combined F repair is offered as complete. Q2 **K candidate K1–K6**, combined
candidate, unreviewed: r68 K with Reader 2's exact r68 K2/K6 extracts and r67 Reader-2 K-c as K4. K-a/K-b
remain alternatives; K-d is separate. Q1 and Q2 are tallied separately.

## Settled (not re-voted)

- Q1 always goes to the owner: cost and latency are the owner's decision.
- The earlier null-pair Form N is not a complete form read here. A reader may supply a third shape as exact
  text; the r68 tally records no third shape and no valid approval of K.

## Outcome rules (r63 rules 1-7 form; rule 3 = the gate)

Per question, each complete form is judged separately.
1. Each reader votes ACCEPT, AMEND or CANNOT ACCEPT on each complete form (Q1 S-final and F-final; Q2 K
   candidate), and picks a Q1 form or supplies a third shape as exact text. Every AMEND explicitly marks
   "behaviour unchanged" or "behaviour changed", gives its span id and exact replacement text.
   - "Behaviour unchanged" counts as ACCEPT only after the manager verifies it changes no behaviour the
     printed form states; this is a wording, quotation or citation repair. Added conformance assertions,
     normative exceptions and payload changes do not ride merely on the author's mark.
   - Changed, unmarked or failed-check AMENDs count as CANNOT ACCEPT, with exact text preserved, and block
     only under rule 3.
   - Every option and separate reader proposal gets take/leave (one variant where alternatives conflict).
     An option carries only at 3 of 4 take with no gated objection. Raw r68 takes never enter this count.
2. A form is owner-ready at 3 of 4 counted ACCEPT with no blocking CANNOT ACCEPT. Only verified wording
   repairs may ride. No manager combination that has not been read whole is recommended as reviewed;
   any such combination needs a scoped confirmation read. The owner question quotes only reviewed behaviour.
3. **The gate.** CANNOT ACCEPT blocks only for a loss that changes a checked verdict:
   - a CNF assertion or Lean theorem flipped, made unreachable or made vacuous (id/theorem name); or
   - a MUST/SHOULD (file and requirement id) with a trace that breaks it.
   A form's explicitly listed assertion amendment is not an unlisted loss; an omitted flip is. An objection
   without this evidence is recorded, not blocking. A verified strict AGENTS.md quotation defect is a wording
   repair with the owner's verbatim words, reported but not blocking. Disclosed quotation defects in the
   preserved r68 forms and archived proposals are not permission to introduce new ones.
4. **Verified gated loss on a final form (decided before launch):**
   - On K or the Q1 pick: one scoped repair read (r69b) before the owner question, using convergent reader
     text or a deletion permitted by rule 5. New coordinator repairs remain unreviewed until read.
   - On the unpicked Q1 form: disclose defect and exact proposed fix to the owner, together with the need
     for a scoped read if that form is selected. No complete F repair is inferred from F11/F12.
   - If neither Q1 form is ready, or picks split 2–2, present the split and defects to the owner; this does
     not waive the repair-read requirement for any recommended form with a verified gated loss.
5. A clause drawing non-converging AMENDs in two successive valid reads is deleted only if no reader names
   normative content the deletion loses under rule 3. The voided r68 vote is not a successful convergence
   round; the r68 tally identifies no clause safe to delete. Record any proposed deletion explicitly.
6. A verified brief error that changes a question's premise voids that question's tally only; re-ask it
   corrected. Other brief errors are reported with the tally, identifying any vote whose reason rests on one.
7. Counterarguments "written on request" are not votes. Relay votes first, labelled counterarguments after.

## The one owner question (after a valid tally)

One question, two parts: Q1 F or S; Q2 apply the reviewed K form? Q1 is "panel recommends <pick>, <n> of 4",
never settled. Include each form's strongest argument and the storage/latency/stale-price costs. Use the
price/reserve qualification in r68's tally. Q2 is a recommendation only when its exact form is owner-ready.
No owner-question.md is written during preparation or launch.

## Reader labels (manager only)

In retained r67 texts: Reader 1=fable, Reader 2=opus, Reader 3=astra, Reader 4=sol.
In r68 extracts: the same labels denote r68 fable/opus/astra/sol respectively. The brief distinguishes rounds.
No model names or reader-seat assignment appear in the brief.

## Preparation and checks

The build/check scripts and their output are saved under parts/ and check/. Exact S/F span preservation,
K assembly, reader extracts, normalized before-string applicability, repository quotations, strict quoting
dispositions and the model-name scan are recorded there before launch. A failed assembly stops launch.
The r68 tally's verified source traces, anchors and unchanged-source gate results are reused per instruction;
no repository specification, bead, commit or remote is changed in this activity.

## Launch settings

Copy r68 launch.sh, run-claude.sh and run-codex.sh changing only r68 paths/unit names to r69. Export
`PATH="$HOME/.npm-global/bin:$PATH"` before launch; launch.sh passes it through `-E PATH`.
Units panel-r69-fable (claude-fable-5-1 xhigh), panel-r69-opus (claude-opus-5-5 xhigh),
panel-r69-astra (gpt-6-astra high), panel-r69-sol (gpt-6.1-sol xhigh). Every unit gets
MemoryMax=16G, MemorySwapMax=0, OOMPolicy=continue. TMPDIR=/var/tmp/provisiond-panel-r69/tmp.
Answers <seat>.md, exits <seat>.exit; timeout 3600; draft by minute 25. Confirm active state and caps for all.
Quota command: `timeout 60 claude -p "/usage" </dev/null`. Stop only if session or any week line is >=95%.
The quota section is the only notes.md edit after preparation finishes. Launch evidence goes in check/ and
one UPDATE line in the top RESUME bullet of the manager brief. Return immediately with the exact wait command.

## Preparation stop (historical; resolved by main)

The required stop condition was reached before step 2. r68/tally.md, "Manager quotation correction for fable
S4", attributes this exact sentence to the proposed STO-60:

> Every successful driver List offers read MUST publish its complete result to the account's row.

r68/brief.md S2 actually has:

> Every successful driver List offers read MUST publish its complete result to the account's row, replacing an existing row only when the incoming `read_at` is later.

The period in the correction replaces a comma and omits the remainder of the owner's sentence. Fixed-string
`rg` returns 1 against the whitespace-normalized S2 owner. This is a quote that does not exist verbatim in
the tally's prescribed material; the instruction requires stopping before launch rather than silently fixing it.
At that stop, the same correction had been copied into the draft verbatim and had not been repaired or approved.

Evidence: check/assembly-check.py, check/assembly-check.out and check/assembly-check.exit (1), plus
check/sto60-{quoted,source}.txt. S1–S6/F1–F10 operative spans match r68 byte-for-byte; K2/K4/K6 match the prescribed
assembly; all complete-form anchors apply once at c5f897c after whitespace normalization. The full quote/strict
sweep remains incomplete because this assembly check stopped preparation. Draft brief: 38,643 bytes.

At that stop: no quota check, reader clones, launcher scripts or reader units. No owner question, spec/bead edit or launch.
check/clone is only a throwaway source-check clone; it is not a reader clone. The r68 tally's verified gates and
mechanics were reused; no gate was re-run on the unchanged source set during the stopped preparation.

Main subsequently resolved the exact assembly discrepancy: the r69 S4 candidate now quotes the whole STO-60
sentence from S2; wording only, with no other brief changes. The assembly checker now reads that corrected
r69 candidate rather than the archived r68 tally; the original checker and artifacts remain in check/.

## Quota (checked before launch)

Checked 2026-10-25 21:04:30 UTC with `timeout 60 claude -p "/usage" </dev/null`; exit 0.

- Current session: 62% used · resets Oct 26, 1:09am (UTC)
- Current week (Fable): 8% used · resets Oct 27, 1:59am (UTC)

The command omitted the all-models week line. No displayed session or week reading reaches the 95% stop line.
Raw output and timestamp: check/quota.{out,err,exit}, check/quota-at.txt.
