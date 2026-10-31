# Panel G r86b tally — 2026-10-30

Pin: `3109b5b44eae17e288cf52aaa976993bd8c5626c`. **apply notes.md rule 6 exactly as written; this prompt adds no void rule**.

**Q1: exact Q1-A selected unanimously; owner approval required. Q2: A-cited/B-cited tied 2–2 after its one consensus round; owner decision required. No further reader round.** The owner queue, in question form with exact option links and each reader's strongest argument, is [owner-questions.md](owner-questions.md). No specification or tracker change is authorized by this tally.

## Admission of outputs and settling rule

Fable, opus, astra and sol each returned a substantive complete answer, exit 0, at the byte lengths in `check/tally-verification.json`. Canonical answers were read whole. Both Claude stderr files are empty; Codex stdout matches its canonical answer apart from trailing whitespace. The Codex stderr streams were scanned in full: their only quota/login-pattern matches reproduce the packet's missing-seat rule, and their terminal output is substantive completion, not failure. Stream receipts are `check/tally-stream-inspection.json`. No top-level draft exists. Grok is missing: HTTP 402 at launch and, per main's supplied receipt, still 402 at 21:13Z. This manager made no further probe. Missing is not a vote.

Notes rule 2 quotes the owner: “a question is settled when at least three agree and more agree than disagree, and a tie comes to you. If grok is down, it falls back to three of four”. Apply that to one exact form, with rule 3's checked blocking-loss condition and rule 6's premise-error condition. Final preference and acceptance remain separate. Historical r86 ballots and requested leave-it-alone arguments are not new votes.

## Q1 — pv-5pmu

| Reader | Explicit r86b pick | Acceptance | Strongest argument; conditions |
|---|---|---|---|
| fable | **Q1-A** | A, C0; not B | The corrected admission obligation defeats claim-only B; A makes local error order explicit while retaining no-call successes, deferrals and marker order. The API-64 read/check/guarded-write interpretation needs no repair. **No condition.** |
| opus | **Q1-A** | A, C0; not B | The base already demands admission rejection plus repeated worker validation; A resolves the remaining fence placement, local error precedence and rescue-check order. It withdraws its historical claim-only acceptance and phase-latitude objection to no edit. **No condition.** |
| astra | **Q1-A** | A, C0; not B | Its funded null-fence retry is a new operator request, so a possible later no-call success does not exempt admission. A preserves already accepted/system attempts' cancellation decisions. Its API-64 read/check/conditional-write reading is implementable. **No condition.** |
| sol | **Q1-A** | A, C0; not B | A correct worker refusal cannot undo a prohibited acceptance. A specifies admission/worker order without replacing cancellation decisions or survived-stop records; a preliminary state read preserves API-64's authoritative guarded write. **No condition.** |

Explicit preference: **A 4; B 0; C0 0**. Acceptance: **A 4; B 0; C0 4**. Both A and C0 meet the acceptance threshold, but every reader explicitly selects A. Recording that unanimous preference preserves their picks; it introduces no manager tie-break. No reader reports a blocking loss against A. The exact selected package is [Q1-A.md](Q1-A.md), identical to the packet at `brief.md:686`.

### Checked traces and substantive cost

- **B's admission loss is verified.** At the pin, `OVR-2` says “the server MUST NOT accept an operation a provider has not declared support for” (`00-overview.md:22`). `OPS-1` says “MUST respond `202 Accepted` with that record” (`03-operation-lifecycle.md:17`). B expressly “enqueues an otherwise valid request even when the running api descriptor lacks that operation's capability” (`brief.md:751`). A valid hard reset without `hard_reset` therefore violates OVR-2 at acceptance under B, before its later worker refusal. C0's literal no edit retains the quoted prohibition; its corrected rationale grants no admission latitude.
- **The retry counterexample was checked, not dropped.** `OPS-41` says “A retry reading the fence null decides from step 3 unless the tenant is suspended now” and, when funded, “it performs the no-mutation abort and settlement above” (`03:1087`, `03:1093`). B could newly admit that retry despite absent delete support; A refuses the new request. All readers now distinguish that invalid admission from an already accepted/system attempt. `CNF-312` specifies “no other admission refusal” (`10:2560`), so this is not a lost CNF-312 success under A.
- **API-64 needs no unread repair.** Its text says “admissible only on an episode in `stalled`” and “by a conditional write guarded on `(id, state = stalled)`”, including a close “after the operator read it” (`04:1052`). All four accept the printed A as requiring read-side admissibility, then capability, then the guarded state-change/enqueue transaction. Non-stalled when read gives state refusal; stalled with missing support stops before writes; a supported request can lose the conditional-write race. No reader conditions its pick on adding these explanatory steps to the source.
- **A adds normative ordering.** The base's `DOM-10` says “before the driver is called” and “There MUST be no operation whose only gate is a driver-internal check” (`01:515`); `OPS-23` says “Validation that was performed at the API boundary MUST be repeated in the worker before the driver is called” (`03:2018`). A fixes additional local error precedence and cancellation fence placement. Do not describe every previous conforming implementation's first error as preserved.
- **Preserved cancellation branches were checked.** `OPS-41` says the restore claim “defers, and writes no fence” (`03:997`), the gone/closed branch “settles the attempt `succeeded`” (`03:1080`), and “the first step that applies decides” (`03:1077`). A puts capability after these outcomes, the funded abort and the paused/no-rate deferrals. When cancellation proceeds, A checks after fence acknowledgement. `OPS-48`'s failed row is `stalled` with fence “**Unchanged**” (`03:1301`); this permits a fenced stall without a provider call, not fence clearing or an automatic retry.
- **Other boundaries were checked.** The operation/capability pairs come from DOM-10's mapping table (`01:522`). `PRV-15` says begin rescue must “initiate the reboot or reset needed to enter it” (`02:722`), so no extra power/reset prerequisite is inferred. `PRV-25` puts PTR comparison “After the ordinary authorization, capability and `API-16` validation” (`02:855`). `CNF-302` asserts `failed`, `rescue_exit: "none"` and rescue marker “**null**” for the pre-rescue refusal (`10:3049`); `CNF-312` retains “settles `failed` with cut-off `conflict`” for its survived-stop prefix (`10:2578`). `API-65` says a manual release has “no driver call to make” (`04:1109`); A adds no gate there and distinguishes operator releases, delete-enqueued releases and suspend children.

