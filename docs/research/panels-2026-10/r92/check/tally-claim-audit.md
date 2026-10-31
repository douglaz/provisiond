# Panel M r92 — manager's independent factual and assertion audit

Pin: `d65dc63e059bdefc8bab2e2e64416acf52f5b904`. Historical C-UNKNOWN pin:
`3109b5b44eae17e288cf52aaa976993bd8c5626c`. This audit applies notes.md rule 6
exactly as written; it adds no void rule. Nothing here amends a tracker or adopts
the draft into a specification checkout used by another session.

## Sources and independent reconstruction

The source inventories are the complete committed pv-zuu5 Agent Brief (comment
843, read with `git show <pin>:.beads/issues.jsonl`) and the exact original
[/var/tmp/provisiond-panel-r88/form-C-UNKNOWN.md](/var/tmp/provisiond-panel-r88/form-C-UNKNOWN.md).
The latter's SHA-256 is
`84b5e77d55ed3d3fcf1d4f0d2ffd8020d5abff978c3d949c991a7c449067902b`.
The source copies, pinned rows, full landed diff, r88 tally and owner question
were checked against their originals. The committed PR #53 pv-by1w row was also
checked using `git show 26743d89663e996aceeb9aed245d185310dc3463:.beads/issues.jsonl`.

[verify-tally.py](verify-tally.py) independently compares the historical CNF-365,
the adopted check block and the pinned CNF-365. The historical-to-adopted change
is solely the eligibility insertion. Inserting those exact bytes into the
landed item produces the reviewed R-BOTH. Removing that insertion recovers the
entire pinned item byte for byte, including every assertion and provenance line.
See [tally-verification.json](tally-verification.json) and
[tally-pin-to-R-BOTH.diff](tally-pin-to-R-BOTH.diff).

The complete `05-persistence.md` is identical between the historical pin and
this round's pin. The adopted STO-54 block begins with the unchanged original
1652–1669 block and is retained exactly. The pre-PR52 checklist at `832a219`
equals the historical-pin checklist. The landed diff changes the reporting arm
and pv-zuu5's closure fields; its other tracker context is unchanged. Thus the
old reporting sentence reprinted in C-UNKNOWN was inherited base text, rather
than an eligibility-policy amendment authored by r88.

## What the decisions authorize

Owner item 9 says pv-zuu5 goes to ready-for-agent "with the exact briefs in the
table and the drain lane implements them". Its brief requires "Express the lack
of a finite loss duration separately from publication of a known endpoint" and
"omitting the known bound or inventing a finite duration fails the case".

Owner item 18 says "Adopt C-UNKNOWN: pause automatic recovery until trustworthy
evidence arrives or a person approves a restore" and "No specific evidence
service is required"; its exact-package instruction is "amend STO-54 and CNF-365
as printed". The adopted STO-54 block says unknown reporting endpoints "are
separate: they use the reporting rules below" and do not delay the authorized
restore once its existing prerequisites are satisfied.

Those retained rules, independently read at pin `05-persistence.md:1701–1733`, say:

> A non-null b MUST certify that every source-history component commit acknowledged before b belongs to recovered committed history. A non-null f MUST certify that no component acknowledged an old-history commit after f.

> If either endpoint cannot be certified, persist null for it and say that endpoint is unknown.

> Otherwise publish each known bound, identify every unknown endpoint and state that no finite duration is established; identify clock/provenance assumptions for known bounds.

> Missing reporting evidence does not hold incident creation, the existing restore procedure or component startup once its existing prerequisites are satisfied.

The pinned quotes and formal scope comments are in
[tally-source-quotes.md](tally-source-quotes.md). A first literal substring check
on the formal comments failed because the source wraps its lines; inspecting
the comments and normalizing whitespace confirmed both quotations. No source
or statement was changed to make that check pass.

## Same-fixture traces and requested counterarguments

Take an idle restarted standby with no replayed transaction record and no lower
certificate. Retained event-clock and fencing evidence certifies upper endpoint
f. Historical waiting-backend coverage may independently be missing: a cutoff
on later acknowledgements does not prove no earlier backend termination occurred.
Under C-UNKNOWN the latter uncertainty prevents automatic promotion; the
operator can authorize the existing restore. The report then publishes f and
its provenance, identifies lower b as unknown, and states no finite duration is
established. This satisfies both decisions' owning text.

| Same-fixture output | STO-54 and combined decision verdict | Exact R-BOTH check |
|---|---|---|
| Certified f and provenance; unknown b; no finite duration | Required report | Lines 24–29 require it. |
| Unknown b and no finite duration, but known f omitted | Violates "publish each known bound" | Lines 30–31 explicitly fail it. |
| A fabricated finite duration with b unknown | Violates "only when both endpoints are known" | Lines 30–31 explicitly fail it. |

