# Panel r42 synthesis — when a successful create's temporary key is deleted (Q24), 2026-10-11

Readers: opus (claude xhigh), astra, sol (codex xhigh); clones at db6bb54. Fable was not run (weekly usage
limit until 2026-10-14). All exit 0.

## Agreed (3–0)

- Nothing obliges deleting a settled create's key: `PRV-9` and `OPS-32` ("is deleted by the sweep only
  when") restrict, and only `CNF-303`'s "delete it when that guard clears" asks for it, owned by no
  requirement.
- The registration may carry the caller's create key; re-registering the same public key meets Cloud's
  duplicate-fingerprint refusal and Robot's `409 KEY_ALREADY_EXISTS` (documented, not reproduced live: the
  2026-10-11 test uploaded a fresh key). The refusal comes before any order, so no money moves. A create
  overlapping another create's flight is refused under either option.
- Settlement need not clear the "no machine still reads `provisioning`" guard: `OPS-27`'s confirming read
  establishes existence, and a later observation (the sweep's) may be what clears it.
- No shared-key reuse (shared ownership and a per-account lock).

## Split

- **Sweep only, with an explicit MUST (opus):** Robot deletes by fingerprint with no conditional delete,
  so a second deleter can remove a later create's registration of the same key (sweep selects A's key →
  prompt cleanup deletes it → B registers the same key → sweep deletes B's). One deleter cannot race: B's
  registration is refused while A's exists. Also: the driver's pre-acceptance deletion must not delete by
  fingerprint after a 409 or a lost `POST /key` reply; `PRV-9`'s "unresolved operation" is too narrow;
  `08-provider-notes` omits Robot's 409.
- **One bounded attempt after settlement commits, sweep as fallback (astra, sol):** shortens the refusal
  window; astra requires preventing the replacement-registration race (validate ownership; a bare
  fingerprint is insufficient); sol notes `PRV-9`'s vanished-record exception versus `STO-14` deleting
  settled operation rows while machines remain.

Owner decision Q24: sweep only, with the MUST (ADR-0040's amendment of 2026-10-11).
