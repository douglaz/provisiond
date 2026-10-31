# Panel J r89 — launch preparation

**CURRENT: r89b tallied; Q1 settles on complete C′ 4–0 and awaits owner approval for its added hourly conformance obligations.** Original r89 votes below remain historical. See r89b/tally.md, r89b/owner-questions.md and the completion entry below. No further consensus round.

Pin: 3109b5b44eae17e288cf52aaa976993bd8c5626c, cloned directly from origin/master. Main checkout, branches and tracker untouched.
Question: pv-9ecf exact wording only. Owner's policy is fixed: every paid create, hourly cloud included.
Verification: no question dropped; all four undefined scope phrases survive at the pin (check/undefined-phrases.txt).
Entry quotas: Claude session 27% (reset Oct 30 23:00 UTC), all-models week 61% (reset Nov 5 15:00 UTC), Fable week 86% (exempt). Active Codex WEEK 95%, below 100%; no hold, no switch/logout.
Before gate: panel-r89-gate-before, unpiped Nix check-all in independent check/spec; actual result in check/gate-before.exit.
No reader or follow-on round launched yet. All other panel folders and units read only.

Prelaunch readings: Claude session 31% (reset Oct 30 23:00 UTC), all-models week 62% and Fable week 87% exempt (both reset Nov 5 15:00 UTC); active Codex WEEK 96%. No hold, no switch/logout. Raw files check/quota-prelaunch-{claude,codex}.txt.
Grok sole one-word probe exit 1, HTTP 402 Payment Required / Grok Build usage balance exhausted. Missing seat, no Grok unit, no retry; owner's three-of-four fallback. Packet is under 100 KB, so no Grok split is needed if availability changes in a later round; this turn launches no Grok call beyond the single probe.
Before gate exit 0, all gates PASS including Lean. Final gate is independent and unpiped; actual result goes to check/gate-final.exit. Readers will run no builds.
Candidate packages: A defined term + existing checks; B self-contained + existing checks; C defined term + explicit hourly checks; D self-contained + explicit hourly checks. All cover any create that starts provider billing, including no-setup-fee hourly rental. Property policy not put to a vote.
Packet validation passed: all printed retained dependents match the pin, all edited ranges remove undefined aliases, quoted PRV-10 consumer strings remain, clones clean and pinned, wrappers differ from r82 only in artifact paths. launch-vs-r82.diff shows only panel path and required unit naming differences.
One additional non-voting internal-consistency pass is running as panel-r89-consistency, sol xhigh in its own clean pinned clone, with the required caps; its only question is whether brief.md/notes.md contradict themselves. No design vote or panel tally requested.

Internal-consistency pass completed exit 0. One error fixed with its exact minimal repair: notes now pins quoted repository text and distinguishes the post-pin owner decision. No form or question changed; check/consistency.md and consistency-disposition.md retain the diagnosis/repair.

Final prelaunch quota refresh 2026-10-30T21:06:52.306055+00:00: Claude session 33%, all-models week 62%, Fable week 87% exempt, active Codex WEEK 96%; launch permitted. The latest raw readings are check/quota-prelaunch-{claude,codex}.txt. Grok not retried.

## LAUNCHED 2026-10-30T21:07:36.454319+00:00

