# Panel Q r96 — pv-gvc adopted Q1-B wording, owner item 13

Read this brief and `/var/tmp/provisiond-panel-r96/notes.md` whole. Packet artifact paths below are relative to `/var/tmp/provisiond-panel-r96/`; repository paths are relative to your own clone. Your own clean reader clone is detached at M=`f8a30457eb84b3077e7580732bef665b3763aae1`, current origin/master (PR #65, pv-kv2). Read specification text only from your clone or git show at M. Main checkout is off-limits: never enter it, read its working files, change it or run br there. No Run has started; pv-gvc has no implementation commits. No question was dropped.

Read-only: no implementation, br, tracker, bead, branch, archive, source, PR, push, commit, checkout, reset, stash, clean, background work, subagents or other reader access. Temporary verification files only `/var/tmp/provisiond-panel-r96/tmp/<seat>/`. Do not read credentials/session/config locations (`~/.claude`, `~/.codex`, `~/.grok`, auth files, kubeconfig, browser profiles). Other panel/manager folders are read-only history; supplied evidence copies and committed archives are preferred. No `lake build` or gate: manager runs full Nix gate separately. Deliver substantive final answer within 3600s; aim <=3000 words plus any exact alternative text and assertion inventory. Do not wait on readers.

**apply notes.md rule 6 exactly as written; this prompt adds no void rule.**

## Plain problem and fixed policy

A customer’s queued order and an administrator’s suspension cleanup race. If cleanup wins, the order cannot be claimed. If the worker claims first, cleanup must affect nothing, and that worker must decide the order’s outcome. Claiming first does not give an order first picked up under suspension permission to buy a server or a guarantee of success. The owner approved a single guarded failure-and-release transaction plus independent store tests of that race and the other guards. That package is fixed; this panel asks only how to express its reference to the worker’s refusal rule and record the correction honestly.

The pre-Run turn found an adopted sentence that describes another requirement without quoting it. A green citation trial does not decide the manual quotation rule. Compare exact wording that preserves every approved assertion. Q-KEEP is eligible only if you demonstrate that AGENTS’s quotation duty does not apply here (for example, a package-own new rule rather than a statement about OPS-43); no exemption is presumed.

The second question is whether the executable Agent Brief alone should change, or whether the original archived approval should also acquire a dated explanatory note with its existing bytes untouched. No source implementation, tracker update, approval, tally, consensus round or Run launch happens this turn. If unsettled, ONE r96b consensus round belongs to a later turn. pv-bxh/item14 and pv-kv2 (closed) are outside this ballot; read item19 only for ordering/provenance. Add nothing item13 excluded: no deferred-operation guard fix, fixture or predicate repair.

## Required evidence

Read evidence/next10-update.md whole (the 2026-11-02 18:06:54 UTC UPDATE from manager-brief.md), next10-stop-report.md, next10-failing-sentence.txt, next10-supporting-source-sentence.txt, next10-agent-brief.md, next10-stop-result.json, next10-citation-trial.diff, next10-citation-trial.log and next10-citation-trial.exit. These are read-only copies from `/var/tmp/provisiond-manager/dr-next10-check/`; source-*.md copies also preserve that turn’s evidence. Read evidence/pv-gvc.json and actual decoded comment853 in evidence/comment-853.md. Its desired+acceptance blocks equal the frozen package; independently verify that.

Read the r83 archive at M: docs/research/panels-2026-10/r83/{brief.md,notes.md,STATE.md,check/settled-Q1-B.txt,check/tally-evidence.md,fable.md,opus.md,astra.md,sol.md}, plus owner-questions.md and tally.md for Q1 provenance. Historical launch instructions there do not override this brief. Q1-B was preferred by Fable/Opus/Astra, Sol preferred A, and all accepted B; the owner then adopted B. The discovered deferred-operation guard issue was separately excluded, not repaired by B.

Read owner items13/19 verbatim below. Read complete OPS-43 home at M (03-operation-lifecycle.md:757–937), not only step1; evidence/OPS-43-at-pin.md is the exact extracted home. Read evidence/OPS-43-before-PR65.md and PR65-OPS-43.diff: PR65 DID change OPS-43 and supplied the current tenant refusal. The supporting step1 quotation is present at M; it was absent in PR65’s parent. Do not confuse old r83 pin3109b5b with today’s source pin.

Read occurrences.md whole and recheck EVERY named reference in the frozen package and decoded comment853. List every summary attribution, including already quoted LDG-32 assertions and the historical Current behavior fence, with locations in comment853 and settled-Q1-B.txt (or explicitly absent from one). Distinguish list/owner pointers, the package’s own new rules, actual summaries and historical evidence. WIR-10’s operation-kind list pointer has the precise enum home WIR-10a; the historical r83 label discrepancy is disclosed, not silently corrected. Supply exact full replacement and locations for any additional occurrence you judge needs a correction; do not confine the audit to OPS-43.

Read complete relevant source homes in evidence/*-at-pin.md (API-58, CNF-202, LDG-32, LDG-35, WIR-10/WIR-10a, API-64 and historical-context OPS-11/DOM-20/WIR-9a/WIR-10b/OPS-39). Verify against your Git objects at M; the preparation receipt records direct extraction, not independent verification by you. The historical Current behavior fence matches its explicit old Git ref; it is not new Run text.

Precedent, not a ruling: evidence/r95-tally.md and r95-settled-pv-kv2.md record Panel P’s Q-QUOTE/L-NOTE 3–0 settlement; evidence/r94-tally.md, r94-r94b-tally.md and r94-settled-pv-kv2.md record Panel O’s Q-QUOTE-OPS43/L-NOTE; evidence/r93-tally.md records Panel N’s Q-QUOTE/dated-note. Verify any precedent you rely on, and do not treat those results as votes here.

## Owner record, verbatim

13. **pv-gvc (Panel D r83 Q1, preference B 3–1 (fable, opus, astra; sol A), acceptance 4–0, owner approval of the
    behaviour)** — Q: "pv-gvc: should failing an unbought order and returning its reserved money be written as one
    step, with a race-losing cleanup releasing nothing?" A: **"B: say it explicitly (Recommended)"**. Option text:
    "One-step release rule plus full race tests. Preferred 3–1 (fable, opus, astra), accepted 4–0." Rejected: "A:
    tests only", "C: fewer tests". Meaning: adopt exactly r83 brief Q1-B as frozen in
    /var/tmp/provisiond-panel-r83/check/settled-Q1-B.txt (per /var/tmp/provisiond-panel-r83/owner-questions.md §1),
    without the newly discovered deferred-operation guard fix. pv-gvc → ready-for-agent with that package as its
    brief, landing with or after pv-kv2's exact mechanics (Panel D Q4, consensus round r83b running) under item 3.

19. **pv-kv2 (Panel D r83b Q4, unsettled after its one consensus round: D preferred and accepted 3–1 by fable +
    astra + sol, opus rejects; A preferred by opus, acceptance 2–2; D's 3–1 blocked by a verified rule-3 loss (the
    positive duty to publish the existing-fleet warning); no panel recommendation; grok missing, 402)** — Q: "pv-kv2
    public terms (panel unsettled): explain the 'approved before suspension' exception, or keep today's exact words and
    warning?" A: **"D: explain exception"**. Option text: "3–1 pick (fable, astra, sol). Terms say an order approved
    before suspension may still complete. Drops the required public warning that existing servers may keep running if
    cancellation fails (opus's objection)." Rejected: "A: keep current words". Meaning: adopt exactly
    /var/tmp/provisiond-panel-r83/r83b/Q4-D.md, unchanged, under item 3 "Stop before buying (Recommended)"; the owner
    knowingly accepts the loss of API-58's positive publication duty for the existing-fleet warning (opus's dissent on
    record). No A/D combination, repaired D or partial D. pv-kv2 → ready-for-agent with item 3's Q1 package plus
    Q4-D.md; items 13 (pv-gvc) and 14 (pv-bxh) stand and land with or after it.

Owner’s wording rule (manager-brief.md PR handling): “For such wording questions, try to solve by getting a consensus of the panel”. It applies only where behavior, requirements/owner meaning and check strength are all unchanged. Classify each separately. A substantive departure goes to the owner. Earlier rounds on different questions do not consume this wording question’s one r96b allowance.

## Governing source passages at M

AGENTS.md:29–32, verbatim:

````text
**Quote the sentence.** A claim about what another requirement says carries that requirement's own
words. `` `WIR-30` says "The gate reads the copy the machine took at create" `` is checkable;
"`WIR-30` forbids resolving eligibility that way" is an assertion, and assertions of that shape were
false repeatedly on 2026-09-03 — `ddd3df0` and `254fc24` carry the cases and what each one cost.
````

AGENTS.md:45–46, verbatim:

````text
**Completion:** every sentence asserting what another requirement says carries its quote, and every
list or count names its source instead of restating it.
````

Read AGENTS’s whole writing section too; the “one rule, one home” and source-list instructions also matter. Source text copied below retains raw whitespace. At eventual CNF-202 landing, add only the existing six-space Markdown list container indent to every candidate payload line; remove exactly that outer container indent to compare the quoted OPS-43 bytes. Preserve the source’s internal newline and three-space continuation indentation. Do not replace LF by spaces and call it byte-identical.

OPS-43 step1, 03-operation-lifecycle.md:786–792 at M (verbatim):

````text
   Next read this operation's tenant status. Where the tenant is suspended, fail this existing
   create with conflict, details.reason: "tenant_suspended", and retryable: false on both the error
   and operation view. This read precedes channel closure and boundary validation. Make no provider
   request, including List offers or a per-order key upload. Settle failed with full commitment
   release and no setup-fee or first-unit debit under OPS-11's pre-step-9 create rule; OPS-11 says "Any create failure the worker records before any step-9 request (before any per-order key upload or order request) MUST settle `failed`, whatever its kind." and “The commitment is released in full under `LDG-32` ("A commitment MUST be closed, and its remaining amount released in full") and `LDG-39` ("**Never debited**; released with the commitment (`LDG-32`)"), with no setup-fee or first-unit debit.”. Preserve
   requested_by and system_reason as originally recorded; do not emit the admission-only kind
   suspended. This is a plain read; the dispatch guard below closes the race after it.
````

The exact refusal quotation used by Q-QUOTE is:

````text
Where the tenant is suspended, fail this existing
   create with conflict, details.reason: "tenant_suspended", and retryable: false on both the error
   and operation view.
````

LDG-32’s quoted phrase “the create fails deterministically” is an exact contiguous substring of 12-billing-and-ledger.md:312 at M. Read the whole home to check its qualifiers. Both occurrences of that phrase in Q1-B remain unchanged in every option.

Citation checker scope, tools/check_citations.py:155–180 at M, verbatim:

````text
           start to matter (`pv-vwe.25`, the decision of 2026-10-01).

  UNQUOTED "`X` says/states/reads ..." with no quote at all is unverifiable by
           construction. Ratcheted against `citation-baseline.json` rather than
           failed outright, because such sentences already exist and a gate that
           fails a clean tree is a gate someone deletes. New ones are refused;
           the standing ones come down as their requirements are next edited.
           The count lives in that file and nowhere else -- a number written
           into prose is wrong the first time either end moves, which this set
           has now learned in `ADR-0003`, `ADR-0011` and `F16`.
           HISTORICAL and TEACHING retain their whole-chunk suppression here,
           including history inside a paired quotation.

Summary verbs are deliberately OUT OF SCOPE. "`OPS-12` forbids automatic retry"
is a correct, useful paraphrase, and most attributions in the set are of that
shape. Demanding a quote there would fire on legitimate prose, which is how a
checklist item ends up unsatisfiable by every conforming implementation
(`CNF-224`).

WHAT THIS DOES NOT CATCH, stated plainly because a gate's limits are part of its
contract: a wrong SUMMARY. "`WIR-30` forbids the server resolving eligibility
that way" reverses `WIR-30`'s meaning, uses a summary verb, and carries no
quote -- no lexical signal separates it from a correct summary. That one was the
worst defect of 2026-09-03 and it stays a review problem. Lean docstrings participate
in the mark guard, QUOTED and EXISTS: they supply neither requirement bodies nor
UNQUOTED or NAMES input.

````

This describes a lexical gate’s scope. It does not grant an exception to the manual AGENTS duty. The stop turn’s citation trial exit0 is disclosed as such; it proves neither semantic preservation nor compliance with every prose rule.

## Q1 — exact executable wording

The target sentence appears once at comment853:57–60 (decoded) and once at settled-Q1-B.txt:31–34; see occurrences.md for exact start positions and independent scans. The replacement boundary begins “A claimed create” and ends “administrative write.”, leaving the surrounding claim-race assertions and held-power instruction intact. Apply the chosen replacement to comment853’s Acceptance criteria and to the full package the future Run will receive. The archived original is governed separately by Q2; do not overwrite it with the executable package.

For EACH of the following, give ACCEPT / CANNOT ACCEPT of that exact form. Give one final preference separately. An alternative needs complete exact replacement text and locations; different repairs are different forms. For “not a purchase” and “it is not required to succeed merely because its claim defeated the administrative write”, say separately whether each is the package’s own case rule or a claim about OPS-43, what evidence supports it, and where your chosen form carries it. Classify the “follows ... refusal” clause separately too.

### Q-QUOTE

Retain every word of the target and insert OPS-43’s exact current refusal words in that same sentence.

Exact replacement:

````text
A claimed create first picked up while the
tenant is suspended follows OPS-43's tenant-status refusal, not a purchase (OPS-43 says “Where the tenant is suspended, fail this existing
   create with conflict, details.reason: "tenant_suspended", and retryable: false on both the error
   and operation view.”); it is not required
to succeed merely because its claim defeated the administrative write.
````

Full executable package (also Q-QUOTE.txt):

````text
In API-58, immediately after the sentence ending "that kind stays an admission-time rejection of a *caller's* write (`DOM-20`).", insert:

Where step (4) fails a create deterministically, the same guarded transaction MUST close its
commitment and release the remaining amount in full; see LDG-32, "the create fails deterministically".
It MUST make no setup-fee or first-unit debit. The administrative status write MUST precede the
release and short-circuit it when it affects no row, after the transaction's generation check
and the tenant's LDG-35 primitive.

At the end of CNF-202, before its existing amendment note, append:

Separately exercise the suspension fan-out's administrative write directly through the store,
on independent fixtures. These are store cases, not a claim that normal queue ordering leaves
an eligible create unclaimed. For each caller-requested operation kind in WIR-10's operation-kind
set that can be queued for this tenant, seed a never-claimed queued operation, a suspended tenant
and this suspension's unsettled parent. Run the write and assert one affected row, failed,
conflict with details.reason: "tenant_suspended", requested_by unchanged as caller,
system_reason null, and no provider request. For a create seed an open commitment with a nonzero
reserve, a nonzero setup fee and prepaid first unit; assert full release and no setup-fee or
first-unit debit. LDG-32 says "the create fails deterministically".

Vary one guard term at a time on fresh fixtures: requested_by system on a queued cancellation;
requested_by operator on a queued API-64 retry; status running under a real claim; tenant active;
and this suspension's parent already settled while the tenant is suspended. In each case assert
zero affected rows, the operation and its origin/error unchanged, and no commitment or provider
effect from this administrative write. Keep the other guard terms satisfied in each fixture.
Include a stale old-parent write after resume and a fresh suspension: the old settled parent
cannot authorize the write under the new suspension.

Race a real claim against the administrative write in both orders. Administrative failure first
prevents the claim. Claim first prevents the administrative failure, preserves the returned
claim number, and leaves settlement to that worker. A claimed create first picked up while the
tenant is suspended follows OPS-43's tenant-status refusal, not a purchase (OPS-43 says “Where the tenant is suspended, fail this existing
   create with conflict, details.reason: "tenant_suspended", and retryable: false on both the error
   and operation view.”); it is not required
to succeed merely because its claim defeated the administrative write. Preserve the existing
held-power scenario above as the scheduling case; do not replace it with a normally eligible
create.
````

### Q-POINTER

Use a bare ownership pointer, then express the preserved race-case expectations as this package’s test instructions. Check that no refusal/no-purchase/no-guarantee assertion is weakened by that separation.

Exact replacement:

````text
Worker disposition: see OPS-43. For this test's claimed create first picked up while the tenant is suspended, assert tenant-status refusal and no purchase; it is not required to succeed merely because its claim defeated the administrative write.
````

Full executable package (also Q-POINTER.txt):

````text
In API-58, immediately after the sentence ending "that kind stays an admission-time rejection of a *caller's* write (`DOM-20`).", insert:

Where step (4) fails a create deterministically, the same guarded transaction MUST close its
commitment and release the remaining amount in full; see LDG-32, "the create fails deterministically".
It MUST make no setup-fee or first-unit debit. The administrative status write MUST precede the
release and short-circuit it when it affects no row, after the transaction's generation check
and the tenant's LDG-35 primitive.

At the end of CNF-202, before its existing amendment note, append:

Separately exercise the suspension fan-out's administrative write directly through the store,
on independent fixtures. These are store cases, not a claim that normal queue ordering leaves
an eligible create unclaimed. For each caller-requested operation kind in WIR-10's operation-kind
set that can be queued for this tenant, seed a never-claimed queued operation, a suspended tenant
and this suspension's unsettled parent. Run the write and assert one affected row, failed,
conflict with details.reason: "tenant_suspended", requested_by unchanged as caller,
system_reason null, and no provider request. For a create seed an open commitment with a nonzero
reserve, a nonzero setup fee and prepaid first unit; assert full release and no setup-fee or
first-unit debit. LDG-32 says "the create fails deterministically".

Vary one guard term at a time on fresh fixtures: requested_by system on a queued cancellation;
requested_by operator on a queued API-64 retry; status running under a real claim; tenant active;
and this suspension's parent already settled while the tenant is suspended. In each case assert
zero affected rows, the operation and its origin/error unchanged, and no commitment or provider
effect from this administrative write. Keep the other guard terms satisfied in each fixture.
Include a stale old-parent write after resume and a fresh suspension: the old settled parent
cannot authorize the write under the new suspension.

Race a real claim against the administrative write in both orders. Administrative failure first
prevents the claim. Claim first prevents the administrative failure, preserves the returned
claim number, and leaves settlement to that worker. Worker disposition: see OPS-43. For this test's claimed create first picked up while the tenant is suspended, assert tenant-status refusal and no purchase; it is not required to succeed merely because its claim defeated the administrative write. Preserve the existing
held-power scenario above as the scheduling case; do not replace it with a normally eligible
create.
````

### Q-KEEP

Leave the sentence byte-for-byte unchanged, only if the reader establishes the quotation duty is inapplicable. Mere correctness, past adoption, a green gate or another panel’s decision is insufficient.

Exact replacement:

````text
A claimed create first picked up while the
tenant is suspended follows OPS-43's tenant-status refusal, not a purchase; it is not required
to succeed merely because its claim defeated the administrative write.
````

Full executable package (also Q-KEEP.txt):

````text
In API-58, immediately after the sentence ending "that kind stays an admission-time rejection of a *caller's* write (`DOM-20`).", insert:

Where step (4) fails a create deterministically, the same guarded transaction MUST close its
commitment and release the remaining amount in full; see LDG-32, "the create fails deterministically".
It MUST make no setup-fee or first-unit debit. The administrative status write MUST precede the
release and short-circuit it when it affects no row, after the transaction's generation check
and the tenant's LDG-35 primitive.

At the end of CNF-202, before its existing amendment note, append:

Separately exercise the suspension fan-out's administrative write directly through the store,
on independent fixtures. These are store cases, not a claim that normal queue ordering leaves
an eligible create unclaimed. For each caller-requested operation kind in WIR-10's operation-kind
set that can be queued for this tenant, seed a never-claimed queued operation, a suspended tenant
and this suspension's unsettled parent. Run the write and assert one affected row, failed,
conflict with details.reason: "tenant_suspended", requested_by unchanged as caller,
system_reason null, and no provider request. For a create seed an open commitment with a nonzero
reserve, a nonzero setup fee and prepaid first unit; assert full release and no setup-fee or
first-unit debit. LDG-32 says "the create fails deterministically".

Vary one guard term at a time on fresh fixtures: requested_by system on a queued cancellation;
requested_by operator on a queued API-64 retry; status running under a real claim; tenant active;
and this suspension's parent already settled while the tenant is suspended. In each case assert
zero affected rows, the operation and its origin/error unchanged, and no commitment or provider
effect from this administrative write. Keep the other guard terms satisfied in each fixture.
Include a stale old-parent write after resume and a fresh suspension: the old settled parent
cannot authorize the write under the new suspension.

Race a real claim against the administrative write in both orders. Administrative failure first
prevents the claim. Claim first prevents the administrative failure, preserves the returned
claim number, and leaves settlement to that worker. A claimed create first picked up while the
tenant is suspended follows OPS-43's tenant-status refusal, not a purchase; it is not required
to succeed merely because its claim defeated the administrative write. Preserve the existing
held-power scenario above as the scheduling case; do not replace it with a normally eligible
create.
````

For Q-QUOTE/Q-POINTER, keep comment853’s desired behavior, scope, historical Current behavior and historical drift evidence unchanged, replace the target as printed, and replace the authority line with the exact corresponding line below. Full prospective comments are comment-853-Q-QUOTE.md and comment-853-Q-POINTER.md; read them and compare their check/*.diff. Q-KEEP leaves comment853 whole, as comment-853-Q-KEEP.md. These files are review candidates, not tracker writes.

````text
**Owner decision:** “B: say it explicitly (Recommended)” (`owner-decisions-1030.md`, item 13). Original adopted form: `docs/research/panels-2026-10/r83/check/settled-Q1-B.txt`. Executable wording: Panel Q r96, Q-QUOTE; the original package remains the historical approval record.
**Owner decision:** “B: say it explicitly (Recommended)” (`owner-decisions-1030.md`, item 13). Original adopted form: `docs/research/panels-2026-10/r83/check/settled-Q1-B.txt`. Executable wording: Panel Q r96, Q-POINTER; the original package remains the historical approval record.
````

## Q2 — exact landing choices

Pick one landing choice and separately ACCEPT / CANNOT ACCEPT each, conditional on your Q1 form. Be explicit whether the choice changes owner item13’s meaning or Q1-B’s meaning, behavior or check strength. The original r83 archive records approved words; explain which choice keeps that record honest. /var/tmp/provisiond-panel-r83 stays entirely read only in every choice.

**L-BRIEF:** In a later preparation commit on branch pv-gvc, before the Run and in the same PR, replace decoded comment853 with the complete corresponding comment-853-Q-*.md candidate, including the authority line for a correction, and give the Run the corresponding complete Q-*.txt package. No edit to the archived r83 package. Preserve all other tracker/branch content except changes later independently authorized by the actual Run. This choice does not apply any normative source text now.

**L-NOTE:** All of L-BRIEF, plus append the exact matching dated note below to docs/research/panels-2026-10/r83/check/settled-Q1-B.txt after its existing final newline. Existing lines1–35 (the full original package) remain an exact byte prefix. Do not rewrite any prior line, original brief, vote or owner record. Archive the reviewed r96 record/notes so the note’s ../../r96/notes.md link resolves. The old frozen package remains historical, while the executable comment/Run package carries the reviewed wording. The note’s wording-only statements are eligible only if your actual verification supports them; if not, reject it or provide a complete alternative, rather than pre-adopting those statements.

A sidecar instead of an appendix is allowed only as a distinct complete alternative: give its exact path, full exact note, executable authority text, and preservation reasoning. No manager synthesis counts as reviewed.

### L-NOTE matching Q-QUOTE — exact append bytes

`````text


## Dated wording note — 2026-11-02, Panel Q r96 (Q-QUOTE)

The original package above records what Panel D and owner item 13 approved; its bytes remain unchanged. For execution in pv-gvc, use the Q-QUOTE wording reviewed under the owner’s 2026-10-28 rule, “For such wording questions, try to solve by getting a consensus of the panel”. See the [r96 record](../../r96/notes.md). This is a wording correction only: owner item 13 and the Q1-B assertions retain their meaning, and the deferred-operation guard fix remains excluded.

Original sentence:

````text
A claimed create first picked up while the
tenant is suspended follows OPS-43's tenant-status refusal, not a purchase; it is not required
to succeed merely because its claim defeated the administrative write.
````

Executable replacement in Agent Brief comment 853 and in the CNF-202 text supplied to the Run:

````text
A claimed create first picked up while the
tenant is suspended follows OPS-43's tenant-status refusal, not a purchase (OPS-43 says “Where the tenant is suspended, fail this existing
   create with conflict, details.reason: "tenant_suspended", and retryable: false on both the error
   and operation view.”); it is not required
to succeed merely because its claim defeated the administrative write.
````
`````

### L-NOTE matching Q-POINTER — exact append bytes

`````text


## Dated wording note — 2026-11-02, Panel Q r96 (Q-POINTER)

The original package above records what Panel D and owner item 13 approved; its bytes remain unchanged. For execution in pv-gvc, use the Q-POINTER wording reviewed under the owner’s 2026-10-28 rule, “For such wording questions, try to solve by getting a consensus of the panel”. See the [r96 record](../../r96/notes.md). This is a wording correction only: owner item 13 and the Q1-B assertions retain their meaning, and the deferred-operation guard fix remains excluded.

Original sentence:

````text
A claimed create first picked up while the
tenant is suspended follows OPS-43's tenant-status refusal, not a purchase; it is not required
to succeed merely because its claim defeated the administrative write.
````

Executable replacement in Agent Brief comment 853 and in the CNF-202 text supplied to the Run:

````text
Worker disposition: see OPS-43. For this test's claimed create first picked up while the tenant is suspended, assert tenant-status refusal and no purchase; it is not required to succeed merely because its claim defeated the administrative write.
````
`````

### L-NOTE matching Q-KEEP — exact append bytes

`````text


## Dated review note — 2026-11-02, Panel Q r96 (Q-KEEP)

The original package above remains unchanged and executable. Panel Q retained the sentence below only upon a verified finding that AGENTS.md’s quotation rule does not apply to it as an attribution. The [r96 record](../../r96/notes.md) must carry that finding before this note is used. Owner item 13 and the Q1-B assertions retain their meaning; the deferred-operation guard fix remains excluded.

````text
A claimed create first picked up while the
tenant is suspended follows OPS-43's tenant-status refusal, not a purchase; it is not required
to succeed merely because its claim defeated the administrative write.
````
`````

## Required reader audit and answer

1. Independently verify target occurrences and every requirement-summary attribution in the package and comment853, with locations in both or explicitly absent. Identify any additional summary requiring a fix. Read complete OPS-43 and confirm PR65’s actual change. Quote the supporting source yourself with path:line.
2. Byte-check EVERY quotation in your chosen correction, authority text and dated note against its named pin/source, including the unchanged LDG-32 words and old sentence cited as history. Report the exact comparison convention (only outer CNF list indent removed, no other whitespace normalization for source quotation payloads). Do not claim that source bodies’ nested quotations are directly exact to their owners unless you actually check them; inherited source defects are not authority for an unrelated repair.
3. Name EACH assertion the target sentence carries and precisely where your pick preserves it: suspended-at-first-pickup scope, worker refusal, no purchase, no success obligation from winning a claim. Distinguish “not required to succeed” from a blanket rule that every claim winner fails. Audit all surrounding race, origin, money, guard and held-power assertions in occurrences.md against the complete package. No assertion/check may be weakened merely to remove an attribution. State whether Q-POINTER fully carries the refusal outcome rather than an owner pointer alone dropping it.
4. For both final picks, separately classify behavior, requirements/owner item13/Q1-B meaning and check strength as WORDING-ONLY or SUBSTANTIVE, with evidence. This determines authority under the wording rule; adoption of exact historical words is not silently erased. Verify no deferred-operation guard term, claimed/deferred queued fixture or other excluded fix is added. Do not reopen pv-bxh or closed pv-kv2.
5. State where this brief is actively wrong or contradicts itself, distinguishing a premise error (notes rule6) from a candidate objection. Give a concrete counterexample that breaks your pick or say none found. Give the strongest contrary argument ON REQUEST, labelled separately from your actual vote. No source build or test execution is required of readers.
6. End `Final Q1: <exact candidate>; acceptability Q-QUOTE ..., Q-POINTER ..., Q-KEEP ...` and `Final Q2: <landing choice>; acceptability L-BRIEF ..., L-NOTE ...`. State whether the exact matching appendix and comment authority line are accepted. Any complete alternative has its own name and full text. A requested counterargument is not a vote.

Five seats are configured: Fable, Opus, Astra, Sol, Grok. Grok’s one-word preflight is recorded in STATE.md before launch; a 402 means missing and three-of-four. A Fable limit line is missing, regardless of quota exemption; it cannot cancel other readers or lower the required three agreements. This is launch-only r96, with no r96b launch or implementation in this turn.
