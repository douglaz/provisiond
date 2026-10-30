# Panel E r84b — consensus tally

Pin: `3109b5b44eae17e288cf52aaa976993bd8c5626c`. This is the ONE consensus round for Q1 pv-ez8 and Q3 pv-tbrs. Read the launch state, frozen notes, complete brief (including historical answers), original r84 tally, all four r84b answers and available execution output. **apply notes.md rule 6 exactly as written; this prompt adds no void rule.** Neither question is void. No further round or unit is authorized or launched.

## Seats and verification

| Reader | Exit | Answer bytes | Substantive |
|---|---|---|---|
| fable | 0 | 11398 | yes |
| opus | 0 | 12178 | yes |
| astra | 0 | 11258 | yes |
| sol | 0 | 8538 | yes |
| grok | missing | — | HTTP 402 at launch; no retry |

The frozen five-seat rule applies with the owner's fallback: "a question is settled when at least three agree and more agree than disagree, and a tie comes to you. If grok is down, it falls back to three of four". No answer is a session/usage-limit, sign-in, capacity, timeout or empty response. No root-level draft exists. Fable/opus stderr are empty; astra/sol stdout equals each final answer apart from a trailing newline. Available Codex execution commands show source reads and independent calculations, no Lean/full gates or source/tracker mutation. Claude command traces are not available; their empty stderr is not an independent command audit. See `check/tally/reader-execution-audit.json` and the saved command bodies.

`check/tally/verify.py` independently checks every printed pinned extract, copies each unchanged candidate to `check/tally/q*-*.md`, checks both trim sets and the printed boundary families, and reproduces the serial/WWN list and element hashes. The source/committed tracker receipts are `source-evidence.txt`, `extract-check.json`, `pinned-tracker-evidence.json` and `calculations.json`. Reader and independent gate clones are clean at the pin (`clone-status.json`). No tracker CLI was used.

## Q1 — pv-ez8

| Reader | r84b final pick | Strongest argument | Exact acceptance and conditions |
|---|---|---|---|
| fable | A (changed from C) | Preserve the pinned admission reading and opaque identity echoes; C adds a policy refusal to an already adopted admission rule. | A/C ACCEPT; B CANNOT ACCEPT as policy, not a blocking loss. A retains the rescue reboot for an unmatched `/dev/` string. Its claim that A/C write the same in every case is overbroad; corrected below. |
| opus | C (unchanged) | Refuse the path spelling shown in inventory before a disruptive rescue reboot; also prevent a caller's path paste accidentally naming another disk's path-shaped serial. | A/B/C ACCEPT; C deliberately excludes `/dev/` identity echoes and requires owner policy approval. The wrong-intent scenario is hypothetical, not a provider fact or modeled resolution failure. |
| astra | C (changed from A) | The documented rescue disruption justifies the narrow prefix restriction while retaining `a/b` and `/tmp/disk`. | A/B/C ACCEPT; disclose unavailable echoes and potentially unselectable disks. No guarantee that C catches other mistaken spellings. |
| sol | A (unchanged) | Preserve identity-string admission and explicitly test unique resolution, matching fingerprint and resolved write paths. | A/B/C ACCEPT; C's availability benefit is real but comes with a new input exclusion. No undocumented serial grammar is assumed. |

Final preferences: **A 2 (fable, sol), C 2 (opus, astra), B 0**. Exact acceptability: **A 4, C 4, B 3** (B rejected by fable). Multiple forms qualify by acceptance, and notes rule 2 says "If more than one form qualifies, preserve explicit preferences rather than inventing a tie-break." Therefore **NO SETTLEMENT: still 2–2 after the one consensus round; OWNER QUESTION**. Neither the status quo nor the broader form with no first preferences is an authorized tie-break. Do not create r84c.

### Verified competing traces and losses

