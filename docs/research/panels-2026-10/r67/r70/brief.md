# Panel E r70: one whole-form S candidate. 2026-10-26

You are one of four independent readers in a fresh throwaway clone of `provisiond-spec` at
`c5f897c32f7894d77a544528872176f241394d0d`. Read `AGENTS.md` first. This is a scoped text and coverage
read: run the coverage check requested below; do not run the full gate suite or `lake`. The manager runs
the required before/after full gates. You may edit a scratch copy inside this clone to apply the candidate.
Write nothing outside this clone; do not commit, push, call a provider API, delegate, background or wait.
Keep TMPDIR as set. Draft by minute 25; keep your answer under about 12 KB.

## Settled direction and scope

The owner's 2026-10-26 ruling, recorded in
`/var/tmp/provisiond-manager/owner-q1-sync-2026-10-23.md`, is:

- Q1 `pv-tcs`: **Stored listing (Recommended)**.
- Q2 `pv-ytv`: **K1–K6 and K-d (Recommended)**, exactly K-d printed in r69's brief at lines 361–362,
  without the later completed-fixture amendment. Q2 needs no further read and is outside this question.

The question is whether the **complete S1–S6 below** can go into the Run under that direction.
It is an **unreviewed combined candidate until this round concludes**. Judge it whole. There is no
request to select the fresh-read alternative or to re-vote Q2. Earlier snippet takes do not approve this
combination. No earlier S-a/b/c/d option or replacement S4 row is imported.

## Outcome and required marks

Give **ACCEPT**, **AMEND**, or **CANNOT ACCEPT** on the whole candidate, not six isolated votes.
Every AMEND must explicitly mark **behaviour unchanged** or **behaviour changed** and give the span id,
the exact text to replace, and its exact replacement. A wording, citation or quotation repair counts as
ACCEPT only after the manager verifies that it changes no behaviour stated by this candidate. Added
conformance assertions, new normative exceptions and changed payload obligations are behavioural changes,
irrespective of the author's mark. A changed, unmarked or failed-check AMEND counts as CANNOT ACCEPT.

A blocking CANNOT ACCEPT needs a loss that changes a checked verdict: a `CNF` assertion or Lean theorem
flipped, made unreachable or made vacuous (name it), or a MUST/SHOULD (file and id) with a trace that breaks
it. An explicitly listed assertion amendment is disclosed, not an omitted loss; identify any additional
flip. Objections without this evidence remain recorded and affect the ACCEPT count, but do not block
under that gate. A strict quotation defect is a wording repair with the owner's verbatim words.

At least three counted ACCEPTs with no verified blocking loss make this exact combined S candidate the
reviewed form for the Run. Otherwise it is not cleared: preserve exact proposed repairs and the dissent,
and report what still needs a scoped repair read or an owner decision. No new manager combination is
treated as reviewed. A verified brief error that changes the premise voids this question's tally only.
The fixed outcome rules are in r70 `notes.md`.

**PR #25 strict quoting rule applies to every proposed word, including your replacements.** A sentence
saying what another requirement does or is carries that requirement's verbatim words; only a bare
`see X` pointer is exempt. No MUST is copied outside the requirement that owns it. Check quotations against
`c5f897c` with fixed-string grep, normalizing whitespace only for wrapped source. Do not repair a quote
by replacing its omitted continuation with a period. In particular any quotation of the proposed
STO-60 publication sentence must include the entire sentence printed in S2. Quotes of proposed text
belong to that proposal; they are not claims that the new text already exists at the base.

## What is assembled and why it is here

- S1 retains the admitting-transaction timing, and S3 retains the printed credential-stop scope.
- S4 retains the explicit engine-process placement. The row that dropped that placement is absent.
- S2 uses the exact common DOM-9 table-row repair, quoting the source sentence rather than making a
  bare attribution; it also inserts the exact caller-clarification sentence supplied in r69.
- S6 appends the exact archived R4 coverage text. This adds conformance assertions; it is not a wording-only
  change. Read its no-demand refresh, stopped-credential, timestamp, publication-order and failed-read
  assertions together with S1–S5, rather than approving it merely because the coverage count passes.

The verified r69 experiment is reused, not re-run: printed S1–S6 had coverage exit 1, 76 ratcheted uncovered
against baseline 74; adding the archived S6 append gave exit 0, 74 uncovered. Source:
`docs/research/panels-2026-10/r67/r69/tally.md`, coverage dissent, and its `tally-evidence/coverage-{printed,with-S6-proposal}.log`
and `.exit` files. The manager separately applies **this exact new combined candidate** and records its
coverage exit/count in r70 `check/coverage.log` and `check/coverage.exit`; that is not evidence of a full
gate pass for the amended specification. The source of the limit is `tools/coverage-baseline.json`.

## Complete S candidate — unreviewed combined candidate

- **S1** `04-api-contract.md`, `API-7`: after «without an extra lock, ceiling slot, write or provider call.» insert:
  > On create, the offers the check reads are the provider account's stored offer listing (`05-persistence.md`, `offer_listings`), read in that snapshot, and the tail prices the commitment and takes the offer snapshot from it. Where no listing is stored, or its `read_at` is older than the stated offer-listing age (`OVR-19`) at the admitting transaction, the create MUST be refused `provider` (`01-domain-model.md`'s error taxonomy) with `retryable: true` before the tail, committing nothing. Every offer-derived input used to size the commitment or populate `request_summary` comes from the named offer in that same stored listing, including recurring price, currency, period, setup fee, `install_strategies`, and any offer-reported billing unit or cancellation bound. Descriptor-declared inputs come from the descriptor the `api` runs with. See `PRV-44`, `PRV-13b` and `05-persistence.md`.

