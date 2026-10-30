# Panel E owner decisions, 2026-10-30

The following answers are quoted verbatim from the owner decision record. They supersede
the owner-pending status in the historical panel records.

8. **pv-2j3 (Panel E r84 Q2)** — Q: "pv-2j3: what size limit should a submitted disk identifier have?" A: **"1024
   bytes, before trimming (Recommended)"**. Option text: "Form A: one cap on the raw value bounds both padding and
   the identity. First pick of all four readers; all four accept." Rejected: "256 bytes, after trimming" (B), "Both
   limits" (C), "Request-body limit only" (D). Meaning: adopt exactly Q2-A (API-13 disk-identifier row and CNF-363
   size-boundary paragraph) as printed in /var/tmp/provisiond-panel-r84/brief.md; SEC-29 and OPS-23 retained.
   pv-2j3 → ready-for-agent with that package as its brief. (r84 Q1 pv-ez8 and Q3 pv-tbrs are in r84b.)

11. **pv-ez8 (Panel E r84b Q1, tie after the one consensus round)** — Q: "pv-ez8: a pasted disk path such as
    /dev/sda goes in the serial field. Refuse it straight away, or keep treating it as a possible serial? (The panel
    split 2–2, and all four readers accept both A and C.)" A: **"A: keep as possible serial"**. Option text: "Today's
    adopted behaviour. A path is checked like any other serial; if nothing matches, the server reboots into rescue and
    fails without writing. A real serial starting /dev/ still works. Picked by fable and sol; all four accept."
    Rejected: "C: refuse /dev/ at once", "B: refuse any slash". Meaning: adopt exactly
    /var/tmp/provisiond-panel-r84/r84b/check/tally/q1-A.md (CNF-200 and CNF-363 case (14); API-13 unchanged; RSC-26
    retained). pv-ez8 → ready-for-agent with that package as its brief.

12. **pv-tbrs (Panel E r84b Q3, 4–0 technically, owner approval of the behaviour)** — Q: "pv-tbrs: approve form E,
    which strips the six whitespace characters (tab, LF, VT, FF, CR, space) from the ends of disk identifiers and fixes
    the test so it hashes the whole disk list?" A: **"Approve E (Recommended)"**. Option text: "Amend RSC-46 and
    CNF-363's whitespace paragraph exactly as reviewed. Edge padding is stripped and characters in the middle stay.
    The test hashes the complete serial/WWN list. All four readers picked it (4–0). Serials that differ only by edge
    padding become the same, and choosing between them fails safely." Rejected: "Hold this bead". Meaning: adopt
    exactly /var/tmp/provisiond-panel-r84/r84b/check/tally/q3-E.md, within the scope stated in
    r84/r84b/owner-questions.md §2 (no required identity value added to the one-disk hash fixtures, no mandated
    cross-product with every boundary value; printed boundary assertions remain). pv-tbrs → ready-for-agent with that
    package as its brief. With items 8, 11 and 12, Panel E r84 is fully decided; its records can now be archived.
