# pin pv-zuu5

Verified on master 59208b3de86bd24e28c555b8853e8d342beac581 after PR #34.

STO-54 says: "Otherwise publish each known bound, identify every unknown endpoint and state that no finite duration is established; identify clock/provenance assumptions for known bounds."

CNF-365 says: "Repeat with an idle restarted standby that has replayed no transaction record and no retained fallback proof: assert unknown history bound and an explicit nonnumeric report, followed by the existing restore procedure."

An idle standby can lack a certified lower history bound while retained event-clock and stopping/fencing evidence certifies the upper endpoint. In that case a report can identify the unknown lower endpoint, publish the known upper endpoint, and state that no finite duration is established. The unqualified nonnumeric-report assertion can reject that report or allow a report that omits the certified upper endpoint. This is an ambiguity in what the conformance check must accept, rather than a presentation preference.

PR #34 retained the quoted restore-report arm while amending the promotion controls. No running implementation was exercised for this finding.


## Comment 843
## Agent Brief

**Category:** bug
**Summary:** Make `CNF-365` distinguish unknown history from an unknown duration without discarding a certified upper endpoint.
**Current behavior:** `STO-54` says “Otherwise publish each known bound, identify every unknown endpoint and state that no finite duration is established; identify clock/provenance assumptions for known bounds.” `CNF-365` says “Repeat with an idle restarted standby that has replayed no transaction record and no retained fallback proof: assert unknown history bound and an explicit nonnumeric report, followed by the existing restore procedure.” The latter assertion does not independently require reporting a certified upper endpoint when the lower endpoint is unknown.
**Desired behavior / key interfaces:** Strengthen the idle-restarted-standby operator-restore arm of `CNF-365` with an explicit fixture whose lower endpoint is unknown and whose upper endpoint has valid retained event-clock and stopping/fencing evidence. Require the persisted unknown lower endpoint, the certified upper endpoint and its evidence, and the corresponding operator report. Express the lack of a finite loss duration separately from publication of a known endpoint, using `STO-54` as the owner rather than defining another reporting policy.
**Acceptance criteria:** (1) In that fixture `lost_window_starts_at` is null, `loss_end_at` equals the certified upper bound, and non-null incident-keyed `history_evidence_ref` retains the evidence and unknown-lower-endpoint reason. (2) The report publishes that upper endpoint and its clock/provenance assumptions, identifies the lower endpoint as unknown, and states that no finite duration is established; omitting the known bound or inventing a finite duration fails the case. (3) Preserve the separate no-verified-event-clock case, unknown-upper-endpoint assertion, prohibition on filling an unknown history bound from restart time/backup name, existing restore continuation and other promotion arms. (4) Run the required full unpiped gates before and after. Verification is of the conformance specification; do not claim a running implementation was exercised.
**Out of scope:** Changing `STO-54`/`STO-56`, endpoint-certification rules, clock-error policy, the restore procedure, classification, formal declarations, gates or ADRs. If a requirement amendment appears necessary, stop and report it.

