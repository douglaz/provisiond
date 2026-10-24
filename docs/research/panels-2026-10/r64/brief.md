# Panel brief r64 (panel D): a lost startup-lock connection during a stop's record, and the write-started marker on the last row — pv-buc, pv-9j6. 2026-10-23

You are one of four independent reviewers. Your working directory is a throwaway clone of the specification
repository `provisiond-spec` at `b90783d` (master). Read `AGENTS.md` first. `br show pv-buc pv-9j6` prints the
two beads (if `br` fails, `.beads/issues.jsonl` holds them). You MAY edit tracked files in this clone to test a
claim. Write nothing outside it (never `/tmp` or `/var/tmp`). Never commit, push or call a provider API. **Run no
gate and no `lake` this round**: the host takes at most two Lean builds at once, and the manager builds the chosen
form afterwards. Keep `TMPDIR` as set. Do not delegate, background or wait on anything: do the work yourself in
this session. Have a draft answer by minute 25. A web lookup is allowed only to cite a PostgreSQL primary source
(postgresql.org documentation), and you must quote what you cite.

Every quote below was grepped at `b90783d`. The manager has still been wrong in briefs before, so **before you
vote, check each "why it matters" claim the brief makes**, and any fact you rely on, and report each error under
"Brief errors". Read text by requirement id, not by line number.

## The gate (how a CANNOT ACCEPT counts)

A CANNOT ACCEPT must name a loss that changes a checked verdict: a `CNF` assertion or a Lean theorem that the
form flips, makes unreachable or makes vacuous (give its id or theorem name), or a MUST/SHOULD (file and
requirement id) together with a trace that breaks it. A CANNOT ACCEPT that names none is recorded but does not
block. Wording you dislike is an AMEND, not a CANNOT ACCEPT.

## Settled (off-limits)

- `OPS-47`/`STO-51`/`ADR-0019`: "**The lock is not a fence**: no write is guarded on it, holding it proves
  nothing about the past, and losing it invalidates nothing already written." No option may guard a write on the
  lock. `OPS-47`'s supervisor posture ("The engine MUST run as exactly one process under an external supervisor
  that restarts it and never runs two") stands.
- `OPS-21`'s Stop-record bound, its expiry exit, the later-stop exit, the Store-retry exhaustion exit and the
  supervisor's wait stand as written, except where a draft below adds to them.
- `STO-54`'s promotion procedure as PR #23 left it, and `ADR-0045`'s "A sent COMMIT is never abandoned", stand.
- `OPS-45`'s marker table, and `OPS-11`'s ambiguity conditions and acceptance amendment (`ADR-0035`), stand.
  `CNF-362`'s post-dispatch assertions stand.

## Governing text (verbatim)

pv-buc:
- `OPS-47`: "Before any claim the engine MUST take `STO-51`'s session-scoped advisory lock on a connection
  outside the pool and hold it for its lifetime. Where the lock is refused it MUST retry for the stated bound
  (`OVR-19`) and then exit non-zero having done no work; where the connection carrying it is lost it MUST exit."
  Then: "It answers one question, once, at boot — is somebody else already here — and a refusal is a
  misconfigured deployment, which is how two engines actually happen."
- `ADR-0019` restates it: "where the connection carrying it is lost it MUST exit. The bound and the keepalive
  settings on that connection are deployment parameters (`OVR-19`)." It gives no reason for the exit.
  `00-overview.md`'s parameter table lists "Startup-lock connection keepalives | `OPS-47` | durations".
- `OPS-21`: "A cancellation of `execute` that the engine survives MUST be recorded before the engine exits, for
  every operation kind, subject to the bounded abandonment and later-stop exits below." The later stop: "A later
  stop, one arriving after the stop being recorded and before that record lands, ends the record as an exit
  without worker classification at any point: before the record's first transaction, during it, or while `OPS-49`
  repeats it; the worker MUST NOT repeat a record transaction already sent when that later stop arrives." Expiry:
  "On expiry the worker MUST abandon the record, and the engine MUST log loudly, naming every operation whose
  record it did not see land, and exit." "The deployment's supervisor MUST wait at least the Stop-record bound
  after a stop before it kills the engine. A kill before the record lands is a crash."
