# Panel brief r61b: pv-6p8, review the synthesized form. 2026-10-21

You are one of four independent reviewers. Your working directory is a throwaway clone of the
specification repository `provisiond-spec` at `4c0bb4c` (master). Read `AGENTS.md` first. `br show pv-6p8`
prints the bead (if `br` fails in the clone, `.beads/issues.jsonl` holds it). You MAY edit tracked files in this
clone to test a claim. Write nothing outside it (never `/tmp` or `/var/tmp`), and never commit, push or call a
provider API. Read nothing outside this clone except toolchain files. The gates exit 0 at `4c0bb4c`:
`nix develop --command bash tools/check-all.sh`, a few minutes. Run it unpiped, redirect it to a file in the
clone, and read its exit code. Keep `TMPDIR` as set. Do not delegate, background or wait on anything: do the work
yourself in this session. Have a draft answer by minute 30. Check every fact below with grep before you rely on
it: the manager has been wrong in briefs before. Read text by requirement id, not by line number.
**Answer in at most 450 words.**

## Background

The question: what does `rescue_inventory` return for a device with no serial and no WWN? Today no conforming
response exists. `WIR-10b`'s example shows each device with a string `identifier`, and `WIR-40` promises
"**stable identifiers**". `RSC-26` (PR #15) says "If a machine bought under a listed strategy has rescue inventory
that shows no unique identifier, that machine meets the abort this paragraph opens with."

Round 1 (r61), four readers, voted **4-0 for option 1**: keep every device and return `identifier: null`. Options 2
(omit the device) and 3 (refuse the inventory) were rejected:
- `RSC-26`'s fingerprint is "over the whole device set".
- `WIR-10b` gives the two rescue-entering installs the same `inventory` shape, so an install still has to report
  the disk.
- No per-offer signal sees `RSC-26`'s last-sentence machine.

The readers split on the details. The manager merged them into the clauses below. No reader has voted on this
text as a whole. That is this round's job.

## Settled (off-limits)

- Option 1's core: every device the rescue environment reports stays in `devices` and in the fingerprint.
- `RSC-26`'s zero/more-than-one abort, PR #15's per-offer strategy omission, `CNF-192` and `CNF-206` as they
  stand, and the capability row "| rescue inventory | `rescue_ssh` (`RSC-38` boots rescue to read the inventory) |".

## The synthesized clauses (accept, reject or amend each)

**C1** (only fable stated this definition). `WIR-10b`: a device's `identifier` is a string or `null`: the
normalized WWN, else the normalized serial, else `null`. `WIR-40` and `RSC-26`'s first bullet say "a stable
identifier per device, `null` where the device has none". The example gains a second device with
`"identifier": null`. Basis: `RSC-26`'s "MUST prefer WWN where the provider exposes it" and `RSC-46`'s "Matching
tries the WWN first, then the serial".

**C2** (4-0 on empty = absent; the hashing half is the manager's). `RSC-46`: a value that is empty after
normalization is absent and matches nothing. The fingerprint hashes the normalized values (trimmed, `0x`
stripped, lowercased), with `null` where a value is absent. Today `RSC-46` normalizes "Before comparison" only,
and says the hashed element is "exactly `{wwn, serial, size_bytes}` with `null` where a value is absent". It never
says whether the hashed values are normalized.

**C3** (round 1 split three ways). `RSC-46`'s "sorted by identifier" becomes: the device list is sorted by each
element's RFC 8785 serialization, compared as UTF-8 byte strings, and identical elements stay, one per device.
- fable and opus: sort by the canonical bytes alone.
- astra: by identifier with null last, then canonical bytes.
- sol: by identifier with null first, then canonical bytes.

JCS writes the keys as `serial`, `size_bytes`, `wwn`, so this order is not WWN-first. That is about ordering only,
not matching.

**C4** (3-1). A new `API-13` row, "disk identifier: a JSON string, non-empty after `RSC-46`'s normalization", is
refused `invalid_request` before enqueue, for `target.identifier` and every `layout.drives[].identifier`.
`WIR-20` points at it. A well-formed string that matches no device still aborts `integrity` (`RSC-26`).
- Opus dissented as written: with C2, an empty identifier "matches nothing, so it aborts `integrity`".
- The manager's own argument, not a reader's: if an empty identifier is enqueued, the machine reboots into
  rescue only to abort.

**C5** (2-2). Do `wwn` and `serial` go on the wire?
- (i) Separate bead (fable, opus). `WIR-2` says "clients MUST ignore unknown response fields", so adding them
  later is cheap.
- (ii) In scope (astra, sol): add nullable `wwn` and `serial` to each `WIR-10b` device, beside `identifier`, and
  `RSC-33` names both.

The bead's acceptance reads "`RSC-33`/`RSC-38` agree". `RSC-33` asks for "at minimum the block-device inventory
(name, path, size, type, model, serial)", while `WIR-10b`'s device has no `serial` and no `name`. Ruled out: naming
serial and WWN in `RSC-33` while keeping them off the wire. That widens the gap.

**C6** (2-2). New `CNF-363`, placed after `CNF-206`, vs amending `CNF-47` (astra, sol). Draft `CNF-363`:

> On a machine with disk A carrying a WWN and disk B carrying neither, a rescue-inventory result lists both, B
> with `"identifier": null`, and its `inventory_fingerprint` is `RSC-46`'s hash over both. A `raw_disk` install
> naming A with that fingerprint resolves A and writes nothing to B. Removing or resizing B between the inventory
> and the install aborts `integrity` with no bytes written. Repeat with B's serial whitespace-only: the same.
> An install whose `target.identifier` is `null` or whitespace-only is refused `invalid_request` before
> enqueue. On a machine where no device has an identifier, the inventory succeeds and lists every device with
> `null`.

**C7** No new Lean theorem. Fable's and opus's plants (a `none` device matching any identifier) both turned the
existing `resolves_only_the_named_disk` red. Docstrings that quote changed text get updated: `Rescue.lean` quotes
"**stable identifiers** — serial and WWN", and `Witnesses.lean` quotes "sorted by identifier".

## Known gap (verified by the manager)

`check_fixtures.py` checks fenced ```json blocks only, and `WIR-10b`'s example is inline. In round 1, putting
`/dev/sda` in place of B's `null` passed every repo gate. Only the CNF item would catch it.

## The owner question as it would be asked (review it too)

> Some disks, mostly cheap or virtual ones, report no serial number and no WWN. Today the inventory answer has no
> legal way to show one. The panel says show it with `identifier: null`, keep it in the list and the
> fingerprint, and make it impossible for an install to name it.
> (a) **Recommended:** C1–C7, with `wwn`/`serial` [per this round's C5 vote].
> (b) Omit such disks from the list.
> (c) Refuse rescue inventory on such machines.

## Questions

1. For each of C1–C7: accept, reject or amend, with one line of reason. Vote C5 (i) or (ii), and C6 (`CNF-363` or
   `CNF-47`).
2. Do any two clauses contradict each other, or contradict text outside them? Quote both sides.
3. Make C1–C7 in your clone, using your C5 and C6 picks, and run the gates. Plant the plausible bad edit, run them
   again, and report whether anything goes red.
4. Is the owner question fair and complete? Rewrite it if not.
5. Labelled as written on request: the strongest argument against the clause you accepted with least confidence.
