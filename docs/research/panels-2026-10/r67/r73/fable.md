Both forms applied and checked independently. Receipts first, then the two votes.

## Receipts

- **Application.** All 27 anchors in printed-forms.json match the brief's base offsets. I applied each form to a fresh `git archive` of c5f897c under `fable/scratch/r73/{H,U}` by descending offsets. My bytes differ from the coordinator's clones only in insertion joiners (I used blank lines where the coordinator joined with a space). Form text is identical.
- **Coverage**, run unpiped from each scratch clone:

| Form | exit | uncovered | baseline |
|---|---|---|---|
| H | 0 | 74 | identical to base |
| U | 0 | 74 | identical to base |

- **Quotations.** PRV-50, PRV-41, DOM-9 and the long OPS-43 sentence are verbatim in c5f897c (whitespace-normalized fixed-string search). The header's `CNF-166` reference lands on the item S6 amends (lines 3684–3706).
- **Lean.** `tools/formal/Provisiond/Admission.lean` models the tail as `purchaseTail`/`tailAdmitted`; `empty_iff_admitted` states that an empty refusal list equals the tail's own verdict. S1's stale refusal fires "if the tail has collected no refusal", outside the tail, exactly as step 5d's `unsupported` already does in `createPurchaseTail`. No theorem is flipped, made vacuous or unreachable. Both forms share S1, so this is form-neutral.
- **Base retention in U's replacements.** Every base sentence of M1–M7, R99, R299, R243 and M8 survives with a clause inserted or the sentence reordered; nothing dropped.

## Form H — ACCEPT

**Strongest argument.** The checklist already governs fixtures by a blanket default paragraph (the 2026-10-08 "Seeds in the items below"), so the header is the established instrument. It scopes the fresh fixture to "asserts or relies on a create being admitted or succeeding", which reaches implicit creates ("admit a complete create", "claim a create", a machine that exists only through admission) that any enumeration misses, and its second clause keeps every refusal age-quantified, which is target (1) stated once instead of 112 times.

