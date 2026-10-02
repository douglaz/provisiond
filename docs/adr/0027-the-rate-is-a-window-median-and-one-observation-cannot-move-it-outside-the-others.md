# The rate is the window median of accepted observations, and one observation cannot move it outside the others

**Status:** accepted (2026-09-23). The rules are `LDG-58`, `LDG-59`, `LDG-16`, `PRV-13e`, `LDG-65`
and `STO-49`, with the schema rows in `05-persistence.md`. Supersedes `ADR-0026`'s first fact, the
rate confirmation reference; its second, the destruction deadline, stood until `ADR-0028`
(2026-09-25) moved the restore grace onto the restore record. Answers the question
`pv-vwe.21` put to the owner — *does the confirmation promise bind anything beyond the sweep's
routing decision?* — by removing the need for it to bind anything at all.

## The problem as found

`ADR-0026` built a confirmation mechanism downstream of the price: a durable per-machine reference
armed by a backward move of the runway date, discharged only by a strictly later accepted
observation, read by the exhaustion sweep's routing predicate and by nothing else. Modelling that
setter in the formal layer (`pv-vwe.20`) and executing traces on the model found three things the
mechanism's own text did not survive.

**The promise stops at the routing decision.** `LDG-16` says "a rate-produced exhaustion MUST
still be **confirmed by a strictly later accepted rate observation** before anything is destroyed".
A machine whose episode is already open needs no second routing decision to be destroyed, and the
reference is read only by that decision. A trace executed on the committed model — a legitimate
exhaustion queues an attempt, the next derivation moves the date into the future, one adverse
observation moves it back and arms the reference, the queued attempt claims, re-derives at the
same poisoned rate and destroys — ends with the reference armed and the disk gone. One accepted
observation stands behind the destruction. A four-model panel on 2026-09-23 confirmed the trace
and rejected every repair that left the price alone: binding the worker's path costs a sentence in
`OPS-41` or `PRV-13e` and an outcome `OPS-48`'s table does not have for a held attempt; closing the
episode when the machine is funded again is a race the set already refused, in `OPS-41`'s words
"The check belongs under the fence, not in the extension."; narrowing the promise a second time
leaves the disk unprotected and says so.

**A second rule promises the same thing in a unit `ADR-0026` retired.** `PRV-13e` says "A
deficiency MUST persist across more than one derivation" before it can trigger cancellation, and
its note calls that rule "what stands between a glitching price feed and a destroyed disk".
`ADR-0026` found derivation count unsound — two derivations an interval apart can consume the
same observation — and re-keyed `LDG-16` to observation identity, but `PRV-13e` was never
re-keyed with it. The trace above satisfies `PRV-13e` as written: two derivations, one observation.

**`LDG-16` contradicts itself about the worker.** It says `OPS-41`'s re-derivation "reads neither
fact except to clear them"; it says of the two bypasses that "Neither reaches the predicate above";
and it says of the same two that "Both do respect the destruction deadline". If the bypasses never
reach the sweep's predicate and must still respect the deadline, something on the worker's path
reads the deadline. The formal layer resolved it the only way it could, by gating the provider
call on the deadline — a change the review then filed as scope creep (`pv-vwe.22`) before the
panel read the three sentences together.

Underneath all three: the mechanism gates *actions*, and there are more actions than it reaches.
Every local theorem in `Provisiond.Fence` is true, and no theorem of the form *destroyed → two
accepted observations stand behind it* exists, because the composition of local gates does not
yield one.

## The decision

**The rate is the lower median of the rate observations accepted inside a window, and one
observation cannot move it outside the range the others carry.** The observations are what
`LDG-58` already produces — "the median of at least three independent sources", one per pass, one
row in `STO-49` — and the window is the span of them
whose `observed_at` lies inside the last window-length before the pass that computed the rate,
stated per deployment and per billing currency as `LDG-59`'s quorum is, twenty-four hours by
default. The rate is what every reader of "the rate" uses: `LDG-33`'s derivation, the meter, the
create-time price, the solvency check. One rate, one home.

- **The rate is computed at a pass and holds until the next** (*amended 2026-09-23, the day of
  acceptance — the first draft measured the window from "now"*). Each pass that accepts an
  observation recomputes the median over the window as of that pass; between passes the rate
  does not move, so an observation ageing out of the window changes nothing until a pass
  recomputes. Every change of rate therefore lands on an instant that already has a durable row,
  and `LDG-38`'s split rule and its "durable before the rate is used" requirement stand exactly as
  written. *A window measured from "now" would have changed the rate at an observation's expiry
  with no row to split an increment at; the owner refused that, and this bullet is the refusal.*

