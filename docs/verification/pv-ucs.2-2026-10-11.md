# pv-ucs.2 verification — 2026-10-11

Implementation target: ADR-0034's Q19, Q20 and Q20b amendments. Starting HEAD:
`dec039f` on `pv-ucs-impl`. The Manager's `in_progress` Beads claim was preserved.
This report supersedes the 2026-10-08 implementation report as evidence for the
current revision; that report remains implementation history.

## Ownership and conformance

| Amendment | Normative owner | Unchecked implementation cases |
|---|---|---|
| Refresh window and claim-time cache | `DOM-8`: "A deployment MUST state a finite, positive refresh freshness window no shorter than the account-sweep interval" and "Startup MUST refuse a shorter window" | `CNF-331`, `CNF-332`, `CNF-339`, `CNF-351` |
| Complete present writes and failed absence confirmation | `OPS-32`: "A complete pass MUST write the observed state and `machines.state_observed_at` (`STO-48`) for every managed machine it observed present" | `CNF-351`, `CNF-352` |
| Throttled Robot rescue exit | `PRV-22`: "A Robot throttled end-rescue call MUST emit a monitorable alarm identifying the provider account" | `CNF-353` |
| Deployment parameter register | `OVR-19` | `CNF-339` |
| Retained view, PTR and reverse-DNS cases | `WIR-11`, `PRV-25`, `SEC-39` | `CNF-333`–`CNF-335` |

`PRV-46`, its descriptor field, its parameter rows, and `CNF-336`–`CNF-338` were removed
as never-master Decision 3 material. The identifier gate reserves exactly those numbers
and rejects their reintroduction or live citations. No edit was made to `PRV-40`,
`Provisiond.Tables.refresh_always_failed`, the Q10 wire projection, the PTR evidence
and invalidation path, and the reverse-DNS ceiling were retained. Historical ADR and
research material was not treated as live normative text.

## Formal model and its limits

`Provisiond.ProviderTraffic` keeps serialized claim-time cache and PTR models.
`validFreshness` models startup rejection of a window shorter than the sweep interval;
`sweepPresent` models a complete pass's write for a managed machine observed present.
The witness at sweep time 100, interval/window 20 and claim time 110 gets refresh
reads = 0. A window of 5 is rejected at startup, and a claim at 110 would require
one refresh read before the next sweep. Removing either the window guard or the
present-write guard has a separate refuted witness in the CI guard list.

`Cache.reads` counts refresh-provider reads, not the sweep's account-list read.
The model assumes successful complete enumeration, an observed-present machine,
serialized claims, and the stated claim times. It does not prove N-machine behavior,
scheduler cadence, provider availability, counting scope, persistence, or runtime
conformance. The checklist remains unchecked. No live provider call was made.

## Gate and control evidence

The baseline unpiped `nix develop --command bash tools/check-all.sh` exited 0 before
edits. The same command exited 0 after the first semantic pass and again after the
final specification, formal, CI and tracker edits. The final run passed all seven
gates, with 797 tagged Lean declarations and no new coverage or citation findings.

The source of standalone controls and guard rows is `.github/workflows/ci.yml`.
All 32 standalone source controls passed on the final formal revision, across
the workflow's shard assignments (11, 7, 7 and 7 controls respectively).
One in-repository copy, `.pv-ucs2-rehearsal/repo`, served the rehearsal. Standalone
mutations were run there and the copy was restored before the next control. The
guard-row rehearsal built that copy green, saved its `.lake` generated state inside
the same scratch directory, and restored both source bytes/timestamps and generated
state between rows. It checked the source-list partition: four shards, each with
24 distinct source indices, covering 0–95 exactly once. Every row required a
nonzero Lean build, exactly one `Provisiond/Witnesses.lean` error, a refuted
`decide` witness and the row's named proposition token. All 96 source rows passed;
the restored copy's final `lake build` exited 0. The new guard rows were source
indices 88 (`sweepWritesPresent`, refuting `sweepRefresh`) and 89
(`windowAtLeastSweep`, refuting `shortWindowValidation`).

The first rehearsal runner used a literal match for Lean's `decide` diagnostic,
where the workflow uses a pattern that accepts Lean's backticks. That runner
reported false failures; its matcher was corrected. A subsequent matrix run
found a genuine isolation failure at source row 84: disabling `preserveAge`
refuted both `ageClaim` and the new sweep witness. After reading the theorems,
the sweep helper pinned the unrelated cache guards on, as the existing witnesses
do. The formal gate then exited 0 and the complete matrix rerun passed with one
targeted refutation per row. No theorem statement was weakened.
The single rehearsal copy and its generated state were deleted after the reruns.
