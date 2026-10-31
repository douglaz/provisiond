I revise my r94 preference to **Q-QUOTE-OPS43**, exactly as supplied, with carried **L-NOTE**. I accept Opus’s narrower source-scope objection and retain the explicit local instructions that made Q-QUOTE preferable to me.

**apply notes.md rule 6 exactly as written; this prompt adds no void rule.**

I read the required packet, originals, occurrence inventory and every complete candidate package, prospective comment and note. I independently verified sources through `git show` in this reader clone. No files or Git state were changed; no gates, background jobs or subagents ran.

| Complete Q1 form | Acceptance | First preference |
|---|---|---|
| Q-QUOTE-OPS43 | **ACCEPT** | **Yes** |
| Q-QUOTE | **CANNOT ACCEPT** | No |
| Q-POINTER | **CANNOT ACCEPT** | No |
| Q-KEEP | **CANNOT ACCEPT** | No |

This is my reader ballot, not a declaration that the panel has settled.

**Why I changed my judgment**

At M, `12-billing-and-ledger.md:489–490` identifies the transaction:

```text
is now load-bearing rather than theoretical.** `OPS-42` requires `OPS-41`'s funding read and the
fence write to be **one** transaction under this primitive, taken by a worker whose operation already
```

Its conclusion at :494 is:

```text
the other clause: **the provider call happens after that transaction commits**, never inside it.
```

The quotation in Q-QUOTE matches exact source bytes. Its referent is nevertheless the funding/fence transaction. Putting those words after the create’s acknowledged transaction, introduced by “because,” makes them appear to establish ordering for that create transaction.

The broader LDG-69 prohibition retains the condition “While it is held” at :465. STO-55 explicitly distinguishes that scope. M `05-persistence.md:257–259` says:

```text
implementation's, not a deployment parameter. `LDG-69` says "A deployment MUST hold `LDG-35`'s
primitive for the duration of one database transaction and no longer", which is this rule for
the tenant primitive alone; it holds for every transaction. `STO-7`'s
```

The universal prohibition belongs to STO-55:253–254:

```text
arithmetic true:** a worker, sweep or watcher MUST NOT hold two transactions at once and MUST NOT hold a transaction
open across a provider, rail or rescue-host call — a sweep selects a bounded batch by key, commits,
```

I therefore accept Opus’s **narrower** objection: OPS-43 does not require holding LDG-35’s primitive at step 8, so LDG-69 does not establish this create ordering. I do not adopt the categorical claim that no conforming implementation could take the primitive there. API-63’s “primitives cannot supply this” discussion at M `04-api-contract.md:1416–1419` concerns admission/account contention and does not prove that categorical claim.

My former justification—reading LDG-69 together with the create-specific ordering—establishes the actual ordering but does not repair the quotation’s referent. An accurate surrounding policy cannot make this particular attribution accurate. **Q-QUOTE is wording-only in behavior, requirements and check strength, but I cannot accept its source attribution.** This is an accuracy objection, without a demonstrated runtime or checked-verdict loss.

The strongest contrary evidence is real. API-63:1428 itself says:

> “`LDG-69` keeps the provider call outside that transaction”

That is textual precedent for the adopted citation and helps explain it. It does not enlarge LDG-69’s own scope. API-63 remains outside these requested edits.

I also accept the strongest argument **for Q-QUOTE’s explicit local instructions**. Its operative text preserves:

> “retry a serialization failure as a whole transaction and do not treat it as a tenant-status refusal.”

and:

> “treat that residue as the potentially dispatched case.”

Those instructions carry adopted obligations beyond the quotations. Deleting them merely to resolve attribution would be the wrong correction. **Q-QUOTE-OPS43 retains both instructions exactly**, while quoting the applicable ordering rule at M `03-operation-lifecycle.md:817`:

> “Step 9 MUST begin only after step 8's transaction is acknowledged.”

That sentence already remains binding after the package’s step-8 insertion. Quoting it changes the explanation’s source without changing the suspension policy.

**The other complete forms**

**Q-POINTER: CANNOT ACCEPT.** Its “For provider-call ordering, see LDG-69” retains the same owner-scope problem.

