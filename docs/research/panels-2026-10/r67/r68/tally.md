# r68 tally (panel E confirmation: Q1 pv-tcs S-final/F-final; Q2 pv-ytv K-final). 2026-10-25

Base: `c5f897c32f7894d77a544528872176f241394d0d`. Rules: [notes.md](notes.md), applied per question, with the current tally instruction taking precedence where stricter. Structure follows r67/tally.md only; no r67 outcome rule was imported. All four answers exit 0 and contain substantive answers, not a session-limit line. Their complete sources are [fable.md](fable.md), [opus.md](opus.md), [astra.md](astra.md), [sol.md](sol.md).

Every source file used below was byte-compared with `git show c5f897c:<file>`. The verification record is [tally-source-checks.txt](tally-source-checks.txt): `rg` first, then `sed` of the cited ranges. Anchor verification is [tally-anchor-checks.txt](tally-anchor-checks.txt). The repository remained clean.

## Outcome: (b) for both questions. Corrected reading required; no owner recommendation from this tally

- **Q1: VOID.** Raw picks **S-final 4, F-final 0**. S-d's universal premise is false, and the F impact inventory omits surviving constraints. The instruction for this step says, **“A verified brief error voids that question's tally”**. The votes and option counts below are evidence of what the readers said, not an owner-ready result.
- **Q2: VOID.** Raw support **K-final 4, other shape 0**. The brief's supporting account-read claim is false: one such case passes the List offers read and fails at step 8, not step 1. The same instruction voids this question. The conditional wording of K4 does accommodate that case; this does not rescue the voided vote.
- The notes' rule 6 says “A verified brief error that changes a question's premise voids **that question's** tally only”. The current instruction omits that qualification. This tally does **not** repeat r67's discretionary “error found, tally stands” treatment. There are independently verified errors in each question.
- No consensus or recommendation is declared. No amendment or option is merged into an owner recommendation, no round was launched, and no spec or bead was changed. **No owner-question.md is drafted:** both questions require outcome (b) first. The eventual owner question remains one two-part question, Q1 F versus S and Q2 whether to apply the reviewed K form.
- Rules 4 and 5 do not override the void. Before voiding, F's losses would have followed the unpicked-form branch of rule 4; no verified gated loss was found on S-final itself. No identified clause satisfies rule 5's combination of two successive non-converging rounds and safe deletion; none is deleted.

## Q1 (pv-tcs): S-final stored listing versus F-final admission read

### Reader verdicts and picks

“BU” below means the reader explicitly marked “behaviour unchanged”; it is not the manager's endorsement of that mark. CA means CANNOT ACCEPT. Counts in this section are conditional on ignoring the void, and are never used to recommend a form.

| Reader | S-final, as reported | F-final, as reported | Pick | Strongest argument, theirs |
|---|---|---|---|---|
| fable | **AMEND, BU**, S3 and S4 | **CANNOT ACCEPT as printed**; unmarked F11 proposed | **S** | Admission makes no driver call, preserving the record-before-call constraints; F still misses one after its listed amendments. The claimed one-span repair is incomplete; see verification below. |
| opus | **ACCEPT** | **AMEND, BU**, F11/F12; explicitly CA as printed; F7 correction also supplied | **S** | The provider-silent admission rules survive without edits under S; F still conflicts with both record timing and admission-only error timing. |
| astra | **ACCEPT** | **CANNOT ACCEPT**; separate F5 wording AMEND, BU | **S** | A successful admission read followed by a balance refusal leaves no operation record, breaking the surviving record-before-call MUST. |
| sol | **AMEND, BU**, S2 and S6 | **CANNOT ACCEPT**; separate F5 AMEND, BU | **S** | A bounded stored source preserves provider-silent balance and halt refusals. |

