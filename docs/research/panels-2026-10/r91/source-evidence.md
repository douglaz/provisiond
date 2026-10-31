# Panel L r91 — source evidence

Repository passages below are at aeb7ff65369238212903d6b60b8ae1622f5c93d8. Manager/memory evidence is separately labelled and is not claimed to be committed.

## Prepared question (entry 4)

Source: /var/tmp/provisiond-manager/owner-queue-1030/questions.md:38–52.

```text
38: 4. **Needs a panel first — the deferred nested-quotation checker repair can now be reconsidered.**
39: 
40:    TL;DR: Its original waiting condition has passed; do not ask the owner to choose parser mechanics.
41: 
42:    A specification quotes an error message, and that message contains another quoted word. The checker can stop at the inner quotation mark and miss a misspelling there. Authors currently avoid that by using different outer quotation marks. If an author forgets, the checker can still miss the bad word. This changes what a check catches, so it is substantive work under the owner's cosmetic-work rule.
43: 
44:    The approved parking comment says: "Unpark when panels A–E from this pass and their Runs are through, or sooner if a citation with a straight quotation nested inside a straight one gets past review." Those are the October 21 panels, completed through the October 26 landing, not today's new panels with reused letters. The bead remains deferred in the committed tracker. Later citation repairs explicitly preserved this separate parsing problem; they did not close it.
45: 
46:    **Panel question to prepare, without launching it:** Does the previously approved cheap rule—reject an attributed straight-quoted span that ends inside inline code, with a diagnostic pointing to the existing outer-mark convention—catch the bead's nested-value corruptions without rejecting valid current citations? Or is code-span-aware quotation extraction necessary? Read the exact candidate change, diagnostic, self-test and CI negative control together, retain all existing valid-quote cases, and verify that changing the nested value makes the check fail. Keep the separate alternative-occurrence problem out of scope. Prefer enforcement in the checker over depending on authors remembering punctuation. If no exact form settles, use the brief's consensus procedure before any owner question.
47: 
48:    Cost: one focused technical reading round and, only after a settled exact package, the normal implementation/review work. The prior owner-approved direction is evidence for the cheap candidate, not a new panel endorsement. No new wording is recommended here, and no owner answer is required before preparing that panel under the standing panel-first rule. No panel was started this turn.
49: 
50:    Evidence: `/var/tmp/provisiond-manager/oq-prep/beads.pretty.json:107` preserves the original defect, corruptions, workaround and acceptance criteria; `:133` preserves the approved reopening trigger and cheap-rule direction. The snapshot's October 21 second-batch block at `:1243` identifies the original A–E membership; `:139` and the October 26 handoff state establish their completion, with `/var/tmp/provisiond-manager/HANDOFF-2026-10-26.md:12` recording Panel E done. `tools/check_citations.py:67` still documents the nested-boundary limitation. The snapshot's October 29 PR #42 OPEN update records that later changes preserved parsing behaviour. `/home/user/.claude/projects/-home-user/memory/feedback_prefer_app_enforced_safety.md:15` supports checker enforcement; `feedback_no_cosmetic_beads.md:11` covers real check-strength defects.
51: 
52:    IDs / decision homes: `pv-602`, `tools/check_citations.py`, `.github/workflows/ci.yml`, `DEF-16`; preserve `pv-erp`'s separate R7/R8 obligations. HANDOFF §2 item 9.
```

## Committed pv-602, entire description and comments

Source: `.beads/issues.jsonl` at the pin; status `deferred`. The structured copy is `check/pv-602.json`.


`tools/check_citations.py` pairs straight double marks left to right. In a straight-quoted citation that itself contains a straight-quoted value, the outer quotation closes at the first inner mark, so the nested value is never compared with the owner, and a misspelt reason name there stays green. How much else goes unchecked depends on the form:
- **Possessive form** (`` `X`'s "…" ``): nothing in the quotation is compared.
- **`says` form**: the fragments between the inner marks are still compared, but the nested values aren't.
- A probe on `pv-oes` confirms both: in the `says` form, a planted `account_terminatd` exits 0 and a planted `three recoverable` exits 1.

- The gate's docstring names the class: "What it cannot see: balanced nested or mispaired straight/curly marks can still select the wrong span within a paragraph."
- Its quote-content fixtures (`check_quote_content`) wrap each quote in curly outer marks (`` `OPS-41` says “…” ``), so straight inside curly is tested. No self-test fixture nests straight marks inside straight ones.
- The one site at master `ad40707` was `03-operation-lifecycle.md`'s `OPS-43` step 1, quoting `API-63` with `details.reason: "account_terminated"` and `"state"` inside. There, planting `account_terminatd` exited 0.
- Method: a non-historical, attributed chunk whose paired straight span holds an odd number of backticks, so it ended inside a code span.
- PR #17 (`pv-oes`) switched that site's outer marks to curly “…”, as `CNF-248` (PR #16) and `05-persistence.md` already do. The count is now zero. The `account_terminatd` plant there exits 1, and so do a `"stat"` plant and a `three recoverable` plant.
- The same scan's looser shape, two straight spans joined by a short token, finds two hits, and neither is a citation: `04-api-contract.md` (`API-63`'s own text) and `13-wire-contract.md` (a JSON fixture).

