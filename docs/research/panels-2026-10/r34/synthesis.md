# Panel r34 synthesis — pv-ucs.6 after Q14: an overcharge behind the mark (Q18a), a missing attachment bound (Q18b), 2026-10-10

Readers: sol, astra (codex xhigh), fable, opus (claude xhigh); clones at 33bb62f. All exit 0.

## Q18a — 4–0 against building the automatic credit (a) now; the posted entries stand today.

- Not attachment-only (fable, opus): a `delete_machine` resolved `applied` with a past date clips at the
  scheduled-machine boundary with the same discard and no credit, since 2026-09-05. One rule belongs in
  `LDG-38`'s exit paragraph for every subject.
- The decisive fact (opus, verified): NO attachment customer rate exists — `machine_attachments` has no
  rate column, the listing returns only `{kind, external_id, billable, cleanup}`, `LDG-24` applies the
  margin "to machine time only". So no attachment increment can be priced or overcharged in v1. The only
  v1 survivor candidate, Robot's `primary_ipv4` add-on, is priced into the machine (`RSC-45` "carry its
  cost into the offer's price"); whether it outlives the server is batch B step 9.
- Robot does return dates (fable, opus, sol, from the Robot docs): IP/subnet cancellation takes a date or
  "now" and returns `cancellation_date` (yyyy-MM-dd).
- (a) is real machinery (sol, fable, opus): usage entries store an increment end but not its start; clamp,
  rate splits and rounding; a correction names exactly ONE entry; a new key; a Lean `Key` constructor.
- (b) is not existing machinery either: no wire route posts an operator usage correction (only `WIR-42`'s
  deposit attribution); `LDG-74`'s restore correction ("nothing triggers it") has the same gap.
- Shape: state once in `LDG-38` that a boundary learned behind the mark leaves posted entries standing, the
  remedy being an operator `LDG-5` correction (fable: as `LDG-74` says of a restore) — opus calls the same
  text (c) for v1. Record the missing operator-correction route as a gap. Build (a) when the first
  attachment with a customer price is sold (opus) / if such offers stay sellable (astra).

## Q18b — refuse, and it is already `LDG-32`'s rule (4–0 refuse; fable, opus: no new rule).

`LDG-32`: "It MUST NOT sell an offer whose attachments have no bounded automatic cleanup unless the operator
has explicitly accepted and capped that exposure." ADR-0037's "or the shortfall meets `LDG-31`'s clamp" is
that carve-out's consequence. The implementation's `PRV-45` sentence is a second copy — and keyed on KINDS,
it would stop all v1 sales (Robot declares additional IP and subnet `api` survivors for every descriptor)
(opus). Fix: `PRV-45` points to `LDG-32`, scoped to kinds the order creates; refusal uses `API-7`'s
existing `offer_not_sellable`; an immediate kind declares zero.

## Also found

- Date-only provider values (opus): the stored date is a timestamp, `WIR-35`'s examples use `T00:00:00Z`,
  and no rule says which instant a date names; read as start-of-day, a "now" release could stop the meter
  before it started. Recommend: the end of that day ("owes … through the effective date").
- The attachment rate needs a source before any attachment is customer-metered (opus).
- Brief defects: `LDG-62` is extend-runway, not a correction path; `LDG-38` (not `LDG-68`) owns correction
  periods; "orders no extra IPs" is not in the spec (`RSC-45` allows the add-on).
