# Panel brief r60: pv-1wn, can CNF-202's suspended-create case be set up? 2026-10-21

You are one of four independent reviewers. Your working directory is a throwaway clone of the
specification repository `provisiond-spec` at `9088148`, on branch `pv-1wn`. The branch is pv-1wn's change, one review
fix and one new bead. Read `AGENTS.md` first. `br show pv-1wn` prints the bead; its "## Agent Brief" comment is the
contract the change implemented. `br show pv-gvc` prints a bead the review filed. `git diff cbb3693..9088148 --
'*.md'` shows the change. You MAY edit tracked files in this clone to test a claim. Write nothing outside it (never
`/tmp` or `/var/tmp`), and never commit, push or call a provider API. Read nothing outside this clone except
toolchain files. The gates exit 0 at `9088148`: `nix develop --command bash tools/check-all.sh`, a few minutes. Run
it unpiped, redirect it to a file in the clone, and read its exit code. Keep `TMPDIR` as set. Do not delegate,
background or wait on anything: do the work yourself in this session. Have a draft answer by minute 30. Check every
fact below with grep before you rely on it: the manager has been wrong in briefs before. Read text by requirement id,
not by line number. **Answer in at most 450 words.**

## Settled (off-limits)

- The owner approved pv-1wn: `CNF-202` gains a case for `API-58` step (4), and its assertions quote `API-58`.
- `API-58` step (4)'s rule. Caller work that is "`queued` but never claimed" when the fan-out reaches it goes
  straight to `failed`, with `conflict` and `details.reason: "tenant_suspended"`. Its `requested_by` stays `caller`
  and its `system_reason` stays null. Don't argue for changing that rule.

## The story

A tenant queues a create. An operator then suspends the tenant. `API-58` says "The flag and the enqueue of the parent
commit together at admission; the fan-out is the worker's". So after the `202`, `API-7` step 5b refuses any new
tenant write, and the `suspend_tenant` parent sits in the queue behind the create. `OPS-6` says "The claim MUST select
the oldest `queued` operation whose availability time has passed". The create is older and has no machine, so
`OPS-8`'s per-machine index never refuses its claim. The manager's claim: a worker claims the create first, and it is
dispatched (`OPS-43`). Once its machine attaches, `OPS-27`'s suspended-attach clause cancels it. The parent's step (4)
then finds no queued, never-claimed create. If so, the case at `9088148` describes a state that a conforming engine
can't be put into.

The manager's proposed route around it: put a caller's machine-scoped operation (for example a power operation)
behind a `running` operation on the same machine. `OPS-8`: "A claim (`OPS-5`) that the index refuses because another
running operation holds the machine MUST return the operation to `queued` with a short delay". `OPS-6`: "A claim the
per-machine index refuses (`OPS-8`) never left `queued` and does not advance the number". `operations.claim_number`
is "default 0 for never claimed" (`05-persistence.md`). A worker then claims the newer parent, and step (4) fails the
power operation. `API-58` step (4) covers "the tenant's own work", not only creates.

The manager's draft bead (not filed) asks whether a caller's create on a suspended tenant should be guaranteed never
to reach a provider. Two example fixes: re-check suspension at claim, or move step (4) into the admission transaction
the way `API-63` does for a terminated account. Or is dispatch followed by `OPS-27`'s cancellation the intended
outcome?

## Questions

1. On a conforming engine, can a test reach `CNF-202`'s case as written: a caller's create still `queued` and never
   claimed when the fan-out reaches it? Trace `OPS-6`, `OPS-8`, `OPS-24`, `API-7` step 5b, `API-58`, `STO-3`'s
   step-(4) write, `OPS-43` and `OPS-27`. Name any route you find, such as an admission race, a defer, the definition
   of "oldest", or a test-harness hold the checklist already uses elsewhere. Say whether a test can produce it
   deterministically.
2. Is the power-operation route real? Quote both sides of any tension between `OPS-8`'s "return the operation to
   `queued`" and `OPS-6`'s "never left `queued`". Does such an operation count as "never claimed"? Do the case's
   three `API-58` quotes still apply to it? What catches are there (step (3)'s cancellation also queued behind the
   held operation, or when the parent settles)?
3. Pick one, and give your strongest argument:
   - (a) swap the fixture to the power operation and file the reachability bead;
   - (b) keep the create as approved and file the bead;
   - (c) park pv-1wn behind the bead;
   - (d) a shape none of these is.
4. Is the create-reachability question a real spec gap, or does some requirement or ADR already settle it? If it's
   settled, quote the settling text. Does `API-58` step (2), `SEC-45` or `OPS-27` make "dispatch, then cancel" the
   intended outcome?
5. Make your pick's edit to `10-conformance-checklist.md` in your clone and run the gates. Then plant the plausible
   bad edit for your pick, run the gates again, and report whether anything goes red, and what. If nothing does, say
   what would catch it.
6. Labelled as written on request: the strongest argument against your own pick.
