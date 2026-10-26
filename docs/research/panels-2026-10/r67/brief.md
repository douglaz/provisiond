# Panel brief r67 (panel E): where admission's offer data comes from, and what a `correlator: none` create records — pv-tcs, pv-ytv. 2026-10-25

You are one of four independent reviewers. Your working directory is a fresh throwaway clone of the specification
repository `provisiond-spec` at `c5f897c` (master). Read `AGENTS.md` first, especially "Quote the sentence" and
"Cite the owner". `br show pv-tcs pv-ytv` prints the two beads (if `br` fails, `.beads/issues.jsonl` holds them).
You MAY edit tracked files in this clone to test a claim, for example by applying a form and grepping for what it
breaks. Write nothing outside the clone (never `/tmp` or `/var/tmp`). Never commit, push or call a provider API.
**Run no gate and no `lake`**: the manager runs the gates on the chosen form afterwards. Keep `TMPDIR` as set. Do
not delegate, background or wait on anything. Have a draft answer by minute 25.

Every quote below was grepped at `c5f897c`, but the manager has been wrong in briefs before: **check every claim
this brief makes before you rely on it**, and report each error under "Brief errors". Read text by requirement id;
line numbers (`04:262` = `04-api-contract.md` line 262) are help, not authority.

## The gate (how a CANNOT ACCEPT counts)

A CANNOT ACCEPT must name a loss that changes a checked verdict: a `CNF` assertion or a Lean theorem that the form
flips, makes unreachable or makes vacuous (give its id or theorem name), or a MUST/SHOULD (file and requirement id)
together with a trace that breaks it. A form that lists a `CNF` assertion as amended has not "lost" it; one it
flips without listing has. Give replacement text for that span only. A CANNOT ACCEPT that names none of these is
recorded but does not block. Wording you dislike is not counted.

**Any text you propose must satisfy `AGENTS.md`'s quoting rule strictly**: a sentence saying what another
requirement does or is carries that requirement's verbatim words; only a bare "see `X`" pointer is exempt; and no
MUST lands outside the requirement that owns the rule.

## Settled (not for re-vote)

- `pv-14b`'s verdict wording in `API-7`: "not sellable under `PRV-13b` or `PRV-31`, or absent from the offers the
  check reads" (04:268), and "No additional lookup is made for this verdict" (04:275).
- `OPS-43`'s claim-time sale re-test and price check, on "one current driver List offers result taken at claim"
  (03:760-761) and its steps 4-6 (03:784-788).
- `PRV-42`'s presence check "is a dispatch check, not a provider lookup during `API-7`'s read-only tail
  collection" (02:1271).
- `PRV-33`: "an ambiguous create on that channel MUST resolve to an operator, never to a guess" (02:1048-1049).
- Robot's standard channel has not passed `CNF-180`: "Satisfied on the auction channel 2026-09-04; the standard
  channel remains open" (10:1491-1492).
- `ADR-0042` moved the dispatch test off the correlator pair onto `operations.about_to_order_at`.

---

## Q1 (pv-tcs): which offer data does create admission read, and how fresh?

**Plain terms.** A customer lists offers at 12:00 and sees auction offer `market:12345` at 90 sats/hour. At 12:03
the provider re-lists it at 120, or drops it. At 12:04 the customer creates. Engine A prices the create from a
listing it read at 12:00: it reserves 90/hour and admits. Engine B reads the listing for this request: it reserves
120/hour, or refuses `offer_not_sellable`. Both can cite the text. `OPS-43`'s claim-time re-test then stops a risen
price or an absent offer before anything is ordered, so no machine is wrongly bought. What still differs is whether
the create is admitted and how much of the customer's balance it holds.

**Verified facts.**

- `API-7`'s tail: "the tail MUST collect every applicable refusal once, from one read-only snapshot inside the
  existing `LDG-35` transaction, without an extra lock, ceiling slot, write or provider call" (04:262-264).
- `API-7`: "A refused tail still commits nothing, including no operation, machine, balance write, receipt or
  provider call." (04:306-307).
- Admission already reads offer data; only its source is unnamed. `05-persistence.md`'s `request_summary` row
  records the accepted "recurring price, its currency and its period", and "The declared cancellation bound MUST
  be resolved to a provider-local date at API acceptance, in the create's admitting transaction, taking the later
  of the descriptor's `cancellation_bound` and the offer-reported bound where both exist" (05:444).
