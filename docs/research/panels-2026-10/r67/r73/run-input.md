# Panel E r73 — exact Run input, not a Run launch

Base: `c5f897c32f7894d77a544528872176f241394d0d`. Selection: Form H, reviewed whole by all four r73 readers; H ACCEPT 4/4, U ACCEPT 0/4. Rules: r73 notes.md. The owner-approved Q2 text is the r69 K1–K6 plus the original K-d printed at r69 brief.md:361–362. No Q2 re-vote.

## Decisions — verbatim record excerpts

Source: `/var/tmp/provisiond-manager/owner-q1-sync-2026-10-23.md`. The r69 ruling and subsequent main decisions below are literal excerpts, with historical next-step references retained as printed.

```text
## Panel E r69 owner ruling (2026-10-26)
- Q1 pv-tcs offer check at create: owner chose "Stored listing (Recommended)" (S; panel pick 4/4; printed S 2 ACCEPT / 2 CA, coverage 74→76 and fable's S4 dropping "running in the engine process"). Next: complete S1–S6 candidate per r69 tally.md "If S is selected" → one whole-form read (r70) → rloop.
- Q2 pv-ytv fingerprint: owner chose "K1–K6 and K-d (Recommended)" (K ACCEPT 4/4; K-d as printed 3 unconditional takes; opus's completed-fixture AMEND does not ride). No further read; goes into the Run.
- Source: /var/tmp/provisiond-panel-r69/{tally.md,owner-question.md}.
```


```text
## Panel E r70 precedence question (2026-10-26, settled by main from the recorded spec)
- r70: S1–S6 combined 2 ACCEPT (fable, astra) / 2 CA (opus, sol); both dissents = same verified defect: S1's stale/absent-listing 502 (retryable) refusal precedes the unhealthy-account 409 state tail, flipping CNF-278 and CNF-307 (terminated → retryable true). Inherited from printed S1, absent at c5f897c.
- Settled: PRESERVE the unhealthy-account response first. Source: c5f897c CNF-278 (10:2789–2792) "a create naming it is `409` `state`" / "Assert the refusal on all three unhealthy statuses"; CNF-307 (10:1225–1226) "termination makes the envelope `retryable: false`"; the owner's S ruling did not ask to change them; no reader argued freshness-first on merit (sol's S7 conditional, unendorsed). Owner may overrule.
- Next: r71 whole-form read of opus's S1/S6 preservation repair + coordinator text for the unhealthy-account offer check.
```


```text
## Panel E r71 → r72 (2026-10-26, settled by main; owner may overrule)
- r71: raw 2 ACCEPT (fable, opus) / 2 CA (astra, sol); the unhealthy-account repair works; both CAs verified the same inherited defect on HEALTHY accounts (stale-listing refusal pre-empts the tail: CNF-307 refusal combinations and success controls flip). The tally's VOID came from main's prompt wording ("a verified brief error voids the tally"), not notes rule 6 (omitted CNF-307 10:1285–1300 excerpt).
- Main's r71 target ("every CNF-278/CNF-307 verdict unchanged") was over-strict; replaced by: (1) refusals never hidden by age; (2) one new refusal: otherwise-admissible create with a stale listing → provider/retryable (owner's age setting); (3) success assertions changed by (2) get listed fresh-listing fixture amendments.
- Astra's no-age-refusal form dropped: contradicts the owner's S choice ("an age setting"; r69 owner-question.md:7 "Missing or stale data refuses the create").
- r72 reads sol's A/B (age check after tail collection) + coordinator-listed fixture amendments.
```


```text
## Panel E r72 → r73 (2026-10-26, main)
- r72: 1 ACCEPT (fable) / 3 CA (opus AMEND-bc, astra, sol); valid. Design holds; every blocker = another success item missing its fresh-listing condition (CNF-99, CNF-299, CNF-243; CNF-343 continued race).
- Main's direction: stop enumerating. Form H = one checklist header default ("Stored offer listings in the items below", styled like the existing "Seeds in the items below" ADR-0033 paragraph) replacing per-item M amendments; Form U (r72 next-read-candidate, per-item union) read alongside as fallback.
```


## pv-tcs — exact reviewed Form H operations, file by file

Source: r73 brief.md Form H and check/printed-forms.json, verified against parts/H.json. Each before span is the literal base substring at the stated zero-based Python character offsets [start,end). For an insertion, the after span retains that anchor and includes the reviewed text, with the preparation joiner. Apply descending offsets within a file. The after text reproduces check/H exactly; all reviewed words and Markdown are retained.

