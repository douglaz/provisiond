# Settled pv-5pmu PR #69 wording correction — Panel r99 (with consensus round r99b and owner item 27)

Q1: Q1-QUOTE. Q2: KEEP. Q3: KEEP. Q4: Q4-ALT. Q5: KEEP. Q-REC: R-NOTE-ALT with its append.

How each settled. Q1, Q3 and Q5 settled 3–0 in Panel r99. Q4 settled 3–0 in consensus round r99b on Q4-ALT (r99's Q4 tally is void under rule 6; r99b is its re-ask). Q-REC settled 3–0 in r99b on R-NOTE-ALT and its append. Opus, Astra and Sol are the three present seats each time; Fable (usage-limit line) and Grok (HTTP 402) are missing seats, not votes. Q2 did not settle on the panel: it split 2–1 in r99 and again in r99b, and came to the owner under the tie rule. The owner answered "Keep the clause as landed" (owner item 27, `owner-decisions-1030.md`; verbatim in `owner-item27.md` next to this file). Q2 is therefore KEEP by the owner's decision, not by panel settlement. This file records the settlement only; no tracker, branch or PR change occurred.

Pin and PR #69 head: `efb40cc55ff04be693473914afd42ef68008fa15` (branch `pv-5pmu`). PR base: `b5f71e78a1f195acfa4ac28f090d38e9a35568f0` (master). Both checked 2026-11-03 14:28Z: PR open, head unchanged, mergeable.

Span convention: each `Qn-*.txt` file ends with one LF that is not part of the span (`read_text()[:-1]`). The append is the whole `R-NOTE-ALT-append.md` file, including its two leading LFs and its final LF.

## Forms

| Form | File | Bytes (file) | SHA-256 (file) |
|---|---|---|---|
| Q1-OLD | `Q1-OLD.txt` | 67 | `e339d2da45ec1e737a219aa0e4486188ffd47cf3a78e85d712935e0b73be9645` |
| Q1-QUOTE | `Q1-QUOTE.txt` | 210 | `4c0cbffbf91643afc682f63211c82ae400928e101dd9b4d48aa8e11a49d5419e` |
| Q2-OLD | `Q2-OLD.txt` | 92 | `12190045a02e094e0c26f8556f7c008eb09bddd7533710f3f10a7d1c634d9ac6` |
| Q2-KEEP | `Q2-KEEP.txt` | 172 | `e3d78fbf0b44b7cd667f0a418c3b5b15b03c4cf067aa5ab9d033a1d8ed4f82f8` |
| Q3-OLD | `Q3-OLD.txt` | 95 | `cd8ff6fa74350e7edb89f869b4080b46bcb1fce28f22e20d750810848e32db37` |
| Q3-KEEP | `Q3-KEEP.txt` | 172 | `d8a232a628594f4bd1f261fcf2b3cf8fb7477ec0369e4a9598c06a66d9525f0c` |
| Q4-OLD | `Q4-OLD.txt` | 80 | `8f673c0a119baeb0677a6ecff4cc4947e29f8c11d5af415835953682d7ad89b7` |
| Q4-ALT | `r99b/forms/Q4-ALT.txt` | 256 | `c12991b321e6e9abc74e67dfebba3f16554ee8048ff09a0ca0895933614fa318` |
| Q5-OLD | `Q5-OLD.txt` | 47 | `9600d5d0ba7b7a0c833a76310fbe5da1d7a86e291192a2e9c5fda475e57e51a9` |
| Q5-KEEP | `Q5-KEEP.txt` | 168 | `49a3adf34de880cb20d3b47eeee30f58f7b7aeb5958a8e667feeb6ce71fb3f27` |
| R-NOTE-ALT | `r99b/forms/R-NOTE-ALT.txt` | 797 | `23c4c1f832289f9eb76dc09a8ecad61a8c8c1b3908d5a4d3f6cc94ff202ba720` |
| R-NOTE-ALT-append | `r99b/forms/R-NOTE-ALT-append.md` | 638 | `445f69c220bfcdefd455fb6447c2c5e93b76d16274a9c051e21b0423358b02ea` |

Rejected by the owner (for the record only, never applied): Q2-QUOTE, `Q2-QUOTE.txt`, `2b46b8b8d673696e3a4668f96be33fe3e2da919431613e22188cb35793b4adc6`.

### Q1-OLD

````text
PRV-25's identical-PTR success remains after its capability check.
````

### Q1-QUOTE

````text
`PRV-25` says "After the ordinary authorization, capability and `API-16` validation" and "An identical established value MUST settle `succeeded`"; that identical-PTR success remains after its capability check.
````

### Q4-OLD

````text
A no-call success or defer returned
by that decision takes no capability check.
````

### Q4-ALT

````text
`OPS-41` says "the worker MUST make no provider call, settle the operation `succeeded`", "the claim MUST defer" and "The short deferrals in steps 3 and 4 are not settlements"; a no-call success or defer returned
by that decision takes no capability check.
````

### Q2-KEEP

````text
KEEP: no byte changes. The 01-domain-model.md:547-548 span stays exactly as landed at efb40cc55ff04be693473914afd42ef68008fa15. No thread exists for it; nothing is posted.
````

### Q3-KEEP

````text
KEEP: no byte changes. The 01-domain-model.md:560-561 span stays exactly as landed at efb40cc55ff04be693473914afd42ef68008fa15. No thread exists for it; nothing is posted.
````

### Q5-KEEP

````text
KEEP: no byte changes. The 01-domain-model.md:577 span stays exactly as landed at efb40cc55ff04be693473914afd42ef68008fa15. No thread exists for it; nothing is posted.
````

### R-NOTE-ALT

````text
Fix commit on branch pv-5pmu, in PR #69: (1) in 01-domain-model.md replace each settled Qn-OLD.txt span with its settled QUOTE or ALT bytes; a settled KEEP changes nothing; (2) in the text of pv-5pmu comment 856 in .beads/issues.jsonl replace the same spans with the same bytes, and on that comment's line 6 replace "with the 2026-10-31 Panel N r93 wording correction." with "with the 2026-10-31 Panel N r93 and 2026-11-03 Panel r99 wording corrections.", changing no other field, comment or bead; (3) append exactly the block below to docs/research/panels-2026-10/r86/r86b/Q1-A.md, all original bytes remaining an exact prefix; (4) archive the reviewed r99 record at docs/research/panels-2026-10/r99/. The archived r93 record stays unchanged. No branch or tracker edit occurs in this panel turn.
````

### R-NOTE-ALT-append (whole file, shown between the fences; it begins with two empty lines)

````text


## Wording correction — 2026-11-03 (Panel r99)

The form approved in owner item 16 and the 2026-10-31 Panel N r93 correction above are retained
with their bytes unchanged. Under the owner's 2026-10-28 wording rule (“For such wording questions,
try to solve by getting a consensus of the panel”), the landed `DOM-10` text and the pv-5pmu Agent
Brief use the exact replacements selected in the panel record below. This note grants no independent
authority to change a requirement; any substantive unresolved conflict returns to the owner.

