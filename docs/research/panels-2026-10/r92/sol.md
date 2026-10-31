**Q1: LANDING ONLY. Q2: R-BOTH, exactly as printed.**

**R-BOTH as final combined implementation: ACCEPT. HOLD as temporary hold: CANNOT ACCEPT.** An exact reconciliation is safe; HOLD would leave item 18 unimplemented.

Item 9 authorizes the “exact briefs in the table” and says “the drain lane implements them.” The pv-zuu5 brief requires: “Express the lack of a finite loss duration separately from publication of a known endpoint.” Item 18 adopts C-UNKNOWN: “pause automatic recovery until trustworthy evidence arrives or a person approves a restore,” with “No specific evidence service” required, and directs amendment of “STO-54 and CNF-365 as printed.” These operative decisions are compatible. ([Owner decisions](/var/tmp/provisiond-panel-r92/sources/owner-items-9-18.md:1), [pv-zuu5 brief](/var/tmp/provisiond-panel-r92/sources/pin-pv-zuu5.md:15))

The historical C-UNKNOWN check contains “assert unknown history bound and an explicit nonnumeric report.” Read alone, that wording admits the ambiguity pv-zuu5 repaired. But its accompanying adopted STO-54 block expressly says unknown reporting endpoints “are separate: they use the reporting rules below.” Those retained rules require:

> “Otherwise publish each known bound, identify every unknown endpoint and state that no finite duration is established; identify clock/provenance assumptions for known bounds.”

They also say:

> “Missing reporting evidence does not hold incident creation, the existing restore procedure or component startup once its existing prerequisites are satisfied.”

