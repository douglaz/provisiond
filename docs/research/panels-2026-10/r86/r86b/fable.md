**Outcome.** Q1: I pick Q1-A, accept Q1-A and Q1-C0, and cannot accept Q1-B. Q2: I pick Q2-A-cited, accept Q2-A-cited and Q2-A-prime, and cannot accept Q2-A, Q2-B or Q2-B-cited as printed. I verified every gate claim by applying each printed form to its own scratch copy under my tmp directory and running the four Python gates. No Lean, lake or Nix was started. Nothing in the clone changed.

| Form | Verdict | Note |
|---|---|---|
| Q1-A | ACCEPT | **Final Q1 pick** |
| Q1-B | CANNOT ACCEPT | Rule-3 loss against OVR-2, quoted below |
| Q1-C0 | ACCEPT | Status quo; breaks nothing; answers the bead only by pointing at OVR-2 |
| Q2-A | CANNOT ACCEPT | Citations gate red as printed |
| Q2-B | CANNOT ACCEPT | Citations gate red as printed; untestable before-enable assertions |
| Q2-A-prime | ACCEPT | Gate-clean; paraphrases three step-3 quotations |
| Q2-A-cited | ACCEPT | **Final Q2 pick** |
| Q2-B-cited | CANNOT ACCEPT | Gate-clean, but the printed contract is incomplete |

Gate runs, Python only, stub index built from the `@[req]` tags. The fixtures gate cannot run here because `markdown_it` is missing outside Nix. No form touches a JSON fixture or either marked region.

| Copy | citations | ids | obligations | coverage |
|---|---|---|---|---|
| base | pass | pass | pass | pass |
| Q1-A, Q1-B | pass | pass | pass | pass |
| Q2-A | **fail** (2 attributions, 3 EXISTS) | pass | pass | pass |
| Q2-B | **fail** (1 attribution, 1 EXISTS) | pass | pass | pass |
| Q2-A-prime, Q2-A-cited, Q2-B-cited | pass | pass | pass | pass |
| Q1-A with Q2-A-cited; Q1-A with Q2-B-cited | pass | pass | pass | pass |

Each form was applied both as printed and with the documents' backtick convention restored on identifiers; results were identical. The Q2-A failures are Admission.lean lines 19, 318 and 1205 quoting the three API-7 sentences the form removes; Q2-B's is line 318.

## Q1

**What changed my mind.** In r86 I accepted the brief's premise that admission phase was open. Sol's objection holds at the pin. OVR-2 at 00-overview.md:22 says "the server MUST NOT accept an operation a provider has not declared support for", and OPS-1 at 03-operation-lifecycle.md:17 names acceptance: a mutating request "MUST respond `202 Accepted` with that record". Describe capabilities is "Pure and synchronous; it MUST NOT perform network I/O" at 02-provider-contract.md:76, so the api knows the answer at admission. Both phases are therefore already required by OVR-2 for admission and by DOM-10 with OPS-23 for the worker. What the set leaves open is only precedence among local checks and the API-64 phase.

**Q1-B is a rule-3 loss.** Its text says admission "enqueues an otherwise valid request even when the running api descriptor lacks that operation's capability". Trace: a valid hard reset names an account whose descriptor lacks `hard_reset`. B enqueues it and answers 202 Accepted. OVR-2, owner of the sentence quoted above, forbids exactly that acceptance. The worker's later refusal does not repair the admission. Astra's retry trace is real as an A/B difference: a stalled episode with a null fence, funding restored, delete support gone, operator retries. B admits and OPS-41 step 3 settles the funded no-call success. But that new request still meets OVR-2 first, and the owner's `API-68` keep remains available. CNF-312 specifies "no other admission refusal", so no checked verdict is lost under A.

