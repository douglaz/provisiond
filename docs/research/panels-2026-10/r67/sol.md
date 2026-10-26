Reviewed F, S, K and N at `c5f897c`. No gates or `lake` run.

**Q1 — F: CANNOT ACCEPT. S: AMEND. Pick S.**

F flips an unlisted assertion: `10-conformance-checklist.md`, `CNF-340`, requires a withheld offer’s create refusal “before any provider call or write”; F first calls List offers. A closed-channel create also breaks `02-provider-contract.md`, `PRV-40`: “refuse subsequent creates on that account and channel before any provider call”. These are concrete refusal traces, independent of the assertions F explicitly amends.

The no-call rule keeps locally rejected purchases from consuming provider requests or depending on provider availability. F lets repeated insufficient-balance requests spend listing reads. `API-29` says “The service SHOULD rate-limit per tenant”; that supplies no stated account-wide listing-read budget. No listing-endpoint limit is evidenced here. S’s engine writes require the fence: `OPS-50` covers “every write transaction made in the engine process”; it expressly says “Writes made in the api process are not checked.”

Admission and claim need independently specified observations. Claim requires “one current driver List offers result taken at claim” (`OPS-43`). That fresh re-test is sufficient; making it reuse admission’s observation would retain stale terms.

The forms name the offer source, but explicitly cover all offer-derived reserve and retained-record inputs. Preserve descriptor inputs and acceptance-time date resolution. S also needs an assigned refresh component and an authentication exception: `PRV-41` says a driver “MUST NOT re-attempt it on a schedule”.

*Against my pick:* S admits purchases using outdated terms within its age bound. It adds storage, publication races, periodic work and configuration; F supplies a simpler relationship between each request and its observed offer.

**Replacement text — S deltas**

In `API-7`, append to S’s source paragraph:

> Every offer-derived input used to size the commitment or populate `request_summary` comes from the named offer in that same stored listing, including recurring price, currency, period, setup fee, `install_strategies`, and any offer-reported billing unit or cancellation bound. Descriptor-declared inputs come from the descriptor the `api` runs with. See `PRV-44`, `PRV-13b` and `05-persistence.md`.

Replace S’s rule beside `offer_listings`:

> **STO-60** `read_at` is the dispatch instant of the successful driver List offers call. Every successful driver List offers read MUST publish its complete result to the account’s row, replacing an existing row only when the incoming `read_at` is later. A failed read MUST leave the row unchanged. See `OPS-51`.

Add in `03-operation-lifecycle.md`:

> **OPS-51** A refresh pass MUST read every account declaring `list_offers` at least once per stated offer-listing refresh interval, except while that credential is subject to the authentication stop. `PRV-41` says “A driver MUST therefore treat an `authentication` failure as terminal for that credential, MUST NOT re-attempt it on a schedule, and MUST surface it for an operator”.

Add to `OVR-17`’s table:

> | Offer-listing refresh (`OPS-51`) | `engine`, running in the engine process | See `OPS-50`. |

Register S’s age under `API-7`, and refresh interval under `OPS-51`. In S’s added price case, replace “at a higher price” with:

> at a higher price sufficient to exceed what the admitted reserve covers, leaving the stored listing unchanged until admission

**Replacement text — additional amendments required if F is chosen**

- In `PRV-40`, replace admission’s “before any provider call” with “before any provider mutation; the create’s admission List offers read is permitted”.
- In `CNF-340`, replace “before any provider call or write” with “before any provider mutation or purchase write; the admission List offers read is permitted”.
- In `CNF-283`, replace “Subsequent local refusals make no provider request” with “Subsequent local refusals make no provider request other than the create’s admission List offers read”.
- Replace F’s failed-read sentence:

> A failed read refuses the create before the tail with the driver error’s own kind, details and retryability, committing nothing. See `PRV-5` and `PRV-41`.

**Q2 — K: AMEND. N: AMEND. Pick K.**

K keeps one durable artifact representation without making automatic eligibility depend on its presence. Scope its insertion to Robot and scope its conformance assertion to the recording transaction.

For `CNF-303`, K’s retained machine contains `(ssh_key_fingerprint, fingerprint)` from the operation; N’s contains the same pair from `request_summary`. The tagged key group links the operation id to that fingerprint. Consequently, retention removes no provisioning guard, and every tagged key remains registered while the machine reads `provisioning`. Explicitly require the generated key beside caller keys; a caller-only order then violates either form rather than producing an unspecified pair.

Neither permits automatic attach after the lost reply, even with one matching transaction. `PRV-33` says “attaching a discovered machine to a tenant MUST be an operator action”. N deliberately gives operation-pair readers null; operator evidence comes from the summary. Its machine index and retained-machine sweep input remain populated.

N’s “as operator evidence only” conflicts with its automated copy into the machine and subsequent sweep use. Replace that restriction. K’s unconditional fingerprint assertion also reaches failures before recording: the operation row says “Written in `API-63`’s correlator transaction”. Qualify the assertion by whether that transaction committed.

*Against my pick:* A populated pair can tempt future consumers to mistake an unverified fingerprint for automatic-resolution authority. N makes that distinction visible in the operation row, at the cost of another source to copy correctly.

**Replacement text — Q2 deltas**

Replace K’s `PRV-26` insertion:

> For Robot, this recording obligation applies on every ordering channel, including one declared `correlator: none`: the kind is `ssh_key_fingerprint` and the value is the per-order key’s fingerprint. See `PRV-33`.

For either form, replace the proposed key-generation sentence in `PRV-32`:

> On every Robot ordering channel, including one declared `correlator: none`, the driver MUST generate a throwaway key unique to that order and send its public key with the order, in addition to the caller’s keys. See `PRV-26` and `PRV-33`.

For K’s `CNF-278` replacement:

> asserting the fingerprint pair on both descriptors where the step-8 transaction committed, and a null pair before any step-8 transaction committed

For N’s `CNF-278` replacement:

> asserting a null operation pair on the latter, and the per-order fingerprint in `request_summary` where the step-8 transaction committed

Replace N’s “as operator evidence only”:

> for operator resolution and for copying into the machine’s correlator pair at attach; it authorizes no automatic resolution

Run `CNF-303` on the standard-channel descriptor under K too.

**Brief errors**

- F’s no-call amendment inventory omits `CNF-340`: “before any provider call or write”.
- The Q2 question calls 05:360’s index an operation-pair consumer. It is under **`machines`**: “index on `(correlator_value)` for reconciliation lookup”.
- “Only link” is too strong: `machines.first_unit_debit_id` references a retained ledger entry, whose schema includes `operation_id`. `LDG-6` requires “the ids of whatever caused it — operation, machine, commitment”.
- A price rise alone does not guarantee refusal: `OPS-43` qualifies it as “where the provider’s price has risen past what the reserve covers”.
- F’s “own kind, `provider` or `timeout`” omits mapped failures: `PRV-5` requires transport failures to map to `network`, among other mappings.