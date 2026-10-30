# r85 — fixed scope and settlement rules

Fixed before launch. triage-1027 Panel F covers Q1 pv-y1zy, Q2 pv-xzre and Q3 pv-hups,
at origin/master 3109b5b44eae17e288cf52aaa976993bd8c5626c. The current bead records and
triage rows are retained read-only in check/beads.json and check/table-rows.md. No question
was dropped as already settled; since-triage.diff records the owning-document comparison.
The pv-wfld disposition and the existing writer-based single-origin results stay outside
this vote. This turn authorizes verification, packet drafting and one launch only: no
main-checkout, branch, tracker, manager-brief, source or PR writes, no adoption, no rloop Run,
no follow-on consensus round and no merge. Reader clones are detached and independent.

Five configured seats: fable, opus, astra, sol and grok. Four participate in this launch.
Grok's sole one-word preflight exited 1 with HTTP 402 Payment Required, “Grok Build usage
balance exhausted”. Its output and true exit are in grok-probe.{out,err,exit}. Grok is a
missing seat, never a vote; no grok unit or retry is launched. Use the owner's three-of-four
fallback. The packet is about 73 KB, below the approximately 1 MB too-big-for-grok case;
its size did not prevent participation. A Fable limit line is also a missing seat and never
holds the launch by itself.

The question forms are exact replacement text plus exact conformance additions at the
printed landing points. Preserve final preference and acceptability separately, by the
same whole form. Q1 A/B/C/D, Q2 A/B/C/D, and Q3 A/B/C are distinct forms, not interchangeable
votes. Q2 D keeps the quoted current origin sentences, with no precedence or fixture;
Q1 C keeps the quoted current row and leaves the disputed set selection unresolved. Q1 D limits its new set rule to the demonstrated cases and uses A's exact fixtures. Q3 B
is the existing normative text plus the printed fixture, not a claim that tests are unchanged.
The technical choices have not been adopted. A proposed alternative needs complete wording
and is not acceptance of a printed form. No unread manager combination counts as reviewed.

## Outcome rules

1. The panel has five seats: fable, opus, astra, sol and grok. Each returns an explicit
   final preference and separately ACCEPT / CANNOT ACCEPT for every printed option on each
   question. Preserve final preference and acceptance separately. An alternative sentence
   is a distinct complete form; do not merge different alternatives or combine unread
   repairs. A requested counterargument is not a vote. Verify factual claims against the
   pinned sources before relaying them.
2. Owner's exact settling rule: "a question is settled when at least three agree and more agree than disagree, and a tie comes to you. If grok is down, it falls back to three of four". Apply this to the same exact form, with no verified blocking loss under rule 3 and no synthesized tie-break. Record both the explicit final-pick tally and acceptability sets. If more than one form qualifies, preserve the readers' explicit preferences; do not invent a tie-break. The owner's "you" means main relaying to the owner, not the manager. A later wording exception applies only after the exact form is settled and verified to change no behavior, requirement or check strength.
3. A blocking loss must identify a checked verdict changed, made unreachable or vacuous
   (a conformance assertion or Lean theorem), or quote a MUST/SHOULD with file, owner and
   trace. Disclose any collateral flip. A changed declaration, proof statement, guard
   hypothesis, normative obligation, fixture or negative-control strength is substantive,
   not an editorial repair. A merely absent new runtime test is not a contradiction in
   the unchanged base. Do not treat a new conformance assertion as proof that its behavior
   was already uniquely required. Verify the substantive/wording judgment before using any
   wording exception; no adoption is authorized in this launch-only turn.
4. A tie or no settlement gets ONE further full-panel consensus round: show each reader
   the others' answers verbatim, name the exact disagreements, give every exact option
   completely, and ask for a form it can accept. If that round settles by rule 2, use its
   result; otherwise return the remaining question to the owner. Never more than one
   consensus round per question. This launch-only turn does not launch that round.
5. A reader answering with a usage-limit line is a missing seat, not a vote. This includes
   Fable regardless of exit code. Failed, empty, unavailable or non-substantive outputs are
   not votes. Verify actual output, not exit 0 alone. If grok is down, apply rule 2's
   three-of-four fallback. The common 1030 launch instruction explicitly permits the same
   missing-seat launch on a preflight “Not signed in”; this turn's result was 402.
6. A verified brief error that changes the question's premise voids its tally; re-ask it
   corrected. Other brief errors are reported with the tally, identifying any vote whose
   reason rests on one.
7. Do not weaken or delete a disputed rule to clear a review. Preserve what it protects
   and name any tested/normative verdict lost before proposing a substantive departure.
   No unread manager synthesis counts as reviewed.

Every tally prompt must say exactly: **apply notes.md rule 6 exactly as written; this prompt adds no void rule**.

## Launch and evidence

The r82 launch.sh, run-claude-stdin.sh and run-codex.sh are copied with panel paths and unit
labels changed only. The Claude stdin unit labels lose the historical -stdin suffix to meet
the requested panel-r85-<seat> naming. Models and efforts: claude-fable-5-1 xhigh,
claude-opus-5-5 xhigh, gpt-6-astra high, gpt-6.1-sol xhigh. Four independent clones at the
pin; no shared Beads database or .git state. Each wrapper has timeout 3600, stdin from the
same brief file and canonical <seat>.exit containing the actual command exit. The launcher
itself and the units receive stdin from /dev/null; CLI prompt stdin is intentionally the
brief, as in r82. Each unit has MemoryMax=16G, MemorySwapMax=0, OOMPolicy=continue, npm-global
first on PATH and TMPDIR under this folder. Reader instructions forbid all builds, source
edits, unrelated reads and subagents. No reader waits on another.

Entry quotas: Claude session 3% (reset Oct 30 23:00 UTC), all-models week 57% (reset Nov 5
15:00 UTC), Fable week 79% (same reset, exempt); active Codex WEEK 88%, permitted below
100%. Record a fresh set before launch in STATE.md. Only Claude session/all-models week
>80% or unavailable holds launch; Fable never holds. Codex at 100% or usage-limit error
stops further Codex work; never switch accounts or log out.

Manager-only before/final gates use unpiped `nix develop --command bash tools/check-all.sh`
in check/spec, with independent capped units and actual exit files. Formal admission waits
while two or more host lake builds exist. Gates certify the unchanged pin only. No reader
runs lake build or any gate. Packet quote/fixture/clone verification, the self-contradiction
pass, r82 script diffs and unit receipts live in check/. All other panel folders and every
pre-existing unit stay untouched.
