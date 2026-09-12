## Recommendation

**Use Lean to give provisiond a small, executable semantic core: precise definitions of the money calculations and lifecycle transitions, with proofs that those definitions satisfy the safety properties stated in the Markdown specs.**

I would **not** translate every requirement into Lean, rewrite the system in Lean, or begin by verifying a future implementation. The immediate opportunity is to verify that **the specifications agree with themselves**, particularly where several individually reasonable requirements interact.

I reviewed the repository at **`ee417b1`**, including the arithmetic gate, the relevant lifecycle and persistence requirements, and the September 12 changes in **ADR-0022, ADR-0023, and ADR-0024**. The repository is explicitly specifications-only, with a carve-out for tools that check those specifications. The proposal below fits that structure.

My recommended starting order is:

| Priority | Formalization                                       | Main benefit                                                                                       |
| -------- | --------------------------------------------------- | -------------------------------------------------------------------------------------------------- |
| **1**    | Meter arithmetic and runway calculation             | Replace sampled arithmetic checks with general proofs, clarify exactly what the formulas guarantee |
| **2**    | Cancellation versus runway extension                | Verify the transaction boundaries that protect a customer’s machine                                |
| **3**    | Claims, deferrals, retries, and ambiguous outcomes  | Prevent database retries from becoming repeated provider mutations                                 |
| **4**    | Reconciliation, commitments, and attachment billing | Verify the interactions between knowledge, resource ownership, and spending authority              |
| **5**    | Restore and mixed-version operation                 | Expose guarantees that depend on durability or deployment assumptions                              |

The important output is not “more formal documentation.” It is **a change to one rule causing a relevant proof or counterexample test to fail before contradictory specs are merged**.

---

## 1. Why this repository is a particularly good fit

The strongest part of provisiond is that it already records **why plausible designs failed**: non-decaying commitments, incorrect rounding, stale cancellation decisions, ineffective fences, and retries that accidentally repeat mutations. Its stable requirement identifiers and conformance items give those lessons durable names.

The remaining weakness is that relationships between requirements are still mostly checked through prose review and specialized scripts.

For example, `tools/check_arithmetic.py` already tests exactly the kind of claims Lean should own. It checks runway behavior over bounded integer inputs and tests the rounding recurrence using 3,000 randomized trials with floating-point arithmetic. That is useful regression protection, but it does not establish the rational-arithmetic claims for every permitted input and execution length.

Two concrete issues I found illustrate the distinction.

### A. The month-boundary rounding explanation points in the wrong direction

`LDG-38` resets the rounding credit to zero at each billing-period boundary and describes the credit as being forfeited **“in the customer’s favour.”** But the recurrence makes that credit an amount that reduces subsequent debits. Resetting it removes that benefit.

A counterexample using exact fractions:

| Event                                 | Exact consumption |  Debit | Remaining rounding credit |
| ------------------------------------- | ----------------: | -----: | ------------------------: |
| First period                          |           0.4 sat |  1 sat |                   0.6 sat |
| Next period, **carrying** the credit  |           0.4 sat | 0 sats |                   0.2 sat |
| Next period, **resetting** the credit |           0.4 sat |  1 sat |                   0.6 sat |

Resetting costs the customer one additional satoshi in this example.

**Independent monthly rounding can still be an intentional policy.** The problem is the explanation, and potentially the intended guarantee, not necessarily the choice to reset.

A formal statement would force the distinction between:

> Metering cadence does not affect the charge within the same billing-period partition.

and:

> Introducing additional billing-period boundaries does not affect the charge.

The first is a suitable target for the current design. The second is false under its reset policy.

### B. The migration requirements contain a platform-level contradiction

`STO-12` requires a migration to execute in one transaction, with a transaction-scoped advisory lock covering history inspection, application, and completion recording. `STO-13` requires concurrent index builds on the large tables.

However, PostgreSQL does not permit `CREATE INDEX CONCURRENTLY` inside a transaction block. ([postgresql.org][1])

The specification therefore needs separate rules for **transactional migrations** and **nontransactional, resumable migration steps**. The latter cannot inherit the former’s atomicity guarantee.

