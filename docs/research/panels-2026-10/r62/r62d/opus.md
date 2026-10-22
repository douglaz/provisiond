**(1)**
NARROW: **CANNOT ACCEPT.** A stored `rootfs_via_rescue` install missing `trust` and `acknowledge_destruction` gets two conforming answers. The row's first cell cites `OPS-23`, which covers four operations, so this is pv-ss4's own defect.
WIDE: **ACCEPT.** PICK: **WIDE.** LABEL: **MECHANICS.**
Reason: r62's settled tie-break has no operation limit. WIDE leaves `OPS-23` untouched and changes neither kind nor `retryable` nor settlement, only which of the rejected fields is named.

**(2)**
OPUS: **CANNOT ACCEPT.** Its `WIR-12` half stays unquoted, and the gate doesn't check "requires", so the rewritten sentence still fails `AGENTS.md`'s completion rule.
SOL: **CANNOT ACCEPT.** The manager's claim holds: a token-first `invalid_request` satisfies "MUST be rejected", so "violates the other" no longer follows. "say which" has nothing to refer back to.
PICK: neither. Replacement for the span through "it was**.":

> `WIR-2` says "The field named in `details.field` MUST be selected under `WIR-9a`" of a rejected unknown body field. `WIR-12` says of a bad admission token "absent, expired, unknown or already spent is `invalid_request`, and the message MUST NOT say which".

- On it, all six text gates exit 0, and changing either quote makes citations exit 1.
- It must stay two sentences: joined by a semicolon, the gate checks both quotes against `WIR-2` and exits 1.
- Older problem, outside this round's scope: a field-first answer breaks none of the quoted `WIR-12` words either. A separate bead should cover it.

**(3)**
- f1 **ACCEPT.** The quote is word for word: `grep -nF 'Unknown fields in a request body MUST be rejected' 13-wire-contract.md` finds it at line 28. "only rejected field" means only one pointer can be named.
- f2 **ACCEPT.** Escaped, `a~b` becomes `a~0b` and `a/b` becomes `a~1b`, and `0` sorts before `1`. Unescaped, `/` (0x2F) sorts before `~` (0x7E). `WIR-2` leaves what goes inside `provider_options` to the driver, so `PRV-47`'s validation sees both.
- f3 **ACCEPT.** `CNF-55` now asserts the descriptor without the ordering capability, the step-5d refusal and the step-3 refusal. `CNF-19` covers the outer gate.

**Brief errors:** none found.
