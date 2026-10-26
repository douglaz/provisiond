**Vote: ACCEPT.** Coverage on the applied candidate: exit 0, 74 uncovered, baseline 74, baseline file byte-identical. No gated loss found; three strict-quotation repairs supplied below as behaviour-unchanged wording, not conditions of the vote.

## Coverage and application

```
python3 tools/check_coverage.py   (scratch copy fable/scratch-applied, all 14 operations applied)
requirements: 515 | covered by >=1 CNF item: 409 (79%)
uncovered (ratcheted): 74 ... OK: 74 uncovered, at or below baseline 74 (set 2026-10-22)
exit 0
```

Pristine clone: exit 0, 74/74. Application: 13 of 14 operations matched their before-span byte-exactly. S6's first span «absent from every source admission could read» has no exact match at c5f897c because base `10:3695–3696` breaks the line after "source"; it matches once under whitespace normalization, which the r71 tally already recorded. Partial application (S1–S5 only) measures 76 uncovered (`OPS-51`, `STO-60`), so S6's appended assertions are what keep the ratchet green. Extra python gates on the scratch copy: ids exit 0, obligations exit 0; citations needs the Lean index (not run, per brief). No Lean region sits in any edited span (the only marked region is `03:1286–1301`).

## Trace obligations, checked against base

- **D1–D3 (healthy stale, refusals present).** S1's age refusal is conditioned on "If the tail has collected no refusal". Offer, channel, solvency, rate, cap and balance refusals are collected first, so every verdict at `10:1231–1283` is byte-for-byte the base verdict: headline, ordering, entry retryability, skip reasons, hidden-price suppression, no writes, no provider call. The r71 D1–D3 loss is repaired.
- **D4 (`10:1281–1283`).** "omitting the cap leaves balance evaluated and `not_checked: []`" is observable only in a refusal response (`WIR-9a` owns `not_checked` on tail refusals). Any refusal response is age-independent. The all-pass case is an admission, which is D5. No amendment needed; the coordinator's claim holds.
- **D5.** Base `10:1292–1293` admits on retry; a stale listing now refuses `provider`/true with no receipt, so the retry re-evaluates afresh. M1 is the listed fixture. Complete.
- **Unhealthy branches.** An unhealthy account always collects `conflict`/`state`, so the age refusal is unreachable there; stale sellable adds nothing, no row reads empty and adds `offer_not_sellable` (false) exactly as base's "absent from the offers the check reads" clause. Terminated, or recoverable plus absent offer, gives a false envelope under `WIR-9b`. `CNF-278`'s "a create naming it is `409` `state`" (`10:2789–2790`) holds at every age.
- **Healthy no-row.** Empty set → `400`/`offer_not_sellable`/false with skips, matching base's absent-offer predicate; no `502`.
- **Healthy stale, no other refusal.** All priced checks run, then `provider`/`502`/true before any admission write. Equality with the age is "no older than", so no refusal; S1 says "older than" and M1–M7 say "no older than". Consistent.
- **Claim path.** `OPS-43` steps 4–6 still read the provider; S6's `price_moved` case is reachable because admission prices from the stored row and claim from the live read.
- **Lean.** `Admission.lean:803` `refusals_are_within_the_five_kinds` covers `admit` (steps 1–5c) only. `tailAdmitted` (`:1147`) models the tail without listing age; the candidate edits no Lean, so nothing flips, becomes unreachable or vacuous. Record for the Run: `ADR-0025` wants the age gate modelled beside `createPurchaseTail` eventually.

## M1–M7: complete and necessary

Each names a base success assertion a stale otherwise-admissible create would now fail, and qualifies only that assertion: M1 `10:1292` retry admission; M2 `10:1165` EUR create admitted; M3 `10:805` commitment contents (zero-unit control included by "commitment assertions in this item"); M4 `10:3674` one winner; M5 `10:3690` bounded offer admitted; M6 `10:4102` race winner; M7 `10:4108` catalogue admissions. No refusal fixture is narrowed in any of them.

Sweep for omissions: I read every checklist line asserting admission, acceptance, `202`, or an opening commitment on a create. Every remaining case is an already-admitted setup or an existential reach (`CNF-340` "can reach purchase admission", `CNF-206` "not refused `offer_not_sellable`", `CNF-241`/`CNF-356` "admit/accept a create" then post-claim assertions, `CNF-55`/`CNF-364` admit-then-worker-refuses). No unlisted unqualified success assertion found.

