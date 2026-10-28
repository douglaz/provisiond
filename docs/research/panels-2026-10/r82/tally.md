# r82 tally — pv-ymjo, pinned at c824e4fa4d612b231110bc5deb3e88b3b3e90f92

**apply notes.md rule 6 exactly as written; this prompt adds no void rule.**

Read [notes.md](notes.md), [brief.md](brief.md), and the whole final answers [fable](fable.md), [opus](opus.md), [astra](astra.md), [sol](sol.md). Each canonical exit is 0; each answer is substantive and contains an explicit final pick for each question. No usage-limit answer is counted. Grok is missing for the frozen prelaunch HTTP 402/balance-exhausted result, not a fifth vote. No Grok retry is needed for this tally's settled result.

## Validity and Astra's disclosure

Rule 6: “A verified brief error that changes the question's premise voids its tally; re-ask it corrected. Other brief errors are reported with the tally, identifying any vote whose reason rests on one.” No such premise-changing brief error was verified for either question. The supplied repository blocks equal their pinned source bytes, adopted B equals r81/check/form-B.txt, and the printed historical proposals remain distinct forms. The historical r81 CNF-302 link at line 3076 is stale at this pin; the linked item and its quoted lost-reply sentence remain correct. The current packet prints the correct full item and the precise insertion boundary. No reader's pick rests on that stale line number.

Astra discloses: “my initial invocation generated ignored Lean artifacts in the reader clone, violating the temporary-file restriction” and “A broad process listing also surfaced unrelated process arguments, which I excluded from the analysis.” The artifact restriction was violated; the process-list exposure is also a disclosed procedural deviation. Independent Git inspection finds unchanged HEAD, tracked worktree and index, no untracked files, and ignored generated paths in Astra's clone. This is not a verified error in the brief, and rules 1–7 contain no automatic seat-exclusion rule for these deviations. Rule 5 excludes failed, empty, unavailable or non-substantive answers, none of which describes this answer. Astra therefore retains its seat and its votes. No unrelated arguments are reproduced or relied upon here. See [reader-state receipt](/var/tmp/provisiond-panel-r82/check/tally-reader-state.json).

## Explicit final picks

| Reader | Q1 exact final form | Landing | Q2 final pick | Behaviour / requirement / check-strength change |
|---|---|---|---|---|
| fable | D2, verbatim | CNF-302, after lost-reply paragraph, before table | REPLACE | NO / NO / NO |
| opus | M-opus, exact merged text below | Same boundary in CNF-302 | REPLACE | NO / NO / NO |
| astra | D3, unchanged | Same boundary in CNF-302 | REPLACE | NO / NO / NO |
| sol | M-sol, exact merged text below | Same boundary in CNF-302 | REPLACE | NO / NO / NO |

The Q1 final-pick tally is D2={fable}; D3={astra}; M-opus={opus}; M-sol={sol}; D1 and D4 have no final picks. The shared landing does not merge the different texts. M-opus and M-sol were each proposed and selected whole by their own author; the other readers did not review either merged form. No unread combination is counted.

## Exact-form acceptability

A = explicit ACCEPT. C = explicit CANNOT ACCEPT as printed. S = author's complete selected form (accepted by its author). — = not reviewed; neither acceptance nor refusal may be inferred. The exact draft/merged bytes and hashes are printed below and recorded in [exact-form receipt](check/tally-exact-forms.json).

| Q1 form and proposed landing | fable | opus | astra | sol | Acceptance set | Refusal set | Rule 2 threshold |
|---|---|---|---|---|---|---|---|
| D1; CNF-302 after supersession/lost-reply paragraph | A | C | C | C | {fable} | {opus, astra, sol} | Does not qualify |
| D2; CNF-302 at that same boundary | A | C | A | A | {fable, astra, sol} | {opus} | Qualifies |
| D3; CNF-302 at that same boundary | C | C | A | A | {astra, sol} | {fable, opus} | Does not qualify |
| D4; CNF-295, no precise insertion point in original draft | C | C | A | A | {astra, sol} | {fable, opus} | Does not qualify |
| M-opus; CNF-302 at that same boundary | — | S | — | — | {opus} | {} | Does not qualify |
| M-sol; CNF-302 at that same boundary | — | — | — | S | {sol} | {} | Does not qualify |

