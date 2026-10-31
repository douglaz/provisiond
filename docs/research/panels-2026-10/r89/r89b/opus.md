**Seat: opus (r89b). Clone at `3109b5b44eae17e288cf52aaa976993bd8c5626c`, clean.** I read the brief and notes.md in full. I applied notes.md rule 6 exactly as written, and this prompt adds no void rule. I found no premise-changing brief error, so nothing is voided. I ran no gates or builds and changed nothing.

## Verdicts

| Form | Verdict | Reason |
|---|---|---|
| A | **CANNOT ACCEPT** | Drops the pinned unconditional `WIR-17` MUST (§2). |
| B | **CANNOT ACCEPT** | Same drop as A. It also copies the scope predicate into nine places; that is a maintenance objection, separate from rule 3. |
| C | **CANNOT ACCEPT** | Same drop. Otherwise it would be acceptable. |
| D | **CANNOT ACCEPT** | Same drop as A, plus B's duplication. |
| C′ | **CAN ACCEPT** as printed, with no fix | This is my pick. |

These verdicts say only what I can accept; my preference is separate. Among the printed forms other than C′, my order is C > A > D > B, and that order is not acceptance. I propose no new form. A fix to A that keeps the same three pinned blocks would be a new form that no other seat can read this round, so I'm not offering it.

I checked C′ mechanically. `diff form-C.md form-Cprime.md` differs only in the title, the change note and the three Replace→Retain blocks. Each retained block also matches the pin byte for byte (`cmp` against `13-wire-contract.md:665–666`, `10-conformance-checklist.md:256–279` and `:4311–4320`).

## 1. Corrections to my own r89 answer

- **"The brief does not disclose this flip": withdrawn.** The parent brief said the wire rule "gets the same scope predicate". What was missing was a trace showing what that change removes. That is not the same as the change being undisclosed.
- **"The api needs the offer's price … effectively becomes a per-offer runtime check before that snapshot is read": withdrawn as stated.** Under A–D, an engine may stay conservative and require the acknowledgement on every create. No rule forbids that rejection, so no reordering is forced. The accurate claim is narrower. A–D *permit* an engine to exempt a create whose offer is free. Such an engine has to classify the offer by step 5, but `API-7` reads offer data only in the tail ("the offers the check reads are the provider account's stored offer listing … read in that snapshot", 04:263–264). So two conforming engines may give different verdicts. The rule allows the exemption but doesn't require it.
- **CNF-316 as evidence of non-billing creates: withdrawn.** A zero `first_unit` can come from zero `seconds` at a positive price. The premise rests instead on the sources listed in §2.
- My "no case anywhere tests a create admission with the acknowledgement absent or false" was about admission only. CNF-182 does mention an absent acknowledgement, but as a Robot-driver test-mode assertion, not an API-7 admission case.

## 2. The manager's rule-3 loss: verified, with its scope stated

**The pinned MUST.** `13-wire-contract.md:665–666`: "`acknowledge_purchase` MUST be literal `true` (`API-15`, `PRV-10`)". It carries no condition.

**Who owns it.** `WIR-17` owns the field. `API-15` calls it "`WIR-17`'s top-level `acknowledge_purchase`, which the wire contract owns".

**Is the premise reachable?** Yes in the specification's model, though not in live v1 sales. The pieces:
- DOM-9 (01:168) allows `setup_fee` to be `"0"` "where the channel charges none" and does not forbid a zero recurring price.
- `LDG-39` (12:1242–1243) names "a positive `seconds` at a zero recurring price with a null floor".
- CNF-315 already uses "a zero recurring price and a null floor" as a fixture.
- 12:967 says "even with positive declared seconds at a zero price".
- I found no sale gate that forbids a zero price. `PRV-31` needs a cancellation bound, and `PRV-13b`/`ADR-0039` concern traffic and exposure. A conformance fixture can therefore build this offer legally.

