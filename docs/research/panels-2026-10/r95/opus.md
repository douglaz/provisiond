## 1. Picks and acceptability

**Q1: Q-QUOTE** · **Q2: L-NOTE**, with the matching `note-Q-QUOTE.md` (6123 B, sha256 `0b07135f…bd85`).

| Form | Verdict | Reason and conditions |
|---|---|---|
| **Q-QUOTE** | **ACCEPT, first choice** | It deletes no adopted word. Every challenged retained-source claim now carries that source's exact words, and the conformance item 6 bytes are unchanged. The one byte change outside an addition is the disclosed OPS-11 LF→space. Condition: the full Nix gate runs on the applied text, because the manager gated only H. |
| **Q-POINTER** | **ACCEPT, second choice** | It is wording-only in all three dimensions, but weaker. It removes adopted words. Step (2) no longer says "cancellation" (the duty survives in OPS-27 M:642–654, API H:672–675 and CNF H:2312–2313). Its pointer at API:669–670 still names OPS-27 content ("later evidence-based attachment after the suspension parent has settled") without quoting it. |
| **Q-KEEP** | **CANNOT ACCEPT** | No exemption exists. OPS-11 M:249, OPS-27 M:642–654 and API-58 M:618 already hold this content at M, so these sentences report other requirements' content. `tools/check_citations.py:173–177`: "it stays a review problem". |
| **L-NOTE** | **ACCEPT, first choice** | Condition: the r95 record is archived so `../../r95/notes.md` resolves. |
| **L-SYNC** | **ACCEPT, second choice** | The spec and brief stay consistent. Two costs: Panel O's appendix line "all other Q4-D text is retained" becomes stale with no qualifying note, and the r95 correction has no committed record. |
| **L-SPEC** | **CANNOT ACCEPT** for Q-QUOTE or Q-POINTER | comment860 says "Executable form: the … blocks below", and that would become false. The PR spec review's claim "All six blocks match comment860 byte-for-byte" would also break. |

## 2. Occurrence inventory

Each row gives the head (H) line, the decoded comment860 line, and the archive `Q4-D.md` line. I searched all six blocks independently: every requirement ID, every possessive, every "under/see/says", and implicit references with no ID.

**A. Summaries of retained source content (need a quote or pointer):**

| H | c860 | Archive | Text | Source at M |
|---|---|---|---|---|
| lifecycle 789–790 | 49–50 | 9–10 | "full commitment release and no setup-fee or first-unit debit under OPS-11's pre-step-9 create rule" | lifecycle:249, the create row, which itself contains both "MUST settle `failed`" and "released in full … with no setup-fee or first-unit debit" |
| lifecycle 814–816 | 59–61 | 19–21 | "API-58's admission-time suspension flag write" | api:618 |
| lifecycle 818–819 | 63–64 | 23–24 | "settle failed under OPS-11's pre-step-9 rule with full release…" | :249 |
| lifecycle 823–824 | 68–69 | 28–29 | "under the same pre-step-9 rule; do not add a null-column term" (implicit OPS-11) | :249, including "no `about_to_order_at IS NULL` term" |
| api 625 | 80 | 39 | "its machine follows OPS-27's suspended-attach cancellation" | lifecycle 642–654 |
| api 670–671 | 95–96 | 54–55 | "retain OPS-27's attach and suspended-tenant cancellation path, including later evidence-based attachment after the suspension parent has settled" | 642–654 ("Without it, a create resolving *observed* after that settlement…") |

**B. Already quoted:**
- OPS-49 quotations: lifecycle 824–826, c860 69–71. Archive 29–30 still holds the historical unquoted form; Panel O's appendix 109–111 holds the quoted one.
- OPS-43 acknowledgement quotation: api 628–629, c860 83–84. Archive 42–43 holds the historical LDG-69 form; Panel O's appendix 117–120 holds the replacement.
- OPS-11 quotation: api 631–633, c860 86–88, archive 45–47. It carries the inherited LF.