- **Lower median, not mean.** `LDG-58` says "The count MUST be odd, so the median is an observed
  price rather than an average of two." That rule is about one pass's sources and stays scoped to
  the pass. The window's count is whatever the passes produced, so the same principle picks the
  lower of two middle values: the rate is always a price some pass accepted.
- **Freshness gains a second use.** `LDG-59` says "Falling back to the last known rate MUST NOT
  happen." and defines its staleness bound per source. The same bound now also applies to the
  window's newest observation — newest by `observed_at`, which `STO-49` keeps unique per currency,
  not by acceptance order, which can disagree with it: none inside it is **no rate**, and that is what feeds `LDG-40`'s
  halt matrix. The window is not a fallback; a dead feed still halts. **One pass below quorum halts
  nothing** (*amended 2026-09-23, the day of acceptance*): it accepts no observation and recomputes
  nothing, so the rate in force holds; `LDG-59`'s quorum decides whether a pass accepts an
  observation, and **no rate** arises only from the window — nothing inside the staleness bound, or
  fewer than three observations. The two are tested on different clocks (*clarified 2026-09-23,
  from the review of `pv-gip.3`*): staleness continuously, so a feed that falls silent halts between
  passes rather than holding its last rate; thinness at the pass that computes the rate, because at
  the minimum window of three passes the oldest observation ages out just before each new one
  arrives, and a continuous count would drop the rate between passes in steady state. **The outage
  record is the subject's, its start is the currency's, and the meter opens it** (*added
  2026-09-25, and corrected the same day: the first form said "one row per currency, keyed on the
  currency", and `pv-gip.16`'s Run found it contradicted `STO-37`, `LDG-64`, `LDG-66`, `OPS-41`
  and `CNF-218`, every one of which makes the rate-outage row a subject's — `OPS-41` even records
  that "a first form named a deployment-wide outage row that `STO-37` does not have" on
  2026-09-05*). `STO-37`'s row carries a machine or attachment, so there is one per subject per
  outage, and **every row of one outage carries the same `absorbed_from`: the earliest instant of
  the maximal interval, ending at the writer's posting, throughout which the window yielded no
  rate** — computed from `STO-49`'s recorded observations by replaying `LDG-59`'s two clocks over
  them (*amended 2026-09-25, from the review of `pv-gip.16`: the first form gave each writer the
  instant its own clock showed at its own posting — "newest plus bound" for staleness, the thin
  pass's instant for thinness — and the two clocks can cross inside one outage: the newest goes
  stale, a machine opens its row, a later pass accepts one observation into a still-thin window,
  and the next machine's posting computes a start hours later than the first's. Two rows, two
  starts, two deadlines, and a window nobody absorbs — against `LDG-59`'s one outage per currency
  and `LDG-64`'s "charge the customer nothing for that window". Copying the start from a sibling
  row was considered and refused: a writer that computed before a thin pass committed and one that
  read after it can interleave so that neither sees the other. A start that is a function of the
  history alone is the same for every writer whatever the interleaving, and reads no sibling.*)
  `STO-49` keeps the replay's inputs at all times, not only during an outage: for each currency,
  the rows inside its window as of the last accepting pass that yielded its rate, and every row of
  that currency accepted since, are not pruned; a later rate-yielding pass moves that snapshot
  forward (*the floor as `pv-gip.18` landed it, 2026-09-25 — the first form here said "until the
  outage closes", which is narrower than the rule needs, since the start is replayed from before the
  outage began*). The meter opens the subject's row at that subject's first posting which computes
  no rate and finds no
  open row for it — open meaning `absorbed_until` null — as a conditional insert guarded on that
  absence, so two postings of one subject open one row. The worker's `OPS-41` contend does not
  open one; a create and the solvency check have no subject to open one for. Both consumers of the
  instant — `LDG-38`'s apportioning and `LDG-64`'s bound — read the persisted `absorbed_from`, so a
  late opening changes no bill and no deadline. *(2026-10-02: `ADR-0029` computes the deadline from
  the replay and stores none, so the bound no longer reads a row.)* `STO-37` owns the rule and carries the argument;
  this paragraph is the decision and its history. *The first
  draft and `pv-gip.1` kept the per-pass halt beside the
  window; the owner withdrew it, since it handed whoever can disrupt one pass a halt they never
  had, and the window exists to absorb exactly that pass.* After an outage shorter than
  the window, the first fresh observation restores a rate whose older half is pre-outage prices —
  that is the lag accepted below, and `LDG-64`'s outage close is keyed to the window producing a
  rate again, not to one observation arriving.
