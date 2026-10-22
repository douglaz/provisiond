# Panel brief r62 (panel B): claim-time errors — pv-p3k, pv-009, pv-gpw, pv-ss4, pv-7j3. 2026-10-22

You are one of four independent reviewers. Your working directory is a throwaway clone of the specification
repository `provisiond-spec` at `07bac41` (master). Read `AGENTS.md` first. `br show <id>` prints a bead (if `br`
fails in the clone, `.beads/issues.jsonl` holds it). You MAY edit tracked files in this clone to test a claim.
Write nothing outside it (never `/tmp` or `/var/tmp`). Never commit, push or call a provider API. Read nothing
outside this clone except toolchain files. Gates are optional this round. Run them only if your form touches Lean
or a `CNF` quote: `nix develop --command bash tools/check-all.sh`, unpiped, redirected to a file in the clone,
exit code read. Keep `TMPDIR` as set. Do not delegate, background or wait on anything: do the work yourself in
this session. Have a draft answer by minute 25.

Every quote below was grepped at `07bac41`. The manager has still been wrong in briefs before, so check any fact
you rely on and report each error under "Brief errors". Read text by requirement id, not by line number.

## Settled (off-limits)

- **pv-009's kind.** The bead's engine B ("makes the read without the gate") breaks `DOM-10` and `SEC-15`. A
  claim-time `list_offers` gate failure is `unsupported` naming the provider account and `list_offers`. Q2 asks
  only its position and its `retryable`.
- **Owner ruling of 2026-10-21 (pv-xer).** `OPS-43` step 1 now quotes `API-63`: "with `retryable: false` for
  `"account_terminated"` and `retryable: true` for `"state"` on both the error and the operation view". The
  ruling is fixed. You may argue from it by analogy.
- **Fixed text.** These stand as written: `OPS-43`'s step order 1–9; its "The first failing check stops
  subsequent checks; its owning classification governs disposition"; `OPS-11`'s create row, "Any create failure
  the worker records before any step-9 request (before any per-order key upload or order request) MUST settle
  `failed`, whatever its kind"; `OPS-23`'s two missing-field bullets; and `PRV-47`'s caller-supplied sentence.
