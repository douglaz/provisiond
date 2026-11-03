# Panel R r97: opus seat answer

I applied notes.md rule 6 exactly as written; this prompt adds no void rule.

## Final picks

| Question | Pick | Behavior | Item 4 / item 24 / C′ meaning | Check strength |
|---|---|---|---|---|
| Q1 | **R-MASTER**: the directive, the comment sentence and the placement together | WORDING-ONLY | WORDING-ONLY | WORDING-ONLY; PR60 is kept |
| Q2a | **Q-QUOTE** | WORDING-ONLY | WORDING-ONLY | WORDING-ONLY |
| Q2b | **Q-QUOTE** | WORDING-ONLY | WORDING-ONLY | WORDING-ONLY |
| Q2c | **Q-QUOTE** | WORDING-ONLY | WORDING-ONLY | WORDING-ONLY |
| Q2d | **Q-KEEP** (exemption shown below) | no change | no change | no change |
| Q2e | **Q-KEEP** (exemption shown below) | no change | no change | no change |
| Further sentences | none found that need a decision (inventory below) | — | — | — |
| Q3 | **S-OUT** | no change | no change | no change |
| Q4 | **L-BRIEF** | no source change | no change | no change |

This selection is exactly the assembled `run-R-MASTER-Q-QUOTE.md` (SHA-256 `56f7b5c3…`) and `comment-861-R-MASTER-Q-QUOTE.md` (`d66f194e…`). That is the same assembly the manager's citation-only trial covered (a/b/c quoted, d/e unchanged; `candidate-citations.exit` = 0). No full gate has been run on any assembled candidate; the Run still needs its own unpiped gates.

## ACCEPT / CANNOT ACCEPT for every printed candidate

| Candidate | Verdict | Reason |
|---|---|---|
| R-MASTER directive + comment sentence + placement | **ACCEPT** | — |
| R-PIN | **CANNOT ACCEPT** | It deletes the fixture item 7 adopted, and nothing authorizes that (Q1 below). |
| R-OWNER | **ACCEPT**, not preferred | It loses nothing but is unnecessary: no adoption's meaning is unsettled. |
| Q2a Q-QUOTE | **ACCEPT** | — |
| Q2a Q-POINTER | **CANNOT ACCEPT** | "gates the create's ordering capability" turns the identity "is `DOM-10`'s gate" into a different relation. |
| Q2a Q-KEEP | **CANNOT ACCEPT** | The step-location claims about API-7 and OPS-43 carry no quote. |
| Q2b Q-QUOTE | **ACCEPT** | — |
| Q2b Q-POINTER | **CANNOT ACCEPT** | It drops the historical contrast that "the wire contract wins" depends on, and keeps the miscapitalized quote. |
| Q2b Q-KEEP | **CANNOT ACCEPT** | The historical WIR-17 claim carries no quote. |
| Q2c Q-QUOTE | **ACCEPT** | — |
| Q2c Q-POINTER | **CANNOT ACCEPT** | "comparison owner" no longer says what is being compared. |
| Q2c Q-KEEP | **CANNOT ACCEPT** | "as `CNF-19` does" carries no quote. |
| Q2d Q-QUOTE | **CANNOT ACCEPT** | The quote doesn't show "top-level", and it is attached after the allow-ordering clause, so it reads as WIR-17 being the authority for account configuration. |
| Q2d Q-POINTER | **ACCEPT**, not preferred | Meaning-equivalent, but no improvement in compliance. |
| Q2d Q-KEEP | **ACCEPT** | — |
| Q2e Q-QUOTE | **CANNOT ACCEPT** | Same misplacement, after `(PRV-10)`. Combined with Q2b Q-QUOTE it would also put the literal-true MUST into API-15 twice. |
| Q2e Q-POINTER | **ACCEPT**, not preferred | — |
| Q2e Q-KEEP | **ACCEPT** | — |
| S-OUT | **ACCEPT** | — |
| S-BEAD | **CANNOT ACCEPT** | I found no traced gap of the qualifying kind. |
| S-FIX | **CANNOT ACCEPT** | No owner authority exists to edit text C′ expressly retains. |
| L-BRIEF | **ACCEPT** | — |
| L-NOTE (+ append) | **ACCEPT**, not preferred | Costs are under Q4. |
| authority-replacement.txt | **ACCEPT** | — |

## Q1: why R-MASTER