Source pin: `efb40cc55ff04be693473914afd42ef68008fa15`.
Panel record: `../../r99/notes.md`.
````

In R-NOTE-ALT, "the block below" means `R-NOTE-ALT-append.md` (bound at `r99b/brief.md:329`).

## Exact locations at the pin

- `01-domain-model.md` (48940 bytes, SHA-256 `528fe5376d1f32e76ffb88f98176b63f7fbbe8aaaf5bfe4b6d8a6fe3aac6980a`): Q1 at line 575, Q4 at lines 565–566. Each OLD span occurs exactly once. Q2 (547–548), Q3 (560–561) and Q5 (577) stay unchanged.
- `.beads/issues.jsonl` (SHA-256 `3681f392d8a404391fade490186f86093c2ed13f8ea4b57d2305b14cd3dc0d64`): only physical line 15, bead pv-5pmu, `comments[0]`, comment id `856` (the Agent Brief; text 6584 bytes, equal to `evidence/pv-5pmu-comment-856.md`). In its decoded text: line 6 gets the authority-line replacement; Q4 at decoded lines 56–57 and Q1 at decoded line 66 get the same bytes as in `01-domain-model.md`. Q2 (decoded 38–39), Q3 (51–52) and Q5 (68) stay unchanged. Each OLD span and the line-6 substring occur exactly once. Re-encode the row with `json.dumps(obj, ensure_ascii=False, separators=(',', ':'))`: at the pin that reproduces line 15 byte for byte. If the base moves, re-resolve the pv-5pmu row.
- `docs/research/panels-2026-10/r86/r86b/Q1-A.md` (4824 bytes, 83 lines, SHA-256 `4cf03ef8c9a04dd8252c3dacfe2efb4d9eb69cc4232380edd4b422837b868881`, ends with LF): replace nothing; append the whole append file. All 4824 original bytes remain an exact prefix. Because the file ends with LF and the append starts with two LFs, two empty lines precede the new heading. Those are the settled bytes; keep them.

