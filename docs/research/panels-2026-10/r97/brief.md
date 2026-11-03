# Panel R r97 — pv-9ecf adopted C′ wording and retention

Read this brief and /var/tmp/provisiond-panel-r97/notes.md whole. Your clone is independently detached at M=`2e2cd94637112f20538eb26b141672fedf0ba455` (current origin/master, PR67/pv-bxh). Original form pin O=`3109b5b44eae17e288cf52aaa976993bd8c5626c`. The paid-create policy and complete C′ package, including its Hourly cloud cases, have owner approval; this round decides exact wording/retention reconciliation, not paid-create policy again. No Run has started and no own branch commit exists.

Read only; write no source, Git state, tracker or panel records. No br, commit/push/checkout/reset/stash/clean/remote mutation, PR contact, subagent, background work, provider call or internet. Do not enter or read spec text from the main checkout. Spec source is your own clone or git show of its objects. Temporary files only under /var/tmp/provisiond-panel-r97/tmp/<seat>/; final answer stdout is captured by the launcher. Do not read ~/.claude, ~/.codex, ~/.grok, credentials, sessions/configs, kubeconfig or browser profiles; do not read other r97 seat outputs/clones. Every other panel/manager/Run folder is read only. Do not run lake, formal gates or check-all: manager owns baseline gates and the host permits at most two lake builds. Finish substantively within 3600s; no waiting for other readers.

**apply notes.md rule 6 exactly as written; this prompt adds no void rule.**

## Plain-terms story and authority

An approved form says to leave an existing check unchanged. Since its review, another approved change added a case that catches a worker writing a marker before validation. Copying the old form’s retained check back would delete that case. Separately, the form describes other requirements without quoting their words, against the repository’s writing rule. We need exact corrections without changing the owner’s policy or losing any approved assertion.

The owner records follow verbatim. Item7 is evidence for PR60 only, not authority to expand pv-9ecf. Items4 and24 are the paid-create authority.

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
The wording precedent is owner 2026-10-28: **“For such wording questions, try to solve by getting a consensus of the panel”**. Use it only for a settlement that changes neither behavior, owner/adopted-form meaning nor check strength. A substantive conflict returns to the owner. Read the entire manager stop UPDATE and main’s 18:40Z ruling:

`````text
  UPDATE (2026-11-02 23:26:52 UTC, next drain pv-9ecf pre-Run STOPPED; NO RUN): Fresh pull clean master=2e2cd94637112f20538eb26b141672fedf0ba455; branchpv-9ecf firstopen/ready-for-agent/unblocked/unclaimed/noeligible skip. PR67 paginated comments/reviews/inline/complete threads no bot post/edit after22:55:10Z; PR66 none since21:09Z, refetched before report. API head66/67 and merge66 specification shards4/4SUCCESS; merge67 shard3SUCCESS/othersIN_PROGRESS at read/no failed result/no completion claim; Node20forced24/Ubuntu26 annotations match action pins/runner, hosted migration not reproduced/no verified gap/newbead. Comment861/archive/frozenCprime SHAbe350270318a2752992a9cb199a2a56879249be99f36e7af430bcfe8a1d47a32/owneritems4+24 exact includingHourlycloud; gap persists/eight replacement anchors exact. STOP: frozen Retainverbatim at pinnedbytes forCNF34 conflicts PR60 8dd8f48 inserted install-marker fixture; original lines survive but full retained span not byteidentical/no inferred exception or restoration. Replacement-only exact eight-block scratch citation trial0 inclPR64controls/fullhourlyblock, preserving live retentions; not clearance of conflicting fullpackage. Manual AGENTS29-32/45-46 quotecheckFAIL: PRV10 configuration-half summary ofDOM10/API7/OPS43, API15 historical WIR17 top-level assertion, CNF364 asCNF19does, retainedCNF18 CNF20/coverage assertions lack sourcewords; exact sentences/omittedwords in dr-next12-check/stop-report.md and quote-check.json. Initial/final full unpiped capped Nix check-all0/0 includingLean/hostlake admission<2; scratch index copied after byteequal formal/buildinput checks. Tracker HEAD/index/worktree exact/all861commentids unique/inheritedfields unchanged. Preparationcommitnone/newbeadnone; no realclaim/nativeproof/instruction/Grok/freshbuild/effortgrep/Run/push/PR/merge. EntryClaudeweek83% resetNov3 20:00UTC/Fable100%EXEMPT/noCurrentSession(noopenwindow)/activeCodexproton42%; noquota hold/no launchreading. Protectedfolders/preexistingunits untouched. Main routes exactwording/retention conflict; no next candidate or panel launched. Evidence /var/tmp/provisiond-manager/dr-next12-check/. No Run wait command applies.
  UPDATE (2026-11-02 19:08:54 UTC, pv-gvc Run LAUNCHED; resume at step3): Main settled the19:02Z stop as a disposable missing-generated-index setup failure, neither a new trial nor quote-check failure; resumed step3 as instructed. The18:40Z checker false positive remains settled by main; only added/changed text audited, inherited fields untouched. Fresh fetch origin/master=f8a30457eb84b3077e7580732bef665b3763aae1; pv-gvc=af39a7c6af84b68510453eb8a576b105af9d427f and main clean at entry/launch; preparation commit untouched/local/unpushed. Earlier step2 evidence retained: exact prospective brief/archive/r96 archive, only comment853.text differs, byte-identical committedJSONL rebuild/flush/database agrees/all861commentids unique. Read-only dr-next10 citation-trial.* and sol/dr-next10.report plus its exact setup traced: copy formal index from successful main build. Own capped full unpiped Nix before gate0 at af39a7c; every tracked tools/formal source and emitter/toolchain/flake input byte-equal between pinned commit/main build/disposable clone, no untracked source; index copied with hash manifest formal-index-resume3.json. Corrected exact-package disposable citation-trial-resume3.exit0; AGENTS29-32/45-46 manual quotation check PASS including exact172B OPS43 source. Native probes/helpers exact pv-kv2 copies retargeted only bead/path with fresh diffs/current companion snapshot; isolated import/baseline/flush/claim/after-claim/rebuild-admission/rebuild/after-rebuild all0, every200database row/scalar/relation and861uniquecomments pass, only scratch status/updated_at changes; real tracker unclaimed before Run. Instruction.md/diff preserve exact committed853/owneritem13/item19tail/settled paragraph/full Q-QUOTE package and standing claim/native rules; base af39a7c builds on preparation/no rewrite or squash, close only pvgvc/no other bead/new bead. Snapshot setup first lookup omitted checklist prefix, fixed once; retry PASS, snapshot-setup-retry.json, no trial/probe failure. Own final capped full unpiped Nix gate0 includingLean/host admissions below2; main DB baseline0/clean launch tree. Sole one-word grok402: grok missing: 402/no manual retry/fallback as pvkv2. Fresh nix build --refresh0, rloop-high copy already all-high/diff empty/effort-grep9high lines. Launch-time direct /usage exit0: "Current week (all models): 78% used · resets Nov 3, 8pm (UTC)"; Fable100%EXEMPT/same reset; no Current session line(noopenwindow); activeCodexprotonWEEK32%, nohold/accountswitch. One Run/noauto/solManager+Implementer/exactlyhigh: rloop-provisiond-pv-gvc-1102T1908 active/running, MemoryMax17179869184/MemorySwapMax0/OOMPolicycontinue/npm-firstPATH/RunlocalTMPDIR/mainBEADS_DIR systemctl-verified. Folder /var/tmp/rloop-units/provisiond-spec-pv-gvc-1102T1840; every earlier prep file/protected folder/pre-existing unit untouched. No push/PR/merge/next bead. NEXT main waits then fresh turn audits whole Run/reviewer outputs; no checkout/tracker mutation while active. Wait: `until [ -e /var/tmp/rloop-units/provisiond-spec-pv-gvc-1102T1840/exit ]; do sleep 60; done`.
  UPDATE (2026-11-02 19:02:17 UTC, pv-gvc preparation COMMITTED; step3 STOPPED; NO RUN): Main settled the18:40Z stop as a checker false positive: audit only text added/changed; inherited tracker fields out of scope and left unchanged. Fresh origin/master and HEAD initially f8a30457eb84b3077e7580732bef665b3763aae1; all83 staged files/numstat/hashes/desiredJSONL matched prior evidence; open/ready-for-agent/unclaimed read-only. Corrected prep/audit2.py/diff/output pass: only comment853.text changes; every other field identical;172 added-line reader-record name hits individually reviewed/pinned, no generated-by line, message plain/trailer-free. ONE local unpushed preparation commit af39a7c6af84b68510453eb8a576b105af9d427f; brief/archive exact prospective, original35lines/2644B prefix exact, r96 manifest/redaction/link pass. Fresh committedJSONL cache rebuild/forced flush0 byte-identical/all200rows scalar+relations agree/all861commentids unique/other raw rows exact/clean tree/citations0. Own full unpiped capped Nix before/atcommit0/0 includingLean/hostadmission below2. STOP: disposable corrected-package citation trial2 omitted formal-index initialization; check_citations exit2 missing tools/formal/.lake/index.jsonl after no-new-quoted-findings output; trial not passed/manual quote-check not reached. Fail-closed sequence halted all later work. No claim proof/instruction.md/Grok/fresh build/Run/unit/launchquota. EntryClaude78%allmodels resetNov3 20:00UTC/Fable100%EXEMPT/noCurrentSession(noopenwindow)/activeCodexproton31%; no hold. Previous prep files, protected folders, every pre-existing unit and other beads untouched. Evidence /var/tmp/rloop-units/provisiond-spec-pv-gvc-1102T1840/prep/resume-stop-report.md,resume-stop-result.json. NEXT one question: initialize scratch formal index through capped full gate and repeat step3 then continue(recommended), or hold?
`````

