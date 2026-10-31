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
