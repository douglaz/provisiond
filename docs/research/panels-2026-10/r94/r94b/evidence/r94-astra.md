I prefer **Q-QUOTE / L-NOTE**, exactly as printed, without OPS-11 normalization or any additional repair. Both selections are **WORDING-ONLY** relative to the owner-approved Q4-D package.

This is an independent reader ballot, not a tally or adoption. I read the complete brief, notes, candidates, prospective comments, originals, stop evidence and r93 precedent. Verification used this clone’s pinned Git objects. No files, Git state, tracker records or external services were changed; no gates ran.

**apply notes.md rule 6 exactly as written; this prompt adds no void rule.**

| Q1 exact form | Acceptance | Classification and reason |
|---|---|---|
| **Q-QUOTE** | **ACCEPT — first preference** | **WORDING-ONLY.** Supplies exact source quotations while retaining explicit whole-transaction retry, the tenant-refusal distinction and the potentially-dispatched instruction. Behavior, requirements and checks are preserved. |
| **Q-POINTER** | **ACCEPT** | **WORDING-ONLY.** The complete owning rule remains binding through the transaction-repetition pointer. Both local classifications remain explicit. Requires more cross-reference interpretation than Q-QUOTE. |
| **Q-KEEP** | **CANNOT ACCEPT** | Identity: no behavior, requirement or check change, but the quotation defect remains. I found no applicable exemption. |

For Q-QUOTE:

| Q2 exact landing | Acceptance | Classification and reason |
|---|---|---|
| **L-BRIEF** | **CANNOT ACCEPT** | **WORDING-ONLY**, with unchanged executable behavior, requirements and checks. The comment honestly distinguishes approval from execution, but the flagged archived package remains unqualified at its own location. |
| **L-BOTH** | **CANNOT ACCEPT** | **WORDING-ONLY** in executable behavior, requirements and checks. Nevertheless, the authority line calls the rewritten path the “Historical adopted form,” without an in-file correction marker. Saving the original elsewhere does not make that description accurate at the referenced location. |
| **L-NOTE** | **ACCEPT — first preference** | **WORDING-ONLY.** Corrects execution and marks the historical/executable distinction at the archived finding’s location, preserving the complete original as a prefix. |

My L-BRIEF/L-BOTH objections concern record integrity; they are not claims of a demonstrated rule-3 runtime or check-strength loss.

AGENTS.md:29–30 says:

```text
**Quote the sentence.** A claim about what another requirement says carries that requirement's own
words.
```

“LDG-69 keeps the call outside the transaction” attributes a rule to LDG-69. “A serialization failure is retried as a whole transaction under OPS-49” likewise attributes retained behavior to OPS-49. Their factual support does not exempt them. Nor does historical approval exempt their prospective insertion into requirements. Q-KEEP therefore fails its stated availability condition.

Q-QUOTE preserves the division between source evidence and the adopted package’s instructions. The whole-transaction retry instruction and “do not treat it as a tenant-status refusal” remain outside the quotations. The instruction to treat the acknowledged/pre-call residue as potentially dispatched likewise remains outside the LDG-69 quotation.

I accept Q-POINTER because its pointer explicitly covers both serialization failures **and transaction repetition**, incorporating the complete owner rather than merely naming an exception. OPS-49 supplies the quoted whole-transaction rule printed below and:

```text
- **Constraint violations and serialization failures are not store errors** and do not consume
  the bound.
```

It also supplies:

```text
A
  serialization failure is repeated at once.
```

I read that exception as changing timing and bound accounting, without authorizing statement-only repetition. Q-POINTER retains “A serialization failure is not a tenant-status refusal,” and its provider passage expressly preserves the potentially-dispatched classification. Thus I find no weakened operative assertion. Q-QUOTE is preferable because it keeps the repeat unit explicit locally.

The LDG-69 payload’s surrounding discussion concerns the funding fence. I did not treat its words “that transaction” as independently defining the create guard. The broader prohibition at LDG-69:465–467 is:

```text
database transaction and no longer. While it is held, an implementation MUST NOT wait on a running
operation's hold on its machine (`OPS-8`), the completion of a child operation (`API-58`,
`WIR-39`), or any provider call.
```

The create-specific ordering is also explicit in OPS-43:817: “Step 9 MUST begin only after step 8's transaction is acknowledged.” The suspension classification of the remaining gap belongs to Q4-D itself.

Other beyond-source instructions retain their proper owners:

