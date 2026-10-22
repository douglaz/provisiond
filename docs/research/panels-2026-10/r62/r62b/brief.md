# Panel brief r62b: reviewed text for panel B (pv-p3k, pv-009, pv-gpw, pv-ss4, pv-7j3). 2026-10-22

You are one of four independent reviewers. Your working directory is a throwaway clone of `provisiond-spec` at
`07bac41`. Read `AGENTS.md` first.

Rules:
- You MAY edit tracked files in the clone to test a claim. Write nothing outside it. Never commit, push or call a
  provider API.
- Gates are optional. If you run them, run `nix develop --command bash tools/check-all.sh` unpiped, redirected to a
  file in the clone, and read the exit code. Keep `TMPDIR` as set.
- Do not delegate, background or wait on anything.
- Have a draft by minute 15.

## Context: round r62's outcome

- **Settled.** pv-7j3's reason is `state` (4-0). These are 4-0 in substance:
  - Q1: `unsupported` naming the account and the ordering capability, `retryable: false`, after `API-7`'s 5c, not
    collected.
  - Q2: the claim-time `list_offers` gate is `retryable: false`.
  - Q3: a value the system wrote that fails validation is `internal`.
  - Q4: `details.field` holds an RFC 6901 pointer, and the least pointer by UTF-16 code units wins.
- **Not on the table.** `DOM-16`'s SHOULD→MUST is the owner's call. B1–B3 ask only: *if the owner takes the MUST,
  is this the text?*
- **Two premises from r62 were wrong.**
  - The Q3 strawman's `retryable: false` for `internal` contradicts `OPS-11`'s create row: "For `network`,
    `timeout`, `internal`, … it MUST carry `retryable: true` on both the error and the operation view" before step 9.
  - One r62 answer rewrote `PRV-47`'s caller-supplied sentence, which is fixed text. It stays verbatim.
- **Verified in r62.**
  - Draft A breaks `PRV-4` ("MUST NOT implement one whose capability it does not declare") and `CNF-18` on an
    `allow_orders: false` account.
  - `OPS-43`'s step 3 has no internal order.
  - `PRV-44` has no `allow_orders` field, yet `WIR-29`'s fixture renders one and says "nothing here is declared
    anywhere else".

The texts below are the manager's merge of the r62 amendments. No one has reviewed them.

## Items

**B1. Declaring (`DOM-16`, `PRV-4`, `CNF-18`, `WIR-29`).**
- `DOM-16` becomes: "Ordering capabilities (`provision_virtual`, `provision_bare_metal`) for providers that bill
  per order MUST be conditional on an explicit per-account `allow_orders` configuration flag: the descriptor
  (`PRV-44`) of an account whose flag is false does not declare them, so that a misconfigured deployment cannot
  spend money. This is in addition to, not instead of, the per-request purchase acknowledgement (`API-15`)."
- `PRV-4` gains: "An ordering capability that `DOM-16` withholds from an account whose `allow_orders` is false is
  not declared for that account, and a driver that implements it does not breach the second clause there."
- `CNF-18` gains: "An ordering capability withheld under `DOM-16` is outside the implemented-implies-declared rows
  for that account; `CNF-19` covers its gate."
- `WIR-29`'s fixture drops `"allow_orders": true,`. The account's `capabilities` now carry the flag.

**B2. Error and admission position (`DOM-10`, `API-7`, `PRV-10`).**
- `DOM-10`: after "naming the provider account and the capability", add ", with `retryable: false` on both the
  error and the operation view where there is one". This is the one home for every capability-gate failure,
  including Q2's.
- `API-7` gains, after 5c: "5d. **gate a create on its ordering capability** under `DOM-10` (`PRV-10`,
  `DOM-16`). A refusal stops here and is not collected by the tail."
- `PRV-10` gains: "The configuration half is `DOM-10`'s gate on the create's ordering capability (`DOM-16`):
  `API-7`'s step 5d at admission and `OPS-43`'s step 3 at claim."

**B3. Claim order (`OPS-43` steps 3 and 4).**
- Step 3 becomes: "3. Repeat boundary validation under `OPS-23`: "Validation that was performed at the API
  boundary MUST be repeated in the worker before the driver is called". This includes `PRV-10`'s "explicit
  purchase acknowledgement", `PRV-8`'s "at least one SSH public key", the missing-field checks defined in
  `OPS-23`, and `DOM-10`'s gate on the create's ordering capability, which is `PRV-10`'s "the account is
  configured to allow ordering". The checks on caller-supplied fields run first, then the checks on fields the
  `api` wrote at admission, then the capability gate."
- Step 4 becomes: "4. Gate on `list_offers` under `DOM-10`, then obtain the current driver List offers result."
  r62 voted 3-1 for this over adding the gate to step 3. One r62 reader put the step-3 gate first; three put it
  last.

**B4. Present values (`OPS-23`, `PRV-47`, `CNF-342`).**
- `OPS-23` gains, after its two bullets: "A field that is present but fails this repeated validation fails as its
  writer's bullet above says, on both the error and the operation view, and settles as these missing-field
  failures do."
- `PRV-47` keeps its caller sentence verbatim and gains after it: "A value this system wrote rather than the
  caller, such as `PRV-9`'s operation id as a temporary key's "provider-side name or tag" or `PRV-32`'s per-order
  throwaway SSH key, that this validation rejects fails `internal` (`DOM-17`: "Defect in this system"); `OPS-11`'s
  create row gives its `retryable`."
- `CNF-342` asserts per writer:
  - a caller-supplied value fails `invalid_request` naming the field, with `retryable: false`;
  - a system-written value fails `internal`, with `retryable: true`.

The engine sentence sits in `PRV-47` only, so it covers create only: a system-written value meets validation only
at step 7. r62 voted 3-1 for `true`, and the r62 reader who voted `false` also made an api-written present value
`internal`. Accept `true` and this split, or object with text.

**B5. Wire form (`WIR-9a`, `WIR-2`).**
- `WIR-9a`'s table gains a row: "| `invalid_request` naming a field (`WIR-2`, `OPS-23`, `PRV-47`) | `field`: an RFC
  6901 JSON Pointer into the request body (`"/acknowledge_purchase"`, `"/provider_options/location"`), also where
  the named field is absent. Where one validation step rejects several fields (an `API-7` step, one of the three
  stages of `OPS-43`'s step 3, or `PRV-47`'s validation), the least escaped pointer, compared by unsigned UTF-16
  code units, the order RFC 8785 (`WIR-3`) sorts member names in |"
- In `WIR-2`, "naming the first unknown field" becomes "naming the unknown field with the least pointer in
  `WIR-9a`'s order".

**B6 (optional; one r62 reader's add-on).** `WIR-48`'s last sentence becomes: "Assigning a tenant to an account
whose `STO-47` status is anything but `healthy` is also `conflict` with `details.reason: "state"` (`STO-36`) —
the failure this verb exists to repair should not be reachable by using it." `STO-36` already forbids writing that
row.

## Answer

For each of B1–B6, write **ACCEPT** or **CANNOT ACCEPT**.
- For CANNOT ACCEPT: name the part, say why in at most 40 words, and give the exact replacement text.
- Flag any item that is a scope or product call rather than mechanics.
- Under "Brief errors", list any wrong fact, with the grep that shows it.

**Total: at most 450 words.**
