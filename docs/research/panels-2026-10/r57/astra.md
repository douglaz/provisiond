1. Choose **B**, with an explicit OPS-49 carve-out. A failure known to precede step 8’s commit belongs in ordinary classification. C creates another classification owner; A unnecessarily changes other operation kinds.

2. Claims 1–6:

   **(1)** Actual commit and acknowledgement differ. `CNF-360` says “Commit step 8 and drop its reply”: the worker still awaits acknowledgement although the column is set. This does **not** refute null-until-commit; it refutes using acknowledgement position as commit knowledge. `OPS-49` says “A worker cancelled during the retry loop stops retrying and exits.” Preserve that path, including before commit. No additional null settlement guard is needed.

   **(2)** Keep driver kinds and apply `retryable: true` to newly cleared ambiguity cases; preserve deterministic refusals’ existing values.

   **(3)** Full release is right, but `STO-3` requires “The guarded status write precedes every money write in the transaction”. Include resource-offer exclusion cleanup.

   **(4)** Model execution phase separately from stored nullness. A free Boolean permits impossible pre-step-8/accepted combinations: preserve `accepted_never_failed` through consistent inputs or acceptance precedence. Test both boundary sides, including cut-off `conflict`.

   **(5)** B preserves post-step-8 pre-send ambiguity without widening other rows.

   **(6)** Scope necessarily overlaps pv-p1y’s disposition: `PRV-47` requires rejection “without any provider mutation for that create”. Its missing error-kind decision remains separate. Step-9 key-upload failures can remain excluded.

3. Edits owed: `OPS-11` introduction, separate create row, last-row references and settlement obligations; `OPS-21` exception explicitly preserving `OPS-49`; `OPS-43`’s classification quotation, preserving its settled steps; `OPS-45`’s execution-only discussion; `LDG-32/39` inclusion clauses. Reference `STO-3`/`LDG-35` atomicity and `STO-58` exclusion lifetime.

   Amend `CNF-31a/b`; add live failure/cancellation, all-channel, retryability, release, exclusion, no-fee/unit-debit and post-boundary controls; extend `CNF-360/294` for retry-loop cancellation. Amend **ADR-0035** for classification, retaining Q11’s order-request rejection; leave ADR-0042’s restart decision intact. Update `Tables.lean`, `Witnesses.lean`, existing CI substitutions and new `ci.yml` negative controls.

4. I planted a cached-null create rule (`/var/tmp/provisiond-panel-r57/astra/r57-wrong-edit.patch`, not committed), reading the claim-returned record. After dispatch, that snapshot incorrectly authorizes `failed`. **Baseline, mutant and restored gates all exited 0**; tracked files are restored. Mutant log (`/var/tmp/provisiond-panel-r57/astra/r57-wrong-edit-gates.log`, not committed). Controls must reject stale-null classification after dispatch and omitted cut-off conflict before the boundary. Bind prose to the model too: model-only controls cannot catch this edit.

5. No mandated equivalent pre-read found for delete, power, reverse DNS or release. `PRV-13` says “MUST NOT issue `GET /server/{n}/cancellation` as a pre-read”; `API-16` uses the “recorded address list”; `PRV-45` lists attachments “on every delete that succeeds with the resource gone”. A demonstrated additional driver pre-read deserves a separate bead.

6. Status-quo advocate: conservative classification avoids trusting fallible phase bookkeeping and preserves pre-send ambiguity. `API-51` warns of “a second purchase”; `OPS-33` requires a “bounded negative window”. Accept temporary commitment retention rather than invite duplicate orders through a mistaken early-failure exception.