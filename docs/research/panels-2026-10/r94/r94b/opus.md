I'm Opus. My final pick stays **Q-QUOTE-OPS43**. That isn't because it was mine. Astra's and Sol's own reasons for accepting Q-QUOTE both rest on the OPS-43 sentence that this form quotes. I still CANNOT ACCEPT Q-QUOTE, but only because its citation is inaccurate. No checked verdict changes under it.

**apply notes.md rule 6 exactly as written; this prompt adds no void rule.**

I read notes.md, the brief, source-packet.md, tally-evidence.md, tally-verification.json, both originals, occurrences.md, all twelve option files and my own r94 answer. I read the spec only by `git show` in my clone at M and H. Temporary files went only in `tmp/opus/`. I changed nothing, ran no gate and read no other reader's r94b output.

## Q1 verdicts

| Form | Acceptance | First pick | Why |
|---|---|---|---|
| **Q-QUOTE-OPS43** | **ACCEPT** | **yes** | Keeps all of Q-QUOTE's local instructions unchanged. Quotes the gap's cause from the requirement that owns it. |
| Q-QUOTE | CANNOT ACCEPT | no | Wording-only on all three dimensions. But its LDG-69 quote describes a different transaction under a rule limited to the tenant primitive. This is an accuracy objection, not a rule-3 loss. |
| Q-POINTER | CANNOT ACCEPT | no | "see LDG-69" names the wrong requirement, and the explicit whole-transaction instruction becomes an inference. |
| Q-KEEP | CANNOT ACCEPT | no | No exemption from AGENTS.md:29–32 exists. |

## The strongest arguments, engaged

### Opus's source-scope objection to Q-QUOTE: I keep it, in a narrower form

Verified at M:
1. **The referent.** LDG-69's "that transaction" is the OPS-42 fence transaction. 12:489–490 says "`OPS-42` requires `OPS-41`'s funding read and the fence write to be **one** transaction under this primitive". The payload at 494 ends that same paragraph.
2. **LDG-69's scope.** Its own prohibition applies only while the tenant primitive is held. 12:464–467: "A deployment MUST hold `LDG-35`'s primitive for the duration of one database transaction and no longer. While it is held, an implementation MUST NOT wait on … or any provider call."
3. **The spec says so outright.** STO-55 at 05:253 and 257–259: "a worker, sweep or watcher MUST NOT hold two transactions at once and MUST NOT hold a transaction open across a provider, rail or rescue-host call … `LDG-69` says "…", which is this rule for the tenant primitive alone; it holds for every transaction." 11:425 adds: "`LDG-69`'s prohibition was scoped to the primitive alone".
4. **Nothing requires step 8 to hold the primitive.**
   - OPS-43 (03:757–835) never names LDG-35; I found 0 occurrences.
   - LDG-35's primitive is "per-tenant advisory locks" (12:440), and 12:455 says "**The primitive MUST NOT require a live `tenants` row.**" So Q4-D's conditional write on the tenants row is not that primitive.
   - The create uses LDG-35 only at settlement (05:37: "take the `LDG-35` primitive, make this guarded status write").

**What I withdraw:** my r94 sentence "Step 8 doesn't hold the primitive" was too strong. The manager is right that a missing requirement doesn't prove an implementation can't take it. The narrower point is enough. If an implementation did take the primitive at step 8, LDG-69's 466–467 would bind it only by that choice, and line 494's "that transaction" would still name the fence. The "because" would hold for some implementations and not others. OPS-43:817 holds for all of them.

**Why I still can't accept Q-QUOTE:** a reader resolves the quote's "that transaction" to "the acknowledged transaction" one line earlier. The sentence therefore claims LDG-69 says this about step 8, and it doesn't. The byte gate passes it; checking the context fails it. This correction exists only to make the attribution accurate, so I can't accept a version that is still inaccurate. There is no runtime loss: "treat that residue as the potentially dispatched case" never depended on the "because".

