# Panel H r87 — Q1 pv-3zzo: no settlement; one consensus round

Pin: `3109b5b44eae17e288cf52aaa976993bd8c5626c`. Source verification used
`check/spec/` and the detached reader clones, never the occupied main checkout.
**apply notes.md rule 6 exactly as written; this prompt adds no void rule.**

## Seats and exact tally

All four returned substantive complete answers and actual exit 0. Byte counts and hashes,
stderr/transcript audit and stdout comparison are in `check/tally-output-audit.json`.
The Codex stdout files equal their answer files apart from the last newline; stderr contains
the reading transcripts, not an additional vote. No draft answer or usage-limit answer was found.
Grok is missing: 402 at launch, still 402 at main's 21:17Z check; no Grok vote.

| Reader | Final pick | Strongest argument | Conditions / exact acceptance |
|---|---|---|---|
| Fable | Its exact A′, labelled F in r87b | Keep immediate diagnostic failure and deployment retry, but do not require a refused runner to know whether a peer is active or scheduled. | A no; B no; C yes; D no. F yes; O unread. Accepts C despite acknowledging its pre-exit delay gap. F uniquely requires the reason “as the authority returned it”. |
| Opus | C | State nonzero exit for deployment retry with the fewest new obligations; peer-runner status is not supplied by the present contract. | A no; B no; C yes; D no. Its own A′, O, yes but not preferred; F unread. C may pause before exit; Opus reads “for deployment retry” as assigning retry externally. |
| Astra | A | Explicit immediate exit, no internal wait/retry, diagnostic and release boundary make the policy distinguishable; C permits arbitrary finite delay. | A yes; B/C/D no; F/O unread. Rejects B's release-before-expiry success fixture because capacity availability does not ensure timely reservation confirmation. Treats A's context field as extra implementation work rather than inherently impossible. |
| Sol | A | Immediate diagnostic failure leaves deployment in charge; C lacks a prohibition on pre-exit delay, whereas B adds a parameter and internal wait. | A/B yes; C/D no; F/O unread. Accepts printed B, including its recovery fixture, which Astra's traced counterexample challenges. |

Explicit preferences: A 2 (Astra, Sol), C 1 (Opus), F 1 (Fable).
Exact printed acceptability: A 2–2; B 1–3; C 2–2; D 0–4. F has only its author's acceptance,
and O only its author's; the other seats did not review either whole alternative as a candidate.
F and O differ, so they are not a pooled A′ vote. The owner's rule in notes.md rule 2 requires
“at least three agree and more agree than disagree” and, with Grok down, “three of four”.
No exact form qualifies. Requested no-change counterarguments are not votes for D.

## Verified facts and full disputed traces

The nine source blocks printed in the brief match the pin byte for byte; the comparison and
line ranges are in `check/tally-output-audit.json`. All reader clones remained tracked-clean
at the pin. The following checks cover the reasons each vote rests on, including both minority
positions; no numerical majority is being accepted over an unchecked dissent.

1. **The migration-outcome premise survives.** STO-55 (`05-persistence.md:285`) includes
   “component pools, reconnects, rollout incarnations, startup-lock holders, migrators and waiting
   runners” among physical attempts, but its outcome clause (`:312`) says “Startup acquisition
   refusal exits for supervisor retry; `api` returns `overloaded` before any transaction;
   worker/periodic acquisition refusal is an `OPS-49` store error”. STO-13 (`:1555`) places the
   entry point “before any component of a release starts”. OPS-47 (`03-operation-lifecycle.md:135`)
   quotes the startup clause for “The engine” under “an external supervisor that retries startup
   subject to `STO-55` admission”. That supports the ambiguity; it does not prove a deployment
   cannot choose to supervise a migrator. Fable's “The migrator has no supervisor” is stronger
   than the demonstrated absence of a specified migrator supervisor. No quoted rule explicitly
   assigns an outcome to the already-running migrator's refused reconnect. OPS-49's subject is
   “a worker, or by a periodic component running in the engine process” (`:1926`), so exporting
   its loop is unsupported. The owner did not select an outcome by approving this panel.
