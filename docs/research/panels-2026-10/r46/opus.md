**Verdict:** adopt (b), with three changes: compare `boot_time` as a plain string, take the baseline read *before activation*, and require at least one fingerprint. Drop (a).

**Why.** `PRV-20` refuses a presented key that matches no current pin, so pinning a stale record ends in `integrity`. It can only fail open for someone holding that boot's private host key, which means someone who had root on that rescue. Both (a) and (b) reject every record that already exists when the baseline is read. A record that appears later and isn't ours can only come from someone holding the account credential, or from Hetzner. Those are "Explicitly *not* defended against" (`07-security-requirements.md:21`). (a) doesn't stop them either: a credential holder who activates and resets after our boot produces a `boot_time` later than our reset. Each bad trace under (b) fails closed:

- **Equal strings:** two boots of one server are at least ~70 s apart. Their strings can match only in October's repeated hour, to the second, and then the session runs to its deadline.
- **Someone else's boot between baseline and reset:** our reset reboots their rescue, or their boot used up our activation and our reset boots the installed OS. Either way the presented key mismatches and the session fails `integrity`.
- **Intermediate record, or a reset that never boots:** an empty key list or a null `boot_time` is never accepted. A new `boot_time` with old keys has never been observed, and it would fail closed.
- **Our own retried reset:** `SEC-27` says "Ambiguous mutations MUST NOT be retried automatically". A new begin-rescue reads a new baseline.
- **404 despite history:** server-market server 3086901 answered 404 before our first rescue, so 404 is the normal first case.

**Change detector: `boot_time`, not fingerprints.** "Every rescue boot generates fresh keys" rests on one boot each of two different servers (3088292, 3086901); no server was rescued twice. If keys are fixed per server, a fingerprint test fails every repeat rescue. A `boot_time` string comparison works either way. Requiring both to change inherits the fingerprint failure.

**Where the read sits.** Put the baseline read next to `PRV-15`'s existing `GET /boot/{n}/rescue`, before activation. A failure there comes before anything has changed on the server, so there is nothing for `PRV-18` to deactivate and no new retry rule is needed. A crash needs no handling: `DOM-11` says "MUST NOT be persisted", `RSC-19` says "An engine crash persists nothing", and recovery activates again, which reads a new baseline. `PRV-20`'s "MUST NOT clear" stops accepted pins from being emptied.

**Left for (a):** nothing normative; just log the raw `boot_time`.

**Defects**
- `01-domain-model.md:253-256`: the session's fields include no reset instant, yet `02-provider-contract.md:692` compares against "this session's reset".
- `ADR-0041:21` and `08-provider-notes.md:129` say the pre-boot record describes the earlier session. That was never observed; the only pre-boot read returned 404.
- `ADR-0041:17-18`, `08:129` and the brief say "about sixty seconds". Port 22 opened at +87 s, the record was first read at +90 s, and `active: false` was first read at +44 s, not "within 30 s".
- Robot's `/server` read answers `404 SERVER_NOT_FOUND` (`live-session2.txt`), but the error code of the last-rescue 404 wasn't captured. Only a no-record 404 should count as an empty baseline; mark that `[verify]`.

**Edits**
- `PRV-15`, Robot amendment (`02:662`), append: "Before activating, it MUST read `GET /boot/{n}/rescue/last` and keep its `boot_time` (none on a no-record 404) as the session's baseline; any other failure fails begin rescue before activation."
- `PRV-19` (`02:691-694`): replace "only when its `boot_time` … awaiting keys." with "only when the record lists at least one fingerprint and a present `boot_time` string that differs from the baseline (`PRV-15`), compared verbatim, never as an instant. Otherwise the session remains awaiting keys."
- `DOM-11` (`01:256`): "an opaque cleanup token, opaque driver refresh state, and an optional expiry". It stays opaque because of `RSC-2`.
- `ADR-0041`:
  - Add a dated Q29 amendment to Decision bullet 2.
  - Reject (a): `boot_time` has no offset, the October hour repeats, and it guards nothing the baseline doesn't.
  - At `:42`, change "without checking `boot_time`" to "without a freshness check".
  - Mark the unobserved facts `[verify]`.
- `CNF-355` (`10:3561-3563`): replace the `boot_time` clause with these cases:
  - After a no-record baseline, accept the first non-empty record.
  - Keep waiting when the baseline record R0 is served again after the reset.
  - Keep waiting on fingerprints with `boot_time: null`.
  - Accept a record R1 whose `boot_time` differs from R0's even though it is earlier than the reset.
  - A failed baseline read sends no activation.
  - A throttled baseline read raises `PRV-5`'s alarm.
- Lean: nothing is tagged `@[req "PRV-19"]`, and `Rescue.lean:24-26` and `:105-106` are only comments. In the `permitsPresented` repair, change "boot-time comparison" to "baseline comparison". Don't model the rule.
- Interaction with the Manager's two repairs: none. The `permitsPresented` defect is about matching the caller's keys, which comes after deciding which provider keys are accepted. For `CNF-283`, the baseline read adds one more `/boot` path that can raise `PRV-5`'s alarm; cite `PRV-5` rather than restating it.

`check-all.sh` ran unpiped and exited 0; I edited nothing.