The suggested D1 opening replacements, D3/D4 sentence deletions, and D2 repairs are conditional repair guidance, not complete independently selected final forms. They are not silently folded into any acceptance above.

| Q2 exact form | Acceptance set | Refusal set | Explicit final-pick set |
|---|---|---|---|
| KEEP: “finds no committed matching record” | {fable, opus, astra, sol} | {} | {} |
| REPLACE: “finds no committed record with that id” | {fable, opus, astra, sol} | {} | {fable, opus, astra, sol} |

All four, including Astra and Sol, explicitly accept KEEP as well as REPLACE. Both Q2 forms meet the acceptance threshold; the explicit preferences are unanimous for REPLACE. This uses those preferences, not a manager tie-break.

## Each reader's strongest reasons, quoted

These are their reasons for their actual selections; requested criticisms are separately audited below.

- **Fable, Q1 D2:** “the predecessor is a fixture the preceding paragraph already supplies”. For the clock it writes: “the pointer form is this repository's convention and the pinned definition is unambiguous.” Q2: “under the only reading in which B's obligations are jointly satisfiable the obligation set is identical, and the reading it forecloses has no satisfiable obligation set to change.”
- **Opus, Q1 M-opus:** “an upsert that resets the marks to 0 passes.” The precise verified point is that reset-to-zero is not distinguished by a zero-valued fixture. Q2: “I prefer REPLACE because it removes reading F's insert-versus-refuse overlap on trace (iii).” Its stronger equivalence argument is qualified below.
- **Astra, Q1 D3:** “The concrete wrong results this catches are an aborted attempt’s `t1` surviving insertion at distinct `t2`; a committed incident being retimed to `t3` or refused solely because `t3` differs; and a matching repeat changing the recorded recovery state or creating another incident.” Q2: “REPLACE retains that protection while making the insertion condition explicitly about absence of the retained id. The preserved refusal clause continues to protect against incompatible reuse.”
- **Sol, Q1 M-sol:** “My merged form adds a later repeat against nonzero marks, making a reset-to-zero implementation distinguishable.” Q2: “The nonzero-mark fixture strengthens the separately authorized Q1 coverage; that strengthening does not come from Q2’s wording replacement.”

## Independent factual audit and broken or limited claims

Sources below are at **c824e4f**, found with rg and then read with sed. Full extracts, exact source hashes and clone-state checks are in [source extraction](/var/tmp/provisiond-panel-r82/check/tally-source-extraction.txt) and [verification receipt](check/tally-source-verification.json). Adopted B postdates the pin and is checked against the frozen owner-adopted form, not misrepresented as text already at the pin.

### D2, its dissent, and the settlement's load-bearing facts

