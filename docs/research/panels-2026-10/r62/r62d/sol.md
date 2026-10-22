(1) NARROW: ACCEPT. WIDE: CANNOT ACCEPT. PICK: NARROW. LABEL: SCOPE.  
WIDE newly constrains install/power/delete claim-time tie-breaks; `OPS-23`’s “naming the field” does not settle ordering. That extension requires an owner decision.

(2) OPUS: CANNOT ACCEPT — the `WIR-12` attribution remains unquoted.  
SOL: CANNOT ACCEPT — its quoted duties permit fieldless rejection satisfying both; “satisfies one and violates the other” does not follow.  
PICK: neither. Replace both attribution clauses with:

> `WIR-2` says “Unknown fields in a request body MUST be rejected” and “The field named in `details.field` MUST be selected under `WIR-9a`”. `WIR-12` says “a body with both a bad token and an unknown field is refused naming no field at all”.

(3)

- f1: ACCEPT — Quote checked manually against `WIR-2`; the sole rejected field gives `/operator_ref`.
- f2: ACCEPT — `a~b` escapes to `a~0b`; `a/b` escapes to `a~1b`. Escaped order reverses the raw-name order.
- f3: ACCEPT — Both checks apply: “matching provision capability” (`CNF-19`) and “account-level opt-in” (`CNF-55`).

Brief errors: None.

Validation: `check-all.sh` exits 0 with NARROW and the replacement above.