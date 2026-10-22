**(1)** NARROW: ACCEPT. WIDE: ACCEPT. PICK: WIDE. LABEL: MECHANICS.
Reason: the settled substance ("with several rejected fields the least escaped pointer wins") names no operation, and the row's first cell already cites `OPS-23` for all four operations; NARROW leaves the install example with no rule, WIDE only names the step. Verified `/acknowledge_destruction` sorts before `/trust` by UTF-16 units.

**(2)** OPUS: ACCEPT. SOL: CANNOT ACCEPT. PICK: OPUS.
Reason: manager's claim confirmed. A field-less `invalid_request` satisfies both of SOL's quoted sentences, so "satisfies one and violates the other" has no premise. OPUS's quote is verbatim at `13-wire-contract.md:28-29` and presupposes a named `details.field`. Residual, pre-panel-B: the `WIR-12` half stays "requires", which the gate's SPEECH set (says/states/reads) never checks.

Citation gate, my runs: exit 0 on the patch alone, on it + `a1-opus` + `api40-opus`, and on it + `a1-opus` + `api40-sol`.

**(3)**
- f1: ACCEPT. Hand check: the quote matches `WIR-2`'s bold sentence exactly. `/operator_ref` is the RFC 6901 pointer, and `CNF-233` asserts the same value.
- f2: ACCEPT. `a~b` escapes to `/provider_options/a~0b`, `a/b` to `/provider_options/a~1b`; `0` (0x30) < `1` (0x31). Unescaped, `/` (0x2F) < `~` (0x7E), so `a/b` sorts first. Both claims hold.
- f3: ACCEPT. `CNF-19` tests refusal of an undeclared provision capability with the driver flag permissive; amended `CNF-55` tests `allow_orders: false` at `API-7` step 5d and `OPS-43` step 3. Together they cover the gate.

**Brief errors:** none found. Checked:

```
grep -n 'For create, install, power and delete' 03-operation-lifecycle.md   # OPS-23 quote
grep -n 'required `trust` object' 13-wire-contract.md                      # WIR-20, line 689
grep -n 'withdraw|withdrew' tools/check_citations.py                        # line 293, unanchored
```
