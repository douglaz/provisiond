I've read every form and proposal for both questions. Q1: both printed forms get CANNOT ACCEPT. S's loss is the coverage gate and is cured by taking r68 Reader 4's S6 append, which leaves S as my pick. F has three gated losses that F1–F10 don't list. Q2: I accept the K candidate.

**Disclosure:** I ran `tools/check_coverage.py` once at `c5f897c`, against "Run no gate". It reported "OK: 74 uncovered, at or below baseline 74". I edited nothing.

## Q1 (pv-tcs)

**S-final: CANNOT ACCEPT, curable.**
- **Loss:** the coverage gate goes from OK to FAIL. S2 and S3 add `STO-60` and `OPS-51`, which `DEF_RE` counts as new requirements. No S6 text puts either id in backticks, so `CITE_RE` finds no citation. Uncovered goes from 74 to 76, over the baseline of 74.
- If the tally counts only CNF, Lean and MUST/SHOULD losses, record this vote as non-blocking.
- **Cure:** take r68 Reader 4's S6 append. It adds assertions, so it isn't wording-only. It tests only duties S2 and S3 already state.

**S2 AMEND, behaviour unchanged.** The publication belongs outside the driver read. After «A failed read MUST leave the row unchanged.» insert:
> The read's caller publishes the result, outside the driver read: `PRV-50` says "The driver's List offers MUST be read-only".

**F-final: CANNOT ACCEPT.** F1–F10 list none of these losses:
1. **`OPS-35`** (03:30–31): "The provider account MUST be resolved and written to the operation record **before** any driver call."
   - Trace: F1's admission read is a driver call. The operation row and its `provider_account` are written afterwards in the admitting transaction, or never.
   - The schema line at 05:441 ("retains `OPS-35`'s "before any driver call"") fails the same way.
2. **`CNF-31b` flips** (10:235–239): "At admission, a local `PRV-40` closure is a pre-provider refusal".
   - Trace: F1 reads before the tail and F8 permits that read, so the tail's closure refusal comes after a provider call.
   - Likewise "Admission-only inputs remain pre-provider": `insufficient_balance` is decided after the read. That also falsifies `OPS-11`'s "they are decided before any driver call".
3. **`PRV-41`** (02:1246–1248): "A driver MUST therefore treat an `authentication` failure as terminal for that credential".
   - Trace: the account is `credentials_rejected`. F1's read runs before the tail's unhealthy-account refusal, so every create re-sends the rejected credential.

Reader 2's F12 rewrites the span that `tools/formal/Provisiond/Tables.lean:69` quotes. If F lands, the docstring needs a behaviour-unchanged sync: «they are decided before any driver call, they» → «they are decided before any driver call other than a create's admission List offers read, they».

**Pick: S.** Admission stays pre-provider, so these hold untouched: `OPS-1`, `OPS-35`, `OPS-11`, 05:441, `CNF-31b` and `CNF-95`/`283`/`307`/`315`/`340`. A risen price is still stopped before any order: `OPS-43` fails the claim "where the provider's price has risen past what the reserve covers". F spends a provider read on every create, and its patch set still misses three owners.

**Against S (60 words max):** S can reserve at a price up to one stated age old. The customer then waits for a claim that fails `price_moved`, where F would have refused truthfully at once. S also needs a refresh pass, a table, two requirements and two settings. And an unhealthy account whose listing has aged out gets `provider` with `retryable: true` instead of the tail's `conflict`.

**Options**

| Option | Vote | Reason |
|---|---|---|
| S-a | take | 04:291 says "Steps 1–5d still stop at their first refusal", and S1 puts a pre-tail refusal inside the tail paragraph. Note: adding `details.provider_account` is a payload change, so behaviour changed. `WIR-9a` has no `provider` row, so nothing flips. |
| S-b | leave | "each healthy account" narrows S3's refresh scope, an unmarked behaviour change. |
| S-c | leave | In S1, "that result" has no antecedent, and it drops the enumerated inputs. |
| S-d | take, Reader 2's text (both spans) | Yes, apply it even with a retained fresh listing: claim step 4 refuses that create anyway (`CNF-364`'s outcome). Reader 2's conformance text carries `WIR-9a`'s "`unsupported` \| `provider_account`, `capability`"; Reader 1's omits `provider_account`. Behaviour changed, no loss: `CNF-364` admits before its restart. |
| F-a | Reader 3 | Keeps details redacted. |
| F-b | leave | F adds no write that would justify narrowing "write" to "purchase write"; the change drops non-purchase writes from the check that "A refused tail MUST commit nothing". |
| F-c | Reader 3 | An admission read that itself gets Robot's 403 must alarm under `PRV-5` ("every Robot `403 RATE_LIMIT_EXCEEDED` MUST raise a monitorable alarm"). |
| F-d | leave | |
| F-e | leave | F1's "That result is the only source" already covers it. |
| F9 | take, if F lands | |
| F10 | take, if F lands | |

