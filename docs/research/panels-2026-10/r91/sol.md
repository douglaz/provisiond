**Final pick: C.** Extraction is unnecessary if enforcing the outer-mark convention and migrating CNF-302 are acceptable. The raw, unconverted cheap rule does reject a correct current citation. B preserves that punctuation, but I found a separate loss of checking strength in its exact printed form.

| Form | Verdict | Strongest reason |
|---|---|---|
| A | **ACCEPT** | Enforces the convention and catches the target corruptions, with the printed migration. Its additional rejection of quotations wholly inside code is unnecessary, so I prefer C. |
| B | **CANNOT ACCEPT** | Extending a Lean quotation beyond the existing length cap can remove previously active QUOTED and EXISTS comparisons. A concrete corruption changes from exit 1 under N to exit 0 under B. |
| C | **ACCEPT — preferred** | Catches the target defect while retaining the existing path for quotations opened inside code. |
| N | **CANNOT ACCEPT** | Reproduces the missed corruptions and continues relying on author memory. |

I ran the required command unpiped:

```sh
python3 /var/tmp/provisiond-panel-r91/verify.py --source "$PWD" --work /var/tmp/provisiond-panel-r91/tmp/sol/verification
```

It exited **0**. Every complete changing package passed the clean citation CLI, all inherited self-test routines and its exact embedded workflow control. The verifier also confirmed that each embedded control equals its supplied `ci-control.py`. [Results and logs](/var/tmp/provisiond-panel-r91/tmp/sol/verification/results.json)

I independently checked that the inherited test routines, `contains_quote()`, `corresponding_roles()`, `span_content()`, attribution comparison functions, mark guard and baseline remain unchanged. Every recorded result in `current-attributions.json` was preserved, including its standing `passes: false` findings. The successful replacement preservation runner is [preservation_and_long.py](/var/tmp/provisiond-panel-r91/tmp/sol/preservation_and_long.py). An earlier replay was interrupted, exit 130, because it repeatedly normalized unused source pools; its completed live CLI receipts remain valid.

The live OPS-43 results were:

| Input | A/C | B | N |
|---|---:|---:|---:|
| Correct curly, either attribution form | 0 | 0 | 0 |
| Each named curly corruption | 1, content diagnostic | 1, content diagnostic | 1, content diagnostic |
| Correct straight, either form | 1, convention diagnostic | 0 | 0 |
| Straight bare possessive: each named corruption | 1, convention diagnostic | 1, content diagnostic | **0** |
| Straight speech verb: nested reason or state corruption | 1, convention diagnostic | 1, content diagnostic | **0** |
| Straight speech verb: `three recoverable` | 1, convention diagnostic | 1, content diagnostic | 1 |

The plants were `account_terminated` → `account_terminatd`, `"state"` → `"stat"` and `two recoverable` → `three recoverable`. Individual commands, exits and diagnostics are in [receipts.json](/var/tmp/provisiond-panel-r91/tmp/sol/probes/receipts.json), with adjacent full CLI logs.

A/C report:

```text
FAIL: 03-operation-lifecycle.md:778: API-63 straight quotation closes inside inline code; use curly outer marks (“…”).
```

B’s target corruptions report:

```text
03-operation-lifecycle.md attributes to API-63 a phrase API-63 does not contain:
```

Thus A/C reject straight syntax before comparison; their red result does **not** establish that they compared the nested value. Their curly controls establish content comparison.

For the raw CNF-302 question, both guards rejected the correct, unconverted citation:

```text
FAIL: 10-conformance-checklist.md:3096: CNF-300 straight quotation closes inside inline code; use curly outer marks (“…”).
```

The printed migration restores a clean corpus and enables comparison of the complete content. **It does not preserve acceptance of the original punctuation.** I accept that explicit convention enforcement in C. B accepts and compares the unchanged citation.

A also changes this valid syntax from exit 0 to exit 1:

```text
`API-63` says `"the last write before the ordering call"`
```

N/B/C accept it. This is A’s disclosed collateral syntax restriction, absent from C. Neither guard changes a conformance assertion or Lean theorem; both change citation admission.

B’s blocking loss occurs in [quotation filtering](/var/tmp/provisiond-panel-r91/candidates/B/tools/check_citations.py:340). I placed the exact API-63 excerpt saved in [long-api63-quote.txt](/var/tmp/provisiond-panel-r91/tmp/sol/probes/long-api63-quote.txt) inside a straight-quoted Lean docstring attribution. It starts with:

```text
`conflict`, with `details.reason: "account_terminated"`
```

and ends with the owner’s “that residue is the dispatched case … below,” passage. The correct fixture exits 0 under N and B. Changing only `two recoverable` to `three recoverable` produces:

- **N: exit 1**, with the API-63 attribution diagnostic and an EXISTS finding.
- **B: exit 0**, with no eligible quotation remaining for either comparison.
- **A/C: exit 1**, with the convention diagnostic.

B extracts the complete span, then discards it because it exceeds Lean’s ordinary 400-character cap. Lean UNQUOTED findings do not rescue this case. This removes a demonstrated corruption verdict; it is not merely an absent new test. [Exact receipts](/var/tmp/provisiond-panel-r91/tmp/sol/probes/long-api63-receipts.json), [N failure](/var/tmp/provisiond-panel-r91/tmp/sol/probes/N-long-api63-recoverable.log), [B miss](/var/tmp/provisiond-panel-r91/tmp/sol/probes/B-long-api63-recoverable.log)

I supplied a **distinct complete repair, B2**, in [B2-complete.patch](/var/tmp/provisiond-panel-r91/tmp/sol/B2-complete.patch). It includes every B change against the pin, exempts code-extended straight spans from the length cap, documents that additional reach, and adds long-span self-tests and an exact-source CI control. Its clean CLI and extended embedded control both exited 0. [B2 results](/var/tmp/provisiond-panel-r91/tmp/sol/B2-results.json)

B2 is a separate proposed form, **not acceptance of B and not my final pick**. Its additional Lean reach is substantive. All forms retain the printed bounded backtick grammar: equal-length runs, paragraph boundaries, unmatched runs treated literally and no special fence parsing.

I checked the brief for internal contradiction. **No premise-changing brief error was verified**, so notes.md rule 6 does not void this recommendation. The minor locator error is that the CNF nested quotation occupies lines 3096–3097, rather than 3095–3096; no verdict rests on that offset. B’s newly demonstrated loss changes its acceptability, not the question’s premise. No supplied verifier assertion failed.

**Requested strongest no-change counterargument — written on request, not my vote:** N preserves existing syntax and the documented scanner limits, avoids another parsing convention, and already rejects the known OPS-43 corruptions when its curly outer marks remain intact. That is a maintenance argument, but it leaves the demonstrated author-memory failure unresolved.

The reviewed source package remains byte-identical to N. I ran no formal build or full gate, made no repository or tracker changes, and launched no follow-on work. Owner approval remains necessary before any check-strength change.

Procedural scope note: my first discovery command inadvertently enumerated neighboring filenames. I opened no neighboring file contents; subsequent project reads were confined to the permitted packet, clone and seat scratch.