On serialization, I still find Astra’s complete-owner reading persuasive. OPS-49’s opening MUST is conditional on a store call that “errors or times out” (:1926–1928). Its exception says:

```text
- **Constraint violations and serialization failures are not store errors** and do not consume
  the bound.
```

and:

```text
A
  serialization failure is repeated at once.
```

I read “repeated” in the complete transaction-repetition context as changing timing and bound accounting, without authorizing statement-only repetition. The pointer expressly names “serialization failures and transaction repetition.” On that reading, its behavior, requirements and check strength remain **WORDING-ONLY**, although the repeat unit becomes less explicit locally.

Opus correctly identifies the conditional opening and the removed explicit sentence. I do **not** find those observations alone prove a changed MUST/SHOULD or checked verdict under rule 3. I therefore do not report a verified serialization blocking loss. My rejection rests independently on the incorrect provider-ordering owner. Q-QUOTE-OPS43 avoids both the scope defect and the need to rely on this disputed incorporation.

**Q-KEEP: CANNOT ACCEPT.** M `AGENTS.md:29–30` says:

```text
**Quote the sentence.** A claim about what another requirement says carries that requirement's own
words.
```

No applicable exemption is established. Historical adoption and a true ordering fact do not establish one. Its identity package changes no behavior, requirement or check, but leaves the attribution defect and unquoted claims. Its supplied note is conditional reference material, not an authorized landing.

**Selected form and carried landing**

These classifications are relative to the owner-adopted Q4-D package, not to M before adoption.

| Dimension | Q-QUOTE-OPS43 | Its carried L-NOTE landing |
|---|---|---|
| Behavior | **WORDING-ONLY:** same refusal, retry, dispatch-gap and attachment outcomes | **WORDING-ONLY:** same executable package |
| Requirements | **WORDING-ONLY:** explicit local obligations retained; applicable existing ordering sentence quoted | **WORDING-ONLY:** authority line distinguishes historical adoption from executable correction; appendix qualifies historical wording |
| Check strength | **WORDING-ONLY:** item 6 is byte-identical; no declaration, guard, fixture or negative-control strength changes | **WORDING-ONLY:** original archive remains an exact prefix; executable acceptance criteria remain identical |

No selected change restores the positive existing-fleet warning publication duty relinquished by item 19. Item 5 remains byte-identical, including its requirement to explain earlier authorization and its prohibitions on promises of recall or successful cancellation.

The suspension-first trace still refuses before step 9. The acknowledged-guard-first trace still permits settlement after suspension and requires cancellation on attachment while the tenant remains suspended. The lost-acknowledgement trace still repeats the whole transaction, rechecks the tenant guard, preserves previously committed values and records deterministic pre-step-9 failure without speculative dispatch. I find no collateral verdict flip.

L-NOTE retains the original archive bytes, appends **`note-Q-QUOTE-OPS43.md` exactly**, and uses the supplied authority correction at prospective comment line 6. The r94 notes and settled correction must accompany that landing so `../../r94/notes.md` resolves. That notes path is absent at H. The supplied appendix’s parent-panel name and pins remain intentional; I propose no metadata repair.

**Assertion inventory**

This inventory follows the original Q4-D items and original brief sections. “Original” means original package lines; Q means complete `Q-QUOTE-OPS43.md`; B means complete prospective comment.

