# Panel N r93 — settled Q-QUOTE / L-NOTE

**apply notes.md rule 6 exactly as written; this prompt adds no void rule.**

Both questions settle on the exact reviewed forms. Nothing is adopted into the tracker by this tally. Next step: an apply turn on PR #53, rebased onto `a7b6884878bc7e53dc403dd8a4383d85afac3634`, with the exact package in `settled-pv-5pmu.md`. No owner question and no r93b are needed.

## Seats and separate tallies

The substantive answers are Opus (exit 0, 17024 bytes), Astra (exit 0, 16856 bytes), and Sol (exit 0, 14129 bytes). Fable exited 1 with a 158-byte limit line; it is missing, not a vote. Grok was missing with HTTP 402 at launch. No seat was rerun. Codex stdout copies equal their final answers apart from trailing whitespace; Claude stderr files are empty. Codex stderr contains the completed read/verification traces, with no additional draft, terminal error, timeout or replacement ballot. See `check/tally-reader-log-review.json` and `check/tally-verification.json` for hashes and byte counts.

notes.md rule 2 gives the owner's threshold verbatim: "a question is settled when at least three agree and more agree than disagree, and a tie comes to you. If grok is down, it falls back to three of four". Missing Fable does not lower the required three agreements. Final picks, acceptability and requested counterarguments are kept separate below.

### Q1 — replacement text

| Reader | Final pick | Strongest argument | Conditions / separate acceptability |
|---|---|---|---|
| Fable | MISSING | Limit line; no substantive answer | No vote |
| Opus | Q-QUOTE | Keeps both explicit adopted instructions while supplying the source facts in their own words | Unconditional; ACCEPT Q-QUOTE; CANNOT ACCEPT Q-POINTER and Q-KEEP |
| Astra | Q-QUOTE | Keeps the replay bypass and manual exclusion explicit, with correct source ownership | Unconditional; ACCEPT Q-QUOTE and Q-POINTER; CANNOT ACCEPT Q-KEEP |
| Sol | Q-QUOTE | Preserves every operative assertion and distinguishes source facts from the adopted timing instruction | Unconditional; ACCEPT Q-QUOTE and Q-POINTER; CANNOT ACCEPT Q-KEEP |
| Grok | MISSING | 402 at launch | No vote |

Final picks: Q-QUOTE 3, Q-POINTER 0, Q-KEEP 0; all available readers agree on the same complete Q-QUOTE pair. Acceptance sets: Q-QUOTE {Opus, Astra, Sol}; Q-POINTER {Astra, Sol}; Q-KEEP {}. No second form qualifies. Opus's Q-POINTER objection is a real distinction in acceptability, not dissent from the settled form. It drops an explicit local replay-bypass sentence and manual explanation; the other readers consider the retained ordering and final exclusion operationally equivalent. That disagreement need not be decided to settle the unanimous preference.

Strongest requested counterargument, not a vote: Q-POINTER avoids duplicated source material and awkward wrapping; Q-QUOTE's qualifier could look narrower in isolation. Verification: the original rule already has the same timing-rule scope and manual exclusion, and the replacement keeps the no-check instruction explicit. No reader proved the Q-KEEP exemption. The source facts being supported does not establish exemption from the quotation rule.

### Q2 — landing and historical integrity

| Reader | Final pick | Strongest argument | Conditions / separate acceptability |
|---|---|---|---|
| Fable | MISSING | Limit line | No vote |
| Opus | L-NOTE | Preserves the adopted original as an exact prefix and gives the flagged archive an in-file correction | ACCEPT L-NOTE and L-BRIEF; CANNOT ACCEPT L-BOTH; ship the referenced r93 archive with the correction |
| Astra | L-NOTE | Distinguishes what was approved from what the Agent Brief will execute without silently rewriting approval evidence | ACCEPT L-NOTE only; ship the referenced r93 archive and make the note true at landing |
| Sol | L-NOTE | Marks the historical/executable distinction at both relevant locations while preserving every original archive byte | ACCEPT L-NOTE only; ship the referenced r93 archive with the correction |
| Grok | MISSING | 402 at launch | No vote |

Final picks: L-NOTE 3, L-BRIEF 0, L-BOTH 0. Acceptance sets: L-NOTE {Opus, Astra, Sol}; L-BRIEF {Opus}; L-BOTH {}. Only L-NOTE qualifies. Each agreeing answer prints the exact same complete `note-Q-QUOTE.md`, including its initial blank line, and accepts the brief's exact authority-line replacement. Their shared application dependency is already part of the reviewed candidate, not a manager repair.

Strongest requested counterargument, not a vote: appending changes the whole archive file's hash, leaves flawed historical sentences visible, duplicates the correction, and could leave a dangling r93 link. L-BRIEF minimizes archive intervention but leaves the finding's location unqualified. L-BOTH silently rewrites approval evidence, and its authority line would then call rewritten bytes historical. The selected note explicitly distinguishes historical original from subsequent correction; original byte identity is verified for the entire preserved prefix, not falsely claimed for the appended whole file. The apply turn must supply `docs/research/panels-2026-10/r93/notes.md` and the settled panel record together. No relative-link gate coverage is assumed.

