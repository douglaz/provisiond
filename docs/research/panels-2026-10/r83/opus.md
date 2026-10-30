# r83 Panel D: opus reading

Pin: `git rev-parse HEAD` returns `3109b5b44eae17e288cf52aaa976993bd8c5626c`. I read the brief and notes.md in full. A script I wrote under `tmp/opus/` compared all 35 pinned quotations with the pin: 34 matched exactly. The OPS-3 block contains a nested fence that the script couldn't parse, so I checked it by eye; it matches too. I ran no Lean, Nix or gate. I listed the panel directory once but didn't open any other reader's files.

**Rule 6.** I found no brief error that changes a question's premise, so nothing is voided. There are three minor label errors:
- The brief's "STO-8" label for the `operations` table. STO-8 is the tombstone rule at `05-persistence.md:498`; the table follows STO-8a. Q3-B repeats this as "STO-8's resolution row".
- Q1-A says "WIR-10's operation-kind set". The kind enum is WIR-10a's (`13-wire-contract.md:271`).
- "Its paragraph beginning 'A create that has produced no machine yet'" is a line inside a paragraph (`04-api-contract.md:661`). It's still easy to find.

No vote below depends on any of these.

---

## Q1: pv-gvc

**Who owns the release.** LDG-32 already owns the duty. It requires release "on **every** terminal outcome: … the create fails deterministically" (`12-billing-and-ledger.md:310–313`). The administrative transition is a deterministic, terminal `failed` with no provider contact. API-63 reads it the same way: "close and release its commitment, exactly as `API-58` step 4 does for a suspension" (`04-api-contract.md:1376–1377`). So asserting the release tests an existing duty; it isn't a new requirement.

What no text covers is the **transaction shape** of the administrative write. STO-3's rule, "The guarded status write precedes every money write in the transaction and short-circuits the rest", sits only in the worker branch. The fifth bullet (`05-persistence.md:64–72`) has no money clause. That leaves "release, then the guarded write" or a two-transaction build permitted. Q1-B is the only form that makes the shape normative. Its generation-check → LDG-35 → status → release order matches STO-3's worker entry order. That is the difference between test and requirement here.

**Which bad writes each form catches:**

| Bad write | Q1-A | Q1-B | Q1-C |
|---|---|---|---|
| Origin term deleted (system cancellation; operator API-64 retry) | caught | caught | caught |
| Parent-unsettled term deleted (settled parent; stale old parent after resume and re-suspend) | caught | caught | caught |
| Lost claim race (both orders) | caught | caught | caught |
| Kind filter that handles only power | caught | caught | caught, through its create and install cases |
| Create release missing | caught | caught | caught |

Q1-C misses a filter that drops `refresh`, `rescue_inventory`, `reverse_dns` or a caller `delete_machine`. STO-3's predicate has no kind term, so A/B's every-kind loop is the complete form.

None of the three forms forces a **create** into the "status running under a real claim" fixture. With a power operation there, a release-before-guard bug still passes. That's a coverage weakness, not a blocker.

**Separate problem: the prose and the printed guard disagree for a deferred operation.**
- API-58 says "`queued` but never claimed" (`04-api-contract.md:628`), and STO-3's bullet says "was never claimed".
- But the guard has no claim term: `(id, status = queued, requested_by = caller, …)` (`05-persistence.md:64–67`).
- The sibling guard in API-63 carries `claim_number = 0`, and its note says "Queued eligibility still requires never claimed, including after a defer" (`04-api-contract.md:1386, 1400`).

A fixture that breaks it:
1. A caller `provider_catalogue` install is claimed (claim number 1).
2. It yields, because RSC-41 says the operation "MUST import and poll the provider … while **yielded**" (`06-rescue-install.md:504`).
3. The suspension's system delete holds the machine, so clearing `yielded_at` is refused and the install defers to `queued` (`03-operation-lifecycle.md:213`).
4. Step 4's printed guard then fails it as `tenant_suspended`, and the record says "it has touched no provider" although the import did.

None of A/B/C changes or tests this. That's right: a test-only form shouldn't silently change the guard. It needs its own bead.

