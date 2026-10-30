# r83 — fixed scope and settlement rules

Fixed before launch. Launch-only first reading round for triage-1027 Panel D at fetched origin/master
3109b5b44eae17e288cf52aaa976993bd8c5626c. The questions are Q1 pv-gvc suspension administrative-write
coverage/release ownership, Q2 pv-bxh admission-race retryability, Q3 pv-y0to non-create evidence dispatch,
and Q4 pv-kv2 mechanics for the owner's fixed stop-before-buying decision. No source, main working tree,
branch, tracker, manager-brief, other panel folder/unit, PR or merge changes are authorized. No follow-on
consensus round is launched in this turn. The four raw bead rows are read-only evidence.

Five configured seats: fable (claude-fable-5-1 xhigh), opus (claude-opus-5-5 xhigh), astra (gpt-6-astra high),
sol (gpt-6.1-sol xhigh), grok (grok-4.7 xhigh). Grok's sole fresh one-word preflight returned HTTP 402,
"Grok Build usage balance exhausted"; it is missing and no grok unit is launched. Use three of four.
A usage-limit answer, including Fable, is a missing seat, never a vote. No Grok retry this turn.

Owner's Q4 answer, verbatim as given in brief.md: **"Stop before buying (Recommended)"**.
Option text, verbatim as given in brief.md: **"At pickup the worker sees the customer is suspended and
fails the order before spending anything. Nothing is bought or charged. Panel D then settles the exact
error and race guard. This is the 10-27 triage's pick; it wasn't put to a panel because it's a
policy choice."** Source: /var/tmp/provisiond-manager/owner-decisions-1030.md item 3.
Policy is settled. Q4's ballot is only the complete technical mechanics; Q1 must coordinate its create
case with it. Buying and charging an order first picked up while suspended is outside the ballot.

The owner's settling sentence, verbatim as printed in brief.md's governing notes rule:
"a question is settled when at least three agree and more agree than disagree, and a tie comes to you. If grok is down, it falls back to three of four".

The outcome rules preserve r82's counting, exact-form acceptance, blocking-loss, missing-seat and
premise-error rules. The prior clock-policy wording exception does not apply to these new technical
questions. The owner authorized these panels in parallel and majority technical settlements; no
unreviewed manager combination is a settled form. Different forms or different landing locations are
distinct. Q1's test-only and explicit-duty forms, Q2's status-sensitive and constant mapping, Q3's
existing-chain and explicit-dispatch forms, Q4's retryability and early-check placement are not merged.

## Outcome rules

1. The panel has five seats: fable, opus, astra, sol and grok. Each returns an explicit final pick for each
   question and separately ACCEPT / CANNOT ACCEPT for every printed form. Preserve final preference and
   acceptance separately. An alternative sentence is a distinct complete form; do not merge different
   alternatives or combine unread repairs. A requested counterargument is not a vote. Verify factual
   claims against the pinned sources before relaying them.
2. Owner's exact settling rule: "a question is settled when at least three agree and more agree than disagree, and a tie comes to you. If grok is down, it falls back to three of four". Apply this to the same exact form,
   with no verified blocking loss under rule 3 and no synthesized tie-break. Record both the explicit
   final-pick tally and acceptability sets. If more than one form qualifies, preserve the readers'
   explicit preferences; do not invent a tie-break. The owner's "you" means main relaying to the owner,
   not the manager. Q4's fixed policy cannot be reversed by a mechanics tally.
3. A blocking loss must identify a checked verdict changed, made unreachable or vacuous (a conformance
   assertion or Lean theorem), or quote a MUST/SHOULD with file, owner and trace. Disclose any collateral
   flip. A changed declaration, proof statement, guard hypothesis, normative obligation, fixture or
   negative-control strength is substantive, not an editorial repair. A merely absent new runtime test
   is not a contradiction in the unchanged base. These are technical proposal votes, not permission to
   weaken the existing checks or to undo the fixed owner policy.
4. A tie or no settlement gets ONE further full-panel consensus round: show each reader the others'
   answers verbatim, name the exact disagreements, give every exact option completely, and ask for a
   form it can accept. If that round settles by rule 2, use its result; otherwise return the remaining
   question to the owner. Never more than one consensus round per question. This launch-only turn does
   not launch that round.
5. A reader answering with a usage-limit line is a missing seat, not a vote. This includes Fable
   regardless of exit code. Failed, empty, unavailable or non-substantive outputs are not votes. Verify
   actual output, not exit 0 alone. With grok down, apply rule 2's three-of-four fallback. The common
   launch instructions explicitly also allow "Not signed in" as a missing grok seat for this launch;
   today's actual result is 402.
6. A verified brief error that changes the question's premise voids its tally; re-ask it corrected.
   Other brief errors are reported with the tally, identifying any vote whose reason rests on one.
7. Do not weaken or delete a disputed rule to clear a review. Preserve what it protects and name any
   tested/normative verdict lost before proposing a substantive departure. No unread manager synthesis
   counts as reviewed.

Every tally prompt must say exactly: **apply notes.md rule 6 exactly as written; this prompt adds no void rule**.

## Launch and evidence

Four clean independent reader clones, fetched origin/master and detached at the recorded pin. The r82
Claude-stdin and Codex wrappers are copied changing artifact paths only. The launch script differs only
in paths and unit labels: panel-r83-fable, panel-r83-opus, panel-r83-astra, panel-r83-sol. These names
follow the owner's panel-r83-<seat> instruction, so Claude's old -stdin unit suffix becomes the seat
label. Each has MemoryMax=16G, MemorySwapMax=0, OOMPolicy=continue, timeout 3600, stdin from /dev/null
at unit entry and identical brief.md on the CLI's stdin. Codex PATH begins /home/user/.npm-global/bin;
TMPDIR is /var/tmp/provisiond-panel-r83/tmp. Each reader has its own clone. No reader runs Lean or Nix
gates. The manager alone runs required unpiped gates. Canonical outputs: <seat>.md and <seat>.exit.
Systemctl caps/active-state receipts, launch-script diff, pin, raw quota outputs, source extraction
receipts and contradiction-only preflight are under check/. Do not wait for the readers this turn.

Entry readings: Claude session 18% (reset 2026-10-30 23:00 UTC), week all models 60% (reset 2026-11-05
15:00 UTC), week Fable 83% (same reset, exempt). Active Codex WEEK 93%, permitted below 100%.
Claude session/all-models >80% or unavailable holds launch. Fable never holds. Codex at 100% or a
usage-limit error stops further Codex launches; never switch/logout. Re-read before launches and
record the raw readings and decision in STATE.md. The one-word Grok probe returned 402, as above.
The brief is substantially below the ~1 MB Grok failure packet threshold; if Grok had answered it
would fit as one packet. Grok is missing; no full material was sent to it.

The initial required unpiped Nix gate in the main checkout passed, exit 0, before artifact drafting;
tracked main-tree state remained clean. The final required gate runs in check/spec at the same pin,
with its own capped unit and artifacts. Gate success verifies the pinned base only: proposals are
not applied, built or claimed gate-verified. Final gate exit is recorded in STATE.md before report.

Completed prelaunch checks: the separate contradiction-only read exited 0 with "NO INTERNAL
CONTRADICTIONS FOUND." No candidate repair or further read was needed. The final pinned-base
unpiped Nix check-all exited 0 with every gate PASS, including Lean. The original wrappers and
launcher-copy diff are verified in check/. Fresh launch quotas and live unit receipts are recorded
in STATE.md; the entry values above are retained as entry evidence.
