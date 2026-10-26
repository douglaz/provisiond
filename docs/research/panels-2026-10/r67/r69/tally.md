# r69 tally (panel E corrected confirmation: Q1 pv-tcs S-final/F-final; Q2 pv-ytv K candidate). 2026-10-25

Base: `c5f897c32f7894d77a544528872176f241394d0d`. Rules: [notes.md](notes.md), fixed before launch. Inputs: [brief.md](brief.md), [fable](fable.md), [opus](opus.md), [astra](astra.md), [sol](sol.md). r68/tally.md supplies the structure only; no r68 vote enters these counts.

All four exits are 0. Each answer is substantive; none contains a session-limit line (fable 8,546 bytes; opus 9,697; astra 7,260; sol 6,943). Opus discloses running the coverage gate once despite the readers' no-gate instruction; this is recorded, not silently treated as a failed answer. No replacement reader or round was launched.

## Outcome: (c) owner question, separately for both questions

**Q1: S 4 picks / F 0. S has 2 counted ACCEPT / 2 counted CANNOT ACCEPT; F has 0 / 4.** Fable's claimed wording-only S4 replacement removes a process-placement restriction. Opus rejects S for a real coverage regression, which is outside notes rule 3's enumerated blocking losses. Neither printed form is owner-ready under rule 2. Rule 4 explicitly sends the choice with defects to the owner when neither form is ready; the settled cost/latency decision also remains the owner's. This is an owner choice of direction, **not approval or recommendation of a combined S repair**. No verified rule-3 loss on the picked S has been established that would require the pre-owner repair read in rule 4. An exact S repair/coverage candidate needs its own whole-form read before recommendation or implementation.

**Q2: K1–K6 ACCEPT 4 / 4.** The exact printed K-d option gets **3 unconditional takes / 1 take conditional on a new AMEND**. The three original-text takes meet rule 1, and the dissent supplies no verified blocking trace against that original conditional suffix. **Carry K-d exactly as printed under the explicit option rule, without opus's fixture AMEND.** This is the specified K5 extension all readers were asked to judge, not a coordinator-written merger of their AMENDs. The owner question distinguishes the four accepts on K1–K6 from the three takes on K-d; it does not claim four accepts on the extended form. No new text is inferred or recommended.

**Neither tally is void.** The brief repeats one truncated proposed-owner quotation, identified below; it is a wording error, not a changed question premise. Claims about an incomplete F inventory were expressly disclosed as incomplete. The old S-d universal was expressly presented as false archived reader speech. The corrected step-8 account case is correct.

Owner draft: [owner-question.md](owner-question.md). Main should relay this one two-part question, then prepare the scoped whole-form read required by the Q1 direction chosen. Selecting F also requires a complete repair candidate; the F11/F12 fragments below are not one. Do not launch that read from this tally step.

## Q1 (pv-tcs): S-final stored listing versus F-final admission read

### Reader verdicts and picks

BU below means the reader's explicit “behaviour unchanged” mark, not the manager's endorsement.

| Reader | S-final as reported | F-final as reported | Pick | Strongest argument, theirs | Rule-1 S count |
|---|---|---|---|---|---|
| fable | **AMEND, BU**, S2 and S4 | **CANNOT ACCEPT** | **S** | Claim re-tests price already; F adds a provider round trip and exercises credentials on every create, while S states its staleness cost. | **CANNOT ACCEPT**: S2 is wording only; S4 drops explicit process placement. No rule-3 blocking trace against printed S supplied. |
| opus | **CANNOT ACCEPT**, coverage regression; separately S2 **AMEND, BU** | **CANNOT ACCEPT** | **S** | S preserves pre-provider balance/halt/account refusals; price protection remains at claim. | **CANNOT ACCEPT**, non-blocking under rule 3, as opus itself requests if only the enumerated losses count. |
| astra | **AMEND, BU**, S2 | **CANNOT ACCEPT**; separate F5 quotation AMEND, BU | **S** | Bounded stored data removes request-dependent provider latency; storage and periodic traffic are explicit costs. | **ACCEPT** after exact S2 quote verification. Its historical S4 repair remains an explicitly left option. |
| sol | **AMEND, BU**, solely S2 | **CANNOT ACCEPT**; separate F5 quotation AMEND, BU | **S** | Stored data amortizes reads on busy accounts and removes provider latency from admission. | **ACCEPT** after exact S2 quote verification. Its historical S4 repair remains an explicitly left option. |

Fable conditions acceptance on both repairs: the manager cannot keep its S2 and erase its S4 condition to invent a third counted ACCEPT. `00-overview.md:316–321` expressly says “A module is not a process” and that the table “did not say which process hosts a periodic component”. Printed S4 adds “running in the engine process”; fable's replacement omits it. `OPS-50`, `03-operation-lifecycle.md:1983–1996`, covers “every write transaction made in the engine process” and says “Writes made in the api process are not checked.” The replacement is not verified behavior-preserving, even though no checked-loss trace against the printed S follows. This is a failed BU mark under rule 1, not a new rule-3 veto.

