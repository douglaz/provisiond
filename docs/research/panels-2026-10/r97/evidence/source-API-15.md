**API-15** A create request against an order-billed provider MUST carry an explicit
purchase acknowledgement — `WIR-17`'s top-level `acknowledge_purchase`, which the wire contract
owns — in addition to the account being configured to allow ordering (`PRV-10`). *"In its provider
options" until 2026-09-05, while `WIR-17` placed it at the top level; the wire contract wins, and a
spending authorization nested inside a driver-private object is one a strict server could not tell
from any other option.*

