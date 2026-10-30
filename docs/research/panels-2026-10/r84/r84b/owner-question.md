# Owner question 1 — unresolved after the ONE consensus round

**TL;DR:** The panel is still split. Should a pasted device path be refused immediately, or reach rescue and be checked as an identity string?

An inventory shows a disk's serial beside its path, `/dev/sda`. A caller pastes the path into the serial field. If no serial matches, A accepts the request, reboots into rescue, then fails without writing. C refuses it before the reboot. The cost of C is that a real serial beginning `/dev/` cannot be used, even though the inventory displays it.

**Which behavior should we adopt?** There is no unique panel recommendation; A and C are tied first picks and accepted by all four. A is listed first as the pinned admission behavior, not as a manager tie-break.

1. **Keep identity admission (A; tied first pick).** Fable and sol prefer A (2); all four accept it. Preserve all otherwise-admissible identity spellings, including a unique serial literally `/dev/sda`; an unmatched value can cause the rescue reboot before failure.
2. **Refuse `/dev/` first (C; tied first pick).** Opus and astra prefer C (2); all four accept it. Avoid that recognizable path-paste reboot, while deliberately losing identity echoes beginning `/dev/`.
3. **Refuse every slash (B).** No first picks; opus/astra/sol accept, fable rejects as policy. Broader refusal also loses serials such as `a/b`.

**Each reader's r84b pick and strongest argument:** fable A — keep the previously adopted admission domain; opus C — avoid the reboot and a path paste selecting another disk's path-shaped serial; astra C — the documented rescue disruption warrants the narrow prefix exclusion; sol A — preserve identity echoes and resolve writes from the matched disk. No verified blocking loss in any Q1 form. Fable's claim of identical write outcomes in every A/C case is too broad: C refuses a matching `/dev/` serial that A can install onto. The path-shaped-serial example is hypothetical, not a provider fact.

**Decision homes and exact forms:** pv-ez8; A changes CNF-200 and CNF-363 case (14), exact `check/tally/q1-A.md`; C/B additionally amend API-13, exact `check/tally/q1-C.md` / `q1-B.md`. RSC-26 retains "The identifier is authoritative; the path is derived" and "An identifier that does not resolve to exactly one device MUST abort `integrity` before any write". Precedent: pv-6p8 comment 801 item 7 records "A well-formed string that matches nothing still aborts `integrity`". Owner tie rule: "a tie comes to you"; this one consensus round is exhausted. Q2 pv-2j3 is already decided by owner-decisions-1030.md item 8 and is not part of this question.
