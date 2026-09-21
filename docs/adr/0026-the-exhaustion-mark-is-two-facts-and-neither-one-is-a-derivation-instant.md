# The exhaustion mark is two facts — an observation to confirm against, and a deadline — and neither one is a derivation instant

**Status:** accepted (2026-09-21). The rules are `LDG-16`, `PRV-13e`, `LDG-65`, `STO-54` and
`STO-49`, with the schema row in `05-persistence.md`. Supersedes the single
`machines.exhausted_since` column added 2026-09-05 and amended by `ADR-0023` on 2026-09-12. Answers
the open decision that session recorded and never closed — *should this column exist at all?*

## The problem as found

`LDG-16` gives the column one setter and one clearer. Set: "only when it moves the date backward
into the past, **or backward across `now + one re-derivation interval`**". Clear: "**any write of a
future `runway_until` clears it**", with "the horizon qualifies only the *set*, never the clear".

**The second half of the set rule has never once fired.** A backward move that crosses
`now + one re-derivation interval` and does not land in the past lands in the future by
construction, so it is also a future write, so the clear fires. The horizon disjunct is unreachable
prose. `CNF-99` is thorough — a poisoned reading, an honest forty-five-to-forty-minute move, a plain
expiry, a bad rate held across two intervals, a restore edge — and it never feeds a reading that
crosses the horizon backward and lands in the future, so it passes a build in which that branch does
nothing. `tools/formal/Provisiond/Fence.lean` states why the formal layer did not catch it either:
its omissions include "`PRV-13e`'s re-derivation, which is what sets `exhausted_since` under
`LDG-16`'s horizon rule (the column is set only in an initial world here)". **The layer models the
clear and the routing and has never exercised the setter.**

**The harm the branch was meant to stop is reachable.** Verified by execution, not by argument.
Take accepted sources `100, 100, 104`; corrupt one to `103` and the median rises to `103`. The
poison *is* the median, so its deviation from the median is zero and `LDG-60` — which excludes "a
source deviating from the median by more than a stated band" — cannot reach it by construction, and
quorum is untouched. With 6,100 usable satoshis, `LDG-33`'s date moves from 61 seconds to 59: across
a sixty-second horizon, into the future, where the dead branch was supposed to hold it. Large
poisons behave *better*: they are excluded, the count falls below quorum, `LDG-59` declares no rate
and `LDG-40` halts re-derivation without triggering exhaustion. **The dangerous input is the small
plausible one**, because near exhaustion the date is a difference of two large numbers.

**And the guard checks the wrong clock.** `LDG-16` justifies the wait as the second derivation the
rule requires not having happened. What it tests is that the mark is "older than one re-derivation
interval". `PRV-13e` re-derives at the current rate and nothing requires that rate to be newly
accepted, so **the same poisoned observation can be consumed twice** and satisfy the test. A
derivation instant says when provisiond computed; only an observation's identity says which price it
used. `CONTEXT.md` now separates the two terms.

## The decision

**Two durable per-machine facts, because there are two obligations and they run on different
clocks.**

- **A rate confirmation reference** — the accepted observation a backward re-derivation used. It is
  set by **every rate-produced backward move of a date that stood in the future**, not only a
  horizon crossing; where one write both arms it and clears it, **the arm wins**. It is discharged
  by the first *strictly later* accepted observation whose own write does not arm it again: the one
  that finds the date already past and leaves it there, so that two accepted observations have each
  put this machine past its runway before anything is destroyed. **A backward move never confirms
  itself.** *Amended while `pv-vwe.14` wrote the rules. The accepted text read "one that still
  derives exhaustion confirms it and permits routing", and its "still" assumed an arming that was
  itself an exhaustion — which the widened arming rule two sentences earlier had just stopped
  guaranteeing. Read literally it restores the defect: an ordinary wobble from two hours out to one
  hour fifty arms the reference, the next reading is the poisoned one, and being strictly later it
  confirms an exhaustion that no observation before it had derived. Also added: a move of a date
  that had already passed arms nothing, without which a machine known to be exhausted goes back
  behind a fresh confirmation once per interval for as long as the rate drifts.*
