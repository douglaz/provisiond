# r67 notes (panel E: pv-tcs, pv-ytv): outcome rules, set BEFORE launch. 2026-10-25

Master `c5f897c`. Clones at `c5f897c`. One shared brief, docs/research/panels-2026-10/r67/brief.md, with no seats.
Scope approved by the owner 2026-10-21: panel E = pv-tcs + pv-ytv, ending in one owner question.
Q1 = pv-tcs (Forms F, S). Q2 = pv-ytv (Forms K, N). Each question is tallied on its own.

## Outcome rules (r63 rules 1-7; rule 3 = the gate)

Per question (Q1, Q2):
1. Each reader votes ACCEPT, AMEND or CANNOT ACCEPT on **each** form, and picks one form (or names a third shape,
   with its exact text). An AMEND counts for a form only if the reader marks it "behaviour unchanged" and its text
   changes no bullet of that form's listed behaviour (the manager checks). Otherwise it counts as CANNOT ACCEPT,
   with the reader's text as its pick.
2. A form carries at 3 of 4 picks with no blocking CANNOT ACCEPT. It goes to the owner as the panel's
   recommendation, with the tally. AMEND texts are merged into a final form, which gets a confirmation read
   (ACCEPT / CANNOT ACCEPT) before it becomes a Run's work order. The owner question quotes only behaviour the
   panel read.
3. **The gate.** A CANNOT ACCEPT must name a loss that changes a checked verdict:
   - a `CNF` assertion or Lean theorem the form flips, makes unreachable or makes vacuous (id or theorem name);
   - or a MUST/SHOULD (file, requirement id) with a trace that breaks it.
   A CANNOT ACCEPT that names none is recorded and does not block. Wording a reader dislikes is not counted.
   Pre-registered: under Q1, a form flipping a CNF assertion **that the form itself lists as amended** is not a
   gated loss; a flipped assertion the form does not list is.
4. If no form reaches 3 of 4, the manager takes the best-supported reader form, states the disputed point
   neutrally with its sources, and runs a confirmation round on that exact form with all four readers. A 2-2
   after that round goes to the owner as a split, both forms with their tallies.
5. A clause that draws non-converging AMENDs in two successive rounds is deleted, not reworded, unless a reader
   names the normative content the deletion loses (rule 3).
6. A verified brief error that changes a question's premise voids **that question's** tally only; it is
   re-asked, corrected. Other brief errors are reported with the tally, naming any vote whose reason rests on one.
7. Counter-arguments "written on request" are not votes. Relay votes first, counter-arguments labelled.

Owner-label pre-registration: Q1's choice between F (a provider read per create) and S (a stored listing) is
partly cost and latency, which is the owner's. So even a 3/4 Q1 pick goes to the owner as the panel's
recommendation, never as settled. Q2 is mechanics (two texts disagree); a 3/4 pick with no blocking
CANNOT ACCEPT goes to the owner as "panel recommends", with the one question below.

## The one owner question (after the tally)

One question, two parts: (a) Q1's form (F or S, or the panel's third shape); (b) Q2's form, asked as "apply the
panel's pick?". Plain-terms story first (the re-listed auction offer for Q1; the standard-channel lost reply for
Q2), recommendation first, then the ids each lands on.

## Bead claims checked before launch (verified at c5f897c)

- pv-tcs: every quote verified (04:262-264, 02:1270-1271, 12:1864-1865, 13:1095-1097, 04:268). The bead's
  "no clause names the offer data it reads" is true, and understated: 05:444 already requires admission to read
  offer data ("resolved to a provider-local date at API acceptance, in the create's admitting transaction, taking
  the later of the descriptor's `cancellation_bound` and the offer-reported bound") and to record the accepted
  price. The read exists; its source is unnamed.
- pv-tcs: the brief adds the cost the bead omits: CNF-95 (10:544-545), CNF-307 (10:1228-1229), CNF-315
  (10:807-808) and CNF-283 (10:1887-1888) each assert no provider call on an admission refusal, and 04:305-307
  says "A refused tail still commits nothing, including no operation, machine, balance write, receipt or provider
  call." A provider read during admission flips them.
- pv-ytv: every quote verified (02:990-991, 02:968-969, 02:1053-1054, 05:441, 02:962-963, 02:895-897, 03:709-711).
  **Overstated:** "An engine that recorded the fingerprint has something to count" changes no traced outcome on
  its own. `OPS-27`'s Unresolved row is keyed on the channel ("no verified correlator exists for the operation's
  ordering channel (`PRV-33`)", 03:556) and `PRV-33` (02:1048-1049) forces an operator either way. The row
  precedence against "Exactly one resource across every channel" is unstated, which Form K closes.
- pv-ytv: the bead omits the consumer that does change a checked verdict: `PRV-9` (02:151-152) and `CNF-303`
  (10:2936-2938) read the guard through retained `machines.correlator_value`, "per-order correlator-key
  fingerprint for Robot". `machines` has no operation-id column (05:309-341). Form N therefore keeps the machine
  pair (05:326) as the fingerprint. The bead's target list (`PRV-26`, 05:441) misses 05:326 and `PRV-9`.
- pv-ytv: **unstated in master**: the bead's "A standard-channel order still carries a per-order key". `PRV-9`
  requires registering the order's keys (02:140-141); uniqueness is `PRV-32`'s (02:963-964); nothing requires a
  generated unique key on a `correlator: none` channel. The brief says so, and both Forms K and N now state the key.
- pv-ytv is not settled by master: `CNF-278` says "making no assertion about the correlator pair on the latter"
  (10:2824-2825) for a `correlator: none` descriptor.

## Settings

Readers: fable claude-fable-5-1 xhigh, opus claude-opus-5-5 xhigh, astra gpt-6-astra high, sol gpt-6.1-sol xhigh.
Units panel-r67-{fable,opus,astra,sol}. `timeout 3600`, draft answer by minute 25, answer cap 900 words excluding
replacement text. Launch recipe: /var/tmp/provisiond-manager/r67-handoff.md.

## Order

These rules were written before the brief. Nothing in them was tailored to the brief's wording.

## Quota (checked before launch)

2026-10-25T06:19Z, `claude -p "/usage"`: session 83% (resets Oct 25 08:50Z), week all models 91% (resets Oct 28
01:00Z), Fable week 54% (resets Oct 28 01:00Z). All under the 95% stop line; launched.
