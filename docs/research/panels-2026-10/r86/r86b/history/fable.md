**Outcome.** Q1: I pick Q1-A and accept Q1-A and Q1-C; I cannot accept Q1-B. Q2: I cannot accept either printed form, because each one as printed turns the citations gate red. My pick is Q2-A plus four comment-only Lean docstring substitutions, printed in full below. That is a distinct form no other reader has seen, so it needs the consensus round. I verified the gate claims by applying each form to a scratch copy under my tmp directory and running the Python-only gates. No Lean was started.

| Form | Exact printed form | Final preference |
|---|---|---|
| Q1-A | ACCEPT | **Q1-A** |
| Q1-B | CANNOT ACCEPT | |
| Q1-C | ACCEPT, as status quo only | |
| Q2-A | CANNOT ACCEPT as printed | |
| Q2-B | CANNOT ACCEPT as printed | |
| Q2-A′ (below) | ACCEPT | **Q2-A′** |

Rule 6 check: I found no brief error that changes either question's premise. One brief defect is reported with the tally. Both Q2 forms are presented as complete, and each one deletes API-7 wording that Lean docstrings quote. That is a completeness defect, not a premise change.

Gate runs on scratch copies at the pin, with the index borrowed from the manager's same-pin gate clone:

| Copy | citations | ids | obligations | coverage |
|---|---|---|---|---|
| base | pass | pass | pass | pass |
| Q1-A | pass | pass | pass | pass |
| Q1-B | pass | pass | pass | pass |
| Q2-A | **fail** | pass | pass | pass |
| Q2-B | **fail** | pass | pass | pass |

The fixtures gate cannot run outside the Nix shell on this host. No candidate touches a JSON fixture or a Lean-rendered region, so I expect no effect there. The regions and formal gates are the manager's.

## Q1

**What the owners already fix.** DOM-10 at 01-domain-model.md:515 says "before the driver is called", and SEC-15 at 07-security-requirements.md:84 repeats it. The driver is called by the worker, and system children have no admission request, so a worker-path gate is already implied for every kind. What is unspecified is the admission phase and the order among local checks. DEF-10 at 09-known-defects.md:78 cites the old worker file, so the historical implementation gated at claim.

**Per operation, under Q1-A.** Power and hard reset take `power_control` or `hard_reset` at admission and claim; PRV-14 stays defense in depth. Each install strategy takes its DOM-10 row, then `rescue_ssh` for rescue-based strategies, after WIR-30's eligibility refusal and OPS-40's accept-time check. Rescue inventory takes `rescue_ssh` before the rescue marker is written, which keeps CNF-302's `rescue_exited_cleanly` null at 10-conformance-checklist.md:3049. Reverse DNS takes `reverse_dns` after API-16 validation and before the PTR compare, which is PRV-25's own order at 02-provider-contract.md:855. A caller delete and an operator release on an `api` row take `delete_machine` at admission; API-65's manual row calls no driver and takes none. API-64 retry takes it before its guarded write. Suspend children, sweep cancellations and the releases a delete enqueues take it at claim only.

**No-call branches and defers hold.** I traced an exhaustion cancellation on a machine funded since routing: OPS-41 step 3 at 03-operation-lifecycle.md:1093 aborts with no provider call and settles `succeeded`, and both Q1 texts exempt that path. The restore-grace defer at 03-operation-lifecycle.md:998 runs before the fence and before the check. A machine recorded gone takes step 1 and never reaches the check. The same-PTR success stays behind its capability check as PRV-25 already orders. Local validation refusals keep their rank in both phases, so no validation refusal moves and no defer becomes terminal.

**The cost Q1-A accepts.** A decision that proceeds past the fence and then fails the capability check settles `failed`, and OPS-48's row at 03-operation-lifecycle.md:1301 leaves the episode `stalled` with the fence unchanged. That is the existing disposition of any deterministic provider rejection after fencing, and the operator's keep or retry clears it. Placing the check before the fence would bypass the no-call success the brief warns about, so this placement is the right one.