So the curly workaround holds only while every author knows to use it; nothing fails when one doesn't.

Fix asked for: teach the gate to compare those values, so authors stop needing the curly workaround. For example, pair straight marks around inline code spans, so a straight-quoted value inside one is compared as content. Every nested value at the one site sat in a code span.

Question for triage: is pairing around code spans the right rule? The cheaper alternative is to fail an attributed straight span that ends inside a code span, naming the curly-mark fix in the message. That would enforce the workaround rather than remove it.

Acceptance:
- a self-test fixture where a typo in a nested straight-quoted value goes red;
- a `ci.yml` negative-control step for it (`DEF-16`);
- the docstring's "What it cannot see" paragraph updated;
- the gates exit 0 unpiped.


Comment 761 (2026-10-21T14:45:09Z):


Triage pass: `enhancement` (gate strength). **v1: no** (spec tooling; no implementer choice). No merge. **Size S.** **Proposed: park until the v1 queue from this pass is through.** When picked up, take the cheaper rule: fail an attributed straight span that ends inside a code span, and name the curly-mark fix in the message. It enforces the convention PR #16 and PR #17 already use rather than removing it. Lands on `tools/check_citations.py`, one self-test fixture and one `ci.yml` negative control (`DEF-16`).


Comment 790 (2026-10-21T14:56:14Z):


Parked; triage is done. Unpark when panels A–E from this pass and their Runs are through, or sooner if a citation with a straight quotation nested inside a straight one gets past review. When picked up, take the cheaper rule: fail an attributed straight span that ends inside a code span, and name the curly-mark fix in the message. Lands on `tools/check_citations.py`, one self-test fixture and one `ci.yml` negative control (`DEF-16`).


## Original second-batch membership and outer-mark convention

Source: /var/tmp/provisiond-manager/oq-prep/manager-brief.snapshot.md:1231–1257.

```text
1231: - **LATEST (landed):** master = `cbb3693` (PR #18 merged 2026-10-21: the second batch triage), gates green.
1232:   - Drain scope then: pv-1wn, then pv-xer.
1233:   - After that, run panel A (pv-6p8), then B–E, one at a time.
1234:   - **Panel B context:** pv-009's "Two engines that each conform" is false. Engine B breaks DOM-10/SEC-15, so the
1235:     kind `unsupported` is settled. What's still open is where the gate sits in OPS-43's claim order, and its
1236:     `retryable`.
1237:   - Pass `--author assistant` to `br comments add`. The 7 comments from PR #18 show the author as "unknown".
1238: - **NOW (landed):** master = `958b62c` (PR #17 merged 2026-10-21: pv-oes), gates green.
1239:   - The drain merged PRs #13–#17: pv-nd6, pv-p1y, pv-pj0, pv-uuv, pv-oes.
1240:   - **needs-triage, waiting on the owner:** pv-009, pv-1wn, pv-602, pv-6p8, pv-7j3, pv-9j6, pv-buc, pv-gpw,
1241:     pv-n98, pv-p3k, pv-s4m, pv-ss4, pv-tcs, pv-xer, pv-ytv.
1242:   - **Parked:** pv-2s6, pv-s5b. pv-4pn stays parked. P4: pv-erp.
1243:   - **Second batch triage, approved by the owner on 2026-10-21** (branch `batch-triage-2`, going through a
1244:     drain PR):
1245:     - Ready to drain: pv-1wn; pv-xer (the owner accepted the flags: `price_moved` retryable; claim-time `state`
1246:       retryable; `account_terminated` not).
1247:     - Panels, run in this order, one at a time, each ending in one owner question:
1248:       - A: pv-6p8, a P2.
1249:       - B: pv-gpw, pv-p3k, pv-ss4 and pv-7j3, then one Run that can also carry pv-xer.
1250:       - C: pv-s4m and pv-n98.
1251:       - D: pv-buc and pv-9j6.
1252:       - E: pv-tcs and pv-ytv.
1253:     - pv-602 is parked until the v1 queue is done. pv-009 depends on pv-p3k.
1254:   - **Citation gate:** use curly outer marks (“…”) on a citation that holds a straight-quoted value. pv-602 is
1255:     the bead for teaching the gate to handle it.
1256: - **Before that:** master = `ad40707` (PR #16: pv-uuv).
1257: - **Before that:** master = `3f14280` (PR #15 merged 2026-10-21: pv-pj0).
```

