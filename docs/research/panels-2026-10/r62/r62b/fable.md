**B1 — CANNOT ACCEPT** (one phrase). Scope flag: the SHOULD→MUST is the owner's product call; the rest is mechanics.
- `PRV-4` addition: "the second clause there" sits inside `PRV-4` and can read as `DOM-16`'s second sentence. Replace with: "An ordering capability that `DOM-16` withholds from an account whose `allow_orders` is false is not declared for that account; a driver that implements it does not breach this requirement's second clause."
- `DOM-16`, `CNF-18`, `WIR-29` fixture: accept. No gate reads the fixture's flag (`grep -rn allow_orders tools/ .github/` → nothing).

**B2 — CANNOT ACCEPT** (`API-7` part only).
- Adding 5d leaves two range statements stale: `04-api-contract.md:261` "After steps 1–5c, the tail MUST collect" and `:290` "Steps 1–5c still stop at their first refusal". Replace "1–5c" with "1–5d" in both.
- `DOM-10` and `PRV-10` additions: accept.
- Note: `Admission.lean`'s `Guards` (tagged `API-7`) models step existence (`ceilingStep`); 5d gets no Lean twin. Unformalized clause, so allowed under `ADR-0025`, but the record should say so.

**B3 — ACCEPT.** The `PRV-10` quote "the account is configured to allow ordering" is verbatim (`02-provider-contract.md:160`). Step 4 wording is fine; `CNF-342`'s "no List offers read" on a step-3 refusal stays true.

**B4 — ACCEPT.** Quotes check: `PRV-9` "provider-side name or tag" (`02:155`); "Defect in this system" is the taxonomy table cell, which `04-api-contract.md:62` already calls "`DOM-17`'s mapping". Accept `true` and the split: an api-written present value at step 3 takes `OPS-23`'s first bullet (`conflict`/`incomplete_record`, `retryable: true`), a system-written value at step 7 takes `internal`.

**B5 — CANNOT ACCEPT** (two parts).
- "one of the three stages of `OPS-43`'s step 3": only the caller-supplied stage yields `invalid_request` naming a field; the api-written stage is `conflict`/`incomplete_record` and the gate is `unsupported`. Replace with: "the caller-supplied stage of `OPS-43`'s step 3".
- `WIR-47` restates `WIR-2`'s withdrawn wording (`grep -n 'first unknown field' 13-wire-contract.md` → lines 29 and 1261). Replace `13:1261`'s "naming that first unknown field" with: "with `details.field: "/operator_ref"` (`WIR-9a`)".
- Rest accept: RFC 8785 orders by UTF-16 code units; `Rescue.lean`'s `WIR-9a` declaration covers `rescue_exit` only, so no Lean change.

**B6 — ACCEPT.** Mechanics, not product: `STO-36` already says "A row MUST NOT be written naming a `provider_account` whose `STO-47` status is anything but `healthy`", and `state` is in `WIR-9a`'s `conflict` reason set. `STO-47`'s "`WIR-48` refused only `terminated`" is past-tense history; leave it.

**Brief errors:** none found. Checked: `grep -n allow_orders 02-provider-contract.md` → only `:1038` (`PRV-34`'s test flag), none in `PRV-44`; `sed -n 731,735p 03-operation-lifecycle.md` shows step 3 as one unordered list; `OPS-11`'s `retryable: true` quote matches `03:241`; `PRV-47`'s caller sentence is untouched at `02:169-170`.