### The case for Q-QUOTE's retained local instructions: I accept it fully

Astra and Sol prefer Q-QUOTE because two of the package's own instructions stay outside the quotes:
- "retry a serialization failure as a whole transaction and do not treat it as a tenant-status refusal"
- "treat that residue as the potentially dispatched case"

I agree, and it's my main reason for rejecting Q-POINTER. But it doesn't separate Q-QUOTE from Q-QUOTE-OPS43:
- The packages differ only on line 44, the comments only on line 84 and the notes only on line 21.
- On each of those lines the only change is the clause `LDG-69 says "…"` becoming `OPS-43 says "…"`.
- Every local instruction, the OPS-49 quotes and the OPS-11 quote are byte-identical between the two forms.

### Astra's and Sol's own reasoning points to OPS-43

- Astra: "I did not treat its words 'that transaction' as independently defining the create guard", and "The create-specific ordering is also explicit in OPS-43:817".
- Sol: "the retained dispatch sequence already requires it: pinned `OPS-43` says 'Step 9 MUST begin only after step 8's transaction is acknowledged.'"

Neither answers the referent objection. Each concedes that the LDG-69 quote can't establish the step-8 ordering by itself, and brings in OPS-43:817 to do it. Q-QUOTE-OPS43 puts that sentence in the text, so someone reading API-58 doesn't need a reviewer's reasoning to see why the gap exists. That's why I think all three of us can accept it.

### Strongest case for keeping the LDG-69 name: weighed, not decisive

API-63 (04:1428) says of this very correlator transaction: "`LDG-69` keeps the provider call outside that transaction". And the owner adopted Q4-D with LDG-69 named. That is the best argument for Q-QUOTE, and it's why I don't think Astra's and Sol's view is unreasonable. It doesn't change my verdict:
- API-63's sentence is an unquoted attribution of the same shape. It doesn't widen what LDG-69 itself says.
- STO-55's text, added later, explicitly limits LDG-69 to the primitive.
- The spec also has the opposite precedent. OPS-50 (03:2011–2012) quotes exactly this sentence for this same gap: "step 9 after step 8 (`OPS-43`: "Step 9 MUST begin only after step 8's transaction is acknowledged")".
- Item 19 adopted the residue rule and the disclosure, not the citation. The owner's 2026-10-28 wording rule governs correcting the citation.

### The same test applied to the OPS-49 quotes (Sol's juxtaposition point)

My one standard is the right requirement, quoted accurately in context. The OPS-49 quotes pass it:
- OPS-49 owns transaction repetition for step 8. OPS-43:818 sends a lost acknowledgement to "`OPS-49`'s "repeat the **whole transaction**" path", and the serialization bullet (03:1953–1956) sits inside that loop.
- The quotes are presented only as what OPS-49 says. The whole-transaction retry for serialization failures follows as the package's own instruction, not as a "because".

The LDG-69 quote fails both tests: it's the wrong requirement, and it's offered as the cause.

### Q-POINTER

I give up part of my r94 objection. Astra's and Sol's reading is reasonable: "repeated at once" sits inside OPS-49's whole-transaction loop. I can't name a checked verdict that changes, so I withdraw r94's flat SUBSTANTIVE label as a blocking claim. Two problems remain, and either is enough for CANNOT ACCEPT:
- "For provider-call ordering, see LDG-69" names the same wrong requirement.
- The adopted explicit unit, "as a whole transaction", becomes an inference. OPS-49's explicit MUST (03:1926–1928) starts "Where a store call … errors or times out", and 03:1953 says serialization failures "are not store errors".

The second is a loss of explicitness, not a demonstrated rule-3 loss.

### Q-KEEP

AGENTS.md:29–30 says: "A claim about what another requirement says carries that requirement's own words." Both "LDG-69 keeps the call outside the transaction" and "retried as a whole transaction under OPS-49" are claims of that kind, with no quotation. I found nothing in the rule or elsewhere that exempts them. Being true, or adopted by the owner, isn't an exemption. The LDG-69 claim also names the wrong requirement.

