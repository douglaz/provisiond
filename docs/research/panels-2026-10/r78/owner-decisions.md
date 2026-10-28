# Owner decisions, Panel C (r78), 2026-10-28

## pv-kwuf — startup-lock wait bound precision (OVR-19, OPS-15, CNF-369, ADR-0047)

Question as put: "pv-kwuf: the startup-lock wait bound is also used for the two PostgreSQL timeouts. Exact whole milliseconds rejects 1.5 ms; rounding down accepts it and applies 1 ms. Which precision rule?"
- "Whole milliseconds (Recommended)": K-EXACT. All 5 readers picked it first (fable, opus, astra, sol, grok); 5 accept / 0 cannot. Configured value = effective value; no conversion. Cost: fractional-ms configs refuse to start.
- "Round down": K-FLOOR. 0 first picks, but 5 counted accepts. 1.5 ms runs as 1 ms. Cost: a conversion rule in OPS-15, extra boundary tests, two more pointer repairs.

Owner answer (verbatim): "Whole milliseconds (Recommended)"

Meaning: adopt exactly the printed K-EXACT package in /var/tmp/provisiond-panel-r78/brief.md plus Sol's verified quotation-only repair R1 (ADR-0047:73), as tallied in /var/tmp/provisiond-panel-r78/tally.md Q1. Fable's FLOOR-only cell and Sol R2 are not part of it. OPS-15's timeout, fatal exit and lost-reply text stay unchanged. pv-kwuf goes to ready-for-agent with that package as its brief, landing in a drain branch's preparation commit together with the r78 records under docs/research/panels-2026-10/.

## pv-75w3

Not settled at r78 (1 conditional S-STOP, 4 behavioural AMENDs); second round r78b finished 2026-10-28 13:34Z, tallied in /var/tmp/provisiond-panel-r78/r78b/tally.md (4 ACCEPT fable/opus/astra/sol; grok AMEND not countable, its date repair failed verification; 0 CANNOT ACCEPT).

Question as put: "pv-75w3: a machine delete gets stopped before it commits, and later an operator retries it. Should the conformance tests cover that path?"
- "Add the checks (Recommended)": "Add the reviewed S-STOP-R package as printed. 4 accept (fable, opus, astra, sol), 0 cannot accept. Grok also supports it, but only with an edit to the model note that doesn't hold up when checked, so its vote isn't counted. Cost: extra test runs with a controlled stop and an engine restart."
- "Keep current coverage": "No reader preferred this. The best case for it, given when asked for and not cast as a vote: the stored state comes out the same, CNF-362 already checks that a stopped delete settles as failed, and fewer tests cost less."

Owner answer (verbatim): "Add the checks (Recommended)"

Meaning: adopt exactly the printed S-STOP-R (S1–S4) in /var/tmp/provisiond-panel-r78/r78b/brief.md, with its already-instructed actual-landing-date substitution in S3, as tallied in r78b/tally.md. No grok repair, no manager union, no new fixture restriction, no executable formal edit. Lands on CNF-312, OPS-41's model-verification note, ADR-0032 and the two explanatory comments in tools/formal/Provisiond/Fence.lean. pv-75w3 goes to ready-for-agent with that package as its brief, in the next drain branch's preparation commit (after pv-oehp's), and drains after pv-kwuf.