**Q1-A holds against every owner I checked.** The admission check sits after 5c, outside the Lean `admit` model, so no theorem moves. Worker order follows OPS-23's "before the driver is called" and OPS-40's claim gate "before any provider mutation and before rescue is entered". System children take OPS-41's gone, funded and restore-grace branches first, and those MUST outcomes are untouched. A proceeding cancellation that then fails capability leaves OPS-48's row "`failed` — deterministic; the provider did not act | `stalled` | **Unchanged**": a fenced stall with no provider call, cleared by keep or retry. That is a design cost, accepted. PRV-25's equality compare stays "After the ordinary authorization, capability and `API-16` validation". CNF-302's capability path stays reachable through a restart between admission and claim, and its OPS-40 alternative is unchanged.

**API-64 resolution.** API-64's admissibility is "by a conditional write guarded on `(id, state = stalled)`", and A puts the check "before its state-change/enqueue transaction". The two coexist only if the retry reads the episode state before the capability check, refuses 409 when not stalled, checks capability, then runs the guarded write, whose zero-row outcome stays 409. That is the deterministic reading; A does not spell it out. No checklist item depends on it, so it is not a vote condition.

**Precedence is an amendment.** A's order of caller fields, api-written fields, other local validation, then capability is new normative text for non-create operations, mirroring OPS-43 step 3. It is not proven old behaviour, and I do not claim it is.

**Q1-C0.** Literal no edit breaks nothing and claims no phase freedom. I accept it as the status quo. Its weakness is that the bead's "admission, claim or both" is then answered only by reading OVR-2 together with DOM-10, and no home states the local-check order.

**Strongest leave-it-alone argument, not my vote.** OVR-2, DOM-10 and OPS-23 already force both phases and the no-call branches are already MUSTs. What A adds is error precedence among outcomes that are all `failed`, non-retryable and touch neither provider nor money, on a P3 bead.

## Q2

**The formal dissent, quoted.** Astra: "Neither provisioning capability being declared makes the Boolean false whichever machine kind might be selected; this does not require guessing one from the offer ID." Sol: A "does bypass the early-refusal guard's checked precedence". I read `createPurchaseTail` at Admission.lean:1180 and both theorems. The evaluation is correct: with the guard on, `orderingDeclared = false` and `offerSellable = false`, the pinned composition returns `unsupported` with no tail at every age.

**Why it is not a rule-3 loss.** Rule 3 needs a checked verdict changed, unreachable or vacuous. Under A-cited no theorem changes statement or truth. `undeclared_ordering_stops_before_tail` still holds and stays non-vacuous: a present offer that is unsellable under PRV-13b with an undeclared kind still supplies Boolean false and sale false. The witness `undeclaredOrderingCreate` uses a present sellable offer and its CI row still reds exactly once. The docstring at 1180 already puts "Machine-kind selection" outside the model, and for an absent offer no kind can be selected, which is the case the bead names as undefined. Astra's "whichever kind" presupposes a kind is selected. The only checked verdict A changes is CNF-55's `501` for an absent-offer or no-listing fixture, which becomes `400 offer_not_sellable`. A discloses that flip and amends CNF-55 and CNF-19 to specify presence. The protected property survives: an absent offer is "an unsellable offer for every rule in this tail", so nothing is admitted or priced, and both refusals are non-retryable per WIR-9a line 174. The error payload also becomes fillable, since DOM-10 demands "naming the provider account and the capability", and for an account declaring neither capability nothing names one.

**Is a declaration amendment necessary?** No, under rule 3 and ADR-0025, which allows an unmodelled clause. It is better practice, because A changes 5d's structure and the twin cannot express presence. The docstring repair in A-prime and A-cited is explicit, not silent, and no proof is cleared by it. I therefore accept the printed repairs, and I print below a complete alternative that models presence with new declarations and a witness, changing no existing theorem. It is first-authored and unbuilt, so it cannot settle this round; it exists for the owner.

