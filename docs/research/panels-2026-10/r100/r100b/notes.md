# Panel r100b — notes (read first)

This is r100's one consensus round. Two questions are open: Q1 (Q1-QUOTE, Q1-KEEP, the printed Q1-ALT
or a complete exact ALT) and Q-ROUTE (R-RUN, R-NOTE or a complete exact ALT). Q2, Q3 and Q6 settled
3–0 on QUOTE, Q4 on Q4-KEEP, and Q5 and Q7 on KEEP; they are not reopened, and no Q8 is open. Answer
each question independently. A label with different bytes is not the same form. The pin is
`2cb8e1189310ae096e598bac798df3437be59500`. The packet makes no recommendation.

## Outcome rules

1. The panel has five seats: fable, opus, astra, sol and grok. Each returns an explicit final pick for
   every question, and separately ACCEPT or CANNOT ACCEPT for every printed option. Keep the final
   preference and the acceptance separate. An alternative is a distinct complete form: do not merge
   different alternatives or combine unread repairs. A requested counterargument is not a vote. Verify
   factual claims against the pinned sources before relying on them.
2. The owner's exact settling rule: "a question is settled when at least three agree and more agree
   than disagree, and a tie comes to you. If grok is down, it falls back to three of four". Apply it to
   the same exact form, with no verified blocking loss under rule 3 and no synthesized tie-break.
   Record both the final-pick tally and the acceptability sets. If more than one form qualifies, keep
   the readers' explicit preferences and do not invent a tie-break. The owner's "you" means main
   relaying to the owner, not the manager. The wording exception lets a later manager act without
   asking only after the exact form is settled and verified to make no behavior, requirement or
   check-strength change.
3. A blocking loss must identify a checked verdict that is changed, made unreachable or made vacuous
   (a conformance assertion or a Lean theorem), or quote a MUST or SHOULD with file, owner and trace.
   Disclose any collateral flip. These are substantive, not editorial repairs: a changed declaration,
   proof statement, guard hypothesis, normative obligation, fixture or negative-control strength. A
   runtime test that is merely absent is not a contradiction in the unchanged base. Verify the three
   beyond-wording judgments separately before applying the wording exception; substantive changes stay
   with the owner.
4. A tie, or no settlement, gets ONE further full-panel consensus round. Show each reader the others'
   answers verbatim, name the exact disagreements, give every exact option in full, and ask for a form
   it can accept. If that round settles by rule 2, use its result; otherwise return the remaining
   question to the owner. There is never more than one consensus round for this question. This round,
   r100b, is that one round; there is no r100c.
5. A reader that answers with a usage-limit line is a missing seat, not a vote. This includes Fable,
   whatever its exit code, and a grok HTTP 402. Failed, empty, unavailable or non-substantive outputs
   are not votes. Verify the actual output, not exit 0 alone. If grok is down, apply rule 2's
   three-of-four fallback. Missing seats never lower the three agreements required.
6. A verified brief error that changes a question's premise voids that question's tally; re-ask it
   corrected. Other brief errors are reported with the tally, naming any vote whose reason rests on one.
7. Do not weaken or delete a disputed rule to clear a review. Keep what it protects, and name any
   tested or normative verdict lost before proposing a substantive departure. No unread manager
   synthesis counts as reviewed.

Every tally prompt must say exactly: **apply notes.md rule 6 exactly as written; this prompt adds no void rule**.

## Fences

- Read only: no edits, no Git mutation, no subagents, no Nix (no `nix develop`, no
  `tools/check-all.sh`), no lake, no br. Your clone is detached at the pin. Scratch goes only under
  your tmp folder.
- Do not read `~/.grok` or any other credential or account directory.
- Do not read or touch `/home/user/projects/provisiond-spec`. Everything you need is in your clone at
  the pin, in r100's and r100b's packet files, and in the read-only records r100's brief cites by path
  under `/var/tmp/` (earlier panels' folders, `/var/tmp/provisiond-manager/owner-decisions-1030.md`
  and `/var/tmp/provisiond-manager/dr-e45e-check/`).
- Do not post to GitHub, and do not touch the tracker or beads.
- r100's answers reach you only through r100b's `brief.md` §6, without names. Do not read any reader
  output or record in `/var/tmp/provisiond-panel-r100` or its `r100b` folder: the `*.md` answers other
  than `brief.md`, `notes.md` and `R-NOTE-append.md`, every `*.out`, `*.err` and `*.exit`, `tally.md`,
  `STATE.md`, `packet-manifest.json`, `prompts/`, `check/*-systemctl-show.txt`,
  `check/*-Q1-ALT.txt` (use `Q1-ALT.txt`), `r100b/check/labels.json`, `r100b/check/build.py`,
  `r100b/check/build.out`, every r100 seat clone other than your own r100b clone, and every `tmp/`
  folder other than your own.
