# r84 — Panel E launch state

Pin: 3109b5b44eae17e288cf52aaa976993bd8c5626c (origin/master fetched by independent remote clone). Main checkout clean at the same pin, read only.

Entry quota: Claude session 3% (reset Oct 30 23:00 UTC), all-models week 57% (reset Nov 5 15:00 UTC), Fable week 79% (exempt, same weekly reset). Active Codex WEEK 88%, permitted below 100% (reset in 5d18h). No hold, switch or logout.

Verification and packet drafting in progress; no readers launched.

## Draft and validation

No question dropped: pv-ez8, pv-2j3 and pv-tbrs remain open/needs-triage; relevant owner/CNF blocks are unchanged since triage (check/verification.md). Complete exact Q1-A/B/C, Q2-A/B/C/D and Q3-A/B forms and quoted pin evidence are in brief.md. Definitions and insertions compose at disjoint locations; alternatives are distinct forms. notes.md fixes the five seats, exact owner settlement sentence and r82 counting rules before launch.

Grok: sole one-word read-only preflight exit 1, HTTP 402 Payment Required, “Grok Build usage balance exhausted”. Missing seat; launch four, fall back to three of four. No retry. Packet is roughly 51 KB including notes, below the ~1 MB Grok threshold; no split needed if available.

Independent initial unpiped Nix check-all exit 0 (check/gate-before.log, .exit, caps). Final unpiped gate and consistency-only reviewer are running in capped panel-r84-gate-final and panel-r84-consistency units; readers are not yet launched. Both jobs use own TMPDIR and npm-global-first PATH, stdin /dev/null, no main writes.

Before these jobs: Claude session 3%, all-models week 57%, Fable week 80% exempt; active Codex WEEK 89%, below 100%; launch permitted.

Four independent direct-remote reader clones verified clean and detached at pin=origin/master. Copied r82 wrappers and launcher differ only in panel paths/unit labels (check/r82-*.diff); requested reader units will be panel-r84-fable, panel-r84-opus, panel-r84-astra, panel-r84-sol.

Final independent unpiped Nix check-all exit 0 (check/gate-final.log/.exit); both full gates passed with Lean. Internal-consistency-only independent reviewer exit 0, `NO_INTERNAL_CONTRADICTION`; read and dispositioned in check/consistency-disposition.md. One inline source line label corrected; no candidate text changed.

## LAUNCHED — 2026-10-30T19:30:03.205915+00:00

Four readers launched and confirmed active/running with MainPID >0: panel-r84-fable (claude-fable-5-1 xhigh), panel-r84-opus (claude-opus-5-5 xhigh), panel-r84-astra (gpt-6-astra high), panel-r84-sol (gpt-6.1-sol xhigh). Every unit confirms MemoryMax=17179869184 (16G), MemorySwapMax=0, OOMPolicy=continue, StandardInput=null, npm-global-first PATH and own-folder TMPDIR. Wrappers retain exact r82 CLI/effort/timeout behavior; paths and unit labels only changed, with diffs in check/. launch-confirmed.json and per-seat systemctl-show receipts hold the configured evidence.

Fresh prelaunch quota: Claude session 4% (reset Oct 30 23:00 UTC), all-models week 57% (reset Nov 5 15:00 UTC), Fable week 80% (exempt, reset Nov 5 14:59 UTC); active Codex WEEK 89% (reset in 5d18h). All required readings available, no hold or account switch. Grok missing: sole probe exit 1 / HTTP 402 / usage balance exhausted; no grok unit or retry. Fallback three of four.

Pin **3109b5b44eae17e288cf52aaa976993bd8c5626c**. No question dropped: Q1 pv-ez8 phase/domain, Q2 pv-2j3 size cap and units/normalization, Q3 pv-tbrs exact whitespace code points and independent hash fixtures. Packet 51270 bytes; SHA-256 receipts frozen in check/packet.sha256. Source quotes verified, r82 copied-script equality verified, independent clones clean at admission, both unpiped full Nix gates exit 0 with Lean, consistency-only pass exit 0 / NO_INTERNAL_CONTRADICTION. Main checkout/branches/tracker and manager brief untouched; every other panel folder and pre-existing unit untouched.

Stop after launch; no reader tally, implementation, next round or merge this turn. Main's exact wait command:

```sh
until [ -e /var/tmp/provisiond-panel-r84/fable.exit ] && [ -e /var/tmp/provisiond-panel-r84/opus.exit ] && [ -e /var/tmp/provisiond-panel-r84/astra.exit ] && [ -e /var/tmp/provisiond-panel-r84/sol.exit ]; do sleep 60; done
```

