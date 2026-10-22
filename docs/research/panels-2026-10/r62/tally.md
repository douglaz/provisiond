# r62 tally (panel B) — 2026-10-22, master 07bac41

All four readers exited 0 (fable 7468 B, opus 6129 B, astra 5332 B, sol 4826 B). Sol ran the baseline gates: exit 0.
Votes first. "Against" lines are the counter-arguments the brief asked for. They were written on request and are not votes.

## Q1 pv-p3k: `allow_orders` refusal

- fable: AMEND A. Keeps A's kind, `retryable: false`, position and non-collection. Rewrites `DOM-16` to name the
  descriptor (`PRV-44`) and keeps its `API-15` tail. **owner**: SHOULD→MUST retires a permitted engine shape.
- opus: AMEND A. Keeps the MUST. Puts `retryable: false` in `DOM-10`. Adds a `PRV-4` carve-out and `API-7` step 5d.
  `PRV-10` points at 5d and at `OPS-43` step 3, where "field checks run first, then the capability gate".
  `WIR-29`'s fixture drops `"allow_orders": true`. **mechanics**.
- astra: AMEND A. Keeps `DOM-16` and the error sentence with `false`. Moves position into `API-7`, after 5c, not
  collected. Step 3 order: caller fields, then api-written fields, then the ordering capability. **owner**.
