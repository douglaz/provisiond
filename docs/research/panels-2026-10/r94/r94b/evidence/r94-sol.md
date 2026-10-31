My first preferences are **Q-QUOTE** and **L-NOTE**, exactly as printed. Both are **WORDING-ONLY**. This is my independent ballot, not a panel settlement.

I reviewed PR #53 head `b85af778fda2a96fb0024a07c69092665303bfbe` against source pin `a7b6884878bc7e53dc403dd8a4383d85afac3634`. I read the complete brief, notes, candidates, prospective briefs, originating audit evidence and r93 records. I made no changes and ran no gates.

**Acceptability**

| Q1 exact form | Verdict | Reason |
|---|---|---|
| **Q-QUOTE** | **ACCEPT — first preference** | Supplies exact source words and explicitly preserves both local instructions. |
| Q-POINTER | ACCEPT | The ownership references retain the governing transaction and ordering rules; the package’s distinct suspension instructions remain explicit. |
| Q-KEEP | CANNOT ACCEPT | I found no exemption from the quotation instruction. Supported facts and exact owner adoption do not establish one. |

| Q2 landing, for Q-QUOTE | Verdict | Reason |
|---|---|---|
| L-BRIEF | CANNOT ACCEPT | Corrects execution and distinguishes authority in the brief, but leaves the flagged archive presenting its original executable package without an in-file qualification. |
| L-BOTH | CANNOT ACCEPT | Rewrites the approved artifact without a dated marker while the authority line still calls that path the “Historical adopted form.” Saving the original elsewhere does not make that pointer accurate enough. |
| **L-NOTE** | **ACCEPT — first preference** | Preserves the original bytes, qualifies the flagged archive locally and identifies the corrected executable brief. The stated r94 archive dependency must accompany application. |

My objections to L-BRIEF and L-BOTH concern record adequacy. I am not claiming they change a runtime verdict or weaken a theorem.

**Preservation judgments**

For **Q-QUOTE**, separately:

- **Behavior: unchanged.** Whole-transaction serialization retry, the tenant-refusal distinction and treatment of the post-acknowledgement/pre-call residue remain explicit.
- **Requirements: unchanged.** The quotations document retained source rules. They do not supply the new suspension policy. Although “after … commits” is more specific than “outside the transaction,” the retained dispatch sequence already requires it: pinned `OPS-43` says “Step 9 MUST begin only after step 8's transaction is acknowledged.”
- **Check strength: unchanged.** Item 6 is byte-identical. No declaration, proof statement, guard, fixture, negative control or conformance assertion changes.

For **L-NOTE**, separately:

- **Behavior: unchanged.** Execution follows the same corrected Desired behavior and Acceptance criteria blocks.
- **Requirements: unchanged.** The appendix identifies the original as historical and gives the exact correction. It neither restores the relinquished publication duty nor adds another suspension promise.
- **Check strength: unchanged.** The landing adds provenance and qualification, not different acceptance criteria.

Thus each selected pick is **WORDING-ONLY**, independently of gate results.

I also accept Q-POINTER. Its reference expressly covers both serialization failures and transaction repetition. I read the serialization exception within the whole-transaction retry home as changing retry timing and bound accounting, not permitting statement-only repetition. The replacement retains “A serialization failure is not a tenant-status refusal,” and its provider passage expressly preserves the potentially-dispatched classification. The unchanged lost-acknowledgement guard recheck remains a local instruction. Q-QUOTE is preferable because it preserves the explicit local whole-transaction instruction without requiring that contextual reading.

**Source and byte receipts**

The four complete source files—AGENTS, lifecycle, API and ledger—are byte-identical between M and H. All six source blocks printed in the brief match their cited M ranges exactly.

The original archive at H matches `evidence/Q4-D-original.md`: **6,606 bytes**, SHA-256:

```text
bd57b4e09cfbedfb955fff449748433f12867749525c43f8ee0c9c552e9c4ae7
```

H `.beads/issues.jsonl:101`, pv-kv2 `comments[0]`, id **860**, matches `evidence/agent-brief-original.md`: **10,661 bytes**, SHA-256:

```text
43250b5bea7ca4b4df595a94ecaaa28d4769aa33c90ac1b94ff5e940b65cb6b5
```

The adopted archive is absent from M.

| Q-QUOTE payload | Exact M location | Byte result |
|---|---|---|
| Whole-transaction quotation | `03-operation-lifecycle.md:1927–1928` | Exact, including LF after `**whole` |
| Serialization quotation | `03-operation-lifecycle.md:1955–1956` | Exact, including `A` followed by LF and two spaces |
| Provider-call quotation | `12-billing-and-ledger.md:494` | Exact, including emphasis and punctuation |