**Coverage dissent checked:** applying the exact printed S1–S6 to source copies gives coverage exit 1, **76 uncovered versus baseline 74**. With the exact archived Reader-4 S6 append it returns exit 0, 74 uncovered. The owner is [tools/check_coverage.py:52–60,87–103,123–138](/var/tmp/provisiond-panel-r69/tally-evidence/source/tools/check_coverage.py) and [coverage-baseline.json](/var/tmp/provisiond-panel-r69/tally-evidence/source/tools/coverage-baseline.json): new definitions count, and only backticked checklist citations cover them. Printed S6 cites neither new id. Evidence: [printed log](/var/tmp/provisiond-panel-r69/tally-evidence/coverage-printed.log), [exit](/var/tmp/provisiond-panel-r69/tally-evidence/coverage-printed.exit), [with-S6 log](/var/tmp/provisiond-panel-r69/tally-evidence/coverage-with-S6-proposal.log), [exit](/var/tmp/provisiond-panel-r69/tally-evidence/coverage-with-S6-proposal.exit). **This is real, but not a flipped CNF/Lean assertion or traced MUST/SHOULD under the fixed panel gate.** Do not silently expand that gate. The S6 append adds assertions and cannot ride as wording only. Its four takes do not certify an assembled S2/S6/other-fix form nobody read whole.

### Verified gated losses against F-final as printed

All readers' shared trace is valid: pass 5d → successful admission driver read under F1 → balance or local-closure refusal in the tail → no admitted operation. `04-api-contract.md:245–248,262–291` places operation creation at admission and says “A refused tail MUST commit nothing”. F10 changes another owner.

| Surviving owner/check | c5f897c evidence | Result |
|---|---|---|
| `OPS-35` | `03-operation-lifecycle.md:30–33`: “The provider account MUST be resolved and written to the operation record **before** any driver call.” | Verified MUST loss; no record exists before the read. |
| `OPS-11` | `03-operation-lifecycle.md:256–263`: admission-only kinds “are decided before any driver call”. | Verified MUST-context loss for insufficient balance or halt decided after the read. |
| Schema quotation | `05-persistence.md:441`: “The `provider_account` write retains `OPS-35`'s \"before any driver call\".” | Surviving contradictory statement; another synchronization span is needed. |
| `CNF-31b` | `10-conformance-checklist.md:235–239`: “Admission-only inputs remain pre-provider” and “a local `PRV-40` closure is a pre-provider refusal”. | Verified unlisted CNF flip, including when mutation acceptance remains false. |

Fable's additional **CNF-307/CNF-278** concern is a valid reachable refusal-precedence loss, not proof that every read on an unhealthy account necessarily returns its alleged kind. `CNF-307`, `10:1214–1230`, asserts the collected unhealthy-account refusal, retryability and envelope. `CNF-278`, `10:2789–2794`, asserts “a create naming it is `409` `state`” for all three unhealthy statuses. F1 requires a read before that status check; choose a provider transport failure there and F1 returns `network` before the tail instead. The printed F3 relaxes the no-call sentence, not these assertions. Thus these are additional unlisted flips on such an execution. Successful reads can still reach the original status refusal; `terminated` alone does not prove provider credentials are invalid.

**Opus's separate PRV-41 claim is not a forced trace.** `02-provider-contract.md:1246–1248` says an authentication failure is “terminal for that credential” and “MUST NOT re-attempt it on a schedule”. F1 does not establish that every driver invocation retransmits a stopped credential: a driver can enforce that terminal stop locally. A known rejected credential must not be retried, but the asserted universal “every create re-sends” is not derived from F1. This does not remove the verified F losses above.

Both F11 alternatives and Reader-2 F12 add exceptions outside the printed inventory. They leave the schema/CNF-31b disposition incomplete; the additional unhealthy-account cases also need disposition. They are **behaviour changed**, regardless of the archived BU labels. If the owner selects F, the next full candidate must state every intended exception and changed assertion; no complete F replacement was supplied by this panel.

### Q1 options: r69 counts, no inferred mergers

