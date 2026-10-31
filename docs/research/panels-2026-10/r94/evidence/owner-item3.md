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

