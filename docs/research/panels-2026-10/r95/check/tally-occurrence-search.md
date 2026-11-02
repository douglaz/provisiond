# Independent occurrence and source-byte receipts — r95 tally

These lines are read from Git objects, not working-tree copies. The main refs still match M/H.

## H executable six blocks

```text
5: release and no setup-fee or first-unit debit under OPS-11's pre-step-9 create rule. Preserve
10: on its status not being suspended. This write and API-58's admission-time suspension flag write
14: on both error and operation view, then settle failed under OPS-11's pre-step-9 rule with full
19: worker's recorded failure under the same pre-step-9 rule; do not add a null-column term to
20: the settlement guard. OPS-49 says "the component MUST repeat the **whole
21: transaction** — never the last failed statement, and never the provider call (`OPS-12`)" and "A
22:   serialization failure is repeated at once."; retry a serialization failure as a whole transaction and do not treat it as a tenant-status refusal. The operation-row claim guard and acknowledgement-before-
25: **fences work already in flight** — a create that passed OPS-43's tenant dispatch guard before
27: abandoned mid-order; its machine follows OPS-27's suspended-attach cancellation. A claim by
29: OPS-43, and suspension winning the step-8 tenant guard also prevents purchase. A create past
31: OPS-43 says "Step 9 MUST begin only after step 8's transaction is acknowledged."; treat that residue as the potentially dispatched
34: OPS-11 says "Any create failure the worker records before any step-9 request (before any
37: For the claimed create's tenant-status read, refusal and dispatch race guard, see OPS-43.
38: Orders already potentially dispatched retain OPS-27's attach and suspended-tenant cancellation
42: at OPS-43's tenant dispatch guard and accounts for every machine, including machines produced
```

## comment860 at M and H

```text
19: 1. Read the provider account's stored status (`STO-47`). This is a plain read, not a
21:    is not `healthy`, fail `conflict`, with `API-63`'s “`details.reason: "account_terminated"`
26:    provider request and release the commitment in full under `LDG-39`'s "Deterministic rejection
43: 1. In OPS-43 step 1, after the account-status refusal paragraph and before step 2, insert:
50: release and no setup-fee or first-unit debit under OPS-11's pre-step-9 create rule. Preserve
55: 2. In OPS-43 step 8, after the STO-47 conditional-write check and before the operations-row write, insert:
59: on its status not being suspended. This write and API-58's admission-time suspension flag write
63: on both error and operation view, then settle failed under OPS-11's pre-step-9 rule with full
68: worker's recorded failure under the same pre-step-9 rule; do not add a null-column term to
69: the settlement guard. OPS-49 says "the component MUST repeat the **whole
70: transaction** — never the last failed statement, and never the provider call (`OPS-12`)" and "A
71:   serialization failure is repeated at once."; retry a serialization failure as a whole transaction and do not treat it as a tenant-status refusal. The operation-row claim guard and acknowledgement-before-
75: 3. In API-58 step (2), replace the complete span beginning `**fences work already in flight**` and ending `unrecorded and unbilled —`, immediately before `then (3)`, with:
78: **fences work already in flight** — a create that passed OPS-43's tenant dispatch guard before
80: abandoned mid-order; its machine follows OPS-27's suspended-attach cancellation. A claim by
82: OPS-43, and suspension winning the step-8 tenant guard also prevents purchase. A create past
84: OPS-43 says "Step 9 MUST begin only after step 8's transaction is acknowledged."; treat that residue as the potentially dispatched
87: OPS-11 says "Any create failure the worker records before any step-9 request (before any
91: 4. In API-58, immediately before “A create that has produced no machine yet”, insert:
94: For the claimed create's tenant-status read, refusal and dispatch race guard, see OPS-43.
95: Orders already potentially dispatched retain OPS-27's attach and suspended-tenant cancellation
99: 5. In API-58, replace the complete bold suspension-promise sentence and its following sentence, beginning `**A suspension is not a promise` and ending `on this one branch it is not.`, at pinned lines 731–734, with:
103: at OPS-43's tenant dispatch guard and accounts for every machine, including machines produced
113: 6. In CNF-202, after the additional Q1 store cases if adopted, otherwise before its amendment note, append:
152: > keep `OPS-27` for orders already dispatched.
```

## Archived Q4-D including Panel O L-NOTE

```text
3: 1. In OPS-43 step 1, after the account-status refusal paragraph and before step 2, insert:
10: release and no setup-fee or first-unit debit under OPS-11's pre-step-9 create rule. Preserve
15: 2. In OPS-43 step 8, after the STO-47 conditional-write check and before the operations-row write, insert:
19: on its status not being suspended. This write and API-58's admission-time suspension flag write
23: on both error and operation view, then settle failed under OPS-11's pre-step-9 rule with full
28: worker's recorded failure under the same pre-step-9 rule; do not add a null-column term to
29: the settlement guard. A serialization failure is retried as a whole transaction under OPS-49
30: and is not a tenant-status refusal. The operation-row claim guard and acknowledgement-before-
34: 3. In API-58 step (2), replace the complete span beginning `**fences work already in flight**` and ending `unrecorded and unbilled —`, immediately before `then (3)`, with:
37: **fences work already in flight** — a create that passed OPS-43's tenant dispatch guard before
39: abandoned mid-order; its machine follows OPS-27's suspended-attach cancellation. A claim by
41: OPS-43, and suspension winning the step-8 tenant guard also prevents purchase. A create past
43: LDG-69 keeps the call outside the transaction; treat that residue as the potentially dispatched
46: OPS-11 says "Any create failure the worker records before any step-9 request (before any
50: 4. In API-58, immediately before “A create that has produced no machine yet”, insert:
53: For the claimed create's tenant-status read, refusal and dispatch race guard, see OPS-43.
54: Orders already potentially dispatched retain OPS-27's attach and suspended-tenant cancellation
58: 5. In API-58, replace the complete bold suspension-promise sentence and its following sentence, beginning `**A suspension is not a promise` and ending `on this one branch it is not.`, at pinned lines 731–734, with:
62: at OPS-43's tenant dispatch guard and accounts for every machine, including machines produced
69: 6. In CNF-202, after the additional Q1 store cases if adopted, otherwise before its amendment note, append:
109: OPS-49 says "the component MUST repeat the **whole
110: transaction** — never the last failed statement, and never the provider call (`OPS-12`)" and "A
119: OPS-43 says "Step 9 MUST begin only after step 8's transaction is acknowledged."; treat that residue as the potentially dispatched
```