| Option | fable | opus | astra | sol | Result |
|---|---|---|---|---|---|
| S-a numbered staleness step | take | take, payload changed | leave, lost admitting-transaction timing | leave | **2 take / 2 leave; does not carry** |
| S-b combined storage/refresh owner | leave | leave | leave | leave | **0 take** |
| S-c offer-input MUST | leave | leave | leave | leave | **0 take** |
| S-d admission capability refusal | take Reader 2, including retained fresh row | take Reader 2, including retained fresh row | leave both | leave both | **2 take / 2 leave; no variant carries** |
| F-a failed-read text | Reader 3 | Reader 3 | Reader 3 | Reader 3 | **Reader 3: 4; printed/Reader 4: 0** |
| F-b purchase-write qualifier | leave | leave | leave | leave | **0 take** |
| F-c second CNF-283 sentence | printed | Reader 3 | Reader 3 | Reader 3 | **Reader 3: 3; printed: 1** |
| F-d omit “the create's” | leave | leave | leave | leave | **0 take** |
| F-e offer-input MUST in F | leave | leave | leave | leave | **0 take** |
| F9 quotation sync | take | take if F | take | take | **4 take, conditional on F where stated** |
| F10 OPS-1 exception | take only if F; calls it new exception | take if F | take, insufficient | take, behaviour changed/insufficient | **4 take with qualifications; already in printed F** |

F-a/Reader 3 and F-c/Reader 3 reach the option threshold; these do not repair the other F owners. F-c/Reader 3 removes a separate alarm ambiguity: `PRV-5`, `02:52–55`, says “every Robot `403 RATE_LIMIT_EXCEEDED` MUST raise a monitorable alarm” for reads too. These are precisely supplied variants, not a new manager combination, and no repaired whole F is recommended from them.

| Separate r68 proposal | fable | opus | astra | sol | Result/disposition |
|---|---|---|---|---|---|
| R1 S3 | leave | leave | leave | leave | **0 take**. “after an authentication failure” can outlive a cleared stop; do not replace printed exception. |
| R1 S4 row adoption | leave original; its new S verdict supplies the corrected row | take with coordinator correction | leave | leave | **1 explicit option take**. Fable's proposed use is separately disclosed, not converted into an option take that it expressly said leave. |
| Coordinator S4 quote correction, independently | supplies same exact repair | takes corrected row | take repair only, leave row adoption | leave | Repair text is authentic; adoption does not carry. Correcting the quotation does not preserve deleted process placement. |
| R1 S-d | leave | leave | leave | leave | **0 take** |
| R1 F11 | leave | leave | leave | leave | **0 take** |
| R2 F11 | take | take | take | take | **4 take; exception, not BU; incomplete F** |
| R2 F12 | take | take + Lean quote sync | take | take | **4 take; exception, not BU; incomplete F** |
| R2 F7 required account detail | take | take | take | take | **4 take; adds an assertion; no BU ride** |
| R2 S-d | take | take | leave | leave | **2 take** |
| R3 F5 quote alternative | leave | leave | leave | leave | **0 take** |
| R4 S2 DOM-9 quote | take | take | take | take | **4 take; verified wording-only repair** |
| R4 S6 conformance append | take, says existing duties | take, coverage cure | take, explicitly added assertions | take, behaviour changed | **4 take; assertions, not BU; no assembled S repair recommended** |
| R4 F5 quote alternative | take | take | take | take | **4 take; verified wording-only repair** |

### Claims checked, including minority positions

All file:line references in this tally refer to the base snapshot, not line numbers after an application. [source-checks.txt](/var/tmp/provisiond-panel-r69/tally-evidence/source-checks.txt) records `rg` first, then `sed` ranges over bytes frozen by `git show c5f897c:<path>`; [snapshot.txt](/var/tmp/provisiond-panel-r69/tally-evidence/snapshot.txt) records the full OID. The below consolidates repetitions across readers without discarding their votes.