Payload SHA-256 values, respectively:

```text
357f3aecab0b2c772fce229e77ee7864cab5a73ab0ba4afa4b9ade0bfd33f5f7
747bf42be7fb239f9900da2b9d2498b06c00c97723f88b6a977246b808f14b0f
d3536e6671d6ae5cdc194cd3e21168a69bcd4e3693748dde47ba8e7c4291ac8c
```

The retained **OPS-11 quotation is not byte-identical**: Q-QUOTE lines 47–48 and prospective brief lines 87–88 contain LF after “any”; pinned lifecycle line 249 contains a space. Replacing only that LF with a space produces an exact substring match. Its words and meaning are preserved. This disclosed presentation difference does not block my acceptance; I propose no normalization.

Other retained quotation distinctions:

- Both Current behavior code blocks exactly match their named historical commit `3109b5b44eae17e288cf52aaa976993bd8c5626c`, at the stated lines.
- The owner-item3 paragraph is reflowed in the brief; its words match after whitespace normalization. The short decision and retained/rejected quotations match their historical source substrings.
- Item 5’s beginning locator renders `**A suspension…`; the source has `**A` followed by LF. Its explicit range and ending locator identify the intended span unambiguously. This is an unchanged locator, not a new exact quotation payload.
- The historical lifecycle/API/checklist equality receipts between `3109b5…` and `832a219…` check out. They are historical receipts, not a claim that today’s checklist is unchanged.

Mechanical comparison confirms each complete candidate contains only its specified pair of substitutions. Each non-KEEP prospective brief contains only that pair plus the specified authority-line replacement. Reversing those substitutions reproduces both originals byte for byte.

For Q-QUOTE/L-NOTE, the prospective archive preserves all **6,606 original bytes** as its prefix. The appendix begins with LF; its heading becomes line 100. The complete file changes to **7,700 bytes**, SHA-256:

```text
316d1c5400e1445b1f1d0ed950e680e5ab35738f9b4e4dfbf22e464618a3fa0c
```

That is prefix preservation, not whole-file identity.

**Assertion inventory**

Locations below refer to complete `Q-QUOTE.md` (**Q**) and `evidence/prospective-agent-Q-QUOTE.md` (**B**).

| Assertion | Executable locations and preservation |
|---|---|
| Unspecified pinned text and placement instructions | Q1; item headings Q3/15/35/51/59/70. B41 and corresponding headings B43/55/75/91/99/113. All retained, including CNF placement relative to additional Q1 store cases. |
| Item 1: check order and exact refusal | Q6–12 / B46–52. Tenant read remains after account refusal, before channel closure and boundary validation; `conflict`, `tenant_suspended`, nonretryable on both views. |
| Item 1: provider, money, origin and read semantics | Same spans retain no provider request including List offers/key upload; failed/full release/no debit; original `requested_by`/`system_reason`; no admission-only `suspended`; plain early read. |
| Item 2: atomic guard | Q18–24 / B58–64. Same-transaction conditional tenant-row write, contention with admission flag, earlier read/lock insufficient, suspension-wins rollback and exact refusal/release, no step 9. |
| Item 2: markers and lost acknowledgement | Q25–29 / B65–69. First failure commits neither marker nor correlator; repeat rechecks tenant guard; earlier committed values remain; recorded failure settles without a null-column term. |
| Item 2: serialization and remaining guards | Q29–32 / B69–72. Exact source quotations plus explicit whole-transaction retry and non-refusal instruction; operation claim guard and acknowledgement-before-step-9 retained. |
| Item 3: dispatch boundary | Q38–45 / B78–85. Passed guard means potentially dispatched and allowed to settle; suspended-attach cancellation; claim alone authorizes no purchase; early-read and guard-lost prevention remain; post-ack/pre-call residue remains potentially dispatched. |
| Item 3: uncertainty and deterministic exception | Q45–48 / B85–88. No never-claimed administrative failure/release of uncertainty; deterministic worker-recorded pre-step-9 failure exception and existing OPS-11 quotation retained. |
| Item 4: ownership and attachment | Q54–56 / B94–96. OPS-43 pointer; OPS-27 attachment/cancellation path including evidence attachment after parent settlement. |
| Item 5: chosen disclosure | Q62–67 / B102–107. No fleet-gone promise; authorization stops at guard; every machine accounted for, including potentially dispatched orders; terms explain earlier authorization, later completion and cancellation; no promise of recall or successful cancellation. No positive existing-fleet warning publication duty restored. |
| Item 6: unclaimed/claim race | Q73–78 / B116–121. Independent valid active-tenant setup, suspension before claim, exact refusal, both retryability views, no provider/purchase/debit, full release, origin and error-kind assertions. |
| Item 6: early-read race and both winners | Q80–87 / B123–130. Permitted preceding nonmutating reads; no step 9 or first-transaction columns; both guard winners; acknowledged guard then suspension before call permits settlement and attach cancellation; late evidence attachment. |
| Item 6: lost acknowledgement and descriptor coverage | Q89–93 / B132–136. Deterministic failure, unchanged columns, full release, no speculative dispatch, claim guard; auction, standard/`correlator: none`, temporary-key coverage. |
| Item 6: refusal priorities | Q95–97 / B138–140. Unhealthy account wins; with healthy account, tenant suspension wins before channel closure; no provider request in either case. |
| Brief context and authority | B1–37 retain category, summary, fixed policy, owner evidence and historical Current behavior. B6 receives exactly the reviewed authority correction. |
| Scope, rejection and drift record | B144–176 retain rejected buy/charge/cancel policy, dispatched-order retention, no A/D synthesis, unchanged-text instruction, dissent/owner record pointers and all drift receipts. |

