# r67 tally (panel E: Q1 pv-tcs F/S, Q2 pv-ytv K/N). 2026-10-25

Master `c5f897c`. Rules: r67/notes.md, applied as written. Seats: fable, opus, astra, sol, all exit 0 (06:24-06:32Z).
Every claim below that bears on a verdict was grepped or read with sed at c5f897c (~/projects/provisiond-spec, HEAD
c5f897c, tree clean).

## Outcome: (b) for both questions. One combined confirmation round (r68), then the one owner question

- **Q1:** picks S 3 (fable, astra, sol), F 1 (opus), each with the reader's own amended text. No form carries as
  written: S has two verified gated losses, F has five unlisted flips. Q1 goes to the owner in any case (notes.md
  owner label: cost).
- **Q2:** picks K 4-0 (four different K texts), N 0. K as written is blocked by one verified gated loss (`CNF-278`),
  which all four readers found. Their fixes converge in substance.
- **How rule 1 applies.** No reader marked an AMEND "behaviour unchanged". brief.md never asked them to, so that is
  a brief gap. Applied as written, every AMEND counts as CANNOT ACCEPT with the reader's text as its pick. The lenient
  reading gives the same result, because every picker's amendment edits a bullet of the form's listed behaviour:
  - S: astra and sol add an exception to S's refresh-pass MUST.
  - K: all four edit K's `CNF-278` bullet.

  Under rule 2 (merge the AMENDs, then a confirmation read) or rule 4 (take the best reader form, then a
  confirmation round), the next step is the same: a confirmation round on exact texts. **The outcome does not
  depend on the reading.** For main: the r68 brief must ask readers for the "behaviour unchanged" mark explicitly.
- **No owner-question.md yet.** Outcome (b). The owner question waits for r68.

## Q1 (pv-tcs): F fresh read vs S stored listing

| Reader | F | S | Pick | Strongest argument (theirs) |
|---|---|---|---|---|
| fable | CANNOT ACCEPT | AMEND (counts as CA, rule 1) | S, fable's text | S keeps admission purity true everywhere the set wrote it, and matches `DOM-8`'s "Machine state is a *cache* of provider truth" |
| opus | CANNOT ACCEPT as written (ACCEPT with its spans) | CANNOT ACCEPT as written | **F, opus's text** | F reads the same source claim reads (`OPS-43` step 4), so two conforming engines read the same thing. That closes the bead's A/B split with no table, pass or parameter |
| astra | CANNOT ACCEPT | AMEND (counts as CA) | S, astra's text | F flips the unlisted `CNF-340` and breaks `PRV-40`. The no-call rule protects provider capacity from requests that cannot buy anything |
| sol | CANNOT ACCEPT | AMEND (counts as CA) | S, sol's text | Same as astra. Also, locally rejected purchases stop depending on provider availability |

### Gated losses against F as written (all verified; none is in F's change list)
- **`CNF-340`** (10:4019, 10:4027-4028): "assert the `offer_not_sellable` tail response from `CNF-307`, before any
  provider call or write". Found by all four.
- **`PRV-40`** (02:1210-1212): "refuse subsequent creates on that account and channel before any provider call".
  Found by fable, astra and sol. Fable's point that the read cannot move behind the closure check is verified too:
  03:822-826 puts `offer_not_sellable` before `rate_limited` at admission. 03:276-277 quotes `PRV-40` and would
  drift.
- **`CNF-283`'s second sentence** (10:1893-1894): "Subsequent local refusals make no provider request". Found by
  opus.
- **`DOM-10`** (01:515): "Every operation with a capability MUST be gated on it before the driver is called". Map
  row 01:531 is "list offers | `list_offers`". Found by opus. Its trace is verified: `CNF-364`'s descriptor (10:138-142)
  declares the ordering capability without `list_offers`, so F calls the driver ungated. F's "`provider` or
  `timeout`" also cannot express `unsupported`.
- **`OPS-1`** (03:17-18): "Every mutating request MUST create or return a durable operation record before any
  provider call is made". Found by fable alone. The trace holds: F's own text puts the read "before that transaction
  opens", so it precedes the operation record.

Not gated, but verified:
- `OVR-9` (00:173-174): "`api` MUST NOT depend on `providers` ... MUST reach `engine` only through a trait". F's
  "`api` MUST first obtain" needs that trait. Raised by fable and opus.