**Why Q1-B cannot be accepted.** Q1-B does not merely omit an admission gate. It says admission "enqueues an otherwise valid request even when the running api descriptor lacks that operation's capability". The descriptor is "Pure and synchronous" at 02-provider-contract.md:76, so the refusal is knowable at admission, and the set rejects every other admission-knowable fault before enqueue. API-13 at 04-api-contract.md:962 says "MUST be enforced before an operation is enqueued". WIR-30 at 13-wire-contract.md:1062 says an ineligible strategy "MUST be rejected as `invalid_request` before the operation is enqueued, exactly as an invalid pairing is". OPS-40 checks "twice". Trace: an operator retries a stalled episode on an account that no longer declares `delete_machine`. Under Q1-B the guarded write moves the episode to `attempting`, the attempt is claimed, the fence transaction runs, the check fails, the attempt settles `failed` and the episode returns to `stalled` with the fence now set. Under Q1-A the retry answers `501` and writes nothing. Q1-B contradicts no quoted MUST. My objection is to the design, and it is not a rule 3 loss.

**Q1-C.** Nothing breaks if it lands. CNF-201 and CNF-302 are satisfiable in either phase. I accept it as the status quo and nothing more. It does not answer the bead, and conformance items keep being unable to assert a phase for a non-create refusal.

**Strongest case for leaving Q1 alone, on request.** Non-create admission moves no money. Capability sets change only across a restart. DOM-10 already forces a worker gate for system children, so an implementation that also gates at admission is conformant today. Nine endpoint classes gain an admission step for a problem that has never bitten.

## Q2

**Both printed forms break the citations gate.** Admission.lean quotes three API-7 sentences in docstrings. Its line 19 quotes "A refusal stops here and is not collected by the tail." Its line 318 quotes "gate a create on its ordering capability". Its line 1205 quotes the stored-listing sentence. The gate's EXISTS rule requires every Lean docstring quote to appear in the corpus. Applying Q2-A as printed produced two unverifiable attributions and three Lean quotes found nowhere. Applying Q2-B produced one of each. The before-gate log shows this gate passing at the pin, so either form as printed cannot land under AGENTS.md. No declaration, theorem or guard changes under either form. `createPurchaseTail` takes a supplied Boolean, and `Summary.offerSnapshot` is an opaque string, so the retained field needs no Lean change. Comment-only docstring substitutions clear the gate for both forms, verified on the scratch copies. Both Q2 forms also replace OPS-43 step 3's three verified quotations with paraphrase. That is a quality regression under the "Quote the sentence" rule, not a gate failure.

**Q2-A on substance.** The offer owns the kind in this set. The offer entity at 01-domain-model.md:166 carries `kind`, WIR-30's fixture carries it per offer, and DOM-10's rows select by the create's kind. Reading that kind from the stored listing in the tail's own snapshot adds no provider call and no guess. The brief flags the precedence change correctly. Trace: an `allow_orders: false` account, a named offer absent from the stored listing, a balance too low. At the pin CNF-55 at 10-conformance-checklist.md:343 asserts `501` at 5d, without saying whether its offer is present. Under Q2-A that case takes the tail and answers `400` `offer_not_sellable` with `not_checked` entries. The `501` survives for a present offer, including on an old listing, which matches the Lean theorem `age_preserves_early_refusal`. The owner's pv-p3k ruling was "MUST, not retryable", and both refusals stay non-retryable. The three panel-E settlements stand: Q2-A touches neither the tail's rank list nor the age sentence, and its CNF-55 insertion specifies presence, which the header default at 10-conformance-checklist.md:32 leaves open for refusal items. The restart case holds: step 3 gates on the retained kind with no List offers read, as CNF-55 requires. A missing or corrupt retained kind takes OPS-23's `incomplete_record`, since the kind is api-written like the accepted-price fields. A live kind change at step 5 refuses before any mutation and releases the commitment and exclusion. Mixed-kind accounts work.

