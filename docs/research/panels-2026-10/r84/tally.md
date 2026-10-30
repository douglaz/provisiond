# r84 — Panel E tally

Pin: `3109b5b44eae17e288cf52aaa976993bd8c5626c`. Read STATE.md, notes.md, brief.md, all four complete final answers and available raw stdout/stderr. **apply notes.md rule 6 exactly as written; this prompt adds no void rule.** No question is void. No source, tracker, main checkout, manager brief or other panel has been changed.

## Seats and evidence

Fable, opus, astra and sol each returned a substantive answer, exit 0: byte sizes and hashes are preserved in the reader files and check/tally audit. There is no session/usage-limit, sign-in, capacity or timeout answer. Fable/opus stderr are empty; astra/sol stdout matches the respective final answer after stripping its extra trailing newline. No root-level draft exists. Grok's launch probe was 402/balance exhausted: missing, not a vote. Apply three of four.

Raw execution audit: `check/tally/reader-execution-audit.txt`. Astra's first rg search exited 127; subsequent Python and source reads supplied the evidence, so this is not a failed seat. Sol read review-skill instruction files outside the packet/clone; those files are procedural, not pinned spec evidence. No voting exclusion for that deviation exists in notes.md. No reader raw transcript shows a Lean build or a main-checkout mutation. Claude execution traces are not available beyond their answers/empty stderr; do not claim an independent command audit for them.

All eleven printed source extracts match the pin exactly (`check/tally/extract-check.json`). Relevant owner/CNF blocks remain intact in 08191bb; their line positions can move, so fixed-line comparisons across commits were not used as evidence of semantic change. Source authority and formal declarations are preserved in `check/tally/source-evidence.txt`. The independent calculation receipt is `check/tally/calculations.json` / `verify-calculations.out`, exit 0. All four reader clones and check/spec remain clean at the pin. Committed JSONL has pv-ez8/pv-2j3/pv-tbrs open/needs-triage, pv-wfld closed; no tracker CLI was used.

## Q1 — pv-ez8: admission versus resolution

| Reader | Final pick | Strongest argument | Conditions / exact acceptance |
|---|---|---|---|
| fable | C | Avoid the recognizable `/dev/` mistake before rescue reboot while excluding fewer identities than B. | A/C ACCEPT; B CANNOT ACCEPT as policy, not a verified blocker. Accept C's deliberate loss of inventory echoes beginning `/dev/`. Background claims about provider serial formats are unverified at this pin. |
| opus | C | Avoid pointless rescue disruption; if a disk serial itself looks like another disk's path, identity matching can surprise a caller thinking in paths. | A/B/C ACCEPT; B broader than needed; C is a substantive domain restriction, not a wording repair. No formal or retained-fixture blocker. |
| astra | A | Match identity without inferring meaning from opaque spelling; the resolved inventory path governs writes. | A/B/C ACCEPT as printed; B/C's new early refusals and lost echoes must be disclosed. The ban is not needed for the write-path property. |
| sol | A | The existing admission domain plus identity resolution suffices; make CNF-200's phase explicit. | A/B/C ACCEPT; B/C may be chosen for availability but exclude legitimate displayed identifiers. No unread repairs. |

Final picks: **A 2 (astra/sol), C 2 (fable/opus), B 0**. Acceptability: A 4, C 4, B 3 (opus/astra/sol); B rejected by fable. Multiple exact forms meet the acceptance count; rule 2 says preserve explicit preferences and do not invent a tie-break. **NO SETTLEMENT: 2–2 preference tie.** One consensus round under rule 4, Q1 only alongside unresolved Q3; all original A/B/C forms remain exact.

Verified trace: API-13's disk row says "a JSON string, non-empty after normalization (`RSC-46`)" (04:974); the install tail says "enqueue an operation, then `202`" (04:248). RSC-26 says "The identifier is authoritative; the path is derived" (06:266) and "An identifier that does not resolve to exactly one device MUST abort `integrity` before any write" (06:268–269). The model's `Resolution.path` projects the resolved Device.path (Rescue.lean:334–339), and `resolve` checks fingerprint then match multiplicity (345–359). Thus A's unmatched and literal-serial fixtures follow the pin; B/C deliberately restrict input earlier. RSC-38 says "entering rescue means rebooting the machine into another operating system" (06:305–306) and describes an ambiguous exit that can strand the service. Their disruption argument is supported; no guarantee of a clean return is inferred.

B excludes normalized `a/b`, C does not; both exclude normalized `/dev/sda`, including the unique-serial fixture. The driver's static offer omission is triggered "where no per-device unique identifier is available at all for that offer" (RSC-26, 06:272–274); uniqueness is not an admission-domain guarantee. A/C/B do not promise that every listed offer supports every displayed identity. CNF-363 starts "Use otherwise-admissible fixtures" (10:2295), so its remaining positive echo cases can still run; their admissible domain is narrowed by B/C as disclosed. Opus's hypothetical wrong-intent example follows identity matching but is not a provider fact or a failure of the modeled identity property. No checked write-safety verdict or Lean statement is weakened.