**C. Bare pointer:** api 669, c860 94, archive 53 ("see OPS-43").

**D. This package's own new rule:**
- api 623 "passed OPS-43's tenant dispatch guard" (c860 78, archive 37).
- api 626–627 "fails under OPS-43" and "the step-8 tenant guard" (c860 81–82, archive 40–41).
- api 742–743 "at OPS-43's tenant dispatch guard" (c860 102–103, archive 61–62).
- The contention MUST at lifecycle 813–816.

Evidence: OPS-43 at M (lifecycle 757–913) contains no "tenant" or "suspend" at all. All five such mentions at H come from this commit. These lines reference a coordinated rule that this same adopted package defines. They do not report what an existing owner says.

**E. Checked and not attributions (no change needed):**
- lifecycle 791–792 "do not emit the admission-only kind suspended" (c860 51–52, archive 11–12) and CNF 2305. These name no requirement. They are a local instruction consistent with OPS-11:261–262 ("MUST NOT be emitted by a worker or a driver").
- References within the same requirement:
  - lifecycle 788 points at OPS-43's own steps 2–3.
  - lifecycle 820–822 and 826–827 point at OPS-43's own step-8 text (H:828–842).
  - api 630–631, "never-claimed administrative write", is API-58's own step (4).
- The CNF-202 block contains no requirement IDs.

**No missed attribution needs a replacement.** One brief locator is wrong: occurrences.md lists "04-api-contract.md:741-742", but the line containing "OPS-43" is 743 and the block spans 742–747.

## 3. Classification and quotation bytes

**Q1, Q-QUOTE:**
- **Behavior: WORDING-ONLY.** Every operative adopted word stays. The additions are quotations of rules already in force at M. The LF→space change renders identically.
- **Requirements: WORDING-ONLY.** The package adds no MUST of its own. The quoted MUSTs (OPS-11, the LDG-32 text inside it, OPS-6) are already-binding obligations, attributed to their owners. Owner items 3 and 19 and Panel O's meaning are unchanged:
  - no A/D mix;
  - no existing-fleet publication duty, since item 5 stays byte-identical at API 765–770;
  - no pv-gvc or pv-bxh change.
- **Check strength: WORDING-ONLY.** CNF-202 is byte-identical (all three option checklists are identical to H). There is no Lean, fixture, gate, baseline or negative-control change.
  - `check_citations.py:234–236` ATTRIB requires a backticked ID, so bare "OPS-27 says" lines get no gate coverage. That was already true of Panel O's quotations, so nothing is added or removed.
  - OBLIG_RE requires "`X` MUST"; none of the inserted text has that shape.
  - The new quotation marks are balanced. The OPS-27 payload contains no straight `"`. The curly outer marks around straight inner quotes follow the gate's stated convention.

**Q2, L-NOTE:** WORDING-ONLY in all three dimensions. It carries the same executable text, and the original 7688 B (sha256 `b1a08789…1682`) stays an exact prefix.

**Byte receipts.** I checked each payload with a script against my own `git show` of M. Each occurs exactly as written.

| Payload | Location at M | Notes |
|---|---|---|
| "Any create failure … whatever its kind." | lifecycle:249 | 155 chars |
| “The commitment is released in full under `LDG-32` (…) and `LDG-39` ("**Never debited**; …(`LDG-32`)"), with no setup-fee or first-unit debit.” | lifecycle:249 | Count 1. The inner LDG quotations also check: billing:310 and :1268 |
| “The settle write keeps the ordinary worker guard (`STO-3`; `OPS-6`: "…`claim_number = mine`"), with no `about_to_order_at IS NULL` term.” | lifecycle:249 | Count 1. The OPS-6 inner text also appears at M:807 |
| "marks the tenant `suspended` **in the admission transaction, before the `202` is returned**" | api:618 | Count 1 |
| OPS-27 paragraph | lifecycle 642–654 | 1229 chars and 13 lines, with LFs, bold, `*observed*` and em dashes identical. Appears exactly twice in the Q-QUOTE spec (API 625–637 and 682–694), twice in the brief and twice in the note |