The beyond-source instructions remain attributed correctly. Q4-D itself owns the new tenant race handling, marker retention on lost acknowledgement, non-null settlement guard, serialization-versus-tenant-refusal distinction and potentially-dispatched classification. LDG-69 supplies transaction ordering, not that suspension classification.

For the additional attachment source, pinned OPS-27 states:

```text
**Where the machine's tenant is suspended at the moment of the attach, that same transaction also
enqueues a system cancellation**
```

That supports retaining the attachment path; the package expressly applies it to the newly defined potentially-dispatched class. Its deterministic pre-step-9 exception retains the OPS-11 quotation, with the wrapping distinction reported above.

**Exact selected appendix**

This is the printed Q-QUOTE/L-NOTE appendix, including its initial blank line. Its two replacement blocks are also my exact Q1 replacements; no additional repair is proposed.

````text

## Wording correction — 2026-10-31 (Panel O r94)

The text above is retained as the historical form approved in owner item 19.
The executable pv-kv2 Agent Brief uses the following replacements under the
owner's 2026-10-28 wording rule; all other Q4-D text is retained.

Replacement for the serialization-retry sentence:

```text
OPS-49 says "the component MUST repeat the **whole
transaction** — never the last failed statement, and never the provider call (`OPS-12`)" and "A
  serialization failure is repeated at once."; retry a serialization failure as a whole transaction and do not treat it as a tenant-status refusal.
```

Replacement for the provider-call passage:

```text
A create past
the guard can still be between the acknowledged transaction and its provider call, because
LDG-69 says "**the provider call happens after that transaction commits**, never inside it."; treat that residue as the potentially dispatched
case.
```

Source pin: `a7b6884878bc7e53dc403dd8a4383d85afac3634`.
Review head: `b85af778fda2a96fb0024a07c69092665303bfbe`.
Panel record: `../../r94/notes.md`.
````

I also accept exactly the specified replacement authority line:

```text
**Owner decision:** “D: explain exception” (`owner-decisions-1030.md`, item 19). Historical adopted form: `docs/research/panels-2026-10/r83/r83b/Q4-D.md`. Executable form: the Desired behavior / key interfaces and Acceptance criteria blocks below, with the 2026-10-31 Panel O r94 wording correction.
```

The r94 record link is currently absent at H. Shipping the stated r94 archive alongside application is therefore a real dependency, already included in this exact landing.

**Requested counterarguments — not votes**

Against Q-QUOTE: it duplicates source text, produces awkward wrapping and juxtaposes a store-error quotation with the serialization exception. Nevertheless, the following local instruction explicitly preserves whole-transaction serialization retry without converting serialization failures into bounded store errors.

Against L-NOTE: it changes the archive’s whole-file hash and leaves flawed historical sentences visible; someone could copy only the prefix. The dated appendix addresses that risk at the affected location, while the authority line expressly identifies the corrected executable blocks. L-BRIEF offers less local qualification; L-BOTH obscures the original approval at its named path.

**Packet consistency and rule 6**

I found no verified brief error changing either question’s premise. The disclosed OPS-11 wrapping difference and retained locator/owner reflow do not change the question. The absent r94 link is an explicit application dependency, not a false claim of current presence. Candidate disagreements are not packet contradictions.

I apply notes.md rule 6 exactly as written; this answer adds no void rule. The r93 result is precedent only.

Q1 FINAL: **Q-QUOTE**  
Q2 FINAL: **L-NOTE**