Lean will not discover PostgreSQL’s behavior independently. But once that platform constraint is represented, a migration plan demanding both properties should be rejected. A real PostgreSQL integration test should verify the platform assumption as well.

These examples suggest the right role for Lean: **check the consequences and compatibility of requirements, rather than merely that every requirement has a citation and a test identifier.**

---

## 2. First project: make the meter a proved executable specification

This is the best initial investment because the relevant arithmetic is small, important, and already isolated in the specs.

### Define the calculation once

`LDG-38` defines, for each increment:

$$
d_i = \left\lceil x_i-r_i \right\rceil
$$

$$
r_{i+1}=r_i+d_i-x_i
$$

Here, \(x_i\) is the exact nonnegative rational cost, \(r_i\) is the rounding credit, and \(d_i\) is the computed debit magnitude. The specification requires exact arithmetic and maintains \(0\le r_i<1\).

The corresponding Lean definitions can remain tiny:

```lean
import Mathlib

namespace Provisiond.Meter

def computedDebit (exact credit : ℚ) : ℤ :=
  ⌈exact - credit⌉

def nextCredit (exact credit : ℚ) : ℚ :=
  credit + (computedDebit exact credit : ℚ) - exact

end Provisiond.Meter
```

These are illustrative definitions, not a claim that I have built and checked a Lean project for the repository.

The substantial work is in the properties around them.

### Prove the mathematical claims

I would give the first module these proof obligations:

| Proposed theorem             | Exact claim                                                                                                                                                   |
| ---------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `credit_range_preserved`     | Nonnegative exact consumption and a credit in `[0,1)` produce another credit in `[0,1)`                                                                       |
| `computed_debit_nonnegative` | The computed debit magnitude is never negative                                                                                                                |
| `computed_total_eq_ceiling`  | Starting from zero credit, accumulated computed debits equal the ceiling of accumulated exact consumption                                                     |
| `partition_invariant`        | Splitting consumption into more increments does not change the total, provided the same pricing and billing-period boundaries are preserved                   |
| `single_corruption_bound`    | One in-range credit corruption changes cumulative computed debits by at most one satoshi, for the same future exact-cost stream and otherwise correct updates |

The cumulative theorem follows from a useful invariant:

$$
\sum_{i<n} d_i=\sum_{i<n}x_i+r_n
$$

Starting with \(r_0=0\), the right-hand residual lies in `[0,1)`, while the debit sum is an integer. That gives the ceiling relationship.

This is stronger than trying many random traces, and it also clarifies the claim’s scope.

**In particular, the corruption theorem should not silently become “arbitrary repeated corruption can never cost more than one satoshi.”** Nor does the arithmetic theorem alone establish a bound on every downstream authorization or cancellation effect. Those require separate composition arguments.

### Then prove its interaction with the ledger

The specs correctly distinguish the full computed debit from the amount actually charged after commitment clamping. They also require corrections to leave the meter state untouched. Those distinctions are central to avoiding previously documented double charges.

The next formalization should therefore include three separate quantities:

$$
\text{computed debit}
$$

$$
\text{tenant debit}=\min(\text{computed debit},\text{remaining authority})
$$

$$
\text{operator deficiency}=\text{computed debit}-\text{tenant debit}
$$

The rounding recurrence advances using **the computed debit**, not the smaller ledger entry.

A useful regression trace is already documented:

```text
Computed consumption: 100 sats
Remaining commitment: 30 sats

Tenant debit:          30
Operator deficiency:   70

Next computed consumption: 50 sats
Correct next computation:  50, not 120
```

Turn this into a checked witness, then prove that the corrected transition cannot reintroduce the absorbed amount through the rounding state.

I would also model increment clipping and the high-water mark. An idempotency key prevents an exact replay, but the stronger property is:

> No billable interval is charged twice, including overlapping re-metering after restart.

That requires specifying how an increment’s start and end relate to the stored high-water mark, not just proving that duplicate keys are rejected.

### Tighten “bounded state”

There is another useful specification clarification here:

**A rational value bounded between zero and one does not necessarily have a bounded-size representation.**

