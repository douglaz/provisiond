## r82: opus's reading

**Rule 6:** I found no brief error that changes a question's premise. I checked the brief's anchors against my clone at c824e4f:
- `05-persistence.md:1442–1448` is the old retry paragraph that B replaces.
- CNF-302's lost-reply sentence sits at `10-conformance-checklist.md:3086–3087`, the table at 3089, and CNF-303 begins at 3098.
- CNF-295 runs from 1019 to 1093.

The r81 tally's `:3076` link points into another clone, so it is line drift, not a premise error.

### Q1: merged form, landing CNF-302

**Insertion point.** In CNF-302, directly after line 3087 ("…or silently continue using predecessor step marks."), add one blank line and then this paragraph. The existing blank line at 3088 and the install table at 3089 follow it unchanged. It uses the item's 6-space indent.

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

**Where each part comes from**

| Text | Source |
|---|---|
| Retained id N, reused on retry | B: "select and retain one new incident id … reuse that id on a lost-reply retry" |
| Runs with and without R | Fixture taken from the preceding CNF-302 paragraph |
| Distinct, recorded `transaction_timestamp()` values | Harness fixture only; places no duty on the implementation |
| Roll back at t1; N absent, R still open | Fixture check that the arm really aborted. R still open follows from the quoted STO-56 duty that the establishing transaction closes R. |
| One N naming R | Pinned STO-56 duty, quoted |
| `restore_instant` t2, not t1 | B: "MUST insert … with restore_instant defined by STO-54 … an instant selected for an earlier attempt that did not commit is not reused"; STO-54 quoted |
| No-op at t3 and in the committed arm | B: "MUST affect that record as a guarded no-op, not create or supersede another record, preserving its step marks and original restore instant" |
| No start before acknowledgement | B: "The initial establishment or its matching no-op repeat MUST be acknowledged before either component starts" |
| Repeat after step (2)'s mark | Same no-op sentence of B. This is the **only new trace**. |

**Why the step (2) trace is there.** B's no-op sentence has no timing condition. I grepped STO-54 and STO-56 and found nothing that forbids repeating establishment while both components are stopped. At the lost-reply point `steps_completed` is 0, so in every draft "preserves step marks" is vacuous: an upsert that resets the marks to 0 passes. Step (2) has an explicit mark in STO-54 ("Its mark keeps this step from running again"), and CNF-295 already kills the engine around it.

**Deliberately not asserted**
- The mismatch refusal: it needs a comparator and depends on Q2.
- Any endpoint derivation: STO-54 only says the recipe "can supply f=restore_instant+e_event".
- Marker provenance.

**Wrong results this case catches**
1. The tool captures an instant client-side before t1, as under the old pinned rule, or reuses t1. The aborted arm requires t2.
2. An upsert of the form `ON CONFLICT (id) DO UPDATE SET restore_instant = transaction_timestamp()`. Both no-op checks fail it, because t2 ≠ t1 and t3 ≠ t2.
3. A comparator that refuses because the repeat's timestamp differs. The committed arm requires an acknowledged no-op.
4. A repeat that treats the open N as a predecessor and supersedes it, or that re-closes R. "Creates or supersedes no record" catches it.
5. An upsert that resets the marks. The step (2) trace catches it.
6. A supersession committed separately from the insert. R would no longer be open after the rollback.

**Verification** (temp copy only; my own clone shows no changes):
- With B applied and this paragraph inserted, the unpiped `nix develop --command bash tools/check-all.sh` exits 0 (`tmp/opus/gateB.log` for an earlier draft with the same quotes, `gateF.log` for the final text).
- With REPLACE also applied, it exits 0 again (`gateR.log`).
- Negative controls: corrupting one word of the STO-54 quote makes `check_citations` exit 1 (neg1, neg3), and so does corrupting the STO-56 quote (neg2). Both quotes are therefore checked.
- Both quoted spans exist at the pin, so the citation gate does not depend on the order in which B lands.

**Verdicts on the four drafts, each with its proposed landing**

- **D1 (fable, CNF-302): CANNOT ACCEPT as printed.**
  - It never requires distinct timestamps. If the two coincide, the committed-run check "it is the first transaction's" passes an overwriting upsert.
  - The aborted run never confirms that N is absent.
  - "Not an instant captured before the first attempt" targets an A-shaped implementation rather than the aborted transaction's own t1.
  - Step marks are vacuous.
  - Repair: add "in a transaction whose `transaction_timestamp()` differs from the first's" to both runs, and "confirm no record with that id exists" before the aborted run's repeat.
  - Its quote is from B's no-op sentence, which Q2 does not touch, so it only passes once B has landed.