## Original Panel E completed

Source: /var/tmp/provisiond-manager/HANDOFF-2026-10-26.md:10–19.

```text
10: - **master is `08191bb`** (PR #26, squash-merged 18:38Z). The local checkout is on master, the tree is clean
11:   and there are no stashes. Post-merge `tools/check-all.sh` exit 0.
12: - **Panel E is done.**
13:   - pv-tcs (create admits from the stored offer listing: STO-60, OPS-51, OVR-17, OVR-19, API-7) and pv-ytv
14:     (Robot order fingerprints K1–K6 + K-d) are closed.
15:   - The r67–r73 records are in the repo under `docs/research/panels-2026-10/`.
16:   - The owner's decisions and main's settlements are in the panel E blocks of
17:     `/var/tmp/provisiond-manager/owner-q1-sync-2026-10-23.md`.
18: - **Nothing for provisiond is running.** (`mgr-lf-t12-3a` belongs to lean-fedimint. Leave it alone.)
19: - **The merge queue is empty:** no open bead is `ready-for-agent`.
```

## Standing gate and quotation instructions

Source: /var/tmp/provisiond-panel-r91/check/spec/AGENTS.md:5–49.

```text
5: 
6: ## Gates
7: 
8: `nix develop --command bash tools/check-all.sh`, before you start and again before you report
9: done. Run it unpiped — a pipe reports the pipeline's status, not the gate's, which is why
10: `check-all.sh` captures each exit code directly. The shell is required: the formal gate needs Lean,
11: and a missing toolchain is a red gate, not a skipped one.
12: 
13: A formalized clause's home is its Lean declaration in `tools/formal/`, tagged `@[req "LDG-38"]`
14: (`ADR-0025`). Change the declaration and the Markdown together; a theorem that stops proving is
15: the gate telling you the amendment contradicts a property the set claims — read the theorem
16: before weakening it, since weakening a statement to make a proof pass is a semantic change like
17: any other. `ADR-0025` says which guard hypotheses are not. Never put a `CNF` identifier in
18: `tools/formal/`.
19: 
20: Green is evidence only because the workflow breaks a document on every run and asserts the gates
21: reject it — one negative-control step per gate that has one, and `.github/workflows/ci.yml` holds
22: the list rather than this sentence. `DEF-16` is why.
23: 
24: ## Writing a requirement
25: 
26: The rule and the record are two edits with two different failure rates. Land the rule; write the
27: record after.
28: 
29: **Quote the sentence.** A claim about what another requirement says carries that requirement's own
30: words. `` `WIR-30` says "The gate reads the copy the machine took at create" `` is checkable;
31: "`WIR-30` forbids resolving eligibility that way" is an assertion, and assertions of that shape were
32: false repeatedly on 2026-09-03 — `ddd3df0` and `254fc24` carry the cases and what each one cost.
33: 
34: **Cite the owner.** One rule, one home; everywhere else points at it.
35: `07-security-requirements.md`'s scope note holds the argument, and `SEC-46` is the standing example
36: of a second copy drifting until an amendment shipped claiming to have applied while the requirement
37: said the opposite. **Arguments have owners too** — re-explaining a rule in a second document is how
38: a second normative copy gets written, because you cannot explain a rule without restating it.
39: 
40: **Cite the list; let it hold the number.** A count written into prose is wrong the first time either
41: end moves. `ADR-0003`'s footnote, `ADR-0011` and `F16` in `11-open-findings.md` each record their
42: own version of this. The same applies to a universal: one counterexample retires it, and
43: `OVR-17` carried a false one for weeks.
44: 
45: **Completion:** every sentence asserting what another requirement says carries its quote, and every
46: list or count names its source instead of restating it.
47: 
48: ## Agent skills
49: 
```

