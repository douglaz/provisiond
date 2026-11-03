**Astra: PASS for the exact selections below**, reviewing pv-9ecf at M=`2e2cd94637112f20538eb26b141672fedf0ba455`, against adopted C′ at O=`3109b5b44eae17e288cf52aaa976993bd8c5626c`. This is a reader recommendation, not a settlement or authorization to start the Run.

**apply notes.md rule 6 exactly as written; this prompt adds no void rule.**

My final picks are:

| Question | Pick |
|---|---|
| Q1 | **R-MASTER** |
| Q2a | **Q-QUOTE** |
| Q2b | **Q-QUOTE** |
| Q2c | **Q-QUOTE** |
| Q2d | **Q-POINTER** |
| Q2e | **Q-POINTER** |
| Further added/changed source-content summaries | **None found beyond the inventory below** |
| Q3 | **S-OUT** |
| Q4 | **L-NOTE**, with exactly the supplied appendix and **no additional duplicate-form note** |

**Verification and rule 6.** I read the required packet, archived r89 records and reader answers, stop evidence, and r95/r96 precedents. I independently compared source using this clone and its Git objects.

The form’s SHA-256 is exactly `be350270318a2752992a9cb199a2a56879249be99f36e7af430bcfe8a1d47a32`. Both archived forms and the external r89b form match it. Comment861 contains it verbatim, and the decoded comment and bead match M’s committed JSONL. The stop evidence copies match their manager originals. The external r89b tally and owner question differ from their archived counterparts only in links rewritten from `consistency/...` to pinned GitHub URLs; they are not wholly byte-identical files.

The historical framing is supported. Original r89’s numeric preference for C did not settle its narrowing of the unconditional wire obligation and worker-fixture domains. The r89b tally records unanimous acceptance of C′, retaining those protections and seeking approval for the hourly cases. Item24 supplies that approval. Neither r95 nor r96 settles r97.

I found **no verified brief error changing this question’s premise**. Rule6 supplies no basis to void it. The following distinctions do not affect my picks:

- The stop report’s extra trailing blank in its CNF-34 diff comes from including the following separator in its extraction. The actual retained-span change is precisely PR60’s insertion.
- The stop report’s statement that frozen retained assertions are in audit scope is evidence of its audit approach, not authority overriding the supplied changed-text ruling.
- Comment861’s historical drift table compares O with `832a219`, not M. I verified its historical spans. It must remain historical evidence.
- Source quotations displayed inside historical or retained text are not universally raw-byte matches; the specific reflows are disclosed below.

**Acceptability, separately from preference.**

| Question | Candidate | Verdict |
|---|---|---|
| Q1 | R-MASTER | **ACCEPT** |
| Q1 | R-PIN | **CANNOT ACCEPT**: unauthorized deletion of adopted conformance assertions |
| Q1 | R-OWNER | **ACCEPT** as the printed conservative hold-and-question alternative; not my preference |
| Q2a | Q-QUOTE / Q-POINTER / Q-KEEP | **ACCEPT / ACCEPT / CANNOT ACCEPT** |
| Q2b | Q-QUOTE / Q-POINTER / Q-KEEP | **ACCEPT / CANNOT ACCEPT / CANNOT ACCEPT** |
| Q2c | Q-QUOTE / Q-POINTER / Q-KEEP | **ACCEPT / ACCEPT / CANNOT ACCEPT** |
| Q2d | Q-QUOTE / Q-POINTER / Q-KEEP | **ACCEPT / ACCEPT / ACCEPT** |
| Q2e | Q-QUOTE / Q-POINTER / Q-KEEP | **ACCEPT / ACCEPT / ACCEPT** |
| Q3 | S-OUT | **ACCEPT** |
| Q3 | S-BEAD | **CANNOT ACCEPT as an applicable bead disposition**: no qualifying gap demonstrated |
| Q3 | S-FIX | **CANNOT ACCEPT**: no complete authorized replacement supplied |
| Q4 | L-BRIEF | **ACCEPT** |
| Q4 | L-NOTE with supplied appendix, no duplicate-form addition | **ACCEPT** |

