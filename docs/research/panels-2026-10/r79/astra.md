**E-KEEP: ACCEPT. E-TOTAL: AMEND. E-SPLIT: ACCEPT. Preference: E-KEEP.**

Reviewed the complete candidates at pin **3c214c147021a90d4ba5a74269b8bd4adc389670**. The substantive review is saved in [astra.draft.md](/var/tmp/provisiond-panel-r79/astra.draft.md). Acceptance of E-SPLIT is package acceptability, not authorization to apply it.

**Certificate and failure story.** Let `g` be the real generation instant, `c` the source-clock reading then, and `s` its represented timestamp, expressed in a common time frame and units. The prospective STO-54 certificate is:

> “A non-null b MUST certify that every source-history component commit acknowledged before b belongs to recovered committed history.”

That is the governing obligation in [application line 49](https://github.com/douglaz/provisiond/blob/3c214c147021a90d4ba5a74269b8bd4adc389670/docs/research/panels-2026-10/r74/decisions/pv-3jw6.md#L49).

For a proof relying on generation order and the recovered complete prefix, the sufficient inequality is `b≤g`. A commit acknowledged before `b` was inserted before that acknowledgement, therefore before generation and R’s insertion, and belongs to the matching continuous prefix.

Consequently, a total allowance needs `s−g≤e`. A symmetric absolute-error bound suffices but is stronger than necessary. E-SPLIT establishes the inequality through:

```text
c−g ≤ e
s−c ≤ q
therefore s−e−q ≤ g
```

The supplied failure trace checks exactly: `10.0004<10.0005<10.0006<10.0007<10.001`. Clock-only `e=0` produces a false certificate. Subtracting `0.0006` reaches generation; subtracting `q=0.001` reaches `10`.

This trace satisfies the local recipe’s listed predicates but violates the overarching MUST. It is **not a compliant E-KEEP execution**. “Only with” gives necessary conditions, not a sufficient inference. The retained sentence “The earlier-acknowledgement implication is the certificate” reinforces that reading.

I found no normative definition completely resolving representation error. The prior readers’ precision explanations establish review intent, not another normative owner. `WIR-1` says timestamps are emitted “at second precision”; that does not establish this source timestamp’s rounding direction. Finite precision alone proves neither upward error nor its absence.

**Whole-package judgments.** E-KEEP remains safe under its mandatory certificate. Its local sentence invites a mistaken sufficient-recipe reading, but the whole package expressly rejects that inference. I accept it without importing a new definition of `e`.

E-TOTAL improves the explanation but leaves “total error” without an explicit reference instant or direction. Under an absolute-error interpretation, perfect-clock downward rounding from `g=10.0004` to `s=10` requires `e≥0.0004`, yielding `b≤9.9996`. Yet downward-only provenance already supports `b=10` with `e=0`. A one-sided interpretation avoids that unnecessary widening. This ambiguity requires the exact amendment below.

E-SPLIT is mathematically sufficient and explicit. Its separate `q` evidence and changed equation are real costs even without another database field. The decomposition is unnecessary where direct total-error evidence exists, but remains an acceptable, safe choice if separately authorized.

**Behaviour classification.** Crucially, `b≤g` is sufficient, not necessary, for the actual inclusion certificate.

Consider a variant of the supplied trace: R is an abort; no component acknowledgement occurs in `[g,10.001)`; the first missing acknowledgement is at `10.002`. Retained evidence proves that absence and inclusion of every earlier acknowledged commit. With a perfect clock, `e=0`, `s=10.001`, and `b=10.001` satisfy E-KEEP’s local conditions and its inclusion MUST.

Both replacement recipes instead require an allowance of at least `0.0006`, yielding `b≤10.0004`. They no longer accept that same timestamp-derived proof. An independently justified fallback might preserve the numerical endpoint; that does not erase the new recipe hypothesis.

E-TOTAL also replaces clock-error evidence with combined-error evidence. Cancellation between clock and representation errors can support a smaller combined allowance than an absolute clock allowance, changing admitted derivations in the other direction.

Therefore, **both printed repairs are BEHAVIOUR-CHANGE requiring the owner**. These are changes to reporting derivations and proof inputs, while the unknown-permitted recovery policy remains intact. The owner chose:

> “Record the window when it’s proven; otherwise record ‘unknown’ with the reason and let recovery proceed.”

The application also says “Preserve the exact approved package.” Neither statement authorizes every replacement proof recipe.

**Boundary and collateral checks.** Upward and nearest rounding need evidence bounding the possible positive displacement; coarse precision can widen the interval substantially. Verified downward-only representation permits `q=0`. Positive clock displacement hurts a lower bound; negative displacement helps. A signed observed offset is not automatically a verified bound. Perfect-clock `e=0` removes only clock uncertainty.

Unavailable precision evidence does not necessarily defeat an independently established inclusion proof. When the selected endpoint cannot be certified, the package says “persist null for it and say that endpoint is unknown.” It also requires:

> “Known b and f MUST be finite and satisfy b≤f.”

Overflow, nonfinite arithmetic, incompatible units, and inconsistent endpoints cannot justify a finite report. Computational or display rounding must preserve the certificate.

The unchanged outcomes remain explicit:

> “Missing reporting evidence does not hold incident creation, the existing restore procedure or component startup once its existing prerequisites are satisfied.”

> “Continuations reuse the persisted endpoints and evidence unchanged.”

The OVR-19 instruction already includes “the endpoint capture, validation and retention procedure.” Representation provenance fits that human procedure. The current OVR-19 owner says “the rows marked human are procedures the deployment records rather than values the process reads.” Making `q` startup-validated would be another, unreviewed change.

Known-bound fixtures using the timestamp recipe must substantiate the replacement’s total allowance or `q`; byte-identical checklist text does not erase that changed proof input. I found no blocking loss under rule 3: these declared changes are amendments, and no Lean theorem is affected. The package explicitly says “Interval/certificate publication remains outside this model’s scope.” Green gates cannot establish the certificate.

An adjacent upper-endpoint issue remains unchanged. Let real transaction start be `20.0004`, represented event time `20`, and an old-history acknowledgement occur at `20.0002`, before stopping at `20.0003`. Clock-only `e_event=0` yields `f=20`, despite proper stopping order. That violates:

> “A non-null f MUST certify that no component acknowledged an old-history commit after f.”

This is another insufficient local recipe, not permission for a false report. It does not block the whole candidates when read with that MUST. I propose no combined event-clock amendment here.

**Requested counterarguments — not votes.** For keeping E-KEEP: it is the exact approved form; its certificate already rejects the bad example; tightening a sufficient construction can reject useful proofs without strengthening the governing safety obligation.

For the smallest explicit repair: implementers naturally copy an adjacent formula. Explicitly connecting it to the existing certificate can prevent mistakes without requiring a particular decomposition of clock and representation error.

**Exact AMEND to E-TOTAL.** Location: prospective `05-persistence.md`, STO-54 source-record paragraph; [E-TOTAL.md:13](/var/tmp/provisiond-panel-r79/check/E-TOTAL.md:13), corresponding to application line 51. Replace only the first sentence.

Before:

> The last replayed commit-or-abort record's timestamp s can supply b=s−e only with evidence that e bounds the source timestamp's total error, including source-clock error and timestamp precision, quantization and rounding, the timestamp was generated before insertion, and the recovered continuous prefix on matching ancestry contains that complete record.

Replacement:

> The last replayed commit-or-abort record's timestamp s can supply b=s−e only with evidence that e is finite and s−e is no later than the real instant at which the timestamp was generated, with the compared times expressed in the same time frame and units and accounting for source-clock error and timestamp precision, quantization and rounding, the timestamp was generated before insertion, and the recovered continuous prefix on matching ancestry contains that complete record.

**Behaviour changed relative to E-KEEP:** requires the generation-time inequality for this recipe. Relative to absolute-error E-TOTAL, it permits one-sided evidence, including downward rounding without needless subtraction. This is not a verified wording-only repair or acceptance of printed E-TOTAL.

**Cheaper optional AMEND to E-KEEP.** Same prospective location; [E-KEEP.md:13](/var/tmp/provisiond-panel-r79/check/E-KEEP.md:13).

Before:

> The last replayed commit-or-abort record's timestamp s can supply b=s−e only with evidence that e bounds the source clock's error, the timestamp was generated before insertion, and the recovered continuous prefix on matching ancestry contains that complete record.

Complete replacement:

> The last replayed commit-or-abort record's timestamp s can supply b=s−e only with evidence that e bounds the source clock's error, the timestamp was generated before insertion, and the recovered continuous prefix on matching ancestry contains that complete record. These conditions do not by themselves establish the preceding inclusion certificate for the computed b; that certificate applies to b computed from the represented timestamp, including any effect of precision, quantization or rounding.

**WORDING-REPAIR; behaviour unchanged:** every condition and equation remains. It points to the already mandatory certificate without requiring `b≤g` or an independent precision allowance where other evidence proves inclusion. It adequately addresses the sufficient-recipe misreading, while intentionally supplying no complete construction. This optional proposal is not my preferred printed package and is not panel-reviewed.

**Evidence and rule 6.** All supplied quotation hashes matched. Independent comparisons confirmed comment 835 matches the application brief, E-KEEP matches the operative package, and each alternative changes only its specified sentence. Exact rational probes verified the failure and contrasting valid traces.

Both required unpiped gate runs exited 0 with “All gates passed.” Final source status was clean. These are baseline checks, not checks of an applied candidate tree.

No verified premise-changing brief error was found: **apply notes.md rule 6 exactly as written; this prompt adds no void rule**. The examples and criteria consistently distinguish an insufficient recipe from a whole-package violation. No adoption, tracker mutation, implementation, delegation, or subsequent round occurred.

| Complete candidate | Vote | Separate classification |
|---|---|---|
| E-KEEP | **ACCEPT** | No error-definition change |
| E-TOTAL | **AMEND** | **BEHAVIOUR-CHANGE requiring owner** |
| E-SPLIT | **ACCEPT** | **BEHAVIOUR-CHANGE requiring owner** |

**Final preference: E-KEEP.**