The strongest case for C0 is the readers' requested counterargument: the quoted existing owners already protect admission and dispatch, so detailed placement could remain unresolved without introducing another obligation. That is **not** any reader's final pick.

**Disposition: owner approval, not ready-for-agent.** A selects requirement strength/order and observable error precedence. The owner's wording-only precedent applies where there is “no behaviour, requirement or check-strength change”; this package exceeds that precedent. Recommend approval of exact A, with C0 as the reviewed no-edit alternative. No bead label or source was changed.

### Q1 round accounting and packet-shape exception

The user's correction governs: r86 Q1 is void, so r86b is Q1's first valid corrected read. Independently, **r86b already satisfies the user's rule-4 packet-shape exception and serves as Q1's consensus round as well**:

- `brief.md:3` says “Every reader sees all previous answers verbatim” and asks for “a single exact form the others can accept”.
- `brief.md:39` names B's omitted-OVR-2 conflict, corrected C0 and A's API-64 conditional-write question; `brief.md:41` names the funded-retry and preserved-path disagreements.
- Complete A is at `brief.md:686`; complete B at `brief.md:745`, with the exact two pointer insertions expressly incorporated from the same packet at `brief.md:785`; complete C0 is at `brief.md:787`. No off-packet option text is required.
- `brief.md:1333` asks separately for ACCEPT/CANNOT ACCEPT and a final pick, and `brief.md:1335` requires addressing the actual dissent.
- The prior answers are byte-identical to both r86 originals and history copies: fable `brief.md:1343`, opus `brief.md:1460`, astra `brief.md:1606`, sol `brief.md:1718`. Exact byte hashes and answer boundaries are in `check/tally-verification.json`.

A settles either way; no r86c is needed or launched. The old notes/launch record's blanket description of both questions as consensus rounds does not itself establish the exception; the packet evidence above does.

## Q2 — pv-e45e

| Reader | Explicit r86b pick | Acceptance | Strongest argument; conditions |
|---|---|---|---|
| fable | **Q2-A-cited** | A-prime, A-cited; not original A/B or B-cited | Offer-owned kind supports mixed accounts and a retained kind preserves the pre-List-offers worker refusal. It treats the disclosed absent-offer flip and changed Boolean convention as lawful without changing declarations; rejects B's unspecified before-enable detection/history obligations. **No condition.** Its newly authored A-formal is separate, unreviewed and unbuilt. |
| opus | **Q2-A-cited** | A-prime, A-cited; not original A/B or B-cited | Explicitly accepts A's substantive semantic narrowing because proofs and the existing negative control remain non-vacuous. B's gate can ignore a visible opposite offer kind and therefore, in its reading, breach the independent outer gate. **No condition.** It authors no formal repair. |
| astra | **Q2-B-cited** | B-cited only | Neither provisioning capability plus no listing makes the pinned Boolean false; A's true-for-absence convention removes that checked instance without a declaration amendment. B provides a total source, with deliberate single-kind/configuration/history costs; an opposite-kind offer violates B's output contract. **No condition.** |
| sol | **Q2-B-cited** | B-cited only | A's unchanged algebra does not preserve the real absent-offer instance after the input meaning changes. B retains early unsupported and an independent external gate; it accepts enforcement outside Describe capabilities and retained identity state as implementation obligations. **No condition.** |

