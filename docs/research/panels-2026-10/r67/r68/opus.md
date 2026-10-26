I'd send pv-tcs to the owner with **S-final** as the pick: no CANNOT ACCEPT, take S-a and S-d. F-final carries as an AMEND (behaviour unchanged), but only with two spans it doesn't have; without them it breaks `OPS-35`. K-final can be applied with two wording fixes (K2, K6), both behaviour unchanged. I edited no files and ran no gate.

## Q1 (pv-tcs)

**S-final: ACCEPT. F-final: AMEND (behaviour unchanged).** As printed, F-final is CANNOT ACCEPT because of an unlisted MUST.

**Pick: S-final.** Every rule that keeps admission off the provider stays true without edits. F needs ten spans and still misses two:
- **`OPS-35` (a MUST):** "The provider account MUST be resolved and written to the operation record **before** any driver call". Trace: F1's admission read is a driver call, and the operation row is written later, in the tail transaction.
- **`OPS-11`, 03:259-260:** the admission-only kinds "are decided before any driver call". Under F, `insufficient_balance` and `halted` are decided in the tail, after the read.

F-final AMEND spans. They are "behaviour unchanged" because F10 already says the read "comes before any record".
- **F11** `OPS-35`, after «resolved and written to the operation record **before** any driver call.» insert:
  > This does not cover a create's admission List offers read, made before any operation record exists: `API-7` says "the `api` MUST obtain one current driver List offers result for the named offer's provider account".
- **F12** `OPS-11`: «they are decided before any driver call,» → «they are decided before any driver call other than a create's admission List offers read,»
- **F7**: «assert `unsupported` with `details.capability: "list_offers"`» → «assert `unsupported` with `details.provider_account` naming the account and `details.capability: "list_offers"`». `WIR-9a`'s row requires it: "`unsupported` | `provider_account`, `capability`".

**Non-blocking, both forms:** the new pre-tail refusal takes the place of the tail's first entry, "`conflict`/`state` for create against a provider account not `healthy`".
- Under F this happens at once. An account recorded `credentials_rejected` fails the read locally (`PRV-41`: "treat an `authentication` failure as terminal for that credential"), so the caller gets `authentication`, not `409`.
- Under S it happens only after the listing ages out.
- `CNF-307`'s "each fault alone" can still be met with a provider that answers, so nothing flips.

**Options:**
- **S-a: take.** 04:291 ("Steps 1–5d still stop at their first refusal") leaves S1's pre-tail refusal with no step.
- **S-b: leave.** Its "healthy account" adds behaviour: unhealthy accounts' listings age out, so the tail's account refusal is replaced sooner.
- **S-c: leave.** "that result" has nothing to refer to in S1.
- **S-d: take.** This is "behaviour changed" against S-final, which refuses `provider`/`retryable: true` forever on such an account; no checked verdict changes (point 2). Insert in S1 before "Where no listing is stored" (if S-a passes, this sentence leads step 5e):
  > On create, an account that does not declare `list_offers` MUST be gated under `DOM-10` before the tail: "A capability check failure MUST return an "unsupported" error naming the provider account and the capability, with `retryable: false`".

  Append to S6:
  > On an account declaring the ordering capability but not `list_offers`, assert `unsupported` with `details.provider_account` and `details.capability: "list_offers"`, `retryable: false`, no `details.refusals`, and no commitment, operation or receipt.
- **F-a: Reader 3.** It keeps the "redacted details", which `WIR-9a` requires for `rate_limited` ("`rate_limited` | `retry_after_ms`"). F1 names only the kind and `retryable`.
- **F-b: leave.** It narrows what the test checks.
- **F-c: F5 as printed.**
- **F-d: leave.**
- **F-e: leave.**
- **F9: take.** The record says "`PRV-40` says to", so it must quote F8's words.
- **F10: take.**