Rule-1 check: fable's S3 is a restatement of the same credential exception. Its S4 changes presentation of the same module assignment, but needs the new storage owner's actual words if that attribution is retained. Sol's S2 is a verbatim-quotation fix. **Sol's S6 adds conformance assertions, rather than merely repairing wording.** Although they exercise duties already listed in S2/S3, the current instruction permits a wording-only ride; S6 is held for the next reading rather than silently counted as one. On that strict check, the provisional S count is **3 ACCEPT / 1 counted CA**, with no gated loss demonstrated against S itself. The raw pick remains S 4–0.

Opus's F11/F12 marks do not make normative exceptions into wording fixes: they relax additional surviving obligations outside the printed form's change inventory. Its F7 supplies an already-required error field. Fable's F11 is unmarked and incomplete. Thus F has **0 counted ACCEPT / 4 CA** before the void. All exact texts are preserved below, including both different F11s.

### Verified gated losses against F-final as printed

- **All readers: `OPS-35`, 03-operation-lifecycle.md:30–33:** “The provider account MUST be resolved and written to the operation record **before** any driver call.” F1 places the driver read after 5d and “before that transaction opens”; the create row is written only on admission, in the transaction (04-api-contract.md:245–248). Trace: pass 5d → successful read → balance refusal → no operation ever exists. F10 adds an exception to a different requirement. **Verified gated loss.**
- **Opus and sol: `OPS-11`, 03-operation-lifecycle.md:256–263:** the listed admission-only kinds, including `insufficient_balance` and `halted`, “are decided before any driver call”. The same F trace decides them after its read. **Verified gated loss**, not repaired by F11 alone.
- **Fable, astra and sol's schema observation, 05-persistence.md:441:** “The `provider_account` write retains `OPS-35`'s "before any driver call".” It would remain an inconsistent current quotation after either F11 exception. A final F repair must account for this span too; neither reader's F11/F12 text does so.
- **Additional manager check, `CNF-31b`, 10-conformance-checklist.md:223–239:** “Admission-only inputs remain pre-provider” and “At admission, a local `PRV-40` closure is a pre-provider refusal”. F performs its read before the relevant tail verdicts. This assertion is not in F's amendment list. Under the ordinary meaning of “pre-provider”, F11/F12 alone still do not make F clean. The corrected read must test this scope explicitly, rather than claim either proposed repair is complete.

The F inventory does accurately enumerate the *edits actually printed*. Its error is treating that inventory as complete coverage of the constraints affected by an admission read. The omitted `OPS-35`/`OPS-11` constraints are independently verified; this distinction prevents relaying a reader's loose “full list” objection as a claim that an unprinted edit already exists.

### Q1 options: raw counts, not merges

| Option | fable | opus | astra | sol | Raw result |
|---|---|---|---|---|---|
| S-a, numbered staleness step | take | take | take | take | **4 take** |
| S-b, combined storage/refresh owner | leave | leave | leave | leave | **0 take** |
| S-c, offer-input MUST | take | leave | leave | take | **2 take** |
| S-d, capability-gap treatment | take, supplies text | take, supplies different text, “behaviour changed” | leave | leave | **2 take; two distinct unreviewed texts** |
| F-a, failed-read wording | F1 printed | Reader 3 | Reader 3 | Reader 3 | **Reader 3: 3; printed: 1** |
| F-b, purchase-write qualifier | leave | leave | leave | take | **1 take** |
| F-c, second CNF-283 sentence | F5 printed | F5 printed | Reader 3 | Reader 3 | **2 printed / 2 Reader 3** |
| F-d, omit “the create's” | leave | leave | leave | leave | **0 take** |
| F-e, offer-input MUST in F | take | leave | leave | take | **2 take** |
| F9, quote synchronization | leave | take | take | take | **3 take** |
| F10, OPS-1 exception as printed | take, with F11 | take | take, insufficient alone | take, insufficient alone | **4 take, with stated qualifications** |

Without the void, only S-a, F-a/Reader 3 and F9 newly reach the option threshold; F10 is already printed and is endorsed with qualifications. Nothing makes S-d's two different texts a merged clause. S-b/S-c/F-b/F-c/F-d/F-e do not reach the threshold. With the void, these remain raw counts for the corrected read.

