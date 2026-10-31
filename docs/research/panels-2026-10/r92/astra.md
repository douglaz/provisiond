**Q1: LANDING ONLY. Q2: R-BOTH, exactly as printed.** I **ACCEPT R-BOTH** as the final combined implementation and **ACCEPT HOLD** as a temporary hold pending settlement. HOLD does not implement item 18 and is not my preferred outcome.

Item 9 authorizes implementation “with the exact briefs in the table.” Its pv-zuu5 brief requires: “Express the lack of a finite loss duration separately from publication of a known endpoint,” and makes “omitting the known bound or inventing a finite duration” fail. Item 18 adopts C-UNKNOWN: “pause automatic recovery until trustworthy evidence arrives or a person approves a restore,” with the exact-package instruction to “amend STO-54 and CNF-365 as printed.” Both decisions remain operative. [Decision source](/var/tmp/provisiond-panel-r92/sources/owner-items-9-18.md); [pv-zuu5 brief](/var/tmp/provisiond-panel-r92/sources/pin-pv-zuu5.md).

The historical C-UNKNOWN check says “assert unknown history bound and an explicit nonnumeric report, followed by the existing restore procedure.” Read alone, “nonnumeric report” is ambiguous. But its accompanying adopted STO-54 text expressly says:

> Unknown possible-loss reporting endpoints on an operator-authorized restore are separate: they use the reporting rules below and do not delay that restore's incident creation, procedure or startup once its existing prerequisites are satisfied.

Those retained reporting rules say:

> Otherwise publish each known bound, identify every unknown endpoint and state that no finite duration is established; identify clock/provenance assumptions for known bounds.