Requested counterarguments remain counterarguments: fable/opus acknowledge C adds a heuristic over an opaque identity; astra/sol acknowledge A permits the rescue reboot. None is counted as a second vote.

## Q2 — pv-2j3: identifier size

| Reader | Final pick | Strongest argument | Conditions / exact acceptance |
|---|---|---|---|
| fable | A | One raw 1024-byte bound also bounds the normalized key; 256 excludes more trimmed inventory echoes without a demonstrated need. | A/B/C ACCEPT, D CANNOT ACCEPT as a policy weakening. Claimed hardware/udev maxima are unsupported by the pinned set and are not accepted as compatibility evidence. |
| opus | A | Bound admitted/stored decoded values; a separate 256-byte normalized cap buys no shown safety property. | A/B/C ACCEPT, D CANNOT ACCEPT; D's SEC-29 interpretation is contestable. A does not prevent receiving/parsing a long body; it rejects admission afterward. |
| astra | A | 1024 is a service budget with fewer identity exclusions than 256; normalize cannot enlarge UTF-8 length. | A/B/C/D ACCEPT. No provider-wide compatibility guarantee; reject long echoes where no shorter equivalent or other identity exists. |
| sol | A | One decoded-value limit bounds later storage/revalidation, with no extra 256-byte domain restriction. | A/B/C/D ACCEPT. Numbers are support policy, not hardware maxima; preserve untruncated inventory and disclose echo/padding losses. |

Final picks: **A 4**, B/C/D 0. Acceptability A/B/C 4 each; D 2 (astra/sol), rejected by fable/opus. Explicit preferences resolve the multiple acceptance sets: **SETTLED on Q2-A exactly**, with no repair. Selected row and entire boundary paragraph are copied verbatim to `check/tally/q2-A.md`.

Verified trace: SEC-29 says "Request bodies MUST be size-capped globally, and individual fields MUST be capped per `API-13`" (07:280–281). The current row has no number; the request-body row says "globally capped (2 MiB is a reasonable default)" (04:978). API-13 already gives `provider options` only "MUST be a JSON object" (04:972), so D's relationship to that delegation is genuinely contested; do not report the D objection as an established blocker of A. A adds the chosen raw decoded UTF-8 limit explicitly in the field owner. It cannot cap network receipt or work already spent parsing before validation. Its guaranteed benefit is the admitted/stored field budget.

ASCII folding preserves UTF-8 byte length, edge trimming and one ASCII prefix removal cannot increase it. Independent calculations confirm all ASCII, U+00E9, padding and JSON-escape examples. 1025 padded bytes normalizing to `a` fail A/C and can pass B/D within the global body cap; normalized lengths 257..1024 can pass A but fail B/C. These admission sets are not universally nested. For exact trimmed wire echoes, B/C exclude more values than A. The caller's arbitrary raw padding must not be confused with a trimmed inventory wire echo.

OPS-23 says "Validation that was performed at the API boundary MUST be repeated in the worker before the driver is called" (03:2018–2019). Its caller bullet requires "`invalid_request` naming the field, with `retryable: false`" (2030–2031), and the present-field paragraph applies it to repeated validation failures (2033). It requires checks before either install marker and supplies `disk_effect: "none"`, `rescue_exit: "none"` (2043–2049). The new injected-request assertions preserve that obligation. No new Lean tag for API-13/RSC-46/SEC-29/OPS-23 exists, and no abstract disk-resolution declaration is changed.

Compatibility loss is real and intentional: a sole usable identity beyond A's cap becomes unselectable; returned inventory is not truncated. CNF-363's "otherwise-admissible fixtures" qualifier keeps the retained echo/padding cases satisfiable, while the new boundaries expressly add different refusal outcomes. The unanimous panel selected the budget, not a proof that every provider identity fits it.

**Next: OWNER QUESTION**, not ready-for-agent. This chooses a new numeric support policy and changes admissible inputs, so it is outside the wording/mechanics precedent. The owner precedent "For such wording questions, try to solve by getting a consensus of the panel" covers wording only; it does not itself authorize this new cap. The general technical majority settles which exact form to recommend; it does not turn compatibility/cost policy into wording. The owner question is `owner-question.md` and is the only ready owner question from this tally.

## Q3 — pv-tbrs: exact whitespace and independent hash

| Reader | Final pick | Strongest argument | Conditions / exact acceptance |
|---|---|---|---|
| fable | A | Remove invisible vertical-tab edge padding with a simple contiguous set. | A/B ACCEPT; no claimed blocker; notes unspecified one-disk fixture value. Outside library/standard statements are requested counterargument/background, not verified premises. |
| opus | A | Include the neighboring control U+000B; a lone vertical tab otherwise passes admission and can cause rescue disruption. | A/B ACCEPT; names unspecified one-disk hash fixture value; any collision remains an integrity abort. Outside standard/library analogy is not pinned evidence. |
| astra | E (its complete alternative) | Both original insertions literally hash the element rather than the device list; supply exact list/bracket repair with A's trimming set. | A/B CANNOT ACCEPT due to the oracle defect; E ACCEPT by its author only. No premise-changing brief error claimed. |
| sol | A | Exact local contiguous trimming set and independent reference calculation, without outside-library assumptions. | A/B ACCEPT unchanged; substantive identity-collision/VT policy choices disclosed; it did not address Astra's later grammar objection. |

