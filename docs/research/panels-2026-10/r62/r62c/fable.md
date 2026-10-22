**Panel r62c, fable.** Patch applied at `07bac41`; all six text gates exit 0 in my clone (formal not run).

**a1. ACCEPT.** Row lands in `WIR-9a`'s kind/`details` table, cites `WIR-3`'s RFC 8785, and the "absent field" clause covers `OPS-23`'s missing-field case.

**a2. ACCEPT.** Keeps the phrase `WIR-47` quotes and states the mixed known/unknown case; matches a1's row.

**a3. ACCEPT.** All three replacements verified in the diff; no other "first unknown field" survives (grep over `*.md`).

**b. ACCEPT.** Only `PRV-4`'s second clause and `DOM-15` would be breached by the withheld-but-implemented method; both now except it, each citing the other. Opus's form fails the gate as claimed (tested: 1 new unquoted attribution).

**c1. ACCEPT.** `501` matches `DOM-17`'s table; keys match `WIR-9a`'s `unsupported` row; 5a before 5d gives the replay; step 3 at claim precedes step 4's read, so "no List offers read" holds.

**c2. ACCEPT.** Mirrors `CNF-19`'s outer-gate proof; `retryable: false` and full release follow `DOM-10` and `OPS-11`'s create row.

**c3. ACCEPT.** `/acknowledge_destruction` is the wire name (13:686); `internal` with `retryable: true` is `OPS-11`'s create row verbatim; two-value case tests the a1 rule.

**STAGE: S1.** Only the caller-supplied checks of step 3 yield `invalid_request`; the api-written checks yield `conflict`, the gate yields `unsupported`. S2 names nothing.

**(d) Bead.** Both outcomes settle `failed`, no mutation, full release; only the kind differs. When picked up, `internal` should win, since a caller fix cannot clear a defect.

**Scope flag.** The patch adds a sentence to `CNF-18` ("`CNF-19` covers its gate") that no item lists. The `allow_orders` gate is tested by `CNF-55`, not `CNF-19`, so it should read "`CNF-19` and `CNF-55` cover its gate". Not blocking.

**Brief errors.** None found. Line numbers verified:

```
git show HEAD:13-wire-contract.md | grep -n "naming that first unknown field"   # 1261
git show HEAD:04-api-contract.md  | grep -n "naming the first one"              # 772
git show HEAD:10-conformance-checklist.md | grep -n "first unknown body field"  # 3397
```
