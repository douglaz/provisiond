# Panel brief r61f: pv-6p8, the `name` field — one landing pick. 2026-10-22

You are one of four independent reviewers. Your working directory is a throwaway clone of the
specification repository `provisiond-spec` at `4c0bb4c` (master). Read `AGENTS.md` first. You MAY edit tracked
files in this clone to test a claim. Write nothing outside it (never `/tmp` or `/var/tmp`), and never commit,
push or call a provider API. Read nothing outside this clone except toolchain files. Gates are optional. If you
edit, run `nix develop --command bash tools/check-all.sh` unpiped, redirect it to a file in the clone, and read
its exit code. Keep `TMPDIR` as set. Do not delegate, background or wait on anything. Have a draft answer by
minute 10. Check every fact below with grep before you rely on it. **Answer in at most 150 words.**

## Where this stands

Bead pv-6p8: everything is settled except whether each rescue-inventory device carries a separate `name`. The
owner asked: **"Try to get a consensus"**. Settled and off-limits: `RSC-33` gains WWN under every form;
`RSC-46` hashes exactly `{wwn, serial, size_bytes}`, so neither `path` nor `name` enters the fingerprint.

**r61e result:** all four readers marked both (a) and (b) ACCEPT. Preferences stayed 2-2: fable (b), opus (b),
astra (a), sol (a). Three readers proposed new forms. An acceptance grid can't choose between two forms everyone
accepts, so this round asks for one landing pick.

## The five forms, as exact text

`RSC-33` today: "Before writing anything, the engine MUST collect a machine-readable inventory report — at
minimum the block-device inventory (name, path, size, type, model, serial) and whether the firmware is UEFI —
and MUST attach it to the operation result. This is the record that tells an operator afterwards which disk was
actually overwritten."

**(a) add `name`** (r61e: 4 ACCEPT).
- `RSC-33`'s list: "(name, path, size, type, model, serial, WWN)".
- `WIR-10b`: every device carries `name`, a JSON string: the device's name as the rescue environment reports it.
  Example device: `{"identifier": "S4EVNF0N123456", "name": "nvme0n1", "path": "/dev/nvme0n1", "size_bytes":
  1024209543168, "model": "SAMSUNG MZVL21T0HCLR", "type": "nvme", "wwn": null, "serial": "S4EVNF0N123456"}`
- `CNF-363` asserts every device carries `name`, and that changing only names leaves the fingerprint unchanged.

**(b) no `name`** (r61e: 4 ACCEPT).
- `RSC-33`'s list: "(path, size, type, model, serial, WWN)".
- `WIR-10b`: the same device without `name`. `CNF-363` asserts nothing about `name`.

**fable-c** (fable, r61e; unreviewed).
- `RSC-33`'s list as (b), and this sentence is added: "The path is the device's name as the rescue environment
  reported it at that reading, under `RSC-27`'s device directory: diagnostic record, not identity (`RSC-26`)."
- Placement: fable didn't say where `RSC-33`'s existing last sentence ("This is the record…") goes. The manager
  put fable's sentence after it, so "This" keeps its antecedent.
- `WIR-10b` and `CNF-363` as (b).

**opus-c** (opus, r61e; unreviewed).
- `RSC-33`'s list as (a). `WIR-10b`'s device as (b), with no `name` field.
- `WIR-10b` gains this sentence: "A device's `path` reports both `RSC-33`'s name and its path, the device as the
  rescue environment names it, and `size_bytes` reports its size; the path selects nothing (`RSC-26`: "The
  identifier is authoritative; the path is derived.")."
- Placement: opus said "after the example". The manager put it at the end of `WIR-10b`'s first paragraph,
  after "`refresh` → `{}`.".
- `CNF-363` as (b).

**sol-MAY** (sol, r61e; unreviewed).
- `RSC-33`'s list as (b). `WIR-10b`'s device as (b), and this sentence is added: "Each device MAY additionally
  carry `name`, a JSON string containing the device's name as the rescue environment reports it."
- sol didn't say what `CNF-363` asserts about `name`. Unless you amend it, read it as (b)'s: nothing.

## Facts the manager checked

- **Gate:** fable-c and opus-c were each applied in a scratch clone at `4c0bb4c`, with the placements above.
  `python3 tools/check_citations.py` exits 0 on both, with no new findings. Planting a misquote in opus-c's
  `RSC-26` quote turns it red (exit 1), so that quote is checked. Only the citation gate was run, not
  `check-all.sh`.
- **Optional-field precedent:** the "MAY carry" fields found are in request bodies: `PRV-13d` ("A create MAY
  carry a caller-requested **runway**") and `WIR-20`'s `provider_native` row ("it MAY carry
  `authorized_keys`"). The nearest response-side case is `WIR-43`: "The key is omitted entirely when the machine
  has no case". That is a stated condition, not the implementation's choice. No response field optional at the
  implementation's discretion was found.
- `WIR-2`: "Responses are the opposite of bodies: **clients MUST ignore unknown response fields**, so the server
  can add fields without a version bump."
- fable's "`model` appears only in `RSC-33` and `WIR-10b`" is true, apart from `CONTEXT.md:434`, which mentions
  a disk's `model` field only to tell it apart from the formal model. opus's `RSC-26` quote ("those are device
  names with exactly the same instability") is verbatim.

## Each reader's r61e "weakest point on my side", verbatim

**fable:** ""Nothing in the set reads a device `name`" proves too much. `model` appears only in `RSC-33` and
`WIR-10b`; `type` likewise. Nothing reads them, and nobody proposes dropping them. `RSC-33` is "the record that
tells an operator afterwards", not a machine input, so "unread" is no argument. What remains is redundancy:
`RSC-27` says "a simple path under the device directory", so for a whole disk `name` is `path` minus the
directory."

**opus:** ""Nothing in the set reads `name`" proves nothing. It's equally true of `model` and `type`, and nobody
wants to drop those. `RSC-33`'s reader is a person: "the record that tells an operator afterwards which disk was
actually overwritten". Calling it "a second copy" doesn't show any harm either, because the field selects
nothing."

**astra:** "My earlier argument established that `name` was required, not that a separate field earned its
place. `RSC-33` calls the report “the record that tells an operator afterwards which disk was actually
overwritten,” but that purpose alone does not demonstrate useful information supplied by `name` beyond `path`.
Preserving an existing obligation is a reason for caution, not a veto on explicitly amending it. Nor did I
establish that the observed name necessarily differs from information recoverable from the path."

**sol:** "My r61d argument’s weakest point was treating the existing contract as sufficient reason to preserve
it during an authorized amendment. `RSC-33` calls the report “the record that tells an operator afterwards which
disk was actually overwritten.” I have not demonstrated that a separate `name` adds diagnostic information
beyond the retained `path`. That purpose supports useful reporting, but does not establish this field’s
necessity."

## Questions

1. Mark **fable-c**, **opus-c** and **sol-MAY** each ACCEPT or CANNOT ACCEPT, as written above. ACCEPT means
   you would sign off on it landing as written. For each CANNOT ACCEPT, quote the blocking clause or
   consequence.
2. **Pick one form to land**, from (a), (b) and the forms you marked ACCEPT. One pick, not a ranking. Give
   the reason in one sentence.
