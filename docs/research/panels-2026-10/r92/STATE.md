# Panel M r92 — TALLIED; Q1 and Q2 settled

Current tally is [tally.md](tally.md). **apply notes.md rule 6 exactly as written;
this prompt adds no void rule**. The source pin remains
`d65dc63e059bdefc8bab2e2e64416acf52f5b904`; no later master is substituted.

| Question | opus | astra | sol | Agree / disagree | Disposition |
|---|---|---|---|---|---|
| Q1 | LANDING ONLY | LANDING ONLY | LANDING ONLY | 3 / 0 | Settled: stale whole-item landing boundary, no demonstrated substantive decision conflict. |
| Q2 | R-BOTH | R-BOTH | R-BOTH | 3 / 0 | Settled exact reviewed wording under the owner's wording rule; both meanings preserved. |

Fable is missing: exit1, 158-byte limit line. Grok is missing: launch probe402.
These are no votes. The threshold is unchanged. R-BOTH is accepted as final by
all participating readers; HOLD as temporary is accepted by Opus/Astra and
rejected by Sol, with no final preference for it. See tally.md's source tables.
No alternative is synthesized, no owner question is needed, no r92b is created
or launched, and no old panel is reopened.

The manager independently reconstructed R-BOTH from `git show` at the old and
current pins plus the original r88 form. Removing its exact eligibility
insertion recovers the complete landed CNF-365 byte for byte. The adopted
STO-54 block still applies without alteration. Every source assertion has a
quoted landing in [check/tally-claim-audit.md](check/tally-claim-audit.md), backed
by [check/tally-verification.json](check/tally-verification.json),
[check/tally-source-quotes.md](check/tally-source-quotes.md) and
[check/tally-pin-to-R-BOTH.diff](check/tally-pin-to-R-BOTH.diff).
The audit addresses the complete requested contrary traces. Opus's provenance
paragraph description and incomplete STO-54 excerpt range are non-premise
imprecisions with no vote relying on them. Neither tally is void under rule 6.

Exact settled artifact: [settled-CNF-365.md](settled-CNF-365.md), byte-identical
to `candidates/R-BOTH.md`, SHA-256
`a2ea1e089e35ab92aeae5301ce5aa865904e833601361e3d6a8bf186a58e5061`.
Checksum: [settled-CNF-365.md.sha256](settled-CNF-365.md.sha256).
The replacement is the complete pinned checklist item at lines 1184–1228,
before `## The rate`, accompanied by the unchanged adopted r88 STO-54 block.

**NEXT: a separate turn applies the settled exact CNF-365 form to pv-by1w's
Agent Brief on PR #53**, preserving the exact adopted STO-54 block and checking
the complete brief, its drift/overlap instructions and current landing sites.
Authority is the existing owner wording rule: "For such wording questions, try
to solve by getting a consensus of the panel", plus this tally turn's explicit
preservation-and-consensus instruction. Nothing is adopted into any tracker by
this turn. No br, commit, push, PR edit, checkout or other bead action was run.

Tally-turn entry and pre-final-job quotas: Claude session11%, all-models
week72%, Fable100% exempt; active Codex WEEK11%. No hold or account switch.
Session reset Oct31 04:00 UTC; all-models week reset Nov5 15:00 UTC. No further
panel/model job or grok probe was needed.

Required unpiped gates in the panel's disposable `check/spec` clone:

| Receipt | Contents tested | Actual gate exit | Host lake builds at admission |
|---|---|---|---|
| `check/gate-tally-before.log` / `.exit` | Clean round pin, before this turn's writes | 0 | 0 |
| `check/gate-tally-final.log` / `.exit` | Exact R-BOTH plus exact adopted STO-54, simulated only in this gate clone | 0 | 0 |

Both complete `nix develop --command bash tools/check-all.sh` runs included
Lean and all gates. Admission used the existing argv-exact `/proc` lake-build
counter and waited if two existed; the runs were sequential. The own new units
`panel-r92-tally-gate-before` and `panel-r92-tally-gate-final` each used
MemoryMax16G/MemorySwapMax0/OOMPolicycontinue, null stdin, npm-global-first PATH
and TMPDIR under r92. The final package simulation changes only
`05-persistence.md` and `10-conformance-checklist.md` in the disposable gate
clone; its tracker is byte-identical to the pin. See
[check/tally-package-simulation.json](check/tally-package-simulation.json) and
[check/tally-package-simulation.diff](check/tally-package-simulation.diff).
This is draft validation, not adoption or implementation evidence.