- **Clock:** [STO-54, 05-persistence.md:1636–1640](/var/tmp/provisiond-panel-r82/check/spec/05-persistence.md:1636) says “restore_instant is transaction_timestamp() of the newly begun transaction inserting this incident.” D2's “a later transaction whose start time differs” makes its aborted-insertion comparison distinguishable by that definition. If T1 at t1 aborts and no N exists, T2 at distinct t2 inserts N, so its field must be t2. Adopted B adds “an instant selected for an earlier attempt that did not commit is not reused.” A value reused from t1 fails. In the committed arm, B's “guarded no-op … preserving its step marks and original restore instant” requires preservation of t1; the no-op's own later timestamp is not an insertion event. D2 explicitly forbids refusal merely for that later start. No comparator algorithm is selected.
- **Predecessor:** [CNF-302, 10-conformance-checklist.md:3079–3087](/var/tmp/provisiond-panel-r82/check/spec/10-conformance-checklist.md:3079) supplies “a backup containing an open predecessor whose ordinary close conditions are unmet.” [STO-56:1431–1439](/var/tmp/provisiond-panel-r82/check/spec/05-persistence.md:1431) says “the transaction establishing the new record MUST close R by supersession and insert a distinct record naming R” and “Where the restored store has no open incident, the new record has `supersedes_incident_id` `null`.” D2 is inserted immediately after that fixture. Opus says D2 “assumes a predecessor in every run”. That accurately describes the selected test fixture, so it is **not recorded as a broken factual claim**. It does not establish a blocking loss: the preceding paragraph already supplies that predecessor. The no-inherited-predecessor run in the merged forms is useful additional coverage, not a condition that B requires every individual conformance case to exercise.
- **Provenance:** [STO-54:1711–1723](/var/tmp/provisiond-panel-r82/check/spec/05-persistence.md:1711) assigns the establishing transaction the duty “MUST set this column `true` on every surviving install or rescue-inventory row whose status is `queued`, `running` or `needs_reconciliation`.” D2's “provenance initialized in the repeating transaction” is that existing duty on the aborted-first-attempt arm, with the preceding CNF-302 surviving-row fixture. It adds no rule for unrelated operation kinds.
- **Acknowledgement and continuation:** B says “The initial establishment or its matching no-op repeat MUST be acknowledged before either component starts.” [STO-54:1738–1759](/var/tmp/provisiond-panel-r82/check/spec/05-persistence.md:1738) says “a process that starts while a restore record is open is continuing that incident, not restarting” and “A marked step does not run again.” D2's successful continuation retains the existing recovery prerequisites; it is not an unconditional liveness guarantee during provider or store failure.
- **No duplicates:** [STO-56:1423–1425](/var/tmp/provisiond-panel-r82/check/spec/05-persistence.md:1423) permits “at most one row” with null `closed_at`, and B requires its repeat to “not create or supersede another record.” D2's no-extra-open-incident assertion and preservation checks follow from these words. The direct foreign-key-to-id assertion exists in the same owning body; Opus's external PostgreSQL uniqueness aside is not needed as evidence for either settlement.
- **Absence after the abort:** Opus says “Absence after the abort is assumed, never checked.” D2 indeed states the fixture as “so that no record with the retained id exists” rather than as a separate harness observation. This is a real preference for stronger fixture verification, not a claim that D2 lacks a noncommit condition. It does not identify a conforming result rejected by the exact case.
- **Quotes:** Opus correctly observes that D2 gives a pointer, “the value `STO-54` defines”, without printing the owner's definition. Its request to quote the definition is preserved as a writing objection under AGENTS.md's “A claim about what another requirement says carries that requirement's own words.” The source definition has been quoted and verified here. The exact D2 pointer has not been silently repaired. A content-free owner pointer can also be read as the “Cite the owner” convention rather than a paraphrase of the definition; that drafting distinction is not a changed normative or checked verdict under rule 3. The full candidate gates independently test whether it creates a gate finding; gate success alone would not settle the broader writing judgment.
- **Nonzero marks:** [STO-56:1434](/var/tmp/provisiond-panel-r82/check/spec/05-persistence.md:1434) initializes “`steps_completed` = 0”. The immediate matching-repeat fixtures can therefore pass a bug that resets marks to zero. Opus and Sol's later step-(2) repeat would distinguish that bug, and B already protects the field with “preserving its step marks”. This is a useful coverage addition, but rule 3 says “A merely absent new runtime test is not a contradiction in the unchanged base.” Missing that extra trace does not veto the separately reviewed D2 case. “Vacuous” should not be taken to mean a zero-preservation assertion catches no corruption at all; it still catches a change to a nonzero value.

### Other draft objections and broken overclaims