### Claims checked, including dissent and minority positions

- **S-d's premise is false as a universal (astra and sol correct; opus repeats the error).** Brief.md:170–172 says “no read ever stores its listing” and “every create ... indefinitely”. Counterexample using the printed S2/S1: read and store a row while `list_offers` is declared; restart without it but retain ordering capability; create while that retained row is fresh. S2 has no deletion/invalidation instruction on restart, and S1's stored-row/age check succeeds. The claim is true for a new account with no usable row, not every such account. At c5f897c, `CNF-364`, 10-conformance-checklist.md:138–147, expressly starts with an account that “declares `list_offers` and the ordering capability” and removes the former only before claim; it is not an admission counterexample. **Q1 brief error; void.**
- **S-a's placement rationale is verified.** 04-api-contract.md:262 and :291 say “After steps 1–5d” and “Steps 1–5d still stop at their first refusal”. The option explicitly updates both ranges. S-b adds a “healthy” qualification absent from S3, which supports leaving it as a separate behavioral option rather than a wording fix.
- **Astra's S/GET distinction is verified.** `API-54`, 04-api-contract.md:1292–1296, says “A read MUST NOT take a write transaction”; `CNF-157`, 10-conformance-checklist.md:3575–3577, says “No `GET` takes a write transaction”. A GET that makes a successful driver read and publishes under S2 would conflict. S does not require such a GET implementation: serving stored listings avoids that trace. No gated loss against S was established.
- **Claim-scoped no-request checks are verified for all four readers.** `CNF-55`, 10:341–345, says “restart with it false before claim” and “assert the worker refuses”; `CNF-342`, 10:4053–4074, starts “Use stored creates”; `CNF-278`, 10:2812–2817, says “before claim, then claim it”; `CNF-364`, 10:138–147, explicitly tests the worker's step-4 refusal. Their no-request assertions describe that worker execution, not a prior admission read. These checks do not supply an additional unlisted F flip.
- **Claim publication timing is verified, subject to placement.** `OPS-43`, 03:785–817, puts the read at step 4, the conditional write at step 8 and uploads/order at step 9. `API-63`, 04:1420–1432, calls step 8 “the last write before the ordering call”. S2 can publish after the successful read and before step 8; it need not write after step 8. `OPS-50`, 03:1983–1997, covers “every write transaction made in the engine process” and “every component `OVR-17` assigns to the engine”. `PRV-50`, 02:123–126, says “The driver's List offers MUST be read-only”; publication must be outside that driver read. No identified claim-time no-write assertion was shown broken by this placement.
- **Error-field and quotation corrections are verified.** `WIR-9a`, 13-wire-contract.md:126–143, lists `unsupported` → `provider_account`, `capability`, and `rate_limited` → `retry_after_ms`. `DOM-9`, 01:185, says “Prices MUST be carried as strings exactly as the provider returned them.” These support opus's F7 and sol's S2 wording corrections. The F5 quote alternatives both use a real `API-7` tail clause at 04:269–270; they are alternative fixes, not text to concatenate.
- **F9's minority objection is recorded, not promoted into a vote.** Fable prefers leaving a dated historical record. The record at 03:276–277 nevertheless uses the present-tense “`PRV-40` says to”, as opus notes. The printed F9 changes only the quoted words to the proposed F8 words. This is quotation synchronization; its raw option tally is 3–1.
- **Fable's “repair is one span” claim is false.** Its F11 does not repair the verified `OPS-11` trace, the 05:441 quotation, or the additional CNF-31b concern. Opus's F11/F12 likewise do not include the latter two. Do not describe either as a fully repaired F.
- **Opus's exact authentication headline is not established.** The terminal-credential rule at 02:1246–1250 says “MUST NOT re-attempt it on a schedule”; it does not specify a repeated create's local headline as `authentication` rather than another refusal. Pre-tail source failure can pre-empt the tail, but the exact kind asserted by opus is an inference, not a verified new requirement. No counted vote depends on it.
- **Fable's cache-error taxonomy objection is correct but non-voting.** The `provider` row is at 01-domain-model.md:587, “Provider returned an error response”, not :584. A missing local listing need not follow any provider response. Fable expressly labels this “Note, not a vote”; it supplies no gated MUST trace. Preserve it as a wording/design concern, not a retroactive CA.