- `LDG-27`: the conversion happens "at the point the obligation is *incurred* — opening or adjusting a commitment"
  (12:1864-1865). `WIR-30`: "An offer price is an indicative quote converted at read time; `binding` is `false` and
  the commitment is priced at accept time (`LDG-27`) and MAY differ" (13:1095-1097). Neither names a source.
- `05-persistence.md` has no offers table (its `## Schema` sections, 05:255 onward).
- `CNF-166` tests the never-listed case as "absent from every source admission could read" (10:3695-3696).
- Four `CNF` assertions forbid any provider call on an admission refusal:
  - `CNF-95`: "A create whose available balance is one satoshi short is rejected and **no provider call is made**"
    (10:544-545);
  - `CNF-307`: "every refusing tail writes no commitment, balance, machine, operation or receipt and makes no
    provider call" (10:1228-1229);
  - `CNF-315`: "the create is refused before any provider call" (10:807-808);
  - `CNF-283`: "refused by the `API-7` tail before any provider call" (10:1887-1888).
  Elsewhere the set counts a List offers read as a provider request: `CNF-358` says "no step-9 request reached the
  provider ... the List offers read is permitted" (10:1527-1531).
- The manager found no documented Robot request limit for the product listings (`08-provider-notes.md`'s limits
  table names no `/order/server/product` row). Do not assume one either way.

### Form F (fresh read per create)

- `API-7`, after "without an extra lock, ceiling slot, write or provider call." (04:264) insert:
  "On create, the `api` MUST first obtain one current driver List offers result for the named offer's provider
  account, after step 5d and before that transaction opens. The offers the check reads are that result, and the
  tail prices the commitment and takes the offer snapshot from it. A failed read refuses the create with the
  read's own kind, `provider` or `timeout` (`DOM-17`), and `retryable: true`, before the tail and committing
  nothing."
- `API-7` (04:306-307): "including no operation, machine, balance write, receipt or provider call." becomes
  "including no operation, machine, balance write, receipt or provider mutation; the create's List offers read
  above is its only provider call."
- `CNF-95`: "**no provider call is made**" becomes "**no provider mutation is made**; the admission List offers
  read is permitted".
- `CNF-307`: "and makes no provider call" becomes "and makes no provider call other than a create's admission
  List offers read".
- `CNF-315` and `CNF-283`: "before any provider call" becomes "before any provider mutation".
- `CNF-166`: "absent from every source admission could read" becomes "absent from the admission List offers
  result". Add two cases: re-list the named offer at a higher price after a listing and before the create, and
  assert the commitment is sized at the new price; fail the admission read, and assert `provider`,
  `retryable: true`, no commitment, operation or receipt.
- Unchanged: `PRV-42` (its check stays a dispatch check), `LDG-27`, `WIR-30`, 05:444.

### Form S (stored listing; admission makes no provider call)

- `API-7`, after "without an extra lock, ceiling slot, write or provider call." (04:264) insert:
  "On create, the offers the check reads are the provider account's stored offer listing (`05-persistence.md`,
  `offer_listings`), read in that snapshot, and the tail prices the commitment and takes the offer snapshot from
  it. Where no listing is stored, or its `read_at` is older than the stated offer-listing age (`OVR-19`) at the
  admitting transaction, the create MUST be refused `provider` (`DOM-17`) with `retryable: true` before the tail,
  committing nothing."
- `05-persistence.md`, new table `offer_listings`: `provider_account` (primary key), `read_at` (timestamp),
  `offers` (json: the driver's List offers result with prices as strings, `DOM-9`). Rule beside it: "Every
  successful driver List offers read the deployment makes MUST replace the account's row when its `read_at` is
  later, and a refresh pass MUST read every account declaring `list_offers` at least once per stated
  offer-listing refresh interval (`OVR-19`)."
- `OVR-19`'s register: two rows, "Offer-listing age" and "Offer-listing refresh interval", each a finite positive
  duration, the interval shorter than the age.
- `CNF-166`: "absent from every source admission could read" becomes "absent from the stored offer listing".
  Add: a listing older than the age refuses `provider`, `retryable: true`, with no provider call; an offer
  re-listed at a higher price inside the age is admitted at the stored price, and `OPS-43`'s claim-time check
  then refuses it.
- Unchanged: `CNF-95`, `CNF-307`, `CNF-315`, `CNF-283`, `PRV-42`, `LDG-27`, `WIR-30`.

### Q1 questions

1. ACCEPT, AMEND or CANNOT ACCEPT on F, and on S. Pick one, or give a third shape as exact text.
2. F deletes the rule that an admission refusal makes no provider call. **What was that rule protecting?** (For
   example, does a refused or abusive create now spend provider reads, and does anything bound that?) Does S's
   new write (the listing row and the refresh pass) need `OPS-50`'s generation fence, or is it outside it?
3. Must admission's source match claim's (`OPS-43` step 4), or is it enough that claim re-tests?
4. Does either form leave a reader of 05:444's snapshot (price, setup fee, first unit, `billing_unit.seconds`,
   `install_strategies`, the offer-reported bound) with no named source?

