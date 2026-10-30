# Panel F owner decisions, 2026-10-30

The following answers are quoted verbatim from the owner decision record. They supersede
the owner-pending status in the historical panel records.

5. **pv-y1zy (Panel F r85 Q1)** — Q: "pv-y1zy: when a request has a bad part, what should the error's field pointer
   name?" A: **"The exact bad part (Recommended)"**. Option text: "Form A: name the specific member or list element
   (e.g. /keys/2), with the new admission test cases. First pick of fable, astra, sol; opus rejects the test-case
   scope. Settles 3–1." Rejected: "The whole group" (B), "Only the shown cases" (D), "Leave it to each server" (C).
   Meaning: adopt exactly Q1-A as printed in /var/tmp/provisiond-panel-r85/brief.md (its CNF paragraph, fixture
   file q1-fixtures.json and owner pointers on WIR-9a, CNF-342, WIR-20, WIR-35, API-13, RSC-4), as tallied in
   /var/tmp/provisiond-panel-r85/tally.md. pv-y1zy → ready-for-agent with that package as its brief.

6. **pv-xzre (Panel F r85 Q2)** — Q: "pv-xzre: caller input and a service-generated value are both invalid. Which
   error comes back?" A: **"Caller's mistake first (Recommended)"**. Option text: "Form B: return the caller's
   validation error so they can fix their input, with paired test fixtures. Picked and accepted by all four readers
   (fable, opus, astra, sol). Counterargument: the service bug stays hidden until the next attempt." Rejected:
   "Service bug first" (A), "Check generated values first" (C). Meaning: adopt exactly Q2-B as printed in
   /var/tmp/provisiond-panel-r85/brief.md (PRV-47, CNF-342, its controls and paired fixture). pv-xzre →
   ready-for-agent with that package as its brief.

7. **pv-hups (Panel F r85 Q3)** — Q: "pv-hups: must every install re-check finish before the worker writes its
   'rescue may have started' marker?" A: **"Say so for all checks + test (Recommended)"**. Option text: "Form A: the
   timing rule explicitly covers every repeated check, before both markers, plus a test that fails a marker-first
   worker. Picked and accepted by all four readers. Counterargument: the current rules arguably imply it already."
   Rejected: "Say so for one check + test" (C), "Test only, no wording change" (B). Meaning: adopt exactly Q3-A and
   its common fixture as printed in /var/tmp/provisiond-panel-r85/brief.md (OPS-23, CNF-34). pv-hups →
   ready-for-agent with that package as its brief.
