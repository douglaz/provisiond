# r70 whole-form S read (opus seat)

## 1. Verdict: **CANNOT ACCEPT** (blocking under rule 3, for the manager to verify)

**Strongest argument.** S1 refuses a create whose listing is stale or absent "before the tail". But the tail's first entry is the unhealthy-account refusal: `04:265–266` says "the request's own resource refusal (`conflict`/`state` for create against a provider account not `healthy`". S2 and S3 make a stale row the normal state on exactly those accounts:
- An unreachable account's reads fail, and STO-60 says "A failed read MUST leave the row unchanged".
- S3 leaves a credential under the PRV-41 authentication stop out of the refresh.

So once one offer-listing age has passed, a create naming such an account is refused `provider`/502 with `retryable: true` instead of `409 conflict`/`state`. No listed amendment discloses this.

**Trace (`account_unreachable`):**
1. Account A is healthy and declares `list_offers` and an ordering capability. OPS-51 publishes its row with `read_at` t0.
2. A becomes unreachable and the operator records `account_unreachable` (`API-63`). Refresh reads now fail, so the row keeps t0 (STO-60).
3. At t0 + age + ε a create names A. In the admitting transaction S1 applies: "Where no listing is stored, or its `read_at` is older than the stated offer-listing age (`OVR-19`) at the admitting transaction, the create MUST be refused `provider` (`01-domain-model.md`'s error taxonomy) with `retryable: true` before the tail, committing nothing." The tail never runs.

**Flipped and unlisted (S6 amends only `CNF-166`):**
- **`CNF-278`**, `10:2789–2791`: "a create naming it is `409` `state`" … "Assert the refusal on **all three** unhealthy statuses".
- **`CNF-307`**, `10:1213–1214`: "unhealthy create account or fenced extension `409` `conflict` (reason `state` or `cancellation_committed`)". Also its combination case at `10:1253`: "An unhealthy create account + sellable offer + solvency halt with a supplied cap: `409`, state then solvency". Under S1 that case returns 502 with no entries.
- **`CNF-307`**, `10:1225–1226`: "termination makes the envelope `retryable: false`". Witness: an account recorded `terminated` before any successful read has no stored row, so S1 refuses it `provider` with `retryable: true`. That also contradicts `WIR-9b`'s row at `13:173`, "The named account cannot recover". I'm not claiming termination forces reads to fail.

**Why this counts, and why it's new.** r69 accepted this same class of loss against F: `tally.md:45` calls it "a valid reachable refusal-precedence loss", and `:311` says "only a reachable failed-read witness is needed". It's new because S1's "before the tail" causes it; at base the tail is reached. r69 mentioned it only in a counterargument written on request ("unhealthy-account error precedence can change", `tally.md:105`), and `owner-question.md` doesn't disclose it.

**Why the fixtures can't avoid it.** A healthy account's fixture can keep its listing fresh. For an unreachable account, whatever makes it unreachable also stops the refresh.

**Against taking this candidate (written on request; not a vote).** The `409 state` is still reachable while the listing is within the age, so every `CNF-278`/`CNF-307` fixture can still pass. All four r69 readers picked S knowing precedence might move. For the recoverable statuses, a `provider` refusal with `retryable: true` is honest. The real costs are the `terminated` envelope and the 409→502 contract change.

## 2. Interactions across S1–S6

- **Admission snapshot and timing:** consistent. S1's "read in that snapshot" and "at the admitting transaction" match `04:263–264`, "from one read-only snapshot inside the existing `LDG-35` transaction". The only loss is the precedence loss in §1.
- **Credential-stop scope:** S3 and S6 match PRV-41's own MUST NOT, and S6's "no scheduled retry" adds no new duty. "the authentication stop" isn't defined anywhere at base, including `CONTEXT.md`; the PRV-41 quote supplies the meaning. Wording only.
- **Process placement:** `00:139` makes `engine` "the only code that may reach a provider credential". So every List offers read, and with it every STO-60 publication, happens in the engine: the refresh (S4's row) and claim step 4 (a worker write). Both fall under OPS-50's "every write transaction made in the engine process". No api-process publication escapes the fence. S4's placement does its job.
- **Caller-side publication:** consistent with PRV-50, as r69 verified.
- **Dispatch ordering:** STO-60's later-`read_at` rule agrees with S6's reverse-order assertion. One nit: S6's "After successful reads, assert publication … with `read_at` equal to the dispatch instant", applied to each read, conflicts with the reverse-order case, where the earlier-dispatched read is correctly not stored. A fixture that sequences its reads satisfies both, so this isn't a flip. I'm not proposing a fix, since rewording an assertion counts as behaviour changed.
- **Age and interval:** S5's "shorter than the offer-listing age" bounds the gap between dispatches, but not the time from dispatch to publication, and `read_at` is the dispatch instant. A healthy account whose reads all succeed can briefly go stale when interval plus call time exceeds the age, and then get a spurious `provider` refusal with `retryable: true`. Compare DOM-8's "at least twice the account-sweep interval". Recorded objection; not a gated loss.
- **Existing limitation, not new:** an account that never declares `list_offers` gets a permanent `provider` refusal with `retryable: true`. r69's S-d disposition covers this and I'm not re-arguing it.

## 3. S6 as added assertions

- They test STO-60 and OPS-51 faithfully. "within each … interval" means the same as "at least once per". The credential-stop exception mirrors S3. The `read_at`, replace-only-when-later and failed-read assertions mirror STO-60. Nothing narrows or widens the form beyond PRV-41's existing MUST NOT.
- The never-listed `CNF-166` case now needs a healthy account with a fresh stored listing, or S1 refuses first. A fixture can choose that, so it isn't a flip.
- The `price_moved` case is reachable if the fixture admits before the next refresh publishes.
- S6's stale-listing sentence doesn't say the account is healthy. That's consistent with S1 as printed, but the repair below needs it scoped to a healthy account.
- S6 itself causes no flip, unreachable witness or vacuous control. The flips in §1 come from S1.

**Proposed repair — behaviour changed.** It counts as CANNOT ACCEPT and is offered for a scoped repair read:
- **S1:** replace «Where no listing is stored, or its `read_at` is older than the stated offer-listing age (`OVR-19`) at the admitting transaction, the create MUST be refused `provider` (`01-domain-model.md`'s error taxonomy) with `retryable: true` before the tail, committing nothing.» with «Where the account's `STO-47` status in that snapshot is `healthy` and its listing is absent or has a `read_at` older than the stated offer-listing age (`OVR-19`) at the admitting transaction, the create MUST be refused `provider` (`01-domain-model.md`'s error taxonomy) with `retryable: true` before the tail, committing nothing.»
- **S6:** replace «Separately let the account's stored listing be older than the offer-listing age:» with «Separately let a `healthy` account's stored listing be older than the offer-listing age:».
- **Still open, for the repair read or the owner:** what the tail's offer check reads for an unhealthy account whose listing is stale or absent. Under the replacement it reads whatever is stored, and an absent listing lists no offers, which adds an `offer_not_sellable` entry after `state`. I'm not treating that as decided.

## 4. Coverage (my own run)

I applied S1–S6 exactly, parsed from brief lines 72–97, at the stated anchors in `.r70scratch/tree/` (a copy of all `*.md` files and `tools/`). I then ran `python3 tools/check_coverage.py` there, unpiped, writing output to a file and capturing the exit code directly.

- **Exit 0, 74 ratcheted uncovered:** "OK: 74 uncovered, at or below baseline 74 (set 2026-10-22)".
- Requirements went from 513 to 515 and covered from 407 to 409. The base run also exits 0 with 74.
- `tools/coverage-baseline.json` is byte-identical to base (checked with `cmp`).

I didn't run `lake` or the full gate suite.

## 5. Strict quoting

All checked with fixed-string grep against `git show c5f897c:<file>`:
- **DOM-9 row:** the whole sentence is verbatim at `01:185`. Pass.
- **Caller clarification:** a prefix of PRV-50 at `02:123`. The quote omits the continuation "under `PRV-12`'s guarantee: …", and its period sits outside the quote marks, so no period stands in for the omitted text. Pass.
- **S3:** the sentence belongs to PRV-41 (heading at `02:1235`, sentence at `02:1246–1248`). It's verbatim and stops before " (`OPS-26`)." Pass.
- **S6:** "where the provider's price has risen past what the reserve covers" matches OPS-43 at `03:865`, and `"price_moved"` matches `03:866`. Pass.
- **STO-60:** the candidate never quotes it, only bare `See` pointers. My replacements quote nothing.
- **Brief errors:** none. The `CNF-166` anchor wraps across `10:3695–3696` and matches once whitespace is normalized.

Final: CANNOT ACCEPT (blocking: S1's "before the tail" flips CNF-278 and CNF-307 on unhealthy accounts, and no listed amendment covers it); coverage exit 0, 74 uncovered, baseline 74 unchanged; remaining spans S1 (the stale/absent refusal sentence) and S6 (the stale-listing sentence), both behaviour changed, needing a scoped repair read or an owner decision.
