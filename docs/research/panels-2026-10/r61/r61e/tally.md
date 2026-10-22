# r61e tally: pv-6p8 `name` (2026-10-22)

All four exits 0; answers in {fable,opus,astra,sol}.md. No tracked edits in any clone (opus left an untracked
draft and a beads migration-state file).

| Reader | (a) add `name` | (b) no `name` | Preference | New form |
|---|---|---|---|---|
| fable | ACCEPT | ACCEPT | (b) | fable-c |
| opus | ACCEPT | ACCEPT | (b) | opus-c |
| astra | ACCEPT | ACCEPT | (a) | none |
| sol | ACCEPT | ACCEPT | (a) | sol-MAY ("my acceptance of (b) does not depend on adopting it") |

Both (a) and (b) are accepted by all four; preference still 2-2. So no single form yet -> r61f asks for one
landing pick.

## New forms (verbatim, unreviewed)

**fable-c:** `RSC-33`: "…the block-device inventory (path, size, type, model, serial, WWN) and whether the
firmware is UEFI — and MUST attach it to the operation result. The path is the device's name as the rescue
environment reported it at that reading, under `RSC-27`'s device directory: diagnostic record, not identity
(`RSC-26`)." `WIR-10b` device and `CNF-363`: exactly as in (b).

**opus-c:** `RSC-33` list: "(name, path, size, type, model, serial, WWN)", the same as (a). `WIR-10b` device:
the same as (b). `WIR-10b` gets one sentence after the example: "A device's `path` reports both `RSC-33`'s name
and its path, the device as the rescue environment names it, and `size_bytes` reports its size; the path selects
nothing (`RSC-26`: "The identifier is authoritative; the path is derived.")." `CNF-363` asserts nothing about
`name`.

**sol-MAY:** `RSC-33` list: "(path, size, type, model, serial, WWN)". `WIR-10b` uses option (b)'s device and
adds: "Each device MAY additionally carry `name`, a JSON string containing the device's name as the rescue
environment reports it."

## Facts checked

- fable: "`CNF-363` does not exist yet" — true (no match at 4c0bb4c). Lean `Device` is `identifier` + `path`
  only — true (`Rescue.lean`). "`model` appears only in `RSC-33` and `WIR-10b`; `type` likewise" — true apart
  from `CONTEXT.md:434`, which mentions a disk's `model` field only to tell it apart from the formal model.
  `RSC-27` "a simple path under the device directory" — verbatim.
- opus: `RSC-26` "those are device names with exactly the same instability — a rootfs install that partitions
  `/dev/sda`" — verbatim (06-rescue-install.md:278-279).

## Gate check of the new wordings (scratch clones /var/tmp/provisiond-panel-r61e/gate/{fable,opus})

`python3 tools/check_citations.py` exits 0 on fable-c and on opus-c (index.jsonl copied from the main repo).
A planted misquote in opus-c's `RSC-26` quote went red (exit 1). Only the citation gate was run.

## Next: r61f (/var/tmp/provisiond-panel-r61f/brief.md), launched 2026-10-22

Q1 grid on fable-c / opus-c / sol-MAY; Q2 one landing pick. Outcome rules, fixed before it ran:
- all four pick the same form -> consensus; update final-form.md (header, item 4 incl. Lands on, 12.6, 12.9),
  reviewed r61d/r61e/r61f.
- picks split -> no r61g; drop any form with a CANNOT; report in three lines (forms all four accept, how picks
  split, the tie needs the owner's one-word pick between reviewed forms, no technical blocker either way).

## r61f result (all exits 0): consensus on (b)

| Reader | fable-c | opus-c | sol-MAY | Land |
|---|---|---|---|---|
| fable | ACCEPT | CANNOT | CANNOT | (b) |
| opus | CANNOT | ACCEPT | CANNOT | (b) |
| astra | ACCEPT | ACCEPT | ACCEPT | (b) |
| sol | ACCEPT | ACCEPT | ACCEPT | (b) |

Verified: AGENTS.md:45 "every sentence asserting what another requirement says carries its quote" (opus);
last CNF item is CNF-362 (fable). fable's "every reader's own weakest-point statement concedes `name` adds
nothing beyond `path`" overstates: only astra and sol conceded that; fable and opus conceded "nothing reads
`name`" proves nothing. final-form.md item 4, header, 12.6, 12.9 updated.