- F's kind list is short. `DOM-17` (01:655) lists no kinds. The closed set is 01's error-taxonomy table (01:580-592),
  which also has `network`, `authentication` and `rate_limited`. Raised by fable and sol.

### The lone dissent (opus, F), checked
- Opus's own trace (`DOM-10`) is verified, and its replacement fixes it.
- **Opus's amended F still leaves `PRV-40` and `OPS-1` broken.** Its spans amend `CNF-340`, `CNF-283` and `CNF-166`
  only. Astra's and sol's "if F is chosen" texts fix `PRV-40`. **No reader's text fixes `OPS-1`**, so any wording
  for it would be the manager's and unreviewed.
- Opus's objection to S, "two engines with different refresh timing still admit differently within the age", is
  true by construction. It is not a gated loss. It is the determinism and cost point that notes.md reserves for the
  owner, so relay it as F's strongest argument.
- Opus alone raised this: under S, an account that declares the ordering capability but not `list_offers` never
  gets a listing, so every create on it is refused `provider` with `retryable: true` forever. Today it is admitted
  and fails `unsupported` at claim. No S text addresses it. Not gated (`CNF-364` admits before its restart).
- Citation slip: opus's F text cites `OVR-10a` for the engine trait. `OVR-10a` (00:216) is the single-component
  credentials rule. The trait rule is `OVR-9` (00:173-174).

### Gated losses against S as written (verified)
- **`OVR-17`** (00:269): "Every component that runs without a caller MUST be assigned to a module". 00:312: "MUST
  be extended when a component is added". S's refresh pass has no row. Opus counts it as a loss. Fable, astra and sol
  list it as a gap. All four supply the row.
- **`PRV-41`** (02:1246-1247): "A driver MUST therefore treat an `authentication` failure as terminal for that
  credential, MUST NOT re-attempt it on a schedule". S's "MUST read every account declaring `list_offers` at least
  once per stated ... interval" forces that scheduled retry. Raised by astra and sol. **Fable's S text still carries
  this loss.**

Also verified, against S's `CNF-166` added case. Brief error 5 below starts here.
- S's case asserts that a re-listed higher price is "admitted at the stored price, and `OPS-43`'s claim-time check
  then refuses it". But `OPS-43` refuses only "where the provider's price has risen past what the reserve covers"
  (03:865). Sol alone caught this and gives the fix.

### Q1 sub-answers (relayed, not votes)
- **Q1.2, what no-call protected:**
  - fable: `OPS-1`, `PRV-40`, and the account read budget. Robot `GET /server`, `GET /server/{n}` and cancellation
    "shared the 200/hour account counter". Verified at 08:477-479; fable cites 08:471. The product listing is
    unmeasured.
  - opus: `ADR-0034`'s title, "Tenant traffic cannot spend the provider request budget the system needs". Verified.
    Opus adds that a Robot create costs two listing reads (08:108-109, verified). `SEC-39` bounds the reads per
    principal (Admission.lean:515 "consumes one unit of its budget", verified). Nothing bounds them across
    principals. Opus calls that tolerable in v1 because `ADR-0034` Decision 3 was deferred (Q19, verified).
  - astra and sol: `API-29` is only "SHOULD rate-limit per tenant" (04:1195, verified).
  - On `OPS-50` (03:1984-1996, verified):
    - Opus: the refresh pass assigned to `engine` is fenced by `OPS-50`'s own words, "every component `OVR-17`
      assigns to the engine".
    - Fable, astra and sol: the pass needs the fence once it has an engine row.
    - All four: "Writes made in the api process are not checked".
- **Q1.3:** all four say claim's re-test is enough for safety. Opus adds that matching sources is what closes the
  bead.
- **Q1.4:** all four say neither form leaves a 05:444 field unsourced. Astra and sol want an explicit
  offer-derived-inputs sentence, with descriptor inputs from `PRV-44`.

### Against my pick (written on request; not votes, rule 7)
- fable, against S: S adds a table, a background component, two parameters and a refusal. It admits at a price up to
  one age old, so claim refuses `price_moved` more often.
