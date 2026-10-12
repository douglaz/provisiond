STATUS: blocked

# pv-ucs.10 — Round 1 Manager decision, 2026-10-12

The specification needs an owner clarification about temporary-key deletion after operation retention. Another implementation round cannot resolve this by choosing a reading. The Q24 and Q25 repairs remain in history; this report does not approve the ticket as complete.

I reviewed change `36fb969b0673b8af3689e9400fc3ba9794dad304` against the brief; the result is **FAIL**, blocked by the owner question below.

Base: `bedd9a5f47ed42ab319b9e47418fafa43f075429`.
Implemented work: `36fb969b0673b8af3689e9400fc3ba9794dad304` (`pv-ucs.10: complete Q24 and Q25 spec repairs`).
Current HEAD: `1f70010edb55987ede8424c13231f954ee7736e6` (`beads: record pv-ucs.10 retention clarification block`).

The Implementer completed normally. Its changes broaden the affirmative sweep duty to cover the lost-registration-reply case, add Q25's future-bound sale exclusion and conformance cases, restore the authorized PRV-13c selector wording, and qualify the exposure-bound claims. Those repairs are retained. The Manager made no specification, formal-model or gate edits, and committed only the tracker disposition after review. No history was rewritten, and no hook or signing bypass was used.

## Owner clarification required: vanished operation versus provisioning guard

These passages give different deletion outcomes for the same reachable state:

- **02-provider-contract.md, PRV-9:** “A tagged temporary key still registered at the provider MUST be deleted by `OPS-32`'s sweep when, and only when, its operation has settled or vanished and no machine it produced still reads `provisioning`, whether or not an order was accepted.”
- **The same requirement:** “The sweep MUST delete a tagged key whose operation record has vanished, because no machine from an unrecorded operation can be attached.”
- **05-persistence.md, STO-14:** “A retention job MUST remove **settled** operations older than a configured age”. Its exclusion is for `needs_reconciliation`, not for a settled create with a provisioning machine.
- **10-conformance-checklist.md, CNF-303:** “After successful settlement, keep the create's machine in `provisioning` and assert the key remains; once a later observation clears that guard, assert the sweep deletes it.”
- **ADR-0040, Decision 2:** “A temporary key is deleted only once its operation has settled or vanished, and no machine it produced still reads `provisioning`.” Its following bullet also says: “A key whose operation record is gone is deleted, since an unrecorded machine is never attached.” The Q24 amendment requires the sweep to delete “once Decision 2 permits it”; it does not resolve this conflict within Decision 2.

Concrete trace:

1. A create or its resolution attaches a machine and settles while that machine still reads `provisioning`, as CNF-303 explicitly permits.
2. Its tagged provider-side key remains. The machine has not yet been observed past provisioning when the configured operation-retention age passes.
3. Retention removes the settled operation row.
4. The next sweep finds the tagged key. The operation has vanished, but its already-attached machine still reads `provisioning`.

Under the conjunctive reading, the sweep retains the key until the machine clears provisioning. Under the unconditional vanished-row reading, it deletes the key now. “No machine … can be attached” addresses a later attachment from a missing operation, not the machine attached before retention. The distinction can determine whether a provider can finish consuming the key and deliver an accessible machine.

The formal layer currently selects the second reading. `tools/formal/Provisiond/Rescue.lean`, `Provisiond.Rescue.Session.keyEligible`, is:

```lean
!w.recordPresent ||
  ((w.status == .succeeded || w.status == .failed) && !w.producedProvisioning)
```

With `recordPresent = false` and `producedProvisioning = true`, the predicate is true. The witness in `tools/formal/Provisiond/Witnesses.lean`, `temporary_key_eligibility_witness`, tests provisioning retention and vanished-row removal separately, not their conjunction. Its green result therefore does not resolve the contradictory obligations.

**Requested clarification:** Does provisioning protection survive operation retention? If so, should retention defer removal of the operation until key-cleanup eligibility, or should the required association survive operation removal? Alternatively, does the owner explicitly intend vanished-row deletion to override the provisioning guard and accept its consequence? Clarify the governing rule before selecting a storage mechanism.

**Recommendation, not an applied decision:** preserve provisioning protection and ensure the association needed to enforce it survives. Consider a narrow retention exception first, rather than adding another independent record. Any chosen answer must align ADR-0040, PRV-9, OPS-32, STO-14, CNF-303 and the tagged Lean predicate/witness. This is a new retention interaction, not a request to reconsider the settled sweep-only cleanup choice.

## Conformance repair to retain on this ticket

CNF-166's positive case now allows only a bound “no later than provider-local today” but still asserts that “a shorter actual date then **lowers `protected_sats` against rather than resizing**”. For a day-only bound of today and an actual date of yesterday, this cannot be a strict reduction from the date term: PRV-13 says “A date equal to the provider's today has passed”, and LDG-33 includes only “cost through any future permitted-from date to its provider-local day end”. Both dates contribute zero to that term with other inputs fixed.

Correct this expectation in the owner-authorized continuation: test legal v1 admission, the zero date contribution and unchanged commitment without requiring a strict decrease. Keep the separate Q23c date-pricing coverage and Q25's prohibition on selling future-bound offers. This is a conformance requirement defect, not cosmetic prose. It needs no new commercial decision and does not independently require an adviser consultation.

## Panel disposition and evidence

- **Astra:** completed, no findings. Considered; it does not override the confirmed retention counterexample.
- **Sol:** completed. Accepted the retention/provisioning conflict after independent inspection. Its CNF-166 suggestion identifies a real expectation problem, but the suggested nonzero-date fixture is not imposed: requiring a future-bound v1 sale would contradict Q25. The repair above stays within the existing decision.
- **Fable and Opus:** each report is `REVIEWER NOT RUN (unavailable)`. They supplied no review and are not counted as agreeing or dissenting.
- No rejected-agent artifacts were found in this run directory. No adviser consultation was run: an owner specification conflict cannot be settled by an implementation vote.

The Manager's unpiped `nix develop --command bash tools/check-all.sh` passed before review. The Implementer's verification continuation records the full gate, the standalone CI controls and all source guard rows in one restored repository-local copy, then its deletion. The Manager inspected that record; it is not a claim that the Manager independently repeated the negative-control rehearsal. The final Manager gate result is recorded below. `git diff --check` passed. No provider API or live account test was called.

## Tracker and handoff

All follow-ups were appended to **pv-ucs.10's notes**, preserving earlier notes and owner comments. No new bead was created. Per the caller's terminal Option A instruction, the ticket is **closed with an explicit blocked reason**, not a completion assertion. Reopen this same ticket for the owner-authorized continuation.

Only pv-ucs.10 changed in the flushed tracker. Its disposition is committed in `1f70010`; the tracked worktree is clean. The run artifacts, including this report, remain under the ignored `.rloop` directory. There are no uncommitted specification edits or rehearsal copies left by the Manager.

Final verification at `1f70010`: the unpiped `nix develop --command bash tools/check-all.sh` completed with exit **0**, all gates passed. No specification or tool changed after that check.
