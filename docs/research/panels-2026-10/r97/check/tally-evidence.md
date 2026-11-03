# r97 independent tally evidence

The executable settlement is incomplete because Q2d/e and Q4 have split preferences. This is an evidence/preservation audit of the unanimously preferred components and the supplied alternatives, not permission to apply a composite form. The source is Git objects at M=2e2cd94637112f20538eb26b141672fedf0ba455; O=3109b5b44eae17e288cf52aaa976993bd8c5626c is C′'s review pin. Main refs are checked by check/tally-verify.py; current byte receipts are check/tally-verification.json. All original C′ line references below apply identically to the external form and both archived copies, whose complete bytes match. The comment embedding starts54 lines later. Decoded comment861 is on physical JSONL row29. No physical JSONL row is edited this turn.

## Writing rule and adoption evidence

Pinned AGENTS passages, including the whole requested ranges:

`````text
**Quote the sentence.** A claim about what another requirement says carries that requirement's own
words. `` `WIR-30` says "The gate reads the copy the machine took at create" `` is checkable;
"`WIR-30` forbids resolving eligibility that way" is an assertion, and assertions of that shape were
false repeatedly on 2026-09-03 — `ddd3df0` and `254fc24` carry the cases and what each one cost.

**Completion:** every sentence asserting what another requirement says carries its quote, and every
list or count names its source instead of restating it.
`````

Owner items4,7,24 as supplied and checked against the owner record:

`````text
4. **pv-9ecf** — Q: "When an account has ordering switched off, which creates should that block?" A: **"Every
   paid create (Recommended)"**. Option text shown: "The switch and the per-request purchase acknowledgement cover
   any create that starts billing, hourly cloud VMs included. 'Orders off' means the account can't spend. Cost:
   cloud accounts also need the switch on, and each cloud create carries the acknowledgement. This is the 10-27
   triage's pick. The exact wording gets a panel read before it lands."
   - Story shown first: a Hetzner Cloud account with `allow_orders` off; one engine reads hourly cloud as not
     "billing per order" and lets a create start hourly billing, another refuses; the four phrases (`DOM-16` "bill
     per order", `PRV-10` "bills on order", `API-15` "order-billed", 00-overview "per ordering account") are
     still undefined at master 3109b5b.
   - Rejected: "Upfront purchases only".
   - Next: exact wording for `DOM-16`, `PRV-10`, `API-15`, the 00-overview row and dependent checklist lines
     (e.g. `CNF-55`) as an explicit property, read by a panel before it lands.


7. **pv-hups (Panel F r85 Q3)** — Q: "pv-hups: must every install re-check finish before the worker writes its
   'rescue may have started' marker?" A: **"Say so for all checks + test (Recommended)"**. Option text: "Form A: the
   timing rule explicitly covers every repeated check, before both markers, plus a test that fails a marker-first
   worker. Picked and accepted by all four readers. Counterargument: the current rules arguably imply it already."
   Rejected: "Say so for one check + test" (C), "Test only, no wording change" (B). Meaning: adopt exactly Q3-A and
   its common fixture as printed in /var/tmp/provisiond-panel-r85/brief.md (OPS-23, CNF-34). pv-hups →
   ready-for-agent with that package as its brief.


24. **pv-9ecf paid-create wording (owner item 4; Panel J r89, consensus round r89b)** — asked short: "Approve C′
    wording plus its added hourly cloud test cases?" A: **"Approve C′ (Recommended)"**. Option text: "4–0: Fable,
    Opus, Astra, Sol. Grok missing (402)." Rejected: "Defer C′" ("No reader recommends it; pv-9ecf stays
    pending."). Adopted: exactly /var/tmp/provisiond-panel-r89/r89b/form-Cprime.md (SHA-256
    be350270318a2752992a9cb199a2a56879249be99f36e7af430bcfe8a1d47a32, pin 3109b5b), including its printed "Hourly
    cloud cases" CNF-55 block; owner relay /var/tmp/provisiond-panel-r89/r89b/owner-questions.md; tally
    /var/tmp/provisiond-panel-r89/r89b/tally.md. Item 4's policy stays as decided. Meaning: pv-9ecf goes to
    ready-for-agent with C′ and both precedents (item 4 and the 2026-10-28 wording rule) as its brief.
`````

