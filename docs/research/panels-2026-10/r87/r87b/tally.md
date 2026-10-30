# Panel H r87b — Q1 pv-3zzo: O preferred 3–1; owner approval required

Pin: `3109b5b44eae17e288cf52aaa976993bd8c5626c`. This is the ONE consensus round.
**apply notes.md rule 6 exactly as written; this prompt adds no void rule.**

## Seats, final picks and conditions

The answers in `fable.md`, `opus.md`, `astra.md` and `sol.md` are substantive, complete,
and exit 0; their byte counts match the main handoff. `check/tally-output-audit.json`
records their hashes, actual exits, clean pinned reader clones, absent drafts and output checks.
The Codex stdout files match the answer files except for a trailing newline. Claude stderr is
empty; Codex stderr contains reading transcripts. Sol's malformed search returned exit 2 and
was followed by a corrected search; it is not a missing-seat or substantive-answer failure.
No usage-limit, login, timeout or empty answer is counted. Grok is missing, HTTP 402 at this
round's preflight and at main's 21:35Z one-word check. No fresh reader or Grok retry is launched.

| Reader | Explicit final pick | Strongest argument | Conditions and exact acceptability |
|---|---|---|---|
| Fable | **O** | Require immediate reported failure and deployment reinvocation without an undefined peer-status source or extra authority-response-shape wording. | A/B/D no; C/F/O yes. Moves from its own F to O. Accepts C as coherent but weaker; O needs no fix. |
| Opus | **F** | “as the authority returned it” identifies the diagnostic source and lets the fixture compare the reason with the actual refusal. | B/C/D no; F/O yes. A only with deletion of the peer field, so no acceptance for printed A. Treats credential exclusion as governing redaction. Withdraws C acceptance. |
| Astra | **O** | Keep immediate failure, successful-migration boundary and full fixtures with the smaller diagnostic obligation. | A/F/O yes; B/C/D no. A is additional integration work rather than inherently impossible. F accepted whole, without a fix. |
| Sol | **O** | Leave reinvocation with deployment; permit a faithful normalized refusal explanation without the extra reason-provenance wording. | A/F/O yes; B/C/D no. F accepted whole. Withdraws r87 B acceptance and its no-fixture-conflict claim. |

| Exact form | Unconditional ACCEPT | Conditional only | CANNOT ACCEPT | Final preference |
|---|---|---|---|---|
| A | Astra, Sol | Opus; does not count | Fable | none |
| B | none | none | Fable, Opus, Astra, Sol | none |
| C | Fable | none | Opus, Astra, Sol | none |
| D | none | none | Fable, Opus, Astra, Sol | none |
| F | Fable, Opus, Astra, Sol | none | none | Opus |
| O | Fable, Opus, Astra, Sol | none | none | Fable, Astra, Sol |

The explicit preference is **O 3–1 F**. F and O independently have **4–0 acceptability**.
Both printed forms meet rule 2's acceptance threshold; preserve the readers' explicit preference
for O rather than inventing a tie-break or collapsing them into A′. In particular, this is not
four final picks for O and is not a rejection of F. A is 2 unconditional accepts, one conditional
and one rejection; B 0–4, C 1–3, D 0–4. Requested no-change counterarguments are not D votes.
The owner's exact rule in notes.md rule 2 is “a question is settled when at least three agree and
more agree than disagree, and a tie comes to you. If grok is down, it falls back to three of four”.
O has three explicit final picks, unanimous acceptance and no verified blocking loss.

## Source and packet verification

`check/tally-source-verification.json` records comparison against `git show <pin>:<path>` using
an own reader clone. Every owning-context block in the brief, including OPS-47, is byte-identical
with its stated pinned line span. All complete form files occur verbatim in the brief, and every
embedded prior answer matches `prior/<seat>.md`. The pinned tracker row is open/needs-triage and
leaves the policy undecided. No live tracker was opened. The landing sites are those in
`brief.md`, “Complete exact alternatives”; the exact operative text remains `forms/q1-O.md`.
No newly merged main-checkout text has been substituted for the pin.

### Missing outcome and no-change counterargument

STO-55 at `05-persistence.md:285` includes “component pools, reconnects, rollout incarnations,
startup-lock holders, migrators and waiting runners” but its outcome clause at `:312` says
“Startup acquisition refusal exits for supervisor retry; `api` returns `overloaded` before any
transaction; worker/periodic acquisition refusal is an `OPS-49` store error”. STO-13 at `:1555`
places `migrate` “before any component of a release starts”. OPS-47 at
`03-operation-lifecycle.md:135` says “The engine MUST run as exactly one process under an external
supervisor that retries startup subject to `STO-55` admission”. This establishes the specified
engine supervisor, not an impossibility of deployment supervising a migration invocation.

