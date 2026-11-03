**PRV-10** For a provider that bills on order, create MUST reject the request unless the
request carries an explicit purchase acknowledgement (`WIR-17`'s top-level
`acknowledge_purchase`), *and* the account
is configured to allow ordering. Both, not either. The configuration half is `DOM-10`'s gate on the create's ordering capability (`DOM-16`): `API-7`'s step 5d at admission and `OPS-43`'s step 3 at claim.

*Amended 2026-10-22 (`pv-p3k`; panel r62, `docs/research/panels-2026-10/r62/`; owner decision 2026-10-22): applied the reviewed ordering-capability change.*