I also **ACCEPT** the exact R-MASTER comment sentence, its complete placement, `authority-replacement.txt`, and the corrected Desired behavior heading.

The complete `run-R-MASTER-Q-QUOTE.md` and matching comment example are **ACCEPTABLE**, including their d/e Q-KEEP choices, though I prefer the explicit pointers below. The complete Q-POINTER examples are **CANNOT ACCEPT** because of Q2b. The complete Q-KEEP examples are **CANNOT ACCEPT** because of a–c. Original C′ remains an accepted historical approval record, but cannot be copied unchanged as an executable restoration instruction at M.

R-OWNER reserves the question whether item24’s exact phrase **“at their pinned bytes”** requires restoring CNF-34 despite item7’s adopted fixture. I consider that question reconcilable as wording through R-MASTER; I find no substantive conflict that necessarily requires owner referral. Accepting the conservative escalation alternative does not authorize R-PIN.

**Q1: retain current master.** The strongest contrary argument is that item24 approved an exact hashed form whose instruction expressly says **“at their pinned bytes.”** A manager should not silently reinterpret that instruction. R-MASTER addresses this objection openly: it changes the executable instruction, preserves the original approval record, and distinguishes historical comparison bytes from current retention.

The archived owner question also says:

> The implementation agent must read the then-current owners and reconcile any concurrent changes before applying the approved blocks.

R-MASTER preserves both adoptions. R-PIN would remove item7’s fixture without any supplied authority to do so.

My independent retained-block comparison is:

| Retained site | Location at M | Result against O |
|---|---|---|
| WIR-17 field-rules opening | `13-wire-contract.md:683` | Exact contiguous bytes |
| CNF-18 | `10-conformance-checklist.md:124` | Exact contiguous bytes |
| CNF-19 | `10-conformance-checklist.md:137` | Exact contiguous bytes |
| CNF-34 | `10-conformance-checklist.md:256` | PR60 insertion only; original lines preserved in order |
| CNF-182 Robot case | `10-conformance-checklist.md:2484` | Exact contiguous bytes |
| CNF-342 acknowledgement paragraph | `10-conformance-checklist.md:4476` | Exact contiguous bytes |
| CNF-344 channel case | `10-conformance-checklist.md:4531` | Exact contiguous bytes |

Thus other retained blocks moved in **line position** where shown, but none changed content.

I read PR60’s source diff and checked its complete insertion. R-MASTER retains:

- Stored `acknowledge_destruction` present but false after admission with true.
- Ordinary trusted provenance, `restore_markers_untrusted false`, initially null markers.
- Validation before either marker write.
- `invalid_request`, `/acknowledge_destruction`, non-retryable error and operation view, `failed`, no driver call, null markers, `disk_effect none`, `rescue_exit none`.
- The proposed execution writing the rescue marker false before validation must fail the ordering assertion even before dispatch.
- The explicit prohibition on hiding that execution by clearing the marker or synthesizing `rescue_exit none`.
- The conditional, identified api-written install-field arm, with `conflict/incomplete_record`, retryable true and the same before-both-markers assertions.
- No invented api-written field, and the complete-record positive control.

The accompanying retained OPS-23 obligation says:

```text
On an install, every check repeated under this requirement, whether it checks for a missing
required field or validates a present caller-supplied or api-written value, MUST finish
before either `OPS-45` marker is written
```

R-PIN leaves that obligation but deletes the explicit conformance demonstration that catches the marker-first proposal. That is a concrete **check-strength loss**, not an editorial reconciliation.

**Q2: exact selected replacements.** These are the supplied candidate bytes, with their LF and indentation preserved.

Q2a — **Q-QUOTE**:

