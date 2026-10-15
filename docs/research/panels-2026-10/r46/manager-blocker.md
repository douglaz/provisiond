STATUS: blocked

Round 1 review of `5acc2522211ef621a25e1fa3d5da63692864cefa..96a09aa17464d9b9fc1a7f170352e8d1a8749156`: FAIL. An owner clarification is needed before another implementation brief. The settled Q27/Q28 decisions are not reopened.

## Owner clarification: what instant does rescue `boot_time` denote?

`02-provider-contract.md`, `PRV-19`, now accepts the record's pins “only when its `boot_time` is strictly later than this session's reset.” ADR-0041's Decision says “A record from an earlier boot is never used.” Neither supplies the interpretation of Robot's offset-less timestamp or its ambiguous local-time case.

The evidence is `docs/research/panels-2026-10/r45/live-session3.txt`: reset at `2026-10-12T17:16:40Z`, port 22 open at `17:18:07Z`, and the read at `17:18:10Z` returns `boot_time: "2026-10-12 19:17:49"`. This fits Berlin summer time; interpreting it as UTC places the alleged boot after the read. A similarly misparsed earlier record can pass the new-reset comparison.

`PRV-13` says “Robot dates in `Europe/Berlin`,” but its paragraph and the cited r40 experiment concern cancellation dates. That evidence cannot silently settle every timestamp field. In particular, the October sample does not decide how to handle a repeated local hour.

The behavioural readings that need a decision are:

- Extend the Berlin interpretation to rescue `boot_time`, resolve an ambiguous local timestamp to a selected occurrence, and compare that instant with reset. The selection can make the record eligible.
- Require unambiguous evidence of ordering; an offset-less value with unresolved interpretations supplies no current-boot pins, so the session continues waiting and can expire at the existing deadline.

Concrete boundary: Berlin `2026-10-25 02:30:00` can denote `00:30Z` or `01:30Z`. With reset at `01:00Z`, the former is stale and the latter is later. This is a choice about accepting a session's pins, not merely a parser-library choice. I verified those conversions locally with `zoneinfo`; no provider call was made.

**Recommended clarification, not an adopted rule:** explicitly name `Europe/Berlin` for rescue `boot_time`; require the driver to establish a unique instant or otherwise unambiguous later-than-reset ordering, and withhold pins when that cannot be established. Continue within the existing rescue deadline and fail closed if it remains unresolved. Add a local-time stale-record fixture and an ambiguous-hour fixture to `CNF-355` once the owner chooses. The owner should confirm both the field's zone and the permitted ambiguity treatment.

Opus and Sol identified this gap. I accept it as an owner question, but reject Opus's claim that the cancellation-date rule already settles it without an owner decision. No adviser consultation was run: advisers cannot clarify the specification owner's behaviour choice, and no next-brief implementation choice was settled here. All Panel files contain substantive reviews; none is `REVIEWER FAILED` or `REVIEWER NOT RUN`.

## Confirmed repairs recorded in pv-wd0's notes

- **Incorrect new formal predicate.** `tools/formal/Provisiond/Rescue.lean`, `Trust.permitsPresented`, returns true for both `permitsPresented false [⟨1⟩] [] false ⟨2⟩` and `permitsPresented false [] [⟨1⟩] false ⟨2⟩`. I independently proved both expressions equal true using Lean through stdin, exit 0. `RSC-3`'s corresponding rows say “Pin exactly those. Strict checking.” and “Pin the driver's. Strict checking.” This is an identity-membership defect in a new tagged declaration, not a demand to model SHA256 or SSH. Correct the predicate or restrict its formal contract to the additional provider-required check; add mismatch regressions without inventing the pre-existing unspecified choice of pin set when caller and provider sets overlap. Astra's finding is accepted.
- **Stale alarm conformance.** `CNF-283` still demands “an account/channel identifying monitorable alarm” in its local-closure case, without the request path. `PRV-5` now says “every Robot `403 RATE_LIMIT_EXCEEDED` MUST raise a monitorable alarm naming the provider account and request path,” while `PRV-40` says that alarm “may include the ordering channel.” Align this older item with the single alarm owner and preserve its closure/queued-create checks. The updated sibling `CNF-344` does not remove the inconsistent obligation in `CNF-283`. Fable's and Opus's finding is accepted.

