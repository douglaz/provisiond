**Q16a verdict: your rule is right, your counterexample is the weaker of two, and the rule can be smaller than you stated.**

**Q16b verdict: the Manager's conflict is real and your rule resolves it, but it is one word in `OPS-32` plus provider notes. "Delete on settlement" is that word, and your rule already is it.**

Baseline gate at 843a2f2: all seven gates pass.

**Q16a, why.** The B≠A trace is not excluded by anything the set holds. V8 is UNDETERMINABLE, and Hetzner's Server Auction FAQ says nothing about whether the delivered unit is the listed one. But a second trace needs no unobserved provider behaviour. `PRV-36` says "Beyond the window, a read still showing the pre-mutation state resolves the mutation as *not applied*" (`02-provider-contract.md:933`), and `PRV-42`'s table inherits that for `GET /server/A` (`02-provider-contract.md:1069`). The visibility window is a maximum over twenty samples. A Robot order sits `in process` for "Usually … 1 business day", "Some orders may take longer", with a sales review for new customers. The two measured samples differed by 2×. An order still in progress past the window reads absent, resolves absent, releases the commitment, and server A arrives later as an operator deficiency. That is exactly what `ADR-0035` closed: "the negative window MUST NOT run against a matched order that is still in progress" (`03-operation-lifecycle.md:1437`). The protection is keyed on a *match*, and the identity path never matches. Only the transaction can tell "in progress" from "never landed". So the negative branch must read the listing anyway, and "the correlator is unnecessary" (`02-provider-contract.md:1048`) is false on that branch.

**Cost of your rule: none.** The auction order carries a key regardless. `PRV-8` forbids passwords, Robot's authorization choice is keys or password, so the fingerprint is on the transaction for free. The 30-day bound and the ordering permission touch only the fallback, as on every other channel. The permission argument was marginal anyway: a `#ws+` user without ordering cannot read `/order/*` and cannot have placed the order (`08-provider-notes.md:442`).

**Smaller rule.** Drop V8's guard entirely. On the positive branch it is not load-bearing: `ADR-0036`'s claim gives one in-flight create per offer across tenants, and "a missing offer MUST NOT be ordered", so the account can own A at resolution only through this create. On the negative branch it never runs. The identity read then reduces to `OPS-27`'s confirming direct read taken first: found and owned, first row; anything else, `PRV-32`'s search unchanged. Nothing depends on the identity by rule, so the `[verify]` can stay open indefinitely. Batch B step 4 (`docs/research/provider-verify-2026-10.md:688`) still collects a sample.

**Framing defects, Q16a:**
- `02-provider-contract.md:1072` says `OPS-29` is "satisfied by construction". `OPS-29` forbids matching "on hostname, offer" (`03-operation-lifecycle.md:1138`). The identity read is a match on offer. What makes it exact is the claim, not the identity. Cite the claim.
- Your framing treats the transaction as fallback evidence for identity failure. It is the only evidence of order status, which `ADR-0035` made load-bearing.
- The Lean model already refuses the negative branch: `Reconcile.step` acts on a read only with `orderLanded = some c` and `.found` (`tools/formal/Provisiond/Reconcile.lean:234`). `PRV-42`'s second row was never formalized.

**Q16b, the conflict precisely.** `PRV-9`: the driver "MUST NOT remove them until the provider has actually consumed the key material" (`02-provider-contract.md:133`). `OPS-32`: a tagged key "whose operation is not `running`" is "**deleted**" (`03-operation-lifecycle.md:1423`). `OPS-15` moves every `running` operation to `needs_reconciliation` at startup (`03-operation-lifecycle.md:336`). So after any crash the next complete pass deletes every in-flight create's key while the provider may still be reading it. That is `DEF-6` reintroduced by the sweep.

**Your rule resolves it, and it is already "delete on settlement".** `CONTEXT.md:76` defines `needs_reconciliation` as "Resolution-pending, not terminal". Replace "not `running`" with "settled". Then: refused create, `failed` before acceptance, no consumer, deleted. Cancelled is ambiguous under `OPS-21`, so resolution settles it, then deleted. Resolved-absent, deleted. Resolved-observed, deleted. The "confirms the machine is up" half is the ordinary driver path, which `PRV-9` already demands per provider; V2, V18 and V19 only fill in the answers. One residual: a Cloud server readable while its create Action still runs, swept in that gap. Leave it `[verify]` for batch A step 3 (`docs/research/provider-verify-2026-10.md:657`), which for €0.01 says whether the Action window exists at all. If SSH succeeds there, Cloud's boundary collapses back to "after the call returns".

**Missing operation record:** report it with the unrecorded machines, do not delete. Retention is free: no documented key-count limit or charge on Hetzner Cloud, Robot or DigitalOcean. Robot rate-limits `POST /key` and `DELETE /key` at 200 per hour, which taxes deletion, not retention.

**Framing defects, Q16b:**
- `03-operation-lifecycle.md:1425` "Its private half died with the process" is true for the Robot throwaway and rescue keys, false for Cloud and DO, where `PRV-9`'s resource carries the caller's key. The conclusion, clutter, still holds.
- The lifetime question presumes one key per operation. On Cloud a duplicate fingerprint is rejected (`docs/research/provider-verify-2026-10.md:156`), so two concurrent creates by one tenant share one resource or the second fails. V3's "freshly generated" contradicts `PRV-9`'s "create them". Not yours to settle here, but the ticket carries it.

**Edits.**
- `PRV-42`: strike "and the correlator is unnecessary" and the second table row; demote retention and permission claims to the positive branch; cite the claim for `OPS-29`; keep the `[verify]`; auction creates record the fingerprint like any Robot order.
- `OPS-27`: one sentence after the direct-read paragraph: on an `offer_is_resource` channel the confirming read may be taken first; `not_found` is not evidence and the search proceeds.
- `CNF-285`: assert the positive read attaches without a search, and that a `not_found` read past the window alone does not resolve absent. Negative control: the in-progress trace.
- Research V8 consequence and the ticket's V8 line: no runtime guard.
- `OPS-32`: "settled", `needs_reconciliation` untouched, unknown operation reported, keep the Robot fingerprint-survival clause.
- `PRV-9`: Cloud is not the synchronous case; cleanup at the boundary the notes record; the sweep removes only after settlement.
- `08-provider-notes.md` key lines per V2, V18, V19.
- `CNF-303`: the next pass must *not* delete after a kill; deletion follows settlement. Negative control: a key deleted while its create is `needs_reconciliation`.
- Formal: no change required. Optional `@[req "PRV-42"]` witness on existing `step`: a `.read .notFound` with no matched order leaves knowledge and commitment unchanged. No key model exists and none is needed.
