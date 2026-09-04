#!/usr/bin/env python3
"""Execute the spec's two contested formulas and assert what it claims about them.

Every other gate here reads the documents. This one *runs* the arithmetic they
state, because the two most expensive arguments of 2026-09-04 were both settled
by evaluation and neither was settled by reading:

  * `OPS-41`'s abort predicate flipped twice across three cross-model reviews --
    `runway_until` -> `usable_sats > 0` -> back -- while a ten-line evaluation
    exhibits the counterexample directly.
  * `LDG-38`'s rounding credit replaced an unbounded cumulative total, and the
    replacement was justified by 3000 randomised trials that lived in a
    scratchpad and were thrown away.

The subject under test is the SPECIFICATION, not an implementation. Each check
encodes a formula exactly as a requirement states it and asserts a property that
requirement claims. A failure means the documents disagree with themselves.
"""
import math
import random
import sys

FAILURES = []


def check(name, ok, detail=""):
    print(f"  {'PASS' if ok else 'FAIL'}  {name}")
    if not ok:
        print(f"          {detail}")
        FAILURES.append(name)


# --- LDG-33 ------------------------------------------------------------------

def runway_seconds(reserved_sats, protected_sats, rate):
    """`LDG-33`, verbatim:

        usable_sats  = max(0, reserved_sats - protected_sats)
        runway_until = now + floor(usable_sats / current_customer_rate)

    Returned as seconds from now, so `runway_until > now` is `> 0`.
    """
    usable = max(0, reserved_sats - protected_sats)
    return usable // rate, usable


def ldg33():
    """The exhaustion sweep routes on `runway_until`; `OPS-41` aborts on it too.

    `05-persistence.md` indexes `machines` on `(runway_until)` "for the exhaustion
    sweep (`LDG-13`)", and `LDG-14` cancels "at end of runway" -- so the sweep
    routes exactly when `runway_until <= now`. `OPS-41` must abort exactly when
    it does not, or one rule's two halves disagree about one machine.
    """
    def abort_date(rw, u): return rw > 0           # OPS-41 as it stands
    def abort_sats(rw, u): return u > 0            # the withdrawn 2026-09-04 form

    def cycles(abort, reserved, protected, rate, limit=64):
        """Route, re-check, abort, repeat -- and see whether it terminates.

        Comparing the two predicates against `routed` directly is a tautology for
        the date form, since both read one variable; the first draft of this check
        did exactly that and could not fail. What actually differs is what happens
        AFTER an abort. The sweep routes on a stored `runway_until` (`LDG-13`'s
        index); `OPS-41` re-derives it under the lock. An abort clears the fence
        and resolves the episode (`OPS-44`'s first row), so the next pass sees the
        same machine unchanged and routes it again. A predicate that aborts a
        machine the sweep will re-route has no fixed point, and each lap mints a
        tenant-visible operation claiming no mutation was needed.

        Returns the number of laps before the machine is destroyed, or `limit`
        where it never is.
        """
        for lap in range(limit):
            rw, u = runway_seconds(reserved, protected, rate)
            if rw > 0:
                return lap          # genuinely funded; the sweep would not route it
            if not abort(rw, u):
                return lap          # destroyed, which is what routing decided
        return limit                # aborted every lap, forever

    nonterminating_date, nonterminating_sats, witness = [], [], None
    for rate in range(1, 12):
        for protected in range(0, 40):
            for reserved in range(0, 40):
                rw, u = runway_seconds(reserved, protected, rate)
                if rw > 0:
                    continue                       # not a routed machine
                if cycles(abort_date, reserved, protected, rate) >= 64:
                    nonterminating_date.append((reserved, protected, rate))
                if cycles(abort_sats, reserved, protected, rate) >= 64:
                    nonterminating_sats.append((reserved, protected, rate))
                    if witness is None and u > 0:
                        witness = (reserved, protected, rate, u, rw)

    check("LDG-33/OPS-41: the date predicate terminates on every routed machine",
          not nonterminating_date,
          f"{len(nonterminating_date)} machines cycle forever, e.g. "
          f"{nonterminating_date[:1]}")

    # The withdrawn form is asserted to be WRONG. If this ever passes, the
    # tombstone in OPS-41 is lying and the flip should be revisited.
    r, p, rate, u, rw = witness if witness else (0, 0, 0, 0, 0)
    check("LDG-33/OPS-41: `usable_sats > 0` does NOT terminate "
          "(so the 2026-09-04 revert stands)",
          bool(nonterminating_sats),
          "no counterexample found -- OPS-41's amendment note is unsupported")
    if nonterminating_sats:
        print(f"          witness: reserved={r} protected={p} rate={rate}/s "
              f"-> usable_sats={u} (>0, aborts) but runway={rw}s (re-routed next pass)")


# --- LDG-38 ------------------------------------------------------------------

def ldg38(trials=3000, seed=20260904):
    """`LDG-38`'s recurrence, verbatim:

        posted_debit_i = ceil(exact_i - r)
        r'             = r + posted_debit_i - exact_i        INVARIANT: 0 <= r < 1

    The claim the redesign rests on is that this posts the same satoshis as the
    withdrawn cumulative form `ceil(total_exact) - already_charged`, while
    carrying bounded state instead of unbounded state.
    """
    rng = random.Random(seed)
    out_of_range = same = 0
    worst_r = 0.0
    for _ in range(trials):
        r = 0.0
        exact_total = 0.0
        charged = 0
        agreed = True
        for _ in range(rng.randint(1, 60)):
            seconds = rng.randint(0, 3600)
            rate = rng.uniform(0.0001, 5.0)
            exact = seconds * rate

            posted = math.ceil(exact - r)
            r = r + posted - exact
            if not (-1e-9 <= r < 1.0 + 1e-9):
                out_of_range += 1
            worst_r = max(worst_r, r)

            # the withdrawn cumulative form, run alongside
            exact_total += exact
            cumulative = math.ceil(exact_total) - charged
            charged += cumulative
            if posted != cumulative:
                agreed = False
        same += agreed

    check("LDG-38: the rounding credit stays in [0,1) on every increment",
          out_of_range == 0, f"{out_of_range} excursions, worst r={worst_r:.6f}")
    check("LDG-38: it posts identically to the withdrawn cumulative form",
          same == trials, f"{trials - same}/{trials} trials diverged")

    # The claim that made the redesign worth doing: a corrupt-but-in-range `r`
    # costs at most one satoshi, where a corrupt cumulative total is unbounded.
    worst = 0
    for _ in range(trials):
        exact = rng.uniform(0, 10_000)
        honest = math.ceil(exact - 0.0)
        for bad in (0.0, 0.5, 0.999999):
            worst = max(worst, abs(math.ceil(exact - bad) - honest))
    check("LDG-38: any in-range corruption of `r` misprices by at most 1 satoshi",
          worst <= 1, f"worst mispricing {worst} sats")


if __name__ == "__main__":
    print("\n" + "=" * 62)
    print("  arithmetic   (the spec's own formulas, executed)")
    print("=" * 62)
    ldg33()
    ldg38()
    if FAILURES:
        print(f"\nFAIL: {len(FAILURES)} arithmetic claim(s) the documents do not support.")
        sys.exit(1)
    print("\nOK: every executed claim holds.")