- **A thin window is no rate.** Fewer than three observations inside the window is **no rate**, for
  the reason a median needs company: a median of one is that one. A deployment MUST state its
  window and its pass cadence so that a full window holds at least three passes, so the thin case
  is always an outage and never a configuration.
- **Retention follows the window.** `STO-49` retains at least one window of observations per
  currency; its clause tying retention to the reference goes with the reference.
- **The confirmation reference is withdrawn.** Its arming and discharge rules, the acceptance-order
  confirmation, "a backward move never confirms itself", the reference half of the routing
  predicate, `LDG-65`'s "unless `rate_confirmation_ref` is armed" clause, and
  `machines.rate_confirmation_ref` all go. The routing predicate becomes what it was before
  2026-09-05 plus the deadline: stored `runway_until` past, `destroy_not_before` null or past.
- **The destruction deadline stays**, and the worker reads it (*superseded 2026-09-25 by
  `ADR-0028`: the grace is one instant in the restore record and no machine carries a deadline;
  the rest of this bullet is the record of what stood for two days*). `STO-54`'s restore grace is a
  different concern — a restore moves the fleet's dates backward by something other than
  consumption, and no price speaks to that — and `pv-gip.1` makes `LDG-16` say plainly that every
  provider call respects it, which is what its bypass sentence already required.
- **`PRV-13e`'s persistence rule becomes a consequence**, stated in two halves the theorem below
  supports: no single observation moves the rate outside what the other observations carry, and a
  rate outside what the honest passes carry needs at least half the window to carry it. The
  derivation-count form and its unit-of-measure note are retired.

**The promise `LDG-16` makes is restated to what the window gives.** A transient bad observation
moves the rate no further than the honest values on either side of it, because it is one value in
a window whose middle it cannot drag past the others. So it cannot move the rate outside the range
the honest passes in the window carry, and cannot destroy a disk that no price inside that range
would destroy. It can land the rate on its own value where that lies between two honest ones —
honest `100, 103, 104` with the `103` replaced by `101.5` reads `101.5` — which is why the bound
is a range and not a membership. That is narrower than "cannot destroy a disk": a machine within one honest step of exhaustion can
be pushed over by that step, and `ADR-0026`'s warning that "near exhaustion the date is a
difference of two large numbers" is why one step can be enough. It is also the promise any
estimator can keep, since no rule can tell two honest prices apart, and it is kept by
construction rather than by gating. The formal home of that promise (`ADR-0025`) is a theorem
about the median, not about the lifecycle: *replacing any one observation in the window cannot
move the median past a value another observation in the window carries.* It is provable over plain
lists, and it cannot be bypassed by a queued attempt because it is a property of the input every
attempt reads.

## What this costs

**Lag.** A real price move reaches the lower median once half the window carries it — half the
window's length in wall clock, whatever the pass cadence. During that half-window the operator
under-charges on a rise and over-charges on a fall, and the wind-down reserve, which `LDG-33`
computes "at the current rate", is short by the move. This is bounded — half a window of one
move's delta, per machine — and it is the operator's exposure to accept, which the owner did on
2026-09-23. `LDG-17`'s reserve requirement is the backstop beneath it. It replaces an exposure
that was not bounded: a paying customer's disk, destroyed on one observation.

**Retention.** `STO-49` today retains a row "at least until every subject **with an open
increment** has closed one past its `observed_at`" and "for as long as any machine's
`rate_confirmation_ref` names it". The first clause stays and gains a floor of one window per
currency; the second goes with the reference.

**Deletion.** The reference is named in eight files. `pv-vwe.20`'s model of the setter, landed the
day before this decision, is mostly retired with it; the negative controls that put the reference's
withdrawn rules back go with the rules.

## What was rejected

**Binding the worker's path** — reading the reference in `OPS-41`'s re-check, deferring the
attempt under the fence while the reference is armed, or refusing the provider call while the
reference is armed. Each is a second normative home for a rule the sweep's predicate owns, each
needs an outcome for a held attempt that `OPS-48`'s table does not have, and each still gates one
more action while leaving the price that produced the exhaustion untouched. The panel's advisers
split on which site was least bad and agreed none was good. The provider call's deadline gate is
not one of these: it reads the deadline, which `LDG-16`'s bypass sentence already required every
cancellation to respect, and the decision above admits it; what it still lacks — an `OPS-48`
outcome for the attempt it holds — is `pv-gip.5`.

