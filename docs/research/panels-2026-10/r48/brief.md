# Panel brief: keep or drop Robot's post-order cancellation read (Q31), 2026-10-14

You are one of four independent reviewers. The working directory is a throwaway clone of the
specification repository `provisiond-spec` at `3639a80` (branch `robot-live-2026-10-12`). Read `AGENTS.md`
first. Do not edit tracked files; write scratch files only inside this clone (never `/tmp` or `/var/tmp`).
You may run the gates (`nix develop --command bash tools/check-all.sh`, unpiped). Search the Markdown with
whitespace normalised. Never call a provider API. This owner repeatedly shows my framing wrong with a
first-principles question and dissolves machinery rather than tuning it; check this framing too, and
verify every fact stated below against the repository before relying on it.

## The question

After a Robot server is ordered and delivered, `PRV-13c` (02-provider-contract.md) requires
"read-and-branch: order, then **read** the provider's per-machine cancellation constraint" — on Robot,
`GET /server/{n}/cancellation`, whose `earliest_cancellation_date` is priced as cost-through-that-date and,
when far in the future, sends the machine to the exception branch (machine-specific reserve, or not sold
on prepaid terms). Should v1 **keep** that read on Robot, or **drop** it for Robot?

## Facts as I understand them (verify each)

- `ADR-0037` Q28 (2026-10-12): Robot's `/server` read family — list, per-server, and the cancellation GET —
  shares ONE counter of 200 requests/hour per account (observed live; r45). Its threat model lists four
  ways tenants add to the counter through provisiond; post-order reads at create are not among them.
  Q28 removed the cancellation PRE-read on deletes and kept this post-order read ("That separate
  post-order read remains required", `PRV-13`'s 2026-10-12 amendment).
- `ADR-0037` Q25: v1 sells no offer whose earliest-cancellation bound is after the provider's today.
  `PRV-31` sizes the create commitment from the declared offer bound; `08-provider-notes.md` records the
  driver's declared worst-case bound for the current Robot launch offers as the provider's today, and
  Hetzner's statement "You can only cancel immediately".
- `08-provider-notes.md` also records that a server's `earliest_cancellation_date` "reflects that
  individual server's contract and is normally *today*", that Hetzner states cancellation periods depend
  on the individual contract, and a documented standard worst case "30 days to the end of the month";
  live tests saw the same-day date on every delivered test server (r45 `live-session2.txt`).
- `PRV-13c` opens: "A deployment MUST NOT encode any provider's current commercial terms as constants."
  Dropping the read for Robot would make "Robot cancels today" a constant.
- `CNF-147` and `CNF-356` test the post-order read and its future-date/deviation cases.
- `ADR-0036`: the Robot order budget is closed by the provider's throttle — check what it says about how
  many orders per hour are possible, i.e. the worst-case share of the 200/h counter this read can take.

## What I need from you

1. What does the spec do TODAY when this post-order read fails (including `rate_limited`, and a blinded
   counter for the rest of the hour)? Does a failure stall the create, leave its commitment sized on the
   declared bound, or something else? Cite by identifier and quote.
2. Worst case each way: (a) keep — the counter share it can take in an hour, and what else (sweep,
   attachments, rescue) it can starve; (b) drop — the operator money a delivered machine with a longer
   contract term would expose, and whether anything else would catch it (delete-time cancellation
   response, invoices, the sweep).
3. Is there an option neither "keep as is" nor "drop": e.g. a cheaper evidence source already read,
   deferring the read, or bounding it. Only if the spec's own text supports it.
4. Your vote: KEEP, DROP-FOR-ROBOT, or a named OTHER — with the requirement text it would change.
5. Then, labelled "Strongest case for the other side (written on request)", the best argument against
   your vote. It is not your position.

Under 600 words. Cite `file:line` or requirement identifiers for every claim.