2. **Fable/Opus diagnostic trace, checked in full.** Runner R1 records a version, loses its
   transport or crashes, and its grant remains charged. STO-55 (`05-persistence.md:290`) says
   “Unknown bindings remain charged. Timeout, transport loss, process exit and rollout completion
   never release a grant.” R2 is refused before connection and cannot inspect the migration key
   through that refused connection. A/B nevertheless require its diagnostic to identify “whether
   another migration runner is active or scheduled”, and their new fixtures assert that diagnostic.
   A retained grant alone does not establish liveness or scheduling. The pin specifies no source
   for that status; its actual allowance is “The enforcement construction is the deployment's”
   (`:299`), and grants bind to “component/attempt identity” (`:289`). Thus the missing-information
   objection is supported, but categorical impossibility is not proved: an implementation could
   supply additional deployment context. Fable's suggestion that its own residual grant must be
   mistaken for another live runner is not entailed by identity-bound accounting. Astra's and
   Sol's acceptance cannot be rewritten as acceptance of removing the field. F/O independently
   remove it and retain all of A's other blocks, but their reason wording differs.
3. **C timing trace, checked in full.** Receive refusal, remain alive for an arbitrarily long
   finite interval without making progress, then exit nonzero. C's exact “exit non-zero for
   deployment retry” and fixture “Assert each refused runner exits non-zero for deployment retry”
   supply neither A's “at once; it MUST NOT wait or retry admission internally” nor B's bound.
   The finite-delay trace is not expressly rejected. This supports Astra/Sol and the qualification
   in Fable/Opus. Whether “for deployment retry” itself excludes internal retries is a textual
   disagreement; do not silently import A's words. Fable's owner-question sentence “Both exit at
   once” overstates C and conflicts with its own earlier qualification. Opus's claim that C/A′
   needs no owner is inapplicable: the current owner instruction expressly reserves behavior,
   requirement and check-strength choices for owner approval, even a settled no-change choice.
4. **Astra's B trace, checked in full.** Let the bound be ten seconds. The first refusal starts
   the episode. Capacity is released at 9.9 seconds while a later request is in backoff or awaiting
   a response. At ten seconds no reservation is confirmed. B's rule says “If no confirmed
   reservation is obtained before the bound expires, `migrate` MUST report exhaustion and exit
   non-zero”; its success fixture says “with verified capacity release before expiry” to assert
   “continuation without first exiting”. Capacity becoming available is not confirmation.
   Neither B nor the pin guarantees a response time or a cadence eliminating this trace. The
   literal fixture is therefore stronger than the rule's success condition. Sol's “no candidate
   contradicting its own fixture” is not sustained for B. This does not negate the bounded-retry
   policy itself, and an unprinted fixture repair is not a vote for B. Fable/Opus's additional
   “confirmed usable reservation” question is a real wording ambiguity: STO-7 (`:194–196`) calls
   a failed new-connection check “a failed connection attempt: the connection is closed unused”,
   while B excludes “transport or connection checks after a grant”. Whether the reservation
   already ended that episode needs an explicit reading, rather than assuming failed-unused
   checks restart a bound. The confirmed-acquisition fixture defect suffices independently.
5. **Other execution and accounting cases remain reachable.** The denied first or replacement
   attempt has no authorized dial. STO-55 (`:285`) requires a “distinct durable reservation before
   dialing”; a denial need not allocate one, and earlier uncertain/residual charges must remain.
   For the second runner, denial precedes connection and hence precedes requesting the SQL key;
   the separately admitted pair instead exercises STO-12's key “distinct from `STO-51`'s” (`:1534`).
   After one recorded version and a refused reconnect, STO-12 holds the key across “inspecting
   the history, applying a migration and recording its completion” (`:1535`), so the later invocation
   can skip that version without undoing it. With capacity C occupied by reservations and adequate
   live previous-release sessions retained, STO-55 permits “Existing admitted sessions may continue”
   (`:308`); with a standby available, the fixtures can assert successful engine/api writes while
   migration admission is denied. Fencing and “fresh privileged direct-primary evidence” (`:301`)
   are still necessary for release; runner exit or leaving SyncRep does not provide them.

## Protection and strength check

A and F/O insert new immediate-outcome/report obligations, an explicit STO-13 successful-completion
boundary and independent CNF-57 fixtures. They are substantive additions. B additionally selects
in-process waiting and a validated positive finite OVR-19 parameter. C preserves the original
refusal block verbatim around its added migration sentence, adds a pointer and adds independent
CNF-57 fixtures; even that smaller package selects a requirement and check strength. D changes
nothing and intentionally leaves the ambiguity if no broader startup reading is adopted.

No existing checked verdict or quoted obligation was verified lost, unreachable or vacuous.
STO-7's sent-COMMIT protection remains: “short of its process exiting” its connection “MUST NOT”
be released before reply or dead transport (`05-persistence.md:178`). Its separate prohibition
on cancelling a SyncRep backend remains; A/F/O introduce no standby deadline, and B excludes
that wait. STO-13's shared-predicate rule still says “MUST stop every component of the previous
release before the first component of the new one starts” (`:1587`), and its backfill says “only
then permit the first new-release component to start” (`:1598`). The new previous-service tests
explicitly use a concurrent-safe release; existing exceptional cases are retained. CNF-57's
“Then the concurrent index step” and backfill assertions are not replaced by any option.