**Coordinator points:**
1. All four items are scoped to the claim. `CNF-55` and `CNF-364` assert "no provider request" of the worker's refusal, and so do `CNF-278`'s account-read cases. `CNF-342`'s step-3 cases are stored creates that never pass admission. No flip.
2. None. In `10-conformance-checklist.md`, `list_offers` appears only in `CNF-364`, which declares it at admission.
3. No `CNF` item asserts "no write" at claim. The publish is an engine write under `OPS-50`. It must come before step 8 to keep `API-63`'s "the last write before the ordering call", and `STO-60` allows that.

**Against S-final (on request):** it admits at a price up to one listing-age old. A customer can reserve too little and only learns of it at claim, after queueing, as `price_moved`. It adds a table, an engine component and two parameters, and the account in S-d needs its own text.

## Q2 (pv-ytv)

**K-final: AMEND (behaviour unchanged).**
- **K2.** Robot orders carry fingerprints, not public keys, and the key's registration stays `PRV-9`'s. Replacement:
  > On every Robot ordering channel, including one declared `correlator: none`, the driver MUST generate a throwaway key unique to that order, and the order MUST name it in `authorized_key[]` beside the caller's keys (`08-provider-notes.md`: "`authorized_key[]` supplies fingerprints to orders"). See `PRV-9`, `PRV-26` and `PRV-33`.
- **K6.** `OPS-27` says "any non-authoritative search MUST leave the create in `needs_reconciliation`", and its fourth row includes "no verified correlator exists for the operation's ordering channel". So a standard-channel create never settles on its own. Replacement:
  > Run this Robot case on a standard-channel (`correlator: none`) descriptor too, settling the create through the operator's attach (`PRV-33`: "attaching a discovered machine to a tenant MUST be an operator action").

**Options:**
- **K-a: leave.** It keeps "send", and quotes `PRV-26` out of context.
- **K-b: leave.** K1 extends `PRV-26`'s MUST to every channel explicitly; K-b only describes it.
- **K-c: Reader 2.** It is case-based. K4's "before any step-8 transaction committed" names a time rather than a case, and "the fingerprint pair" omits the kind.
- **K-d: take.**

**Question 3: yes, the sweep keeps every tagged key.**
1. Step 8 records `ssh_key_fingerprint` and the fingerprint.
2. Step 9 registers the per-order key and the caller key, both tagged with the operation id.
3. The operator's attach writes the machine. Its pair is "what was actually written into the provider at create" (05:326), which is the fingerprint.
4. After retention, `PRV-9`'s "the sweep MUST still check the provisioning condition against retained `machines` rows" reads the fingerprint, finds the correlator key and its operation-id tag, and keeps every key with that tag while the machine reads `provisioning`.

One gap remains: no text says who copies the pair at attach. That gap predates K and is shared with the auction channel.

**Question 4: yes, for conforming engines.** K3 sends this create to the no-verified-correlator row ("applies, and it is **Unresolved**"). `PRV-33` already forbids the first row's automatic attach: "attaching a discovered machine to a tenant MUST be an operator action". `OPS-27`'s table still states no precedence of its own. CNF-371 and K-d test the outcome.

**Against K-final (on request):** the pair holds a value no automatic path may act on, so its meaning depends on the channel. An engine that keys an automatic path on a non-null pair, instead of on `correlator: none`, attaches on an unverified channel. A null pair fails safe, but loses `CNF-303`'s link from the machine to its keys.

## Brief errors
1. **The F inventory and "full list" omit `OPS-35` and `OPS-11` at 03:259-260** (quoted above).
2. **"Its account-read cases fail at `OPS-43`'s step 1" is wrong for one case.** The fresh-account case ("let the List offers read complete, then commit termination before step 8 commits", 10:2817-2818) fails at step 8's conditional write.
3. **Not every «before» string hits exactly once on a literal grep.** The anchors for K1, K2, K6, F2 and F8 span a line break; for example, 02:990-991 breaks between "`PRV-33`" and "governs." They hit only once whitespace is normalised.
