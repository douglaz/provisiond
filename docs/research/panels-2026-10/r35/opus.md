**Reject.** The proposal tunes a bound that prices nothing in v1. Withdraw the bound and the `PRV-45` refusal, and make the per-kind bound a second precondition beside Q18a's automatic credit.

## Why

The first-principles question is what the bound pays for. Both places that use it price it at "that attachment's customer rate" (`02-provider-contract.md:245`, `:553`). No such rate exists anywhere:
- `LDG-24` puts the margin on "machine time only" (`12-billing-and-ledger.md:1832`).
- `machine_attachments` has no rate column (`05-persistence.md:334-343`).
- The listing returns only `{kind, external_id, billable, cleanup}` (`02:520`).
- Q18a lists "attachments gaining their own customer price" as a future condition.

So in v1, count × rate × bound has no rate, and the bound sizes nothing. All the sentence does in v1 is refuse. That refusal also departs from a settled ADR. ADR-0037 (`docs/adr/0037…md:124-127`) says a date "needs a bound declared per attachment kind at create … **or** the shortfall meets `LDG-31`'s clamp", which allows the sale either way. The departure is `02:552-553`'s "MUST NOT be sold", not anything in the proposal.

## Answers

**1. Robot trace.**
- **Without the add-on:** "the server will be ordered without an IPv4 address" (`RSC-45`, `06-rescue-install.md:503`). The order creates nothing billable.
- **With `primary_ipv4`:** the order creates one IPv4, priced into the machine ("carry its cost into the offer's price", `06:513`). Two things are still open:
  - whether it outlives the server (batch B step 9, `08-provider-notes.md:488`);
  - whether it is day-billed, which is the research note's own inference (`docs/research/provider-verify-2026-10.md:554`).
- **If it survives:** it is listed `billable`/`api` and metered at no rate. Its tail is the operator's, the same shape as `02:223`: "The provider's unit remainder is a different cost, absorbed by the operator under `ADR-0033`".
- **`offer_not_sellable`:** in HEAD it is reached only if Robot cannot declare a bound for the kinds `02:195` makes every descriptor declare. r34's "would stop all v1 sales" overstates this. The accurate claim is that sales are blocked until someone establishes Robot's worst-case IP/subnet cancellation date, which `:554` leaves open.

**2. "Kinds the order creates" isn't decidable before create.** `PRV-31` makes a missing bound "a descriptor-decidable unsellable offer" (`02:483`), but no descriptor field says which kinds a create orders. The add-on is a driver choice tied to `rescue_address_family`, so the scoping needs a new field. It also leaves holes:
- An attachment added out of band is listed at delete with no reserve. The ADR's clamp branch already accepts that.
- A failed listing is `pv-ucs.4`'s separate hole.
- No tenant route adds attachments; I searched `04`/`13`.
- Whether Robot's free IPv6 /64 appears in `GET /subnet` is unverified. Free means `billable: false` either way.

The bound is also per kind with no count, and the count is known only at deletion.

**3. Q18a.** The fix doesn't contradict Q18a, but it is inert. The bound sizes the reserve for exactly the condition Q18a gates, so it belongs on the same precondition list. Proposal (3) does contradict Q18a(1): a "now" release that returns a day-only date names the end of that day UTC. That is up to 24 h, not zero.

**4. The carve-out points at nothing.** "explicitly accepted and capped" exists only at `12:329-331`, unchanged since `9f1f468` (2026-08-13). There is no register row, no cap, no config and no CNF item; I searched with whitespace normalised. The rule the wire enforces is elsewhere:
- `API-7` refuses only "when the named offer is not sellable under `PRV-13b` or `PRV-31`" (`04-api-contract.md:266-267`).
- `PRV-13b` requires "cleanup for every billable attachment" with no carve-out (`02:203-205`).

So `LDG-32`'s sentence is the drifted second copy, the `SEC-46` pattern AGENTS.md names. Proposal (1) points at the copy with an exception the wire never applies.

**5. The clamp is not the carve-out.** `LDG-31`'s clamp is automatic and uncapped. "Explicitly accepted and capped" is neither, so recording one as the other misstates both.

**Brief facts.**
- The ADR-0039 claim is close but not its words: "`unlimited` (Robot's default 1 Gbit dedicated servers) is sellable".
- Everything else I checked holds.
- The gate is green at `8c3087e` (exit 0).
- No Lean `@[req]` declaration encodes the bound; `f86de91`'s Lean diff only touches attachment seed and stop comments. The edits below are Markdown-only.

## Edits (land with Q18a's `LDG-38` text)

- `02:82-83`: delete `attachment_cancellation_bound`. `02:110`: replace the note with "withdrawn (Q18b)".
- `02:244-246`: replace with: "The `billable_attachments` term is zero while no attachment carries a customer price (`LDG-24`). Pricing one first needs a per-instance effective-date bound; see `LDG-38`'s preconditions."
- `02:551-555`: delete.
- `12:347`: revert to "surviving billable attachments (PRV-13a)".
- `12:329-331`: replace the sale sentence with "The sale gate is `PRV-13b`'s." This deletes the unspecified carve-out, which is a semantic change for the owner to confirm. It narrows the text to match what `API-7` already enforces.
- `LDG-38`, in Q18a's precondition list: alongside the automatic credit, before any attachment is priced, add a rate source and a per-instance worst-case date bound in the reserve.
- ADR-0037 `:124-127`: amend. Until attachments carry a price, a surviving attachment's tail is the operator's, in `02:223`'s shape, and the bound moves to the precondition list.
- `10-conformance-checklist.md:3223-3224`: delete "Verify the per-kind bound declared at create and `LDG-31`'s clamp if a later date exceeds it."

**Strongest "don't build this":** nothing in v1 charges a customer for an attachment. A bound, a scope rule, a zero-value convention and an operator carve-out would all size or gate money that doesn't exist yet.