The strongest requested argument for D is that initial migration acquisition is startup,
existing admission and schema checks preserve safety, and deployment tooling can select the
outcome. But an already-running runner that recorded a migration and then requests a replacement
connection is not plainly in startup. OPS-49 at `03-operation-lifecycle.md:1925` scopes its loop to
“a worker, or by a periodic component running in the engine process”. No quoted rule supplies
that migrator reconnect's result. Choosing to leave it unspecified is available to the owner;
it does not close the gap as fixed. All readers reject D as this bead's resolution.

### Full check of the F dissent and the F/O difference

The exact STO-55 diagnostic in O is:

> The diagnostic MUST identify `migrate`, the release being attempted, whether this was initial
> acquisition or reconnect, and the admission-refusal reason, without credentials.

F instead requires “the admission-refusal reason as the authority returned it, without
credentials.” The STO-13 and CNF-57 blocks are identical in F and O; every other STO-55 sentence
is identical. Both require “exit non-zero at once; it MUST NOT wait or retry admission internally”.

Opus's trace is executable: a controlled authority supplies a credential-free refusal reason;
the runner reports that reason; the harness compares its diagnostic with that response; the
runner exits without deliberate waiting. If the authority reason includes a credential, Opus
reads “without credentials” as requiring redaction, not raw disclosure. The pin neither defines
an authority reason format nor requires verbatim copying. STO-55 at `05-persistence.md:299`
says “The enforcement construction is the deployment's”. Thus F supplies a new provenance
obligation; its trace shows a possible implementation, not an existing source-format requirement.
O still requires the actual refusal reason and credential exclusion while permitting faithful
normalization. No existing verdict is lost by omitting the additional F wording. Opus expressly
accepts O without repair, so its preference is not a blocking dissent.

Opus also says it prefers F because “Fable already picked it”. That refers to the prior round:
current Fable explicitly moves to O. It cannot be counted as two current F final picks. Conversely,
Fable's undefined-response and credential observations are reasons to prefer O, not a proof that
F is impossible; Fable itself accepts F. Astra and Sol also accept F exactly.

### Other disputed claims and traces

- **A's peer-runner field:** let R1 crash after recording version V. Its grant stays charged:
  STO-55 at `05-persistence.md:290` says “Unknown bindings remain charged. Timeout, transport
  loss, process exit and rollout completion never release a grant.” R2 is refused before
  connection. That residual grant does not prove R1 is active or scheduled. STO-55's “Bind grants
  to component/attempt identity” prevents assuming the runner must mistake its own grant for a
  peer's. No pinned source supplies scheduling/liveness, but deployment could supply additional
  context. This supports the missing-source objection and Astra/Sol's narrower feasibility
  judgment, not categorical impossibility. O and F omit the field as printed, not by repair.
- **Fable's register argument is broader than its source:** OVR-19 at `00-overview.md:363`
  says “Every value the set says a deployment MUST state is listed here”. That does not prove
  every implementation-supplied transient schedule fact is a new registered parameter. A creates
  an information obligation but does not require a stated deployment value. Fable's additional
  unregistered-parameter reason is unproved; its O choice also rests on the verified undefined
  peer-source and narrower-diagnostic arguments. This reader overstatement is not a brief error.
- **C's timing trace:** refusal, deliberate arbitrary finite sleep, then nonzero exit satisfies
  its printed “exit non-zero for deployment retry” and exit assertion. C contains no “at once”
  or no-wait clause. Fable accepts that weaker contract; the other readers do not accept it as
  the complete timing answer. No pinned safety requirement is thereby proven lost. Opus's new
  claim that C's release-boundary fixture is stronger than its rule depends on interpreting
  STO-13's “MUST be applied” and “run ... before any component” as insufficient for successful
  completion. Preserve that as its reading, not a demonstrated base contradiction. O removes
  the ambiguity with its explicit new successful-completion MUST NOT.
- **B's full conflict:** first refusal at t=0 starts a ten-second episode; verified capacity
  release at t=9.9 occurs during backoff or an unanswered authority call; no reservation is
  confirmed by t=10. B's rule says “If no confirmed reservation is obtained before the bound
  expires, `migrate` MUST report exhaustion and exit non-zero”. Its success fixture instead
  demands, “with verified capacity release before expiry”, “continuation without first exiting”.
  Capacity release does not ensure timely acquisition; no cadence or response bound excludes
  the trace. The new rule and new assertion demand different outcomes. All current readers
  reject printed B; Sol explicitly withdraws its prior acceptance. No repaired fixture is counted.
  B's “confirmed usable reservation” versus exclusion of “connection checks after a grant” is
  also ambiguous: STO-7 at `05-persistence.md:194` says a failed check is “a failed connection
  attempt: the connection is closed unused”. Reading “usable” as an admission grant may reconcile
  those phrases; an endlessly restarted episode is not established as the only reading.
