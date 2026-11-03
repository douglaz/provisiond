# Panel r100 — pv-e45e's adopted Q2-A-cited text against "Quote the sentence"

Pin: `2cb8e1189310ae096e598bac798df3437be59500` (master; local branch `pv-e45e` is at the same commit, with no commits of its own). Your
clone is detached at it. Read every source with `git show 2cb8e1189310ae096e598bac798df3437be59500:<path>` in your clone and check the
bytes yourself. Source blocks below were sliced from those bytes by `check/build_brief.py`; form
blocks are the form files' bytes. Read `notes.md` first.

**apply notes.md rule 6 exactly as written; this prompt adds no void rule.**

Owner's settling rule, verbatim: "a question is settled when at least three agree and more agree than
disagree, and a tie comes to you. If grok is down, it falls back to three of four".

## 1. The story in plain terms

On 2026-10-30 the owner decided pv-e45e's design question, "may one account sell both VMs and physical
servers?", with "A: yes, kind per offer" (owner item 17). That adopts exactly the text of
`docs/research/panels-2026-10/r86/r86b/Q2-A-cited.md` (the r86b form "Q2-A-cited"), as pv-e45e's brief: it rewrites `API-7` step 5d, the
rich-purchase tail's opening, `OPS-43` steps 3 and 5, and adds sentences to `OPS-23`, the
`05-persistence.md` `request_summary` row, `STO-50`, `CNF-55`, `CNF-19` and four Lean docstrings in
`tools/formal/Provisiond/Admission.lean`. pv-e45e's Agent Brief comment 857 carries the same blocks.

On 2026-11-03 the owner settled how a related `PRV-10` quotation reaches the Run (owner item 26, "Run
instruction carries the edit"): no preparation commit, comment 857 is not edited, and the Run
instruction quotes the r98 route text and `check/F-QUOTE.txt` verbatim.

At 15:50Z the same day, the manager launching pv-e45e's Run stopped at its pre-Run quote check. Some
adopted sentences assert what another requirement says without that requirement's words, against
`AGENTS.md:29-30` and its completion line `:45-46` (§2). The Run's reviewers would very likely flag
them, as a review bot flagged the same shape on PR #69 (panel r99). Under the owner's 2026-10-28
wording rule ("For such wording questions, try to solve by getting a consensus of the panel"), a
wording-only touch on adopted text gets panel consensus first and goes to the owner only when there is
no consensus.

So the Run's review does not surface another sentence later, the manager swept everything the Run
would write (§3) and lists seven sentences. For each, this panel decides whether to quote (QUOTE),
leave it as adopted (KEEP), or use a complete exact alternative; Q4 also has a byte-identical ASIS.
Q-ROUTE asks how any change reaches the Run and the record. Part of your job is to say whether each
option really is wording-only.

## 2. The rule, and what the gate checks

`AGENTS.md:29-46` at the pin, verbatim:

`````text
**Quote the sentence.** A claim about what another requirement says carries that requirement's own
words. `` `WIR-30` says "The gate reads the copy the machine took at create" `` is checkable;
"`WIR-30` forbids resolving eligibility that way" is an assertion, and assertions of that shape were
false repeatedly on 2026-09-03 — `ddd3df0` and `254fc24` carry the cases and what each one cost.

**Cite the owner.** One rule, one home; everywhere else points at it.
`07-security-requirements.md`'s scope note holds the argument, and `SEC-46` is the standing example
of a second copy drifting until an amendment shipped claiming to have applied while the requirement
said the opposite. **Arguments have owners too** — re-explaining a rule in a second document is how
a second normative copy gets written, because you cannot explain a rule without restating it.

**Cite the list; let it hold the number.** A count written into prose is wrong the first time either
end moves. `ADR-0003`'s footnote, `ADR-0011` and `F16` in `11-open-findings.md` each record their
own version of this. The same applies to a universal: one counterexample retires it, and
`OVR-17` carried a false one for weeks.

**Completion:** every sentence asserting what another requirement says carries its quote, and every
list or count names its source instead of restating it.
`````

The citation gate (`tools/check_citations.py`) checks a quotation only in these shapes, with the ID in
backticks: `` `ID` says/said/states/stated/reads/read "…" ``, `` `ID`'s <rule|claim|wording|statement|sentence|words|text> that "…" ``,
`` `ID`'s "…" `` and `` `ID`: "…" ``; only quotations of four or more normalized words; and in Lean
docstrings the EXISTS rule (every quoted string must exist somewhere in the corpus). The first speech
attribution in a sentence owns every later quotation in that sentence. Summary verbs are outside its
reach by design. It scans only root `*.md` (`tools/check_citations.py:642`) and `docs/adr/*.md`
(`:645`), plus the Lean docstrings, so `docs/research/` is outside it. Most IDs in the adopted text
are written without backticks (e.g. "OPS-43 step 5", "API-7", "CNF-55"), so those mentions are
outside the gate's reach whatever they say. Every QUOTE form below uses the backticked shape so that
the gate checks it against the text as it would stand after the Run (§9).

Note that several QUOTE forms quote the adopted new `API-7` step 5d or `OPS-43` step 5, which exist
only once the Run lands them; the trial applies the whole adopted package first and then checks.

## 3. The sweep

Swept whole: `docs/research/panels-2026-10/r86/r86b/Q2-A-cited.md` at the pin (SHA-256 `d611bbae87294a0fc0087c567fa82aa1404cd0c5a54abe394b5327488ec51ea2`,
159 lines, byte-equal to the r86b record and to `evidence/Q2-A-cited.md`), comment 857
(`evidence/pv-e45e-comment-857.md`, SHA-256 `9fa9dba3f79b051bc5f09a8d3f6a5a8bf6a08ca308db0ec0ebd812fd8f5823e1`, byte-equal to
the comment's `text` in `.beads/issues.jsonl` at the pin; its 20 text blocks are Q2-A-cited's blocks
plus the current-text blocks; line map: Q2-A-cited `:N` is comment 857 `:N+26` up to `:70` and
`:N+29` after), and the PRV-10 form `check/F-QUOTE.txt` (SHA-256 `2393f71eef02a593e37ca93d6dc4bd441bfc928a0bbeff4e9939e43a34bf2323`, byte-equal to
`/var/tmp/provisiond-panel-r98/check/F-QUOTE.txt`). Every sentence of every block the Run writes was
asked: does it assert what another requirement (by ID, or a step of one) says? If so, does it carry
that requirement's own words? The manager's record is `check/sweep.txt`.

The adopted text, whole, verbatim (`docs/research/panels-2026-10/r86/r86b/Q2-A-cited.md` at the pin):

`````markdown
### Complete candidate Q2-A-cited — read the admission snapshot early and retain the kind

Replace `API-7` step 5d with exactly:

```text
5d. For create, open the existing LDG-35 admission transaction and read the provider account's
    stored offer listing in the same read-only snapshot the rich purchase tail will use,
    regardless of listing age; no stored listing means an empty offers set. If the named
    offer is present, take its kind and gate on DOM-10's matching ordering capability using
    the descriptor api runs with. A capability refusal stops here and is not collected by
    the tail. If the offer is absent, run no ordering-capability check and infer no kind from
    the provider account, capability set, offer-id spelling or caller input; continue to the
    ordinary tail's absent-offer verdict. No provider call or admission write is made here.
    On admission, retain the named offer's kind as machine_kind in the create's
    request_summary offer snapshot in the same transaction as the operation and commitment.
```

Replace the rich-purchase tail's opening (from "**Rich purchase tails" through "no listing is stored.") with exactly:

```text
**Rich purchase tails (create and extend-runway only; amended 2026-10-04, ADR-0030).**
After steps 1–5d, the tail MUST collect every applicable refusal once, from one read-only
snapshot inside the existing LDG-35 transaction, without an extra lock, ceiling slot, write
or provider call. For create this is the same transaction and snapshot opened at step 5d;
the tail uses the same stored offer listing and named-offer lookup and prices the commitment
and takes the offer snapshot from them. For extend-runway the transaction and snapshot
are opened for the tail as before.
```

Keep the immediately following age-refusal sentence and remaining tail verbatim. An absent named offer therefore takes the already-quoted collected unsellable refusal; an unhealthy account can still be its headline. A present named offer's capability refusal remains before the tail, including when that stored listing is old. No age check moves to 5d.

Replace `OPS-43` step 3 with exactly:

```text
3. Repeat boundary validation under `OPS-23`: "Validation that was performed at the API boundary
   MUST be repeated in the worker before the driver is called". This includes `PRV-10`'s
   "explicit purchase acknowledgement", `PRV-8`'s "at least one SSH public key", and the
   missing-field checks in `OPS-23`. Validate `request_summary`'s `machine_kind` as `virtual`
   or `bare_metal`. The `api` writes `machine_kind` at admission; for missing or invalid
   fields, see `OPS-23`. Check caller-supplied fields first, then api-written admission
   fields, then gate on `DOM-10`'s matching ordering capability selected by that persisted
   `machine_kind`, using the descriptor the worker runs with. No current offer read supplies
   this gate.
```

Replace `OPS-43` step 5 with exactly:

```text
5. Check for the named offer's absence from that result, applying the create-tail verdict
   quoted above. If present but its kind differs from request_summary's machine_kind,
   settle failed with invalid_request, details.reason: "offer_not_sellable" and
   retryable: false on both the error and the operation view, before any provider mutation;
   do not substitute the current kind or its capability. Otherwise re-test the named offer
   for sale on that result and the running descriptor. An absent offer or kind mismatch
   gets no price comparison, per-order key upload or order request; the same existing
   pre-step-9 settlement releases the commitment and any resource-offer exclusion.
```

In `OPS-23`, insert after its paragraph defining the claim-time absence/sale-retest exception:

```text
The offer-kind consistency check at OPS-43 step 5 uses the same exception: it runs on
step 4's current List offers result, after that read and before any provider mutation.
```

In the `operations.request_summary` row of `05-persistence.md`, replace the exact words "the **offer snapshot** (`offer_id`, the offer's `install_strategies` as accepted," with:

```text
the **offer snapshot** (`offer_id`, `machine_kind` (`virtual` or `bare_metal`, copied from the
named offer at admission under API-7), the offer's `install_strategies` as accepted,
```

In `STO-50`'s "For a create" bullet, append this exact sentence:

```text
The enumerated offer snapshot includes machine_kind as defined on the request_summary row.
```

In `CNF-55`, insert immediately after its opening sentence (ending "account-level opt-in."):

```text
For the ordering-capability refusals below, the stored listing contains the named offer
with its explicit kind; run the admission refusal on both a fresh and an old listing.
The admitted create's request_summary retains that kind as machine_kind.
```

Append to `CNF-19`, after its current first sentence:

```text
Use one account whose stored listing contains both a virtual offer and a bare_metal offer.
With only provision_virtual declared, assert that a create of the bare_metal offer refuses
at API-7 step 5d naming provision_bare_metal, and that the virtual offer passes that gate;
reverse the declared provisioning capability and assert the converse. When the named offer
is absent, assert no guessed ordering-capability refusal: run the normal collected tail,
with an unhealthy-account refusal ahead of offer_not_sellable when both apply, no cap or
balance check, and no admission provider call. Repeat with no stored listing. For a present
named offer, assert a capability refusal before tail collection whatever listing age; with
its capability declared, the stored listing older than the stated offer-listing age, and no
collected refusal, assert the existing stale-listing refusal.
Admit with a fresh named offer, then remove the matching ordering capability before claim:
assert the CNF-55 pre-List-offers refusal using the retained machine_kind. Separately omit
or corrupt that api-written field and assert OPS-23's incomplete_record result, before any
provider request. With valid retained kind and capabilities, return a live offer of the
opposite kind at OPS-43 step 4; assert step 5's kind-mismatch refusal, no price comparison or
provider mutation, full commitment release and release of any resource-offer exclusion.
With the live offer absent, assert the existing absent-offer refusal after the list read.
```

The first instruction above refers to `CNF-19`'s sentence as quoted in the evidence; insert after the complete existing checklist item's sentence. These are proposed changes to the test's fixtures and assertions, not claims that the old test already proves the kind source. In particular, Q2-A explicitly qualifies `CNF-55`'s capability-refusal fixture by named-offer presence and introduces an absent-offer skip at step 5d; flag the observable precedence change and assess it rather than claiming every old refusal is preserved. It does not change the stored-listing header default. No caller `kind` field is added, and the snapshot retains no new customer secret.


Additionally perform all the following exact Lean docstring substitutions:

Line 19, replace:
```text
`API-7` says "A refusal stops here and is not collected by the tail."
```
with:
```text
`API-7` says "A capability refusal stops here and is not collected by the tail."
```

Lines 317–319, replace:
```text
`orderingCapabilityGuard` (`API-7`, 2026-10-22, `pv-p3k`): `API-7` says
"**gate a create on its ordering capability**". Off, a create without that declaration reaches
the purchase tail.
```
with:
```text
`orderingCapabilityGuard` (`API-7`, 2026-10-22, `pv-p3k`; step 5d reworded 2026-10-30,
`pv-e45e`): step 5d gates a create on the ordering capability selected by the named offer's kind
in the stored listing, and takes no gate for an offer absent from it. Off, a create without that
declaration reaches the purchase tail.
```

Lines 1181–1182, replace:
```text
whether the account declares the create's ordering capability. Machine-kind selection and
descriptor construction are outside this model.
```
with:
```text
whether the account declares the ordering capability selected by the named offer's kind in the
stored listing; for an offer absent from that listing step 5d takes no gate and the Boolean is
supplied `true`. Offer-kind selection and descriptor construction are outside this model.
```

Lines 1205–1206, replace:
```text
`API-7`: "On create, the tail reads the stored listing regardless of age, or an empty offers set
if no listing is stored." The supplied sale verdict
```
with:
```text
`API-7`'s step 5d reads the stored listing "regardless of listing age; no stored listing means an
empty offers set". The supplied sale verdict
```

`````

**Listed (asked as Q1–Q7).**

- Q1 `Q2-A-cited.md:62-63` — the `OPS-23` insert: "The offer-kind consistency check at OPS-43 step 5 uses the same exception: it runs on step 4's current List offers result, after that read and before any provider mutation." Restates where `OPS-43` steps 4 and 5 run, without their words.
- Q2 `Q2-A-cited.md:131-134` — the `Admission.lean:317-319` docstring: "step 5d gates a create on the ordering capability selected by the named offer's kind in the stored listing, and takes no gate for an offer absent from it." Paraphrases `API-7` step 5d, and replaces a quotation already in the file (`"**gate a create on its ordering capability**"`).
- Q3 `Q2-A-cited.md:144-146` — the `Admission.lean:1181-1182` docstring: "for an offer absent from that listing step 5d takes no gate". Paraphrases step 5d's absent-offer branch. Its first clause (what the model's Boolean answers) is model semantics and is not listed.
- Q4 `Q2-A-cited.md:69-70` — the `05-persistence.md:523` `request_summary` row: "copied from the named offer at admission under API-7". Borderline: the same shape as r99's Q2, which the owner kept (item 27). Also: the adopted block's line break after "copied from the" lands inside the one-line Markdown table row and splits it (Q4 below).
- Q5 `Q2-A-cited.md:39` (span `:39-43`) — `OPS-43` step 3: "The `api` writes `machine_kind` at admission". Borderline: it names no requirement, but restates what `API-7` step 5d's last sentence requires.
- Q6 `Q2-A-cited.md:55-56` — `OPS-43` step 5's last clause: "the same existing pre-step-9 settlement releases the commitment and any resource-offer exclusion." Asserts what `OPS-11`'s pre-step-9 settlement does; landed `OPS-43` steps 1 and 8 (`03-operation-lifecycle.md:790`, `:819`) quote `OPS-11` for the same release claim.
- Q7 `Q2-A-cited.md:101` — the `CNF-19` addition: "assert the CNF-55 pre-List-offers refusal using the retained machine_kind." Borderline: a test directive, but it characterizes where `CNF-55`'s refusal happens ("pre-List-offers") without `CNF-55`'s words.

The launch manager's five (`/var/tmp/provisiond-manager/dr-e45e-check/sweep.txt`) are Q1, Q2, Q3 (its
F1–F3) and Q4, Q5 (its B1, B2), all confirmed; Q4 is extended by the row split. Q6 and Q7 are new.