Its denominator can still become large. The current design bounds the residual’s *magnitude* and the number of state fields, not automatically their bit size.

The Lean model should use exact rationals initially. A later fixed-width implementation needs a separate representation theorem or explicit overflow policy. Otherwise, an implementation can satisfy the mathematical formula only approximately while appearing to implement it exactly.

---

## 3. Second project: prove the cancellation/extension protocol

This is probably the most valuable lifecycle proof.

`OPS-41`, `OPS-42`, and `LDG-62` jointly protect the interval between deciding that a machine is unfunded and sending the destructive provider request. The specs explicitly require the funding re-check and fence write to occur in one transaction, followed by the provider call outside the money serialization.

### Model the real boundaries

Do not represent cancellation as one abstract action that instantaneously checks funding and destroys the machine. That abstraction would remove the race the requirements exist to prevent.

Represent at least:

```text
Queue cancellation
Claim operation
Commit funding re-check and cancellation fence
Release database transaction
Dispatch provider mutation
Observe provider result
Commit settlement
```

Runway extension is a competing transaction that checks the fence and updates the commitment.

The model should permit an extension between any two non-atomic steps.

### State the guarantee narrowly enough to be true

“Funded machines are never deleted” is too broad. Tenant suspension, explicit customer deletion, later consumption, and changing rates complicate that statement. The current cancellation logic deliberately checks the tenant’s **current** suspension state rather than historical episode reasons.

A better proof obligation is:

> For a funding-based cancellation of an active tenant’s machine, under the applicable rate and re-check rules, a sufficient extension committed before the cancellation decision is observed by that decision. An extension attempted after the cancellation fence is committed is rejected without opening or growing a commitment.

The proof should establish both orderings:

| Transaction ordering               | Required result                                                                             |
| ---------------------------------- | ------------------------------------------------------------------------------------------- |
| Sufficient extension commits first | Cancellation re-check sees the updated authority and aborts that funding-based cancellation |
| Cancellation fence commits first   | Extension is rejected and does not consume available authority                              |

The exact point at which these operations take effect becomes part of the formal specification.

### Include the episode, not just the operation

The fence holds an **episode ID**, not an attempt’s operation ID. A later retry under the same episode must be able to proceed, while a closed episode must not reacquire a fence. The specification also requires gone observations to close the episode and clear the fence.

Useful target properties include:

* A closed episode never becomes open again.
* A fence refers to the relevant open cancellation episode.
* A failed attempt does not falsely resolve an episode whose resource still exists.
* Recording the resource gone closes its open episode and clears its fence atomically.

These should be properties of the **combined machine–episode–operation transition**, not three independent state-machine proofs.

### Preserve the historical counterexamples

The current arithmetic gate already contains the sub-second runway counterexample:

```text
Usable balance: 1 sat
Rate:           2 sats/second
Runway:         floor(1 / 2) = 0 seconds
```

Aborting cancellation because `usable_sats > 0` sends the unchanged machine back into the same route/abort cycle.

Keep this as a checked negative witness. Also keep a variant that separates the funding read from the fence transaction and demonstrates the accepted-extension/deleted-machine race.

**A successful proof should be accompanied by evidence that removing the relevant protection actually makes the bad trace possible.**

---

## 4. Third project: formalize ADR-0022’s retry semantics

The new claim-number rules are an especially good formal-methods target.

ADR-0022 describes a subtle failure within a single engine process:

```text
Execution A claims operation under claim number 1
A defers it
The defer commits, but its reply is lost

Execution B claims the same operation under claim number 2

A retries its old defer write
```

A guard checking only `status = running` accepts A’s stale write because B has made the row running again. The claim-number condition is what rejects it.

### Distinguish the identities in Lean

I would use distinct types for:

```text
OperationId
ClaimNumber
EpisodeId
```

These should not be interchangeable aliases of one integer or UUID type.

Their roles are different:

| Identity     | Meaning                                                         |
| ------------ | --------------------------------------------------------------- |
| Operation    | One attempt                                                     |
| Claim number | One execution’s ownership of the queued operation               |
| Episode      | A recovery/cancellation process that may span multiple attempts |