- opus, against F: F puts a provider round-trip into every synchronous create, refused ones included, which runs
  against `ADR-0034`'s cache direction.
- astra and sol, against S: storage, scheduling and stale-data failures. A customer can be admitted and then refused
  predictably at claim.

## Q2 (pv-ytv): K record fingerprint vs N null pair

| Reader | K | N | Pick | Strongest argument (theirs) |
|---|---|---|---|---|
| fable | AMEND (counts as CA) | CANNOT ACCEPT (`PRV-26`) | K, fable's text | 05:441, 05:326, `PRV-9` and `CNF-303` stay true as written. N splits the operation and machine rows |
| opus | CANNOT ACCEPT as written (`CNF-278`) | CANNOT ACCEPT (`PRV-26`) | K, opus's text | One fact gets one value. Trust lives in the descriptor (`OPS-38`, `PRV-33`) |
| astra | AMEND (counts as CA) | AMEND | K, astra's text | One durable fingerprint across the operation and machine rows |
| sol | AMEND (counts as CA) | AMEND | K, sol's text | One representation, with no automatic eligibility resting on its presence |

### Gated loss against K as written (verified; all four found it)
- **`CNF-278`.** 05:441 says the pair is "Written in `API-63`'s correlator transaction, which is `OPS-43`'s step 8".
  K's replacement asserts the fingerprint "on both" across "the step-8 barriers and account-read cases"
  (10:2821-2824). The account-read cases fail at step 1 (10:2813-2817). The barrier cases terminate "before step 8
  commits" (10:2818). So every conforming build fails the amended item, on the auction descriptor too.
- Fixes, converged in substance: a null pair where step 8 did not commit, and the fingerprint where it did. Texts:
  - fable: "null on both before step 8 commits ... fingerprint on both after it"
  - opus: "where step 8 committed ... null pair on both where it did not"
  - astra: "null ... before any successful step-8 commit ... after that commit, on both Robot descriptors"
  - sol: "where the step-8 transaction committed, and a null pair before any step-8 transaction committed"

### Gated loss against N (verified)
- **`PRV-26`** (02:895-897): "Whichever it is, the kind and the value MUST be recorded on the operation row". N
  writes null on the row while its own `PRV-32` insert makes the per-order artifact exist. Found by fable and opus.
- Astra and sol flag N's "operator evidence only" as clashing with its own copy into the machine for the sweep.
  Fable and opus add that N names no time at which the `request_summary` fingerprint is written.

### Disputed points for r68 (stated neutrally)
- **`PRV-32` "MUST" on generating the per-order key.**
  - Opus, astra and sol: yes. K's "still sends" is not a MUST.
  - Fable: K's per-order key already excludes a caller-only order.
- **Caller-key-only trace.**
  - Fable: the pair would hold the caller key's fingerprint, which `PRV-26` forbids (02:899-900 "anything else
    linkable to a").
  - Opus: the pair would be null, so after retention the sweep deletes the caller key while the machine reads
    `provisioning`. That breaks `PRV-9`'s "only when ... no machine that operation produced still reads
    `provisioning`" (02:141-143, verified).
  - Both traces end at the same fix, the MUST.
- **Robot scope of K's `PRV-26` insert:** astra and sol.
- **`PRV-32` lead-in.** K's "That declaration is the descriptor's `correlator: none`" restates `PRV-33` without
  quoting it, which breaks the AGENTS.md quoting rule. Opus raised this and gives a verbatim-quote text.
- **Extra cases:**
  - Opus: after `OPS-33`'s window releases, there is no automatic attach by `OPS-32`. 03:1697: "an **operator**
    search, not an automatic", verified.
  - Sol: run `CNF-303` on the standard-channel descriptor under K too.

### Q2 sub-answers (relayed)
- Q2.2: all four say the sweep keeps every tagged key under either form. `PRV-9` 02:154 says "the same eligibility",
  verified.
- Q2.3: all four say no conforming engine auto-attaches. `PRV-33` 02:1055-1056: "MUST be an operator action",
  verified.
- Q2.4: N contradicts `PRV-26` (fable, opus). For K, only the `CNF-278` loss.

### Against my pick (written on request; not votes)
All four say the same thing, against K: a non-null pair on a channel declared `correlator: none` can tempt a
consumer into treating it as auto-attach authority. Opus names `OPS-33`'s continued search and `OPS-36`. N's null
rules that mistake out.