- sol: AMEND A. Keeps A, but makes the gate "the first check within `OPS-43`'s step 3". **owner**.
- **4-0 in substance:** `unsupported` naming the account and the ordering capability; `retryable: false`; after
  5c (5a's replay must return its stored result first); not collected; `DOM-16` MUST.
- **Split:**
  - Where the position lives: `PRV-10` (fable, sol) or `API-7` 5d (opus, astra).
  - Step-3 order: gate last (fable, opus, astra) or gate first (sol).
  - Where `retryable` lives: `PRV-10` (fable, astra, sol) or `DOM-10` (opus).
  - Opus's `PRV-4` and `WIR-29` edits are unvoted.
- Against (on request), all four: by pv-xer's "can recover" analogy an operator can flip the flag back, so
  `true`. Opus adds that `PRV-44` calls the descriptor "a typed, immutable value".

## Q2 pv-009: claim-time `list_offers` gate

- fable: AMEND A. Step 3 gains the gates, and its checks "run in the order listed", gates last. **mechanics**.
- opus: REJECT → B (gate at the head of step 4); `retryable` from its `DOM-10` sentence. **mechanics**.
- astra: REJECT → B, stating `retryable: false`. **owner**.
- sol: REJECT → B, stating `retryable: false`. **mechanics**.
- **4-0:** `retryable: false`, the same as Q1. Traces are 4-0 as well:
  - `credentials_rejected` fails at step 1 with `conflict`/`state`, `retryable: true`.
  - A closed channel fails at step 2 with `rate_limited`, `retryable: true` (`PRV-40`).
  - Neither account reaches the gate.
- **Split 3-1 for B.**
- Against (on request):
  - fable: `DOM-10` says "before the driver is called", and step 4 is that call (an argument for B).
  - opus: B makes claim stricter than admission.

## Q3 pv-gpw: claim-time rejection of a present value

- fable: AMEND A. One by-writer rule. Engine-written: `internal`, `retryable` **true** (from `OPS-11`'s create row).
  Its `PRV-47` replacement **rewrites the fixed caller sentence**, which is out of bounds, so it's excluded.
  **mechanics**.
- opus: REJECT → B, per-check sentences. `OPS-23`: a present field "fails as its writer's bullet says".
  `PRV-47`: engine-written fails `internal`, with `retryable` from `OPS-11`'s create row (**true**). **mechanics**.
- astra: REJECT → B, narrower. Engine-written, *and an api-written present value*, fail `internal` with
  `retryable` **false**. **owner**.
- sol: AMEND A. Create-only rule in `OPS-23`. Engine-written: `internal`, **true**. **mechanics**.
- **4-0:** engine-written kind `internal`.
- **Split:**
  - `retryable`: true 3, false 1 (astra).
  - Structure: one rule (fable, sol) or per-check sentences (opus, astra).
- Against (on request): fable, opus and sol each say `true` tells callers to resend something that fails the same
  way every time.

## Q4 pv-ss4: wire form of "naming the field"

- All four: AMEND A. `details.field`, an RFC 6901 pointer, least pointer by **UTF-16** code units (JCS's order),
  and `WIR-2` adopts it. Engine-written values carry no key (4-0).
  - fable: a `WIR-9a` table row.
  - opus: "one validation step".
  - astra and sol: also for an absent field; astra adds "escaped pointer".
- Labels: astra **owner**, the other three **mechanics**.
- Against (on request):
  - opus: string order isn't segment order (`"/a!"` < `"/a/x"`).
  - opus and sol: one key hides the other rejections.

## Q5 pv-7j3: reason on `WIR-48`'s terminated refusal

- **4-0 ACCEPT A (`state`). SETTLED.**
- Labels: astra **owner**, the other three **mechanics**.
- Fable's unvoted add-on: widen the clause to `STO-36`'s "anything but `healthy`". It goes to r62b as B6 and is
  not part of the settlement.
- Against (on request), all four: `account_terminated` tells the caller "permanent"; `state` hides it.

## Q6 Run shape (process; not a panel call)

- opus: one Run for all five.
- fable: one Run for four, with pv-7j3 as its first commit or landing alone.
- sol: one Run for four; pv-7j3 split.
- astra: three groups (p3k+009, gpw+ss4, 7j3).
- Manager: follow the owner's triage plan ("then one Run"), with pv-7j3 as the first commit.

## Brief errors (reader-reported, verified)

1. **Q3 strawman `retryable: false` was wrong.** `OPS-11`'s create row (03:232) says: "For `network`, `timeout`,
   `internal`, … it MUST carry `retryable: true` on both the error and the operation view" before step 9. It
   landed with pv-qga (c8b7cbc, PR #8, r57 / `ADR-0043`). Fable, opus and sol caught it; astra did not.
2. **The `WIR-29` quote omitted text** (opus): "This view is a subset of the driver's descriptor (`PRV-44`)" and
   "nothing here is declared anywhere else". `PRV-44` has no `allow_orders`.
3. **The `STO-36` omission** (fable): `STO-36` already forbids writing an assignment row to any non-`healthy`
   account. `STO-47` says "`WIR-48` refused only `terminated`".
4. **`TailRefusal.rank` is tagged `API-7`**, not `WIR-9a` (fable); only `retryable` is `WIR-9a`. Minor.
5. **(manager)** The `DOM-16` quote dropped its last sentence: "This is in addition to, not instead of, the
   per-request purchase acknowledgement (`API-15`)." Draft A's rewrite would have lost it.

## Reader claims checked

- **True:** opus's `PRV-4` / `CNF-18` breach. `PRV-4` says "MUST NOT implement one whose capability it does not
  declare", and `CNF-18` requires "every implemented operation … has its capability declared". So A, as drafted,
  breaks both on an `allow_orders: false` account.
- **True:** step 3 has no internal order (opus). `OPS-43` orders only its numbered steps.
- **True:**
  - `API-7` 5a: "an equal fingerprint under the same `(principal, key)` returns the stored result".
  - `PRV-40`'s closed channel gives operation-view `retryable: true`.
  - `WIR-29`: "At admission, a create naming an account that is not `healthy` MUST be refused `conflict` with
    `details.reason: "state"`".
- **Wrong:** fable says the stored `request` is purged "only by age". 05:396 purges it "on entry to any settled
  state and to `needs_reconciliation`". The conclusion holds, because the operation is live at claim.
- **Don't relay:** opus's "JSONB". 05 types the column `json`.

## Unvoted candidate bead (for the assistant)

- opus: `DOM-10`'s gate has no admission step for power, install or rescue inventory either. The manager's grep
  agrees: `API-7` places no capability gate.

## Settled vs open

- **Settled:** Q5 = A.
- **Settled in substance, text pending r62b:**
  - Q1: kind, `false`, after 5c, not collected.
  - Q2: B's position (3-1) and `false`.
  - Q3: engine kind `internal`.
  - Q4: the pointer rule.
- **r62b** (`/var/tmp/provisiond-panel-r62b/`), items B1–B6, the manager's merged texts. Units `panel-r62b-{fable,opus,astra,sol}` were
  launched 2026-10-22 with the memory cap and a 2400 s timeout:
  - B1 `DOM-16` + `PRV-4` + `CNF-18` + `WIR-29`'s fixture (if the owner takes the MUST)
  - B2 the error and position: `DOM-10` + `API-7` 5d + `PRV-10`
  - B3 `OPS-43` steps 3 and 4
  - B4 `OPS-23` + `PRV-47` + `CNF-342`
  - B5 `WIR-9a` + `WIR-2`
  - B6 the optional `WIR-48` widening

## Owner question (draft; SUPERSEDED by the r62b section at the end of this file)

**pv-p3k: when an account's `allow_orders` is off, should it stop advertising that it can order?**

TL;DR: money is safe either way. `PRV-10` already MUSTs the refusal. The choice is how the refusal looks and what
a customer sees.

Example: `hetzner-robot-1` has `allow_orders: false`.

1. **MUST (recommended; 4-0 in r62).** `GET /v1/providers` lists the account without `provision_bare_metal`. A
   create fails `unsupported` with `{provider_account: "hetzner-robot-1", capability: "provision_bare_metal"}`
   and `retryable: false`.
2. **MUST, but `retryable: true`.** The operator may switch the flag back. This follows the pv-xer "can recover"
   analogy, which every reader wrote on request against their own pick; no reader voted for it.
3. **Keep the SHOULD.** The listing still shows `provision_bare_metal`, and the refusal can't be `unsupported`:
   `DOM-15` calls a declared capability that answers `unsupported` a defect. It becomes `conflict`/`state`
   (`retryable: true`) or `invalid_request`.

Labels: fable, astra and sol call it the owner's call, because it retires an engine that checks the flag at run
time while still declaring the capability. Opus calls it mechanics, because `DOM-10` and `DOM-15` already force
the kind.

IDs: `DOM-16`, `PRV-10`, `DOM-10`, `DOM-15`, `PRV-4`, `CNF-18`, `WIR-29`. Prior: the pv-xer ruling of 2026-10-21.

There's no second owner question. Q3's `retryable` is decided by `OPS-11`'s create row, which landed with the
owner-decided pv-qga (r57). It becomes a question only if someone proposes changing that row.

---

# r62b tally (B1–B6), 2026-10-22

All four readers exited 0: fable 3036 B, opus 3243 B, astra 1635 B, sol 1566 B. Opus ran the citation gate on B3
and B4. Astra says it ran no gates. The complete reviewed text is in `final-form.md`, next to this file.

## Votes, one line per reader

- **B1** (`DOM-16`, `PRV-4`, `CNF-18`, `WIR-29`): 2 ACCEPT, 2 CANNOT ACCEPT.
  - fable: CANNOT ACCEPT. `PRV-4`'s "the second clause there" can point at `DOM-16`; it should say "this
    requirement's second clause". Calls the MUST the owner's product call.
  - opus: CANNOT ACCEPT. The same wording fix, and `DOM-15` is still breached. Proposes adding "nor `DOM-15`" to
    `PRV-4` plus an exception sentence in `DOM-15`. Calls it owner/product.
  - astra: ACCEPT, "conditional on the owner's `DOM-16` MUST decision".
  - sol: ACCEPT. "That remains a product call".
- **B2** (`DOM-10`, `API-7` 5d, `PRV-10`): 4-0, with the "1–5d" fix.
  - fable: CANNOT ACCEPT on the `API-7` part only. "1–5c" becomes "1–5d" at `04:261` and `04:290`.
  - opus: CANNOT ACCEPT, the same fix.
  - astra: ACCEPT, and also update the "1–5c" references.
  - sol: ACCEPT. Flag: one `retryable` for every capability gate "is a scope choice".
- **B3** (`OPS-43` steps 3 and 4): 4-0 ACCEPT.
  - fable: ACCEPT. The `PRV-10` quote is verbatim.
  - opus: ACCEPT. The citation gate stayed green.
  - astra: ACCEPT. Flag: the check order within the step is "a policy choice".
  - sol: ACCEPT. Flag: "an observable error-precedence policy".
- **B4** (`OPS-23`, `PRV-47`, `CNF-342`): 4-0, with opus's gate fix.
  - fable: ACCEPT. Its "quotes check" was wrong for the `DOM-17` quote.
  - opus: CANNOT ACCEPT. The citation gate fails "Defect in this system"; replace it with `` (`DOM-17`) ``.
    Otherwise it accepts `true`, the split, `OPS-23` and `CNF-342`.
  - astra: ACCEPT. Flag: sending a present but invalid `api`-written value to `incomplete_record` is a policy
    choice.
  - sol: ACCEPT. Flag: `OPS-23`'s sentence covers "For create, install, power and delete"; "That scope extension
    should be deliberate".
- **B5** (`WIR-9a` row, `WIR-2`): 0-4, NOT converged.
  - fable: CANNOT ACCEPT. "Three stages" should be "the caller-supplied stage", and `WIR-47` at `13:1261` restates
    "first unknown field".
  - opus: CANNOT ACCEPT. `WIR-2` contradicts the row on one `API-7` step-5 body. "Three stages" should be "a
    stage".
  - astra: CANNOT ACCEPT on `WIR-2` (the same conflict) and gives a replacement. It accepts the row.
  - sol: CANNOT ACCEPT on `WIR-2` (the same conflict) and gives a replacement.
- **B6** (widen `WIR-48` per `STO-36`): 4-0 ACCEPT on the text. Labels split:
  - fable: ACCEPT, "Mechanics, not product".
  - opus: ACCEPT, "This is a scope call".
  - astra: ACCEPT, no label. "Supplies the wire outcome for `STO-36`'s existing prohibition".
  - sol: ACCEPT, no label. "Aligns the wire refusal with `STO-36`".

## Reader claims checked against 07bac41

- **True:** `04:261` and `04:290` say "1–5c". `git grep` finds no other in tracked files.
- **True:** `DOM-15` says "Declaration and implementation MUST agree", and both `PRV-4` and `CNF-18` cite it. So B1
  leaves `DOM-15` breached (opus).
- **True:** the citation gate fails B4's "Defect in this system", with exit 1. That phrase is the `internal` row of
  the error table (`01:588`), and `DOM-17` is at `01:652`. With `` (`DOM-17`) `` the gate exits 0. Both were
  reproduced in a scratch clone.
- **True:** `WIR-2` and the row conflict.
  - `API-7` step 5 is a single step, "deserialize and validate the body".
  - `WIR-17` says "`acknowledge_purchase` MUST be literal `true`", so opus's example body fails in that step.
- **True:** `WIR-47` at `13:1261` says "naming that first unknown field" (fable). The manager's grep found two
  more that no reader named: `API-40` at `04:772` ("naming the first one") and `CNF-233` at `10:3397` ("names it
  as the first unknown body field").
- **True:** all four quote `STO-36` exactly. `STO-47`'s statuses are `healthy`, `account_unreachable`,
  `credentials_rejected` and `terminated`. `terminated` is `SEC-46`'s write-once state, so B6 includes the narrow
  case.
- **True:** `OPS-23`'s first bullet covers "A field the `api` itself writes", at step 3, "For create, install,
  power and delete" (opus, astra, sol).
- **True:** no `allow_orders` appears under `tools/` or `.github/` (fable).
- **Incomplete:** fable says "`Rescue.lean`'s `WIR-9a` declaration covers `rescue_exit` only". `Admission.lean`
  also tags `TailRefusal.retryable` (`:1233`) and `account_retryability` (`:1298`) as `WIR-9a`. Neither models
  `invalid_request` details, so fable's conclusion that no Lean change is needed holds.
- **Applied set:** with every item in `final-form.md` applied, `tools/check_citations.py` exits 0, with the narrow
  `WIR-48` sentence and with the B6 sentence.

## Brief errors (r62b)

1. B4's "a system-written value meets validation only at step 7" is too broad (opus, astra, sol). `api`-written
   fields meet it at step 3. B4's text already sends those to `incomplete_record`, so the text stands.
   - The real error is the brief's Q3 summary, "a value the system wrote … is `internal`". r62 settled only the
     engine-written kind.
   - Sol's "worker-written value" wording was not voted on as text, so it isn't adopted.
2. B4's `DOM-17` quote fails the citation gate (opus).
3. B5's "one of the three stages" is wrong (fable, opus). Only the caller-supplied stage yields `invalid_request`
   naming a field, and under the SHOULD there is no gate stage.

## Open, and the smallest next step

- **pv-ss4 (B5):** the text did not converge. The substance is settled from r62.
- **pv-p3k, `PRV-4` and `DOM-15` (B1):** this matters only if the owner takes the MUST.
- **Not drafted:**
  - `CNF-55` (pv-p3k) asserts no kind, no `retryable` and no position.
  - No CNF item drives pv-009's `list_offers` gate.
  - Both belong in r62c item (a) or (b).
- **Tracker:** pv-009 depends on pv-p3k, but pv-009's text needs no MUST (`final-form.md`, Part 1). If Q1 comes
  back SHOULD, that edge holds pv-009 behind text it doesn't need. Dropping it is the assistant's call.
- **Option:** item (a) could start before the owner answers if it uses fable's "caller-supplied stage"
  phrasing, which holds under both SHOULD and MUST. The trade-off is two rounds instead of one combined
  round.
- **Smallest next step:** one r62c round, four readers, two items, after the owner answers Q1.
  - (a) B5. Pick one `WIR-2` sentence from the three reader texts, a row phrasing without "three", and the
    `WIR-47`, `API-40` and `CNF-233` restatements. Add the `details.field` expectations in `CNF-34` and `CNF-342`.
  - (b) B1's `PRV-4` and `DOM-15` text, only if Q1 is MUST.
  - Pre-check each candidate with the citation gate. `13:1259` quotes `WIR-2`'s opening phrase.
  - If Q1 is SHOULD, pv-p3k needs a fresh question round for the SHOULD shape instead of (b).

## Candidate needs-triage bead (not filed)

- **From opus, r62.** `DOM-10`'s capability gate has no named step for power, install or rescue inventory.
  - `API-7` has no capability gate. B2's 5d covers only create's ordering capability.
  - `git grep DOM-10` finds no citation in `03`, `04` or `06`.
  - Owners: `DOM-10`, `API-7`, `OPS-43`.

## Owner questions (refreshed against r62b)

**Q1, pv-p3k. When an account's `allow_orders` is off, should the account stop advertising that it can order?
(`DOM-16`: SHOULD → MUST)**

Recommendation: **MUST** (option 1). Money is safe either way, because `PRV-10` already requires the refusal. The
choice is what the refusal looks like and what a customer sees.

Example: `hetzner-robot-1` has `allow_orders: false`.
1. **MUST (recommended).** `GET /v1/providers` lists the account without `provision_bare_metal`.
   - A create gets `501 unsupported` with `{provider_account: "hetzner-robot-1", capability:
     "provision_bare_metal"}` and `retryable: false`, at admission (new step 5d). Nothing is written.
   - If the operator turns the flag off while a create is queued, the worker refuses it the same way at claim. It
     settles `failed` and the commitment is released in full.
2. **MUST, but `retryable: true`,** because the operator may switch the flag back on. This is the pv-xer "can
   recover" analogy.
   - No reader voted for it; every reader wrote it, on request, as the case against their own pick.
   - It would also need an exception to the new `DOM-10` `false`, which no one has reviewed.
3. **Keep the SHOULD.** The listing still shows `provision_bare_metal`, and the refusal can't be `unsupported`:
   `DOM-15` calls a declared capability that answers "unsupported" a defect. It becomes `conflict`/`state`
   (`retryable: true`) or `invalid_request`. That text needs a new panel round.

Panel:
- r62 was 4-0 for the MUST shape: `unsupported`, `retryable: false`, after 5c, not collected.
- In r62b, all four call the choice the owner's:
  - fable: "the owner's product call";
  - opus: "an owner/product call, because it depends on the MUST" (in r62, opus had called it mechanics);
  - astra: "conditional on the owner's `DOM-16` MUST decision";
  - sol: "that remains a product call".
- The case for `true` was written on request by all four. It is not a vote.

Cost of a yes: one short round (r62c) on the `PRV-4`/`DOM-15` sentence. The rest of the MUST text is reviewed
(`final-form.md`, Part 2).

IDs: `DOM-16`, `PRV-10`, `DOM-10`, `DOM-15`, `PRV-4`, `CNF-18`, `WIR-29`, `API-7` 5d, `OPS-43` step 3. Prior: the
pv-xer ruling of 2026-10-21.

**Q2 (B6, pv-7j3's scope). Should `WIR-48` also refuse an assignment to an account that is `account_unreachable`
or `credentials_rejected`, not only `terminated`, with the same `conflict`/`state`?** For example, the operator
assigns tenant T to `hetzner-cloud-2` while it is `credentials_rejected`. `STO-36` already forbids writing that row,
but `WIR-48` names no response. With yes, it's a `409` `conflict`/`state`.
- Recommendation: yes.
- The text was accepted 4-0. Labels: opus says scope, fable says mechanics, astra and sol gave none.
- No means pv-7j3 lands with the narrow, terminated-only sentence, which is settled.

Q3's `retryable` stays `OPS-11`'s create row (`true`), so it needs no owner question.

---

# r62c (launched 2026-10-22, after the owner's rulings): /var/tmp/provisiond-panel-r62c/

Owner, verbatim: pv-p3k "MUST, not retryable (Recommended)"; B6 "Yes, any unhealthy (Recommended)". Units
panel-r62c-{fable,opus,astra,sol}, capped. Items a1–a3 + STAGE vote (pv-ss4), b (PRV-4/DOM-15), c1–c3 (manager CNF
drafts: CNF-55, new CNF-364, CNF-34/342), d (optional mixed PRV-47 rejection). Pre-launch gates: see r62c/notes.md.
Tallied 2026-10-22 by a fresh manager.

## r62c votes, one line per reader

All four exited 0: fable 2140 B, opus 2579 B, astra 1465 B, sol 1806 B. All four reviewed `applied-fable.patch`
(S1). Fable, opus and sol report six text gates exit 0. Astra reports citations exit 0 and stopped the full gate
during the Lean build. Sol ran `nix develop --command bash tools/check-all.sh` before and after the patch, and
both runs exited 0, as `sol.err` shows (formal: "Build completed successfully (58 jobs)").

- **a1** (`WIR-9a` row): 3 ACCEPT, 1 CANNOT ACCEPT. **Open.**
  - fable, astra, sol: ACCEPT.
  - opus: CANNOT ACCEPT. The first cell cites `OPS-23` for four operations, but the tie-break names only create's
    stage. Replace the parenthetical with "(an `API-7` step, `OPS-23`'s repeated check of caller-supplied fields,
    or `PRV-47`'s validation)". **This changes meaning:** it widens the tie-break to install, power and delete.
- **a2** (`WIR-2`): 4-0 ACCEPT.
- **a3** (stale "first unknown field"): 1 ACCEPT (fable), 3 CANNOT ACCEPT. `CNF-233` and `API-40`'s second half
  ("no `details.field` and no token detail") draw no objection.
  - `WIR-47`: opus, astra and sol say "a withdrawal body containing `operator_ref`" → `/operator_ref` is a false
    universal. Opus and astra independently give the same text, "a withdrawal body whose only rejected field is
    `operator_ref`". Sol gives "… with `details.field` selected under `WIR-9a`". **Folded: opus/astra's.**
  - `API-40`: opus and sol say it reports `WIR-2` without quoting it, which breaks `AGENTS.md`'s "Quote the
    sentence". Fable and astra accept it. The two texts differ. **Open.**
    - opus: "`WIR-2` says "The field named in `details.field` MUST be selected under `WIR-9a`" of a rejected
      unknown body field;"
    - sol: "`WIR-2` says “Unknown fields in a request body MUST be rejected” (field selection: `WIR-9a`).
      `WIR-12` says “the message MUST NOT say which” for a bad admission token." **This changes meaning:** the
      quoted words no longer carry the naming duty, so the next sentence, "satisfies one and violates the other
      whichever way a handler goes", no longer follows from them.
- **b** (`PRV-4`/`DOM-15`): 4-0 ACCEPT. Fable and opus reproduced the gate failure of opus's old `DOM-15` form.
- **c1** (`CNF-55`): 4-0 ACCEPT.
- **c2** (`CNF-364`): 4-0 ACCEPT.
- **c3** (`CNF-34`/`CNF-342`): 3 ACCEPT, 1 CANNOT ACCEPT. **Folded: opus's case.**
  - opus: an arbitrary pair can't catch an implementation that sorts raw keys or unescaped pointers. It replaces
    the pair with members `a/b` and `a~b`, asserting `"/provider_options/a~0b"`. That case is one instance of the
    "two provider-options values" the other three accepted.
- **STAGE:** S1 4-0. Opus calls it moot under its a1 text.
- **(d):** "bead" 4-0. Fable, unvoted: when picked up, "`internal` should win, since a caller fix cannot clear a
  defect".
- **Non-blocking (fable):** `CNF-18`'s "`CNF-19` covers its gate" should read "`CNF-19` and `CNF-55` cover its gate".
  **Folded.**
- Scope or product flags: none from opus. Astra and sol label (d) "a separate product decision".

## r62c reader claims checked (variant-v3 = `applied-fable.patch` + the three folds)

- **True (a1, opus).** `03:1884` says "For create, install, power and delete, a missing required field MUST
  fail as follows", and the caller bullet says "fails `invalid_request` naming the field". `CNF-34` already
  drives the install case (`/acknowledge_destruction`). Opus's example: `trust` is required only on the
  `rootfs_via_rescue` and `raw_disk` installs (`13:689`). For create, opus's text and S1 select the same field.
- **True (a3, `WIR-47`).** Take `{"status":"unknown","operator_ref":"x","evidence":"y"}`. Both members are
  unknown on withdrawal, and `/evidence` < `/operator_ref`, so the drafted sentence is false for that body.
- **True (a3, `API-40`).** `AGENTS.md:29` says "A claim about what another requirement says carries that
  requirement's own words". The unquoted shape is older: 07bac41 already reads "`WIR-2` requires … **naming the
  first one**", and its `WIR-12` half is unquoted too.
- **True (c3, opus).** Escaped, `a~0b` < `a~1b` ('0' < '1'). Unescaped, `a/b` < `a~b` ('/' 0x2F < '~' 0x7E). The
  case therefore separates an escaped-pointer sort from a raw-key sort. An arbitrary pair does not.
- **True, loosely attributed (c1, fable).** The 501 is right: `01:578`, `unsupported` → 501. That table sits
  under "Error taxonomy", before `DOM-17` (`01:649`), so it is not "`DOM-17`'s table".
- **True (c3, fable).** `/acknowledge_destruction` is the wire name (`13:686`).
- **True (fable, `CNF-18`).** `CNF-55`, as c1 drafts it, drives the `allow_orders` gate at 5d and at step 3.
- **Wrong as a general claim (opus's manager note).** Opus wrote that `check_citations` "verifies a quote only when
  "says" directly follows the ID". The gate does check the bare possessive. Moving `WIR-47`'s sentence away from
  the word "withdrawal" turns a planted false quote red. The real cause is `HISTORICAL`'s `withdraw`
  (`tools/check_citations.py:293`), which matches the domain noun "withdrawal". Every quote in a sentence that
  mentions a withdrawal is skipped. How many other quotes it hides is unmeasured: a line grep can't reproduce the gate's sentence split. No bead covers this
  (`pv-602` is the nested-quote case). It is a candidate bead below.
- **Gate checks on the open texts.** Opus's `API-40` quote and sol's curly `API-40` quote are both checked: each
  turns red when planted false.

## r62c gates

Six text gates (citations, ids, fixtures, obligations, coverage, regions), each on a fresh clone of 07bac41 +
`applied-fable.patch`, with the Lean index/regions from `../provisiond-panel-r62c/lake/`:
- v0 (as drafted): all exit 0.
- **v3 (the folded final form, saved as `final-form.patch`): all exit 0.**
- v1 (v3 + opus's a1 + opus's `API-40`): all exit 0. Saved as `candidate-v1.patch`.
- v2 (sol's `WIR-47` + sol's `API-40`): all exit 0. Saved as `candidate-v2.patch`.
- Script: `../provisiond-panel-r62c/gates-variant.sh`, with amendments in `amend.py`. The formal build was not
  run by the manager. Sol's two check-all runs (above) cover 07bac41 + the patch, and no item touches `tools/formal/`.

## Open after r62c (no r62d started)

1. **a1's scope.** Two ways out:
   - (i) Land the narrow S1 row and file the install/power/delete tie-break as a candidate bead.
   - (ii) Put opus's wide parenthetical through a round. Sol's r62b flag on `OPS-23` ("That scope extension should
     be deliberate") bears on it.
2. **`API-40`'s `WIR-2` attribution.** Opus and sol give different texts. Any merge of them is a manager
   synthesis and needs a round. The drafted text passes every gate but breaks `AGENTS.md`'s rule.

# r62d (closing round), launched 2026-10-22 17:57Z: /var/tmp/provisiond-panel-r62d/

Items: (1) a1 NARROW vs WIDE + SCOPE/MECHANICS label; (2) `API-40` OPUS vs SOL; (3) confirm folds f1 `WIR-47`,
f2 `CNF-342` `a/b`~`a~b`, f3 `CNF-18` pointer. Outcome rules fixed before launch (r62d/notes.md): majority with no
CANNOT ACCEPT = settled; a1 labelled SCOPE by a majority → one owner question; still split → stop, no r62e.
Tallied 2026-10-22 by a fresh manager. All four exited 0: fable 1880 B, opus 2188 B, astra 1280 B, sol 1213 B.

## r62d votes, one line per reader

- **fable:** (1) NARROW ACCEPT, WIDE ACCEPT, PICK WIDE, MECHANICS. (2) OPUS ACCEPT, SOL CANNOT, PICK OPUS. (3) f1, f2, f3 ACCEPT.
- **opus:** (1) NARROW CANNOT ("two conforming answers"), WIDE ACCEPT, PICK WIDE, MECHANICS. (2) OPUS CANNOT (`WIR-12` half unquoted), SOL CANNOT, PICK neither + own text (opus2). (3) f1, f2, f3 ACCEPT.
- **astra:** (1) NARROW ACCEPT, WIDE CANNOT ("needs an owner decision"), PICK NARROW, SCOPE. (2) OPUS CANNOT, SOL CANNOT, PICK neither + own text (as2). (3) f1, f2, f3 ACCEPT.
- **sol:** (1) NARROW ACCEPT, WIDE CANNOT ("requires an owner decision"), PICK NARROW, SCOPE. (2) OPUS CANNOT, SOL CANNOT, PICK neither + own text, word for word astra's (as2). (3) f1, f2, f3 ACCEPT.
- Brief errors: none, from all four.

## r62d outcome under the fixed rules

- **(3) settled, 4-0 each.** f1–f3 marked reviewed (r62d) in final-form.md. No text change; the patch is unchanged.
- **(1) split: stop.** PICK 2-2, LABEL 2-2, split by vendor (Claude WIDE/MECHANICS, codex NARROW/SCOPE). No SCOPE
  majority, so no owner question under the rules. NARROW's 3 accepts carry opus's CANNOT ACCEPT, as in r62c.
- **(2) split: stop.** SOL 0-4. OPUS 1-3. Two replacement texts (as2: astra = sol; opus2: opus), each seen only by
  its author(s). Folding either is a manager pick and needs a round.

## r62d reader claims checked (fresh clone of 07bac41 + final-form.patch)

- **True (fable, f1/brief).** `OPS-23` at `03:1884` "For create, install, power and delete"; `trust` required on
  `rootfs_via_rescue` and `raw_disk` at `13:689`; `HISTORICAL`'s `withdraw` at `tools/check_citations.py:293`.
- **True (fable, opus, sol, f1).** `13:28` bold sentence "Unknown fields in a request body MUST be rejected" matches
  `WIR-47`'s quote exactly (the gate skips that sentence, so this is the hand check).
- **True (all, f2).** RFC 6901: `~`→`~0`, `/`→`~1`, so `a~b`→`a~0b`, `a/b`→`a~1b`; '0' < '1'. Raw: '/' 0x2F < '~' 0x7E.
- **True (fable, opus, sol, f3).** `CNF-19` (`10:133`) tests the outer provision-capability gate with the driver flag
  permissive; `CNF-55` (`10:321`) tests `allow_orders: false` at 5d and at `OPS-43` step 3.
- **True (all four, item 2: the manager's claim).** Under SOL a field-less `invalid_request` satisfies both quoted
  sentences, so "satisfies one and violates the other" loses its premise.
- **True (fable).** The gate's `SPEECH` is `says|said|states|stated|reads|read` (`tools/check_citations.py:215`), so the
  unquoted "`WIR-12` requires …" is never quote-checked.
- **True (opus, opus2).** Both quotes verbatim (`13:28-29` in the patched text; `13:428-429`). Six text gates exit 0.
  Each quote planted false → citations exit 1. Semicolon join → citations exit 1: "attributes to WIR-2 a phrase
  WIR-2 does not contain: absent, expired, …".
- **True (astra, sol, as2).** All three quotes verbatim (`13:28`, `13:28-29`, `13:429-430`). Six text gates exit 0;
  each of the three quotes planted false → citations exit 1. Sol's and astra's full `check-all.sh` claims not
  re-run by the manager.
- **Manager observation, unvoted:** as2's `WIR-12` quote is `WIR-12`'s restatement of `API-40`'s own precedence
  (the clause ends "`API-40`'s stated precedence"), so quoting it as one of the two conflicting MUSTs is circular.
  opus2 quotes the real MUST, but (opus) a field-naming answer breaks none of those words. Behaviour is fixed by
  `04:768`'s MUST either way; this is wording inside Open 2.

## r62d gates

`/var/tmp/provisiond-panel-r62d/gates.sh <name> [variant] [gate…]` (fresh clone of 07bac41 + final-form.patch +
`variants.py` variant; logs in `r62d/gates/`):
- final: citations 0, ids 0, fixtures 0, obligations 0, coverage 0, regions 0. Clone diff byte-identical to the patch.
- opus2: all six 0 (`candidate-opus2.patch`). as2: all six 0 (`candidate-as2.patch`).
- Plants, citations only: opus2-semicolon 1, opus2-plant-wir2 1, opus2-plant-wir12 1, as2-plant-wir2a 1,
  as2-plant-wir2b 1, as2-plant-wir12 1.

## Open after r62d

1. a1: 2-2 on pick and label. Routing (owner question despite no SCOPE majority, or land NARROW + candidate bead 4)
   is the coordinator's call.
2. `API-40`: as2 vs opus2, each unvoted by the other side; the manager's circularity observation is unvoted too.

## After r62d (2026-10-22)

- Owner on a1: "Wide: all four ops (Recommended)". WIDE folded into final-form.patch/.md ("r62d + owner"); six
  text gates on a fresh clone exit 0 (`r62d/gates/final-wide.*`), and with as2 or opus2 on top (`wide-as2`,
  `wide-opus2`). Candidate bead 4 dropped.
- r62e (`API-40` only, as2 vs opus2) launched 18:17:55Z: /var/tmp/provisiond-panel-r62e/ (notes.md holds the
  outcome rules and the tally steps).

# r62e (`API-40` attribution span only), launched 2026-10-22 18:17:55Z: /var/tmp/provisiond-panel-r62e/

Options: as2 (astra + sol, r62d) vs opus2 (opus, r62d). Outcome rules fixed before launch (r62e/notes.md): settled =
≥3 ACCEPT and no CANNOT ACCEPT; both settle → PICK majority, BOTH counting for each; anything else, including
replacement text, is split → stop, no r62f. Tallied 2026-10-22 by a fresh manager. All four exited 0: fable 1262 B,
opus 1520 B, astra 1070 B, sol 1074 B (no session-limit bodies).

## r62e votes, one line per reader

- **fable:** as2 CANNOT (`WIR-12` quote has no MUST; it echoes "`API-40`'s stated precedence"). opus2 CANNOT with the next sentence unchanged (a field-first answer breaks no quoted `WIR-12` word). PICK opus2's span + own replacement next sentence.
- **opus:** as2 CANNOT (quotes `WIR-12`'s copy of the precedence, not the owner). opus2 CANNOT ("violates the other whichever way" fails). PICK as2 "if forced", plus own replacement span; next sentence unchanged.
- **astra:** as2 CANNOT (uses the consequence of the precedence to justify it). opus2 CANNOT (naming a field discloses no token category). PICK neither + own replacement span, next sentence AND the preceding bold sentence.
- **sol:** as2 CANNOT (quotes a consequence as an independent MUST). opus2 CANNOT (same reason as astra). PICK neither + own replacement: span word for word astra's; next and preceding bold sentences differ from astra's.
- Brief errors: none, from all four.

Replacement texts (each voted only by its author):
- fable: opus2 span; next sentence → "Selecting that field in a body that also carries a bad token means validating the body before the token is checked, which the order above forbids."
- opus: span → “Unknown fields…MUST be rejected” and “The field named…`WIR-9a`” (as2's `WIR-2` half) + "The other MUST is this requirement's own token check, stated above."; next sentence unchanged.
- astra: preceding → "**The order is stated explicitly as a precedence.**"; span → as2's `WIR-2` half + `WIR-12` says “absent, expired, unknown or already spent is `invalid_request`, and the message MUST NOT say which”; next → "The admission-first rule above determines which validation runs first when both faults are present."
- sol: preceding → "**The order is an explicit precedence.**"; span = astra's; next → "The rule above gives admission-token validation precedence over unknown-field validation."

## r62e outcome under the fixed rules

**Split: stop. No r62f.** as2 0-4, opus2 0-4; neither settles, and three replacement forms (fable; opus; astra≈sol) are
on the table. final-form.md and final-form.patch are unchanged; `API-40` stays open there.

Common ground (findings, not a recommendation):
- 4-0: as2's `WIR-12` quote is `WIR-12` restating `API-40`'s precedence (circular). 4-0: against `WIR-12`'s real MUST
  ("the message MUST NOT say which"), a field-first answer breaks nothing, so "violates the other whichever way" fails.
- fable and opus place the real conflict at `API-40`'s own token-first MUST (`04:768`); astra and sol drop the
  conflict claim and rewrite the preceding bold sentence, outside the designated span (sol says so).
- Manager observation, unvoted: under opus's form the other MUST is the precedence itself, so "The order resolves a
  conflict between two MUSTs" has the order resolving a conflict it is half of.

## r62e reader claims checked (fresh clone of 07bac41 + final-form.patch)

- **True (fable, opus).** "`API-40`'s stated precedence" closes `WIR-12`'s clause at `13:430` patched (`13:428` at
  bare 07bac41); the quoted "a body with both … naming no field at all" follows "so" and carries no MUST.
- **True (astra, sol).** “absent, expired, unknown or already spent is `invalid_request`, and the message MUST NOT
  say which” is `WIR-12`'s own text (`13:426-428`, wrapped); the citation gate matches it, and planting "tell" for
  "say" turns citations red ("attributes to WIR-12 a phrase WIR-12 does not contain").
- **True (opus).** "The admission token MUST be checked before any other validation of the body" is bold at `04:768`,
  above the span.
- **True (all four, reasoning).** A field-first `invalid_request` naming the unknown field says nothing about which
  of absent/expired/unknown/spent the token was.
- **True (fable, opus):** as2, opus2, the five plants and the semicolon join behave as the brief states (r62d gates).
- Opus reports one rule breach: a helper script written to `/tmp` outside its clone, then deleted. Not a vote issue.

## r62e gates (manager re-run: r62e/verify-gates/{forms.py,gates.sh}, logs alongside)

Fresh clone of 07bac41 + final-form.patch + each reader's full replacement:
- fable: citations 0, ids 0, fixtures 0, obligations 0, coverage 0, regions 0 (fable claimed citations only).
- opus: all six 0; unquoted attributions "22, none new against baseline 22" (as claimed). Plants: `WIR-2` "rejected"→"refused" citations 1; "selected"→"chosen" citations 1.
- astra: all six 0 (astra claimed citations only; its full gates were unfinished).
- sol: all six 0 (as claimed). The astra/sol span with "say"→"tell" planted: citations 1.

## Open after r62e

1. `API-40`'s attribution span: split, routing is the coordinator's. Four forms (fable, opus, astra, sol), each
   gate-green and each unvoted by the other readers.
2. Unfiled report items unchanged: candidate beads `PRV-47` mixed rejection, `DOM-10` admission gap, the citation
   gate's "withdrawal" filter; opus's non-bead note on `API-40`'s rationale wording.

## After r62e (2026-10-22)

- Coordinator's routing: delete `API-40`'s conflict rationale, don't reword it (owner's standing lesson: prefer
  deleting an unsupported clause). One deletion form `del` (`../provisiond-panel-r62f/variants.py`); six text gates
  exit 0 on a fresh clone; control plants in the paragraph: true quote 0, false quote 1.
- r62f (`del` only; ACCEPT/CANNOT; a CANNOT must name lost normative content to block) launched 18:51:17Z:
  /var/tmp/provisiond-panel-r62f/ (notes.md holds the outcome rules and the settle steps). No round after r62f.

# r62f (`API-40` deletion `del` only), launched 2026-10-22 18:51:17Z: /var/tmp/provisiond-panel-r62f/

Form: `del` deletes `API-40`'s conflict rationale ("The order resolves a conflict between two MUSTs…" through
"…whichever way a handler goes.") and opens the outcome sentence "For a body carrying both a bad token and an unknown
field, **the token check wins**: …". Outcome rules fixed before launch (r62f/notes.md): ACCEPT or CANNOT only;
replacement text not counted; a CANNOT blocks only if it names lost normative content; settled = ≥3 ACCEPT and no
valid CANNOT; anything else stops, no r62g. Tallied 2026-10-22 by a fresh manager. All four exited 0: fable 1079 B,
opus 1267 B, astra 602 B, sol 538 B (no session-limit bodies).

## r62f votes, one line per reader

- **fable:** ACCEPT. Only rationale goes; the MUST at `04:768`, the response at `04:772` and `WIR-12`'s restatement at `13:429-430` remain. Brief errors: none.
- **opus:** ACCEPT. What goes is the "conflict between two MUSTs" claim and two restatements of unchanged rules; `13:430`'s "`API-40`'s stated precedence" still resolves to `04:772`. Brief error (harmless): "A body" also became "a body".
- **astra:** ACCEPT. `04:768` and `04:772` retain the MUST and the response; `13:429-430` independently retains both. Brief errors: none listed.
- **sol:** ACCEPT. Same three anchors; no repository reference depends on the deleted rationale. Brief errors: none.

## r62f outcome under the fixed rules

**Settled: 4 ACCEPT, 0 CANNOT.** `del` is folded into final-form.md and final-form.patch, marked reviewed (r62f).
final-form.md: "Nothing is open".

## r62f reader claims checked (fresh clone of 07bac41 + final-form.patch.bak-r62e + `del` = `gates/variant-r62f-final`, diff byte-identical to `candidate-del.patch`)

- **True (all four).** `04:768`: "**The admission token MUST be checked before any other validation of the body**".
  `04:772`: "For a body carrying both a bad token and an unknown field, **the token check wins**: the response is
  `invalid_request` with no `details.field` and no token detail."
- **True (all four).** `WIR-12` at `13:426`; "the message MUST NOT say which" at `13:428-429`; "that check precedes
  `WIR-2`'s unknown-field rule, so a body with both a bad token and an unknown field is refused naming no field at
  all" at `13:429-430`, ending "`API-40`'s stated precedence". `WIR-2` at `13:28-30`.
- **True (fable).** `Admission.lean:27-29` quotes "`API-7`'s ordering applies to authenticated endpoints", still at
  `04:766`. `tools/citation-baseline.json:22` is `"13-wire-contract.md:API-40"`. `CNF-76` (`10:450`) cites only
  `API-33`, `WIR-49`, `WIR-12`.
- **True (opus, brief error).** "A body" → "a body" is a change the brief's list omits. No effect.
- **Imprecise (opus).** "grep for 'two MUSTs|stated as a precedence|whichever way a handler' … finds nothing else":
  `git grep` finds "two MUSTs" at `01:266` (`RSC-19`) and `03:637` (`LDG-10`). Both are unrelated; neither depends
  on `API-40`. Substance holds: no dependent.
- **True (astra, sol).** No repository reference depends on the deleted words: `git grep` for `API-40` near
  "precedence|conflict" finds only `13:430`, which still resolves.
- Gate claims: every reader ran citations only (exit 0); astra and sol say their full gate was stopped.

## r62f gates (manager, `../provisiond-panel-r62f/gates.sh r62f-final del`, logs `../provisiond-panel-r62f/gates/r62f-final.*.log`)

citations 0 (unquoted attributions 22, none new against baseline 22), ids 0, fixtures 0, obligations 0, coverage 0
(74 uncovered, baseline 75), regions 0. After the fold, a fresh clone of 07bac41 + the new final-form.patch alone
(`gates.sh r62f-applied`): all six 0 again, `git diff` byte-identical to final-form.patch. No formal or Lean build.

## After r62f

- Panel B is complete: final-form.md says "Nothing is open"; final-form.patch is the work order text.
- File with the drain PR (listed at the end of final-form.md): `PRV-47` mixed rejection, `DOM-10` admission gap,
  the citation gate's "withdrawal" history-word filter.
- Opus's r62d non-bead note is answered by the deletion.
