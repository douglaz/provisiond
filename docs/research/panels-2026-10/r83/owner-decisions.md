# Owner decisions — Panel D

Verbatim items from the owner decision log for 2026-10-30 follow. They supersede the historical pending-approval status in the panel records. The requirement owners hold the rules; the Agent Briefs carry the adopted exact forms.

2. **Work order** — Q: "What should the managers start on so beads become ready to merge? …" A: **"Do all in
   parallel"** (panels D–G, triage of the five new beads, and the owner questions). Then, mid-turn: "For any beads
   that require my input, you can start asking now".
3. **pv-kv2** — Q: "When a suspended customer's queued order is first picked up after the suspension, what should
   happen?" A: **"Stop before buying (Recommended)"**. Option text shown: "At pickup the worker sees the customer
   is suspended and fails the order before spending anything. Nothing is bought or charged. Panel D then settles
   the exact error and race guard. This is the 10-27 triage's pick; it wasn't put to a panel because it's a
   policy choice."
   - Story shown first: a customer queues a server order at 10:00, you suspend them at 10:01, a worker first
     picks the order up at 10:02; today's text lets it buy, charge the setup fee and first billing unit, then
     enqueue a cancellation that can itself fail.
   - Rejected: "Buy, charge, then cancel".
   - Decision homes (triage-1027 row): `API-58`, `OPS-43`; keep `OPS-27` for orders already dispatched. The
     refusal kind and race guard go to Panel D (r83).
13. **pv-gvc (Panel D r83 Q1, preference B 3–1 (fable, opus, astra; sol A), acceptance 4–0, owner approval of the
    behaviour)** — Q: "pv-gvc: should failing an unbought order and returning its reserved money be written as one
    step, with a race-losing cleanup releasing nothing?" A: **"B: say it explicitly (Recommended)"**. Option text:
    "One-step release rule plus full race tests. Preferred 3–1 (fable, opus, astra), accepted 4–0." Rejected: "A:
    tests only", "C: fewer tests". Meaning: adopt exactly r83 brief Q1-B as frozen in
    /var/tmp/provisiond-panel-r83/check/settled-Q1-B.txt (per /var/tmp/provisiond-panel-r83/owner-questions.md §1),
    without the newly discovered deferred-operation guard fix. pv-gvc → ready-for-agent with that package as its
    brief, landing with or after pv-kv2's exact mechanics (Panel D Q4, consensus round r83b running) under item 3.
14. **pv-bxh (Panel D r83 Q2, 4–0, owner approval of the behaviour)** — Q: "pv-bxh: when an order is refused because
    the account changed mid-admission, should the retry advice depend on whether the account can recover?" A: **"A:
    tell them apart (Recommended)"**. Option text: "Keep the refusing status under the account lock: retry for
    unreachable/rejected credentials, stop for terminated. 4–0." Rejected: "B: always say stop", "N: leave the gap".
    Meaning: adopt exactly r83 brief Q2-A as frozen in /var/tmp/provisiond-panel-r83/check/settled-Q2-A.txt (per
    /var/tmp/provisiond-panel-r83/owner-questions.md §2). pv-bxh → ready-for-agent with that package as its brief.
    (Panel D Q3 pv-y0to settled 4–0 on exact A, check/settled-Q3-A.txt, as a cross-reference clarification: ready-for-agent
    under item 2 without an owner question.)
19. **pv-kv2 (Panel D r83b Q4, unsettled after its one consensus round: D preferred and accepted 3–1 by fable +
    astra + sol, opus rejects; A preferred by opus, acceptance 2–2; D's 3–1 blocked by a verified rule-3 loss (the
    positive duty to publish the existing-fleet warning); no panel recommendation; grok missing, 402)** — Q: "pv-kv2
    public terms (panel unsettled): explain the 'approved before suspension' exception, or keep today's exact words and
    warning?" A: **"D: explain exception"**. Option text: "3–1 pick (fable, astra, sol). Terms say an order approved
    before suspension may still complete. Drops the required public warning that existing servers may keep running if
    cancellation fails (opus's objection)." Rejected: "A: keep current words". Meaning: adopt exactly
    /var/tmp/provisiond-panel-r83/r83b/Q4-D.md, unchanged, under item 3 "Stop before buying (Recommended)"; the owner
    knowingly accepts the loss of API-58's positive publication duty for the existing-fleet warning (opus's dissent on
    record). No A/D combination, repaired D or partial D. pv-kv2 → ready-for-agent with item 3's Q1 package plus
    Q4-D.md; items 13 (pv-gvc) and 14 (pv-bxh) stand and land with or after it.