**Retained blocks, checked independently** by locating each block's pinned bytes in master (`tmp/opus/blocks.py`):
- **Byte-identical, contiguous, unmoved:** CNF-18 (line 124) and CNF-19 (line 137).
- **Byte-identical, contiguous, moved:**
  - WIR-17 field rules opening: 665 → 683
  - CNF-182: 2371 → 2484
  - CNF-342 acknowledgement paragraph: 4311 → 4476. PR57 (a7b6884) added a separate paragraph immediately after it, outside the retained bytes.
  - CNF-344: 4358 → 4531
- **CNF-34 is the only one that is not contiguous.** Its pinned 24 lines no longer occur as one block. The diff from the pin to master is exactly the 15-line insertion shown in the brief, and every original line is still there in order. It matches `git show 8dd8f48`. Every inserted line appears in `/var/tmp/provisiond-panel-r85/brief.md`.
- **Replace anchors:** each pinned block occurs exactly once in master. API-15 moved 987 → 1032 and CNF-55 moved 340 → 355; the rest are unmoved.
- **The scope gap is still open:** the five old scope phrases ("bill per order", "bills on order", "order-billed", "per ordering account", "opt-in ordering") still occur only at the sites C′ replaces. No new alias has appeared since the pin.

**PR60's assertions, read against the complete inserted text:**
- **Stored acknowledgement:** destructive acknowledgement present but false in the stored request, after admission with a valid true value.
- **Starting state:** ordinary trusted marker provenance (`restore_markers_untrusted` false) and initially null marker columns.
- **Ordering:** the repeated validation completes before either marker write.
- **Expected outcome:** `invalid_request`, field `/acknowledge_destruction`, not retryable on both the error and the operation view; `failed`; no driver call; both markers still null; `disk_effect` none and `rescue_exit` none.
- **Negative case:** a proposed execution that writes the rescue marker before validating violates the required ordering even though dispatch hasn't happened. Clearing the marker or synthesizing `rescue_exit` none from false may not be used to make it pass.
- **Conditional arm:** a present-but-invalid api-written install field applies only if the release names one; no such field is invented.
- **Positive control:** the complete-record control proceeds past validation.

Under R-MASTER all of these stay in CNF-34 at master lines 273–287.

**Why R-MASTER is a wording-only settlement:**
1. **Retention means "not an edit".** `r89/brief.md:44` says: "An item marked Retain verbatim is part of that exact candidate and is intentionally not an edit". At the pin, "not an edit" and "pinned bytes" meant the same thing. At master, only R-MASTER still means "not an edit"; R-PIN requires an edit, a deletion.
2. **The owner's relay anticipated concurrent changes.** Item 24 names it as the owner relay, and `r89b/owner-questions.md:20` says: "The implementation agent must read the then-current owners and reconcile any concurrent changes before applying the approved blocks."
3. **Item 24 never touched PR60's fixture.** It adopted C′ at 3109b5b, before PR60 existed. Item 7 adopted that fixture "exactly". Restoring the pin would remove a negative control and its assertions, which is a substantive loss in check strength.
4. **C′'s protections survive.** The create domain C′ retained ("On separate creates", CNF-34 line 257; "complete, valid resource-offer", CNF-342 line 4477) is unchanged. The unconditional WIR-17 MUST (lines 683–684) is unchanged.

So no adoption's meaning conflicts, and R-OWNER isn't needed.

**Does the record support the brief's framing of r89?** Yes, with one qualification. The r89 tally says "C has the numeric majority, but the rule-3 condition is held over the verified conditional-wire/worker-fixture narrowing". `r89b/tally.md` says "That is why A–D were held under rule 3 despite r89's numerical C majority. C′ retains the protection." The qualification: Form C already contained the hourly block (the r89b tally says C′'s "other blocks match C exactly"). "Added the hourly block" is true relative to the pin, not relative to C.

**Strongest contrary argument (for R-OWNER, not a vote):** the owner approved "exactly" a form saying "at their pinned bytes", and was told the blocks "remain byte-identical to the pin". The panel can't make that statement true at master. My answer: that sentence was evidence that the create domain was not narrowed, which still holds. It stays in comment 861, labeled as historical, and no reading of item 24 authorizes deleting what item 7 adopted.

## Q2: per sentence

