# Panel brief r68 (panel E, confirmation round): the exact texts for pv-tcs (S-final, F-final) and pv-ytv (K-final). 2026-10-25

You are one of four independent reviewers. Your working directory is a fresh throwaway clone of the specification
repository `provisiond-spec` at `c5f897c` (master). Read `AGENTS.md` first, especially "Quote the sentence" and
"Cite the owner". `br show pv-tcs pv-ytv` prints the two beads (if `br` fails, `.beads/issues.jsonl` holds them).
You MAY edit tracked files in this clone to test a claim, for example by applying a form and grepping for what it
breaks. Write nothing outside the clone (never `/tmp` or `/var/tmp`). Never commit, push or call a provider API.
**Run no gate and no `lake`**: the manager runs the gates on the chosen form afterwards. Keep `TMPDIR` as set. Do
not delegate, background or wait on anything. Have a draft answer by minute 25.

**What this is.** An earlier round (r67) read four forms for these two beads. No text carried as written: each
reader amended the form they picked. This round reads the **exact** texts below, assembled from those readers'
texts. Each text and each option carries its author's label: Reader 1 to Reader 4 are r67's readers, and you may
be one of them. Text marked **[coordinator]** is the coordinator's and no reader has read it. **None of these texts
has been read whole.** Q1 goes to the owner either way, as a choice between S-final and F-final (cost and latency
are the owner's), so **both** must be clean. Q2 asks whether K-final can be applied.

Every quote below was grepped at `c5f897c`, and every "before" string (in «») was checked to hit exactly once in
its file. The coordinator has been wrong in briefs before: **check every claim this brief makes before you rely on
it**, and report each error under "Brief errors". Read text by requirement id; line numbers (`04:262` =
`04-api-contract.md` line 262) are hints, not authority.

## The gate, and the mark every AMEND needs

- Vote **ACCEPT**, **AMEND** or **CANNOT ACCEPT** on each form read: S-final and F-final (Q1), K-final (Q2).
- **Every AMEND carries one explicit mark, "behaviour unchanged" or "behaviour changed"**, plus exact replacement
  text for its span only. "Behaviour unchanged" means that your text changes no behaviour the form states (a
  wording, quoting or citation fix). An AMEND that changes behaviour is marked "behaviour changed". It counts as
  CANNOT ACCEPT, so name its gated loss.
- **A CANNOT ACCEPT must name a loss that changes a checked verdict.** That is a `CNF` assertion or a Lean theorem
  the form flips, makes unreachable or makes vacuous (give its id or theorem name), or a MUST/SHOULD (file and
  requirement id) together with a trace that breaks it. A form that lists a `CNF` assertion as amended has not
  "lost" it; a flipped assertion it does not list is a loss. A CANNOT ACCEPT that names none of these is recorded
  but does not block. Wording you dislike is not counted.
- **Each option** (S-a, F-a, K-a, …) gets "take" or "leave" from you. An option changes its form only if three
  readers take it.
- **Any text you propose must satisfy `AGENTS.md`'s quoting rule strictly.** A sentence saying what another
  requirement does or is carries that requirement's verbatim words; only a bare "see `X`" pointer is exempt; and no
  MUST lands outside the requirement that owns the rule. If a text below breaks that rule, report it as a wording
  AMEND ("behaviour unchanged") with the verbatim fix.

## Settled (not for re-vote)

- `pv-14b`'s verdict wording in `API-7`: "not sellable under `PRV-13b` or `PRV-31`, or absent from the offers the
  check reads" (04:268), and "No additional lookup is made for this verdict" (04:275).
- `OPS-43`'s claim-time sale re-test and price check, on "one current driver List offers result taken at claim"
  (03:760-761), and its steps 4-6 (03:785-790).
- `PRV-42`'s presence check "is a dispatch check, not a provider lookup during `API-7`'s read-only tail
  collection" (02:1271).
- `PRV-33`: "an ambiguous create on that channel MUST resolve to an operator, never to a guess" (02:1048-1049).
- Robot's standard channel has not passed `CNF-180`: "Satisfied on the auction channel 2026-09-04; the standard
  channel remains open" (10:1491-1492).
- `ADR-0042` moved the dispatch test off the correlator pair onto `operations.about_to_order_at`.
- Q2's null-pair shape (an earlier "Form N") is not read this round. r67 traced a `PRV-26` loss in it (02:895-897,
  "Whichever it is, the kind and the value MUST be recorded on the operation row"). A reader who still prefers a
  null pair may give it as a third shape with exact text; it is recorded and does not block K-final.