```text
The configuration half is `DOM-10`'s gate on the create's ordering capability (`DOM-16`); `DOM-10` says “Every operation with a capability MUST be gated on it before the
driver is called, **including create**”. At admission, step 5d is the gate: `API-7` says “**gate a create on its ordering capability** under `DOM-10` (`PRV-10`, `DOM-16`). A refusal stops here and is not collected by the tail”. At claim, step 3 is the gate: `OPS-43` says “Repeat boundary validation under `OPS-23`: "Validation that was performed at the API boundary
   MUST be repeated in the worker before the driver is called". This includes `PRV-10`'s
   "explicit purchase acknowledgement", `PRV-8`'s "at least one SSH public key", the missing-field
   checks defined in `OPS-23`, and `DOM-10`'s gate on the create's ordering capability, which is
   `PRV-10`'s "the account is configured to allow ordering". The checks on caller-supplied fields
   run first, then the checks on fields the `api` wrote at admission, then the capability gate”.
```

The configuration half and ordering-capability identity remain in the opening clause; DOM-10 remains its owner; admission/API-7/step5d and claim/OPS-43/step3 remain explicit. The quotations provide evidence without adding a new fixture or changing precedence.

Q2b — **Q-QUOTE**:

```text
Until 2026-09-05, `API-15` said “purchase acknowledgement in its provider options, in addition to the account being
configured to allow ordering (`PRV-10`).” (revision `7116e90b9932211c08f2e712690cc176b56edea6`); at that same revision, `WIR-17` said “`acknowledge_purchase` MUST be literal
`true` (`API-15`, `PRV-10`).” and placed the acknowledgement at the top level in this create body: “{
  "provider_account": "hetzner-cloud-1",
  "offer": "standard:cx32",
  "region": "fsn1",
  "hostname": "worker-1",
  "image": null,
  "ssh_public_keys": ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIexamplekeyxxxxxxxxxxxxxxxxxxxxxxxx"],
  "user_data": null,
  "labels": {"team": "batch"},
  "runway_seconds": 2592000,
  "max_commitment_sats": 90000,
  "acknowledge_purchase": true,
  "provider_options": {}
}”. The wire contract wins, and a spending authorization nested inside a driver-private object is one a strict server could not tell from any other option.
```

`7116e90…` is the parent of the September5 correction `b278433…`. At that revision, the API-15 text and WIR-17 body coexist: the acknowledgement is a sibling of `provider_options`, not inside it. This establishes the **historical** discrepancy. Current WIR-17 alone would not.

The old provider-options wording, historical top-level location, wire precedence and driver-private ambiguity rationale all survive explicitly. Q-POINTER loses the explicit historical top-level assertion. Its current first sentence cannot establish where the field was at the historical revision. That rejection concerns preservation of adopted historical meaning; I do not claim a changed runtime verdict from that omission.

Q2c — **Q-QUOTE**:

```text
While it is still queued and unclaimed, restart with a descriptor for that account that
      removes only `list_offers`, keeping the ordering capability declared and the driver's
      List offers code path answering, so the test proves the gate exists, as `CNF-19` does (`CNF-19` says “Create is refused when the provider has not declared the matching
      provision capability — with the driver's internal ordering flag set to permissive,
      so the test proves the outer gate exists.”).
```

Queued/unclaimed timing, restart, removing only `list_offers`, retained ordering declaration, answering implementation, gate demonstration and comparison to CNF-19 all remain. Q-POINTER also preserves these through its explicit demonstration and comparison-owner pointer. I prefer the quoted form because it preserves the original comparison’s words.

Q2d — **Q-POINTER**:

```text
**PRV-10** For a paid create (`DOM-16`), create MUST reject the request unless the
request carries an explicit purchase acknowledgement (top-level
`acknowledge_purchase`; wire owner: `WIR-17`), *and* the account is configured to allow ordering.
```

Q2e — **Q-POINTER**:

```text
**API-15** A paid create request (`DOM-16`) MUST carry an explicit purchase
acknowledgement — top-level `acknowledge_purchase`; wire owner: `WIR-17` — in addition to the account being configured to allow ordering (`PRV-10`).
```

Both preserve paid-create scope, explicit acknowledgement, top-level field location, WIR-17 ownership and account opt-in. PRV-10’s following **“Both, not either.”** stays untouched; API-15 retains **“in addition to”**.

