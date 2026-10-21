# Panel r60 synthesis: pv-1wn review, whether `CNF-202`'s suspended-create case can be set up, 2026-10-21

Readers: fable (claude-fable-5-1, xhigh), opus (claude-opus-5-5, xhigh), astra (gpt-6-astra, high) and sol
(gpt-6.1-sol, xhigh). Each had its own clone of branch `pv-1wn` at `9088148`. All four exited 0, with answers of
3.0-4.0 KB. Every quotation below was checked against `9088148`. The brief is `brief.md`. The patches and gate logs
the readers link stay under `/var/tmp` and are not committed.

## The story

pv-1wn gave `CNF-202` a case for `API-58` step (4): suspend a tenant holding a caller's create that is still `queued`
and never claimed, and assert it is `failed` with `conflict` and `details.reason: "tenant_suspended"`, `requested_by:
caller`, a null `system_reason`, and no provider request. The `/code-review` of the branch reported that a conforming
engine can't reach that state. The create is older than the `suspend_tenant` parent, and `OPS-6` says “The claim MUST
select the oldest `queued` operation whose availability time has passed”. A create names no machine, so `OPS-8`'s
index never holds it back. The manager proposed holding a caller's power operation behind a `running` operation on
the same machine instead.

## Errors in the brief that the readers caught

- **`OPS-27` does not cancel the create (opus).** The brief said the suspended-attach clause “cancels it”. `OPS-27`
  says that transaction “also enqueues a system cancellation” for the machine. The create settles `succeeded`, and
  `LDG-39` debits the setup fee “when the order is known to have landed and the create settles”, with the first unit
  beside it. The tenant pays the fee and first unit for a machine bought after its suspension.
- **“Can't be put into” is too strong (astra, sol, fable).** No reader found a deterministic API-level route for the
  create. None proved one impossible either:
  - fable: an admission race. A create whose `API-7` step 5b read came before the flag can commit with a later
    `created_at`. That is not deterministic unless its transaction is held in flight.
  - astra: seed a future `available_at`. sol: exercise the step-(4) write directly at the store, as `CNF-290` tests a
    claim “directly at the store”.
  - Both say this covers the transition, not reachability through the scheduler.

## Picks

| | fable | opus | astra | sol |
|---|---|---|---|---|
| Q1 create reachable on a conforming engine | not deterministically; admission race only | no, not deterministically | not via the ordinary queue; impossibility unproven | no deterministic route; impossibility unproven |
| Q2 power-operation route | real | real | real | real |
| Q3 fixture | **(a)** | **(a)** | **(a)** | **(a)** |
| Q4 create reachability | real gap | gap: the outcome is defined but nothing says it is intended | real gap | real gap |

Strongest argument for (a), each in its own words:
- fable: “An item no conforming engine can run is `pv-1wn`'s bug in a new coat: a wrong reason still passes.”
- opus: “What's settled is the step and the quotes, not the kind of operation. A conformance item that no conforming
  engine can be set up for is a box anyone can tick.”
- astra: “The power fixture follows an existing queue path without assuming a create delay.”
- sol: “A reproducible queue fixture covers the approved rule without waiting for new policy.”

Each reader's strongest argument against (a), written on request: the approved brief names a create. A create-only
error bug, and `pv-gvc`'s commitment release, are then not covered (all four). fable adds: changing the fixture
under `pv-1wn`'s id rewrites what a closed bead says it did, and if “create” was the owner's term, (c) is the honest
route. astra and sol add: a store-level create fixture could keep the create coverage alongside.

## What was checked

- **The power route.** `OPS-8` says the refused claim “MUST return the operation to `queued` with a short delay”, and
  `OPS-6` says it “never left `queued` and does not advance the number”. `ADR-0022` reconciles the verbs: “An
  index-refused claim never left `queued`”. `05-persistence.md` gives `claim_number` “default 0 for never claimed”.
  `CNF-290` already asserts “the refused operation's `claim_number` did not advance”. `API-58` step (4) covers “the
  tenant's own work”, so all three quotes apply unchanged (4-0).
- **No defer route for the create.** `CONTEXT.md`: a claim “after an `OPS-8` defer — gets the next number”.
  `API-63`: “Queued eligibility still requires never claimed, including after a defer”.
- **Nothing re-checks suspension at claim.** `OPS-43` step 1 reads “the provider account's stored status”, not the
  tenant's (fable). `API-58` promises “nothing further can be bought” (fable, astra, sol). `OPS-23` says “Validation
  that was performed at the API boundary MUST be repeated in the worker before the driver is called” (sol).
- **Catches for the power fixture (the readers' union):**
  - the holder must not be yielded;
  - a second worker must be free to claim the parent;
  - step (3)'s cancellation is also refused behind the holder, so the parent settles only after the hold is
    released, and the assertions come before that;
  - astra and sol want a controlled clock so that the power operation's delayed `available_at` hasn't passed when
    the parent is claimed. opus says `OPS-8`'s delay alone keeps the worker from re-selecting it.
- **Plants.**
  - fable changed a word inside its new `OPS-6` quote, and `citations` went red (exit 1).
  - opus removed the holding text, leaving a bare swap to a power operation. astra and sol changed the refused
    claim's expected number from 0 to 1. All three of those stayed green.
  - opus's first draft went red in `citations`: the gate attributed an `OPS-6` quote to `OPS-8` within one sentence.
  - The fixture's semantics are invisible to the gates. `Claim.lean` represents `OPS-8`'s “short delay” by `none`
    and models no claim ordering. Only an engine run catches a fixture that can't be set up.

## Drafting points the four drafts leave open (not voted)

- Order of the steps: refuse the power claim and check `claim_number` 0 before suspending (fable, opus, sol), or
  suspend first and then attempt the claim (astra).
- Whether the `claim_number` 0 check is an assertion or a setup check. opus notes `API-58` doesn't state it, and it
  quotes `OPS-6` either way.
- fable's draft adds a sentence on why a create can't be the fixture. That is an argument, and `AGENTS.md` gives
  arguments owners: it belongs in the bead or the record, not in the item.
- Keep the `OPS-6` and `OPS-8` quotes in separate sentences (opus's red first draft).

## The create-reachability question (all four: a real gap, not settled anywhere)

- `API-58` step (2) covers only “a create claimed before the suspension landed”.
- `SEC-45` asks to “Suspend a tenant and cancel its fleet in one operator action”.
- `API-58` calls `OPS-27`'s attach-time cancellation a backstop: “settlement here is not the last guard”.
- No text says that a create first claimed after the suspension landed may dispatch, attach, be charged its fee and
  first unit, and then be cancelled.
- opus frames the bead as a question about whether that outcome is intended, not as a demand that nothing dispatch.
  fable names the cheapest fix: a tenant-status read in `OPS-43` step 1.
- The manager's draft bead is `/var/tmp/provisiond-gates/bead-draft-1wn-create-reachability.md`, not filed. It
  needs opus's correction: the create succeeds and is charged, it is not cancelled.

## Where a ruling lands

- (a): `CNF-202`'s pv-1wn case, rewritten on the `pv-1wn` branch, and the reachability bead filed needs-triage.
- (b): no checklist change, and the bead filed.
- (c): pv-1wn reopened, its case reverted, and the bead filed with pv-1wn depending on it.
