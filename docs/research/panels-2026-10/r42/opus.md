**Verdict:** go with option 2 (sweep only), and say it outright: the sweep is the only thing that deletes a settled operation's key, and it must do so. Option 1 adds a second deleter on the one provider where it helps, and that provider deletes keys by fingerprint.

**Why**
- The key is the caller's, registered fresh for each operation under that operation's id (02:128, 02:130). Nothing reuses a registration.
- The refusal is documented for Cloud (research:147) and Robot (`409 KEY_ALREADY_EXISTS`, research:248), and neither has been tested live: batch B uploaded a fresh key (live-result.txt:3). DigitalOcean and Cherry record nothing (r31/opus.md:56). So ADR-0040:54's "providers reject" is a universal claim resting on two documents.
- The guard can only be observed by a read. `OPS-27`'s confirming read comes before `succeeded` (03:494-497). Robot polls to `ready` (08:116), and the server read `ready` at that moment (live-result.txt:6). If `ready` maps past `provisioning` (08:196 gives no mapping), Robot's guard clears at settlement. Nothing says whether Cloud waits for its Action (research:131). Wherever settlement reads `provisioning`, the next observer is the sweep (01:132-134). The Manager's "the driver attempts" has no actor in that case.
- **The race:** Robot deletes with `DELETE /key/{fp}` (research:689).
  1. The sweep lists fp under A's name, and A is eligible.
  2. A's engine deletes fp.
  3. Create B registers the same fp.
  4. The sweep deletes fp, and B's in-flight key is gone (`DEF-6`).

  Cloud gives a re-registered key a new id; Robot keeps the same fingerprint. With one deleter, B can't register while A's key exists, because Robot answers 409.
- `OPS-8` isn't affected: its index is over "`operations(machine_id)`", and a key names no machine. A lost delete reply is already covered: "A delete may answer that it already happened; `OPS-11`'s goal-state rule makes that a success" (03:1459). `PRV-41` is unchanged.
- **Cost:** a later create with the same key is refused before acceptance, so no order is placed and no money moves. The refusal lasts at most one sweep interval (03:1447). A concurrent create with the same key is refused for the first create's whole flight under either option: 19 minutes on Robot (live-result.txt:5-6).

**Defects**
1. The brief's framing is wrong: nothing obliges anyone to delete a settled create's key. `PRV-9`'s only sweep MUST covers "a tagged key whose operation record has vanished" (02:128). `OPS-32` restricts rather than obliges: "is deleted by the sweep only when" (03:1460). The duty appears only in `CNF-303`'s "delete it when that guard clears" (10:2444), a MUST that no requirement owns.
2. 02:130 and ADR-0040:54 say "unresolved operation". That is too narrow: any registration still on the account blocks the next create with the same key.
3. 02:128 says "the driver MUST delete any registered temporary key". On Robot, a create that deletes by fingerprint after being refused with 409, or after losing its `POST /key` reply, removes the key of the operation that holds it.
4. 08:122 omits Robot's 409. Cloud's is at 08:67.

**Edits**
- `PRV-9`, 02:128. Replace the sweep sentence with: "`OPS-32`'s sweep MUST delete a tagged key once this rule permits it; a vanished record permits it. After settlement nothing else deletes it: Robot addresses keys by fingerprint, so a second deleter can remove a later create's registration." Change "any registered temporary key" to "every key resource carrying its operation id".
- 02:130. Replace the clause with: "refuses a same-key create on that account while any registration of that key survives, including during another create's flight and after settlement until the sweep."
- ADR-0040. Add a dated Q24 amendment. The Consequence points at `PRV-9`, and the universal becomes "Hetzner Cloud and Robot document rejecting a duplicate fingerprint (research V3, V9)".
- 08:122. Add the 409, marked documented but not tested.
- `OPS-32`, 03:1460. Change "only when" to "when, and only when".
- `CNF-303`. Assert that only the sweep deletes a settled create's key, and that a create with the same key in that interval fails before acceptance with no order sent.
- Lean. No change (Rescue.lean:969, 997).

**Strongest "don't build"**
Don't build reuse of an already-registered identical key. It is the only shape that removes the collision, including the in-flight case, but one registration would then serve several operations. Eligibility would become per account and fingerprint, checked against every live operation's persisted request. A's check-then-delete would then race B's lookup-then-order, which is `DEF-6` again, unless a per-account lock serializes the two. If you take option 1 anyway, every Robot deleter must re-read the key's name just before `DELETE /key/{fp}`. That narrows the race to one round trip but can't close it, because Robot has no conditional delete.
