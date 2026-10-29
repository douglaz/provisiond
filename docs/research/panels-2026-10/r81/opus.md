I pick **A**. **A: ACCEPT. B: CANNOT ACCEPT as printed.** On question 4, a new CNF case is needed (**YES**); a new gate is not (**NO**). My clone is clean at the pin and I wrote nothing outside `/var/tmp/provisiond-panel-r81/tmp/opus/`. A fuller copy is in `/var/tmp/provisiond-panel-r81/tmp/opus/answer.md`.

apply notes.md rule 6 exactly as written; this prompt adds no void rule.

## 0. What I checked

- **PostgreSQL 18, §9.9.5:** I read the official page. It says these functions "return values based on the start time of the current transaction", that "their values do not change during the transaction", and that "`transaction_timestamp()` is equivalent to `CURRENT_TIMESTAMP`". The brief's claim holds: a later transaction gets its own start time.
- **Base claim:** the definition is at `05-persistence.md:1613` in 7974839, and the diff from 7974839 to c824e4f does not touch it. Confirmed.
- **Gate with each option applied** (scratch copies, unpiped `nix develop --command bash tools/check-all.sh`):
  - A: exit 0.
  - B: exit 0.
- **Negative control:** A's Markdown and ADR edits with `Restore.lean` left at the pin make `check_citations.py` exit 1 ("1 Lean docstring quote(s) found nowhere", the old STO-54 sentence). So A3–A8 are forced by the gate, not optional.
- **The CNF text in §4:** added to both copies; citations, coverage and ids gates each exit 0.
- **One brief defect** (rule 6; it doesn't change the question and no vote rests on it): A3 says it replaces `Restore.lean:21–28`, but line 21 is blank and A3's text has no blank line. Applied literally it merges two docstring paragraphs. I applied it to lines 22–28.

## 1. Is the conflict real? Yes, but only when the first attempt doesn't commit

- **Unsupported premise, not a contradiction.** P says "select and retain one new incident id and restore instant per actual restore before attempting establishment". At the pin, the only valid restore instant is a transaction's start time. A value picked before T1 begins can't be T1's start. So the archived committed trace ("The operator retains N's chosen id and restore instant") only works if the operator reads `transaction_timestamp()` inside T1, before the insert. That's possible, so it isn't a contradiction.
- **(ii) T1 commits but its reply is lost.** N is stored with t1. The repeat T2 is STO-56's guarded no-op, "preserving its step marks and original restore instant", and inserts nothing. STO-54's "newly begun transaction inserting this incident" is T1. Both rules hold: **no contradiction**.
- **(i) T1 doesn't commit and no N exists.**
  - The operator can't tell this from (ii), so it is a lost-reply retry.
  - Recovery needs an insert, because STO-54 says the deployment "MUST start neither component until the transaction that commits `STO-56`'s record (below) has been acknowledged".
  - When T2 inserts N, STO-56 ("reuse both on a lost-reply retry") requires t1, and STO-54 ("transaction_timestamp() of the newly begun transaction inserting this incident") requires t2, which differs.
  - This holds wherever the operator reads the time. No stored value satisfies both MUSTs: **a real contradiction**.
- The r77b line "an uncommitted first attempt establishes N once" is right about how many records exist. It says nothing about which instant they carry.

## 2. Pick: A — ACCEPT A, CANNOT ACCEPT B

**Why A:**
- It keeps the owner-adopted P retry paragraph word for word. It changes only the definition that P's retained instant contradicts.
- Afterwards, no live passage still describes the old clock: nothing outside `docs/research/` and `.beads/` mentions `transaction_timestamp`, "incident transaction", "incident-creation" or "newly begun".
- **Traces:**
  - Case (i): T2 inserts (N, t1, R), supersedes R and writes provenance; it is acknowledged before the components start.
  - Case (ii): the repeat matches the stored t1 and is a no-op; it is acknowledged before start.
  - If a different restore reuses id N, its new instant hits "A mismatch in the id's restore instant … MUST be refused".

**Why not B: two defects in the printed words.**

1. **The instant comparison is either incoherent or blocks recovery.** B no longer has the operator keep an instant ("select and retain one new incident id"), but it still says "A mismatch in the committed id's restore instant or predecessor MUST be refused with both components stopped". A repeat has nothing to compare against.
   - *Reading 1:* the natural upsert compares the repeat's own `transaction_timestamp()`.
     - Then every repeat in case (ii) mismatches (t2 ≠ t1) and is refused, every time.
     - That conflicts with STO-56 `05-persistence.md:1446–1447` ("The initial establishment or its matching no-op repeat MUST be acknowledged before either component starts") and STO-54 `:1633–1634`. The first reply was lost and a matching no-op can never happen, so the components never start.
     - **This is a verified blocking loss (rule 3).**
   - *Reading 2:* nothing is compared, so the instant half of the rule is dead text.
     - Trace: the restored store holds a closed N with no predecessor, and a new restore wrongly reuses N. B treats it as a matching no-op and the components start with no open record.
     - STO-54 calls that "an ordinary restart" — the destructive boot this requirement exists to prevent — and the marker-provenance setup is skipped.
     - P refuses this case. The operator has to break "A new actual store restore uses a distinct id" to reach it, so **I count this reading as a disclosed, non-blocking loss**. It still needs the owner's approval.
2. **Two MUSTs overlap.** "finds no committed matching record … MUST insert" also covers a committed N whose predecessor differs. There one MUST says insert and the next says "MUST be refused". The intended condition is "no committed record with that id".

**B′ — an exact alternative, labelled as a repair of B, not my pick.** I would accept it as a form. It knowingly gives up the instant as a check against a reused id, and it picks no predecessor-comparison algorithm (R2 stays excluded). It replaces `05-persistence.md:1442–1448`:

```text
The operator MUST select and retain one new incident id per actual restore before attempting
establishment, and reuse that id on a lost-reply retry. If establishment with that id finds no
committed record with that id, it MUST insert the incident with restore_instant defined by STO-54
for the newly begun transaction inserting it; the timestamp of an earlier attempt that did not
commit is not reused. Repeating establishment with that id when a committed matching record
exists MUST affect that record as a guarded no-op, not create or supersede another record,
preserving its step marks and original restore instant; the repeating transaction's own
timestamp is not compared with that instant. A mismatch in the committed id's predecessor MUST
be refused with both components stopped. The initial establishment or its matching no-op repeat
MUST be acknowledged before either component starts. A new actual store restore uses a distinct
id even when the predecessor incident is still open.
```

**Requested counterargument (against A):** A rewrites the clock the owner approved under UO. It swaps a database-generated value nobody can forge for an instant a person picks, from a clock A never names. The stored "incident creation" time no longer has to come after the restored store exists or after recovery ends; it can precede the real insert by the whole retry interval, or even the whole backup restore. B keeps the clock mechanical and changes only P's hours-old retry wording. The protection B gives up only matters if the operator breaks another MUST. On that view B′ costs less than A.

## 3. Substance and side effects

**What is substantive and what is synchronization:**
- Substantive in A:
  - A1 changes the definition to "the instant selected before the first attempt".
  - A2 moves f's anchor from "that transaction's start" to "that selection".
- Editorial in A:
  - A3–A8, the Lean docstrings, are forced by the citation gate.
  - A9, the ADR, is required by AGENTS.md's quoting rule; the gate doesn't read ADRs.
- All of B is substantive: it qualifies the adopted P retry rule rather than re-applying P.
- Either way the owner must approve the change: A departs from UO's adopted definition and B from P's adopted text.

**What UO's definition protected, and what A keeps:**
- The event is separate from the recovered history: **kept** ("not the time of the recovered history").
- The event comes after stopping and fencing: **kept** ("The selection occurs after the existing stopping/fencing requirements are satisfied").
- A single database clock nobody can forge: **lost**.
  - Certificates stay true: an unverified clock gives an unknown f ("A verified upper error bound on the selected event time's clock"; "record their provenance").
  - No checked verdict changes, because no CNF item checks the value.
- The event always comes after recovery ends: **lost** (disclosed, not blocking).
  - STO-54 stops components "Before the restore begins", so under A the selection can come before the restored store exists.
  - A replayed non-component record created after the selection can make b = s−e exceed f = t1+e_event. "Known b and f MUST … satisfy b≤f" then sends the report to "Inconsistent endpoint evidence is invalid", i.e. unknown.
  - At the pin the insert runs on a recovered store, so b ≤ f always holds.
  - No certificate becomes false. Nothing else needs the instant to come after the store lands: ADR-0028 withdrew the deadline that did, and CNF-295 asserts grace uses "its own event, not b, f or restore_instant".
  - An optional, separate tightening, not a condition of my acceptance: add "and after the restored or promoted store has finished recovery" to A1's third sentence.

**What P's retained instant protected:** a check against a reused id that doesn't depend on the lost reply. A keeps it; B loses it (§2).

**Everything else the brief asked about:**
- Stopping/fencing, the unknown path and endpoint reuse ("Continuations reuse the persisted endpoints and evidence unchanged") are unchanged under both.
- The certificate wording for b, including "generated before insertion", is unchanged.
- Record/start boundary: A completes both cases. B as printed gets stuck in case (ii) under reading 1.
- Marker provenance and supersession happen in T2 under both, because T1 rolled back.
- Step marks and grace are anchored to their own events and are unaffected.
- Continuation ("read from the record and never re-computed") holds under both.

**Formal model:**
- `restoreInstant : Nat` is abstract, and the model has neither an establishment retry nor a second clock.
- `RestoreTrace.store` (tagged STO-54) sets `restoreInstant := t.now`, which stays correct under either meaning.
- No declaration, theorem or guard hypothesis has to change.

**Nothing missing from the packet:**
- No CNF, WIR, OVR-19 or CONTEXT passage needs a forced replacement; the OVR-19 clock-evidence row is generic.
- Frozen research files and `.beads` still quote the old text; they are evidence, not targets.
- A new owner-decision record is owed after adoption.

**Consistency with earlier decisions:**
- E-KEEP: A2 changes only the event-clock anchor. The source recipe ("e bounds the source clock's error") is untouched and no precision policy is added.
- pv-kwuf: "Whole milliseconds" governs only the Startup-lock wait bound, which neither option touches.

## 4. Separate CNF/gate question: CNF YES, gate NO

**Why a CNF case:** nothing tests this today. CNF-302's "A lost transaction reply must not produce two open incidents" checks how many records exist, not which instant they carry or whether recovery can proceed. This case catches three failures:
- the wrong instant stored in case (i);
- every committed repeat refused (B's reading 1);
- a second record created.

It points to STO-54 for the value instead of restating it, so it works under A, B′ or whatever the owner adopts.

**Why no gate:** this is runtime behaviour no Markdown gate can see. The Lean model has no retry and one clock, so no theorem can express it. The citation gate already catches the wording drift, as the negative control showed.

**Exact words:** append to CNF-302 right after "…or silently continue using predecessor step marks.":

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

**Votes:**
- Pick: A.
- A: ACCEPT.
- B: CANNOT ACCEPT. The blocking loss is reading 1 of its instant comparison, and its insert and refuse MUSTs overlap.
- B′: an acceptable form, not my pick.
- Q4: CNF YES, gate NO.