**Q2-B on substance.** Beyond the gate failure, Q2-B has a hole. Its only guard against drift is a driver MUST, "Every offer returned for the account MUST have that machine kind", with no engine-side check and no checklist assertion after enabling. Trace: a descriptor with `machine_kind: bare_metal` declaring only `provision_bare_metal`; a later refresh stores a virtual offer under the same credential; a create names it. Step 5d passes on `provision_bare_metal`, the tail prices it, step 3 passes, steps 4 and 5 find it present and sellable, and the worker orders a virtual machine. DOM-10's row at 01-domain-model.md:525, "create machine, `kind = virtual`" requires `provision_virtual`, goes unenforced. Under Q2-A the same create answers `501` naming `provision_virtual`. Q2-B also adds a descriptor field, a configuration refusal and an account-identity rule to exclude a provider shape the set models as possible, which is a domain restriction wider than the question.

**Narrower form.** I found none that keeps mixed accounts, keeps the early refusal and invents no source. Gating absent offers on "neither provisioning capability declared" names no capability for `details.capability`. Re-deriving the kind at claim from the live listing moves the gate after step 4 and loses CNF-55's no-List-offers refusal. Q2-A's retained field follows the accepted-price precedent at 05-persistence.md:523.

**Strongest case for leaving Q2 alone, on request.** The bead itself records that every v1 driver sells one kind per account, so both divergence points are latent. Against it: the set already gives two conformant engines different answers for `details.capability`, which CNF-55 asserts.

**Cross-check of Q1-A with Q2-A′.** Q1-A inserts text only, touches no create step, and both Q2 forms keep step 5d create-only. API-7's steps 1 to 5c, replay at 5a and the ceilings at 5c stay ahead of every tail. Q1-A's claim order and Q2-A′'s step 3 order agree: caller-supplied first, api-written second, capability last. The stored-listing policy and both ordering gates are untouched by Q1-A.

## Q2-A′, exact form

Every Markdown substitution and insertion of Q2-A, exactly as the brief prints them, plus these four substitutions in `tools/formal/Provisiond/Admission.lean`. Each touches a docstring only.

Line 19, replace:
```text
`API-7` says "A refusal stops here and is not collected by the tail."
```
with:
```text
`API-7` says "A capability refusal stops here and is not collected by the tail."
```

Lines 317–319, replace:
```text
`orderingCapabilityGuard` (`API-7`, 2026-10-22, `pv-p3k`): `API-7` says
"**gate a create on its ordering capability**". Off, a create without that declaration reaches
the purchase tail.
```
with:
```text
`orderingCapabilityGuard` (`API-7`, 2026-10-22, `pv-p3k`; step 5d reworded 2026-10-30,
`pv-e45e`): step 5d gates a create on the ordering capability selected by the named offer's kind
in the stored listing, and takes no gate for an offer absent from it. Off, a create without that
declaration reaches the purchase tail.
```

Lines 1181–1182, replace:
```text
whether the account declares the create's ordering capability. Machine-kind selection and
descriptor construction are outside this model.
```
with:
```text
whether the account declares the ordering capability selected by the named offer's kind in the
stored listing; for an offer absent from that listing step 5d takes no gate and the Boolean is
supplied `true`. Offer-kind selection and descriptor construction are outside this model.
```

Lines 1205–1206, replace:
```text
`API-7`: "On create, the tail reads the stored listing regardless of age, or an empty offers set
if no listing is stored." The supplied sale verdict
```
with:
```text
`API-7`'s step 5d reads the stored listing "regardless of listing age; no stored listing means an
empty offers set". The supplied sale verdict
```

For the record only, and not my vote: Q2-B becomes gate-clean with one substitution at lines 317–319.
```text
`orderingCapabilityGuard` (`API-7`, 2026-10-22, `pv-p3k`; step 5d reworded 2026-10-30,
`pv-e45e`): step 5d gates a create on `DOM-10`'s ordering capability selected by the running
descriptor's `machine_kind`. Off, a create without that declaration reaches the purchase tail.
```

Landing note for every printed form: the brief's code blocks drop the backticks the documents put around identifiers and field names. I read the forms with the repository's backtick convention restored and treat that as formatting, not a semantic change.