- **D1's negative comparison:** Fable says D1 “asserts nothing beyond B” and that timestamp distinctness is “only implied” by its comparison to an instant captured before the first attempt. **That implication breaks.** STO-54's quoted inserting-transaction definition imposes no inequality against an arbitrary earlier captured value. A captured value c can equal the retry timestamp t2 while the aborted transaction has distinct t1. Persisting t2 then conforms to B but fails D1's “not an instant captured before the first attempt”. Likewise c≠t2 alone does not establish t1≠t2. Astra, Opus and Sol's request for distinct observed transaction timestamps is justified. D1's connection drop is also weaker as fixture wording than an observed abort: a lost connection is not itself proof of noncommit. These limitations affect Fable's D1 acceptance rationale, not its D2 final pick.
- **D3/D4 certified-recipe disagreement:** Fable and Opus object that these drafts require a derivation B does not require; Astra and Sol read “using STO-54’s event-clock recipe” / “exercise the event-clock upper-bound recipe” as deliberate permitted fixture selection. [STO-54:1660–1666](/var/tmp/provisiond-panel-r82/check/spec/05-persistence.md:1660) says the certified event-clock evidence “can supply f=restore_instant+e_event”, and “If either endpoint cannot be certified, persist null for it and say that endpoint is unknown.” Thus the recipe is permissive, not mandatory for every known endpoint. However the exact drafts select recipe runs, not all deployments' possible bounds. The claim that they **necessarily** impose that recipe on every deployment, or that a conforming alternative-certificate implementation necessarily fails them, is not verified from those exact words. A test with missing prerequisite evidence would not be the printed certified-recipe fixture. This remains a disputed fixture reading, not a proven additional product duty or a manager conversion of refusals into ACCEPTs. The recorded D3/D4 refusal sets stand.
- **D4's landing:** Fable is correct that the original D4 names CNF-295 without a precise insertion point. Opus is correct that [CNF-295:1019–1020](/var/tmp/provisiond-panel-r82/check/spec/10-conformance-checklist.md:1019) is the rehearsal “Before the first customer payment, by someone other than whoever wrote the procedure”. Whether to put retry coverage there is a landing preference; all final picks instead choose CNF-302. The before-step-(3) grace field is null under [STO-56:1457–1461](/var/tmp/provisiond-panel-r82/check/spec/05-persistence.md:1457), which says “It is null until step (3) … is marked”; checking it immediately does not catch a reset-to-null bug.
- **Historical/gate checks:** Git blame verifies Fable's 12c3da0 attribution for the retry paragraph and CNF-302 restore additions. Frozen B's complete SHA256 is bb7cdb82e8133ce6cdb229b8653aa3ccf4f58c15ef086c7ac484f17d58e66786, matching Fable's abbreviation. [check_citations.py:208–232](/var/tmp/provisiond-panel-r82/check/spec/tools/check_citations.py:208) implements the quoted-colon/direct-speech shapes; D1's B-specific no-op quote is not the pinned old sentence and requires B to land. [check_obligations.py:48](/var/tmp/provisiond-panel-r82/check/spec/tools/check_obligations.py:48) recognizes an identifier followed by MUST/SHOULD; none of the exact drafts has that assignment shape. Opus's retained positive logs say all gates passed and its quote-corruption logs report unverifiable quotes; these are consistent with its report but are not substituted for the manager's independent gates.

### Q2: each beyond-wording judgment checked separately

**Behaviour: no verified change.** The complete adopted paragraph supplies the decision boundaries, not one isolated adjective. For no committed N after an abort, KEEP and REPLACE require insertion using the newly inserting transaction's instant. For an existing compatible N, both retain “a guarded no-op, not create or supersede another record, preserving its step marks and original restore instant”. For an actually incompatible assertion about the committed N's instant or predecessor, both retain “MUST be refused with both components stopped”. Neither alternative requires comparing the no-op transaction's later timestamp as if it inserted the incident. The resulting concrete trace outcomes are identical under the coherent adopted reading: T1-abort/T2-insert stores t2; T1-commit/T2-no-op retains t1; incompatible same-id reuse refuses. No additional branch outcome has been verified as required or permitted by REPLACE but forbidden by the jointly read adopted duties.

**Requirement: no verified change.** The exact edit changes only the absent-record condition. It leaves the matching no-op duty, preservation, mismatch refusal, new-actual-restore distinct-id duty and acknowledgement boundary byte-for-byte intact. The original “matching” protects against treating an existing compatible incident as absent; REPLACE keeps that protection because such a record has the retained id. Compatibility is still guarded by the following no-op and explicit refusal clauses. The full-payload predicate is not defined or mandated by the pin or B. Treating it as the authoritative insertion predicate would import the very comparator choice the packet leaves unspecified. The earlier r81 insert/refuse overlap is conditional on that choice, not a verified unavoidable contradiction in B.