Inherited quotations:
- The OPS-49 quotations match M 1927–1928 and 1955–1956 once the 3-space list indentation is removed ("A\n  serialization").
- The OPS-43 quotation matches M:817.
- The inherited OPS-11 quotation at H api:632–633 has an LF where the source has a space. Q-QUOTE normalizes it (API:644). Q-KEEP would keep the mismatch.
- I re-verified that the brief's source fences equal M byte for byte (AGENTS 29–32 and 45–46, OPS-11, OPS-27, API-58, OPS-43, citations 157–178). The evidence OPS-11 and OPS-27 copies equal M and H.

**Where the clauses beyond the quoted words come from:**
- **Release and no debit:** OPS-11:249 says it directly, and Q-QUOTE quotes it. The local instruction is kept verbatim.
- **Refusal kind and retryability:** this is Q4-D's own policy (item 3 to Panel D). OPS-11 forces `retryable: true` only for network, timeout, internal, provider-5xx and cut-off conflict, so `false` does not conflict.
- **Late evidence after the parent settles:** OPS-27, "the parent settles `succeeded` … no later pass will ever look again. Without it, a create resolving *observed*…". Quoted, plus CNF 2313–2314.
- **All entry points:** "This applies at **all three** entry points". Quoted.
- **Lost acknowledgement:** OPS-43 M:817–818 plus Q4-D item 2's recheck, kept verbatim.
- **Guarded settlement:** the OPS-11 guard sentence (quoted), plus the local "do not add a null-column term" and "claim guard … remain required".
- **Dispatch classification:** item 3's own policy. The OPS-43 quotation supports only the ordering.

## 4. Where each assertion survives in Q-QUOTE

Lines are the landed spec file / prospective brief.

| Assertion | Spec lines | Brief lines |
|---|---|---|
| Account refusal first, then tenant read before channel closure and boundary validation | life 776–784, 786, 788 | 46, 48 |
| No List offers, key upload or provider request on early refusal | 788–789 | 48–49 |
| conflict / `tenant_suspended` / `retryable: false` on error and view | 786–788 | 46–48 |
| Original `requested_by`/`system_reason`; no admission-only `suspended` | 790–792 | 50–52 |
| Plain early read | 792 | 52 |
| Same-row conditional tenant guard contending with API-58's write | 813–816 | 58–61 |
| A plain read is no substitute | 815–816 | 60–61 |
| Zero rows: rollback, failure, full release, no debit | 816–819 | 61–64 |
| No step 9 | 819 | 64 |
| First failed transaction commits neither column | 819–820 | 64–65 |
| Lost-ack repeat rechecks, keeps prior columns, no null term | 820–824 | 65–69 |
| Whole-transaction immediate serialization retry, distinct from refusal | 824–826 | 69–71 |
| Claim guard and acknowledgement before step 9 | 826–827, plus OPS-43 830 and 841 | 71–72 |
| Past the guard: potentially dispatched, allowed to settle | API 623–625 | 78–80 |
| A claim alone is not enough | 637–639 | 92–94 |
| Guarded but not yet called residue | 639–642 | 94–97 |
| No administrative fail or release for it, but a recorded pre-step-9 failure still fails | 642–644 | 97–99 |
| Cancellation at attach when the tenant is suspended | 625–637, 681–694, pre-existing 695–698 | 80–92, 106–119 |
| Late evidence attachment after the parent settles | 680–694 | 105–119 |
| Item 5 exception and disclaimer, with no existing-fleet duty | 765–770 | 125–130 |
| Item 6, every assertion | CNF 2300–2324, identical | 139–163 |

