**Final: Q2d=Q-POINTER; Q2e=Q-POINTER; Q4=L-BRIEF.**

I reviewed the exact r97b alternatives against M=`2e2cd94637112f20538eb26b141672fedf0ba455`. **PASS for these selections as my independent reader recommendation.** This answer does not itself establish the panel tally or authorize the Run.

**apply notes.md rule 6 exactly as written; this prompt adds no void rule.**

| Question | Q-KEEP | Q-POINTER | Q-QUOTE | Final preference |
|---|---|---|---|---|
| Q2d | **ACCEPT** | **ACCEPT** | **ACCEPT** | **Q-POINTER** |
| Q2e | **ACCEPT** | **ACCEPT** | **ACCEPT** | **Q-POINTER** |

| Q4 exact form | Verdict |
|---|---|
| L-BRIEF.txt | **ACCEPT**, preferred |
| L-NOTE.txt with exactly L-NOTE-append.md | **ACCEPT** |
| L-NOTE-append.md | **ACCEPT** as the supplied appendix, with the limitations below |
| authority-replacement.txt | **ACCEPT** |

My L-NOTE acceptance includes **no additional note in the duplicate r89/r89b form**. I propose no synthesis or repaired bytes.

For Q2d and Q2e, KEEP’s conditional argument holds. AGENTS:29–32 requires quotation for **“A claim about what another requirement says”**; AGENTS:45–46 applies to **“every sentence asserting what another requirement says”**. These sentences give their own prospective obligations—**“create MUST reject”** and **“A paid create request … MUST carry”**—and identify the acknowledged field through its owner. That identification fits AGENTS:34: **“One rule, one home; everywhere else points at it.”** This conclusion rests on the sentences’ function, not their inheritance or lexical-gate success.

POINTER makes that function clearer through the explicit **“wire owner: `WIR-17`”** label. I therefore change my r97 preferences to the already reviewed POINTER forms. The supplied prior answers establish that the other substantive readers accept them.

My exact selected Q2d text is:

```text
**PRV-10** For a paid create (`DOM-16`), create MUST reject the request unless the
request carries an explicit purchase acknowledgement (top-level
`acknowledge_purchase`; wire owner: `WIR-17`), *and* the account is configured to allow ordering.
```

My exact selected Q2e text is:

```text
**API-15** A paid create request (`DOM-16`) MUST carry an explicit purchase
acknowledgement — top-level `acknowledge_purchase`; wire owner: `WIR-17` — in addition to the account being configured to allow ordering (`PRV-10`).
```

Both preserve paid-create scope, explicit acknowledgement, top-level location, wire ownership and account opt-in. PRV-10’s following **“Both, not either.”** remains untouched; API-15 retains **“in addition to”**. Neither replacement changes the PRV-10 phrases quoted inside the fixed OPS-43 excerpt.

I also accept both QUOTE alternatives. Their WIR-17 quotation is an exact 67-byte substring at M, `13-wire-contract.md:683`. Opus’s objection identifies real editorial costs: the quotation follows the account-configuration clause, and literal true alone does not establish nesting. Nevertheless, the sentence separately identifies the wire field, and its own MUST supplies the dual authorization. I find no changed obligation or checked verdict. Current WIR-17’s JSON body independently establishes top-level placement: `acknowledge_purchase` and `provider_options` are sibling members.

For Q4, I change my preference from L-NOTE to **the exact supplied L-BRIEF.txt**.

The strongest NOTE argument remains valid: an adjacent dated qualification helps readers distinguish the historical approval from later execution, while preserving every original byte as a prefix. I verified that the prospective file is exactly original form plus supplied appendix.

The strongest BRIEF argument is stronger after tracing the archival consequences:

- Both archived forms currently have SHA-256 `be350270318a2752992a9cb199a2a56879249be99f36e7af430bcfe8a1d47a32`.
- `r89/check/tally/verification.json` records that hash.
- `r89/r89b/check/validate.py` contains `assert actual==original.read_bytes()`.
- Appending only to the specified original changes its whole-file hash to `ebf5de10cdebba5297239ac528d6c81c61f86e5e15e7baff97f9cb5c4ae0928d`; the duplicate remains unchanged. That equality assertion would fail if replayed.
- The appendix’s `../../../r97/notes.md` resolves to the outcome-rules document, rather than explicit selected replacement text.

These are disclosed archival costs, not a demonstrated loss of a conformance assertion, normative obligation or Lean property under rule 3. They do not make L-NOTE unacceptable to me. They do make L-BRIEF preferable: the corrected authority statement, historical/current labels and archived r97 selections already distinguish approval from execution while preserving both archival hashes. The supplied prior substantive answers also accept L-BRIEF.

The separate classifications for my picks are:

| Pick | Behavior | Requirements / items 4+24 / C′ meaning | Check strength |
|---|---|---|---|
| Q2d Q-POINTER | **WORDING-ONLY** | **WORDING-ONLY** | **WORDING-ONLY** |
| Q2e Q-POINTER | **WORDING-ONLY** | **WORDING-ONLY** | **WORDING-ONLY** |
| Q4 L-BRIEF | **WORDING-ONLY** | **WORDING-ONLY** | **WORDING-ONLY** |

Owner item 4’s **“Every paid create (Recommended)”** policy remains intact. Item 24’s approval includes the printed **“Hourly cloud cases”** block; I verified that complete payload remains unchanged in the POINTER assemblies. The r97 inventory’s other protected assertions remain intact: unconditional wire acknowledgement; CNF-34’s **“On separate creates”** coverage and complete current PR60 fixture; CNF-342’s **“complete, valid resource-offer”** coverage; CNF-55’s existing exclusion, low-balance, replay and worker cases; and CNF-364’s authorizations, gate demonstration and outcomes.

I independently verified the inventory’s source spans and quotation payloads without whitespace normalization, including the historical API/WIR quotations at `7116e90…`, confirmed as `b278433`’s parent. Replacing only d/e in the supplied fixed-context examples produced:

| Assembly | SHA-256 |
|---|---|
| Executable form | `c782dbfa7ec9db145f34705c699bf63d4cf544dac38f8bec1ca65243dc795a55` |
| Comment 861 | `0aa180115ac0f706860c216f60160f1068a1fcdcc7e64b5207c33daf02e54bbc` |

No additional repair is included.

I found **no verified brief error changing an open question’s premise**. The Q4 hash, equality and link limitations are expressly disclosed in this packet. The preserved preparation-only status is superseded by the actual launch instruction. Neither supplies a rule-6 void.

Immediately before returning, protected main refs `origin/master` and `pv-9ecf` both remained M. The clone’s tracked diff is empty. I wrote scratch only under the assigned `tmp/sol`; I ran no gates, lake, br, provider requests, external messages, Git mutations or subagents.