**Opus's overbroad Q2 proof claim is not accepted as the proof of equivalence.** Opus writes “The achievable outcomes are the same on every trace” while its own full-payload row (iv) says KEEP-F demands an impossible insert and REPLACE-F has no applicable insert/no-op rule. An unsatisfiable insertion obligation and an absent obligation are not equivalent merely because both leave components stopped; an acknowledgement guard does not satisfy an impossible MUST. That all-interpretations argument overclaims. Its “REPLACE narrows S2's trigger” disclosure accurately describes its hypothetical full-payload reading, not a verified change to the actual adopted duties. This is not a verified YES change claim: neither the source nor the adopted paragraph requires that hypothetical extra-field predicate. The independently checked coherent identity-lookup/guarded-validation reading above supports the shared NO result. No substantive departure is enacted on the basis of the overclaim.

**Check strength: no verified change.** At the pin the span “finds no committed” has not yet landed. The active occurrence of “matching record” is the old STO-56 paragraph at 05:1444; no CNF assertion or Lean declaration contains this phrase. The [Restore record](/var/tmp/provisiond-panel-r82/check/spec/tools/formal/Provisiond/Restore.lean:95) extends the claim record with `restoreInstant`; the model has no incident-id/establishment-retry comparison transition (see its Event and step definitions). Q2 changes no declaration, proof, guard hypothesis, negative control, fixture or expected conformance verdict. Q1's separately authorized new case adds coverage; it is not a strength change caused by Q2. D1's quote is of B's following no-op sentence, which is unchanged. The disposable KEEP+exact-D2 and REPLACE+exact-D2 candidates differ only in the requested words; all formal source bytes, conformance bytes and gate source bytes are identical between them. Independent gates are recorded below. These are specification-gate checks, not executed runtime conformance tests.

## Settlement under fixed rules 1–7

**Q2 SETTLED: REPLACE.** Both alternatives are acceptable to every participating reader; every explicit preference is REPLACE. No behaviour, requirement or check-strength change was independently verified. The owner's wording instruction, “For such wording questions, try to solve by getting a consensus of the panel”, permits this settled wording result without an owner question. This turn records it only; pv-ymjo remains untouched. The exact operation is to replace `finds no` followed by newline and `committed matching record` with `finds no` followed by newline and `committed record with that id`, preserving all other adopted-B bytes.

**Q1 SETTLED: D2, at CNF-302's shared exact insertion boundary.** Under rule 2, D2 has the acceptance set {fable, astra, sol}, refusal set {opus}, and no verified blocking loss under rule 3. No other exact Q1 form meets the threshold. The split explicit final picks do not erase those explicit acceptances, and there is no competing qualifying form that needs a preference tie-break. The missing distinct no-predecessor/nonzero-mark runs and the preserved writing objection do not identify a changed MUST/SHOULD or lost checked verdict. No unread repair is added. Rule 6 does not void either question. Rule 4's consensus-round condition is therefore not reached; no r82b, Grok call, rloop Run, source/tracker edit, commit, push, PR action or owner question is launched. Exact D2 plus its exact landing is [check/cnf-case.md](check/cnf-case.md).

## Verification evidence

The required unpiped `nix develop --command bash tools/check-all.sh` runs in the independent pinned clone both exit 0: [before log](/var/tmp/provisiond-panel-r82/check/gate-tally-before.log), [actual exit](/var/tmp/provisiond-panel-r82/check/gate-tally-before.exit); [final log](/var/tmp/provisiond-panel-r82/check/gate-tally-final.log), [actual exit](/var/tmp/provisiond-panel-r82/check/gate-tally-final.exit). Every gate passes.

The same unpiped full command also independently exits 0 for adopted-B KEEP plus exact D2 ([log](/var/tmp/provisiond-panel-r82/check/tally-candidate-keep.log), [exit](/var/tmp/provisiond-panel-r82/check/tally-candidate-keep.exit)) and for the exact Q2 REPLACE plus the same exact D2 ([log](/var/tmp/provisiond-panel-r82/check/tally-candidate-replace.log), [exit](/var/tmp/provisiond-panel-r82/check/tally-candidate-replace.exit)). [Byte comparison](check/tally-q2-byte-comparison.json) proves the sole Q2 difference is the requested insertion-condition span. The candidate/gate units were launched with MemoryMax=16G, MemorySwapMax=0, OOMPolicy=continue; captured active/cap receipts are in check/tally-candidate-{keep,replace}-caps.txt and check/tally-gate-final-caps.txt. No gate is piped and no red or unavailable formal gate is skipped.