### Against my pick (written on request; not votes)

- **fable, against S:** new table, background component, two parameters and an error label that misdescribes a cache miss; admission can use stale information.
- **opus, against S:** reserve an obsolete price and learn only at claim, after queueing; table, component and parameters cost work; the missing-capability case needs a decision.
- **astra, against S:** durable state, periodic reads, freshness settings and stale-data refusals; a fresh request-specific read gives a more current purchase decision.
- **sol, against S:** persistent state and scheduled reads; stale prices; a new account without a usable listing repeatedly refuses. F avoids that machinery once its omitted constraints are resolved.

These are tradeoffs for the eventual owner, not votes for F. The story must retain `OPS-43`'s qualification, 03:865: “where the provider's price has risen past what the reserve covers”. A higher price alone does not prove claim refusal.

## Q2 (pv-ytv): K-final records the fingerprint on every Robot channel

### Reader verdicts and support

| Reader | K-final, as reported | Pick/support | Strongest argument, theirs |
|---|---|---|---|
| fable | **ACCEPT** | **K** | The retained machine fingerprint lets the sweep find the operation's registrations and retain the distinct caller key as well. |
| opus | **AMEND, BU**, K2 and K6 | **K with those texts** | Standard-channel delivery must reach the retained machine through operator attachment; naming the registered key by its fingerprint reflects the documented order transport. |
| astra | **ACCEPT** | **K** | The fingerprint preserves retention evidence, while “has no count” prevents it being used as automatic matching authority on an unverified channel. |
| sol | **ACCEPT** | **K** | Same retained-key trace; K3 removes the cardinality input for automatic attachment and preserves operator resolution. |

Raw support is **K 4–0**. Opus marks both spans “behaviour unchanged”. K6 makes an existing fixture constraint explicit. **K2 is not verified wording-only under the strict current instruction:** the printed MUST says “send its public key with the order”; opus's MUST instead requires naming it in `authorized_key[]`, whose values are fingerprints. This repairs a real transport mismatch, but changes the printed payload obligation and therefore needs review, rather than riding on the author's mark. Provisional rule-1 count would be **3 ACCEPT / 1 counted CA**, without a gated CA trace supplied against the rest of K. The brief error independently voids the question, so neither count establishes readiness.

### Q2 options: raw counts, not merges

| Option | fable | opus | astra | sol | Raw result |
|---|---|---|---|---|---|
| K-a, quoted lead-in/replacement key sentence | leave | leave | leave | leave | **0 take** |
| K-b, alternative PRV-26 sentence | leave | leave | leave | leave | **0 take** |
| K-c, conditional pair test | Reader 2 | Reader 2 | Reader 3 | Reader 2 | **Reader 2: 3; Reader 3: 1** |
| K-d, after-release assertion | take | take | leave, OPS-33 objection | take | **3 take / 1 leave; dissent checked below** |

Without the void, K-c/Reader 2 and K-d reach the option threshold. They are not merged here. In particular, “three take” does not mean astra's trace was ignored.

### Verified mechanics and the lone K-d dissent