## Current extraction contract

Source: /var/tmp/provisiond-panel-r91/check/spec/tools/check_citations.py:43–122.

```text
43:            REACH: a quote is checked only when its SPLIT chunk carries an
44:            ATTRIB match (a speech verb, or `X`'s <noun> that) before it, or is
45:            directly after a bare possessive (`X`'s "four or more words") or,
46:            in root Markdown only, a colon (`X`: "four or more words"). The
47:            chunk must not be TEACHING. Lean also skips HISTORICAL chunks;
48:            Markdown assesses history per candidate as described below. A bare possessive
49:            owns only its immediately following quote; each such pair is checked,
50:            even with multiple owners in a chunk. The colon shape has the same
51:            immediate-quote ownership and never adds UNQUOTED input either.
52:            Colon coverage excludes Lean docstrings: EXISTS already compares
53:            every eligible docstring quote against the corpus; ci.yml's
54:            "Prove the citation gate rejects a Lean docstring quote found nowhere"
55:            relies on Wire.lean's colon-form API-11 chunk staying outside QUOTED.
56:            Extending the shape to Lean docstrings is pv-s4g's open follow-up.
57:            In Lean docstrings that was the minority: at `c5e31be` (2026-10-02), 56 of the 925 quotes of four
58:            or more normalised words were compared. The gate prints both figures
59:            on every run; the numbers here are that day's reading, not a rule.
60:            Paired quotations stay in one chunk, including sentence enders and
61:            spaced elisions. Marks are paired before length/word filtering, so a
62:            short span cannot steal the next quote's opening mark (pv-vwe.35).
63:            Before these rules, unpaired straight or curly double marks fail
64:            with a source file and line, even in historical/teaching prose or
65:            spans outside the word/length limits. Each paragraph is checked
66:            independently; separately extracted Lean docstrings stay separate.
67:            What it cannot see: balanced nested or mispaired straight/curly
68:            marks can still select the wrong span within a paragraph. Two stray
69:            straight marks, such as inch marks surrounding a real quotation,
70:            can pair with its marks and hide it, including in a Lean docstring:
71:            A 3.5" drive. `OPS-29` says "A correlator match MUST be exact.". A 2.5" drive.
72:            The quotation in that sentence gets no QUOTED or EXISTS comparison,
73:            even if corrupted; Lean UNQUOTED findings are not enforced. Balancing
74:            alone cannot identify the intended quotation boundaries. Prefer a
75:            spelled-out unit (3.5 inch); the double-prime unit symbol (3.5″) also
76:            avoids straight marks. Inline code spans and fenced code blocks do
77:            not shield marks from the guard; a lone inch mark there still fails.
78:            Curly double quotation marks are checked separately and are not a
79:            substitute for the double-prime unit symbol. Blank lines
80:            are hard boundaries, including between separate Lean docstrings.
81:            This is a paired-mark scanner, not a Markdown or Lean prose parser.
82:            TEACHING applies to the whole resulting chunk. HISTORICAL does too,
83:            except in Markdown QUOTED: an exact case-insensitive whole word
84:            superseded wholly inside the candidate's paired content does not
85:            suppress that candidate. Every other history match still suppresses,
86:            including superseded outside it or inside another quote. Embedded
87:            superseded identifiers do not mark history in either input kind;
88:            word boundaries use Python's Unicode semantics. All history occurrences
89:            are considered; ownership and cited pools use the original chunk.
90:            CNF-216's note beginning "Amended 2026-10-02" remains historical:
91:            corrupting "the greatest `increment end` among that subject's rows"
92:            there is skipped; the same attribution in a current chunk is checked.
93:            Possessives require a straight apostrophe and whitespace immediately
94:            followed by the opening quote; intervening prose or markup is not
95:            this shape. Colons require whitespace immediately followed by the
96:            opening quote: intervening prose or markup, or no whitespace, is
97:            outside the shape. An ADR id or document name before a colon is
98:            outside it too. An explanatory colon after a requirement citation
99:            is read as attribution, so write such a colon only before the
100:            cited requirement's own words.
101:            A colon-form quote in a Lean docstring gets only EXISTS's owner-free
102:            comparison unless another supported attribution shape applies.
103:            Quotes below four normalized words remain outside QUOTED. Markdown
104:            QUOTED has no length cap; Lean QUOTED retains the 400-character cap.
105:            Comparison locates candidate source spans without quotation marks,
106:            then compares their content, including adjacent apostrophes. Only
107:            locally paired delimiters are formatting; word-internal and unpaired
108:            trailing apostrophes remain content. See comparison_text() and
109:            span_content() for the bounds and ambiguous-punctuation limitation.
110:            QUOTED comparison ignores a blockquote marker only at the start of
111:            a continuation line: newline, optional spaces/tabs, > and at most
112:            one following space. Other > characters remain content. quotations()
113:            still yields exact source slices; signature identity still uses
114:            norm(), retaining all marks, including blockquote markers.
115:            A chunk shaped `X` says `Y`'s "four or more words" compares against
116:            both owners; the same applies to `X` says `Y`: "four or more words"
117:            in Markdown. No precedence rule was chosen. A nested example can
118:            gain a second attribution. An allowance is per full signature, not
119:            positional: deleting its standing occurrence and restating it
120:            elsewhere in the same file can pass. Making the standing chunk
121:            historical (e.g. "was itself overbroad" -> "was previously overbroad")
122:            and restating identical wording as current can also pass.
```