**Narrowing the promise a second time**, to cover only a machine the sweep would newly route. It
is the cheapest correct edit and it leaves `PRV-13e`'s promise on the books and false; a set that
says "one bad rate read cannot cancel a paying customer's machine" in one document cannot say
"except one that was already queued" in another.

**Closing the episode when the machine is funded again.** It explains why the attempt is still
there and changes nothing about whether it fires, since at claim the poisoned rate still reads the
machine unfunded — "(a) with a different justification", as one adviser put it. It is also the
race `OPS-41` already refused.

**Keeping the reference beside the median.** The reference exists to survive the case the median
now absorbs. Two mechanisms for one case is the second-copy drift `AGENTS.md` names, and the
reference's own text had already drifted twice.

**A cross-source median alone**, which `ADR-0026` rejected with the sources `100, 100, 104` and a
corruption to `103`: the poison *is* that pass's median. It still is. The window is what makes it
one value among many.

## What this does not promise

A plausible print carried by half the window confirms itself, and no median refuses it. That is
the same exclusion `LDG-16` already carries — "It promises no more than that." — with a larger
number in it: several intervals become half a window.

One observation can still move the rate — to its own value where that lies between two honest
ones, otherwise to the nearest honest value — and more poisoned observations can move it further
while they stay under half the window. Every such move stays inside the range honest passes
made. A machine close enough to exhaustion that a move inside that range crosses it can be
exhausted by them, and nothing in this set sizes a reserve to the window's spread; the theorem
bounds the move to that range and no tighter, and that is the whole of what it promises.

## Consequences

This is the edit list `pv-gip.1` lands, and the record and the ticket name the same edits.

`LDG-58` states the window, its `observed_at` bound measured from the pass, the lower median, that
the rate is computed at a pass and holds until the next, and that its odd-count rule is the
pass's. `LDG-59` states that its staleness bound also applies to the window's newest observation,
that a thin window is no rate, that a deployment's window must hold three passes, and that a pass
below quorum accepts no observation and halts nothing.
`LDG-16` loses its reference paragraphs and keeps the deadline, the two bypasses and the wind-down
argument; its promise is restated to what the window gives, and its three worker sentences are
rewritten to hold together. `PRV-13e` loses its "It MUST also maintain
`machines.rate_confirmation_ref`" duty, restates its persistence rule in the two halves above, retires the note
calling the derivation-count form the control that matters, and separates the re-derivation interval from the rate window where it currently calls both
"`LDG-16`'s window". `LDG-41` names the window median as the security control the persistence
rule was. `LDG-62` and `OPS-41` say "clears the deadline" where they say "clears both facts".
`LDG-64`'s outage close is keyed to the window producing a rate again. `LDG-65` loses its
reference clause and the paragraph explaining it. `05-persistence.md`'s machines table loses the
`rate_confirmation_ref` row and the `destroy_not_before` row's mentions of it; `STO-49` gains a
retention floor of one window and loses its reference clause; `STO-54` loses "any
`rate_confirmation_ref` already present is preserved" and keeps its grace. `CNF-99` exchanges its
confirmation cases for window cases, of which it holds the list: one poisoned pass moves the rate
no further than the honest values beside it; a print carried by half the window moves it there; a window with no fresh observation is no
rate; a thin window is no rate. `10-conformance-checklist.md`'s rate section points at the window
where it points at the persistence rule. The wind-down worked example names the window that
produced its rate. `CONTEXT.md`'s **Rate** and **Window** entries, which cite this decision, cite
`LDG-58` and `LDG-59` once those carry the rules.

The formal layer (`pv-gip.2`) gains a rate module with the median theorem as the promise's home
and loses the setter's reference half, four negative controls, and `World.routed`'s reference
clause. `pv-vwe.21` closes as dissolved. `pv-vwe.22` keeps its restore-formula and `agedWorld`
sites and drops its first, which this decision admits into `LDG-16`'s text.

*Four independent readers — Fable, Opus, and Codex at `gpt-6-astra` and `gpt-5.6-sol`, each on
the same brief — rejected repairing the mechanism from inside, by four routes; the window median
was the owner's answer, and it was checked against `ADR-0026`'s recorded rejections before being
written down here.*
