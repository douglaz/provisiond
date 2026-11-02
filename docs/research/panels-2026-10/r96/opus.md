# Panel Q r96: Opus reader answer (pv-gvc, owner item 13)

I applied notes.md rule 6 exactly as written. This prompt adds no void rule. I read specification text only from my clone, detached and clean at `f8a30457eb84b3077e7580732bef665b3763aae1`. I made no writes outside `tmp/opus/`, ran no gate, build or `br`, and read no other reader's output.

**Votes.** Q1: **Q-QUOTE**. Q-QUOTE ACCEPT, Q-POINTER CANNOT ACCEPT, Q-KEEP CANNOT ACCEPT. Q2: **L-NOTE** with the matching Q-QUOTE appendix. L-BRIEF ACCEPT, L-NOTE ACCEPT.

---

## 1. Verification and attribution audit

**Package identity, checked myself**
- The committed `docs/research/panels-2026-10/r83/check/settled-Q1-B.txt` at M has sha256 `37db59ef…64c8`. That equals `/var/tmp/provisiond-panel-r83/check/settled-Q1-B.txt` (read only) and `evidence/settled-Q1-B-at-pin.txt`.
- comment853 text decoded from `evidence/pv-gvc.json` equals `evidence/comment-853.md`, which equals `next10-agent-brief.md`.
- comment853:24–30 equals settled:1–7, and comment853:35–61 equals settled:9–35. So the desired and acceptance blocks are the frozen package.
- `Q-KEEP.txt` equals settled. `comment-853-Q-KEEP.md` equals comment853.
- Every exact block printed in the brief equals its file. That covers the three replacements, the three packages, the three notes and both authority lines.
- For each candidate comment, undoing its two substitutions (authority line and target) reproduces comment853 byte for byte.

**Target occurrence.** It occurs once in each file: comment853:57–59 and settled:31–33.

**OPS-43**
- I read the complete home at `03-operation-lifecycle.md:757–936`.
- PR65 (`f8a3045`, parent `6a3b601`) added two things:
  - the step-1 tenant paragraph at :786–792;
  - the step-8 tenant guard at :813–827.
- The parent contains no "Where the tenant is suspended". At M the supporting source is `03-operation-lifecycle.md:786–788`:

  > Where the tenant is suspended, fail this existing create with conflict, details.reason: "tenant_suspended", and retryable: false on both the error and operation view.

- The step-1 context matters: "Make no provider request, including List offers or a per-order key upload." (:788–789). Ordering is "The first failing check stops subsequent checks" (:854).

**Every named reference** (c = comment853, s = settled-Q1-B.txt)

| Reference | c | s | Class | Verified |
|---|---|---|---|---|
| “B: say it explicitly (Recommended)”, `owner-decisions-1030.md` item 13 | 6 | absent | owner-record quote | Words exact against the owner file (it uses straight outer marks). Path exists at M. |
| `04-api-contract.md:626` at `3109b5b` | 10 | absent | historical locator | Fence c:13–19 byte-identical to `3109b5b`:626–632 and `832a219`:626. Still at M:645–651. |
| OPS-39; WIR-9a, WIR-10b | 13; 16 | absent | owner pointers inside the historical fence | — |
| "`OPS-11` classifies as admission-only and forbids a worker to emit" | 18 | absent | **actual summary**, but it is API-58's own source text, quoted as dated history | Accurate against OPS-11 :257–262 ("they MUST NOT be emitted by a worker or a driver"). Not Run text. Changing it would amend API-58 source, outside item 13. **No prospective correction.** |
| DOM-20 anchor sentence | 19, 24 | 1 | placement locator, not an attribution | Once at API-58 M:650–651. **Not byte-identical**: the source has a line break between "that" and "kind". Same in every option. |
| API-58; CNF-202 | 24; 35 | 1; 9 | landing instructions | — |
| LDG-32, "the create fails deterministically" | 27 | 4 | quoted pointer supporting the package's **own new** release rule | Exact contiguous at `12-billing-and-ledger.md:312`, home :310–345. Qualifiers: the list is "**every** terminal outcome"; :325 says the outcome "includes the create row's case" (an inclusive list). The no-debit duty is not attributed to LDG-32. |
| LDG-35 | 30 | 7 | bare owner pointer inside the package's own ordering rule | Home :431. |
| WIR-10 operation-kind set | 39 | 13 | source-list pointer; nothing enumerated | Precise enum home is WIR-10a, `13-wire-contract.md:288–289`; WIR-10 at :262 is the view. Fable and Opus disclosed this at r83, and all four readers accepted. **Retained, not corrected**: WIR-10a is "The closed enums" of WIR-10's view, directly after it, so the pointer reaches the right list. It does not assert anything about what WIR-10 says. |
| LDG-32 says "the create fails deterministically" | 45 | 19 | explicit quoted attribution | Exact at :312. |
| API-64 retry | 48 | 22 | fixture pointer | API-64 enqueues "`requested_by: operator`" (:1107). |
| OPS-43 | 57–58 | 31–32 | **the only unquoted summary attribution in executable text** | Supported by :786–788. Missing its quote. |
| "held-power scenario above" | 60 | 34 | internal reference | CNF-202 M:2280–2297. |
| item 19 quote; item 13 quotes; `owner-questions.md:13` ×2 | 67; 71, 87; 76, 82 | absent | owner quotes | All exact. Both quoted sentences really are on line 13, one long line. |
| Drift section | 91–94 | absent | historical | Both files have identical blobs at `3109b5b`/`832a219`; `832a219` is an ancestor of M. Scoped to that named pair. |

