**as2: CANNOT ACCEPT.** Its `WIR-12` quote contains no MUST, and it is `WIR-12` repeating "`API-40`'s stated precedence". `API-40` would be quoting the copy instead of the owner.

**opus2: CANNOT ACCEPT.** Naming the unknown field doesn't say which token failure happened, so a field-first answer breaks no quoted `WIR-12` word and "violates the other whichever way" fails.

**PICK: as2**, if forced. Its words keep the next sentence true, while opus2 makes that sentence assert a conflict that isn't there.

**Replacement span:**
> `WIR-2` says “Unknown fields in a request body MUST be rejected” and “The field named in `details.field` MUST be selected under `WIR-9a`”. The other MUST is this requirement's own token check, stated above.

The next sentence doesn't change. A field-first handler breaks "The admission token MUST be checked before any other validation of the body", and a token-first handler names no field.

On the patch plus this span, all six gates exit 0. Planting either `WIR-2` quote false turns citations red. Unquoted attributions stay at "22, none new against baseline 22". The second sentence has no quotation marks, so no quote goes unchecked.

**Brief errors:** none found.
- Both options exit 0 on all six gates.
- All six planted variants and the semicolon variant turn citations red.
- `grep -n 'refused naming no field at all' 13-wire-contract.md` puts the line at 428 bare and 430 patched.

One breach: I wrote a helper script to `/tmp` (outside the clone) and then deleted it.