Entry quota read in this turn: Claude session 10%, all-models week 19%, Fable week 27% (exempt), active Codex WEEK 55% (below 100, permitted). No panel, reading round, manager review or rloop Run was launched.

Source application is confined to disposable copies under tmp/tally/. Main and all reader tracked states remain clean at the pin. Older panel directories were read only. The only manager-brief mutation is one UPDATE line under the first RESUME bullet. The repository's required before/final gates run unpiped in the independent pinned check/spec clone; the canonical source branch has not been touched.

## Exact Q1 forms (distinct, unmerged)

### D1

SHA256 `1ace4afe9484906026b3551d220cd86e6161cb3b29e5187b6ff0794008e28ec6`.

```text
Separately drive establishment twice for one actual restore with one retained id: once with
the first attempt's connection dropped before its commit reaches the store, and once with it
dropped after the commit is durable but before its reply. In each run assert exactly one
record carries that id, no refusal occurs, and recovery proceeds after the acknowledged
repeat without operator re-selection. In the aborted run assert the persisted
`restore_instant` equals the inserting retry transaction's own `transaction_timestamp()`,
read in that transaction, and not an instant captured before the first attempt; in the
committed run assert it is the first transaction's and the repeat changes nothing. `STO-56`:
"Repeating establishment with that id when a committed matching record exists MUST affect
that record as a guarded no-op".
```

### D2

SHA256 `ccc7b25a690b1eda5d385947392464a8bdd3673ee95f7512adc7638382d12231`.

```text
For one actual restore, lose the establishment transaction's connection before it commits,
so that no record with the retained id exists, and repeat establishment with that id in a
later transaction whose start time differs: assert exactly one record with that id, its
`restore_instant` the value `STO-54` defines, its predecessor closed by supersession and
provenance initialized in the repeating transaction, and neither component started before
that transaction is acknowledged. Separately let establishment commit, drop its reply and
repeat with the same id: assert the repeat is acknowledged as a guarded no-op preserving the
stored instant, predecessor and step marks, that it is not refused merely because the
repeating transaction starts later, and that the components then start and continue that
incident. Neither arm leaves two open incidents. This case selects no predecessor-comparison
algorithm.
```

### D3

SHA256 `ce167c328e5271033d4aa8de997bff162ae08e038143d4b3754644e24ed17da5`.

```text
**Establishment retry clock.** Exercise the following cases for one actual restore per run, retaining the same new incident id N throughout its establishment retries. Run each case with no inherited open incident and with an inherited open predecessor R whose ordinary close conditions are unmet. Use establishment transactions whose observed `transaction_timestamp()` values differ.

In the first case, let the first establishment transaction have timestamp t1, force it to abort, and lose its reply. Verify that N is absent and none of its establishment effects committed. Retry in a newly begun transaction with timestamp t2. Assert that the committed N carries restore_instant=t2, not t1. Lose this transaction’s commit reply too. Keep both components stopped, repeat establishment in a transaction with timestamp t3, and assert a matching guarded no-op preserving t2, the predecessor, step marks, endpoint fields and history_evidence_ref. Acknowledge that repeat before either component starts.

In a separate case, let the first establishment transaction commit N at t1 and lose its reply. Repeat in a transaction with timestamp t2 and assert the same preservation and acknowledgement behavior, with restore_instant still t1.

Use null endpoint fields with retained unknown-endpoint reasons for the unknown-evidence runs. Repeat with certified upper-bound evidence using STO-54’s event-clock recipe; assert that the upper bound uses the transaction event persisted by the successful insertion and remains unchanged on matching repeats. Assert no duplicate incident or additional supersession.
```

### D4

SHA256 `8ec8e83b65e4238b61dede26ec6e111d9eb3f220b8c6bff4b32d67dadf4e783e`.