- **S-a timing dissent is valid against the option, not against printed S.** S1 says “at the admitting transaction”. S-a moves the check before it and does not retain that instant. Trace: row within age at 5e, expires before admitting snapshot, admission still succeeds. `04:262,291` do support updating the step ranges, but that does not repair the lost timing or make the added `details.provider_account` merely wording. It has only two takes.
- **S-b narrows behavior twice (astra/sol correct).** Printed S3 says “every account declaring `list_offers`”, except the credential stop; S-b says “each healthy account”. Printed S2 says “A failed read MUST leave the row unchanged”; S-b protects only advancing `read_at`. Neither is a verified wording-only substitution. It has zero takes.
- **S-c inventory and F-e sale protection:** printed S1 enumerates the offer inputs; its replacement drops that inventory and has an ambiguous “that result”. All leave it. F1 still says “On create” and names its sole source; unchanged `API-7`, `04:263–275`, requires “collect every applicable refusal once” and the unsellable-offer verdict. The rejected F-d/F-e proposals do not themselves establish a loss in printed F.
- **S-d false universal was already corrected in this brief.** A successful read while capability is present can leave a fresh stored row across a restart that removes `list_offers`; printed S1 then admits. `CNF-364`, `10:138–147`, starts with both capabilities and removes `list_offers` only before claim. `OPS-43`, `03:785`, says “Gate on `list_offers` under `DOM-10`”. Thus the existing fixture remains reachable; no new admission capability gate is implied. The two takes explicitly choose R2 and say its new refusal also applies to retained fresh rows. They do not carry.
- **Error detail field:** `WIR-9a`, `13-wire-contract.md:142`, lists `unsupported` → `provider_account`, `capability`; `DOM-10`, `01:515–519`, says a capability failure names both. This validates R2 F7's detail correction, not its classification as a wording-only assertion addition.
- **Claim-scoped no-request checks do not forbid the later successful publication placement.** `CNF-278`, `10:2812–2820`, and `CNF-364`, `10:138–147`, describe worker refusals. `CNF-55`, `10:341–345`, says “before claim”; `10:4053–4074` uses stored creates. `OPS-43`, `03:767–790`, stops at unhealthy status, closure or boundary validation before the List offers read. No successful read is required in those paths.
- **Claim publication can preserve record-first ordering and read-only drivers.** `PRV-50`, `02:123–124`, says “The driver's List offers MUST be read-only”. S2 publication can be by the caller after successful step 4 and before step 8, which `03:793` calls “the last write before the ordering call”. `03:807` says step 9 begins only after step 8 is acknowledged. No later write between steps 8/9 is required. Opus's proposed caller clarification is wording only by this reconciliation; merging it with other readers' fixes is not silently authorized.
- **F-b narrows an existing protection.** `API-7`, `04:287–288`, says “A refused tail MUST commit nothing”. `CNF-340`'s broader no-write assertion remains justified without replacing “write” with “purchase write”. Every reader leaves F-b.
- **F9 sync:** current `03:276–277` attributes the old clause to `PRV-40`; printed F8 changes that clause. F9 synchronizes that quotation, not the missing admission-ordering exceptions. Every reader now takes it.
- **Price/reserve qualification:** `OPS-43`, `03:855–869`, refuses “where the provider's price has risen past what the reserve covers”. A price rise alone is not sufficient. A provider read at admission also does not eliminate the later claim re-test. The owner story preserves both qualifications.
- **Taxonomy concern:** `01:587` defines `provider` as “Provider returned an error response”. Missing/stale local data need not follow a response. Fable calls this an owner concern, not a vote; no additional rule-3 loss is established by that note.
- **Formal scope:** `tools/formal/Provisiond/Admission.lean:1114–1136` supplies `offerSellable` as a Bool and says “provider failures and post-order terms are outside”. `Tables.lean:69–74` really does quote the admission-only “before any driver call” clause. Opus's proposed docstring sync would have to accompany an accepted F12; it is not a proof that F12 is wording only.

### Against my pick (written on request; not votes)

- **fable:** “F admits and prices on the live listing, so a dropped or re-priced offer never holds a customer's balance until claim” and avoids the new table, sweep, settings and stale-row error. Qualification: it avoids the already-stale-at-admission case, not a later price change after F's own read.
- **opus:** “S can reserve at a price up to one stated age old.” A later claim can fail; refresh/storage/settings cost work and unhealthy-account error precedence can change.
- **astra:** “It spends refresh traffic without customer demand, maintains another stored dataset, and can admit a stale price only to fail at claim.”
- **sol:** “Its ‘stored offer listing’ can admit a create later refused at claim; idle accounts still incur refresh traffic.”

These requested counterarguments do not turn any of their four S picks into an F vote.

## Q2 (pv-ytv): K candidate records the fingerprint on every Robot channel

### Reader verdicts and support

| Reader | K1–K6 verdict | Pick/support | Strongest argument, theirs |
|---|---|---|---|
| fable | **ACCEPT** | **K** | Retained machine fingerprint supports key retention; K3 separates evidence from matching authority. |
| opus | **ACCEPT** | **K** | Makes the retained-machine guard work across Robot channels while K3 prevents automatic matching. |
| astra | **ACCEPT** | **K** | Durable cleanup evidence without automatic matching authority. |
| sol | **ACCEPT** | **K** | Same retained-key trace, preserving operator resolution. |

**Counted ACCEPT 4 / 4; no blocking CANNOT ACCEPT or AMEND on the complete candidate.** K2's payload obligation is now in the complete form they read; it is not being slipped in as wording only. No reader supplies a third complete form.

### Q2 options: exact original option versus proposed fixture AMEND

| Option | fable | opus | astra | sol | Result |
|---|---|---|---|---|---|
| K-a | leave | leave | leave | leave | **0 take** |
| K-b | leave | leave | leave | leave | **0 take** |
| K-c | take candidate K4/R2 | take candidate K4/R2 | take candidate K4/R2 | take candidate K4/R2 | **4 take**; R1/R3 alternatives do not carry |
| K-d as printed | take | take **with fixture AMEND** | take original | take original, calls it added assertion | **3 unconditional takes**; original option carries under rule 1, subject to dissent verification below |
| Explicit completed-fixture addition | no AMEND needed | requires it, marks BU | leave explicit addition | no AMEND needed | Only opus proposes this new text; **does not ride** |