## Pinned writing rule, whole passages

`````text
29: **Quote the sentence.** A claim about what another requirement says carries that requirement's own
30: words. `` `WIR-30` says "The gate reads the copy the machine took at create" `` is checkable;
31: "`WIR-30` forbids resolving eligibility that way" is an assertion, and assertions of that shape were
32: false repeatedly on 2026-09-03 — `ddd3df0` and `254fc24` carry the cases and what each one cost.
`````

`````text
45: **Completion:** every sentence asserting what another requirement says carries its quote, and every
46: list or count names its source instead of restating it.
`````
Read AGENTS.md whole in your clone. The citation gate is narrower: tools/check_citations.py’s docstring leaves summary attributions to review. The stopped turn’s successful citation trial is not an exemption from the prose rule.

## Verified packet and required provenance

Read evidence/comment-861.md whole and evidence/form-Cprime.md whole, and occurrences.md plus check/reference-paragraphs.json. They were independently decoded/read from M. The form equals both archived copies and /var/tmp/provisiond-panel-r89/r89b/form-Cprime.md, SHA-256 be350270318a2752992a9cb199a2a56879249be99f36e7af430bcfe8a1d47a32. Comment861 embeds it word for word. The original bead and its labels/comments are evidence/bead.json, not the shared br database.

Read the r89 archive in your own clone: brief.md, STATE.md, reader files fable/opus/astra/sol.md, check/owner-item-4.md, check/source-extracts.md, check/tally/form-Cprime.md and check/tally/verification.json; r89b/tally.md and owner-questions.md record the eventual consensus and owner question. The external r89/r89b tally and owner-questions were checked against archived counterparts; historical absolute paths are pointers only, no permission to mutate them. The original panel’s numeric C majority was held because it narrowed the unconditional wire rule and worker fixture domains; r89b’s approved C′ retained those protections and explicitly added the hourly block. Read the actual record and say whether this framing is supported.

Source stop report first, then quote-check/trial-blocks/retention-diff/agent-brief/citation-trial/stop-result copies under evidence/stop-*. They equal /var/tmp/provisiond-manager/dr-next12-check/ originals, read only. These are evidence, not rulings on the panel’s choices. Current source homes and exact quote bytes are evidence/current-homes.md and check/quote-bytes.json; confirm them using your clone.

Panel Q r96 and Panel P r95 are precedent only: their tallies settled Q-QUOTE plus dated L-NOTE 3–0 with missing Grok/Fable; neither settles this package. Read /var/tmp/provisiond-panel-r96/tally.md and settled-pv-gvc.md and /var/tmp/provisiond-panel-r95/tally.md read only. Prior quotas there are historical; notes.md’s new 95% rule controls this launch.

## Q1 — retain current master, restore the old pin, or ask the owner?

