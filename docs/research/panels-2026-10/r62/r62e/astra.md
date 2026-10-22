as2: CANNOT ACCEPT — It uses the consequence of this precedence to justify that same precedence.

opus2: CANNOT ACCEPT — Naming an unknown field does not disclose why the token failed; the retained “violates the other” assertion therefore does not follow.

PICK: neither.

Exact replacement span:

> `WIR-2` says “Unknown fields in a request body MUST be rejected” and “The field named in `details.field` MUST be selected under `WIR-9a`”. `WIR-12` says “absent, expired, unknown or already spent is `invalid_request`, and the message MUST NOT say which”.

**Yes, change the next sentence** to:

> The admission-first rule above determines which validation runs first when both faults are present.

The preceding sentence also needs replacement:

> **The order is stated explicitly as a precedence.**

A span-only repair leaves the unsupported conflict claim intact. These surrounding edits change the explanation, not the settled behavior.

**Brief errors:** None found.

Checks: citations passed for both options; full gates were stopped unfinished.