---

## Q2 (pv-ytv): on a `correlator: none` channel, what does the correlator pair hold?

**Plain terms.** A Robot create goes out on the standard channel, which the descriptor declares
`correlator: none`. Suppose the order carries a per-order SSH key with fingerprint `29:07:2c:…`, as `PRV-32`
describes for the Robot correlator (master does not say a `correlator: none` order must; see below). The order
reply is lost. Engine A wrote that fingerprint into `operations.correlator_value` before
ordering; engine B wrote null. Both cite the text. Under both, `PRV-33` sends the create to an operator. The
difference that reaches a check is later: after the machine is delivered and retention removes the operation row,
`OPS-32`'s key sweep finds the machine through `machines.correlator_value`.

**Verified facts.**

- `PRV-32`: "Until a driver's own channel passes `CNF-180`, it MUST declare no correlator and `PRV-33` governs"
  (02:990-991). `PRV-33`: "The driver declares the absence as that channel's `correlator: none` in the
  descriptor's `ordering_channels`" (02:1053-1054). `PRV-44`: "`correlator: operation_id | per_order_key | none`"
  (02:81).
- `PRV-26`: "Whichever it is, the kind and the value MUST be recorded on the operation row —
  `operations.correlator_kind` and `operations.correlator_value` (`05-persistence.md`) — before the order is sent"
  (02:895-897). It names no channel exception.
- `05-persistence.md`: the `operations` row holds "`ssh_key_fingerprint` on Robot (`PRV-32`)" (05:441), and the
  `machines` row holds the same, "Nullable, for a machine that bore none when adopt returns (`ADR-0020`)" (05:326).
  Neither names a channel.
- `PRV-9`: "For an operation that produced a machine, its `machines.correlator_value` is the operation UUID on
  Hetzner Cloud and DigitalOcean, or its per-order correlator-key fingerprint on Robot" (02:151-152). `CNF-303`:
  "Read the guard through retained `machines.correlator_value`: operation UUID for Cloud and DigitalOcean,
  per-order correlator-key fingerprint for Robot" (10:2936-2938). `machines` has no column naming the operation
  that created it (05:309-341). So the machine pair is the sweep's only link from a retained machine to its
  operation's tagged keys.
- Master does not state whether a Robot order on a `correlator: none` channel carries a generated per-order key.
  `PRV-9` requires "the driver MUST register and attach them as temporary provider-side resources" (02:140-141),
  of keys the order needs; it mentions "a freshly generated rescue/correlator public key" (02:155-156) and "a
  caller key distinct from Robot's correlator key" (02:153) with no channel. `PRV-32`: "making it **unique per
  order** costs nothing" (02:963-964). The bead's "A standard-channel order still carries a per-order key" is
  therefore not stated by master; both forms below state it.
- `OPS-38`: "A create that recorded none has no count: `OPS-27`'s row for "no verified correlator exists for the
  operation's ordering channel" applies, and it is **Unresolved**" (03:709-711). `OPS-27`'s rows include "Exactly
  one resource across every channel" (Resolved-observed) and "no verified correlator exists for the operation's
  ordering channel (`PRV-33`)" (Unresolved) (03:553-556); the table states no precedence between them.
- `CNF-278` repeats its cases on a `correlator: none` descriptor, "making no assertion about the correlator pair on
  the latter" (10:2822-2825). So master leaves the pair open on that channel.
- **Bead claim corrected:** the bead says an engine that recorded the fingerprint "has something to count". On the
  traced lost-reply case, both engines still end Unresolved at an operator (`PRV-33`; `OPS-27`'s channel-keyed
  row). The count difference changes no outcome by itself; the unstated row precedence is what Form K closes.

