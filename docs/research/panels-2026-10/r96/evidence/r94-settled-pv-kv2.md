# Settled pv-kv2 wording correction — Panel O r94 / consensus r94b

Q1 **Q-QUOTE-OPS43**: Opus, Astra and Sol each prefer and ACCEPT the supplied complete package, comment and matching appendix (3–0). Fable's limit line and Grok's HTTP402 are missing seats, not votes. Q2 **L-NOTE** was settled by r94 and carried here. This records settlement only; nothing is adopted into the tracker or PR.

Source pin M: `a7b6884878bc7e53dc403dd8a4383d85afac3634`. Reviewed PR #53 head H: `b85af778fda2a96fb0024a07c69092665303bfbe`. Both live refs still match; no moved-ref stop condition. AGENTS.md29–32 and all independently audited source files match between M/H.

The owner's wording rule is “For such wording questions, try to solve by getting a consensus of the panel”. All three classify behavior, requirements and check strength WORDING-ONLY for this exact form and L-NOTE. Independent verification agrees: owner item19's meaning and every Q4-D assertion are preserved; no A/D combination, weakened assertion or restored positive warning-publication duty. No owner question is needed. Full assertion/occurrence/source audit: `r94b/check/tally-evidence.md`; exact byte receipts: `r94b/check/tally-verification.json`.

## Exact PR #53 locations

- `.beads/issues.jsonl:101`: only pv-kv2, comments[0], id860, Agent Brief. Replace decoded line6 with the authority line below, the serialization substring at decoded lines69–70 and provider substring at decoded lines81–84. These become lines69–71 and82–85. All surrounding bytes remain. The full comment is encoded on physical JSONL row101; re-resolve row/comment identity after any rebase.
- `docs/research/panels-2026-10/r83/r83b/Q4-D.md`: replace no original line. Keep original lines1–98, all6606 bytes, SHA-256 `bd57b4e09cfbedfb955fff449748433f12867749525c43f8ee0c9c552e9c4ae7`, as an exact historical prefix. Append exactly the dated note below: its leading blank is line99, heading100, final line125. Original serialization29–30 and provider41–44 remain historical; executable replacements appear in appendix109–111 and117–120.
- The apply turn must archive the settled r94 panel record, including `docs/research/panels-2026-10/r94/notes.md` and this settled correction, so the appendix's `../../r94/notes.md` link resolves. That path is absent at H. This dependency was reviewed under carried L-NOTE.

## Exact serialization substring replacement

Old (archive29–30; decoded Agent Brief69–70):

```text
A serialization failure is retried as a whole transaction under OPS-49
and is not a tenant-status refusal.
```

New, exactly:

```text
OPS-49 says "the component MUST repeat the **whole
transaction** — never the last failed statement, and never the provider call (`OPS-12`)" and "A
  serialization failure is repeated at once."; retry a serialization failure as a whole transaction and do not treat it as a tenant-status refusal.
```

## Exact provider-call substring replacement

Old (archive41–44; decoded Agent Brief81–84):

```text
A create past
the guard can still be between the acknowledged transaction and its provider call, because
LDG-69 keeps the call outside the transaction; treat that residue as the potentially dispatched
case.
```

New, exactly:

```text
A create past
the guard can still be between the acknowledged transaction and its provider call, because
OPS-43 says "Step 9 MUST begin only after step 8's transaction is acknowledged."; treat that residue as the potentially dispatched
case.
```

## Exact Agent Brief authority-line replacement

Old (decoded line6):

```text
**Owner decision:** “D: explain exception” (`owner-decisions-1030.md`, item 19). Adopted exact form: `docs/research/panels-2026-10/r83/r83b/Q4-D.md`.
```

New, exactly:

```text
**Owner decision:** “D: explain exception” (`owner-decisions-1030.md`, item 19). Historical adopted form: `docs/research/panels-2026-10/r83/r83b/Q4-D.md`. Executable form: the Desired behavior / key interfaces and Acceptance criteria blocks below, with the 2026-10-31 Panel O r94 wording correction.
```

## Exact dated archive appendix

The outer fence contains the complete appendix including its leading LF and final newline, SHA-256 `31f743fac08408f2798ffbf4553310144082f89199b91c6f823ea76e7d914c4b`. Parent-r94 metadata is intentional and unchanged from the reviewed form.

````text

## Wording correction — 2026-10-31 (Panel O r94)

The text above is retained as the historical form approved in owner item 19.
The executable pv-kv2 Agent Brief uses the following replacements under the
owner's 2026-10-28 wording rule; all other Q4-D text is retained.

Replacement for the serialization-retry sentence:

```text
OPS-49 says "the component MUST repeat the **whole
transaction** — never the last failed statement, and never the provider call (`OPS-12`)" and "A
  serialization failure is repeated at once."; retry a serialization failure as a whole transaction and do not treat it as a tenant-status refusal.
```

Replacement for the provider-call passage:

```text
A create past
the guard can still be between the acknowledged transaction and its provider call, because
OPS-43 says "Step 9 MUST begin only after step 8's transaction is acknowledged."; treat that residue as the potentially dispatched
case.
```

Source pin: `a7b6884878bc7e53dc403dd8a4383d85afac3634`.
Review head: `b85af778fda2a96fb0024a07c69092665303bfbe`.
Panel record: `../../r94/notes.md`.
````

## Verification limits and prospective artifacts

The inserted OPS-49 payloads match lifecycle1927–1928 and1955–1956 byte for byte, including LF, indentation, emphasis and backticks; the OPS-43 payload matches lifecycle817 exactly and governs this create's step8/9 sequence. The discarded LDG-69 quotation has exact bytes but concerns OPS-42's funding/fence transaction. STO-55 distinguishes the primitive-only rule; API-63's repeated attribution does not expand LDG-69's scope.

The retained OPS-11 quotation has a pre-existing LF after “any” where its source has a space; checked and disclosed, not claimed byte-identical or normalized. Item5's retained locator and the historical item3 quotation have separate reflow differences. Historical Current behavior blocks match their named historical ref exactly. These unchanged differences do not change this wording question's premise; notes rule6 voids no vote.

The whole-transaction serialization retry and tenant-refusal distinction remain explicit local instructions from adopted Q4-D item2; OPS-49's quotations do not by themselves supply both. The potentially-dispatched classification and permission to settle remain explicit item3 policy from owner item19. OPS-43 supplies existing acknowledgement ordering; OPS-11 and OPS-27 supply retained pre-step9 and attachment context. No new policy is inferred from the quotations.

Complete reviewed executable package: `r94b/options/Q-QUOTE-OPS43.md`, SHA-256 `ba7ddd938d8b7f0defe1616f1b0868bdf5361f8291bc3ad056336134ceacdbf4`.
Complete prospective decoded Agent Brief: `check/prospective-agent-brief.md`, SHA-256 `d14a8a5680f319221789d3e151a4ae9e744cad8eb3c01bcbd4addbf75e830c7c`.
Complete prospective archive plus exact appendix: `check/prospective-archive.md`, SHA-256 `b1a08789423da142a4bb0d2d87cdb92fe813c7460f80e545101bc74c20171682`.
These are local review artifacts. Next step: an apply turn on PR #53 with these exact forms, the r94 archive dependency and a fresh drift check. No tracker, bead, specification, PR comment, thread resolution, push or merge occurred; no r94c.