**A fact the brief doesn't state:** all five target sentences are wording inherited from the pin inside Replace payloads. A word-level diff of every Replace payload against the pin (`tmp/opus/repdiff.py`) shows that inside PRV-10 and API-15, C′ changed only the scope phrases ("paid create (`DOM-16`)"); PRV-10 was also reflowed. CNF-364 changed only by adding the explicit `allow_orders: true` / acknowledgement setup. So Q-KEEP introduces no new violation compared with master, but the Run rewrites these whole paragraphs. That is why I treat Replace payloads as the package's own text and Retain blocks as not.

**Quote bytes.** Every quoted payload is an exact raw substring at its stated revision, with the source's line breaks and indentation:
- DOM-10 at line 515: 103 B
- API-7 step 5d at line 241: 135 B
- OPS-43 step 3 at line 797: 571 B
- CNF-19 at line 137: 204 B
- WIR-17 at line 683: 67 B
- At 7116e90: API-15 at line 919 (123 B), WIR-17 literal-true at line 506 (67 B), and the create body at line 490 (403 B). That JSON body no longer exists at master, so it is evidence only under its revision label.

**Q2a: where each assertion survives.**
- The configuration half and the ordering-capability identity: "The configuration half is `DOM-10`'s gate on the create's ordering capability (`DOM-16`)", kept word for word.
- DOM-10 as owner: that possessive, plus the DOM-10 quote.
- Admission: "At admission, step 5d is the gate: `API-7` says “**gate a create on its ordering capability**…”".
- Claim: "At claim, step 3 is the gate: `OPS-43` says “Repeat boundary validation… then the capability gate”".
- The OPS-43 consumer quotes of PRV-10 ("explicit purchase acknowledgement", "the account is configured to allow ordering") still match PRV-10's body.

**Q2b: why revision 7116e90 establishes the history.** 7116e90 (2026-09-05 06:11Z) is the parent of b278433, the commit that removed "in its provider options" and added this italic note. `git log -S` shows that wording ran from the first commit until b278433. At 7116e90, WIR-17's create body has `"acknowledge_purchase": true` at the top level next to `"provider_options": {}`. A present-day rule alone could not show that.
- Old provider-options wording: now in API-15's actual words. The current "In its provider options" is miscapitalized; the original was lowercase.
- Historical top-level location: the quoted create body.
- Wire precedence: "The wire contract wins".
- Driver-private rationale: kept word for word.
- One scoping change: WIR-17's placement is now stated "at that same revision" rather than over the whole period. This is non-normative history, and accurate.
- Q-POINTER loses the stated contrast, so I count it as a loss, not a pointer.

**Q2c: where each assertion survives.** The queued/unclaimed restart, removal of only `list_offers`, the ordering capability kept declared, the driver's answering code path, "so the test proves the gate exists" and "as `CNF-19` does" all stay word for word. The CNF-19 quote is added as evidence. The CNF-19 quote's six-space indentation matches CNF-364's list item.

**Q2d/e: why Q-KEEP is justified here.** Each sentence states the package's own rule (the paid-create MUST and "Both, not either"; API-15's carry MUST). "`WIR-17`'s top-level `acknowledge_purchase`" is a noun-phrase pointer that identifies a field by its owner. It is what AGENTS "Cite the owner … everywhere else points at it" asks for, and anyone can check it by following it to the current owner. It isn't a statement of what WIR-17 requires. Q2b differs: it states what WIR-17 did, in the past, which no current text can confirm. Q-POINTER gains nothing, because "top-level `acknowledge_purchase`; wire owner: `WIR-17`" states the same content. Under Q-KEEP, paid-create coverage, the explicit acknowledgement, top-level location, wire ownership, both authorizations and API-15's "in addition to" are all unchanged.

**Strongest contrary arguments (not votes):**
- *For Q2a Q-POINTER:* about 800 B of copied text from other requirements turns into upkeep work. My answer: the citation gate makes drift visible instead of silent.
- *For Q2b Q-KEEP:* an old JSON object looks like a fixture. My answer: it is outside a code span and pinned to a revision.
- *For Q2d/e Q-QUOTE:* "top-level" is content. My answer: the supplied quote doesn't prove it.

## Inventory of every summary in C′'s replacement payloads

Comment line = C′ line + 54.

- **Unquoted statements about another requirement's content (predication):**
  - Q2a: C′ 26–27 / comment 80–81
  - Q2b: C′ 35–38 / comment 89–92; comment 41 is the historical copy and stays unchanged
  - Q2c: C′ 212–214 / comment 266–268
