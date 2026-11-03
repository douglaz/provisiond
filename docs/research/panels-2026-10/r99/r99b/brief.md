# Panel r99b — the one consensus round on Q2, Q4 and Q-REC

Pin: `efb40cc55ff04be693473914afd42ef68008fa15` (unchanged from r99: PR #69 head, branch `pv-5pmu`). Your clone is detached at it.
Read sources with `git show efb40cc55ff04be693473914afd42ef68008fa15:<path>` in your clone and check the bytes yourself. Every block
below is sliced from r99's frozen brief, from the pinned sources or from form files by the
manager's build script (fenced, because it holds the seat map); none was retyped. Relative paths inside r99's sections (`Qn-*.txt`,
`R-*.txt`, `R-NOTE-append.md`, `check/`, `evidence/`, `forms.sha256`) resolve from r99's folder
`/var/tmp/provisiond-panel-r99`; r99b's new form files are in `/var/tmp/provisiond-panel-r99/r99b/forms/`.
Read r99b's `notes.md` first.

**apply notes.md rule 6 exactly as written; this prompt adds no void rule.**

Owner's settling rule, verbatim: "a question is settled when at least three agree and more agree than
disagree, and a tie comes to you. If grok is down, it falls back to three of four"

## 1. Where r99 left things

Fable answered with a usage-limit line and Grok returned HTTP 402 (re-probed for this round: still
402), so both are missing seats. Three readers answered in full; their answers are in §5 as
Reader A, Reader B and Reader C, without names. Three present seats means a question settles only
when all three make the same exact final pick (3–0).

- **Settled 3–0 and not reopened here:** Q1 on Q1-QUOTE (`Q1-QUOTE.txt`, sha256
  `4c0cbffbf91643afc682f63211c82ae400928e101dd9b4d48aa8e11a49d5419e`); Q3 on Q3-KEEP and Q5 on Q5-KEEP (no bytes change). No reader opened a Q6.
- **Q-REC applies**, because Q1 settled on a non-KEEP form.
- **Split 2–1, asked again here:** Q2, Q4 and Q-REC. This is their one consensus round (notes rule 4);
  there is no r99c. A question that does not settle here goes to the owner.

| Question | Reader A | Reader B | Reader C | Printed forms every reader ACCEPTED in r99 |
|---|---|---|---|---|
| Q2 | Q2-KEEP | Q2-KEEP | Q2-QUOTE | Q2-QUOTE and Q2-KEEP |
| Q4 | Q4-KEEP | Q4-KEEP | Q4-ALT (new; C cannot accept KEEP) | Q4-QUOTE (Q4-ALT was read by C only) |
| Q-REC | R-NOTE | R-NOTE | R-NOTE-ALT (new; C cannot accept R-BRIEF or R-ARCHIVE) | R-NOTE (R-NOTE-ALT was read by C only) |

Acceptance does not choose a form (notes rule 2): only the same exact final pick from all three settles.

## 2. The exact disagreements

### Q2 (`01-domain-model.md:547-548`): add API-64's words before the clause, or keep it

- Reader C (QUOTE): "the rule depends on one fact about `API-64`, that the state change and the enqueue form a single transaction."
  and "It states that fact in a coined term: "state-change/enqueue" appears in no root requirement except `01-domain-model.md:547`."
  It also says: "the main predicate is `DOM-10`'s own, so I accept KEEP."
- Reader A (KEEP): "the operative assertion is DOM-10’s own placement rule: “checks delete_machine before its state-change/enqueue transaction.” “API-64 operator retry” identifies the operation, and “state-change/enqueue transaction” identifies the boundary."
- Reader B (KEEP): "“Its state-change/enqueue transaction” identifies the transaction before which that new check runs. It does not independently specify the transaction’s atomicity or idempotency semantics."

### Q4 (`01-domain-model.md:565-566`): quote OPS-41's outcomes, and if so which words

- Reader C (Q4-ALT): ""returned by that decision" has the same shape as r93's "returned by API-7 step 5a", so I cannot accept KEEP."
  On Q4-QUOTE: "Its defect is incomplete evidence." Reader C also reported the brief error in §3 below and
  judged it premise-changing.
- Reader A (KEEP): "The operative rule is DOM-10’s “takes no capability check” (`01-domain-model.md:565`). It applies to outcomes obtained from the preceding gates; it does not prescribe their predicates."
- Reader B (KEEP): "“A no-call success or defer returned by that decision” identifies the applicable outcomes conditionally; the sentence does not restate their triggering conditions."

### Q-REC: how the record follows

- Reader C (R-NOTE-ALT): "R-NOTE is acceptable and follows the right precedent, but it has three record defects:"
  (its three defects are in §5; they are checked in the Q-REC disclosures below).
- Reader A (R-NOTE): "I prefer R-NOTE because it synchronizes the executable block and leaves a dated explanation at the historical form’s existing location."
- Reader B (R-NOTE): "R-NOTE preserves the original archive bytes, keeps the executable brief synchronized, and adds a direct route from the historical form to the later correction."

## 3. Every exact option, in full

Each of the three sections below is sliced from r99's `brief.md` (lines 264-307, 352-406 and
448-495) and is followed by what r99b adds: the new forms a reader printed, and corrections.

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

