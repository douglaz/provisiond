**Verdict: ACCEPT** the complete S1–S6 candidate as printed. No AMEND. Three non-blocking objections are recorded below.

## 1. Verdict and arguments

**Strongest argument for.** The six spans now form one closed loop with one owner per rule: `API-7` owns the admission source and the stale refusal (S1), `STO-60` owns publication and ordering (S2), `OPS-51` owns the refresh duty and its credential-stop exception (S3), `OVR-17` and `OVR-19` only register the component and the two parameters (S4, S5), and `CNF-166` demonstrates each stated duty (S6). Admission makes no provider call, so every existing pre-provider property survives: `OPS-35` ("before any driver call", `03:30–33`), `OPS-11`'s admission-only kinds, `CNF-31b`, and the Lean docstring at `Tables.lean:69` all stay true as written. The price risk S1 accepts is bounded by the unchanged claim re-test, which S6's second case exercises with `OPS-43`'s own qualification ("where the provider's price has risen past what the reserve covers"). I found no CNF assertion or Lean theorem flipped, made unreachable or made vacuous, and no MUST with a breaking trace.

**Strongest argument against (written on request, not a vote).** The candidate buys admission latency with a new table, a new periodic engine writer, two parameters, a new 502 at create and a precedence change: an account whose credential is stopped is no longer refreshed, its listing ages out, and a create then gets `provider` 502 instead of the tail's `conflict`/`state` 409 that `CNF-278` and `CNF-307` describe, while `api`-replica catalogue reads become unfenced writers of `offer_listings` under `OPS-50`'s "Writes made in the api process are not checked."

## 2. Interactions across S1–S6

- **Admission snapshot and timing.** S1 reads the stored row "in that snapshot" and judges age "at the admitting transaction", inside the `LDG-35` transaction `04:262–264` names. The refusal is before the tail, commits nothing and writes no receipt, matching `04:287–288` ("A refused tail MUST commit nothing"). No `details.refusals` list is implied, so `WIR-9a`'s create-tail rules are untouched. `WIR-9a`'s per-kind table (`13-wire-contract.md`, rows `insufficient_balance` to `integrity`) has no `provider` row, so the refusal carries no required detail it cannot supply.
- **Credential-stop scope.** S3's exception and S6's two assertions use the same scope ("while ... subject to the authentication stop"). It coheres with `PRV-41`'s terminal stop and `STO-47`'s `credentials_rejected` status. **Objection A (recorded, not gated):** under S1 and S3 together a stopped credential's listing ages past the offer-listing age, after which a create is refused `provider` before the tail rather than `conflict`/`state`. `CNF-278` (`10:2789–2794`) and `CNF-307` stay reachable because a fixture can publish a row and then flip the status inside the age, so this is a precedence change the text does not state, not a flip.
- **Process placement.** S4 keeps "running in the engine process", so the refresh's publication write falls under `OPS-50` ("every component `OVR-17` assigns to the engine"), which the row's bare `See OPS-50` points at. `STO-55` sizes the engine pool "one per periodic component that runs in the engine process (`OVR-17`)" and holds no number, so the added row is absorbed by construction. Nothing in `tools/formal/` enumerates `OVR-17` rows (grep for `OVR-17`, `STO-55`, `account sweep` in `Provisiond/*.lean` returns no hits).
- **Caller-side publication.** `OVR-9` says "`api` MUST NOT depend on `providers`", so a catalogue read on `WIR-30`'s route reaches the driver through the engine trait; STO-60's "Every successful driver List offers read MUST publish" then includes that read and the claim-time read at `OPS-43` step 4. **Objection B (recorded):** the api-process publication is outside `OPS-50`'s fence; STO-60's later-`read_at` rule bounds a superseded replica's write. Consistent, not a loss.
- **Dispatch ordering.** `read_at` is the dispatch instant and replacement requires a strictly later `read_at`, so S6's reverse-completion case has exactly one correct outcome. `OPS-43` step 6 compares against "that same List offers result" taken at claim, not the stored row, so claim publication cannot change the claim's own verdict.
- **Age and interval.** S5 registers the interval as "shorter than the offer-listing age" with startup validation, following the `DOM-8` row's precedent (`01:143` states its own "at least twice"). Here the relation lives only in the register; `OVR-19` owns startup validation, so this is acceptable, but no CNF demonstrates the startup refusal for interval ≥ age. Gap, not a flip.
- **Other checklist cases checked.** `CNF-364` (`10:138–147`), `CNF-55` (`10:345`), the re-derivation item at `10:4303–4310` and the admission case at `10:2150–2152` either operate at claim or admit from a listing that can be the stored one. The allowance item at `10:4035` ("read current overage price with the offer terms") names no live read, so S1 weakens "current" to the stored terms without flipping an assertion. **Objection C (recorded, already in r69):** `01:587` defines `provider` as "Provider returned an error response"; a stale local row is not that. Owner-level wording, not gated.