## Current OPS-43 context and the bead live site

Source: /var/tmp/provisiond-panel-r91/check/spec/03-operation-lifecycle.md:757–832.

```text
757: **OPS-43** **The provider's price MUST be re-checked at claim, and the order refused where the
758: commitment no longer covers it.** A create is priced and its commitment sized when the API accepts
759: it; the purchase happens later, in a worker. `WIR-30` says an offer price is "an indicative quote
760: … `binding` is `false`", and the auction channel is a live market with other bidders in it, so the
761: provider's own price can move in that window — which on the dedicated product can be long, since
762: `OPS-33` records that robot-style orders poll through an `in process` state with no documented
763: bound.
764: 
765: **Sale re-test at claim.** At claim (`OPS-5`), before any provider mutation, the worker MUST
766: re-test the create's named offer for sale under `PRV-13b` and `PRV-31`, applying `API-7`'s
767: create-tail verdict: "`invalid_request`/`offer_not_sellable` when the named offer is
768: not sellable under `PRV-13b` or `PRV-31`, or absent from the offers the check reads".
769: The inputs are the descriptor the worker runs with
770: (`PRV-44`: "The descriptor is a typed, immutable value") and one current driver List offers
771: result taken at claim. Date bounds MUST resolve against provider-local today at the time of
772: the check.
773: 
774: The worker MUST order the following steps as listed:
775: 
776: 1. Read the provider account's stored status (`STO-47`). This is a plain read, not a
777:    conditional-write guard; the guard remains the conditional write at step 8. If the status
778:    is not `healthy`, fail `conflict`, with `API-63`'s “`details.reason: "account_terminated"`
779:    where the status is `terminated` and `"state"` for the two recoverable statuses, since
780:    presenting an unreachable account as a permanent termination is false, and with
781:    `retryable: false` for `"account_terminated"` and `retryable: true` for `"state"` on both the
782:    error and the operation view”. Make no
783:    provider request and release the commitment in full under `LDG-39`'s "Deterministic rejection
784:    before acceptance" case.
785: 2. Read the stored channel closure (`PRV-40`: "the worker MUST read the stored closure for that
786:    account and ordering channel when it claims the operation (`OPS-5`), before any provider
787:    request, including a per-order key upload").
788: 3. Repeat boundary validation under `OPS-23`: "Validation that was performed at the API boundary
789:    MUST be repeated in the worker before the driver is called". This includes `PRV-10`'s
790:    "explicit purchase acknowledgement", `PRV-8`'s "at least one SSH public key", the missing-field
791:    checks defined in `OPS-23`, and `DOM-10`'s gate on the create's ordering capability, which is
792:    `PRV-10`'s "the account is configured to allow ordering". The checks on caller-supplied fields
793:    run first, then the checks on fields the `api` wrote at admission, then the capability gate.
794: 4. Gate on `list_offers` under `DOM-10`, then obtain the current driver List offers result.
795: 5. Check for the named offer's absence from that result, applying the create-tail verdict quoted
796:    above; if present, re-test the named offer for sale on that result and the running descriptor.
797: 6. Compare its price using that same List offers result, as below. An unsellable offer gets no
798:    price comparison.
799: 7. Run `PRV-47`'s driver validation: "the driver MUST validate every value it forwards to the
800:    provider, including provider options". For the rejection's error, see `PRV-47`.
801: 8. Perform `API-63`'s conditional write on `STO-47`'s row, in the correlator transaction:
802:    "the worker MUST repeat the admission check as a conditional write on `STO-47`'s row guarded
803:    on `healthy`". It remains "the last write before the ordering call" (`API-63`).
804:    In this same transaction, on every ordering channel, including `correlator: none`, the worker
805:    MUST set `operations.about_to_order_at` to `COALESCE(about_to_order_at, <transaction time>)`
806:    guarded on `(id, status = running, claim_number = mine)` (`STO-3`; `OPS-6`:
807:    "every write that worker makes to the operation MUST carry `claim_number = mine`").
808:    The write MUST NOT be guarded on the column being null: a whole-transaction repeat after a
809:    lost reply affects one row and changes nothing. If this operation-row write affects zero rows,
810:    something else moved the operation: step 9 MUST NOT run and the worker MUST exit. This differs
811:    from the zero-row `STO-47` check above, of which `API-63` says "where it affects no row MUST
812:    fail the operation deterministically". A first attempt that fails that check commits no
813:    `about_to_order_at`. If an earlier step-8 transaction committed but its reply was lost, and an
814:    account-status write makes the account non-`healthy` before the whole-transaction repeat,
815:    the repeat can fail that check with the column already set. The create still settles `failed`
816:    under `OPS-11`'s create row: `OPS-11` says "Any create failure the worker records before any step-9 request (before any per-order key upload or order request) MUST settle `failed`, whatever its kind."
817:    Step 9 MUST begin only after step 8's transaction is acknowledged. A lost acknowledgement
818:    MUST take `OPS-49`'s "repeat the **whole transaction**" path, never speculative dispatch.
819: 9. Perform the per-order key upload, then the order. Here **per-order key upload** means every
820:    temporary key registration required for this create (`PRV-9`: "the driver MUST register and
821:    attach them as temporary provider-side resources").
822: 
823: *Amended 2026-10-17 (`pv-k4l`; panels r56 and r56b, `docs/research/panels-2026-10/r56/` and `docs/research/panels-2026-10/r56/r56b/`): made step 8 write the column under the worker guard and await acknowledgement before step 9.*
824: 
825: *Amended 2026-10-21 (`pv-p1y`): pointed step 7's rejection at `PRV-47`.*
826: 
827: *Amended 2026-10-21 (`pv-xer`; owner decision of 2026-10-21): extended step 1's quote of `API-63`
828: to its `retryable` values.*
829: 
830: The first failing check stops subsequent checks; its owning classification governs disposition.
831: Claim-time refusals are not collected: the error carries neither `details.refusals` nor
832: `details.not_checked`. The order differs from admission: a create both closed and unsellable
```

