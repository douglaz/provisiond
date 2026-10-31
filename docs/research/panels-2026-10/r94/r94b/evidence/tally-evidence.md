# Independent tally audit — 2026-10-31, Panel O r94

This is a read-only audit, not adoption. Source text was read by `git show` in r94's
reader clone. `tally-verification.json` and `tally-verify.py` hold the independent
byte receipts. The live ref check in `tally-remote-pins.txt` still gives
M=`a7b6884878bc7e53dc403dd8a4383d85afac3634`,
H=`b85af778fda2a96fb0024a07c69092665303bfbe`. No moved-ref stop condition.

## Occurrences and preservation

Read the complete original archive and decoded Agent Brief, not just identifier
matches. At H, the target is `.beads/issues.jsonl:101`, pv-kv2, comments[0], id860.
There is one attributed serialization claim in each copy: archive 29–30 and decoded
brief 69–70. There is one attributed provider-ordering claim in each: archive
41–44, specifically 43, and decoded brief 81–84, specifically 83.
`occurrences.md` quotes those spans and lists the related local lost-acknowledgement
and conformance passages. The full substitution check independently confirms each
span occurs once in each original and every candidate changes exactly those spans
(plus the specified authority line in non-KEEP briefs).

For either Q-QUOTE or Q-QUOTE-OPS43, serialization lands at complete-package 29–31 /
decoded-brief 69–71, and the provider passage at 42–45 / 82–85. The authority line
lands at decoded-brief 6. Under the separately agreed L-NOTE landing, these do not
replace original archived lines: the exact original remains the prefix and its
correction is appended starting with the heading at line100. Which exact appendix
lands remains dependent on unsettled Q1. No settled prospective files exist.

The following map names the original assertions and where both quoted alternatives
carry them. It follows original Q4-D's items, which are the source of the list.
Q means either complete quoted candidate; B is its corresponding prospective brief.

| Original assertion | Q / B location and independent result |
|---|---|
| Item1 placement, tenant plain read after account refusal and before channel/boundary checks | 3,6–12 / 43,46–52: byte-identical |
| Item1 exact conflict/tenant_suspended/nonretryable on both views; no provider request including List offers/key upload; failed/full release/no debit; preserved origin; no admission-only kind | 6–12 / 46–52: byte-identical |
| Item2 placement after account-row check, same-transaction conditional tenant-row write, contention with suspension admission, earlier read/lock insufficient | 15,18–21 / 55,58–61: byte-identical |
| Item2 suspension-wins rollback, refusal on both views, failed/full release/no debit/no step9; first transaction commits no marker/correlator | 21–25 / 61–65: byte-identical |
| Item2 lost-acknowledgement recheck, previously committed values retained, worker-recorded pre-step9 failure, no null settlement term | 25–29 / 65–69: byte-identical |
| Item2 serialization retry as whole transaction and distinct from tenant refusal | 29–31 / 69–71: explicit instruction retained outside source quotes in both quoted alternatives |
| Item2 operation claim guard and acknowledgement before step9 | 31–32 / 71–72: byte-identical |
| Item3 complete replacement boundaries; guard-passed create potentially dispatched, allowed to settle, attach cancellation | 35,38–40 / 75,78–80: byte-identical |
| Item3 claim alone insufficient; early-read and guard-lost prevention | 40–42 / 80–82: byte-identical |
| Item3 acknowledged/pre-call residue treated as potentially dispatched | 42–45 / 82–85: explicit instruction retained; reason's source is disputed |
| Item3 no administrative never-claimed failure/release of uncertainty; deterministic worker pre-step9 exception and OPS-11 words | 45–48 / 85–88: byte-identical, including disclosed OPS-11 wrap mismatch |
| Item4 OPS-43 ownership pointer; OPS-27 route and late evidence attachment after parent settlement | 51–57 / 91–97: byte-identical |
| Item5 no fleet-gone promise; authorization stops at guard; account for every machine including potentially dispatched orders; terms explain prior authorization/later completion/cancellation; no promise of recall/successful cancellation | 59–68 / 99–108: byte-identical; neither quoted candidate restores the relinquished public warning duty or combines A/D |
| Item6 placement and independent active-admission/unclaimed/claim race: exact error/views, no request/purchase/debit, full release, original origin, no admission-only error | 70,73–78 / 113,116–121: byte-identical |
| Item6 early-read-active race, permitted nonmutating reads, no step9/first marker or correlator, both guard winners | 80–87 / 123–130: byte-identical |
| Item6 acknowledged guard then suspension before provider call: allow settlement, attach cancellation if still suspended, late evidence after parent settlement | 83–87 / 126–130: byte-identical |
| Item6 lost acknowledgement: deterministic failure, preserved columns/full release/no speculative dispatch/claim guard | 89–91 / 132–134: byte-identical |
| Item6 auction, standard/correlator:none and temporary keys | 92–93 / 135–136: byte-identical |
| Item6 unhealthy-account priority and healthy-account tenant-before-channel priority, no provider request | 95–97 / 138–140: byte-identical |
| Brief fixed policy, owner evidence and historical Current behavior | B1–37: only reviewed authority line B6 changes |
| Brief retained/rejected scope, no A/D combination, public-warning loss and historical drift receipts | B144–176: byte-identical |
| Unspecified pinned text | Q1/B41 and B158–162: byte-identical |