## 3. S6 as added assertions

Judged as new assertions, not a quotation repair. Each maps to a stated duty and nothing more:

- Stale row → `provider`, `retryable: true`, no provider call: S1's MUST.
- Re-list higher inside the age, row unchanged until admission → admitted at stored price, claim `price_moved`: S1's pricing source plus the surviving `OPS-43` re-test, with the reserve qualification preserved. Realizable: the refresh pass is the only automatic publisher before admission and its interval is deployment-stated, so the witness is reachable and not vacuous.
- No-demand refresh within each interval, except the stopped credential; no scheduled retry: `OPS-51`'s MUST and exception, and `PRV-41`'s existing duty in this context.
- Publication with `read_at` = dispatch instant; reverse order keeps the later row; failed read leaves it unchanged: STO-60's three sentences.

The replaced phrase narrows the never-listed fixture to the one source S1 defines; "every source admission could read" is quoted nowhere else (grep over `*.md`, `*.lean`, `docs/`). No unlisted flip, unreachable witness or vacuous control found. No replacement spans proposed.

## 4. Coverage, run here

Applied all six edits to `scratch/` inside this clone from the brief's text and ran `python3 -I scratch/tools/check_coverage.py` unpiped.

| Measure | Result |
|---|---|
| Exit code | 0 |
| Ratcheted uncovered | 74 |
| Baseline | 74, file byte-identical to base |

My five edited files are byte-identical to the manager's `check/scratch/` copies. Base run for reference also reports 74. I did not run `lake`, the full suite or any other gate.

## 5. Strict quoting and brief errors

All attributions verified with fixed-string grep at `c5f897c`, whitespace-normalized only where wrapped:

- S2 row: `DOM-9` whole sentence, `01:185`, verbatim including its period.
- S2 caller clarification: "The driver's List offers MUST be read-only", `02:123`, inside `PRV-50`'s body; the period sits outside the closing mark, so no omitted continuation is replaced.
- S3: `PRV-41` words at `02:1246–1248` (wrapped; header at `02:1235`), curly marks, period outside the quote. Same disposition.
- S6: `OPS-43` words at `03:865`, inside `OPS-43`'s body (header `03:747`, no other `OPS` header before `03:900`).
- Bare pointers only: `OVR-19`, `PRV-44`, `PRV-13b`, `05-persistence.md`, `OPS-50`, `OPS-51`, `STO-60`, the error taxonomy.
- Gates by reading: `check_obligations.py`'s pattern (backticked id directly followed by MUST) matches nothing new; `check_ids.py` sees `STO-60` after `STO-59` and `OPS-51` after `OPS-50`, each defined once.

Candidate provenance checked against the r69 brief: S1, S3, S4, S5 match lines 108, 122, 124, 126–127 verbatim; S2 is printed S2 plus the two exact repairs; S6 is printed S6 (line 130) plus the archived R4 append (line 270) verbatim. The two source-context excerpts are accurate. No brief error found; premise unchanged. Vocabulary note only: `CONTEXT.md:57` lists "listing" under *Avoid* for **Offer**, but the base already uses "customer offer listing" (`01:187`, `CNF-166`) for the collection, and "authentication stop" has no definition at base. Neither is a quoting defect.

Final: ACCEPT; 74 uncovered / exit 0, baseline 74 unchanged; none
