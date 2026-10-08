**Verdict: none of the three as offered. My answer is (a′): keep (a)'s write rule, drop its per-driver declaration, and delete `none` from the enum.**

**Why.** `DOM-27` says "The signal's job is to **stop** a remediation loop" (`01-domain-model.md:329`). A stop signal only needs positive values. `none` is a "go" value: no requirement branches on it, and no launch source can support it.
- Robot's `locked` is documented only as "Status of locking", and the server object has no lock field.
- Cloud's `blocked` is per IP, while Hetzner also locks "entire servers", and for reasons that include "Non-payment".
- DigitalOcean exposes nothing.

Deleting `none` costs less than (a):
- It makes "`unknown` MUST NOT be rendered as `none`" true by construction.
- It drops (a)'s per-driver declaration, which every launch driver would set to false. The set already withdraws surfaces of that shape (`README.md:215`, `01-domain-model.md:479`).
- It no longer depends on "none of the three can establish `none`". That premise is weakest on Cloud, whose flag is documented as "Whether the IP is blocked by our abuse department".
- A future driver that could support `none` and reports `unknown` instead fails safe. So the "written now rather than later" argument at `05-persistence.md:1063` doesn't carry over.

(a) leaves its write rule implicit; it needs one sentence: **neither source overwrites the other's positive, and each withdraws only its own.** A read showing a clear flag writes `unknown` / `provider_api` / now, but only over the driver's own value or an `unknown`. The operator withdraws a record by recording `unknown`.

**1. The story is true, but on a weaker premise.** The set writes `none` itself:
- `13-wire-contract.md:299` renders `hetzner-cloud-1` as `{"status": "none", "source": "provider_api", …}`. That example plus `PRV-35`'s "MUST report" is the only writer of `none` the set names.
- On DigitalOcean an operator can also record `none`: `WIR-47` gives an example body but no closed list of statuses.
- `WIR-47` says the record "MUST be refused … where the driver reports this provider", and `CNF-233` asserts that refusal. No conformance item asserts that `none` is ever produced.

Defects in your framing:
- **"Every IP reads `locked: false`" has never been observed.** V6 shows only that no server-level field exists. Hetzner's own detection method is "traceroute ends at `blocked.hetzner.com`", plus an email (https://docs.hetzner.com/robot/dedicated-server/troubleshooting/guideline-in-case-of-server-locking/). The argument survives anyway: no source says a clear flag means unlocked.
- **The story picks the wrong provider for the harm.** Robot has no native rebuild (`08-provider-notes.md:37`), and "Everything in this document reaches the machine over SSH" (`06-rescue-install.md:508`). So a Robot install on a locked server should fail before it writes a byte. Wiping a disk needs a rebuild that works without the network, which only Cloud and DigitalOcean have.
- **"A set flag yields `restricted`" maps to an undefined term.** Nothing defines `restricted` versus `disabled`; the words appear only at `01:312`, `05:268`, `13:1153` and `10:2617`. `CNF-228` asserts `disabled`. And one set flag fully blocks a single-family machine: V1's `null` family, and `RSC-45`'s Robot default with no IPv4.
- **`server.locked` can't be settled by a live batch.** Batch A cannot make Hetzner lock a server. The research note's §5 says "Written inquiries are separate, because no account action can settle them". Leave `server.locked` unmapped, as V15 does for DigitalOcean's `locked`.

**2. Where (a) is wrong.** The machine holds a single status/source/time triple (`05-persistence.md:268-270`). Under (a), a set flag after an operator's `disabled` overwrites it with `restricted`, and the next clear flag then erases the whole-server lock. The rule above prevents both.
- **When an operator record ends:** when the operator withdraws it. That matches Hetzner's process: it unlocks only when the customer files an unlock request through Robot support, and the operator is that customer.
- **Stale `disabled`:** a risk of operator diligence, not of structure. It still has a cost, because `DOM-27` names delete as the remedy a positive value invites.
- **Can the operator record `none`?** No; it records `unknown`.

What (a′) touches elsewhere:
- `DOM-7`'s exclusion and `STO-39`: untouched.
- `LDG-71`: the story breaks it today; (a′) restores it.
- `SEC-41`: an account-wide lock goes from unrepresentable (refused) to one record per machine. That is the hand enumeration `07-security-requirements.md:406` forbids for suspension, so the cost should be stated.
- Two homes: "an operator MUST NOT be able to shadow a fact the driver can read" (`05:1049`) still holds once "fact" means a set flag. "the precedence rule therefore bites" (`05:1060`) needs "on a set flag" added.
- `API-63` refuses "exactly as `WIR-47` refuses" (`04-api-contract.md:1420`). Its own trigger, "a status the driver itself reports", is already per value, so narrowing `WIR-47` makes "exactly" true.

**3. Delete `none`.** That is the verdict.

**4. The split and per-family data.** `DOM-27` concedes "even a boolean would lose information a single enum value cannot carry" (`01:317-319`), then stores one value. No reader branches on `restricted` versus `disabled`. Either define them by coverage ("`disabled`: every address the machine has; `restricted`: some") or collapse them into one value.
- Floating IPs don't matter here: no `.md` file in the set mentions them.
- Primary IPs and Load Balancers carry their own `blocked`. Whether a Primary IP's flag mirrors the server's `public_net` is undocumented, so don't build on it.

**5. Third shapes, and the strongest "don't build this".**
- **Third shape:** two triples, one per source, rendered as whichever positive is stronger. It is honest, but it adds a second home.
- **Strongest "don't build this":** (c). Email is the provider's complete channel. It loses on Cloud, where a rebuild wipes the disk and the flag is the documented abuse block.

**6. Formal layer.** No declaration encodes `DOM-27`, `PRV-35` or `WIR-47`'s 409. `Verb.recordNetworkRestriction` appears only in classification tables: the `WIR-34` listener, `API-7`, `SEC-39`, `LDG-20` and `LDG-40`. `check-all.sh` passes at `82e7f37` (exit 0).

**What (a′) edits:**
- `DOM-27` (`01:310-319`). Separately, its `STO-44` citation for the observed time is wrong; those columns are at `05:268-270`.
- `PRV-35` (`02:756-778`): report positives only, rewrite the precedence sentence, lower the Robot row's confidence, and add the Cloud row's `null` family and `server.locked`.
- `05:268-270` and `05:1047-1066`.
- `WIR-47` (`13:1153-1157`, `13:1164-1166`) and the example at `13:299`.
- `API-63` (`04:1419-1420`).
- `CNF-233` and `CNF-228`.

`CNF-250` is unchanged, and nothing in Lean needs to change.