Final picks: **A 3 (fable/opus/sol), E 1 (astra)**. Acceptability: A/B 3 each; E reviewed/accepted by astra alone, unreviewed by the other three. E is not counted as A. **NO EXACT-FORM SETTLEMENT**, despite A's raw preference majority: the dissent's hash trace is verified below under rule 3. No silently merged repair is recommended.

Full lone-dissent trace: RSC-46 says "The `inventory_fingerprint` is SHA-256 over the RFC 8785 canonical JSON of the device list" (06:321), then "each element exactly `{wwn, serial, size_bytes}`" (322), and the wire digest is "64 lowercase hex characters" (325). Both Q3 original insertions instead say "independently construct each normalized `{wwn, serial, size_bytes}` element, its RFC 8785 canonical bytes and SHA-256, and assert the fingerprint against those expected bytes and digest." The grammatical referent of "its" is the element. Literal execution computes an object hash; computing the list hash requires an inferred correction. The manager's displayed reference correctly uses lists but does not alter the exact proposed requirement text.

Independently reproduced A serial fixture:

- Required list bytes: `[{"serial":"ab","size_bytes":1024,"wwn":null}]`; SHA-256 `8a7ab8eb85404e4ef4022bdf6f1cfc768b029d7f68271f0f60c931d494b72641`.
- Literal element bytes: `{"serial":"ab","size_bytes":1024,"wwn":null}`; SHA-256 `b2fa45b2bdac148628b4ec507afb927aafd8d8c51a5389e5a1a35a8d117bbc05`.

The two digests differ in all four serial/WWN A/B cases (`calculations.json`). A conforming list-hashing engine fails the proposed literal object-hash assertion. This is a checked conformance-verdict defect, not an absent runtime test or an objection to A's policy. The existing list-hash obligation is preserved; no Lean definition or proof is to be weakened. Astra E changes only this oracle sentence in the CNF insertion and keeps the A definition. Its full exact text/landing is `check/tally/q3-E.md`. It must be read whole by everyone before it can settle. Fable/opus's separate fixture-value ambiguity remains available to the next round; E must not be silently strengthened by choosing new required values.

All supplied list reference hashes are correct. Independent explicit-set calculations confirm A trims U+000B while B retains it; retained edges prevent stripping a nonleading `0x`; folding happens before one prefix strip; wire display trims without folding; interiors survive; empty normalizations are absent. The preserved owner says "trim ASCII whitespace, ASCII-lowercase, then strip exactly one leading `0x`" and "A value that is empty after normalization is absent and matches nothing" (06:314–316). No other code-point list in that owner resolves the policy. The choices change identity equivalence and possible collisions deliberately; neither gets a universal provider-safety guarantee. Their policies do not change the natural-number `Identifier` / fingerprint abstraction in Rescue.lean.

**Rule 6:** Astra broke the brief's claim that each printed Q3 form is a complete correct exact patch with the listed independent hash oracle. This is an *other brief error*: it changes a proposed case's verdict, not the premise that the trimming set is unspecified. Record the defect and affected votes, do not void the tally. Astra's original-form rejections rest on it; the other readers' acceptances did not address it. No other premise-changing brief error is verified. Fable's blanket “No printed form changes a checked verdict” is overbroad given this oracle defect and the explicitly printed domain changes; retain its actual acceptance votes without adopting that assertion.

**Next: ONE consensus/whole-form confirmation round r84b**, only Q1 and Q3, with other answers verbatim and all exact forms complete. Original Q3-A/B stay visible so no dissent is rewritten; E is distinctly labelled as astra's alternative. If neither produces a qualifying exact form, relay the unresolved policy to the owner after this one round. Q2 must not be re-asked.

## Gates and fences

Initial independent full unpiped Nix check-all at the pin exited 0 with Lean (`check/gate-tally-before.log/.exit`), in capped panel-r84-tally-gate-before. Final full gate will be recorded in STATE.md after packet preparation. These validate the unchanged pin, not applied candidates. Reader calculations are source-only; no candidate build is claimed. Quotas at tally entry: Claude session 19%, all-models week 60%, Fable 83% exempt; active Codex WEEK 93%, below 100. No account switch/logout. Only this panel's artifacts and own units are used; no implementation/PR/merge or tracker action is authorized here.

Final gate update: independent full unpiped Nix check-all also exited 0 with Lean and every gate PASS (`check/gate-tally-final.log/.exit`); baseline pin unchanged. Before/final gate exits are 0/0.

Next-step update: r84b launched for Q1/Q3 only; four capped seats confirmed active/running, quotas permitted, sole fresh grok402 probe missing/no retry. Packet/copy/exact-option/verbatim-answer proofs and consistency disposition in r84b/check/. Q2 owner question remains ready independently. See r84b/STATE.md for exact wait; no r84b answer is tallied here.
