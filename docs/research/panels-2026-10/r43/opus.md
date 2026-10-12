**Verdict: neither reading. No v1 purchase can reach the gap, because an existing owner decision already blocks the only offer that could. Say that in `PRV-31` and leave the threshold alone.**

**Why**
- **The Manager's framing is wrong at purchase.** The report says the server's "stored start is 30 minutes away (ordinary branch, nothing reserved at purchase)". But nothing is stored at purchase.
  - `PRV-13c` tests "the stored permitted-from instant", and that read happens after "order, then **read**" (02-provider-contract.md:551).
  - At create, `PRV-31` decides instead: "The declared bound sizes the commitment at create" (02:525–526). `CNF-166` (10-conformance-checklist.md:3111) and `CNF-147` also size from that bound with no condition.
  - The only text that applies a branch at create is `PRV-13b`'s comment `# exception branch only (PRV-13c)` (02:288).
- **The purchase gap needs an offer whose declared bound is the next day, and v1 can't enable such an offer.** `LDG-38` (12-billing-and-ledger.md:999–1003) says the case "becomes reachable if … an offer permits future-scheduled cancellation on `PRV-13c`'s exception path". It goes on: "Enabling either condition requires an automatic, idempotent corrective credit for the excess already posted; v1 posts no such correction." ADR-0037 Q18 rejected "building the automatic credit now". So any offer v1 can sell has a bound of today, and today reserves nothing under either reading.
- **After the order, only provider deviation reaches it: a date read back that is later than the declared bound.**
  - `CNF-147` injects exactly that case, and `ADR-0020:113` calls it "rare on the launch set", which is not "never".
  - The two readings differ only in who pays, and the amount is at most about 24.5 h of one machine. Start-based, `LDG-33` takes it from the fixed commitment and any excess meets `LDG-31`'s clamp. End-based, `LDG-63` tops up from the customer's available balance.
  - Neither reading reserves anything before the order.
- **First principles: end-of-day pricing is right for the path the spec prescribes.**
  - A rejected `now` is followed by scheduling at the earliest date (`CNF-147`: "a rejection followed by scheduling").
  - Robot's API defines `cancellation_date` as "Date to which the server should be cancelled" (docs/research/provider-verify-2026-10.md:323).
  - The alternative is to wait for the day's start and then send `now`. That needs a deferred dispatch, and it depends on behaviour V12 records as "Not documented".

**Defects**
1. **Robot's declared bound is never stated, and two texts disagree on it.**
   - `PRV-31` (02:531) says only "In practice the bound is trivial for the launch set".
   - V12 says the worst case "can be declared as 30 days to the end of the month" (provider-verify:336). Under `LDG-38`, that value would make every Robot offer one v1 can't enable.
   - Nothing enforces "trivial". A bound "MAY be reported on the offer instead", and `CNF-166` sells against any declared bound.
2. **`LDG-63` (12:1991) is wrong under deviation.** It says the shortfall is "bounded per machine by `PRV-31`'s declared worst case", which is false when the date read back is later than that bound.
3. **Two claims in the brief don't hold.**
   - `CNF-147` contains no "no launch product reaches the branch by default". I searched every tracked Markdown file with whitespace normalised.
   - `PRV-13c` doesn't refuse such offers. It gives a choice: "either carry a machine-specific reserve … or not be sold on prepaid terms at all".

**Edits**
- **`PRV-31` (02:531).** Replace "In practice the bound is trivial…normally today" with a rule:
  - An offer whose declared or reported bound is later than the provider's today permits future-scheduled cancellation.
  - Quote `LDG-38`'s "Enabling either condition … v1 posts no such correction".
  - In v1 such an offer is not sellable under `PRV-31`. `API-7`'s existing tail ("not sellable under `PRV-13b` or `PRV-31`") already covers this, so no new refusal is needed.
  - Robot's commercial term stays in `08-provider-notes.md` rather than becoming a constant (`PRV-13c`).
- **`CNF-166`.** Add that an offer whose declared bound is later than the provider's today gets the same refusal.
- **`LDG-63` (12:1991).** Add "where the read date lies within it; a later read date is operator-borne, an accident no adversary can cause."
- **ADR-0037, new Q25 amendment.** Record that the case can't arise at purchase in v1, and reject both readings for v1. Leave the comment at 02:288 for whoever enables future-dated offers, next to `LDG-38`'s corrective-credit precondition.
- **Don't add the `CNF-63` near-midnight fixture.**

**Strongest "don't build"**
Don't change the threshold, don't add "judge a future day by its end", and don't add the fixture.
- For day-only dates, the Manager's rule makes the threshold dead. A future day's end is always more than 24 h away, which is beyond any hourly threshold. So the rule quietly rewrites `PRV-13c`, for a case no v1 offer can reach at purchase.
- Decide the purchase test when future-dated offers clear the corrective-credit gate, against a real contract.

**Gates:** `nix develop --command bash tools/check-all.sh`, run unpiped at `12a1c89`, passed every gate ("All gates passed.", exit 0). I edited no tracked files; my scratch notes are in `.scratch/` inside the clone.