- **Brief error, verified (opus correct): not every account-read case fails at step 1.** Brief.md:285–289 says “Its account-read cases fail at `OPS-43`'s step 1”. `CNF-278`, 10-conformance-checklist.md:2817–2820, includes “let the List offers read complete, then commit termination before step 8 commits”. That is after step 4. The rejection is the conditional write of step 8, 03:791–806 and 04:1420–1434. The earlier credentials-rejected/account-unreachable cases do fail at step 1. **Q2 tally void under the current instruction.** Opus identifies the error; the other readers' general confirmations do not correct the brief's false supporting universal.
- **Step-8 pair timing is verified.** 05-persistence.md:441 says “Written in `API-63`'s correlator transaction, which is `OPS-43`'s step 8”. `CNF-278`, 10:2803–2825, includes both before-commit and after-commit cases. The printed K4 is conditional already; the Reader-2 K-c variant makes the exact kind/value and the two outcomes explicit. No new pair write before step 8 is authorized.
- **Key transport, opus correct:** 08-provider-notes.md:127 says “`authorized_key[]` supplies fingerprints to orders”. `PRV-9`, 02:139–158, says the driver “MUST register and attach them as temporary provider-side resources” and “Every temporary key resource a driver registers ... MUST carry the operation id as its provider-side name or tag”. `OPS-43`, 03:809–812, puts temporary registrations at step 9. Opus's revised K2 preserves registration and requests a fingerprint on the order; the original public-key-with-order wording is inaccurate. No provider API was called in this tally.
- **Retention trace, all readers correct:** K1/K2 supply a unique per-order key and pair. 05:326 describes the machine's pair as “what was actually written into the provider at create”. `PRV-9`, 02:150–154, says “the sweep MUST still check the provisioning condition against retained `machines` rows” and “Every temporary key tagged with that operation id, including a caller key distinct from Robot's correlator key, has the same eligibility”. `CNF-303`, 10:2930–2954, checks retention after the operation is removed and reads through `machines.correlator_value`. Trace: record pair at step 8 → register/tag keys at step 9 → deliver and attach machine retaining the fingerprint → reap settled operation → find the retained provisioning machine via fingerprint and retain all registrations with that operation tag. A distinct caller key is not itself used as the correlator.
- **Opus's claimed missing copier is not an established loss:** no explicit separate “copy the pair at operator attach” algorithm was found in the searched attach/schema paths, but 05:326 already states the required field contents, and `PRV-9` explicitly requires the retained machine guard. A conforming attach cannot omit the required pair merely because no second procedural writer sentence repeats it. This is shared pre-existing specification detail, not a demonstrated K regression.
- **K3 precedence, all readers correct:** `OPS-38`, 03:708–712, ends with “has no count” and “it is **Unresolved**”. K3 extends that sentence to `correlator: none`; thus the “Exactly one resource across every channel” row of `OPS-27`, 03:553, cannot gain a cardinality from the unverified fingerprint. Independently, `PRV-33`, 02:1055–1056, says “attaching a discovered machine to a tenant MUST be an operator action”. A non-null pair alone is not matching authority.
- **K6 clarification, opus correct:** `OPS-27`, 03:579–585, says “any non-authoritative search MUST leave the create in `needs_reconciliation`”. On the standard channel, the successful-settlement fixture of `CNF-303` therefore needs the operator attachment route. Opus's K6 states that existing route; it introduces no automatic attachment.
- **K-d dissent checked at 3–1:** astra cites the real `OPS-33` guard, 03:1689–1692: “the negative window MUST NOT run against a matched order that is still in progress”. K5's printed fixture says “exactly one standard-listing transaction carrying its fingerprint”, without stating progress status. The guard is verified, and any test forcing release while that order is still in progress would violate it. **The stronger claim that K-d itself necessarily forces such a release is not proved:** its exact wording is “After the negative window releases the commitment, assert still no automatic attach”, which asserts the post-release result rather than a deadline overriding the guard. A fixture with a legitimately completed negative/operator search can reach that assertion. Astra voted **leave**, not CA with a forced-release trace. The corrected read must explicitly resolve this fixture status/conditional interpretation; it must not recommend a new manager-written guard as though three readers had reviewed it.

### Against K-final (written on request; not votes)

- **fable:** the recorded kind appears to disagree with the descriptor's absence until K3 is read; a null pair would align those appearances at the cost of the recording rule.
- **opus:** an engine could mistake a non-null pair for authority and attach on an unverified channel; the descriptor must control that choice.
- **astra:** K3 and the lost-reply test must accompany recording; a fingerprint by itself does not authorize attachment.
- **sol:** generating/registering a separate key adds work and failure points even though operator resolution remains necessary.

