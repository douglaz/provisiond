# Panel brief: should a non-rate-limit failure of Robot's post-order read raise an alarm? (Q31 alarm), 2026-10-15

You are one of four independent reviewers. The working directory is a throwaway clone of the
specification repository `provisiond-spec` at `084cdd9` (branch `robot-live-2026-10-12`). Read `AGENTS.md`
first. Do not edit tracked files; write scratch files only inside this clone (never `/tmp` or `/var/tmp`).
You may run the gates (`nix develop --command bash tools/check-all.sh`, unpiped). Never call a provider API.
This owner repeatedly shows my framing wrong with a first-principles question and dissolves machinery rather
than tuning it; check this framing too, and verify every fact stated below before relying on it.

## The question

`ADR-0037`'s 2026-10-14 amendment (Q31) keeps Robot's post-order cancellation read (`PRV-13c`) as one
attempt at create settlement whose failure is absorbed. My amendment text says that on "a failed read of any
kind, `rate_limited` included ... `PRV-5`'s alarm is raised", and its Conformance bullet says "the alarm is
raised". But `PRV-5`'s alarm exists only for "every Robot `403 RATE_LIMIT_EXCEEDED`" (Q28, 2026-10-12), and Q28
rejected "a separate alarm per requirement". The ticket that applied Q31 (pv-y87) wrote into `PRV-13c`:
"Absorbing the failure MUST NOT suppress `PRV-5`'s ... alarm ... where its trigger applies", and `CNF-356`
asserts the alarm only on the 403 case. So as built, a timeout, network error, 5xx or other non-403 failure of
the post-order read is absorbed with no alarm; the machine's `earliest_cancellation_date` stays null until an
accepted cancellation's response supplies it. A second review flagged the divergence between my ADR wording and
the build.

Should a non-403 failure of this read raise a monitorable alarm?

## What I need from you

1. Verify the facts: quote `PRV-5`'s alarm rule, Q28's "one alarm rule" and its rejection list, Q31's amendment
   text, and `PRV-13c`/`CNF-356` as built. Does any other requirement already surface a failed provider read to
   the operator (a generic provider-error alarm, metric, log, health or reconciliation surface, `OPS-*`,
   `SEC-*`, `PRV-*`)? Cite it.
2. What does silence cost? With the read failed and the column null: what does the operator not learn, for how
   long, and what money is at risk (v1 sells only offers whose bound is today, `PRV-31`/Q25; a deviating
   contract is the only case the read catches)? What later event surfaces it anyway (`PRV-13`'s cancellation
   response, `LDG-63`, `LDG-75`, invoices)?
3. What does an alarm cost? Noise from transient failures; whether an alarm per failed read is the "separate
   alarm per requirement" Q28 rejected; any cheaper signal the spec already has (e.g. a recorded state the
   operator can query, a counter) that would satisfy "the operator can tell this machine's term is unverified".
4. Your vote: NO-ALARM (fix the ADR wording to "where its trigger applies"), ALARM-ON-ANY-FAILURE (with the text
   it changes), or a named OTHER (e.g. a queryable "term unverified" mark, no alarm) — only if the spec's own
   text supports it.
5. Then, labelled "Strongest case for the other side (written on request)", the best argument against your
   vote. It is not your position.

Under 500 words. Cite `file:line` or identifiers for every claim.
