# Panel E owner and main decisions

Panel E excerpts from the machine-local decision log, starting at the r69 ruling.

## Panel E r69 owner ruling (2026-10-26)
- Q1 pv-tcs offer check at create: owner chose "Stored listing (Recommended)" (S; panel pick 4/4; printed S 2 ACCEPT / 2 CA, coverage 74→76 and fable's S4 dropping "running in the engine process"). Next: complete S1–S6 candidate per r69 tally.md "If S is selected" → one whole-form read (r70) → rloop.
- Q2 pv-ytv fingerprint: owner chose "K1–K6 and K-d (Recommended)" (K ACCEPT 4/4; K-d as printed 3 unconditional takes; opus's completed-fixture AMEND does not ride). No further read; goes into the Run.
- Source: /var/tmp/provisiond-panel-r69/{tally.md,owner-question.md}.

## Panel E r70 precedence question (2026-10-26, settled by main from the recorded spec)
- r70: S1–S6 combined 2 ACCEPT (fable, astra) / 2 CA (opus, sol); both dissents = same verified defect: S1's stale/absent-listing 502 (retryable) refusal precedes the unhealthy-account 409 state tail, flipping CNF-278 and CNF-307 (terminated → retryable true). Inherited from printed S1, absent at c5f897c.
- Settled: PRESERVE the unhealthy-account response first. Source: c5f897c CNF-278 (10:2789–2792) "a create naming it is `409` `state`" / "Assert the refusal on all three unhealthy statuses"; CNF-307 (10:1225–1226) "termination makes the envelope `retryable: false`"; the owner's S ruling did not ask to change them; no reader argued freshness-first on merit (sol's S7 conditional, unendorsed). Owner may overrule.
- Next: r71 whole-form read of opus's S1/S6 preservation repair + coordinator text for the unhealthy-account offer check.

## Panel E r71 → r72 (2026-10-26, settled by main; owner may overrule)
- r71: raw 2 ACCEPT (fable, opus) / 2 CA (astra, sol); the unhealthy-account repair works; both CAs verified the same inherited defect on HEALTHY accounts (stale-listing refusal pre-empts the tail: CNF-307 refusal combinations and success controls flip). The tally's VOID came from main's prompt wording ("a verified brief error voids the tally"), not notes rule 6 (omitted CNF-307 10:1285–1300 excerpt).
- Main's r71 target ("every CNF-278/CNF-307 verdict unchanged") was over-strict; replaced by: (1) refusals never hidden by age; (2) one new refusal: otherwise-admissible create with a stale listing → provider/retryable (owner's age setting); (3) success assertions changed by (2) get listed fresh-listing fixture amendments.
- Astra's no-age-refusal form dropped: contradicts the owner's S choice ("an age setting"; r69 owner-question.md:7 "Missing or stale data refuses the create").
- r72 reads sol's A/B (age check after tail collection) + coordinator-listed fixture amendments.

## Panel E r72 → r73 (2026-10-26, main)
- r72: 1 ACCEPT (fable) / 3 CA (opus AMEND-bc, astra, sol); valid. Design holds; every blocker = another success item missing its fresh-listing condition (CNF-99, CNF-299, CNF-243; CNF-343 continued race).
- Main's direction: stop enumerating. Form H = one checklist header default ("Stored offer listings in the items below", styled like the existing "Seeds in the items below" ADR-0033 paragraph) replacing per-item M amendments; Form U (r72 next-read-candidate, per-item union) read alongside as fallback.
