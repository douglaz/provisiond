# Panel L r91 — Q1 tally, pv-602

Pin: `aeb7ff65369238212903d6b60b8ae1622f5c93d8`.

**apply notes.md rule 6 exactly as written; this prompt adds no void rule.**

**Technical recommendation settled: exact C. Owner approval is pending; nothing is adopted.**
The explicit picks are C 3–1 over B; C is acceptable to all participating readers.
No consensus round is required. No implementation, tracker update, ready-for-agent decision,
PR or merge is authorized by this tally.

## Seats and votes

The substantive answers, true exits and hashes are recorded in
`check/tally-1030/input-receipts.json`. Each participating answer contains actual execution,
an explicit preference and separate verdicts for every printed form. The Codex `.out` files
repeat their answers; their `.err` files contain execution transcripts and completed answers,
not a terminal quota, authentication or timeout response. The Claude `.err` files are empty.
No reader left a root-level `.draft.md`. Grok is missing (402), not a vote; the launch receipt
and main's supplied 21:35Z recheck stand. No retry was made.

| Reader | Explicit final pick | Strongest reason | Conditions and limits |
|---|---|---|---|
| Fable | C | The narrower guard fails loudly on the target defect and the extraction candidate's chunk-pairing hazard, while retaining quotations wholly inside code. | Accepts A and C; rejects printed B and N. Accepts the disclosed punctuation restriction and exact migration. Supplies B′ separately, acceptable but not preferred; other seats have not reviewed it. |
| Opus | C | The guard catches the named corruptions without changing extraction; A additionally rejects unambiguous code-contained quotations, and B silently loses a citation after an earlier code-span cut. | Accepts C only. Accepts the exact migration; notes that unattributed Lean EXISTS cases retain their existing limitation. Optional stronger diagnostic assertion is explicitly not a condition. No complete repaired B supplied. |
| Astra | B | Content comparison catches the target typo while preserving the current straight outer punctuation. | Accepts B and C; rejects A and N. C is acceptable only with its disclosed punctuation restriction and printed migration. Claims no current inventory slice is lost, rather than proving preservation on every possible input. |
| Sol | C | The narrower guard catches the defect; printed B can extend a quotation past Lean's retained length cap and turn a previously rejected corruption green. | Accepts A and C; rejects printed B and N. Accepts the migration. B2 is a distinct complete repair with additional reach, not acceptance of B or a final pick. |

| Exact printed form | ACCEPT | CANNOT ACCEPT | Explicit first picks |
|---|---|---|---|
| A | Fable, Sol | Opus, Astra | none |
| B | Astra | Fable, Opus, Sol | Astra |
| C | Fable, Opus, Astra, Sol | none | Fable, Opus, Sol |
| N | none | Fable, Opus, Astra, Sol | none |

Notes rule 2 says: “a question is settled when at least three agree and more agree than
disagree, and a tie comes to you. If grok is down, it falls back to three of four”. C alone
qualifies, by both first picks and acceptability. Astra's B preference is preserved; acceptance
of C is not relabelled a first pick. Neither B′ nor B2 is merged into a printed form or counted.
Requested no-change counterarguments are not votes.

The requested strongest N argument is maintenance cost: keep the existing scanner and
documented curly convention, avoiding a new bounded scanner or syntax restriction. Each
reader rejects N despite that argument because the demonstrated misses persist. The B-side
argument is Astra's preservation of punctuation and direct content comparison, not that
requested no-change argument.

## Verification against the pin and exact packages

Independent manager receipts and scripts are under `check/tally-1030/`; testing copies are
under `tmp/tally/`. These are panel artifacts, not repository changes.

- `package-proof.json` verifies the source clone's HEAD, byte identity of the shared base
  checker, base-plus-exact-patch reconstruction of every complete candidate, and unchanged
  inherited self-test and comparison-function ASTs. In particular `find()`, `exists()`,
  `contains_quote()`, `corresponding_roles()` and `span_content()` are unchanged. Every quote
  slice in `current-attributions.json`, using its source chunk in `current-chunks.json`, remains
  extractable. This current-inventory result does not assert universal preservation by B.