Closest calls, which I classify as setups, not flips: `CNF-278`'s second barrier (`10:2796–2799`, "admit a create that passes the health check ... assert the create is refused"), `CNF-307`'s race sentence (`10:1297–1298`), and `CNF-343`'s continuation (`10:4106–4110`: "further creates lose", "assert the exclusion releases", "Race account termination separately"). Each asserts a refusal at a conditional-write barrier, and reaching that barrier is the setup; a stale fixture never satisfies the setup. I read M6's "For this race, each create" as covering the further and post-settlement creates of the same race. The coordinator applied the same criterion (asserted success, not barrier reach) when choosing M6, so the treatment is consistent.

## Strict-quotation repairs (behaviour unchanged, verified byte-exact against owners under whitespace normalization)

**Q1, S2 `STO-60`.** Before: `` `PRV-50` says "The driver's List offers MUST be read-only". `` Replacement:
```text
`PRV-50` says “The driver's List offers MUST be read-only under `PRV-12`'s guarantee: "Get machine MUST be read-only and free of side effects".”.
```
Omitted operative condition: "under `PRV-12`'s guarantee". Curly outer marks keep the inner pair intact for the citation gate, as S3 already does.

**Q2, S6.** Before: `` (`OPS-43`: "where the provider's price has risen past what the reserve covers") `` Replacement:
```text
(`OPS-43`: "fail the operation deterministically — before any provider mutation — where the provider's price has risen past what the reserve covers")
```
This is the span `CNF-248` (`10:3140–3142`) already quotes; the fragment omitted "before any provider mutation".

**Q3, S3, optional.** Before: `` MUST surface it for an operator” `` Replacement: `` MUST surface it for an operator (`OPS-26`).” `` Only the trailing citation was dropped; all operative conditions are present, so this one can be skipped.

The candidate's `DOM-9` and `WIR-30` quotes are whole sentences and verbatim. The current fragments pass the citation gate (coordinator's gate-after exit 0); these are `AGENTS.md` sentence-quoting repairs, reported, not blocking.

## Recorded, non-blocking

- **Kind `provider` for a local stale row.** `DOM-17` row: "Provider returned an error response | 502". No provider was called. Owner-settled; noted only.
- **"refresh" vocabulary.** `CONTEXT.md:387` lists refresh under *Avoid* ("that is `DOM-8`'s read of the provider") and `refresh` is an operation kind in `API-7`'s tail table. S3–S6 and both `OVR-19` rows use "refresh" for the offer-listing sweep. A rename such as "offer-listing sweep" would be wording-only; I do not condition on it.
- **`STO-60`'s writers** are all engine components (`00-overview.md:139`: engine is "the only code that may reach a provider credential"), so `OPS-50`'s generation check covers publication by both the `OPS-51` pass and `OPS-43` step 4. Fable's r71 api-process worry is moot.
- **"authentication stop"** in `OPS-51`/S6 is not a `CONTEXT.md` term; the `PRV-41` quote beside it defines it adequately.
- **No Added-date annotations** on `STO-60`/`OPS-51`, and no ADR. `AGENTS.md`: "Land the rule; write the record after." For the Run.

## Strongest argument (for)

A makes the age refusal strictly last and conditional on an empty refusal list, so every refusal verdict the base states, healthy or unhealthy, at any listing age, is unchanged, including `CNF-278`'s state-first precedence and `CNF-307`'s full combination matrix. The only changed verdicts are otherwise-admissible stale creates, and every base assertion such a create must satisfy is listed in M1–M7. The owner's age setting is retained with a retryable refusal that commits nothing, and the stored-price/claim-price split is now asserted in S6.

## Counterargument, written on request (not a vote)

If the coordinator holds that reaching a conditional-write barrier is an assertion rather than a setup, three spans are omitted flips: `CNF-278` `10:2796–2799`, `CNF-307` `10:1297–1298`, `CNF-343` `10:4106–4110`. Their base outcome is a `409` `state` from the guard; a stale fixture now yields `502` `provider` before the guard. The repair shape would be M6's clause prepended to each ("each create uses a stored listing containing the named sellable offer, with its `read_at` no older than the offer-listing age (`OVR-19`) at the admitting transaction"), behaviour changed. The coordinator's own M6 criterion (asserted winner) argues against this reading, and I do not adopt it.

Final: ACCEPT. Coverage: `python3 tools/check_coverage.py`, exit 0, 74 uncovered, baseline 74 unchanged; application succeeded with one whitespace-normalized before-span (S6, base `10:3695–3696`).