All readers' requested strongest counterargument is the literal reading of
"an explicit nonnumeric report" as prohibiting even a certified numeric
endpoint. That would make the historical sentence conflict with the same
package's retained "publish each known bound" rule. It is not an independently
adopted prohibition found in item 18. Opus additionally raises whether moving
the explicit unknown-report assertion between fixtures weakens the historical
no-endpoints case. I checked its full trace: the landed item already contains
the separate "Repeat with no verified event-clock bound and assert an unknown
upper bound" and the generic null/evidence assertions, and C-UNKNOWN's final
fixture expressly checks "null endpoints and an explicit unknown report" with
no reporting-evidence wait. R-BOTH preserves all of those exact assertions.
Its reporting-arm differences from historical C-UNKNOWN are precisely the
already-approved pv-zuu5 repair. No additional report verdict is relaxed by
this reconciliation. These are requested counterarguments, not dissent votes.

Literal use of C-UNKNOWN's stale whole-item replacement would remove the landed
"A report omitting the certified upper endpoint or inventing a finite loss
duration fails this case." The stop correctly identified that regression.
Preserving the newer assertion while applying the eligibility insertion does
not imply that the owner rescinded either decision. No reader establishes a
same-fixture incompatible demand from the complete owner packages.

## Assertion-by-assertion landing audit

Locations below are lines in [settled-CNF-365.md](../settled-CNF-365.md), which
equals the complete reviewed R-BOTH. Add 1183 to locate a line when replacing
the pinned item beginning at checklist line 1184. The two source inventories
named above own the assertions; this table verifies their preservation.

| Source assertion | Exact surviving words and location |
|---|---|
| pv-zuu5: unknown-lower/known-upper idle fixture | 21–24: "replayed no transaction record and no retained fallback proof, leaving the lower history endpoint unknown"; "supply valid retained event-clock and stopping/fencing evidence certifying an upper endpoint". |
| pv-zuu5: null lower | 24–25: "persists `lost_window_starts_at` as null". |
| pv-zuu5: certified upper persisted | 25: "`loss_end_at` as that certified upper endpoint". |
| pv-zuu5: evidence reference and reasons | 25–27: "a non-null incident-keyed `history_evidence_ref` identifying the retained evidence and the unknown-lower-endpoint reason". |
| pv-zuu5: upper published with assumptions | 27–28: "the operator report publishes the certified upper endpoint and its clock/provenance assumptions". |
| pv-zuu5: explicit unknown lower and duration | 28–29: "identifies the lower endpoint as unknown and states that no finite duration is established". |
| pv-zuu5: omission failure | 30–31: "A report omitting the certified upper endpoint or inventing a finite loss duration fails this case." |
| pv-zuu5: invented-duration failure | The same complete sentence at 30–31 explicitly rejects it independently of known-bound omission. |
| Both: existing restore procedure | 31: "Follow with the existing restore procedure." |
| Both: no verified event clock | 31–32: "Repeat with no verified event-clock bound and assert an unknown upper bound." |
| Both: no invented replacement bound | 32–33: "Do not use a restart time or a backup name to fill an unknown history bound." |
| C-UNKNOWN: lagging-standby certified positive case | 20–21: "Promote a lagging standby as an operator restore with verified prefix/clock evidence and assert the incident stores certified bounds." |
| C-UNKNOWN: old unknown-history/nonnumeric-report check | 24–29 explicitly check the null/unknown lower and absence of finite duration; 30–31 forbid a fabricated duration; 65–67 separately check both null endpoints and "an explicit unknown report". The retained reporting owner requires publication of certified f, as quoted above. |
| Both: evidence for every known endpoint | 34–35: "supply certified evidence for each asserted known `lost_window_starts_at` or `loss_end_at`". |
| Both: null for every unknown endpoint and reference | 35–37: "store null for each unknown endpoint and retain a non-null incident-keyed `history_evidence_ref` identifying evidence or unknown-endpoint reasons". |
| C-UNKNOWN: paired fixture common inputs | 45–46: "two fixtures with identical surviving standby reports on the same actual old-primary history and no open incident". |
| C-UNKNOWN: clean/equal evidence positive control | 46–48: "complete trustworthy negative evidence of no waiting-backend cancellation or termination; satisfy every other restart condition. Promote each equal standby in a separate run". |
| C-UNKNOWN: positive restart and no restore effects | 49–50: "assert restart classification, no restore record and no restore credential-generation bump, preserving the ordinary startup-generation advance". Always refusing cannot pass. |
| C-UNKNOWN: hidden independently observed event | 50–53: "termination independently observed by the test", loss of primary/logs and hidden event evidence, with "the surviving reports are the same as in the first fixture". |
| C-UNKNOWN: hidden-event verdict and notice | 53: "Assert unknown eligibility, operator notice and no automatic promotion." |
| C-UNKNOWN: no oracle leak or false known violation | 54–55: "Do not give the procedure the test's hidden oracle or label its unknown state as a known violation." |
| C-UNKNOWN: valid known event, including shutdown | 55–56: "supply valid event evidence and assert the existing restore classification, including when the termination was caused by primary shutdown". |
| C-UNKNOWN: no-event lost/incomplete coverage | 58: "Repeat unknown eligibility with no event in fact but lost or incomplete coverage". |
| C-UNKNOWN: mismatched identity/history | 58–59: "mismatched database/incarnation/ancestry evidence". |
| C-UNKNOWN: unauthenticated/conflicting evidence | 59–60: "an unauthenticated clean assertion and conflicting records". |
| C-UNKNOWN: no missing-log/noncontinuous pass | 60: "Missing logs or an assertion without continuous coverage cannot pass." |
| C-UNKNOWN: known termination inherited | 60–62: "Retain a known termination and separately an unknown interval across later catch-up, equal reports and an incarnation change on which the next restart depends; neither is silently reset." |
| C-UNKNOWN: unknown interval inherited | The same sentence at 60–62 separately retains the unknown interval. |
| C-UNKNOWN: no automatic restore | 62–63: "In each unknown fixture assert no restore begins automatically". |
| C-UNKNOWN: explicit operator authorization | 63–64: "let an operator explicitly authorize one". |
| C-UNKNOWN: stopped components and acknowledged record | 64–65: "assert the stopped-components procedure and an acknowledged incident record before startup". |
| C-UNKNOWN: stated reproduction limit | 65: "This is not a fast-shutdown read/action reproduction." |
| C-UNKNOWN: no certified report endpoints | 65–67: "Finally authorize a restore with no certified loss-report endpoints and assert null endpoints and an explicit unknown report". |
| C-UNKNOWN: no reporting-evidence delay | 67: "followed by the existing procedure without a wait for reporting evidence". |
| Both: original promotion success and selection | 1–6 retain "at least as far ahead as the other's", "no open restore record and every other restart-promotion condition satisfied", stopped old processes, "serves no component", both rows, no restore record and "`OPS-15`'s restart branch". |
| Both: connection failure controls | 6–11 retain primary/backend stalled-write crashes, "no component uses a connection before a standby has flushed at or past the flush position it reported", deadline failure, "closure without use or fallback, no check-issued writes, and no check-created `SyncRep` backend", plus topology inspection. |
| Both: unavailable/timeline/operator boundary | 12–19 retain "none until an operator decides", "automatic failover promotes neither standby at all, including as a restore", numerical-equality independence and the commit-holder selection with roles swapped. |
| Both: existing equal-report successful restarts | 39 retains "once promoting each standby", "restart classification, no restore record and no tenant credential-generation bump from the restore procedure" and ordinary startup advance. |
| Both: equal-report exclusions and behind selection | 41 retains "neither case may use the equal-position path", "only with all other conditions satisfied", "selecting the behind standby requires an operator's restore", and "equality permits neither promotion as a restart" for known historical disqualifiers. |
| Both: existing known-restore ordering | 41 retains "Automatic failover does not perform these restores" and the stopped-components/acknowledged-record-before-start requirement. |
| Both: continuation | 43 retains "Assert continuation of that same incident", "A marked step does not repeat", both step-(3) mark cases and "Equality neither closes the record nor waives any outstanding incident obligation." |
| Both: owner/provenance | 69–70 are identical to the original provenance lines. The added blank line separates them from the preceding paragraph exactly as the adopted form did. |

