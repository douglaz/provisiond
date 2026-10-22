**Vote 1:** retain every device, with `identifier: null` when neither WWN nor serial exists. This preserves `RSC-26`’s “over the whole device set” and distinguishes an unselectable disk from a missing disk.

Costs and mixed-machine traces, assuming install eligibility and other prerequisites:

1. **Null:** caller sees A+B, can install on A, and the fingerprint covers exactly A+B. Amend `WIR-10b/40`, `RSC-26/33/38/46`, `WIR-20`, and `CNF-47`; align glossary/diagram. `DOM-*` stays unchanged. Lean already has `Device.identifier : Option Identifier` and non-optional `Request.identifier`; my mixed-machine witness passes without changing the resolver.
2. **Omit:** caller sees A and can install on A. Keeping the whole-set fingerprint hashes A+B, unlike the visible set. Hashing only A violates “over the whole device set”. Costs the same reporting requirements, loses diagnostic completeness, and still needs `RSC-46`’s ordering repair. No nullable request form is needed.
3. **Refuse:** pure refusal supplies no inventory/fresh fingerprint for selecting A. Requires reporting exceptions and admission/failure rules involving `WIR-40/10b`, `RSC-26/33/38`, `DOM-10`, `WIR-30`, and `OPS-11/WIR-9a`. Returning inventory despite failure becomes an additional wire form; emitting its fingerprint still requires deterministic ordering.

The frozen strategy list is **not an identifier-presence signal**. `DOM-10`’s inventory row names “`rescue_ssh`”; `RSC-26` calls omission “a static per-offer declaration from provider facts”. Absence can reflect other eligibility limits; presence cannot predict the unexpected post-purchase case. A broader static prohibition loses diagnostics. Runtime refusal after reading inventory can cover the unexpected case, but needs explicit error/report and rescue-exit semantics.

`RSC-46`’s “sorted by identifier” leaves absence and ties unspecified. My edit orders normalized identifiers with null last, breaks ties by canonical tuple bytes, and retains identical tuples’ multiplicity. It explicitly makes normalized-empty serials/WWNs—including whitespace-only values—absent; that equivalence was previously unstated.

The triage justification is incomplete: callers cannot name a null device. `WIR-20`’s “is a drive serial or WWN” does not explicitly classify null/empty input. I specify `invalid_request` before enqueueing for missing/null/non-string/normalized-empty identifiers; valid strings with zero matches still abort `integrity`.

Keep the serial/WWN gap **in scope**: expose both nullable fields alongside `identifier`, supporting the report and reproducible fingerprint.

**CNF-47 draft, condensed:** “Return A and anonymous B, with B’s identifier/wwn/serial null; hash both; allow A’s install; changing only B’s size causes integrity before writes.” The amendment additionally tests anonymous-only machines, ordering, multiplicity, and invalid requests.

Baseline, proposal, bad-fixture, and restored-final gates all exited **0**. The bad fixture substituted `/dev/sdb` for B’s identifier. A separate semantic fixture check rejected it (**1**) and passed after restoration. That check and implemented CNF-47 would catch it. [Proposed edits remain in the clone](/var/tmp/provisiond-panel-r61/astra/r61-proposal.patch).

**Strongest argument against my pick:** null breaks string-only clients. `WIR-2`’s “ignore unknown response fields” does not protect a changed known-field type.