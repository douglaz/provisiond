# Seat opus: r99 answer

**Applying notes.md rule 6 exactly as written; this prompt adds no void rule.**

| Question | Final pick | Other options | Pick is wording-only? |
|---|---|---|---|
| Q1 | **Q1-QUOTE** | Q1-KEEP: CANNOT ACCEPT | Yes |
| Q2 | **Q2-QUOTE** | Q2-KEEP: ACCEPT | Yes |
| Q3 | **Q3-KEEP** | Q3-QUOTE: ACCEPT | Yes, no bytes change |
| Q4 | **Q4-ALT** (below) | Q4-QUOTE: ACCEPT; Q4-KEEP: CANNOT ACCEPT | Yes |
| Q5 | **Q5-KEEP** | Q5-QUOTE: CANNOT ACCEPT | Yes, no bytes change |
| Q-REC | **R-NOTE-ALT** (below) | R-NOTE: ACCEPT; R-BRIEF and R-ARCHIVE: CANNOT ACCEPT | Yes, record only |
| Q6 | Not opened | | |

Each pick is also ACCEPT from me. None of my CANNOT ACCEPTs is a rule 3 blocking loss: no printed option changes a checked verdict or a MUST. They are conflicts with `AGENTS.md` or with precedent.

**Main finding:** the brief's Q4 note is false, and I judge that it changes Q4's premise (details under Q4).

## Q1: `PRV-25` sentence
- **Reason:** "remains after its capability check" states `PRV-25`'s own ordering (`02-provider-contract.md:873`, `:875`). It is not a new `DOM-10` rule.
- **Precedent:** r93 replaced a sentence of the same shape, "A replay returned by API-7 step 5a never reaches this check". `r93/tally.md:25` says "The source facts being supported does not establish exemption from the quotation rule."
- **Against KEEP:**
    - Item 16 is no exemption, because r93 already corrected item-16 text under the wording rule (`r86b/Q1-A.md:63-65`).
    - r93's retained bytes were a scope limit (`r93/brief.md:231`) and a byte audit (`assertion-map.md:276`), not a ruling.
    - The posted reply already concedes the sentence restates `PRV-25` without quoting it.
- **Wording-only:** the quoted MUST stays attributed to `PRV-25`, and the sentence's claim is unchanged.

## Q2: `API-64` transaction
- **Reason:** the rule depends on one fact about `API-64`, that the state change and the enqueue form a single transaction.
    - It states that fact in a coined term: "state-change/enqueue" appears in no root requirement except `01-domain-model.md:547`.
    - `API-64`'s own words are at `04-api-contract.md:1116-1117`. The quote puts that fact in the gate's reach.
- **Why this differs from the unlisted names:** "restore claim gate" and "fence transaction" are `OPS-41`'s own terms (`03-operation-lifecycle.md:1113`, `:1099`).
- **Closest call of my picks:** the main predicate is `DOM-10`'s own, so I accept KEEP.

## Q3: "classified by OPS-11"
- **Reason:** this points at the owner (`AGENTS.md:34`) and states none of `OPS-11`'s content.
- **Against QUOTE:** the quoted lead never mentions a capability refusal, so the gate would check a string but not the claim.
    - It also says less than the source: before the write-started marker, power, reverse-DNS, delete and release MUST settle `failed` (`03-operation-lifecycle.md:250`), and this check runs before either marker (`01-domain-model.md:557`).
    - It is harmless, so I accept it.

## Q4: `OPS-41` no-call success or defer

### Brief error
The brief says "the defer comes from OPS-41's restore claim gate, not its fence-transaction decision" and "QUOTE carries OPS-41's words for each outcome". Both are false. The ordered decision (`03-operation-lifecycle.md:1099`) has its own outcomes that QUOTE does not quote:
- **Step 3:** "the worker MUST return the attempt to `queued`" (`:1122`).
- **Step 4:** "The claim defers" (`:1133`).
- **Both steps:** "The short deferrals in steps 3 and 4 are not settlements" (`:1153`).
- **Step 1, a no-call success:** "The worker makes no provider call and settles the attempt `succeeded`" (`:1104`).

The packet's source excerpts omit all of these. Q4-QUOTE's only defer quotation is the one `OPS-41` itself places outside this decision: "Step 1 and the restore claim gate above remain ahead of this decision" (`:1113`).

**Rule 6:** I judge that this changes Q4's premise, because the packet tells readers the quoted defer is the only one. If so, Q4's tally is void and Q4 should be re-asked with steps 1, 3 and 4 printed. Any Q4-QUOTE acceptance that relied on the note rests on this error. My picks do not.

### Pick: Q4-ALT
Replaces the `Q4-OLD.txt` span, `01-domain-model.md:565-566`:

`````text
`OPS-41` says "the worker MUST make no provider call, settle the operation `succeeded`", "the claim MUST defer" and "The short deferrals in steps 3 and 4 are not settlements"; a no-call success or defer returned
by that decision takes no capability check.
`````

The file is `tmp/opus/Q4-ALT.txt`, SHA-256 `c12991b321e6e9abc74e67dfebba3f16554ee8048ff09a0ca0895933614fa318`. This is a new form that no other reader has reviewed.

- **Why quote at all:** "returned by that decision" has the same shape as r93's "returned by API-7 step 5a", so I cannot accept KEEP.
- **Why I still accept Q4-QUOTE:** its words are real and every rule byte survives, so no behaviour changes. Only sentences that proceed to cancellation require the check (`01-domain-model.md:566-567`). Its defect is incomplete evidence.
- **Limits of the ALT:**
    - It does not quote step 1. Its no-call quotation is the abort that step 3 invokes.
    - It leaves "that decision" as landed. Changing that word would be a semantic change for the owner.