| Exact printed form | ACCEPT | CANNOT ACCEPT | Explicit final picks |
|---|---|---|---|
| Q2-A | none | all available readers | none |
| Q2-B | none | all available readers | none |
| Q2-A-prime | fable, opus | astra, sol | none |
| **Q2-A-cited** | **fable, opus** | **astra, sol** | **fable, opus** |
| **Q2-B-cited** | **astra, sol** | **fable, opus** | **astra, sol** |

**No settlement: A-cited 2, B-cited 2.** No exact form reaches three-of-four. A-prime is not merged with A-cited, and the first-authored A-formal is not substituted for either. Q2 has used its one consensus round; send the tie to the owner. Launch no further Q2 round.

### Verification of both sides' decisive objections

**Original A/B citation defects are reproduced.** Using the citation checker read-only on reader-applied candidates with the authoritative index published by this turn's successful full same-pin gate, original A exits 1 with its removed API-7 quotation sources; original B exits 1 for the removed gate phrase. A-prime, A-cited and B-cited exit 0. Receipts and full logs are `check/tally-citation-checks.json` and its referenced logs. This also reproduces citation success for Q1-A and its composition with each cited Q2 option. This is a Python citation check, not a full candidate gate or candidate Lean build. Reader counts and all diagnostic strings were checked, not merely their reported exit 0.

**The formal trace is valid; its policy interpretation remains split.** At `Admission.lean:1180`, the input is “whether the account declares the create's ordering capability”; the same docstring says “Machine-kind selection and descriptor construction are outside this model”. `undeclared_ordering_stops_before_tail` (`:1195`) returns `{ refusal := some .unsupported, tail := none }` for every sale/tail input with the guard enabled. The composition says the sale verdict includes “the named offer's absence, including an empty offers set” (`:1206`); `age_preserves_step_5d` (`:1252`) retains the result at every age.

Trace: no provisioning capability, healthy account, no listing, otherwise passing early checks. The pinned function at Boolean false returns early unsupported/no collection. A-cited says “If the offer is absent, run no ordering-capability check” and changes the docstring to supply true; the tail collects absence instead. An unhealthy account can then become the headline. This changed real outcome is verified and is not dismissed because algebra still proves. Fable accepts it as an explicit outside-model convention; opus calls it a substantive narrowing but accepts the printed amendment; astra/sol require representation in a declaration/theorem. Their ADR-0025 citation is accurate: adding “any other hypothesis to an existing theorem, or narrowing its conclusion” is a weakening (`ADR-0025:192`). No changed guard, declaration or existing theorem occurs in the printed repair. This manager does not settle that disagreement by reinterpreting the Boolean or weakening a theorem.

The existing witness `undeclaredOrderingCreate` uses `offerSellable = true` (`Witnesses.lean:4341`) and the CI control row still points at it (`.github/workflows/ci.yml:912`). Thus the unchanged witness/control does not exercise the absent-offer trace. Both these facts support the readers' descriptions of the existing control; neither proves the contested semantic-preservation claim. No candidate Lean proof or negative control was run here.

**B's driver trace and enforcement costs were checked in full.** A descriptor says virtual/only provision_virtual; an offer says bare_metal; B's descriptor-selected admission/worker checks can pass and reach ordering. The trace also violates B's printed “Every offer returned for the account MUST have that machine kind”. It is not a conforming B driver. Opus treats the visible-kind discrepancy as an independent DOM-10 outer-gate loss; astra/sol treat it as outside the conforming input contract. Fable agrees the contract violation is not by itself that MUST loss, but rejects the configuration assertions as incomplete. DOM-10's “There MUST be no operation whose only gate is a driver-internal check” and CNF-19's permissive-driver fixture (`10:137`) were read. The manager reports the competing scope readings rather than inventing a runtime mismatch check.

Describe capabilities says “MUST NOT perform network I/O” (`02:76`); that method restriction alone does not establish that all separate configuration validation is prohibited. No existing `machine_kind` history record occurs in the pinned persistence specification. `STO-21` permits operational state that “MUST live in named tables” (`05:684`), but supplies no history table and proves no universal impossibility. B requires before-enable rejection plus an immutable retained account identity; enforcement across restarts is a real new obligation. Astra/sol's suggested validation/history mechanisms are feasibility explanations, not additional exact landing text. The launch-driver scope is the list in ADR-0010, not a domain restriction inferred by this tally.

### Other factual claims checked at the pin