These mechanical results do not decide whether a quotation describes the right
transaction. They do establish that the two quoted alternatives preserve operative
instructions and checks; the source attribution remains the Q1 dispute.

Q-POINTER differs: its local whole-transaction instruction is removed in favor of
the pointer. Astra/Sol read the complete OPS-49 owner as preserving it; Opus rejects
that incorporation and calls the requirement dimension substantive. Do not turn
that disputed preservation judgment into consensus. No changed Lean statement,
fixture, negative control or concrete runtime verdict was demonstrated by a reader.

## Full dissent trace and source claims

LDG-69 at M `12-billing-and-ledger.md:464–467` says:

```text
`OPS-8` defines instead.** A deployment MUST hold `LDG-35`'s primitive for the duration of one
database transaction and no longer. While it is held, an implementation MUST NOT wait on a running
operation's hold on its machine (`OPS-8`), the completion of a child operation (`API-58`,
`WIR-39`), or any provider call.
```

The referent in its last paragraph is explicit at 489–490:

```text
is now load-bearing rather than theoretical.** `OPS-42` requires `OPS-41`'s funding read and the
fence write to be **one** transaction under this primitive, taken by a worker whose operation already
```

The Q-QUOTE payload at 494 is byte-exact:

```text
**the provider call happens after that transaction commits**, never inside it.
```

It describes that funding/fence transaction. The printed candidate places it after
the create guard's acknowledged transaction, so Opus's referent objection is
supported. Astra explicitly notices the funding-fence context, but accepts the quote
with the wider prohibition and create-specific ordering read together. Sol also
relies on create-specific ordering. The wider LDG-69 prohibition still has the
primitive-held condition; it is not by itself the rule for every transaction.

STO-55 at M `05-persistence.md:253–254` says:

```text
arithmetic true:** a worker, sweep or watcher MUST NOT hold two transactions at once and MUST NOT hold a transaction
open across a provider, rail or rescue-host call — a sweep selects a bounded batch by key, commits,
```

Its 257–259 explicitly distinguishes the source's scope:

```text
implementation's, not a deployment parameter. `LDG-69` says "A deployment MUST hold `LDG-35`'s
primitive for the duration of one database transaction and no longer", which is this rule for
the tenant primitive alone; it holds for every transaction. `STO-7`'s
```

The historical finding at M `11-open-findings.md:425` independently says
"`LDG-69`'s prohibition was scoped to the primitive alone."

Read all of OPS-43:757–835. Its create step8 does not require taking LDG-35's
primitive. Q4-D adds a conditional tenant-row write, not a new primitive-holding
instruction. API-63:1416–1419 says "primitives cannot supply this" in its
admission/account-contention discussion; that passage is supporting context, not
a standalone prohibition on using a primitive at step8. Thus Opus's categorical
"Step 8 doesn't hold the primitive" is stronger than what absence of a requirement
proves. The supported narrower conclusion suffices: no mandatory primitive hold
has been established for this dispatch guard, so LDG-69 does not establish its
ordering. STO-3:37's create primitive is explicitly settlement.