**No other occurrence needs correction.**

**The target's three clauses**
- **"follows OPS-43's tenant-status refusal"** is a claim about OPS-43. It asserts that OPS-43 contains such a refusal and that the refusal governs this case. The r83 record proves it is an attribution rather than a pointer. At pin `3109b5b` the claim was false: Fable at r83 wrote "No such refusal exists at the pin", and `tally-evidence.md` says "absent from pinned step 1 (:776–784)". That is exactly the failure AGENTS.md:29–32 targets.
- **"not a purchase"** is the package's case expectation, contrasted with the refusal. Read as a claim about OPS-43, it is supported by "fail this existing create" and by :788–789. It also follows owner item 3.
- **"it is not required to succeed merely because its claim defeated the administrative write"** is the package's **own case rule**. OPS-43 says nothing about the administrative write. Its support is API-58 M:665–666, "loses this race and settles through that worker instead".

Q-QUOTE carries all three verbatim at Q-QUOTE.txt:31–35.

**Q-KEEP's exemption is not established.** AGENTS.md:45–46 covers "every sentence asserting what another requirement says". AGENTS.md:29–32's own bad example is a summary ("`WIR-30` forbids…"). The checker's statement that summary verbs are "OUT OF SCOPE" describes the lexical gate only, and it says a wrong summary "stays a review problem".

---

## 2. Byte checks

**Convention.** I compared raw bytes. The only allowed adjustment is removing the six-space CNF list-container indent, and only at landing. comment853 and the Q-*.txt packages have no container indent, so I compared their payloads directly. No other whitespace normalization.

**Q-QUOTE payload**
- It is 172 bytes and equals `03-operation-lifecycle.md` from "Where" at :786 through "view." at :788.
- That includes both line breaks and the three-space continuation indents.
- It occurs once in the file, inside OPS-43's home, and equals `evidence/OPS-43-quote.txt`.
- At landing the lines become six spaces plus the original line, or nine spaces before "create" and "and". Removing exactly six restores the source bytes.
- The payload contains no nested requirement quotation. "tenant_suspended" is a value, in straight marks inside curly outer marks, which is the checker's stated convention. Line 790's nested OPS-11/LDG-32/LDG-39 quotes fall outside the payload and are not relied on.

**Other quotations**
- LDG-32's phrase is exact at :312. It is unchanged at package lines 4 and 19 in every option.
- The authority-line owner words are exact (see §1). Both paths exist at M.
- The note's owner-rule quote is exact at `/var/tmp/provisiond-manager/manager-brief.md:1694`, read only. That passage is dated "owner, 2026-10-28" at :1692.
- The note's "Original sentence" block equals settled:31 (from "A claimed") through :33 ("write."), with its original line breaks. Its executable block equals `Q-QUOTE-replacement.txt`.
- `note-Q-QUOTE.md` equals the brief's printed bytes, including the leading two newlines.
- `check/prospective-archive-Q-QUOTE.txt` equals settled followed by the note. Lines 1–35 are an exact prefix.

**Gate reach, a disclosure.** `ATTRIB` requires backticked IDs (`tools/check_citations.py:234–236`). The citation gate therefore never reaches this package's bare-ID attributions: not the target, not Q-QUOTE's quote, not LDG-32's two quotes. The stop turn's green trial says nothing about any of them. The same bare-ID convention is already in PR65's landed OPS-43 text (OPS-11, API-58 and OPS-49 quotes). Q-QUOTE's quote is carried by manual verification, which I did above.

---

## 3. Assertion inventory

