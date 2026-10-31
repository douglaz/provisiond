**Q1 final pick: Q-QUOTE. Q2 final pick: L-NOTE.** Both picks are **WORDING-ONLY**, assessed separately below. This is one reader’s ballot, not a panel settlement.

I applied notes.md rule 6 exactly as written; this prompt adds no void rule. I found no verified brief error that changes either question’s premise.

| Exact Q1 form | Verdict | Reason |
|---|---|---|
| Q-QUOTE | **ACCEPT** | Preserves the explicit assertions and supplies exact supporting quotations. |
| Q-POINTER | **ACCEPT** | Preserves the operative obligations through the retained timing, exclusions and owning requirements, although it removes their explicit local explanations. |
| Q-KEEP | **CANNOT ACCEPT** | Its required exemption is unproved. These are cross-requirement assertions, so factual support alone does not satisfy the quotation rule. |

My picked replay replacement, in full:

```text
API-7 step 5a says "an equal fingerprint under the
    same `(principal, key)` returns the stored result, a different one fails `conflict`."; a replay returned there never reaches this check.
```

My picked manual-release replacement, in full:

```text
API-65 says "On a row whose `cleanup` is `manual` there is no driver call to make: it
writes `released_at` and answers `200` with the row, minting no operation,"; a manual attachment release takes no capability check under this timing rule.
```

The manual **no-capability-check instruction belongs to item 16’s adopted timing rule**. API-65 supplies the quoted no-driver-call/no-operation facts; it does not supply the words “takes no capability check.” Q-QUOTE preserves that instruction expressly after the quotation. Its ownership qualification agrees with the retained final exclusion and the admission scope limited to API-cleanable attachment releases. It supplies no permission to introduce a manual-release capability gate.

For Q-POINTER, the explicit replay-bypass and manual no-driver/no-check sentences disappear locally. Replay bypass still follows from the retained placement after steps 1–5c together with step 5a’s stored-result return. Manual no-check remains supported by the retained final exclusion, admitted-operation scope and API-65’s no-operation case. I identify no changed normative or checked verdict from that redistribution. I prefer Q-QUOTE because it preserves the assertions explicitly.

| Exact Q2 landing | Verdict | Record assessment |
|---|---|---|
| L-BRIEF | **CANNOT ACCEPT** | The revised brief distinguishes historical approval from execution, but the flagged archive itself remains an unqualified complete candidate with neither correction nor local notice. This inadequately addresses the historical/executable ambiguity at the finding’s location. |
| L-BOTH | **CANNOT ACCEPT** | Silently changes the document adopted exactly by the owner. Readers could mistake corrected words for the words originally approved. |
| L-NOTE | **ACCEPT** | Preserves the original approval evidence and identifies the subsequent executable correction at both relevant locations. |

My L-BRIEF rejection concerns completeness and record presentation; I claim no runtime or formal verdict changes merely from that landing.

For L-NOTE, use the specified authority-line replacement exactly:

```text
**Owner decision:** “Approve A (Recommended)” (`owner-decisions-1030.md`, item 16). Historical adopted form: `docs/research/panels-2026-10/r86/r86b/Q1-A.md`. Executable form: the Desired behavior / key interfaces block below, with the 2026-10-31 Panel N r93 wording correction.
```

Append **note-Q-QUOTE.md in full**, including its initial blank line:

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

The note preserves evidence of defective wording; it does **not** make those original sentences compliant merely by calling them historical. Its explicit historical designation, operative replacements and supporting source quotations prevent them from remaining the executable instruction. This preserves what the panel and owner actually approved without silently rewriting it.

The relative panel-record path resolves correctly from the archive’s directory to `docs/research/panels-2026-10/r93/notes.md`. That file **does not exist at the reviewed PR head**. The later authorized application must archive the settled panel record there alongside the correction. The prospective note must not be presented as an already-applied correction or completed consensus.

**Classification and authority**

