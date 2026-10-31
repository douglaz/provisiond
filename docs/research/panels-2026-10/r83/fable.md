**Verification result.** Every pinned quotation in the brief matches the clone at 3109b5b line for line. The bead rows and triage rows in `check/` match the questions. I found no brief error that changes any question's premise, so no tally is void under rule 6. Non-void brief defects are listed under each question. One applies to every printed form: the forms omit the backticks the citation gate reads around identifiers and quotes; that is a landing convention, not a substantive change, and I do not count it against acceptability.

**Formal scope, checked.** No printed form touches a modelled property. The two API-58 declarations are `reap_refuses_active` (`tools/formal/Provisiond/Funding.lean:1011`, the reap refusal) and `suspend` (`Fence.lean:1083`, sets a flag and enqueues one cancellation). `Claim.lean:14-16` lists among its omissions "`API-58`'s fan-out transition (`pv-vwe.6`)" and `OPS-27`'s resolution writes. `AccountStatus.lean:13-15` says "Not modelled: `API-63`'s recording transaction — ... its contention with admission on the account row". `Admission.lean:40-41` says the tail "does not read provider-account or machine rows". `Reconcile.lean` models one create's knowledge, as the brief says. The LDG-32 declarations model release amounts, not which transaction triggers them. So all four questions sit outside the current model, and no theorem needs weakening or extension to accept any form.

---

**Q1 — pv-gvc.** Preferred form: **Q1-B**.

Acceptability: Q1-A ACCEPT, Q1-B ACCEPT, Q1-C ACCEPT, each with one condition stated below.

Release ownership. LDG-32 owns the rule, and its outcome list reaches the administrative transition: `12-billing-and-ledger.md:310-312` says release is due on "**every** terminal outcome: ... the create fails deterministically". A step-(4) create has "touched no provider" (`04-api-contract.md:630-631`), so it is a deterministic failure in that sense. What no text supplies is the writer's own money order, and every other writer in this set states it: the worker (`05-persistence.md:34`: "take the `LDG-35` primitive, make this guarded status write, then release"), the startup pass (`OPS-15`: "Only if the status write affects a row MUST the same transaction close and release the commitment in full"), and the termination (`04-api-contract.md:1375-1377`: "transition every `queued`, never-claimed create ... **and close and release its commitment**"). API-58 step (4) says nothing about money, while API-63 asserts "exactly as `API-58` step 4 does for a suspension". At the pin that assertion has no sentence behind it, which is the AGENTS.md failure shape. Q1-B's insert gives API-58 the duty, places it in the same transaction, after the generation check and the tenant primitive, with the status write short-circuiting the release on zero rows. That matches STO-3's stated order and makes API-63's existing sentence true. So the test alone (A, C) is acceptable because LDG-32 already owns the outcome, but the duty's placement needs the rule, which is why B is the complete form.

Coverage of the five bad builds:

- Deleted origin term: all three vary `requested_by` system and operator on fresh fixtures. Caught.
- Deleted parent-unsettled term: all three run the settled-parent and stale-old-parent cases. Caught.
- Lost claim race: all three race both orders and assert the claim number survives. Caught.
- Kind filter handling only power: A and C both catch it. A build with a {create, install, power} allowlist passes C and fails A.
- Missing create release: all three assert full release and no fee or first-unit debit. Under A and C the only normative basis is LDG-32's outcome row. Under B the writer's transaction is named.

Conditions and non-void defects:

- Every Q1 form's CNF text says a claimed create "follows OPS-43's tenant-status refusal". No such refusal exists at the pin (`03-operation-lifecycle.md:776-784` reads only "the provider account's stored status"). Each Q1 form is acceptable only landed together with, or after, a Q4 form. If Q4 does not settle, that sentence must be removed before landing.
- Q1-A says "WIR-10's operation-kind set". The closed kind enum is WIR-10a's (`13-wire-contract.md:271-273`). Editorial owner correction.
- The "tenant active" fixture with an unsettled parent is unreachable through the API, since WIR-41 refuses resume while the parent is unsettled. As a store fixture it is valid, and the text says so.

