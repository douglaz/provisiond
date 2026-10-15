# Panel brief: telling a fresh Robot last-rescue record from a stale one (Q29), 2026-10-12

You are one of four independent reviewers. The working directory is a throwaway clone of the
specification repository `provisiond-spec` at `da3e268` (branch `robot-live-2026-10-12`; pv-wd0 round 1
applied). Read `AGENTS.md` first. Do not edit tracked files; write scratch files only inside this clone
(never `/tmp`); you may run the gates (`nix develop --command bash tools/check-all.sh`, unpiped). Search the
Markdown with whitespace normalised. This owner repeatedly shows my framing wrong with a first-principles
question and dissolves machinery rather than tuning it; check this framing too, and verify every fact I
state.

## Context

ADR-0041 (read it whole) pins Robot rescue host keys from `GET /boot/{server-number}/rescue/last` after
boot, "only when the record's `boot_time` is later than the session's reset"; no keys in time fails
closed. An rloop Manager blocked ticket pv-wd0 on what instant that offset-less `boot_time` denotes
(`docs/research/panels-2026-10/r46/manager-blocker.md`, first section): the live sample
(`docs/research/panels-2026-10/r45/live-session3.txt`: reset 17:16:40Z, read 17:18:10Z,
`"boot_time": "2026-10-12 19:17:49"`) fits Europe/Berlin summer time, but the Berlin evidence (r40) is for
cancellation dates; and on the October clock change Berlin 02:00-03:00 repeats (02:30 = 00:30Z or 01:30Z).

Live facts (r45): before any rescue the last-rescue read answered `404`; the activation response and
`GET /boot/{n}/rescue` carry `host_key: []` before and after boot; activation is consumed at boot
(`active` false within 30 s); the last-rescue record listed SHA256 fingerprints and `boot_time` by the
time port 22 opened (~60 s after reset); every rescue boot generates fresh host keys.

## Options

(a) The Manager's: name Europe/Berlin for `boot_time`; establish a unique instant later than the reset;
an ambiguous local hour withholds the pins until the rescue deadline (fail closed).
(b) Proposed (owner leans to it): no time interpretation. Read the last-rescue record just BEFORE the
reset; after the reset accept only a record whose `boot_time` DIFFERS from that pre-reset value (any
record when the pre-reset read answered `404`); a failed pre-reset read is retried, else fail closed.
(Variant: compare the fingerprint set instead of, or as well as, `boot_time`, since keys are fresh per boot.)

## Questions

1. Is (b) sound? Find the traces where it accepts a stale record or rejects a fresh one: two boots with
   equal `boot_time` strings (second resolution); a rescue boot by someone else between the pre-read and
   ours (the account's other users, Robot's own actions); the record updating late, after an intermediate
   value; an activation that does not boot (reset fails); our own retried reset; the 404 case when a
   previous rescue happened but the record expired. Is `boot_time`, the fingerprints, or both the right
   change detector?
2. Where does the pre-reset read sit in `PRV-15`/`PRV-19` and the session state (it must survive a crash
   between read and reset — or does a crash already fail the session)? What does `PRV-20` ("MUST NOT clear an
   already-known host key set") imply?
3. Does (b) leave anything for (a) (e.g. diagnostics), or does (a) become unnecessary? Strongest "don't build".
4. Exact edits (ADR-0041 amendment, `PRV-19`, CNF-355, Lean `Rescue` if it models freshness), and whether the
   Manager's two confirmed repairs (`Trust.permitsPresented`; `CNF-283`'s alarm) interact.

## Output

At most 700 words, no preamble: a one-line verdict; why; every defect with `file:line`; the edits.