## Classification: Q-QUOTE-OPS43 and its L-NOTE landing

| | Behavior | Requirements | Check strength |
|---|---|---|---|
| **Q-QUOTE-OPS43** | **WORDING-ONLY**. The instructions for the early read, both guard races, the lost acknowledgement, serialization and the residue are unchanged, and so is the order of checks. | **WORDING-ONLY**. The quoted sentence is already a MUST at 03:817, and the package already requires it ("acknowledgement-before-step-9 rules remain required", lines 31–32). Item 2 is inserted before the operations-row write at 03:804, so line 817 survives and the quote stays true. Item 5's disclosure is unchanged, the positive existing-fleet warning duty is not restored, and the OPS-27 path is unchanged. | **WORDING-ONLY**. Item 6 is byte-identical (package 70–98 / comment 113–141). No Lean statement, guard hypothesis, fixture or negative control is touched. |
| **L-NOTE** (note-Q-QUOTE-OPS43.md) | **WORDING-ONLY**. What runs is the comment's corrected blocks. | **WORDING-ONLY**. The note marks the archive as historical and lists the two replacements. It adds no duty and restores nothing item 19 gave up. | **WORDING-ONLY**. It is provenance only. |

For the L-NOTE landing, all 6,606 original bytes stay as the prefix and the heading lands at line 100. The result is 7,688 bytes, SHA-256 `b1a08789423da142a4bb0d2d87cdb92fe813c7460f80e545101bc74c20171682`. One dependency must land with it: `docs/research/panels-2026-10/r94/notes.md` and the settled correction, so that `../../r94/notes.md` resolves. That path is absent at H; I checked.

## What goes beyond LDG-69's and OPS-49's words, and where it really comes from

| Claim | Actual source |
|---|---|
| Step 9 starts only after step 8 is acknowledged, which leaves a gap | OPS-43:817. Q-QUOTE credits it to LDG-69:494, which is about the fence transaction. |
| No transaction is held open across a provider call | STO-55, 05:253. No form quotes it, and none needs to. |
| The residue is potentially dispatched and may settle | Q4-D item 3 (owner item 19). It parallels 04:1437, "A claimed create with `about_to_order_at` set MUST be treated as potentially dispatched". |
| Serialization failures are retried as a whole transaction | The package's own explicit instruction. OPS-49 supplies "repeated at once" and the store-error whole-transaction MUST. |
| A serialization failure is not a tenant-status refusal | Q4-D's own rule. |
| On a lost-acknowledgement repeat: recheck the guard, keep previously committed values, add no null-column term | Q4-D item 2. Consistent with OPS-43 (03:810–816), OPS-11 (03:249) and STO-3 (05:37: "adds no `about_to_order_at IS NULL` term"). |
| A deterministic failure recorded before step 9 settles `failed` | OPS-11, 03:249. Quoted, with the line break disclosed below. |
| Cancellation when the machine attaches | OPS-27, 03:642–643: "**Where the machine's tenant is suspended at the moment of the attach, that same transaction also enqueues a system cancellation**". The resolving-observed and late-attach entry points are at 611–612. |

## Assertion inventory

Columns are original archive line → Q-QUOTE-OPS43.md line → prospective comment line. Rows marked * are the replaced spans; every other row is byte-identical.

