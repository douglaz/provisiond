# Requirement-reference and attribution inventory — manager preflight, not a panel ruling

C′ line numbers refer to evidence/form-Cprime.md (identical to both archived copies); comment line numbers refer to decoded comment861 at M. Current behavior fences in comment861 are explicitly historical quotations from 3109b5b and remain unchanged. Exact whole comment is evidence/comment-861.md. All source words for candidates are in check/quote-bytes.json with raw LF, source ref and SHA-256; byte comparison uses no whitespace normalization.

## Source-content summaries requiring a decision

- Q2a: PRV-10 configuration-half sentence; C′:26; comment861:80. Unquoted summary attribution in executable replacement.

`````text
The configuration half is `DOM-10`'s gate on the create's ordering capability (`DOM-16`):
`API-7`'s step 5d at admission and `OPS-43`'s step 3 at claim.
`````
- Q2b: API-15 historical italic sentence; C′:35; comment861:41, 89. Unquoted summary attribution in executable replacement.

`````text
"In its provider
options" until 2026-09-05, while `WIR-17` placed it at the top level; the wire contract wins, and a
spending authorization nested inside a driver-private object is one a strict server could not tell
from any other option.
`````
- Q2c: CNF-364 comparison sentence; C′:212; comment861:266. Unquoted summary attribution in executable replacement.

`````text
While it is still queued and unclaimed, restart with a descriptor for that account that
      removes only `list_offers`, keeping the ordering capability declared and the driver's
      List offers code path answering, so the test proves the gate exists, as `CNF-19` does.
`````
- Q2d: PRV-10 first sentence (ownership-pointer boundary); C′:23; comment861:77. Potential ownership-pointer boundary; included for explicit reader classification, not presumed a violation.

`````text
**PRV-10** For a paid create (`DOM-16`), create MUST reject the request unless the
request carries an explicit purchase acknowledgement (`WIR-17`'s top-level
`acknowledge_purchase`), *and* the account is configured to allow ordering.
`````
- Q2e: API-15 first sentence (ownership-pointer boundary); C′:33; comment861:87. Potential ownership-pointer boundary; included for explicit reader classification, not presumed a violation.

`````text
**API-15** A paid create request (`DOM-16`) MUST carry an explicit purchase
acknowledgement — `WIR-17`'s top-level `acknowledge_purchase`, which the wire contract
owns — in addition to the account being configured to allow ordering (`PRV-10`).
`````
For Q2b, comment861:41 is inside the unchanged Current behavior quotation; comment861:89 is the executable occurrence. Change only the latter. The Q2b full-sentence candidate includes the historical quote, placement contrast, wire precedence, and driver-private spending-authorization rationale. Historical evidence comes from 7116e90 (the parent of b278433, the 2026-09-05 correction); its WIR-17 literal-true wording also remains byte-identical at M. The historical JSON quotation demonstrates top-level placement; a current literal-true quote alone would not establish historical placement. The supplied Q-QUOTE fixes the historical API-15 phrase’s capitalization/reflow by quoting that revision’s actual words.

Q2a names DOM-10, API-7 and OPS-43 as content owners. DOM-16 is the package’s own paid-create definition pointer. Q2c attributes the permissive-driver outer-gate comparison to CNF-19. Q2d/e name WIR-17’s top-level field: decide whether those are already bare owner/location pointers under AGENTS or also assertions requiring exact source words. The source JSON and literal-true rule are supplied either way. Q2e’s PRV-10 citation is attached to its own new dual-authorization requirement; decide explicitly whether it asserts separate source content.

## Other references in every replacement block

| Site | Reference and classification to recheck | Location source |
|---|---|---|
| DOM-16 | PRV-44 descriptor owner; API-15 acknowledgement owner; the capability condition and addition of acknowledgement are this package’s normative rule, not a report of prior words | Heading and full payload in independent-blocks.json |
| PRV-10 | DOM-16 definition pointer; WIR-17 field/location pointer Q2d; source-content gate summary Q2a; “Both, not either” is its own norm | Q2a/d above |
| API-15 | DOM-16 definition pointer; WIR-17 wire owner/location Q2e; PRV-10 dual-authorization owner; historical WIR-17 placement summary Q2b | Q2b/e above |
| Overview configuration row | DOM-16 points to the new paid-create definition; table label is own schema catalogue text | Full replacement below |
| Provider-notes Create matrix row | Bare “see DOM-16” ownership pointers, no source-content assertion | Full replacement below |
| DEF-17 scope paragraph | DOM-16 definition pointer in the package’s own historical defect description; no statement that DOM-16 says a second purchase occurs | Full replacement below |
| CNF-55 base case | DOM-16 definition; API-7/OPS-43 step references and PRV-42/STO-58 exclusion references locate the package’s explicit fixture assertions, not a report that those requirements say them; error/verdict assertions remain mandatory | Full CNF-55 payload below |
| CNF-55 Hourly cloud cases | PRV-13b/PRV-31 live-sale owner pointers constrain this fixture’s authority; API-7 step5d/OPS-43 step3 locate its own new assertions; WIR-17/OPS-23/OPS-11 trail are owner pointers | Entire Hourly block below, unchanged in every supplied example |
| CNF-364 | PRV-42/STO-58 exclusion and OPS-43 step4 references locate explicit fixture assertions; Q2c alone says another CNF “does” the comparison; tail owner list and dated amendment describe local check history | Full payload below |

These are provisional classifications, not exemptions. Every reader must identify any further summary, give exact C′ and comment locations, and supply full Q-QUOTE/Q-POINTER/conditional Q-KEEP candidates. In particular a fixture’s own prospective assertion is distinct from saying an existing requirement already asserts it. A reference to a list is not an uncited count; do not invent prose counts from grep.

## Retained and historical text

CNF-18 is unchanged at M and C′ retains it: its DOM-10 table/PRV-44 descriptor references, CNF-20 method attribution and CNF-19/CNF-55 coverage attribution are inherited. The two reported sentences are Q3 below. CNF-182’s API-15/PRV-10 description and CNF-344’s PRV-5 alarm description are likewise inherited retained text, not changed replacement text. CNF-34/CNF-342 carry existing source quotations; record any source-LF/display reflow without treating it as authority to edit inherited blocks. The source-word rule is not waived merely because the citation gate passes.

In comment861’s Retained/rejected/out-of-scope section (after the complete form), quoted r89b owner-questions/tally paragraphs explicitly discuss what C′ changes and retains, quote WIR-17’s literal-true words, CNF-34 “On separate creates”, CNF-342 “complete, valid resource-offer”, and API-15 “MUST carry”. These are provenance quotes, not extra source changes. The CNF-34 full-byte-identity claim is retained inside its explicitly labeled historical quotation in Q1; the exact corrected current execution sentence is added outside that quotation, with the complete placement printed in R-MASTER-comment-placement.txt. Historical Drift facts describe 832a219; do not relabel that table as a comparison to current M. The new execution authority and current retention table distinguish that old comparison.