No new wording repair rides. Q1–Q3 are already integrated in the reviewed S2/S3/S6 text. Keep the reviewed header and exact M8; the H selection drops the U-only per-item fixture spans.

### 00-overview.md

#### S4 — after; base [21295,21401)

Before:

```text
| `OPS-32`'s account sweep | `engine` | Lists resources at a provider, so it needs a provider credential |
```


After:

```text
| `OPS-32`'s account sweep | `engine` | Lists resources at a provider, so it needs a provider credential |
| Offer-listing refresh (`OPS-51`) | `engine`, running in the engine process | See `OPS-50`. |
```


#### S5 — after; base [29073,29187)

Before:

```text
| Refresh freshness window | `DOM-8` | finite, positive duration at least twice the account-sweep interval | yes |
```


After:

```text
| Refresh freshness window | `DOM-8` | finite, positive duration at least twice the account-sweep interval | yes |
| Offer-listing age | `API-7` | finite, positive duration | yes |
| Offer-listing refresh interval | `OPS-51` | finite, positive duration, shorter than the offer-listing age | yes |
```


### 03-operation-lifecycle.md

#### S3 — after; base [169684,169735)

Before:

```text
its guarantee covers one writable database history.
```


After:

```text
its guarantee covers one writable database history.

**OPS-51** A refresh pass MUST read every account declaring `list_offers` at least once per stated offer-listing refresh interval, except while that credential is subject to the authentication stop. `PRV-41` says “A driver MUST therefore treat an `authentication` failure as terminal for that credential, MUST NOT re-attempt it on a schedule, and MUST surface it for an operator (`OPS-26`).”
```


### 04-api-contract.md

#### S1 — after; base [22918,22978)

Before:

```text
without an extra lock, ceiling slot, write or provider call.
```


After:

```text
without an extra lock, ceiling slot, write or provider call. On create, the offers the check reads are the provider account's stored offer listing (`05-persistence.md`, `offer_listings`), read in that snapshot, and the tail prices the commitment and takes the offer snapshot from it. On create, the tail reads the stored listing regardless of age, or an empty offers set if no listing is stored. If the tail has collected no refusal and the stored listing has a `read_at` older than the stated offer-listing age (`OVR-19`) at the admitting transaction, the create MUST be refused `provider` (`01-domain-model.md`'s error taxonomy) with `retryable: true` before any admission write, committing nothing. Every offer-derived input used to size the commitment or populate `request_summary` comes from the named offer in that same stored listing, including recurring price, currency, period, setup fee, `install_strategies`, and any offer-reported billing unit or cancellation bound. Descriptor-declared inputs come from the descriptor the `api` runs with. See `PRV-44`, `PRV-13b` and `05-persistence.md`.
```


### 05-persistence.md

#### S2 — before; base [59289,59302)

Before:

```text
### `tenants`
```


After:

```text
### `offer_listings`

**STO-60** `read_at` is the dispatch instant of the successful driver List offers call. Every successful driver List offers read MUST publish its complete result to the account's row, replacing an existing row only when the incoming `read_at` is later. A failed read MUST leave the row unchanged. The read's caller publishes the result, outside the driver read: `PRV-50` says “The driver's List offers MUST be read-only under `PRV-12`'s guarantee: "Get machine MUST be read-only and free of side effects".” See `OPS-51`.

| Column | Type | Notes |
|---|---|---|
| `provider_account` | text | primary key |
| `read_at` | timestamp | see `STO-60` |
| `offers` | json | the driver's List offers result (`DOM-9`: "Prices MUST be carried as strings exactly as the provider returned them.") |

### `tenants`
```


### 10-conformance-checklist.md

#### H — before; base [2072,2089)

Before:

```text
## Build and gate
```


After:

```text
**Stored offer listings in the items below** (2026-10-26): An item that asserts or relies on a create being admitted or succeeding, including a create used to show a release, without specifying the stored listing's age, runs on a stored listing that contains the named offer and has a `read_at` no older than the stated offer-listing age at the admitting transaction (see `OVR-19`). This default qualifies only the admission or success assertion and any create used to reach it; an item asserting a refusal without specifying the stored listing's age asserts it whatever that age. For the stale-listing refusal case, see `CNF-166`.

## Build and gate
```


#### S6 — replace; base [328018,328069)

Before:

```text
absent from every source
      admission could read
```


After:

```text
absent from the stored offer listing
```


#### S6 — after; base [328330,328415)

Before:

```text
Cap and balance do not run; there is no commitment, purchase write or provider order.
```


