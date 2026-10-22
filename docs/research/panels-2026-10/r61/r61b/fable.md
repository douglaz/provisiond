**Votes.** C1 **amend**: as written ("normalized WWN, else normalized serial") plus C2's "lowercased" makes `WIR-10b`'s own `"S4EVNF0N123456"` nonconforming. I wrote: the wire carries the reported value trimmed, `null` where neither value survives `RSC-46`'s normalization; matching and the fingerprint use the normalized form. C2 **accept**. C3 **accept** (canonical bytes alone; total order, no null-placement rule). C4 **accept**: `RSC-38` says "`PRV-22` makes the exit *always* ambiguous, so a failure can strand a customer's machine there", so a doomed install is a reboot that can strand the machine, not a cheap abort. C5 **(i)**: `RSC-26` calls it "an opaque `inventory_fingerprint`", so no client needs `wwn`/`serial` for anything this bead asks, and adding them makes `identifier` a derived duplicate of two sibling fields. C6 **`CNF-363`**, amended to cover `layout.drives[].identifier`; `CNF-47` is about report presence. C7 **accept**; the docstring edits are mandatory, since the citation gate's EXISTS rule finds the old quote nowhere once `RSC-26` changes.

**Contradictions.**
- C1/C2 case clash above.
- Outside: `RSC-46` says "`WIR-20` and `WIR-10b` cite this for the `target.identifier` and `inventory_fingerprint` constraints", yet at `4c0bb4c` neither document contains `RSC-46` (grep). C1 and C4 make the sentence true.
- `CONTEXT.md`: "reports its disks with stable identifiers" vs C1. I amended that one line.
- C3 vs `Witnesses.lean`'s quote "sorted by identifier": C7 covers it.

**Gates.** Three unpiped runs, logs in the clone (`gate-baseline.log`, `gate-amended.log`, `gate-planted.log`), diff in `panel-r61b-fable-good.diff`.

| run | exit |
|---|---|
| baseline | 0 |
| C1–C7 applied | 0 |
| plant: B's `null` → `"/dev/sda"` | 0 |

The plant confirms the known gap: nothing reads the inline example. Side effect worth recording: `RSC-46` gets its first checklist citation (ratcheted uncovered 76 → 75).

**Owner question.** Not quite fair. "Make it impossible for an install to name it" overstates: the caller can send any string; it is refused before enqueue or aborts `integrity`. It omits that such a machine stays sellable with the two strategies omitted (`RSC-26`), and that (c) needs a static signal no requirement provides. Rewrite of the key sentence:

> The panel says list it with `identifier: null`, keep it in the fingerprint, refuse an install that sends no identifier, and abort one that names a device the machine no longer has. (a) Recommended: C1–C7, `wwn`/`serial` deferred to a follow-up bead. (b) Omit such disks. (c) Refuse inventory, which needs a per-machine signal that does not exist today.

**Least confident: C5 (i).** The bead's acceptance reads "`RSC-33`/`RSC-38` agree", and `RSC-33` names `serial` in the minimum report whose purpose is "the record that tells an operator afterwards which disk was actually overwritten". Under (i) a WWN-bearing disk's serial reaches no record, so the acceptance is met by deferral, and the deferral costs a triage, panel and PR cycle for two nullable fields on an object this change already edits.