### Q4: r99's note, withdrawn, and the corrected sources

r99's `brief.md:408` said, verbatim:

`````text
QUOTE carries OPS-41's words for each outcome and keeps the landed sentence's bytes after them. Note that the defer comes from OPS-41's restore claim gate, not its fence-transaction decision; the landed "that decision" spans both (`:564-565`), and QUOTE does not change that. KEEP rests on the sentence being a DOM-10 rule about what takes a check, naming outcomes rather than saying what OPS-41 says.
`````

Its first sentence's "words for each outcome" and its "Note that the defer comes from OPS-41's
restore claim gate, not its fence-transaction decision" are **wrong** (reported by Readers A and C;
verified by the manager). Reader B cited the decision's own deferrals (`:1133`, `:1153`) and read the
note as naming only the selected quotation's source. OPS-41's ordered fence-transaction decision has its
own no-call success and its own short deferrals, which r99 did not print. Also, "keeps the landed
sentence's bytes after them" is not literal: Q4-QUOTE and Q4-ALT both change the landed initial "A"
(`Q4-OLD.txt` begins `A no-call`) to "a". The landed span, Q4-KEEP and every form's bytes are
unchanged by this correction.

`03-operation-lifecycle.md:1099-1102` at the pin (the decision's lead):

`````text
**The worker decides in this order, inside the fence transaction and on what that transaction
reads, never on its claim snapshot.** The order holds for every exposure-reducing cancellation,
whatever reason the attempt was enqueued under, and the first step that applies decides.
Enqueue reason does not substitute for step 2's origin test:
`````

`:1104-1107` (step 1, a no-call success):

`````text
1. **The machine is recorded gone, or its episode is closed.** The worker makes no provider call and
   settles the attempt `succeeded` with a result recording that no mutation was required (`OPS-48`;
   a close is permanent). **It writes no `runway_until`**: the date the no-mutation case above
   writes is a re-derived one, and this step re-derives nothing.
`````

`:1113` (in step 2):

`````text
   Step 1 and the restore claim gate above remain ahead of this decision. The durable origin
`````

`:1117-1126` (step 3, including its no-mutation abort and its short deferral):

`````text
3. **A rate exists for the machine's currency** (`LDG-59`). The worker re-derives and applies the
   predicate above **first**. If funded, it performs the no-mutation abort and settlement above,
   including the re-derived date write, fence clearing and episode closure where applicable.
   **Only if the predicate would cancel**, and a restore record is open, its original
   `grace_ends_at` has passed, and the currency has accumulated less than one re-derivation
   interval of rate-present time since step (3), the worker MUST return the attempt to `queued`
   by `OPS-8`'s ordinary short delay. The paused check reads the restore record and currency
   history on this transaction's reads, including the returned rate it sees, never the claim's
   rate snapshot. It writes no new fence, makes no provider call, and neither settles the attempt
   nor closes its episode. Otherwise it proceeds to the existing fence and cancellation path.
`````

`:1132-1134` (step 4, a short deferral):

`````text
4. **There is no rate, and the outage's deadline has not passed** (`LDG-64` holds how the deadline
   is computed). The claim defers: the operation is returned to `queued` by `OPS-8`'s ordinary
   short delay, and no fence is written.
`````

`:1153-1156`:

`````text
**The short deferrals in steps 3 and 4 are not settlements.** The episode stays open and
`OPS-48` gains no row — a re-queued attempt has not settled — and each later eligible claim
decides again from step 1, so a suspension that joins the episode, a rate that returns and a
machine recorded gone are each seen at the next claim, with no wake-up to arrange. The original
`````

Where each quotation sits: Q4-QUOTE quotes `:1003-1004` (the no-mutation abort, which step 3 at
`:1118` invokes as "the no-mutation abort and settlement above") and `:1025` (the restore claim gate,
which `:1113` places ahead of the decision). Q4-ALT adds `:1153`. Neither quotes step 1's own words
(`:1104-1105`) or step 4's "The claim defers" (`:1133`); Reader C discloses the step 1 omission.

**Rule 6 handling (manager's reading, not a vote):** Reader C judged the error premise-changing.
Reader A judged it not, and said its vote relies on the forms' broad scope, not on the note. Reader B
read the note narrowly, as above, and said neither form should narrow the no-check rule to the
restore-claim branch. The manager did not
void Q4's r99 tally: the error is about how complete QUOTE's evidence is and changes no form's
bytes. This round prints the corrected sources. If main judges the error premise-changing, this
round's Q4 counts as the corrected re-ask instead.

**Q4-ALT** (Reader C's, new in r99; `r99b/forms/Q4-ALT.txt`, SHA-256 `c12991b321e6e9abc74e67dfebba3f16554ee8048ff09a0ca0895933614fa318`, pin `efb40cc55ff04be693473914afd42ef68008fa15`), the
exact bytes replacing the `Q4-OLD.txt` span:

`````text
`OPS-41` says "the worker MUST make no provider call, settle the operation `succeeded`", "the claim MUST defer" and "The short deferrals in steps 3 and 4 are not settlements"; a no-call success or defer returned
by that decision takes no capability check.
`````

Citation trial (r99b `check/trial-alt.py`, same method and read-only lake index as r99's §7, results
`r99b/check/trial-alt.json`): Q1-QUOTE + Q4-ALT, exit 0 (365 compared, unquoted attributions 22,
none new); Q1-QUOTE + Q2-QUOTE + Q4-ALT + R-NOTE-ALT's append, exit 0 (366 compared, none new); the
same with "The short deferrals" corrupted to "The short WRONGWORD", exit 1 naming `OPS-41`. Q4-ALT's
quotations are in the gate's reach.

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

### Q-REC: what r99b adds

Settled so far: Q1-QUOTE, Q3-KEEP and Q5-KEEP. So the all-QUOTE prospective files that r99 points to
above are **not** the result: Q3 and Q5 change nothing. The changed spans will be Q1 plus whichever
of Q2 and Q4 settle on a non-KEEP form (or come back so from the owner).

**R-NOTE-ALT** (Reader C's, new in r99; `r99b/forms/R-NOTE-ALT.txt`, SHA-256 `23c4c1f832289f9eb76dc09a8ecad61a8c8c1b3908d5a4d3f6cc94ff202ba720`, pin `efb40cc55ff04be693473914afd42ef68008fa15`):

`````text
Fix commit on branch pv-5pmu, in PR #69: (1) in 01-domain-model.md replace each settled Qn-OLD.txt span with its settled QUOTE or ALT bytes; a settled KEEP changes nothing; (2) in the text of pv-5pmu comment 856 in .beads/issues.jsonl replace the same spans with the same bytes, and on that comment's line 6 replace "with the 2026-10-31 Panel N r93 wording correction." with "with the 2026-10-31 Panel N r93 and 2026-11-03 Panel r99 wording corrections.", changing no other field, comment or bead; (3) append exactly the block below to docs/research/panels-2026-10/r86/r86b/Q1-A.md, all original bytes remaining an exact prefix; (4) archive the reviewed r99 record at docs/research/panels-2026-10/r99/. The archived r93 record stays unchanged. No branch or tracker edit occurs in this panel turn.
`````

Its appended block (`r99b/forms/R-NOTE-ALT-append.md`, SHA-256 `445f69c220bfcdefd455fb6447c2c5e93b76d16274a9c051e21b0423358b02ea`; it begins with two
newlines):

`````markdown


## Wording correction — 2026-11-03 (Panel r99)

The form approved in owner item 16 and the 2026-10-31 Panel N r93 correction above are retained
with their bytes unchanged. Under the owner's 2026-10-28 wording rule (“For such wording questions,
try to solve by getting a consensus of the panel”), the landed `DOM-10` text and the pv-5pmu Agent
Brief use the exact replacements selected in the panel record below. This note grants no independent
authority to change a requirement; any substantive unresolved conflict returns to the owner.

Source pin: `efb40cc55ff04be693473914afd42ef68008fa15`.
Panel record: `../../r99/notes.md`.
`````

Disclosures (checked by the manager at the pin; not changes to any option):

1. **ALT bytes.** R-NOTE's step (1) replaces spans with "its selected Qn-QUOTE.txt bytes", and R-BRIEF
   and R-ARCHIVE take step (1) from R-NOTE. If Q4 settles on Q4-ALT, those three name no bytes for
   it. R-NOTE-ALT's step (1) says "settled QUOTE or ALT bytes".
2. **The note's label.** R-NOTE's append says (its line breaks joined) "The text above, with the 2026-10-31 Panel N r93
   correction, is retained as the historical form approved in owner item 16". At the pin
   `docs/research/panels-2026-10/r86/r86b/Q1-A.md:61-65` reads:

`````text
## Wording correction — 2026-10-31 (Panel N r93)

The text above is retained as the historical form approved in owner item 16.
The executable pv-5pmu Agent Brief uses the following replacements under the
owner's 2026-10-28 wording rule; all other Q1-A text is retained.
`````

   so the pinned note gives the item-16 label to the text above it before r93's replacements.
   R-NOTE-ALT's append says instead "The form approved in owner item 16 and the 2026-10-31 Panel N
   r93 correction above are retained with their bytes unchanged."
3. **Comment 856, line 6.** R-NOTE, R-BRIEF and R-ARCHIVE leave it ending "with the 2026-10-31 Panel
   N r93 wording correction." (§5 of r99's brief prints the line). R-NOTE-ALT rewrites that ending
   to name r99 too. r93's package also rewrote line 6 (`/var/tmp/provisiond-panel-r93/settled-pv-5pmu.md:11`
   and its "Agent Brief authority-line replacement" section from `:48`).
4. **Owner item 25** (`/var/tmp/provisiond-manager/owner-decisions-1030.md:204-210`) asked for pv-9ecf
   "Add a dated archive note, or change the brief only?" and chose "Add dated archive note
   (Recommended)"; "Change the brief only" was rejected.
5. **Citation trial:** R-NOTE-ALT's append with Q1-QUOTE, Q2-QUOTE and Q4-ALT gives exit 0 (above).
   r99's T2 covered R-NOTE's append.

## 4. What to return

For each of Q2, Q4 and Q-REC:

1. A final pick: one printed label (Q2-QUOTE, Q2-KEEP; Q4-QUOTE, Q4-KEEP, Q4-ALT; R-NOTE, R-BRIEF,
   R-ARCHIVE, R-NOTE-ALT) or a new complete exact ALT printed in full. Say whether it changes your
   r99 pick, and why.
2. ACCEPT or CANNOT ACCEPT for every printed option, including Q4-ALT and R-NOTE-ALT, with a reason for
   each CANNOT ACCEPT. Keep your preference separate from what you can accept.
3. Any verified blocking loss under notes rule 3 in the picked form, or none.
4. Answer the other side's strongest argument (§2) directly.
5. Any brief error you find in this packet, with file:line, and whether it changes a premise.

Do not reopen Q1, Q3 or Q5, and open no Q6. Read only: no edits to your clone or anything else, no Git
mutation, no subagents, no Nix, no lake, no br. Write scratch only under your tmp folder. Your final
message is your answer.

## 5. r99's answers, verbatim

Each answer is copied byte for byte except where a seat name or a seat's scratch path appeared; those
are replaced by the visible marks `[seat]` and `[scratch]`. Nothing else is changed.

### Fable (missing seat: limit line)

`````text
You've reached your Fable limit. Switch to another model, or manage usage credits at https://claude.ai/settings/usage?from=cc_cli_limit_message, to continue.
`````

### Grok (missing seat)

The r99 preflight and this round's refreshed preflight both returned: "API error (status 402 Payment
Required): Grok Build usage balance exhausted".

### Reader A

``````markdown
Seat [seat] reviewed PR #69 at `efb40cc55ff04be693473914afd42ef68008fa15`. **FAIL as landed for Q1’s quotation compliance; no substantive amendment is needed.**

**apply notes.md rule 6 exactly as written; this prompt adds no void rule**

| Question | Final pick | QUOTE | KEEP | Pick is wording-only |
|---|---|---|---|---|
| Q1 | **Q1-QUOTE** | ACCEPT | CANNOT ACCEPT | Yes |
| Q2 | **Q2-KEEP** | ACCEPT | ACCEPT | Yes; unchanged |
| Q3 | **Q3-KEEP** | ACCEPT | ACCEPT | Yes; unchanged |
| Q4 | **Q4-KEEP** | ACCEPT | ACCEPT | Yes; unchanged |
| Q5 | **Q5-KEEP** | ACCEPT | ACCEPT | Yes; unchanged |

Conditional on any non-KEEP settlement:

| Question | Final pick | R-NOTE | R-BRIEF | R-ARCHIVE | Pick is wording-only |
|---|---|---|---|---|---|
| Q-REC | **R-NOTE** | ACCEPT | ACCEPT | ACCEPT | Yes |

These labels select the packet’s exact forms, without modifications.

**Q1.** The sentence describes an existing ordering and outcome, so the quotation rule applies directly. `AGENTS.md:29` says, “A claim about what another requirement says carries that requirement’s own words.” At `02-provider-contract.md:873`, PRV-25 says “After the ordinary authorization, capability and `API-16` validation”; at `:875`, it says “An identical established value MUST settle `succeeded` without a provider call.” Q1-QUOTE supplies the relevant words while preserving the ordering.

The strongest KEEP argument is the owner’s approval of the complete wording. But approval of its behavior does not establish an exception to the quotation convention. The pinned archive’s r93 note explicitly says “all other Q1-A text is retained” (`docs/research/panels-2026-10/r86/r86b/Q1-A.md:65`); retention does not establish that this particular attribution was reviewed and exempted. No verified premise error.

**Q2.** At `01-domain-model.md:547`, the operative assertion is DOM-10’s own placement rule: “checks delete_machine before its state-change/enqueue transaction.” “API-64 operator retry” identifies the operation, and “state-change/enqueue transaction” identifies the boundary. This is a reasonable application of `AGENTS.md:34`: “One rule, one home; everywhere else points at it.”

Q2-QUOTE is also acceptable: API-64’s “the state change, the enqueue and the idempotency record commit together” appears at `04-api-contract.md:1116`. The added sentence accurately documents that boundary without changing the capability-check placement. I prefer KEEP because the existing clause assigns timing rather than explaining the transaction’s implementation. No verified premise error.

**Q3.** “is classified by OPS-11” (`01-domain-model.md:561`) delegates classification to its owner; it does not reproduce or choose a classification outcome. OPS-11’s lead says “On failure, the system MUST classify the error into `failed` or `needs_reconciliation` using the operation kind and the error kind” (`03-operation-lifecycle.md:240`). Keeping the pointer preserves that complete classifier.

Q3-QUOTE accurately adds part of the lead and changes no classification. I accept it, but the quotation is unnecessary for this delegation. The reference to DOM-10’s own result is not a claim about another requirement. No verified premise error.

**Q4.** The operative rule is DOM-10’s “takes no capability check” (`01-domain-model.md:565`). It applies to outcomes obtained from the preceding gates; it does not prescribe their predicates. I prefer keeping that concise instruction. Q4-QUOTE is also acceptable because its excerpts are accurate and the broad no-check instruction remains.

There is a **verified error in the brief’s explanation**: deferral does not come exclusively from the restore claim gate. OPS-41 introduces its ordered decision with “inside the fence transaction” (`03-operation-lifecycle.md:1099`). Its step 3 says “the worker MUST return the attempt to `queued`” (`:1122`), and step 4 says “The claim defers: the operation is returned to `queued`” (`:1133`). Thus an attempt past the initial restore claim gate can still defer within the ordered decision.

**This does not change Q4’s premise and does not void its tally under rule 6.** Both printed forms retain the broad exclusion for a returned defer; neither restricts it to the initial restore gate. Correcting the explanation changes neither the available forms nor their scope. My vote relies on that broad scope, not the brief’s exclusive-origin claim.

There is also a minor byte-description error: Q4-QUOTE changes the retained sentence’s initial `A` to `a`, so “keeps … bytes” is not literally exact. That capitalization change is editorial and does not change the premise.

**Q5.** This is a list-owner pointer. `AGENTS.md:40` says “Cite the list; let it hold the number.” The landed wording at `01-domain-model.md:577` neither enumerates the methods nor repeats their count. I prefer KEEP on that basis, independently of the similar pre-existing wording.

Q5-QUOTE remains acceptable: the explicitly attributed list matches PRV-4’s “The three methods with no entry there — *describe capabilities*, *get machine* and *refresh rescue session*” (`02-provider-contract.md:27`). It is more duplication than this pointer needs, but introduces no different membership or gate. No verified premise error.

**Q-REC.** I prefer R-NOTE because it synchronizes the executable block and leaves a dated explanation at the historical form’s existing location. Comment 856 explicitly labels its block “Executable form” (`evidence/pv-5pmu-comment-856.md:6`, verified against the pinned `.beads/issues.jsonl`), while the archive already distinguishes its historical form from subsequent replacements (`docs/research/panels-2026-10/r86/r86b/Q1-A.md:63`).

R-BRIEF remains acceptable because it synchronizes the executable block and archives the correction. R-ARCHIVE is less discoverable, particularly given comment 856’s label, but explicitly preserves the closed bead historically and records the divergence. I found no rule requiring rejection of that record policy. No verified premise error.

I open **no Q6**. The unlisted references identify boundaries, owners, or retained scope without reproducing the underlying rules. In particular, the ceiling sentence at `01-domain-model.md:570` preserves scope without attempting to enumerate its conditions.

For rule 3, I assessed the dimensions separately: the accepted replacements change no execution behavior, introduce or remove no normative obligation, and change no theorem, guard, conformance assertion, fixture, gate implementation, or negative-control strength. QUOTE forms expose additional citation text to the existing checker. I identified no substantive blocking loss or collateral verdict flip.

I verified the form hashes, source quotations, prospective all-QUOTE text, comment equality, archive append, and supplied trial logs/diff hashes. I did **not** rerun Nix or lake because notes.md prohibits them. The clone remains unchanged.
``````

### Reader B

``````markdown
Seat [seat] reviewed PR #69 at `efb40cc55ff04be693473914afd42ef68008fa15`. **FAIL as landed on Q1’s quotation-rule compliance.** My picks are **Q1-QUOTE; Q2–Q5 KEEP; conditionally R-NOTE**. No ALT or Q6.

| Question | Final pick | QUOTE option | KEEP option | Pick wording-only? |
|---|---|---|---|---|
| Q1 | **Q1-QUOTE** | ACCEPT | CANNOT ACCEPT | Yes |
| Q2 | **Q2-KEEP** | ACCEPT | ACCEPT | Yes |
| Q3 | **Q3-KEEP** | ACCEPT | ACCEPT | Yes |
| Q4 | **Q4-KEEP** | ACCEPT | ACCEPT | Yes |
| Q5 | **Q5-KEEP** | ACCEPT | ACCEPT | Yes |

**Q1.** The landed sentence reports an existing ordering, rather than establishing a new timing rule. `PRV-25` says “After the ordinary authorization, capability and `API-16` validation” and “An identical established value MUST settle `succeeded`” (`02-provider-contract.md:873`, `:875`). Q1-QUOTE supplies precisely the two fragments supporting that report and retains its ordering.

KEEP does not satisfy `AGENTS.md:29`: “A claim about what another requirement says carries that requirement’s own words.” Approval of the original wording establishes its authority; it does not establish an exception to this instruction. The dated r93 note records the earlier correction and says “all other Q1-A text is retained” (`docs/research/panels-2026-10/r86/r86b/Q1-A.md:65`); that is not a ruling exempting every retained sentence from later wording review.

**Q2.** KEEP is preferable because the operative assertion establishes DOM-10’s capability-check placement. “Its state-change/enqueue transaction” identifies the transaction before which that new check runs. It does not independently specify the transaction’s atomicity or idempotency semantics.

`API-64` supplies the transaction’s content: “the state change, the enqueue and the idempotency record commit together” (`04-api-contract.md:1116`). Q2-QUOTE accurately quotes that content and preserves the timing instruction, so I also ACCEPT it. I do not find the additional sentence necessary for this pointer.

**Q3.** “Is classified by OPS-11” delegates classification to its owner; it does not reproduce a classification outcome. That follows `AGENTS.md:34`: “One rule, one home; everywhere else points at it.”

`OPS-11` says “the system MUST classify the error into `failed` or `needs_reconciliation`” (`03-operation-lifecycle.md:240`). Q3-QUOTE accurately supplies those words without changing the delegation. Both forms are acceptable; KEEP avoids repeating the classifier’s introduction.

**Q4.** The sentence establishes which outcomes take DOM-10’s new capability check. “A no-call success or defer returned by that decision” identifies the applicable outcomes conditionally; the sentence does not restate their triggering conditions.

The supplied quotations are accurate: `OPS-41` says “the worker MUST make no provider call, settle the operation `succeeded`” (`03-operation-lifecycle.md:1003`) and “the claim MUST defer” (`:1025`). Accordingly, QUOTE is acceptable too.

The complete source also matters: the ordered decision itself says “The claim defers” at `:1133`, and describes “The short deferrals in steps 3 and 4” at `:1153`. I read the brief’s note about the restore-claim defer as identifying the **selected quotation’s** source, not as excluding those other deferrals. Neither candidate should narrow the unchanged no-check instruction to the restore-claim branch alone.

**Q5.** KEEP points to the owning list without reproducing its membership or count. This directly follows `AGENTS.md:40`: “Cite the list; let it hold the number.” DOM-10 already uses the corresponding pointer, “the ones `PRV-4` names” (`01-domain-model.md:516`).

Q5-QUOTE accurately reproduces `PRV-4`’s list (`02-provider-contract.md:27`). I ACCEPT it as an explicitly attributed quotation, but prefer retaining the shorter pointer.

**Q-REC**, conditional on a non-KEEP result:

| Option | Judgment |
|---|---|
| **R-NOTE — final pick** | **ACCEPT** |
| R-BRIEF | ACCEPT |
| R-ARCHIVE | CANNOT ACCEPT |

R-NOTE preserves the original archive bytes, keeps the executable brief synchronized, and adds a direct route from the historical form to the later correction. That continues the distinction already recorded at `docs/research/panels-2026-10/r86/r86b/Q1-A.md:63`: “The text above is retained as the historical form approved in owner item 16.”

R-BRIEF remains acceptable because it synchronizes the executable text and archives the correction, although discovery from the historical form is weaker.

I cannot accept R-ARCHIVE’s record treatment. Comment 856 explicitly labels its block “Executable form” (`.beads/issues.jsonl`, pv-5pmu comment 856, text line 6; verified byte-equal to the supplied evidence). Leaving that block divergent while explaining the divergence only elsewhere creates an avoidable inconsistency about which text is executable. This is a documentation objection, not a claimed behavioral or formal blocking loss.

**Wording-only assessment.** All printed QUOTE replacements preserve the operative timing, outcomes, exceptions and owner delegation. KEEP changes nothing. The record options change documentation only. None changes a Lean declaration, proof statement, guard hypothesis, conformance assertion, fixture, checker implementation, baseline or negative-control strength.

The backticked quotations add citation-check coverage; that collateral effect is explicit. They supply new quotation input to the existing checker rather than changing its rules or weakening an existing verdict. I found no rule-3 blocking loss.

**Rule 6.** I verified two packet inaccuracies:

- `check/sweep-diff.txt` equals the **Markdown-only** diff, rather than the complete command’s output; it omits `.beads/issues.jsonl`. I separately checked the pinned bead and comment. This does not change any question’s premise.
- Q4-QUOTE changes the original initial “A” to “a”; therefore the statement that it preserves the sentence’s bytes is not literally correct. The exact printed form is clear, and this capitalization change has no semantic effect. It does not change Q4’s premise.

Neither error voids a question under rule 6, and none of my votes relies on either erroneous statement.

I verified the form hashes, quoted fragments, OLD-span occurrences, prospective replacements and comment/archive byte relationships against pinned sources. The supplied citation-trial logs support the reported results; I did not rerun gates because `notes.md` forbids them for this panel. The clone remains unchanged and detached at the pin.
``````

### Reader C

``````markdown
# Seat [seat]: r99 answer

**Applying notes.md rule 6 exactly as written; this prompt adds no void rule.**

| Question | Final pick | Other options | Pick is wording-only? |
|---|---|---|---|
| Q1 | **Q1-QUOTE** | Q1-KEEP: CANNOT ACCEPT | Yes |
| Q2 | **Q2-QUOTE** | Q2-KEEP: ACCEPT | Yes |
| Q3 | **Q3-KEEP** | Q3-QUOTE: ACCEPT | Yes, no bytes change |
| Q4 | **Q4-ALT** (below) | Q4-QUOTE: ACCEPT; Q4-KEEP: CANNOT ACCEPT | Yes |
| Q5 | **Q5-KEEP** | Q5-QUOTE: CANNOT ACCEPT | Yes, no bytes change |
| Q-REC | **R-NOTE-ALT** (below) | R-NOTE: ACCEPT; R-BRIEF and R-ARCHIVE: CANNOT ACCEPT | Yes, record only |
| Q6 | Not opened | | |

Each pick is also ACCEPT from me. None of my CANNOT ACCEPTs is a rule 3 blocking loss: no printed option changes a checked verdict or a MUST. They are conflicts with `AGENTS.md` or with precedent.

**Main finding:** the brief's Q4 note is false, and I judge that it changes Q4's premise (details under Q4).

## Q1: `PRV-25` sentence
- **Reason:** "remains after its capability check" states `PRV-25`'s own ordering (`02-provider-contract.md:873`, `:875`). It is not a new `DOM-10` rule.
- **Precedent:** r93 replaced a sentence of the same shape, "A replay returned by API-7 step 5a never reaches this check". `r93/tally.md:25` says "The source facts being supported does not establish exemption from the quotation rule."
- **Against KEEP:**
    - Item 16 is no exemption, because r93 already corrected item-16 text under the wording rule (`r86b/Q1-A.md:63-65`).
    - r93's retained bytes were a scope limit (`r93/brief.md:231`) and a byte audit (`assertion-map.md:276`), not a ruling.
    - The posted reply already concedes the sentence restates `PRV-25` without quoting it.
- **Wording-only:** the quoted MUST stays attributed to `PRV-25`, and the sentence's claim is unchanged.

## Q2: `API-64` transaction
- **Reason:** the rule depends on one fact about `API-64`, that the state change and the enqueue form a single transaction.
    - It states that fact in a coined term: "state-change/enqueue" appears in no root requirement except `01-domain-model.md:547`.
    - `API-64`'s own words are at `04-api-contract.md:1116-1117`. The quote puts that fact in the gate's reach.
- **Why this differs from the unlisted names:** "restore claim gate" and "fence transaction" are `OPS-41`'s own terms (`03-operation-lifecycle.md:1113`, `:1099`).
- **Closest call of my picks:** the main predicate is `DOM-10`'s own, so I accept KEEP.

## Q3: "classified by OPS-11"
- **Reason:** this points at the owner (`AGENTS.md:34`) and states none of `OPS-11`'s content.
- **Against QUOTE:** the quoted lead never mentions a capability refusal, so the gate would check a string but not the claim.
    - It also says less than the source: before the write-started marker, power, reverse-DNS, delete and release MUST settle `failed` (`03-operation-lifecycle.md:250`), and this check runs before either marker (`01-domain-model.md:557`).
    - It is harmless, so I accept it.

## Q4: `OPS-41` no-call success or defer

### Brief error
The brief says "the defer comes from OPS-41's restore claim gate, not its fence-transaction decision" and "QUOTE carries OPS-41's words for each outcome". Both are false. The ordered decision (`03-operation-lifecycle.md:1099`) has its own outcomes that QUOTE does not quote:
- **Step 3:** "the worker MUST return the attempt to `queued`" (`:1122`).
- **Step 4:** "The claim defers" (`:1133`).
- **Both steps:** "The short deferrals in steps 3 and 4 are not settlements" (`:1153`).
- **Step 1, a no-call success:** "The worker makes no provider call and settles the attempt `succeeded`" (`:1104`).

The packet's source excerpts omit all of these. Q4-QUOTE's only defer quotation is the one `OPS-41` itself places outside this decision: "Step 1 and the restore claim gate above remain ahead of this decision" (`:1113`).

**Rule 6:** I judge that this changes Q4's premise, because the packet tells readers the quoted defer is the only one. If so, Q4's tally is void and Q4 should be re-asked with steps 1, 3 and 4 printed. Any Q4-QUOTE acceptance that relied on the note rests on this error. My picks do not.

### Pick: Q4-ALT
Replaces the `Q4-OLD.txt` span, `01-domain-model.md:565-566`:

`````text
`OPS-41` says "the worker MUST make no provider call, settle the operation `succeeded`", "the claim MUST defer" and "The short deferrals in steps 3 and 4 are not settlements"; a no-call success or defer returned
by that decision takes no capability check.
`````

The file is `[scratch]/Q4-ALT.txt`, SHA-256 `c12991b321e6e9abc74e67dfebba3f16554ee8048ff09a0ca0895933614fa318`. This is a new form that no other reader has reviewed.

- **Why quote at all:** "returned by that decision" has the same shape as r93's "returned by API-7 step 5a", so I cannot accept KEEP.
- **Why I still accept Q4-QUOTE:** its words are real and every rule byte survives, so no behaviour changes. Only sentences that proceed to cancellation require the check (`01-domain-model.md:566-567`). Its defect is incomplete evidence.
- **Limits of the ALT:**
    - It does not quote step 1. Its no-call quotation is the abort that step 3 invokes.
    - It leaves "that decision" as landed. Changing that word would be a semantic change for the owner.

## Q5: methods `PRV-4` names
- **Reason:** the landed text is the form `AGENTS.md:40-43` and `:45-46` ask for: "every list or count names its source instead of restating it". `01-domain-model.md:516-517` already says "the ones `PRV-4` names".
- **Against QUOTE:** it writes "The three" and the whole list into `DOM-10`, breaking that clause to satisfy the quotation clause. The gate would catch later drift, so this is a rule conflict, not a blocking loss.

## Q-REC: how the record follows

### Why not the others
- **R-BRIEF:** owner item 25 rejected "Change the brief only" in the comparable case. It would also leave `r86b/Q1-A.md:65` false and uncorrected: "all other Q1-A text is retained".
- **R-ARCHIVE:** the closed bead's "Executable form" would differ from the landed text, and neither that comment nor `Q1-A.md` would point at r99.

### Why R-NOTE-ALT over R-NOTE
R-NOTE is acceptable and follows the right precedent, but it has three record defects:
1. Its note calls the r93-corrected text "the historical form approved in owner item 16". Item 16 approved only the original at pin `3109b5b`, and r93's correction came under the wording rule (`Q1-A.md:63-65`).
2. It leaves comment 856's line 6 naming only r93, though the block would then carry r99's changes too. The line 6 hash is identical in the prospective comment. r93's package updated this same line (`settled-pv-5pmu.md:11`, `:48`).
3. Its "Qn-QUOTE.txt bytes" cannot carry a settled ALT.

### Pick: R-NOTE-ALT
`````text
Fix commit on branch pv-5pmu, in PR #69: (1) in 01-domain-model.md replace each settled Qn-OLD.txt span with its settled QUOTE or ALT bytes; a settled KEEP changes nothing; (2) in the text of pv-5pmu comment 856 in .beads/issues.jsonl replace the same spans with the same bytes, and on that comment's line 6 replace "with the 2026-10-31 Panel N r93 wording correction." with "with the 2026-10-31 Panel N r93 and 2026-11-03 Panel r99 wording corrections.", changing no other field, comment or bead; (3) append exactly the block below to docs/research/panels-2026-10/r86/r86b/Q1-A.md, all original bytes remaining an exact prefix; (4) archive the reviewed r99 record at docs/research/panels-2026-10/r99/. The archived r93 record stays unchanged. No branch or tracker edit occurs in this panel turn.
`````

Appended block, which begins with two newlines (`[scratch]/Q-REC-ALT-append.md`, SHA-256 `445f69c220bfcdefd455fb6447c2c5e93b76d16274a9c051e21b0423358b02ea`):

`````markdown


## Wording correction — 2026-11-03 (Panel r99)

The form approved in owner item 16 and the 2026-10-31 Panel N r93 correction above are retained
with their bytes unchanged. Under the owner's 2026-10-28 wording rule (“For such wording questions,
try to solve by getting a consensus of the panel”), the landed `DOM-10` text and the pv-5pmu Agent
Brief use the exact replacements selected in the panel record below. This note grants no independent
authority to change a requirement; any substantive unresolved conflict returns to the owner.

Source pin: `efb40cc55ff04be693473914afd42ef68008fa15`.
Panel record: `../../r99/notes.md`.
`````

The owner sentence is verified at `docs/adr/0023-a-restore-is-a-recovery-incident-and-durability-is-bought-where-there-is-no-second-truth.md:311` and `r93/brief.md:36`.

## Q6: not opened
`:570-571` is the closest unlisted case. "Retain their existing scope" states no content from either requirement, unlike Q1's "after its capability check".

## What I checked
**Packet checks:** all `forms.sha256` entries pass, and `brief.md` matches `brief.sha256`. Each Q1–Q5 OLD span occurs once in comment 856. The prospective `DOM-10` block differs from the pin only at the five spans. r93's quoted lines and the line citations I sampled match.

**Gates:** the packet's trial ran only the citation gate, so I ran the other Python gates on scratch clones outside the Nix shell. The three trees were the pin, all five QUOTE forms, and my picks (Q1-QUOTE, Q2-QUOTE, Q4-ALT).

| Gate | Result on all three trees |
|---|---|
| `check_ids`, `check_obligations`, `check_coverage` | Exit 0, output identical to the pin |
| `check_citations` | Exit 0; compared 360, 367 and 366 respectively, otherwise identical |
| `check_fixtures` | **Not verified:** exit 1 on all three, `markdown_it` is missing outside Nix |
| `check_regions` | **Not verified:** exit 2 on all three, needs `regions.jsonl` from lake |
| `check_formal` | **Not run:** fenced |

- **ALT checks:** corrupting the ALT's new quotation gave exit 1, naming `OPS-41`. The four gates that pass above also passed on my picks with the ALT note appended.
- **Inference, not a run:** the `DOM-10` block has no `<!-- formal` region and no `@[req "DOM-10"]` tag, so I expect the unrun formal and regions gates to be unaffected. The apply turn must still run the full `check-all.sh` under Nix.

**Other brief errors:** one, which does not change any premise. §2 labels its block `AGENTS.md:29-32` and `:45-46`, but it also prints `:34-43`.

**Fences:** I used the same read-only lake index as the trial (hash matches `trial.json`), plus the r93 record and `owner-decisions-1030.md`, and searched the manager folder only for the owner's sentence. I read no r99 reader outputs. My clone is still clean at the pin, and scratch stayed in `[scratch]`.
``````
