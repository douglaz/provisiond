# Owner decisions, Panel B (r77), 2026-10-28

## pv-8mt4 — negative model for the successor sweep (OPS-15, Provisiond.Restore.successor_sweeps_running)

Question as put: "pv-8mt4: which broken test model should the spec add?"
- "Add M-I (Recommended)": separate model with both checks off; existing model kept. 5 of 5 accept, 4 prefer (opus, astra, sol, grok).
- "Re-read smaller M-S": fable's preference: one skipped startup step. As written 0 accept; costs another reading round.

Owner answer (verbatim): "Add M-I (Recommended)"

Meaning: adopt exactly the printed M-I package in /var/tmp/provisiond-panel-r77/brief.md, as tallied in /var/tmp/provisiond-panel-r77/tally.md. No unread repair or union is approved. pv-8mt4 goes to ready-for-agent with that package as its brief, landing in a drain branch's preparation commit together with the r77 records under docs/research/panels-2026-10/.

## pv-ymjo

Not settled at r77 (PROV 2, WIDE 1); decided at r77b, see below.

## pv-ymjo — decided (r77b)

Question as put: "pv-ymjo: after a crash, does provisiond trust install facts recorded since the last restore?"
- "Adopt P (Recommended)": Trust them. 4 accept, 4 prefer (fable, astra, sol, grok); fixes are wording only.
- "Adopt W": Hide them for good. 4 accept, none prefer; it guards against a restore path that skips its reset.
- "Read opus's fix first": Opus: a lost reply to a retry can leave startup stopped. Its fix changes behaviour and is unread, so another round.

Owner answer (verbatim): "Adopt P (Recommended)"

Meaning: adopt package P as tallied in /var/tmp/provisiond-panel-r77/r77b/tally.md, with only the wording-only repairs that tally verified and counted toward P (it lists them); nothing else. Opus's R2 is NOT adopted (unread behavioural repair); its dissent stays on record. pv-ymjo goes to ready-for-agent with that package, in the next drain branch's preparation commit (or the current one, if not yet committed).
