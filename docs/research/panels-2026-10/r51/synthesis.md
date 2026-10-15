# Panel r51 synthesis — should a non-rate-limit failure of Robot's post-order read raise an alarm? (Q31 alarm), 2026-10-15

Readers: fable (claude-fable-5-1), opus (claude-opus-5-5), astra (gpt-6-astra), sol (gpt-6.1-sol), all at xhigh;
clones at 084cdd9. All exit 0.

## Votes

All four: **NO-ALARM** — keep `PRV-5`, `PRV-13c` and `CNF-356` as built; fix `ADR-0037` Q31's Failure bullet to
"`PRV-5`'s alarm is raised where its trigger applies" and its Conformance bullet to the `403` case.

## Facts the readers established

- `PRV-5`'s alarm is the 403 rule only; Q28 made it "One alarm rule" with its "home" at `PRV-5`, and rejected
  "a separate alarm per requirement". As built, `PRV-13c` keeps that alarm "where its trigger applies" and
  `CNF-356` asserts it "On the `403` case": other-failure alarms are not required, rather than prohibited.
- The wording slip traces to r48: its synthesis put "any failure" and "`PRV-5`'s alarm" in one sentence, citing
  `PRV-5`'s existing rule, not proposing a new trigger (opus, fable).
- The spec already treats a sibling read this way: `PRV-13`'s delete read-back, which "fails for any reason
  including throttle, authentication, network error", settles with only `PRV-5`'s 403 alarm (opus).
- No other surface reports a failed provider read: `OVR-18`'s three alarms are liveness, recovery point and a
  stalled standby; `driver_observation` "is reserved and today unreachable"; `API-28`/`SEC-32` require no log of
  this absorbed error.
- **A signal already exists:** `WIR-11`'s machine view carries `earliest_cancellation_date`; on a settled Robot
  machine it is null only if the post-order read failed, because a successful read records today's date. It
  carries no cause or timestamp, and operator access is per tenant (`WIR-33`), not fleet-wide.
- Cost of silence: none in the normal case (v1 sells only today-bound offers; live deliveries were same-day). On
  a deviating contract, satoshis stay advertised as runway until the machine's accepted cancellation fills the
  column; `LDG-63` then surfaces any shortfall "as a named deficiency", and invoices supply the rest (`LDG-75`).
- Cost of an alarm: nobody can act on it inside provisiond — the read "MUST NOT be retried" and the column has no
  operator writer — and each transient timeout or 5xx would page.

## Strongest case for the other side (written on request — not the readers' positions)

Because the read is one attempt with no retry, one dropped packet removes that machine's protection for its whole
life — a lasting change, not a passing error. An operator who is told could check Robot's portal and reserve by
hand. The null field is a pull nobody must perform. One more trigger kept in `PRV-5`, the single home for alarms,
would respect "one alarm rule" (opus).