After:

```text
Cap and balance do not run; there is no commitment, purchase write or provider order. Separately let a `healthy` account's stored listing contain the named sellable offer and be older than the offer-listing age, with no other refusal condition: the create is refused `provider`, `retryable: true`, after tail collection and before any admission write, with no provider call. Separately re-list the named offer, inside the age, at a higher price sufficient to exceed what the admitted reserve covers, leaving the stored listing unchanged until admission: the create is admitted at the stored price, and the claim fails `conflict` with `details.reason: "price_moved"` (`OPS-43`: “After the sale re-test passes, and before any per-order key upload or other provider mutation, the worker MUST re-read the offer's current price from that same List offers result **in the provider's own currency** and compare it with the native price the commitment was sized from — **carried on the operation's `request_summary`, which MUST hold the accepted recurring price, its currency and its period, and the accepted setup fee and prepaid first unit, the unit with its `billing_unit.seconds`** (`LDG-2`, `LDG-67`; *the unit and its seconds added 2026-10-08, `ADR-0033`, because the machine's row copies the seconds for its first seed, `LDG-38`, `05-persistence.md`*; *the fields are named so a worker restarted before claim can perform this comparison at all*; *named 2026-09-05 — a first form cited a native figure on the commitment row, which carries only `reserved_sats`*) — and **fail the operation deterministically — before any provider mutation — where the provider's price has risen past what the reserve covers**: `conflict`, `details.reason: "price_moved"`, the shortfall in `details`, telling the caller to re-submit, and `retryable: true` on both the error and the operation view (`WIR-9b`).”). With no customer requests, assert each account declaring `list_offers` is read within each stated offer-listing refresh interval, except while its credential is subject to the authentication stop. Assert no scheduled retry for a stopped credential. After successful reads, assert publication of the complete result with `read_at` equal to the dispatch instant. Complete two reads in reverse dispatch order and assert the row retains the later read's `read_at` and offers. Fail a read and assert the existing row is unchanged. See `STO-60` and `OPS-51`.
```


#### M8 — replace; base [362592,362774)

Before:

```text
Kill the winner after step 8 commits and keep it unresolved across engine restart and assert further
      creates lose on every replica; settle it and assert the exclusion releases.
```


After:

```text
Kill the winner after step 8 commits and keep it unresolved across engine restart and assert further creates lose on every replica; settle it and assert the exclusion releases. Each of these further creates, including any create used to show the release, uses a stored listing containing the named sellable offer, with its `read_at` no older than the offer-listing age (`OVR-19`) at the admitting transaction.
```


## pv-ytv — exact owner-approved printed instructions

The following is copied literally from r69 brief.md:333–344, followed by the original K-d at 361–362. Historical author and coordinator annotations are retained; they are not additional specification text.

```markdown
- **K1** `02-provider-contract.md`, `PRV-26`: after «reconciliation would otherwise have nothing durable to search for.» insert:
  > For Robot, this recording obligation applies on every ordering channel, including one declared `correlator: none`: the kind is `ssh_key_fingerprint` and the value is the per-order key's fingerprint. See `PRV-33`.
- **K2** `02-provider-contract.md`, `PRV-32`: after «it MUST declare no correlator and `PRV-33` governs.» insert:
  > On every Robot ordering channel, including one declared `correlator: none`, the driver MUST generate a throwaway key unique to that order, and the order MUST name it in `authorized_key[]` beside the caller's keys (`08-provider-notes.md`: "`authorized_key[]` supplies fingerprints to orders"). See `PRV-9`, `PRV-26` and `PRV-33`.

- **K3** `03-operation-lifecycle.md`, `OPS-38`: «A create that recorded none has no count:» → «A create that recorded none, or whose ordering channel is declared `correlator: none` (see `PRV-33`), has no count:» (r67 K; the rest of the sentence stays). [coordinator: r67 K's "(`PRV-33`)" becomes the bare pointer "(see `PRV-33`)".]
- **K4** `10-conformance-checklist.md`, `CNF-278`: «making no assertion about the correlator pair on the latter» → «asserting, where step 8 committed, `correlator_kind` `ssh_key_fingerprint` and the per-order key's fingerprint on both, and a null pair on both where it did not»
- **K5** `10-conformance-checklist.md`, new item after `CNF-165`: after «and why the others are believed spurious. (`OPS-38`, `OPS-31`)» insert:
  > - [ ] **CNF-371** — On a standard-channel (`correlator: none`) descriptor, lose a create's order reply with exactly one standard-listing transaction carrying its fingerprint; assert **Unresolved**, operator escalation and no automatic attach. (`OPS-38`, `PRV-33`, `OPS-27`)

- **K6** `10-conformance-checklist.md`, `CNF-303` (Reader 4): after «per-order correlator-key fingerprint for Robot.» insert:
  > Run this Robot case on a standard-channel (`correlator: none`) descriptor too, settling the create through the operator's attach (`PRV-33`: "attaching a discovered machine to a tenant MUST be an operator action").
```