For d/e, I also accept Q-KEEP: these sentences state their own prospective MUST and identify the wire-owned field. They do not narrate what WIR-17 previously said or did. API-15’s PRV-10 citation similarly points to the companion authorization owner. This is the demonstrated non-application of the source-summary rule—not an exemption for inherited wording or successful gates. I prefer Q-POINTER because it makes that ownership function explicit. The exact Q-QUOTE alternatives are also acceptable evidence additions, although their literal-true quotation is not itself evidence of JSON nesting.

**Quotation identity and interactions.** I checked every Q-QUOTE outer payload directly against its stated Git revision, without whitespace normalization:

| Payload | Source | Raw UTF-8 bytes |
|---|---|---:|
| Q2a DOM-10 | M, `01-domain-model.md:515` | 103 |
| Q2a API-7 selected excerpt | M, `04-api-contract.md:241` | 135 |
| Q2a OPS-43 selected excerpt | M, `03-operation-lifecycle.md:797` | 571 |
| Q2b historical API-15 | `7116e90…`, `04-api-contract.md:919` | 123 |
| Q2b historical WIR-17 rule | `7116e90…`, `13-wire-contract.md:506` | 67 |
| Q2b historical create body | `7116e90…`, `13-wire-contract.md:490` | 403 |
| Q2c CNF-19 | M, `10-conformance-checklist.md:137` | 204 |
| Q2d/e optional WIR-17 quotation | M, `13-wire-contract.md:683` | 67 |

The selected API-7 and OPS-43 excerpts stop before their source periods; their bytes match exactly. The packet’s longer source payloads, including those periods, also match.

Separately, these inherited/display quotations are **not** raw direct-owner matches:

- CNF-34’s WIR-17 quotation replaces the source LF before `` `true` `` with a space.
- CNF-34’s accepted-price quotation reflows OPS-43’s LF between “its” and “currency”.
- CNF-34’s API-14 quotation adds a display LF and checklist indentation inside “explicit destructive acknowledgement”.
- OPS-43’s nested OPS-23 quotation has different line wrapping from OPS-23 itself. Q2a’s **outer OPS-43 quotation is exact**; this does not make that nested quotation raw-identical to OPS-23.
- The historical WIR-17 quotation in comment861:298 is reflowed.
- The original historical phrase `"In its provider\noptions"` changes capitalization and wrapping from the pre-correction API-15 source. Q2b’s selected executable correction uses the actual historical source bytes.

CNF-342’s quotation **“Repeat boundary validation under `OPS-23`”** is directly byte-exact. None of these disclosures authorizes editing retained or historical text.

I inspected the combined selections in memory. The a/d and b/e targets are disjoint. “Both, not either.”, the historical italics, and the following CNF-364 worker assertions survive. Both PRV-10 phrases quoted by OPS-43—**“explicit purchase acknowledgement”** and **“the account is configured to allow ordering”**—remain intact. The historical create-body example does not become a current runtime fixture.

For reproducibility, replacing only d/e in the supplied Q-QUOTE examples with the selected Q-POINTER targets yields:

- Executable form: 18,210 bytes; SHA-256 `c782dbfa7ec9db145f34705c699bf63d4cf544dac38f8bec1ca65243dc795a55`.
- Comment861: 26,237 bytes; SHA-256 `0aa180115ac0f706860c216f60160f1068a1fcdcc7e64b5207c33daf02e54bbc`.

These are in-memory comparisons, not written artifacts. They introduce no additional sentence repair. Any later semantic alteration needs another reading.

**Complete attribution inventory.** Locations below refer to original C′ and original decoded comment861; this explicit inventory is the source of coverage, rather than an inferred count.