| Pick | Behavior | Requirement | Check strength | Classification |
|---|---|---|---|---|
| Q-QUOTE | Same replay return and manual-release treatment | Same exemptions and placement | No changed refusal, validation, marker or ordering obligation | **WORDING-ONLY** |
| L-NOTE | Same executable behavior | Same approved instructions, with provenance distinguished | No weakened declaration, obligation, fixture or negative control | **WORDING-ONLY** |

Historical integrity is included in the second assessment: the original bytes remain, and the correction is identified as subsequent. After exact-form consensus and verification, the owner’s 2026-10-28 exception permits these wording corrections without another owner decision. This ballot alone does not establish consensus. Item 16’s original adoption separately authorized substantive ordering choices; this correction does not reauthorize or alter them.

**Byte verification**

Here, **M** means master `3d1fca55e64056e5ad6bc9ac3edcc308ecf04073`; **R** means review head `fde983c1794e8d4727f22bc87d1d6ee7f407eca5`.

| Evidence | Verification |
|---|---|
| Clone refs | HEAD equals M; `origin/pr53` equals R. |
| Replay quotation | Exact substring of M:`04-api-contract.md:209–210`. Embedded LF and four leading spaces on the continuation match. |
| Manual quotation | Exact substring of M:`04-api-contract.md:1109–1110`. Embedded LF, unindented continuation and terminal comma match. |
| Quotation rule | M:`AGENTS.md:29–32`, ownership passage at `34–38`, and completion passage at `45–46` match the supplied blocks, including line breaks. |
| Master/review equality | Entire `AGENTS.md` and `04-api-contract.md` are byte-identical between M and R. Thus the relevant API-7/API-65 passages are identical too. |
| Archive | R:`docs/research/panels-2026-10/r86/r86b/Q1-A.md:1–59` equals `evidence/Q1-A-original.md` byte for byte. SHA-256: `db7f2b55cf4f49fcc22e6b57d6efc72daaa158817faff1cf2ad67981c19f28e3`. |
| Agent Brief | `evidence/agent-brief-original.md` equals pv-5pmu’s `comments[0].text` in R:`.beads/issues.jsonl`, byte for byte. It is stored in the comment, not the description field. |
| Owner adoption | R:`docs/research/panels-2026-10/r86/owner-decisions.md:5–11` confirms item 16’s exact adoption. The authority-line decision wording matches that record. |
| Complete candidates | Each supplied Q1 file equals the historical archive after precisely its specified pair of replacements; Q-KEEP equals the original. |
| Note variants | Both were read whole; each contains precisely its corresponding replacement pair. The selected note above preserves its newlines and indentation. |
| Existing source | M:`01-domain-model.md:515–541` and `03-operation-lifecycle.md:2018–2034` match the supplied source passages; both complete files also equal R. |

The finding reply’s displayed quotation is **not byte-identical** to API-7/API-65: it reflows their embedded newlines. That is a verification failure for treating the reply’s display as an exact source quotation, not a failure of Q-QUOTE. I used the pinned source bytes.

The quotation rule’s operative sentence is, exactly, at M:`AGENTS.md:29–30`:

```text
A claim about what another requirement says carries that requirement's own
words.
```

That applies to the original replay attribution and manual-release attribution. Q-KEEP supplies no demonstrated exemption. The unresolved finding establishes a stop condition, not a ballot against any replacement.

**Assertion map**

Let **H** denote R’s archived `r86/r86b/Q1-A.md`, and **Q** the supplied complete `Q-QUOTE.md`. The executable Agent Brief retains Q’s body beginning at Q:3; its line numbers are Q’s plus 25. L-NOTE preserves every original H byte and appends the note.