Thus C-UNKNOWN does not establish a separate prohibition on numeric endpoints. Its “nonnumeric report” must be read consistently with the reporting contract it explicitly retains: an unknown bound or duration must not be fabricated numerically; a certified endpoint must still be published. This conclusion rests on the complete adopted package, not merely on choosing the most convenient interpretation of an isolated adjective. [Adopted form](/var/tmp/provisiond-panel-r92/sources/r88-form-C-UNKNOWN.md); [STO-54](https://github.com/douglaz/provisiond/blob/d65dc63e059bdefc8bab2e2e64416acf52f5b904/05-persistence.md#L1727).

The distinctions matter:

| Unknown fact | Consequence and source |
|---|---|
| Restart eligibility | C-UNKNOWN: “Automatic failover MUST NOT promote while restart eligibility is unknown”; an operator may authorize a restore. This concerns evidence of historical restart conditions. |
| Lower endpoint | STO-54 requires a certificate that “every source-history component commit acknowledged before b belongs to recovered committed history.” Without that certificate, persist null; a separately certified upper endpoint remains usable. |
| Upper endpoint | STO-54 requires certification that “no component acknowledged an old-history commit after f.” Without it, persist null for that endpoint. |
| Duration | STO-54 permits a bounding duration “only when both endpoints are known.” One certified endpoint does not establish a finite duration. |

A concrete compatible case is an idle restarted standby with no retained lower-bound proof, but retained event-clock and fencing evidence certifying `f = 2026-10-30T12:00:02Z`. Historical waiting-backend coverage can still be missing: proving no acknowledgements occurred after a fencing boundary does not establish whether a waiting backend was terminated earlier.

After explicit operator authorization, persist null lower, that certified upper, and the incident-keyed evidence reference. A compatible report is:

> Lower endpoint unknown: no retained lower-bound certificate. Certified upper endpoint: 2026-10-30T12:00:02Z, derived from the retained incident event-clock error bound and stopping/fencing evidence identified by this incident’s evidence reference. No finite duration is established.

That report satisfies the landed reporting assertion and C-UNKNOWN’s retained reporting contract. Unknown eligibility prevents automatic promotion; missing reporting evidence does not prevent the authorized restore once its prerequisites hold. STO-54 explicitly says: “Missing reporting evidence does not hold incident creation, the existing restore procedure or component startup once its existing prerequisites are satisfied.”

Conversely, a report saying only “lower endpoint unknown; no finite duration established,” while omitting that certified upper, fails the landed sentence: “A report omitting the certified upper endpoint or inventing a finite loss duration fails this case.” Literal application of the historical whole-item replacement removes that explicit test. This is a real check-strength regression and justified the stop. It does **not** demonstrate that item 18 intended a contradictory reporting policy.

**Authority and exact landing.** My selection is the complete printed R-BOTH replacement for `10-conformance-checklist.md:1184–1228`, ending before `## The rate`, accompanied by the unchanged owner-adopted STO-54 replacement.

- **Item 9: MEANING PRESERVED / WORDING REBASED.** Its landed fixture and assertions survive byte-for-byte.
- **Item 18: MEANING PRESERVED / WORDING REBASED.** Its eligibility additions survive byte-for-byte; its inherited reporting arm incorporates the separately approved repair without changing its retained reporting policy.

The owner’s wording rule can settle this reconciliation once the panel satisfies its settlement conditions. This answer alone does not establish consensus or authorize application. C-UNKNOWN’s original behavior/check-strength change remains substantive relative to master, already authorized by item 18. Likewise, pv-zuu5’s strengthening was authorized by item 9. R-BOTH preserves their combination; it introduces no additional substantive choice.

The following audit uses line numbers in the exact [R-BOTH candidate](/var/tmp/provisiond-panel-r92/candidates/R-BOTH.md). The obligation inventories are owned by the [pv-zuu5 brief](/var/tmp/provisiond-panel-r92/sources/pin-pv-zuu5.md) and [C-UNKNOWN form](/var/tmp/provisiond-panel-r92/sources/r88-form-C-UNKNOWN.md).

| Source obligation | Exact surviving text and location in R-BOTH |
|---|---|
| pv-zuu5: idle standby and differentiated evidence | Lines 21–24 retain “replayed no transaction record and no retained fallback proof, leaving the lower history endpoint unknown,” and “supply valid retained event-clock and stopping/fencing evidence certifying an upper endpoint”. |
| pv-zuu5: persisted endpoints and evidence | Lines 24–27: “the incident persists `lost_window_starts_at` as null and `loss_end_at` as that certified upper endpoint,” with “a non-null incident-keyed `history_evidence_ref` identifying the retained evidence and the unknown-lower-endpoint reason”. |
| pv-zuu5: complete report | Lines 27–29: “the operator report publishes the certified upper endpoint and its clock/provenance assumptions, identifies the lower endpoint as unknown and states that no finite duration is established”. |
| pv-zuu5: negative assertions | Lines 30–31: “A report omitting the certified upper endpoint or inventing a finite loss duration fails this case.” Neither failure becomes unreachable or vacuous. |
| Both reporting arms: procedure, unknown upper, no invented substitute | Lines 31–33: “Follow with the existing restore procedure. Repeat with no verified event-clock bound and assert an unknown upper bound. Do not use a restart time or a backup name to fill an unknown history bound.” |
| C-UNKNOWN: certified-bounds positive case | Lines 20–21: “Promote a lagging standby as an operator restore with verified prefix/clock evidence and assert the incident stores certified bounds.” |
| C-UNKNOWN: old “explicit nonnumeric report” meaning | Lines 28–29 retain explicit unknown lower and “no finite duration is established”; lines 30–31 reject invented finite duration. Publishing the certified upper preserves the governing reporting rule quoted above. The ambiguous adjective is replaced, not a substantive ban on endpoints. |
| Both: generic endpoint/evidence discipline | Lines 34–37: “supply certified evidence for each asserted known `lost_window_starts_at` or `loss_end_at`; store null for each unknown endpoint and retain a non-null incident-keyed `history_evidence_ref` identifying evidence or unknown-endpoint reasons”. |
| C-UNKNOWN: paired fixture setup and positive control | Lines 45–50 retain “identical surviving standby reports on the same actual old-primary history and no open incident”; “complete trustworthy negative evidence”; “satisfy every other restart condition”; “Promote each equal standby in a separate run”; and “assert restart classification, no restore record and no restore credential-generation bump, preserving the ordinary startup-generation advance.” Always refusing cannot pass. |
| C-UNKNOWN: hidden event, identical survivors, refusal and notice | Lines 50–53 retain “termination independently observed by the test,” loss of primary/logs and hidden event evidence, “the surviving reports are the same as in the first fixture,” and “Assert unknown eligibility, operator notice and no automatic promotion.” |
| C-UNKNOWN: no oracle leakage or false known classification | Lines 54–55: “Do not give the procedure the test's hidden oracle or label its unknown state as a known violation.” |
| C-UNKNOWN: known event, including shutdown | Lines 55–56: “supply valid event evidence and assert the existing restore classification, including when the termination was caused by primary shutdown.” |
| C-UNKNOWN: deficient evidence without an actual event | Lines 58–60 retain “no event in fact but lost or incomplete coverage, mismatched database/incarnation/ancestry evidence, an unauthenticated clean assertion and conflicting records.” |
| C-UNKNOWN: missing/noncontinuous evidence cannot pass | Line 60: “Missing logs or an assertion without continuous coverage cannot pass.” |
| C-UNKNOWN: inherited known termination and unknown interval | Lines 60–62: “Retain a known termination and separately an unknown interval across later catch-up, equal reports and an incarnation change on which the next restart depends; neither is silently reset.” |
| C-UNKNOWN: operator boundary and startup order | Lines 62–65: “In each unknown fixture assert no restore begins automatically; let an operator explicitly authorize one and assert the stopped-components procedure and an acknowledged incident record before startup.” |
| C-UNKNOWN: reproduction limitation | Line 65: “This is not a fast-shutdown read/action reproduction.” |
| C-UNKNOWN: no certified endpoints | Lines 65–67: “Finally authorize a restore with no certified loss-report endpoints and assert null endpoints and an explicit unknown report, followed by the existing procedure without a wait for reporting evidence.” |

The older CNF-365 obligations also survive unchanged:

- **Lines 1–19:** maximal named-standby promotion retains “no open restore record and every other restart-promotion condition satisfied”; old-process stopping, old-primary exclusion, both rows, no restore record and the restart branch remain. Connection checks retain “no component uses a connection before a standby has flushed at or past the flush position it reported,” “closure without use or fallback, no check-issued writes, and no check-created `SyncRep` backend,” and topology inspection. Unavailable-report and different-timeline cases retain refusal before operator choice. The alternating-write case still says “promotes the one holding that write, then repeat with the standbys' roles swapped.”
- **Line 39:** equal-report success retains “once promoting each standby,” restart/no-record/no-restore-bump assertions, and “Preserve the engine's ordinary startup-generation advance.”
- **Line 41:** different timelines/unavailable reports retain “neither case may use the equal-position path”; unequal reports retain “only with all other conditions satisfied” and “selecting the behind standby requires an operator's restore.” Known historical disqualifiers retain “equality permits neither promotion as a restart,” automatic-restore refusal, stopped components and acknowledged record before startup.
- **Line 43:** “Assert continuation of that same incident,” “A marked step does not repeat,” both step-(3) cases, and “Equality neither closes the record nor waives any outstanding incident obligation.”
- **Lines 69–70:** the original owner/provenance paragraph remains unchanged.

No existing guard, normative obligation, positive control, negative assertion or theorem is weakened. The reporting fixture’s strengthening relative to historical C-UNKNOWN is precisely item 9’s already-authorized repair. The eligibility obligations added relative to the pin are precisely item 18’s already-authorized additions. No other fixture change or collateral verdict flip is proposed.

The formal layer does not decide report formatting. `Restore.lean` explicitly says “Interval/certificate publication and its evidence protocol remain outside the model's scope”; `WalHistory.lean` says it “models neither incident procedures nor permission to promote.” No declaration or hypothesis changes, and no theorem is offered as proof of either report format or deployment evidence.

**Requested counterargument—not my vote:** Item 18 says “adopt exactly” and “as printed,” while “nonnumeric report” could literally forbid a report containing a numeric timestamp. On that interpretation, R-BOTH changes a check verdict. The strongest reason to reject that interpretation is internal to the adopted package: it explicitly retains the reporting rules that require publication of each known bound. Treating the adjective as a new endpoint-suppression policy would make the package contradict its own retained owner rule and would disregard item 9’s explicit repair. The manager correctly stopped rather than choosing this interpretation unilaterally.

**Brief errors and verification:** I found no verified brief error changing the premise, and no other verified brief error affecting my vote. Under notes.md rule 6, there is no basis here to void the tally. Historical “not adopted” wording is accurately presented as historical.

I verified the form hash, pinned bead copies, HOLD’s identity with the pinned item, and R-BOTH’s exact reconstruction from the pinned item plus C-UNKNOWN’s added eligibility paragraphs. No files or Git state were changed; no gates, Lean commands, background work or subagents were run. Historical gate receipts are not validation of this candidate.

Q1 FINAL: LANDING ONLY
Q2 FINAL: R-BOTH; ITEM9: MEANING PRESERVED / WORDING REBASED; ITEM18: MEANING PRESERVED / WORDING REBASED; AUTHORITY: WORDING RULE