- Q4-D items 1–3 supply the tenant read, competing tenant-row write, refusal classification, lost-acknowledgement tenant recheck, preservation of earlier values and treatment of uncertain dispatch.
- OPS-11 supplies the pre-step-9 failure exception. Its source also states: “The settle write keeps the ordinary worker guard” and “with no `about_to_order_at IS NULL` term.”
- Q4-D retains the attach route through OPS-27, whose pinned text at 642–643 is:

  ```text
  **Where the machine's tenant is suspended at the moment of the attach, that same transaction also
  enqueues a system cancellation**
  ```

  Its entry-point description includes “`OPS-27` **resolving-observed**” and “`OPS-36`'s **late attach**” at 611–612. The late-attachment instruction is not attributed to LDG-69 or OPS-49.

For the selected Q1 correction, **behavior** remains the same across suspension-first, guard-first and lost-acknowledgement races. **Requirements** retain every local instruction and the owner’s exact disclosure choice. **Check strength** is unchanged: item 6 is byte-identical, and the correction changes no declaration, guard, fixture or negative control. No positive duty to publish the existing-fleet warning is restored.

For selected Q2, the executable package is the same Q-QUOTE package. Behavior, requirements and check strength therefore remain unchanged. The record correction distinguishes original approval from subsequent wording correction. Its archive dependency must land with it: `docs/research/panels-2026-10/r94/notes.md` and the settled correction must exist so `../../r94/notes.md` resolves. That directory is absent at H; I am not treating the dependency as already satisfied.

**Exact verification receipts.** M is `a7b6884878bc7e53dc403dd8a4383d85afac3634`; H is `b85af778fda2a96fb0024a07c69092665303bfbe`. HEAD and `origin/pr53` respectively match them.

The complete AGENTS, lifecycle, API and ledger files are byte-identical across M/H. Every supplied source block matches its stated M span, including line breaks. Q4-D exists at H and is absent at M.

| Verified artifact | SHA-256 |
|---|---|
| H Q4-D = evidence original; 6,606 bytes | `bd57b4e09cfbedfb955fff449748433f12867749525c43f8ee0c9c552e9c4ae7` |
| H pv-kv2 comment860 = evidence original; 10,661 bytes | `43250b5bea7ca4b4df595a94ecaaa28d4769aa33c90ac1b94ff5e940b65cb6b5` |
| Complete Q-QUOTE | `b4764a9675f8cfcb615aa6fec18f29ce6e6a3f952273bda4b703c3128aec094d` |
| Complete prospective Q-QUOTE comment | `ecb75b0086f3603347fdbc78e39cd878aad03b608ea96af61bbab435a5e9c896` |
| Exact Q-QUOTE appendix | `7092834f15abcfaa5e56d31b91bb8d3594ec0f49eba98d0658f07f3e5d369baa` |
| Original plus appendix, computed in memory; 7,700 bytes | `316d1c5400e1445b1f1d0ed950e680e5ab35738f9b4e4dfbf22e464618a3fa0c` |

The tracker target is physical JSONL row 101, `comments[0]`, id860. For each candidate, independently substituting exactly its pair into the originals reproduces its complete package and prospective comment; non-KEEP comments additionally contain exactly the authority replacement. No other bytes differ.

| New quotation payload | Exact source location | Bytes | SHA-256 |
|---|---|---:|---|
| Whole-transaction payload | lifecycle:1927–1928 | 127 | `357f3aecab0b2c772fce229e77ee7864cab5a73ab0ba4afa4b9ade0bfd33f5f7` |
| Serialization payload | lifecycle:1955–1956 | 46 | `747bf42be7fb239f9900da2b9d2498b06c00c97723f88b6a977246b808f14b0f` |
| Provider-call payload | ledger:494 | 78 | `d3536e6671d6ae5cdc194cd3e21168a69bcd4e3693748dde47ba8e7c4291ac8c` |

These payloads match source bytes, including the whole-transaction LF, serialization LF plus two spaces, backticks and emphasis. The printed appendix equals `note-Q-QUOTE.md` exactly.

The retained OPS-11 quotation is **not byte-identical**: its LF after “any” corresponds to a source space. Replacing that LF with one space yields the exact source sentence at lifecycle:249. I accept the printed form: it carries the requirement’s actual words, with a disclosed soft wrap, and changes no meaning. This is not an exemption for unquoted paraphrases. I propose no normalization.

The historical Current behavior blocks exactly match their named `3109b5b44eae17e288cf52aaa976993bd8c5626c` sources at lifecycle:776 and API:731. The historical file-equality drift receipts also check out against `832a2197aec28e63bd6d0bf70996171cd0dbd6f7`. Owner items 3/19 and owner-questions evidence match H’s archived records. These historical quotations do not instruct restoration of the relinquished publication duty.

**Assertion inventory.** Q means complete `Q-QUOTE.md`; B means complete `prospective-agent-Q-QUOTE.md`. Locations include the placement instructions where relevant.