Independent recheck of every “Retain verbatim” block:
| Site | Current line | Comparison with original pin |
|---|---|---|
| WIR-17 field rules opening | 13-wire-contract.md:683 | Byte-identical contiguous block |
| CNF-18 | 10-conformance-checklist.md:124 | Byte-identical contiguous block |
| CNF-19 | 10-conformance-checklist.md:137 | Byte-identical contiguous block |
| CNF-34 | 10-conformance-checklist.md:256 | CNF-34 insertion only; all original lines remain in order |
| CNF-182 Robot test-mode case | 10-conformance-checklist.md:2484 | Byte-identical contiguous block |
| CNF-342 acknowledgement paragraph | 10-conformance-checklist.md:4476 | Byte-identical contiguous block |
| CNF-344 channel declaration is no capability grant | 10-conformance-checklist.md:4531 | Byte-identical contiguous block |

CNF-34 drift, independently reconstructed from O and M:

`````text
--- 3109b5b44eae17e288cf52aaa976993bd8c5626c
+++ 2e2cd94637112f20538eb26b141672fedf0ba455
@@ -15,6 +15,21 @@
       acknowledgement; an api-filled install case applies only if the release names a field the
       `api` writes at install admission, and the fixture must identify that field. It asserts
       `conflict`/`incomplete_record`, `retryable: true` and the same untouched-install outcome.
+      Repeat the install caller-field fixture with acknowledge_destruction present but
+      false in the stored request, after admission with a valid true value. Use ordinary
+      trusted marker provenance (restore_markers_untrusted false) and initially null marker
+      columns. Assert the repeated validation completes before either marker write and
+      rejects invalid_request, details.field /acknowledge_destruction, retryable false on
+      error and operation view, failed, no driver call, both markers still null, disk_effect
+      none and rescue_exit none. Instrument a proposed execution that writes the rescue
+      marker false before this validation, then tries to validate before begin-rescue
+      dispatch: assert this execution violates the required ordering even though dispatch
+      has not occurred. Do not clear the marker or synthesize rescue_exit none from false
+      to make that proposed execution pass. Repeat for a present-but-invalid api-written
+      install field only if the release names such a field; identify it and retain
+      conflict/incomplete_record, retryable true and the same before-both-markers assertions.
+      No api-written install field is invented for the fixture. The complete-record control
+      proceeds past validation. (`OPS-23`, `OPS-45`, `API-14`, `WIR-9a`, `WIR-9b`)
       Complete-record controls on create and install proceed. (`OPS-23`, `OPS-43`, `API-14`,
       `WIR-17`, `WIR-9a`, `WIR-9b`, `OPS-11`, `OPS-45`, `LDG-39`)
       *Amended 2026-10-17 (`pv-14b`; panel r55, `docs/research/panels-2026-10/r55/`):
`````
PR60 is 8dd8f48bead424312ffde59ac0a8c3fdb796d1a7, “Finish repeated request checks before either install marker (#60)”; owner item7 above adopted exactly Q3-A and its common fixture. Read the commit diff in your clone. Every reader must name its assertions: present-but-false stored destructive acknowledgement after valid admission; ordinary trusted provenance/null markers; all repeated validation before either write; invalid_request field/non-retryable error+view, failed/no driver/null markers/disk_effect none/rescue_exit none; marker-first negative proposal fails even before dispatch and cannot be hidden by clearing/synthesizing; conditional named api-written field arm without invented fields; positive control proceeds. Verify these against the complete quoted insertion, not this summary.

Pick one exact directive:

### R-MASTER-directive.txt

`````text
Changes from Form C: the `WIR-17` field rules opening, `CNF-34` and the `CNF-342` acknowledgement paragraph are **Retain verbatim**, meaning this package does not edit them. For execution at `2e2cd94637112f20538eb26b141672fedf0ba455`, retain their complete current master text, including PR #60’s install-marker fixture in `CNF-34`; the printed 3109b5b blocks below are historical comparison text. Every other block is identical to Form C except for the exact quotation corrections selected in Panel R r97.
`````

### R-MASTER-comment-sentence.txt

`````text
CNF-34 and CNF-342’s acknowledgement paragraph are not edited by pv-9ecf: retain their complete master text at `2e2cd94637112f20538eb26b141672fedf0ba455`, including PR #60’s install-marker fixture in CNF-34. C′’s retained create coverage remains **"On separate creates"** in CNF-34 and **"complete, valid resource-offer"** in CNF-342.
`````

### R-MASTER-comment-placement.txt

`````text
**Historical approval record — original wording at 3109b5b:**

`docs/research/panels-2026-10/r89/r89b/owner-questions.md:28`:

> The wire rule remains the pin's unconditional **"`acknowledge_purchase` MUST be literal `true` (`API-15`, `PRV-10`)"** ([WIR-17](consistency/13-wire-contract.md#L665)). CNF-34's **"On separate creates"** and CNF-342's **"complete, valid resource-offer"** acknowledgement fixture also remain byte-identical to the pin. C′ keeps existing acknowledgement coverage on a modeled create that starts no provider billing, rather than silently exempting it. Paid-create coverage and the broader wire rule are compatible: the new API-15 says paid requests **"MUST carry"** acknowledgement, not that only paid requests must carry it. This broader wire/narrower provider layering already existed at the pin.

**Current execution guidance — Panel R r97:** CNF-34 and CNF-342’s acknowledgement paragraph are not edited by pv-9ecf: retain their complete master text at `2e2cd94637112f20538eb26b141672fedf0ba455`, including PR #60’s install-marker fixture in CNF-34. C′’s retained create coverage remains **"On separate creates"** in CNF-34 and **"complete, valid resource-offer"** in CNF-342.
`````

### R-PIN-directive.txt

`````text
Restore CNF-34 to the exact complete 3109b5b bytes printed in C′, removing PR #60’s install-marker fixture. Leave every other retained block at its unchanged 3109b5b/current-master bytes. Claimed authority for restoration must be identified by the reader; this candidate supplies no new owner authorization.
`````

### R-OWNER-directive.txt

`````text
Do not start the pv-9ecf Run. Ask the owner whether retaining CNF-34 means leaving the complete current master text, including PR #60’s install-marker fixture, or restoring the 3109b5b text printed in C′ and removing that fixture. Preserve both historical adoption records until the owner answers.
`````
R-MASTER changes the executable retention instruction and adds the exact corrected current execution sentence beside comment861’s unchanged historical quotation; it does not rewrite that attributed quotation or the original archived form. The corrected Desired behavior heading reads exactly “Desired behavior / key interfaces / acceptance criteria — executable form with Panel R r97 corrections”, so a modified executable form is not labeled verbatim approval. The entire current CNF-34, including PR60, stays unchanged. R-PIN’s full restored bytes are evidence/CNF-34-old.md (also printed in C′); its deletion is exactly the inverse of the shown insertion. R-PIN must identify what authorizes deleting item7’s adopted fixture; no authority is assumed. R-OWNER holds execution pending an owner decision, and must state exactly which adoption’s meaning cannot be settled as wording. Also report whether any other retained block moved; do not infer all from checking only the two reported sites.

## Q2 — exact sentence replacements, independently per sentence

Choose Q-QUOTE, Q-POINTER or conditional Q-KEEP for each of a–e below. Q2a/b/c are the reported summaries; Q2d/e are additional owner-pointer boundary cases found during the full audit. Q-KEEP is allowed only with a demonstrated AGENTS non-application, such as the sentence stating the package’s own new rule; mere inherited wording inside an explicitly replaced block, citation-gate success or historical italics is not an exemption. Different choices per sentence are allowed. Identify every further occurrence and supply its complete candidates before recommending it; do not claim an unprinted manager repair reviewed.

Every target is replaced in comment861’s executable form and in the precise source text supplied to the Run. Original Current behavior quotations and archived adopted-form prefix remain historical evidence. Q2b’s original historical comment occurrence stays unchanged. For the historical WIR-17 quote, name the revision and why it establishes the historical claim; a present-day rule alone does not do that.

### Q2a — PRV-10 configuration-half sentence

C′ line 26; comment861 lines 80.
Original / Q-KEEP:

`````text
The configuration half is `DOM-10`'s gate on the create's ordering capability (`DOM-16`):
`API-7`'s step 5d at admission and `OPS-43`'s step 3 at claim.
`````

Q-QUOTE, complete exact replacement:

`````text
The configuration half is `DOM-10`'s gate on the create's ordering capability (`DOM-16`); `DOM-10` says “Every operation with a capability MUST be gated on it before the
driver is called, **including create**”. At admission, step 5d is the gate: `API-7` says “**gate a create on its ordering capability** under `DOM-10` (`PRV-10`, `DOM-16`). A refusal stops here and is not collected by the tail”. At claim, step 3 is the gate: `OPS-43` says “Repeat boundary validation under `OPS-23`: "Validation that was performed at the API boundary
   MUST be repeated in the worker before the driver is called". This includes `PRV-10`'s
   "explicit purchase acknowledgement", `PRV-8`'s "at least one SSH public key", the missing-field
   checks defined in `OPS-23`, and `DOM-10`'s gate on the create's ordering capability, which is
   `PRV-10`'s "the account is configured to allow ordering". The checks on caller-supplied fields
   run first, then the checks on fields the `api` wrote at admission, then the capability gate”.
`````

Q-POINTER, complete exact replacement:

`````text
The configuration half gates the create's ordering capability (`DOM-16`) at admission and again at claim; owners: `DOM-10`, `API-7` step 5d and `OPS-43` step 3.
`````

### Q2b — API-15 historical italic sentence

C′ line 35; comment861 lines 41, 89.
Original / Q-KEEP:

`````text
"In its provider
options" until 2026-09-05, while `WIR-17` placed it at the top level; the wire contract wins, and a
spending authorization nested inside a driver-private object is one a strict server could not tell
from any other option.
`````

Q-QUOTE, complete exact replacement:

`````text
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
`````

Q-POINTER, complete exact replacement:

`````text
"In its provider
options" until 2026-09-05; historical wire-location owner: `WIR-17` at revision `7116e90b9932211c08f2e712690cc176b56edea6`. The wire contract wins, and a spending authorization nested inside a driver-private object is one a strict server could not tell from any other option.
`````

### Q2c — CNF-364 comparison sentence

C′ line 212; comment861 lines 266.
Original / Q-KEEP:

`````text
While it is still queued and unclaimed, restart with a descriptor for that account that
      removes only `list_offers`, keeping the ordering capability declared and the driver's
      List offers code path answering, so the test proves the gate exists, as `CNF-19` does.
`````

Q-QUOTE, complete exact replacement:

`````text
While it is still queued and unclaimed, restart with a descriptor for that account that
      removes only `list_offers`, keeping the ordering capability declared and the driver's
      List offers code path answering, so the test proves the gate exists, as `CNF-19` does (`CNF-19` says “Create is refused when the provider has not declared the matching
      provision capability — with the driver's internal ordering flag set to permissive,
      so the test proves the outer gate exists.”).
`````

Q-POINTER, complete exact replacement:

`````text
While it is still queued and unclaimed, restart with a descriptor for that account that
      removes only `list_offers`, keeping the ordering capability declared and the driver's
      List offers code path answering, so the test proves the gate exists; comparison owner: `CNF-19`.
`````

### Q2d — PRV-10 first sentence (ownership-pointer boundary)

C′ line 23; comment861 lines 77.
Original / Q-KEEP:

`````text
**PRV-10** For a paid create (`DOM-16`), create MUST reject the request unless the
request carries an explicit purchase acknowledgement (`WIR-17`'s top-level
`acknowledge_purchase`), *and* the account is configured to allow ordering.
`````

Q-QUOTE, complete exact replacement:

`````text
**PRV-10** For a paid create (`DOM-16`), create MUST reject the request unless the
request carries an explicit purchase acknowledgement (`WIR-17`'s top-level
`acknowledge_purchase`), *and* the account is configured to allow ordering (`WIR-17` says “`acknowledge_purchase` MUST be literal
`true` (`API-15`, `PRV-10`).”).
`````

Q-POINTER, complete exact replacement:

`````text
**PRV-10** For a paid create (`DOM-16`), create MUST reject the request unless the
request carries an explicit purchase acknowledgement (top-level
`acknowledge_purchase`; wire owner: `WIR-17`), *and* the account is configured to allow ordering.
`````

### Q2e — API-15 first sentence (ownership-pointer boundary)

C′ line 33; comment861 lines 87.
Original / Q-KEEP:

`````text
**API-15** A paid create request (`DOM-16`) MUST carry an explicit purchase
acknowledgement — `WIR-17`'s top-level `acknowledge_purchase`, which the wire contract
owns — in addition to the account being configured to allow ordering (`PRV-10`).
`````

Q-QUOTE, complete exact replacement:

`````text
**API-15** A paid create request (`DOM-16`) MUST carry an explicit purchase
acknowledgement — `WIR-17`'s top-level `acknowledge_purchase`, which the wire contract
owns — in addition to the account being configured to allow ordering (`PRV-10`) (`WIR-17` says “`acknowledge_purchase` MUST be literal
`true` (`API-15`, `PRV-10`).”).
`````

Q-POINTER, complete exact replacement:

`````text
**API-15** A paid create request (`DOM-16`) MUST carry an explicit purchase
acknowledgement — top-level `acknowledge_purchase`; wire owner: `WIR-17` — in addition to the account being configured to allow ordering (`PRV-10`).
`````
Q2a assertion map: preserve the configuration half, ordering-capability identity, DOM-10 owner, admission API-7 step5d and claim OPS-43 step3. Q2b: preserve old provider-options wording as history, the historical top-level wire location, wire precedence and the driver-private-option ambiguity rationale. Q2c: preserve queued/unclaimed restart, removal of only list_offers, retained ordering declaration, an answering driver implementation, the outer-gate demonstration and comparison to CNF-19. Q2d/e: preserve paid-create coverage, explicit purchase acknowledgement, top-level field location/wire owner, both authorizations and API-15’s addition to account opt-in. Name exactly where every assertion survives your pick. The Q-POINTER historical candidate removes the explicit old top-level clause and instead points to its owner while the current first sentence still gives the location; decide if that preserves the adopted historical assertion or is a loss. No candidate is presumed acceptable merely because printed.

Full assembled examples are run-R-MASTER-Q-{QUOTE,POINTER,KEEP}.md and comment-861-R-MASTER-Q-{QUOTE,POINTER,KEEP}.md. They apply a/b/c uniformly, leave d/e at Q-KEEP for the ownership-pointer question, and change the retention directive. They are examples for whole-package inspection, not a rule to choose the same Q2 answer or a claim d/e are exempt. Disjoint per-sentence selections are the reviewed units; report exact bytes and all cross-sentence interactions. If the eventual selected assembly differs semantically from these independent picks it requires a new reading, not a tally synthesis. Exact authority replacement is authority-replacement.txt. Historical r89 Current behavior/drift records remain unchanged and explicitly labeled as historical; the new evidence retention table describes current M.

## Q3 — inherited CNF-18 sentences

The complete CNF-18 retained block is printed in C′. The two reported sentences:

`````text
- [ ] **CNF-18** — **AMENDED 2026-09-08 (`ADR-0018`) — the table is `DOM-10`'s, and the descriptor's
      fields are rows too.** For every driver, every declared capability has a working code path,
      and every implemented operation with a capability entry in `DOM-10`'s table has its
      capability declared. Table-driven over that table, one case per (driver, capability) pair;
      the three capability-less methods are `CNF-20`'s and are not rows here. **Then iterate the
      descriptor** (`PRV-44`), one case per (driver, field): a declared value has a working code
      path behind it — a declared ordering channel is searched, a declared evidence source is read,
      a declared surviving attachment kind is listed, and each ordering channel carries
      its own validated `order_budget` — and a field with nothing to declare says so
      explicitly rather than being absent. An ordering capability withheld under `DOM-16` is outside the implemented-implies-declared rows for that account; `CNF-19` and `CNF-55` cover its gate. (`DOM-15`, `DOM-10`, `PRV-4`, `PRV-44`)
      *Amended 2026-10-09 (`ADR-0036`): the order-budget field is iterated per channel.*
      *Amended 2026-10-22 (`pv-p3k`; panel r62, `docs/research/panels-2026-10/r62/`; owner decision 2026-10-22): applied the reviewed ordering-capability change.*
`````

S-OUT.txt
`````text
Leave both CNF-18 sentences unchanged. They are inherited source text C′ retains, outside this package’s added/changed-text audit under main’s 2026-11-02 18:40Z ruling. No bead.
`````

S-BEAD.txt
`````text
Leave both CNF-18 sentences unchanged in pv-9ecf. Propose a needs-triage bead only after identifying a behavior, requirement or check-strength gap and its trace; wording alone does not qualify under feedback_no_cosmetic_beads.md. This panel turn does not create a bead.
`````

S-FIX.txt
`````text
Change both retained CNF-18 sentences in this package only if the reader supplies the complete exact replacement text and identifies existing owner authorization to change C′’s expressly retained text; absent that evidence S-FIX is incomplete and cannot count as an accepted form.
`````
Main’s 18:40Z ruling limits the changed-text audit; it does not weaken the repository rule or authorize editing a retained block. Memory feedback_no_cosmetic_beads.md says “File a follow-up issue (bead, GitHub issue, TODO) only for a finding that would change **what the software does, what the specifications require, or whether a check can catch a defect**”. Wording alone gets no bead. To choose S-BEAD give a traced qualifying gap. To choose S-FIX give complete exact sentence replacements and existing owner authority to edit retained C′; otherwise mark it CANNOT ACCEPT. This panel turn writes no bead regardless.

## Q4 — where do settled corrections land?

Pick L-BRIEF or L-NOTE (or give one complete exact better-supported form). Both prepare comment861 before the Run, in pv-9ecf’s same PR, and the Run uses the exact executable replacements, not historical old summaries. No change is applied this turn.

L-BRIEF.txt
`````text
Preparation commit on branch pv-9ecf before the Run, in the same PR: replace only the executable comment-861 wording at the selected targets and its authority/retention instructions; preserve historical Current behavior quotations and all other tracker fields. The Run writes the exact selected executable replacements, leaving retained current source blocks unchanged if R-MASTER wins. Preserve the original archived C′ form with no note. Archive the reviewed r97 record to supply the authority reference. No real branch or tracker edit occurs in this panel turn.
`````

L-NOTE.txt
`````text
Preparation commit on branch pv-9ecf before the Run, in the same PR: replace only the executable comment-861 wording at the selected targets and its authority/retention instructions; preserve historical Current behavior quotations and all other tracker fields. The Run writes the exact selected executable replacements, leaving retained current source blocks unchanged if R-MASTER wins. Append exactly L-NOTE-append.md under docs/research/panels-2026-10/r89/check/tally/form-Cprime.md; all original bytes remain an exact prefix. Also qualify the duplicate r89/r89b/form-Cprime.md with a pointer note only if the reader supplies and accepts that exact additional text; no silent archive rewrite. Archive the reviewed r97 record to supply the authority reference. No real branch or tracker edit occurs in this panel turn.
`````

L-NOTE-append.md
`````text


## Dated execution note — 2026-11-02, Panel R r97

The form above records exactly what Panel J and owner item 24 approved at 3109b5b; its original bytes remain unchanged. For execution in pv-9ecf, use the corrected Agent Brief comment 861 and the exact selected replacements in the [Panel R r97 record](../../../r97/notes.md). The owner’s wording precedent is “For such wording questions, try to solve by getting a consensus of the panel”. This note grants no independent authority to change an assertion, fixture or approved policy. Items 4 and 24, including the complete “Hourly cloud cases” block, retain their meaning; any substantive unresolved conflict returns to the owner.
`````
L-NOTE’s append preserves every original byte in check/tally/form-Cprime.md. check/prospective-archive-form-Cprime.md demonstrates that exact prefix. The duplicate r89/r89b/form-Cprime.md remains the original adoption record, and authority-replacement.txt explicitly labels it historical; if you require a sidecar note there, print its complete bytes and treat it as a distinct Q4 alternative, not silently part of L-NOTE. The external /var/tmp/provisiond-panel-r89 stays read only. State which choice keeps the approval record honest, including the distinction between original approval and later executable wording. If R-OWNER wins, a landing preference does not authorize execution or a substantive adoption.

## Full original approved C′ — historical record, not a command to restore old retained blocks


`````text
## Form C′ — Form C with the unconditional wire acknowledgement retained

This is a complete landing form. The blocks below are all its replacements and explicitly retained direct dependents. Historical amendment paragraphs outside the printed replacement ranges stay as pinned; no new decision record is being proposed.

Changes from Form C: the `WIR-17` field rules opening, `CNF-34` and the `CNF-342` acknowledgement paragraph become **Retain verbatim** at their pinned bytes. Every other block is identical to Form C.

### Replace: DOM-16 — `01-domain-model.md:570–571` at the pin

```markdown
**DOM-16** A **paid create** is a create that starts new provider billing to the
operator, whether an upfront charge or hourly or other recurring machine rental; neither a
setup fee nor immediate payment is required. For each provider account, an ordering capability
(`provision_virtual` or `provision_bare_metal`) that permits a paid create MUST be conditional
on an explicit per-account `allow_orders` configuration flag: the descriptor (`PRV-44`) of an
account whose flag is false does not declare that capability, so that a misconfigured deployment
cannot start that billing. This is in addition to the per-request purchase acknowledgement
(`API-15`).
```

### Replace: PRV-10 — `02-provider-contract.md:159–162` at the pin

```markdown
**PRV-10** For a paid create (`DOM-16`), create MUST reject the request unless the
request carries an explicit purchase acknowledgement (`WIR-17`'s top-level
`acknowledge_purchase`), *and* the account is configured to allow ordering. Both, not either.
The configuration half is `DOM-10`'s gate on the create's ordering capability (`DOM-16`):
`API-7`'s step 5d at admission and `OPS-43`'s step 3 at claim.
```

### Replace: API-15 — `04-api-contract.md:987–992` at the pin

```markdown
**API-15** A paid create request (`DOM-16`) MUST carry an explicit purchase
acknowledgement — `WIR-17`'s top-level `acknowledge_purchase`, which the wire contract
owns — in addition to the account being configured to allow ordering (`PRV-10`). *"In its provider
options" until 2026-09-05, while `WIR-17` placed it at the top level; the wire contract wins, and a
spending authorization nested inside a driver-private object is one a strict server could not tell
from any other option.*
```

### Replace: configuration row — `00-overview.md:412–412` at the pin

```markdown
| `allow_orders`, per provider account with an ordering capability that permits a paid create (`DOM-16`) | `DOM-16` | boolean | yes |
```

### Replace: Create matrix row — `08-provider-notes.md:31–31` at the pin

```markdown
| Create | see `DOM-16` | see `DOM-16` | see `DOM-16` |
```

### Replace: DEF-17 historical scope paragraph — `09-known-defects.md:163–165` at the pin

```markdown
Requeue re-executed the original request verbatim. For a paid create (`DOM-16`), that is a
second purchase, gated by nothing beyond the same tenant token that placed the first one.
```

### Retain verbatim: WIR-17 field rules opening — `13-wire-contract.md:665–666` at the pin

```markdown
`ssh_public_keys` MUST be non-empty (`PRV-8`, `API-13`). `acknowledge_purchase` MUST be literal
`true` (`API-15`, `PRV-10`). `image` (nullable, a catalog identifier), `user_data` (nullable,
```

### Retain verbatim: CNF-18 — `10-conformance-checklist.md:124–135` at the pin

```markdown
- [ ] **CNF-18** — **AMENDED 2026-09-08 (`ADR-0018`) — the table is `DOM-10`'s, and the descriptor's
      fields are rows too.** For every driver, every declared capability has a working code path,
      and every implemented operation with a capability entry in `DOM-10`'s table has its
      capability declared. Table-driven over that table, one case per (driver, capability) pair;
      the three capability-less methods are `CNF-20`'s and are not rows here. **Then iterate the
      descriptor** (`PRV-44`), one case per (driver, field): a declared value has a working code
      path behind it — a declared ordering channel is searched, a declared evidence source is read,
      a declared surviving attachment kind is listed, and each ordering channel carries
      its own validated `order_budget` — and a field with nothing to declare says so
      explicitly rather than being absent. An ordering capability withheld under `DOM-16` is outside the implemented-implies-declared rows for that account; `CNF-19` and `CNF-55` cover its gate. (`DOM-15`, `DOM-10`, `PRV-4`, `PRV-44`)
      *Amended 2026-10-09 (`ADR-0036`): the order-budget field is iterated per channel.*
      *Amended 2026-10-22 (`pv-p3k`; panel r62, `docs/research/panels-2026-10/r62/`; owner decision 2026-10-22): applied the reviewed ordering-capability change.*
```

### Retain verbatim: CNF-19 — `10-conformance-checklist.md:137–139` at the pin

```markdown
- [ ] **CNF-19** — Create is refused when the provider has not declared the matching
      provision capability — with the driver's internal ordering flag set to permissive,
      so the test proves the outer gate exists. (`DOM-10`, `DEF-10`)
```

### Retain verbatim: CNF-34 — `10-conformance-checklist.md:256–279` at the pin

```markdown
- [ ] **CNF-34** — Validation is enforced in the worker even when the stored request bypasses
      the API layer. On separate creates, store records missing a caller-supplied field —
      `acknowledge_purchase` (`WIR-17`: "`acknowledge_purchase` MUST be literal `true`") — and
      an api-filled admission field, using the accepted-price fields in `request_summary`
      (`OPS-43`: "the accepted recurring price, its currency and its period"). For the caller field assert `invalid_request` with
      `details.field: "/acknowledge_purchase"` and `retryable: false`; for the api-filled
      field assert `conflict`, `details.reason: "incomplete_record"` and `retryable: true`.
      Assert the same kind, applicable reason and `retryable` on the error and the operation
      view (`WIR-9b`), `failed`, no driver call, and the create's commitment released in full
      with no setup-fee or first-unit debit.
      Repeat the caller-field case on an install, using `API-14`'s "explicit destructive
      acknowledgement". Assert `invalid_request` with `details.field: "/acknowledge_destruction"` and `retryable: false`
      on the error and view, `failed`, no driver call, both marker columns still null,
      `disk_effect: "none"` and `rescue_exit: "none"`. The install fixture uses that caller
      acknowledgement; an api-filled install case applies only if the release names a field the
      `api` writes at install admission, and the fixture must identify that field. It asserts
      `conflict`/`incomplete_record`, `retryable: true` and the same untouched-install outcome.
      Complete-record controls on create and install proceed. (`OPS-23`, `OPS-43`, `API-14`,
      `WIR-17`, `WIR-9a`, `WIR-9b`, `OPS-11`, `OPS-45`, `LDG-39`)
      *Amended 2026-10-17 (`pv-14b`; panel r55, `docs/research/panels-2026-10/r55/`):
      added missing-field fixtures, error/view agreement, commitment release,
      install marker outcomes and complete-record controls.*

      *Amended 2026-10-22 (`pv-ss4`; panel r62, `docs/research/panels-2026-10/r62/`): applied the reviewed field-pointer form and validation ordering.*
```

### Replace: CNF-55 — `10-conformance-checklist.md:340–359` at the pin

```markdown
- [ ] **CNF-55** — A paid create (`DOM-16`) is rejected without both the
      per-request purchase acknowledgement and the account-level opt-in. On an account whose
      `allow_orders` is false, assert `GET /v1/providers` lists it without its ordering
      capability, and that a create carrying `acknowledge_purchase: true` is refused at `API-7`'s
      step 5d: HTTP `501`, `unsupported`, `details.provider_account` and `details.capability`
      naming the account and that capability, `retryable: false`, and, with a balance too low for
      the create, no `details.refusals` or `details.not_checked` and no operation or commitment.
      A same-key, same-body replay of a create admitted before the flag was turned off returns its
      stored result. Admit a complete resource-offer (`offer_is_resource`) create with
      `allow_orders` true, and assert this create's exclusion for its provider account, ordering
      channel and offer id is held at admission (`PRV-42`, `STO-58`). While it is still queued
      and unclaimed, restart with only that flag changed to false, and assert the worker
      refuses it at `OPS-43`'s step 3 with the same kind, `details`
      and `retryable: false` on both the error and the operation view, `failed`, the commitment
      released in full with no setup-fee or first-unit debit, this create's settlement freeing
      that same held resource-offer exclusion (`STO-58`), and no provider request, including
      no List offers read. (`API-15`, `PRV-10`, `DOM-10`, `DOM-16`, `API-7`, `OPS-43`, `WIR-9a`,
      `WIR-9b`, `LDG-39`)

      **Hourly cloud cases.** Each admission case uses a fresh idempotency key. Use an
      otherwise valid, sellable hourly cloud catalogue offer
      with a positive recurring provider price and no setup fee, on a healthy assigned provider
      account implementing `provision_virtual`. Keep all unrelated sale, price, balance and
      admission conditions satisfied in the fixture. The driver is internally permissive and
      would start hourly billing if its create method were called; count its create calls and
      simulated billing starts. This fixture supplies the sale evidence needed for the test;
      it does not authorize sale of a live offer withheld under `PRV-13b` or `PRV-31`.
      With `allow_orders: false` and `acknowledge_purchase: true`, assert the provider listing
      omits `provision_virtual` and a fresh-key create fails at `API-7`'s step 5d with HTTP `501`,
      `unsupported`, `details.provider_account` naming that account,
      `details.capability: "provision_virtual"`, and `retryable: false`. Assert no operation,
      commitment or provider request, zero driver create calls and zero simulated billing starts.
      With `allow_orders: true`, separately omit `acknowledge_purchase` and set it to `false`.
      Each request fails HTTP `400`, `invalid_request`, `details.field: "/acknowledge_purchase"`,
      `retryable: false`, without an operation, commitment or provider request, and with zero
      driver create calls and zero simulated billing starts. A fresh-key control with both
      `allow_orders: true` and `acknowledge_purchase: true` reaches the fixture driver's create
      exactly once and records exactly one simulated hourly billing start.
      Separately admit this hourly catalogue create while both are true; while queued and
      unclaimed, restart with only `allow_orders` changed to false. Assert rejection at
      `OPS-43`'s step 3 with `unsupported`, the same account and capability details and
      `retryable: false` on both the error and operation view, `failed`, commitment released in
      full with no setup-fee or first-unit debit, no provider request including no List offers
      read, zero driver create calls and zero simulated billing starts. This catalogue offer
      holds no resource-offer exclusion. On a separate admitted hourly create with
      `allow_orders: true`, remove only its stored `acknowledge_purchase` before claim. Assert
      `OPS-43`'s step-3 `invalid_request`, `details.field: "/acknowledge_purchase"`,
      `retryable: false` on the error and view, `failed`, full commitment release with no
      setup-fee or first-unit debit, no provider request including no List offers read, zero
      driver create calls and zero simulated billing starts. (`WIR-17`, `OPS-23`, `OPS-11`)

      *Amended 2026-10-22 (`pv-p3k`; panel r62, `docs/research/panels-2026-10/r62/`; owner decision 2026-10-22): applied the reviewed ordering-capability change.*
```

### Retain verbatim: CNF-182 Robot test-mode case — `10-conformance-checklist.md:2371–2376` at the pin

```markdown
- [ ] **CNF-182** — The Robot driver's order test flag **defaults to test mode**, and a real
      purchase requires an explicit spend intent that is set exactly once, where `API-15`'s
      acknowledgement and `PRV-10`'s `allow_orders` both hold. Asserted by placing an order with
      the acknowledgement absent and confirming the API returns a `Cancelled` transaction and no
      server. **A driver defaulting to "real purchase" turns every mistaken conformance run into a
      bought server.** (`PRV-34`, `API-15`, `PRV-10`)
```

### Retain verbatim: CNF-342 acknowledgement paragraph — `10-conformance-checklist.md:4311–4320` at the pin

```markdown
      Separately omit the caller-supplied purchase acknowledgement from the stored record:
      admit a complete, valid resource-offer (`offer_is_resource`) create and assert this
      create's exclusion for its provider account, ordering channel and offer id is held at
      admission (`PRV-42`, `STO-58`), then remove only the stored caller-supplied acknowledgement
      before worker claim and validation (`OPS-23`). Assert rejection at
      `OPS-43`'s step 3, "Repeat boundary validation under `OPS-23`": `invalid_request` with
      `details.field: "/acknowledge_purchase"`, `retryable: false` on the error and operation view, `failed`, commitment
      released in full with no setup-fee or first-unit debit, this create's settlement freeing
      that same held resource-offer exclusion (`STO-58`), and no provider request at all,
      including no List offers read.
```

### Replace: CNF-364 setup and retained list-offers assertions — `10-conformance-checklist.md:140–154` at the pin

```markdown
- [ ] **CNF-364** — **The claim-time List offers read is gated on `list_offers`.** Admit a
      complete resource-offer (`offer_is_resource`) create on an account that declares
      `list_offers` and the ordering capability, with `allow_orders: true` and the request
      carrying `acknowledge_purchase: true`. Assert this create's exclusion for its provider
      account, ordering channel and offer id is held at admission (`PRV-42`, `STO-58`).
      While it is still queued and unclaimed, restart with a descriptor for that account that
      removes only `list_offers`, keeping the ordering capability declared and the driver's
      List offers code path answering, so the test proves the gate exists, as `CNF-19` does. Assert the worker
      refuses the create at `OPS-43`'s step 4: `unsupported` with `details.provider_account`
      naming the account and `details.capability: "list_offers"`, `retryable: false` on both the
      error and the operation view, no `details.refusals` or `details.not_checked`, `failed`, the
      commitment released in full with no setup-fee or first-unit debit, this create's settlement
      freeing that same held resource-offer exclusion (`STO-58`), and no List offers read,
      per-order key upload or order request. (`DOM-10`, `OPS-43`, `OPS-11`, `LDG-39`, `WIR-9a`,
      `WIR-9b`)
      *Amended 2026-10-22 (`pv-009`; panel r62, `docs/research/panels-2026-10/r62/`): applied the reviewed claim-time capability gate and refusal checks.*
```

### Retain verbatim: CNF-344 channel declaration is no capability grant — `10-conformance-checklist.md:4358–4363` at the pin

```markdown
- [ ] **CNF-344** — **Amended 2026-10-12 (`ADR-0037`, Q28).** **Each channel declares its own order budget.** Enumerate the
      descriptor's ordering channels and assert each has a positive `limit` and finite,
      positive `per`; no top-level `order_budget` substitutes for a missing channel
      entry. Verify the declared limit documents capacity; Robot's reported `403 RATE_LIMIT_EXCEEDED` raises `PRV-5`'s alarm naming account and request path (and channel where useful) and closes the local gate. No local request count raises that alarm.
      Another channel's mere declaration authorizes no new ordering capability.
      (`PRV-44`, `PRV-40`, `DOM-10`)
```
`````
## Response contract

1. Read the whole packet and required sources, recheck every quote byte for byte at its stated revision (raw LF/indentation, not normalized text), recheck every retained block and each motivating claim. Name any inaccurate premise; apply notes.md rule6 exactly. Existing display reflows in historical/inherited quotations are disclosed separately from new candidate payload identity; do not claim they are raw-byte matches or silently fix them.
2. Final explicit picks: Q1; Q2a, b, c, d, e and every further found sentence; Q3; Q4. Separately mark ACCEPT/CANNOT ACCEPT for every complete printed candidate, giving conditions as distinct alternatives. Requested counterarguments are not votes. A usage-limit answer is missing.
3. Give a complete inventory of every source-content summary in the package’s added/changed text, with C′ and decoded-comment locations; distinguish inherited retain blocks, unchanged historical fences, bare owner/list pointers and prospective local new rules. Check occurrences.md and reference-paragraphs.json independently, not by trusting the manager’s classification. Count source is that explicit list, not an uncited prose total.
4. For each pick classify behavior, requirement/owner-item4+24/C′ meaning, and check strength separately as WORDING-ONLY or SUBSTANTIVE. Also preserve owner item7’s PR60 assertion adoption. A meaning/behavior/test-strength change goes to the owner; the 2026-10-28 rule applies only to a verified wording-only settlement.
5. Verify no assertion is weakened: name each target assertion and where it lands, including PR60 marker fixture; unconditional WIR-17 acknowledgement; broad CNF-34 and CNF-342 domains; all CNF-55 Hourly cloud assertions, original resource-offer exclusion/low-balance/replay/worker checks; both authorizations; and CNF-364’s List offers negative gate demonstration. Confirm nothing items4+24 did not approve is added. A quotation is evidence, not a new runtime assertion. Do not change Lean/proof/guard/gates/negative controls or invent new fixtures.
6. Strongest contrary argument on request, then actual choices. If nothing printed is acceptable, supply one exact complete alternative and distinguish it as unread by the other seats. Scope excludes pv-5pmu, pv-e45e, pv-by1w, pv-3zzo, pv-y0to and every closed bead; PR60 is evidence for retaining current text only. Do not reopen their policy.

This turn only launches r97. No tally, fix, Run, push or owner question. A later turn may run ONE r97b on an unsettled result; never launch it yourself.