API-13's disk row says "a JSON string, non-empty after normalization (`RSC-46`)" (`04-api-contract.md:974`); the install endpoint says "enqueue an operation, then `202`" (`04-api-contract.md:248`). RSC-26 says "The identifier is authoritative; the path is derived" (`06-rescue-install.md:266`) and "An identifier that does not resolve to exactly one device MUST abort `integrity` before any write" (`:268–269`). These support A's two distinct fixtures: an unmatched `/dev/sda` is admitted then fails resolution; a unique serial literally `/dev/sda` resolves by identity. The pinned `Resolution.path` reads the resolved device's path, and `resolve` checks fingerprint and multiplicity (`Rescue.lean:334–359`).

RSC-38 says "entering rescue means rebooting the machine into another operating system" and that failure can leave it "with nothing serving" (`06-rescue-install.md:305–307`). This verifies C's disruption argument. WIR-10b's inventory example displays `"path": "/dev/nvme0n1"` beside the identity (`13-wire-contract.md:293–297`), and CNF-363 case (6) says "every device carries `path`" (`10-conformance-checklist.md:2309`). A path paste is a plausible mistake, not a measured frequency claim.

Opus's full hypothetical: X has path `/dev/sda`, serial `/dev/sdb`, and no conflicting WWN; Y has path `/dev/sdb` and a different identity. With the matching fingerprint, an input `/dev/sdb` resolves X under A, even if the caller intended Y by path. C refuses it before enqueue. This follows the identity rule and does not violate its write-path theorem. No evidence establishes that an actual provider emits such serials. WIR-20's "not a device path" (`13-wire-contract.md:730`) identifies the field's meaning; it does not already supply C's new lexical ban, given the explicit API-13 admission row.

B forbids `/` anywhere after normalization, including `a/b`; C forbids only normalized `/dev/` prefixes, including ` 0X/DeV/sda `. Inventory values remain visible. If no other admissible identity exists, a disk becomes unselectable under either exclusion. RSC-26's strategy omission applies "where no per-device unique identifier is available at all for that offer" (`06-rescue-install.md:272–274`); a unique but refused identifier does not satisfy that condition. CNF-363 starts "Use otherwise-admissible fixtures" (`10-conformance-checklist.md:2295`), so its retained positive cases remain executable within the narrowed domain. These are printed policy losses, not a hidden blocker.

OPS-23 says validation "MUST be repeated in the worker before the driver is called" (`03-operation-lifecycle.md:2018–2019`); present-but-invalid fields fail "as its writer's bullet above says" (`:2033`), with the caller outcome "`invalid_request` naming the field, with `retryable: false`" (`:2030–2031`). Its install settlement gives `disk_effect: "none"` and `rescue_exit: "none"` before either marker (`:2043–2049`). This verifies B/C's injected saved-request tests. No existing formal declaration or retained resolution property is weakened.

Fable's historical claims are verified in committed pv-6p8 comment 801 item 7, which records "Admission (r61b 4-0)" and "A well-formed string that matches nothing still aborts `integrity`", and comment 802, which reads CNF-200 as "admission followed by an integrity abort with no write". The pv-ez8 row likewise explicitly distinguishes a new admission rule from resolution. This history supports A's argument; it does not settle this round's tie. The row's illustrative "no real disk can match" is unsupported by any pinned serial grammar and is disproved by the explicitly permitted literal-serial fixture.

**Reader overclaim corrected:** fable says "A and C write the same bytes to the same disks in every case." For a sole unique serial `/dev/sda`, A permits resolution/write while C refuses the request. The shared property is that admitted writes use resolved paths; successful outcomes are not identical. Fable itself discloses this exclusion later. Preserve its actual A preference and A/C acceptances; do not repeat the universal as fact. No reader reports a verified blocking loss for Q1.

## Q3 — pv-tbrs