- The Offer entity's field is `kind: virtual | bare_metal` (`01:166`); WIR-17's caller fixture (`13:641`) supplies no machine-kind field. A reads and retains the stored offer kind; B adds a distinct descriptor machine_kind. Neither selects from the provider's existing kind.
- `API-7` says an absent offer is “an unsellable offer for every rule in this tail” and “No additional lookup is made for this verdict” (`04:273`). Its rank list starts with the account refusal, then offer-not-sellable, and its age sentence begins “If the tail has collected no refusal” (`04:265`). Both candidates preserve those tail ranks and that age decision. A changes whether an absence enters this tail, not its internal ordering.
- `CNF-55` says “no provider request, including no List offers read” (`10:355`). Both cited forms select the claim gate before step 4. `CNF-364` separately gates that read on `list_offers` (`10:140`). A's retained kind, B's descriptor kind and capability withdrawal were traced through the printed worker sequence.
- `OPS-23` says an API-written missing field fails `conflict` with `details.reason: "incomplete_record"`, `retryable: true` on both views (`03:2026`), and applies the same writer's result to a present-invalid field (`03:2033`). A declares its new kind API-written, including the previous-release missing-field case. A's new live mismatch refusal precedes mutation and follows the existing pre-step-9 full-release/exclusion settlement; the matching existing absence outcome is quoted at `03:845` and its releases at `03:853`.
- `STO-50` says request_summary “is a closed enumeration” and “Nothing else” (`05:559`, `05:577`). A amends that owner and its `request_summary` row (`05:523`). The formal wire field is `offerSnapshot : Option String` (`Wire.lean:552`), which does not model the inner kind. B adds no operation snapshot field, but its retained-identity rule still requires an enforcement mechanism.
- The checklist header says its stored-listing default “qualifies only the admission or success assertion” and a refusal assertion holds “whatever that age” (`10:32`). A's CNF-55 insertion explicitly adds named-offer presence and fresh/old coverage; it does not change this default. No policy from a different running panel is folded into these options.

### First-authored alternative

Fable's `fable.md` section “Alternative Q2-A-formal” adds `step5dPasses`, present/absent theorems and an absence witness on top of A-cited. It is **unreviewed by the other seats and unbuilt**, and its existing declarations remain unchanged. It has one author's acceptance, not a panel settlement. It is recorded as evidence only, not a recommended combination or an extra owner option. No follow-up round is launched for it.

## Rule 6, broken claims and completion

No reader identifies a new premise-changing error in r86b; checking their cited facts confirms no new rule-6 void. Candidate completeness objections and disputed policy costs are reported above, not converted into a manager-added void rule.

Two packet defects are disclosed without voiding the tally:

1. At `brief.md:743`, “The added early admission check does change an unsupported request's observable phase” is overbroad. An otherwise valid caller request accepted despite known missing support already violates OVR-2. All readers rely on the corrected premise at `brief.md:24`, not on treating that invalid old phase as permitted. What A newly specifies is detailed placement/precedence.
2. The evidence label `brief.md:552` starts the formal excerpt at Admission.lean:15; its API-7 quote is actually at line 19, as opus notes. This is a range/quote-line distinction, not a false source quotation.

Fable additionally notes the replacement prose in the persistence table is line-wrapped; preserving one Markdown table row when applying it is formatting only, not an extra semantic condition or a new form. Every final ballot is unconditional.

The authoritative packet/hash/clone/history/source receipts are `check/tally-verification.json`; further source excerpts are `check/tally-extra-source-excerpts.md`. The only changed state files are this panel's records. Main checkout/tracker/branches, manager brief, other panel folders and pre-existing units were not touched. New work this turn consists of this tally's capped base-gate units and local verification/record files. No reader, consistency pass, Grok probe, r86c, PR or implementation was launched.

Entry quota receipt: Claude session 48%, all-models week 65%, Fable week 91% exempt; active Codex gmail WEEK 0%, inactive proton 97%. The active account differs from the historical launch receipt; this manager did not switch, log out or modify accounts. Session reset 2026-10-30 23:00Z; week reset 2026-11-05 15:00Z. No hold.

Initial full **unpiped** `nix develop --command bash tools/check-all.sh` in the panel's clean pinned `../check/spec` clone: `check/gate-tally-before.exit` **0**, with Lean and every gate PASS. Final full-gate receipt follows below. These are base gates; they do not prove either Q2 candidate or Fable's new formal alternative correct.

Both new full unpiped Nix base gates passed, actual exits 0/0, with Lean and every gate PASS. Each admitted at host lake count one; both units used MemoryMax=16G, MemorySwapMax=0, OOMPolicy=continue and null stdin, with runner-exported npm-global-first PATH and panel-local TMPDIR. Receipts: check/gate-tally-before.exit, check/gate-tally-final.exit, their logs, check/tally-gate-final-caps.txt and check/tally-gate-journal.txt. Final pre-gate quota check: Claude session 56%, all-models week 66%, Fable 93% exempt; active Codex gmail WEEK 1%, inactive proton 98%, no hold/account action. No source/candidate change; no full candidate build claimed.