```text
Exercise establishment for one actual restore with incident id N, for backup restore and separately for restore-class promotion. Begin the first establishment transaction at t1, lose its connection/reply, and establish that it did not commit; assert N is absent. Retry the same actual restore with the same id in a newly begun transaction at t2 distinct from t1. Assert N is inserted once with restore_instant equal to t2. Repeat with an open predecessor and assert atomic supersession.

Separately let the first establishment transaction commit at t1 but lose its reply. Retry at distinct t2 and assert a guarded no-op preserving N’s original restore instant, predecessor, step marks, grace end, endpoints and evidence reference, without creating another incident. Neither component starts before establishment or its matching no-op is acknowledged.

Use null endpoint fields with a non-null incident-keyed evidence reference retaining the unknown-endpoint reasons. Also exercise the event-clock upper-bound recipe with certified evidence for the transaction that inserted N; assert it uses the persisted incident instant rather than an uncommitted attempt’s instant or the no-op transaction’s timestamp.
```

### M-opus

SHA256 `c355bb70ebfe826a5238d85197c7914928d730c2694f082f3704f2fbbd8653a4`.

```markdown
      Exercise establishment retries for one actual restore with retained incident id N, once with
      no inherited open incident and once with the preceding paragraph's open predecessor, here R.
      Each establishment transaction below is newly begun, and the harness records its
      `transaction_timestamp()`, distinct from every other's. First force the transaction at t1 to
      roll back and withhold its reply; confirm that N is absent and R, where present, is still
      open. Repeat with N at t2: assert exactly one record N, naming R where present (`STO-56`:
      "MUST close R by supersession and insert a distinct record naming R"), with
      `restore_instant` t2, not t1 (`STO-54`: "restore_instant is transaction_timestamp() of the
      newly begun transaction inserting this incident"). Lose that commit's reply and repeat at t3:
      assert an acknowledged guarded no-op that changes nothing in N, so `restore_instant` stays
      t2, and creates or supersedes no record. Separately let the transaction at t1 commit N and
      lose its reply, then repeat at t2: assert the same acknowledged no-op, with `restore_instant`
      still t1. In every run neither component starts before the inserting transaction or its
      matching no-op repeat is acknowledged. In one run, after that acknowledgement, kill the
      engine after step (2)'s mark commits and, with both components stopped, repeat establishment
      with N once more: assert a guarded no-op leaving `steps_completed` at its marked value and
      `restore_instant` unchanged.
```

### M-sol

SHA256 `aa203f7418d4a20b34c20b91a4ae1fbba7937a78d267fe480c1274879ae4feb0`.

```markdown
      **Establishment retry clock.** Exercise the following arms for one actual restore per run,
      retaining the same new incident id N for all its establishment retries. Run each arm
      with no inherited open incident and with an inherited open predecessor R whose ordinary
      close conditions are unmet. Satisfy the existing stopping/fencing prerequisites. Use null
      `lost_window_starts_at` and `loss_end_at` with a non-null incident-keyed
      `history_evidence_ref` retaining the unknown-endpoint reasons. Read each establishment
      transaction's `transaction_timestamp()` in that transaction; use distinct observed values
      t1, t2 and, for the later repeat below, t3.

      In the aborted-first-attempt arm, force the transaction at t1 to abort and lose its
      reply. Verify in the store that N is absent and none of that transaction's changes
      committed. Retry with N in a newly begun transaction at t2 and let it commit. Assert
      exactly one N with `restore_instant` = t2, not t1.

      In the committed-first-attempt arm, let the transaction at t1 commit N and lose its
      reply. Repeat with N in a transaction at t2 and assert an acknowledged matching guarded
      no-op preserving t1 and the step marks, without refusal merely because t2 differs from t1.

      Keep both components stopped until the insertion or its matching repeat is acknowledged.
      With R, assert that the abort left R unchanged and open, and that the successful insertion
      retains R, closes it by supersession and names it in N's `supersedes_incident_id`.
      For every matching no-op in this case, assert no additional incident or supersession and
      preservation of the committed N's restore instant, predecessor, step marks, grace end,
      endpoint fields and evidence reference.

      After the acknowledged insertion or repeat in each arm, follow the existing procedure
      until step (2)'s mark commits. Stop both components without another actual restore, repeat
      establishment with N at t3, and assert a matching guarded no-op preserving the now nonzero
      step marks as well as the other persisted fields above. Acknowledge that repeat before
      restarting either component. This case selects no comparison algorithm. (`STO-54`, `STO-56`)
```