**How the three paths differ.**
- The store administrative write affects only `queued` rows.
- In the worker race, the pass reads C as queued, a worker claims it, and the administrative write affects zero rows. The worker then settles C (under Q4, by the tenant refusal).
- A dispatched order is never `queued`, so the administrative write can't reach it.

**Coordination with Q4.** All three Q1 forms say "follows OPS-43's tenant-status refusal". That's true only after a Q4 form lands, so Q1 must land with Q4 or after it.

**Formal scope.** `Claim.lean:17` omits "`API-58`'s fan-out transition (`pv-vwe.6`)". The LDG-32 declarations model release arithmetic, not which outcomes trigger it. No Lean change is needed.

**Strongest don't-build argument (requested; not my vote).** CNF-202 already exercises the path that's actually reachable. A fixture like "tenant active, parent unsettled" can't be reached through the API, because WIR-41 fences resume. Store-level cases pin SQL rather than observable behaviour. My answer: STO-3's predicate is itself normative. API-58 records that on 2026-09-05 a paraphrase dropped the `requested_by` term and let step (4) fail a system delete. Only a test of each term separately catches that.

**Follow-ups.**
- The deferred-operation guard bead above.
- The administrative `tenant_suspended` failure states no `retryable`; align it with Q4's value.
- An install failed this way must carry `disk_effect`/`rescue_exit` "whatever the kind" (WIR-9a); assert `none`.
- Assert that STO-58's exclusion is freed for an administratively failed resource-offer create, as #47 does elsewhere.
- Use a create in the claimed-running negative fixture.
- Add STO-3, LDG-32, LDG-39 and OPS-43 to CNF-202's citation list, plus the dated amendment note.
- Overlaps with other beads: pv-kv2 (Q4), pv-shub (exclusion fixture).

**Votes.** Q1-A ACCEPT · Q1-B ACCEPT · Q1-C ACCEPT (weaker). **Preference: Q1-B.**

---

## Q2: pv-bxh

**The premise holds; Q2-N cannot stand.**
- API-63's admission clause states no `retryable` (`04-api-contract.md:1407–1409`).
- WIR-9a's rows depend on the "collection-snapshot `STO-47` status" (`13-wire-contract.md:172–173`). In this race that status is `healthy`, so neither row applies.
- API-7's false is "specific to the resource-offer guard" (`:302`).
- WIR-9b only combines collected tail entries.

No existing clause yields a value, so two engines can disagree, as the bead's example shows.

**How Q2-A works.** A zero-row UPDATE returns nothing. Q2-A names how to keep the status: `SELECT … FOR UPDATE` returns the account row's current committed status and locks it. The guarded write then misses that same locked version, and the response keeps the locked status. A concurrent recovery waits on the row lock until the admitting transaction rolls back.

**Lock order.** The collection is taken "from one read-only snapshot inside the existing `LDG-35` transaction, without an extra lock" (`:263–264`), so the account lock must come after collection. The order is LDG-35 → collection → account row → commitment. Those are the same lock objects in the same order as the base's conditional UPDATE, which already holds that row lock until commit. Q2-A adds no new lock order.

**Transaction errors.** Q2-A rightly refuses to turn a serialization failure into this refusal. One caveat: under an isolation level that raises a serialization failure on the concurrent update, the zero-row path is never reached. The api doesn't repeat transactions ("a failed request transaction is the caller's `internal` error", `03-operation-lifecycle.md:1941`), so the fixture couldn't get a 409. The base API-63 ("where that write affects no row") and CNF-278 already make the same assumption. A fixture precondition note fixes it; I don't count it against the form.

**Editorial issues in Q2-A.**
- The replacement deletes "so a create admitted after a termination is impossible … which is `OPS-42`'s shape". The next italic note, "called it the same shape", then has nothing to refer to. Restore it as rationale; no rule or test is lost.
- Putting the row in WIR-9a's "Purchase-tail entries" table could suggest the refusal carries `details.refusals`. The base is already ambiguous here; clarify it.