## Before/after: 01-domain-model.md (only Q1 and Q4 change)

Q4, line 565. Before:

````text
transaction decision run before this capability check. A no-call success or defer returned
````

After:

````text
transaction decision run before this capability check. `OPS-41` says "the worker MUST make no provider call, settle the operation `succeeded`", "the claim MUST defer" and "The short deferrals in steps 3 and 4 are not settlements"; a no-call success or defer returned
````

Line 566 (`by that decision takes no capability check. ...`) is unchanged; the Q4 span's second line is the same in Q4-OLD and Q4-ALT.

Q1, line 575. Before:

````text
checks rescue_ssh. PRV-25's identical-PTR success remains after its capability check. No
````

After:

````text
checks rescue_ssh. `PRV-25` says "After the ordinary authorization, capability and `API-16` validation" and "An identical established value MUST settle `succeeded`"; that identical-PTR success remains after its capability check. No
````

## Before/after: comment 856 decoded text (only line 6, Q4 and Q1 change)

Decoded line 6. Before:

````text
**Owner decision:** “Approve A (Recommended)” (`owner-decisions-1030.md`, item 16). Historical adopted form: `docs/research/panels-2026-10/r86/r86b/Q1-A.md`. Executable form: the Desired behavior / key interfaces block below, with the 2026-10-31 Panel N r93 wording correction.
````

After:

````text
**Owner decision:** “Approve A (Recommended)” (`owner-decisions-1030.md`, item 16). Historical adopted form: `docs/research/panels-2026-10/r86/r86b/Q1-A.md`. Executable form: the Desired behavior / key interfaces block below, with the 2026-10-31 Panel N r93 and 2026-11-03 Panel r99 wording corrections.
````

Decoded line 56 (Q4): before and after are exactly the 01-domain-model.md line 565 pair above. Decoded line 57 is unchanged.

Decoded line 66 (Q1): before and after are exactly the 01-domain-model.md line 575 pair above.

No other field of the row, no other comment and no other bead changes.

## R-NOTE-ALT steps (1)–(4) as exact operations (one fix commit on `pv-5pmu`, PR #69)