### Form K (record the fingerprint on every Robot channel)

- `PRV-26`, after "reconciliation would otherwise have nothing durable to search for." (02:898-899) insert:
  "This holds on a channel declared `correlator: none` too, where the value is the per-order key's fingerprint.
  `PRV-33` says of that channel "an ambiguous create on that channel MUST resolve to an operator, never to a
  guess"."
- `PRV-32`, after "it MUST declare no correlator and `PRV-33` governs." (02:991) insert: "That declaration is the
  descriptor's `correlator: none`. The driver still sends a per-order key unique to the order, and `PRV-26` says
  "Whichever it is, the kind and the value MUST be recorded on the operation row"."
- `OPS-38` (03:710): "A create that recorded none has no count:" becomes "A create that recorded none, or whose
  ordering channel is declared `correlator: none` (`PRV-33`), has no count:". The rest of the sentence stays.
- `CNF-278`: "making no assertion about the correlator pair on the latter" becomes "asserting
  `correlator_kind` `ssh_key_fingerprint` and the per-order key's fingerprint on both". New case beside
  `CNF-165`: on a standard-channel (`correlator: none`) descriptor, lose a create's order reply with exactly one
  standard-listing transaction carrying its fingerprint; assert **Unresolved**, operator escalation and no
  automatic attach.
- Unchanged: 05:441, 05:326, `PRV-9`, `CNF-303`, `PRV-33`.

### Form N (null pair on the operation; the machine keeps the fingerprint)

- `PRV-26`, same place (02:898-899) insert: "On a channel declared `correlator: none` (`PRV-33`), both are null. The
  per-order key's fingerprint is kept as the create's correlator in `request_summary` (`05-persistence.md`), as
  operator evidence only."
- `PRV-32`, after "it MUST declare no correlator and `PRV-33` governs." (02:991) insert: "That declaration is the
  descriptor's `correlator: none`. The driver still sends a per-order key unique to the order."
- `05-persistence.md` `operations` row (05:441): "`ssh_key_fingerprint` on Robot (`PRV-32`)" becomes
  "`ssh_key_fingerprint` on a Robot channel declared `per_order_key` (`PRV-32`), and null on a channel declared
  `correlator: none` (`PRV-26`)".
- `05-persistence.md` `machines` row (05:326), append: "On a channel declared `correlator: none` the pair is
  still the per-order key's fingerprint, copied from `request_summary`'s correlator. `PRV-9` reads it: "its
  `machines.correlator_value` is the operation UUID on Hetzner Cloud and DigitalOcean, or its per-order
  correlator-key fingerprint on Robot"."
- `CNF-278`: "making no assertion about the correlator pair on the latter" becomes "asserting a null pair on the
  latter, with the per-order key's fingerprint in `request_summary`". `CNF-303`: run its Robot case on a
  standard-channel (`correlator: none`) descriptor too.
- Unchanged: `OPS-38`, `PRV-33`, `PRV-9`.

### Q2 questions

1. ACCEPT, AMEND or CANNOT ACCEPT on K, and on N. Pick one, or give a third shape as exact text.
2. Trace `CNF-303` for a standard-channel Robot create under each form, after retention removes the operation row.
   Does the sweep keep every tagged key while the machine reads `provisioning`? Under each form, what would the
   machine pair hold if the only key on the order were the caller's?
3. Trace a standard-channel lost reply whose fingerprint matches exactly one standard-listing transaction, under
   each form. Can any conforming engine auto-attach? Under N, does any other consumer of the operation pair
   (05:360's index, `OPS-27`'s search, `OPS-32`) now read a null it did not before?
4. Does either form contradict anything around it at `c5f897c`? A yes needs a quote of each side.

---

## Answer

- **Q1:** F: ACCEPT, AMEND or CANNOT ACCEPT. S: the same. **Pick** (or third shape), with your strongest reason.
  Answers to Q1 questions 2-4, one short paragraph each. **Against my pick (written on request):** at most 60
  words. At most 400 words, not counting replacement text.
- **Q2:** K: ACCEPT, AMEND or CANNOT ACCEPT. N: the same. **Pick** (or third shape), with your strongest reason.
  Answers to Q2 questions 2-4. **Against my pick (written on request):** at most 60 words. At most 400 words, not
  counting replacement text.
- **Brief errors:** each wrong fact, with the grep or quote that shows it.

**Total answer: at most 900 words**, not counting replacement text.