| Original assertion or instruction | Exact executable landing |
|---|---|
| Existing mapping rows and error sentence retained; insertion before amendment note | H:3 → Q:3 unchanged; existing M:`01-domain-model.md:515–540` retained |
| Power/on/off/reboot, hard reset, all install strategies, inventory, reverse DNS, delete/cancel and API-cleanable-release admission scope; caller/operator MUST check before enqueue | H:6–8 → Q:6–8 unchanged |
| After steps 1–5c and endpoint validation/admissibility; immediately before first transaction write | H:9–10 → Q:9–10 unchanged |
| API descriptor; no provider request; refusal enqueues nothing and writes neither endpoint state nor money | H:10–12 retained around replacement, Q:10–12 |
| Replay bypass | H:12–13 replaced by the full picked replay text, Q:12–13 |
| API-64 retry checks `delete_machine` before state-change/enqueue transaction | H:13–14 → Q:13–14 unchanged bytes |
| Manual release has no driver operation and takes no capability check | Picked manual replacement, Q:14–15; no-operation fact quoted, no-check instruction explicit |
| Suspend parent has no admission per-machine check; children gated at claim | H:15–16 → Q:16–17 unchanged |
| Worker scope, descriptor, HTTP-independent work, retries and delete-enqueued releases | H:18–20 → Q:19–21 unchanged |
| After claim/serialization; before first driver call and either marker | H:21–22 → Q:22–23 unchanged |
| Caller fields, API fields, remaining local validation, install eligibility, signed URL, then capability | H:22–25 → Q:23–26 unchanged |
| First failure stops later checks; classifier and existing unsupported result retained | H:25–26 → Q:26–27 unchanged |
| No commitment/rate/solvency check introduced for non-purchases | H:26–27 → Q:27–28 unchanged |
| Cancellation restore gate and ordered fence decision precede capability; no-call/defer bypass | H:29–31 → Q:30–32 unchanged |
| Proceeding cancellation checks after fence acknowledgement, before driver/marker | H:31–33 → Q:32–34 unchanged |
| Existing failed-attempt/episode disposition; no extra automatic attempt or fence clearing | H:33–34 → Q:34–35 unchanged |
| Internal enqueue has no enqueue-time check; operator/system ceiling scopes retained | H:35–36 → Q:36–37 unchanged |
| Mapping determines capability; rescue strategy before `rescue_ssh`, before rescue; inventory checks `rescue_ssh` | H:38–40 → Q:39–41 unchanged |
| Identical-PTR success after capability; no inference from install eligibility | H:40–41 → Q:41–42 unchanged |
| Refresh, manual release and capability-less-method exclusions | H:41–42 → Q:42–43 unchanged |
| API-7 pointer and insertion position | H:45–48 → Q:46–49 unchanged |
| OPS-23 pointer and insertion position | H:51–55 → Q:52–56 unchanged |
| No create-gate movement; pre-rescue classifier/marker preservation; observable-phase assessment | H:58 → Q:59 unchanged |
| Acceptance criteria, retained/rejected material and other Agent Brief bytes | Unchanged outside the specified Desired block pair and authority line |
| Original approval and historical wording | H preserved byte for byte; original Agent Brief quotations remain uncorrected as historical quotations |

No assertion is removed by my complete pick. No checked or normative verdict is changed, made unreachable or vacuous.

**Requested counterargument — not a vote**

Against Q-QUOTE, the phrase “under this timing rule” could be read as narrower than the original manual exemption, and embedded source wrapping is awkward. My assessment is that the qualifier identifies the exemption’s actual owner and scope; the explicit exemption remains alongside the original final exclusion.

Against L-NOTE, retaining offending sentences may invite copying them, and the note references a future panel archive. Those are real presentation and application risks. The authority-line distinction, local corrective appendix and synchronized executable brief address copying; creation of the referenced panel record remains an application dependency.

The historical observable-phase sentence warrants care. M:`00-overview.md:23–24` already contains:

```text
the server MUST NOT
accept an operation a provider has not declared support for.
```

Thus an interpretation that unsupported enqueue was previously permitted is false. The supplied historical owner-questions §1:23 already acknowledges that earlier overstatement. Exact placement and precedence can still determine observable refusals. This does not change Q1’s replacement question or Q2’s provenance question, so rule 6 does not void either tally; neither pick relies on the false interpretation.

All work was read-only. No gates, builds, tracker commands, external actions or subagents were run.

Final: Q1=Q-QUOTE; Q2=L-NOTE; Q1=WORDING-ONLY; Q2=WORDING-ONLY