**Q2-B is blocked by DOM-17**, which says "`retryable` describes whether repeating the *same request* is safe and sensible" (`01-domain-model.md:656–658`). A concrete case:
1. The collection reads `healthy`.
2. An operator records `account_unreachable`.
3. The guarded write misses, and Q2-B answers `false`.
4. The identical request 1 ms later is refused by the tail with WIR-9a's `true`, "The named account can recover" (`13-wire-contract.md:172`).

Same status, same request, opposite advice, decided purely by timing. After recovery, repeating the request succeeds, so `false` is a wrong description. It also contradicts the worker's step-8 mapping for the same status (`state` → `true`).

**Snapshot versus locked status.** The healthy collection snapshot is what T1 read. The locked refusing status is what T1's FOR UPDATE sees after T2 commits. I found no breaking interleaving for Q2-A under read-committed semantics.

**Formal scope.** `Admission.lean`'s `account_retryability` covers only the collection snapshot ("does not model status persistence or the transaction collecting the snapshot"). `AccountStatus.lean` omits "its contention with admission on the account row". Q2-A sits outside the model; no Lean change.

**Strongest don't-build argument (requested; not my vote).** Nothing commits on this path, the window is milliseconds, and a constant `false` is conservative. My answer: DOM-17 requires a determinate, truthful value, and two engines disagree today.

**Follow-ups.**
- The fixture note on isolation level.
- The restored rationale.
- Whether this refusal carries `details.refusals`.
- A possible pre-existing lock inversion: admission takes LDG-35, then the account row. Termination writes the status first (`04-api-contract.md:1367`), then holds the affected tenants' LDG-35 locks (`:1457`). This needs checking; it doesn't affect the vote.
- pv-ip7 is a separate bead.

**Votes.** Q2-A ACCEPT · Q2-B CANNOT ACCEPT · Q2-N CANNOT ACCEPT. **Preference: Q2-A.**

---

## Q3: pv-y0to

**The automatic path already exists.**
- **Owner and trigger.** OPS-27: "The system MUST attempt automatic resolution before asking a human" (`03-operation-lifecycle.md:555–556`), in the section whose flowchart opens with the non-create branch (`:505–513`). OPS-3 says resolution transitions "are made by no worker — by `OPS-27`'s sweep or `OPS-31`/`WIR-35`'s operator verb" (`:95–96`), including "resolved applied (non-create)" (`:107`). And "`OPS-27`'s evidence sweep is itself automatic and does move the state" (`:76`).
- **Module.** OVR-17 assigns OPS-27's resolution sweep to `engine` (`00-overview.md:295`).
- **The read, per kind.** PRV-29: "resolution MUST proceed by reading authoritative, non-mutating provider evidence" (`02-provider-contract.md:422–424`). The descriptor declares `evidence_sources` "per mutation kind" (`:82`), ranked by PRV-36.
- **When the window starts.** PRV-36: "`OPS-27`'s resolution MUST NOT take its first read before the window has elapsed from the end of the mutating call's wait" (`:1143–1144`). This names OPS-27 as the reader of non-create evidence.
- **Cadence.** OVR-19: "for a resolution-pending mutation, once its effective visibility window ends, its resolution read MUST be issued within that cadence" (`00-overview.md:445–447`). Its conformance item says "enforce the stated cadence" (`10-conformance-checklist.md:4178–4179`).
- **Settlement guard.** STO-3's `(id, status = needs_reconciliation, resolution IS NULL)`, plus STO-19's write-once columns.
- **Operator fallback.** OPS-45: "falling back to `OPS-31`'s `applied`/`not_applied`/`abandoned` where it cannot" (`03-operation-lifecycle.md:1522–1523`), with OPS-26's listing.
- **No mutation.** OPS-28 (`:914`). CNF-237 tests a delayed delete.
- **Provider-managed kinds** (power, reverse DNS, delete, release attachment, provider-native and catalogue installs) take the evidence path.
- **Rescue-based disk writes** can't be settled by provider evidence. Once the write marker is set, it rules out `not_applied` (`:1419`) and OPS-45 routes the operation to an operator. Seeing the machine still present proves nothing about the install.

