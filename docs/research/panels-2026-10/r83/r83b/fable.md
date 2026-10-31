**Verification.** HEAD is `3109b5b44eae17e288cf52aaa976993bd8c5626c` and the clone is clean. I read notes.md whole and every exact form completely. API-58 at `04-api-contract.md:617–753`, the OPS-43 excerpt, CNF-202 at `10-conformance-checklist.md:2252–2275`, OPS-27's suspended-attach clause, STO-3's guard cases and LDG-35 all match the packet line for line. I changed no files, Git state or tracker records, ran no gates, Lean, subagents or background work, and opened no other seat's folder.

**Rule 6.** No verified brief error changes the Q4 premise. Nothing is voided. Three non-void defects, none the basis of any vote:

- A, B and C call `about_to_order_at` a "marker" in "previously committed marker/correlator" and "null-marker term". CONTEXT.md's About-to-order time entry says the column is "distinct from a **marker** or correlator" and lists marker under _Avoid_. D uses the glossary's word.
- A, B and C's step (2) anchor begins inside `**fences work already in flight**`, so the landed text leaves an unclosed bold span. D's anchor is explicit and correct.
- Every form omits the backticks the citation gate reads around identifiers and quotes. That is a landing convention.

## The disputed trace, decided

Run the trace against the forms' step (2) and the pinned promise.

1. **10:00.** Step 8 commits and is acknowledged while the tenant is active. The tenant guard affected one row, and `about_to_order_at` and the correlator are committed. Under step (2) as every form rewrites it, this create "passed OPS-43's tenant dispatch guard before the suspension landed", so it "is potentially dispatched and MUST be allowed to settle".
2. **10:01.** Suspension commits. API-58 step (1) writes the flag "in the admission transaction, before the `202` is returned". The worker holds nothing across the provider call, because `LDG-69` says an implementation "MUST NOT wait on ... any provider call" under the primitive.
3. **10:02.** Step 9 orders and the provider accepts. Attach runs `OPS-27`: "Where the machine's tenant is suspended at the moment of the attach, that same transaction also enqueues a system cancellation". `LDG-39` makes the setup fee a debit "only when the order is known to have landed and the create settles", and the prepaid first unit follows it. So the customer pays fee and first unit for a machine bought after the operator's action, then cancelled.
4. The pinned promise reads "nothing further can be bought", and "The terms and the operator documentation MUST say so in those words".

**Finding 1: the trace is already in the unchanged base, in a wider form.** Pinned step (2) says "a create claimed before the suspension landed MUST be allowed to settle rather than abandoned mid-order, and its machine is then cancelled by the same sweep". Pinned OPS-43 step 1 reads only "the provider account's stored status" and never the tenant. So at the pin a create claimed at 10:00:30 runs steps 1 to 9 with no tenant check at all and buys at 10:02. OPS-27's clause exists because otherwise "a create resolving *observed* after that settlement attaches a funded, billing machine to a suspended tenant". The promise and the residue were written side by side in one requirement. The pin's own structure treats the step (2) fence as the qualification of the promise. Every form shrinks the residue from "claimed before" to "passed step 8 before".

**Finding 2: no checked verdict moves in either direction.** No CNF item asserts the words of the terms. CNF-202, CNF-272 and the other items that cite API-58 quote other clauses. The citation gate reads root `*.md` and `docs/adr/*.md`. The only quotes of the promise sentence outside API-58 sit in `docs/research/` panel records, which the gate does not scan. The two Lean declarations tagged API-58 are the reap refusal at Funding.lean:1011 and the flag-plus-enqueue at Fence.lean:1083. Neither models the promise.

**Rule 3 verdict: not a verified block against A, B or C.** Rule 3 needs a verdict changed, made unreachable or vacuous, or a MUST that the form's text contradicts. The quoted MUST is untouched by A, B and C. The words it prescribes become truer under every form, not falser. A pre-existing imprecision that a form narrows belongs to the same class as rule 3's "merely absent new runtime test". It is a property of the unchanged base, reported with the tally.

**On the merits of the specific disagreement.** Sol is right that the detailed exception qualifies the promise as its author wrote it, and right that no stricter boundary exists. Astra is right about one thing the exception cannot reach. "In those words" puts an unqualified sentence into customer terms and operator documentation, where no qualifying exception travels with it, while the specification itself names a residue in which a fee and a first unit are debited after the operator's action. That is a disclosure-quality defect worth correcting. It is not a condition of the mechanics, and it is not what the owner asked Panel D to settle. So the promise does not have to change for a form to be acceptable, and D's correction of it is acceptable and better.

## Forms

| Form | Acceptability |
|---|---|
| A | ACCEPT |
| B | CANNOT ACCEPT |
| C | ACCEPT |
| D | ACCEPT, preferred |