Item 6 sub-assertions by CNF line:
- 2300–2305: unclaimed-then-claimed create fails with failed, conflict, `tenant_suspended`, false on both, no request, no purchase or setup/first-unit debit, full release, origin stamp, and no admission-only error.
- 2307–2309: early read sees active, suspension lands before the guard; only non-mutating reads, no step 9, no first-transaction column or correlator.
- 2309–2313: the race in both orders, and the acknowledged guard counted as potentially dispatched with the attach-transaction cancellation.
- 2313–2314: late evidence.
- 2316–2318: lost acknowledgement.
- 2318: claim guard.
- 2319–2320: auction, `correlator: none` and per-order keys.
- 2322–2324: both precedence cases, with no request.

The Panel O payloads are byte-identical. Owner item 3's homes stay as decided ("keep `OPS-27`").

## 5. Landing, history and record

L-NOTE is the only choice that keeps the executable spec and brief consistent while leaving every historical byte in place. It also qualifies Panel O's present-tense line "all other Q4-D text is retained" in the same file. What changes:
- **Spec:** lifecycle 790, 816, 819 and 824; API 625 (becomes 625–637), 632–633 (becomes 644) and 671 (becomes 682–694).
- **comment860:** decoded lines 6, 50, 61, 64, 69, 80, 87–88 and 96, and nothing else. The bead stays closed. Prospective sha256 is `d68e73fc…da52`.
- **Archive:** the note is appended after byte 7688.
- **Dependency:** the r95 record is archived.

I checked that the note's seven replacements cover every executable change in the Q-QUOTE brief, and each appears verbatim there. Replacement 7 also occurs inside replacements 1–3, but its historical match (archive 46–47, with the LF) is unique.

**COUNTERARGUMENT (not my vote):** Q-QUOTE copies OPS-27's 13-line paragraph, argument included, into API-58 twice. API-58 already paraphrases it at H:672–675, and Q-QUOTE adds three more copies of the OPS-11 sentence. AGENTS says "Arguments have owners too" and "One rule, one home; everywhere else points at it". These bare-ID quotations sit outside the gate's reach (ATTRIB needs backticks), so an OPS-27 amendment would leave two stale copies silently, which is the SEC-46 failure. Q-POINTER is the fix AGENTS itself describes. Against L-NOTE: the archive keeps collecting appendices, its whole-file hash changes, a closed bead's comment gets edited, and there is a link dependency. Item 19's "unchanged … no repaired D" could be read as barring any edit at all.

Why I still choose Q-QUOTE: it is exact today and deletes nothing the owner adopted. Any quotation can drift, including Panel O's settled ones, and Q-POINTER still leaves an unquoted descriptor of OPS-27's content. Panel N r93 and Panel O r94b both settled on quotation plus L-NOTE.

**Contradictions in the brief:**
1. The occurrences locator `741-742` should read 742–743.
2. The brief says the summary-verb exclusion leaves prose to review. That is true but incomplete: the gate doesn't reach bare-ID quotations either, so no quotation in any of these forms is gate-verified.
3. The repository itself is in tension: `check_citations.py:168–172` calls summary paraphrase "legitimate prose", while AGENTS.md:45–46 requires a quote. AGENTS governs prose review.
4. Item 19's "unchanged" sits against the 10-28 wording rule; Panel O's precedent resolves it for wording-only forms.

**Rule 6, applied exactly as written:** none of these is a verified error that changes the question's premise, so no tally is void. None of my votes depends on any of them.

I ran no gates, builds or `br`. Temporary files are only under `tmp/opus/`.

Final: Q1=Q-QUOTE; Q2=L-NOTE; behavior=WORDING-ONLY; requirements=WORDING-ONLY; check-strength=WORDING-ONLY; owner-needed=no (wording-only exact form within the 10-28 wording rule; needs ≥3 agreeing readers, the full gate on the applied text, and the r95 record archived).