## What r67's brief got wrong (corrected here)

1. **The inventory of rules F touches was short.** Besides `CNF-95`, `CNF-307`, `CNF-315` and `CNF-283`'s first
   sentence, a provider read at admission also contradicts `CNF-283`'s second sentence ("Subsequent local refusals
   make no provider request", 10:1893-1894), `CNF-340` ("before any provider call or write", 10:4028), `PRV-40`
   ("refuse subsequent creates on that account and channel before any provider call", 02:1211-1212) and `OPS-1`
   ("Every mutating request MUST create or return a durable operation record before any provider call is made",
   03:17-18). F's read must also be gated under `DOM-10`: "Every operation with a capability MUST be gated on it
   before the driver is called" (01:515), whose map row is "list offers | `list_offers`" (01:531). F-final below
   amends each of the first five and honours `DOM-10` by gating its read. Its `DOM-10` text is unchanged.
2. **04:306-307 is not `API-7`'s normative text.** "A refused tail still commits nothing, including no operation,
   machine, balance write, receipt or provider call." sits in the italic "*Amended 2026-10-09 (`ADR-0039`, …)*"
   record (04:304-308). The normative sentence is "A refused tail MUST commit nothing and write no `STO-35`
   receipt" (04:287-288). The no-call rule lives at 04:262-264. F-final edits no amendment record in `API-7`.
3. **`DOM-17` lists no error kinds** (01:655). The closed set is `01-domain-model.md`'s "Error taxonomy" table
   (01:574 onward), which also has `network`, `authentication` and `rate_limited`.
4. **05:360's index is not a consumer of the operation pair.** "index on `(correlator_value)` for reconciliation
   lookup" (05:360) sits under `### machines` (05:307).
5. **`OPS-43` does not stop every risen price.** It fails a create "where the provider's price has risen past what
   the reserve covers" (03:865). The story below is corrected.
6. **The machine pair is not the only link from a retained machine to its operation.** `machines.first_unit_debit_id`
   (05:329) references a ledger entry, which carries `operation_id`. `PRV-9` (02:151-152) and `CNF-303` still read
   the guard through `machines.correlator_value`.
7. **r67's brief never asked for the "behaviour unchanged" mark.** This one does (above).

---

## Q1 (pv-tcs): which offer data does create admission read, and how fresh?

**Plain terms.** A customer lists offers at 12:00 and sees auction offer `market:12345` at 90 sats/hour. At 12:03
the provider re-lists it at 120, or drops it. At 12:04 the customer creates. Under S-final, admission prices the
create from a stored listing up to one stated age old: it reserves 90/hour and admits. Under F-final, admission
reads the listing for this request: it reserves 120/hour, or refuses `offer_not_sellable`. Under S-final the claim
then re-reads, and `OPS-43` fails the create only "where the provider's price has risen past what the reserve
covers"; a dropped offer fails as absent. No machine is wrongly bought under either. What differs is whether the
create is admitted, how much balance it holds, and whether admission spends a provider read.

**Verified facts.**

- `API-7`'s tail: "the tail MUST collect every applicable refusal once, from one read-only snapshot inside the
  existing `LDG-35` transaction, without an extra lock, ceiling slot, write or provider call" (04:262-264).
- Step 5d: "**gate a create on its ordering capability** under `DOM-10` (`PRV-10`, `DOM-16`). A refusal stops here
  and is not collected by the tail." (04:241). "Steps 1–5d still stop at their first refusal" (04:291).
- Admission already reads offer data; only its source is unnamed. 05:444 records the accepted "recurring price, its
  currency and its period", and "The declared cancellation bound MUST be resolved to a provider-local date at API
  acceptance, in the create's admitting transaction, taking the later of the descriptor's `cancellation_bound` and
  the offer-reported bound where both exist".