No reader proposes an exact third shape in this round. These requested counterarguments do not reinstate Form N or count as votes for it.

## Exact AMEND texts and disposition

The extracts below are copied verbatim from the answers, including their marks and anchors. They are proposals, not applied changes. Option S-d has two different texts; neither is synthesized. F11 also has two different texts. The two F5 quotation repairs are alternatives.

Individual wording-only candidates are sol S2, fable S3, the wording of fable S4 after the required owner quotation is repaired, either F5 quotation fix, opus F7's already-required field, and opus K6's existing operator-route clarification. **None actually rides now because the question tallies are void.** Sol S6's added assertions, the F11/F12 normative exceptions, the S-d behavior decision, and opus K2's transport obligation require reading as exact text. Any combined form assembled from several readers' AMENDs is unreviewed and must be read whole before recommendation, as the current instruction requires.

### Q1: fable — S3/S4 (BU), S-d (unmarked), F11 (unmarked)

```markdown
**S3, behaviour unchanged**, whole paragraph:
> **OPS-51** A refresh pass MUST read every account declaring `list_offers` at least once per stated offer-listing refresh interval, except a credential after an `authentication` failure: `PRV-41` says “A driver MUST therefore treat an `authentication` failure as terminal for that credential, MUST NOT re-attempt it on a schedule, and MUST surface it for an operator”.

**S4, behaviour unchanged**, the row:
> | Offer-listing refresh (`OPS-51`) | `engine` | Reads offers at a provider, so it needs a provider credential, and writes `offer_listings` (`STO-60`) |

**S-d text**, appended to S-a's 5e (or to S1's second sentence if S-a fails):
> A create whose provider account does not declare `list_offers` is refused here with `DOM-10`'s error: "A capability check failure MUST return an "unsupported" error naming the provider account and the capability, with `retryable: false`".

and appended to S6's insertion:
> On an account declaring the ordering capability but not `list_offers`, assert `unsupported` with `details.capability: "list_offers"`, `retryable: false`, no `details.refusals`, and no commitment, operation or receipt.

**F11** (`03-operation-lifecycle.md`, `OPS-35`), after «account was only ever determined inside the call that vanished.» insert:
> This does not cover a create's admission List offers read, which comes before any record: `API-7` says "the `api` MUST obtain one current driver List offers result for the named offer's provider account".
```

### Q1: opus — F11/F12 (BU), F7 (unmarked separately)

```markdown
F-final AMEND spans. They are "behaviour unchanged" because F10 already says the read "comes before any record".
- **F11** `OPS-35`, after «resolved and written to the operation record **before** any driver call.» insert:
  > This does not cover a create's admission List offers read, made before any operation record exists: `API-7` says "the `api` MUST obtain one current driver List offers result for the named offer's provider account".
- **F12** `OPS-11`: «they are decided before any driver call,» → «they are decided before any driver call other than a create's admission List offers read,»
- **F7**: «assert `unsupported` with `details.capability: "list_offers"`» → «assert `unsupported` with `details.provider_account` naming the account and `details.capability: "list_offers"`». `WIR-9a`'s row requires it: "`unsupported` | `provider_account`, `capability`".
```

### Q1: opus — S-d, explicitly behaviour changed

```markdown
- **S-d: take.** This is "behaviour changed" against S-final, which refuses `provider`/`retryable: true` forever on such an account; no checked verdict changes (point 2). Insert in S1 before "Where no listing is stored" (if S-a passes, this sentence leads step 5e):
  > On create, an account that does not declare `list_offers` MUST be gated under `DOM-10` before the tail: "A capability check failure MUST return an "unsupported" error naming the provider account and the capability, with `retryable: false`".

  Append to S6:
  > On an account declaring the ordering capability but not `list_offers`, assert `unsupported` with `details.provider_account` and `details.capability: "list_offers"`, `retryable: false`, no `details.refusals`, and no commitment, operation or receipt.
```

