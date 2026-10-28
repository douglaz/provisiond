# Panel A decisions — draft application and drain plan

This is the requested single draft step. The bead files in this directory are the application
inputs; none has been posted or applied. The live pv-6350 Run and the main checkout, branches,
tracker, remotes, manager brief and memory have not been changed. Work product and verification
artifacts are confined to this `decisions/` directory.

The decision source is `/var/tmp/provisiond-manager/owner-decisions-1028-panelA.md` (2026-10-28).
It supersedes the historical owner-pending status in `../STATE.md` and `../r76/tally.md`, not their
review evidence. The reviewed base is `4662d85c7e67c2ebb4c5c8e1c98dc6e1c0efc239`.

## Files, landing sites and readiness

| Bead / draft | Actual amendment or artifact sites | Ready to apply as written? |
|---|---|---|
| [pv-c7vg](pv-c7vg.md) | `STO-7`, `STO-55`; decision/pointer record in `ADR-0045` | Yes: direct minimal fold of “Don't add the check”; no new technical mechanism or policy. |
| [pv-3jw6](pv-3jw6.md) | `STO-54`, `STO-56`, `OVR-19`, `CNF-295`, `CNF-365`; restore/seed companions listed in its exact UO package; `Restore.lean` event-clock documentation; decision/pointers in `ADR-0023` | Yes: UO with only the tally-verified `defined above` repair. |
| [pv-oehp](pv-oehp.md) | `STO-55`, `OPS-47`, `OPS-49`, `OVR-18`, `OVR-19`, `CNF-57`, `CNF-290`, `CNF-296`, `CNF-299`, `CNF-362`, new drill `CNF-372`; decision/pointer record in `ADR-0045` | Yes: B4* with the exact r76 consumer antecedent and disclosed A/observer obligation. Recheck the new drill identifier on fresh master. |
| [pv-1i3n](pv-1i3n.md) | `STO-54`, `STO-5`, `CNF-365`, `Restore.lean` classification comment; decision/pointers in `ADR-0045` | Yes: T-known T1–T6, including its reviewed known-violation fixture restriction. |
| [pv-5lip](pv-5lip.md) | `CNF-365`; unchanged owner `STO-54` | Yes within original approved brief; serially held until the overlapping Panel A edits settle. |
| [pv-26ju](pv-26ju.md) | WAL-history formal model and imports, tagged to `STO-7`/`STO-54`; any synchronized owner rendering/pointer under `ADR-0025` | Yes within original approved brief; use the settled configuration and classification premises. |
| [pv-v4gp](pv-v4gp.md) | Proposed `docs/research/promotion-durability-audit.md`; read/audit targets in its file, including `STO-54`, `OPS-32`, `API-11`, `API-53`, `API-56`, `LDG-14`, `ADR-0045` | Yes for the approved audit record only; no normative policy amendment is authorized by that brief. |

The source for the held briefs is the committed JSONL at the reviewed base: comments 828, 826
and 827, respectively. Each held file preserves its original Agent Brief verbatim. The manager
brief's triage PR #27 entry records the owner approval “Approve all (Recommended)”. No held brief
is enlarged or rewritten by this plan. “Ready” here assesses the draft; it neither changes a
tracker label nor bypasses the live-Run hold or ordinary fresh-master checks.

## pv-c7vg reading-round call

No reading round is needed for the exact minimal fold in [pv-c7vg.md](pv-c7vg.md). The owner
answered “Don't add the check”, selected “Trust the deployment to keep replication on.”, and
explicitly chose documentation “as an operator requirement”. The existing `STO-7` sentence is:

> The deployment MUST NOT let the primary commit without one of them: no connection lowers `synchronous_commit`, and the primary never serves with `synchronous_standby_names` empty.

The existing `STO-55` rule is “No pooler in transaction mode fronts the pools”; its printed reason
is “behind one, a crash of the primary ends its backends but not the component's connection to
the pooler, so `STO-7`'s new-connection check would never run.” The draft assigns maintenance of
those existing conditions to the operator and records the verified H-d2 failure when they are
violated. It adds no detection deadline, controller, historical evidence requirement, unknown-history
classification or new conformance verdict. That is a direct owner-ruling fold, not a synthesis of
the rejected controller candidates. The source verification is `../r76/check/tally-claim-audit.md`
Q1 and the baseline owners, not a claimed fresh panel tally.

The policy remains conditional on configuration and history. `STO-54` retains its exception
“after the primary committed without one of them”. Equal reports after an undisclosed violation
do not provide a historical detector. The uncertainty/evidence audit remains with pv-v4gp; its
candidate remedies require their own later mechanics review and owner ruling. No reading-round
brief is prepared because this draft does not propose those remedies.

## Cross-draft checks and constraints