The current specs explicitly distinguish those concepts, including that a deferred operation may have several claims without becoming several attempts.

### Model a committed write with a lost response

The model needs separate facts for:

```text
The database committed the transaction.
The worker learned that it committed.
```

Similarly, for provider calls:

```text
The request was dispatched.
The provider applied it.
The worker received a response.
```

Collapsing either pair would erase provisiond’s central uncertainty problem.

The main proof obligations should be:

**Same-write repetition is harmless.** Repeating an accepted settlement with the same claim and same result does not duplicate ledger effects, advance revisions again, or change the recorded result.

**Stale executions cannot overwrite later claims.** A repeated write from claim N cannot change the operation after claim N+1 takes ownership.

**Database retry does not imply provider retry.** Repeating a store transaction never takes execution back across an already-dispatched non-repeatable provider mutation.

**Ambiguity is preserved.** A lost provider response does not become evidence that nothing happened.

The specification already distinguishes settlement repetition, defer repetition, and a lost response to the claim itself. The latter is fatal rather than blindly retried. Those should remain distinct transitions in the model.

Importantly, the resulting theorem is **not** “the provider can never create two machines.” It is that provisiond does not re-dispatch the purchase through its prohibited retry paths. Provider-side duplication remains an external possibility requiring reconciliation.

---

## 5. Compose those proofs with money and evidence

Once the first three projects exist, I would connect them into a small end-to-end slice:

```text
Authorize create
→ reserve authority and enqueue atomically
→ dispatch
→ lose response
→ enter needs_reconciliation
→ release commitment after the negative window
→ observe the machine later
→ attach and route cleanup
→ accept extension or commit cancellation
```

That slice crosses the most important boundaries in the design.

### Spending authority

The ledger specification defines available balance as ledger balance minus open commitments. Consumption decrements both the balance and the relevant commitment, while closing a commitment releases the exact remaining reservation. Funding idempotency is based on the payment’s rail identity.

Prove transaction properties such as:

> Every accepted new reservation was authorized against current available funds at its commit point.

and:

> Replaying one payment identity cannot create a second funding credit.

Avoid starting with an overly broad invariant such as “available balance is always nonnegative” without first specifying how every correction and exceptional transition affects it.

### Reconciliation knowledge

A particularly important distinction is:

> Releasing a commitment after the negative window does not establish that the provider created nothing.

That distinction is explicit in `OPS-33`: the commitment closes while the operation remains unresolved, and a later observation follows the late-attach path.

Model separately:

```text
Resource observed
Authoritative absence established
Outcome still unknown
Customer authority released
```

Do not make “unknown” a disguised Boolean absence.

Likewise, a completed listing is not automatically a snapshot. The specs require a direct reread before recording a missing machine as gone, and distinguish complete from interrupted pagination. Those conditions should be represented in the evidence-producing transitions.

### Machines and attachments

Prove that stopping a machine’s meter does not automatically stop its billable attachments or release their remaining authority. The specification deliberately distinguishes resource disappearance, meter stopping, tombstoning, and commitment closure.

This is exactly the kind of cross-document interaction where separate, individually correct definitions are insufficient.

---

## 6. Treat recovery and deployment assumptions as part of the theorem

This is where Lean could improve the *honesty* of the specifications as much as their consistency.

### A restore is not a crash

The repository now correctly distinguishes ordinary restart from restoring older database state. `STO-54` acknowledges that a restore can erase an accepted extension, resurrect a credential, and return an already-executed operation to `queued`. It also explicitly states that commitments are not reconstructed from payment history.

The formal model should therefore contain separate events:

```text
ProcessCrash
ProcessRestart
RestoreEarlierDatabaseState
CompleteRecoveryProcedure
```

A theorem proved only over crash/restart traces must not be presented as covering restoration.

There is also an important limit to the current recovery mechanism:

**Setting `exhausted_since` and waiting an interval does not reconstruct an extension lost from the database.**

Consider a fixed-rate trace in which an extension was acknowledged, a restore erases it, and nobody submits another extension during the grace interval. The restored commitment remains insufficient afterward.