## TALLIED — 2026-10-30

All four answers substantive/exit 0; grok missing 402. See tally.md for per-reader picks, acceptance sets, verified source claims, full lone dissent and notes.md rule 6 disposition (no question void). Q1 A2/C2, all accept A/C: no tie-break; one consensus round. Q2 A4 first picks, exact Q2-A settled; new numeric policy/echo compatibility exclusion requires owner; owner-question.md is the sole ready question, exact form check/tally/q2-A.md. Q3 raw A3/E1; astra's literal element-versus-list oracle objection verified with independent distinct digests, so no exact-form settlement; complete E is unreviewed by other readers and goes to the same one r84b round. Q2 is not re-asked.

Initial independent unpiped full Nix gate exit 0 with Lean: check/gate-tally-before.log/.exit. Quotas entry Claude session 19%, all-models week 60%, Fable 83% exempt; active Codex WEEK 93%, permitted below 100%. All reader/check clone tracked states remain clean at pin. No main checkout, branches, tracker, manager brief, other panel folder or pre-existing unit mutation. Next: prepare r84b for Q1/Q3 only, consistency-only pass, quotas/grok check/size check, then launch once if admitted.

Final independent full unpiped Nix check-all exit 0 with Lean, every gate PASS: check/gate-tally-final.log/.exit. The unchanged-pin gate supplies baseline evidence; no candidate build or implementation is claimed. r84b packet prepared under r84b/, all original answers and exact alternatives intact; Grok sole fresh probe 402/missing, packet 86012 bytes/no split. The consistency-only pass is the remaining prelaunch check.

## r84b LAUNCHED — 2026-10-30T20:48:13.835924+00:00

Q1/Q3 only, four units panel-r84b-fable/opus/astra/sol confirmed active/running with all caps/stdin/PATH/TMPDIR checked. Whole prior answers and all exact alternatives; Q2 stays settled technically/owner pending, no re-ask. Quotas session19/week60/Fable83 exempt/Codex94; Grok402 missing/no retry, packet86012 bytes/no split. One consistency-only pass confirms the disclosed Q3 original oracle defect and finds no additional contradiction; no candidate changes. Both independent unpiped full Nix gates exit0 with Lean. Details and exact wait in r84b/STATE.md. Original answers preserved byte-for-byte, no r84b tally/implementation/main/tracker/other-panel change. Main can ask the sole owner question in owner-question.md while waiting for r84b.


## r84b TALLIED — 2026-10-30T21:02:28.092462+00:00

The ONE consensus round finished; all four answers substantive/exit0, grok402 missing. Q1 remains A2 (fable/sol) versus C2 (opus/astra), A/C accepted by all: owner tie, no r84c. Q3 exact E4 preferred/accepted, original A/B hash-oracle defect confirmed; E technically settled but its new trim policy/checks need owner approval, beyond the wording-only precedent. Per-reader strongest arguments, conditions, source verification and corrected fable A/C overclaim are in r84b/tally.md. notes rule6 voids neither question.

Q2 pv-2j3 is already owner-approved in owner-decisions-1030.md item8 (“1024 bytes, before trimming (Recommended)”), exact original Q2-A; supersedes earlier owner-pending notes, no re-tally. Queue r84b/owner-questions.md has (1) Q1 tie, (2) approve/hold E; r84b/owner-question.md is the first question only. Main asks one at a time. No new round/unit/tracker/implementation/PR/merge this turn. Initial independent full unpiped Nix gate exit0 with Lean under existing manager cap; final gate waiting for host-build admission, receipt to follow. Main checkout and all other panels untouched.


## FINAL CHECK — 2026-10-30T21:05:18.366202+00:00

r84b final verification complete: independent unchanged-pin full unpiped Nix check-all **0/0**, Lean and every gate PASS; r84b/check/tally/gate-before.* and gate-final.*. Final admission waited for fewer than two host builds, cleared at one; both checks ran inside the existing capped tally manager, **zero new units**. Reader/check clones remain clean; exact packet/answer hashes unchanged. Completed report r84b/tally.md and numbered owner queue r84b/owner-questions.md: Q1 A2/C2 to owner after the one consensus round; Q3 exact E4 technically settled, owner policy approval needed. Q2 already owner-decided item8, not re-tallied. No r84c, synthesis, tracker or main checkout change.