The direct owner is OPS-43:817, whose byte-exact sentence is:

```text
Step 9 MUST begin only after step 8's transaction is acknowledged.
```

The remainder of the line begins the lost-acknowledgement sentence, which continues
at 818 with "MUST take `OPS-49`'s \"repeat the **whole transaction**\" path, never speculative dispatch."
OPS-50:2011–2012 already quotes the OPS-43 ordering for a post-check call.
These support Opus's alternative without supplying a new suspension policy.

The strongest contrary evidence was also read in full: API-63:1428–1430 itself
says "`LDG-69` keeps the provider call outside that transaction" about this create
transaction. This verifies the textual precedent cited in Opus's requested
counterargument; it does not enlarge LDG-69's own scope. API-63 is outside this
panel's requested edits. Record the observation, do not create a bead or edit it.

For serialization, OPS-49's complete home was read. At 1926–1928 its
whole-transaction MUST begins "Where a store call" and is conditioned on error or
timeout. At 1953–1956 it separately says:

```text
- **Constraint violations and serialization failures are not store errors** and do not consume
  the bound. A unique violation on a repeat is the repeat landing on its own earlier commit, and
  the guarded status write preceding the money writes short-circuits the rest (`STO-3`). A
  serialization failure is repeated at once. **A `lock_timeout` is a store error for this
```

That is the shared factual basis for the readers' different pointer readings.
Neither quoted candidate attributes the distinct tenant-refusal instruction to
OPS-49: both explicitly retain the adopted local instruction after the quotes.
Q4-D itself supplies that classification and the suspension-guard race/repeat
policy. OPS-43/OPS-11 supply the surrounding acknowledgement, lost-reply and
pre-step9 classification constraints. OPS-27:642–643 says:

```text
**Where the machine's tenant is suspended at the moment of the attach, that same transaction also
enqueues a system cancellation**
```

OPS-27:611–612 lists resolving-observed and late attach. The adopted package
applies that retained path to its newly defined potentially-dispatched class;
LDG-69 and OPS-49 do not supply that class or permission to settle it.

## Quotation and historical receipts

`tally-verification.json` independently verifies all new payload bytes, including
LF/indentation/emphasis/backticks, and the full source blocks in the launch brief.
LDG-69's exact-byte success is not a finding of semantic applicability.
The unchanged OPS-11 quote has LF after "any" where its source has one space;
all readers disclose and accept it without normalization. Item5's unchanged
beginning locator likewise uses a space where the source has LF after `**A`.
Neither difference changes this question's premise. The historical Current
behavior code blocks match their named 3109b5b ref exactly. The quoted owner-item3
paragraph has reflowed whitespace, as already disclosed; it is not byte-identical
to the multi-line historical record. Historical file-equality receipts 3109b5b /
832a219 were independently checked, not projected onto today's checklist.

## Rule6 and next step

Apply notes.md rule6 exactly as written; this audit adds no void rule. The stop
report/reply and Q-QUOTE description overstate LDG-69's support. This breaks a
claimed source justification for those candidates. It does not change the
question's premise: the unquoted attributions still need correction; the brief
expressly permits another source and complete exact alternatives. Opus supplies
one, rather than answering a different policy question. No vote is voided.

All three say their own selected picks are wording-only. That does not yield
three agreements on a single Q1 exact form. Q1 remains 2 Q-QUOTE / 1
Q-QUOTE-OPS43, and no printed Q1 form has three ACCEPTs. Q2's separately asked
landing mechanism L-NOTE has three first preferences; Opus explicitly says its
landing ranking is independent of Q1. The appendices contain different Q1 text,
so there is no three-reader exact appendix or settled combined package yet.
Do not merge those texts or treat Astra/Sol as accepting Opus's new alternative.

Next step: the sole Q1 consensus round r94b in r94/r94b, retaining Q2 L-NOTE
without re-asking its landing choice. Give every reader the others' verbatim
answers, all exact forms, this dissent trace and the unchanged owner constraints.
This tally neither launches that round nor asks the owner a question.
