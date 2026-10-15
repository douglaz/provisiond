**Vote: NO-ALARM. Only Q31's wording needs fixing.** The build (`PRV-13c`, `CNF-356`) already matches the spec, and nobody ever decided on a new alarm trigger. I ran no gate because I edited nothing tracked.

**1. Facts (checked at `084cdd9`)**
- `PRV-5`'s alarm is limited to the 403 (02:51-54): "every Robot `403 RATE_LIMIT_EXCEEDED` MUST raise a monitorable alarm naming the provider account and request path … An absorbed read-back failure still raises this alarm".
- Q28's "**One alarm rule**" (ADR-0037:348-350) has its "home is `PRV-5`; the alarms in `PRV-40` and `PRV-22` cite it". Its rejection list (358) is "funding the tail; a local `/server` read budget or reserve; a separate alarm per requirement."
- Q31 says "a failed read of any kind, `rate_limited` included … `PRV-5`'s alarm is raised" (373-378) and "the alarm is raised" (385).
- As built, `PRV-13c` says "MUST NOT suppress `PRV-5`'s … alarm … where its trigger applies" (02:597-598). `CNF-356` asserts the alarm only "On the `403` case" (10:3644).
- No other surface exists. `driver_observation` "is reserved and today unreachable" (05:1120). `OVR-18` alarms only liveness, the recovery point and a stalled standby (00:333-337).
- The spec already handles a sibling read this way. `PRV-13`'s read-back, which "fails for any reason including throttle, authentication, network error" (02:216), settles with only `PRV-5`'s 403 alarm.
- The wording error started in the panel: `r48/synthesis.md:12` put "any failure" and "`PRV-5`'s alarm" in the same sentence.

**2. What silence costs**
- Nothing at all in the normal case. Live deliveries came back with "**same day**, both" (08:419), and v1 sells only offers whose bound is today (`PRV-31`).
- With a deviating contract, the satoshis Q31 says only this read can move into `protected_sats` (ADR-0037:387) stay advertised as runway. At most the tenant's commitment shifts to the operator.
- Silence lasts until the machine's accepted cancellation, including exhaustion. That cancellation's response fills the column (`PRV-13c`, 02:602-604), and `LDG-63` then says the shortfall "MUST be surfaced to the operator as a named deficiency" (12:1990). Payables pick it up from invoices later (`LDG-75`).

**3. What an alarm costs**
- Nobody can act on it. The column has exactly two writers, and neither is an operator (05:268). `PRV-13c` says "The post-order read MUST NOT be retried" and forbids any later re-read (02:599-600).
- It would be louder about an unknown term than the spec is about a known bad one. I found no alarm when a successful read finds a deviation; only `LDG-63`'s deficiency fires, and only at cancellation.
- A trigger owned by `PRV-13c` is exactly "a separate alarm per requirement". Each transient 5xx or timeout would page someone with nothing to do.
- A cheaper signal already exists. `WIR-11`'s machine view carries `earliest_cancellation_date` (13:327). On a Robot machine it is null after attach only if the read failed, because a successful read records today's date (`CNF-356`). That is the "term unverified" mark already. Two limits:
  - It is meaningful per driver only.
  - I found operator access only per tenant (`WIR-33`), and `WIR-25` filters by `?state=` only.

**4. The repair (ADR text only)**
- Q31's Failure bullet: "`PRV-5`'s alarm is raised" becomes "`PRV-5`'s alarm is raised where its trigger applies".
- Q31's Conformance bullet: "the alarm is raised" becomes "on a `403`, the alarm is raised".
- `PRV-13c` and `CNF-356` stay as they are.

**5. Strongest case for the other side (written on request)**

The read only exists to protect money, and Q31 makes it a single attempt with no retry. So one dropped packet quietly cancels the protection for that machine's whole life. Normally that protection would come back on the next attempt; here nothing brings it back. That is a lasting change in what's protected, not a passing error, which is the usual reason a system gets an alarm.

An operator who is told can still act outside provisiond: open Robot's portal, check the date, and reserve by hand.

The null-column signal is weak:
- It isn't searchable across the fleet.
- It means nothing without knowing the driver.
- It is the same null an unattached view shows.

Q28's rejection was aimed at copies of the throttle alarm, not at a different condition that has no alarm at all. One more trigger, kept in `PRV-5` as the single place alarms live, would respect "one alarm rule" and still cover the case.