- **Out of scope.** Admission's offer source (pv-tcs, a later panel). `WIR-48`'s missing `retryable` (note it if
  you like, as a new bead, but don't vote on it).

## Governing text (verbatim)

- `PRV-10`: "create MUST reject the request unless the request carries an explicit purchase acknowledgement
  (`WIR-17`'s top-level `acknowledge_purchase`), *and* the account is configured to allow ordering. Both, not
  either."
- `DOM-16`: "Ordering capabilities (`provision_virtual`, `provision_bare_metal`) for providers that bill per order
  SHOULD be conditional on an explicit per-account `allow_orders` configuration flag, so that a misconfigured
  deployment cannot spend money."
- `DOM-10`: "Every operation with a capability MUST be gated on it before the driver is called, **including
  create**" and "A capability check failure MUST return an "unsupported" error naming the provider account and
  the capability." Its table maps "list offers" to `list_offers`.
- `DOM-15`: "A capability that is declared but whose code path returns "unsupported" is a defect. Declaration and
  implementation MUST agree".
- `SEC-15`: "Every operation MUST be capability-gated before the driver is called, including create (`DOM-10`)."
- `DOM-17`: "`retryable` describes whether repeating the *same request* is safe and sensible." Kind table:
  `invalid_request` "Caller error, deterministic"; `unsupported` "Capability not declared or not implemented",
  501; `internal` "Defect in this system", 500.
- `WIR-9a`: "**`details` is machine-readable and its keys are defined per kind, not left to prose.** The caller is
  software; routing a value through `message` (which `API-25` constrains) forces an agent to parse English.
  Minimum keys:". Its `unsupported` row: "`provider_account`, `capability` (`DOM-10`)". Its purchase-tail
  `retryable` table: `conflict`/`state` on a `terminated` account is `false`, "The named account cannot recover";
  on `account_unreachable` or `credentials_rejected` it is `true`, "The named account can recover".
- `WIR-29`'s fixture lists `"allow_orders": true` beside `"capabilities": [...]`, and says "`kind` and
  `capabilities` are the descriptor's fields, rendered". `PRV-44`: "The descriptor is a typed, immutable value".
  The `00-overview.md` configuration table has "`allow_orders`, per ordering account | `DOM-16` | boolean | yes",
  where the last column is "Startup-validated".
- `OPS-43`'s claim steps: "1. Read the provider account's stored status (`STO-47`)." … "2. Read the stored channel
  closure" … "3. Repeat boundary validation under `OPS-23`: … This includes `PRV-10`'s "explicit purchase
  acknowledgement" and "the account is configured to allow ordering", `PRV-8`'s "at least one SSH public key",
  and the missing-field checks defined in `OPS-23`." … "4. Obtain the current driver List offers result." … "7.
  Run `PRV-47`'s driver validation: "the driver MUST validate every value it forwards to the provider, including
  provider options". For the rejection's error, see `PRV-47`." Step 1 fails `conflict`/`state` on a recoverable
  status. Step 2 fails `rate_limited` on a closed channel.
- `OPS-23`: "A field the `api` itself writes when it admits the operation fails `conflict`, with
  `details.reason: "incomplete_record"` and `retryable: true` on both the error and the operation view. The
  accepted-price fields above are such fields; the worker-written correlator is not." and "A field the caller
  must supply fails `invalid_request` naming the field, with `retryable: false` on both the error and the
  operation view."
- `PRV-47`: "A caller-supplied value this validation rejects fails `invalid_request` naming the rejected value's
  field, with `retryable: false` on both the error and the operation view (`WIR-9b`)." `PRV-9`: "Every temporary
  key resource a driver registers — for a create or for rescue — MUST carry the operation id as its
  provider-side name or tag".
- `OPS-11`'s install row says `failed` "for the deterministic caller errors `invalid_request`, `not_found`,
  `unsupported`, `authentication` and `rate_limited`".
- `WIR-2`: "**Unknown fields in a request body MUST be rejected** with `invalid_request` naming the first unknown
  field." and "`provider_options` (`WIR-17`) is a free-form object whose interior is the driver's to validate, not
  the core parser's". `WIR-1a` makes bodies I-JSON. `WIR-3` canonicalizes with RFC 8785 (JCS), which sorts
  members. The manager found no text that gives object members an order.
- `CNF-34` asserts "`invalid_request` naming the field". `CNF-342` asserts "`invalid_request` naming the rejected
  value's field" for "provider-forwarded values that pass API boundary validation but the driver rejects".
- `WIR-48`: "naming one not flagged assignable is `conflict` with `details.reason: "state"`. Assigning a tenant to
  an account that `SEC-46` has recorded as confirmed-terminated is also `conflict` — the failure this verb exists
  to repair should not be reachable by using it."
- `API-7`'s tail: "the request's own resource refusal (`conflict`/`state` for create against a provider account
  not `healthy` …". `API-63`'s queued-create sweep: "`conflict`, `details.reason: "account_terminated"`".
  `CNF-248` drives every `conflict` reason as a `409` "except `tenant_suspended`, `price_moved`,
  `account_terminated`, `incomplete_record` and `cut_off`", because "Each excluded reason is recorded on an
  operation's `error`."

Verified negatives, which you should re-check:
- `API-7`'s steps 1–5c and its tails place no capability gate. A grep of `04-api-contract.md` for "capabilit"
  finds only the `GET /v1/providers` row and an unrelated "leaked capability".
- No text states a `retryable` for `unsupported`.
- No `details` key `field`, `fields`, `path` or `pointer` exists.
- In Lean, `TailRefusal` (`tools/formal/Provisiond/Admission.lean`) is a closed inductive with a `rank` and a
  `retryable` tagged `WIR-9a`. A new collected refusal would need a constructor and a `WIR-9a` table row.

## Questions

For each, answer **ACCEPT A**, **AMEND A** (give the exact replacement text), or **REJECT** (name the option or
give your own form). Then list the requirement ids your pick touches, and label the question **mechanics** or
**owner** (a scope or product call), with one line of reason. **At most 120 words per question**, not counting
drafted text. Drafted citations that hold a straight-quoted value use curly outer marks (“…”).

**Q1 (pv-p3k): kind, `details`, `retryable` and position of an `allow_orders` refusal.**
Draft A (the triage default):
- `DOM-16` becomes: "Ordering capabilities … for providers that bill per order MUST be conditional on an explicit
  per-account `allow_orders` configuration flag: an account whose flag is false does not declare them."
- `PRV-10` gains: "The configuration half is `DOM-10`'s capability gate: it fails `unsupported` naming the
  provider account and the ordering capability, with `retryable: false`, on both the error and the operation
  view where there is one. At admission it runs after `API-7`'s step 5c and before the tail, and it stops there.
  It is not a collected refusal. At claim it is `OPS-43`'s step 3 repeat."

Alternatives:
- B: keep the SHOULD, and `PRV-10` states its own kind: `conflict`/`state`, `retryable: true`.
- C: `invalid_request`, `retryable: false`.
- D: A with `retryable: true` (the flag can come back, as in pv-xer's "can recover").

Also say:
- Is A's position right? Step 5, after 5c, or a collected tail refusal?
- If you reject A's `MUST`, what does `details.capability` hold, given `DOM-15`?

**Q2 (pv-009): position and `retryable` of the claim-time `list_offers` gate.**
Draft A: `OPS-43` step 3 gains "and `DOM-10`'s gates on the create's ordering capability and on `list_offers`,
each failing as `PRV-10` states for the configuration half". pv-009 then closes with pv-p3k's edit.
Alternatives:
- B: a gate at the head of step 4: "Gate on `list_offers` under `DOM-10`, then obtain the current driver List
  offers result."
- C: a gate before step 1.

Trace your pick on two accounts:
- an account that is `credentials_rejected` and no longer declares `list_offers`;
- an account whose channel is closed and that no longer declares `list_offers`.

Which error does each return? Under A, which check wins when step 3 holds several failing checks? Is `retryable`
the same as Q1's?

**Q3 (pv-gpw): a claim-time rejection of a value that is present.** There are three writers: the caller, the
`api` at admission, and the worker or driver at claim.
Strawman A (the manager's form, unreviewed): one rule in `OPS-23` covers a missing or present value that fails
claim-time validation at step 3 or step 7, split by writer:
- caller-supplied: `invalid_request` naming the field, `retryable: false`;
- written by the `api` at admission: `conflict`/`incomplete_record`, `retryable: true`;
- written by the worker or driver at claim (a temporary key's operation-id name or tag, a generated correlator
  key): `internal`, `retryable: false`.

`PRV-47`'s kind sentence then cites this rule, and `CNF-342` keeps its scope, asserting per writer.
Alternatives:
- B: per-check sentences. `OPS-23` gains a present-value bullet, and `PRV-47` gains an engine-written sentence.
- C: narrow `CNF-342` to caller-supplied values and leave engine-written values unkinded (CodeRabbit's
  suggestion).

Vote separately on the engine-written kind and its `retryable`.

**Q4 (pv-ss4): the wire form of "naming the field".**
Strawman A (the manager's form, unreviewed): `WIR-9a` gains "An `invalid_request` that names a rejected field
carries `details.field`, an RFC 6901 JSON Pointer into the request body (`"/acknowledge_purchase"`,
`"/provider_options/location"`). Where several are rejected by one check, it names the least pointer in
code-unit order." `WIR-2`'s "first unknown field" adopts the same order.

Alternatives:
- B: `details.fields`, a sorted list of every rejected pointer.
- C: top-level names only (`"provider_options"`).
- D: name any one rejected field; tests accept any.

Can a claim-time check recover your order from the stored record? Does an engine-written value (Q3) carry the
key?

**Q5 (pv-7j3): the reason on `WIR-48`'s confirmed-terminated refusal.**
Draft A (the triage default): "… is also `conflict` with `details.reason: "state"` …".
Alternative B: `account_terminated`. `CNF-248` then drops it from its exclusions and drives it as a `409`.
Reason only.

**Q6.** Should pv-p3k, pv-009, pv-gpw, pv-ss4 and pv-7j3 land in one Run, or should any of them be split out?
Answer in one line.

**Against my picks (written on request).** For each question, give the strongest argument against your own
pick, in at most 60 words, labelled as written on request.

**Brief errors.** List any fact above that is wrong, with the grep that shows it.

**Total answer: at most 900 words.**
