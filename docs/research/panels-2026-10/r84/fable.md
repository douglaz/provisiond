**Verdicts:** Q1 prefer C, accept A and C, cannot accept B. Q2 prefer A, accept A, B and C, cannot accept D. Q3 prefer A, accept A and B. No printed form changes a checked verdict, a Lean declaration or a gate outcome; every CANNOT ACCEPT below is a policy objection and is labelled as one. No brief error voids a tally.

**Verification.** My clone is at 3109b5b44eae17e288cf52aaa976993bd8c5626c and clean. Every pinned extract matches its file and line numbers. All three tracker rows are open and labelled needs-triage. The four reference digests recompute exactly from the stated canonical byte strings, and sorted compact JSON round-trips them byte for byte. No Lean declaration is tagged API-13, RSC-46, SEC-29, OPS-23, RSC-23, CNF-200 or CNF-363, and the two Lean docstring quotations of RSC-46 are sentences no form touches. Against the gates: no form adds a quotation shape the citation gate checks, the only straight double marks added are the paired `"none"` values that the pinned OPS-23 already carries, every cited identifier exists, CNF coverage can only rise, and Q3's `{wwn, serial, size_bytes}` span is the field-set shape the fixture gate already skips. No build was run, as instructed. pv-wfld is closed at the pin, so the injected-value assertions in Q1-B, Q1-C and Q2 rest on pinned text: OPS-23 at 03:2033 says "A field that is present but fails this repeated validation fails as its writer's bullet above says", the caller bullet gives `invalid_request` with `retryable: false`, and 03:2045–2046 settle the install `failed` with `disk_effect: "none"` and `rescue_exit: "none"`.

## Q1, pv-ez8

| Form | Verdict |
|---|---|
| A | ACCEPT |
| B | CANNOT ACCEPT |
| C | ACCEPT, preferred |

Safety needs no ban. RSC-26 at 06:266 says "The identifier is authoritative; the path is derived", and the Lean projection `Resolution.path` at Rescue.lean:337 reads the path off the resolved device only. No form changes what is written. What a ban buys is the reboot: RSC-38 at 06:305–306 says "entering rescue means rebooting the machine into another operating system", and this set already accepted that cost as grounds for pre-enqueue refusal when r61b refused empty identifiers. Copying the inventory's neighbouring `path` field is the one mistake the service can recognise. C refuses exactly that shape with `invalid_request`, which the taxonomy at 01:581 defines as "Caller error, deterministic", instead of `integrity`, defined at 01:590 as "Digest or host-key verification failed", delivered after a reboot with PRV-22's always-ambiguous exit.

C's cost is a serial beginning with `/dev/`, which becomes unnameable although the inventory shows it, and RSC-26's offer-level omission cannot see this because a unique identifier is available. C prints that deliberately. I know of no firmware or virtualisation serial of that shape, which is background knowledge, not packet evidence. C's fixtures are consistent with its paragraph: ` 0X/DeV/sda ` trims, lowercases and strips to `/dev/sda` and is refused; `a/b`, `/tmp/disk` and `not-a-disk` are admitted at `202`, which 04:248 gives for install, then abort `integrity`; a unique serial `a/b` resolves.

A is faithful to r61b's rule that a well-formed string matching nothing aborts `integrity`, and it adds no rule. Its fixtures are consistent: `/dev/sda` is admitted then aborts with no write, and a disk whose serial is literally `/dev/sda` resolves by identity. Its cost is the reboot above for the one recognisable mistake, plus a 422 for a caller typo. Acceptable.

B: CANNOT ACCEPT. No gate contradiction and no checked verdict flips. The objection is the exclusion class. A slash anywhere excludes serials that virtualised providers can derive from volume names, and buys nothing for the story beyond C, since both refuse `/dev/sda`. RSC-26 at 06:258–259 says "An install request MUST carry both the chosen device's stable identifier and the `inventory_fingerprint` it was chosen from"; under B no admissible request exists for such a disk while its strategy stays listed. B's fixtures are internally consistent.

Requested counterargument against C: it writes an OS-specific heuristic over an opaque string into a MUST table, and it carves an exception out of a 4-0 panel decision that only empties are refused before enqueue. A keeps one rule and lets the one checked outcome, abort before any write, do the work.

Loss common to all three, not blocking: CNF-200's phrase "exactly as raw-disk does" disappears, and the parity assertion survives only through CNF-363's both-strategies rule. Each form also drops case (14)'s RSC-26 quotation, which is a checked citation, not a verdict.

## Q2, pv-2j3

| Form | Verdict |
|---|---|
| A, 1024 bytes raw | ACCEPT, preferred |
| B, 256 bytes normalized | ACCEPT |
| C, both | ACCEPT |
| D, body cap only | CANNOT ACCEPT |