**Trace.** Take a valid create on an offer with a zero recurring price, null floor and `setup_fee` `"0"`. The account is healthy and assigned, `allow_orders` is true, the idempotency key is fresh, and the body carries `acknowledge_purchase: false`.
- **At the pin:** API-7 step 5 ("deserialize and validate the body") applies `WIR-17`, giving 400 `invalid_request` with `details.field: "/acknowledge_purchase"` (WIR-9a row at 13:134; DOM-17 maps `invalid_request` to 400 at 01:581). A worker repeat of the same check is required by `OPS-23`. There is exactly one conforming verdict.
- **Under A–D:** every acknowledgement MUST is conditioned on a paid create: `WIR-17` "For a paid create (`DOM-16`)", `PRV-10`, and `API-15`. `OVR-6` (00:46) covers only "billable actions" and names no field, error kind or pointer, so it cannot stand in for the verdict. Does a zero-priced rental "start new provider billing"? The owner's own gloss, "'Orders off' means the account can't spend", points to *no*. Under that reading, no rule requires the refusal any more.

**What kind of loss it is.** A–D remove a required refusal. They do not force admission: an engine may still reject. The checked verdict goes from required to reading-dependent, which is the same "two engines can each cite the text" defect pv-9ecf was filed for. `CNF-34` ("On separate creates" becomes "paid creates") and CNF-342's fixture lose their non-paid instances as a consequence.

**Was it already authorized?** No. Owner item 4 sets a floor: "The switch and the per-request purchase acknowledgement cover any create that starts billing, hourly cloud VMs included." It decides which creates must be covered. It does not exempt any create. The bead's named owners are "`DOM-16`, `PRV-10`, `API-15`", not `WIR-17`. The parent brief disclosed the narrowing, and three seats accepted it, but neither of those is owner authorization. Under this brief's boundary ("dropping a check … beyond item 4 needs owner approval"), A–D carry a dropped check that item 4 does not cover.

**What this does not mean.** I don't claim any live v1 verdict flips, and none does. That limits the loss to modeled, fixture-legal cases. It doesn't make the loss go away.

## 3. Strongest reasons on each side

**For C, the alignment side (fable, astra and sol):**
- All three acknowledgement rules share one defined predicate.
- No live offer is free.
- The narrowing was offered openly.
- The hourly cases test the owner's exact failure story.

That last point is real, but **C′ keeps every hourly case byte for byte.** The alignment only matters for non-billing creates. In exchange it gives up a pinned refusal that nobody asked to give up.

**For retaining the pinned blocks (C′):**
- The unconditional rule requires a superset of `API-15`'s paid creates, so there is no conflict between them.
- The pin already had exactly this layering: `API-15` said "order-billed provider" while `WIR-17` was unconditional. C′ adds no new mismatch.
- Step 5 needs no per-create classification.
- CNF-34's colon quote of `WIR-17` stays a whole-sentence quote, as the "Quote the sentence" convention asks, rather than a quote that has lost its new condition.
- Fable's r89 answer already preferred to "keep lines 665-666 as pinned".

## 4. C′ as printed: losses and new obligations

- **New obligation, which needs owner approval.** The "Hourly cloud cases" paragraph in `CNF-55` is identical to C's. It adds:
  - a permissive fixture driver with a simulated-billing-start counter;
  - fresh-key 501 (ordering off) and 400 (acknowledgement absent and false) admission cases;
  - a positive control that reaches the driver exactly once;
  - the claim-time flag-flip case;
  - the stored-acknowledgement-removal case.

  This is implementation-conformance text. It is not a repository test and does not authorize a live sale; its fixture says it "does not authorize sale of a live offer withheld under `PRV-13b` or `PRV-31`".
