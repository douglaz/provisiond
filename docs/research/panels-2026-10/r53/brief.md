# Panel brief: triage of bead pv-d21 (rollout of `machines.declared_cancellation_bound`), 2026-10-16

You are one of four independent reviewers. The working directory is a throwaway clone of the
specification repository `provisiond-spec` at `02ed28a` (master, PR #4 `pv-tsb` merged). Read `AGENTS.md`
first. Do not edit tracked files; write scratch files only inside this clone (never `/tmp` or `/var/tmp`).
This is a text question; you need not run the gates (green at `02ed28a`). Never call a provider API.
This owner often shows my framing wrong with a first-principles question; check this framing too, and
verify every fact below before relying on it.

## The bead (`br show pv-d21`, filed by an rloop Manager after pv-tsb)

"Settle what `machines.declared_cancellation_bound` holds on rows written before the column exists, and what a
worker does with a create whose `request_summary` snapshot an older `api` wrote without the bound." It quotes
the `machines` row (05-persistence.md:261: "Where `earliest_cancellation_date` is also null, a null value MUST
contribute no earliest-date term") and `OPS-23` (03:1623-1628: "A field a previous-release `api` may not have
written is a deterministic failure in the worker, never a passed check"), and says "Nothing says whether
attaching it fails (per `OPS-23`) or writes a null copy." It concedes no v1 effect and asks for a decision
"before any offer whose declared bound is later than provider-local today is sold".

## My triage reading (attack it)

1. **Pre-column rows.** The null-read rule already decides them: no term. Under `PRV-31`'s v1 rule
   (02:547-549, `ADR-0037` Q25 at docs/adr/0037…:270-299) every sold offer's bound is at most the sale day, and
   `LDG-33` (12:353-354) prices it "only if later than provider-local today", so null prices exactly what the
   true value would, on every later day. Precedent: `billing_unit_seconds` (05:260, null read as zero) and
   `install_strategies` (05:259, null read as empty) got a null-read rule and no other rollout rule.
2. **In-flight create from an older `api`.** Before dispatch, nothing in the worker reads the bound: `OPS-43`
   (03:663-679) lists the snapshot fields the claim check needs and the bound is not among them, and no worker
   re-check of `PRV-31` reads the snapshot. `OPS-23` is scoped "before the driver is called"; the bound is read
   only at attach (`OPS-27`, `OPS-36`, `WIR-35`), after the driver call, so the copy writes null and point 1
   applies.
3. **No implementation exists** (owner's fact; this repo is spec-only), so no deployment has such rows today.

My recommendation: `wontfix` (already specified), closing with a comment that points at where each half lives.

## What I need from you

1. Does the text at `02ed28a` settle both halves, as I claim? Trace the attach paths and any worker re-validation.
   Where the text leaves an implementer to choose, quote the sentence that fails.
2. Is null ever *not* exact? Consider a release that later lifts `PRV-31`'s v1 rule, `PRV-13c`'s deviation
   branch, `STO-13`'s stop-everything rule for an `LDG-33` change (05:1396-1403), late or operator attach days
   after admission, and anything else.
3. Pick: (A) `wontfix`, already specified; (B) `ready-for-agent`, one clarifying sentence — name the identifier
   it lands on and draft it; (C) keep open, deferred to whatever lifts `PRV-31`'s v1 rule; (D) other.
4. Then, labelled "Strongest case for the other side (written on request)", the best argument against your pick.
   It is not your position.

Under 500 words. Cite `file:line` or identifiers for every claim.