### Q1: astra — F5, BU

```markdown
**F5 wording AMEND — behaviour unchanged.** Replace its first replacement text, `` `API-7` tail before any provider mutation ``, with:

> tail before any provider mutation (`API-7`: “`rate_limited` when the offer's account and ordering channel are closed under `PRV-40`”)
```

### Q1: sol — S2/S6/F5, each BU

```markdown
**S2 — AMEND, behaviour unchanged.** Replace the `offers` table row with:

```text
| `offers` | json | the driver's List offers result (`DOM-9`: "Prices MUST be carried as strings exactly as the provider returned them.") |
```

**S6 — AMEND, behaviour unchanged.** Append to its inserted conformance text:

> With no customer requests, assert each account declaring `list_offers` is read within each stated offer-listing refresh interval, except while its credential is subject to the authentication stop. Assert no scheduled retry for a stopped credential. After successful reads, assert publication of the complete result with `read_at` equal to the dispatch instant. Complete two reads in reverse dispatch order and assert the row retains the later read's `read_at` and offers. Fail a read and assert the existing row is unchanged. See `STO-60` and `OPS-51`.

This demonstrates the new duties and supplies their otherwise missing conformance citations.

**F5 — AMEND, behaviour unchanged.** Replace its first replacement text with:

```text
`API-7` tail ("then, on create only, `rate_limited` when the offer's account and ordering channel are closed under `PRV-40`") before any provider mutation
```
```

### Q2: opus — K2/K6, BU

```markdown
**K-final: AMEND (behaviour unchanged).**
- **K2.** Robot orders carry fingerprints, not public keys, and the key's registration stays `PRV-9`'s. Replacement:
  > On every Robot ordering channel, including one declared `correlator: none`, the driver MUST generate a throwaway key unique to that order, and the order MUST name it in `authorized_key[]` beside the caller's keys (`08-provider-notes.md`: "`authorized_key[]` supplies fingerprints to orders"). See `PRV-9`, `PRV-26` and `PRV-33`.
- **K6.** `OPS-27` says "any non-authoritative search MUST leave the create in `needs_reconciliation`", and its fourth row includes "no verified correlator exists for the operation's ordering channel". So a standard-channel create never settles on its own. Replacement:
  > Run this Robot case on a standard-channel (`correlator: none`) descriptor too, settling the create through the operator's attach (`PRV-33`: "attaching a discovered machine to a tenant MUST be an operator action").
```

### Manager quotation correction for fable S4 (wording only; not reader-authored)

If that individual row is used, replace its attribution to the storage owner with the proposed owner's actual words. This repairs the quoting defect; it is not a merged S recommendation:

```text
| Offer-listing refresh (`OPS-51`) | `engine` | Reads offers at a provider, so it needs a provider credential. `STO-60`: "Every successful driver List offers read MUST publish its complete result to the account's row." |
```

## What the corrected round reads (not launched)

One four-reader corrected confirmation read, with the same two separately tallied questions. Main prepares complete forms and freezes their exact words before launching; this tally does not launch or silently approve that assembly.