| C′ / comment861 | Content | Classification and disposition |
|---|---|---|
| 10–17 / 64–71 | DOM-16 definition, capability condition, descriptor and acknowledgement references | Package’s own prospective rule; DOM-16/PRV-44/API-15 owner pointers |
| 23–25 / 77–79 | PRV-10 paid-create MUST and wire field | Q2d ownership boundary; select POINTER |
| 25 / 79 | “Both, not either.” | Local dual-authorization rule |
| 26–27 / 80–81 | Configuration gate attributed to DOM-10/API-7/OPS-43 | Source-content summary; Q2a QUOTE |
| 33–35 / 87–89 | API-15 paid-create MUST, wire field and PRV-10 reference | Q2e ownership boundary; select POINTER |
| 35–38 / 89–92 | Historical API/WIR placement contrast and rationale | Source-content summary; Q2b QUOTE |
| 44 / 98 | Configuration catalogue row | Local catalogue entry; DOM-16 definition/owner pointer |
| 50 / 104 | Create matrix row | Bare “see DOM-16” pointers |
| 56–57 / 110–111 | DEF-17 purchase/requeue history | DEF-17’s own historical assertion; DOM-16 definition pointer |
| 124–141 / 178–195 | CNF-55 base assertions, gate positions, exclusion references | Prospective conformance obligations; cited owners locate the checks |
| 143–173 / 197–227 | Hourly fixture and its outcomes | Prospective fixture obligations; sale limitation restricts this fixture’s authority, rather than paraphrasing PRV-13b/PRV-31 |
| 175 / 229 | CNF-55 amendment note | Local amendment history |
| 207–211, 214–222 / 261–265, 268–276 | CNF-364 setup, worker outcomes, owners and amendment | Local fixture assertions and owner pointers |
| 212–214 / 266–268 | “as CNF-19 does” | Source-content comparison; Q2c QUOTE |

The retained/historical boundary is:

| C′ / comment861 | Content | Disposition |
|---|---|---|
| 63–64 / 117–118 | WIR-17 field rules | Retained normative owner text |
| 70–81 / 124–135 | CNF-18 table/descriptor references, CNF-20 methods and CNF-19/CNF-55 coverage attribution | Inherited retained text; Q3 S-OUT |
| 87–89 / 141–143 | CNF-19 outer-gate fixture | Retained local conformance rule |
| 95–118 / 149–172 | Printed old CNF-34 | Historical comparison under R-MASTER; current complete CNF-34 retained |
| 181–186 / 235–240 | CNF-182 acknowledgement/opt-in description | Inherited retained text |
| 192–201 / 246–255 | CNF-342 acknowledgement fixture | Inherited retained text and existing quotation |
| 228–233 / 282–287 | CNF-344 descriptor/alarm/capability text | Inherited retained text |
| — / 22–50 | Current behavior fences | Exact historical O quotations, including Q2b’s occurrence at 41 |
| — / 294, 298, 302, 306 | Quoted approval/tally passages | Unchanged provenance; 298 receives the supplied historical label and separate current guidance |
| — / 308–331 | Drift table and comparison record | Historical comparison to `832a219`; not a claim about M |

The new authority statement, retention directive, current-guidance sentence and dated appendix describe execution/provenance. Their requirement-content fragments—**“On separate creates”** and **“complete, valid resource-offer”**—are exact quotations. I found no further executable source-summary sentence needing an unprinted repair.

**Preservation of the approved package.** The following assertion map remains intact:

- **Wire and worker breadth:** WIR-17 retains its unconditional literal-true MUST. CNF-34 retains **“On separate creates”**, including its api-filled-field arm; CNF-342 retains **“complete, valid resource-offer”**. Neither acquires a paid-create-only restriction.
- **CNF-55 original cases:** ordering-off discovery omission; acknowledgement-true refusal at API-7 step5d; HTTP501/unsupported/account/capability/non-retryable details; deliberately low balance with no tail refusal or not-checked fields; no operation or commitment; stored same-key/same-body replay; resource-offer exclusion acquisition; queued/unclaimed restart changing only the flag; step3 error/view agreement, failed settlement, full release without setup-fee/first-unit debit, release of the same exclusion, and no provider request including List offers.
- **Hourly setup:** fresh admission keys; otherwise valid sellable hourly catalogue offer; positive recurring provider price, no setup fee; healthy assigned `provision_virtual` account; unrelated admission conditions satisfied; internally permissive driver with create/billing counters; no live-sale authorization.
- **Hourly ordering-off case:** listing omits `provision_virtual`; step5d HTTP501/unsupported with account/capability details and retryable false; no operation, commitment or provider request; zero driver creates and billing starts.
- **Hourly acknowledgement cases:** with ordering enabled, omission and false are separate cases; each produces HTTP400/invalid_request, `/acknowledge_purchase`, retryable false, no admission/provider effects and zero counters.
- **Hourly positive control:** both authorizations true, fresh key, exactly one driver create and one simulated billing start.
- **Hourly flag-change worker case:** admitted with both true, queued/unclaimed restart changing only the flag; step3 unsupported and matching non-retryable error/view details; failed, full release, no setup-fee/first-unit debit, no provider request or List offers, zero counters; no resource-offer exclusion.
- **Hourly stored-field worker case:** separate admitted create, ordering enabled, only stored acknowledgement removed; step3 invalid_request with field pointer, non-retryable error/view agreement, failed, full release without debit, no provider/List-offers request and zero counters.
- **CNF-364:** both authorizations remain explicitly true before removal of only `list_offers`. The ordering capability remains declared and the driver path answers. Its step4 unsupported verdict, details, error/view agreement, absent tail fields, failed settlement, full release, exclusion release and prohibition on List offers/key upload/order remain unchanged.
- **PR60:** the complete assertion set listed under Q1 remains unchanged at M.

No obligation beyond items4+24 is added to pv-9ecf. Item7 supports retaining already-landed PR60 text only. Quotations provide evidence; they introduce no new runtime assertion. No Lean declaration, proof, guard, gate, negative control or fixture is changed.

**Q3 and Q4.** S-OUT preserves the inherited CNF-18 sentences under the supplied changed-text ruling. The rule is not waived: the coverage attribution remains unquoted inherited prose, while the method count already names its list owner. I found no traced behavior, requirement or check-strength gap qualifying for S-BEAD, and no authorization to replace expressly retained CNF-18 text.

L-NOTE keeps the approval history honest by appending the supplied dated execution qualification after the unchanged original form. I verified the prospective archive is exactly **original bytes + supplied appendix**. The appendix starts with two LF bytes and has SHA-256 `40480a93445c3699dce04eac8687193d037dec03ed46fdaa49f9773a983d55d2`.

The duplicate `r89/r89b/form-Cprime.md` remains unchanged. I require no additional note there: the corrected authority statement expressly labels it the original historical approval record. Archive r97 so the supplied relative link resolves. Historical approval and later executable corrections must remain distinguishable; the modified executable form must not retain the “verbatim” approval heading.

**Separate classifications for my picks**, relative to approved C′ plus the current independently adopted retentions:

| Pick | Behavior | Requirements / owner4+24 / C′ meaning | Check strength |
|---|---|---|---|
| R-MASTER | WORDING-ONLY | WORDING-ONLY | WORDING-ONLY |
| Q2a Q-QUOTE | WORDING-ONLY | WORDING-ONLY | WORDING-ONLY |
| Q2b Q-QUOTE | WORDING-ONLY | WORDING-ONLY | WORDING-ONLY |
| Q2c Q-QUOTE | WORDING-ONLY | WORDING-ONLY | WORDING-ONLY |
| Q2d Q-POINTER | WORDING-ONLY | WORDING-ONLY | WORDING-ONLY |
| Q2e Q-POINTER | WORDING-ONLY | WORDING-ONLY | WORDING-ONLY |
| S-OUT | WORDING-ONLY | WORDING-ONLY | WORDING-ONLY |
| L-NOTE | WORDING-ONLY | WORDING-ONLY | WORDING-ONLY |

The strongest contrary case favors R-OWNER’s strict treatment of exact adoption, shorter owner pointers instead of lengthy quotations, and L-BRIEF’s avoidance of another archive qualification. Those are genuine alternatives, not my votes. My actual selections preserve the explicit historical assertion, expose source evidence for the reported summaries, retain PR60, and distinguish approval from execution.

No files, Git state, tracker or panel records were written. HEAD remains M and the tracked diff is empty. I ran no gates, builds, provider calls, internet access, subagents, Run, tally, owner question or follow-on round.