## API-63 owning text for the live site

Source: /var/tmp/provisiond-panel-r91/check/spec/04-api-contract.md:1419–1436.

```text
1419: have the termination commit behind it, and open a commitment against a dead account.* **A create claimed but not yet dispatched narrows the unreachable case to a dispatched order**:
1420: in `OPS-43`'s step 8, the correlator transaction (`PRV-26`: "before the order is
1421: sent"), where "on every ordering channel, including `correlator: none`, the worker MUST set
1422: `operations.about_to_order_at`" (`OPS-43`) — the last write before the ordering call — the worker MUST repeat the admission check as a
1423: conditional write on `STO-47`'s row guarded on `healthy`, and where it affects no row MUST fail the
1424: operation deterministically — `conflict`, with `details.reason: "account_terminated"` where the status is
1425: `terminated` and `"state"` for the two recoverable statuses, since presenting an unreachable
1426: account as a permanent termination is false, and with `retryable: false` for `"account_terminated"`
1427: and `retryable: true` for `"state"` on both the error and the operation view (`WIR-9b`) — releasing its commitment,
1428: with no provider mutation. `LDG-69` keeps the provider call outside that transaction, so a
1429: termination can still commit between the write and the call; that residue is the dispatched case
1430: below, **and `about_to_order_at` is what tells the termination which case it is**: a claimed
1431: create still `running` with the column null has not passed the conditional-write check and does not dispatch. Under
1432: `OPS-43`'s claim order it may fail at step 1, "Read the provider account's stored status", at
1433: another preceding check, or at this conditional write. Interruption can instead leave the create
1434: unresolved (`OPS-15`: "the engine MUST move every `running` operation to `needs_reconciliation`"),
1435: except for the create exception (`OPS-15`: "A create found `running` at startup with
1436: `about_to_order_at` null MUST be settled `failed`, on a restart only.").
```

