# Panel L r91 — launch state

Pin: aeb7ff65369238212903d6b60b8ae1622f5c93d8, origin/master after Panel E prep PR #50 merged. Initially origin/master was 01210c62f17f0a77a71056b80c886d7a8ee0efeb; independently fetched the later master into this panel's clone. Every changed path is tracker/archive only; relevant spec, checker, CI, existing fixtures and owning ADRs are byte-identical. Proof: check/packet-verification.json. Main checkout and tracker database were never written/opened. pv-602's committed object is identical and remains deferred.

Nothing dropped as settled. Source question: owner-queue-1030/questions.md entry 4, lines 38–52, copied whole with its evidence in source-evidence.md. The October 21 A–E completion condition is met, as documented in the October 26 handoff. This is launch only: no owner approval, implementation, tracker change, PR, merge or follow-on panel round.

Exact complete A/B/C/N packages and every existing quote case are supplied, with the bead's own corruptions. Literal unmigrated guards reject a correct current CNF-302 citation of CNF-300 at 10-conformance-checklist.md:3095–3096; this is disclosed, not hidden as a successful content comparison. A/C include the exact two-mark migration and B retains the original bytes. Complete packages pass the actual Python CLI and the exact embedded CI control; no-change misses all named straight bare-possessive plants. Final manager verification: tmp/manager-final-verifier/results.json; current unconverted-input CLI receipts: check/unconverted-current-cli.json. The old manager-verifier run predates the final small Lean source-line handling fix and is preliminary only. Every inherited self-test is byte-identical and every prior comparison survives: check/current-comparison-preservation.json and packet-verification.json. No pv-erp R7/R8 matcher/search repair is included.

Consistency-only reviewer: check/consistency.md, exit 0, CONSISTENT; disposition in check/consistency-disposition.md. Full unpiped Nix check-all: check/gate-before.exit=0 at initial pin and check/gate-final.exit=0 at final pin, including Lean. Both were independent from main; admission found fewer than two host lake builds before start. Units panel-r91-gate-before, panel-r91-gate-final and panel-r91-consistency had MemoryMax=16G, MemorySwapMax=0, OOMPolicy=continue. Gate/source clones remain clean apart from ordinary ignored build outputs. No reader may run lake build or check-all.

Entry quotas: Claude session 58% (reset Oct 30 23:00 UTC), all-models week 67% (reset Nov 5 15:00 UTC), Fable week 93% (exempt); active Codex WEEK 1%. Before consistency/final gate: session 60%, week 67%, Fable 94% exempt, Codex 2%. Prelaunch: session 61%, week 67%, Fable 94% exempt, Codex 3%. Raw readings in check/quota-*.txt. Claude blocking readings <=80 and Codex <100; no hold, switch or logout.

Grok: sole read-only one-word preflight exit 1, HTTP 402 Payment Required, “Grok Build usage balance exhausted”. Missing seat, no retry. Four participating readers; owner's three-of-four fallback is fixed in notes.md with the settling sentence verbatim. Required read packet is 676655 bytes (files enumerated in freeze-launch.py), below the ~1 MB Grok threshold. Full resulting candidate files are also provided; shared-base-plus-complete-patch avoids rereading unchanged CI/checklist copies. Packet hashes: check/packet.sha256.

Clean independent detached clones: fable/, opus/, astra/, sol/, all at the final pin. r82 wrappers differ only in panel paths; launch.sh differs only in panel path and required unit labels. Diff evidence: check/r82-*.diff. Models/efforts unchanged: claude-fable-5-1 xhigh, claude-opus-5-5 xhigh, gpt-6-astra high, gpt-6.1-sol xhigh. stdin/caps/environment follow r82. Protected panel folders, pgharness, main checkout and all pre-existing units are untouched.

Prelaunch complete; units not yet launched. Next action is launch.sh, verify active state/caps/environment, append receipts, then return without waiting or tallying.