- `05-persistence.md` has no offers table (its `## Schema` sections, 05:255 onward).
- `CNF-166` tests the never-listed case as "absent from every source admission could read" (10:3695-3696).
- `OVR-17`: "Every component that runs without a caller MUST be assigned to a module" (00:269), and "MUST be
  extended when a component is added" (00:312).
- `PRV-41`: "A driver MUST therefore treat an `authentication` failure as terminal for that credential, MUST NOT
  re-attempt it on a schedule, and MUST surface it for an operator (`OPS-26`)." (02:1246-1248).
- `OPS-50` fences "every write transaction made in the engine process", naming "every component `OVR-17` assigns
  to the engine", and says "Writes made in the api process are not checked." (03:1985-1996).
- `OVR-9`: "`api` MUST NOT depend on `providers` or `rescue` at all, and MUST reach `engine` only through a trait
  whose signatures mention no credential type." (00:172-173).
- No documented Robot request limit names the product listings (`08-provider-notes.md`'s limits table has no
  `/order/server/product` row). Do not assume one either way.

### S-final (stored listing; admission makes no provider call). Reader 4's S text

- **S1** `04-api-contract.md`, `API-7`: after «without an extra lock, ceiling slot, write or provider call.» insert:
  > On create, the offers the check reads are the provider account's stored offer listing (`05-persistence.md`, `offer_listings`), read in that snapshot, and the tail prices the commitment and takes the offer snapshot from it. Where no listing is stored, or its `read_at` is older than the stated offer-listing age (`OVR-19`) at the admitting transaction, the create MUST be refused `provider` (`01-domain-model.md`'s error taxonomy) with `retryable: true` before the tail, committing nothing. Every offer-derived input used to size the commitment or populate `request_summary` comes from the named offer in that same stored listing, including recurring price, currency, period, setup fee, `install_strategies`, and any offer-reported billing unit or cancellation bound. Descriptor-declared inputs come from the descriptor the `api` runs with. See `PRV-44`, `PRV-13b` and `05-persistence.md`.

  [coordinator: "(`DOM-17`)" after `provider` repointed to the error taxonomy, r67 error 3.]
- **S2** `05-persistence.md`, new subsection: before «### `tenants`» insert:
  > ### `offer_listings`
  >
  > **STO-60** `read_at` is the dispatch instant of the successful driver List offers call. Every successful driver List offers read MUST publish its complete result to the account's row, replacing an existing row only when the incoming `read_at` is later. A failed read MUST leave the row unchanged. See `OPS-51`.
  >
  > | Column | Type | Notes |
  > |---|---|---|
  > | `provider_account` | text | primary key |
  > | `read_at` | timestamp | see `STO-60` |
  > | `offers` | json | the driver's List offers result, prices as strings (`DOM-9`) |

  [coordinator: the columns are r67 S's, set in 05's table form; the subsection follows `### provider_observations`.]
- **S3** `03-operation-lifecycle.md`, new requirement after `OPS-50`: after «its guarantee covers one writable database history.» insert:
  > **OPS-51** A refresh pass MUST read every account declaring `list_offers` at least once per stated offer-listing refresh interval, except while that credential is subject to the authentication stop. `PRV-41` says “A driver MUST therefore treat an `authentication` failure as terminal for that credential, MUST NOT re-attempt it on a schedule, and MUST surface it for an operator”.
- **S4** `00-overview.md`, `OVR-17`'s table: after «| `OPS-32`'s account sweep | `engine` | Lists resources at a provider, so it needs a provider credential |» insert:
  > | Offer-listing refresh (`OPS-51`) | `engine`, running in the engine process | See `OPS-50`. |