**Q2-B's outer gate.** Fable and opus's trace stands as a behaviour of the printed engine steps. My decision: the bare-metal offer on a `machine_kind: virtual` account is a violating driver output, outside B's contract, and a driver can satisfy the duty by filtering List offers by kind. B's engine gate is an engine-side descriptor check, so DOM-10's "There MUST be no operation whose only gate is a driver-internal check" is not breached by a conforming B. The cost is robustness: a mislabelled offer defeats A, and any off-kind offer defeats B, so B trusts more of the driver. That is design cost, not a MUST loss.

**Q2-B is incomplete as printed.** It requires "A mixed-kind account ... MUST be rejected as invalid deployment configuration before api or engine enables that account" and "machine_kind MUST NOT change for a retained provider-account identity", and its CNF-19 text asserts both refusals. The descriptor carries one `machine_kind` and no network I/O, so a mixed account is undetectable before any List offers read. No persisted prior kind exists and B adds none; STO-21 names operational state but no such record. Both assertions are tests the set cannot run as specified, the F39 pattern STO-50 records. That is a fixture-level completeness defect under rule 3, so I cannot accept B-cited despite its clean gate. B's account-shape restriction is a real domain cost beyond the bead; I would weigh it only against a complete form.

**Q2-A-cited on the remaining cases.** Present offer, undeclared kind: `501` before the tail, fresh or old listing, matching `age_preserves_step_5d`. Present, declared, old, nothing collected: existing stale-listing refusal. Absent or no listing: tail collects `offer_not_sellable`, unhealthy account ahead of it, cap and balance suppressed, no provider call. Restart with the capability withdrawn: step 3 gates on the retained kind before List offers, preserving CNF-55's "no List offers read". Missing or corrupt kind: OPS-23's api-written bullet, `conflict`/`incomplete_record`, retryable. Live absence: existing step-5 refusal. Live kind change: the new step-5 refusal mirrors the pinned unsellable outcome at 03-operation-lifecycle.md:843, settling `failed` with full release and exclusion freed. The retained field follows the accepted-price precedent on the request_summary row, STO-50's enumeration is amended, and Wire.lean's `offerSnapshot` is an opaque string. A-cited over A-prime: it restores the OPS-23 and PRV-8 quotations, and it drops only PRV-10's "the account is configured to allow ordering", which no longer selects the gate. The gate count confirms two of three Markdown comparisons return.

**Strongest leave-it-alone argument, not my vote.** Every v1 driver sells one kind per account, so both divergence points are latent on a P4 bead, and a dual-kind provider's ADR could decide with real facts. Against it: two conforming engines already give different `details.capability` values that CNF-55 asserts.

**Rule 6.** I broke no premise claim in this packet. Every pinned excerpt and Lean line matches the pin, the gate reports match my reruns, and the two traces evaluate as the packet says. Two notes with the tally: the 05-persistence replacement text as printed has a line break inside a table row and must be joined on landing, a formatting matter; and the brief's "The added early admission check does change an unsupported request's observable phase" is true only against a build that already violated OVR-2.

**Composition.** Q1-A inserts only, after the rewritten 5d and before "The tail then depends on what the endpoint does:", and before OPS-23's amendment note where Q2's exception paragraph also lands. Replay, suspension and ceilings stay ahead of every tail. Both forms' worker orders agree: caller fields, api-written fields, capability. No purchase-tail rank, age sentence or panel-E settlement moves. The combined scratch copies pass all four gates.

## Alternative Q2-A-formal, complete, first-authored, unreviewed, unbuilt

Every Markdown substitution and insertion of Q2-A-cited exactly as printed, its line-19 and lines-317–319 Lean substitutions exactly as printed, and the following in place of its lines-1181–1182 and lines-1205–1206 substitutions, plus two insertions. No existing declaration, theorem or witness changes. Proofs mirror the neighbouring ones; I ran no build.

