**Q1 — F: CANNOT ACCEPT as submitted. S: AMEND. Pick S.**

F flips unlisted `CNF-340`: “before any provider call or write.” Trace: submit a remembered, traffic-unsellable offer; F calls List offers before refusing it. F also contradicts `02-provider-contract.md`, `PRV-40`: “refuse subsequent creates on that account and channel before any provider call.” Trace: close the channel, then submit another create; F reads before reaching the closure refusal. These are checked losses beyond the assertions F lists for amendment.

The no-call rule protects provider capacity from requests that cannot buy anything. F permits an insufficient-balance loop to generate reads. `SEC-39` names “machines created per interval”; that is not an explicit allowance for unsuccessful admission reads. `API-29` says “SHOULD rate-limit per tenant,” which supplies no mandatory provider-read budget. No product-listing limit should be inferred.

S needs a named refresh owner, defined timestamp semantics and an authentication exception. Its unconditional refresh conflicts with `PRV-41`: “MUST NOT re-attempt it on a schedule.” Put the refresher in the engine: `OVR-17` says its component list “MUST be extended when a component is added.” Its writes require the fence: `OPS-50` covers “every write transaction made in the engine process”; API-process writes remain exempt—“Writes made in the api process are not checked.”

Admission and claim need not read the same listing instance. `OPS-43` explicitly uses “one current driver List offers result taken at claim.” A bounded stored admission snapshot plus that later check is coherent.

Both forms name the offer-origin snapshot’s source, including prices, fees and install eligibility. Preserve descriptor-origin inputs too: `PRV-44` describes `billing_unit` in the descriptor and says “like the bound it MAY be reported on the offer instead.”

**Against my pick:** S adds storage, scheduling and stale-data failures. Customers can receive an admission followed by a predictable claim refusal; F offers fresher acceptance pricing without maintaining a listing cache.

**Q2 — K: AMEND. N: AMEND. Pick K.**

K preserves one durable fingerprint representation across operation and machine. Its `CNF-278` replacement needs timing qualification: the unchanged operations schema says “Written in `API-63`’s correlator transaction.” Account-read failures never reach that transaction; asserting a fingerprint throughout the repeated cases is wrong. N’s summary assertion needs the same qualification.

After successful attachment and operation retention, both forms can preserve every tagged key: K leaves the fingerprint on the machine; N copies it there from the summary. `CNF-303` requires the sweep to “retain every key that operation tagged,” including distinct caller and correlator keys; `PRV-9` says they have “the same eligibility.” Group provider registrations by their operation-id tag, find the designated correlator registration’s fingerprint, then consult the retained machine. Neither form should permit substituting a reusable caller fingerprint. Make generation explicit; a caller-key-only order then fails the amended contract.

A lost reply with exactly one standard-channel match cannot auto-attach under either form: `PRV-33` says “attaching a discovered machine to a tenant MUST be an operator action.” K makes the cardinality exclusion explicit. N leaves the operation pair null, but preserves operator evidence. The machine index and post-retention sweep remain populated; see `OPS-32`.

N also conflicts internally: “as operator evidence only” versus its machine rule “copied from `request_summary`’s correlator,” subsequently used for automatic key retention. Replace “only” and specify the durable write’s timing. K’s extension should explicitly name Robot, rather than prescribe a key fingerprint for every conceivable `correlator: none` channel.

**Against my pick:** K requires every reader to distinguish stored attribution evidence from verified automatic-reconciliation capability. N expresses that distinction directly in the operation pair, at the cost of a separate fingerprint source.

**Replacement text — Q1**

For F, the narrowly affected spans, if its policy is chosen:

- `PRV-40`, replace “before any provider call” with:
  > before any provider mutation; the admission List offers read is permitted
- `CNF-340`, replace “before any provider call or write” with:
  > before any provider mutation or purchase write; the admission List offers read is permitted
- `CNF-283`, replace “Subsequent local refusals make no provider request and need no new provider-throttle alarm” with:
  > Subsequent local refusals permit only the admission List offers read; the local refusal itself needs no new provider-throttle alarm.
- F’s failed-read sentence:
  > A failed admission read refuses before the tail and commits nothing, preserving the driver error’s kind, retryability and redacted details. See `PRV-5`, `PRV-41` and `DOM-17`.

For S, replace its listing-maintenance rule with a new owner beside the table:

> **STO-60** Each successful complete driver List offers result MUST be recorded in `offer_listings`. `read_at` is the store-clock timestamp obtained immediately before dispatch, not response completion. Replacement MUST be atomic and occur only when no row exists or the incoming `read_at` is later. Failed or incomplete reads MUST NOT advance `read_at`. Recording is outside the driver read.
>
> The engine’s refresh pass MUST attempt a read for each healthy account declaring `list_offers` at least once per stated refresh interval, except while its credential is barred following authentication failure. `PRV-41` says “treat an `authentication` failure as terminal for that credential” and “MUST NOT re-attempt it on a schedule”. See `OPS-50`.

Add to `OVR-17`’s component table:

> | Offer-listing refresh (`STO-60`) | `engine` | Periodic provider reads and listing persistence |

Use these `OVR-19` rows:

> | Offer-listing age | `API-7` | finite, positive duration | yes |
> | Offer-listing refresh interval | `STO-60` | finite, positive duration strictly shorter than offer-listing age | yes |

In either form’s `API-7` insertion, replace its snapshot-source sentence with:

> The tail MUST take every offer-origin input to commitment pricing and the accepted snapshot from that result. Descriptor-declared inputs come from the admitting process’s immutable descriptor. See `PRV-44` and `05-persistence.md`.

**Replacement text — Q2**

For either form, replace its new `PRV-32` sentences with:

> That declaration is the descriptor’s `correlator: none`. On every Robot ordering channel, the driver MUST generate and send a distinct throwaway SSH key unique to the order. See `PRV-26`.

For K’s new `PRV-26` text:

> On every Robot ordering channel, including one declared `correlator: none`, the recorded kind is `ssh_key_fingerprint` and the value is that order’s generated key fingerprint. `PRV-33` says “an ambiguous create on that channel MUST resolve to an operator, never to a guess”.

For K’s `CNF-278` replacement:

> asserting a null correlator pair before any successful step-8 commit, and `ssh_key_fingerprint` with the generated per-order fingerprint after that commit, on both Robot descriptors

For N’s new `PRV-26` text:

> On a channel declared `correlator: none`, both operation columns are null. For Robot, the worker MUST durably record the generated per-order fingerprint as `request_summary`’s correlator in the same transaction that first records `about_to_order_at`. It supports operator evidence and the retained machine’s key-sweep attribution. See `PRV-33` and `PRV-9`.

For N’s `CNF-278` replacement:

> asserting a null operation pair on the standard-channel descriptor throughout; assert the generated per-order fingerprint in `request_summary` after a successful step-8 commit, without requiring it in cases that never committed step 8

**Brief errors**

- The admission no-call inventory omits `CNF-340`: `rg -n 'before any provider call or write' 10-conformance-checklist.md` finds line 4028. F does not list that assertion for amendment.
- Q2 calls 05:360’s index a consumer of the operation pair. It is under `### machines`: “index on `(correlator_value)` for reconciliation lookup.” N changes the operation pair, not that indexed machine value.

Reviewed against `c5f897c`; no gates or `lake` run.