Opus is not counted as accepting the unamended option. Nor is its changed fixture merged into the other three readers' text. Carrying the exact preprinted K-d option follows its explicit three-of-four rule; it is not a BU exemption for a newly supplied AMEND. If main elects to incorporate opus's fixture change later, that different candidate needs a whole-form read.

### Verified mechanics and the lone K-d dissent

- **Step-8 timing:** `05-persistence.md:441` says “Written in `API-63`'s correlator transaction, which is `OPS-43`'s step 8”. `03:791–812` puts provider-side registration/order after acknowledgement. K2 can generate the key locally before step 8 without an early registration. K4 asserts a null pair where step 8 did not commit, fingerprint where it did. `CNF-278`, `10:2817–2820`, explicitly says “let the List offers read complete, then commit termination before step 8 commits”; the corrected brief correctly distinguishes it from the earlier step-1 refusals. No pair write is moved earlier.
- **Payload:** `08-provider-notes.md:127` says “`authorized_key[]` supplies fingerprints to orders”. `PRV-9`, `02:139–158`, requires registered temporary resources and says every temporary key MUST “carry the operation id as its provider-side name or tag”. K2 names the generated key beside caller keys in that documented field. `PRV-32`, `02:967–991`, still limits empirical verification to auction; K does not assert that the standard channel passed `CNF-180`. The extra payload/resource duty is a reviewed behavior choice, not a new provider verification.
- **CNF-303 trace:** record the generated per-order fingerprint pair at step 8 → acknowledge it → register generated and distinct caller keys tagged with the operation id at step 9 → send order naming both → lose reply → operator attaches under K6 → machine remains provisioning → retention removes settled operation → sweep finds the retained machine's fingerprint and retains every tagged key → later observation clears provisioning → eligible registrations are deleted. `PRV-9`, `02:150–154`, says “A vanished operation record satisfies only the settlement condition”, requires the retained-machine provisioning check, and says “Every temporary key tagged with that operation id, including a caller key distinct from Robot's correlator key, has the same eligibility”. `CNF-303`, `10:2930–2940`, checks that exact retained-machine path. The distinct caller key need not itself be the correlator.
- **Fable's missing-writer concern is not a K regression.** `05:326` requires the machine's pair to be “what was actually written into the provider at create”; `PRV-9`, `02:151–152`, states the machine's Robot value is “its per-order correlator-key fingerprint on Robot”. Those are required contents even if no second procedural sentence names a copier at operator attach. A conforming attachment cannot omit the required value. It is incorrect to infer from an absent procedural writer sentence that the normative contents are optional.
- **Lost reply/exactly one listing entry:** K3 expressly makes a create on `correlator: none` have “no count”. `OPS-27`, `03:553–556`, has both exactly-one and unverified-channel outcomes; K3 selects the latter by denying cardinality. `PRV-33`, `02:1053–1056`, says “attaching a discovered machine to a tenant MUST be an operator action”. A stored fingerprint remains evidence, not matching authority. K5 tests that path. `Reconcile.lean:251–262` has no channel-kind input; no additional Lean theorem flip was established.
- **Lone dissent checked at 3–1:** `OPS-33`, `03:1689–1692`, says “the negative window MUST NOT run against a matched order that is still in progress”, followed by “This adds no timeout on an in-progress order.” K3 changes automatic cardinality; it does not prohibit the human from positively matching an in-progress order. Fable's inference that there can therefore be no protected matched order on this channel is **false**. An operator-confirmed in-progress order remains protected. Conversely, a lawful release after a completed/non-in-progress operator search reaches K-d's suffix. The original “After ... releases” clause imposes no earlier release and overrides no guard.
- **Opus's vacuity argument does not block original K-d.** K5 leaves status open, so an in-progress execution need not reach the suffix. That does not make it unreachable in every permitted fixture: a completed transaction with lawful release reaches it. No CNF/Lean assertion is forced vacuous, and no MUST is necessarily broken by the conditional addition. An implementer who silently overrides the in-progress guard violates the surviving owner, not K-d. This validates the original option's three takes without accepting fable's erroneous rationale.
- **Opus's new fixture AMEND is not BU.** It adds “Let that transaction be complete”, narrowing an existing conformance fixture. Added conformance constraints are explicitly excluded from wording-only rides by notes rule 1. Its two owner quotations are authentic; authenticity does not make the fixture change wording only. Preserve, do not merge.

### Against K (written on request; not votes)

- **fable:** “Recording an unverified fingerprint in the column `OPS-27` searches invites a builder to count it”; K2 also adds a key on an empirically unverified channel.
- **opus:** “K2 adds a payload MUST on a channel that hasn't passed `CNF-180`.”
- **astra:** “K2 adds a generated-key payload obligation on every Robot channel. That is an order-shape decision”.
- **sol:** “K2's ‘throwaway key unique to that order’ adds provider resources on an unverified channel”.

