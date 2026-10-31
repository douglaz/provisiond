# Occurrence inventory at PR #53 b85af778fda2a96fb0024a07c69092665303bfbe

Target physical row: .beads/issues.jsonl:101; pv-kv2 comments[0], id 860. Comment line numbers below are decoded, not physical JSONL lines.

## Q4-D-original.md

25: failed transaction commits neither about_to_order_at nor a correlator. A whole-transaction
29: the settlement guard. A serialization failure is retried as a whole transaction under OPS-49
42: the guard can still be between the acknowledged transaction and its provider call, because
43: LDG-69 keeps the call outside the transaction; treat that residue as the potentially dispatched
83: commits and is acknowledged, suspend before the provider call and assert the attempt is treated
88: Lose step 8's acknowledgement, suspend before the whole-transaction repeat, and assert
## agent-brief-original.md

65: failed transaction commits neither about_to_order_at nor a correlator. A whole-transaction
69: the settlement guard. A serialization failure is retried as a whole transaction under OPS-49
82: the guard can still be between the acknowledged transaction and its provider call, because
83: LDG-69 keeps the call outside the transaction; treat that residue as the potentially dispatched
126: commits and is acknowledged, suspend before the provider call and assert the attempt is treated
131: Lose step 8's acknowledgement, suspend before the whole-transaction repeat, and assert

There is one OPS-49-attributed claim and one LDG-69-attributed claim in each file. Exact replacement spans: archive 29–30 and 41–44; decoded Agent Brief 69–70 and 81–84. Lost-acknowledgement whole-transaction rechecks at archive 25–29 and 88–90 / brief 65–69 and 131–133 are this adopted package’s guard/retry case and conformance assertions, not further statements naming OPS-49. The provider-call barrier at archive 83–87 / brief 126–130 is its own conformance assertion. Inspect all remaining text yourself; do not infer exhaustiveness from identifier search alone.

The retained OPS-11 quotation at archive 46–47 / brief 86–87 is semantically supported by pinned OPS-11 (03-operation-lifecycle.md:249), but its LF after “any” is a space in the pin. This is a pre-existing byte mismatch in every candidate; no claim of byte identity is made for it. Report the distinction and, if it blocks a pick, print a complete exact alternative rather than silently normalizing it. New quotation payloads in Q-QUOTE have exact source bytes, including the embedded line breaks and two spaces in OPS-49. Historical Current behavior blocks are checked against their named historical commit, not passed off as new pin quotations.