```markdown
- **K-d (Reader 2): the window's end.** In K5, before the cite list, add:
  > After the negative window releases the commitment, assert still no automatic attach (`OPS-33`: "the search it bounds is an **operator** search, not an automatic one").
```

## pv-ytv — file-by-file before/after application

These spans apply only those printed instructions to the base. The K5 after span inserts the original K-d immediately before its cite list, exactly where the printed instruction places it. No completed/in-progress-fixture amendment is added. Paragraph separators are mechanical joiners; all operative words match the printed instructions.

### 02-provider-contract.md

#### K1 — after; base [69314,69382)

Before:

```text
reconciliation would
  otherwise have nothing durable to search for.
```


After:

```text
reconciliation would
  otherwise have nothing durable to search for.

For Robot, this recording obligation applies on every ordering channel, including one declared `correlator: none`: the kind is `ssh_key_fingerprint` and the value is the per-order key's fingerprint. See `PRV-33`.
```


#### K2 — after; base [76290,76341)

Before:

```text
it MUST declare no correlator and `PRV-33`
governs.
```


After:

```text
it MUST declare no correlator and `PRV-33`
governs.

On every Robot ordering channel, including one declared `correlator: none`, the driver MUST generate a throwaway key unique to that order, and the order MUST name it in `authorized_key[]` beside the caller's keys (`08-provider-notes.md`: "`authorized_key[]` supplies fingerprints to orders"). See `PRV-9`, `PRV-26` and `PRV-33`.
```


### 03-operation-lifecycle.md

#### K3 — replace; base [59082,59123)

Before:

```text
A create that recorded none has no count:
```


After:

```text
A create that recorded none, or whose ordering channel is declared `correlator: none` (see `PRV-33`), has no count:
```


### 10-conformance-checklist.md

#### K4 — replace; base [251518,251583)

Before:

```text
making no assertion about the
      correlator pair on the latter
```


After:

```text
asserting, where step 8 committed, `correlator_kind` `ssh_key_fingerprint` and the per-order key's fingerprint on both, and a null pair on both where it did not
```


#### K6 — after; base [261875,261928)

Before:

```text
per-order correlator-key
      fingerprint for Robot.
```


After:

```text
per-order correlator-key
      fingerprint for Robot. Run this Robot case on a standard-channel (`correlator: none`) descriptor too, settling the create through the operator's attach (`PRV-33`: "attaching a discovered machine to a tenant MUST be an operator action").
```


#### K5 + original K-d — after; base [326865,326927)

Before:

```text
and why the others are believed spurious. (`OPS-38`, `OPS-31`)
```


After:

```text
and why the others are believed spurious. (`OPS-38`, `OPS-31`)

- [ ] **CNF-371** — On a standard-channel (`correlator: none`) descriptor, lose a create's order reply with exactly one standard-listing transaction carrying its fingerprint; assert **Unresolved**, operator escalation and no automatic attach. After the negative window releases the commitment, assert still no automatic attach (`OPS-33`: "the search it bounds is an **operator** search, not an automatic one"). (`OPS-38`, `PRV-33`, `OPS-27`)
```


## Reading notes and acceptance checks

These are tally verification notes, not replacement specification wording. The header is read per asserted create/admission: its “asserts or relies on” includes an earlier admitted setup. An explicitly stale case elsewhere in the same item does not disable that default for another create. The later refusal retains its own conditions. M8 explicitly conditions its further guard probes; an age refusal alone is not guard evidence. Fable’s same-instant claim for racing snapshots is not assumed.

The Run must preserve every reviewed span above and check the added lines under AGENTS.md’s strict quotation and ownership rules. Do not silently narrow a theorem to make a proof pass; consult AGENTS.md and ADR-0025 for any required formal work. Run `nix develop --command bash tools/check-all.sh` unpiped before work and before reporting completion, with the full required toolchain. Coverage is reported separately from the panel’s rule-3 gate.

Verification receipts: tally-evidence/locations.json, coverage.json, projection-audit.json, run-input-verification.json; full tally in tally.md. This file authorizes no launch by the tally manager.