The r89 archive's candidate-contract sentence includes “An item marked Retain verbatim is part of that exact candidate and is intentionally not an edit”. The archived r89b owner question says “The implementation agent must read the then-current owners and reconcile any concurrent changes before applying the approved blocks.” Those exact statements support retention as no edit in the presence of independently adopted concurrent work. The r89b tally says “C′ differs operatively from C only by retaining WIR-17's field-rules opening, CNF-34 and CNF-342's acknowledgement paragraph. Its other blocks match C exactly.” This verifies the hourly block's provenance relative to C and prevents misreporting it as introduced only by C′.

## Complete requirement-reference and summary inventory

The list below is this audit's explicit inventory source. “Own” means the package itself gives the prospective rule or conformance assertion; it is not a purported quotation of an older requirement. Ownership pointers are permitted by AGENTS' “One rule, one home; everywhere else points at it.” Step/exclusion pointers inside the package's own explicit test assertions do not independently claim that those owners previously enumerated that fixture.

| C′ line / decoded comment861 line | Reference or attribution | Coverage / disposition |
|---|---|---|
|10–17 /64–71|DOM16 paid-create definition; descriptor PRV44 and acknowledgement API15|Own prospective rule; owner pointers. “hourly or other recurring machine rental; neither a setup fee nor immediate payment is required” remains exact |
|23–25 /77–79|PRV10 own MUST; DOM16 definition; WIR17 field identification|Q2d KEEP/POINTER split; both retain paid scope, explicit/top-level acknowledgement, wire owner and account opt-in; following “Both, not either.” untouched |
|26–27 /80–81|Configuration-half identity attributed to DOM10; API7 step5d/admission; OPS43 step3/claim|Q2a QUOTE unanimously preferred; exact source evidence below |
|33–35 /87–89|API15 own MUST; DOM16; WIR17 field/location and PRV10 companion authorization|Q2e KEEP/POINTER split; own rule with owner pointer, both retain “in addition to” |
|35–38 /89–92|Old API15 provider-options wording; WIR17 historical top-level placement; wire precedence/private-object rationale|Q2b QUOTE unanimously preferred; contemporaneous historical evidence below; old occurrence at comment41 remains within historical Current behavior quotation |
|44 /98|allow_orders catalogue and DOM16|Own catalogue row with definition/owner pointers |
|50 /104|Create matrix “see DOM16”|Bare owner pointers, unchanged by repairs |
|56–57 /110–111|DEF17 second-purchase historical scope, DOM16 definition|Own defect-history explanation; no claim that DOM16 supplies the requeue behavior |
|124–141 /178–195|CNF55 prospective base fixture; API7/OPS43 step labels, PRV42/STO58 exclusions, owner trail|Own complete mandatory assertions, unchanged from adopted C′ |
|143–173 /197–227|CNF55 hourly fixture; PRV13b/PRV31 withholding owners; API7/OPS43 step labels and owner trail|Own adopted assertions; “it does not authorize sale of a live offer withheld under `PRV-13b` or `PRV-31`” restricts this fixture's authority, not a restatement of their sale rules |
|175 /229|CNF55 dated amendment|Same-item amendment history remains |
|207–211,214–222 /261–265,268–276|CNF364 setup, exclusions, step4 outcomes/owners, amendment|Own fixture instructions and ownership locators, unchanged outside Q2c |
|212–214 /266–268|“as CNF-19 does”|Q2c QUOTE unanimously preferred; comparison and all test instructions preserved |
|63–65 /117–119|Retained WIR17 source obligation|Owner text unchanged, including unconditional literal-true rule |
|70–81 /124–135|Retained CNF18 DOM10 table/PRV44 fields; CNF20 method attribution; CNF19/CNF55 coverage|Inherited Retain text; Q3 S-OUT. Source/count named; no inferred drafting exemption for changed text |
|87–89 /141–143|Retained CNF19 outer-gate demonstration|Own retained fixture, no edit |
|95–118 /149–172|Printed retained old CNF34, source quotations and worker assertions|Historical comparison under R-MASTER; actual execution retains full M bytes including PR60 |
|181–186 /235–240|Retained CNF182 API15/PRV10 acknowledgements/flag attribution|Inherited Retain text. PRV10's body does not spell allow_orders; flag identifier is at DOM16. No behavior/check-strength gap established and no edit authorized |
|192–201 /246–255|Retained CNF342 OPS43 quoted step and exclusions|Inherited Retain text, no edit |
|228–233 /282–287|Retained CNF344 PRV5 alarm and descriptors|Inherited Retain text, no edit |
|— /22–50|Current behavior fences incl PRV10 summary and API15 history at41|Exact historical O source text; not executable replacement targets |
|— /294,298,302,306|Quoted r89b approval/tally assertions about wire obligation, CNF34/CNF342 coverage, API15 MUST and approved package|Inherited provenance. R-MASTER adds a historical label and separate current guidance; it does not alter the attributed quote. Link-identity discrepancy disclosed in tally |
|— /308–331|Drift table/983a9dc comparison|Historical comparison to832a219, not M; retained without pretending it proves current byte identity |
|New authority/directive/current guidance/optional dated note|Execution and approval chronology; CNF34 “On separate creates”, CNF342 “complete, valid resource-offer”|Exact short fragments occur in current/pinned owners; no added runtime rule. Q4 landing still unresolved |

