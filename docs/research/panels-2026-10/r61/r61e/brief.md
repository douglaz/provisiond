# Panel brief r61e: pv-6p8, the `name` field only. 2026-10-22

You are one of four independent reviewers. Your working directory is a throwaway clone of the
specification repository `provisiond-spec` at `4c0bb4c` (master). Read `AGENTS.md` first. You MAY edit tracked
files in this clone to test a claim. Write nothing outside it (never `/tmp` or `/var/tmp`), and never commit,
push or call a provider API. Read nothing outside this clone except toolchain files. Gates are optional. If you
edit, run `nix develop --command bash tools/check-all.sh` unpiped, redirect it to a file in the clone, and read
its exit code. Keep `TMPDIR` as set. Do not delegate, background or wait on anything. Have a draft answer by
minute 15. Check every fact below with grep before you rely on it: the manager has been wrong in briefs before.
**Answer in at most 250 words.**

## Why this round

Bead pv-6p8 asks what `rescue_inventory` returns for a disk with no serial and no WWN. Everything is settled
except one item: whether each inventory device carries a separate `name` field. Round r61d split 2-2 on it. The
owner was offered both options and answered: **"Try to get a consensus"**.

So this round is not a re-vote. It asks what you can live with.

## Settled (off-limits)

- Each device carries `identifier`, `wwn` and `serial`, each the string as read, trimmed of ASCII whitespace,
  `null` where `RSC-46`'s normalization leaves nothing. `identifier` is `wwn` if non-null, else `serial`, else
  `null`.
- **Owner decision:** `RSC-33` gains WWN under either option below.
- `RSC-46`'s hashed element stays exactly `{wwn, serial, size_bytes}`. Neither `path` nor a `name` enters the
  fingerprint under either option.
- Everything else in pv-6p8: normalization, sort order, admission, `RSC-23` scope, qualifiers, `CNF-363`.

## Premises from r61d that were wrong

- The r61d brief said "`RSC-33` names both". At `4c0bb4c` it does not: it has no WWN. Adding it is the owner's
  pending amendment (fable caught this).
- The r61d brief said that under (a) "the wire meets it word for word". It doesn't. `RSC-33` says "size" and
  `WIR-10b` says `size_bytes` (opus caught this).
- The r61d brief said that under (a) "`RSC-33` stays as it is". Under (a) `RSC-33` also gains WWN.

## The two options, as exact text

`RSC-33` today reads: "report — at minimum the block-device inventory (name, path, size, type, model, serial)
and whether the firmware is UEFI —".

**Option (a): add `name`.**
- `RSC-33`'s list becomes "(name, path, size, type, model, serial, WWN)".
- `WIR-10b`: every device carries `name`, a JSON string: the device's name as the rescue environment reports it.
  The first example device reads (the values of the settled fields are illustrative):
  `{"identifier": "S4EVNF0N123456", "name": "nvme0n1", "path": "/dev/nvme0n1", "size_bytes": 1024209543168,
  "model": "SAMSUNG MZVL21T0HCLR", "type": "nvme", "wwn": null, "serial": "S4EVNF0N123456"}`
- `CNF-363` asserts that every device carries `name`. It also asserts that changing only names leaves the
  fingerprint unchanged.

**Option (b): no `name`.**
- `RSC-33`'s list becomes "(path, size, type, model, serial, WWN)".
- `WIR-10b`: the same device without `name`:
  `{"identifier": "S4EVNF0N123456", "path": "/dev/nvme0n1", "size_bytes": 1024209543168,
  "model": "SAMSUNG MZVL21T0HCLR", "type": "nvme", "wwn": null, "serial": "S4EVNF0N123456"}`
- `CNF-363` asserts nothing about `name`.

## Governing sentences (verbatim, at `4c0bb4c`)

- `RSC-33` (`06-rescue-install.md`): "Before writing anything, the engine MUST collect a machine-readable
  inventory report — at minimum the block-device inventory (name, path, size, type, model, serial) and whether
  the firmware is UEFI — and MUST attach it to the operation result. This is the record that tells an operator
  afterwards which disk was actually overwritten."
- `RSC-26`, heading: "naming a device is not enough, because the name is not stable."
- `RSC-26`: "But `/dev/sda` is an ordering artefact that can differ across boots, between the rescue
  environment and the installed system, and after any hardware change".
- `RSC-26`: "`RSC-22`'s installer layout carries a `drives` list, and those are device names with exactly the
  same instability".
- `RSC-26`: "The identifier is authoritative; the path is derived."
- `RSC-46`: "device paths are excluded, because they are the unstable part."
- `WIR-10b` (`13-wire-contract.md`), the device today: `{"identifier": "S4EVNF0N123456", "path":
  "/dev/nvme0n1", "size_bytes": 1024209543168, "model": "SAMSUNG MZVL21T0HCLR", "type": "nvme"}`.
- `WIR-2`: "Responses are the opposite of bodies: **clients MUST ignore unknown response fields**, so the
  server can add fields without a version bump."

## Each reader's r61d argument on `name`, verbatim

**fable (b):** "The edit is free: `RSC-33` must be amended to name WWN, and dropping `name` rides along. Nothing
in the set reads a device `name`. `WIR-20` takes an identifier, `RSC-27` validates the resolved path, and
`RSC-46` excludes paths "because they are the unstable part". A `name` is a second copy of that unstable part.
`RSC-33`'s purpose is "the record that tells an operator afterwards which disk was actually overwritten", and
path, serial and WWN are that record."

**opus (b):** "Two of (a)'s premises don't hold. `RSC-33` lists "(name, path, size, type, model, serial)" and
has no WWN, so the settled WWN decision means `RSC-33` gets edited either way. `WIR-10b` uses `size_bytes`, not
"size", so the wire doesn't match `RSC-33` word for word even now. `RSC-26` says "the name is not stable …
`/dev/sda` is an ordering artefact", and that quote is about a path. A `name` field would just be a second copy
of that unstable value. Nothing in `tools/formal/`, the checklist or `CONTEXT.md` quotes the six fields."

**astra (a):** "Keep `name`. `RSC-33` calls the report “the record that tells an operator afterwards which disk
was actually overwritten.” An observed name remains useful diagnostic evidence despite being unsuitable for
identity. Adding the missing field preserves that reporting obligation."

**sol (a):** "`RSC-33` requires “(name, path, size, type, model, serial)”. Preserve that reporting contract.
`RSC-26`’s “an ordering artefact” explains why names cannot select disks; it does not justify removing observed
names from diagnostic reports."

## Questions

1. **Acceptability grid.** Mark each option ACCEPT or CANNOT ACCEPT, as written above. ACCEPT means you would
   sign off on it landing as written, even if you prefer the other. For each CANNOT ACCEPT, quote the exact
   clause or consequence that blocks it. Then name your preference in one word.
2. **Your side's weakest point.** The weakest point in the case for the option you preferred in r61d.
3. **A form all four could accept.** If one exists that differs from (a) and (b) as written, give it as exact
   spec wording: the `RSC-33` list, and the `WIR-10b` device or sentence if it changes. Otherwise write "none".
