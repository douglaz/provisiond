Every other r99 wording question settled 3–0, but after the one consensus round the readers are still split over whether DOM-10's API-64 retry clause should carry API-64's own words, and all three accept both forms. **Quote API-64's own words in DOM-10's retry clause?** **Add the API-64 quotation (Recommended)** (Astra, Sol); **Keep the clause as landed** (Opus). The recommendation is mine (the manager's): it is the majority pick, it costs no landed byte, and it adds a checked quote the way Q1 and Q4 settled.
Astra: QUOTE. The transaction's identity is a source fact, and API-64 says "the state change, the enqueue and the idempotency record commit together" (04-api-contract.md:1116–1117). Quoting it makes that checkable and leaves the timing clause unchanged.
Sol: QUOTE. Quoting the transaction's owner "removes an avoidable interpretive dispute without changing placement or adding transaction semantics"; the check placement stays DOM-10's own rule.
Opus: KEEP. The clause says when the retry checks delete_machine, which API-64 never mentions. "Its state-change/enqueue transaction" only names the boundary, a pointer under AGENTS.md:34 ("One rule, one home; everywhere else points at it"), and it is built from API-64's own words, so it can't point at another transaction. The quote checks a side fact the clause doesn't use. All three accept both forms, and none claims a blocking loss. Fable limit and Grok 402 are missing. Four packet slips were found and verified (r99b/brief.md:243 calls :1113 "ahead of the decision" though it sits in step 2; :173 leaves a reading standing; the :262 trial never checks the appended note; :326 says "the block below" for a separate file); none touches Q2, and no reader claim was wrong.
IDs: pv-5pmu, comment 856, DOM-10 (01-domain-model.md:547–548), API-64, PR #69, pin efb40cc; QUOTE = /var/tmp/provisiond-panel-r99/Q2-QUOTE.txt 2b46b8b8…; KEEP = /var/tmp/provisiond-panel-r99/Q2-KEEP.txt e3d78fbf… (no byte change); /var/tmp/provisiond-panel-r99/{tally.md,r99b/}.

---

## For main, not the owner: what the settled questions alone allow now

- **Settled so far:** Q1-QUOTE (`4c0cbffb…`), Q3-KEEP and Q5-KEEP (no change), Q4-ALT (r99b/forms/Q4-ALT.txt `c12991b3…`), and Q-REC R-NOTE-ALT (r99b/forms/R-NOTE-ALT.txt `23c4c1f8…`). R-NOTE-ALT's "the block below" is r99b/forms/R-NOTE-ALT-append.md (`445f69c2…`, starts with two LFs).
- **No apply yet.** R-NOTE-ALT is one fix commit covering every settled span. An apply now that left Q2 as landed would decide Q2 as KEEP by default. Everything except Q2's one span is fixed, so the owner's single answer completes the package.
- **After the answer:** write settled-r99.md, then make one plain fix commit on pv-5pmu per R-NOTE-ALT steps (1)–(4).
  - Spans replaced in 01-domain-model.md and in comment 856: Q1 and Q4 under KEEP; Q1, Q2 and Q4 under QUOTE.
  - Plus comment 856's line-6 replacement, the append to r86b/Q1-A.md, and the archive at docs/research/panels-2026-10/r99/.
- **Trials already cover both outcomes:**
  - KEEP: r99b/check/trial-A-Q4ALT, Q1-QUOTE + Q4-ALT, exit 0, 365 compared.
  - QUOTE: r99b/check/trial-A-ALL, Q1-QUOTE + Q2-QUOTE + Q4-ALT + the append, exit 0, 366 compared.
  - check_citations never reads the append. The Nix gates (check_formal, check_fixtures, check_regions) were run by no one, so the apply turn runs the full check-all.sh.
- **The archive must carry the selections.** The note links "Panel record: `../../r99/notes.md`", and notes.md holds no selections (opus, verified). Step (4) has to archive tally.md and the settled package next to notes.md.
- **Nothing else is blocked on Q2.** pv-e45e stays not started, as instructed.
