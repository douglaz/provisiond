**Astra: PASS for the selected r97b forms**, reviewed against M=`2e2cd94637112f20538eb26b141672fedf0ba455` and approved C′ at O=`3109b5b44eae17e288cf52aaa976993bd8c5626c`.

**Final: Q2d=Q-KEEP; Q2e=Q-KEEP; Q4=L-NOTE**, using exactly the supplied appendix, with **no additional duplicate-form note**.

**apply notes.md rule 6 exactly as written; this prompt adds no void rule.**

These are my independent final preferences, not a panel tally or Run authorization. I do not reopen Q1, Q2a–c or Q3.

| Question | Exact candidate | Verdict |
|---|---|---|
| Q2d | Q-KEEP | **ACCEPT — final preference** |
| Q2d | Q-POINTER | **ACCEPT** |
| Q2d | Q-QUOTE | **ACCEPT** |
| Q2e | Q-KEEP | **ACCEPT — final preference** |
| Q2e | Q-POINTER | **ACCEPT** |
| Q2e | Q-QUOTE | **ACCEPT** |
| Q4 | L-BRIEF.txt | **ACCEPT** |
| Q4 | L-NOTE.txt with exactly L-NOTE-append.md, no duplicate addition | **ACCEPT — final preference** |
| Coordination | authority-replacement.txt | **ACCEPT** |

**Q2d: I change my preference from POINTER to KEEP.** The exact selected sentence is:

```text
**PRV-10** For a paid create (`DOM-16`), create MUST reject the request unless the
request carries an explicit purchase acknowledgement (`WIR-17`'s top-level
`acknowledge_purchase`), *and* the account is configured to allow ordering.
```

The strongest KEEP argument survives AGENTS29–32/45–46: this sentence states its own prospective obligation, **“create MUST reject”**, and identifies the acknowledgement field through its owner. It does not separately report a WIR-17 rule. AGENTS also expressly directs **“One rule, one home; everywhere else points at it.”** This is functional non-application of the source-summary requirement, not an exemption based on inherited wording or a successful lexical gate.

POINTER makes that ownership function clearer through **“wire owner: `WIR-17`”**. That remains a reasonable editorial improvement, but it repairs no demonstrated semantic or drafting violation here. Given the other readers’ actual preferences and acceptance, I choose KEEP. The following **“Both, not either.”** remains untouched.

**Q2e: independently, I change my preference from POINTER to KEEP.** The exact selected sentence is:

```text
**API-15** A paid create request (`DOM-16`) MUST carry an explicit purchase
acknowledgement — `WIR-17`'s top-level `acknowledge_purchase`, which the wire contract
owns — in addition to the account being configured to allow ordering (`PRV-10`).
```

Here **“MUST carry”** states API-15’s own prospective rule. Its field identification already expressly says **“which the wire contract owns”**. POINTER makes the same ownership more schematic; KEEP communicates it adequately while preserving the adopted words. **“In addition to”** retains the dual authorization requirement, and the PRV-10 reference identifies the companion owner.

For both questions, I retain **ACCEPT** for Q-QUOTE. Opus’s concern is real: the quotation appears after the account-authorization clause, and the literal-true words do not prove JSON nesting. Nevertheless, the explicit quotation names `acknowledge_purchase`; it does not assert that WIR-17 owns account configuration. The top-level identification is independently correct in WIR-17’s create body. I regard the placement as awkward, unnecessary evidence rather than a false normative attribution. I do not prefer it.

**Q4: I retain L-NOTE, with its costs explicitly acknowledged.** L-BRIEF’s strongest argument is preservation of both complete archive files and their original receipts. Its corrected authority statement, historical labels and archived r97 selections can distinguish approval from execution without changing either form.

L-NOTE’s strongest argument is placing the later execution qualification beside the historical form itself. That helps a reader encountering the old executable-looking document understand its historical role. I continue to prefer that local qualification, and all substantive prior readers accepted its exact supplied text.

I independently verified the complete archive concern:

- Both original forms contain 16,085 bytes and hash to `be350270318a2752992a9cb199a2a56879249be99f36e7af430bcfe8a1d47a32`.
- The r89 receipt records that hash. The archived r89b validator contains `actual==original.read_bytes()`.
- Appending the supplied note preserves every original byte as an exact prefix, but changes the whole-file hash to `ebf5de10cdebba5297239ac528d6c81c61f86e5e15e7baff97f9cb5c4ae0928d`.
- Comparing that appended file with the untouched duplicate would fail the historical equality assertion. This collateral result must not be described as unchanged archive verification.
- The note’s `../../../r97/notes.md` link resolves to the rules document, not the exact selections. I accept the disclosed navigation limitation; the corrected Agent Brief and archived selection record must supply the executable text. I propose no silent link repair.

That historical equality comparison is not a runtime conformance assertion or Lean theorem. Neither `tools/check-all.sh` nor the CI workflow invokes the archived validator. No validator, receipt, gate or negative control is weakened to conceal the difference.

My Q4 vote includes exactly the supplied appendix, SHA-256 `40480a93445c3699dce04eac8687193d037dec03ed46fdaa49f9773a983d55d2`. It includes no new synthesis and no added note in `r89/r89b/form-Cprime.md`.

**Verification and preservation.** I checked the actual candidate payloads against Git objects without whitespace normalization. The d/e literal-true quotations are exact at M. The fixed Q2a and Q2c quotation payloads also match M; Q2b’s API text, wire rule and JSON body match `7116e90…`, verified as `b278433`’s parent. The current and historical create bodies independently establish top-level placement. The appendix’s owner-wording quotation matches the archived r89b tally.

Using the supplied [assertion inventory](/var/tmp/provisiond-panel-r97/check/tally-evidence.md), I verified the unchanged complete CNF-55 payload against approved C′ and the retained source spans against M. The CNF-34 difference is exactly PR60’s insertion. The selected open forms preserve paid-create scope, both authorizations, the complete hourly package, current retentions and the fixed CNF-364 correction. They introduce no runtime assertion or fixture.

| Final pick | Behavior | Requirements / items 4+24 / C′ meaning | Check strength |
|---|---|---|---|
| Q2d Q-KEEP | **WORDING-ONLY**, unchanged | **WORDING-ONLY**, unchanged | **WORDING-ONLY**, unchanged |
| Q2e Q-KEEP | **WORDING-ONLY**, unchanged | **WORDING-ONLY**, unchanged | **WORDING-ONLY**, unchanged |
| Q4 L-NOTE | **WORDING-ONLY** | **WORDING-ONLY**; separates historical approval from execution | **WORDING-ONLY**; historical archive-equality consequence disclosed above |

**Rule 6:** I found no verified brief error changing an open question’s premise. The historical approval quotation’s archive-link mismatch remains a disclosed, non-premise-changing discrepancy; none of my preferences depends on whole-paragraph byte identity. The appendix-link limitation is expressly disclosed in this packet. The preparation-only statements are superseded by the actual launch instruction.

At the final recheck, main’s `origin/master` and `pv-9ecf` both remained M; the moved-ref condition did not arise. This clone’s HEAD remained M and its tracked diff was empty. I wrote no files and ran no gates, builds, provider requests, external messages, Git mutations or subagents.