| Shared surface | Evidence / overlap | Constraint |
|---|---|---|
| `STO-7` / `STO-55` trust versus admission | pv-c7vg adds operator-duty wording to the replication and pooler paragraphs. B4* replaces a separate pool-consumer sentence and the residual-slot sentence, then adds capacity admission. | They compose by location. Admission proves capacity accounting; it is not a replication-posture monitor. Preserve the operator-duty text when applying B4*. No P4 observation parameters are introduced, so B4*'s C/A names acquire no controller meaning. |
| `STO-54` report versus comparison | UO edits the report/procedure lead-in and possible-loss reference. T-known edits the promotion comparisons and their rationale. | Preserve UO's event/history separation when changing equality. Equality is a restart only under all retained prerequisites; open incidents still continue. Neither report endpoints nor backend grants prove promotion eligibility. |
| `CNF-365` | UO appends an operator-restore report arm; T-known changes the positive title/setup and appends equality controls; pv-5lip strengthens the existing other-timeline control. | Apply UO, then T-known, then pv-5lip. Keep all arms inside one item and before its owner/history footer; do not replace the whole item from a stale snapshot. T-known's unavailable standby report control must remain distinct from UO's unknown reporting endpoint. |
| `Restore.lean` | UO clarifies the event-clock documentation. T6 replaces the classification comment. pv-26ju adds the WAL-history model. | The comment edits have separate anchors. UO/T-known change no declaration. Add the proof only after the normative policy settles; do not assign report b/f to `now` or imply existing event theorems prove timestamp/certificate semantics. |
| `OVR-19` | UO registers evidence/capture procedures. B4* registers C, A, resource ceilings and authority/reconstruction procedures. | Add owner-linked rows once. UO's human evidence rows must not become startup holds when reporting evidence is absent. B4*'s admission may delay startup; these are independent reasons and outcomes. |
| `ADR-0045` / `ADR-0023` | Configuration ruling, residual admission and equality decisions have different owners. | Land each rule first, then its record. Replace stale open-follow-up wording with the settled pointer. Keep the capacity argument at `STO-55`, classification at `STO-54`, and reporting at `STO-54`/`STO-56`; avoid writing a second normative explanation in an ADR. |
| B4* and pv-v4gp | B4* prohibits releasing a charged residual on timeout or exit. The audit considers histories/effects and loss of cancellation evidence. | Capacity evidence is not durability/history evidence. Do not discharge the history audit from a reservation grant or a passing connection check. Keep the no-SyncRep-cancellation rule and primary-shutdown exception. |
| pv-26ju and pv-v4gp | The proof establishes a conditional history property. The audit examines externally visible actions, including read-based effects. | Run the proof first so the audit can cite its actual scope. The audit must still cover the named actions and the disputed runway case; a barrier theorem is not blanket evidence for read-based provider actions. |

The order above is a proposed serial drain order, not a newly written dependency graph. UO and
B4* have no semantic dependency on each other. The same-item checklist edits require preservation
and sequencing; they do not justify merging multiple beads into one Run. The formal model and
audit could be designed independently, but running them after the selected policy avoids stale
premises and repeated owner questions.

## Proposed drain order

First let the current pv-6350 Run finish and be handled under the existing drain lane. Do not
switch its branch, touch its tracker or run preparation against its working tree.

Then take one bead per turn, from freshly pulled master:

1. **pv-c7vg** — settle the P1 trust boundary and its documented residual risk.
2. **pv-3jw6** — land the P2 report/event/schema contract and its restore fixtures.
3. **pv-oehp** — land B4* admission, resources and its consumer/recording fixtures.
4. **pv-1i3n** — land equality on the updated reporting/checklist base.
5. **pv-5lip** — strengthen the surviving other-timeline control in the final `CNF-365` item.
6. **pv-26ju** — formalize the settled history/replication/classification premises.
7. **pv-v4gp** — audit the resulting text and actual proof limits; return new design choices separately.

No owner decision remains for these exact forms. A substantive conflict found at application,
an identifier collision requiring a changed mapping, or a new behavioral remedy is reported at
that point; it is not silently folded into a reviewed package. The owner has not been asked to
approve an unreviewed manager union.

## Verification and operational boundaries

Quota reads in this draft session: Claude session **80%** (reset Oct 28, 6am UTC), all-model week
**31%** (Nov 3, 8pm UTC), Fable week **44%** (Nov 3, 7:59pm UTC); active Codex WEEK **16%**
(displayed reset 5d1h). Exactly 80% is allowed by the rule. These are observations, not future
launch admission. Re-read every quota before later jobs; any unreadable/over-80% Claude value
holds new work, and Codex holds at 100% under the owner's exception. No account switch/logout,
panel, reading round, rloop Run, PR or systemd unit is launched in this draft step.

The required before/after `nix develop --command bash tools/check-all.sh` commands run unpiped in
`check/baseline/`, an isolated copy of the pinned panel checkout beneath this allowed directory.
They certify that unchanged baseline only. No proposed spec edit is applied even there. Their
receipts are `check/gate-before.{log,exit,json}` and `check/gate-after.{log,exit,json}`; both must
exit 0 before this draft step is reported done. The draft-verification receipt separately checks
the candidate extraction/repair, owner quotations, old anchors, held comments, identifier mapping
and cross-draft preservation. Neither check is a database experiment or an implementation
certificate. No main-checkout gate is run because that could publish formal build artifacts into
the live Run's tree.

The proposed public Agent Brief bodies omit reader/model attribution and disclaimers. Local
provenance and the private B4* option quotation remain outside their markers. Use the tracker
tool for any later posting/status/label changes; this task performs none.

Final receipts: both isolated unpiped baseline gates exited **0**, and the draft/source checks
passed, including exact package/decision identity and an archive comparison confirming that no
proposed edit was applied to the isolated source. `check/draft-verification.json` records the
individual checks and final Markdown hashes.