| Assertion | Lines |
|---|---|
| All unspecified pinned text unchanged | 1 → 1 → 41; also quoted at comment 158–162 |
| Item 1: placed after the account refusal, before step 2 | 3 → 3 → 43 |
| Item 1: tenant read; `conflict` / `tenant_suspended` / `retryable: false` on both views | 6–8 → 6–8 → 46–48 |
| Item 1: before channel closure and boundary validation; no provider request, including List offers and key upload | 8–9 → 8–9 → 48–49 |
| Item 1: settles `failed` with full release and no setup or first-unit debit | 9–10 → 9–10 → 49–50 |
| Item 1: origin kept; no admission-only `suspended`; plain read, closed by the guard | 10–12 → 10–12 → 50–52 |
| Item 2: placement | 15 → 15 → 55 |
| Item 2: same-transaction tenant-row conditional write that contends with the admission flag; a read or claim-time lock is no substitute | 18–21 → 18–21 → 58–61 |
| Item 2: suspension wins, roll back, refusal on both views, `failed`, full release, no debit | 21–24 → 21–24 → 61–64 |
| Item 2: no step 9; the first failed transaction commits no marker or correlator | 24–25 → 24–25 → 64–65 |
| Item 2: a lost-acknowledgement repeat rechecks the guard, keeps values, adds no null term | 25–29 → 25–29 → 65–69 |
| Item 2*: serialization retried as a whole transaction, not a tenant refusal (instruction kept, OPS-49 quotes added) | 29–30 → 29–31 → 69–71 |
| Item 2: claim guard and acknowledgement before step 9 remain required | 30–31 → 31–32 → 71–72 |
| Item 3: replacement boundaries | 34 → 35 → 75 |
| Item 3: a create past the guard is potentially dispatched and may settle; OPS-27 cancellation | 37–39 → 38–40 → 78–80 |
| Item 3: a claim alone authorizes no purchase; the early read and a lost guard prevent purchase | 39–42 → 40–43 → 80–83 |
| Item 3*: the acknowledged-to-call residue is potentially dispatched (only the cited cause changes) | 41–44 → 42–45 → 82–85 |
| Item 3: no never-claimed administrative write; pre-step-9 exception with the OPS-11 quote | 44–47 → 45–48 → 85–88 |
| Item 4: placement, OPS-43 pointer, OPS-27 path including late evidence after the parent settles | 50–56 → 51–57 → 91–97 |
| Item 5: boundaries; not a promise the fleet is gone; purchase authorization stops at the guard; every machine accounted for | 58–62 → 59–63 → 99–103 |
| Item 5: terms MUST explain earlier authorization, later completion and cancellation; MUST NOT promise recall or successful cancellation | 62–66 → 63–67 → 103–107 |
| Item 6: placement | 69 → 70 → 113 |
| Item 6: unclaimed-then-claimed race and its full assertion list | 72–77 → 73–78 → 116–121 |
| Item 6: early read sees active; both guard orders; ack then suspend; attach cancellation; late evidence | 79–86 → 80–87 → 123–130 |
| Item 6: lost acknowledgement, claim guard, auction / `correlator: none` / temporary keys | 88–92 → 89–93 → 132–136 |
| Item 6: account refusal wins over tenant; tenant wins over channel; no provider request | 94–96 → 95–97 → 138–140 |
| Brief: category and summary | comment 3–4 |
| Brief*: authority line, historical vs executable | comment 6 |
| Brief: fixed policy and item 3 quote | comment 8–12 |
| Brief: historical Current behavior blocks | comment 14–37 |
| Brief: rejected "Buy, charge, then cancel"; keep OPS-27; no A/D combination; Q4-D:1 quote; public-warning loss and dissent | comment 144–164 |
| Brief: drift receipts; PR #51 base | comment 166–175 |

## Byte receipts

