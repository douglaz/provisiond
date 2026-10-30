# Panel F — r85

Scope: verification, exact candidate packet and one launch only. No main-checkout, branch,
tracker or manager-brief writes. All artifacts stay under this folder.

Entry quota readings (2026-10-30 UTC): Claude session 3% (reset Oct 30 23:00 UTC),
all-models week 57% (reset Nov 5 15:00 UTC), Fable week 79% (same reset, exempt).
Active Codex WEEK 88%, permitted until 100%; no account switch or logout.
Raw receipts: quota-claude.txt and quota-codex.txt. No blocking quota reading.

Verified pin: origin/master 3109b5b44eae17e288cf52aaa976993bd8c5626c.
All three questions remain open; no already-settled question dropped. Current owner passages
and complete bead descriptions were read at the pin. The since-08191bb diff changes restore
marker provenance, not the disputed pointer/origin/timing clauses. Fixtures use trusted
marker provenance explicitly. Sole Grok probe exit 1 / HTTP 402 Payment Required:
“Grok Build usage balance exhausted”; missing seat, no retry, three-of-four fallback.
Manager before gate panel-r85-gate-before launched with required caps; admission waits for
fewer than two host lake builds. No reader build is authorized.

Before gate: check/gate-before.exit = 0, all gates PASS including Lean. Gate admission observed
host lake counts 3/2 and waited until 1, then ran; no reader performed a build. Gate unit caps
were confirmed. Before final-gate quotas: Claude session 4%, all-models week 58%, Fable 80%
(exempt), active Codex WEEK 89%; no hold. Four independent detached reader clones created
from the repository's origin URL at the pin, with separate .git state.

Prelaunch quota receipt 2026-10-30T19:35:54.021474+00:00: Claude session 7%, all-models week 58%, Fable 81% (exempt), active Codex WEEK 89%; guard permits launch. No account switch/logout.
Both unpiped manager gate runs exit 0, including Lean. check/packet-verification.json verifies exact source quotes/replacement spans, fixture data, reader clones at the origin pin, r82 script equality except paths/unit labels, and both gate exits. Internal-consistency pass completed in check/self-consistency.md. Packet frozen for this launch; no candidate has been adopted.

LAUNCHED 2026-10-30T19:35:54.136358+00:00: panel-r85-fable, panel-r85-opus, panel-r85-astra, panel-r85-sol. All four independently confirmed active/running with MemoryMax=16G, MemorySwapMax=0, OOMPolicy=continue, StandardInput=null, npm-global-first PATH and panel-local TMPDIR. Same r82 models/efforts, 3600-second wrappers, four distinct clones. No Grok unit; missing 402 seat; three-of-four fallback. No reader awaited, no follow-on round, no main checkout/tracker/branch or manager-brief change.
Wait: `until [ -e /var/tmp/provisiond-panel-r85/fable.exit ] && [ -e /var/tmp/provisiond-panel-r85/opus.exit ] && [ -e /var/tmp/provisiond-panel-r85/astra.exit ] && [ -e /var/tmp/provisiond-panel-r85/sol.exit ]; do sleep 60; done`

## Tally, 2026-10-30

All four answers read whole and substantive, actual exits 0; no limit/sign-in/capacity
answer and no draft. Codex .out agrees with each final answer. Raw error transcripts
were audited; command inventory, answer hashes, all pinned Source owner quote checks,
and clean tracked reader states are in check/tally-verification.json. Grok remains the
launch's missing 402 seat, no retry. Apply notes.md rule 6 exactly as written; this
prompt adds no void rule. No premise-changing brief error or verified rule-3 blocker.

Q1 final A=fable/astra/sol, A-prime=opus; A/B/D accepted by fable/astra/sol, C accepted
by astra/sol. Q1-A SETTLED; opus's admission field-presence objection traced in full,
preserved as an added-obligation qualification, not counted as acceptance of printed A.
Q2 final B=all four, B accepted by all; A/C accepted by astra/sol, D by none. Q2-B SETTLED.
Q3 final A=all four, A/C accepted by all; B accepted by fable/opus. Q3-A SETTLED.
No manager merge, new form, tie-break or rule-6 void. Canonical exact packages remain
in brief.md, not adopted. All selected packages add behavior or conformance strength:
OWNER QUESTIONS, not ready-for-agent under the wording-only precedent. Main asks item 1
of owner-questions.md first; later items remain queued. No consensus round needed or
launched. Tally and verified objections: tally.md.

Fresh tally entry quota: Claude session 19%, all-models week 60%, Fable 83% exempt;
active Codex WEEK 93%. Fresh before-final-gate receipt: same percentages, in
check/tally-final-quota-{claude,codex}.txt with actual exit files, both 0. No hold or
account switch/logout. The initial codex-switch list lookup lacked ~/.local/bin on PATH;
the installed absolute-path command then returned a valid reading. No failure was
treated as a quota reading.

Independent capped manager before gate panel-r85-tally-gate-before completed exit 0,
all gates PASS including Lean, check/gate-tally-before.{log,exit}. Final gate
panel-r85-tally-gate-final launched with MemoryMax=16G, MemorySwapMax=0,
OOMPolicy=continue and StandardInput=null, confirmed active/running. Its wrapper sets
npm-global-first PATH and panel-local TMPDIR and waits for host lake count below two.
Final gate completed exit 0, all gates PASS including Lean; actual receipts are
check/gate-tally-final.{log,exit}. The gate clone remains tracked-clean at the pin.
Both independent unpiped manager gates passed; no candidate gate result is claimed.

No main-checkout, branch, tracker, source, manager-brief, PR, other-panel or existing-unit
mutation; no adoption or implementation. Only panel-local tally artifacts and the two
new manager gate units were created.