| Original assertion and placement | Original | Q | B |
|---|---:|---:|---:|
| Item 1 insertion after account refusal, before step 2; plain tenant read before channel closure and boundary validation | 3, 6–12 | 3, 6–12 | 43, 46–52 |
| Suspended tenant gives `conflict` / `tenant_suspended`, nonretryable on both views | 6–8 | 6–8 | 46–48 |
| No provider request, including List offers/key upload; failed/full release/no setup or first-unit debit | 8–10 | 8–10 | 48–50 |
| Preserve `requested_by` and `system_reason`; no admission-only `suspended`; later guard closes race | 10–12 | 10–12 | 50–52 |
| Item 2 placement after account check, before operation write; same-transaction conditional tenant-row write | 15, 18–19 | 15, 18–19 | 55, 58–59 |
| Contention with admission flag; earlier read or earlier-check lock insufficient | 19–21 | 19–21 | 59–61 |
| Suspension wins: rollback, exact refusal/views, failed/full release/no debit/no step 9 | 21–24 | 21–24 | 61–64 |
| First failed transaction commits neither marker nor correlator | 24–25 | 24–25 | 64–65 |
| Lost acknowledgement: whole-transaction guard recheck, preserve earlier values, recorded pre-step-9 failure, no null settlement term | 25–29 | 25–29 | 65–69 |
| Whole-transaction serialization retry; distinct from tenant refusal | 29–30 | 29–31 | 69–71 |
| Operation claim guard and acknowledgement-before-step-9 retained | 30–31 | 31–32 | 71–72 |
| Item 3 full replacement boundaries; guard-passed create potentially dispatched and MUST be allowed to settle; attach cancellation | 34, 37–39 | 35, 38–40 | 75, 78–80 |
| Claim alone insufficient; early-read refusal and guard defeat prevent purchase | 39–41 | 40–42 | 80–82 |
| Acknowledged/pre-call residue remains potentially dispatched | 41–44 | 42–45 | 82–85 |
| No administrative failure/release of uncertain order; deterministic worker pre-step-9 exception and OPS-11 quotation | 44–47 | 45–48 | 85–88 |
| Item 4 placement and OPS-43 pointer; OPS-27 route, including late evidence after parent settlement | 50–56 | 51–57 | 91–97 |
| Item 5 replacement boundaries; no fleet-gone promise; authorization ends at guard; account for machines from potentially dispatched orders | 58–63 | 59–64 | 99–104 |
| Terms/operator documentation explain earlier authorization, later completion and cancellation; no recall/success promise | 63–66 | 64–67 | 104–107 |
| Item 6 insertion after additional Q1 store cases if adopted, otherwise before amendment | 69 | 70 | 113 |
| Active admission/unclaimed/claim race: exact failure/views, no request/purchase/debit, full release, original origin, no admission-only error | 72–77 | 73–78 | 116–121 |
| Early read sees active: same refusal, only preceding nonmutating reads, no step 9 or first marker/correlator; race both winners | 79–83 | 80–84 | 123–127 |
| Acknowledged guard then suspension before call: potentially dispatched, settlement, suspended-attach cancellation and late evidence | 82–86 | 83–87 | 126–130 |
| Lost acknowledgement: deterministic failure, preserved columns, full release, no speculative dispatch, claim guard every settlement | 88–90 | 89–91 | 132–134 |
| Auction, standard/`correlator: none`, temporary-key coverage | 91–92 | 92–93 | 135–136 |
| Unhealthy-account priority; healthy-account tenant-before-channel priority; no request | 94–96 | 95–97 | 138–140 |
| Unspecified pinned text unchanged | 1 | 1 | 41, 158–162 |
| Category, summary, fixed policy, owner evidence, historical Current behavior | Original brief 1–37 | — | 1–37 |
| Authority line: historical adopted artifact versus corrected executable blocks | Original brief 6 | — | 6 |
| Rejected buy/charge/cancel; retained dispatched-order route; no A/D combination; warning-loss/dissent record | Original brief 143–163 | — | 144–164 |
| Historical drift receipts and PR51/base statement | Original brief 165–175 | — | 166–176 |

All unaffected bytes are preserved. The substitutions reproduce the entire candidate package and comment exactly, rather than merely preserving selected identifiers.

The tenant refusal classification, competing tenant-row write, suspension-race treatment, serialization/tenant-refusal distinction, permission to settle the uncertain residue and associated conformance cases belong to **Q4-D itself under item 19**. They are not deductions from LDG-69 or OPS-49.

The surrounding retained sources are independently applicable:

- OPS-43:817–818 supplies acknowledgement ordering and the lost-acknowledgement instruction: “MUST take `OPS-49`'s "repeat the **whole transaction**" path, never speculative dispatch.”
- OPS-11:249 supplies “MUST settle `failed`, whatever its kind” for worker-recorded pre-step-9 failure and states “with no `about_to_order_at IS NULL` term.”
- OPS-27:642–643 says:

  ```text
  **Where the machine's tenant is suspended at the moment of the attach, that same transaction also
  enqueues a system cancellation**
  ```

  Its entry-point text at :611–612 expressly includes resolving-observed and late attach. Q4-D applies that existing route to its adopted potentially-dispatched class.

