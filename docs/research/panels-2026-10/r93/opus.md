# Panel N r93: opus seat

I ran no gates, made no source, Git, tracker or PR changes and launched no subagents. My only writes were scratch scripts under `tmp/opus/`. I did not read other readers' outputs.

## 1. Q1: which exact replacement text

**Q1 final pick: Q-QUOTE.**

| Form | Verdict |
|---|---|
| Q-QUOTE | **ACCEPT** |
| Q-POINTER | **CANNOT ACCEPT** |
| Q-KEEP | **CANNOT ACCEPT** (its exemption is not proved, so it is not eligible) |

The picked pair, in full.

Replay replacement:

```text
API-7 step 5a says "an equal fingerprint under the
    same `(principal, key)` returns the stored result, a different one fails `conflict`."; a replay returned there never reaches this check.
```

Manual-release replacement:

```text
API-65 says "On a row whose `cleanup` is `manual` there is no driver call to make: it
writes `released_at` and answers `200` with the row, minting no operation,"; a manual attachment release takes no capability check under this timing rule.
```

**Why Q-QUOTE**
- Each claim about another requirement now carries that requirement's own words. Both quotes match the pin byte for byte (§4).
- The quote shape, including the line break and the 4-space indent, is already used in a requirement at the pin. API-68 (`04-api-contract.md:1085–1086`) reads: `` `API-7` step 5a applies first: "an equal fingerprint under the `` / `    same `(principal, key)` returns the stored result".` So this is not a new style.
- Both of item 16's assertions stay explicit, in the same place in the text.
- The paraphrase "has no driver operation" is replaced by API-65's own words. "there is no driver call to make" and "minting no operation" cover both halves of the old phrase.

**Where "takes no capability check" comes from.** It is item 16's own timing rule, not API-65. API-65 (`04-api-contract.md:1102–1115`) never uses the word "capability" (I counted zero occurrences). In the archived Q1-A the rule appears in three places:
- line 14: "…takes no capability check.";
- lines 41–42: "this timing rule adds no gate / to refresh, a manual attachment release, or the capability-less methods named by PRV-4.";
- the admission scope list at lines 6–7, which names only "API-cleanable attachment release", so manual release is outside it.

It is consistent with existing text but not stated there. DOM-10 at `01-domain-model.md:515–516` gates "Every operation with a capability … before the / driver is called". API-65's quoted words say a manual release has no driver call and mints no operation, so there is nothing for that gate to apply to.

In Q-QUOTE the rule is kept at derived line 15 ("a manual attachment release takes no capability check under this timing rule."), and the unchanged lines 42–43 keep the paragraph-4 restatement. "Under this timing rule" marks the clause as item 16's rule rather than part of the API-65 quote. It is the same scope paragraph 4 already states, so it adds no new rule. **My pick is unconditional.**

**Why not Q-POINTER**
- The replay bypass is DOM-10's own rule about its own check. API-7 says nothing about non-create capability checks: its step 5d only says "gate a create on its ordering capability" (`04-api-contract.md:241`). So "see API-7 step 5a" points at whoever owns the fact (a replay returns its stored result), not the rule (a replay never reaches this check).
- The explicit replay sentence is therefore lost. It survives only as an inference from "runs after API-7's steps 1–5c" plus step 5a's "returns the stored result".
- No conformance item or Lean theorem covers where non-create checks sit, so this is not a rule-3 blocking loss. It does still remove an explicit sentence the owner adopted, which is a change to the requirement text rather than a pure rewording.
- The manual-release no-check survives only through paragraph 4 and the scope list.
- The printed form has a defect: "transaction; For manual attachment release, see API-65." puts a capital letter after a semicolon and joins a retry rule to a pointer. Fixing it would make a different form.

**Why not Q-KEEP.** AGENTS.md lines 29–32 do apply here.
- "API-65's manual release has no driver operation" is a paraphrase of what API-65 says. That is the shape AGENTS.md:31 calls "an assertion".
- AGENTS.md:45 requires "every sentence asserting what another requirement says carries its quote".
- That the claim is true does not exempt it. The rule is about whether the claim can be checked, and the merge stop already found the facts true and the defect still present.
- `check_citations.py:162` says "Summary verbs are deliberately OUT OF SCOPE.", but that limits what the gate can detect, not what AGENTS.md requires.
- Since the exemption is not shown, I print no reply.

## 2. Q2: where the fix lands

**Q2 final pick: L-NOTE, using `note-Q-QUOTE.md`.**

| Landing | Verdict | Reason |
|---|---|---|
| L-NOTE | **ACCEPT** | Keeps the original bytes as a prefix of the file, adds a dated note with the correction, and the Brief's authority line names both forms. |
| L-BRIEF | **ACCEPT** (acceptable fallback, not preferred) | Nothing becomes false. But the archive, which still says "This form adds the following paragraphs … in `DOM-10`", has no in-file pointer to the correction, and PR #53's README row links it as "exact [Q1-A](r86/r86b/Q1-A.md)". It lands the rule but writes no record where the defect lives (AGENTS.md:26–27: "Land the rule; write the record after."). |
| L-BOTH | **CANNOT ACCEPT** | See below. |

**Why L-BOTH fails**
- **It silently rewrites what the owner adopted.** Item 16 says "adopt exactly /var/tmp/provisiond-panel-r86/r86b/Q1-A.md". The archive's sha256 `db7f2b55…` currently equals that external file; L-BOTH breaks that, and the README's "exact [Q1-A]" becomes false.
- **It contradicts the new authority line**, which would call the edited file the "Historical adopted form".
- **It breaks the Brief's own line citations.** The Brief must stay otherwise unchanged, so its `Q1-A.md:25` and `Q1-A.md:58` citations would point at the wrong lines. I checked this mechanically: under Q-QUOTE the text moves to lines 26 and 59; under Q-POINTER to 24 and 57.

**Keeping the original offending sentences in the archive is acceptable under AGENTS.md.**
- The quotation rule sits under "## Writing a requirement", and the archive is a record, not a requirement.
- The gates read only root `*.md`, `docs/adr` and the Lean files (`check_citations.py:572–575`, `check_ids.py:65`).
- By analogy, the panels README (line 8) keeps readers' answers "verbatim, including claims a later round or the synthesis corrected."

**Dependency on the r93 archive.** The note's `../../r93/notes.md` resolves to `docs/research/panels-2026-10/r93/notes.md`. That file is absent at both refs, and no gate checks relative links, so a missing file would leave the link broken with no warning. The apply turn must add the r93 archive in the same change, or the note must not ship.

One cosmetic point: the archive ends in two newlines and the note starts with one, so the appended file has two blank lines before the note. That is harmless.

**L-NOTE keeps the record of what the panel and owner actually approved honest.**

The chosen note, in full:

````text

## Wording correction — 2026-10-31 (Panel N r93)

The text above is retained as the historical form approved in owner item 16.
The executable pv-5pmu Agent Brief uses the following replacements under the
owner's 2026-10-28 wording rule; all other Q1-A text is retained.

Replacement for the replay sentence:

```text
API-7 step 5a says "an equal fingerprint under the
    same `(principal, key)` returns the stored result, a different one fails `conflict`."; a replay returned there never reaches this check.