No further executable source-content summary requiring an additional candidate was found. The complete literal text is in evidence/form-Cprime.md and evidence/comment-861.md, so this inventory does not replace its source. The source-content summaries Q2a/b/c are covered by exact quotations; Q2d/e are open ownership wording choices, not omitted findings. Every retained/historical attribution is classified rather than silently repaired.

## Exact quote verification

The table is generated from direct byte comparisons, with no whitespace normalization. Actual candidate outer payloads were separately extracted and compared, including the selected API7 and OPS43 excerpts that omit terminal source periods.

| Payload | Revision | Source file:line | Bytes | SHA256 |
|---|---|---|---|---|
|DOM-10|2e2cd94637112f20538eb26b141672fedf0ba455|01-domain-model.md:515|103|df658512a6f6d6ecdb7dce306a85a4bb2f5844a529910a74e048535b381fe79c|
|API-7|2e2cd94637112f20538eb26b141672fedf0ba455|04-api-contract.md:241|136|5afc78f57105c9842175b77ac0d370f0be059408c81fadbb601df60438fccfb1|
|OPS-43|2e2cd94637112f20538eb26b141672fedf0ba455|03-operation-lifecycle.md:797|572|35408350ec4950a2f18bd1fdb08f4d58dfae8958a9c4f58b6c6c7549bc6adfd4|
|CNF-19|2e2cd94637112f20538eb26b141672fedf0ba455|10-conformance-checklist.md:137|204|ddc2e127d3399ad76b1876897fbc3f318a3ab442eafada09f8a1a7d6c7c3940c|
|WIR-17|2e2cd94637112f20538eb26b141672fedf0ba455|13-wire-contract.md:683|67|ab0256762b712c773fc7905504f581c480a2b0dec6ab5fe9648698f8c239aea7|
|historical-WIR-17|7116e90b9932211c08f2e712690cc176b56edea6|13-wire-contract.md:506|67|ab0256762b712c773fc7905504f581c480a2b0dec6ab5fe9648698f8c239aea7|
|historical-WIR-17-body|7116e90b9932211c08f2e712690cc176b56edea6|13-wire-contract.md:490|403|03e9cd3ae27f2f3b56be7ef1a340c8ffa44958ec449929e578c6d13bd0048615|
|historical-API-15|7116e90b9932211c08f2e712690cc176b56edea6|04-api-contract.md:919|123|00f4544f8eb97c64911c6d991f73d60bd4e5431197d93d487138fd70e7e428be|
|selected-Q2a-API-7|2e2cd94637112f20538eb26b141672fedf0ba455|04-api-contract.md:241|135|78a7f7e3a99b55ecf09a5eaa7d58c483fea57c7a255d8bd11fd95eee0cb7b07b|
|selected-Q2a-OPS-43|2e2cd94637112f20538eb26b141672fedf0ba455|03-operation-lifecycle.md:797|571|c518dcfe6e4479cc99d69ad86b39c51137aece2b4c9fbef78a78ba85d8d92838|