**Q4-A ACCEPT.** Strongest reason: the step-1 read fails the owner's story before List offers. The same-row tenant write in step 8 makes the second story "one provably loses", which is the shape API-63 already uses for the account row. `retryable: false` is DOM-17's answer. While suspended, the same request is refused `suspended` at API-7 step 5b, resume is an operator act, and WIR-41 refuses resume while the parent is unsettled. Condition: none blocking. At landing, replace "marker" with the column name, close the bold span, add backticks.

**Q4-B CANNOT ACCEPT.** Reason: `retryable: true` fails DOM-17's test, "whether repeating the *same request* is safe and sensible", on the concrete case. The same request gets a 403 `suspended` at step 5b until an operator decides otherwise. API-51 makes the field "normative for callers", so true steers an agent into repeated refusals. The recoverable account statuses get true because a gate "can recover" by itself. Suspension is a judgment about the caller and clears only by a human decision about that caller. Opus, sol and astra found B defensible by analogy. I keep my r83 position. The only condition under which I would accept B is the value itself, which is a substantive change, so I propose no repair.

**Q4-C ACCEPT.** Reason: it stops before spending on every path, and differs from A only in precedence. Condition: none blocking. Why not preferred: a suspended tenant's create on a closed channel is told `rate_limited` with `retry_after_ms`, inviting a resend step 5b will refuse. Note that D's new precedence case asserts `tenant_suspended` wins over a closed channel, which is C's mirror image. The two cannot both land. Since one form lands, that is not a defect.

**Q4-D ACCEPT, preferred.** Items 1 to 4 and 6 are A's mechanics with four corrections. The column is named as the glossary names it. The bold-span anchor is explicit. The first fixture carries prerequisites, a healthy account and an open channel, so the case exercises the tenant refusal and not an earlier check. The precedence tests supply the first-failure order the Q4 question asked for, and they agree with the step-1 placement. Item 5 is a substantive disclosure change and I reviewed it as one. It flips no checked verdict, as shown above. It preserves the paragraph's purpose, which is the branch where a child cancellation fails and a machine of a suspended tenant keeps running, through "not a promise that the fleet is gone" and "MUST NOT promise ... that cancellation has already succeeded". It states the residue the specification already names. Named changes: the exact-words duty becomes an explain duty with stated content, and the rationale clause about "suspended" reading as "stopped" is dropped. Two nits, neither blocking. "New purchase authorization" and "authorized for dispatch" use a word CONTEXT.md's Commitment entry lists under _Avoid_ in the card-payments sense. The glossary says of itself that it is not normative, and API-58 already says "tenant-authorized", so this is vocabulary for the lander or owner, not a rule. A requirement identifier sits inside a bold promise sentence. The MUST clause does not require the terms to reproduce that sentence, so the terms can still be written in plain words.

## Breaking trace

None found for A, C or D. I checked both orders of the step-8 tenant write against the suspend admission. I checked the lost-acknowledgement repeat with a suspension between: the repeat fails the guard, the column stays set, the create settles `failed` by position under OPS-11's create row, and no step 9 runs. I checked a crash between step-8 commit and step 9: the restart sends the set-column create to `needs_reconciliation`, and resolution either finds nothing or attaches and cancels under OPS-27. I checked the owner's story, first pickup at 10:02 after a 10:01 suspension: refused at step 1 in A, B and D and at step 3 in C, with no provider request and full release.

Lock order for the new tenants-row write. `LDG-35` states its primitive as "per-tenant advisory locks", not a lock on the tenants row. The tenants row is locked by the suspend flag write, by WIR-41's resume, and now by step 8. The first two touch no other locked row. Step 8's order is the generation row `FOR SHARE`, then STO-47's row, then the tenants row, then the operations row. Create admission conditional-writes STO-47's row under the advisory lock and never locks the tenants row. API-63's recording takes STO-47's row and then advisory locks. No cycle exists, so a deadlock cannot form, and a plain serialization failure takes OPS-49's whole-transaction repeat as every form says.

## Formal scope

The mechanics sit outside the current model. Claim.lean's opening scope omits "`API-58`'s fan-out transition". AccountStatus.lean omits the recording transaction's "contention with admission on the account row". Reconcile.lean models one create's knowledge, not a dispatcher. Every form settles a pre-step-9 recorded failure `failed`, which keeps `create_before_step9_failed` in Tables true. No declaration needs a changed statement or a weakened guard under any form, and I claim no new coverage.

## Follow-ups, not conditions

- API-58 step (4)'s own `tenant_suspended` failure states no `retryable`. Give it this value and assert it in CNF-202, or the same reason carries two values by path.
- WIR-9a's `conflict` list credits `tenant_suspended` to API-58 alone. Add OPS-43 as a second emitter.
- List the step-8 tenants-row conditional write in STO-6 and STO-27's primitive lists.
- If A or C lands instead of D, open a bead to sharpen the promise sentence as D's item 5 does, since the imprecision is real and pre-existing.

Final Q4: Q4-D; acceptability A ACCEPT, B CANNOT ACCEPT, C ACCEPT, D ACCEPT.
