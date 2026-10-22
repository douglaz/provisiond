# Panel B final form (r62 through r62f), master 07bac41, 2026-10-22

**Status: Nothing is open.** `API-40`'s conflict rationale is deleted, reviewed (r62f) 4-0 ACCEPT; r62e had split
0-4 on both rewordings. a1 is settled WIDE (r62d 2-2, then the owner, 2026-10-22: "Wide: all four ops
(Recommended)"). Everything below is reviewed.

This is the reviewed text only. Every item was voted on as written, or changed by a reader fix that I verified
and that keeps its meaning. Each fix is labelled with its author. The exact text of everything below is in
`final-form.patch`, next to this file. That patch is `../provisiond-panel-r62c/applied-fable.patch` plus three
r62c folds (`amend.py`: `wir47-opus-astra`, `c3-opus`, `cnf18-fable`), a1's WIDE fold (`amend.py a1-opus`) and the
r62f deletion (`../provisiond-panel-r62f/variants.py del`). The three r62c reader-worded folds were
**reviewed (r62d), 4-0 ACCEPT each**:
- the `WIR-47` fix by opus and astra;
- the `CNF-342` case by opus;
- the `CNF-18` pointer by fable.

The text changes since r62c are a1's WIDE parenthetical (`amend.py a1-opus`), folded after the owner's ruling, and
`API-40`'s deletion (`del`), folded after r62f.

**Evidence (r62d):** on a fresh clone of 07bac41 with `final-form.patch` applied, `check_citations`, `check_ids`,
`check_fixtures`, `check_obligations`, `check_coverage` and `check_regions` all exit 0
(`../provisiond-panel-r62d/gates/final.*.log`, script `../provisiond-panel-r62d/gates.sh final`). The clone's
`git diff` is byte-identical to `final-form.patch`. After the WIDE fold, the same six gates on a fresh clone exit 0
again (`../provisiond-panel-r62d/gates/final-wide.*.log`). After the `del` fold (r62f), the six gates on a fresh
clone of 07bac41 + `final-form.patch.bak-r62e` + `del` exit 0 again
(`../provisiond-panel-r62f/gates/r62f-final.*.log`, script `../provisiond-panel-r62f/gates.sh r62f-final del`), and
that clone's `git diff` is byte-identical to this `final-form.patch` and to `../provisiond-panel-r62f/candidate-del.patch`.
On a fresh clone of 07bac41 with this `final-form.patch` alone, the six gates exit 0 once more
(`../provisiond-panel-r62f/gates/r62f-applied.*.log`).
I did not run the formal build at any stage. Sol ran the full `check-all.sh`, Lean included, on 07bac41 +
`applied-fable.patch`, and it exited 0 (r62c); no formal or Lean build ran after the WIDE or `del` folds. No item
touches `tools/formal/`.

**Owner rulings (2026-10-22, verbatim):** pv-p3k "MUST, not retryable (Recommended)"; B6 "Yes, any unhealthy
(Recommended)". Every part below is therefore in scope. Option 2 (`retryable: true`) is gone, and so is its note.

## pv-7j3: `WIR-48` (r62 Q5 4-0; r62b B6 4-0; owner: B6)

`13-wire-contract.md`, `WIR-48`. The sentence "Assigning a tenant to an account that `SEC-46` has recorded as
confirmed-terminated is also `conflict` — …" becomes:

> Assigning a tenant to an account whose `STO-47` status is anything but `healthy` is also `conflict` with
> `details.reason: "state"` (`STO-36`) — the failure this verb exists to repair should not be reachable by using it.

- `CNF-248` needs no change under `state`: its exclusions list `account_terminated`, not `state`.
- `STO-47`'s "`WIR-48` refused only `terminated`" is past-tense history, so it stays (fable, r62b).
- No CNF item drives `WIR-48`'s refusal reason; `CNF-243` tests only the successful re-assignment. This is context
  for the Run, not a finding.

## pv-009: the claim-time `list_offers` gate (r62 Q2 3-1 for B, 4-0 `false`; r62b B2, B3 4-0; r62c c2 4-0)

- **`DOM-10`** (`01:519`, r62b B2). After "naming the provider account and the capability", add:
  > , with `retryable: false` on both the error and the operation view where there is one
- **`OPS-43` step 4** (`03:735`, r62b B3) becomes:
  > 4. Gate on `list_offers` under `DOM-10`, then obtain the current driver List offers result.
- **`CNF-364`**, new, after `CNF-19` (r62c c2, 4-0): "The claim-time List offers read is gated on `list_offers`."
  Restart with a descriptor that no longer declares `list_offers`, with the ordering capability and the List
  offers code path still live. Assert a step-4 refusal: `unsupported` naming the account and `"list_offers"`,
  `retryable: false` on the error and the view, `failed`, a full release, and no List offers read, key upload or
  order.
- Reader label (r62b): sol calls one `retryable` for every capability gate "a scope choice".
- Lands on: `DOM-10`, `OPS-43`, `CNF-364`.

## pv-gpw: a present value that fails claim-time validation (r62 Q3; r62b B4 4-0 with opus's gate fix; r62c c3)

- **`OPS-23`** (r62b B4). After its two bullets, add:
  > A field that is present but fails this repeated validation fails as its writer's bullet above says, on both
  > the error and the operation view, and settles as these missing-field failures do.
- **`PRV-47`** (`02:169`, r62b B4). After the caller sentence ("… (`WIR-9b`).") add:
  > A value this system wrote rather than the caller, such as `PRV-9`'s operation id as a temporary key's
  > "provider-side name or tag" or `PRV-32`'s per-order throwaway SSH key, that this validation rejects fails
  > `internal` (`DOM-17`); `OPS-11`'s create row gives its `retryable`.
- **`CNF-342`** (r62c c3, 3-1; opus's fix folded, reviewed r62d 4-0). Each step-7 case asserts `invalid_request` with `details.field`
  holding the rejected value's RFC 6901 pointer (`"/provider_options/location"`). Then:
  > Add a stored create carrying provider-options members `a/b` and `a~b`, both rejected by the driver, and assert
  > `details.field: "/provider_options/a~0b"`, the least escaped pointer in `WIR-9a`'s order; unescaped, `a/b`
  > sorts first.

  A fixture driver that rejects a value this system wrote (`PRV-9`'s key name) asserts `internal`,
  `retryable: true`, `failed`, and the same no-mutation and release outcomes. The step-3 acknowledgement case
  asserts `details.field: "/acknowledge_purchase"`.
  - Opus's fix is one instance of the "two provider-options values" that fable, astra and sol accepted. It also
    tells an escaped-pointer sort from a raw-key sort, which an arbitrary pair does not: `a~0b` < `a~1b`, but
    `a/b` < `a~b`.
- The split that all four readers accepted in r62b:
  - An `api`-written value fails at step 3: `conflict`/`incomplete_record`, `retryable: true`.
  - A worker- or driver-written value fails at step 7 under `PRV-47`: `internal`, with `retryable: true` from
    `OPS-11`'s create row.
- Reader labels (r62b): astra calls `incomplete_record` for a present but invalid `api`-written value "a
  classification policy choice". Sol says the `OPS-23` sentence covers "For create, install, power and delete",
  and "That scope extension should be deliberate".
- Lands on: `OPS-23`, `PRV-47`, `CNF-342`.

## pv-p3k: `allow_orders` (r62 Q1 4-0 in substance; r62b B1–B3; r62c b, c1 4-0; owner: MUST, not retryable)

- **`DOM-16`** (`01:566`, r62b B1; MUST per the owner) becomes:
  > Ordering capabilities (`provision_virtual`, `provision_bare_metal`) for providers that bill per order MUST be
  > conditional on an explicit per-account `allow_orders` configuration flag: the descriptor (`PRV-44`) of an
  > account whose flag is false does not declare them, so that a misconfigured deployment cannot spend money. This
  > is in addition to, not instead of, the per-request purchase acknowledgement (`API-15`).
- **`PRV-4`** (r62c b, 4-0) gains:
  > An ordering capability that `DOM-16` withholds from an account whose `allow_orders` is false is not declared
  > for that account, and a driver that implements it breaches neither this requirement's second clause nor
  > `DOM-15`.
- **`DOM-15`** (r62c b, 4-0) gains:
  > An ordering capability withheld under `DOM-16` is excepted from that agreement (`PRV-4`).
- **`CNF-18`** (r62b B1; fable's r62c fix folded, reviewed r62d 4-0) gains:
  > An ordering capability withheld under `DOM-16` is outside the implemented-implies-declared rows for that
  > account; `CNF-19` and `CNF-55` cover its gate.
- **`WIR-29`'s fixture** (`13:1010`, r62b B1) drops `"allow_orders": true,`. `grep -rn allow_orders tools/
  .github/` finds nothing (fable).
- **`API-7`** (r62b B2) gains, after 5c:
  > 5d. **gate a create on its ordering capability** under `DOM-10` (`PRV-10`, `DOM-16`). A refusal stops here and
  > is not collected by the tail.

  The same edit changes "1–5c" to "1–5d" at `04:261` and `04:290`. A `git grep` of 07bac41 finds no other "1–5c".
  Run note (fable, r62b): `Admission.lean`'s `Guards` gives 5d no Lean twin. `ADR-0025` allows that, but the Run's
  record should say so.
- **`PRV-10`** (r62b B2) gains:
  > The configuration half is `DOM-10`'s gate on the create's ordering capability (`DOM-16`): `API-7`'s step 5d at
  > admission and `OPS-43`'s step 3 at claim.
- **`OPS-43` step 3** (`03:731`, r62b B3 4-0) becomes:
  > 3. Repeat boundary validation under `OPS-23`: "Validation that was performed at the API boundary MUST be
  > repeated in the worker before the driver is called". This includes `PRV-10`'s "explicit purchase
  > acknowledgement", `PRV-8`'s "at least one SSH public key", the missing-field checks defined in `OPS-23`, and
  > `DOM-10`'s gate on the create's ordering capability, which is `PRV-10`'s "the account is configured to allow
  > ordering". The checks on caller-supplied fields run first, then the checks on fields the `api` wrote at
  > admission, then the capability gate.

  astra and sol label the check order an error-precedence policy.
- **`CNF-55`** (r62c c1, 4-0) asserts the following on an `allow_orders: false` account:
  - The listing omits the ordering capability.
  - A create carrying `acknowledge_purchase: true` is refused at 5d with `501` `unsupported`, naming the account
    and the capability, `retryable: false`. With a balance too low for the create, the refusal still carries no
    `details.refusals` or `details.not_checked`, and nothing is written.
  - A same-key, same-body replay of a create admitted before the flag went off returns its stored result.
  - A create admitted with the flag true, then restarted with it false before claim, is refused at step 3: same
    kind, `details` and `retryable: false` on the error and the view, `failed`, a full release, and no provider
    request (no List offers read).
- `API-15` needs no edit. It cites `PRV-10` for the configuration half, and `PRV-10` carries the kind.
- Lands on: `DOM-16`, `PRV-4`, `DOM-15`, `CNF-18`, `WIR-29`, `API-7`, `PRV-10`, `OPS-43`, `CNF-55`.

## pv-ss4: the wire form of "naming the field" (substance r62 Q4 4-0; text r62c)

- **`WIR-9a` row** (r62c a1, 3-1; STAGE S1 4-0; scope WIDE: r62d + owner). After the `offer_not_sellable` row:
  > | `invalid_request` naming a field (`WIR-2`, `OPS-23`, `PRV-47`) | `field`: an RFC 6901 JSON Pointer into the
  > request body (`"/acknowledge_purchase"`, `"/provider_options/location"`), also where the named field is absent.
  > Where one validation step rejects several fields (an `API-7` step, `OPS-23`'s repeated check of
  > caller-supplied fields, or `PRV-47`'s validation), the least escaped pointer, compared by unsigned UTF-16 code units, the order
  > RFC 8785 (`WIR-3`) sorts member names in |

  The tie-break covers create, install, power and delete (owner, 2026-10-22, "Wide: all four ops"). r62d was
  2-2 by vendor; astra's and sol's only objection to WIDE was that it needed an owner decision. For create it
  selects the same field as the narrow S1 text. A stored `rootfs_via_rescue` install missing `trust` and
  `acknowledge_destruction` names `/acknowledge_destruction`.
- **`WIR-2`** (r62c a2, 4-0). Its first sentence becomes:
  > **Unknown fields in a request body MUST be rejected** with `invalid_request`. The field named in
  > `details.field` MUST be selected under `WIR-9a`, including when the same validation step also rejects known
  > fields.
- **`WIR-47`** (`13:1261`, r62c a3; the opus/astra fix is folded, reviewed r62d 4-0). It becomes:
  > Under `WIR-2`'s "Unknown fields in a request body MUST be rejected" rule, a withdrawal body whose only rejected
  > field is `operator_ref` returns `invalid_request` with `details.field: "/operator_ref"` (`WIR-9a`).

  - Opus, astra and sol showed that the drafted "a withdrawal body containing `operator_ref`" is a false
    universal: `{"status":"unknown","operator_ref":"x","evidence":"y"}` selects `/evidence`.
  - Opus and astra wrote the fix independently, word for word. It is a true subset of what fable accepted, and
    it removes sol's stated reason.
  - Sol's alternative: "… a withdrawal body containing `operator_ref` returns `invalid_request` with
    `details.field` selected under `WIR-9a`." Sol accepted the folded text in r62d.
  - The citation gate skips this sentence's quote (it mentions a withdrawal; candidate bead 3). Checked by hand:
    `WIR-2`'s bold sentence at `13:28` is "Unknown fields in a request body MUST be rejected" (fable, opus, sol and
    the manager).
- **`API-40`** (`04:772`; r62c a3 for the response, **reviewed (r62f) 4-0 ACCEPT** for the deletion). In the
  `API-7` bullet, the conflict rationale from "**The order resolves a conflict between two MUSTs, so it is stated as
  a precedence.**" through "… whichever way a handler goes." is deleted, and the paragraph opens:
  > For a body carrying both a bad token and an unknown field, **the token check wins**: the response is
  > `invalid_request` with no `details.field` and no token detail.

  The rest of the paragraph ("Enrolment is the one route where naming a field is a free oracle …") is unchanged.
  - Why delete: r62c, r62d and r62e reworded the span and never converged; in r62e all four readers rejected both
    rewordings and agreed that a field-naming answer breaks nothing in `WIR-12`'s MUST ("the message MUST NOT say
    which"). The coordinator routed it to deletion.
  - What still carries the behaviour (r62f, all four, verified): `04:768`'s "**The admission token MUST be checked
    before any other validation of the body**"; `04:772`'s response; `WIR-12` at `13:429-430`, "that check precedes
    `WIR-2`'s unknown-field rule, so a body with both a bad token and an unknown field is refused naming no field at
    all", whose "`API-40`'s stated precedence" still resolves to "the token check wins". `WIR-2` and `WIR-12` are
    not touched.
- **`CNF-233`** (`10:3397`, r62c a3; no objection): "assert `invalid_request` with `details.field:
  "/operator_ref"` and no column change".
- **`CNF-34`** (r62c c3, 4-0 on this part): `details.field: "/acknowledge_purchase"` for the create caller field
  and `"/acknowledge_destruction"` for the install.
- `CNF-342`'s `details.field` values: see pv-gpw above.
- Lands on: `WIR-9a`, `WIR-2`, `WIR-47`, `API-40`, `CNF-233`, `CNF-34`, `CNF-342`.

## File with the drain PR

Three candidate beads, not yet filed:

1. **(d) `PRV-47`: a mixed caller and system rejection** (r62c, "bead" 4-0). One `PRV-47` validation can reject a
   caller value and a system-written value together, and nothing says whether `invalid_request` or `internal`
   wins. Both settle `failed` with no mutation and a full release. Fable, unvoted: "`internal` should win, since a
   caller fix cannot clear a defect". Owners: `PRV-47`, `OPS-11`, `WIR-9a`.
2. **`DOM-10` (opus, r62).** Power, install and rescue inventory have no admission capability-check step.
   - `API-7` has no capability gate; 5d covers only create's ordering capability.
   - `git grep DOM-10` finds no citation in `03`, `04` or `06`.
   - Owners: `DOM-10`, `API-7`, `OPS-43`.
3. **The citation gate's history filter matches "withdrawal"** (found verifying opus's r62c gate note).
   - `HISTORICAL`'s `withdraw` (`tools/check_citations.py:293`) matches the domain noun, so every quote in a
     sentence that mentions a withdrawal goes unchecked. `WIR-47`'s quote of `WIR-2` is one of them.
   - A planted false quote there stays green. Moving the sentence away from "withdrawal" turns it red.
   - How many other quotes it hides is unmeasured. No bead covers this; `pv-602` is the nested-quote case. Check strength, so not cosmetic.
   - r62d: fable confirmed the line (`grep -n 'withdraw|withdrew' tools/check_citations.py` → 293).

Not a bead: opus's r62d note (one reader, unvoted) asked for a bead because a field-first answer breaks none of
`WIR-12`'s quoted words. The r62f deletion answers it: the clause it questioned is gone, and `04:768` fixes the
behaviour.
