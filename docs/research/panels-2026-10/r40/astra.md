1. **Gone when seen gone; review of `dec039f`: FAIL pending the clarifications below.**

DOM-19 explicitly allows “unless the resource is independently recorded gone before it” ([01-domain-model.md:120](https://github.com/douglaz/provisiond/blob/dec039f878821929479f136c8a51c797a893d1b8/01-domain-model.md#L120)). A cancellation acknowledgement and subsequent absence are compatible facts. The returned day does not prove continued existence.

**Blocker/edit:** [02-provider-contract.md:180](https://github.com/douglaz/provisiond/blob/dec039f878821929479f136c8a51c797a893d1b8/02-provider-contract.md#L180) classifies the *driver* instead of the individual outcome. Amend PRV-13: **authoritative gone evidence selects gone; a provider-established schedule supplies its effective date; a raw calendar date alone selects neither.** Preserve per-contract branching. Your fallback also needs qualification: presence inside the visibility window cannot distinguish pending destruction from scheduling. PRV-29 explicitly separates “accepted-pending” from “scheduled with an effective date” ([02-provider-contract.md:327](https://github.com/douglaz/provisiond/blob/dec039f878821929479f136c8a51c797a893d1b8/02-provider-contract.md#L327)).

The scheduled reading can charge through `min(day_end, sweep_observation)` instead of the direct observation. The paid first unit may absorb that difference: LDG-38 says “the prepaid debit stands” ([12-billing-and-ledger.md:959](https://github.com/douglaz/provisiond/blob/dec039f878821929479f136c8a51c797a893d1b8/12-billing-and-ledger.md#L959)). Direct confirmation costs a provider read but avoids that delay and reaches PRV-45’s “every delete that succeeds with the resource gone” listing ([02-provider-contract.md:529](https://github.com/douglaz/provisiond/blob/dec039f878821929479f136c8a51c797a893d1b8/02-provider-contract.md#L529)). Hourly provider billing does not establish this server’s final invoice; [Hetzner confirms hourly billing](https://docs.hetzner.com/general/billing-and-account-management/cancellation/cancellations-robot/), while LDG-75 assigns “Provider tails after the gone-write” to the operator ([12-billing-and-ledger.md:2130](https://github.com/douglaz/provisiond/blob/dec039f878821929479f136c8a51c797a893d1b8/12-billing-and-ledger.md#L2130)).

2. **One authoritative direct absence during the ordinary delete is enough; no second 404.**

PRV-36 says “A read showing the post-mutation state is evidence at any time” ([02-provider-contract.md:960](https://github.com/douglaz/provisiond/blob/dec039f878821929479f136c8a51c797a893d1b8/02-provider-contract.md#L960)). Require the correct account and known machine identity, with provider-mapped `SERVER_NOT_FOUND`, not arbitrary HTTP 404. [Robot documents that mapping](https://robot.hetzner.com/doc/webservice/en.html#get-server-server-number). The supplied summary omits the error code; retain it in verification evidence.

OPS-32 explains its re-read: “The listing narrows the candidates; it never establishes one” ([03-operation-lifecycle.md:1380](https://github.com/douglaz/provisiond/blob/dec039f878821929479f136c8a51c797a893d1b8/03-operation-lifecycle.md#L1380)). That is listing-plus-direct-read, not direct-read-plus-direct-read.

**Blocker/edit:** qualify the blanket window statements at [02-provider-contract.md:915](https://github.com/douglaz/provisiond/blob/dec039f878821929479f136c8a51c797a893d1b8/02-provider-contract.md#L915) and [12-billing-and-ledger.md:534](https://github.com/douglaz/provisiond/blob/dec039f878821929479f136c8a51c797a893d1b8/12-billing-and-ledger.md#L534); cite the positive-evidence exception. Preserve the separate restriction that resolution “MUST NOT take its first read before the window has elapsed.” A failed confirmation after acceptance remains uncertain; OPS-11 says a later error “MUST NOT classify that accepted mutation `failed`” ([03-operation-lifecycle.md:274](https://github.com/douglaz/provisiond/blob/dec039f878821929479f136c8a51c797a893d1b8/03-operation-lifecycle.md#L274)).

3. **Amend Q18a to use the verified provider calendar; the sample does not establish Berlin cancellation semantics.**

The [key observation, live-result.txt:8](docs/research/panels-2026-10/r39/live-result.txt:8) establishes UTC+2 for that timestamp. It establishes neither the cancellation field’s zone nor its winter behavior. Treat `Europe/Berlin` as unverified until cancellation-specific evidence establishes it.

**Blocker/edit:** move the common rule from [02-provider-contract.md:544](https://github.com/douglaz/provisiond/blob/dec039f878821929479f136c8a51c797a893d1b8/02-provider-contract.md#L544) into PRV-13; replace the duplicate at [13-wire-contract.md:899](https://github.com/douglaz/provisiond/blob/dec039f878821929479f136c8a51c797a893d1b8/13-wire-contract.md#L899) with a reference:

> For a scheduled cancellation expressed as an inclusive calendar day, the boundary is the start of the following calendar day in the driver’s verified provider zone, converted to UTC. Explicit timestamps retain their instant. A `now` acknowledgement does not itself establish a scheduled boundary.

This also replaces `23:59:59` with an exact exclusive boundary. Under Berlin rules, October 11 ends at `2026-10-11T22:00:00Z`.

Proven immediate cancellations need no date conversion. Genuine future constraints still affect reserves and scheduled stops; `earliest_cancellation_date` is permission to cancel, not evidence of completed cancellation. Future-scheduled offers remain subject to LDG-38’s “automatic, idempotent corrective credit” precondition ([12-billing-and-ledger.md:986](https://github.com/douglaz/provisiond/blob/dec039f878821929479f136c8a51c797a893d1b8/12-billing-and-ledger.md#L986)).

4. **Don’t build another settlement mechanism: select existing outcomes, normalize dates inside drivers, retain Q21’s survivor precondition.**

No engine timezone service, second-confirmation timer, or Robot-wide immediacy constant.

**Blocker/edit:** complete Q21’s tombstone deletion, including the overlooked “tombstone … clears the fence” at [12-billing-and-ledger.md:653](https://github.com/douglaz/provisiond/blob/dec039f878821929479f136c8a51c797a893d1b8/12-billing-and-ledger.md#L653). Remove `Event.tombstone` from [Tables.lean:358](https://github.com/douglaz/provisiond/blob/dec039f878821929479f136c8a51c797a893d1b8/tools/formal/Provisiond/Tables.lean#L358), its [Render.lean:59](https://github.com/douglaz/provisiond/blob/dec039f878821929479f136c8a51c797a893d1b8/tools/formal/Provisiond/Render.lean#L59) edge, and update the rendered table/diagram, WIR-35 and CNF-271.

Extend CNF-237/271/328: dated acknowledgement plus direct absence; pending presence versus established schedule; failed reads; later stale presence; atomic meter/episode/fence changes; attachment listing; preserved first-unit debit; Berlin midnight and DST boundaries.

Lean must distinguish deletion goal evidence from creation absence, preserve sweep guards and permanent closure, and retain earlier-of metering. Do not weaken `Reconcile.absence_requires_three` to model another path. Provider truth and timezone correctness remain external assumptions. Keep CNF identifiers outside Lean.

Both required gate runs passed; tracked files remain unchanged.