## Current CNF-300 owner

Source: /var/tmp/provisiond-panel-r91/check/spec/10-conformance-checklist.md:3026–3048.

```text
3026: - [ ] **CNF-300** — **A `failed` install says what it did to the disk, and the state never carries
3027:       it** (added 2026-09-15, `pv-x8r`). Drive a `rootfs_via_rescue` install whose installer starts
3028:       and then rejects the layout, with the rescue exit succeeding and the engine reporting
3029:       `invalid_request`: assert the operation settles `failed`, `terminal: true`, `retryable` is
3030:       what `DOM-17` gives that kind, and the error carries `details.disk_effect:
3031:       "destructive_boundary_crossed"`. Then `CNF-279`'s pinned-key abort: `failed` with
3032:       `disk_effect: "none"`. Then a `provider_native` rebuild the provider rejects `not_found`
3033:       before acting: `failed` with `disk_effect: "none"`. Then `CNF-279`'s failed rescue exit: `needs_reconciliation`,
3034:       `retryable: false`, `disk_effect: "none"` (it aborted before writing) and `rescue_exit:
3035:       "unknown"`; and an ambiguous `provider_native` dispatch: `disk_effect: "unknown"`,
3036:       `rescue_exit: "none"` (*corrected 2026-09-16; the first draft paired the abort with
3037:       `destructive_boundary_crossed`*). Assert every install error carries
3038:       the key, and that the two `failed` rescue installs differ on nothing but it — or the item
3039:       passes an implementation whose callers cannot tell an untouched disk from a partitioned one.
3040:       (`OPS-3`, `OPS-11`, `OPS-45`, `API-51`, `WIR-9a`)
3041: - [ ] **CNF-301** — **`on_failure` is gone from both rescue-entering bodies** (added 2026-09-15,
3042:       `RSC-18`). An install or rescue-inventory body carrying it is rejected `invalid_request`
3043:       naming the field (`WIR-2`, `WIR-20`, `WIR-40`). A `rootfs_via_rescue` install whose digest
3044:       mismatches before the installer runs exits rescue and settles `failed` with `disk_effect:
3045:       "none"` and `rescue_exit: "clean"`; the same with the exit failing is `needs_reconciliation`
3046:       with `rescue_exit: "unknown"`, the address and port, and a key file named by the operation id.
3047:       Every install and rescue-inventory error carries `rescue_exit`. (`RSC-18`, `RSC-19`, `RSC-25`,
3048:       `OPS-11`, `OPS-45`, `WIR-9a`)
```

## Current CNF-302, including the newly found straight-nested citation

Source: /var/tmp/provisiond-panel-r91/check/spec/10-conformance-checklist.md:3049–3102.

