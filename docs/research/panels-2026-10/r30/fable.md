**Verdict:** (1) is right that null means "no observation held", but it keeps one piece of machinery too many: make `source`/`observed_at` the provenance of the *positive* only, null exactly when `status` is `unknown`, and retire r24's "else last read". The Manager's trace then has nothing left to decide.

**Why.** No reader of provenance on `unknown` exists, and none may. `DOM-27`'s consumer is the agent: "The signal's job is to **stop** a remediation loop" (01:350). A stop fires on positive evidence; `unknown` is the no-stop case whatever its provenance. `ADR-0038` deleted `none` because "no source can support the negative" (lines 30–31). So an agent handed `unknown`/`provider_api`/five-minutes-ago must act exactly as on `unknown`/null/null, and any reader that branched on the difference would be reading `none`. r24's "else last read" (synthesis.md:56) renders that `none` by another name on every unrestricted Hetzner machine, which is `WIR-11`'s old `{"status": "none", "source": "provider_api"}` (13:322) with one word changed. The operator "is never refused" (ADR D3), so records without consulting it. `WIR-11`/`WIR-43` render and do not branch. `CNF-250` tests one fixture. The time is not lost: the view already carries `state_observed_at`, "when `state` was last established by an authoritative read of the provider" (05:278), and `PRV-35` reads the flag on "the same path ... as every other machine field" (02:864–865). Whether a driver has a signal at all is `PRV-35`'s table, a per-driver fact, not per-machine data.

"Never looked" vs "looked, withdrawn" has no reader either. Withdrawal history is audit; the ADR already declined to surface even a forgotten record (r24 synthesis.md:33–34) and gave follow-up an owner outside this system via `operator_ref` (ADR line 41). Option (2) retains history for nobody.

Item 3 is bigger, not smaller. "Latest observation of either kind" needs the operator column to survive its own clear and renders `unknown`/`operator_notice`/t2, a value the operator never asserted: they withdrew a record; they did not observe the network clear. The unlock is the provider's act, and the ADR says no source supports the negative.

**Render table.** Rule: `restricted` carries the positive's source and time (`provider_api` where both); `unknown` carries null/null. Total by construction, since `restricted` always has a positive.

| State | status | source | observed_at | r24/(1) differs? |
|---|---|---|---|---|
| never read, no record (fresh; DigitalOcean forever) | unknown | null | null | no |
| provider clear, no record | unknown | null | null | yes: `provider_api`, T |
| provider set, no record | restricted | provider_api | provider time | no |
| operator record only | restricted | operator_notice | recorded time | no |
| both positive | restricted | provider_api | provider time | no |
| withdrawn, never read (the Manager's trace) | unknown | null | null | no; `CNF-250`'s gloss is false either way |
| withdrawn, provider clear | unknown | null | null | yes: `provider_api`, T |
| withdrawn, provider set | restricted | provider_api | provider time | no |

Cost accepted: the view no longer shows that a flag was ever read. Nothing reads that.

**Defects in the framing.**

- `docs/research/panels-2026-10/r24/fable.md:7` (mine) and `synthesis.md:58`, carried into pv-ucs.7: "`CNF-250` holds unchanged" was false the moment `operator_recorded_at` became clearable. "null means no record" is not "nobody has looked". The Manager is right, and right to refuse to reword a universal silently.
- The brief's item 2 treats "a clear read is `unknown`/`provider_api` with a time" as settled. `ADR-0038` D2 (lines 36–37) defines `source`/`observed_at` for the positive only: "Its `source` is the positive one ... and its `observed_at` is that source's." The `unknown` rendering is r24's edit list, not the ADR, and is open.
- The Manager framed it as "a specification behavior decision". The ticket's own render rule already answers its trace (no positive, no record, no reading: nothing renders); the clash was the ticket's "`CNF-250` unchanged" instruction.
- The universal has four homes: 10:2522 (`CNF-250`), 13:1217 (`WIR-47`), 10:2846 (`CNF-233`), 05:272–273. One rule, one home.
- `manager-blocker.md` says its lines are the current checkout but cites 10:2445 and 05:270–271; at 843a2f2 they are 10:2522 and 05:272–273. Content correct.
- "Lean: none" holds only if withdraw is the same route. `Verb.recordNetworkRestriction` (`tools/formal/Provisiond/Admission.lean:139`) is matched in eight places under "No wildcard, so a verb added without a listener is a missing case" (line 161). A new withdraw route adds a constructor to all eight.

**Edits.**

- `WIR-47` (13:1216–1217): "`source` and `observed_at` are the positive observation's: the provider's set reading (`provider_api`, its time), else the operator's record (`operator_notice`, when recorded). Both are null exactly when `status` is `unknown`." Delete "where nobody has looked". Withdraw is the same route with `{"status": "unknown", "operator_ref": ...}` (r23 opus.md:14's shape), clearing `operator_recorded_at` only; route table and Lean gain nothing.
- `CNF-250` (10:2522): "`source` and `observed_at` are null exactly when `status` is `unknown`", quoting `WIR-47`; keep the fresh-machine fixture; add that a clear reading and a withdrawn record each render the same object.
- `CNF-233` (10:2845–2848): drop the 409; the four r24 sequences; add the Manager's trace and "withdraw, then clear reading", both rendering the fixture.
- `CNF-228` (10:2839): `restricted` from either source, each with its own time.
- `05-persistence.md` 272–273: r24's three columns; `provider_observed_at` "null where the driver has never read a signal" as 05:278 is phrased; `operator_recorded_at` "null where no record is held; cleared by a withdrawal". No rendering sentence here.
- `WIR-11` (13:322): `{"status": "unknown", "source": null, "observed_at": null}`, not r24's `"source": "provider_api"`. `WIR-43` fixture gains the same object.
- `DOM-27` (01:334–335): "a status (`restricted` | `unknown`) and, where restricted, the source and time", citing 05's columns.
- `ADR-0038`: dated note under D2: "Where neither is positive the view carries no source and no time: a clear reading is the negative no source can support, and `state_observed_at` already dates the provider's last read."
- pv-ucs.7: replace "`CNF-250` unchanged" and "else last reading". Lean: none.

Gates at 843a2f2, unpiped: all passed, exit 0. Answer also at `docs/research/panels-2026-10/r30/fable-answer.md`.
