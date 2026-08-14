# v1 ships three drivers across two companies

## Context

The specification names no providers on purpose: `02-provider-contract.md` states what any driver
must satisfy, and `08-provider-notes.md` describes provider *shapes* rather than a launch set. That
neutrality is worth keeping, but it left a question the design has been leaning on without ever
answering — **what does v1 actually run against** — and different answers prove very different
things.

Two machine shapes exist and they are not variations on each other:

- **Cloud** — rented by the hour, deleted by an API call, billing stops at once, no joining fee.
- **Dedicated** — a physical box with a one-off setup fee, where cancellation may set a future
  effective date and the machine keeps running and keeps billing until it arrives (`DOM-19`).

**Nearly every difficult requirement in this set exists because of the second shape.** The setup
fee committed before the order and debited on acceptance (`LDG-39`), the reserve that must cover cost through a cancellation
date (`PRV-13b`), `cancellation_scheduled`, `PRV-13c`'s exception branch, `ADR-0006`'s
pass-through — a cloud-only launch runs none of it. It is also where the differentiator lives:
booting a rescue system to install a caller's own image is a convenience on a cloud VPS whose
provider already has an image API, and it is the entire product on a dedicated box.

## Decision

**v1 ships three drivers: Hetzner Cloud, Hetzner Robot, and DigitalOcean.** Both shapes, two
unrelated companies.

Each of the three is there for a distinct reason, and the reasons are what makes this three rather
than a number chosen for its own sake:

- **Hetzner Robot** is the product. It is the dedicated shape, it is where rescue-and-install
  justifies the whole system, and it is the only one that exercises the money machinery built for
  it.
- **Hetzner Cloud** is the cheap machine. Development and conformance testing against Robot alone
  costs a setup fee per iteration, which makes the checklist expensive to run and therefore run
  less. It is also the fallback product if `F29` turns out to be true.
- **DigitalOcean** is the proof that the driver contract abstracts anything. Two drivers against
  one company's API house style can share assumptions neither author notices; an unrelated third
  is what turns `02-provider-contract.md` from a description of Hetzner into an interface.

No single provider can end the business, which is what `SEC-43`'s spread-tenants-across-accounts
requirement actually needs to be real — `SEC-44` already records that one company may link and
terminate accounts together, in which case multiple accounts at one provider are not isolation.

## Considered options

**Cloud only — Hetzner Cloud and DigitalOcean** was rejected despite being the least work. It
sidesteps setup fees, cancellation dates, the exception branch, `F26` and `F29` entirely, and
ships the least differentiated version of the product: a thin reseller of machines the customer
could rent directly. It would leave the dedicated money path written and never run, which is the
condition under which specifications turn out to be wrong.

**Hetzner Robot only** was rejected on testability. Every conformance run costs a setup fee, and
the entire launch would ride on `F29` being false with no second product to fall back to.

**Both Hetzner lines, no third company** was the recommendation and was rejected as insufficiently
paranoid in one specific way: it puts every customer behind one company's account-termination
policy, and leaves the driver interface unproven against anything but one API dialect.

## Consequences

- **Three drivers before the first customer.** This is straightforwardly more work than any
  alternative considered, undertaken before anything has been validated against a real
  transaction. The trade accepted is breadth of proof over speed to a first sale.
- **`F29` becomes blocking for the Robot driver specifically, not for the launch.** If Hetzner
  Robot's `comment` field forces manual order processing, the correlator design and the measured
  negative window are wrong for that provider — but Hetzner Cloud and DigitalOcean still ship.
  **Verify it before writing the Robot driver, not before shipping.**
- **The capability matrix stops being hypothetical.** Three drivers with genuinely different
  capability sets is enough for `OVR-2`'s runtime discovery to be exercised rather than asserted,
  and `F10`'s dead capability branches — `remote_console`, `attach_iso`, the missing list-offers
  capability — become concrete rather than theoretical.
- **`PRV-13c`'s "do not encode commercial terms as constants" gets its first real test.** Three
  products with three different cancellation stories is where an implementation that hardcoded
  Hetzner's behaviour will fail visibly.