Textual inspection of the complete Migration.lean, Restore.lean's `migrateCreate` and
`claimed_legacy_create_stays_unresolved`, and Witnesses.lean's backfill witness confirms the
shape/population scope reported by the readers; they do not model admission-refusal outcomes.
No `@[req "STO-55"]` declaration was found. No formal statement or guard change is proposed.
The flush-left packet blocks require the existing STO-55/CNF-57 continuation indentation at
landing; that mechanical detail changes no vote. Gates do not execute these runtime fixtures.

## Rule 6, broken brief claims and next step

No verified brief error changes the missing-outcome premise. **The tally is not void.**
A/B's peer-status diagnostic problem is disputed feasibility of a proposed new obligation;
B's verified rule/fixture mismatch is a defect of one alternative. Report both with the votes
whose reasons depend on them, as above. The brief explicitly asked whether B was complete
enough, so it did not assert that this alternative had already passed. Its framing that the
pinned set lacks an explicit migration-refusal outcome and that no formal clause changes survived.
Do not expand notes.md rule 6 into “any candidate defect voids the question”.

No settled form is owner-ready or ready-for-agent. notes.md rule 4 and the owner's “If there are
ties, try to run the panel once more focusing on reaching consensus” require ONE r87b round.
`r87b/brief.md` gives every reader all prior answers verbatim and complete A/B/C/D/F/O forms,
the exact disputes and the pinned source context. A valid surviving split after r87b goes to main/the
owner, with no additional consensus round; any verified rule-6 error goes to main for
the corrected re-ask required by that rule. Any settled form there, including D, becomes an owner-approval question with
that exact form recommended. No source, tracker, branch, main checkout or other panel is amended.

Gate evidence for this tally turn: the first before-gate unit exited 127 because its supplied
PATH omitted Nix; `check/gate-tally-before.log` preserves that failure. The corrected full-PATH
run exited 0 with all gates, including Lean, passing (`check/gate-tally-before-retry.*`).
Final gate and launch receipts are appended to STATE.md after they complete.


## r87b launch complete

2026-10-30T21:29:47Z: launch exit 0; four required reader units active/running with
all caps, null stdin, own clones, correct models and npm-global-first PATH verified.
Fresh quota: Claude session 58%, all-models week 67%, Fable 93% exempt; Codex WEEK 1%.
Grok one-word probe again 402/missing. Packet 118460 bytes, below split threshold.
Single consistency pass found a conditional conflict in the blanket no-follow-on-round
wording; repaired the launch boundary while preserving rule 6 verbatim and its required
corrected re-ask. No exact candidate or prior answer changed. No second pass.
Final full unpiped gate exited 0/all gates PASS including Lean (check/gate-tally-final.*).
Return to main immediately; wait command and complete launch receipts in r87b/STATE.md.


## r87b tally completed — owner approval required

2026-10-30T21:43:27.566436+00:00: Q1 pv-3zzo exact O has final picks Fable/Astra/Sol; Opus picks F and
accepts O. Explicit preference O 3–1 F; F and O separately accepted by all four.
A has two unconditional accepts plus Opus conditional only; B 0–4, C 1–3, D 0–4.
All outputs substantive/exit 0; Grok missing, 402 (main 21:35Z check included).
No verified premise-changing brief error; rule 6 does not void the tally. B's verified
new-rule/new-fixture conflict is reported, with Sol's prior acceptance withdrawn.
No blocking loss under O; behavior, requirement and CNF-57 check-strength changes are
substantive. Exact O is recommended for OWNER APPROVAL, never auto-adopted.
The single consensus round is exhausted; no further round launched. Main asks one
question in [r87b/owner-questions.md](r87b/owner-questions.md), with O recommended,
F as Opus's reviewed acceptable alternative and D as intentional no change.
Full tally, per-reader conditions and source/packet audits: [r87b/tally.md](r87b/tally.md)
and r87b/check/tally-*.json. Main checkout/tracker/branches, other panels, pgharness
and pre-existing units untouched. Final baseline gate receipt follows in r87b/STATE.md.


Final r87b tally verification: before/final full unpiped Nix baseline gates actual exits 0/0,
all gates PASS including Lean. Reader/form hashes unchanged and all own clones tracked-clean.
No job remains. Main asks r87b/owner-questions.md; exact O recommended pending owner approval.