**Independent byte receipts**

The clone’s local HEAD resolves to M=`a7b6884878bc7e53dc403dd8a4383d85afac3634`; local `origin/pr53` resolves to H=`b85af778fda2a96fb0024a07c69092665303bfbe`. The source files listed in `tally-verification.json` are byte-identical between M and H. Every source-packet “Source at M” block matches its stated range.

At H, the archived Q4-D equals the evidence original. The target is physical `.beads/issues.jsonl` row 101, `pv-kv2`, `comments[0]`, id860; its decoded text equals the original brief. The archived package is absent at M.

| Newly quoted payload | Exact M source | Bytes | Result |
|---|---|---:|---|
| Whole-transaction clause | lifecycle:1927–1928 | 127 | Exact, including LF |
| Serialization clause | lifecycle:1955–1956 | 46 | Exact, including LF and two spaces |
| LDG provider clause | ledger:494 | 78 | Exact bytes; applicability objection remains |
| OPS43 provider clause | lifecycle:817 | 66 | Exact bytes and applicable transaction |

For every candidate, applying only its supplied pair of replacements reproduces its complete package; applying that pair plus the specified authority replacement reproduces every non-KEEP prospective comment. KEEP reproduces both originals unchanged. Every candidate retains item 5 and item 6 byte-for-byte.

My selected, already supplied artifacts are:

| Artifact | SHA-256 |
|---|---|
| Complete Q-QUOTE-OPS43 package, 6,831 bytes | `ba7ddd938d8b7f0defe1616f1b0868bdf5361f8291bc3ad056336134ceacdbf4` |
| Complete prospective comment, 11,036 bytes | `d14a8a5680f319221789d3e151a4ae9e744cad8eb3c01bcbd4addbf75e830c7c` |
| Corresponding dated note, 1,082 bytes | `31f743fac08408f2798ffbf4553310144082f89199b91c6f823ea76e7d914c4b` |
| Original archive plus that note, 7,688 bytes | `b1a08789423da142a4bb0d2d87cdb92fe813c7460f80e545101bc74c20171682` |

The latter preserves all original archive bytes as its prefix; the appendix heading starts at line 100. I propose no additional form or combination.

The retained OPS-11 quotation has an LF after “any” where the source has a space. Replacing only that LF with a space produces the exact source sentence. I accept its disclosed wrapping and preserve its bytes. Item 5’s beginning locator similarly uses a space where the source has LF after `**A`. The owner-item3 quotation is historically reflowed. These differences are distinct from the exact new quotation payloads.

The historical Current behavior blocks match their named `3109b5b44eae17e288cf52aaa976993bd8c5626c` sources. The complete historical lifecycle, API and checklist files match between that ref and `832a2197aec28e63bd6d0bf70996171cd0dbd6f7`.

**Rule 6, separately from candidate disagreement**

The original “source facts supported” description was overbroad regarding LDG-69’s applicability. Verification confirms the narrower source objection. This does not change the question’s premise: the same retained-rule attributions need wording correction, and an applicable alternative source was expressly permitted. **No tally is voided under rule 6.**

My earlier Q-QUOTE acceptance relied on the insufficient combined-source justification; this ballot withdraws it. Opus’s categorical “Step 8 doesn’t hold the primitive” exceeds what the source establishes, but his narrower objection survives without that categorical premise. The disclosed whitespace differences do not change either question’s premise.

**Strongest counterargument — not a vote:** Q-QUOTE follows API-63’s existing attribution, preserves all operative instructions, and quotes exact bytes. Changing its citation could look like departing from the historical adopted form. My answer is that Q-QUOTE-OPS43 preserves that form’s operative obligations and corrects only the explanatory source; L-NOTE honestly records the distinction.

If this sole consensus round does not settle an exact form under the existing rules, the remaining question goes to the owner.

**Q1 FINAL: Q-QUOTE-OPS43; carried Q2: L-NOTE.**