- **Owner pointers, no change needed:**
  - Q2d (C′ 24–25) and Q2e (C′ 34–35)
  - DOM-16's `PRV-44` (C′ 14) and `API-15` (C′ 17)
  - API-15's `(PRV-10)` (C′ 35)
  - The `DOM-16` definition pointers at C′ 23, 33, 44, 50, 56 and 124
  - Hourly block "withheld under `PRV-13b` or `PRV-31`" (C′ 150). Accurate: PRV-31 says "MUST NOT be sold on prepaid terms". It sits inside the hourly block item 24 explicitly approved.
- **Step locators inside the package's own test instructions (not reports of another requirement):** C′ 127–128, 136, 152, 164, 170 and 215.
- **Owner lists:** C′ 140–141, 173 and 220–221. **Same-item amendment history:** C′ 175 and 222.
- **New rules of this package:** the DOM-16 definition, "Both, not either", the hourly block, and CNF-364's added authorizations.
- **Inherited Retain blocks, which pv-9ecf doesn't write:**
  - CNF-18 at C′ 74 and 79 (Q3)
  - CNF-182 at C′ 182–183: "`PRV-10`'s `allow_orders`". PRV-10's body doesn't contain `allow_orders`; DOM-16 owns the flag. Wording only, no gap.
  - CNF-344's PRV-5 alarm sentence at C′ 231
  - The existing quotes in CNF-34 and CNF-342. CNF-34 quotes WIR-17 as "literal `true`" on one line where the source breaks the line: an inherited reflow, not a raw-byte match.
- **Unchanged historical text:** the Current behavior fences (raw-equal to the pin), the provenance quotes and the Drift facts table.

## Q3: S-OUT

Both CNF-18 statements are accurate at master. CNF-20 does cover `PRV-2`'s three exceptions, and CNF-19/CNF-55 do cover the gate. C′ keeps them, and item 24 adopted it exactly. A Retain block is not written by the Run, so editing it needs owner authority that doesn't exist. Wording alone gets no bead. S-OUT's reference to the 18:40Z ruling only holds if "added/changed text" is read at block level. Read word by word, it would exempt Q2a–e too, which the brief rejects.

## Q4: L-BRIEF

L-BRIEF keeps the approval record honest:
- Both archived C′ copies stay byte-identical to their receipts.
- Comment 861's relabeled heading and authority line separate the original approval from the later executable wording.
- The archived r97 record holds the selections.

L-NOTE has two costs:
- It appends to `r89/check/tally/form-Cprime.md`, the copy whose hash r89's `check/tally/verification.json` records as C′'s SHA-256, and which `r89b/check/validate.py` asserts is equal to the adopted copy. The original bytes do survive as a prefix (I verified this).
- Readers following item 24's or comment 861's citation of `r89b/form-Cprime.md` never see the note.

Its link `../../../r97/notes.md` also points at the rules file, not at the selections. The strongest case for L-NOTE is the r95/r96 precedent. I need no sidecar note.

## What I checked for loss

Nothing is weakened by my selection:
- PR60's install-marker fixture
- The unconditional WIR-17 acknowledgement
- The broad CNF-34 and CNF-342 create domains
- Every CNF-55 hourly assertion
- CNF-55's resource-offer exclusion, low-balance, replay and worker checks
- Both authorizations
- CNF-364's negative List offers gate

Nothing beyond items 4 and 24 is added; the quotations are evidence, not new runtime obligations. No Lean file, proof, guard, gate or negative control changes.

## Brief errors (rule 6)

None of these changes a question's premise, so nothing is voided. None of my votes rests on any of them.
1. The brief says the drift records are "explicitly labeled as historical". In the assembled comments, the Drift facts prose ("freshly fetched base", CNF-34 "None") is unchanged and dated only by its 832a219 column. The current retention table exists only as panel evidence, not in comment 861. The R-MASTER directive overrides it, so this doesn't block.
2. "Explicitly added the hourly block" is true relative to the pin; Form C had the same block.
3. Comment 861 line 298, and therefore R-MASTER-comment-placement, quotes `owner-questions.md:28` with the external file's `consistency/…` link. The archived file at that cited path has the GitHub permalink, so the quote is not a raw-byte match. I have not fixed it.
4. The manager's stop-report CNF-34 diff ends with an extra blank "+" line. That comes from how the span was selected, not from a content change.

## Process notes

I wrote only under `tmp/opus/` and changed no source, Git ref, tracker record or panel record. I ran `git status` and `git diff --stat` inside the manager's disposable `check/candidate-trial` clone. That may have refreshed its index stat cache; no content changed.
