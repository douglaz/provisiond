# r99b STATE

- Status: LAUNCHED 2026-11-03 ~05:40Z (check/launch.exit 0). The one consensus round on r99's split Q2, Q4
  and Q-REC (2–1 each); no r99c. Q1 (Q1-QUOTE), Q3 (KEEP) and Q5 (KEEP) settled 3–0 in r99 and are not reopened.
- Pin efb40cc55ff04be693473914afd42ef68008fa15; packet hashes in packet-manifest.json and brief.sha256/notes.sha256.
- Units panel-r99b-{fable,opus,astra,sol} (16G, no swap, OOMPolicy=continue, stdin null). Fable exited 1 at once
  with the usage-limit line: missing seat. Grok not launched: preflight 402. Three seats present, so settle = 3–0
  on the same exact form; otherwise the question goes to the owner.
- Seat map for §5 (Reader A/B/C) is in check/labels.json only; check/build.py is fenced from readers.
- Q4 rule 6: r99's brief.md:408 note verified wrong, not voided (changes no form's bytes); r99b prints the
  corrected OPS-41 sources. If main judges it premise-changing, r99b's Q4 counts as the corrected re-ask.
- Wait: until-loop on {opus,astra,sol,fable}.exit, 3600 s deadline. Next: tally r99b (verify each reader is real).