That means the recovery model cannot establish “every acknowledged extension remains effective” merely from the grace mechanism. The formalization should force an explicit choice: preserve recoverable authority evidence, quarantine affected destructive decisions until authority is re-established, or state a weaker recovery guarantee.

This is not a claim that the specs overlook all restoration loss. They explicitly record unrepaired state. The value of Lean is to make clear **which advertised theorem does not survive that acknowledged loss**.

### Measured provider bounds remain assumptions

The effective visibility window is defined as the maximum of a declaration and recorded observations. The model can prove that ordinary updates do not decrease that stored maximum. It cannot turn those observations into proof that a future provider response will never take longer.

Keep separate:

> Our window calculation is monotone.

and:

> The provider always becomes observable within that window.

The first is a software property. The second is an environmental assumption or service guarantee supported by evidence, not by the calculation itself.

### Single engine means single engine

`OPS-47` explicitly makes supervision a deployment obligation and excludes a partitioned old engine that remains able to reach providers. The startup advisory lock is not a fence on external effects.

Do not accidentally “prove” protection from two engines by leaving the second engine out of the model and then forgetting that assumption in the theorem’s description.

### Mixed versions need semantic compatibility

ADR-0024 already identifies the important case: an old API and new engine can agree on the schema while disagreeing about runway calculations or idempotency keys.

Lean can help classify a change as:

> Both versions preserve the same authority and transition semantics.

or:

> The mixed-version theorem does not hold, so the specified stop-all upgrade rule applies.

Do not relax the current conservative upgrade requirement merely because a schema migration is structurally compatible.

---

## 7. How I would organize the Lean specification

### Keep it inside the existing specification-checking boundary

A suitable initial layout would be:

```text
tools/formal/
  lean-toolchain
  lakefile.toml

  Provisiond/
    Units.lean
    Meter.lean
    Runway.lean
    Operations.lean
    Cancellation.lean
    Reconciliation.lean
    Recovery.lean
    Witnesses.lean

  Main.lean
  requirements.json
```

`Main.lean` would expose an executable test oracle, not a production daemon.

Start with `Units`, `Meter`, `Runway`, and `Witnesses`. The other modules are the expansion plan, not prerequisites for the first useful result.

### Use executable definitions plus an explicit transition relation

I would use pure functions for deterministic decisions and arithmetic, with a transition relation for scheduling, external outcomes, and failures.

For example:

```text
Deterministic:
  calculateDebit
  calculateRunway
  classifyFailure
  evaluateCancellationDecision

Nondeterministic environment:
  loseDatabaseReply
  applyProviderRequest
  loseProviderReply
  crashProcess
  observeProviderState
```

The safety proof has the familiar structure:

$$
Init(s)\Rightarrow Invariant(s)
$$

$$
Invariant(s)\land Step(s,e,s')\Rightarrow Invariant(s')
$$

Therefore, every reachable state satisfies the invariant.

**Do not define `Step` to require the desired post-state invariant.** That would assume the result instead of checking that the operational rules produce it.

Also require successful execution witnesses. A model that refuses every create and every cancellation can satisfy many safety properties while specifying an unusable system.

For progress properties, state the necessary scheduling and availability assumptions. “Every unresolved operation eventually resolves” is not an unconditional guarantee this system should claim.

### Give each formalized rule one authority

I would add an ADR establishing:

> For explicitly formalized calculations and transition tables, the named Lean definition is the semantic authority. Markdown retains the requirement’s intent, rationale, assumptions, and human-readable explanation.

Without that rule, Lean becomes another independently maintained copy that can drift.

Generate selected tables, examples, and fixtures from the formal definitions. Keep unformalized requirements in Markdown. The goal is not to migrate the entire writing system.

Verso could eventually support documentation with checked Lean examples and cross-references, but I would defer a documentation-platform migration until the first proof modules have demonstrated value. ([GitHub][2])

---

## 8. Connect it to CI and future implementations

### Track evidence, not just coverage

A requirement-to-proof manifest could contain:

```yaml
LDG-38:
  definition: Provisiond.Meter.computedDebit
  theorems:
    - Provisiond.Meter.credit_range_preserved
    - Provisiond.Meter.computed_total_eq_ceiling
    - Provisiond.Meter.partition_invariant
  conformance:
    - CNF-185
    - CNF-216
  assumptions:
    - exact_nonnegative_costs
    - fixed_billing_period_partition
```

These are proposed declarations, not existing repository symbols.

The gate should resolve actual declarations and record their statements and assumptions. A changed normative source section should trigger review of its mapping, even when the old theorem still compiles.

Keep evidence categories distinct:

| Evidence                        | What it establishes                                                     |
| ------------------------------- | ----------------------------------------------------------------------- |
| Proved in Lean model            | The formal rules imply the stated property under the listed assumptions |
| Bounded trace exploration       | No counterexample occurred within the explored bounds                   |
| Implementation conformance test | A particular implementation behaved correctly on tested executions      |
| Provider observation            | A particular external behavior was measured                             |

A Lean proof must not automatically tick an implementation conformance item.

### Preserve and extend the existing mutation-test culture

Retain the current Python gates. Add Lean checks alongside them, then generate exact arithmetic fixtures for cross-checking.

Historical broken designs should remain executable negative examples: per-tick rounding, the `usable_sats > 0` cancellation abort, a missing claim guard, a funding read separated from its fence write, and an absence decision based on incomplete listing evidence.

For proof integrity, audit transitive axiom dependencies and reject unfinished proofs using `sorryAx` or unreviewed project axioms. Standard logical axioms need an explicit policy rather than an indiscriminate “zero axioms” rule. Lean provides `#print axioms` for this inspection. Compiler-backed proof mechanisms such as `native_decide` also require an explicit trust policy rather than being silently treated as kernel-only checking. ([Lean Language][3])

### Use the executable model as an implementation oracle

When an implementation exists, feed the model and implementation the same normalized commands and failure schedules:

```text
create
claim
provider accepts request
provider reply lost
restart
reconcile
extend runway
cancel
```

Compare observable outcomes, ledger effects, episode transitions, and dispatched provider requests.

This gives every implementation a common behavioral reference while retaining language neutrality. It is stronger testing, **not yet a proof that the implementation refines the model**.

For a future Rust implementation, Aeneas is worth considering specifically for the pure billing or decision core. Its current scope includes a subset of safe Rust and a Lean backend, while concurrency and unsafe-code support remain limitations. I would not make whole-system Tokio/PostgreSQL/provider verification depend on it. ([GitHub][4])

---

## The first changes I would make

| Change                                         | Concrete acceptance criterion                                                                                                     |
| ---------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| **Resolve the two specification issues above** | The month-reset policy states its actual effect, and migration rules distinguish transactional from concurrent-index steps        |
| **Add the first Lean arithmetic module**       | General rounding invariants and cumulative-equivalence proofs, with the historical runway witness and period-reset example        |
| **Add the claim/retry model**                  | Same-write repetition is harmless, the stale-defer trace is rejected, and removing the claim guard admits the counterexample      |
| **Add the cancellation/extension model**       | Both transaction orderings satisfy the scoped funding guarantee, and separating the re-check from the fence exposes the bad trace |
| **Compose and connect**                        | Requirement mappings, generated fixtures, explicit assumptions, and a runnable oracle for future conformance tests                |

**The highest-value first deliverable is a proved `LDG-38`/`LDG-33` arithmetic specification, followed by a small model of `OPS-42` and ADR-0022.** Those targets are narrow enough to review, directly address defects the repository has repeatedly encountered, and establish a reusable pattern for the rest of the system.

The success criterion should be: **a plausible but incorrect amendment can no longer pass review merely because its prose sounds consistent.**

[1]: https://www.postgresql.org/docs/current/sql-createindex.html "PostgreSQL: Documentation: 18: CREATE INDEX"
[2]: https://github.com/leanprover/verso "GitHub - leanprover/verso: Lean documentation authoring tool · GitHub"
[3]: https://lean-lang.org/doc/reference/latest/Axioms/ "Axioms"
[4]: https://github.com/AeneasVerif/aeneas "GitHub - AeneasVerif/aeneas: A verification toolchain for Rust programs · GitHub"

