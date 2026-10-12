# Panel r38 synthesis — pv-ucs.4: attachments left unrecorded when the listing never runs (Q21), 2026-10-11

Readers: fable, opus (claude xhigh), astra, sol (codex xhigh); clones at dec039f. All exit 0.

## Agreed (4–0)

- **The gap is real and wider than filed.** `PRV-45` lists attachments only "on every delete that succeeds
  with the resource gone" (02:528); nothing covers a failed listing (`ADR-0035:79` excludes it), a
  provider-terminated machine, or a scheduled delete. With zero rows, `STO-18` (05:357) and `LDG-32`
  (12:308-310) are satisfied vacuously, the machine is tombstoned and its commitment closes; `OPS-32`
  visits only retained machines and `API-65` acts only on existing rows. A survivor is never cancelled.
- **"Settles `failed`" is out of date:** an accepted delete followed by a failed read is
  `needs_reconciliation` (`OPS-11`, 03:270-275).
- **Cost:** no customer charge (no attachment customer rate, Q18); the operator pays Hetzner's rent for
  a surviving IP with no end date. Conditional on batch B step 9 (does the `primary_ipv4` add-on outlive
  its server). No adversary is needed; accidents suffice. Q18 sold the add-on on "operator rent until its
  `cleanup: api` cancellation", a cancellation this gap never issues.
- **(c) "list on every gone path" fails:** a listing after the server is gone can fail too, and may be
  unable to find the IP at all (a cancelled Robot server answers `404`; whether its IPs keep the
  `server_number` link is step 9's unknown).

## Split on the fix

- **Fable — record while present, release at the gone-write.** Robot's `GET /server/{n}` already returns
  the server's `ip` and `subnet` arrays on the reads `STO-41` names (create, resolution, post-action,
  refresh, and the sweep). Upsert attachment rows from those reads; the gone-write, where all three paths
  converge, enqueues `release_attachment` for each billable `api` row with a null `released_at`. Nothing
  is read after the machine is gone. An IP that went with the server answers "already cancelled", which
  `OPS-11` makes success. Fable also finds `03:1072` and `Tables.lean` collapse a scheduled machine's
  tombstone into its gone-write, which `LDG-74` forbids.
- **Opus — an account-level pass.** Every `OPS-32` pass lists the account's IPs and subnets (two reads);
  an unrecorded entry whose provider-side assignee is null or a machine recorded gone here, and tied to
  it by assignee or `machine_addresses`, gets a row and a release; one assigned to a live server is
  reported, never released. Also catches hand-added IPs and machines tombstoned before the fix.
- **Astra — retain until discovery completes** (the triage's (a)), with a durable completion fact and
  the sweep revisiting gone machines; "persist identities while attached" if Robot loses the link.
- **Sol — step 9 first**; if the add-on survives, capture identity and ownership while observable, then an
  account-level comparison; if the association is lost and nothing was captured, refuse the offer.
- Against (a): a post-gone listing may `404` forever and strand the commitment (opus, sol); fable: an empty
  complete listing would release the gate over a live orphan.

## Also found

- Whether Robot's `now` delete is immediate or scheduled is unstated: `08:407` observed "Immediate
  destroy, no scheduled tail", while Q18a reads Robot's returned date as the end of that day (fable, opus).
- `WIR-10a` gains a `system_reason` if the sweep enqueues releases (opus).
- Lean omits attachments entirely (`Funding.lean:141-143`).