| Assertion retained | Q lines | B lines |
|---|---:|---:|
| Item 1 placement: after account refusal, before channel closure/boundary validation | 3, 6–8 | 43, 46–48 |
| `conflict` / `tenant_suspended`, nonretryable on both views; no provider request, including List offers/key upload | 6–9 | 46–49 |
| Failed/full release/no setup or first-unit debit; original `requested_by`/`system_reason`; no admission-only `suspended`; plain early read | 9–12 | 49–52 |
| Item 2 placement after STO-47 check, before operation-row write; same-transaction conditional tenant write; admission-flag contention; earlier read/lock insufficient | 15, 18–21 | 55, 58–61 |
| Suspension-wins rollback, exact refusal on both views, failed/full release/no debit/no step 9; first failed transaction writes neither marker nor correlator | 21–25 | 61–65 |
| Lost-acknowledgement repeat rechecks guard, retains previous marker/correlator, settles recorded pre-step-9 failure, adds no null-column settlement condition | 25–29 | 65–69 |
| Explicit whole-transaction serialization retry; not tenant refusal; operation claim guard and acknowledgement-before-step-9 retained | 29–32 | 69–72 |
| Item 3 replacement boundaries; guard-passed create potentially dispatched and allowed to settle; suspended-attach cancellation | 35, 38–40 | 75, 78–80 |
| Claim alone insufficient; early-read refusal and guard defeat prevent purchase; acknowledged/pre-call gap remains potentially dispatched | 40–45 | 80–85 |
| No administrative failure/release of uncertain order; deterministic worker-recorded pre-step-9 exception and OPS-11 quotation | 45–48 | 85–88 |
| Item 4 insertion point, OPS-43 ownership pointer, OPS-27 route including evidence attachment after parent settlement | 51–56 | 91–96 |
| Item 5 complete replacement boundaries; no fleet-gone promise; authorization stops at guard; accounts for machines from potentially dispatched orders | 59–64 | 99–104 |
| Terms/operator documentation explain previously authorized completion and cancellation; no promise of recall or successful cancellation | 64–67 | 104–107 |
| Item 6 placement after Q1 store cases if adopted, otherwise before amendment note | 70 | 113 |
| Independent active-admission/unclaimed/claim race; exact refusal, both views, no request/purchase/debits, full release, original origin and no admission-only error | 73–78 | 116–121 |
| Early-read-active race; only preceding nonmutating reads allowed; no step 9 or first-transaction marker/correlator; both guard winners | 80–83 | 123–126 |
| Acknowledged guard then suspension before provider call: allow settlement, attach cancellation if still suspended; late evidence after parent settlement | 83–87 | 126–130 |
| Lost acknowledgement: deterministic failure, unchanged columns, full release, no speculative dispatch, claim guard in every settlement | 89–91 | 132–134 |
| Auction, standard / `correlator: none`, temporary-key coverage | 92–93 | 135–136 |
| Unhealthy-account priority; healthy-account tenant-before-channel priority; no provider request in either case | 95–97 | 138–140 |
| Unspecified pinned text unchanged | 1 | 41, 158–162 |
| Category/summary; fixed policy and owner evidence; historical Current behavior | — | 3–37 |
| Historical/executable authority distinction | — | 6 |
| Rejected buy/charge/cancel, retained dispatched-order route, no A/D combination; public-warning loss/dissent record | — | 144–164 |
| Historical drift receipts and named base | — | 166–175 |

Full reading found no additional operative assertion omitted by that inventory. Items 1, 4–6 and all surrounding brief material remain byte-identical; items 2–3 differ only by the reviewed substitutions.

**Packet discrepancy, separately from candidate disagreement.** Item 5’s locator spells `**A suspension is not a promise`, while M:731–732 contains `**A\nsuspension is not a promise`. The named lines and complete sentence identify the intended span unambiguously. This is a pre-existing locator precision issue, not a different disclosure option. Together with the explicitly disclosed OPS-11 wrap mismatch, it does not change either question’s premise. I found no premise-changing brief error under rule 6.

**Exact selected appendix**, including its initial blank line:

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

I accept the authority-line replacement exactly as printed in the brief. L-NOTE preserves original lines 1–98 as the exact prefix; the appended heading begins at line 100. The whole file’s hash changes.

**Requested counterargument — not a vote:** Q-POINTER avoids awkward source wrapping and duplicated explanation while retaining ownership. L-BRIEF leaves the approved archive’s entire hash intact and already identifies the corrected executable brief. Against my selections, Q-QUOTE is longer, while L-NOTE changes the archived file and leaves obsolete sentences visible. I nevertheless prefer explicit local retry instructions and an in-file historical qualification at the finding’s location. The appendix makes those surviving sentences historical evidence rather than competing execution instructions.

**Q1 FINAL: Q-QUOTE**  
**Q2 FINAL: L-NOTE**