**Considered and not listed** (the manager reads each as a pointer, a name, the requirement's own rule,
a test directive naming which refusal to assert, or already quoted; any reader who disagrees may open
Q8 with a complete exact ALT naming its span):

- `:6` "open the existing LDG-35 admission transaction"; `:22-23` "inside the existing LDG-35 transaction" — name the transaction; the sentence is `API-7`'s own rule.
- `:9` and `:41` "gate on DOM-10's matching ordering capability" — names the gate; the sentence is the step's own rule.
- `:22` "After steps 1–5d", `:24`, `:30` — `API-7`'s references to its own step.
- `:35-37` step 3 opening — carries `OPS-23`, `PRV-10` and `PRV-8` quotations (the r86b "-cited" restoration).
- `:38` "the missing-field checks in `OPS-23`" and `:39-40` "for missing or invalid fields, see `OPS-23`" — pointers (the pin already has "missing-field checks defined in `OPS-23`", `03-operation-lifecycle.md:799-800`).
- `:50-52` `details.reason: "offer_not_sellable"` — a value literal, not a quotation.
- `:76` `STO-50` "as defined on the request_summary row" — a pointer.
- `:82-84` the `CNF-55` fixture sentences — `CNF-55`'s own text.
- `:90-99`, `:100`, `:102-106` `CNF-19` directives: `:92` "refuses at API-7 step 5d naming provision_bare_metal", `:94-95` "the normal collected tail", `:99` "the existing stale-listing refusal", `:102` "OPS-23's incomplete_record result" (`OPS-23`'s own term, `03-operation-lifecycle.md:2052`), `:104` "OPS-43 step 4" and "step 5's kind-mismatch refusal", `:106` "the existing absent-offer refusal" — directives naming which refusal to assert. Q7 is listed because it also characterizes the cited refusal's placement.
- `:120` (Lean line 19) and `:156-157` (Lean line 1205) — carry quotations.
- `:133-134` "Off, a create without that declaration reaches the purchase tail." — model flag semantics, unchanged landed words.
- `:144` the first clause of the Lean line-1181 docstring — model semantics.
- `check/F-QUOTE.txt` — every added span is a quotation of the new steps. Under Q5-QUOTE it is regenerated by r98's rule as `check/F-QUOTE-Q5.txt` (Q5).

**Pre-existing, out of scope (reported, not asked):** the landed `OPS-23` paragraph quotes step 4 as
"Obtain the current driver List offers result" (`03-operation-lifecycle.md:2078`) while step 4 at
`:803` reads "obtain"; the Run does not touch it. The adopted tail opening (`:21`) drops the
backticks the pinned tail has around ADR-0030 and LDG-35; not a quotation issue.

## 4. How r86/r86b judged the quotations in Q2-A-cited

All read only; verbatim with file:line.

- r86b's brief says what "-cited" added, `/var/tmp/provisiond-panel-r86/r86b/brief.md:44`:
`````text
1. Fable applied original A/B in scratch and their removed API-7 wording breaks Lean docstring citations. A-prime repairs those docstrings; the two cited forms below additionally restore selected OPS-43 quotations. Original and repaired exact forms have separate ballots. No full candidate Lean build is claimed.
`````
- and how the cited forms came to the panel, `r86b/brief.md:684` (the paragraph opening "Complete candidates for this round"):
`````text
All source substitutions are relative to the pin. Inline code formatting may follow the existing document convention, but no word, quotation, owner, declaration or obligation may change under a formatting excuse. The original Q1-A/B and Q2-A/B are printed in full; a changed rationale is labeled. Q2-A-prime is fable’s distinct reader form. Q2-A-cited and Q2-B-cited are manager-prepared, unreviewed whole forms submitted NOW, not prior settlements. Their additional edits repair quotations/docstrings and claim no resolution of the disputed formal semantics, domain restriction or enforcement concern.
`````
- r86's fable answer, reproduced verbatim in r86b (`r86b/brief.md:1342` "BEGIN VERBATIM R86 fable"), excerpt of `r86b/brief.md:1386`:
`````text
Both Q2 forms also replace OPS-43 step 3's three verified quotations with paraphrase. That is a quality regression under the "Quote the sentence" rule, not a gate failure.
`````
- r86's opus answer, reproduced in r86b (`r86b/brief.md:1460` "# r86 Panel G: opus reader answer", section "Brief errors (rule 6)" at `:1586`), `r86b/brief.md:1590-1591`:
`````text
- Both Q2 forms' `OPS-43` step 3 rewrites drop three gate-checked quotations: `OPS-23`'s colon quote, `PRV-8`'s "at least one SSH public key" and `PRV-10`'s "the account is configured to allow ordering". Restating claims about other requirements without quoting them falls short of AGENTS.md's completion rule. No test pins those quotes, and `PRV-10` (`02:162`) still points at step 3. This is editorial, and I am not conditioning my vote on it.
- Lean `createPurchaseTail`'s docstring (`Admission.lean:1181–1194`) stays true under Q2-A, but `orderingDeclared` must then be read as "5d passes", which is true for an absent offer. A one-line docstring follow-up is advisable. No theorem or witness changes: `undeclaredOrderingCreate` uses a sellable, present offer.
`````
- r86b opus, `r86b/opus.md:102`, `:104` and `:152`:
`````text
A-prime and A-cited narrow that rule to present offers. Their docstring edit is a semantic narrowing. Its effect is the same as adding `offerPresent = true` as a hypothesis to `undeclared_ordering_stops_before_tail`. It is not an editorial repair, and I don't call it one.

**It is still lawful.** I checked what changes and what doesn't:
`````
`````text
**Why A-cited over A-prime.** They mean the same thing. A-cited restores the OPS-23, PRV-10 and PRV-8 quotations in step 3, as AGENTS.md's "Quote the sentence" asks. It still drops PRV-10's "the account is configured to allow ordering", but PRV-10's own pointer (`02:162`) to the gate at step 3 stays correct.
`````
- r86b fable, `r86b/fable.md:10-11`, `:59` (its rule-6 note) and `:65` (its alternative A-formal, unreviewed):
`````text
| Q2-A-prime | ACCEPT | Gate-clean; paraphrases three step-3 quotations |
| Q2-A-cited | ACCEPT | **Final Q2 pick** |
`````
`````text
**Rule 6.** I broke no premise claim in this packet. Every pinned excerpt and Lean line matches the pin, the gate reports match my reruns, and the two traces evaluate as the packet says. Two notes with the tally: the 05-persistence replacement text as printed has a line break inside a table row and must be joined on landing, a formatting matter; and the brief's "The added early admission check does change an unsupported request's observable phase" is true only against a build that already violated OVR-2.
`````
`````text
Every Markdown substitution and insertion of Q2-A-cited exactly as printed, its line-19 and lines-317–319 Lean substitutions exactly as printed, and the following in place of its lines-1181–1182 and lines-1205–1206 substitutions, plus two insertions. No existing declaration, theorem or witness changes. Proofs mirror the neighbouring ones; I ran no build.
`````
- r86b tally, `r86b/tally.md:70`:
`````text
**Original A/B citation defects are reproduced.** Using the citation checker read-only on reader-applied candidates with the authoritative index published by this turn's successful full same-pin gate, original A exits 1 with its removed API-7 quotation sources; original B exits 1 for the removed gate phrase. A-prime, A-cited and B-cited exit 0. Receipts and full logs are `check/tally-citation-checks.json` and its referenced logs. This also reproduces citation success for Q1-A and its composition with each cited Q2 option. This is a Python citation check, not a full candidate gate or candidate Lean build. Reader counts and all diagnostic strings were checked, not merely their reported exit 0.
`````

The manager's fair reading: in r86b, "cited" meant gate-clean plus the restored `OPS-43` step-3
quotations (`OPS-23`, `PRV-10`, `PRV-8`). The Lean docstrings were judged for formal semantics and for
the gate (opus.md:102-104; tally.md:70; brief.md:1591 asked for a docstring follow-up), not against
the quotation rule. No r86 or r86b reader judged the `OPS-23` insert (Q1), the line-317 and line-1181
paraphrases (Q2, Q3), the 05 row (Q4; fable noted only its line break), the step-3 admission clause
(Q5), the step-5 settlement clause (Q6) or the `CNF-19` line (Q7) against the quotation rule. Weigh the
other way: the owner adopted the whole text exactly (item 17, §5); fable's A-formal took the line-317
substitution "exactly as printed" (fable.md:65); and r86 fable called the step-3 paraphrase "a quality
regression … not a gate failure" (brief.md:1386), i.e. a reader did weigh the rule, if only for step 3.

**The r99 precedent (same shape, different text).** Panel r99 swept PR #69's adopted `DOM-10` wording
for the same rule. Its tally (`/var/tmp/provisiond-panel-r99/tally.md`): a sentence restating
`PRV-25`'s ordering and outcome settled QUOTE 3–0 (`:22-35`); "classified by OPS-11" settled KEEP 3–0
as a pointer to its owner, `AGENTS.md:34` (`:52-65`); "the capability-less methods named by PRV-4" settled
KEEP 3–0 as a list-owner pointer, `AGENTS.md:40-43` (`:83-96`). "An API-64 operator retry checks
delete_machine before its state-change/enqueue transaction" split 2–1 in r99 and again in r99b, every
seat switched, and went to the owner, who chose "Keep the clause as landed" (owner item 27, §5).
Q4 here ("copied from the named offer at admission under API-7") has that shape: a new rule of its own
that names the requirement it comes from.

## 5. The approval record

Owner item 17, verbatim (`/var/tmp/provisiond-manager/owner-decisions-1030.md:135-142`, machine-local):

`````text
17. **pv-e45e (Panel G r86b Q2, tied 2–2 after its one consensus round: fable + opus A-cited, astra + sol B-cited; the
    owner's tie)** — Q: "pv-e45e (tied 2–2): may one account sell both VMs and physical servers?" A: **"A: yes, kind
    per offer"**. Option text: "fable + opus. Mixed accounts work; a vanished offer gets 'not sellable' instead of early
    'unsupported'. Open objection: the formal model needs a real amendment." Rejected: "B: no, kind per account".
    Meaning: adopt exactly /var/tmp/provisiond-panel-r86/r86b/Q2-A-cited.md (per r86b/owner-questions.md §2, pin
    3109b5b), with astra/sol's open objection (the changed missing-offer formal case needs a substantive formal
    amendment) on record. pv-e45e → ready-for-agent with that package as its brief. With item 16, Panel G is fully
    decided; its records can be archived.
`````

Owner item 26, verbatim (`/var/tmp/provisiond-manager/owner-decisions-1030.md:218-233`):

`````text
26. **pv-e45e vs PR #68 PRV-10 quote, route (wording Panel r98, consensus round r98b; owner asked 2026-11-03
    ~04:42Z)** — r98 settled Q2 3–0 (Opus, Astra, Sol): F-QUOTE, exactly /var/tmp/provisiond-panel-r98/check/F-QUOTE.txt
    (SHA-256 2393f71eef02a593e37ca93d6dc4bd441bfc928a0bbeff4e9939e43a34bf2323, brief sha256
    8d3fb791555ecad30f7b390c069916923e3b992773341c23dbf1a31d498e4995, pin b5f71e7). Q1 split 2–1 in r98 (Astra, Sol RUN;
    Opus PREP) and again in r98b with every seat switched (Astra, Sol PREP; Opus RUN); all three accept both routes;
    Fable limit and Grok 402 missing, so it came to the owner under the tie rule. Asked short: "Record the PRV-10 edit
    in pv-e45e's brief first?" A: **"Run instruction carries the edit"** (Opus). Rejected: "Prep commit edits comment
    857 (Recommended)" (Astra, Sol; check/prep-F-QUOTE.md 5cf4ed0919577f86abefe3e86cd3c3e347123d00f1a2b58e45b96e24cc1429a9).
    Adopted: Q1-RUN as /var/tmp/provisiond-panel-r98/brief.md:201–203 words it: "Comment 857 is not edited. The pv-e45e
    Run also updates `PRV-10`'s quotation to the new text, as mechanical follow-through on the brief's step rewrites,
    and its instruction carries the Q2 form verbatim. No preparation commit." Owner relay
    /var/tmp/provisiond-panel-r98/r98b/owner-question.md; tallies /var/tmp/provisiond-panel-r98/tally.md (incl. its
    r98b section). Meaning: after pv-5pmu merges, pv-e45e's Run launches with no preparation commit; its instruction
    quotes brief.md:201–203 and check/F-QUOTE.txt verbatim. The joined RUN fragment e4a86029… was never panel-read;
    the Run instruction quotes the two sources, not that fragment.
`````

The route text item 26 adopts, `/var/tmp/provisiond-panel-r98/brief.md:201-203`:

`````text
- **Q1-RUN (a).** Comment 857 is not edited. The pv-e45e Run also updates `PRV-10`'s quotation to the
  new text, as mechanical follow-through on the brief's step rewrites, and its instruction carries the
  Q2 form verbatim. No preparation commit.
`````

Owner item 27, verbatim (`/var/tmp/provisiond-manager/owner-decisions-1030.md:234-246`):

`````text
27. pv-5pmu PR #69 Q2: DOM-10's API-64 retry clause (wording Panel r99, consensus round r99b; owner asked 2026-11-03
    ~05:53Z, answered ~14:23Z). The codex P1 4450997798 on 01-domain-model.md:575 led to a sweep of the PR #69 diff,
    which found five unquoted restatements. Settled 3–0: Q1 Q1-QUOTE (4c0cbffbf91643afc682f63211c82ae400928e101dd9b4d48aa8e11a49d5419e), Q3 KEEP,
    Q5 KEEP (r99); Q4 Q4-ALT (r99b/forms/Q4-ALT.txt c12991b3…; r99's Q4 voided as premise-changing, r99b is the re-ask);
    Q-REC R-NOTE-ALT (r99b/forms/R-NOTE-ALT.txt 23c4c1f8…, append R-NOTE-ALT-append.md 445f69c2…). Q2 split 2–1 in r99
    (Astra, Sol KEEP; Opus QUOTE) and again in r99b with every seat switched (Astra, Sol QUOTE; Opus KEEP); all three accept
    both forms, none claims a blocking loss; Fable limit and Grok 402 missing, so it came to the owner under the tie rule.
    Asked short: "Should DOM-10's retry clause quote API-64's own words?" A: **"Keep the clause as landed"** (Opus).
    Rejected: "Add the quote (Recommended)" (Astra, Sol; Q2-QUOTE.txt 2b46b8b8…). Adopted: Q2-KEEP
    (/var/tmp/provisiond-panel-r99/Q2-KEEP.txt e3d78fbf…, no byte change). Owner relay
    /var/tmp/provisiond-panel-r99/r99b/owner-question.md; tallies /var/tmp/provisiond-panel-r99/tally.md (incl. r99b).
    Meaning: the PR #69 fix commit replaces only the Q1 and Q4 spans (01-domain-model.md and comment 856), per
    R-NOTE-ALT steps (1)–(4), with the trial r99b/check/trial-A-Q4ALT (exit 0, 365 compared) as the KEEP outcome's check.
`````

Comment 857's line 6, verbatim (`evidence/pv-e45e-comment-857.md:6`):

`````text
**Owner decision:** “A: yes, kind per offer” (`owner-decisions-1030.md`, item 17). Adopted exact form: `docs/research/panels-2026-10/r86/r86b/Q2-A-cited.md`.
`````

## Q1 — the `OPS-23` insert

Adopted span: `docs/research/panels-2026-10/r86/r86b/Q2-A-cited.md:62-63` (comment 857:88-89). It lands after `03-operation-lifecycle.md:2076-2079`. `Q1-OLD.txt`, SHA-256 `91b89db887aa220e7afbd11a2eff527a2441d0860109b7cfd59394777d5615c2`:

`````text
The offer-kind consistency check at OPS-43 step 5 uses the same exception: it runs on
step 4's current List offers result, after that read and before any provider mutation.
`````

Sources, verbatim at the pin:

`03-operation-lifecycle.md:2076-2079` (the landed `OPS-23` exception paragraph the insert follows):

`````text
The worker's claim-time absence check and sale re-test at `OPS-43`'s step 5, "Check for the named
offer's absence from that result", are exceptions to this requirement's "before the driver is
called": they run on the result of `OPS-43`'s step 4, "Obtain the current driver List offers
result", after that read.
`````

`03-operation-lifecycle.md:803` (`OPS-43` step 4, unchanged by the Run):

`````text
4. Gate on `list_offers` under `DOM-10`, then obtain the current driver List offers result.
`````

`Q2-A-cited.md:48-57` (adopted new `OPS-43` step 5):

`````text
```text
5. Check for the named offer's absence from that result, applying the create-tail verdict
   quoted above. If present but its kind differs from request_summary's machine_kind,
   settle failed with invalid_request, details.reason: "offer_not_sellable" and
   retryable: false on both the error and the operation view, before any provider mutation;
   do not substitute the current kind or its capability. Otherwise re-test the named offer
   for sale on that result and the running descriptor. An absent offer or kind mismatch
   gets no price comparison, per-order key upload or order request; the same existing
   pre-step-9 settlement releases the commitment and any resource-offer exclusion.
```
`````

QUOTE's quoted segments and where they sit (checked by `check/build.py`, whitespace-insensitive, each found exactly once in its block):

- OPS-43 5, `Q2-A-cited.md (adopted new OPS-43 step 5, :49-56)`:50-51: "If present but its kind differs from request_summary's machine_kind, settle failed with invalid_request"
- OPS-43 5, `Q2-A-cited.md (adopted new OPS-43 step 5, :49-56)`:52: "before any provider mutation"
- OPS-43 4, `03-operation-lifecycle.md`:803: "obtain the current driver List offers result"

**Q1-QUOTE** (`Q1-QUOTE.txt`, SHA-256 `03732e8fe458a0e015d2c630d243ea1737777ec2077e5a8641d91a641def2cfc`, pin `2cb8e1189310ae096e598bac798df3437be59500`), the exact bytes replacing the span:

`````text
The offer-kind consistency check at OPS-43 step 5 uses the same exception: it runs on
step 4's current List offers result, after that read and before any provider mutation.
`OPS-43` says "If present but its kind differs from request_summary's machine_kind, settle
failed with invalid_request" and "before any provider mutation", and its step 4 says "obtain
the current driver List offers result".
`````

**Q1-KEEP** (`Q1-KEEP.txt`, SHA-256 `937155571f5b6cf8613b55b42b1de46c55ab75476847c7fdcd060a6c2afa9754`, pin `2cb8e1189310ae096e598bac798df3437be59500`):

`````text
KEEP: no byte changes. The Q2-A-cited.md:62-63 span (comment 857:88-89) stays exactly as adopted; the Run writes it as Q2-A-cited.md has it, at pin 2cb8e1189310ae096e598bac798df3437be59500.
`````

Trial: T-Q1 (this QUOTE alone, every other span as adopted, Q4 joined) exits 0, 367 Markdown and 143 Lean docstring quotations compared, unquoted attributions 22, none new. N-Q1 (all QUOTE forms, this one's third quoted word "but" replaced by WRONGWORD) exits 1.

QUOTE keeps the adopted two lines and appends one sentence carrying step 5's and step 4's words for the claims it relies on (what the check is, "before any provider mutation", and the List offers read). KEEP rests on the insert being `OPS-23`'s own exception rule that names where it applies, as the landed paragraph above it is (and that paragraph does quote steps 4 and 5).

## Q2 — the `Admission.lean:317-319` docstring

Adopted span: `docs/research/panels-2026-10/r86/r86b/Q2-A-cited.md:131-134` (comment 857:160-163). It replaces `tools/formal/Provisiond/Admission.lean:317-319`. `Q2-OLD.txt`, SHA-256 `4524048925d049ea5220035ce9d259fa3681fe2ae0a72c0547eefa11a2a65ce8`:

`````text
`orderingCapabilityGuard` (`API-7`, 2026-10-22, `pv-p3k`; step 5d reworded 2026-10-30,
`pv-e45e`): step 5d gates a create on the ordering capability selected by the named offer's kind
in the stored listing, and takes no gate for an offer absent from it. Off, a create without that
declaration reaches the purchase tail.
`````

Sources, verbatim at the pin:

`tools/formal/Provisiond/Admission.lean:317-319` at the pin (what the adopted text replaces):

`````text
`orderingCapabilityGuard` (`API-7`, 2026-10-22, `pv-p3k`): `API-7` says
"**gate a create on its ordering capability**". Off, a create without that declaration reaches
the purchase tail.
`````

`Q2-A-cited.md:5-16` (adopted new `API-7` step 5d):

`````text
```text
5d. For create, open the existing LDG-35 admission transaction and read the provider account's
    stored offer listing in the same read-only snapshot the rich purchase tail will use,
    regardless of listing age; no stored listing means an empty offers set. If the named
    offer is present, take its kind and gate on DOM-10's matching ordering capability using
    the descriptor api runs with. A capability refusal stops here and is not collected by
    the tail. If the offer is absent, run no ordering-capability check and infer no kind from
    the provider account, capability set, offer-id spelling or caller input; continue to the
    ordinary tail's absent-offer verdict. No provider call or admission write is made here.
    On admission, retain the named offer's kind as machine_kind in the create's
    request_summary offer snapshot in the same transaction as the operation and commitment.
```
`````

QUOTE's quoted segments and where they sit (checked by `check/build.py`, whitespace-insensitive, each found exactly once in its block):

- API-7 5d, `Q2-A-cited.md (adopted new API-7 step 5d, :6-15)`:8-9: "If the named offer is present, take its kind and gate on DOM-10's matching ordering capability"
- API-7 5d, `Q2-A-cited.md (adopted new API-7 step 5d, :6-15)`:11: "If the offer is absent, run no ordering-capability check"

**Q2-QUOTE** (`Q2-QUOTE.txt`, SHA-256 `d82170607ffaccca68bf057c8f6f3117caa7fcc02d65599ad19f9e02502c83f6`, pin `2cb8e1189310ae096e598bac798df3437be59500`), the exact bytes replacing the span:

`````text
`orderingCapabilityGuard` (`API-7`, 2026-10-22, `pv-p3k`; step 5d reworded 2026-10-30,
`pv-e45e`): step 5d gates a create on the ordering capability selected by the named offer's kind
in the stored listing, and takes no gate for an offer absent from it; `API-7` says "If the named
offer is present, take its kind and gate on DOM-10's matching ordering capability" and "If the
offer is absent, run no ordering-capability check". Off, a create without that declaration
reaches the purchase tail.
`````

**Q2-KEEP** (`Q2-KEEP.txt`, SHA-256 `0fb3218d2699ebc984bfd721440623b7d0c1d629dccd3258ddf87f8be0bf6fef`, pin `2cb8e1189310ae096e598bac798df3437be59500`):

`````text
KEEP: no byte changes. The Q2-A-cited.md:131-134 span (comment 857:160-163) stays exactly as adopted; the Run writes it as Q2-A-cited.md has it, at pin 2cb8e1189310ae096e598bac798df3437be59500.
`````

Trial: T-Q2 (this QUOTE alone, every other span as adopted, Q4 joined) exits 0, 364 Markdown and 145 Lean docstring quotations compared, unquoted attributions 22, none new. N-Q2 (all QUOTE forms, this one's third quoted word "named" replaced by WRONGWORD) exits 1.

QUOTE keeps the adopted docstring and adds `API-7`'s words for both halves before "Off, …"; the Lean EXISTS rule checks them. KEEP rests on the docstring being a model summary of what the guard models, not a claim about `API-7`'s wording; and on r86b, where fable's A-formal kept this substitution exactly (§4). Against KEEP: the pinned docstring quotes `API-7`, and the adopted text replaces that quotation with a paraphrase.

## Q3 — the `Admission.lean:1181-1182` docstring

Adopted span: `docs/research/panels-2026-10/r86/r86b/Q2-A-cited.md:144-146` (comment 857:173-175). It replaces words on `tools/formal/Provisiond/Admission.lean:1181-1182`. `Q3-OLD.txt`, SHA-256 `4bd4350a8282428dd293b49b1e51306bd5ca23bc0c034d77b3ee7c7d9e916912`:

`````text
whether the account declares the ordering capability selected by the named offer's kind in the
stored listing; for an offer absent from that listing step 5d takes no gate and the Boolean is
supplied `true`. Offer-kind selection and descriptor construction are outside this model.
`````

Sources, verbatim at the pin:

`tools/formal/Provisiond/Admission.lean:1180-1183` at the pin:

`````text
/-- Step 5d composed before the create's tail (`API-7`, `DOM-10`). The supplied Boolean answers
whether the account declares the create's ordering capability. Machine-kind selection and
descriptor construction are outside this model. Only creates enter this function; the shared
steps 1–5c and extend-runway's tail are separate. -/
`````

`Q2-A-cited.md:5-16` (adopted new `API-7` step 5d):

`````text
```text
5d. For create, open the existing LDG-35 admission transaction and read the provider account's
    stored offer listing in the same read-only snapshot the rich purchase tail will use,
    regardless of listing age; no stored listing means an empty offers set. If the named
    offer is present, take its kind and gate on DOM-10's matching ordering capability using
    the descriptor api runs with. A capability refusal stops here and is not collected by
    the tail. If the offer is absent, run no ordering-capability check and infer no kind from
    the provider account, capability set, offer-id spelling or caller input; continue to the
    ordinary tail's absent-offer verdict. No provider call or admission write is made here.
    On admission, retain the named offer's kind as machine_kind in the create's
    request_summary offer snapshot in the same transaction as the operation and commitment.
```
`````

QUOTE's quoted segments and where they sit (checked by `check/build.py`, whitespace-insensitive, each found exactly once in its block):

- API-7 5d, `Q2-A-cited.md (adopted new API-7 step 5d, :6-15)`:11: "If the offer is absent, run no ordering-capability check"

**Q3-QUOTE** (`Q3-QUOTE.txt`, SHA-256 `83bc80552410d2e6292c1a0d1cf702e82d635878ce0858b089e43ee68cf8fc09`, pin `2cb8e1189310ae096e598bac798df3437be59500`), the exact bytes replacing the span:

`````text
whether the account declares the ordering capability selected by the named offer's kind in the
stored listing; for an offer absent from that listing step 5d takes no gate and the Boolean is
supplied `true` (`API-7` says "If the offer is absent, run no ordering-capability check").
Offer-kind selection and descriptor construction are outside this model.
`````

**Q3-KEEP** (`Q3-KEEP.txt`, SHA-256 `8a0028848c42bfe50e49b3df26f451f1d4b587f2303f909b91b22cb55bf2dc81`, pin `2cb8e1189310ae096e598bac798df3437be59500`):

`````text
KEEP: no byte changes. The Q2-A-cited.md:144-146 span (comment 857:173-175) stays exactly as adopted; the Run writes it as Q2-A-cited.md has it, at pin 2cb8e1189310ae096e598bac798df3437be59500.
`````

Trial: T-Q3 (this QUOTE alone, every other span as adopted, Q4 joined) exits 0, 364 Markdown and 144 Lean docstring quotations compared, unquoted attributions 22, none new. N-Q3 (all QUOTE forms, this one's third quoted word "offer" replaced by WRONGWORD) exits 1.

QUOTE adds `API-7`'s absent-offer sentence in parentheses. Only the absent-offer clause is asked; the first clause (what the Boolean answers) is model semantics. KEEP rests on the clause describing the model's convention ("the Boolean is supplied `true`"), which r86 opus asked for as a docstring follow-up (brief.md:1591), rather than restating `API-7`.

## Q4 — the 05 `request_summary` row

Adopted span: `docs/research/panels-2026-10/r86/r86b/Q2-A-cited.md:69-70` (comment 857:95-96). It replaces the exact words "the **offer snapshot** (`offer_id`, the offer's `install_strategies` as accepted," inside `05-persistence.md:523`, a single Markdown table row of 1982 characters. `Q4-OLD.txt`, SHA-256 `434ff18ea37383aff8146cdda770b5d1040115541249ab9ce9e80b316b13252d`:

`````text
the **offer snapshot** (`offer_id`, `machine_kind` (`virtual` or `bare_metal`, copied from the
named offer at admission under API-7), the offer's `install_strategies` as accepted,
`````

Sources, verbatim at the pin:

`05-persistence.md:523` at the pin, first 330 characters (the whole row is one line):

`````text
| `request_summary` | json | what survives the purge: what was attempted, plus provider-side identifiers, plus, for a create, **one record and not a list** (`ADR-0014`): the correlator, the **offer snapshot** (`offer_id`, the offer's `install_strategies` as accepted, and — *added 2026-09-05, because `OPS-43`'s claim-time price c …
`````

`Q2-A-cited.md:5-16` (adopted new `API-7` step 5d):

`````text
```text
5d. For create, open the existing LDG-35 admission transaction and read the provider account's
    stored offer listing in the same read-only snapshot the rich purchase tail will use,
    regardless of listing age; no stored listing means an empty offers set. If the named
    offer is present, take its kind and gate on DOM-10's matching ordering capability using
    the descriptor api runs with. A capability refusal stops here and is not collected by
    the tail. If the offer is absent, run no ordering-capability check and infer no kind from
    the provider account, capability set, offer-id spelling or caller input; continue to the
    ordinary tail's absent-offer verdict. No provider call or admission write is made here.
    On admission, retain the named offer's kind as machine_kind in the create's
    request_summary offer snapshot in the same transaction as the operation and commitment.
```
`````

`check/trial-T-ASIS.diff`, the 05 hunk's changed lines (each cut at 150 characters): the adopted line break splits the row into a table row and a stray line

`````text
-| `request_summary` | json | what survives the purge: what was attempted, plus provider-side identifiers, plus, for a create, **one record and not a  …
+| `request_summary` | json | what survives the purge: what was attempted, plus provider-side identifiers, plus, for a create, **one record and not a  …
+named offer at admission under API-7), the offer's `install_strategies` as accepted, and — *added 2026-09-05, because `OPS-43`'s claim-time price che …
`````

QUOTE's quoted segments and where they sit (checked by `check/build.py`, whitespace-insensitive, each found exactly once in its block):

- API-7 5d, `Q2-A-cited.md (adopted new API-7 step 5d, :6-15)`:14-15: "On admission, retain the named offer's kind as machine_kind in the create's request_summary offer snapshot"

**Q4-QUOTE** (`Q4-QUOTE.txt`, SHA-256 `4695e74ec303f96672dd49acb804136a56853582e7a84e78b6864ea31d0e9925`, pin `2cb8e1189310ae096e598bac798df3437be59500`), the exact bytes replacing the span:

`````text
the **offer snapshot** (`offer_id`, `machine_kind` (`virtual` or `bare_metal`, copied from the named offer at admission under API-7; `API-7` says "On admission, retain the named offer's kind as machine_kind in the create's request_summary offer snapshot"), the offer's `install_strategies` as accepted,
`````

**Q4-KEEP** (`Q4-KEEP.txt`, SHA-256 `5db74cb1fc638bf9250e7c8f2b733aaec85b88f905d22c9f9375aa091e4b1c94`, pin `2cb8e1189310ae096e598bac798df3437be59500`):

`````text
the **offer snapshot** (`offer_id`, `machine_kind` (`virtual` or `bare_metal`, copied from the named offer at admission under API-7), the offer's `install_strategies` as accepted,
`````

**Q4-ASIS** (`Q4-ASIS.txt`, SHA-256 `ad7fc89a36d9ba7f526e58da86b5b89bdccdfefe22a5196149e856ba798e827a`, pin `2cb8e1189310ae096e598bac798df3437be59500`), no byte change:

`````text
ASIS: no byte changes. The Run writes Q2-A-cited.md:69-70 (comment 857:95-96) exactly as adopted, including its line break, into the one-line 05-persistence.md:523 table row.
`````

Trial: T-Q4 (this QUOTE alone, every other span as adopted) exits 0, 365 Markdown and 143 Lean docstring quotations compared, unquoted attributions 22, none new. N-Q4 (all QUOTE forms, this one's third quoted word "retain" replaced by WRONGWORD) exits 1.

Q4 has three forms. **Q4-ASIS** writes the adopted bytes as they are, line break included, which splits the table row (r86b fable.md:59: "the 05-persistence replacement text as printed has a line break inside a table row and must be joined on landing, a formatting matter"). **Q4-KEEP** is the adopted words joined onto one line: every word as adopted, only the line break replaced by a space. **Q4-QUOTE** is Q4-KEEP plus `API-7`'s words. KEEP rests on the clause being the row's own rule naming its source, the same shape as r99's Q2 that the owner kept (item 27). ASIS keeps the bytes exactly but leaves a broken table row; KEEP and QUOTE change bytes, so Q-ROUTE applies to them.

## Q5 — the `OPS-43` step 3 admission clause

Adopted span: `docs/research/panels-2026-10/r86/r86b/Q2-A-cited.md:39-43` (comment 857:65-69). It replaces `03-operation-lifecycle.md:797-802` (`OPS-43` step 3) as part of the adopted step. `Q5-OLD.txt`, SHA-256 `eccfa79b55784a9cfa092ba606ea67776db58a91bc7cdb73d1ff5d8571d6551b`:

`````text
   or `bare_metal`. The `api` writes `machine_kind` at admission; for missing or invalid
   fields, see `OPS-23`. Check caller-supplied fields first, then api-written admission
   fields, then gate on `DOM-10`'s matching ordering capability selected by that persisted
   `machine_kind`, using the descriptor the worker runs with. No current offer read supplies
   this gate.
`````

Sources, verbatim at the pin:

`03-operation-lifecycle.md:797-802` at the pin (`OPS-43` step 3, replaced by the adopted step):

`````text
3. Repeat boundary validation under `OPS-23`: "Validation that was performed at the API boundary
   MUST be repeated in the worker before the driver is called". This includes `PRV-10`'s
   "explicit purchase acknowledgement", `PRV-8`'s "at least one SSH public key", the missing-field
   checks defined in `OPS-23`, and `DOM-10`'s gate on the create's ordering capability, which is
   `PRV-10`'s "the account is configured to allow ordering". The checks on caller-supplied fields
   run first, then the checks on fields the `api` wrote at admission, then the capability gate.
`````

`Q2-A-cited.md:34-44` (adopted new `OPS-43` step 3):

`````text
```text
3. Repeat boundary validation under `OPS-23`: "Validation that was performed at the API boundary
   MUST be repeated in the worker before the driver is called". This includes `PRV-10`'s
   "explicit purchase acknowledgement", `PRV-8`'s "at least one SSH public key", and the
   missing-field checks in `OPS-23`. Validate `request_summary`'s `machine_kind` as `virtual`
   or `bare_metal`. The `api` writes `machine_kind` at admission; for missing or invalid
   fields, see `OPS-23`. Check caller-supplied fields first, then api-written admission
   fields, then gate on `DOM-10`'s matching ordering capability selected by that persisted
   `machine_kind`, using the descriptor the worker runs with. No current offer read supplies
   this gate.
```
`````

`Q2-A-cited.md:5-16` (adopted new `API-7` step 5d):

`````text
```text
5d. For create, open the existing LDG-35 admission transaction and read the provider account's
    stored offer listing in the same read-only snapshot the rich purchase tail will use,
    regardless of listing age; no stored listing means an empty offers set. If the named
    offer is present, take its kind and gate on DOM-10's matching ordering capability using
    the descriptor api runs with. A capability refusal stops here and is not collected by
    the tail. If the offer is absent, run no ordering-capability check and infer no kind from
    the provider account, capability set, offer-id spelling or caller input; continue to the
    ordinary tail's absent-offer verdict. No provider call or admission write is made here.
    On admission, retain the named offer's kind as machine_kind in the create's
    request_summary offer snapshot in the same transaction as the operation and commitment.
```
`````

QUOTE's quoted segments and where they sit (checked by `check/build.py`, whitespace-insensitive, each found exactly once in its block):

- API-7 5d, `Q2-A-cited.md (adopted new API-7 step 5d, :6-15)`:14-15: "On admission, retain the named offer's kind as machine_kind in the create's request_summary offer snapshot"

**Q5-QUOTE** (`Q5-QUOTE.txt`, SHA-256 `bf20ab03e6fd3291b167a391f672d0375fa3a91917d50ed88ece1fffbaf24f21`, pin `2cb8e1189310ae096e598bac798df3437be59500`), the exact bytes replacing the span:

`````text
   or `bare_metal`. The `api` writes `machine_kind` at admission (`API-7` says "On admission,
   retain the named offer's kind as machine_kind in the create's request_summary offer
   snapshot"); for missing or invalid fields, see `OPS-23`. Check caller-supplied fields
   first, then api-written admission fields, then gate on `DOM-10`'s matching ordering
   capability selected by that persisted `machine_kind`, using the descriptor the worker runs
   with. No current offer read supplies this gate.
`````

**Q5-KEEP** (`Q5-KEEP.txt`, SHA-256 `a873afce596157e55a6d03068aad8904c855002cbe720e32e3139368fa05f27e`, pin `2cb8e1189310ae096e598bac798df3437be59500`):

`````text
KEEP: no byte changes. The Q2-A-cited.md:39-43 span (comment 857:65-69) stays exactly as adopted; the Run writes it as Q2-A-cited.md has it, at pin 2cb8e1189310ae096e598bac798df3437be59500.
`````

Trial: T-Q5 (this QUOTE alone, every other span as adopted, Q4 joined) exits 0, 365 Markdown and 143 Lean docstring quotations compared, unquoted attributions 22, none new. N-Q5 (all QUOTE forms, this one's third quoted word "retain" replaced by WRONGWORD) exits 1.

QUOTE adds `API-7`'s retention sentence in parentheses and rewraps the step. Cascade: `PRV-10`'s form (`check/F-QUOTE.txt`, which the Run carries under item 26) quotes step 3 whole, so under Q5-QUOTE the same r98 re-slice rule gives `check/F-QUOTE-Q5.txt` (SHA-256 `c818daa69e4d98197407c29f467c835edb5d795048d066d0004ae943c1dd6776`, 2089 bytes against F-QUOTE's 1962): its step-3 quotation then contains the parenthesis and the new line breaks; nothing else differs. KEEP rests on the clause naming no requirement: it is step 3's own statement of who writes the field it validates.

## Q6 — the `OPS-43` step 5 settlement clause

Adopted span: `docs/research/panels-2026-10/r86/r86b/Q2-A-cited.md:55-56` (comment 857:81-82). It is the last clause of the adopted step 5, which replaces `03-operation-lifecycle.md:804-805`. `Q6-OLD.txt`, SHA-256 `32874589b5372b0b0f2799e46aa243ad4ba3ef2a5db1ea61c12d6a1c5f55d95c`:

`````text
the same existing
   pre-step-9 settlement releases the commitment and any resource-offer exclusion.
`````

Sources, verbatim at the pin:

`03-operation-lifecycle.md:249` at the pin (`OPS-11`, the create row, one line):

`````text
| create | Any create failure the worker records before any step-9 request (before any per-order key upload or order request) MUST settle `failed`, whatever its kind. The boundary is the worker invoking the first step-9 per-order key upload or order call. It is the worker's position: this rule MUST NOT read `about_to_order_at`, nor any snapshot or cached copy of it. The settle write keeps the ordinary worker guard (`STO-3`; `OPS-6`: "every write that worker makes to the operation MUST carry `claim_number = mine`"), with no `about_to_order_at IS NULL` term. The error MUST keep its reported kind. For `network`, `timeout`, `internal`, `provider` with a 5xx or no upstream status, and a cut-off `conflict`, it MUST carry `retryable: true` on both the error and the operation view; a failure classified `failed` without this pre-step-9 rule keeps its stated `retryable`. An `OPS-21` cancellation of `execute` stays a cut-off `conflict`. The commitment is released in full under `LDG-32` ("A commitment MUST be closed, and its remaining amount released in full") and `LDG-39` ("**Never debited**; released with the commitment (`LDG-32`)"), with no setup-fee or first-unit debit. Settlement takes the `LDG-35` primitive, then follows `STO-3`: "The guarded status write precedes every money write in the transaction and short-circuits the rest". Where the create holds a resource-offer exclusion, it is freed under `STO-58`: "Its lifetime follows the winning create's outcome settlement". Before step 9 no provider mutation has been requested (`PRV-50`). From step 9 onward, including a key-upload failure or an order-call failure before any byte was sent: `needs_reconciliation` if the failure is *ambiguous*, otherwise `failed`. |
`````

`03-operation-lifecycle.md:786-792` at the pin (`OPS-43` step 1, which quotes `OPS-11` for the same release):

`````text
   Next read this operation's tenant status. Where the tenant is suspended, fail this existing
   create with conflict, details.reason: "tenant_suspended", and retryable: false on both the error
   and operation view. This read precedes channel closure and boundary validation. Make no provider
   request, including List offers or a per-order key upload. Settle failed with full commitment
   release and no setup-fee or first-unit debit under OPS-11's pre-step-9 create rule; OPS-11 says "Any create failure the worker records before any step-9 request (before any per-order key upload or order request) MUST settle `failed`, whatever its kind." and “The commitment is released in full under `LDG-32` ("A commitment MUST be closed, and its remaining amount released in full") and `LDG-39` ("**Never debited**; released with the commitment (`LDG-32`)"), with no setup-fee or first-unit debit.”. Preserve
   requested_by and system_reason as originally recorded; do not emit the admission-only kind
   suspended. This is a plain read; the dispatch guard below closes the race after it.
`````

QUOTE's quoted segments and where they sit (checked by `check/build.py`, whitespace-insensitive, each found exactly once in its block):

- OPS-11, `03-operation-lifecycle.md`:249: "The commitment is released in full under `LDG-32`"
- OPS-11, `03-operation-lifecycle.md`:249: "Where the create holds a resource-offer exclusion, it is freed under `STO-58`"

**Q6-QUOTE** (`Q6-QUOTE.txt`, SHA-256 `ad77bbdd4095faa1336db546c6058f1ef58ee3239607af89299974aa0b4bf9d5`, pin `2cb8e1189310ae096e598bac798df3437be59500`), the exact bytes replacing the span:

`````text
the same existing
   pre-step-9 settlement releases the commitment and any resource-offer exclusion; `OPS-11`
   says "The commitment is released in full under `LDG-32`" and "Where the create holds a
   resource-offer exclusion, it is freed under `STO-58`".
`````

**Q6-KEEP** (`Q6-KEEP.txt`, SHA-256 `8459058682b9e8a1fc6736e93bc0c1bc816ac44716398838f6cecc57d777b9a9`, pin `2cb8e1189310ae096e598bac798df3437be59500`):

`````text
KEEP: no byte changes. The Q2-A-cited.md:55-56 span (comment 857:81-82) stays exactly as adopted; the Run writes it as Q2-A-cited.md has it, at pin 2cb8e1189310ae096e598bac798df3437be59500.
`````

Trial: T-Q6 (this QUOTE alone, every other span as adopted, Q4 joined) exits 0, 366 Markdown and 143 Lean docstring quotations compared, unquoted attributions 22, none new. N-Q6 (all QUOTE forms, this one's third quoted word "is" replaced by WRONGWORD) exits 1.

QUOTE appends `OPS-11`'s words for both released things. KEEP rests on "the same existing pre-step-9 settlement" pointing at the settlement already quoted in steps 1 and 8, so that a third copy of the quotation adds nothing ("Cite the owner", AGENTS.md:34).

## Q7 — the `CNF-19` directive

Adopted span: `docs/research/panels-2026-10/r86/r86b/Q2-A-cited.md:101` (comment 857:130). It is the twelfth line of the block appended to `CNF-19`. `Q7-OLD.txt`, SHA-256 `e8c33b627550be3699e9de7b95f7390ed04c7174ed55caffc9ef77312c2db5dd`:

`````text
assert the CNF-55 pre-List-offers refusal using the retained machine_kind.
`````

Sources, verbatim at the pin:

`10-conformance-checklist.md:358-376` at the pin (`CNF-55`):

`````text
- [ ] **CNF-55** — A paid create (`DOM-16`) is rejected without both the
      per-request purchase acknowledgement and the account-level opt-in. On an account whose
      `allow_orders` is false, assert `GET /v1/providers` lists it without its ordering
      capability, and that a create carrying `acknowledge_purchase: true` is refused at `API-7`'s
      step 5d: HTTP `501`, `unsupported`, `details.provider_account` and `details.capability`
      naming the account and that capability, `retryable: false`, and, with a balance too low for
      the create, no `details.refusals` or `details.not_checked` and no operation or commitment.
      A same-key, same-body replay of a create admitted before the flag was turned off returns its
      stored result. Admit a complete resource-offer (`offer_is_resource`) create with
      `allow_orders` true, and assert this create's exclusion for its provider account, ordering
      channel and offer id is held at admission (`PRV-42`, `STO-58`). While it is still queued
      and unclaimed, restart with only that flag changed to false, and assert the worker
      refuses it at `OPS-43`'s step 3 with the same kind, `details`
      and `retryable: false` on both the error and the operation view, `failed`, the commitment
      released in full with no setup-fee or first-unit debit, this create's settlement freeing
      that same held resource-offer exclusion (`STO-58`), and no provider request, including
      no List offers read. (`API-15`, `PRV-10`, `DOM-10`, `DOM-16`, `API-7`, `OPS-43`, `WIR-9a`,
      `WIR-9b`, `LDG-39`)
`````

QUOTE's quoted segments and where they sit (checked by `check/build.py`, whitespace-insensitive, each found exactly once in its block):

- CNF-55, `10-conformance-checklist.md`:369-370: "the worker refuses it at `OPS-43`'s step 3"

**Q7-QUOTE** (`Q7-QUOTE.txt`, SHA-256 `1d9bef585097566af304dc2fd3e4d644a4a5492ba730374432ce34ff21c220fb`, pin `2cb8e1189310ae096e598bac798df3437be59500`), the exact bytes replacing the span:

`````text
assert the CNF-55 pre-List-offers refusal using the retained machine_kind (`CNF-55` says
"the worker refuses it at `OPS-43`'s step 3").
`````

**Q7-KEEP** (`Q7-KEEP.txt`, SHA-256 `d59a4fadf509e0272ffa120048fdba452c4609f886513e973b7ef55156c981db`, pin `2cb8e1189310ae096e598bac798df3437be59500`):

`````text
KEEP: no byte changes. The Q2-A-cited.md:101 span (comment 857:130) stays exactly as adopted; the Run writes it as Q2-A-cited.md has it, at pin 2cb8e1189310ae096e598bac798df3437be59500.
`````

Trial: T-Q7 (this QUOTE alone, every other span as adopted, Q4 joined) exits 0, 365 Markdown and 143 Lean docstring quotations compared, unquoted attributions 22, none new. N-Q7 (all QUOTE forms, this one's third quoted word "refuses" replaced by WRONGWORD) exits 1.

QUOTE adds `CNF-55`'s words for where the worker refuses. KEEP rests on the line being a test directive naming which assertion to reuse ("the CNF-55 … refusal"), like the other `CNF-19` directives in §3; "pre-List-offers" matches `CNF-55`'s "no provider request, including no List offers read" (`:373-374`).

## Q-ROUTE — how a changed form reaches the Run and the record

Answer this conditionally: it applies if any of Q1–Q7 settles on a form whose bytes differ from the
adopted text (any QUOTE, Q4-KEEP, or an ALT). It does not apply if every question settles on KEEP or
Q4-ASIS. Pick one, or print a complete exact ALT.

Precedents: owner item 26 ("Run instruction carries the edit": no preparation commit, comment 857 not
edited, the Run instruction quotes the settled forms verbatim), and the dated archive notes r97 Q4
(owner item 25) and r99 Q-REC (`/var/tmp/provisiond-panel-r99/r99b/forms/R-NOTE-ALT.txt`, which also
edited comment 856 and appended "## Wording correction — 2026-11-03 (Panel r99)" to the r86b record).
Both forms below leave comment 857 unedited, as item 26 has it, and add no preparation commit; a
"prep commit edits comment 857" route is not printed because item 26 rejected exactly that ("Prep
commit edits comment 857 (Recommended)"). An ALT may still propose it.

**R-RUN** (`R-RUN.txt`, SHA-256 `606973ea02527fc50d1ae9be52e073d69ff74c2009c455cd61a925e06c31a0dd`, pin `2cb8e1189310ae096e598bac798df3437be59500`):

`````text
No preparation commit; comment 857 and docs/research/panels-2026-10/r86/r86b/Q2-A-cited.md are not edited. The pv-e45e Run instruction quotes verbatim /var/tmp/provisiond-panel-r98/brief.md:201–203, the PRV-10 form (r100 check/F-QUOTE.txt, or check/F-QUOTE-Q5.txt if Q5 settles on Q5-QUOTE), and each settled r100 form whose bytes differ from the adopted text, each with the Q2-A-cited.md span it replaces; the Run writes those forms in place of those spans and archives the reviewed r100 record at docs/research/panels-2026-10/r100/. No branch or tracker edit occurs in this panel turn.
`````

**R-NOTE** (`R-NOTE.txt`, SHA-256 `d50de4177d3aa9c689d1bc4e6f1ff7cd6fbb08831ae8fd5702484ce3efff43a7`, pin `2cb8e1189310ae096e598bac798df3437be59500`):

`````text
Exactly as R-RUN, and in addition the Run appends exactly R-NOTE-append.md to docs/research/panels-2026-10/r86/r86b/Q2-A-cited.md, all original bytes remaining an exact prefix. Comment 857 is not edited. No branch or tracker edit occurs in this panel turn.
`````

`R-NOTE-append.md` (SHA-256 `40db5de25fb651fc30575c9850d4397f78d0b76213df023e372f572238b58af9`), the exact bytes appended. The pinned
Q2-A-cited.md ends with a blank line, so it begins directly with the heading:

`````markdown
## Wording correction — 2026-11-03 (Panel r100)

The text above is retained as the historical form approved in owner item 17; its original
bytes remain unchanged. Under the owner's 2026-10-28 wording rule (“For such wording
questions, try to solve by getting a consensus of the panel”), the pv-e45e Run writes the
exact replacements selected in the panel record below in place of the spans they replace.
Comment 857 is not edited. This note grants no independent authority to change a
requirement; any substantive unresolved conflict returns to the owner.

Source pin: `2cb8e1189310ae096e598bac798df3437be59500`.
Panel record: `../../r100/notes.md`.
`````

`check/prospective-Q2-A-cited-with-note.md` (SHA-256 `0e665520d8d83469799d5afc62ad735f506b26e23d9b61b66696e9a88ea7a7c1`)
shows the result; the pinned bytes are its exact prefix. `docs/research/` is outside the gate (§2).
For the all-QUOTE case, `check/prospective-Q2-A-cited-allquote.md` (SHA-256
`6e58fd5afcdd6ccbeb47287e2fb9b5accc0446ae02b91619dc8aad6fdcc2c436`) shows what the Run would write in place of the
adopted text; it is a reading aid, not a form.

## 9. Citation trial (scratch clones of the pin, `check/trial.py`, results `check/trial.json`)

The trial copies `/var/tmp/provisiond-manager/dr-e45e-check/citation-trial.py`: it applies comment
857's edits with each r100 form substituted for its span, plus the `PRV-10` form (`check/F-QUOTE.txt`,
or `check/F-QUOTE-Q5.txt` under Q5-QUOTE), to a fresh clone at the pin, then runs
`python3 tools/check_citations.py`. The lake index was copied read only (SHA-256
`7d378b871bcc783cc91b0aa5d29a6ffd10d3a5c1a588fbb7283bf04a7989fcd9`, built at `514b4a4ac92c73798c2a9ab3369970008c952f26`); `tools/formal` and the gate are
byte-equal to that build at the pin.

| Trial | What is applied | Exit | Markdown compared | Lean QUOTED compared | Unquoted (none new) |
|---|---|---|---|---|---|
| T0 | the pin as is | 0 | 365 | 144 | 22 |
| T-ASIS | adopted text as is (Q4 row split), F-QUOTE | 0 | 364 | 143 | 22 |
| T-KEEP | adopted text, Q4 joined (Q4-KEEP), F-QUOTE | 0 | 364 | 143 | 22 |
| T-Q1 | Q1-QUOTE alone, others adopted, Q4 joined | 0 | 367 | 143 | 22 |
| T-Q2 | Q2-QUOTE alone, others adopted, Q4 joined | 0 | 364 | 145 | 22 |
| T-Q3 | Q3-QUOTE alone, others adopted, Q4 joined | 0 | 364 | 144 | 22 |
| T-Q4 | Q4-QUOTE alone, others adopted | 0 | 365 | 143 | 22 |
| T-Q5 | Q5-QUOTE alone, others adopted, Q4 joined | 0 | 365 | 143 | 22 |
| T-Q6 | Q6-QUOTE alone, others adopted, Q4 joined | 0 | 366 | 143 | 22 |
| T-Q7 | Q7-QUOTE alone, others adopted, Q4 joined | 0 | 365 | 143 | 22 |
| T-ALL | all seven QUOTE forms, F-QUOTE-Q5 | 0 | 372 | 146 | 22 |

T-ASIS's diff is byte-identical to the launch manager's trial T2 (`dr-e45e-check/trial.json`), so the
trial applies the adopted text as the Run would. Negative controls (T-ALL with the third word of one
question's first quotation replaced by WRONGWORD): N-Q1 1, N-Q2 1, N-Q3 1, N-Q4 1, N-Q5 1, N-Q6 1, N-Q7 1; each fails with that question's corrupted
quotation as the one unverifiable attribution (N-Q2 and N-Q3 also with one Lean docstring quote found nowhere). Every QUOTE form is in the gate's
reach. KEEP is T-ASIS, plus the Q4 join (T-KEEP). From T0 to T-ASIS one Markdown and one Lean
comparison are lost; the adopted text drops `PRV-10`'s "the account is configured to allow ordering"
from step 3 (r86b opus.md:152) and the line-317 docstring's `API-7` quotation (Q2). The manager did
not trace each count to its sentence.

## 10. Your answer

For each of Q1, Q2, Q3, Q4, Q5, Q6, Q7 and Q-ROUTE (and any Q8 you open):

1. Final pick: one label (Qn-QUOTE, Qn-KEEP, Q4-ASIS, R-RUN, R-NOTE) or a complete exact ALT printed in
   full with its exact span.
2. ACCEPT or CANNOT ACCEPT for every printed option, separately from the pick.
3. Whether the picked form is wording-only: no behavior, requirement or check-strength change (rule 3).
4. The strongest reason, with file:line at the pin.
5. Any brief error you verified, and whether it changes the question's premise (rule 6).

Also say, in one line, whether comment 857 stays unedited under your Q-ROUTE pick.
