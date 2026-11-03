# Panel r99 — PR #69's added `DOM-10` sentences against "Quote the sentence"

Pin: `efb40cc55ff04be693473914afd42ef68008fa15` (PR #69 head, branch `pv-5pmu`, over master `b5f71e78a1f195acfa4ac28f090d38e9a35568f0`). Your clone is detached at it.
Read every source with `git show efb40cc55ff04be693473914afd42ef68008fa15:<path>` in your clone and check the bytes yourself. Source
blocks below were sliced from those bytes by `check/build_brief.py`; form blocks are the form files'
bytes. Read `notes.md` first.

**apply notes.md rule 6 exactly as written; this prompt adds no void rule.**

Owner's settling rule, verbatim: "a question is settled when at least three agree and more agree than
disagree, and a tie comes to you. If grok is down, it falls back to three of four".

## 1. The story in plain terms

On 2026-10-30 the owner approved `pv-5pmu`'s wording (owner item 16, "Approve A (Recommended)"). It
adds four paragraphs to `DOM-10` saying when a non-create operation's capability is checked and
which error wins. On 2026-10-31 panel r93 corrected two of its sentences (the replay sentence and the
manual-release clause) to quote the requirements they described, because a review bot flagged them.
PR #69 lands the corrected wording word for word.

On 2026-11-03 the review bot flagged a third sentence of the same wording, at
`01-domain-model.md:575`: "PRV-25's identical-PTR success remains after its capability check." Its
finding (codex P1 4450997798, thread PRRT_kwDOT30eC86y-3YB) says the sentence restates `PRV-25`
without its own words, against `AGENTS.md` lines 29-32. The merge turn verified that `PRV-25`
supports the substance and that the sentence does not quote it, posted that as an evidence reply
(4451040045), and left the thread open. Under the owner's 2026-10-28 wording rule ("For such wording
questions, try to solve by getting a consensus of the panel"), a wording-only touch on adopted text
gets panel consensus first and goes to the owner only when there is no consensus.

So that round 2 does not surface a fourth sentence, the manager swept every line PR #69 adds and
listed every sentence that asserts what another requirement says without that requirement's words
(§3). This panel decides, for each listed sentence, whether to quote it (QUOTE), leave it (KEEP), or
use a complete exact alternative; and, if anything changes, how the approval record follows (Q-REC).
Part of your job is to say whether each option really is wording-only.

## 2. The rule, and what the gate checks

`AGENTS.md:29-32` and `:45-46` at the pin, verbatim:

`````text
**Quote the sentence.** A claim about what another requirement says carries that requirement's own
words. `` `WIR-30` says "The gate reads the copy the machine took at create" `` is checkable;
"`WIR-30` forbids resolving eligibility that way" is an assertion, and assertions of that shape were
false repeatedly on 2026-09-03 — `ddd3df0` and `254fc24` carry the cases and what each one cost.

**Cite the owner.** One rule, one home; everywhere else points at it.
`07-security-requirements.md`'s scope note holds the argument, and `SEC-46` is the standing example
of a second copy drifting until an amendment shipped claiming to have applied while the requirement
said the opposite. **Arguments have owners too** — re-explaining a rule in a second document is how
a second normative copy gets written, because you cannot explain a rule without restating it.

**Cite the list; let it hold the number.** A count written into prose is wrong the first time either
end moves. `ADR-0003`'s footnote, `ADR-0011` and `F16` in `11-open-findings.md` each record their
own version of this. The same applies to a universal: one counterexample retires it, and
`OVR-17` carried a false one for weeks.

**Completion:** every sentence asserting what another requirement says carries its quote, and every
list or count names its source instead of restating it.
`````

The citation gate (`tools/check_citations.py`) checks a quotation only in these shapes, with the ID in
backticks: `` `ID` says/said/states/stated/reads/read "…" ``, `` `ID`'s <rule|claim|wording|statement|sentence|words|text> that "…" ``,
`` `ID`'s "…" `` and `` `ID`: "…" ``; and only quotations of four or more normalized words. The first
speech attribution in a sentence owns every later quotation in that sentence. Summary verbs (forbids,
requires, names, …) are outside its reach by design. The landed DOM-10 block writes IDs without
backticks, so r93's two quotations ("API-7 step 5a says", "API-65 says") are outside the gate's reach;
the manager checked both by hand against `04-api-contract.md:209` and `:1168` at the pin (whitespace
normalized) and they match. Every QUOTE form below uses the backticked shape so the gate checks it
(§7). That is a style difference from r93's two quotations; an ALT may differ.

## 3. The sweep

Method: `git diff b5f71e78a1f195acfa4ac28f090d38e9a35568f0 efb40cc55ff04be693473914afd42ef68008fa15` (`check/sweep-diff.txt`). It adds 39 lines to `01-domain-model.md`
(DOM-10, :540-577), three to `03-operation-lifecycle.md` (OPS-23, :2081-2082) and two to
`04-api-contract.md` (API-7, :243), and changes pv-5pmu's line in `.beads/issues.jsonl` (the bead closes).
Every added sentence was read against what it names.

The landed DOM-10 block at the pin (01-domain-model.md:540-577), verbatim:

`````text
For power on, power off, reboot, hard reset, every install strategy, rescue inventory,
reverse DNS, delete/cancel and API-cleanable attachment release, a caller or operator
request MUST pass the capability check before admission enqueues the operation. This check
runs after API-7's steps 1–5c and all endpoint-local admission validation and admissibility
checks, immediately before the enqueue transaction's first write. It uses the descriptor
running in api and makes no provider request. A failed check enqueues no operation and
makes no endpoint-state or money write. API-7 step 5a says "an equal fingerprint under the
    same `(principal, key)` returns the stored result, a different one fails `conflict`."; a replay returned there never reaches this check. An API-64 operator retry checks delete_machine before its state-change/enqueue
transaction; API-65 says "On a row whose `cleanup` is `manual` there is no driver call to make: it
writes `released_at` and answers `200` with the row, minting no operation,"; a manual attachment release takes no capability check under this timing rule.
A suspend parent takes no per-machine capability check at admission: its cancellation
children are gated at claim as below.

Every operation in the preceding paragraph MUST also pass the capability check in the
worker using the descriptor running there, including operations enqueued without an HTTP
request, API-64 retry attempts and attachment releases enqueued by a successful delete.
The check runs after claim and per-machine serialization, before the operation's first
driver call and before either OPS-45 marker is written. Repeated validation checks caller-
supplied fields first, api-written admission fields second, then the other applicable
local validation, including machine install eligibility and OPS-40's signed-URL check;
the capability check follows. The first failing check stops subsequent checks. A capability
refusal is classified by OPS-11 and carries DOM-10's existing unsupported result. This
paragraph introduces no commitment, rate or solvency check for a non-purchase.

For an exposure-reducing cancellation, OPS-41's restore claim gate and ordered fence-
transaction decision run before this capability check. A no-call success or defer returned
by that decision takes no capability check. A decision that proceeds to cancellation MUST
pass the capability check after the fence transaction is acknowledged and before any
driver call or write-started marker. Capability failure follows the existing failed-attempt
and episode disposition; it does not authorize another automatic attempt or clear a fence.
An internally enqueued operation takes no capability check at enqueue. API-7's operator
retry ceiling and OPS-39's system-ceiling exemption retain their existing scope.

The capability is the operation's entry in the mapping table. A rescue-based install checks
its strategy capability first and rescue_ssh second, before beginning rescue; an inventory
checks rescue_ssh. PRV-25's identical-PTR success remains after its capability check. No
capability is inferred from an install-eligibility list, and this timing rule adds no gate
to refresh, a manual attachment release, or the capability-less methods named by PRV-4.
`````

**Listed (asked as Q1–Q5).** Each describes what another requirement contains, in words that are not
that requirement's:

- Q1 `01-domain-model.md:575` — "PRV-25's identical-PTR success remains after its capability check." (the flagged sentence)
- Q2 `01-domain-model.md:547-548` — "An API-64 operator retry checks delete_machine before its state-change/enqueue transaction;" (describes API-64's transaction)
- Q3 `01-domain-model.md:560-561` — "A capability refusal is classified by OPS-11 and carries DOM-10's existing unsupported result." (says OPS-11 classifies it)
- Q4 `01-domain-model.md:565-566` — "A no-call success or defer returned by that decision takes no capability check." (describes what OPS-41's decision returns)
- Q5 `01-domain-model.md:576-577` — "…or the capability-less methods named by PRV-4." (says PRV-4 names capability-less methods)

**Considered and not listed** (the manager reads each as a name, label, position or pointer, not as a
statement of what the requirement says; any reader who disagrees may print a complete exact ALT
under an extra question, Q6, naming the span):

- `:542-543` "API-7's steps 1–5c" — a position in API-7's numbered list.
- `:547` and `:555` "API-64 operator retry" / "API-64 retry attempts" — names the operation API-64 defines.
- `:557` "either OPS-45 marker" — names OPS-45's markers (`03-operation-lifecycle.md:1502` "write-started marker", `:1513` "a second marker is required").
- `:559` "OPS-40's signed-URL check" — names a check.
- `:561` "DOM-10's existing unsupported result" — DOM-10 itself (`01-domain-model.md:516-519`).
- `:564-565` "OPS-41's restore claim gate and ordered fence-transaction decision" — names OPS-41's parts (`03-operation-lifecycle.md:994`, `:1021-1025`).
- `:568-569` "the existing failed-attempt and episode disposition" — names no requirement.
- `:570-571` "API-7's operator retry ceiling and OPS-39's system-ceiling exemption retain their existing scope." — a no-change statement; the labels match `04-api-contract.md:238` ("**`API-64`'s retry is not exempt**: it counts against `SEC-39`'s operator retry ceiling") and `03-operation-lifecycle.md:972-973` ("**Exposure-reducing system cancellations MUST be exempt from `SEC-39`'s per-principal destruction ceiling.**"). This is the closest call among the unlisted ones.
- `03-operation-lifecycle.md:2081-2082` and `04-api-contract.md:243` — pointers to DOM-10 ("Cite the owner").

**Already quoted:** `:546-547` (API-7 step 5a) and `:548-549` (API-65), r93's corrections, outside the
gate's reach but checked by hand (§2). **Pre-existing, not added by this PR:** `01-domain-model.md:516-517`
"the ones `PRV-4` names" is on master; it is out of this sweep.

## 4. Why r93 kept these spans unchanged

r93 was a wording panel on two flagged sentences only. Its record, read only, verbatim:

- `/var/tmp/provisiond-panel-r93/brief.md:9`:
`````text
Only pv-5pmu's adopted wording and its historical/executable copies are in scope. PR #53's other beads are out of scope. No text is applied, no tracker is changed and no PR is contacted this turn. A split or unsettled result gets ONE consensus round r93b in a later turn; do not launch it.
`````
- `/var/tmp/provisiond-panel-r93/brief.md:231`:
`````text
Pick one complete candidate. Each pair replaces only the replay sentence and the manual-release clause, leaving the API-64 retry clause and all other Q1-A bytes unchanged. Read the full derived forms `/var/tmp/provisiond-panel-r93/Q-QUOTE.md`, `Q-POINTER.md`, and `Q-KEEP.md`; they make the complete reviewed form explicit. A new proposal is a distinct form: print its exact full replacements and do not claim other readers reviewed it.
`````
- `/var/tmp/provisiond-panel-r93/assertion-map.md:274-276` (a byte-preservation audit: O = archived Q1-A, Q = Q-QUOTE.md, B = the prospective brief):
`````text
## 24. Identical-PTR success remains after capability

O:40 → Q:41 → B:66. Unchanged bytes.
`````
- `/var/tmp/provisiond-panel-r93/opus.md:211` (a reader's note):
`````text
- Unchanged clauses such as API-64's state-change/enqueue transaction and the OPS-41/PRV-25/OPS-39 references still paraphrase other requirements without quotes. Source text does support the API-64 clause (`04-api-contract.md:1053–1054`). They are out of scope here, but a later bot pass could flag them.
`````
- `/var/tmp/provisiond-panel-r93/tally.md:25` (on r93's own Q-KEEP for the two flagged sentences):
`````text
Strongest requested counterargument, not a vote: Q-POINTER avoids duplicated source material and awkward wrapping; Q-QUOTE's qualifier could look narrower in isolation. Verification: the original rule already has the same timing-rule scope and manual exclusion, and the replacement keeps the no-check instruction explicit. No reader proved the Q-KEEP exemption. The source facts being supported does not establish exemption from the quotation rule.
`````
- `/var/tmp/provisiond-panel-r93/tally.md:97`:
`````text
- Opus notes the pre-existing machine-local `owner-decisions-1030.md` authority reference and other unchanged paraphrases could attract later review. The former is pre-existing and owner authority is independently verified; the latter are outside this pair's scope. API-64's transaction source was checked at M `04-api-contract.md:1053–1054`; its existing clause remains byte-identical. Neither licenses weakening or enlarging this correction.
`````

The manager's fair reading: r93 kept these spans byte for byte because they were outside its two-
sentence scope, and one reader foresaw that a later bot pass could flag them; r93 did not rule on
whether they fall under the quotation rule. Two facts point the other way, and you should weigh them:
the owner approved the whole Q1-A text (item 16), and r93's settled package
(`/var/tmp/provisiond-panel-r93/settled-pv-5pmu.md`, SHA-256
`2c579a573654e9f5ded4d66a9e16eaa747dcef63ed1bbc9b68287ef652152f21`) deliberately retained "all other
Q1-A bytes unchanged". Also relevant: r93 rejected its own Q-KEEP for the two flagged sentences, which
had the same shape as Q1 ("A replay returned by API-7 step 5a never reaches this check" became a quotation).

## 5. The approval record

Owner item 16, verbatim (`/var/tmp/provisiond-manager/owner-decisions-1030.md:127-133`, machine-local):

`````text
16. **pv-5pmu (Panel G r86b Q1, picks 4–0 A, acceptance 4–0, owner approval of the added order)** — Q: "Panel G Q1
    (pv-5pmu): adopt A, the panel's exact wording for when support is checked and which error wins, or leave the text
    as it is?" A: **"Approve A (Recommended)"**. Option text: "Picked 4–0, accepted 4–0. All four readers (fable, opus,
    astra, sol) picked A: it settles the fence placement, the error order and the recheck order, which today's general
    rules don't spell out together. Exact form: r86b/Q1-A.md. Amends DOM-10, with pointers in API-7 and OPS-23."
    Rejected: "Keep text unchanged (C0)". Meaning: adopt exactly /var/tmp/provisiond-panel-r86/r86b/Q1-A.md (per
    r86b/owner-questions.md §1, pin 3109b5b). pv-5pmu → ready-for-agent with that package as its brief.
`````

`docs/research/panels-2026-10/r86/r86b/Q1-A.md` at the pin holds the original form (Q1's sentence at
`:40`) and r93's dated note "## Wording correction — 2026-10-31 (Panel N r93)" (`:61-83`). pv-5pmu's
Agent Brief comment 856 (status `closed` at the pin) is `evidence/pv-5pmu-comment-856.md`, byte-equal
to the comment's `text` in `.beads/issues.jsonl` at the pin; its line 6 reads:

`````text
**Owner decision:** “Approve A (Recommended)” (`owner-decisions-1030.md`, item 16). Historical adopted form: `docs/research/panels-2026-10/r86/r86b/Q1-A.md`. Executable form: the Desired behavior / key interfaces block below, with the 2026-10-31 Panel N r93 wording correction.
`````

Its "Desired behavior / key interfaces" block (lines 31-68, inside the text fence at :30 and :69) is byte-equal to the landed DOM-10 block
(checked by `check/build.py`). Each Q1–Q5 OLD span occurs exactly once in it.

The evidence reply already posted on the thread (4451040045), verbatim:

`````text
Verified. PRV-25 (`02-provider-contract.md:873-875` at efb40cc) says "After the ordinary authorization, capability and `API-16` validation, the worker MUST compare the requested PTR value with the machine's recorded value for that address under `OPS-8`'s serialization. An identical established value MUST settle `succeeded` without a provider call." The sentence's substance is supported by that text, and the sentence does restate PRV-25 without quoting it, which `AGENTS.md` lines 29-32 ask against.

The sentence belongs to the owner-adopted DOM-10 wording for pv-5pmu (the approved text in comment 856, applied word for word in this PR). A change to adopted wording goes to a wording review before it lands, so this PR does not edit it here. This thread stays open until that review settles the form.
`````

## Q1 — the PRV-25 sentence (flagged)

Landed span (01-domain-model.md:575 at the pin), `Q1-OLD.txt`, SHA-256 `e339d2da45ec1e737a219aa0e4486188ffd47cf3a78e85d712935e0b73be9645`:

`````text
PRV-25's identical-PTR success remains after its capability check.
`````

Source, verbatim at the pin:

`02-provider-contract.md:869-876` (PRV-25):

`````text
**PRV-25** The caller-supplied IP MUST have been verified by the control plane to belong
to the machine before the driver is called (`API-16`). The driver MUST still encode it
into the request path safely (`PRV-6`).

After the ordinary authorization, capability and `API-16` validation, the worker MUST compare
the requested PTR value with the machine's recorded value for that address under `OPS-8`'s
serialization. An identical established value MUST settle `succeeded` without a provider call.
Result shape: `WIR-10`. A missing or unknown value is not equality.
`````

Quoted segments and where they sit (checked by `check/build.py` with whitespace-insensitive matching, each found exactly once):

- `02-provider-contract.md:873`: "After the ordinary authorization, capability and `API-16` validation"
- `02-provider-contract.md:875`: "An identical established value MUST settle `succeeded`"

**Q1-QUOTE** (`Q1-QUOTE.txt`, SHA-256 `4c0cbffbf91643afc682f63211c82ae400928e101dd9b4d48aa8e11a49d5419e`, pin `efb40cc55ff04be693473914afd42ef68008fa15`), the exact bytes replacing the span:

`````text
`PRV-25` says "After the ordinary authorization, capability and `API-16` validation" and "An identical established value MUST settle `succeeded`"; that identical-PTR success remains after its capability check.
`````

**Q1-KEEP** (`Q1-KEEP.txt`, SHA-256 `8d131e40a08e6617adbd454b99f9afe973564ab15d456f562ffbe8a6e1c5bc80`, pin `efb40cc55ff04be693473914afd42ef68008fa15`):

`````text
KEEP: no byte changes. 01-domain-model.md:575 stays exactly as landed at efb40cc55ff04be693473914afd42ef68008fa15. Main answers review thread PRRT_kwDOT30eC86y-3YB (codex P1 4450997798) with the panel's evidence and resolves it.
`````

QUOTE carries both halves the sentence relies on: the ordering ("After … capability …") and the success ("settle `succeeded`"). KEEP rests on the sentence not being a claim the rule covers, or on r93 / owner item 16 having decided it (§4).

## Q2 — the API-64 transaction

Landed span (01-domain-model.md:547-548 at the pin), `Q2-OLD.txt`, SHA-256 `12190045a02e094e0c26f8556f7c008eb09bddd7533710f3f10a7d1c634d9ac6`:

`````text
An API-64 operator retry checks delete_machine before its state-change/enqueue
transaction;
`````

Source, verbatim at the pin:

`04-api-contract.md:1109-1118` (API-64):

`````text
**API-64** **ADDED 2026-09-08 (`ADR-0017`) — a stalled episode is retried by an operator, and by
nothing else.** `POST /v1/episodes/{id}/actions/retry` (`WIR-51`) is **operator-only** (`WIR-34`)
and is admissible only on an episode in `stalled` (`DOM-31`): it moves the episode to `attempting`
**by a conditional write guarded on `(id, state = stalled)`** and enqueues a fresh `delete_machine`
attempt under it, both in one transaction, and answers `200`
with the episode view. In any other state — including where that write affects no row because a
gone-write closed the episode after the operator read it (`OPS-48`, `ADR-0021`) — it is refused
`409` `conflict` with `details.reason: "state"`. It is idempotent under `WIR-24`'s one-transaction rule — the state change, the enqueue and
the idempotency record commit together — and it counts against `SEC-39`'s operator retry ceiling
(`API-7` step 5c). **A `stalled` episode is never retried by a timer** (`OPS-48`): the attempt
`````

Quoted segments and where they sit (checked by `check/build.py` with whitespace-insensitive matching, each found exactly once):

- `04-api-contract.md:1116-1117`: "the state change, the enqueue and the idempotency record commit together"

**Q2-QUOTE** (`Q2-QUOTE.txt`, SHA-256 `2b46b8b8d673696e3a4668f96be33fe3e2da919431613e22188cb35793b4adc6`, pin `efb40cc55ff04be693473914afd42ef68008fa15`), the exact bytes replacing the span:

`````text
`API-64` says "the state change, the enqueue and the idempotency record commit together". An API-64 operator retry checks delete_machine before its state-change/enqueue
transaction;
`````

**Q2-KEEP** (`Q2-KEEP.txt`, SHA-256 `e3d78fbf0b44b7cd667f0a418c3b5b15b03c4cf067aa5ab9d033a1d8ed4f82f8`, pin `efb40cc55ff04be693473914afd42ef68008fa15`):

`````text
KEEP: no byte changes. The 01-domain-model.md:547-548 span stays exactly as landed at efb40cc55ff04be693473914afd42ef68008fa15. No thread exists for it; nothing is posted.
`````

QUOTE inserts one sentence before the landed sentence and keeps its bytes; it ends with a full stop so that the gate does not assign API-65's later quotation in the same landed sentence to API-64. KEEP rests on the clause being a new DOM-10 timing rule that only names API-64's transaction.

## Q3 — "classified by OPS-11"

Landed span (01-domain-model.md:560-561 at the pin), `Q3-OLD.txt`, SHA-256 `cd8ff6fa74350e7edb89f869b4080b46bcb1fce28f22e20d750810848e32db37`:

`````text
A capability
refusal is classified by OPS-11 and carries DOM-10's existing unsupported result.
`````

Source, verbatim at the pin:

`03-operation-lifecycle.md:240-241` (OPS-11 lead):

`````text
**OPS-11** On failure, the system MUST classify the error into `failed` or
`needs_reconciliation` using the operation kind and the error kind:
`````

`03-operation-lifecycle.md:250` (OPS-11, the last row):

`````text
| power, reverse-DNS, delete, release attachment | Subject to the goal-state success rule, any failure the worker records while `OPS-45`'s write-started marker is unset, where no rescue session was opened or the one opened was closed without error, MUST settle `failed`, whatever its kind (`OPS-45`, which owns the rule), unless the mutation is known to have been accepted (`details.accepted` is `true`). Otherwise `needs_reconciliation` if the failure is *ambiguous*, otherwise `failed`. A release is a delete of a smaller thing (`PRV-45`) and classifies exactly as one. |
`````

Quoted segments and where they sit (checked by `check/build.py` with whitespace-insensitive matching, each found exactly once):

- `03-operation-lifecycle.md:240-241`: "the system MUST classify the error into `failed` or `needs_reconciliation`"

**Q3-QUOTE** (`Q3-QUOTE.txt`, SHA-256 `7119ff65a407c649f8ccbd413d31ecb16b5f9eefde3f4321f8a49e569b8739e6`, pin `efb40cc55ff04be693473914afd42ef68008fa15`), the exact bytes replacing the span:

`````text
A capability
refusal is classified by OPS-11 and carries DOM-10's existing unsupported result; `OPS-11` says "the system MUST classify the error into `failed` or `needs_reconciliation`".
`````

**Q3-KEEP** (`Q3-KEEP.txt`, SHA-256 `d8a232a628594f4bd1f261fcf2b3cf8fb7477ec0369e4a9598c06a66d9525f0c`, pin `efb40cc55ff04be693473914afd42ef68008fa15`):

`````text
KEEP: no byte changes. The 01-domain-model.md:560-561 span stays exactly as landed at efb40cc55ff04be693473914afd42ef68008fa15. No thread exists for it; nothing is posted.
`````

QUOTE appends OPS-11's own lead words. KEEP rests on "classified by OPS-11" being a pointer to the owner ("Cite the owner") rather than a statement of what OPS-11 says.

## Q4 — OPS-41's no-call success or defer

Landed span (01-domain-model.md:565-566 at the pin), `Q4-OLD.txt`, SHA-256 `8f673c0a119baeb0677a6ecff4cc4947e29f8c11d5af415835953682d7ad89b7`:

`````text
A no-call success or defer returned
by that decision takes no capability check.
`````

Source, verbatim at the pin:

`03-operation-lifecycle.md:994` (OPS-41):

`````text
**OPS-41** **An exposure-reducing cancellation MUST apply the ordered decision below under the fence.**
`````

`03-operation-lifecycle.md:1001-1005` (OPS-41, the no-call success):

`````text
`runway_until` — **in the same serialized transaction that writes `OPS-42`'s fence**, without which
the extension it is racing can commit between the read and the write. Where re-deriving `LDG-33`
from what it read now puts **`runway_until` strictly in the future**, the worker MUST make no
provider call, settle the operation `succeeded` with a result recording that no mutation was
required, **write that re-derived `runway_until` to the machine row** (*withdrawn 2026-09-25,
`````

`03-operation-lifecycle.md:1021-1026` (OPS-41, the claim defer):

`````text
**A claim made while a restore record is open and its `grace_ends_at` is null or in the future
defers, and writes no fence** (*added 2026-09-25, `ADR-0028`*). A worker claiming **any**
exposure-reducing cancellation MUST read the restore record (`STO-56`) at each such claim, before
the fence transaction above, and while a restore record is open and its `grace_ends_at` is null or
in the future the claim MUST defer: the operation is returned to `queued` with `available_at =
grace_ends_at` where the instant is set, and by `OPS-8`'s ordinary short delay where it is not yet
`````

Quoted segments and where they sit (checked by `check/build.py` with whitespace-insensitive matching, each found exactly once):

- `03-operation-lifecycle.md:1003-1004`: "the worker MUST make no provider call, settle the operation `succeeded`"
- `03-operation-lifecycle.md:1025`: "the claim MUST defer"

**Q4-QUOTE** (`Q4-QUOTE.txt`, SHA-256 `06392de56a1eb54ff3e45e435f0c81f86d3053f5a92d1cb04328276dbeaee10d`, pin `efb40cc55ff04be693473914afd42ef68008fa15`), the exact bytes replacing the span:

`````text
`OPS-41` says "the worker MUST make no provider call, settle the operation `succeeded`" and "the claim MUST defer"; a no-call success or defer returned
by that decision takes no capability check.
`````

**Q4-KEEP** (`Q4-KEEP.txt`, SHA-256 `230d598ccbb5634c9846500e948d8c0cbd737728308f421c035e3789e744f4c3`, pin `efb40cc55ff04be693473914afd42ef68008fa15`):

`````text
KEEP: no byte changes. The 01-domain-model.md:565-566 span stays exactly as landed at efb40cc55ff04be693473914afd42ef68008fa15. No thread exists for it; nothing is posted.
`````

QUOTE carries OPS-41's words for each outcome and keeps the landed sentence's bytes after them. Note that the defer comes from OPS-41's restore claim gate, not its fence-transaction decision; the landed "that decision" spans both (`:564-565`), and QUOTE does not change that. KEEP rests on the sentence being a DOM-10 rule about what takes a check, naming outcomes rather than saying what OPS-41 says.

## Q5 — the methods PRV-4 names

Landed span (01-domain-model.md:577 at the pin), `Q5-OLD.txt`, SHA-256 `9600d5d0ba7b7a0c833a76310fbe5da1d7a86e291192a2e9c5fda475e57e51a9`:

`````text
or the capability-less methods named by PRV-4.
`````

Source, verbatim at the pin:

`02-provider-contract.md:25-29` (PRV-4):

`````text
**PRV-4** A driver MUST NOT declare a capability it does not implement, and — for every
operation with a capability entry in `DOM-10`'s table — MUST NOT implement one whose capability
it does not declare (`DOM-15`). The three methods with no entry there — *describe capabilities*,
*get machine* and *refresh rescue session* — are outside the second clause; `PRV-2` and `PRV-3`
govern them. An ordering capability that `DOM-16` withholds from an account whose `allow_orders` is false is not declared for that account, and a driver that implements it breaches neither this requirement's second clause nor `DOM-15`.
`````

Quoted segments and where they sit (checked by `check/build.py` with whitespace-insensitive matching, each found exactly once):

- `02-provider-contract.md:27-28`: "The three methods with no entry there — *describe capabilities*, *get machine* and *refresh rescue session*"

**Q5-QUOTE** (`Q5-QUOTE.txt`, SHA-256 `eb1d82e154dc6945c61f7b7878ae0238ee288732d06e5bc4e6889a5fc3c3482b`, pin `efb40cc55ff04be693473914afd42ef68008fa15`), the exact bytes replacing the span:

`````text
or the capability-less methods named by PRV-4; `PRV-4` says "The three methods with no entry there — *describe capabilities*, *get machine* and *refresh rescue session*".
`````

**Q5-KEEP** (`Q5-KEEP.txt`, SHA-256 `49a3adf34de880cb20d3b47eeee30f58f7b7aeb5958a8e667feeb6ce71fb3f27`, pin `efb40cc55ff04be693473914afd42ef68008fa15`):

`````text
KEEP: no byte changes. The 01-domain-model.md:577 span stays exactly as landed at efb40cc55ff04be693473914afd42ef68008fa15. No thread exists for it; nothing is posted.
`````

QUOTE appends PRV-4's list. KEEP rests on "Cite the list; let it hold the number" (`AGENTS.md:40-43`): pointing at the list's owner instead of restating it is that rule's own form, and master's `01-domain-model.md:516-517` already says "the ones `PRV-4` names".

## Q-REC — how the record follows

Answer this only conditionally: it applies if any of Q1–Q5 settles on a non-KEEP form, because then
the landed text differs from comment 856 and from the r93 package. The precedent is owner item 25,
which chose r97's Q4 "Add dated archive note (Recommended)" (r97's L-NOTE). Pick one, or print a
complete exact ALT. All three leave the archived r93 record unchanged.

**R-NOTE** (`R-NOTE.txt`, SHA-256 `6e6a167b06d2df2d3a1d45dd0a0ee8d2c2ff005a8e5bbd3ffa3a6e446e3b413b`, pin `efb40cc55ff04be693473914afd42ef68008fa15`):

`````text
Fix commit on branch pv-5pmu, in PR #69: (1) in 01-domain-model.md replace each selected Qn-OLD.txt span with its selected Qn-QUOTE.txt bytes; (2) in the text of pv-5pmu comment 856 in .beads/issues.jsonl replace the same spans with the same bytes, changing no other field, comment or bead; (3) append exactly R-NOTE-append.md to docs/research/panels-2026-10/r86/r86b/Q1-A.md, all original bytes remaining an exact prefix; (4) archive the reviewed r99 record at docs/research/panels-2026-10/r99/. The archived r93 record stays unchanged. No branch or tracker edit occurs in this panel turn.
`````

`R-NOTE-append.md` (SHA-256 `02dcd93d7347976e0934b235e3c428a26796a287bfff91d2a37ab003ca58d298`), the exact bytes appended (it begins with two newlines):

`````markdown


## Wording correction — 2026-11-03 (Panel r99)

The text above, with the 2026-10-31 Panel N r93 correction, is retained as the historical
form approved in owner item 16; its original bytes remain unchanged. Under the owner's
2026-10-28 wording rule (“For such wording questions, try to solve by getting a consensus of
the panel”), the landed `DOM-10` text and the pv-5pmu Agent Brief use the exact replacements
selected in the panel record below. This note grants no independent authority to change a
requirement; any substantive unresolved conflict returns to the owner.

Source pin: `efb40cc55ff04be693473914afd42ef68008fa15`.
Panel record: `../../r99/notes.md`.
`````

`check/prospective-Q1-A.md` shows the result; the pinned Q1-A.md bytes are its exact prefix.

**R-BRIEF** (`R-BRIEF.txt`, SHA-256 `33e383dd7d1bddc691fa89d8685a4f3f539084106db10914752201c8fd13ad40`, pin `efb40cc55ff04be693473914afd42ef68008fa15`):

`````text
Fix commit on branch pv-5pmu, in PR #69: (1) and (2) exactly as R-NOTE; leave docs/research/panels-2026-10/r86/r86b/Q1-A.md unchanged, with no note; (4) archive the reviewed r99 record at docs/research/panels-2026-10/r99/. The archived r93 record stays unchanged. No branch or tracker edit occurs in this panel turn.
`````

**R-ARCHIVE** (`R-ARCHIVE.txt`, SHA-256 `15d0281707c66b533cf46a38e4b71a4ca5d4ba9bac28dd9b54c98335290df635`, pin `efb40cc55ff04be693473914afd42ef68008fa15`):

`````text
Fix commit on branch pv-5pmu, in PR #69: (1) exactly as R-NOTE; leave comment 856 and docs/research/panels-2026-10/r86/r86b/Q1-A.md unchanged as historical records of the closed bead; (4) archive the reviewed r99 record at docs/research/panels-2026-10/r99/, which alone records the divergence. The archived r93 record stays unchanged. No branch or tracker edit occurs in this panel turn.
`````

For the all-QUOTE case, `check/prospective-comment-856-allquote.md` and
`check/prospective-DOM10-allquote.md` show the exact resulting text (`forms.sha256` lists every file's
SHA-256). A subset of QUOTE forms changes only its own spans.

## 7. Citation trial (scratch clones of the pin, `check/trial.py`, results `check/trial.json`)

The lake index came read only from the pv-5pmu Run's trial; `tools/formal` and the gate are
byte-equal to that source at the pin. Every run below is `python3 tools/check_citations.py`.

- T0, the pin as is: exit 0; 360 Markdown quotations compared; unquoted attributions 22, none new against baseline 22.
- T1, all five QUOTE forms: exit 0; 367 compared (the seven new quotations); unquoted 22, none new.
- T-Q1 … T-Q5, each QUOTE form alone: exit 0.
- T2, T1 plus R-NOTE's Q1-A.md append: exit 0.
- N-Q1 … N-Q5, negative controls (T1 with one word of that question's first quotation replaced by WRONGWORD): exit 1 each, naming that question's owner (PRV-25, API-64, OPS-11, OPS-41, PRV-4). Every QUOTE form is in the gate's reach.

KEEP is T0.

## 8. Your answer

For each of Q1, Q2, Q3, Q4, Q5 and Q-REC (and any Q6 you open):

1. Final pick: one label (Qn-QUOTE, Qn-KEEP, R-NOTE, R-BRIEF, R-ARCHIVE) or a complete exact ALT
   printed in full with its exact span.
2. ACCEPT or CANNOT ACCEPT for every printed option, separately from the pick.
3. Whether the picked form is wording-only: no behavior, requirement or check-strength change (rule 3).
4. The strongest reason, with file:line at the pin.
5. Any brief error you verified, and whether it changes the question's premise (rule 6).
