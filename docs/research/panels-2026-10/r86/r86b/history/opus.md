# r86 Panel G: opus reader answer

I read the pinned clone at `3109b5b`. I edited nothing, ran no gate or Lean, and wrote no temporary files. I applied notes.md rule 6 exactly as written.

## Votes

| Form | Acceptance | |
|---|---|---|
| Q1-A | **ACCEPT** | **Final Q1 pick: Q1-A** |
| Q1-B | **ACCEPT** | |
| Q1-C | **CANNOT ACCEPT** | |
| Q2-A | **ACCEPT** | **Final Q2 pick: Q2-A** |
| Q2-B | **CANNOT ACCEPT** (blocking trace below) | |

I propose no alternative form.

## Q1: where non-create operations check capability

### The cases, checked against their owners
- **Power and hard reset.** Both A and B check after `OPS-23`'s repeated validation and before the provider call. `OPS-45` sets the marker "when the provider call is dispatched", so the check comes before any marker. Under `OPS-11`'s last row a failure there settles `failed`. A also refuses at admission with `DOM-10`'s 501.
- **Install strategies and `rescue_ssh`.** `DOM-10`'s table maps each strategy to its own capability. Begin rescue separately carries "**Capability** — `rescue_ssh`" (`02:720`), so the A/B order (strategy capability, then `rescue_ssh`, then begin rescue) only spells out what `DOM-10` already implies.
  - `CNF-302` (`10:3050`) drives "a `rescue_ssh` capability refusal (`DOM-10`)" and asserts `rescue_exited_cleanly` **null**. Both forms put the check "before either OPS-45 marker is written", so that verdict holds.
  - Under A, that `CNF-302` path is reached by a restart between admission and claim. It stays reachable, and its `OPS-40` alternative is unchanged.
- **Rescue inventory.** `rescue_ssh` only, checked before the rescue marker. `CNF-201` is unaffected.
- **Reverse DNS.** `PRV-25` (`02:855`) says "After the ordinary authorization, capability and `API-16` validation, the worker MUST compare…". Both forms keep the identical-PTR success after the capability check. `CNF-334`'s "Retain the capability check" (`10:4238`) is unaffected.
- **Caller delete/cancel.** This is not an exposure-reducing cancellation (`CONTEXT.md:478`: "the set's umbrella for the system's own destruction paths"). It has no no-call branch at claim.
- **System children (exhaustion, suspend fan-out, outage bound).** Both forms gate them only at claim, after `OPS-41`'s restore gate and ordered decision.
  - Gone or closed episode (`03:1080`, "The worker makes no provider call and settles the attempt `succeeded`"): no capability check, success kept.
  - Restored grace (`03:1001`, "the claim MUST defer"): no capability check. The defer stays a defer.
  - Renewed funding (step 3): no-call success kept.
  - So no added gate overrides a no-call success or turns a defer into a terminal failure.
  - The suspend parent gets no per-machine check, which matches `04:713` ("`unsupported` on an account that never declared `delete_machine`" as a child-level outcome).
- **Cancelled before dispatch.** `API-58` step (4) and the queued system cancellations an account termination fails both settle a never-claimed operation. Neither reaches a claim-time check, under either form.
- **Operator retry (`API-64`).** A checks at admission and at claim. B checks only at claim, after `OPS-41` step 2.
- **Attachment release, both origins.**
  - Operator `api` row: A checks at admission and claim; B at claim.
  - Release enqueued by a delete's terminal transaction: claim only, under both.
  - `manual` row: no check, under both.
- **Local validation.** Both forms put capability after all admission-side checks (`API-13`, `API-14`, `API-16`, `WIR-30` eligibility, `OPS-40` at accept) and after worker-side validation. No validation refusal moves behind or ahead of anything it currently precedes.

### Traces for the disputed points

**1. Q1-A refuses some retries a claim could have closed (affects only A).**
- A stalled episode has a null fence. For example, an earlier attempt failed `incomplete_record` before the fence transaction, and the account was later restarted without `delete_machine`.
- The tenant tops up. The operator retries.
- Under A: 501 at admission.
- Under B: the retry is admitted. Step 2 says "A retry reading the fence null decides from step 3" (`03:1087`). Step 3 finds the machine funded and settles a no-call `succeeded`, closing the episode `funded`.
- Under A the operator still has `API-68` keep (close reason `kept`; the fence is cleared and the runway re-derived). No `CNF` or Lean theorem asserts the retry route.
- I count this as a narrow difference, not a blocking loss. It is an operator request the account cannot execute, which is the case 5c says a ceiling exists for.