- **S2** `05-persistence.md`, new subsection: before «### `tenants`» insert:
  > ### `offer_listings`
  >
  > **STO-60** `read_at` is the dispatch instant of the successful driver List offers call. Every successful driver List offers read MUST publish its complete result to the account's row, replacing an existing row only when the incoming `read_at` is later. A failed read MUST leave the row unchanged. The read's caller publishes the result, outside the driver read: `PRV-50` says "The driver's List offers MUST be read-only". See `OPS-51`.
  >
  > | Column | Type | Notes |
  > |---|---|---|
  > | `provider_account` | text | primary key |
  > | `read_at` | timestamp | see `STO-60` |
  > | `offers` | json | the driver's List offers result (`DOM-9`: "Prices MUST be carried as strings exactly as the provider returned them.") |

- **S3** `03-operation-lifecycle.md`, new requirement after `OPS-50`: after «its guarantee covers one writable database history.» insert:
  > **OPS-51** A refresh pass MUST read every account declaring `list_offers` at least once per stated offer-listing refresh interval, except while that credential is subject to the authentication stop. `PRV-41` says “A driver MUST therefore treat an `authentication` failure as terminal for that credential, MUST NOT re-attempt it on a schedule, and MUST surface it for an operator”.

- **S4** `00-overview.md`, `OVR-17`'s table: after «| `OPS-32`'s account sweep | `engine` | Lists resources at a provider, so it needs a provider credential |» insert:
  > | Offer-listing refresh (`OPS-51`) | `engine`, running in the engine process | See `OPS-50`. |

- **S5** `00-overview.md`, `OVR-19`'s register: after «| Refresh freshness window | `DOM-8` | finite, positive duration at least twice the account-sweep interval | yes |» insert:
  > | Offer-listing age | `API-7` | finite, positive duration | yes |
  > | Offer-listing refresh interval | `OPS-51` | finite, positive duration, shorter than the offer-listing age | yes |

- **S6** `10-conformance-checklist.md`, `CNF-166`: «absent from every source admission could read» → «absent from the stored offer listing»; and after «Cap and balance do not run; there is no commitment, purchase write or provider order.» insert:
  > Separately let the account's stored listing be older than the offer-listing age: the create is refused `provider`, `retryable: true`, with no provider call. Separately re-list the named offer, inside the age, at a higher price sufficient to exceed what the admitted reserve covers, leaving the stored listing unchanged until admission: the create is admitted at the stored price, and the claim fails `conflict` with `details.reason: "price_moved"` (`OPS-43`: "where the provider's price has risen past what the reserve covers"). With no customer requests, assert each account declaring `list_offers` is read within each stated offer-listing refresh interval, except while its credential is subject to the authentication stop. Assert no scheduled retry for a stopped credential. After successful reads, assert publication of the complete result with `read_at` equal to the dispatch instant. Complete two reads in reverse dispatch order and assert the row retains the later read's `read_at` and offers. Fail a read and assert the existing row is unchanged. See `STO-60` and `OPS-51`.

## Source context for the preserved excerpts

These are source words at `c5f897c`, not further proposed changes. The preserved caller clarification and
credential-stop quotation above remain exactly as prescribed by the scoped-read instruction. For their
complete source sentences, read:

- `PRV-50`, `02-provider-contract.md:123–124`:
  > The driver's List offers MUST be read-only under `PRV-12`'s guarantee: "Get machine MUST be read-only and free of side effects".
- `PRV-41`, `02-provider-contract.md:1246–1248`:
  > A driver MUST therefore treat an `authentication` failure as terminal for that credential, MUST NOT re-attempt it on a schedule, and MUST surface it for an operator (`OPS-26`).

## Answer this whole-form read

1. Start with the whole candidate's ACCEPT / AMEND (with the required mark) / CANNOT ACCEPT, then your
   strongest argument for that verdict. Give the strongest argument against taking this candidate too,
   explicitly labelled as written on request, not another vote.
2. Check interactions across S1–S6: admission snapshot and timing, credential-stop scope, process placement,
   caller-side publication, dispatch ordering, and the stated age/interval. For a gated loss, name the
   assertion/theorem or owner and trace; distinguish an existing limitation from a new loss. Do not
   re-verify mechanics already recorded as verified in r69's tally.
3. **New conformance assertions:** judge the appended S6 text as added assertions, not as a quotation repair.
   Do they demonstrate the proposed duties without silently narrowing or widening the form? Name any
   unlisted assertion flip, unreachable witness or vacuous control. Give exact replacement spans and marks.
4. **Coverage — run it:** apply all of this candidate to a scratch copy in your clone and run
   `python3 tools/check_coverage.py` there, unpiped. Report the actual exit code and ratcheted uncovered count,
   and whether the baseline was unchanged. If you cannot run it, say so explicitly. Never infer a result
   from the manager's or an earlier reader's measurement. No `lake` or full gate suite is needed for this
   scoped check. Do not raise the baseline to make a candidate pass.
5. **Strict quoting:** check all candidate attributions, including the DOM-9 row, the caller clarification,
   S3 and S6. Any replacement you propose must itself meet the strict rule above; include exact owner words
   and source locations, or a bare pointer where that is sufficient. Use the whole STO-60 sentence when
   quoting it. Identify brief errors with evidence, distinguishing a changed premise from a wording defect.

End with `Final: <whole-candidate verdict>; <count/exit from your coverage run>; <remaining exact span ids or none>`.