- **Losses: none found.**
  - **Fixtures.** CNF-34 and CNF-342 are the pinned bytes. CNF-55's base text is unchanged apart from its heading. CNF-364's added `allow_orders: true` and `acknowledge_purchase: true` were already implied by "declares … the ordering capability" and by step 5, so they remove nothing.
  - **Check order.** No step of `API-7` or `OPS-43` is edited.
  - **Error details.** The hourly 501 matches WIR-9a's `unsupported` row at 13:142 and DOM-17 at 01:584. The 400 matches the field-pointer row at 13:134, which applies "also where the named field is absent".
- **Gate exposure, by reading only; no gate was run.**
  - `OPS-43`'s quotes "explicit purchase acknowledgement" and "the account is configured to allow ordering" both survive in C′'s `PRV-10`.
  - CNF-34's `WIR-17` quote is intact.
  - A grep finds the seven live alias sites (01:570, 02:159, 04:987, 00:412, 08:31, 09:163, 10:340), and C′ replaces all seven.
  - The only Lean reference to `WIR-17` is `Witnesses.lean:3271`, the create-body shape, which is unaffected.
- **Test strength:** stronger than the pin. It adds the admission 400 for an absent or false acknowledgement, which the pin lacks, and a 501 that names `provision_virtual`.
- **Editorial points, not blocking:**
  - DOM-16 drops ", not instead of,". "In addition to", together with `PRV-10`'s "Both, not either", still carries the obligation.
  - "Catalogue offer" is an undefined term, but its meaning can be recovered from `PRV-42`'s "Catalogue products do not take this claim".
  - CNF-182's driver-level "API returns a `Cancelled` transaction" is pre-existing.

## 5. Traces under C′ (from the text; nothing was executed)

1. **Hourly, positive price, no setup fee; `allow_orders: false`; acknowledgement `true`.**
   - DOM-16 says the capability "permits a paid create" ("hourly or other recurring machine rental; neither a setup fee nor immediate payment is required"), so the descriptor withholds `provision_virtual` and the listing omits it.
   - Step 5 passes, because the retained `WIR-17` is satisfied by `true`.
   - Step 5a: the fresh key has no stored result. Steps 5b and 5c pass.
   - Step 5d, `DOM-10`'s gate before the driver "**including create**", refuses with 501 `unsupported`, the account and capability in `details`, and `retryable: false`. "A refusal stops here and is not collected by the tail", so there is no commitment, no `details.refusals` and no driver call.
   - A same-key replay still returns its stored result at 5a.
2. **Same create, `allow_orders: true`, acknowledgement absent or `false`.** Step 5 rejects with 400 `invalid_request`, `/acknowledge_purchase`, `retryable: false`, before 5d and the tail. With `true`, the control is admitted and reaches the driver once.
3. **Claim time: admitted with both true, then restarted with `allow_orders: false`.**
   - `OPS-43` step 1 sees a healthy account and step 2 reads the closure locally.
   - Step 3 runs the caller-field checks (pass), then the api-field checks (pass), then the capability gate, which fails `unsupported`.
   - The create settles `failed` (`OPS-11`) and the commitment is released in full under `LDG-39`'s "Deterministic rejection before acceptance", with no debit.
   - Step 4's List offers read never happens, and no exclusion is held (`PRV-42`).
4. **Stored acknowledgement removed before claim.** The step-3 caller-field check fails first: `invalid_request` on `/acknowledge_purchase`, `retryable: false` on both the error and the view (`OPS-23`). Under C′ this holds for every create; under C it holds only for paid ones.

## Final

**Final: C′**

This is also my preference. C′ is C with only the three pinned blocks retained, so a seat that accepted C on the grounds of a single owner and direct hourly tests loses neither. Fable's stated preference already points this way.

**It is not wording-only under item 4.** Its normative edits word item 4 and drop no check. Its hourly conformance cases are an additional test obligation, so C′ goes to the owner as the recommended exact form. It is not ready-for-agent from this panel alone.

The manager's hold on C is correct: the rule-3 loss is verified as traced in §2, within the scope stated there.