| Check | Result |
|---|---|
| Same source blobs at M and H | AGENTS.md and files 03, 04, 05, 10, 11 and 12 |
| Live refs | HEAD = M, origin/pr53 = H |
| Originals | H Q4-D.md matches the archive copy (`bd57b4e0…c4ae7`). H `.beads/issues.jsonl:101`, pv-kv2 `comments[0]` id 860, matches the comment copy (`43250b5b…cb6b5`). Q4-D.md is absent at M. |
| OPS-49 whole-transaction payload | 03:1927–1928, 127 B, `357f3aec…`, exact including the line break |
| OPS-49 serialization payload | 03:1955–1956, 46 B, `747bf42b…`, exact including the line break and two spaces |
| LDG-69 payload | 12:494, 78 B, `d3536e66…`. Bytes exact; context wrong, as argued above. |
| OPS-43 payload | 03:817, 66 B, `5a92b5fa3982fcac5f8efa8fdf78e8724e5b97fa6db79cf7b2020e3404a377b1` |
| Payload occurrences | Each occurs once in its source and once in each file of its form |
| Candidate hashes | All twelve match the manifest |
| Historical blocks | Both Current behavior blocks match 3109b5b; 3109b5b and 832a219 are identical for 03, 04 and 10 |

## Rule 6 and packet errors, reported separately

No error I found changes the question's premise. Two unquoted attributions still need exact wording, and the brief invited another source. Nothing is voided. These are reported only:
1. **My own r94 overstatement**, "Step 8 doesn't hold the primitive", corrected above. My vote rests on the narrower claim.
2. **The stop report's "source facts supported" for LDG-69 was too broad**; the brief already says so. Astra's and Sol's acceptance of Q-QUOTE leans partly on it, but both add OPS-43:817. Their votes aren't void.
3. **The brief's title still says "PREPARED, NOT LAUNCHED"**, while STATE.md says the round was admitted and launched. Cosmetic.
4. **Locator imprecision in bytes no candidate changes:**
   - Item 5's "`**A suspension is not a promise`" has a line break after `**A` in the source (04:731–732).
   - Item 4's anchor drops the leading `**` of 04:661.
   - Both still point at one place unambiguously, and neither is part of Q1.
5. **The retained OPS-11 quote has a line break after "any"** where 03:249 has a space. The form with the line break appears 0 times in the source; the form with a space appears 6 times. I accept it as disclosed and propose no normalization.

## Exact form: Q-QUOTE-OPS43 (already printed in options/, not a new form)

The complete package is `options/Q-QUOTE-OPS43.md` (6,831 B, `ba7ddd938d8b7f0defe1616f1b0868bdf5361f8291bc3ad056336134ceacdbf4`). The complete comment is `options/prospective-agent-Q-QUOTE-OPS43.md` (11,036 B, `d14a8a5680f319221789d3e151a4ae9e744cad8eb3c01bcbd4addbf75e830c7c`), with the brief's exact authority line at comment line 6. The appendix is `options/note-Q-QUOTE-OPS43.md` (1,082 B, `31f743fac08408f2798ffbf4553310144082f89199b91c6f823ea76e7d914c4b`). Here is the appendix verbatim, starting with its blank line:

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
OPS-43 says "Step 9 MUST begin only after step 8's transaction is acknowledged."; treat that residue as the potentially dispatched
case.
```

Source pin: `a7b6884878bc7e53dc403dd8a4383d85afac3634`.
Review head: `b85af778fda2a96fb0024a07c69092665303bfbe`.
Panel record: `../../r94/notes.md`.
````

## Requested counterargument (not a vote)

Against my pick:
- Q-QUOTE keeps the owner-adopted LDG-69 name and matches API-63:1428's existing sentence, so it is the more conservative correction.
- Q-QUOTE-OPS43 changes the cited source, which could be called more than the request to "add the supporting source quotations".
- Astra and Sol already accept Q-QUOTE, so one more ACCEPT would settle it. Holding out may send a one-clause difference to the owner.

My answer: the referent is a verified fact, not a reading preference. The only quotation that supports the claim for step 8 is OPS-43:817, and the other two readers already rely on it.

If this round doesn't settle, the owner faces one cited source in one clause. Q-QUOTE has no behavior, requirement or check-strength loss. My recommendation would still be Q-QUOTE-OPS43.

Q1 FINAL: Q-QUOTE-OPS43; carried Q2: L-NOTE