```

Replacement for the manual-release clause:

```text
API-65 says "On a row whose `cleanup` is `manual` there is no driver call to make: it
writes `released_at` and answers `200` with the row, minting no operation,"; a manual attachment release takes no capability check under this timing rule.
```

Source pin: `3d1fca55e64056e5ad6bc9ac3edcc308ecf04073`.
Review head: `fde983c1794e8d4727f22bc87d1d6ee7f407eca5`.
Panel record: `../../r93/notes.md`.
````

The authority line is replaced exactly as the brief prints it.

## 3. Wording-only or meaning change

**Q1 (Q-QUOTE): WORDING-ONLY.**
- **Behavior:** unchanged. A replay still returns at step 5a, before the check. A manual release still mints no operation and gets no check.
- **Requirement:** both explicit statements are kept, and no obligation is added or removed. The "under this timing rule" scope is already stated in paragraph 4.
- **Check strength:** unchanged. At the pin, no conformance item or Lean theorem covers non-create placement; Q1-A is not yet applied, and grep finds nothing touching manual-release capability.

**Q2 (L-NOTE): WORDING-ONLY.** It is purely about keeping the record: no requirement text changes, the original bytes are retained, and the note adds no rule.

**Owner exception.** The 2026-10-28 exception covers both picks once they are settled; with grok down, that means three of four readers. They touch "only the WORDING of owner-adopted text".

This is separate from item 16's own substantive adoption. That adoption needed the owner because, per `owner-questions-original.md` §1, "A's additional normative order exceeds the owner's wording-only precedent". This correction does not reopen it. L-BOTH, if anyone wanted it, would change the adoption record itself and should go to the owner.

## 4. Quotation verification

Every quote was matched with `git show` at both refs; each occurs once.

| Quote | Location (both refs) | Line breaks / indent |
|---|---|---|
| API-7 step 5a ("an equal … `conflict`.") | `04-api-contract.md:209–210` | Newline plus 4 spaces before "same": **match** |
| API-65 ("On a row … minting no operation,") | `04-api-contract.md:1109–1110` | Newline after "it", no indent: **match** |
| API-68 precedent | `04-api-contract.md:1085–1086` | **match** |
| API-7 step 5d; tail anchor; manual tail row | `04-api-contract.md:241`; `243`; `251` | **match** |
| API-64 "both in one transaction" | `04-api-contract.md:1053–1054` | **match** |
| AGENTS.md | lines 26–27, 29–32, 34–38, 45–46 | **match** |
| DOM-10 | `01-domain-model.md:515–516`; release-attachment row at 538 | **match** |
| OVR-2 | `00-overview.md:23–24` | **match** |
| OPS-23 | `03-operation-lifecycle.md:2018–2019` | **match** |

**Whole files.** `04-api-contract.md`, `AGENTS.md`, `01-domain-model.md`, `03-operation-lifecycle.md` and `00-overview.md` are identical between master and the PR head. All eight pinned blocks in the brief equal master's bytes.

**Archive and Agent Brief**
- The archive at the PR head equals the evidence copy and the external r86b original (sha256 `db7f2b55cf4f…`, matching `stop-result.json`).
- The pv-5pmu Agent Brief comment at the PR head equals `agent-brief-original.md`. The authority line is at its line 6, the two offending sentences occur once each, and its Desired behavior block equals archive lines 3–59.
- Item 16 equals `r86/owner-decisions.md:5–11` at the PR head; the evidence copy only adds one trailing newline.
- `owner-questions-original.md` equals the PR's `r86b/owner-questions.md`.

**Derived forms.** `Q-QUOTE.md`, `Q-POINTER.md` and `agent-Q-*.md` are exactly the pair applied mechanically; nothing else differs.

**Failures:** none. The finding reply shows the quotes reflowed onto one line, which is display-only; the real bytes contain the newlines above.

## 5. Assertion map (Q-QUOTE + L-NOTE)

"Unchanged" means the bytes are identical; line numbers are in the derived Q-QUOTE form. All original bytes also stay in the archive under L-NOTE, as a prefix of the file.

| # | Assertion | Where it lands |
|---|---|---|
| 1 | Inserted after the mapping table, before the amendment note; mapping rows and error sentence kept | Unchanged, line 3; DOM-10 at 515–519 and table 521–538 retained |
| 2 | Admission scope list | Unchanged, 6–7 |
| 3 | Caller/operator request MUST pass before enqueue | Unchanged, 7–8 |
| 4 | Runs after API-7 steps 1–5c and local admission checks, before the first enqueue write | Unchanged, 9–10 |
| 5 | Uses the api descriptor; no provider request | Unchanged, 10–11 |
| 6 | Failed check: no enqueue, no state or money write | Unchanged, 11–12 (the Brief's archive `:11` citation stays valid) |
| 7 | **Replay bypass** | **Replacement**, 12–13; the fact's source is API-7 at 209–210 |
| 8 | API-64 retry checks `delete_machine` before its transaction | Unchanged, 13–14 |
| 9 | **Manual release: no driver operation** | **Replacement**: API-65's own words at 1109–1110 |
| 10 | **Manual release: no capability check** | **Replacement** at 15, plus unchanged 42–43 |
| 11 | Suspend parent unchecked; its children gated at claim | Unchanged, 16–17 |
| 12 | Worker MUST check, using the worker's descriptor | Unchanged, 19–20 |
| 13 | Worker scope: non-HTTP work, API-64 retry attempts, releases enqueued by a delete | Unchanged, 20–21 |
| 14 | After claim and serialization; before the driver call and both OPS-45 markers | Unchanged, 22–23 |
| 15 | Validation order, ending with the capability check | Unchanged, 23–26 |
| 16 | First failing check stops the rest | Unchanged, 26 (the Brief's archive `:25` citation stays valid) |
| 17 | Classified by OPS-11; DOM-10's existing unsupported result | Unchanged, 26–27 |
| 18 | No commitment, rate or solvency check for a non-purchase | Unchanged, 28 |
| 19 | OPS-41 claim gate and fence decision come first | Unchanged, 30–31 |
| 20 | No-call success or defer takes no check | Unchanged, 31–32 |
| 21 | Check after fence acknowledgement, before driver call or marker | Unchanged, 32–33 |
| 22 | Failure disposition; no automatic attempt; fence not cleared | Unchanged, 34–35 |
| 23 | No check when work is enqueued internally | Unchanged, 36 |
| 24 | Retry ceiling and OPS-39 exemption keep their scope | Unchanged, 36–37 |
| 25 | Capability = mapping entry; rescue order; inventory; PTR | Unchanged, 39–41 |
| 26 | No inference from eligibility; no gate on refresh, manual release or PRV-4 methods | Unchanged, 42–43 |
| 27 | API-7 pointer | Unchanged, 49 |
| 28 | OPS-23 pointer | Unchanged, 55–56 |
| 29 | No create gate moves; classifier/markers keep their meaning; phase change disclosed | Unchanged, 59 (the Brief's archive `:58` citation stays valid) |

**Nothing is lost under Q-QUOTE.** Under Q-POINTER, assertion 7 would survive only as an inference and assertion 10 only through assertion 26. No checked verdict would change, but explicit text would be lost.

## 6. Requested counterargument (not a vote) and brief errors

**Against Q-QUOTE.** It copies API-7 and API-65 text into DOM-10, which AGENTS.md:37–38 warns is "how a second normative copy gets written". With bare IDs and the "step 5a says" shape, the citation checker's attribution pattern would not verify either quote, so later drift would go unnoticed. "Under this timing rule" could also be read as narrowing the rule. Q-POINTER is the "one rule, one home" answer, and the bot itself suggested pointers.

My rebuttal: the quotes cover facts, not rules, and DOM-10 still owns the rules. The pointers would drop DOM-10's own replay rule, and API-68 already uses this exact quote.

**Against L-NOTE.** Appending to the file changes its sha, so the README's "exact" link no longer points at exactly the adopted bytes. There would be two copies of the correction (note and Brief) that could diverge, and the r93 link may be left broken without warning. L-BRIEF avoids all three.

My rebuttal: the original bytes are kept as a prefix under a dated heading, and keeping the defect visible next to the archive is worth that cost.

**Brief errors.** None of these changes the premise of either question, so under rule 6 no tally is void. No reason I give rests on them.
- `agent-Q-QUOTE.md` and `agent-Q-POINTER.md` apply only the pair, not Q2's authority-line replacement. So no single file of the complete landed Agent Brief was supplied for review.
- Q-POINTER's "; For" capitalization defect is not mentioned in the brief.
- `r86/owner-decisions.md:3` at the PR head says "the Agent Briefs carry the adopted exact forms." No landing updates that sentence, and after any correcting landing it is out of date for pv-5pmu. The apply turn should fix it.
- The authority line cites `owner-decisions-1030.md`, which is not in Git; `r83/brief.md:13` says the same. This already exists and is not introduced by this correction.
- Unchanged clauses such as API-64's state-change/enqueue transaction and the OPS-41/PRV-25/OPS-39 references still paraphrase other requirements without quotes. Source text does support the API-64 clause (`04-api-contract.md:1053–1054`). They are out of scope here, but a later bot pass could flag them.

Final: Q1=Q-QUOTE; Q2=L-NOTE; Q1=WORDING-ONLY; Q2=WORDING-ONLY
