# Panel brief: pv-ucs.4 after a live Robot test (Q21), 2026-10-11

You are one of four independent reviewers. The working directory is a throwaway clone of the
specification repository `provisiond-spec` at commit `dec039f`. Read `AGENTS.md` first. Do not edit
tracked files; write scratch files only inside this clone (never `/tmp`); you may run the gates
(`nix develop --command bash tools/check-all.sh`, unpiped). Search the Markdown with whitespace
normalised. This owner repeatedly shows my framing wrong with a first-principles question and dissolves
machinery rather than tuning it; check this framing too, and verify every fact I state. The owner has
rejected absorbing an operator loss without a threat model, and rejected manual operator steps.

## Context

Read `docs/research/panels-2026-10/r38/synthesis.md` (last round, on pv-ucs.4: a surviving attachment is
never recorded when `PRV-45`'s post-delete listing does not run — a failed listing, a provider-terminated
machine, a scheduled delete). The owner chose to test first. The live result is
`docs/research/panels-2026-10/r39/live-result.txt` (read it): research batch B steps 1-5 and 9 on a real
Robot account. Summary:
- Auction offer 3084954 ordered with `addon[]=primary_ipv4`; delivered as server 3084954 after ~19 min
  (`server_number == offer id`, V8). After `DELETE /key`, the transaction still lists the key (V9).
- Before cancelling, `GET /server/3084954` returned `ip: ["62.238.91.26"]` and
  `subnet: [{"ip":"2a01:4f9:3120:2e90::","mask":"64"}]`; `GET /ip` and `GET /subnet` both carried
  `server_number: 3084954`. `GET /server/{n}/cancellation`: `earliest_cancellation_date` today,
  `reservation_possible: false`.
- `POST /server/3084954/cancellation` with `cancellation_date=now` and `reserve_location=false` answered
  `200` with `"cancelled": true, "cancellation_date": "2026-10-11"` (a calendar day).
- One second later `GET /server/3084954` answered `404`; the add-on IPv4 was gone from `GET /ip`
  (`GET /ip/62.238.91.26` → `404`) and the IPv6 /64 gone from `GET /subnet` (`404`). It stayed gone in the
  per-minute watch that followed.

## My proposal (review it)

1. pv-ucs.4 has **no v1 instance**: the only attachment provisiond orders on Robot (`RSC-45`'s
   `primary_ipv4` add-on) and the included /64 are removed with the server at once. Build nothing for v1.
2. Record the observation (batch B step 9 settled; `02:195`'s "possible survivors pending research batch
   B, step 9" and `08-provider-notes`), and amend the Robot descriptor's survivor declaration accordingly.
3. Make r38's option A (record attachments from the reads made while the machine is present; enqueue
   `release_attachment` at the gone-write, where every exit path converges) a **precondition** for selling
   any offer that creates an attachment that outlives its server (a separately ordered Robot IP or subnet;
   Cloud volumes and Primary IPs when Cloud returns), as Q18 and Q19 recorded preconditions.
4. Record two facts the last panel raised: a Robot `now` cancellation is immediate (gone in a second) even
   though Robot answers with a calendar day — so which `OPS-48` row applies (scheduled vs gone) must be
   stated; and fable's latent defect (03:1072 and `Tables.lean` fold a scheduled machine's tombstone into
   its gone-write, which `LDG-74` forbids).

## Questions

1. Does the live result support (1)? What does one sample not establish (other datacenters, catalogue
   (non-auction) servers, a provider-initiated termination, an operator adding an IP by hand)? Is any of it
   a v1 path that still leaks?
2. Is "precondition" the right shape, or is the gap still worth closing now (the triage found it wider than
   attachments: zero rows look like "listed, nothing found")? The strongest "don't build" and the strongest
   "build".
3. Point 4: with Robot answering `now` with a day while the server is gone in a second, what must the spec
   say (driver reports gone? scheduled with the end-of-day date of Q18a? `LDG-38`'s earlier-of rule)? Is
   fable's tombstone defect real at dec039f?
4. The exact edits (owners, ADR), and what CNF/Lean must show.

## Output

At most 800 words, no preamble: a one-line verdict; why; every defect with `file:line`; the edits.