| Reader | r84b final pick | Strongest argument | Exact acceptance and conditions |
|---|---|---|---|
| fable | E (changed from A) | Retain A's explicit trim set while fixing the element/list hash contradiction it previously missed. | E ACCEPT; A only with exact E fix; B only with distinct B′ fix. No extra mandatory fixture-value coverage. Its stronger reading of per-character hash coverage is not imposed on the shared form. |
| opus | E (changed from A) | E changes only the defective oracle sentence and keeps the trim policy every previous preferred form used. | E ACCEPT; A only with exact E fix; B only with distinct B′ fix. Disclose identity collapse at edge U+000B. It reads more per-character hash coverage than astra/sol require; no added cross-product is adopted. |
| astra | E (unchanged) | Literal A/B hashes an object, changing a checked verdict; E explicitly hashes the list including brackets. | A/B CANNOT ACCEPT, E ACCEPT unchanged; the separate hash fixture need not contain U+000B or every preceding boundary value. |
| sol | E (changed from A) | E retains the explicit trim set and makes the independent oracle agree with the owner's list fingerprint. | A/B CANNOT ACCEPT, E ACCEPT unchanged; no hidden fixture-value obligation, preserve coverage limitation and deliberate identity effects. |

Final preferences: **E 4**. Unchanged exact acceptance: **E 4, A 0, B 0**. Conditional repairs are distinct forms, never acceptances of unchanged A/B. Fable and opus each accept a B′ containing B's trim set and E's list-oracle replacement; this is not a printed candidate reviewed by astra/sol, has no final preference, and is not substituted for E. **SETTLED TECHNICALLY: exact Q3-E whole, without amendment.**

### Full verified blocking trace for original A/B

RSC-46 says "The `inventory_fingerprint` is SHA-256 over the RFC 8785 canonical JSON of the device list" (`06-rescue-install.md:321–322`), with wire output "64 lowercase hex characters" (`:325`). Original A/B instead say "construct each normalized `{wwn, serial, size_bytes}` element, its RFC 8785 canonical bytes and SHA-256". The grammatical referent is the element. For a serial-only device normalized to `ab`:

```text
Required list bytes: [{"serial":"ab","size_bytes":1024,"wwn":null}]
SHA-256: 8a7ab8eb85404e4ef4022bdf6f1cfc768b029d7f68271f0f60c931d494b72641
Literal element bytes: {"serial":"ab","size_bytes":1024,"wwn":null}
SHA-256: b2fa45b2bdac148628b4ec507afb927aafd8d8c51a5389e5a1a35a8d117bbc05
```

Independent calculations reproduce these distinct digests and the WWN and B-policy pairs (`check/tally/calculations.json`). A conforming list-hashing implementation fails the literal element assertion; an element-hashing implementation could pass that new assertion while failing the owner and retained list test. This is a changed checked verdict, not an absent test or the intended trim-policy choice. The r84 lone dissent is verified in full, and all readers now acknowledge it. E explicitly requires "canonical bytes of that list, including its enclosing array brackets" and comparison with the digest's lowercase hex encoding. Do not weaken the list owner or a Lean theorem to retain A/B.

### Boundary checks, scope and deliberate policy effects

RSC-46's existing order is "trim ASCII whitespace, ASCII-lowercase, then strip exactly one leading `0x`" (`06-rescue-install.md:314–315`); its wire fields are "strings as read, trimmed of ASCII whitespace, or `null` where normalization leaves nothing" (`:319–320`). E defines the exact set locally in that owner, and the independent fixture assertions agree:

- Each of U+0009 through U+000D and U+0020 around `0XAb` yields wire `0XAb`, normalized `ab`; each alone becomes absent. Both caller fields and both inventory identity fields are covered by E's complete paragraph.
- U+0008, U+000E, U+001F, U+007F and U+00A0 remain at the edges and prevent a later `0x` from becoming leading. Interior tested characters survive, including `0X` + U+000B + `Ab` becoming U+000B + `ab`; there is no second trim.
- Existing case (8) remains: ` 0x0XAB ` normalizes to `0xab`, while `0XAB` normalizes to `ab`. These are different matches.
- E trims edge U+000B; B retains it, giving the wrapped normalized value `\u000b0xab\u000b` and different fingerprints. E may collapse identities previously distinguished by that edge content, or make a U+000B-only identity absent. With no alternative distinguishing match, duplicates abort under RSC-26's "does not resolve to exactly one device" rule. These are substantive behavior choices, not editorial equivalence.

