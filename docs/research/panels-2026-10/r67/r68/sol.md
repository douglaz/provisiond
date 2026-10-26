**Q1:** S-final: **AMEND — behaviour unchanged**, S2 and S6 below. F-final: **CANNOT ACCEPT**, with an additional wording amendment to F5.

**Pick S.** It defines a bounded admission source while preserving provider-silent balance and halt refusals.

F’s unlisted loss is [OPS-35](https://github.com/douglaz/provisiond/blob/c5f897c32f7894d77a544528872176f241394d0d/03-operation-lifecycle.md#L30): “The provider account MUST be resolved and written to the operation record **before** any driver call.” Trace: pass 5d → perform F1’s driver read → only afterwards open admission’s transaction and create the operation. The required record does not exist at the call. F10 excepts `OPS-1` alone.

A successful read followed by `insufficient_balance` also contradicts `OPS-11`’s unchanged “they are decided before any driver call”.

- S-a: **take**.
- S-b: **leave**.
- S-c: **take**.
- S-d: **leave**; the bootstrap availability limitation is real, but I found no checked admission requirement it violates.
- F-a: **take Reader 3**.
- F-b: **take**.
- F-c: **take Reader 3**.
- F-d: **leave**.
- F-e: **take**.
- F9: **take as printed**.
- F10: **take as printed**, insufficient to repair the omitted loss.

Coordinator points:

1. **Claim-scoped; no unlisted admission-read flip.** The fixtures identify worker refusals after “before claim”/“Before claim”, “then claim it”, or “Use stored creates”.
2. **No such CNF found.** `CNF-364` initially requires an account that “declares `list_offers` and the ordering capability”.
3. **No claim-time no-write loss found.** Publication belongs outside the driver call; `PRV-50` says “The driver's List offers MUST be read-only”.

**Against S:** It adds persistent state and scheduled reads, can admit stale prices, and leaves a new account without `list_offers` repeatedly refusing with retryable `provider`. F avoids that machinery and uses a request-specific read, once its omitted amendments are decided.

**S2 — AMEND, behaviour unchanged.** Replace the `offers` table row with:

```text
| `offers` | json | the driver's List offers result (`DOM-9`: "Prices MUST be carried as strings exactly as the provider returned them.") |
```

**S6 — AMEND, behaviour unchanged.** Append to its inserted conformance text:

> With no customer requests, assert each account declaring `list_offers` is read within each stated offer-listing refresh interval, except while its credential is subject to the authentication stop. Assert no scheduled retry for a stopped credential. After successful reads, assert publication of the complete result with `read_at` equal to the dispatch instant. Complete two reads in reverse dispatch order and assert the row retains the later read's `read_at` and offers. Fail a read and assert the existing row is unchanged. See `STO-60` and `OPS-51`.

This demonstrates the new duties and supplies their otherwise missing conformance citations.

**F5 — AMEND, behaviour unchanged.** Replace its first replacement text with:

```text
`API-7` tail ("then, on create only, `rate_limited` when the offer's account and ordering channel are closed under `PRV-40`") before any provider mutation
```

**Q2:** K-final: **ACCEPT**.

- K-a: **leave**.
- K-b: **leave**.
- K-c: **take Reader 2**.
- K-d: **take**.

**Retention trace:** Yes. The generated correlator registration carries the operation-id tag; its fingerprint reaches the retained machine pair. The sweep associates the operation’s tagged registrations with that provisioning machine and retains the caller and correlator keys. `PRV-9` explicitly includes “a caller key distinct from Robot's correlator key” in “the same eligibility”.

**Precedence:** Yes. K3’s “has no count” removes the input needed for the “Exactly one resource across every channel” row. Its retained sentence specifies “it is **Unresolved**”. Independently, `PRV-33` requires “attaching a discovered machine to a tenant MUST be an operator action”.

**Against K-final:** It requires a generated key alongside caller keys on the unverified channel, adding registration work and possible failure points while operator resolution remains necessary.

**Brief errors:**

- F’s claimed “full list” misses `OPS-35` and `OPS-11`, quoted above. The supposedly unaffected `05-persistence.md:441` also explicitly says: “The `provider_account` write retains `OPS-35`'s ‘before any driver call’.”
- S-d’s “no read ever stores its listing” needs a no-history qualification. Populate a listing, restart without `list_offers` while retaining ordering capability, and create before the row ages out. The printed stored-row checks can pass; refusal need not occur until claim.

No gates or `lake` were run; tracked files were unchanged.