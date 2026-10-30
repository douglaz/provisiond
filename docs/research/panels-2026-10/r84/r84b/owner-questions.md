# Owner queue — ask one at a time

## 1. Q1: immediate path-prefix refusal or identity resolution

Ask the complete question in `owner-question.md` first. It includes the plain example, all unchanged reviewed alternatives, every reader's r84b pick/argument, deliberate compatibility loss and decision homes. A/C remain tied 2–2 after the ONE consensus round; there is no unique panel recommendation. Do not launch another round.

## 2. Q3: exact trimming policy, technically unanimous

**TL;DR:** All four readers recommend trimming the six specified edge characters, including vertical tab, and testing the fingerprint over the complete device list. This chooses an identity rule and needs your policy approval.

A disk reports serial `ABC123` followed by an invisible vertical tab. Today two engines can disagree about whether that last character belongs to the serial, producing different displayed serials and fingerprints. E removes it at the edges. If two serials differ only by that padding, they become indistinguishable and selection may fail safely; an identifier consisting only of that padding becomes absent. Interior characters stay.

**Approve this exact policy and test package?**

1. **Trim the six characters + list-hash test (Recommended).** Exact E; fable, opus, astra and sol all prefer and accept it (4–0). Trim U+0009 through U+000D and U+0020 at the edges only; preserve the printed neighbors and interior characters. Include the complete independent serial/WWN list-hash test exactly as reviewed.
2. **Hold this bead.** Leave the present ambiguity open; no alternate policy or unreviewed repair is adopted.

**Each reader's r84b pick and strongest argument:** fable E — keep the preferred trimming set and correct the missed hash defect; opus E — retain the same policy with only the oracle sentence fixed; astra E — hashing an element contradicts the required list fingerprint; sol E — explicit trimming and a correct independent list oracle, without a hidden fixture-value requirement. All reject unchanged A/B or accept only distinct corrections. B′ is accepted by its two authors as a separate repair, not reviewed by astra/sol, not preferred by anyone and not the recommendation.

**Scope of approval:** exact `check/tally/q3-E.md`, without adding a required identity value to the separate one-disk hash fixtures or mandating their cross-product with every boundary value. The printed explicit boundary assertions all remain. No claim of compatibility with every provider identity or outside library convention is made.

**Decision homes and precedent:** pv-tbrs; amend RSC-46 and CNF-363's whitespace-boundary paragraph. RSC-46 keeps "trim ASCII whitespace, ASCII-lowercase, then strip exactly one leading `0x`" and "SHA-256 over the RFC 8785 canonical JSON of the device list". The owner precedent "For such wording questions, try to solve by getting a consensus of the panel" covers no behavior/requirement/check-strength change; this package selects behavior and adds checks. Q2 pv-2j3's size policy is separately approved in owner-decisions-1030.md item 8. No second consensus round or unit is launched by this tally.