- `OPS-21`, after `execute` returns: "A stop the engine survives that arrives after `execute` returns and before
  the worker's settle write lands MUST be recorded by that settle write, under the shielding below, and the
  Stop-record bound and exits that apply to a recorded cancellation." "The settle write that records a stop after
  `execute` returns MUST NOT be cancelled or abandoned by that stop." "The Stop-record bound and its expiry exit,
  the later-stop exit, the Store-retry bound's exhaustion exit, the lost-reply case and the supervisor's wait
  apply to the record of a stop after `execute` returns as they do to a recorded cancellation".
- `OPS-49`: "**A worker cancelled during the retry loop stops retrying and exits.**"
- New since the bead (PR #23): `05-persistence.md`, `ADR-0045`: "**A sent COMMIT is never abandoned** ... short
  of its process exiting, a deadline or a cancellation of the request or worker that sent it MUST NOT release its
  connection before the reply arrives or the transport is found dead." And `STO-54`'s promotion: "Before any
  component connects to the promoted store, the deployment MUST stop every engine and `api` process that was
  connected to the old primary".
- `STO-56`: "The startup read above is taken once per process".

pv-9j6:
- `OPS-45`'s scope: "**This requirement governs the kinds that act on a machine that already exists — install,
  rescue inventory, power, reverse DNS, delete and release attachment (`PRV-45`) — and nothing else.**" Marker
  row: "| power, reverse DNS, delete, release attachment | the provider call is dispatched |".
- `OPS-45`'s settlement: "**An operation settles `failed` — deterministically, with no operator and no
  reconciliation — when the write-started marker is unset *and* either no rescue session was opened or the one
  that was opened was closed without error.**" ... "This rule classifies a failure a worker recorded" ...
  "Everything else follows `OPS-11`'s classification".
- `OPS-11`'s last row: "| power, reverse-DNS, delete, release attachment | `needs_reconciliation` if the failure
  is *ambiguous*, otherwise `failed`. ..." Ambiguous includes "the error kind is `network`, `timeout`, or
  `internal`" and "the error kind is `conflict` *and* it arose from the worker being cut off mid-flight (`OPS-21`)".
- `OPS-21`: "The other classification pointers are `OPS-11`'s install row, ..., rescue inventory's "Same rows as
  `install`", and refresh's "Always `failed`". The kind's row owns the outcome, including where it reads ambiguity.
  Where the row reads `OPS-45`'s markers, the record MUST classify against the markers its own transaction reads".
- `05-persistence.md`, `write_started_at`: "Null means the mutation provably did not begin, and with the column
  below makes the failure deterministic rather than ambiguous (`OPS-11`)"; the next row says "(`OPS-45`, which
  owns the rule)".
- `CNF-362`: "power, reverse DNS, delete and release attachment stopped during their provider call after
  dispatch, other than a delete's direct read after an accepted dated cancellation, enter `needs_reconciliation`."
  "Make no assertion about `retryable` for the other cases."
- `Tables.lean` `classify`: "`| .power | .deleteMachine | .releaseAttachment => some (if goalState r f then
  .succeeded else mutationRow r f)`", "`| .reverseDns => some (mutationRow r f)`"; the create arm is "`if
  r.preStep9Rule && f.beforeStep9 && !f.accepted then .failed else mutationRow r f`". No last-row arm reads
  `Markers`.
- `theorem accepted_never_failed`: "`∀ (goal marker s : Bool) (k : Kind) (e : ErrorKind) (c : Bool) (u :
  Upstream) (g b w x : Bool), k.lastRow = true → classify ⟨goal, marker, true, s⟩ k ⟨e, c, u, g, true, b⟩ ⟨w, x⟩ ≠
  some .failed`".
- Precedent, `docs/research/panels-2026-10/r58/synthesis.md`: "**pv-9j6:** decide separately, 4-0. It survives
  every option, because a recorded pre-dispatch `timeout` or" `internal` shows the same disagreement.

## Facts the manager checked

- No sentence governs a stop's record when `OPS-47`'s lock connection drops. Lock loss is not among `OPS-21`'s
  listed exits, so `OPS-47`'s "MUST exit" and `OPS-21`'s "MUST be recorded before the engine exits" leave the
  order to the engine. No `CNF` item drives a lost lock connection: `CNF-290` drives a *refused* lock, `CNF-362`
  no lock loss. `StopRecord.lean`'s `Event` is `store | serialization | laterStop`.
- `OPS-11`'s last row reads no marker. `OPS-45` says a pre-dispatch failure of those four kinds is `failed`;
  `OPS-11` and `classify` say a cut-off `conflict` or an `internal` there is `needs_reconciliation`.
- `CNF-31b` asserts a last-row pre-send `network` failure is `needs_reconciliation`. The marker is written
  before dispatch, so that case is unaffected by Q2's A. `CNF-362` asserts nothing for those four kinds stopped
  *before* dispatch, which is Q2's story.
- `Rescue.lean`'s `governs` returns true for all six kinds.
- Next free ids: `CNF-366`, `ADR-0046`.

## Questions

For each, answer **ACCEPT A**, **AMEND A** (give the exact replacement text and say "behaviour unchanged" or
"behaviour changed"), or **CANNOT ACCEPT A** (name the option you pick, or give your own form), under the gate
above. Then list the ids your pick touches and label the question **mechanics** or **owner** (a scope or product
call), with one line of reason. **At most 150 words per question**, not counting drafted text. Drafted citations
that hold a straight-quoted value use curly outer marks (“…”).

**Q1 (pv-buc): when the lock connection drops while a stop's record is pending, does the engine exit at once or
record first?**
A concrete case, in two variants. A deploy stops the engine. A create's `execute` has returned success, and its
settle write is repeating under `OPS-49`. Then the lock connection drops.
- (a) An in-place PostgreSQL restart or a network blip: no further stop follows. Engine X exits at once: the row
  stays `running`, `OPS-15` parks it at the next start, and the correlator resolves it. Engine Y keeps repeating,
  lands the write within the Stop-record bound once the store is back, settles `succeeded`, then exits.
- (b) A failover: `STO-54`'s "the deployment MUST stop every engine" arrives while the record is pending. The
  manager reads that stop as a *later stop* under `OPS-21`, which already "ends the record as an exit". **Verify
  this.** If it holds, PR #23 narrows the gap to (a) rather than making it routine.

Draft A (lock loss is a listed exit):
- `OPS-21` gains, after the later-stop sentence: "A loss of the connection carrying `OPS-47`'s startup lock ends
  the record the same way, as an exit without worker classification at any point: before the record's first
  transaction, during it, or while `OPS-49` repeats it; the worker MUST NOT repeat a record transaction already
  sent when the loss is seen, and a row still `running` goes to restart recovery as after a crash." The
  after-return list ("The Stop-record bound and its expiry exit, the later-stop exit, ...") gains "the lock-loss
  exit".
- `StopRecord.lean` gains `Event.lockLost` with an exit theorem beside `later_stop_exits`, or `laterStop` is
  documented as covering it (say which).
- `CNF-362` gains the case, or a new `CNF-366` does: drop the lock connection during a cancellation's record and
  during an after-return settle write; assert the engine exits, writes no worker classification, and the next
  start's `OPS-15` classifies the `running` row.

Alternatives:
- B (lock loss is a stop of every worker): `OPS-47`'s clause becomes "where the connection carrying it is lost,
  the engine MUST claim nothing more, treat the loss as a stop of every worker, record each under `OPS-21`
  within the Stop-record bound and its exits, and then exit." If you pick B, say whether its record write can
  reach the promoted store before `STO-54`'s "Before any component connects to the promoted store", and whether
  `ADR-0045`'s "short of its process exiting" changes anything.
- C (delete the clause): delete "where the connection carrying it is lost it MUST exit" from `OPS-47` and its
  restatement in `ADR-0019`. A lost lock connection then changes nothing. C must say what happens to the
  "Startup-lock connection keepalives" parameter, which exists only to detect that loss.

**Whatever you pick, answer this openly: what does `OPS-47`'s "where the connection carrying it is lost it MUST
exit" protect?** `ADR-0019` gives no reason. Name the requirement or trace that fails without it, or say nothing
does. (Unverified candidates from the manager's notes, listed after the question so they do not anchor it:
`STO-56`'s "once per process" record read; the boot check staying true for the process's lifetime, since the
lock is held "for its lifetime".)

Q1b: does your pick also govern a lock loss with **no** stop, while workers are in `execute`? Under A the engine
exits at once (a crash for each of them, `OPS-15`); under B each is cancelled and records a cut-off `conflict`.
Say which you intend and whether the text says it.

**Q2 (pv-9j6): a power, reverse-DNS, delete or release-attachment failure the worker records before dispatch:
`OPS-45`'s `failed`, or `OPS-11`'s `needs_reconciliation`?**
A concrete case: a stop cuts a delete off before its provider call is dispatched; the worker records a cut-off
`conflict`, with `write_started_at` null and no rescue session. `OPS-45` says `failed`; `OPS-11`'s last row
and `classify` say `needs_reconciliation`, and an operator resolves a delete the provider never saw. A second
case: a pre-dispatch `internal` (the driver fails while building the request).
Draft A (`OPS-45` governs):
- `OPS-11`'s last row becomes: "`needs_reconciliation` if the failure is *ambiguous*, otherwise `failed`; and
  `failed`, whatever its kind, for any failure the worker records while `OPS-45`'s write-started marker is
  unset." The goal-state success rule keeps precedence.
- `OPS-21`'s pointer list gains the last row's marker clause. Its sentence "Where the row reads `OPS-45`'s
  markers, the record MUST classify against the markers its own transaction reads" then reaches the four kinds.
- `Tables.lean`: the power/delete/release arm becomes "goalState first, then `r.markerRule && !m.writeStarted &&
  m.rescueClean && !f.accepted` → `.failed`, else `mutationRow r f`"; the `reverseDns` arm gains the same marker
  test before `mutationRow`. **The `!f.accepted` guard is required:** `accepted_never_failed` quantifies over every
  marker pair `⟨w, x⟩` with `accepted = true`, so an unguarded arm returns `failed` at `w = false` and the theorem
  fails. The create arm guards the same way.
- `CNF-31b` and `CNF-362` gain: for each of the four kinds, a recorded pre-dispatch cut-off `conflict` and a
  recorded pre-dispatch `internal`, marker unset, settle `failed`. Say whether `CNF-31a` changes.

Alternatives:
- B (the deletion form, `OPS-11` governs): `OPS-45`'s settlement and `05-persistence.md`'s "makes the failure
  deterministic rather than ambiguous" narrow to install and rescue inventory. For the four kinds the marker stays
  as resolution evidence (`PRV-29`/`PRV-36`). Say whether `Rescue.lean`'s `governs` then needs narrowing.
- D (an add-on to A or B): delete `05-persistence.md`'s restatement "and with the column below makes the failure
  deterministic rather than ambiguous (`OPS-11`)", leaving `OPS-45` the only owner.

Also say: (i) does the last row's prose need an explicit not-accepted guard, or can it rely on a pre-dispatch
failure being unable to carry acceptance (`PRV-5`)? (ii) Does A need a `retryable` rule for the new `failed`
cases (the create row pins `retryable: true`; `CNF-362` says "Make no assertion about `retryable` for the other
cases"; `WIR-9b` owns precedence)?

**Q3.** Should pv-buc and pv-9j6 land in one Run? Answer in one line.

**Against my picks (written on request).** For each question, give the strongest argument against your own pick,
in at most 60 words, labelled as written on request.

**Brief errors.** List any fact above that is wrong, with the grep that shows it.

**Total answer: at most 900 words.**
