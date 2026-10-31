# Owner approval — Panel H r87b Q1

**TL;DR:** The panel prefers immediate reported failure, with deployment deciding when to run
again. Exact O has final picks Fable/Astra/Sol; Opus picks F and accepts O. Both O and F are
accepted by all four. Grok is missing, 402. This is approval of behavior, requirements and test
strength, not adoption by the panel. No further round will launch.

**Plain terms:** The old release is still serving. At 12:00 the database updater asks for a
connection and receives “capacity full”. The proposed rule makes it print why and stop at once.
Deployment can run it again later, and must keep the new release stopped until the updates have
finished successfully. If capacity never frees, the rollout can remain delayed indefinitely.
It does not impose a deadline on an unanswered connection-authority call or an SQL lock wait.

**Approve exact O for this behavior and its checks?**

- **Approve O (Recommended):** use the complete [reviewed O](forms/q1-O.md). Print the updater,
  release, first-connection/reconnect stage and refusal reason without credentials; exit at once
  without internal waiting/retry. Require successful migration completion before new components
  start, and add the independent refusal and lock-wait checks. Final picks: Fable, Astra, Sol;
  Opus also accepts. Acceptability 4–0.
- **Choose F:** use the complete [reviewed F](forms/q1-F.md). Same rule and checks, but require
  the reason “as the authority returned it”, still without credentials. Opus's final pick:
  naming the response as the source makes that field directly comparable in the fixture.
  Fable/Astra/Sol also accept. Acceptability 4–0.
- **Keep D / no change:** preserve [reviewed D](forms/q1-D.md). No new migration-specific outcome
  or checks; intentionally leave the gap open. No final picks; acceptability 0–4. This remains
  an owner scope choice, not a fixed-bead result.

Each reader's strongest argument and all A/B/C/D/F/O judgments are in [tally.md](tally.md).
Fable prefers O's smaller reason obligation; Astra prefers its retained timing/boundary without
unnecessary context; Sol prefers its normalized truthful reason with deployment retry. Opus
prefers F's explicit source. No verified blocking loss or premise-changing brief error was found.
O does not promise a numerical total rollout bound. B's printed rule/fixture conflict is not
silently repaired, and no synthesized option is recommended.

IDs last: `pv-3zzo`; exact O or F amends **STO-55**, **STO-13**, **CNF-57** at the landing sites
in `brief.md`, “Complete exact alternatives”. O/F adds no parameter, identifier, ADR or formal
change. Prior “Approve (Recommended)” authorized triage and Panel H, not this policy.