The main checkout and its pv-avok Run, every protected worktree, other panel
folder, pgharness, PR, tracker and pre-existing unit were left untouched.
Only this panel's artifacts and its disposable gate clone were written.

## Preserved launch record (historical; tally above supersedes pending status)

Pin: origin/master d65dc63e059bdefc8bab2e2e64416acf52f5b904 (PR #52, pv-zuu5); fresh remote-head check in check/. PR #53 live OPEN unchanged at 26743d89663e996aceeb9aed245d185310dc3463. Read-only rebase 29dcceebdea761e6ad71feb018d95b0f176f0bf2 CNF-365 equals the pin. No protected-worktree/folder/unit, main-checkout, tracker, PR or bead change. No owner-decision record written.

Scope: pv-by1w only against pv-zuu5; no question dropped as settled. Q1 substance versus stale CNF-365 whole-item replacement. Q2 exact R-BOTH plus a HOLD reference, preservation of both decisions and wording-authority classification. R-BOTH preserves every landed byte and inserts exactly the C-UNKNOWN eligibility paragraphs; full exact candidates under candidates/. No reader-checkable policy conflict established by manager, so no speculative direction-specific policy amendments printed. Readers must supply both full alternatives if they establish such a conflict.

Required source records, owner items 9/18, r88 full form/tally/owner question and stop evidence copied into sources/, hashes in check/source-manifest.json; whole landed git diff retained. Exact block/row/pin/paragraph assertions in check/packet-verification.json; launcher diff check/launcher-vs-r82.diff. The consistency-only reviewer panel-r92-consistency completed exit0: NO INTERNAL CONTRADICTION. No substantive panel verdict sought or counted there.

Entry quotas: Claude session10%, all-models week72%, Fable100% exempt; active Codex WEEK9%. Resets Oct31 04:00 UTC session, Nov5 15:00 UTC both Claude weeks. Sole fresh grok one-word probe exit1 / HTTP402 balance exhausted; grok missing, no unit/retry, three-of-four fallback. Any Fable limit line is missing regardless of exit code; no threshold relaxation. Fresh prelaunch quotas: Claude session10/all-models week72/Fable100 exempt/active Codex10; explicit launch-admission.json permits launch.

Before gate: actual unpiped full nix develop --command bash tools/check-all.sh exit0, including Lean; check/gate-before.log/exit. An earlier admission-only unit panel-r92-gate-before falsely counted command-line text; stopped before gate command ran, not a gate result. Corrected /proc argv-exact admission in count-lake.py, successful initial unit panel-r92-gate-initial admitted at0 actual lake-build processes. Final unit panel-r92-gate-final completed the same complete unpiped command sequentially in check/spec, actual exit0/all gates pass including Lean; no reader runs Lean. Every own unit has MemoryMax16G/MemorySwapMax0/OOMPolicycontinue and TMPDIR under r92.

Launched 2026-10-30T23:39:27Z..23:39:28Z: panel-r92-fable, panel-r92-opus, panel-r92-astra, panel-r92-sol. All four confirmed active/running at launch with caps, npm-global-first PATH, own TMPDIR and StandardInput=null; exact receipts check/*-systemctl-show.txt and launch-verification.json. Source manifest and frozen packet hashes remain verified. Only r92 launched this turn; no tally, adoption, r92b, implementation or PR operation. A later unsettled tally gets ONE consensus round r92b in a later turn.

## Immediate postlaunch observation (no panel wait/tally)

{
  "fable": {
    "exit": "1",
    "bytes": 158,
    "limit_line_missing_seat": true
  },
  "opus": {
    "running_at_observation": true
  },
  "astra": {
    "running_at_observation": true
  },
  "sol": {
    "running_at_observation": true
  }
}

A completed limit-line answer is a missing seat, never a vote. Main must read each actual answer and count under notes.md; no finding, final-pick tally or settlement is inferred from a process exit.

Exact wait command for main:

```sh
until [ -e /var/tmp/provisiond-panel-r92/fable.exit ] && [ -e /var/tmp/provisiond-panel-r92/opus.exit ] && [ -e /var/tmp/provisiond-panel-r92/astra.exit ] && [ -e /var/tmp/provisiond-panel-r92/sol.exit ]; do sleep 60; done
```

Fable immediate answer read whole: “You've reached your Fable limit. Switch to another model, or manage usage credits at https://claude.ai/settings/usage?from=cc_cli_limit_message, to continue.” Exit1, 158 bytes: **missing seat, not a vote**. No rerun/model substitution. Grok also missing402. Opus, Astra and Sol continue; the three-of-four threshold remains three, no synthetic fourth vote or reduced threshold.
