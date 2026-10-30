I reviewed the printed r83 Panel D bundles against **3109b5b44eae17e288cf52aaa976993bd8c5626c** and read `notes.md` whole. My preferences are **Q1-A, Q2-A, Q3-A and Q4-A**.

| Question | Exact-form acceptability |
|---|---|
| Q1 | A **ACCEPT**; B **ACCEPT**; C **ACCEPT** |
| Q2 | A **ACCEPT**; B **CANNOT ACCEPT**; N **CANNOT ACCEPT** |
| Q3 | A **ACCEPT**; B **ACCEPT**; N **ACCEPT** |
| Q4 | A **ACCEPT**; B **ACCEPT**; C **ACCEPT** |

These are individual reader votes, not a settlement or authorization to implement.

**Q1 — prefer Q1-A.**

All printed forms catch the requested defects:

| Defect | A | B | C |
|---|---|---|---|
| Deleted origin term | System cancellation and operator retry fixtures | Same | Same |
| Deleted parent-unsettled term | Settled-parent and old-parent fixtures | Same | Same |
| Lost claim race | Both claim/write orderings | Same | Same |
| Filter handling only power | Other caller kinds | Same | Create and install |
| Missing create release | Nonzero commitment and fee/unit assertions | Same | Same |

C catches the specifically named **power-only** implementation. It would not catch every omitted kind: an implementation handling precisely create, install and power could pass C. A’s coverage tied to the existing kind set is stronger without maintaining another representative list. The enum’s precise home is **WIR-10a**, “The closed enums,” at [13-wire-contract.md:271](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/13-wire-contract.md#L271).

The existing release duty suffices to justify the release assertion. **LDG-32** already requires release on “the create fails deterministically” at [12-billing-and-ledger.md:310](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/12-billing-and-ledger.md#L310). **LDG-39** supplies the money verdict: “Deterministic rejection before acceptance” is “Never debited; released with the commitment” at [12-billing-and-ledger.md:1268](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/12-billing-and-ledger.md#L1268). Administrative refusal before provider contact satisfies that description; it need not become a worker classification to qualify.

B remains acceptable. Its useful addition is **explicit atomic composition and ordering** of the administrative status write and release. That is stronger local machinery than merely adding coverage for the existing release outcome. I do not require that additional obligation to accept A’s tests.

The concrete fixture is a queued system cancellation beside caller work, under a suspended tenant and unsettled parent. Removing only `requested_by = caller` must change its administrative-write result from zero to one. For the worker race, claim first must leave the administrative write at zero; the worker may subsequently fail its own create under the separately settled Q4 mechanics. That worker failure must not be mistaken for administrative race loss.

There is an additional, pre-existing predicate problem. **API-58** says “queued but never claimed,” while its quoted “full predicate” omits a never-claimed term at [04-api-contract.md:628](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/04-api-contract.md#L628) and [04-api-contract.md:643](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/04-api-contract.md#L643). **STO-3** repeats the mismatch at [05-persistence.md:64](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/05-persistence.md#L64). A caller catalogue install can be claimed, yield during import, defer, and return to `queued` with a positive claim number. The printed predicate admits it despite the prose. None of these fresh, never-claimed fixtures repairs or detects that problem. It needs a separate coordinated owner amendment; I have not silently added `claim_number = 0` here.

Q1’s worker-race expectation must land alongside an accepted Q4 mechanics form. It is not evidence that pinned **OPS-43** already contains a tenant-status refusal. Preserve CNF-202’s held-power scheduling case and its existing origin assertions.

*Strongest don’t-build argument, requested; not my vote:* the generic store predicate makes exhaustive kind fixtures look repetitive. C is a defensible smaller regression bundle. It still leaves selective omissions that A catches; existing CNF-202 does not independently reject the named negative guard writes.

**Q2 — prefer Q2-A.**

A identifies the refusing status without inventing information in an UPDATE result: it first locks the account row, retains that locked status, and classifies before releasing it. A zero-row guarded UPDATE alone returns no refusing row.

The healthy collection snapshot and refusing status have different jobs. The snapshot permits the earlier tail to pass; the locked non-healthy status determines this later refusal. **WIR-9a**’s existing rows expressly say “collection-snapshot” at [13-wire-contract.md:171](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/13-wire-contract.md#L171), so they cannot supply the later input by themselves.

A preserves the existing ordering requirement, **API-63**’s “contend with admission on the account row itself, and that ordering comes first,” at [04-api-contract.md:1406](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/04-api-contract.md#L1406). Its row lock supplements rather than replaces the conditional write. It also preserves the money primitive: **LDG-35** requires “The authorization read and the commitment write MUST be serialized per tenant” at [12-billing-and-ledger.md:431](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/12-billing-and-ledger.md#L431). No provider call belongs under that money hold.

Serialization failure must remain a transaction failure, not fabricated evidence of an unhealthy status. In particular, **OPS-49** says “api’s components do not run this loop” and calls a failed request transaction the caller’s `internal` error at [03-operation-lifecycle.md:1940](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L1940). A does not import the engine’s retry loop into admission.

**Q2-B blocker:** consider a healthy snapshot, then `account_unreachable` winning before admission’s final guard. Admission commits nothing; the same named account subsequently recovers. Repeating the unchanged purchase is safe and can succeed. B nevertheless requires false solely because the failure occurred at the later barrier. **DOM-17** defines `retryable` as whether repeating “the same request is safe and sensible” at [01-domain-model.md:655](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/01-domain-model.md#L655). The concrete recovery supplies both properties. Merely naming this a “distinct refusal” supplies no changed request or side effect explaining opposite advice. This is my technical ruling on the proposed mapping, not a claim that the pinned snapshot rows already govern it.

**Q2-N blocker:** no cited pinned clause supplies both a determinate value and its race-free input for the healthy-snapshot case. **API-63** requires `conflict/state` when the admission write affects no row at [04-api-contract.md:1407](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/04-api-contract.md#L1407), without specifying retryability there. **API-7** explicitly says its constant-false response “is specific to the resource-offer guard” at [04-api-contract.md:298](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/04-api-contract.md#L298).

The concrete adversarial trace is: healthy snapshot → recoverable status → locked refusal → concurrent attempted recovery → rollback/unlock → recovery succeeds → response retains the captured decision’s value. A handles it; no breaking interleaving found.

The complete alternative to B and N is **the printed Q2-A bundle unchanged**, at its stated API-63, WIR-9a and CNF-278 locations. I propose no repaired hybrid. This remains an HTTP admission response with no existing operation view.

*Strongest don’t-build argument, requested; not my vote:* constant false avoids retaining status and adding an explicit locking read. That simplicity costs accurate guidance for the concrete recoverable refusal above.

**Q3 — prefer Q3-A; Q3-N is sufficient.**

The existing automatic path is real:

- **Discovery/trigger:** **OPS-27** says “The system MUST attempt automatic resolution before asking a human” at [03-operation-lifecycle.md:555](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L555). **OVR-19** quantifies the achieved read duty over a “resolution-pending mutation,” rather than only creates.
- **Component:** **OVR-17** assigns “OPS-27’s resolution sweep” to `engine` at [00-overview.md:295](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/00-overview.md#L295). The row’s correlator explanation is incomplete for non-creates; it does not exclude them.
- **Identity and dispatch:** **PRV-29** requires authoritative non-mutating evidence anchored to the known `external_id` and, where available, the attempt at [02-provider-contract.md:421](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/02-provider-contract.md#L421). **PRV-36** requires evidence sources “Per mutation kind” at [02-provider-contract.md:1114](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/02-provider-contract.md#L1114).
- **Timing:** **PRV-36** starts the window at “the end of the mutating call’s wait,” including deadline expiry, at [02-provider-contract.md:1142](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/02-provider-contract.md#L1142). **OVR-19** requires the read “MUST be issued within that cadence” at [00-overview.md:443](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/00-overview.md#L443).
- **Settlement:** **STO-3** supplies `(id, status = needs_reconciliation, resolution IS NULL)` at [05-persistence.md:59](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/05-persistence.md#L59); **STO-19** requires write-once evidence.
- **Fallback:** **OPS-45** explicitly directs resolution through provider evidence “where the driver can produce it,” falling back to the operator verbs “where it cannot,” at [03-operation-lifecycle.md:1521](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L1521).

A periodic scan of retained unresolved rows is an executable way to satisfy that universal cadence duty, including rows surviving restart. The specification need not prescribe a helper name or require one particular discovery implementation.

For provider-managed mutations, dispatch the declared action/history or resource evidence for that mutation’s goal. Preserve source ranking and the distinction between mutation completion, disappearance and billing stop.

For rescue disk writes, ordinary machine presence establishes neither installation completion nor non-application. **OPS-45** says a set destructive marker means preservation “is no longer proven, not that a byte landed” at [03-operation-lifecycle.md:1525](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L1525). Without truthful evidence for that attempt, use operator fallback; do not boot or end rescue during the evidence pass. The diagram’s “still present” label cannot be generalized into an install-completion test.

A clarifies the existing linkage and scopes the correlator table, making it my preferred documentation repair. B is acceptable but adds explicit discovery obligations and broader running-engine conformance assertions. Those are more than a missing pointer. N remains acceptable because the combined existing obligations already require the path.

Adversarial trace: an ambiguous delete’s resource read still shows the pre-delete state inside the visibility window. It remains pending; after the window, authoritative evidence can resolve it. A pending power mutation cannot instead be resolved merely because the machine remains present. No breaking interleaving found for A, B or the properly interpreted existing chain.

*Strongest don’t-build argument, requested; not my vote:* choose N. The achieved cadence, automatic sweep, evidence contract and fallback already impose the behavior. A improves discoverability without requiring another resolver.

**Q4 — prefer Q4-A.**

All printed forms implement the fixed pickup story: the early tenant check refuses before List offers, key upload or ordering; a create that observes suspension there never reaches step 8’s residue case.

A/B establish precedence **account → tenant → channel → boundary validation**. C establishes **account → channel → tenant → boundary validation**. C still stops purchase when an earlier channel refusal wins. At step 8, all forms retain account guard before tenant guard and operation-row guard, with the generation check first under **OPS-50**, “MUST read STO-59’s row FOR SHARE as its first statement” at [03-operation-lifecycle.md:1996](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L1996).

The critical interleavings are correctly separated:

1. Administrative failure wins against an unclaimed operation: no worker dispatch.
2. Claim wins: the administrative write affects zero rows; that worker still performs its own refusal checks.
3. Early tenant read sees active, suspension wins before the tenant dispatch guard: rollback and deterministic worker failure.
4. Dispatch transaction wins before suspension: potentially dispatched; preserve settlement and suspended-attach cancellation.
5. Step-8 commit loses its acknowledgement, suspension defeats the repeat: no speculative step 9; record the known pre-step-9 failure while retaining committed correlation data.

The fourth case respects the fixed owner policy: it concerns a create already authorized for dispatch while active, not one first observing suspension at pickup. A stricter zero-gap provider guarantee is neither supplied by these forms nor required by the owner’s quoted pickup decision. **LDG-69** prohibits waiting on “any provider call” while holding the money primitive at [12-billing-and-ledger.md:463](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/12-billing-and-ledger.md#L463).

The lost-acknowledgement exception is essential. **OPS-11** says a worker-recorded failure before any step-9 request “MUST settle failed, whatever its kind,” and forbids using `about_to_order_at` to decide that classification at [03-operation-lifecycle.md:249](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L249). A set timestamp therefore does not justify retaining the commitment after this known refusal.

I prefer false for the suspension refusal because it communicates the operator’s stop-serving decision. B is nevertheless acceptable: true can describe safe caller reissuance after authorized resume; it grants no automatic service retry. No pinned clause assigns a contradictory fixed value to `tenant_suspended`. This differs from an unresolved dispatched order, whose retryability remains false.

The API-58 replacement is appropriate: the old phrase “a create claimed before the suspension landed” at [04-api-contract.md:623](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/04-api-contract.md#L623) does not identify the dispatch authorization boundary. The detailed exception also qualifies API-58’s “nothing further can be bought” promise; that promise cannot truthfully mean that already authorized in-flight purchases vanish at suspension. I require no additional owner edit beyond the printed coordinated replacements.

Keep **OPS-27** unchanged: “Where the machine’s tenant is suspended at the moment of the attach, that same transaction also enqueues a system cancellation” at [03-operation-lifecycle.md:642](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L642). None of this creates tenant-status refusal rules for power, install or system cancellation.

*Strongest don’t-build argument, requested; not my vote:* existing attach-and-cancel handles resource accounting. It cannot satisfy the fixed policy for a create picked up under suspension, so it cannot replace the early refusal and dispatch guard.

**Follow-up scope and formal limits.**

The landing owners/assertions are those in the accepted bundles: CNF-202 for Q1/Q4; API-63, WIR-9a and CNF-278 for Q2; OPS-27/OVR-17 for Q3-A, with CNF-237 additions only if B is selected. Preserve existing exclusion-release coverage. The supplied `pv-ip7` overlap concerns worker recoverable-status coverage, not Q2’s admission response.

No current declaration models the new administrative predicate or tenant dispatch protocol. **Claim.lean** explicitly omits “API-58’s fan-out transition” at [Claim.lean:15](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/tools/formal/Provisiond/Claim.lean#L15). **Admission.lean** carries snapshot collection and says it “does not … execute a write” at [Admission.lean:42](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/tools/formal/Provisiond/Admission.lean#L42); its `account_retryability` theorem remains snapshot-specific. **Reconcile.lean** describes knowledge about “one create” at [Reconcile.lean:2](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/tools/formal/Provisiond/Reconcile.lean#L2), not a non-create scheduler. Existing exact-remainder release declarations are unchanged. No new formalism is a condition of these votes.

Applying **notes.md rule 6 exactly as written**, I found no verified brief error changing a question’s premise. The never-claimed predicate mismatch is an additional source defect the brief explicitly asks readers to identify. The corrected brief does not rely on the raw bead’s obsolete implication that CNF-202 lacks origin assertions or that the specification lacks every automatic non-create path.

The clone remains clean. No files, tracker records or panel records changed; no gates, builds, subagents or background work ran.

Final Q1: Q1-A; acceptability A ACCEPT, B ACCEPT, C ACCEPT.  
Final Q2: Q2-A; acceptability A ACCEPT, B CANNOT ACCEPT, N CANNOT ACCEPT.  
Final Q3: Q3-A; acceptability A ACCEPT, B ACCEPT, N ACCEPT.  
Final Q4: Q4-A; acceptability A ACCEPT, B ACCEPT, C ACCEPT.