Reviewed `applied-fable.patch` on `07bac41`.

- **a1: ACCEPT** — Defines pointer representation and ordering within each validation step.
- **a2: ACCEPT** — Explicitly handles mixed known and unknown rejected fields.
- **a3: CANNOT ACCEPT** — Another rejected `/a` makes the hardcoded `/operator_ref` wrong; `API-40` also lacks the quotation required by `AGENTS.md`.

Replace `WIR-47`’s withdrawal paragraph ending, beginning “a withdrawal body”, with:

> a withdrawal body containing `operator_ref` returns `invalid_request` with `details.field` selected under `WIR-9a`.

Replace `API-40`’s attribution sentence, beginning “`WIR-2` requires” and ending “it was”, with:

> `WIR-2` says “Unknown fields in a request body MUST be rejected” (field selection: `WIR-9a`). `WIR-12` says “the message MUST NOT say which” for a bad admission token.

- **b: ACCEPT** — The exception permits implementation of ordering capabilities withheld for a particular account.
- **c1: ACCEPT** — Covers descriptor visibility, admission precedence, replay, claim rejection, and commitment release.
- **c2: ACCEPT** — The permissive driver fixture demonstrates that the outer gate prevents the List offers call.
- **c3: ACCEPT** — Covers literal pointers, least-pointer selection, and isolated caller-written and system-written failure cases.

**STAGE: S1** — Precisely identifies the caller-supplied stage relevant to this `invalid_request` row.

**(d): bead** — Simultaneous caller/system rejection precedence is a separate product decision; the proposed fixtures isolate those cases.

**Brief errors:** None found.

The required full gates, including Lean, passed before and after applying the supplied patch. The proposed quotation replacement also passed a targeted citation probe.