1. `01-domain-model.md`: replace the Q1-OLD span with the Q1-QUOTE span and the Q4-OLD span with the Q4-ALT span, once each. Q2, Q3 and Q5 are KEEP: no bytes change.
2. `.beads/issues.jsonl` line 15, pv-5pmu comment 856 `text`: the same two span replacements, plus on decoded line 6 replace `with the 2026-10-31 Panel N r93 wording correction.` with `with the 2026-10-31 Panel N r93 and 2026-11-03 Panel r99 wording corrections.`. Re-encode as above. Change nothing else.
3. `docs/research/panels-2026-10/r86/r86b/Q1-A.md`: `f.write_text(f.read_text() + append)`, with `append` the whole `r99b/forms/R-NOTE-ALT-append.md`.
4. Archive the reviewed record at `docs/research/panels-2026-10/r99/`. The append's link `../../r99/notes.md` resolves to `docs/research/panels-2026-10/r99/notes.md`, so `notes.md` (SHA-256 `14c98e411963fb6d60f4bb0d96fd6a9d70508b2abf353041c2ac6385a4b2b736`) must be in the commit. `notes.md` holds no selections, so the tally, this package and owner item 27's words sit next to it. Copy from `/var/tmp/provisiond-panel-r99/`, paths kept:
   - top level: `notes.md`, `notes.sha256`, `brief.md`, `brief.sha256`, `PIN`, `STATE.md`, `packet-manifest.json`, `forms.sha256`, every `Q1-*.txt` … `Q5-*.txt`, `R-NOTE.txt`, `R-NOTE-append.md`, `R-BRIEF.txt`, `R-ARCHIVE.txt`, the answers `fable.md`, `opus.md`, `astra.md`, `sol.md`, and `tally.md`, `settled-r99.md`, `settled-r99.md.sha256`, `owner-item27.md`;
   - `evidence/pv-5pmu-comment-856.md`;
   - `check/`: `base-DOM10-block.md`, `build.py`, `build.json`, `build_brief.py`, `sweep-diff.txt`, `prospective-*.md`, `trial.py`, `trial.json`, `trial-*.diff`, `trial-*.log`;
   - `r99b/`: `notes.md`, `notes.sha256`, `brief.md`, `brief.sha256`, `PIN`, `STATE.md`, `packet-manifest.json`, `owner-question.md`, `fable.md`, `opus.md`, `astra.md`, `sol.md`, `forms/*`, and from `r99b/check/`: `build.py`, `build.out`, `labels.json`, `trial-alt.py`, `trial-alt.json`, `trial-*.diff`, `trial-*.log`.
   Leave out: `prompts/`, `tmp/`, the reader home folders (`fable/`, `opus/`, `astra/`, `sol/`), every `*.err`, `*.out`, `*.exit`, `launch.sh`, `run-*.sh`, `*-systemctl-show.txt`, `quota-*`, `grok-preflight*`, `run-grok-preflight.sh`, `check/repo/`, `check/settled/` and `check/manager-brief.before-r99.md` (manager state; it holds the Robot server number). The two `STATE.md` files are launch snapshots; `tally.md` and owner item 27 supersede them (r99b's STATE says r99's Q4 was not voided; the tally and owner item 27 record it as voided, with r99b as the re-ask).

The archived r93 record stays unchanged. No gate reads `docs/research/` (every gate globs root `*.md`, and some `docs/adr/*.md`), so no gate checks the append or the archive; verify them by the hashes here.

## Prospective results at the pin (built and reversed to the pin bytes; in `/var/tmp/provisiond-panel-r99/check/settled/`, not archived)

| File | SHA-256 after | git blob after |
|---|---|---|
| `01-domain-model.md` (49259 bytes) | `0d73d23770a96a9cd4dec4f2973e4f16426bd0a214666301a011920e01e92aa4` | `c5b5c5f376fbaebc638fab73366e86da1bac47ae` |
| `.beads/issues.jsonl` (3460044 bytes) | `269d95fca054b610eb6d76d1c859b9df4a8b8e2459ffa315cd69bab33919c5de` | `af2b4ef4703bee6f14a3cc21a525d58da7fc92c2` |
| comment 856 text (6929 bytes) | `a04b809d371e7c10d4d38ac1cb9600565a3b5c6f1a3465b29ad3586296910e13` | — |
| `docs/research/panels-2026-10/r86/r86b/Q1-A.md` (5462 bytes) | `45db3ceeb76dc1974ce3a8f47ad1c366514d97df8a833aae9be80d41166f96c2` | `8fda2e8259f29b5c66c5dea8ab372651ff5f2fc0` |