## LAUNCHED

2026-10-30T21:46:19.448778+00:00: all four units active/running with live caps, npm-global-first PATH, own TMPDIR, correct working clones and unchanged frozen packet verified. Receipts: check/launch-receipts.json and <seat>-systemctl-show.txt. Grok missing (402); no unit launched. No reader answer has been waited on or tallied; no follow-on action.

Wait command for main:

```sh
until [ -f /var/tmp/provisiond-panel-r91/fable.exit ] && [ -f /var/tmp/provisiond-panel-r91/opus.exit ] && [ -f /var/tmp/provisiond-panel-r91/astra.exit ] && [ -f /var/tmp/provisiond-panel-r91/sol.exit ]; do sleep 60; done
```

## TALLIED — Q1 technical recommendation C; owner approval pending

The launch state above is historical. All participating answers are substantive and exit 0;
Grok is missing (402), not a vote. Final picks: Fable C, Opus C, Astra B, Sol C. Exact C
is accepted by all four; A by Fable/Sol, B by Astra, N by none. C alone settles under
notes rule 2. No verified brief error changes the premise under rule 6. The one-line
locator error, B's per-chunk scanner limitation, newly identified B length-cap regression
and reader procedural limitations are recorded in `tally.md`; none is silently repaired
or converted into a new void rule.

Owner question: `owner-questions.md`. Recommend only the complete printed C package,
`candidates/C/exact.patch`, SHA-256
`7fe46ae3b60c21c6b19b2dc553c1bd7d2617497ef18cef509aa891ee6406903f`.
It includes the narrower guard, its self-test/docstring, exact CI control and CNF-302's
two outer-mark changes. Original straight punctuation is rejected; the migration is
not claimed to preserve that syntax. No r91b needed or launched. B′ and B2 remain
distinct unreviewed alternatives, not counted or combined. Nothing is adopted;
pv-602 remains deferred pending owner approval, with no tracker/implementation action.

Independent tally audit: `check/tally-1030/audit.exit=0`, with complete candidate
reconstruction, inherited-test/comparison-function preservation, current inventory slice
preservation and real-CLI reproductions of both sides' strongest arguments. The supplied
verifier was freshly rerun: `check/tally-1030/verify.exit=0`; clean packages and exact
embedded controls pass, N's named straight bare-possessive plants stay green, and
unconverted correct CNF-302 fails A/C. Full receipts are linked from `tally.md`.

Tally initial full unpiped Nix check-all: `check/tally-1030/gate-before.exit=0`, all gates
PASS including Lean; admission recorded one existing host lake build. Unit
`panel-r91-tally-gate-before` had 16G/zero swap/OOMPolicy=continue/null stdin.
The final gate is the remaining check before reporting completion; its result will be
recorded below. Initial quotas: Claude session74/week69/Fable98 exempt/Codex5;
before final gate: session75/week69/Fable98 exempt/Codex5. No hold, retry, login,
logout or account switch. Source reads and all writes stay within this panel;
main checkout, tracker, other panels, pgharness and pre-existing units are untouched
by this tally. No `br` command was run.

Final tally gate complete: `check/tally-1030/gate-final.exit=0`; every summary gate PASS,
including Lean. Final admission recorded zero host lake builds. Both full gates were
unpiped, with actual exits captured by the wrapper. Immediate live launch checks confirmed
both units' 16G/zero-swap/OOMPolicy=continue/null-stdin properties; observations and their
provenance are in `check/tally-1030/gate-launch-receipts.json`. The completed transient
units were later unloaded; a post-completion query's default infinity properties are not
treated as their runtime configuration. PATH/TMPDIR are assigned in the preserved wrapper.
`check/tally-1030/source-clean.json` confirms every reader clone and the gate clone remain
clean at the pin. Recommendation and exact C hash unchanged. Tally complete; next action
belongs to main: relay the single compact owner-approval question, without adopting it.