The bead's sentence is true of PRV-29 alone, but the specification names the resolver elsewhere, so Q3-N's chain is complete. The real risk is how a builder reads it: OPS-27's body, and OVR-17's "It searches providers by correlator", both describe create only.
- **Q3-A** removes that risk with pointers and adds no behaviour.
- **Q3-B** adds duties: discovery on entry to the state, the resolving engine's identity, keeping a failed read eligible for a later pass, and applying OPS-31's refusal to automatic resolution. These are consistent today. But Q3-B copies OVR-19's MUST, PRV-36's window start and OPS-31's refusal into OPS-27, against AGENTS.md: "One rule, one home; everywhere else points at it."
  - It also cites "STO-8's resolution row", which is the wrong owner.
  - "Only on authoritative evidence for that attempt" can be read as narrowing PRV-36's resource read beyond the window, which resolves "not applied" without any anchor to the attempt.
  - The repair is to drop the copies, which leaves Q3-A.

**Pre-existing tension no form fixes (separate bead).** PRV-36's source 1, "The mutation endpoint's own report that the goal state already holds" (`02-provider-contract.md:1117`), and the flowchart's matching branch (`03-operation-lifecycle.md:509`) can only be obtained during resolution by sending the mutation again. OPS-28 and OVR-5 forbid that.

**Worked example.** A lost-reply delete on a driver that has only a resource read: the window opens at the deadline expiry, and the read is issued within the cadence once the window ends. A pre-mutation reading resolves *not applied*; a post-mutation reading resolves *applied*. I found nothing that breaks the chain. A build that implements only creates would fail CNF-237 and the cadence item.

**Formal scope.** `Reconcile.lean` models "what the system knows about the resource one create ordered". Non-create dispatch is outside the model; no Lean change.

**Strongest don't-build argument (requested; not my vote).** That argument is Q3-N: every piece exists, and Q3-A adds one more sentence that must track six owners.

**Follow-ups.** The source-1 bead. `tools/citation-baseline.json` has an unquoted-attribution entry for OVR-17; the manager's gate run should confirm Q3-A's row replacement doesn't alter that finding.

**Votes.** Q3-A ACCEPT · Q3-B CANNOT ACCEPT · Q3-N ACCEPT. **Preference: Q3-A.**

---

## Q4: pv-kv2 (mechanics only; the policy is fixed)

**Policy test.** Take a create first picked up while the tenant is suspended, so the suspension committed before the claim. The tenant read comes after the claim (step 1 in A/B, step 3 in C), sees `suspended`, and fails the create before any provider request.

An implementation could read inside a claim-transaction snapshot that predates the suspension. Even then, step 8's conditional write on the tenants row competes with API-58's flag write on that same row, affects zero rows, and fails the create.

So the leftover window, where a create is past the guard but hasn't reached the provider, holds only creates whose step-8 transaction committed before the suspension. All of those were claimed earlier. LDG-69 forbids holding a lock across the provider call, so the step-8 commit is the strictest race-free boundary available. It matches API-63's `about_to_order_at` approach. All three forms satisfy the owner's policy.

**Other mechanics I checked.**
- **Flag write.** API-58 step (1) writes `tenants.status` in its admission transaction, so the two writes really are on the same row.
- **Lost acknowledgement.** This mirrors OPS-43's existing account case: the earlier marker stays, OPS-11 classifies by the worker's position, and the worker's claim guard is kept.
- **Serialization failure.** It is repeated whole under OPS-49, then the guard is checked again.
- **Lock order.** Step 8 takes the account row, then the tenants row; the suspension takes only the tenants row. I found no new deadlock cycle.

**Does the existing "claimed before" sentence need replacing?** It isn't strictly contradicted, because a failure before purchase is still a settlement. But "its machine is then cancelled by the same sweep" assumes the claimed create buys, so the replacement is needed to keep API-58 coherent. Its "OPS-27's suspended-attach cancellation" is accurate: OPS-27 says it "applies at **all three** entry points" (`03-operation-lifecycle.md:646`), which includes the worker's own settlement.