7116e90b9932211c08f2e712690cc176b56edea6 is b278433's parent. `git log -S 'in its provider options' -- 04-api-contract.md` identifies the original introduction and September5 removal, not a later invented reconstruction. At that parent the old API wording and the quoted complete create JSON coexist. `acknowledge_purchase` is a top-level sibling of `provider_options`, whose object is empty. The historical italic's new source label prevents a present-day MUST alone being offered as evidence of past nesting. The historical example remains within italic quoted history, not a new runtime fixture.

The exact outer OPS43 quote contains inherited nested quotation wrapping that is not raw-equal to OPS23's direct home. It is exact to OPS43, which is what Q2a quotes. Other inherited displays are not newly certified: CNF34 reflows WIR17's LF before true, OPS43's LF after “its”, and API14's “explicit destructive acknowledgement”; the old API15 historical fragment changes capitalization/wrapping; the historical approval paragraph reflows the wire quote. CNF342's “Repeat boundary validation under `OPS-23`” fragment is exact. None authorizes an inherited edit or invalidates a checked exact outer payload.

## Assertions preserved by every unanimously preferred replacement

| Sentence | Every carried assertion | Where it lands |
|---|---|---|
|PRV10 Q2a|configuration half; identity with DOM10 gate; ordering capability; DOM16 definition pointer; admission/API7/step5d; claim/OPS43/step3|Same opening identity/definition clause; explicit admission and claim sentences; exact DOM10/API7/OPS43 outer quotes. Both authorizations in the preceding PRV10 sentence remain |
|API15 Q2b|provider-options historical wording until September5; contemporaneous WIR17 top-level placement; wire precedence; strict-server ambiguity of driver-private spending authorization|Historical API15 quote with parent revision; same-revision WIR17 quote plus complete JSON; unchanged meaning of final wire-precedence/private-object rationale. Capitalization is corrected to actual historical bytes |
|CNF364 Q2c|queued and unclaimed timing; restart descriptor; remove only list_offers; keep ordering capability; keep driver's answering code; prove gate exists; comparison with CNF19|All original instructions and comparison remain verbatim apart from sentence punctuation needed for added exact CNF19 evidence |
|Q2d/e options|paid-create scope; explicit acknowledgement; top-level field location; wire owner; account opt-in; dual rather than alternative authorization|Both KEEP and POINTER keep each in the same own MUST; following PRV10 “Both, not either.” and API15 “in addition to” unchanged. No source-content quotation exemption based on gate success is asserted |
|R-MASTER current-retention correction|no conditional weakening of WIR17; CNF34's complete separate-create domain and both missing-field arms; CNF342's complete valid resource-offer domain; no change to any Retain block|Current complete master text retained, not overwritten by the printed old comparison. New current guidance explicitly names preserved short fragments; original approval paragraph stays historical |

Q2a adds source evidence that includes existing field/capability-check ordering, not another independent ordering owner. The PRV10 strings quoted inside OPS43—“explicit purchase acknowledgement” and “the account is configured to allow ordering”—still occur in the prospective PRV10 body. All other replacement blocks remain identical to C′. The quote payloads add no assert, guard or fixture. No theorem/declaration/proof/negative control is edited.

## CNF34 and concurrent PR60

`check/tally-CNF-34-current.md` is exactly the retained current span at M; SHA256 d495bb8e659dcb044dde50d5c6048bdd64e6e76ffbd875f3e0f3062ef5958948. `check/tally-CNF-34.diff` is reconstructed directly from O/M. Its sole delta is exactly the insertion in commit8dd8f48's checklist diff. All other pinned CNF34 lines remain in order. The retention table's source is the direct receipt:

| Retained site | Current line | Byte identity O→M |
|---|---|---|
|WIR-17 field rules opening|683|Exact contiguous bytes|
|CNF-18|124|Exact contiguous bytes|
|CNF-19|137|Exact contiguous bytes|
|CNF-34|256|Only PR60 insertion; original lines in order|
|CNF-182 Robot test-mode case|2484|Exact contiguous bytes|
|CNF-342 acknowledgement paragraph|4476|Exact contiguous bytes|
|CNF-344 channel declaration is no capability grant|4531|Exact contiguous bytes|

Complete PR60 inserted fixture, whose adoption source is owner item7:

`````text
      Repeat the install caller-field fixture with acknowledge_destruction present but
      false in the stored request, after admission with a valid true value. Use ordinary
      trusted marker provenance (restore_markers_untrusted false) and initially null marker
      columns. Assert the repeated validation completes before either marker write and
      rejects invalid_request, details.field /acknowledge_destruction, retryable false on
      error and operation view, failed, no driver call, both markers still null, disk_effect
      none and rescue_exit none. Instrument a proposed execution that writes the rescue
      marker false before this validation, then tries to validate before begin-rescue
      dispatch: assert this execution violates the required ordering even though dispatch
      has not occurred. Do not clear the marker or synthesize rescue_exit none from false
      to make that proposed execution pass. Repeat for a present-but-invalid api-written
      install field only if the release names such a field; identify it and retain
      conflict/incomplete_record, retryable true and the same before-both-markers assertions.
      No api-written install field is invented for the fixture. The complete-record control
      proceeds past validation. (`OPS-23`, `OPS-45`, `API-14`, `WIR-9a`, `WIR-9b`)
`````

Its complete assertion set is visible in that exact source: false stored destructive acknowledgement after valid true admission; ordinary trusted provenance and initially null markers; validation before either marker; invalid_request/field/non-retryable error and view/failed/no driver/null markers/none effects; marker-first negative proposal fails before dispatch and cannot pass by clearing or synthetic output; conditional named api-written field with conflict/incomplete-record/retryable true and same marker assertions; no invented field; positive control. R-MASTER keeps the complete span exactly. R-PIN removes this demonstration and has no supplied authority, while OPS23's broadened timing obligation remains—an actual check-strength loss. No preferred candidate makes that loss.

Every C′ assertion about CNF34 still holds under R-MASTER: missing caller and api-admission-field create cases; their respective invalid_request versus incomplete_record/retryability; error/view agreement; failed/no driver/full release/no fee-unit debit; install missing-field outcomes with untouched markers; conditional api-install field arm; complete-record controls; broad “On separate creates” scope. The original full-byte-identity statement is historical rather than falsely repeated about M.

## Other preserved protections and limits

Whole CNF55 payload identity is checked in both complete example files against the approved C′ payload. This preserves its original exclusion acquisition/release, discovery omission, low-balance pre-tail refusal, same-key replay, queued/unclaimed flag-only restart, full error/view settlement and no provider requests. The Hourly cloud block preserves fresh keys, valid sellable positive recurring/no-setup-fee fixture, healthy assigned account, unrelated conditions, permissive counted driver, live-sale restriction, disabled-ordering refusal and zero counters, separate omitted/false acknowledgements, both-true one-create/one-billing control, worker flag change and stored-ack removal with their exact distinct outcomes, full release/no debit/provider request and no resource-offer exclusion. None is a claim that these runtime tests were executed here.

CNF364 retains both true authorizations before list_offers removal, and all step4/error-view/no-tail/failed/release/exclusion/no-provider-call assertions outside Q2c. WIR17's retained literal-true MUST is unconditional. CNF342 retains the complete valid resource-offer stored-ack fixture. Scope items and closed beads named out of scope by the prompt remain excluded.

## Lone preference traces and non-void corrections

Astra's POINTER preference is an explicit ownership clarification, while its own text accepts KEEP's non-application because the sentences state their own prospective MUST. Opus/Sol also accept POINTER. Therefore no reader's trace says a runtime or conformance verdict differs; only preference lacks three votes.

Opus's L-BRIEF trace was checked end to end: the C′ hash is in the r89 receipt, the r89b validation script asserts original/duplicate equality, and an append necessarily changes only one whole-file hash. The original form remains an exact prefix, and the other duplicate remains byte-identical. The supplied link points to the outcome-rules document. Opus accepts the exact appendix notwithstanding those costs. Astra/Sol accept L-BRIEF too. This leaves two mutually acceptable landings with differing preferences, not a verified blocking loss.

The remaining factual qualifications are recorded in tally.md under rule6. No question's premise changes: protected bytes and all relevant source words were independently verified, and no preference depends on the erroneous “explicitly historical” shorthand, whole-paragraph archive-link identity or claim that C′ first introduced the hourly block relative to C.
