# Panel r39 synthesis — pv-ucs.4 after the live Robot test (Q21), 2026-10-11

Readers: fable, opus (claude xhigh), astra, sol (codex xhigh); clones at dec039f. All exit 0.

## Agreed (4–0)

- **The test settles less than "no v1 instance".** It shows the `primary_ipv4` add-on (which is the
  server's main IPv4: `server_ip` = `ip[0]`) gone at +1 s and the included /64 gone at +20 s (read once)
  after an auction `now` cancellation. Untested: separately ordered IPs and subnets (the descriptor's
  declared kinds), the standard catalogue channel (`08:163`, `08:353`), other datacenters,
  provider-initiated termination, hand-added IPs, and billing after the `404` (step 10, the invoice).
  V9 is settled (the transaction keeps the deleted key); V8 gains a sample.
- **Keep Robot's declared survivor kinds** (`02:192-198`: "The declaration names kinds, not an assertion
  that every instance survives"); replace "pending research batch B, step 9" with the observation.
- **Build no survivor machinery for the sold path now**; record what was observed. The precondition shape
  is right (fable, opus) or must be stronger (astra, sol): complete automatic discovery and cleanup —
  identities captured while the machine is present (r38 option A as the candidate), a release enqueued at
  every gone-write, "never listed" distinguishable from "listed, none", disappearance before capture
  covered — before any sold create path can leave a billable attachment that outlives its server
  (separately ordered Robot IPs/subnets; Cloud and DigitalOcean on re-admission). No manual step.
- **Fable's tombstone defect is real:** `03:1072` makes a scheduled machine's tombstone its gone-write
  ("Cleared by the tombstone"), against `LDG-74` (12:564, "MUST NOT be collapsed") and `STO-18`; the
  last row already closes `scheduled` at the gone-write. Fix by deletion: the scheduled row closes at the
  gone-write, the tombstone follows when `STO-18` allows; delete `Event.tombstone` in `Tables.lean` and
  the `(.scheduled, .tombstone)` edge in `Render.lean`, `01:231/242`, `13:894`; `CNF-271`.

## Split: what a Robot `now` delete settles as (next owner question)

- **Scheduled (fable, opus):** the driver surfaces the day (`PRV-13` 02:180); end of that day; the machine
  is `cancellation_scheduled`; the sweep's gone-write closes it; `LDG-38`'s earlier-of stops the meter at
  the sweep's observation. "Robot `now` is immediate" as a rule breaks `PRV-13c`'s per-contract facts.
- **Gone (astra, sol):** a day-only date is no proof of a live scheduled machine; once the direct read
  answers `404`, take `OPS-48`'s gone row and stop at that observation; a failed read stays uncertain.
- **New fact (fable):** Robot stamps local time — the key uploaded at 03:47:37Z reads `created_at
  05:47:37` (CEST) — so a `now` near UTC midnight answers the next day, and Q18a's "end of that day, UTC"
  reads Robot's day in the wrong zone. The day-only rule also has no machine owner (`PRV-13` vs `PRV-45`,
  `WIR-35`) (opus).