| # | Assertion | Original (s / c) | Q-QUOTE (pkg / comment) | Q-POINTER |
|---|---|---|---|---|
| A1 | Scope: "A claimed create first picked up while the tenant is suspended" | s31–32 / c57–58 | verbatim, 31–32 / 57–58 | narrowed to "this test's claimed create…" |
| A2 | Worker refusal: "follows OPS-43's tenant-status refusal" | s32 | verbatim, :32, plus quote :32–34 | "see OPS-43" plus "assert tenant-status refusal" |
| A3 | "not a purchase" | s32 | verbatim, :32 | "assert … no purchase" |
| A4 | "it is not required to succeed merely because its claim defeated the administrative write" | s32–33 | verbatim, :34–35 / c60–61 | verbatim |

**A4 is not a blanket rule.** "Not required to succeed merely because…" removes one ground for success. It does not say every claim winner fails.
- A create claimed before suspension landed is outside A1. API-58 says it "MUST be allowed to settle", and CNF-202 M:2310–2313 tests a guard winner proceeding.
- In-scope failure comes from OPS-43's refusal (A2), not from A4.
- Q-QUOTE's quote is conditional ("Where the tenant is suspended"), so it adds no blanket rule.

**Surrounding assertions.** All of these are byte-unchanged in Q-QUOTE.txt:1–31 and :35–37. The diff replaces only s:32, with three lines.
- Race in both orders. Administrative-first prevents the claim. Claim-first prevents the administrative failure, preserves the returned claim number, and leaves settlement to that worker.
- Same guarded transaction does the close and full release, with no setup-fee or first-unit debit. Order is generation check → LDG-35 primitive → status write → release, with a zero-row short circuit.
- Independent store fixtures, "not a claim that normal queue ordering leaves an eligible create unclaimed". The loop covers every WIR-10 caller kind.
- Positive asserts: one row, failed, conflict with tenant_suspended, requested_by caller, system_reason null, no provider request. Create fixture: nonzero reserve, setup fee and prepaid unit, then release and no debit.
- Five one-term-at-a-time negative guards, each with the other terms satisfied. Each asserts zero rows, unchanged operation and origin/error, and no commitment or provider effect.
- Stale old parent after resume and a fresh suspension.
- Held-power case retained as the scheduling case.

No check is weakened.

**Does Q-POINTER carry the refusal outcome?** Yes, by name plus pointer, as the original does. Neither version states the error values. So the pointer does not drop it. Q-POINTER's problem is the opposite one (see §4).

---

## 4. Classification

**Q-QUOTE**
- **Behavior: WORDING-ONLY.** OPS-43 already mandates the refusal at M. The parenthetical only attributes it.
- **Requirements / item 13 / Q1-B meaning: WORDING-ONLY.** Every adopted word is retained. "OPS-43 says" adds no MUST. Item 13's "adopt exactly" is departed from in wording only, which is the case the 2026-10-28 rule covers. The authority line and the note disclose it, so the original adoption is not silently erased.
- **Check strength: WORDING-ONLY.** No assertion is added or removed. The quoted values are OPS-43's, are already referenced by the original, and are already asserted at CNF-202 M:2302–2305 by PR65. Gate reach is unchanged.

**Q-POINTER**
- **Behavior: WORDING-ONLY.**
- **Meaning: WORDING-ONLY in substance, but A1's scope is narrowed** from a statement about a class of creates to "this test's" create. That also presupposes the race uses a create.
- **Check strength: SUBSTANTIVE.** The original race paragraph uses declarative expectations. Its OPS-43 sentence can fairly be read as explaining "leaves settlement to that worker" rather than requiring the store race to drive the worker. Its A4 clause plainly tells the tester what *not* to assert.

  Under that reading, consider a store race test that stops after the zero-row and claim-number checks. It conforms to Q1-B. It fails Q-POINTER, which says "assert tenant-status refusal and no purchase" and so requires running worker logic inside "store cases". That is a strengthening, not a rule-3 loss. But a change in check strength is outside the wording exception (notes rule 3, final sentences) and belongs to the owner.

**Exclusions.** No deferred-operation predicate term, no claimed-then-deferred queued fixture and no guard repair is added in any option. The diffs confirm that only the target changes. pv-bxh and closed pv-kv2 are untouched.

---

## 5. Brief errors, counterexamples, contrary argument

None of these errors changes the question's premise. Rule 6 voids nothing. No vote of mine rests on any of them.

