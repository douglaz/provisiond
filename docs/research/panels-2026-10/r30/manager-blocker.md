Selected `pv-ucs.7` (ADR-0038), the first open ticket in the caller's exact sequence, at repository HEAD `d76a23b`. Claimed it with `br update --status in_progress`. The blocker is recorded on that ticket in comment **260**; no new bead was filed. `pv-ucs.9` remains unselected. No specification or gate implementation was changed, and no Implementer brief was written.

The owner must clarify the wire provenance after an operator-only restriction is withdrawn. This does not reopen the accepted enum, independent observations, OR combination, or removal of the provider-based recording refusal.

## Passages that need reconciliation

Read ADR-0038 first, then its cited r24 synthesis and the underlying r24 answers. Locations below refer to the current checkout, not the ticket's older line numbers.

- `docs/adr/0038-a-network-restriction-is-positive-evidence-from-either-source.md`, Decision 2, lines 33–39: “The view is `restricted` if either is positive and `unknown` otherwise.” The provenance rule there is: “Its `source` is the positive one (`provider_api` where both are) and its `observed_at` is that source's.” This settles the positive cases but does not state provenance after the only observation is withdrawn.
- The same ADR, Decision 3, lines 40–42: “A withdrawal clears only the operator's own record, after the unlock is granted.”
- `docs/research/panels-2026-10/r24/synthesis.md`, lines 25–29, specifies nullable `provider_restricted`, `provider_observed_at`, and `operator_recorded_at`, with derived source and withdrawal touching only the operator's column. Its Edits section gives “render rule: provider positive, else operator record, else last read” and explicitly says “CNF-250 unchanged.” The ticket repeats the unchanged instruction.
- `10-conformance-checklist.md:2445`, **CNF-250**: “`network_restriction.source` is null exactly when nobody has looked”. Its fresh-machine example is `{"status": "unknown", "source": null, "observed_at": null}`.
- `05-persistence.md:270` currently says “**Null exactly when nobody has looked**”; line 271 says “Null with a status of `unknown` means nobody has looked”. These are the old columns due for amendment, but the checklist's equivalent wording is expressly to remain.

The underlying r24 answer in `fable.md` exposes the conflict: it proposes “`operator_recorded_at` (null means no record)” and then concludes “Source is null exactly when both columns are null, so `CNF-250` holds unchanged.” Absence of a retained record and absence of any past observation cease to be equivalent after withdrawal. The synthesis does not resolve that distinction.

## Concrete trace and different readings

Start with a machine for which no provider restriction reading has ever been recorded, as is possible with a provider that exposes no signal. The operator records a restriction at `t1`, then withdraws it at `t2` after the unlock is granted. No provider reading intervenes. The status after withdrawal is unambiguously `unknown` under the accepted ADR. The returned source and time are the unresolved part.

1. **Provenance describes retained observations.** Withdrawal clears the operator's record. With no provider reading, the derived object is `{"status": "unknown", "source": null, "observed_at": null}`. This implements the compact column shape and clearing rule, but requires changing or explicitly qualifying CNF-250's “exactly when nobody has looked”: the operator did look and record.
2. **Provenance preserves whether anyone ever looked.** CNF-250's historical reading requires non-null provenance even after the positive operator record is withdrawn. The specification would need to say what operator evidence survives withdrawal and which instant renders: the former observation at `t1` or the withdrawal at `t2`. The listed nullable operator timestamp alone cannot both be cleared to remove the positive and retain this provenance.

These readings produce different machine and joined case JSON. Choosing between them is a specification behavior decision, not gate tooling or wording within an already settled behavior. Adding a withdrawal history field, assigning a synthetic provider observation, or silently changing the meaning of the unchanged checklist would make that decision without the owner.

## Clarification recommended

Confirm that **null source/time means no retained observation**, including after an operator-only withdrawal when no provider reading exists. Authorize a dated ADR-0038 clarification and corresponding amendment of CNF-250's universal wording, preserving its fresh-machine fixture. Add this trace to the withdrawal coverage in CNF-233. This keeps the accepted independent-observation model and does not add history just to retain a withdrawn warning's provenance.

If the owner instead wants historical provenance to survive, specify the retained evidence and exact post-withdrawal source/time before implementation. This report recommends the first reading but does not adopt it.

