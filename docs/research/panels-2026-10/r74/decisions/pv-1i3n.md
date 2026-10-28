# pv-1i3n — proposed ready-for-agent brief

Draft only. This file has not been posted and changes no tracker state. The body between the
Agent Brief markers is the proposed bead comment. Local provenance stays outside that comment.

<!-- AGENT_BRIEF_BEGIN -->
## Agent Brief

**Category:** bug. **Readiness:** ready to apply T-known as written, after the ordinary
fresh-master anchor check and live-Run hold.

**Owner answer, verbatim (2026-10-28):**

> Yes, T-known (Recommended)

**Option shown to the owner, verbatim:**

> Panel pick, 4–0 as written. Promote either as a restart, so tokens stay valid; all existing guards and known-violation handling stay. Becomes ready-for-agent.

**Problem and desired behavior:** Make equal valid maximal reports eligible for the restart path
without introducing a tenant credential-generation bump, while keeping the open-incident and
prior-violation cases distinct.

**Landing sites:** `STO-54` and the `STO-5` pointer in `05-persistence.md`; `CNF-365` in
`10-conformance-checklist.md`; the module classification comment in
`tools/formal/Provisiond/Restore.lean`. After the rule edits, record the equality decision and
point to the classification owner in `ADR-0045`. No new identifier or formal declaration is needed.

**Exact reviewed T1–T6 package to execute:**

<!-- REVIEWED_TEXT_BEGIN -->
~~~markdown
## T1: STO-54 comparisons — behaviour changed

In `05-persistence.md`, replace exactly:

> and the one further ahead is promoted:

with:

> and a standby whose reported end is at least as far ahead as the other's is promoted (either may be chosen when they are equal):

Replace exactly:

> or of the one not further ahead,

with:

> or of a standby whose reported end is behind the other's,

No other restart-promotion precondition is removed. In particular the existing open-record exception, old-process stopping, old-primary fencing, named-standby membership, same-history report requirements, prior posture conditions and other-standby streaming requirement retain their current text.

## T2: STO-54 reasoning — behaviour unchanged relative to T1

Replace exactly:

> so that one holds them all

with:

> so every standby at the maximal reported end holds them all

This changes no evidence requirement. Its premise remains the paragraph's existing sentence:

> every acknowledged commit was flushed by one of them, and both hold a prefix of one WAL sequence

## T3: STO-5 pointer — behaviour unchanged relative to T1

Replace this entire italic paragraph:

> *Promoting the standby `STO-54`'s report puts further ahead is a restart; `STO-54` says what any other promotion is: "is a restore: the procedure below runs on it" (`ADR-0045`).*

with this bare pointer:

> *For promotion classification, see `STO-54` (`ADR-0045`).*

The classification rule remains solely in STO-54; its existing unaltered introductory restart promise stays in STO-5.

## T4: CNF-365 title and initial drill — behaviour changed for tally purposes

In `10-conformance-checklist.md`, replace exactly:

> **Promoting the standby `STO-54`'s report puts further ahead is a restart**

with:

> **Promotion after the primary is lost**

Replace exactly:

> Kill the primary and promote the standby `STO-54`'s report puts further ahead by the deployment's procedure, with a standby streaming from the promoted store.

with:

> Kill the primary and promote a named standby whose reported end is at least as far ahead as the other's, with no open restore record and every other restart-promotion condition satisfied, by the deployment's procedure, with a standby streaming from the promoted store.

All following original assertions and controls remain unchanged. The explicit positive-fixture restriction is declared behavioural; it is not smuggled in as a citation repair.

## T5: CNF-365 appended equality controls — behaviour changed

Append before its existing owner references/history, keeping every new paragraph indented as part of the same checklist item:

> Repeat with both named standbys reporting the same flushed end on the old primary's timeline, no open restore record and every other restart-promotion condition satisfied, once promoting each standby. Assert restart classification, no restore record and no tenant credential-generation bump from the restore procedure. Preserve the engine's ordinary startup-generation advance.
>
> Repeat with equal numerical reports on different timelines and with an unavailable report; neither case may use the equal-position path. With unequal reports on the same history, the greater end may use the restart path only with all other conditions satisfied; selecting the behind standby requires an operator's restore. Repeat equal reports after the primary committed without either named standby, and separately after a waiting backend was cancelled or terminated, each made known to the deployment's procedure: equality permits neither promotion as a restart. Automatic failover does not perform these restores; an operator's restore follows the stopped-components procedure and commits its record with acknowledgement before component startup.
>
> Repeat equal reports with an open restore record. Assert continuation of that same incident. A marked step does not repeat; with step (3) unmarked, its credential-generation bump still occurs when that step is completed, and with step (3) already marked it is not repeated. Equality neither closes the record nor waives any outstanding incident obligation.

These controls distinguish numerical equality, valid same-history equality, incident continuation and prior posture violations. They introduce no new historical-evidence mechanism and do not assume a Q1 monitor exists.

## T6: formal module classification comment — behaviour unchanged relative to T1

In `tools/formal/Provisiond/Restore.lean`, replace exactly:

> Promoting the standby
> `STO-54`'s report puts further ahead is a restart (`STO-54`), and any other promotion is a
> `RestoreTrace`.

with:

> For promotion classification, see `STO-54`. This module takes the classification as input;
> it does not compare WAL reports. A restore-class promotion is a `RestoreTrace`.

No declaration, guard hypothesis or theorem changes. The package claims no formal proof of WAL report accuracy or comparison. No checklist identifier is added to `tools/formal/`.
~~~
<!-- REVIEWED_TEXT_END -->

**Disclosed obligations/limits:** Retain trustworthy same-history reports and every existing
stopping, fencing, membership and streaming guard. Equal numbers authenticate neither the reports
nor hidden unsafe history. The known-violation fixtures supply the procedure's knowledge;
they introduce no historical detector. An open incident continues with its original step marks;
the ordinary engine startup-generation advance remains distinct from tenant credential generation.

**Acceptance:** Check each T1–T6 replacement and the equal/unequal/unavailable/different-timeline,
known-violation and open-incident controls. Keep UO's added `CNF-365` restore-report arm intact if
it has already landed. Preserve the original other-timeline control for the subsequent pv-5lip
strengthening. Do not turn knowledge in an injected fixture into a new general classification
exception or adopt any runtime controller.

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
`r76/tally.md` Q4 counts fable/opus/astra/sol ACCEPT on T-known, including the already-reviewed
known-violation fixture restriction. T1–T6 are copied byte-for-byte; historical candidate preamble
and the final review solicitation are not application instructions and are omitted. No repair.
Original candidate SHA-256: `6dbae0d502b7f7f1b3211227b007f1646df6d7be9cc11300becc8feb3300fbf4`. T1–T6 package SHA-256: `f984a4bbb019c1c50883fafe7a283f052b4a2edb0a948ddd8369ddcaf5806cf2`.

This turn authorizes drafts only. No Run, tracker mutation, source application, branch operation
or PR follows from this file. Live pv-6350 must leave the checkout before any later drain starts.