The `01-domain-model.md` blob equals the post-image in `r99b/check/trial-A-Q4ALT.diff` (`76a761a..c5b5c5f`). The values hold only if the base is still `efb40cc`; otherwise re-resolve and recompute.

## Owner-route wording check

Every R-NOTE-ALT and append sentence was checked against Q2 being KEEP by owner item 27 rather than by the panel. No byte is literally wrong, so no wording changes:

- R-NOTE-ALT (1) "each settled Qn-OLD.txt span … a settled KEEP changes nothing": Q2 is settled (by the owner) and KEEP; true.
- R-NOTE-ALT (2) line-6 text "2026-11-03 Panel r99 wording corrections": the only corrections are Q1 and Q4, both panel-settled (Q4 in r99b, r99's consensus round, archived under `r99/r99b/`); true.
- Append "the exact replacements selected in the panel record below": the replacements are Q1-QUOTE and Q4-ALT, both selected by the panel; Q2 is not a replacement. The append makes no claim that the panel settled Q2; true.
- Append "any substantive unresolved conflict returns to the owner": consistent with the owner deciding Q2.
- Append "under the owner's 2026-10-28 wording rule": governs the panel-selected Q1 and Q4; true.

## Check the apply turn must repeat

1. Re-run the trial: `python3 -I /var/tmp/provisiond-panel-r99/r99b/check/trial-alt.py`, then confirm in `r99b/check/trial-alt.json` that `A-Q4ALT` has exit 0, "Markdown quoted attributions: 365 compared", and diff_sha256 `69968375a1c110f178df5b63080bbe39afa1c67998d256d11db182f475b8d6eb` (A-ALL and N-Q4ALT are rerun with it; N-Q4ALT must still fail naming OPS-41). At 14:28Z `trial-alt.json` is `bbf639cbae196d3535285b71a5ebdb03ed6c00caf7174fa96d00d149ceb63363`. Run this before copying `r99b/check/` into the archive.
2. In the fix-commit worktree, confirm `git rev-parse HEAD:01-domain-model.md` is `c5b5c5f376fbaebc638fab73366e86da1bac47ae` (base `efb40cc`), and the Q1-A.md and issues.jsonl values above.
3. The full gate, unpiped: `bash tools/check-all.sh > <log> 2>&1; echo $?`; it must print 0 and "All gates passed."

## Thread reply for 4450997798 (post after the fix commit lands and the gate passes; replace `<FIX-SHA>`)

````text
Fixed in `<FIX-SHA>`. The wording review for this PR settled the form: the sentence now quotes PRV-25 (`02-provider-contract.md:873-875`) and reads: `PRV-25` says "After the ordinary authorization, capability and `API-16` validation" and "An identical established value MUST settle `succeeded`"; that identical-PTR success remains after its capability check.

The review also swept the other DOM-10 sentences this PR adds for the same pattern. The OPS-41 sentence at `01-domain-model.md:565` now quotes OPS-41 as well; the other three stay as written. The approved text in the pv-5pmu Agent Brief (comment 856) gets the same two replacements, the correction is noted in `docs/research/panels-2026-10/r86/r86b/Q1-A.md`, and the review record is archived at `docs/research/panels-2026-10/r99/`. `tools/check-all.sh` passes on the fix commit. Resolving this thread.
````

The reply file is `/var/tmp/provisiond-panel-r99/check/settled/reply-4450997798.txt` (SHA-256 `350edc274afbd9d2d866ba7c8fdc6885aed7c2fe5a887a869366add843cc93f9`). Resolve the thread after posting.
