# Owner decisions — Panel J, 2026-10-30

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

24. **pv-9ecf paid-create wording (owner item 4; Panel J r89, consensus round r89b)** — asked short: "Approve C′
    wording plus its added hourly cloud test cases?" A: **"Approve C′ (Recommended)"**. Option text: "4–0: Fable,
    Opus, Astra, Sol. Grok missing (402)." Rejected: "Defer C′" ("No reader recommends it; pv-9ecf stays
    pending."). Adopted: exactly /var/tmp/provisiond-panel-r89/r89b/form-Cprime.md (SHA-256
    be350270318a2752992a9cb199a2a56879249be99f36e7af430bcfe8a1d47a32, pin 3109b5b), including its printed "Hourly
    cloud cases" CNF-55 block; owner relay /var/tmp/provisiond-panel-r89/r89b/owner-questions.md; tally
    /var/tmp/provisiond-panel-r89/r89b/tally.md. Item 4's policy stays as decided. Meaning: pv-9ecf goes to
    ready-for-agent with C′ and both precedents (item 4 and the 2026-10-28 wording rule) as its brief.

Owner wording precedent (2026-10-28): "For such wording questions, try to solve by getting a consensus of the panel".
