# Settled pv-gvc wording — Panel Q r96, 2026-11-02

Q1 **Q-QUOTE** and Q2 **L-NOTE** settle 3–0: Opus, Astra and Sol all prefer and accept these exact supplied forms. Fable's limit line and Grok's HTTP402 are missing seats, not votes. All agreeing readers and the independent tally audit classify both picks wording-only in behavior, owner-item13/frozen-Q1-B meaning and check strength. No assertion is weakened and no deferred-operation guard fix is added. Owner's 2026-10-28 rule, “For such wording questions, try to solve by getting a consensus of the panel”, settles this correction without an owner question. Nothing is applied to the tracker or branch by this document.

Pin: `f8a30457eb84b3077e7580732bef665b3763aae1`. Both origin/master and pv-gvc still resolve to this pin. See tally.md, check/tally-evidence.md and check/tally-verification.json for the complete occurrence inventory, assertion mapping, quotation audit and rule6 disposition.

## Preparation commit on pv-gvc, before the Run

1. `.beads/issues.jsonl`: the physical row is 94 at this pin, issue pv-gvc, comment id853. Replace only decoded comment line6 (authority below) and decoded lines57–59 (target below). Whole resulting decoded text must equal `check/prospective-agent-brief.md`. Preserve every other comment/issue field and all other rows. Re-resolve comment identity if the ref moves rather than trusting the physical row number.
2. `docs/research/panels-2026-10/r83/check/settled-Q1-B.txt`: append the exact dated note bytes below immediately after the existing final LF at line35. Existing lines1–35 / 2,644 bytes remain an exact prefix; do not substitute within that historical prefix. The resulting file must equal `check/prospective-archive.md`. The new appendix occupies lines36–58 (two leading blank lines; heading38; replacement payload53–57).
3. Archive the reviewed r96 record, including notes.md, brief.md, the three substantive answers and missing-seat receipts, tally.md, this settlement/hash, check/tally-evidence.md, byte-check receipts and exact selected executable package. This fulfills L-NOTE's dependency: the link `../../r96/notes.md` from r83/check must resolve to `docs/research/panels-2026-10/r96/notes.md`. Preserve the original approval/votes/owner records. Do not edit the external /var/tmp/provisiond-panel-r83 folder.

This is a preparation commit in pv-gvc's same PR, followed by the Run turn. The preparation changes no normative source text. Apply gates against actual changes then; this tally's gates checked the unchanged baseline.

## Exact target substitution for executable text

Old target (comment853:57–59; frozen package and archived copy:31–33):

`````text
A claimed create first picked up while the
tenant is suspended follows OPS-43's tenant-status refusal, not a purchase; it is not required
to succeed merely because its claim defeated the administrative write.
`````

Exact new target (comment853:57–61; executable package:31–35):

`````text
A claimed create first picked up while the
tenant is suspended follows OPS-43's tenant-status refusal, not a purchase (OPS-43 says “Where the tenant is suspended, fail this existing
   create with conflict, details.reason: "tenant_suspended", and retryable: false on both the error
   and operation view.”); it is not required
to succeed merely because its claim defeated the administrative write.
`````

The OPS-43 quotation payload is exactly172 UTF-8 bytes from 03-operation-lifecycle.md:786–788 at the pin. Preserve LF and intrinsic three-space continuation indentation. At future CNF-202 landing add only the existing six-space outer list-container indent to each line; stripping exactly those six spaces must restore the payload. No whitespace normalization.

The case scope, refusal clause, `not a purchase` and no-success-obligation clause retain all their operative words. The latter two are the adopted package's own case/race expectations, not direct quotations about the administrative race from OPS-43. The new parenthetical provides evidence for the existing OPS-43 attribution. Ordered-check precedence remains unchanged; an earlier account refusal still wins. No blanket rule that every claim winner fails is added.

## Exact authority-line substitution

Old decoded line6:

`````text
**Owner decision:** “B: say it explicitly (Recommended)” (`owner-decisions-1030.md`, item 13). Adopted exact form: `docs/research/panels-2026-10/r83/check/settled-Q1-B.txt`.
`````

New decoded line6:

`````text
**Owner decision:** “B: say it explicitly (Recommended)” (`owner-decisions-1030.md`, item 13). Original adopted form: `docs/research/panels-2026-10/r83/check/settled-Q1-B.txt`. Executable wording: Panel Q r96, Q-QUOTE; the original package remains the historical approval record.
`````

## Exact Run instruction and complete executable package

The following instruction must accompany the Run:

> Implement pv-gvc using the corrected Agent Brief comment853 committed by the r96 preparation turn. Its complete Desired behavior and Acceptance criteria text is the exact Q-QUOTE package below, also recorded as r96/check/prospective-run-package.txt. This executable package supersedes frozen r83 Q1-B lines31–33 for execution only; use its quoted replacement, not the old unquoted OPS-43 sentence. The frozen original and its dated appendix are approval/provenance records. Preserve the existing PR65 worker/dispatch and account-precedence cases and the held-power scenario. Item13's deferred-operation guard fix remains excluded. No other substitution is authorized by this wording settlement.

Read this complete package, not only the original frozen file:

`````text
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
`````

At the pin, API-58's insertion follows 04-api-contract.md:651. CNF-202's append goes before the existing amendment at 10-conformance-checklist.md:2326. Those source lines are future Run insertion locations, not preparation edits.

## Exact dated appendix bytes

The append payload starts with two LF bytes before its heading, as enclosed below. It is exactly `note-Q-QUOTE.md` (1,295 bytes). Do not add or remove a leading or final LF.

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

The archive keeps the original sentence at31–33 and quotes it as history at45–47; the executable replacement is at53–57. These historical occurrences are not instructions to write the old sentence. There is no other live summary requiring a correction: LDG-32's two attributions already carry exact source words; historical OPS-11 is inside the original dated API-58 quotation. The audit discloses unchanged display reflows in the insertion locator and rejected-option history and does not claim they are raw-byte exact.

## Prospective artifacts and diffs

Each file is built directly from the pin's bytes with only the settled substitutions; each diff compares against that pin's decoded original/comment or original archive/package.

- `check/prospective-agent-brief.md` — SHA-256 `afd0b829083d304e3b819788455b097c9bb02a8fc33542bdd4f151ff17586023`; diff `check/prospective-agent-brief.md.diff`.
- `check/prospective-archive.md` — SHA-256 `f72d58f480c00535197ba5b48cd9db7a2764772bb7627abdee739802ad6f4a6d`; diff `check/prospective-archive.md.diff`.
- `check/prospective-run-package.txt` — SHA-256 `21c7d08b5944f9b54a8c3fb1e6e5ad5eaceab33cd4953b1a241b30d78cd0a5bd`; diff `check/prospective-run-package.txt.diff`.

Next step: apply turn (preparation commit on pv-gvc), then the Run turn. No owner question, r96b, tracker write, branch change or adoption occurs in this tally.