Normalization never lengthens a value: trimming and prefix stripping shorten it, and ASCII-lowercasing preserves byte length. A raw cap therefore bounds the parsed value, the stored value and the matching key at one observation point, which is how every other row works. An echo of an inventory value has raw length equal to the trimmed as-read value, so A refuses an echo only when the trimmed serial or WWN exceeds 1024 bytes. B refuses echoes above 256 normalized bytes, a strictly larger exclusion, while admitting two mebibytes of padding; its own fixture admits a 1025-byte padded value. C adds B's bound to A's, so it excludes everything B excludes for a key-size benefit I cannot name. A is the least restrictive form that still bounds the input.

On the numbers, as background knowledge and not packet evidence: ATA and NVMe serials are 20 bytes, NAA WWNs are 16 or 32 hex digits, NVMe NGUIDs are 32 hex digits, and Linux udev's SCSI serial buffers are 256 bytes. 256 covers every format I know with no margin; 1024 covers them with fourfold margin. Both are defensible without a provider guarantee. The margin is why I prefer A.

Fixture consistency holds in A, B and C. 512 copies of U+00E9 are 1024 bytes and 128 copies are 256; appending `a` crosses each limit by one; literal and `\u0061` spellings decode identically. All three keep inventory values untruncated and use OPS-23's pinned kind and settlement for an injected value.

Lost capability shared by A, B and C, reported as a printed policy: a disk whose only identifier exceeds the cap is visible, uniquely identified and unnameable, and RSC-26's offer-level omission cannot see it. No CNF asserts such an echo, so no verdict flips.

D: CANNOT ACCEPT. SEC-29 at 07:280–281 says "individual fields MUST be capped per `API-13`". D satisfies that in letter only by writing "no separate field-size cap" into API-13, which makes SEC-29's second clause vacuous for the one field that can be two mebibytes, and the tracker row's own example, a 1.9 MiB identifier stored and compared in the worker, becomes conformant. Notes rule 7 says not to weaken a disputed rule to clear a review. No gate verdict changes; this is a policy objection.

Requested counterargument against A: the pinned table's other string rows count "characters" while A counts decoded UTF-8 bytes, a second counting convention, and if the owner wants the tightest defensible key bound, C's 256 is it, at the price of defending two numbers.

## Q3, pv-tbrs

| Form | Verdict |
|---|---|
| A, with U+000B | ACCEPT, preferred |
| B, without U+000B | ACCEPT |

Both definitions are exact, both fixture sets agree with their own definition and with the pinned null and prefix rules, and both reference digests verify. Under A, a vertical-tab-wrapped `0XAb` trims to `0XAb`, lowercases to `0xab`, strips to `ab` and hashes as `ab`; its echo and `ab` both match. Under B nothing trims, the value lowercases to VT`0xab`VT, the leading character is VT so no prefix is stripped, the echo matches and `ab` matches nothing, exactly as B's fixture says. U+0008, U+000E, U+001F, U+007F and U+00A0 at the edges are retained and block the strip under both. Case folding precedes prefix removal in both. VT-only is refused before enqueue under A and admitted under B, each consistent with its definition and with the pinned row at 04:974, "empty-after-normalization `target.identifier` or `layout.drives[].identifier` MUST be refused `invalid_request` before enqueue". Interior characters are preserved in both, matching case (13).

I prefer A because the trim exists to remove invisible firmware padding, and vertical tab is invisible padding. B's own fixture shows the trap it keeps: a serial only its exact echo can match. A's set is a contiguous range plus space, easy to state and to check. Two r61c readers proposed it and the tracker row names it.

Requested counterargument against A: the phrase "ASCII whitespace" has a widely published exact definition that excludes U+000B, and a mainstream standard-library predicate of the same name agrees, so defining the phrase differently invites an implementer to call that predicate and diverge on the one discriminating fixture. B keeps the term and the common predicate aligned. Background, not premise.

Two observations, neither blocking. Neither form trims U+0000, so a NUL-padded serial stays non-null and unnormalized under both, consistent with how both retain U+0008. Neither form's fingerprint sentence names which value the one-disk reports carry; the manager's calculation reads it as the vertical-tab case, the only discriminating one, and I read it the same way.

**Composition and brief errors.** C, A and A compose without overlap. Q1-C's paragraph follows the API-13 table and Q2-A replaces only the row. Q2-A's paragraph follows case (14) and Q3-A's follows it, before CNF-363's owner line. Every Q2 and Q3 fixture satisfies Q1-C and Q2-A, since nothing begins with `/dev/` and nothing exceeds 1024 bytes. Q1-C and Q2-A both carry "Worker repetition: `OPS-23`", a harmless duplication inside one owner. Any other accepted combination composes the same way; no Q1 form depends on the Q2 or Q3 choice. Applying notes rule 6 as written: I found no brief error, premise-changing or otherwise. Every quotation and line reference I checked is accurate, including the RSC-38 reboot sentence at 06:305–306, the RSC-46 fingerprint sentence at 06:321–323, and CNF-363 case (2) at 10:2303.