- **E1 (locator).** "comment853:57–60" and "settled-Q1-B.txt:31–34" overrun the target, which ends at 59 and 33. Lines 60 and 34 are the held-power sentence, which every option keeps. The replacement strings themselves are correct.
- **E2 (trivial).** OPS-43's home text ends at :936, not :937; line 937 is blank.
- **E3 (scope, disclosed).** The wording rule's home is the PR-handling bot-finding list, `manager-brief.md:1692–1696`. This finding came from pre-Run preparation with no PR open yet. The precedents I checked (r93, r94/r94b, r95) arose on PRs #53 and #65. The question has the same shape (only the wording of owner-adopted text), and L-BRIEF lands inside the pv-gvc PR, so I treat it as "such wording questions". Main should still disclose the extension.
- **E4 (understatement).** The brief says the green trial doesn't decide the manual rule. It is stronger than that: the gate cannot see bare-ID attributions at all (§2).
- **Note on the archive file.** settled-Q1-B.txt is `.txt`, so the appendix's Markdown heading and link won't render. Gates read only root `*.md` and `docs/adr/*.md` (for example `check_ids.py:65`), so nothing checks that link.

**Counterexample attempts against Q-QUOTE**
- **Unhealthy provider account.** A create first picked up while suspended on a `terminated` account fails at step 1's *account* read with account_terminated. The account read comes before the tenant read (:776–784 before :786), and :854 stops at the first failing check. So the *literal* universality of A2 fails for the adopted Q1-B, and equally for Q-QUOTE and Q-KEEP.

  Q-QUOTE does not make this worse. The quoted sentence follows "Next read this operation's tenant status", so OPS-43 supplies the precedence itself. A3 and A4 still hold, and CNF-202 M:2322–2324 already tests that the account refusal wins. Repairing it would add a fixture condition (a healthy account), which is substantive and outside this ballot.
- **Startup pass after a crash** (OPS-15 settles the create failed): same pattern. No purchase, no success.
- **A deferred create re-claimed later** is outside "first picked up" and is excluded by item 13.

None of these breaks Q-QUOTE relative to the adopted meaning.

**Strongest contrary argument (requested; not a vote).** The case for Q-POINTER: "One rule, one home" and "Arguments have owners too". Q-QUOTE copies OPS-43's error values into CNF-202, and the lexical gate cannot police that copy because the ID is bare. A later OPS-43 amendment would leave a stale quote that only review catches; r83's Q4-B, for instance, proposed `retryable: true`. Q-POINTER keeps OPS-43's text out of the checklist.

My answer: an attributed quote that goes stale becomes a detectably false quotation, not a silent second rule. CNF-202 at M already restates those values for PR65's worker case. And Q-POINTER buys its separation with a change in check strength that the wording rule does not authorize.

---

## 6. Q2 landing

**Pick: L-NOTE with `note-Q-QUOTE.md` exactly as printed.** ACCEPT.

L-NOTE keeps the record honest at the place where readers of item 13's "adopted form" actually land:
- Archived lines 1–35 stay an exact byte prefix, and the external r83 copy stays read only.
- The appendix states that the executable wording differs, gives both forms exactly, and limits itself to wording. Every statement in it is verified above: the original's bytes unchanged, the owner's 2026-10-28 rule quoted exactly, "wording correction only", and the deferred-operation guard fix still excluded.
- It changes neither item 13 nor Q1-B's meaning, behavior or check strength.

Conditions for L-NOTE:
- Archive the r96 record together with it, so that `../../r96/notes.md` resolves from `r83/check/` to `panels-2026-10/r96/notes.md`.
- After landing, the committed file is **prefix-identical**, not byte-identical, to the external frozen file. The stop report's "byte-identical" will then no longer hold. That is expected and disclosed. It matches the precedent of `r83/r83b/Q4-D.md` at M: the external copy is its exact 6,606-byte prefix, followed by dated r94 and r95 appendices. I verified the precedent; it is not a vote here.

**L-BRIEF: ACCEPT.** It is not false: the authority line calls the original historical. It is weaker in two ways:
- the archived adopted file keeps presenting, unqualified, a sentence the Run will not execute;
- "Panel Q r96" has no repository record unless it is archived separately.

**Accepted text.** I accept the exact Q-QUOTE authority line:

> **Owner decision:** “B: say it explicitly (Recommended)” (`owner-decisions-1030.md`, item 13). Original adopted form: `docs/research/panels-2026-10/r83/check/settled-Q1-B.txt`. Executable wording: Panel Q r96, Q-QUOTE; the original package remains the historical approval record.

I also accept the complete `comment-853-Q-QUOTE.md` and `Q-QUOTE.txt` as printed. I propose no alternative form.

---

Final Q1: Q-QUOTE; acceptability Q-QUOTE ACCEPT, Q-POINTER CANNOT ACCEPT, Q-KEEP CANNOT ACCEPT

Final Q2: L-NOTE (exact Q-QUOTE matching appendix `note-Q-QUOTE.md` and the Q-QUOTE authority line, both accepted; the r96 record must be archived so the link resolves); acceptability L-BRIEF ACCEPT, L-NOTE ACCEPT