## Independent verification of wording-only claims

I verified each reader's Q1 judgment independently against the actual pin and the external r86b original. The replay instruction remains explicit in the exact reviewed replacement. Its source payload matches `04-api-contract.md:209–210`, including LF plus four spaces. The manual replacement keeps the no-check instruction outside the source quotation; its source payload matches `04-api-contract.md:1109–1110`, including LF, unindented continuation, and trailing comma. `check/tally-verification.json` records their exact bytes, locations and hashes.

The original manual instruction is at Q1-A:14:

```text
API-65's manual release has no driver operation and takes no capability check.
```

The same adopted form's own final exclusion at Q1-A:41–42 is:

```text
this timing rule adds no gate
to refresh, a manual attachment release, or the capability-less methods named by PRV-4.
```

These are the ownership evidence for the no-capability-check instruction. API-65 supplies the separate source facts through the quotation printed in the settled package; it is not the source of the no-check words. The replacement's final clause identifies the existing timing rule and preserves that instruction at Q-QUOTE:15; the final exclusion remains byte-identical at Q-QUOTE:42–43. The admission scope's API-cleanable-release restriction is also untouched. Neither the qualifier nor quotation grants permission for a manual capability gate.

For Q1, separately for Opus, Astra and Sol: behavior is preserved by the explicit replay bypass, explicit manual no-check instruction and unchanged surrounding scope/order; requirement meaning is preserved by the complete map and reverse-substitution proof; check strength is preserved because no normative condition, declaration, proof, guard, fixture, negative control or tested assertion is removed or changed by this correction. No claim that gate success proves semantic equivalence is made. No absent runtime test is treated as a contradiction. The original owner adoption remains the substantive authorization for its ordering package; this correction does not reclassify that adoption.

For Q2, separately for Opus, Astra and Sol: behavior and requirements follow the same executable package; check strength is unchanged; historical integrity follows from retaining all original bytes as a prefix and explicitly identifying the dated correction. The authority line distinguishes historical approval from executable wording rather than retroactively attributing the new words to the owner. The unchanged historical sentences are evidence of the former wording, with the operative correction alongside them; this is not Q-KEEP. The archive dependency must be satisfied at application, and nothing here claims it already exists on the PR.

The complete independent assertion audit is `assertion-map.md`, with its machine-derived span manifest at `check/assertion-map.json`. Each entry names its assertion, quotes its original span without reflow, gives exact Q-QUOTE and prospective Agent Brief locations, and verifies unchanged bytes or the exact reviewed replacement. The map covers the insertion/mapping/error retention; all admission scope/order/state effects; replay; retry; manual release; suspend children; worker scope, descriptor and recheck order; validation/first failure/classifier/purchase-check scope; cancellation restore/fence/no-call/defer/failure/retry constraints; internal enqueue and ceiling scopes; capability mapping/rescue/inventory/PTR; eligibility inference and all exclusions; both pointer contents and placements; create-gate retention; classifier/marker retention; and the observable-phase assessment. The prospective Agent Brief also retains every acceptance criterion, historical quotation and out-of-scope byte. Reversing exactly the pair and authority-line substitutions reproduces the original comment byte for byte.

## Source drift and quotation receipts

The independent `git show` checks use the reader clone, never the main checkout or another worktree. M = source pin `3d1fca55e64056e5ad6bc9ac3edcc308ecf04073`; N = newer master `a7b6884878bc7e53dc403dd8a4383d85afac3634`; H = reviewed PR head `fde983c1794e8d4727f22bc87d1d6ee7f407eca5`.

All source quotations in the settled pair and appendix match M and N byte for byte. The API-tail placement anchor in the complete form matches `04-api-contract.md:243` at both. AGENTS.md:29–32 matches at M and N byte for byte, SHA-256 `a80fcc166aea1648948f886a09c1a240631164c61e345e4469f0c55dc6c8758f` including its final LF. All source blocks supplied in brief.md match their cited M spans. The complete AGENTS.md, overview, domain, API and lifecycle files are equal across M/N/H. There is no source-drift stop condition. N differs from M only in the tracker and checklist; that change does not silently alter the settled source quotations. No claim is made about a completed rebase of PR #53.

The AGENTS rule being applied, M/N/H:29–32, is:

```text
**Quote the sentence.** A claim about what another requirement says carries that requirement's own
words. `` `WIR-30` says "The gate reads the copy the machine took at create" `` is checkable;
"`WIR-30` forbids resolving eligibility that way" is an assertion, and assertions of that shape were
false repeatedly on 2026-09-03 — `ddd3df0` and `254fc24` carry the cases and what each one cost.
```