- `verify.log`, `verify.exit` and `tmp/tally/verification/results.json` record a fresh real-CLI
  run of the supplied verifier: every complete package is green, every changing package's
  exact embedded CI control passes, and the embedded bodies equal their supplied files.
  N misses all the named straight bare-possessive corruptions. Each changing package's
  inherited self-tests run through the CLI; they were neither substituted nor weakened.
- The raw, unconverted guard does reject a correct current citation. At pinned
  `10-conformance-checklist.md:3096–3097`, the actual content is
  `` `disk_effect: "none"` (it aborted before writing) and `rescue_exit: "unknown"` ``
  inside straight outer marks. Its owner at lines 3034–3035 contains
  `` `disk_effect: "none"` (it aborted before writing) and `rescue_exit: "unknown"` ``.
  A/C reject the old punctuation; their exact packages change only its two outer marks.
  The new curly input passes and becomes compared. This is an intentional syntax-admission
  change, not evidence that the old input remains accepted. B accepts and compares the old
  input without migration. `git blame` attributes both old quotation lines to
  `a58532130b7f41315bbcdcd1cbd0b113053d88d8`, dated 2026-10-29, PR #36; Fable's history claim is correct.
- The original OPS-43 site is currently curly: pinned `03-operation-lifecycle.md:778–782`
  starts ``with `API-63`'s “`details.reason: "account_terminated"` ``. Its owner at
  `04-api-contract.md:1424–1427` contains the same named value and “two recoverable statuses”.
  Independent speech-verb probes preserve Astra's strongest point: B accepts correct straight
  input and rejects the reason typo with the existing API-63 content diagnostic. N misses it;
  A/C reject the straight syntax with the convention diagnostic. The supplied embedded controls
  separately test the named reason, state and recoverable-status corruptions in both mark styles.
- A's extra restriction is real: appending
  `` `API-63` says `"Recording a status the driver itself reports MUST be refused"`. ``
  is accepted by N/B/C but rejected by A. C keeps that existing syntax. This independently
  checks the shared objection to A; it is a disclosed collateral flip, not a hidden current fixture loss.
- Fable/Opus's B trace is reproducible through the real CLI: use straight outer marks at the
  live site, change the earlier ``fail `conflict` `` to ``fail `e.g. conflict` ``, and plant
  `account_terminatd`. N/B return 0; A/C return 1 with the convention diagnostic. B's
  `chunks()` computes span protection on the whole input, but `find()` then calls
  `quotations(sent, ...)` on each resulting chunk. A sentence cut in earlier inline code
  leaves the latter scan different backtick pairs; the citation loses its content comparison.
- Sol's B trace is separately reproducible: copy the exact API-63 source slice from
  `` `conflict`, with `details.reason: "account_terminated"` `` through “below,” into an
  attributed straight quotation in an added scratch Lean docstring. Correct input returns
  0 under N/B. Changing only “two recoverable” to “three recoverable” returns 1 under N
  with both attribution and EXISTS diagnostics, but 0 under B. B extends the quotation,
  then its unchanged `quotations()` length filter discards it; Lean UNQUOTED is not enforced.
  A/C return 1 with the convention diagnostic. This is a checked corruption verdict lost
  by printed B under rule 3, not merely a missing new test. Fable/Opus's broader “no blocking
  loss” conclusion for B must therefore be qualified by this counterexample.
- Opus's extra benefit of B is also reproducible: corrupting the nested `"unknown"` in the
  named current `Rescue.lean` and `Witnesses.lean` docstring quotations fails EXISTS under B
  and remains green under N/A/C. These are owner-free quotations, so C's attributed guard
  does not repair them. This benefit is recorded alongside B's regression, not omitted.