## What r68 reads (one round, all four readers, both questions; ACCEPT / AMEND marked "behaviour unchanged" / CANNOT ACCEPT)

None of these exact texts has been read whole. Each is unreviewed until r68.
- **Q1, S-final: sol's S text verbatim.** It covers astra's deltas in substance:
  - the `PRV-41` exception;
  - `read_at` semantics;
  - the `OVR-17` row;
  - the `OVR-19` rows;
  - the offer-derived-inputs sentence.

  It also alone fixes the `CNF-166` price case. Fable's text carries the `PRV-41` loss.

  Deltas to state neutrally:
  - fable's numbered step 5e. 04:291: "Steps 1–5d still stop at their first refusal".
  - opus's `unsupported` refusal for an account without `list_offers`. No reader text exists for it.
- **Q1, F-final: opus's F text plus astra's or sol's `PRV-40` span.** Read it now because the owner may pick F.
  Correct opus's `OVR-10a` citation to `OVR-9`. Flag **`OPS-1` (03:17-18)** as broken with no reader text: either
  the brief carries a manager-worded span marked unreviewed, or the readers are asked for one.
- **Q2, K-final: one of opus's, astra's or sol's K texts, each of which has the MUST. Suggested: sol's**, which has
  the Robot scope, the MUST, the `CNF-278` fix and `CNF-303` on the standard channel. Deltas:
  - opus's verbatim `PRV-33` lead-in;
  - opus's `OPS-33`-window case.
- **Rule 5 watch:** if a clause draws non-converging AMENDs again in r68, it is deleted, not reworded.
- **After r68:** the one two-part owner question per notes.md. Q1 is F-final vs S-final, with the panel's pick and
  the cost points above. Q2 is "apply K-final?".

## Brief errors (none voids a question under rule 6)

1. **The "Four `CNF` assertions" inventory undercounts.** It misses:
   - `CNF-340` (10:4028);
   - `CNF-283`'s second sentence (10:1893-1894);
   - `PRV-40` (02:1211) and `OPS-1` (03:17-18), from F's change list.

   All verified. Found by all four (`CNF-340`), opus (`CNF-283`), fable, astra and sol (`PRV-40`), and fable
   (`OPS-1`). **It does not void Q1.** It undercounts F's cost and leaves its premise ("F deletes the rule that an
   admission refusal makes no provider call") true. Every reader corrected it before voting. **The F CANNOT ACCEPT
   votes rest on the corrected fact:** a corrected F that lists these would clear the gate (pre-registered rule 3).
   That is why r68 reads a corrected F-final, not S alone. If main reads rule 6 as voiding Q1, the action is the
   same: re-ask Q1 with both forms corrected.
2. **04:306-307 is not `API-7`'s normative text.** It sits in the italic "*Amended 2026-10-09 (`ADR-0039` ...)*"
   record (04:304-308). The normative 04:287-288 says "A refused tail MUST commit nothing and write no `STO-35`
   receipt". Verified (opus). The no-call rule survives at 04:262-264, so this changes no premise. F-final must not
   edit an amendment record.
3. **`DOM-17` cited as the source of kinds.** It lists none (01:655). The table is at 01:580-592. Verified (fable,
   sol).
4. **"05:360's index" is not a consumer of the operation pair.** It sits under `### machines` (05:307; the index is
   at 05:360). Verified (all four). It was in a question, not a form, and it cuts toward N. No vote rests on it.
5. **The plain-terms story overstates `OPS-43`.** It says "stops a risen price", but `OPS-43` refuses only "past what
   the reserve covers" (03:865). Verified (sol). No wrong purchase follows. It breaks S's `CNF-166` case (above). No
   vote rests on it.
6. **"The machine pair is the sweep's only link" is too strong.** `machines.first_unit_debit_id` (05:329) references
   `ledger_entries`, which carries `operation_id` (05:635; `LDG-6` 12:107-108 "the ids of whatever caused it").
   Verified (sol). Not premise-changing: `PRV-9` (02:151-152) and `CNF-303` read the guard through
   `machines.correlator_value` anyway.
7. **The brief never asked for the rule-1 "behaviour unchanged" mark** (above).
