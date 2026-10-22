**as2: CANNOT ACCEPT.** Its `WIR-12` quote carries no MUST. It is `WIR-12` echoing "`API-40`'s stated precedence" (same sentence), so `API-40` cites its own precedence as the opposing rule.

**opus2: CANNOT ACCEPT with the next sentence unchanged.** Opus is right. A field-first handler names `/foo` and says nothing about absent, expired, unknown or spent, so no quoted `WIR-12` word is violated.

**PICK: opus2's span, next sentence replaced.** Reason: opus2 quotes the two real MUSTs. The actual conflict is between `WIR-2`'s selection rule and the bolded token-first order two sentences above, and only the next sentence misstates it.

Span: opus2, verbatim. The next sentence changes to:

> Selecting that field in a body that also carries a bad token means validating the body before the token is checked, which the order above forbids.

The "token check wins" sentence after it stands and now follows.

Verified in the clone. The citation gate exits 0 on as2, opus2, and opus2 plus the sentence above. All five planted quotes and the semicolon join exit 1, as the brief states.

**Brief errors:** none found. The circularity reading is confirmed by:

```
grep -n "stated precedence" 13-wire-contract.md   # line 430: ..., `API-40`'s stated precedence
```