The fixed accompanying STO-54 block remains the entire adopted block, including
its evidence predicate, known-disqualification precedence, automatic-refusal
and operator boundary, no-expiry/inherited-uncertainty treatment, continuation
distinction and "operator belief alone cannot reclassify unknown as
established". None of that owner text is repaired or reinterpreted by r92.

No formal declaration, statement, guard hypothesis, negative control or gate
is changed. `Restore.lean` says "Interval/certificate publication and its
evidence protocol remain outside the model's scope" and `WalHistory.lean` says
"It models neither incident procedures nor permission to promote". A full
gate checks consistency of the specification; it is not runtime evidence of
report generation or an implementation of deployment certificates.

## Brief errors, rule 6 and authority

Opus identifies two imprecisions, independently verified: the original
owner/provenance lines continue the open-record paragraph until the insertion
separates them, and the printed STO-54 range is an excerpt rather than the
entire requirement. The first is a paragraph description with correct printed
bytes. The second is a correctly labelled line range with complete relevant
reporting/eligibility context, not an assertion that STO-54 ends there. Neither
changes the question's premise. Opus explicitly says neither grounds its vote;
Astra and Sol identify no premise-changing brief error. Rule 6 therefore
requires reporting these imprecisions, with no affected vote; it does not void
either tally. No additional void rule is used.

There is no dissenting final vote to investigate. All requested countertraces
are addressed above. The wording-authority test compares the combined existing
owner decisions, rather than pretending C-UNKNOWN's already-authorized
eligibility change is editorial relative to master. R-BOTH preserves item 9's
landed check strength and item 18's exact added assertions and owning rule;
it introduces no third behavior, requirement or check-strength choice.
Accordingly the settled form falls under the owner's 2026-10-28 wording rule:
"For such wording questions, try to solve by getting a consensus of the panel".
No owner question is needed under this turn's explicit instruction.