One editorial fix: the replaced span starts inside `**fences work already in flight**`, so the closing `**` has to be moved.

**Retryable: `false` (Q4-A).**
- DOM-10's operator-controlled capability refusal carries `retryable: false` (`01-domain-model.md:519`).
- WIR-9a gives `insufficient_balance` `false` because "The caller must supply balance before purchasing" (`13-wire-contract.md:178`).
- A suspension is an operator sanction on the customer itself. Step 5b refuses the same request until resume, and WIR-41 doesn't allow resume while the suspension is still running.
- API-58 promises "nothing further can be bought" (`04-api-contract.md:733`).

Q4-B is defensible by analogy with recoverable account statuses, which get `true` even though an operator clears them. So it's acceptable, but not preferred.

**Placement: step 1 (A) over step 3 (C).** Under C, a suspended tenant's create on a closed ordering channel fails `rate_limited` with `retryable: true` and a retry interval (`13-wire-contract.md:175`). That invites a resend that step 5b will refuse. It also doesn't match the owner's "the worker sees the customer is suspended and fails the order". Both placements stop before spending anything, so C is acceptable.

**Coordinated edits the forms omit** (follow-ups, not blocking):
1. List the step-8 tenants-row conditional write in STO-6's store-primitive list and STO-27's (`05-persistence.md:137–142`). STO-27 explains why: an unlisted primitive is one a deployment could "silently lose" (`:957`).
2. API-58 step 4's administrative `tenant_suspended` failure states no `retryable`; align it with this value.
3. WIR-9a's `conflict` reason list credits `tenant_suspended` to API-58 alone (`13-wire-contract.md:141`); add OPS-43.
4. In Q4's CNF cases, assert STO-58's exclusion is freed for resource-offer creates.
5. Optionally clarify "nothing further can be bought" to cover the leftover window. The API-58 replacement already describes it.

**Formal scope.** Tables.lean keeps `suspended` admission-only, and these forms emit `conflict`, so they agree. Step 8 is outside the live model (`Restore.lean:35`: "`Live` has no step 8"). No Lean change.

**Timelines.**
- **Store administrative write:** an unclaimed create is still queued when the suspension's pass runs, so it fails through the Q1 path.
- **Worker settlement:**
  - Claimed at 10:02 after a 10:01 suspension: refused at step 1.
  - Claimed at 10:00:30, reads `active`, suspension at 10:01: the step-8 guard affects zero rows, so no marker commits and the create is refused.
- **Dispatched:**
  - Step 8 commits at 10:00:59, suspension at 10:01, provider call at 10:01:01: the order is potentially dispatched, and OPS-27 enqueues its cancellation at attach.
  - Lost acknowledgement, then suspension, then the repeat: the guard fails, the earlier marker stays set, and the create fails with no step 9.

I found no break.

**Strongest don't-build argument (requested; not my vote).** The plain read alone covers the owner's literal story. The tenants-row write adds contention on a busy row and a new primitive, and the remaining race costs at most one order that OPS-27 cancels. My answer: OPS-43 calls its own plain read "not a conditional-write guard", and API-63 records that under snapshot isolation "a read contends with nothing". The claim-snapshot case above lets a create claimed after the suspension buy.

**Votes.** Q4-A ACCEPT · Q4-B ACCEPT · Q4-C ACCEPT. **Preference: Q4-A.**

---

Final Q1: Q1-B; acceptability Q1-A ACCEPT, Q1-B ACCEPT, Q1-C ACCEPT; land with or after Q4, because all Q1 forms cite OPS-43's tenant refusal.
Final Q2: Q2-A; acceptability Q2-A ACCEPT, Q2-B CANNOT ACCEPT (DOM-17), Q2-N CANNOT ACCEPT (no existing value).
Final Q3: Q3-A; acceptability Q3-A ACCEPT, Q3-B CANNOT ACCEPT (copies rules owned elsewhere; the repair is Q3-A), Q3-N ACCEPT.
Final Q4: Q4-A; acceptability Q4-A ACCEPT, Q4-B ACCEPT, Q4-C ACCEPT; the owner's stop-before-buying policy is not re-voted.