([Historical check](/var/tmp/provisiond-panel-r92/sources/adopted-C-UNKNOWN-CNF-365.md:20), [adopted separation](/var/tmp/provisiond-panel-r92/sources/adopted-C-UNKNOWN-STO-54.md:58), [reporting owner](https://github.com/douglaz/provisiond/blob/d65dc63e059bdefc8bab2e2e64416acf52f5b904/05-persistence.md#L1727))

Thus “nonnumeric report” preserves an explicit unknown loss-duration result; it does not establish a prohibition on publishing a certified numeric endpoint. R-BOTH expresses that meaning explicitly instead of silently dropping it.

The distinctions matter:

| Unknown fact | Consequence supported by the owning text |
|---|---|
| Restart eligibility | C-UNKNOWN: “Automatic failover MUST NOT promote while restart eligibility is unknown”; an operator may authorize restore. |
| Lower endpoint `b` | STO-54: “If either endpoint cannot be certified, persist null for it and say that endpoint is unknown.” This does not invalidate independently certified `f`. |
| Upper endpoint `f` | The same null/unknown rule applies independently; “The event timestamp alone never substitutes for a missing history bound.” |
| Bounding duration | “Publish possible loss within [b,f] and its bounding duration only when both endpoints are known.” A known endpoint alone supplies no finite duration. |

([Eligibility owner](/var/tmp/provisiond-panel-r92/sources/adopted-C-UNKNOWN-STO-54.md:45), [certification rules](https://github.com/douglaz/provisiond/blob/d65dc63e059bdefc8bab2e2e64416acf52f5b904/05-persistence.md#L1701))

A concrete compatible trace: historical cancellation coverage is lost, so eligibility remains unknown. The operator authorizes restore. The idle standby supplies no lower certificate, while retained event-clock and stopping/fencing evidence certifies `f = 2026-10-30T23:00:02Z`. Persist null `b`, that `f`, and the incident-keyed evidence reference. Report:

> Lower endpoint unknown: no retained lower certificate. Upper endpoint 2026-10-30T23:00:02Z, derived from the incident event clock with verified upper error bound of two seconds and retained stopping/fencing evidence E. No finite duration is established.

That report satisfies both decisions. Evidence E establishes an acknowledgement cutoff; it does not establish the absence of historical waiting-backend termination. No same-fixture incompatible owner demands are demonstrated.

Literal application of the historical whole-item replacement would nevertheless delete the landed sentence:

> “A report omitting the certified upper endpoint or inventing a finite loss duration fails this case.”

That deletion is a real loss of explicit check strength, explaining the stop. It is not evidence that item 18 intended that loss. ([Exact difference](/var/tmp/provisiond-panel-r92/sources/cnf365-exact-form-difference.diff:1))

My exact pick is [R-BOTH](/var/tmp/provisiond-panel-r92/candidates/R-BOTH.md:1), replacing the complete pinned CNF-365 item at `10-conformance-checklist.md:1184–1228`, before `## The rate`, accompanied by the unchanged owner-adopted STO-54 replacement.

- **Item 9: MEANING PRESERVED / WORDING REBASED.** Its landed reporting arm survives byte-for-byte.
- **Item 18: MEANING PRESERVED / WORDING REBASED.** Its added eligibility paragraphs survive byte-for-byte; its reporting summary is expressed through the separately adopted repair and retained reporting owner.

The owner’s wording exception can settle this exact reconciliation after the required panel settlement: it permits changes involving “no behaviour, requirement or check-strength change.” This reader’s answer alone is not settlement. C-UNKNOWN remains a substantive, already-authorized addition relative to master; the reconciliation introduces no further substantive choice. ([Wording authority](/var/tmp/provisiond-panel-r92/sources/owner-wording-rule.md:1))

The preservation audit below uses **B** for the pinned CNF-365 base, **Z** for pv-zuu5’s complete acceptance criteria, and **C** for the adopted C-UNKNOWN check. Locations are lines in R-BOTH. Those sources, rather than the brief’s review checklist, hold the assertions. ([B](https://github.com/douglaz/provisiond/blob/d65dc63e059bdefc8bab2e2e64416acf52f5b904/10-conformance-checklist.md#L1184), [Z](/var/tmp/provisiond-panel-r92/sources/pin-pv-zuu5.md:15), [C](/var/tmp/provisiond-panel-r92/sources/adopted-C-UNKNOWN-CNF-365.md:1))

| Source and obligation | Exact surviving words and location |
|---|---|
| **B: initial promotion fixture, prerequisites and results** | R1–6 retains “commit step 8 and order, and claim a second”; selection “at least as far ahead as the other's,” “no open restore record and every other restart-promotion condition satisfied,” and “with a standby streaming from the promoted store.” It retains stopped old processes before connection, “serves no component,” both surviving rows, “no restore record is written,” and “`OPS-15`'s restart branch.” |
| **B: connection controls** | R6–11 retains stalled-write primary and backend crashes, “no component uses a connection before a standby has flushed at or past the flush position it reported”; results withheld through the connection-attempt deadline; “closure without use or fallback, no check-issued writes, and no check-created `SyncRep` backend”; and “Inspect the deployed topology for transaction-mode pooling.” |
| **B: unavailable/different-timeline cases and commit-holder selection** | R12–19 retains “none until an operator decides, while that standby's report stays unavailable”; “automatic failover promotes neither standby at all, including as a restore”; numerical-equality independence; and “promotes the one holding that write, then repeat with the standbys' roles swapped.” |
| **Z/C: certified and unknown reporting fixtures** | R20–27 retains “verified prefix/clock evidence” and “incident stores certified bounds”; the idle standby has “replayed no transaction record and no retained fallback proof,” “leaving the lower history endpoint unknown,” while supplying “valid retained event-clock and stopping/fencing evidence.” It persists `lost_window_starts_at` “as null,” `loss_end_at` “as that certified upper endpoint,” and a “non-null incident-keyed `history_evidence_ref`” identifying retained evidence and the unknown-lower reason. |
| **Z/C: explicit unknown-duration report** | R27–29 requires publication of “the certified upper endpoint and its clock/provenance assumptions,” identifies the lower endpoint “as unknown” and “states that no finite duration is established.” This preserves C’s explicit unknown/nonnumeric loss-duration meaning. |
| **Z: negative verdict and separate unknown-upper case** | R30–33 retains the complete quoted failure sentence above; “Follow with the existing restore procedure”; “Repeat with no verified event-clock bound and assert an unknown upper bound”; and “Do not use a restart time or a backup name to fill an unknown history bound.” |
| **Z/C: general endpoint provenance** | R34–37 retains “supply certified evidence for each asserted known” endpoint, “store null for each unknown endpoint,” and the non-null incident-keyed reference “identifying evidence or unknown-endpoint reasons.” |
| **B: valid equality positive control** | R39 retains the same old-primary timeline, no open record, every other condition, and “once promoting each standby”; “restart classification, no restore record and no tenant credential-generation bump from the restore procedure”; and “Preserve the engine's ordinary startup-generation advance.” |
| **B: equality exclusions and operator restore** | R41 retains different timelines/unavailable reports: “neither case may use the equal-position path”; greater-end selection only “with all other conditions satisfied”; behind selection requires “an operator's restore.” Commits without either named standby and known cancellation/termination retain “equality permits neither promotion as a restart.” It retains “Automatic failover does not perform these restores” and acknowledged record commitment before startup. |
| **B: continuation** | R43 retains “continuation of that same incident,” “A marked step does not repeat,” the unmarked/marked step-(3) credential cases, and “Equality neither closes the record nor waives any outstanding incident obligation.” |
| **C: paired fixture and substantiated positive control** | R45–50 retains “identical surviving standby reports on the same actual old-primary history and no open incident”; “complete trustworthy negative evidence”; “satisfy every other restart condition”; promotion of each equal standby separately; restart/no-record/no-restore-bump results; and “preserving the ordinary startup-generation advance.” |
| **C: hidden event and epistemic negative control** | R50–55 retains termination “independently observed by the test,” loss of primary/logs, hidden event evidence and identical survivor reports; “unknown eligibility, operator notice and no automatic promotion”; and “Do not give the procedure the test's hidden oracle or label its unknown state as a known violation.” |
| **C: known event, including shutdown** | R55–56 retains “supply valid event evidence and assert the existing restore classification, including when the termination was caused by primary shutdown.” |
| **C: deficient evidence without an actual event** | R58–60 retains “no event in fact but lost or incomplete coverage,” mismatched database/incarnation/ancestry, unauthenticated assertion and conflicting records. “Missing logs or an assertion without continuous coverage cannot pass.” |
| **C: inherited facts** | R60–62 retains a known termination and separately an unknown interval across “later catch-up, equal reports and an incarnation change on which the next restart depends”; “neither is silently reset.” |
| **C: operator boundary/startup ordering** | R62–65 retains “In each unknown fixture assert no restore begins automatically”; explicit operator authorization; “the stopped-components procedure and an acknowledged incident record before startup”; and “This is not a fast-shutdown read/action reproduction.” |
| **C: absent reporting certificates do not block authorized restore** | R65–67 retains “no certified loss-report endpoints,” “null endpoints and an explicit unknown report,” followed by the existing procedure “without a wait for reporting evidence.” |

The fixed STO-54 accompaniment preserves its complete evidence predicate, known-disqualification precedence, operator boundary, inherited uncertainty and continuation treatment. Its sentence “operator belief alone cannot reclassify unknown as established” remains intact.

Relative to historical r88, the more specific reporting fixture and stronger explicit report failures are item 9’s authorized repair. Relative to the pin, the eligibility fixtures and obligations are item 18’s authorized addition. **The reconciliation itself loses no guard, obligation, fixture, negative-control strength or positive control. No theorem statement or guard hypothesis changes.**

No formatting theorem is inferred: `Restore.lean` states “Interval/certificate publication and its evidence protocol remain outside the model's scope”; `WalHistory.lean` states “It models neither incident procedures nor permission to promote.” ([Restore](https://github.com/douglaz/provisiond/blob/d65dc63e059bdefc8bab2e2e64416acf52f5b904/tools/formal/Provisiond/Restore.lean#L27), [WalHistory](https://github.com/douglaz/provisiond/blob/d65dc63e059bdefc8bab2e2e64416acf52f5b904/tools/formal/Provisiond/WalHistory.lean#L39))

**Requested counterargument, not my vote:** Item 18 says “adopt exactly” the hashed package, and “an explicit nonnumeric report” could be read as banning every numeric endpoint. On that reading R-BOTH changes an adopted verdict. The objection is strongest at the literal-text level. It fails to establish substantive incompatibility because the same package expressly retains the reporting rules requiring known-bound publication. An explicit numeric-endpoint ban would require an owner decision; none is demonstrated here.

**Verified brief errors / rule 6:** None found. The stale replacement boundary is the stated question, not a newly discovered premise error. There is no verified error triggering rule 6’s void-and-reask provision.

I read the required historical sources whole. Read-only checks confirmed the adopted SHA-256, HOLD’s equality to the pinned item, R-BOTH’s insertion-only difference from that item, and byte-identical eligibility paragraphs. The clone remains clean. I ran no gates or Lean commands; Z’s required full-gate criterion remains with the manager as instructed. Previous gate receipts do not verify this candidate, and no runtime implementation was exercised.

Q1 FINAL: LANDING ONLY  
Q2 FINAL: R-BOTH; ITEM9: MEANING PRESERVED / WORDING REBASED; ITEM18: MEANING PRESERVED / WORDING REBASED; AUTHORITY: WORDING RULE