The separate serial-only/WWN-only hash fixture does not name the identity value. Astra/sol explicitly accept it without requiring U+000B or a hash calculation for each boundary value; fable/opus infer broader coverage from the earlier "normalized hash value is `ab`" assertion. The common exact form is executable without adding that broader cross-product. Preserve the separate independent list test and every explicit boundary assertion; do not add a value-specific requirement as if all four had adopted it. Notes rule 3 says "An absent new runtime test alone is not a contradiction." No reader conditions E acceptance on an amendment.

Outside standards/library claims in fable/opus's requested counterarguments are not verified at the pin and are not premises of the settlement. No web/library fact or hardware format guarantee is used. The independent calculation covers these fixed JSON fixtures, not a general implementation of RFC 8785. `Identifier.n : Nat`, `Inventory.fingerprint : Nat` and the inspected resolution declarations abstract away strings/hashing (`Rescue.lean:295–359`); no formal edit is required by this exact package.

**Next: OWNER QUESTION, not ready-for-agent.** The owner precedent is "For such wording questions, try to solve by getting a consensus of the panel"; its recorded scope is "no behaviour, requirement or check-strength change" (manager brief, PR handling). E chooses previously unspecified code points, changes identity equivalence/wire/fingerprint outcomes, and adds boundary checks. The unanimous technical selection determines the exact recommendation; the wording precedent does not authorize this policy change. Q2's approved size limit does not adopt Q3. The owner package is queued as question 2 in `owner-questions.md`.

## Rule 6, composition and next actions

No verified premise-changing brief error; **neither tally is void**. The original A/B oracle defect is the previously disclosed other brief error, faithfully printed and challenged in r84b. Astra/sol call it an other brief error; fable/opus find no new brief error. All four original-form Q3 rejections/conditional repairs rest on the verified defect. It does not change the premise that the trim set was unspecified, and E was reviewed whole. The brief's Q2 "owner pending" wording was true at launch and is superseded by owner-decisions-1030.md item 8; it supplies no new Q2 vote and affects neither question's premise. No new contradiction in the r84b brief is established. Fable's A/C universal is a reader overclaim, not a new brief premise.

Q1's selected replacement cases and Q3's insertion locations do not overlap the already approved Q2-A row/size paragraph. Under E, vertical-tab padding is removed before C's prefix check, so a wrapped `/dev/sda` is refused if C is chosen. Under A it remains subject to identity resolution. E preserves the approved Q2 boundary outcomes: those fixtures use spaces, ASCII and U+00E9, and none becomes a `/dev/` input. This is composition verification only; Q2 is already owner-decided and is not tallied here.

**Owner queue:** (1) resolve Q1 A/C tie, with B preserved as the broader reviewed alternative; (2) approve or hold exact Q3-E. `owner-questions.md` contains both, numbered for main to ask one at a time; `owner-question.md` contains only the first. No synthesis, implementation, readiness-label update, tracker change, new panel, consistency reader or other unit is launched.

## Gates and fences

Both independent unchanged-pin full unpiped `nix develop --command bash tools/check-all.sh` runs exited **0**, with Lean and every gate PASS: `check/tally/gate-before.log/.exit` and `gate-final.log/.exit`. They ran directly inside this already capped manager unit, not a newly launched unit. Its cgroup is `mgr-pe-r84b-tally.service`, confirmed MemoryMax=16G, MemorySwapMax=0, OOMPolicy=continue, StandardInput=null. Own `check/spec` clone and round-local TMPDIR; npm-global-first PATH. Initial host Lean-build admission was one; final admission waited while two builds ran, then cleared at one (`final-build-admission.log`). Five clones remain clean at the pin after both gates. This validates the unchanged pin; no candidate is applied or built.

Entry quota readings: Claude session 27% (Oct 30 23:00 UTC reset), all-models week 61% (Nov 5 15:00 UTC), Fable 86% exempt; active Codex WEEK 95%, permitted below 100%. No account switch/logout. Only r84b artifacts, its own new gate clone and the explicitly authorized parent STATE.md are written. Main checkout, branches, tracker, manager brief, other panel folders and every pre-existing unit remain untouched by this tally.