- **S5** `00-overview.md`, `OVR-19`'s register: after «| Refresh freshness window | `DOM-8` | finite, positive duration at least twice the account-sweep interval | yes |» insert:
  > | Offer-listing age | `API-7` | finite, positive duration | yes |
  > | Offer-listing refresh interval | `OPS-51` | finite, positive duration, shorter than the offer-listing age | yes |

  [coordinator: rows written from Reader 4's "Register S's age under `API-7`, and refresh interval under `OPS-51`"
  and r67 S's "each a finite positive duration, the interval shorter than the age".]
- **S6** `10-conformance-checklist.md`, `CNF-166`: «absent from every source admission could read» → «absent from the stored offer listing»; and after «Cap and balance do not run; there is no commitment, purchase write or provider order.» insert:
  > Separately let the account's stored listing be older than the offer-listing age: the create is refused `provider`, `retryable: true`, with no provider call. Separately re-list the named offer, inside the age, at a higher price sufficient to exceed what the admitted reserve covers, leaving the stored listing unchanged until admission: the create is admitted at the stored price, and the claim fails `conflict` with `details.reason: "price_moved"` (`OPS-43`: "where the provider's price has risen past what the reserve covers").

  [r67 S's two cases with Reader 4's price fix. coordinator: "`OPS-43`'s claim-time check then refuses it"
  replaced by `OPS-43`'s verbatim words; clause order set.]
- **Unchanged under S-final:** `CNF-95`, `CNF-307`, `CNF-315`, `CNF-283`, `CNF-340`, `PRV-40`, `OPS-1`, `DOM-10`,
  `PRV-42`, `LDG-27`, `WIR-30`, 05:444.

**S options (take or leave each):**
- **S-a (Reader 1): a numbered step for the staleness refusal.** Replace S1's second sentence with a new step after
  5d (04:241), and change "steps 1–5d" to "steps 1–5e" at 04:262 and 04:291, the only two "1–5d" ranges [coordinator: the
  consequential edit]:
  > 5e. **refuse a create whose provider account has no stored offer listing** (`STO-60`) **or whose listing's `read_at` is older than the stated offer-listing age** (`OVR-19`): `provider` with `retryable: true` and `details.provider_account`. A refusal stops here and is not collected by the tail.

  Reader 1's reason: 04:291, "Steps 1–5d still stop at their first refusal".
- **S-b (Reader 3): one `STO-60` with the timestamp, atomicity and refresh rules.** Replace S2's `STO-60` paragraph
  and S3 with the text below. S4's row and S5's interval row then cite `STO-60`, not `OPS-51`.
  > **STO-60** Each successful complete driver List offers result MUST be recorded in `offer_listings`. `read_at` is the store-clock timestamp obtained immediately before dispatch, not response completion. Replacement MUST be atomic and occur only when no row exists or the incoming `read_at` is later. Failed or incomplete reads MUST NOT advance `read_at`. Recording is outside the driver read.
  >
  > The engine’s refresh pass MUST attempt a read for each healthy account declaring `list_offers` at least once per stated refresh interval, except while its credential is barred following authentication failure. `PRV-41` says “treat an `authentication` failure as terminal for that credential” and “MUST NOT re-attempt it on a schedule”. See `OPS-50`.
- **S-c (Reader 3, offered for either form): a MUST on the offer-derived inputs.** Replace S1's last three
  sentences ("Every offer-derived input … `05-persistence.md`.") with:
  > The tail MUST take every offer-origin input to commitment pricing and the accepted snapshot from that result. Descriptor-declared inputs come from the admitting process’s immutable descriptor. See `PRV-44` and `05-persistence.md`.
- **S-d (Reader 2; no text exists): an account that declares the ordering capability but not `list_offers`.**
  Under S-final no read ever stores its listing, so every create on it is refused `provider` with
  `retryable: true`, indefinitely. At `c5f897c` such a create is admitted and fails `unsupported` at claim
  (`OPS-43` step 4, "Gate on `list_offers` under `DOM-10`"). Take means "S-final needs text for this": give it.

### F-final (fresh read per create). Reader 2's F text, Reader 4's `PRV-40` span, and an `OPS-1` span by the coordinator

- **F1** `04-api-contract.md`, `API-7`: after «without an extra lock, ceiling slot, write or provider call.» insert:
  > On create, after step 5d and before that transaction opens, the `api` MUST obtain one current driver List offers result for the named offer's provider account, in the order of `OPS-43`'s step 4: "Gate on `list_offers` under `DOM-10`, then obtain the current driver List offers result." That result is the only source of the offers the check reads. The tail prices the commitment, takes the offer snapshot and tests the offer for sale from it. A gate refusal or a failed read stops the create as step 5d's does: "A refusal stops here and is not collected by the tail." A failed read refuses with the kind and `retryable` the read reported, committing nothing; see `DOM-17`. See `OVR-9` for the route.

  [coordinator: Reader 2's "through `engine`'s narrow trait (`OVR-10a`)," is deleted and "See `OVR-9` for the
  route." added. `OVR-10a` (00:216) is the credentials rule, and "`engine`'s narrow trait" restates `OVR-9`
  without its words. Reader 2's "(`DOM-17`)" after "the read reported" becomes "; see `DOM-17`".]
- **F2** `10-conformance-checklist.md`, `CNF-95`: «**no provider call is made**» → «**no provider mutation is made**; the admission List offers read is permitted»
- **F3** `10-conformance-checklist.md`, `CNF-307`: «operation or receipt and makes no provider call» → «operation or receipt and makes no provider call other than a create's admission List offers read»
- **F4** `10-conformance-checklist.md`, `CNF-315`: «the create is refused before any provider call» → «the create is refused before any provider mutation»
- **F5** `10-conformance-checklist.md`, `CNF-283`: «`API-7` tail before any provider call» → «`API-7` tail before any provider mutation»; and «Subsequent local refusals make no provider request» → «Subsequent local refusals make no provider request other than the admission List offers read»

  [coordinator: the quoting sweep flags the first sentence, "refused by the `API-7` tail before any provider
  mutation", for naming the `API-7` tail without its words. "refused by the `API-7` tail" is `c5f897c`'s text;
  F5 changes only "call". Say if you want a quote added.]
- **F6** `10-conformance-checklist.md`, `CNF-340`: «before any provider call or write» → «before any provider mutation or write; the admission List offers read is permitted»
- **F7** `10-conformance-checklist.md`, `CNF-166`: «absent from every source admission could read» → «absent from the admission List offers result»; and after «Cap and balance do not run; there is no commitment, purchase write or provider order.» insert:
  > Separately re-list the named offer at a higher price after a listing and before the create, and assert the commitment is sized at the new price. Fail the admission read with a retryable `provider` error, and assert `provider`, `retryable: true`, no commitment, operation or receipt. On an account declaring the ordering capability but not `list_offers`, assert `unsupported` with `details.capability: "list_offers"`, no `details.refusals`, and no List offers read, commitment, operation or receipt.

  [r67 F's two cases and Reader 2's third. coordinator: "with a retryable `provider` error" added, since F1
  refuses with "the kind and `retryable` the read reported".]
- **F8** `02-provider-contract.md`, `PRV-40` (Reader 4): «refuse subsequent creates on that account and channel before any provider call, with `rate_limited` and `retry_after_ms` for the remaining interval.» → «refuse subsequent creates on that account and channel before any provider mutation, with `rate_limited` and `retry_after_ms` for the remaining interval; the create's admission List offers read is permitted.»

  [Reader 4's span was "before any provider mutation; the create's admission List offers read is permitted".
  Reader 3's is the same without "the create's" (option F-d). Reader 4's is used because "the create's" ties the
  permitted read to the refused create. coordinator: clause order set so "with `rate_limited` and
  `retry_after_ms`" stays on the refusal.]
- **F9 [coordinator, UNREVIEWED]** `03-operation-lifecycle.md`, the italic record at lines 276-277: «before any provider call" and, for a queued» → «before any provider mutation" and, for a queued»

  [The italic record says "`PRV-40` says to" in the present tense. With F9 it quotes F8's words. To leave the
  record as it is, answer "leave" on F9.]
- **F10 [coordinator, UNREVIEWED]** `03-operation-lifecycle.md`, `OPS-1`: after «and MUST respond `202 Accepted` with that record.» insert:
  > This does not cover a create's admission List offers read, which comes before any record and is made whether or not the create is then admitted: `API-7` says "the `api` MUST obtain one current driver List offers result for the named offer's provider account".

  [No reader text fixes `OPS-1`. This is a separate second sentence, so `OPS-1`'s first sentence stays verbatim:
  impl-report-01.md:174 quotes it. Vote on F10 like any span.]
- **Rules F-final changes, the full list:** `API-7` (F1), `CNF-95` (F2), `CNF-307` (F3), `CNF-315` (F4), `CNF-283`
  both sentences (F5), `CNF-340` (F6), `CNF-166` (F7), `PRV-40` (F8), the 03:276-277 record (F9), `OPS-1` (F10).
  **Honoured without a text change:** `DOM-10` (F1's gate). **Unchanged:** `PRV-42` (its check stays a dispatch
  check), `LDG-27`, `WIR-30`, 05:444, and the `API-7` amendment records at 04:304-308 and 04:309-313. Provenance
  notes are the implementation Run's.

**F options (take or leave each):**
- **F-a: the failed-read sentence** (F1's "A failed read refuses with the kind and `retryable` the read reported,
  committing nothing; see `DOM-17`."). Say which you take, or "F1 as printed":
  - Reader 4: "A failed read refuses the create before the tail with the driver error’s own kind, details and retryability, committing nothing. See `PRV-5` and `PRV-41`."
  - Reader 3: "A failed admission read refuses before the tail and commits nothing, preserving the driver error’s kind, retryability and redacted details. See `PRV-5`, `PRV-41` and `DOM-17`."
- **F-b (Readers 3 and 4): `CNF-340` with "purchase write".** F6 becomes «before any provider call or write» → «before any provider mutation or purchase write; the admission List offers read is permitted».
- **F-c: `CNF-283`'s second sentence.** In place of F5's second replacement:
  - Reader 4: «Subsequent local refusals make no provider request» → «Subsequent local refusals make no provider request other than the create’s admission List offers read».
  - Reader 3: «Subsequent local refusals make no provider request and need no new provider-throttle alarm» → «Subsequent local refusals permit only the admission List offers read; the local refusal itself needs no new provider-throttle alarm».
- **F-d (Reader 3): `PRV-40` without "the create's".** F8's last clause becomes "the admission List offers read is permitted".
- **F-e (Reader 3): S-c above, applied to F1** in place of "The tail prices the commitment, takes the offer
  snapshot and tests the offer for sale from it."

### Points the coordinator could not settle (answer each in a line)

1. **Claim-time "no provider request" items under F-final.** These assert no provider request for a refusal at
   `OPS-43`'s steps 1-4, in a create that F-final has already read at admission: `CNF-55` ("no provider request,
   including no List offers read", 10:344-345), `CNF-278` ("no provider request", 10:2816), `CNF-342` ("no provider
   request at all, including no List offers read", 10:4074) and `CNF-364` ("no List offers read, per-order key
   upload or order request"). The coordinator reads each as scoped to the claim. If you read one as counting the
   admission read, it is an unlisted flip: name it.
2. **F1's gate and admission on an account without `list_offers`.** Does any `CNF` item admit a create on an
   account that declares the ordering capability but not `list_offers`? F1 now refuses that create `unsupported`
   at admission. `CNF-364` admits on an account that declares `list_offers` and drops it only before claim.
3. **S-final's `STO-60` and claim.** `STO-60` makes every successful List offers read publish to the row,
   including `OPS-43`'s claim-time read in a worker. Does that write break any claim-time assertion of "no write"?

### Q1 questions

1. ACCEPT, AMEND (marked) or CANNOT ACCEPT on S-final, and on F-final. **Pick one**, or give a third shape as
   exact text, with your strongest reason.
2. Take or leave each option: S-a, S-b, S-c, S-d, F-a (which text), F-b, F-c (which text), F-d, F-e, and F9 and F10
   as printed.
3. The three points above, a line each.

---

## Q2 (pv-ytv): on a `correlator: none` channel, what does the correlator pair hold?

**Plain terms.** A Robot create goes out on the standard channel, which the descriptor declares
`correlator: none`. The order carries a per-order SSH key with fingerprint `29:07:2c:…`. The order reply is lost.
At `c5f897c`, engine A has written that fingerprint into `operations.correlator_value` before ordering, and engine B
has written null. Both cite the text. Under both, `PRV-33` sends the create to an operator. The difference that
reaches a check comes later. After the machine is delivered and retention removes the operation row, `OPS-32`'s key
sweep reads the guard through `machines.correlator_value` (`CNF-303`). K-final makes engine A's behaviour the rule.

**Verified facts.**

- `PRV-32`: "Until a driver's own channel passes `CNF-180`, it MUST declare no correlator and `PRV-33` governs"
  (02:990-991). `PRV-33`: "The driver declares the absence as that channel's `correlator: none` in the descriptor's
  `ordering_channels`" (02:1053-1054).
- `PRV-26`: "Whichever it is, the kind and the value MUST be recorded on the operation row —
  `operations.correlator_kind` and `operations.correlator_value` (`05-persistence.md`) — before the order is sent"
  (02:895-897). It names no channel exception.
- 05:441: the `operations` pair holds "`ssh_key_fingerprint` on Robot (`PRV-32`)", and is "Written in `API-63`'s
  correlator transaction, which is `OPS-43`'s step 8". 05:326 (the `machines` pair) is "Nullable, for a machine that
  bore none when adopt returns (`ADR-0020`)". Neither names a channel.
- `PRV-9`: "For an operation that produced a machine, its `machines.correlator_value` is the operation UUID on
  Hetzner Cloud and DigitalOcean, or its per-order correlator-key fingerprint on Robot" (02:151-152). `CNF-303`:
  "Read the guard through retained `machines.correlator_value`: operation UUID for Cloud and DigitalOcean,
  per-order correlator-key fingerprint for Robot" (10:2936-2938).
- Master does not state that a Robot order on a `correlator: none` channel carries a generated per-order key.
  `PRV-32`: "`PRV-9` already requires the driver to register a temporary key per order, so making it **unique per
  order** costs nothing" (02:962-964). K-final states the key as a MUST.
- `OPS-38`: "A create that recorded none has no count: `OPS-27`'s row for "no verified correlator exists for the
  operation's ordering channel" applies, and it is **Unresolved**" (03:710-712). `OPS-27`'s rows include "Exactly
  one resource across every channel" and the no-verified-correlator row, and the table states no precedence
  between them.
- `CNF-278` repeats "the step-8 barriers and account-read cases" on a `correlator: none` descriptor, "making no
  assertion about the correlator pair on the latter" (10:2821-2825). Its account-read cases fail at `OPS-43`'s step
  1, its first barrier case commits the termination "before its step-8 transaction commits", and its second barrier
  case commits it "*after* step 8 commits" (10:2805-2817). So on the same item step 8 commits in some cases and not
  in others.
- `OPS-33`, on a channel with no verified correlator: "the search it bounds is an **operator** search, not an
  automatic one" (03:1697-1698).

### K-final (record the fingerprint on every Robot channel). Reader 4's K text

- **K1** `02-provider-contract.md`, `PRV-26`: after «reconciliation would otherwise have nothing durable to search for.» insert:
  > For Robot, this recording obligation applies on every ordering channel, including one declared `correlator: none`: the kind is `ssh_key_fingerprint` and the value is the per-order key's fingerprint. See `PRV-33`.
- **K2** `02-provider-contract.md`, `PRV-32`: after «it MUST declare no correlator and `PRV-33` governs.» insert:
  > On every Robot ordering channel, including one declared `correlator: none`, the driver MUST generate a throwaway key unique to that order and send its public key with the order, in addition to the caller's keys. See `PRV-26` and `PRV-33`.

  [coordinator: r67 K's lead-in "That declaration is the descriptor's `correlator: none`." is dropped. It says
  what `PRV-33` does without `PRV-33`'s words, and K2 already says "including one declared `correlator: none`".
  Reader 2's verbatim lead-in is option K-a.]
- **K3** `03-operation-lifecycle.md`, `OPS-38`: «A create that recorded none has no count:» → «A create that recorded none, or whose ordering channel is declared `correlator: none` (see `PRV-33`), has no count:» (r67 K; the rest of the sentence stays). [coordinator: r67 K's "(`PRV-33`)" becomes the bare pointer "(see `PRV-33`)".]
- **K4** `10-conformance-checklist.md`, `CNF-278`: «making no assertion about the correlator pair on the latter» → «asserting the fingerprint pair on both descriptors where the step-8 transaction committed, and a null pair before any step-8 transaction committed»
- **K5** `10-conformance-checklist.md`, new item after `CNF-165`: after «and why the others are believed spurious. (`OPS-38`, `OPS-31`)» insert:
  > - [ ] **CNF-371** — On a standard-channel (`correlator: none`) descriptor, lose a create's order reply with exactly one standard-listing transaction carrying its fingerprint; assert **Unresolved**, operator escalation and no automatic attach. (`OPS-38`, `PRV-33`, `OPS-27`)

  [r67 K's case. coordinator: the id and the closing cite list.]
- **K6** `10-conformance-checklist.md`, `CNF-303` (Reader 4): after «per-order correlator-key fingerprint for Robot.» insert:
  > Run this Robot case on a standard-channel (`correlator: none`) descriptor too.
- **Unchanged under K-final:** 05:441, 05:326, `PRV-9`, `PRV-33`, `CNF-303`'s existing cases.

**K options (take or leave each):**
- **K-a (Reader 2): `PRV-32` with a verbatim `PRV-33` lead-in.** In place of K2:
  > `PRV-33` says "The driver declares the absence as that channel's `correlator: none`". The driver MUST still send a per-order key unique to the order, and `PRV-26` says "Whichever it is, the kind and the value MUST be recorded on the operation row".
- **K-b (Reader 3): `PRV-26` quoting `PRV-33`.** In place of K1:
  > On every Robot ordering channel, including one declared `correlator: none`, the recorded kind is `ssh_key_fingerprint` and the value is that order’s generated key fingerprint. `PRV-33` says “an ambiguous create on that channel MUST resolve to an operator, never to a guess”.
- **K-c: the `CNF-278` fix.** All four r67 readers fixed the same defect: K's first form asserted the fingerprint
  "on both" in cases that fail before step 8 commits. Say which you take, or "K4 as printed":
  - Reader 1: "asserting the pair null on both before step 8 commits, and `correlator_kind` `ssh_key_fingerprint` with the per-order key's fingerprint on both after it"
  - Reader 2: "asserting, where step 8 committed, `correlator_kind` `ssh_key_fingerprint` and the per-order key's fingerprint on both, and a null pair on both where it did not"
  - Reader 3: "asserting a null correlator pair before any successful step-8 commit, and `ssh_key_fingerprint` with the generated per-order fingerprint after that commit, on both Robot descriptors"
- **K-d (Reader 2): the window's end.** In K5, before the cite list, add:
  > After the negative window releases the commitment, assert still no automatic attach (`OPS-33`: "the search it bounds is an **operator** search, not an automatic one").

  [coordinator: Reader 2 wrote "after `OPS-33`'s window releases the commitment, no automatic attach by `OPS-32`'s
  sweep"; `OPS-33`'s verbatim words added for the quoting rule.]

**Disputed in r67 (stated neutrally; K-final takes the second side of the first point):**
- **Does K2 need its MUST?** Reader 1: K's per-order key already excludes a caller-only order. Readers 2, 3 and
  4: K's "still sends" is not a MUST, so nothing requires the key.
- **A caller-key-only order.** Reader 1: the pair would hold the caller key's fingerprint, which `PRV-26` forbids
  ("anything else linkable to a person", 02:899-900). Reader 2: the pair would be null, so after retention the sweep
  deletes the caller key while the machine reads `provisioning`, which breaks `PRV-9`'s "only when … no machine
  that operation produced still reads `provisioning`" (02:141-143). Both traces end at the MUST.

### Q2 questions

1. ACCEPT, AMEND (marked) or CANNOT ACCEPT on K-final.
2. Take or leave each option: K-a, K-b, K-c (which text), K-d.
3. Trace `CNF-303` for a standard-channel Robot create under K-final after retention removes the operation row:
   does the sweep keep every tagged key while the machine reads `provisioning`?
4. Does K3 settle the precedence between `OPS-27`'s "Exactly one" row and its no-verified-correlator row, so that
   no conforming engine auto-attaches on the traced lost reply?

---

## Answer

- **Q1:** S-final: ACCEPT / AMEND (marked) / CANNOT ACCEPT. F-final: the same. **Pick**, with your strongest
  reason. Options, one line each. The three coordinator points, one line each. **Against my pick (written on
  request):** at most 60 words. At most 450 words, not counting replacement text.
- **Q2:** K-final: ACCEPT / AMEND (marked) / CANNOT ACCEPT. Options, one line each. Questions 3-4. **Against K-final
  (written on request):** at most 60 words. At most 300 words, not counting replacement text.
- **For every AMEND:** the span id (S1, F8, K4 …), the exact replacement, and the mark "behaviour unchanged" or
  "behaviour changed".
- **Brief errors:** each wrong fact, with the grep or quote that shows it.

**Total answer: at most 900 words**, not counting replacement text.