No new beads were created. These repairs and the owner question are in the existing ticket's notes. The task was already closed by the Implementer. Option A instructs closing the tracker task even when the Run blocks, so it remains closed; its Manager notes explicitly state that the work is **not accepted as complete**. The earlier completion reason is not the Manager's verdict.

## Other feedback disposition

Opus's engine-conditional finding is not established: prose naming Robot does not require a provider branch in the engine, and the session already carries whether provider pins are required/awaited. The new Lean wrapper consumes that flag. Capitalizing the indicative/lowercase statements would improve drafting but does not establish a second behaviour against the explicit current-pin rule. I am not requiring new interface machinery.

The both-supplied pin-set question was already explicitly outside the model; Q27 adds the requirement to match a current provider pin. Requiring intersection membership beyond the existing overlap check would settle an additional policy, so that suggestion is not imposed. The incorrect ordinary-session predicate above is independent of this omission.

The instruction to record repeated activation as applying to the next boot came from the caller's work list and brief. Sparse captures do not authorize reopening that decision. Likewise, the attachment-endpoint suggestion must not replace Q28's explicitly chosen `/ip` and `/subnet` scope with new API work. The protocol-format details can be handled by the driver within SHA256 pin matching; no new public input or cryptographic machinery is requested. `CNF-339`'s comparison with the old window need not require booting a conforming deployment with an invalid configuration; it can accompany the startup refusal and predicate-level boundary check.

Cosmetic observations, recorded once and dropped: the verification record's duplicated counts and unquoted paraphrases; the Rescue model's omission comment; clearer `use_provider_keys` wording; naming the intervening delivery sample; narrower deployed-installer inspection wording; the removed “opportunistically” qualifier; uppercase normative drafting and amendment-note placement; and restoring the generic abort note in the diagram. These are not new issues or reasons for another round under the caller's cosmetic-finding rule.

Fable reports using `/var/tmp/pvwd0-review-rehearsal`, contrary to this Run's repository-only scratch restriction, and reports deleting it. I did not inspect or modify that external path and do not treat that run as evidence of compliance with the scratch restriction. There are no `rejected-*` artifacts in the Run directory. The Implementer output reports completion rather than failure; its repository-local rehearsal is documented in `docs/verification/pv-wd0-2026-10-12.md`. I reviewed that record and the changed controls, but did not repeat the full mutation campaign.

## History, verification and tree

The Implementer committed the specification, conformance, formal, CI and evidence changes as `96a09aa17464d9b9fc1a7f170352e8d1a8749156`. Much of the requested work is present, including delayed fingerprint pinning, cancellation without the pre-read, the shared alarm owner, two-sweep validation and its old-policy negative control, attachment endpoint rules and dated live observations. The defects above prevent whole-change acceptance. That commit was already in history before this review; I neither rewrote nor squashed it and made no specification or code fixes.

I committed only the accepted Manager review notes in `.beads/issues.jsonl` as `da3e268f8d50642d56d26296e28ecccec70374dc` (`pv-wd0: record blocked review and remaining defects`).

- Base: `5acc2522211ef621a25e1fa3d5da63692864cefa`.
- Current HEAD: `da3e268f8d50642d56d26296e28ecccec70374dc`.
- Both Manager runs of `nix develop --command bash tools/check-all.sh`, UNPIPED, exited 0, including the final run after the tracker commit. Passing gates do not resolve the missing timestamp policy or refute the demonstrated predicate defect.
- `git diff --check` passed. The tracked tree is clean; no untracked work is awaiting commit. This ignored `finished.md` is the only Run artifact written by the Manager this round. Existing ignored rloop/build artifacts remain; no Manager scratch repository was created.

Next action belongs to the owner: clarify rescue timestamp interpretation and ambiguous ordering. Then resume pv-wd0 with that decision and the confirmed repairs above; do not interpret the tracker closure or green specification gates as approval to ship this revision.