All four nonetheless ACCEPT the printed K candidate. These are the requested strongest counterarguments, not extra CA votes or provider observations.

## Exact AMEND texts and disposition

These are the new r69 texts. Identical quotations are shown once where explicitly shared; author and span are preserved. No failed mark is repaired by silently changing its text.

### Q1: fable — S2/S4, both marked behaviour unchanged

**S2**, replace the `offers` row (same exact repair separately supplied by astra and sol):

```text
| `offers` | json | the driver's List offers result (`DOM-9`: "Prices MUST be carried as strings exactly as the provider returned them.") |
```

**Disposition:** verified wording only; all four take this archived R4 variant. DOM-9's full sentence is verbatim (`01:185`). It can ride individually without altering the data requirement. This alone does not satisfy fable's two-part condition or opus's coverage objection.

**S4**, replace the row:

```text
| Offer-listing refresh (`OPS-51`) | `engine` | Reads offers at a provider, so it needs a provider credential. `STO-60`: "Every successful driver List offers read MUST publish its complete result to the account's row, replacing an existing row only when the incoming `read_at` is later." |
```

**Disposition:** the proposed STO-60 quote is exact, but the complete row drops printed process placement. Failed BU check; counts CA for fable's conditional form acceptance. Do not ride it into S. Astra/sol supply the same exact text **only as a quotation repair of archived R1 S4**, explicitly leaving adoption; do not turn those repairs into votes to adopt the row.

### Q1: opus — S2 caller clarification, marked behaviour unchanged

After «A failed read MUST leave the row unchanged.» insert:

> The read's caller publishes the result, outside the driver read: `PRV-50` says "The driver's List offers MUST be read-only".

**Disposition:** verified reconciliation with surviving `PRV-50`, `02:123`; no new behavior is needed to honor both owners. Individually wording only. No assembled multi-reader S repair is recommended. Opus's S form vote remains CA for coverage.

### Q1: astra and sol — F5, each marked behaviour unchanged

Replace F5's first replacement text with (the exact archived R4 variant, taken by all four):

```text
`API-7` tail ("then, on create only, `rate_limited` when the offer's account and ordering channel are closed under `PRV-40`") before any provider mutation
```

**Disposition:** quote verified at `04:269–270`; wording only and the identical repair may ride if a reviewed F candidate is later used. It repairs none of the other F losses. These readers also supply the identical S2 row above and the historical S4 quote repair above; their historical-row adoption votes remain leave.

### Q1: opus — conditional Tables.lean quotation sync if F12 lands

At `tools/formal/Provisiond/Tables.lean:69`, exact proposed sync:

```text
they are decided before any driver call, they
```

→

```text
they are decided before any driver call other than a create's admission List offers read, they
```

**Disposition:** held with the unselected F repair. The current source quote exists across the wrapped lines. The docstring can follow an accepted normative amendment; it does not excuse that amendment from behavioral review. No Lean declaration or docstring was changed by this tally.

### Q2: opus — K-d fixture replacement, marked behaviour unchanged

Replace K-d's text with:

> Let that transaction be complete; `OPS-33` says "the negative window MUST NOT run against a matched order that is still in progress". After the negative window releases the commitment, assert still no automatic attach (`OPS-33`: "the search it bounds is an **operator** search, not an automatic one").

**Disposition:** exact quotations verified at `03:1689–1698`; fixture changes, so failed BU check. No ride and no merger. The original option, carried at three takes, is instead exactly:

> After the negative window releases the commitment, assert still no automatic attach (`OPS-33`: "the search it bounds is an **operator** search, not an automatic one").

### Separate archived AMEND texts read this round

The following is copied verbatim from the r69 brief's labelled archives, so every archived replacement considered in the take/leave table remains available exactly. These texts are **not** a patch or a recommended merged form. Reader 1=fable, 2=opus, 3=astra, 4=sol for the attributed earlier rounds.

### r68 Reader 1 — S3/S4 (BU), S-d (unmarked), F11 (unmarked)

````markdown
**S3, behaviour unchanged**, whole paragraph:
> **OPS-51** A refresh pass MUST read every account declaring `list_offers` at least once per stated offer-listing refresh interval, except a credential after an `authentication` failure: `PRV-41` says “A driver MUST therefore treat an `authentication` failure as terminal for that credential, MUST NOT re-attempt it on a schedule, and MUST surface it for an operator”.

**S4, behaviour unchanged**, the row:
> | Offer-listing refresh (`OPS-51`) | `engine` | Reads offers at a provider, so it needs a provider credential, and writes `offer_listings` (`STO-60`) |