**Does H cover every success?** Yes, as far as I could falsify it. I checked each category against the header's words:
- *Proceeds* (CNF-99 "creates ... proceed"): an asserted admission. Covered.
- *First send* (CNF-299): "succeeds as a first send" is a create succeeding when the generic write is a create. Covered through "relies on".
- *Generic writes* (CNF-299's "the next write", CNF-285): covered whenever the implementer's write is a create; a non-create write is untouched by S1.
- *Shared winning race* (CNF-343 initial pair, CNF-163): the item relies on the winner's admission, so it "runs on" the fresh row; the loser reads the same per-account `offer_listings` row at the same instant, so it cannot be at a different age. Covered.
- *Release probes* (CNF-343): named in the header and in exact M8. Covered twice.
- *Creates used to reach later assertions* (CNF-278 third and fourth barriers, account-read cases, fresh-account claim; CNF-364; CNF-318): "relies on a create being admitted" pins their admission fresh; the later claim-time failures are failures, not create refusals, so the whatever-age clause does not bite them. Covered.
- Extensions: untouched, since S1 is "On create".
I also swept the 240 items the coordinator excluded for admission vocabulary. The nine hits (CNF-19, 185, 208, 218, 253, 272, 304, 311, 312) are refusals, extensions, operator verbs or meter prose, not create successes. **No miss named.**

One reading note, not a repair: the second sentence says the default "qualifies only the admission or success assertion", while the first sentence also covers an admission the item merely relies on. Read with the first sentence it is unambiguous; I do not stake the vote on it and propose no AMEND, since a scope clarification could not be verified behaviour-unchanged.

**Does H narrow any refusal?** No undeclared one. The header's third clause keeps every unspecified refusal at every age. Exact M8 narrows CNF-343's continued losing probes to fresh listings; that is declared, and it is principled rather than cosmetic: after "keep it unresolved across engine restart" the row can age past the bound, and a stale further create would be refused `provider` before the barrier, which does not show the exclusion guard. The initial race needs no such clause because both creates share one row at one instant. Earlier setups pinned fresh: CNF-278's queued and claimed creates, CNF-307's resend, CNF-343's winner. Later refusals retained at all ages: CNF-278's "a create naming it is 409 state" on all three statuses (state-first in the tail, so the stale check never runs), the second barrier, CNF-307's guard race, CNF-343's termination race.

**Observation on guard refusals, applying equally to both forms.** CNF-278's second barrier, CNF-307's "race admission against the existing account/fence conditional-write guards" and CNF-343's termination race are conditional-write refusals. At a stale age S1 refuses `provider` before the barrier, so a stale run satisfies "is refused" without exercising the guard. Neither form specifies their age (U qualifies none of them either), nothing flips, and a fresh run still exercises the guard, so this is recorded, not gated. It is the one place where Reader 2's M8 argument would extend further than M8.

**Trace (my own, S1 identical in H and U).**
- D1 unsellable or absent offer, any status healthy, any age or no row: single `offer_not_sellable` 400, retryable false, cap (when supplied) and balance skipped `offer_not_sellable`, no pacing, no amounts, no write, receipt or call. Stale check unreached because a refusal was collected.
- D2 healthy sellable, channel + solvency + no rate + cap: 429 headline with channel's own `retry_after_ms`, entries channel, solvency, rate; cap and balance skipped `rate_unavailable`; envelope true; same at every age.
- D3 each unhealthy status + unsellable + channel + solvency, rate present or absent, cap or not: state first (`account_unreachable`, `credentials_rejected` true; `terminated` false), then offer, channel, solvency, rate when absent; skip reasons per present check in account, offer, rate order; envelope false; subordinate channel delay never supplies headline pacing; identical at stale, fresh and no row.
- D4 healthy sellable, rate, no cap: balance evaluated, `not_checked: []`; short balance 402 false at every age; adequate balance fresh 202 with normal admission writes and receipt; adequate balance stale 502 `provider` retryable true, no write, receipt, pacing or provider call.
- D5 resend of the same key after recoverable faults clear: stale 502 true with no receipt, so a later resend re-evaluates; fresh admitted (H by header, U by M1).
- Healthy no row: empty offers set, so the named offer is absent and D1's shape results, with no `read_at` to test. Equality boundary: `read_at` exactly at the age is "no older than", admitted.
- Extensions (64 cases): fence + solvency + absent rate unchanged, 409, no synthesized pacing.
This matches the coordinator's trace-cases.json at every point I compared; the only base differences are the two target-(2) rows.

**Strict quoting, sentence by sentence.** S1: three bare references, MUST inside API-7's own tail passage. S2: STO-60's MUSTs are its own; the one claim about PRV-50 carries PRV-50's whole sentence. S3: OPS-51's MUST is its own; the PRV-41 claim carries the verbatim sentence. S4: bare "See `OPS-50`"; OVR-17's prose above the table makes no universal the row breaks. S5: register rows; the "shorter than the offer-listing age" range follows the register's convention (the DOM-8 row already carries "at least twice", which DOM-8 itself does not state). S6: the OPS-43 claim carries the whole sentence; "See `STO-60` and `OPS-51`" is bare. M8 and header: bare `OVR-19`/`CNF-166` references, no MUST. Pass.

Non-blocking wording notes: "the authentication stop" is not a defined term (the PRV-41 quote carries its meaning); S4's "Why there" cell says only "See `OPS-50`", which is a fence rule rather than a placement reason.

**Counterargument (written on request).** A blanket default is only as good as its scope words; "relies on a create being admitted" asks the implementer to recognise implicit creates, and the second sentence's "assertion" could be read to exclude relied-upon admissions, leaving CNF-278's queued and claimed creates unpinned. U names each create and leaves no such reading. Keeping M8 while dropping M6 concedes that guard refusals need explicit text, and the header does not say which refusals are guards.

## Form U — CANNOT ACCEPT (no gated loss)

**Strongest argument.** U's policy, storage, refresh and settings are byte-identical to H's and pass the same checks, so the only question is target (3). U supplies explicit fixtures to nine items and leaves 103 create paths with none, including direct checked successes of the same kind as the three r72 repaired: CNF-364 ("Admit a complete create on an account that declares `list_offers`"), CNF-318's accepted create, and CNF-278's queued, claimed and fresh-account creates. The carried r72 finding that CNF-99/299/243 missed success fixtures applies verbatim to these, and no stated criterion explains why CNF-138 and CNF-315 got a clause while CNF-364 and CNF-318 did not. Any repair that adds the missing fixtures is behaviour changed, so no AMEND can rescue the form in this round; the scoped alternative is H's header.

No CNF assertion or Lean theorem flips under U; the omissions leave admitted creates with an unstated listing fixture, as base left the catalogue source unstated. Quotations and anchors pass as for H. U's M6 and M4 are more explicit than H's header for the concurrent races, and R299's restructuring keeps every base assertion.

**Counterargument (written on request).** An unstated fixture is not a defect under the gate: the base never named a catalogue fixture either, an implementer supplies state, and nothing becomes false or unreachable. Under that standard U is exact reader text with explicit per-item precision where it matters most (races, resend, commitments), and its remaining omissions are a disclosed follow-up rather than a reason to reject.

## Preference

H. Both would be preferred over the base policy without fixtures, but only H completes target (3) without an enumeration, and it does so with the checklist's existing default-paragraph mechanism.