**2. A fenced stall with no provider call (both A and B).**
- Both forms check capability "after the fence transaction is acknowledged".
- A delete-incapable exhaustion attempt therefore fences, fails, and leaves the episode `stalled` with the fence unchanged (`03:1301`, "`failed` — deterministic; the provider did not act | `stalled` | **Unchanged**").
- `LDG-62` (`03:1233`) then refuses the tenant's extension until the operator keeps.
- This matches `OPS-42`'s 2026-10-04 settlement ("keep supplies that explicit decision"). Under `PRV-13b` (`02:299`, "an API path to stop the cost"), an account without `delete_machine` cannot have sold the machine, so the case needs a capability withdrawn after the sale.
- It is a design cost, not a MUST conflict.

**3. Q1-C leaves the phase to each implementation.**
- A hard reset on an account without `hard_reset`: one build answers 501 at once, another answers `202` and then fails the operation `unsupported`. Both conform to "before the driver is called" (`01:515–516`).
- An install whose capability was withdrawn and whose signed URL can no longer outlive the install: the failure kind differs by build (`OPS-40`'s error or `unsupported`).
- That is a client-visible split in a wire contract, and it is exactly what `pv-5pmu` asks to settle. It isn't a rule-3 loss, because nothing changes; my objection is that it doesn't answer the question.

### Why A over B
- A extends the create's two-phase design (5d at admission plus `OPS-43` step 3 at claim, owner ruling "MUST, not retryable") to every request, and keeps system children claim-only.
- B *forbids* the early refusal ("enqueues an otherwise valid request even when the running api descriptor lacks…"). So B is not only narrower: it bans a cheap, pure check that Q1-C permits.
- A's admission check runs after 5c (as 5d does), so it sits outside the Lean `admit` model, which covers steps 1–5c (`refusals_are_within_the_five_kinds`). No theorem changes.

### Wording points (not conditions on my vote)
- **`API-64` precedence.** A puts the check after "admissibility checks" but before "its state-change/enqueue transaction". `API-64`'s admissibility *is* that conditional write (`04:1052`).
  - So A effectively requires reading the episode state first.
  - A build that relies on the conditional write alone would answer 501 where another answers 409, for a non-stalled episode on a delete-incapable account.
  - No checklist verdict depends on this.
- **No Lean step for this path.** The fence model has no step for "failed after the fence without a provider call". `providerDelete false (some false)` reproduces the same world state, so `fenced_waits_for_the_provider` and `destroyed_only_by_provider_from_fenced` still hold. This applies to A and B alike.

## Q2: where a create's machine kind comes from

### Q2-A against every case asked
| Case | Result under Q2-A |
|---|---|
| Offer present; capability declared, fresh listing | 5d passes; tail; admitted, with `machine_kind` retained |
| Offer present; capability undeclared (fresh or old listing) | 5d 501 naming the offer kind's capability, before the tail. Same rank as today (Lean `age_preserves_step_5d`) |
| Offer present, declared, old listing, nothing collected | Existing stale-listing `provider` refusal, unchanged |
| Offer absent, or no stored listing | 5d skipped; the tail collects `offer_not_sellable`. Every such create is refused (`04:273`: "an unsellable offer for every rule in this tail"), so nothing is admitted ungated. Cap and balance are suppressed; no provider call |
| Unhealthy account plus absent offer | 409 `state` headline ahead of `offer_not_sellable` (panel-E settlement 1 holds) |
| Mixed account, both or one capability | Gate follows each offer's kind; the converse case is also tested |
| Mixed account, neither capability | Present offer: 501. Absent offer: 400 |
| Restart before claim, capability withdrawn | Step 3 gates on the retained kind, before List offers. `CNF-55`'s "no List offers read" is preserved |
| Retained kind missing or corrupt | `OPS-23`'s api-written rule: `conflict`/`incomplete_record`, `retryable: true`, before any provider request. Q2-A says the `api` writes the field, which satisfies `OPS-23`'s "MUST state whether the caller supplies it or the `api` writes it" |
| Live offer absent at claim | Existing step-5 refusal |
| Live offer's kind has changed | New step-5 `offer_not_sellable`: no price comparison, no mutation, full release, exclusion freed |

**Observable flip (disclosed, required to answer the question).**
- Today `CNF-55`'s 5d refusal (501, no refusals list) holds whether or not the named offer is in the stored listing.
- Under Q2-A, an absent offer on an account whose `allow_orders` is false gets `400 offer_not_sellable` with `refusals`/`not_checked` instead.
- Q2-A amends `CNF-55` and `CNF-19` to say the offer is present.
- This is forced. `DOM-10` requires naming "the capability", and for an absent offer the only ways to name one are the inferences the brief forbids.

**No owner ruling is violated.**
- `pv-p3k`'s ruling was about strength and retryability; both are kept for present offers.
- Admission still reads the stored listing with no provider call. 5d reads the same listing the tail uses, so `04:274–275`'s "No additional lookup is made" stays true.
- The age refusal is not moved.
- The per-item `CNF-55` qualification is about whether the offer is present, which the Form H header default (it governs listing age) doesn't reach. It doesn't replace that header.

### Q2-B: blocking loss
`DOM-10` (`01:515–518`) says "Every operation with a capability MUST be gated on it before the driver is called, **including create**" and "There MUST be no operation whose only gate is a driver-internal check". Its table (`01:526`) maps "create machine, `kind = bare_metal`" to `provision_bare_metal`.

Trace:
1. A descriptor declares `machine_kind: virtual` and only `provision_virtual`.
2. The driver's List offers returns a `bare_metal` offer, either as a bug or because the provider added a product line. `STO-60` stores that result.
3. Q2-B's 5d gates on `provision_virtual` and passes. The tail finds the offer present and admits the create.
4. At claim, step 3 passes on `provision_virtual` and step 5 finds the offer present. The order goes out.
5. Result: a bare-metal machine bought with no `provision_bare_metal` gate. The only barrier was Q2-B's new driver duty, "Every offer returned for the account MUST have that machine kind". That is the driver-internal reliance `DEF-10` names ("gated only by each driver's internal ordering flag"), which `CNF-19` exists to rule out.
6. Under Q2-A, 5d reads the offer's own kind and refuses naming `provision_bare_metal`.

Q2-B's added `CNF-19` text also demands checks nothing in the form can perform:
- **Mixed-kind detection.** It requires a configuration refusal "before enabling" for "an account selling both kinds". The descriptor is static, and Describe capabilities "MUST NOT perform network I/O" (`02:76`). The form names no read that could see the offers.
- **Kind changes.** It also requires refusing "a change of machine_kind for a retained account identity". The form persists no prior value, and `STO-21` (`05:684`) requires such state to "live in named tables".
- So that test has no defined mechanism to exercise.

Two further costs:
- **Scope.** All three v1 drivers (`ADR-0010`) sell one kind per account. A later dual-kind provider would need two account identities on one credential.
- **Second copy of `OPS-23`.** Q2-B's step 3 restates `OPS-23`'s MUST in unquoted words and drops "in the worker". That is the second-copy pattern AGENTS.md warns against.

### Is there a smaller complete form?
I found none. At admission, the only source the set already owns that exists before the tail is the stored listing's named offer. At claim, refusing before List offers needs a stored kind, and `request_summary` (a closed list under `STO-50`) is the owned record of accepted terms. Dropping step 5's kind-mismatch check would reopen `DOM-10`'s table gap at claim.

## Brief errors (rule 6)
None changes a question's premise, and none of my votes rests on one.
- The brief calls Q1-B "narrower than Q1-A". It also adds a prohibition that Q1-C does not have.
- The failure story implies that today a capability refusal could replace a no-call success. At the pin that would already be non-conforming: `03:1080` and `03:1001` say MUST, and `DOM-10` only says "before the driver is called". What is genuinely open is the admission phase, the order among local failures, and whether the check comes before or after the fence.
- Both Q2 forms' `OPS-43` step 3 rewrites drop three gate-checked quotations: `OPS-23`'s colon quote, `PRV-8`'s "at least one SSH public key" and `PRV-10`'s "the account is configured to allow ordering". Restating claims about other requirements without quoting them falls short of AGENTS.md's completion rule. No test pins those quotes, and `PRV-10` (`02:162`) still points at step 3. This is editorial, and I am not conditioning my vote on it.
- Lean `createPurchaseTail`'s docstring (`Admission.lean:1181–1194`) stays true under Q2-A, but `orderingDeclared` must then be read as "5d passes", which is true for an absent offer. A one-line docstring follow-up is advisable. No theorem or witness changes: `undeclaredOrderingCreate` uses a sellable, present offer.

## Cross-check of Q1-A with Q2-A
- Q1-A's text covers only non-create operations and leaves `DOM-10`'s create rows alone. Q2-A changes only 5d, the tail opening and `OPS-43` steps 3 and 5.
- Q1-A's `API-7` pointer follows the rewritten 5d. In `OPS-23`, the two inserts sit side by side.
- Replay, suspension and ceilings (5a–5c) stay ahead in both. `CNF-55`'s replay case is preserved.
- No purchase-tail rank moves, and panel-E's three settlements hold.

## Requested counterargument (not my vote)
- **Leave Q1 alone.** Every risky order (no-call success, defer, same-PTR, markers) is already pinned by existing MUSTs. What remains is error phase and kind among outcomes that are all `failed`, non-retryable and touch neither the provider nor money. The bead is P3, and `PRV-13b` keeps delete-incapable sold machines out of normal operation.
- **Leave Q2 alone.** Every launch driver is single-kind, so the two engines `pv-e45e` contrasts can't diverge on any v1 configuration. The issue is P4 and latent. A dual-kind driver's ADR could decide it with real provider facts, instead of adding a persisted field and a fixture flip now.