**S-d text**, appended to S-a's 5e (or to S1's second sentence if S-a fails):
> A create whose provider account does not declare `list_offers` is refused here with `DOM-10`'s error: "A capability check failure MUST return an "unsupported" error naming the provider account and the capability, with `retryable: false`".

and appended to S6's insertion:
> On an account declaring the ordering capability but not `list_offers`, assert `unsupported` with `details.capability: "list_offers"`, `retryable: false`, no `details.refusals`, and no commitment, operation or receipt.

**F11** (`03-operation-lifecycle.md`, `OPS-35`), after «account was only ever determined inside the call that vanished.» insert:
> This does not cover a create's admission List offers read, which comes before any record: `API-7` says "the `api` MUST obtain one current driver List offers result for the named offer's provider account".
````

### r68 Reader 2 — F11/F12 (BU), F7 (unmarked separately)

````markdown
F-final AMEND spans. They are "behaviour unchanged" because F10 already says the read "comes before any record".
- **F11** `OPS-35`, after «resolved and written to the operation record **before** any driver call.» insert:
  > This does not cover a create's admission List offers read, made before any operation record exists: `API-7` says "the `api` MUST obtain one current driver List offers result for the named offer's provider account".
- **F12** `OPS-11`: «they are decided before any driver call,» → «they are decided before any driver call other than a create's admission List offers read,»
- **F7**: «assert `unsupported` with `details.capability: "list_offers"`» → «assert `unsupported` with `details.provider_account` naming the account and `details.capability: "list_offers"`». `WIR-9a`'s row requires it: "`unsupported` | `provider_account`, `capability`".
````

### r68 Reader 2 — S-d, explicitly behaviour changed

````markdown
- **S-d: take.** This is "behaviour changed" against S-final, which refuses `provider`/`retryable: true` forever on such an account; no checked verdict changes (point 2). Insert in S1 before "Where no listing is stored" (if S-a passes, this sentence leads step 5e):
  > On create, an account that does not declare `list_offers` MUST be gated under `DOM-10` before the tail: "A capability check failure MUST return an "unsupported" error naming the provider account and the capability, with `retryable: false`".

  Append to S6:
  > On an account declaring the ordering capability but not `list_offers`, assert `unsupported` with `details.provider_account` and `details.capability: "list_offers"`, `retryable: false`, no `details.refusals`, and no commitment, operation or receipt.
````

### r68 Reader 3 — F5, BU

````markdown
**F5 wording AMEND — behaviour unchanged.** Replace its first replacement text, `` `API-7` tail before any provider mutation ``, with:

> tail before any provider mutation (`API-7`: “`rate_limited` when the offer's account and ordering channel are closed under `PRV-40`”)
````

### r68 Reader 4 — S2/S6/F5, each BU

````markdown
**S2 — AMEND, behaviour unchanged.** Replace the `offers` table row with:

```text
| `offers` | json | the driver's List offers result (`DOM-9`: "Prices MUST be carried as strings exactly as the provider returned them.") |
```

**S6 — AMEND, behaviour unchanged.** Append to its inserted conformance text:

> With no customer requests, assert each account declaring `list_offers` is read within each stated offer-listing refresh interval, except while its credential is subject to the authentication stop. Assert no scheduled retry for a stopped credential. After successful reads, assert publication of the complete result with `read_at` equal to the dispatch instant. Complete two reads in reverse dispatch order and assert the row retains the later read's `read_at` and offers. Fail a read and assert the existing row is unchanged. See `STO-60` and `OPS-51`.

This demonstrates the new duties and supplies their otherwise missing conformance citations.

**F5 — AMEND, behaviour unchanged.** Replace its first replacement text with:

```text
`API-7` tail ("then, on create only, `rate_limited` when the offer's account and ordering channel are closed under `PRV-40`") before any provider mutation
```
````


## What a subsequent scoped read must read (not launched)

The owner must first choose the cost/latency direction because neither Q1 form is owner-ready, as notes rule 4 expressly permits. This tally does not supply a new recommended composite.

- **If S is selected:** show one complete S1–S6 candidate, preserving S1's admitting-transaction timing, printed S3's credential-stop scope, and printed S4's “running in the engine process”. Use the exact common S2 DOM-9 row repair, the exact opus S2 caller-clarification sentence, and the exact archived R4 S6 coverage append, all labelled as an **unreviewed combined candidate until that round concludes**. Do not import S-a/b/c/d (none carried), or the failed-BU S4 replacement. The read must judge the whole candidate, not merely revote the snippets; ask explicitly about new conformance assertions, coverage and strict quoting. These are the available exact texts for main's preparation, not approval of their merger.
- **If F is selected:** main must first write one complete repair candidate. Read F1–F10, with the exact carried F-a/Reader-3 and F-c/Reader-3 variants and common F5 quotation repair, together with a stated disposition for OPS-35, OPS-11, 05:441, CNF-31b and the additional CNF-307/CNF-278 unhealthy-account cases. F11/F12 are supplied fragments, not a complete solution. Include any necessary Tables.lean docstring sync alongside the normative amendment, and check the credential-stop interpretation. Coordinator additions remain unreviewed until read; no exact complete F repair is fabricated by this tally.
- **Q2 needs no further read for the exact K1–K6 candidate and original carried K-d option.** A proposed change to its completed/in-progress fixture, a merger with opus's new K-d text, or any other changed candidate does need its own reading. Do not silently expand the recommendation beyond the printed K spans and printed option.

## Brief and reader errors ledger

| Claim | Verified evidence | Disposition |
|---|---|---|
| Brief: S2's owner says “Every successful driver List offers read MUST publish its complete result to the account's row.” | brief.md:100 quotes a period where S2's owner at :121 continues “, replacing an existing row only when the incoming `read_at` is later.”; [quotation-checks.txt](/var/tmp/provisiond-panel-r69/tally-evidence/quotation-checks.txt) | **False exact quotation, wording only.** Full owner sentence and corrected S4 candidate are present in this same brief. It changes no question premise, so rule 6 voids neither tally. No text carrying this truncated quote is recommended. |
| Fable calls its S4 replacement BU | Printed S4 includes “running in the engine process”; replacement does not. `00:316–321` distinguishes module/process; `03:1983–1996` states fence scope. | **Failed BU check; counted CA for its S verdict.** Do not silently discard its acceptance condition. |
| Opus: printed S fails coverage 74 → 76 | Actual isolated application plus coverage exit 1; archived S6 append returns exit 0. | **Verified.** Coverage is not an enumerated rule-3 loss. Non-blocking CA remains CA for the three-ACCEPT threshold. |
| Fable: F's “loss inventory” is short | New reachable CNF-307/278 preemption trace verified at `10:1214–1230,2789–2794`; brief :183–188 expressly says listed edits are not complete impact inventory. | Additional F defects, **not a false completeness premise or a void**. Fable's guaranteed authentication/network headline on every unhealthy account is overbroad; only a reachable failed-read witness is needed. |
| Opus: F necessarily re-sends rejected credentials on every create | `02:1246–1248` requires a terminal stop; F1 does not require bypassing that local stop. | **Not established** as a forced new PRV-41 loss. Shared F losses independently stand. |
| Fable: on a no-count channel no matched in-progress order can be protected | `03:1689–1698` preserves the in-progress qualification and operator search; `02:1053–1056` preserves human resolution. | **False.** Operator-confirmed positive in-progress evidence is possible without automatic cardinality. Does not block the original conditional K-d. |
| Opus: original K-d cannot check anything without its added completion sentence | A completed transaction with lawful operator-window release reaches the suffix; guard at `03:1689–1692` only prevents release in the still-in-progress case. | **Overstated, not a proved universal vacuity.** Record its conditional take and exact text; do not count it as an unconditional original-option take. |
| Opus: new completed-fixture K-d AMEND is BU | Replaces unspecified progress status with “Let that transaction be complete”. | **Failed BU check** under the explicit exclusion for added conformance constraints. Its quotes are valid, its new fixture is unreviewed. |
| Archived R2 S-d “forever” / old universal step-1 account refusal / archived F11/F12 and S6 BU marks | Retained fresh-row trace; `10:2817–2820`; surviving owners and added assertions above. | They are expressly disclosed historical claims, not r69 premises. Correct classifications do not void the tally. |
| Fable: no sentence names a machine-pair writer at operator attach | `05:326` states required machine contents, and `02:151–154` states required retained guard/value. | Missing procedural writer naming is not an established missing obligation or K regression. |
| Fable: monotonic publication needs no generation fence for correctness | `03:1983–1996` still requires the engine-process write check; printed S4 retains that placement. | No exemption follows from the monotonic row rule. No reader supplies a gated trace against printed S from this aside. |
| Opus: formal docstring quotes the OPS-11 span | `tools/formal/Provisiond/Tables.lean:69–74` | **Verified**, additional synchronization work if F12 is later accepted. Not a false current premise. |

## Validation

The required unpiped before gate completed exit 0 with all gates PASS: [log](tally-gate-before.log), [exit](tally-gate-before.exit). The required unpiped after gate also completed exit 0 with all gates PASS: [log](tally-gate-after.log), [exit](tally-gate-after.exit). These gates check the unchanged source set, not the proposals. The isolated coverage experiment above intentionally applies the printed S and a separate S6 addition only under `tally-evidence/`; its red result is retained as evidence, not masked by a pipe or baseline change. No real spec, tracker, memory, commit or remote was changed. Only tally artifacts and one UPDATE in the top manager RESUME bullet are authorized outputs.
