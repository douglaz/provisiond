One internal inconsistency: **Q2-A’s exact `CNF-19` amendment requires a stale-listing refusal without restricting that assertion to an old listing.**

The proposed sentence is:

> “For a present named offer, assert a capability refusal before tail collection whatever listing age; with its capability declared and no collected refusal, assert the existing stale-listing refusal.” ([brief.md:706](/var/tmp/provisiond-panel-r86/brief.md:706))

But the retained checklist rule explicitly says:

> “This default qualifies only the admission or success assertion and any create used to reach it; an item asserting a refusal without specifying the stored listing's age asserts it whatever that age.” ([brief.md:611](/var/tmp/provisiond-panel-r86/brief.md:611))

Consequently, the added stale-listing assertion also covers a fresh listing. That conflicts with the age condition in the rule Q2-A expressly preserves:

> “If the tail has collected no refusal and the stored listing has a `read_at` older than the stated offer-listing age (`OVR-19`) at the admitting transaction, the create MUST be refused `provider` (`01-domain-model.md`'s error taxonomy) with `retryable: true` before any admission write, committing nothing.”

Q2-A instructs:

> “Keep the immediately following age-refusal sentence and remaining tail verbatim.”

It also states:

> “It does not change the stored-listing header default.”

Thus the exact test amendment broadens the age refusal while claiming to preserve its governing rule and interpretation.

**Smallest correction:** replace:

> “with its capability declared and no collected refusal”

with:

> “with its capability declared, the stored listing older than the stated offer-listing age, and no collected refusal”

I found no other internal contradiction in the fixed scope, substitutions, questions, return shape or counting rules.