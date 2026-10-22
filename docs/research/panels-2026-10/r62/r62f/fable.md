**ACCEPT.**

The deletion removes only rationale. Every normative element survives:

- **Ordering MUST** stays at `04:768`: "The admission token MUST be checked before any other validation of the body".
- **Combined-case behaviour** stays at `04:772` ("the token check wins", `invalid_request`, no `details.field`, no token detail) and is restated at `13:429-430`: "that check precedes `WIR-2`'s unknown-field rule, so a body with both a bad token and an unknown field is refused naming no field at all".
- `WIR-2` (`13:28`) and `WIR-12` (`13:428`) are untouched; `CNF-76` cites only `API-33`/`WIR-49`/`WIR-12`.
- `Admission.lean:27-29` quotes "`API-7`'s ordering applies to authenticated endpoints", still at `04:766`.
- `13:430`'s pointer "`API-40`'s stated precedence" is a baselined unquoted attribution (`tools/citation-baseline.json:22`); its referent, the ordering at `04:768`, remains.

Citation gate on the patched clone: exit 0, nothing new against baseline.

**Brief errors:** none found. Line numbers `04:768`, `04:772`, `13:28`, `13:426-430` verified with `sed -n`.