## Q5: methods `PRV-4` names
- **Reason:** the landed text is the form `AGENTS.md:40-43` and `:45-46` ask for: "every list or count names its source instead of restating it". `01-domain-model.md:516-517` already says "the ones `PRV-4` names".
- **Against QUOTE:** it writes "The three" and the whole list into `DOM-10`, breaking that clause to satisfy the quotation clause. The gate would catch later drift, so this is a rule conflict, not a blocking loss.

## Q-REC: how the record follows

### Why not the others
- **R-BRIEF:** owner item 25 rejected "Change the brief only" in the comparable case. It would also leave `r86b/Q1-A.md:65` false and uncorrected: "all other Q1-A text is retained".
- **R-ARCHIVE:** the closed bead's "Executable form" would differ from the landed text, and neither that comment nor `Q1-A.md` would point at r99.

### Why R-NOTE-ALT over R-NOTE
R-NOTE is acceptable and follows the right precedent, but it has three record defects:
1. Its note calls the r93-corrected text "the historical form approved in owner item 16". Item 16 approved only the original at pin `3109b5b`, and r93's correction came under the wording rule (`Q1-A.md:63-65`).
2. It leaves comment 856's line 6 naming only r93, though the block would then carry r99's changes too. The line 6 hash is identical in the prospective comment. r93's package updated this same line (`settled-pv-5pmu.md:11`, `:48`).
3. Its "Qn-QUOTE.txt bytes" cannot carry a settled ALT.

### Pick: R-NOTE-ALT
`````text
Fix commit on branch pv-5pmu, in PR #69: (1) in 01-domain-model.md replace each settled Qn-OLD.txt span with its settled QUOTE or ALT bytes; a settled KEEP changes nothing; (2) in the text of pv-5pmu comment 856 in .beads/issues.jsonl replace the same spans with the same bytes, and on that comment's line 6 replace "with the 2026-10-31 Panel N r93 wording correction." with "with the 2026-10-31 Panel N r93 and 2026-11-03 Panel r99 wording corrections.", changing no other field, comment or bead; (3) append exactly the block below to docs/research/panels-2026-10/r86/r86b/Q1-A.md, all original bytes remaining an exact prefix; (4) archive the reviewed r99 record at docs/research/panels-2026-10/r99/. The archived r93 record stays unchanged. No branch or tracker edit occurs in this panel turn.
`````

Appended block, which begins with two newlines (`tmp/opus/Q-REC-ALT-append.md`, SHA-256 `445f69c220bfcdefd455fb6447c2c5e93b76d16274a9c051e21b0423358b02ea`):

`````markdown


## Wording correction — 2026-11-03 (Panel r99)

The form approved in owner item 16 and the 2026-10-31 Panel N r93 correction above are retained
with their bytes unchanged. Under the owner's 2026-10-28 wording rule (“For such wording questions,
try to solve by getting a consensus of the panel”), the landed `DOM-10` text and the pv-5pmu Agent
Brief use the exact replacements selected in the panel record below. This note grants no independent
authority to change a requirement; any substantive unresolved conflict returns to the owner.

Source pin: `efb40cc55ff04be693473914afd42ef68008fa15`.
Panel record: `../../r99/notes.md`.
`````

The owner sentence is verified at `docs/adr/0023-a-restore-is-a-recovery-incident-and-durability-is-bought-where-there-is-no-second-truth.md:311` and `r93/brief.md:36`.

## Q6: not opened
`:570-571` is the closest unlisted case. "Retain their existing scope" states no content from either requirement, unlike Q1's "after its capability check".

## What I checked
**Packet checks:** all `forms.sha256` entries pass, and `brief.md` matches `brief.sha256`. Each Q1–Q5 OLD span occurs once in comment 856. The prospective `DOM-10` block differs from the pin only at the five spans. r93's quoted lines and the line citations I sampled match.

**Gates:** the packet's trial ran only the citation gate, so I ran the other Python gates on scratch clones outside the Nix shell. The three trees were the pin, all five QUOTE forms, and my picks (Q1-QUOTE, Q2-QUOTE, Q4-ALT).

| Gate | Result on all three trees |
|---|---|
| `check_ids`, `check_obligations`, `check_coverage` | Exit 0, output identical to the pin |
| `check_citations` | Exit 0; compared 360, 367 and 366 respectively, otherwise identical |
| `check_fixtures` | **Not verified:** exit 1 on all three, `markdown_it` is missing outside Nix |
| `check_regions` | **Not verified:** exit 2 on all three, needs `regions.jsonl` from lake |
| `check_formal` | **Not run:** fenced |

- **ALT checks:** corrupting the ALT's new quotation gave exit 1, naming `OPS-41`. The four gates that pass above also passed on my picks with the ALT note appended.
- **Inference, not a run:** the `DOM-10` block has no `<!-- formal` region and no `@[req "DOM-10"]` tag, so I expect the unrun formal and regions gates to be unaffected. The apply turn must still run the full `check-all.sh` under Nix.

**Other brief errors:** one, which does not change any premise. §2 labels its block `AGENTS.md:29-32` and `:45-46`, but it also prints `:34-43`.

**Fences:** I used the same read-only lake index as the trial (hash matches `trial.json`), plus the r93 record and `owner-decisions-1030.md`, and searched the manager folder only for the owner's sentence. I read no r99 reader outputs. My clone is still clean at the pin, and scratch stayed in `tmp/opus`.