- **Promptness measurement:** Fable and Opus suggest observing a single admission request.
  One request followed by deliberate sleep would still satisfy that observation. Astra and Sol
  correctly require actual observation/instrumentation of the no-internal-wait path as well as
  calls and exit. O's fixture explicitly says “at once, without an internal admission wait/retry”.
  It supplies no numerical end-to-end latency promise, initial authority-response deadline or
  bound on total rollout progress. No implementation fixture has been executed in this tally.

## Reachability, retained protections and three change dimensions

The complete cases under O are those in `forms/q1-O.md`'s CNF-57 block, not a manager synthesis:

- First acquisition: a denied physical attempt makes no dial or SQL, reports the selected fields
  and exits immediately; it records no migration completion.
- Second runner: an independently admitted runner holds the migration key while the other is
  refused before connection. A separately admitted pair exercises the SQL-lock wait instead.
  STO-12 at `05-persistence.md:1534` requires a key “distinct from `STO-51`'s” across “inspecting
  the history, applying a migration and recording its completion”; CNF-57 at
  `10-conformance-checklist.md:370` retains “the engine's startup lock is untouched”.
- Reconnect: after V is recorded and transport fails, the replacement denial causes exit without
  erasing V. A later deployment invocation after evidenced release obtains a fresh reservation
  and resumes through history inspection; the fixture rejects reapplying completed V.
- Capacity exhaustion: charged reservations occupy C while adequate admitted previous-release
  sessions remain and the required standby is available. STO-55 at `05-persistence.md:308`
  permits “Existing admitted sessions may continue”; the new fixture requires actual engine and
  `api` writes to succeed. No-progress migration admission and continuing old service coexist.

STO-55 at `05-persistence.md:285` requires a “distinct durable reservation before dialing”;
its release rule at `:301` requires “fencing every delayed arrival/retry and fresh privileged
direct-primary evidence, read in a fresh transaction, that the bound backend ended”. Exit or
transport loss is not release evidence. O preserves both rules and requires retained residual
charges in its fixtures. OVR-18 at `00-overview.md:350` says “Admission exhaustion and accounting
loss MUST be alarmed”; the amendment adds no replacement alarm or reserve-release shortcut.

STO-7 at `05-persistence.md:178` says, “short of its process exiting”, a deadline or cancellation
“MUST NOT release its connection before the reply arrives or the transport is found dead”.
STO-55 at `:315` retains “No individual `SyncRep` backend may be cancelled or terminated to make
room”. O adds no sent-COMMIT or standby deadline and no backend eviction. STO-13 at `:1587`
retains “MUST stop every component of the previous release before the first component of the new
one starts”, and its backfill at `:1598` retains “only then permit the first new-release component
to start”. The concurrent-safe fixture qualification preserves those exceptions and does not
permit restarting an already-stopped exceptional release.

| Dimension | Exact O against the pin |
|---|---|
| Behavior | Immediate diagnostic failure after received refusal; no internal wait/retry; a later invocation is deployment retry. |
| Normative requirement | New reporting/no-wait MUSTs in STO-55; new explicit deployment MUST NOT start before successful migration completion in STO-13. |
| Check strength | Independent refusal fixtures, actual previous-release writes, history/reservation checks and admitted-lock-wait control added to CNF-57. Existing assertions remain. |

All dimensions are substantive. The launch approval is not approval of this policy. No existing
obligation or checked verdict was verified removed, unreachable or vacuous. Inspection of
`Migration.lean`, `Restore.lean:migrateCreate/claimed_legacy_create_stays_unresolved` and
`Witnesses.lean:legacy_create_failed_without_backfill` confirms migration-shape and backfill
population properties, not admission-refusal outcomes. The pin has no STO-55-tagged Lean
declaration; no formal statement, guard, witness or rendered region changes. Gates check the
specification artifacts, not whether a running migrator passes these future CNF-57 fixtures.

## Rule 6 and next step

No verified brief error changes the missing-outcome premise. **The tally is not void.**
The packet's source quotations, exact alternatives and prior-answer transfers were checked.
Its listed defects are explicitly matters to review, not assertions that all candidates pass.
No motivating claim in r87b was broken. Reader overstatements and corrected r87 reasons are
reported above with the affected reader; they do not expand rule 6 into a candidate-defect void rule.

**Next: main asks the owner to approve exact O as recommended**, preserving the explicit O 3–1 F
preference and both 4–0 acceptability sets. The question is in `owner-questions.md`. F remains a
separately reviewed acceptable alternative. No further round, synthesis, adoption, tracker update,
ready-for-agent transition, implementation or PR is authorized by this tally. Main records the
owner's decision before a later authorized application. The complete form and landing sites remain
`forms/q1-O.md` and `brief.md`, “Complete exact alternatives”. No new identifier, parameter, ADR
or formal change is in O.

Before/final gate receipts for this tally are recorded in STATE.md after completion. They run the
required full unpiped Nix command at the pinned baseline in the isolated `check/tally-spec/` clone;
they are not a claim of applied O or runtime conformance. Main checkout, protected panel folders,
pgharness, manager brief and all pre-existing units remain untouched.
