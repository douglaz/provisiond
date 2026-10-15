# Panel r52 synthesis — the codex bot's crash-recovery finding on Robot's one-shot post-order read (PR #3), 2026-10-15

Readers: fable (claude-fable-5-1), opus (claude-opus-5-5), astra (gpt-6-astra), sol (gpt-6.1-sol), all at xhigh;
clones at 74ad5f7. All exit 0; each ran the gates unpiped (exit 0).

## Is the finding real?

**Yes, all four.** `STO-55` forbids a transaction across a provider call, so the read precedes the landed-order
commit. After a crash `OPS-15` moves the create to `needs_reconciliation`, `OPS-49` says "the outcome in hand is
thrown away", and `OPS-27` reaches the read again at its second or third entry point. Nothing in the store says
whether a read was made, so `PRV-13c`'s "MUST NOT be retried ... MUST NOT read ... again" and "MUST record a
successful post-order read's date" cannot both be met. A restore reproduces it after commit (opus).

## Fixes

| Reader | Pick |
|---|---|
| sol | (a) a lost result is a failed read, **plus** a durable "opportunity consumed" marker written before dispatch; full result journal unnecessary |
| astra | same as sol (marker + (a)); relaxing the count instead needs an owner decision |
| fable | **(d)** anchor "once" to the pass whose landed-order transaction commits; an interrupted worker's result is thrown away like the confirming read's (`OPS-49`); no marker; "no owner decision needed" |
| opus | **(d)** as fable, but it changes Q31's "one per delivered order", so the owner confirms it in one line |

Against my two-line fix (a) alone: recovery cannot tell a lost result from a read never made, so it must either
skip the read on every interrupted create (writing null where nothing failed, and contradicting `CNF-356`) or keep
a record; and Q31's "a failed read of any kind" does not cover a read that succeeded (fable, opus). Against a
marker (b): it has its own crash window between writing the record and making the read, and a read, unlike
`OPS-45`'s disk write, can simply be made again (fable, opus). Cost of (d): at most one extra read per create in
flight at a crash, bounded by the worker count (`STO-55`); recovery already repeats the confirming
`GET /server/{n}` on the same counter.

## Other defects found in the sweep

- **`PRV-13c`'s "On failure, the declared bound MUST remain the priced term" has no home** (fable):
  `LDG-33`'s formula prices only "cost through any future permitted-from date"; it has no declared-bound input.
  Fix: one clause in `LDG-33`, "or the offer's declared bound (`PRV-31`) where the column is null"; `PRV-13c`
  quotes it.
- **The operator's synchronous `observed` attach makes no confirming read** (opus): `WIR-35`'s operator verb
  "attaches a discovered resource (`OPS-27`)" without one, yet `PRV-13c` binds the read to "after `OPS-27`'s
  confirming read" and `OPS-27` demands a date or null. Fix: "a settlement with no confirming read (`WIR-35`)
  makes none" — it writes null.
- sol and astra found no further blocker; `CNF-356` needs crash cases for whichever protocol is chosen.

## Recommendations

All four: fix before merging, in one pass, then merge on the next clean gate.

## Strongest case for the other side (written on request — not the readers' positions)

Merge now with a follow-up: the crash window is an alarmed outage, a lost date matters only for a deviating
contract v1 has never seen, and (a) keeps "exactly one `GET /server/{n}/cancellation` for each create" as an
absolute a test can check; (d) changes a count the owner decided and puts new text in front of a bot that has
found a P1 in every new sentence (opus, fable). Or relax the one-shot promise outright, since recovery already
repeats other reads on the same counter (astra).
