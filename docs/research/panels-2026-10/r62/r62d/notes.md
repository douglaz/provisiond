# r62d manager notes (2026-10-22), for resuming

- Coordinator go-ahead 2026-10-22 ~17:50Z: closing round, three items: (1) a1 NARROW vs WIDE + SCOPE/MECHANICS label,
  (2) API-40 OPUS vs SOL (BOTH allowed), (3) confirm folds f1 WIR-47, f2 CNF-342 a/b~a~b, f3 CNF-18 pointer.
- Outcome rules (fixed before launch, coordinator):
  - majority with no CANNOT ACCEPT = settled;
  - a1 labelled SCOPE by a majority -> owner question with the rescue-install worked example (trust + acknowledge_destruction);
  - still split on mechanics -> stop, report; NO r62e.
- On settle: fold into ../provisiond-panel-r62/final-form.md and final-form.patch, re-run six text gates (gates-variant.sh
  in ../provisiond-panel-r62c with amend.py names), report.
- Launched 17:57Z via launch.sh: units panel-r62d-{fable claude-fable-5-1, opus claude-opus-5-5, astra gpt-6-astra high,
  sol gpt-6.1-sol xhigh}; MemoryMax=16G MemorySwapMax=0 OOMPolicy=continue; TMPDIR=$P/tmp; timeout 2400 s.
  Clones at 07bac41, clean. Answers $P/<r>.md, exits $P/<r>.exit.
- Pre-launch gates (six text gates, exit 0): final-form.patch (v3); + a1-opus + api40-opus (v1); + a1-opus + api40-sol (v5).
- Tallied 2026-10-22 by a fresh manager: (3) 4-0 settled; (1) 2-2 split; (2) split (as2 vs opus2). Stopped, no r62e. See ../provisiond-panel-r62/tally.md '# r62d' and final-form.md 'Open after r62d'. Gates: gates.sh + variants.py, logs in gates/.
