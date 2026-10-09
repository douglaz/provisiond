# Panel r31 synthesis — pv-ucs.9: auction identity resolution (Q16a) and temporary-key lifetime (Q16b), 2026-10-09

Readers: sol, astra (codex xhigh), fable, opus (claude xhigh); clones at 843a2f2. All exit 0.

## Q16a — 4–0: a "not found" identity read must not resolve an auction order absent; the shortcut goes.

- Stronger counterexample than mine, needing no unobserved provider behaviour (fable, opus): a Robot order
  sits `in process` "with no documented bound" (03:1451); `PRV-42`'s absent row depends only on
  `PRV-36`'s window; `OPS-33`'s ADR-0035 guard covers only "a matched order that is still in progress",
  and the identity read never matches an order. So a slow order reads 404 past the window, resolves
  absent, releases the commitment, and the server arrives later as an operator deficiency.
- Even a positive identity read does not prove the server came from THIS order (sol, astra); V8's
  "check on the transaction" needs the transaction, which after a lost reply only `PRV-32`'s fingerprint
  search can reach (opus). So V8's guard collapses into the existing search.
- Shape (all four, wording varies): resolve auction creates by `OPS-27`'s existing fingerprint search,
  reading the delivered `server_number` from the matched transaction. Strike `PRV-42`'s "the correlator
  is unnecessary" and its absent row. Opus: withdraw `PRV-42`'s identity-resolution clause, table and "MUST
  prefer" (they conflict with its own `[verify]`); fable: the identity read may be taken first as
  `OPS-27`'s confirming direct read, `not_found` proving nothing. Keep ADR-0036's one-create-in-flight
  claim (`offer_is_resource` = "the offer names one machine"). Cost: only the 30-day listing horizon,
  which sends a still-unmatched order to `OPS-31` after `OPS-33` released the commitment.
- "Offer id = server number" stops being load-bearing; it stays an observation (opus) / `[verify]`.

## Q16b — 4–0 the conflict is real and lives in the sweep's test; split on the exact rule.

Conflict: `PRV-9` "MUST NOT remove them until the provider has actually consumed the key material" vs
`OPS-32` deleting a tagged key "whose operation is not `running`". Startup moves every `running` operation
to `needs_reconciliation`, and ADR-0035 sends every post-acceptance failure there — so after a crash the
sweep deletes keys a provider may still be reading: `DEF-6` through the sweep. `CNF-303` requires it today.

- Fable: one word — "not `running`" → "settled"; `needs_reconciliation` is "Resolution-pending, not
  terminal". A `failed` create is pre-acceptance under ADR-0035, so no consumer.
- Opus: "settled or vanished" (RSC-42's wording) AND no machine it produced still reads `provisioning`
  (OPS-27 can attach a machine that is still deploying); a missing operation record → delete; `PRV-9`
  owns the rule, `OPS-32` cites it; the Robot exception can go (search applies only to open operations).
- Sol, astra: provider evidence of consumption or of no remaining consumer, shared by cleanup and sweep;
  `failed` "establishes nothing about its side effects" (OPS-3), so settlement alone is unsafe; unknown/
  missing → retain and surface. (Fable/opus answer: since ADR-0035 a post-acceptance failure is never
  `failed`.)
- Framing defects: "Robot: rescue booted" covers rescue, not create (opus); "Its private half died with
  the process" is false for create keys, which are the caller's `ssh_public_keys` (fable, opus).
- Real limit (opus): providers reject a duplicate fingerprint, so a caller's key held by an unresolved
  operation blocks that caller's next create on the same account — retaining longer stretches this.

## Edits

Q16a: `PRV-42` (strike "correlator is unnecessary", the absent row / resolution clause; keep the claim),
`OPS-27` (auction creates resolve by search; `not_found` is not evidence), `CNF-285`, research V8 and
written inquiry 3, an ADR or dated note recording V8's guard as rejected. Formal: none required.
Q16b: `PRV-9` owns the rule; `OPS-32` cites it (drop "not running", the "private half" sentence);
`CNF-303` (a crashed create's key survives); `DEF-6`; provider notes per V2/V18/V19 (`[verify]`). Formal:
`Rescue.sweepRemovesCredential` gains the guard (opus prototyped: gate passes, +1 theorem).
