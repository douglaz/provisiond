# Panel brief r62c: panel B's last open text (pv-ss4, pv-p3k, pv-009, pv-gpw). 2026-10-22

You are one of four independent reviewers. Your working directory is a throwaway clone of `provisiond-spec` at
`07bac41`. Read `AGENTS.md` first.

Rules:
- You MAY edit tracked files in the clone to test a claim. Write nothing outside it. Never commit, push, call a
  provider API, or run `br`.
- `git apply /var/tmp/provisiond-panel-r62c/applied-fable.patch` puts the whole set below into your clone
  (`applied-opus.patch` is the same with stage wording S2). It also carries the already-reviewed panel B text.
- Citation gate alone: `mkdir -p tools/formal/.lake && cp /var/tmp/provisiond-panel-r62c/lake/*.jsonl
  tools/formal/.lake/` (built from 07bac41's Lean tree, which no item touches), then
  `python3 tools/check_citations.py > cit.log 2>&1; echo $?`. Never pipe a gate. Keep `TMPDIR` as set.
- Do not delegate, background or wait on anything. Have a draft by minute 15.

## Settled (not for re-vote)

- Owner, 2026-10-22, verbatim: pv-p3k "MUST, not retryable (Recommended)"; B6 "Yes, any unhealthy
  (Recommended)". So `DOM-16` is a MUST: an `allow_orders: false` account does not declare its ordering
  capabilities, and a create fails `unsupported` naming the account and capability, `retryable: false`.
- Reviewed in r62/r62b and in the patch: `DOM-10`'s `retryable: false`, `API-7` 5d with "1–5d", `PRV-10`,
  `OPS-43` steps 3 and 4, `OPS-23` and `PRV-47`'s present-value sentences, `DOM-16`, `CNF-18`, `WIR-29`'s fixture,
  `WIR-48` (wide).
- pv-ss4's substance (r62, 4-0): `details.field` holds an RFC 6901 pointer; with several rejected fields the least
  escaped pointer by unsigned UTF-16 code units wins; `WIR-2` adopts it.

With every item applied, `check_citations`, `check_ids`, `check_fixtures`, `check_obligations`,
`check_coverage` and `check_regions` exit 0 (both stage wordings). The formal build was not run.

## Items

**(a) pv-ss4.**
- a1. `WIR-9a`'s table gains, after the `offer_not_sellable` row: "| `invalid_request` naming a field (`WIR-2`,
  `OPS-23`, `PRV-47`) | `field`: an RFC 6901 JSON Pointer into the request body (`"/acknowledge_purchase"`,
  `"/provider_options/location"`), also where the named field is absent. Where one validation step rejects several
  fields (an `API-7` step, **STAGE**, or `PRV-47`'s validation), the least escaped pointer, compared by unsigned
  UTF-16 code units, the order RFC 8785 (`WIR-3`) sorts member names in |"
  - **Vote STAGE:** S1 (fable) "the caller-supplied stage of `OPS-43`'s step 3", or S2 (opus) "a stage of
    `OPS-43`'s step 3".
- a2. `WIR-2`'s first sentence becomes astra's r62b text: "**Unknown fields in a request body MUST be rejected**
  with `invalid_request`. The field named in `details.field` MUST be selected under `WIR-9a`, including when the
  same validation step also rejects known fields." Manager's pick over opus's and sol's same-meaning texts: it
  names the key and states the mixed case outright, and keeps the phrase `WIR-47` quotes.
- a3. Stale "first unknown field":
  - `WIR-47` (13:1261): "naming that first unknown field" → "with `details.field: "/operator_ref"` (`WIR-9a`)".
  - `API-40` (04:772): "**naming the first one**" → "**naming a rejected field** in `details.field` (`WIR-9a`)";
    and "`invalid_request` naming no field and giving no token detail" → "`invalid_request` with no
    `details.field` and no token detail".
  - `CNF-233` (10:3397): "assert `invalid_request` names it as the first unknown body field, with no column
    change" → "assert `invalid_request` with `details.field: "/operator_ref"` and no column change".

**(b) `PRV-4` / `DOM-15`** (r62b split 2-2 on the earlier draft).
- `PRV-4` gains (opus's text, carrying fable's "this requirement's second clause"): "An ordering capability that
  `DOM-16` withholds from an account whose `allow_orders` is false is not declared for that account, and a driver
  that implements it breaches neither this requirement's second clause nor `DOM-15`."
- `DOM-15` gains: "An ordering capability withheld under `DOM-16` is excepted from that agreement (`PRV-4`)."
  Opus's form, "`PRV-4` states its exception for …", fails the citation gate as an unquoted attribution, so the
  manager reworded it.

**(c) Conformance, drafted by the manager (no reader has seen them).** Read them in the patched clone:
- c1. `CNF-55` (pv-p3k): kind, details, `retryable`, admission at 5d (after a 5a replay, before the tail), and
  claim at step 3.
- c2. new `CNF-364` after `CNF-19` (pv-009): the step-4 `list_offers` gate at claim.
- c3. `details.field` values in `CNF-34` and `CNF-342`. `CNF-342` also carries pv-gpw's per-writer split, which
  r62b accepted only as a description: a two-value least-pointer case, and a system-written value failing
  `internal`, `retryable: true`.

**(d) Optional.** One `PRV-47` validation can reject a caller value and a system-written value together, and
nothing says whether `invalid_request` or `internal` wins. Say "bead" if it can wait, or give text if it can't.

## Answer

For a1, a2, a3, b, c1, c2, c3: **ACCEPT** or **CANNOT ACCEPT**, plus a reason of one line (at most 25 words). For
CANNOT ACCEPT, give the exact replacement text. Then **STAGE: S1 or S2**, and (d) in one line. Flag any scope
or product call. List wrong facts under "Brief errors", with the grep that shows each one.

**Total: at most 350 words.**