- **D2 (opus, CNF-302): CANNOT ACCEPT as printed.**
  - "Its `restore_instant` the value `STO-54` defines" is an unquoted claim about STO-54 (AGENTS.md, "Quote the sentence") and never names t2 against t1.
  - "Its predecessor closed by supersession and provenance initialized" assumes a predecessor in every run, and asserts STO-54's marker-provenance duty without its words.
  - Absence after the abort is assumed, never checked.
  - Repair: state "= the repeating transaction's `transaction_timestamp()`, not the first's" with the quote; run with and without R; drop the provenance assertion or quote it.
- **D3 (astra, CNF-302): CANNOT ACCEPT as printed.**
  - Its certified-upper-bound sentence asserts that "the upper bound uses the transaction event persisted by the successful insertion". STO-54's recipe is permissive ("can supply"), and nothing requires a known bound to be persisted. An implementation that persists a null f, or a sound f from a fence that also preceded t1, conforms and fails this check.
  - Repair: delete "Repeat with certified upper-bound evidence … on matching repeats." The rest is sound, apart from its vacuous step-mark check, and is the closest draft to mine.
- **D4 (sol, CNF-295): CANNOT ACCEPT as printed.**
  - It has the same event-clock overreach as D3.
  - Its "grace end" check compares null with null.
  - CNF-295 is the human rehearsal "Before the first customer payment, by someone other than whoever wrote the procedure". The lost-reply sentence lives in CNF-302, so this landing splits the coverage.
  - Repair: delete the event-clock sentence and land it in CNF-302.

### Q2: KEEP or REPLACE

**Labels used below**
- S2: B's insert sentence ("finds no committed matching record … MUST insert").
- S3: the no-op sentence.
- S4: the mismatch refusal.
- S5: the acknowledgement sentence.
- I: "matching" means a record with that id.
- F: "matching" means that id plus every compared field.

**Which sentences apply on each trace**

| Trace | KEEP, I | KEEP, F | REPLACE, I | REPLACE, F |
|---|---|---|---|---|
| (i) no committed N | S2 insert | S2 | S2 | S2 |
| (ii) committed N matches | S3 no-op | S3 | S3 | S3 |
| (iii) committed N, predecessor differs | S3 and S4 overlap, inherited from the pinned text | **S2 insert and S4 refuse** | S3 and S4, same as KEEP-I | S4 only |
| (iv) F only: N differs in some other field | — | S2 insert alone | — | No rule applies; S5 still holds both components stopped |

**The S2 insert on (iii) and (iv) cannot be carried out.** In every retry trace N is open, and STO-56 says "at most one row may have `closed_at` null, a partial unique index over the table". As a supporting point, outside STO-56's wording: `supersedes_incident_id` is a foreign key to `id`, and PostgreSQL requires a foreign-key target to be unique.

On (iv) under REPLACE-F, components still cannot start, because neither "initial establishment or its matching no-op repeat" has been acknowledged (S5).

**What "matching" protects.** It makes S2 the literal complement of S3, so a repeat never inserts when a matching record exists. REPLACE keeps that guarantee, since a matching record has that id. Under reading I the two phrases mean the same thing.

**(a) Behaviour change: NO.** The achievable outcomes are the same on every trace. Wherever the two wordings differ, KEEP's insert cannot be carried out and S5 holds both components stopped.

**(b) Requirement change: NO.** Disclosure: under reading F, REPLACE narrows S2's trigger, but only on traces (iii) and (iv), where its insert cannot be carried out. It removes no duty that could be met.

**(c) Check-strength change: NO.**
- Outside archived panel research, "matching record" appears only in pinned `05-persistence.md:1444`, which B replaces. No CNF and no Lean declaration contains it.
- `Restore.lean` does not model incident ids or establishment retries; its record has only `graceEndsAt` and `restoreInstant`.
- The full gate exits 0 under both wordings, and my case exercises only traces (i) and (ii).

**Acceptance and preference.** KEEP: ACCEPT. Reading I makes it consistent, as r81's checked verdict found. REPLACE: ACCEPT. I prefer REPLACE because it removes reading F's insert-versus-refuse overlap on trace (iii).

Final Q1: exact merged form above; CNF-302; new paragraph immediately after line 3087 ("…or silently continue using predecessor step marks."), preceded by one blank line and followed by the existing blank line and the install table at 3089

Final Q2: REPLACE; behaviour change NO; requirement change NO; check-strength change NO (KEEP ACCEPT, REPLACE ACCEPT)