Lines 1181–1182, replace:
```text
whether the account declares the create's ordering capability. Machine-kind selection and
descriptor construction are outside this model.
```
with:
```text
whether the account declares the ordering capability selected by the named offer's kind in the
stored listing; for an offer absent from that listing step 5d takes no gate and `step5dPasses`
supplies `true`. Offer-kind selection and descriptor construction are outside this model.
```

Lines 1205–1207, replace:
```text
`API-7`: "On create, the tail reads the stored listing regardless of age, or an empty offers set
if no listing is stored." The supplied sale verdict includes the named offer's absence, including
an empty offers set. There is no separate no-row refusal or presence policy here. -/
```
with:
```text
`API-7`'s step 5d reads the stored listing "regardless of listing age; no stored listing means an
empty offers set". The supplied sale verdict includes the named offer's absence, including an
empty offers set. There is no separate no-row refusal here; `step5dPasses` carries the named
offer's presence into the gate's Boolean. -/
```

In `tools/formal/Provisiond/Admission.lean`, insert after the line `  simp [createPurchaseTail, h]` that closes `undeclared_ordering_stops_before_tail`, before `/-! ## Composed create admission`:
```lean

/-- `API-7` step 5d (2026-10-30, `pv-e45e`): the Boolean `createPurchaseTail` takes, computed from
whether the named offer is present in the stored listing and whether the account declares the
ordering capability its kind selects. An absent offer takes no gate, so the gate passes and the
tail's absent-offer verdict decides. Reading the listing and selecting the kind are outside. -/
@[req "API-7"]
def step5dPasses (offerPresent kindDeclared : Bool) : Bool := !offerPresent || kindDeclared

/-- An offer absent from the stored listing takes no step-5d gate whatever the account declares:
the create reaches the tail, whose supplied sale verdict is false for an absent offer. -/
@[req "API-7"]
theorem absent_offer_takes_no_gate (g : Guards) (kindDeclared : Bool) (a : AccountStatus.Status)
    (c s r q p b : Bool) :
    createPurchaseTail g (step5dPasses false kindDeclared) a false c s r q p b =
      { refusal := none, tail := some (purchaseTail g true a false c false s r q p b) } := by
  simp [createPurchaseTail, step5dPasses]

/-- A present offer whose kind selects an undeclared capability stops before the tail, at every
sale verdict and snapshot input, as before. -/
@[req "API-7"]
theorem present_undeclared_stops_before_tail (g : Guards) (h : g.orderingCapabilityGuard = true)
    (a : AccountStatus.Status) (o c s r q p b : Bool) :
    createPurchaseTail g (step5dPasses true false) a o c s r q p b =
      { refusal := some .unsupported, tail := none } := by
  simp [createPurchaseTail, step5dPasses, h]
```

In `tools/formal/Provisiond/Witnesses.lean`, insert after the `:= by decide` that closes `missing_listing_keeps_offer_refusal`, before `@[req "API-7"]` of `listing_age_equality_keeps_clean_create`:
```lean

/-- `pv-e45e`: a create naming an offer absent from the stored listing takes no step-5d gate, with
neither provisioning capability declared, and the tail's absent-offer verdict refuses it. Same
pinned guards and snapshot as `missing_listing_keeps_offer_refusal`. -/
def absentOfferUndeclaredCreate :=
  createAdmission listingFixtureGuards (step5dPasses false false) .healthy false false false true true true true 0 10

@[req "API-7"]
theorem absent_offer_refused_by_the_tail_not_the_gate :
    absentOfferUndeclaredCreate =
      { refusal := none, tail := some { refusals := [.offerNotSellable], notChecked := [(.commitmentCap, .unsellable), (.balance, .unsellable)] } } := by decide
```

No CI row changes: the witness pins `listingFixtureGuards`, so no guard flip reds it. No conformance identifier enters the formal layer. The one docstring quotation, "regardless of listing age; no stored listing means an empty offers set", is in the new 5d text. I ACCEPT this form as well; my pick stays Q2-A-cited because it is the complete form the other seats have read.