Historical matches are checked against their historical sources, not mislabeled as master requirements. H's archive, the evidence copy, and `/var/tmp/provisiond-panel-r86/r86b/Q1-A.md` are byte-identical, SHA-256 `db7f2b55cf4f49fcc22e6b57d6efc72daaa158817faff1cf2ad67981c19f28e3`. The pv-5pmu comment is H `.beads/issues.jsonl:15`, comments[0], id856, and exactly matches `evidence/agent-brief-original.md`. Its Desired behavior contains the whole adopted body. The historical owner-question file matches the H archive; owner item16's exact adoption is present in H `r86/owner-decisions.md:5–11`. The original authority string's presentation is retained; its approval wording is checked against that historical owner record. Retained current-behavior quotations also match M/N. Retained acceptance/scope quotations match Q1-A exactly. The merge reply's reflowed display is not byte-identical to the source; the exact payloads in stop-result.json and the chosen form are. The captured open finding is not a candidate vote or a claim about current live PR status.

## Reader-reported brief errors and factual caveats

- Astra and Sol identify the overbroad reading of the unchanged observable-phase sentence. The pinned overview passage is:

```text
the server MUST NOT
accept an operation a provider has not declared support for.
```

  This matches OVR-2 at M/N `00-overview.md:23–24`. The historical owner-questions §1 already records that unsupported admission was not formerly permitted; exact check placement can still affect the refusal point. Neither present question depends on the false interpretation. Under rule 6 this does not change the quotation/record premise and does not void either tally.

- Opus notes that the supplied derived Agent Brief files omit Q2's authority-line replacement. Verified: the pair and authority replacement were nevertheless both stated explicitly and reviewed together in the brief and every selected answer. The complete prospective comment is now a mechanical realization of those reviewed instructions; its reverse-substitution proof excludes any unread repair. This is not a new candidate or premise change.
- Opus notes Q-POINTER's capitalized `For` after the retained semicolon. Verified in the exact candidate. It does not affect Q-QUOTE or change the question's premise. No repair is synthesized.
- Opus notes historical archive-index/owner-record phrasing can look stale after a wording correction. Verified against H README and `r86/owner-decisions.md:3`. The selected note makes the actual chronology explicit and preserves the adopted bytes. No extra rewrite of those records has consensus; this tally does not bundle one. This is a presentation caveat, not verified blocking loss or a premise-changing contradiction.
- Opus notes the pre-existing machine-local `owner-decisions-1030.md` authority reference and other unchanged paraphrases could attract later review. The former is pre-existing and owner authority is independently verified; the latter are outside this pair's scope. API-64's transaction source was checked at M `04-api-contract.md:1053–1054`; its existing clause remains byte-identical. Neither licenses weakening or enlarging this correction.
- Opus's gate-scope observations were checked against `tools/check_citations.py:162`, `572–575`, and `tools/check_ids.py:65`. Those explain detection limits, not an exemption from AGENTS. The full conformance/formal search finds other capability cases; no broad claim that capability behavior lacks conformance coverage is adopted. Settlement rests on preservation, not on absent coverage.

No reader rests its selected pick on a verified false premise. No dissent from either selected form exists. No checked verdict is changed, made unreachable or vacuous, and no quoted MUST/SHOULD trace establishes blocking loss. Rule 6 therefore voids neither question. This applies the existing void rule and adds no rule.

## Authority, package and verification boundary

The owner's wording precedent is: "For such wording questions, try to solve by getting a consensus of the panel". The accompanying manager-brief PR-handling scope authorizes action on a settled wording-only result without asking. All three agreeing readers classify Q1 and Q2 separately as WORDING-ONLY, and the independent checks above support each classification. The user explicitly directs this tally to settle in that case. The exact pair, authority replacement and dated note are therefore settled; no additional owner decision is required.

`settled-pv-5pmu.md` identifies the exact PR-head file/comment/decoded-line targets and prints the full replacements and dated note. Its SHA-256 is recorded in `settled-pv-5pmu.md.sha256`. The prospective comment/archive files are local review artifacts only. Neither tracker, PR, bead nor spec has been changed; no comment, thread resolution, push, rebase, adoption or consensus-round launch occurred. All writes are confined to r93, and all pre-existing units were left alone.

Entry quota check: Claude session23%, all-models week74%, Fable100% exempt, active Codex26%; no hold. The unpiped initial tally gate ran in the existing isolated r93 check clone at M, exit0 including Lean, with host capacity checked and 16G/no-swap/OOMPolicycontinue caps. The final tally gate also exited0 including Lean; the initial/final host admission counts were0/1. Actual exit/admission receipts are recorded in `check/gate-tally-{before,final}.*`. Both own gate units were verified capped at16G, no swap, OOMPolicycontinue. These gates verify the baseline clone, not application or rebase of this package; the apply turn must run its own gates after landing.