1. **Q1, exact existing forms:** S-final S1–S6 and F-final F1–F10 from r68/brief.md, with all existing options and the raw votes above disclosed as void, not as a majority to follow. Correct S-d's premise to distinguish no-history accounts from accounts with a retained fresh listing. Disclose the surviving OPS-35/OPS-11/schema constraints and the CNF-31b trace. Ask whether the printed forms are acceptable and which to pick, with explicit marked AMENDs. S-a's four raw takes, the exact S wording/coverage proposals, both F11s and opus F12/F7, and the two F5 alternatives are supplied verbatim for reading; **no combined F repair is claimed complete**. If main instead assembles these into a repaired F candidate, the panel must read that complete candidate, including the schema quotation and CNF-31b disposition, before it can be recommended.
2. **Q2, exact correction candidate for review:** K-final K1–K6, replacing K2 and K6 with opus's exact extracts below, and K4 with the brief's Reader-2 K-c text: “asserting, where step 8 committed, `correlator_kind` `ssh_key_fingerprint` and the per-order key's fingerprint on both, and a null pair on both where it did not”. This is a combined candidate requiring its own read, **not** an accepted wording ride. K-a/K-b remain alternatives with zero raw takes, not silently deleted normative text. Present K-d exactly as printed as a separate take/leave option and ask explicitly whether its after-release assertion needs a completed/not-in-progress fixture or is sufficiently conditional already. Correct the account-read explanation to distinguish step-1 failures from the post-read step-8 failure. Retention and no-automatic-attach traces must be checked again on the complete candidate.
3. Ask for ACCEPT/AMEND (explicit BU/changed mark)/CA per complete form, exact replacement spans, each option's take/leave, and the strongest argument. Do not carry the voided counts as valid approvals. Any behavior-changing repair, any merged reader amendments, and any new coordinator sentence must be labelled unreviewed until this read concludes.

After a valid tally, follow notes.md rule 4: a verified gated loss on K or the Q1 pick requires the scoped repair read before the owner question; an unpicked F defect is disclosed to the owner with the proposed fix and the need for a scoped read if selected. The owner question still recommends a Q1 pick rather than calling it settled, includes the cost/latency tradeoff, and asks Q2 whether to apply the reviewed K form. **Main's next action is the corrected reading preparation/launch, not asking the owner to accept these voided results.**

## Brief and reader errors ledger

| Claim | Check at c5f897c | Disposition |
|---|---|---|
| S-d: no listing ever; every such create refuses indefinitely | S1/S2 plus retained-row restart trace; existing capability-restart fixture 10:138–147 | **False universal; void Q1.** Astra/sol found it; opus repeats the overstatement. |
| F impact coverage complete | OPS-35 03:30–33; OPS-11 03:256–263; schema 05:441; additional CNF-31b 10:223–239 | **Omitted surviving constraints; Q1 cannot use this as a clean F premise.** The edit list itself is a correct list of printed edits. |
| All CNF-278 account-read cases fail at step 1 | 10:2817–2820 explicitly passes the read; step-8 guard at 03:791–806 | **False; void Q2 under the current instruction.** Opus found it. |
| Every before-string hits once, understood literally | [tally-anchor-checks.txt](tally-anchor-checks.txt): nine anchors span wrapping; all match once after whitespace normalization | Literal claim false; not a failed normalized applier. Fable's “eight” omits S6, which repeats F7's same wrapped before-string. |
| Fable: F11 alone repairs F | OPS-11/schema/CNF-31b traces above | **False as a complete-repair claim.** Preserve text but do not recommend it as sufficient. |
| Opus marks F11/F12 and K2 as wording-only | These add normative exceptions or change the expressly required payload | **Marks fail the strict wording-only ride check.** Exact texts need review. |
| Fable PRV-9 and taxonomy line hints | PRV-9 relevant sentence is 02:150–151; taxonomy heading 01:575, provider row :587 | Hints corrected; words are found. |
| Fable: overview diagram lacks the F admission read | 00:90–116 includes claim-time List offers at :113 and no admission read | Verified documentation synchronization concern; no independent MUST loss alleged. |
| Astra: K-d lacks an in-progress exclusion | 03:1689–1692 guard is real; option begins “After ... releases” | Guard verified; forced premature release not demonstrated. Record dissent and re-read the exact option/fixture. |

## Validation

The required before/after runs of unpiped `nix develop --command bash tools/check-all.sh` both exited 0 with all gates PASS, in scopes capped at 16G, no swap, OOMPolicy=continue: [before log](tally-gate-before.log), [before exit](tally-gate-before.exit), [after log](tally-gate-after.log), [after exit](tally-gate-after.exit). They check the unchanged c5f897c source set, not the proposed forms. No provider call, tracker write, commit, push, round launch, or memory edit occurred.
