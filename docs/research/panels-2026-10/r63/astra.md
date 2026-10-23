Reviewed pv-s4m and pv-n98 at `dc5d40d`: amendments required. No gates or Lean builds run; tracked files unchanged.

**Q1 — AMEND A; behaviour changed. Owner:** accepting an outage and token invalidation on every promotion is a product decision.

Keep A’s `OPS-15` deletion. In its `STO-5` note, replace “after its primary failed” with “whether planned or unplanned”. Replace its new `STO-54` paragraph with:

> **Every promotion of an asynchronous standby is a restore, including a planned switchover.** Before promotion, the deployment MUST inhibit component starts, stop every engine and `api` process, and deny their connections to the candidate. It MUST commit a new restore record before admitting fresh processes. An existing `api` process MUST NOT reconnect across the handoff. A candidate containing an open restore record MUST remain unavailable to both components; its completed marks MUST NOT authorize startup after another possible loss.
>
> For step (1), the deployment MUST publish a numeric upper bound on the possibly lost interval, together with its evidence, and record the corresponding conservative recovered-through instant as `restore_instant`. A missing replay timestamp MUST NOT be reported as zero loss. Without an evidenced bound, both components remain stopped. The whole procedure applies even where no write was lost.

The timestamp alone is insufficient: PostgreSQL describes a “commit or abort WAL record” and says “If no transactions have been replayed during recovery, the function returns `NULL`.” [PostgreSQL documentation](https://www.postgresql.org/docs/current/functions-admin.html#FUNCTIONS-RECOVERY-INFO-TABLE) An available timestamp can inform the bound; it is not universally available.

The connection boundary is deployable with the explicit supervisor and connection interlock above; automatic restart alone supplies neither.

Use **CNF-365**: repeat `CNF-295` through promotion, losing the claim and step-8 write separately; assert no duplicate order or erroneous failure/release. Exercise premature supervisor restart, surviving `api`, planned switchover, missing timestamp, and inherited-open-record refusal.

Touches: `STO-5`, `STO-54`, `OPS-15`, `CNF-365`, `ADR-0045`; synchronize the Restore glossary and model scope documentation.

**Q2 — AMEND A; behaviour changed. Mechanics:** separate process initialization from durable incident progress.

Keep A’s running-row rule and checklist change. Replace its proposed step-(2) addition with:

> Step (2) comprises the queued-row quarantine and initial holding of unsettled suspension parents. Its mark never suppresses `OPS-15`’s pass over `running` rows at each process startup.

Replace “`permits.claim` needs both” with:

> In restore mode, claiming requires `locked && passDone && stepTwoMarked`; ordinary restart requires `locked && passDone`. A crash clears the process’s `passDone` and preserves `stepTwoMarked`.

Add to the model work:

> Model admission of fresh queued work after step (3), and its provider application, so the post-mark create/crash trace is expressible. Preserve the no-second-order theorem’s conclusion; the quarantine invariant must distinguish restored work from subsequently admitted work.

Without that addition, the current `Event` type cannot produce the brief’s newly admitted create. Merely splitting flags could leave the central regression outside the proof.

`CNF-295` must inspect the successor before claims or resolution obscure the transition, and verify a later delete is no longer deferred by the stranded power row.

Touches: `OPS-15`, `STO-54`, `CNF-295`, `Restore.lean`, associated witnesses.

**Q2b — ACCEPT A / A1. Owner:** this chooses automatic continuation after the suspension exception’s freeze ends, resolving conflicting existing wording.

Replace `OPS-15`’s blanket restore-parent clause with:

> While `STO-54` freezes the `suspend_tenant` exception, an unsettled parent found `running` or `queued` waits for operator confirmation and is not claimed. Once that freeze has lifted for the exception, a parent found `running` MUST return to `queued` and resume without renewed confirmation.

Replace its later parenthetical “on a restart; after a restore it waits, above (`STO-54`)” with:

> unless `STO-54` freezes the exception, in which case it waits as above

A1 preserves `STO-54`’s stated condition: “until the operator has confirmed or cancelled every waiting parent”. Make `passOp` consult the effective freeze permission rather than `Fault.isRestore` alone. Add the post-freeze parent crash case to `CNF-295`.

Touches: `OPS-15`, `CNF-295`, `Restore.lean`, witnesses.

**Q3 — Yes, one Run; mechanics:** shared `OPS-15`/`STO-54` edits and promotion rehearsal should exercise the corrected successor behavior together.

**Against my picks — written on request**

- **Q1:** Every planned switchover becomes disruptive despite demonstrable zero loss. Refusing candidates with inherited open records further sacrifices availability; a proven lossless handoff could avoid both costs.
- **Q2:** Expanding the model’s event vocabulary increases proof work. A narrower transition lemma plus conformance evidence might establish the needed startup behavior with less formal machinery.
- **Q2b:** A1 relaxes `OPS-15`’s explicit “does not fire on a restore”; A2 conservatively requires renewed human attention throughout the incident.
- **Q3:** Promotion policy needs owner approval; bundling can delay an independently useful startup-pass repair.

**Brief errors**

- Literal `promot` claim: `rg -n promot 01-domain-model.md` also finds “promoted to a property of the domain”. The standby-specific claim holds.
- The stranded-row assertion needs qualification. `rg -n -A 3 '^\*\*OPS-8\*\*' 03-operation-lifecycle.md` says “not yielded” and shows `yielded_at IS NULL`. A yielded running row does not itself block subsequent claims through that index.