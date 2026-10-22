as2: **CANNOT ACCEPT** — It quotes a consequence of this precedence as though it were an independent conflicting MUST.

opus2: **CANNOT ACCEPT** — Naming an unknown field can disclose no token category, so “violates the other whichever way” does not follow.

**PICK: NEITHER.** Accurate quotations do not establish the claimed contradiction.

Exact replacement span:

> `WIR-2` says “Unknown fields in a request body MUST be rejected” and “The field named in `details.field` MUST be selected under `WIR-9a`”. `WIR-12` says “absent, expired, unknown or already spent is `invalid_request`, and the message MUST NOT say which”.

**Change the next sentence** to:

> The rule above gives admission-token validation precedence over unknown-field validation.

A span-only repair is insufficient. The preceding sentence also needs replacing with:

> **The order is an explicit precedence.**

That additional editorial change exceeds the designated span; the settled behavior remains intact. The proposed paragraph passes all gates.

**Brief errors:** None found.