- **A destruction deadline** — `STO-54`'s restore grace, which "buys the tenant one re-derivation
  interval in which to extend again". It is wall-clock and nothing else discharges it.

Natural expiry arms neither. An extension or other authorized future-date write clears both. A
restore that adds its deadline preserves any rate reference already present.

`STO-49` already records "**One row per rate the deployment accepts** (`LDG-58`'s median),
**written before that rate is used for anything**", so the reference needs no new table — but it is
"unique on `(currency, observed_at)`" and nothing makes `observed_at` monotone or non-reusable. The
comparison is therefore against **a transactionally increasing per-currency acceptance order**, not
a timestamp, and the machine's reference is written in the same transaction as the date it explains.

**Two cancellations bypass confirmation entirely**, because no observation will arrive for them:
`LDG-64`'s bound, which requires the deployment "**cancel machines at that bound** if no rate has
returned", and the suspended tenant, where `OPS-41` already says "**The funding re-check does not
apply where the machine's tenant IS suspended** at the moment of" the claim. **Neither bypasses the
destruction deadline**, which is wall clock, expires on its own and is never longer than one
re-derivation interval, so honouring it costs the bound at most that interval and keeps the restore
grace a single rule rather than one with exceptions.

## What was rejected

**Deleting the mechanism**, which the 2026-09-05 note proposed on the ground that `LDG-58`'s median
already resists a poisoned source. It does not, as the counterexample above shows, and a reader who
argued the same case qualitatively — that one source moves the median by basis points, not by the
multiple needed — was refuted by carrying those basis points through `LDG-33`'s formula.

**A universal fence at the point of destruction**, permitting cancellation only after a fresh
confirming observation. It is refused by `LDG-16`'s own text: "*The null case routes immediately,
and that is the point: natural expiry of a runway the customer was shown is not a glitch, and
delaying it an interval would run every ordinary exhaustion one interval into the wind-down reserve
this requirement exists to keep whole.*" A naturally expired machine has no reference observation to
be later than, and with `PRV-13e`'s "*Hourly is the sensible default*" the delay would spend 3,600
seconds of the worked example's 8,970-second reserve — forty per cent of `protected_sats` — on every
ordinary exhaustion. `LDG-65` refuses it a second time: a runway expiring mid-outage "is cancelled
normally — **unless `machines.exhausted_since` is set**", and a universal rule would invert that
into cancelling nothing while the outage lasts, stranding the exposure `LDG-64` exists to cap.

**Re-keying the single column to an observation**, which loses the restore grace silently: two fresh
observations can arrive seconds after a restore and confirm exhaustion from the restored, smaller
commitment, destroying a machine whose owner was promised an interval to act.

**Fixing only the overlap**, which leaves elapsed time standing in for a second opinion.

## What this does not promise

Confirmation catches a **transient** error. A plausible print that every source carries for several
intervals confirms itself, and no version of this mechanism refuses it; `LDG-16`'s current wording
claims more than that and is narrowed accordingly. `LDG-58`'s median remains the primary control and
this is the second derivation it asks for, not a replacement for it.

## Consequences

`CNF-99` loses its "an honest reading that moves a date from forty-five to forty minutes out leaves
it null" case, which the wider arming rule deliberately changes, and gains one for the reading that
crosses the horizon and lands in the future — the case that would have caught the dead branch — and
one for the wobble-then-poison trace that holds a backward move to never confirming itself. Its
natural-expiry and restore assertions stand unchanged. `05-persistence.md` carries two columns where
it carried one. The formal layer owes the setter it has never modelled, and a negative control that
puts the dead branch back.

*Three independent readers — a fresh Opus reader and Codex at `gpt-6-astra` and `gpt-5.6-sol`, each
on the same brief — agreed the universal fence fails, by three different routes, and two arrived at
the two-fact split independently. The briefs and answers are in `.context/`, which is untracked.*
