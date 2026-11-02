# r95 occurrence inventory at review head 96a72898c7ace67790aec0bab3727eee858e2245

The table below inventories requirement names and implicit retained-rule references within the six executable blocks. It is deliberately broader than the four reported summaries. A sentence that defines this package's own new policy may differ from a sentence asserting a retained source's content; each reader must decide with evidence. Line numbers identify the actual review head, not the master source pin. JSONL physical row is resolved below; decoded lines refer to comment860's text.

| Head location | Sentence/reference | Candidate handling and unresolved review point |
|---|---|---|
| 03-operation-lifecycle.md:789-790 | full commitment release/no debit under OPS-11 | Q-QUOTE adds exact classification and money sentences to this sentence; Q-POINTER retains local settlement/debit instructions plus bare ownership pointer |
| 03-operation-lifecycle.md:814-816 | API-58's admission-time suspension flag write; same-row contention | Extra summary candidate: Q-QUOTE adds API-58's exact flag words; Q-POINTER retains same-row rule plus bare flag pointer. Contention is the package's own new rule |
| 03-operation-lifecycle.md:816-819 | refusal and settle failed under OPS-11 | Q-QUOTE adds exact classification and money words; Q-POINTER retains local refusal/release/no-debit and pointer |
| 03-operation-lifecycle.md:820-824 | recorded failure under the same pre-step-9 rule; no null-column term | Implicit OPS-11 reference beyond four reported occurrences: Q-QUOTE adds exact classification and worker-guard words; Q-POINTER preserves the explicit pre-step-9 local instruction and pointer |
| 03-operation-lifecycle.md:824-827 | OPS-49 says quoted whole transaction and immediate retry; local serialization/refusal distinction; retained claim/ack guards | Already Panel O-corrected. Existing quotations retained; review exact payload after removing Markdown list container indentation. Explicit local commands retained |
| 04-api-contract.md:623-625 | OPS-43 tenant dispatch guard and potentially-dispatched classification; OPS-27 suspended-attach cancellation | Q-QUOTE adds complete exact OPS-27 suspension paragraph to this sentence. Q-POINTER uses machine ownership pointer. Guard/classification is the package's own new policy, not a claim it existed at master |
| 04-api-contract.md:625-627 | claim alone no purchase; tenant-suspended failure under OPS-43; guard prevents purchase | Retained in all supplied forms as coordinated new rule in this package, with reader required to assess whether any part is another unquoted retained attribution |
| 04-api-contract.md:627-630 | OPS-43 acknowledgement quote and potentially-dispatched residue | Existing exact quote and local classification retained, as settled by Panel O |
| 04-api-contract.md:631-633 | OPS-11 says quoted pre-step-9 classification | Q-QUOTE and Q-POINTER repair disclosed existing LF-after-any mismatch to source's space, no policy change claimed; Q-KEEP keeps original mismatch |
| 04-api-contract.md:669 | For claimed-create read/refusal/guard see OPS-43 | Already a bare ownership pointer; retained |
| 04-api-contract.md:670-671 | OPS-27 path including later evidence attachment after parent settles | Q-QUOTE adds entire suspension paragraph, including all entry points and post-parent-settlement rationale. Q-POINTER becomes bare scoped pointer; each reader must test for lost explicit strength |
| 04-api-contract.md:741-742 | stops authorization at OPS-43 guard; accounts for machines | Retained as package's own new disclosure rule; read owner item19 and test that no added positive existing-fleet publication duty is inferred |

The acceptance block contains no requirement identifier or attribution sentence: its assertions are owned by the adopted package. Its late attachment, release/no debit, origin, claim guard and negative provider-call assertions must all survive. No body text outside these six blocks is in scope. In particular the neighboring pre-existing API-58 attributions at :639ff and :673ff are not newly adopted blocks.

## decoded comment860 — matching lines (historical copies are not replacement targets)

```text
43: 1. In OPS-43 step 1, after the account-status refusal paragraph and before step 2, insert:
50: release and no setup-fee or first-unit debit under OPS-11's pre-step-9 create rule. Preserve
55: 2. In OPS-43 step 8, after the STO-47 conditional-write check and before the operations-row write, insert:
59: on its status not being suspended. This write and API-58's admission-time suspension flag write
63: on both error and operation view, then settle failed under OPS-11's pre-step-9 rule with full
68: worker's recorded failure under the same pre-step-9 rule; do not add a null-column term to
69: the settlement guard. OPS-49 says "the component MUST repeat the **whole
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
152: > keep `OPS-27` for orders already dispatched.
```

## archived Q4-D at pin/head — matching lines (historical copies are not replacement targets)

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
46: OPS-11 says "Any create failure the worker records before any step-9 request (before any
50: 4. In API-58, immediately before “A create that has produced no machine yet”, insert:
53: For the claimed create's tenant-status read, refusal and dispatch race guard, see OPS-43.
54: Orders already potentially dispatched retain OPS-27's attach and suspended-tenant cancellation
58: 5. In API-58, replace the complete bold suspension-promise sentence and its following sentence, beginning `**A suspension is not a promise` and ending `on this one branch it is not.`, at pinned lines 731–734, with:
62: at OPS-43's tenant dispatch guard and accounts for every machine, including machines produced
109: OPS-49 says "the component MUST repeat the **whole
119: OPS-43 says "Step 9 MUST begin only after step 8's transaction is acknowledged."; treat that residue as the potentially dispatched
```

## external Panel O settlement — matching lines (historical copies are not replacement targets)

```text
20: A serialization failure is retried as a whole transaction under OPS-49
27: OPS-49 says "the component MUST repeat the **whole
48: OPS-43 says "Step 9 MUST begin only after step 8's transaction is acknowledged."; treat that residue as the potentially dispatched
81: OPS-49 says "the component MUST repeat the **whole
91: OPS-43 says "Step 9 MUST begin only after step 8's transaction is acknowledged."; treat that residue as the potentially dispatched
102: The inserted OPS-49 payloads match lifecycle1927–1928 and1955–1956 byte for byte, including LF, indentation, emphasis and backticks; the OPS-43 payload matches lifecycle817 exactly and governs this create's step8/9 sequence. The discarded LDG-69 quotation has exact bytes but concerns OPS-42's funding/fence transaction. STO-55 distinguishes the primitive-only rule; API-63's repeated attribution does not expand LDG-69's scope.
104: The retained OPS-11 quotation has a pre-existing LF after “any” where its source has a space; checked and disclosed, not claimed byte-identical or normalized. Item5's retained locator and the historical item3 quotation have separate reflow differences. Historical Current behavior blocks match their named historical ref exactly. These unchanged differences do not change this wording question's premise; notes rule6 voids no vote.
106: The whole-transaction serialization retry and tenant-refusal distinction remain explicit local instructions from adopted Q4-D item2; OPS-49's quotations do not by themselves supply both. The potentially-dispatched classification and permission to settle remain explicit item3 policy from owner item19. OPS-43 supplies existing acknowledgement ordering; OPS-11 and OPS-27 supply retained pre-step9 and attachment context. No new policy is inferred from the quotations.
```

Tracker physical path: `.beads/issues.jsonl:101`, pv-kv2, comment id860. The same decoded executable blocks occur at master and head; bead is **closed** at head. Source body must stay coordinated even on a closed bead; this panel changes no tracker.
