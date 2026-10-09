# Panel brief: a network restriction's provenance after an operator-only withdrawal (2026-10-09)

You are one of four independent reviewers. The working directory is a throwaway clone of the
specification repository `provisiond-spec` at commit `843a2f2` (branch `pv-ucs-impl`; numbered Markdown
requirements, ADRs in `docs/adr/`, glossary `CONTEXT.md`, Lean in `tools/formal/`). Read `AGENTS.md`
first. Do not edit tracked files; you may write scratch files and run the gates. Search the Markdown
with whitespace normalised. This owner repeatedly shows my framing wrong with a first-principles
question and dissolves machinery rather than tuning it; check this framing too, and verify every fact I
state before relying on it.

## Settled (do not re-litigate)

`ADR-0038` (read it whole): status `restricted | unknown` (`none` deleted); the provider's last reading
and the operator's record sit side by side on the machine, OR-combined; each source withdraws only its
own; the operator is never refused; source and `observed_at` are the positive one's (`provider_api` where
both). Panel records: `docs/research/panels-2026-10/r23/` and `r24/synthesis.md` (r24 proposed three
nullable columns: `provider_restricted`, `provider_observed_at`, `operator_recorded_at`, with "source is
null exactly when both columns are null, so `CNF-250` holds unchanged").

## The gap (an rloop Manager blocked pv-ucs.7 on it)

Read `docs/research/panels-2026-10/r30/manager-blocker.md` (the Manager's own words). Trace: no provider
reading ever recorded (a driver with no signal, e.g. DigitalOcean); the operator records `restricted` at
t1; the operator withdraws at t2 after the unlock; no provider reading intervenes. Status is `unknown`.
What are `source` and `observed_at`? `CNF-250` says "`network_restriction.source` is null exactly when
nobody has looked", with the fresh-machine fixture `{"status": "unknown", "source": null,
"observed_at": null}`.

## Options put to the owner

- (1) Null: provenance describes the observation the field currently rests on; after an operator-only
  withdrawal none remains. Reword CNF-250 (and the persistence rows) from "nobody has looked" to "no
  current observation"; keep the fresh-machine fixture. (My recommendation, and the Manager's.)
- (2) Keep a trace of the operator's look, so "null = nobody ever looked" stays true; needs a rule for
  which instant renders (t1 or t2) and retained withdrawal history.

## What I want from you

1. Who reads `source`/`observed_at` when status is `unknown` (an agent deciding whether to reinstall, an
   operator, `WIR-11`/`WIR-43` renderings, conformance)? Does any reader need to distinguish "never
   looked" from "looked, withdrawn"? Does `DOM-27`'s purpose (stop a reinstall loop) care?
2. Where is (1) wrong? Does it collide with the provider side: a provider read that shows clear flags is
   `unknown`/`provider_api` with a time (r24) — so after an operator withdrawal on a machine the provider
   HAS read, which reading renders? Is the render rule total over all states (never read; provider clear;
   provider set; operator only; both; operator withdrawn with/without a provider reading)?
3. Is there a smaller shape — e.g. `source`/`observed_at` describe the latest observation of either kind
   (so a withdrawal renders `operator_notice` at t2), or the withdrawal itself is an observation?
4. Formal layer and conformance: what changes (`CNF-250`, `CNF-233`, `CNF-228`, `WIR-11`, `WIR-43`,
   `05-persistence.md` rows).

## Output

At most 800 words, no preamble: verdict in one line; why; a render table over the states in item 2;
every defect in my framing with `file:line`; the edits.