Break fixture: none found for any form. The three writers are distinguishable in each form: the store write is guarded on `status = queued`, the worker's settlement on `(running, claim_number = mine)`, and a dispatched order is `running` with the column set and is unreachable by the administrative write.

Don't-build, on request: adding a money sentence to API-58 gives release mechanics a second home beside STO-3 and LDG-32, and a future amendment to one can drift from the other. Counter: OPS-15 and API-63 already carry their own copies for the same reason, and the guard protects nothing that B removes.

Follow-ups: STO-58 frees an `offer_is_resource` exclusion on "the winning create's outcome settlement" and CNF-202 should assert it for a step-(4) failure (overlap with #47). API-58 step (4) states no `retryable` for its failure; see Q4.

---

**Q2 — pv-bxh.** Preferred form: **Q2-A**.

Acceptability: Q2-A ACCEPT, Q2-B CANNOT ACCEPT, Q2-N CANNOT ACCEPT.

Q2-N fails its own acceptance test. No existing clause yields a value: WIR-9a's two account rows key on the "collection-snapshot `STO-47` status" (`13-wire-contract.md:171-172`), which was `healthy` in the race; API-7's constant false is "specific to the resource-offer guard" (`04-api-contract.md:302`); API-63's values at 1423-1427 are the worker's step-8 mapping. DOM-17 gives the meaning of the field, not a value.

Q2-B borrows the resource-offer guard's false without a ruling and contradicts DOM-17 on a concrete refusal. `01-domain-model.md:656-657`: "`retryable` describes whether repeating the *same request* is safe and sensible." Interleaving: a healthy snapshot, then `account_unreachable` commits before the conditional write. Q2-B answers false. The account recovers an hour later and the same request would succeed. One step later on the same condition, API-63 gives true and says why: "presenting an unreachable account as a permanent termination is false" (`04-api-contract.md:1423-1424`). The offer guard's false has a permanent reason (the offer is gone); this refusal does not.

Q2-A names the mechanism the brief asked for. A zero-row UPDATE returns no status; `SELECT ... FOR UPDATE` first does, and under READ COMMITTED it returns the latest committed version after any in-flight recording commits, so the status it returns is the one the guarded write then tests. The recording transaction's own write of STO-47 blocks on that lock, so recovery cannot change the status under a decision already taken. Lock order: the admission already holds the tenant's LDG-35 primitive and already locks the account row at its UPDATE, so Q2-A moves the row lock a few statements earlier and introduces no new ordering. The pre-existing hazard is API-63's recording transaction, which does not say whether its tenant primitives are acquired before its status write; if after, the two deadlock and PostgreSQL aborts one. That is not Q2-A's defect and is a follow-up. Q2-A's "A serialization failure is not a non-healthy status" is right and is the branch the test under snapshot isolation would otherwise misread.

Non-void defects in Q2-A, none blocking:

- The replaced API-63 sentence carried the rationale "so a create admitted after a termination is impossible rather than merely unlikely ... which is `OPS-42`'s shape". Q2-A drops it. Rationale, not a MUST.
- The landing instruction names "the Second barrier sentence and its following explanatory sentence", but `10-conformance-checklist.md:2939-2942` is one sentence ending "snapshot isolation." Locatable.
- Neither Q2-A nor Q2-B states the response shape of this refusal: an ordinary WIR-9 error, as the offer guard's is, or a one-entry refusals list. Either way WIR-9b makes the value determinate. Follow-up.

Break fixture: the deadlock interleaving above, pre-existing, not specific to Q2-A.

Don't-build, on request: the explicit `FOR UPDATE` on a hot per-account row lengthens every create's admission lock footprint, and the constant-false mapping needs no lock. Counter: the lock is already taken at the UPDATE; the only new cost is ordering it before the write, and the constant value is the DOM-17 contradiction above.

---

**Q3 — pv-y0to.** Preferred form: **Q3-A**.

Acceptability: Q3-N ACCEPT, Q3-A ACCEPT, Q3-B ACCEPT.

The automatic path exists at the pin, so I name it before judging the forms. Discovery and owner: `03-operation-lifecycle.md:95-96` says resolution transitions are made "by `OPS-27`'s sweep or `OPS-31`/`WIR-35`'s operator verb", and lines 76-77 say "`OPS-27`'s evidence sweep is itself automatic and does move the state"; OVR-17's row assigns "`OPS-27`'s resolution sweep" to `engine`. Per-kind dispatch: `02-provider-contract.md:1114-1115` says "Per mutation kind it can be asked to resolve, a driver MUST declare its evidence sources", in PRV-44's descriptor. Window origin: `02:1141-1143` says "`OPS-27`'s resolution MUST NOT take its first read before the window has elapsed from the end of the mutating call's wait", which binds OPS-27's resolution to non-create reads. Cadence: `00-overview.md:445-447` says "its resolution read MUST be issued within that cadence". Guarded settlement: `05-persistence.md:59-60` guards it on "(id, status = needs_reconciliation, resolution IS NULL)", STO-19 makes it write-once, OPS-3 lists the exact `applied`/`not_applied` transitions. Operator fallback: `03:1522-1524` says resolution "proceeds by `PRV-29`/`PRV-36`'s provider evidence where the driver can produce it, falling back to `OPS-31`'s `applied`/`not_applied`/`abandoned` where it cannot". CNF-237 already requires an ambiguous delete to resolve this way, and CNF-329 requires the cadence enforced.

Two kinds of mutation, separately. Provider-managed kinds (delete, power, reverse DNS, release attachment, `provider_native` and `provider_catalogue` installs) have a provider-side action to read: the write path's own report, the action history, or the resource read after the window. Rescue-based disk writes and rescue inventory have no provider mutation to read; their ambiguity is the engine's own disk write and the rescue exit, and PRV-29's path yields nothing truthful about a disk's contents, so the chain delivers them to OPS-31, where `not_applied` is refused with a set marker. Ordinary machine presence proves nothing about either; no form claims otherwise.

Why Q3-A anyway. OPS-27's own body is create-shaped from its second sentence on, and OVR-17's rationale reads "It searches providers by correlator". A builder reading OPS-27 as the definition of automatic resolution reaches pv-y0to's conclusion. Q3-A adds no behaviour; it tells OPS-27 that its sweep covers non-create operations and points at the owners. Q3-N is acceptable on the chain above, but leaves the misreading in place.

Q3-B is internally consistent and I found no contradiction, so I accept it. It is not preferred because it writes second copies of MUSTs owned elsewhere: OVR-19's cadence ("Reads MUST be issued within OVR-19's stated resolution-read cadence"), OPS-28's no-mutation rule, and STO-19's write-once rule, which AGENTS.md warns is how copies drift. It also adds one new obligation nothing else carries: "Record ... the resolving engine identity with the resolution", a content rule for `resolved_by` with no STO-8 edit. Its CNF-237 append is good coverage, including the operator-wins-the-guard race.

Break fixture: none found. Q3-A's "the correlator search and outcome table below apply to create only" is true; the table's four rows all act on a resource to attach and a commitment.

Don't-build, on request: the chain exists and every added sentence in OPS-27 is a second home. Counter: Q3-A's one paragraph names owners and quotes OPS-28; it restates nothing, and the OVR-17 rationale it replaces is the one sentence in the set that actively says "correlator" where the component also reads evidence.

---

**Q4 — pv-kv2.** Preferred form: **Q4-A**.

Acceptability: Q4-A ACCEPT, Q4-B CANNOT ACCEPT, Q4-C ACCEPT.

Policy test. A create first claimed while the tenant is suspended cannot enter the residue under A or C: the step-1 read (A) or step-3 read (C) sees the committed flag, since API-58 "(1) marks the tenant `suspended` **in the admission transaction, before the `202` is returned**" (`04:618`). A create that reads active while a suspend transaction is uncommitted was not yet suspended at pickup; its step-8 tenant write blocks on that row's lock and re-evaluates to zero rows when the suspend commits, which is "one provably loses". The only create that reaches the residue passed the guard while active, which is the "claimed before the suspension landed" case the owner kept. A stricter boundary is impossible: `12:465-467` forbids waiting on "any provider call" under the primitive, and a last plain read is not race-free. The step-8 boundary is the existing account-termination shape (`04:1437`: "A claimed create with `about_to_order_at` set MUST be treated as potentially dispatched"). I therefore do not reject on boundary grounds.

Mechanics checked against the pin:

- Kind and reason: `conflict`/`tenant_suspended` is already in WIR-9a's union (`13:141`) and is what API-58 step (4) uses for the same situation; the admission-only kind `suspended` is forbidden to a worker (`03:264`).
- Settlement: OPS-11's create row (`03:250`) settles any pre-step-9 recorded failure `failed`, and "a failure classified `failed` without this pre-step-9 rule keeps its stated `retryable`", so the forms must state the value, and they do.
- Lost acknowledgement: the forms mirror the existing account-status sentence (`03:793-797`); the repeat can fail with the column set and still settles under the create row.
- Lock order: the step-8 transaction takes STO-47's row then the tenants row; the suspend admission takes the tenants row only; API-63's recording takes STO-47's row and tenant primitives, never the tenants row. No cycle.
- Step (2) replacement: "its machine follows OPS-27's suspended-attach cancellation" is right, since OPS-27's clause "applies at **all three** entry points" (`03:646`), including settle-time verification; the re-sweep text later in API-58 is untouched and finds that episode already open. The quoted "claimed before" sentence does need replacing: with a guard, a claim no longer licenses purchase, and the sentence as pinned says it does.

Retryability. Q4-B's true fails DOM-17 on the concrete case: while the tenant is suspended, the same request is refused at API-7 step 5b with the 403 kind `suspended`, and the condition clears only by an operator's resume, after which the fleet is gone and a create is a fresh decision. `halted` and `account_unreachable` are true because a system gate "can clear" on its own; suspension is a judgment about the caller, and API-51 makes the field "normative for callers", so true instructs an agent into repeated 403s. A is the DOM-17 reading. C's only difference from A is precedence: a suspended tenant whose channel is closed is told `rate_limited` with `retry_after_ms`, inviting a retry that admission will refuse `suspended`. Acceptable, less honest, not preferred.

Non-void defects:

- API-58 step (4)'s own `tenant_suspended` failure carries no stated `retryable` at the pin, and CNF-202 does not assert one. Q4 lands a value for the worker's path only. Coordinated follow-up: give step (4) the same value and assert it in CNF-202, or the same reason carries two values by path.
- WIR-9a's union cites `API-58` alone for `tenant_suspended`; OPS-43 becomes a second emitter. Editorial.
- The forms do not extend the rule to a claimed power or install after suspension, and I do not propose that here.

Break fixture: none found for A. Both orders of the step-8 guard against the suspend, the lost-ack repeat, and a crash between step-8 commit and step 9 (restart sends the set-column create to `needs_reconciliation`; resolution finds nothing ordered and releases) all land on the owner's outcome.

Don't-build, on request: a tenants-row write in every create's step 8 adds contention on a row the admission pipeline also reads, and the step-1 read alone satisfies the owner's story in the brief. Counter: the owner's option text says Panel D "settles the exact error and race guard", and without the guard the second story (read active, suspension commits, purchase) buys a machine the fence must then cancel at the customer's fee and first unit.

---

**Other-bead overlap.** pv-ip7 (CNF-360 recoverable statuses) is adjacent to Q2 but distinct. Q1 and Q4 share CNF-202 and API-58 and should land in Q4-then-Q1 order. The API-63 recording-transaction lock order noted under Q2 is a separate pre-existing finding.

Final Q1: Q1-B; acceptability A ACCEPT, B ACCEPT, C ACCEPT, each conditional on landing with or after a Q4 form.
Final Q2: Q2-A; acceptability A ACCEPT, B CANNOT ACCEPT, N CANNOT ACCEPT.
Final Q3: Q3-A; acceptability N ACCEPT, A ACCEPT, B ACCEPT.
Final Q4: Q4-A; acceptability A ACCEPT, B CANNOT ACCEPT, C ACCEPT.