Both independent required unpiped Nix check-all invocations exited 0, all gates PASS with Lean. Final gate waited for host build admission before running. No source edits in any clone; final-gate clone remains at the pin.
Units panel-r89-fable, panel-r89-opus, panel-r89-astra, panel-r89-sol confirmed active/running with MemoryMax=16G, MemorySwapMax=0, OOMPolicy=continue, npm-global-first PATH, own TMPDIR and StandardInput=null. Each has its own clean detached reader clone and reads the same final brief on command stdin through the copied r82 wrappers. Caps/command/environment proof in check/*-systemctl-show-final.txt and launched-units.json.
Grok missing (sole probe 402), no Grok reader unit, no retry. Five configured seats; four launched seats; threshold three of four. A quota-limit/empty/non-substantive eventual output is missing, never a vote. No tallies or follow-on round this turn.
No questions dropped. Q1 offers A/B/C/D complete exact forms; all implement the fixed every-paid-create policy. All other panel folders/units and the main checkout remain untouched. Candidate packet and final receipt hashes are in check/packet-verification.json.
Wait command for main:

```sh
until [ -e /var/tmp/provisiond-panel-r89/fable.exit ] && [ -e /var/tmp/provisiond-panel-r89/opus.exit ] && [ -e /var/tmp/provisiond-panel-r89/astra.exit ] && [ -e /var/tmp/provisiond-panel-r89/sol.exit ]; do sleep 60; done
```

## TALLY 2026-10-30 — Q1, rule 6 unchanged

Read the common tally instructions, required manager sections/memories, original packet/rules, all four full substantive exit-0 answers, complete forms and reader side artifacts. Artifact/source/form verification is in check/tally/verification.json; no drafts exist, stdout matches final answers, stderr commands/diagnostics are preserved as readable extracts. Main checkout and other panels/pgharness were not read for source or mutated.

Explicit final picks C=fable/astra/sol, C′=opus. Exact acceptance A/C=fable/astra/sol; B/D=sol; opus rejects A–D and alone has read/accepts its complete C′. Requested counterarguments are not votes. Grok missing 402. C has the numeric majority, but the rule-3 condition is held over the verified conditional-wire/worker-fixture narrowing beyond item 4; tally.md gives the full dissent trace and its limits (zero first_unit alone proves neither free service nor no billing; no forced reordering/admission is asserted). No premise-changing brief error, no void tally, no extra void rule, no synthetic tie-break. Q1 gets its ONE consensus round r89b before any owner question or adoption.

Both this turn's independent pinned unpiped full gates passed with Lean: check/gate-tally-before.exit=0 and check/gate-tally-final.exit=0. The gate units were capped at 16G/no-swap/OOMPolicy=continue; source clones remain clean at the pin. These are baseline specification gates, not execution of the proposed conformance cases.

Entry and consensus-preparation quotas: Claude session 60%, all-models week 67%, Fable week 94% exempt; active Codex WEEK 2% (no account switch/logout). Raw readings/guards are in check/tally/ and r89b/check/. The consensus packet, complete A–D/C′ forms, verbatim r89 answers, notes and manifest are in r89b/. An internal-consistency-only pass and the single actual Grok availability check are in progress/completed there; panel readers have not yet launched at this entry. Two initial preflight processes failed before either model executed because their explicit PATH omitted the Nix profile (node/Grok absent); raw exec-path-error receipts are preserved. Restarted those infrastructure processes with the inherited full PATH and npm-global first. The one actual Grok call returns 402, missing, no retry. No r89b vote or adoption is recorded here.

## CONSENSUS LAUNCHED 2026-10-30T21:44:58Z

The sole actual consistency pass exited 0, "No internal contradiction found." Packet remains unchanged: 176666 bytes, SHA256 49b6485d6b1f76a30961db7832dd5bc33fccfcf81b56fff301348904107f5353; Grok size check below split case and actual probe 402, missing. Mechanical validation proves all exact forms, original rule 6, owner threshold, verbatim prior answers and clean pinned clones.

Final launch quotas session 61%, all-models week 67%, Fable 94% exempt, active Codex WEEK 3%; launch guard PASS. Units panel-r89b-fable/opus/astra/sol all active/running, live-verified caps 16G/no-swap/OOMPolicy=continue/StandardInput=null, npm-global first/full inherited PATH and own TMPDIR. Evidence r89b/check/launched-units.json and launch-vs-r89.diff. This is the first review round launched by the tally turn and Q1's sole consensus round. No r89b answer opened/tallied, owner question, adoption, source/tracker mutation or other panel/unit action. Both full pinned unpiped gates 0/0, including Lean.

NEXT: main runs `bash /var/tmp/provisiond-panel-r89/r89b/WAIT.sh`, then assigns a fresh r89b tally. No further consensus round for Q1; any settled package changing check/test/behavior beyond item 4 needs owner approval, while a wording-only settlement quotes both owner precedents before ready-for-agent.

## r89b COMPLETE — 2026-10-30

The one consensus round settles Q1 on exact C′: fable/opus/astra/sol all prefer and unconditionally accept C′; all reject A/B/C/D as printed. Grok missing 402, neither acceptance nor dissent; no probe repeated and no further round. Original r89 picks C=fable/astra/sol, C′=opus are preserved. No premise-changing brief error and no vote voided under original rule 6. See [r89b/tally.md](r89b/tally.md) for each reader's argument, exact acceptability and the source-verified former dissent trace.

Owner approval is needed for the added CNF-55 hourly conformance obligations, with complete reviewed C′ recommended 4–0. The precedents are owner item 4 "Every paid create (Recommended)" and owner 2026-10-28 "For such wording questions, try to solve by getting a consensus of the panel". No ready-for-agent or tracker action follows from this tally alone. [r89b/owner-questions.md](r89b/owner-questions.md) holds the short question, detail and complete unchanged form; [r89b/form-Cprime.md](r89b/form-Cprime.md) SHA256 be350270318a2752992a9cb199a2a56879249be99f36e7af430bcfe8a1d47a32.

Independent full unpiped pinned Nix gates before/final exit 0/0 including Lean, with one other host lake build at each admission; receipts r89b/check/tally-gate-results.json. Clean pinned reader/gate clones and all exact source/form comparisons verified. No source/tracker/branch/PR/adoption action, other panel or pgharness write, account switch, or new review round. Main may relay the one approval question; further action waits for the owner answer.
