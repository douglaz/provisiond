TL;DR: The panel unanimously prefers a 1024-byte limit on each submitted disk identifier, measured before trimming.

A caller sends 1025 spaces/letters that trim down to `a`: this limit refuses it before queueing or rebooting. A disk whose only usable serial itself exceeds 1024 bytes stays visible in inventory but cannot be selected with that value. The number is a service budget, with no provider-wide compatibility guarantee.

Which exact reviewed limit should we adopt?

- **1024 bytes before trimming (Recommended):** Q2-A; fable/opus/astra/sol prefer it (4–0), all four accept; one cap bounds admitted padding and identity.
- **256 bytes after normalization:** Q2-B; no first picks, all four accept; long padding can pass within the body limit.
- **Both limits:** Q2-C; no first picks, all four accept; more restrictive identity domain plus raw-padding cap.
- **Body limit only:** Q2-D; no first picks, astra/sol accept and fable/opus reject; no separate identifier-field budget.

These are the exact row plus boundary paragraph in r84/brief.md; no combined or revised cap is recommended. All options use decoded UTF-8 bytes rather than JSON escape length, and preserve untruncated inventory. IDs: pv-2j3; API-13 disk-identifier row and CNF-363 size-boundary paragraph; SEC-29 and OPS-23 retained. Q1 and Q3 are pending r84b and are not part of this choice.
