# r77b — Panel B Q1 reading rules

Current authorization: the owner's r77 tally instruction explicitly authorizes preparing and launching another five-seat reading when no reviewed form is settled. This round reads only pv-ymjo's complete Y-PROV-R/Y-WIDE-R packages. Pinned SHA: 1fc54e8f361e4a9342359388314d32c398595f62. Work only in /var/tmp/provisiond-panel-r77/r77b/ and its independent reader clones; prior r77 final answers are read-only evidence. No main checkout, branches/shared tracker, manager-brief write, Panel A, production, br, commit, push, implementation or automatic next round.

## Outcome rules

1. Give ACCEPT / AMEND / CANNOT ACCEPT on every exact package for that question, followed by one explicit final preference among acceptable packages or NONE. AMEND must quote exact location, before and replacement, and mark behaviour unchanged or behaviour changed. Wording/quotation/citation-only repairs count ACCEPT only after verification. A new normative exception, payload change, conformance assertion, fixture restriction or feasibility mechanism is behavioural. Changed, unmarked or failed-verification AMEND does not count ACCEPT of the printed package. A preferred direction is not complete-form acceptance.
2. A package is reviewed only with the owner's settling rule ("a question is settled when at least three agree and more agree than disagree, and a tie comes to you. If grok is down, it falls back to three of four") and no verified blocking loss under rule 3. If multiple qualify, preserve each reader's explicit preference; do not synthesize or invent a tie-break. A policy/cost choice returns to the owner after mechanics; ready-for-agent additionally requires existing owner authorization of that behavior. No automatic application or Run follows this read.
3. A blocking loss must name a checked verdict changed, made unreachable or vacuous (CNF assertion or Lean theorem), or quote a MUST/SHOULD with file, owner and trace. Declared new obligations and declared fixture/classification changes are considered as amendments, not hidden baseline losses. Any omitted collateral flip must still be disclosed. An absent new runtime test is not a contradiction in the unchanged base. Coverage and resource/latency costs are reported separately; other substantive objections still affect ACCEPT. Strict quotation-only repairs use the owner's exact words and are reported as wording repairs.
4. If no exact package qualifies, return explicit vote sets, exact proposed repairs, strongest arguments and dissent traces. No unread manager union or reader repair is recommended as reviewed. Compatible repairs need their own complete-form reading. Do not automatically launch another round.
5. No automatic deletion of a disputed clause is authorized. Preserve what it protects and name any tested/normative verdict lost before proposing deletion.
6. A verified brief error that changes a question's premise voids that question's tally only; re-ask it corrected. Other brief errors are reported with the tally, identifying any vote whose reason rests on one.
7. Counterarguments written on request are not votes. Relay votes first and labelled counterarguments after.

Every tally prompt must say exactly: **apply notes.md rule 6 exactly as written; this prompt adds no void rule**.

In rule 2 the owner's “you” means the assistant relaying to the owner: a tie goes to the owner, never to a manager's tie-break. There are five seats. An absent or failed Grok review uses the owner's three-of-four fallback; prelaunch “Not signed in” still stops this launch. Confirm substantive answers and verify wording repairs before counting any seat.

## Scope

The common supersession exception, upgrade treatment and already-reconciling-row policy are proposed amendments, not facts already authorized by the owner. Q2 is outside this read. No repaired package or synthesis is accepted until these readers examine it whole; acceptance still leaves owner policy/cost choices. No automatic deletion of disputed safeguards or automated adoption follows.

## Launch and quota

Five seats, identical brief, independent detached clones: fable claude-fable-5-1 xhigh; opus claude-opus-5-5 xhigh; astra gpt-6-astra high; sol gpt-6.1-sol xhigh; grok grok-4.7 xhigh. Every reader unit has MemoryMax=16G, MemorySwapMax=0, OOMPolicy=continue and timeout 3600. PATH starts /home/user/.npm-global/bin; TMPDIR is this round's tmp/. The r77 wrappers and launcher are copied with only round-folder/unit substitutions. Claude background agents remain disabled; Grok keeps the exact read-only invocation and deny flags. Credential/session/config stores including ~/.grok, ~/.claude and ~/.codex are forbidden reads.

Before launch read claude -p /usage for all three readings and codex-switch list for the active WEEK. Any unavailable Claude reading or any Claude quota >80% holds new work; exactly 80% is allowed. Codex's 2026-10-28 exception permits WEEK below 100%, recorded with the others. At 100% or a Codex usage-limit failure start no further Codex work; never switch/logout accounts. Confirm a one-word Grok probe answers before launch; Not signed in stops launch and requires the owner's grok login --device-code. Record fresh quotas/login, activity, caps and live PATH/TMPDIR. Launch then return; do not wait for reader completion. No delayed launcher is queued on hold.
