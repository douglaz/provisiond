# Q4 T-complete — coordinator assembly, UNREVIEWED

This is a proposed complete edit package against 4662d85. It combines r74's T comparisons, returned pointer/rationale companions, and an explicit open-incident fixture guard. Nobody has yet accepted this assembly. The package settles equality only; Q1–Q3 proposals are not included or presumed adopted.

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
> Repeat with equal numerical reports on different timelines and with an unavailable report; neither case may use the equal-position path. With unequal reports on the same history, the greater end may use the restart path only with all other conditions satisfied; selecting the behind standby requires an operator's restore. Repeat equal reports after the primary committed without either named standby, and separately after a waiting backend was cancelled or terminated: equality permits neither promotion as a restart. Automatic failover does not perform these restores; an operator's restore follows the stopped-components procedure and commits its record with acknowledgement before component startup.
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

## Review target

Read T1–T6 as one package. Check all exact anchors against the pin, apply it in a throwaway copy only if useful, and challenge both behaviour marks and fixture reachability. Confirm whether it contains only equality policy, conformance controls and matching pointer/comment repairs. If any required correction changes behaviour or restricts a fixture further, give exact wording and count the printed package as AMEND rather than silently accepting your repair.