The independent real-CLI trace results and full diagnostics are in `adversarial-results.json`
and its adjacent logs. Current-comparison preservation also has the original launch receipt
`check/current-comparison-preservation.json` and the readers' linked inventories. No claim
of universal safe extraction is inferred from a clean current corpus.

## Brief accuracy and rule 6

No verified brief error changes the question's premise. The tally stands under rule 6.

- The brief's CNF locator is off by one line: the quotation occupies 3096–3097, not
  3095–3096. The quotation and exact migration are correct. No reader bases a vote on that offset.
- The brief says “Their backtick scanner matches equal-length runs inside a paragraph”.
  This describes A/C's whole-input scan and B's initial chunk protection, but is inaccurate
  as an end-to-end description of B: the comparison path repeats the scan per chunk.
  Opus explicitly identifies this broken claim; Fable identifies the same error in B's
  docstring while saying no brief claim broke; Astra relies on paragraph-local pairing
  in accepting B. The independently verified counterexample limits that reason. The
  question still offers a valid exact guard versus an exact extraction prototype; the
  result that the prototype has a hole does not remove the motivating defect or turn
  C into an unreviewed form. The explicit instruction to assess that prototype's scope
  and report failures remains meaningful. This error therefore is reported, not used
  to manufacture a void rule.
- B's changes to the two unattributed Lean quotation readings were not highlighted in the
  brief. They are additional extraction effects, verified above. The brief's narrower
  current-attributed-citation example is not a universal assertion that no other quote changes.
- B's length-cap regression was not forecast by the brief. No brief promise asserts
  universal preservation of all newly constructed inputs. Its requested existing inventory
  and inherited fixtures remain preserved; the new counterexample changes B's acceptability,
  not the question's premise. Astra's current-inventory claim remains true.

No verified blocking loss is established for exact C. Its admitted syntax restriction is
substantive and requires owner approval. The exact patch changes no Lean declaration,
theorem, guard hypothesis, baseline, existing fixture or normative assertion; its checklist
migration changes only outer quotation marks. The independent base gates are evidence for
the pinned base, not a claim that the candidate has been implemented or formally adopted.

Procedural limitations are preserved: Opus reports processing the complete JSON artifacts
with scripts and inspecting relevant subsets by eye, rather than reading every record by
eye. Sol reports an initial discovery command enumerating neighboring filenames, without
opening their contents. Neither establishes a premise-changing brief error or makes a
substantive final answer a missing seat under notes rule 5; no extra void rule is introduced.

## Next step and boundaries

The owner question is `owner-questions.md`. Recommend **only** the exact already-reviewed
`candidates/C/exact.patch`, SHA-256
`7fe46ae3b60c21c6b19b2dc553c1bd7d2617497ef18cef509aa891ee6406903f`, including its
docstring, guard, appended self-test, CI negative control and two-mark migration. The
alternative is the reviewed unchanged N, not an unread combination of B′ and B2.

No r91b is needed or launched. pv-602 stays deferred pending the owner's decision.
Main checkout, tracker, other panels, pgharness and all pre-existing units are untouched;
no `br` command was run. The separate pv-erp matcher/search problem remains outside scope.

Full unpiped Nix gate receipts for this tally are `check/tally-1030/gate-before.*` and
`gate-final.*`, including their host-build admission logs. Both gate units use 16G,
zero swap and OOMPolicy=continue, with null stdin and panel-local TMPDIR. Launch-time
gates remain separately documented in STATE.md. Quotas at tally entry are recorded in
`input-receipts.json`; Fable's week is exempt and no account switch occurred.

Final receipts: both `gate-before.exit` and `gate-final.exit` are 0, with every summary
gate PASS including Lean. Admission logs record host lake-build counts of one and zero
respectively. `gate-launch-receipts.json` preserves the immediate live cap observations;
the later unloaded-unit defaults are explicitly not runtime evidence. `source-clean.json`
confirms the reader and gate clones remain clean at the pin. This tally is complete;
only the owner's approval decision remains.
