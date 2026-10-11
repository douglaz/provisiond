# Panel brief: three owner questions left by the branch review (Q23a–c), 2026-10-11

You are one of four independent reviewers. The working directory is a throwaway clone of the
specification repository `provisiond-spec` at commit `82bc3d8` (branch `pv-ucs-impl`, all pv-ucs tickets
accepted). Read `AGENTS.md` first. Do not edit tracked files; write scratch files only inside this clone
(never `/tmp`); you may run the gates (`nix develop --command bash tools/check-all.sh`, unpiped). Search the
Markdown with whitespace normalised. This owner repeatedly shows my framing wrong with a first-principles
question and dissolves machinery rather than tuning it; check this framing too, and verify every fact I
state. The owner rejects absorbing an operator loss without a threat model, and rejects manual operator
steps. Settled: ADR-0033..0040 with every amendment (read ADR-0037's Q18, Q21 and Q22 amendments whole).

## Q23a — the failed read-back leaves a sweep interval unfunded

Q22: after an accepted dated cancellation the driver reads the machine once; not-found records gone and
stops the meter there; "A read that fails or still shows the server settles the attempt scheduled with the
date ... the sweep records gone later." Q22's own Rejected list says recording gone only at the sweep
leaves "up to one sweep interval that `PRV-13b`'s wind-down sum leaves out". `PRV-13b` (02, "Wind-down funds
the customer's meter through the gone-write") has no sweep-interval term. So on the failure path the meter
runs to the earlier of the provider-zone end of day and the sweep's observation, unfunded beyond wind-down;
`LDG-31`'s clamp turns the excess into an operator deficiency. Options: add the sweep interval (or the
remaining-day bound) to the wind-down sum; stop the customer's meter at the read-back attempt on that path;
accept the deficiency with its threat model (can a tenant induce a failed read-back — e.g. Robot's 200/h
`GET /server/{n}` limit, Q20/Q20b — and what does it cost the operator?). Which, and the smallest edit?

## Q23b — `LDG-32`'s "accepted and capped" versus `PRV-49`

`LDG-32` (12): "It MUST NOT sell an offer whose attachments have no bounded automatic cleanup unless the
operator has explicitly accepted and capped that exposure." `PRV-49` (02, from Q21) keeps current Robot
`primary_ipv4` offers sold under an accepted accident-only residual, and ADR-0037 Q21 says the operator
would pay the add-on's rent "with no end date". Q18 rejected reading `LDG-32`'s cap as `LDG-31`'s clamp
(the clamp caps the customer, not the operator). Is there a contradiction? If so: does Q21's acceptance
need a cap (what bounds it?), should `LDG-32` cite `PRV-49` as its explicit acceptance, or is `cleanup: api`
already "bounded automatic cleanup" so LDG-32 is met and the residual is outside it?

## Q23c — which instant `earliest_cancellation_date` names

Q22: a day-only date names the end of that day in the provider's zone for EFFECTIVE dates only;
"`earliest_cancellation_date` is a date cancellation is permitted from, not a stop instant". But
`05-persistence.md` types it `timestamp`, `PRV-13c` compares it to "now plus one re-derivation period plus the
product's wind-down bound", and `LDG-33` prices "cost through any earliest cancellation date not yet
passed". No text says which instant a day-only value becomes. Live: a Robot server's
`GET /server/{n}/cancellation` returned `earliest_cancellation_date` equal to today (provider-local) for a
server cancellable now. Candidates: the start of that day in the provider's zone; keep it a date and compare
dates in the provider's zone; something else. Which, where does the rule live (`PRV-13`/`PRV-13c`), and
what must CNF show?

## Output

At most 900 words, no preamble: for each of Q23a, Q23b, Q23c a one-line verdict, then why, every defect
with `file:line`, and the edits; the strongest "don't build" for each.
