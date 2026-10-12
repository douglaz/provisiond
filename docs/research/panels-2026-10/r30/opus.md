**Verdict:** take option (1) and cut it further. `source` and `observed_at` render only beside `restricted`; an `unknown` status always renders both null. Reject (2), and reject "latest observation of either kind".

**Why**

- **Nobody reads provenance on `unknown`.** A whitespace-normalised search found no requirement that branches on `source` or `observed_at`. The hits are definitions (01:333-335, 05:271-273), renderings (13:322, 13:1216-1220) and `CNF-233`/`CNF-250`.
  - **Agent:** "The signal's job is to **stop** a remediation loop" (01:351), and only `restricted` stops one. Never-looked and withdrawn both mean "proceed".
  - **Operator:** `SEC-32` audits each write (07:288-290), and `operator_ref` names the notice.
  - **Conformance:** `CNF-250` alone.
- **Non-null provenance on `unknown` is a negative claim.** `none` was deleted because "no source can support the negative" (ADR-0038:30-31), and the harm the ADR names is `{"status": "none", "source": "provider_api"}` (ADR-0038:21).
  - r24's "else last read" (synthesis.md:56) plus opus.md's `WIR-11` edit, which changes only `status`, renders `{"status":"unknown","source":"provider_api",…}`. That is the deleted fixture under a new name.
  - A withdrawal rendered as `operator_notice` at t2 is an operator `none`. The ADR excludes it: "an operator's value can only agree with the provider's or add to it" (ADR-0038:40-41).
- **Read literally, the ADR already gives null.** "Its `source` is the positive one" (ADR-0038:36-37): no positive observation, no source. A dated note makes that explicit.
- **The rule is total, and `CNF-250` becomes local.** The check reads one response and needs no history.

**Render table** (`p` = provider read time, `o` = operator record time)

| State | (1) with r24's last-read rule | Proposed |
|---|---|---|
| never read, no record | unknown/null/null | same |
| provider clear | unknown/`provider_api`/p | unknown/null/null |
| provider set | restricted/`provider_api`/p | same |
| operator only | restricted/`operator_notice`/o | same |
| both | restricted/`provider_api`/p | same |
| withdrawn, never read | unknown/null/null | same |
| withdrawn, provider clear | unknown/`provider_api`/p | unknown/null/null |
| withdrawn, provider set | restricted/`provider_api`/p | same |

**Defects in the framing**

1. Item 2 treats "clear flags is `unknown`/`provider_api` with a time" as settled. That is r24's rule (synthesis.md:56), not ADR-0038:36-37, and it creates the gap. Option (1)'s "no current observation" still counts a clear read as an observation.
2. The "three nullable columns" leave out the notice. The ADR's operator record holds "the notice it came from" (ADR-0038:34-35), and "A record carries an `operator_ref`" (ADR-0038:41-42). r24's columns (synthesis.md:25-27) have no slot for it.
3. `SEC-32` will not hold option (2)'s history. Its fields include "operation id, operation kind", these writes mint none (`API-61`), and it lists no body. So with a shared route, a withdrawal may be indistinguishable from a record.
4. "t1 or t2" hides a third instant. `WIR-47`'s body carries an operator-supplied `observed_at` (13:1205), while r24's column is `operator_recorded_at` (synthesis.md:26). `WIR-47` must say which renders. This does not block the verdict.
5. Item 4's list omits `WIR-47`, which is where the render rule lives, plus `PRV-35` and `DOM-27`. "Nobody (has) looked" also appears at 02:879, 10:2848 and 13:1217.
6. "No Lean declaration encodes this" (ADR-0038:85) holds only if withdrawal is a body on `record-network-restriction`. `Verb` (Admission.lean:134) has one constructor per route, and "a verb added without a listener is a missing case" (Admission.lean:163).

**Edits**

- **ADR-0038**, dated note to Decision 2: "Where neither is positive, `source` and `observed_at` are null." Record last-read and latest-of-either rendering as rejected.
- **`WIR-47`** owns the rule.
  - 13:1216-1217 becomes: "`restricted` renders the positive observation's source and time (`provider_api` where both are); `unknown` renders both null, whatever was read or withdrawn before."
  - The 13:1205 body becomes `restricted` plus `operator_ref`.
  - Withdrawal is `{"status": "unknown"}` on the same route.
  - Delete the 409 (13:1206-1209).
- **`DOM-27`** (01:333-335): new enum; cite `WIR-47` for rendering.
- **05:271-273:** four nullable columns, `provider_restricted`, `provider_observed_at`, `operator_recorded_at` and `operator_ref`. A withdrawal clears the last two. No "nobody has looked" sentence; the derived `source` cites `WIR-47`. The clear-read time loses its wire reader, but dropping it touches Decision 2, so that is the owner's call.
- **`PRV-35`:** keep 02:877-878's "`unknown` MUST NOT be rendered as `none`"; delete 02:880-881's "authoritative … fallback".
- **`CNF-250`** (10:2522): change the first clause to "`source` and `observed_at` are null exactly when `status` is `unknown`". Keep the `system_reason` half and the fresh fixture, and add that a clear read renders null/null.
- **`CNF-233`** (10:2845-2848): add the trace (no-signal driver, record t1, withdraw t2, renders `unknown`/null/null) and r24's four sequences; delete the 409.
- **`CNF-228`** (10:2840): `disabled` becomes `restricted`, from either source.
- **`WIR-11`** (13:322): `{"status":"unknown","source":null,"observed_at":null}`.
- **`WIR-43`** fixture (13:1089-1101): add the joined object that 13:1218-1220 promises.
- **Lean:** none, if withdrawal stays on the existing route.

**Gate:** `nix develop --command bash tools/check-all.sh` at `843a2f2` exited 0. No tracked files were changed; a copy of this answer is at `/tmp/r30-opus-answer.md`.
