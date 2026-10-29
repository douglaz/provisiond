# r62c manager notes (2026-10-22), for resuming

- Launched 2026-10-22 ~17:5xZ: units panel-r62c-{fable (claude-fable-5-1), opus (claude-opus-5-5), astra (gpt-6-astra high),
  sol (gpt-6.1-sol xhigh)}, MemoryMax=16G, MemorySwapMax=0, OOMPolicy=continue, TMPDIR=$P/tmp, timeout 2400 s.
  Clones at 07bac41, clean at launch. Answers: $P/<r>.md, exit codes $P/<r>.exit.
- Candidate set: apply.py (stage fable|opus) -> applied-fable.patch / applied-opus.patch. Scratch clone: scratch/.
- Pre-launch gates on scratch (both stages): check_citations, ids, fixtures, obligations, coverage, regions all exit 0,
  using the Lean index/regions jsonl copied from the repo (Lean tree == 07bac41). Formal build not run.
- Gate fix before launch: opus's DOM-15 "`PRV-4` states its exception for ..." failed citations (unquoted
  attribution); replaced by "An ordering capability withheld under `DOM-16` is excepted from that agreement (`PRV-4`)."
- WIR-2 pick: astra's r62b text (names details.field, states the mixed case, keeps the phrase WIR-47 quotes).
- Not asserted in CNF-342: "no details.field" on internal (WIR-9a keys are minimums; no text forbids it).
- Owner, 2026-10-22, verbatim: pv-p3k "MUST, not retryable (Recommended)"; B6 "Yes, any unhealthy (Recommended)".
- On convergence: fold into ../provisiond-panel-r62/final-form.md, drop the "Note on option 2", make the wide WIR-48
  sentence the only one, remove "pending the owner" markers, header "Nothing is open".