```text
3049: - [ ] **CNF-302** — **`rescue_exit: "none"` is a fact, and the column is written before the session,
3050:       not after the exit** (added 2026-09-16). Drive an install refused before begin rescue —
3051:       `OPS-40`'s claim-time URL gate, or a `rescue_ssh` capability refusal (`DOM-10`) — and assert
3052:       `failed`, `rescue_exit: "none"`, no `rescue_address`, and `rescue_exited_cleanly` **null** in
3053:       the row and in `request_summary`. Then kill the engine after the pre-dispatch write commits
3054:       and before the begin-rescue dispatch (*step added 2026-09-20, `pv-v1f`*): no begin-rescue call
3055:       reaches the provider, `OPS-15` moves the operation to `needs_reconciliation`, the column is
3056:       **false** over a machine that was never rebooted into rescue, the error carries
3057:       `rescue_exit: "unknown"` with the `rescue_address` and `rescue_port` that `OPS-15`'s pass
3058:       renders from the machine row (`RSC-19`), and no key file exists. Then kill the engine between
3059:       the begin-rescue dispatch and the end-rescue call: `OPS-15` moves the operation to
3060:       `needs_reconciliation`, the error carries `rescue_exit: "unknown"` with `rescue_address` and
3061:       `rescue_port`, the column is **false**, and no key file exists (`RSC-19`: a crash persists
3062:       nothing, and `unknown` never implies a file). Then `CNF-301`'s clean exit: **true**. Then
3063:       repeat the pre-dispatch write after a simulated lost reply and assert it affects one row and
3064:       changes nothing (`ADR-0022`, `STO-3`). Then restore from a backup taken before the dispatch,
3065:       inserting an incident with null `lost_window_starts_at` and `loss_end_at` and a non-null
3066:       incident-keyed `history_evidence_ref` retaining the unknown-endpoint reasons (`STO-54`,
3067:       `STO-56`), and assert the quarantined row renders both keys `unknown` whatever the restored
3068:       columns hold (`WIR-9a`). Three distinct column values, or the item passes an implementation that writes the
3069:       marker only at the exit — which renders a crashed session as `none`, the one lie the column
3070:       exists to prevent. The pre-dispatch kill is the step that separates the required write from
3071:       one made at the dispatch instead: `OPS-45` states "false, written before begin rescue … is
3072:       dispatched", and an implementation that waits for the dispatch renders that row `none`.
3073:       (`OPS-45`, `OPS-15`, `RSC-19`, `WIR-9a`, `STO-50`, `STO-54`)
3074: 
3075:       Keep a restore incident open through the following paired cases. Restore a backup with an
3076:       unsettled install whose markers are `null` although its destructive phase and rescue dispatch
3077:       occurred in the lost interval. Complete step (3), then assert the old row renders both keys
3078:       `unknown`. Admit separate fresh raw-disk installs after step (3), and crash the engine while
3079:       each remains `running`: (a) before either marker write, (b) after the write-started marker and
3080:       pre-rescue `false` marker have committed, (c) after the write-started marker and clean
3081:       rescue-exit `true` marker have committed but before settlement. Run the successor's startup
3082:       pass and assert each row is `needs_reconciliation`, with no replay or automatic deterministic
3083:       settlement. Assert `none`/`none` for (a), `destructive_boundary_crossed`/`unknown` for (b),
3084:       `destructive_boundary_crossed`/`clean` for (c). Repeat successor startup, close the incident
3085:       under its ordinary close conditions, and purge payloads; assert the retained wire values do
3086:       not change merely because of those events. In another actual restore from a backup containing
3087:       a still-unsettled formerly fresh row, assert both keys now render `unknown`. For rescue
3088:       inventory repeat the old-row and later-restore cases with `rescue_exit` `unknown`; for
3089:       separate fresh rescue-inventory rows with rescue marker `null`, `false` and `true` assert
3090:       `none`, `unknown`, `clean`. Do not write an install write-started marker or introduce
3091:       `disk_effect` on that kind. Check provenance and rendering across a lost transition reply and
3092:       a repeat.
3093: 
3094:       Separately construct `CNF-300`'s unresolved failed-rescue-exit row with `disk_effect` `none` and
3095:       `rescue_exit` `unknown` without a prior restore, then back it up and actually restore it
3096:       (`CNF-300`: "`disk_effect: "none"` (it aborted before writing) and `rescue_exit:
3097:       "unknown"`"). It
3098:       remains `needs_reconciliation`, acquires `true` provenance before startup, and now renders
3099:       `unknown`/`unknown`. This is a declared conservative change on a row already awaiting
3100:       resolution. For settled rows with established `false` provenance, an actual restore does not
3101:       alone change their flag. During upgrade a `null` flag renders conservatively; backfill changes
3102:       only nulls, never a freshly admitted `false` row or an already-true row. Assert that a settled
```

## DEF-16

Source: /var/tmp/provisiond-panel-r91/check/spec/09-known-defects.md:232–238.

```text
232: ### DEF-16 — There were no tests at all — *verified*
233: 
234: Zero test functions across roughly 6,100 lines. The CI step that ran the test suite passed
235: vacuously, which is worse than having no step: it produced a green check.
236: 
237: **Prohibition** — see `10-conformance-checklist.md`. A green check on an empty suite is
238: how a system with a tenancy hole ships looking healthy.
```

## Later repairs preserved the separate parsing problem

Source: `/var/tmp/provisiond-manager/oq-prep/manager-brief.snapshot.md:240`, October 29 PR #42 OPEN update. Verbatim excerpt: “only first historical alternative narrowed; other historical/teaching alternatives, attribution/parsing/source-pool/baseline behavior preserved, no requirement/formal change.” The complete current checker is supplied as `existing-checker.py`; its limitation above remains present.

## Owner preference

The current instruction explicitly says: “Owner preference (memory feedback_prefer_app_enforced_safety.md): checker enforcement over author memory.” The memory source says: “a safety property that a forgotten or reset setting silently disables isn't one they trust” (`/home/user/.claude/projects/-home-user/memory/feedback_prefer_app_enforced_safety.md:15`). This is a preference for enforcement, not a prior endorsement of any exact candidate below.
