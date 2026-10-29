# Check 2b at c824e4f

rg -n -i 'restore_instant|transaction_timestamp|lost-reply|restore instant' docs .beads/issues.jsonl

Full matches are retained in clock-grep.txt; this includes docs/adr and the archived r77/r77b/r80 trees. No matching text occurs under archived r80. The current clock definition and direct formal documentation are inventoried in brief.md. Owner P adoption: docs/research/panels-2026-10/r77/owner-decisions.md:24-26. UO: docs/research/panels-2026-10/r74/owner-decisions.md:6-10 and decisions/pv-3jw6.md:47,53,73; those define the old event clock, not its precedence over P on an absent-record retry. Archived r77b/tally.md:39-43 traces a committed lost reply and mentions an uncommitted first attempt without resolving the inserting-transaction timestamp conflict. No recorded owner decision found settles this pair.

pv-kwuf is .beads/issues.jsonl:100 (committed comment 840) and docs/research/panels-2026-10/r78/owner-decisions.md:3-11. K-EXACT's exact precision rule is for OVR-19's Startup-lock wait bound and OPS-15's statement_timeout/lock_timeout, not restore_instant. Its application scope is OVR-19/CNF-369/ADR-0047 with startup semantics retained; no restore clock or stored timestamp precision amendment. Exact source passages in brief.md.