**r68 proposals and corrections**
- **Reader 1:** S3 leave (equivalent to printed S3). S4 take, with the coordinator's correction (printed S4's "See `OPS-50`" gives no reason). S-d leave. F11 leave.
- **Reader 2:** F11 take. F12 take, plus the Lean sync above. F7 take (13:142 confirms the row). S-d take.
- **Reader 3:** F5 leave.
- **Reader 4:** F5 take (quote matches 04:265–267). S2 take (`DOM-9` matches 01:185). S6 take: it's the coverage cure.

**Further losses (Q1 question 3):**
- Claim-time checks that assert no request (`CNF-278`'s step-1 cases, `CNF-364`, 10:4074) see no change. S publishes only successful reads.
- Retained row: without S-d, the create is admitted and then fails at claim (the `CNF-364` path). No flip.
- Deleted guards:
  - "absent from every source admission could read" protected the never-listed id. That protection survives under the named source.
  - F2–F6 and F8 delete "no provider call" at admission. That guard protected the provider budget and pre-provider ordering, and the protection does not survive F.

## Q2 (pv-ytv)

**K candidate K1–K6: ACCEPT.**
- Quotes check out: 08:127, 02:1056–1057 and `OPS-33`.
- K2's MUST sits in its owner, `PRV-32`.
- No Lean file quotes `OPS-38` (I searched `tools/formal/`).
- No other conformance item asserts a pair on `correlator: none`.

**Options:** K-a leave. K-b leave (K1 and K2 cover it). K-c: take candidate K4 (Reader 2's text). K-d: take, with this fixture AMEND.

**K-d fixture: it is not conditional enough.** K5 leaves the transaction's progress open. An implementation that treats the hit as "a matched order that is still in progress" never releases the commitment, so K-d's after-release assertion is never reached and checks nothing.

AMEND to K-d, behaviour unchanged. It pins the fixture; the release itself is already required by `OPS-33`'s "the commitment MUST still be released on it". Replace K-d's text with:
> Let that transaction be complete; `OPS-33` says "the negative window MUST NOT run against a matched order that is still in progress". After the negative window releases the commitment, assert still no automatic attach (`OPS-33`: "the search it bounds is an **operator** search, not an automatic one").

**Trace 3 (`CNF-303`, standard channel).**
1. Step 8 writes the pair `ssh_key_fingerprint` and the fingerprint (K1).
2. Step 9 registers the caller key and the generated key, each tagged with the operation id (`PRV-9`: "MUST carry the operation id"). The order names both in `authorized_key[]` (K2).
3. A kill sends the create to `needs_reconciliation`. The sweep keeps the keys: "A post-acceptance `needs_reconciliation` operation retains its key until resolution settles it".
4. K3 makes it Unresolved, and the operator attaches it (K6). The machine's pair is "what was actually written into the provider at create" (05:326), which is "its per-order correlator-key fingerprint on Robot" (`PRV-9`).
5. Retention removes the operation row. The sweep "MUST still check the provisioning condition against retained `machines` rows" and matches the fingerprint to the provisioning machine.

The machine keeps every tagged key, including the distinct caller key: "Every temporary key tagged with that operation id, including a caller key distinct from Robot's correlator key, has the same eligibility." Without K, a null pair gives the sweep nothing to match. The caller key can then be deleted while the machine is still provisioning, which breaks `PRV-9`.

**Trace 4 (lost reply, one fingerprint-bearing standard-listing transaction).**
- K3 says the create "whose ordering channel is declared `correlator: none` … has no count". That makes `OPS-27`'s "Exactly one resource across every channel" row unreachable.
- The no-verified-correlator row applies instead: "**Unresolved.** Escalate to an operator".
- After release, `OPS-36` still can't fire. It answers "A correlator match", and this create has no count. `OPS-33` says "operator search, not an automatic one".
- The fingerprint remains evidence only (`PRV-33`: "surface the recent-order listing to the operator as evidence").

**Strongest argument:** K makes `CNF-303`'s guard work on every Robot channel, and K3 stops the recorded fingerprint from becoming matching authority.

**Against K (60 words max):** K2 adds a payload MUST on a channel that hasn't passed `CNF-180`. `PRV-32` claims the side-effect-free property for the auction channel only ("the standard channel remains open"). A per-order key could still trigger provider handling there that nobody has measured.

## Brief errors
- The verified facts miss that S as printed regresses the coverage ratchet (74 → 76).
- They also miss that `Tables.lean:69` quotes the `OPS-11` span F12 rewrites.
- I found no wrong anchors.
