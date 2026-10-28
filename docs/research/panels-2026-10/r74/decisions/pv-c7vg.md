# pv-c7vg — proposed ready-for-agent brief

Draft only. This file has not been posted and changes no tracker state. The body between the
Agent Brief markers is the proposed bead comment. Local provenance stays outside that comment.

<!-- AGENT_BRIEF_BEGIN -->
## Agent Brief

**Category:** enhancement (fold the owner ruling into its requirement owners).
**Readiness:** this minimal fold is ready as written; no new reading round is required.

**Owner answer, verbatim (2026-10-28):**

> Don't add the check

**Option text, verbatim:**

> Trust the deployment to keep replication on.

**Fuller version of that option, verbatim:**

> No new control — Rely on the deployment never disabling synchronous replication; document it as an operator requirement. Cheapest, and it puts safety on infrastructure configuration.

**Landing sites:** normative duty and misconfiguration limit at `STO-7`; later routing/pooler
operator duty at `STO-55`, both in `05-persistence.md`. Decision/pointer update at `ADR-0045`,
after the rule edits. `STO-54`, `CNF-296` and `CNF-365` are consistency checks, not policy/checklist
amendment sites for this fold. There are no new values for `OVR-19` or new requirement identifiers.

**Baseline rule, quoted at its owner:** `STO-7` says:

> The deployment MUST NOT let the primary commit without one of them: no connection lowers `synchronous_commit`, and the primary never serves with `synchronous_standby_names` empty.

**Exact proposed `STO-7` insertion:** Put the following paragraph after its replication-configuration
paragraph ending “every write waits.” and before the new-connection check:

<!-- STO7_DRAFT_BEGIN -->
> The operator MUST keep this synchronous replication configuration in force while the primary serves component work. Provisiond relies on that duty; no additional runtime replication-configuration drift check is required. If `synchronous_standby_names` is emptied after a connection has passed its new-connection check, a later commit on that connection can be acknowledged locally without either named standby having flushed it. That is a deployment misconfiguration, and the earlier connection check does not detect the change.
<!-- STO7_DRAFT_END -->

**Exact proposed `STO-55` insertion:** Append the following to the existing transaction-mode-pooler
bullet, leaving its existing rule and explanation intact. That bullet's rule is “No pooler in
transaction mode fronts the pools”; its explanation is “behind one, a crash of the primary ends
its backends but not the component's connection to the pooler, so `STO-7`'s new-connection check
would never run.”

<!-- STO55_DRAFT_BEGIN -->
> The operator MUST maintain this exclusion while components use this path, including after routing changes. No additional runtime topology-drift check is required.
<!-- STO55_DRAFT_END -->

**Exact decision-record edit, after the requirements:** In `ADR-0045`, replace the existing
paragraph beginning “Correct replication configuration is a trusted deployment assumption.”
and ending “The same follow-up covers a transaction-mode pooler added later.” with:

<!-- ADR_DRAFT_BEGIN -->
> Runtime replication-configuration and routing duties, including their misconfiguration limits, are owned by `STO-7` and `STO-55`. For `pv-c7vg`, on 2026-10-28 the owner answered “Don't add the check”, selecting “Trust the deployment to keep replication on.” The fuller option was “No new control — Rely on the deployment never disabling synchronous replication; document it as an operator requirement. Cheapest, and it puts safety on infrastructure configuration.” No runtime controller was adopted. The separate action/history audit stays with `pv-v4gp`.
<!-- ADR_DRAFT_END -->

**Concrete residual misconfiguration:** On an already checked connection, disable the standby
list, commit locally, then lose the primary before either standby has that commit. Equal stale
standby reports do not reveal the missing commit. This is the existing H-d2 failure of the trusted
deployment premise, not a new conforming restart trace. A later transaction-mode pooler can also
hide backend replacement behind a surviving client connection. The operator bears both risks.

**Classification consistency:** Leave `STO-54`'s rule unchanged, including its clause “after the
primary committed without one of them” and its complete operator-only sentence: “Only an operator
starts a promotion that is a restore: an automatic failover promotes only as a restart, and
otherwise leaves the store without a primary until both standbys report or an operator decides.”
T-known changes equality only. Its fixtures explicitly make prior violations known. The uncertainty
and off-primary-evidence questions remain audit candidates in pv-v4gp, not new policy in this fold.

**Reading-round call and reason:** No round for this exact text. The owner expressly instructed
documentation of the operator requirement and declined the check. The baseline quotation above
already forbids the drift, and the existing pooler bullet already excludes that route. The added
words identify who maintains those duties and disclose the already-verified unchecked failure;
they change no classification, fixture, deadline, evidence mechanism or deployment control. Under
`r76/notes.md` rule 1 this is a direct ruling/wording fold, not a manager combination of P4 repairs.
The stronger change that would need a round is any new runtime enforcement, residual-session
proof or conservative-unknown promotion rule. None is proposed here, so no round brief is needed.

**Acceptance:** Match the owner quotations exactly; verify these insertions against their baseline
owners; retain the connection/deposit checks and all promotion prerequisites. Read the revised
requirements together before adding the record. Close as an applied operator-duty ruling with
pointers to `STO-7`/`STO-55`, rather than as a claim that runtime drift is detected. Add no controller,
new monitoring fixture or historical-evidence admission requirement.

**Execution and completion:** Before applying, verify every replacement anchor against freshly
pulled master and the quoted decision against its decision record. Preserve the exact approved
package; report a substantive conflict instead of resolving it by an unreviewed synthesis.
Run `nix develop --command bash tools/check-all.sh` unpiped before and after the actual change.
Land the requirements and checklist edits before writing their amendment/decision record. Keep
arguments with their requirement owners and use pointers elsewhere. Change a formal declaration
only when its actual meaning changes; preserve theorems and keep checklist identifiers out of
formal sources. Close this bead through the tracker only after verification, flush its record,
and verify closure in committed JSONL. Add no attribution disclaimer or coauthor trailers.
<!-- AGENT_BRIEF_END -->

## Local provenance — do not post to the tracker

Decision source: `/var/tmp/provisiond-manager/owner-decisions-1028-panelA.md`. Review base: `4662d85c7e67c2ebb4c5c8e1c98dc6e1c0efc239`.
The H-d2 claim and its nonconforming-deployment premise are independently checked at
`r76/check/tally-claim-audit.md` Q1 (first source row), grounded in the existing `STO-7` quotation
and PostgreSQL source snapshots. The pooler explanation is already printed in `STO-55`.
This form is new wording, not an accepted P4C/P4R/P4C-R/V/A form. No part of those proposals is
imported, and none of their votes is claimed for this fold. The reading decision rests on the
explicit owner direction and unchanged baseline duties, not a claimed fresh panel acceptance.

This turn authorizes drafts only. No Run, tracker mutation, source application, branch operation
or PR follows from this file. Live pv-6350 must leave the checkout before any later drain starts.
