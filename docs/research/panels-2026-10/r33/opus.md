**Verdict:** Store and render the server's recording instant, and drop `observed_at` from the request. On this point the Manager is right and your recommendation is not.

## Why

- **Who reads it.** The set names one reader, at ADR-0038:64-65: "The rendered `observed_at` shows the record's age". No requirement branches on `network_restriction.observed_at`; the only hits are 05:273, 05:287 and 13:1222. Nothing reads "since when". The notice behind `operator_ref` keeps its own time.
- **One field, one clock.** The provider has no instant to give. Hetzner Cloud's field is `Blocked bool` (provider-verify:104) and Robot's is "locked (Boolean)" (:197). So the provider's half is our read time, "when it was read" (ADR-0038:34), and it moves forward on every read. An operator-supplied onset would make `observed_at` mean "last confirmed" under `provider_api` and "began" under `operator_notice`.
- **Staleness.** A new record moves the recording time forward, so an operator who re-confirms a lock resets its age. With an onset time, a lock re-confirmed today and one forgotten weeks ago look identical. ADR-0038:62-63's stale-`restricted` cost would then have no signal at all.

## Defects in your framing

1. **The audit-record claim is false.** You said the recording time is "already in `SEC-32`'s audit record". `SEC-32` (07:288-290) lists "correlation id, tenant, authenticated identity, … operation kind, target machine, and outcome": no time. `CNF-61` (10:341-343) has none either. `SEC-33` (07:292) keeps audit records apart from anything the view reads, and `updated_at` moves on later writes (05:285-286). If the column holds the onset, the recording instant is stored nowhere.
2. **The settled text already chooses.** ADR-0038:35 says "when it was recorded" and :99-100 says "the operator's record time".
3. **"Refuse a future instant" breaks a settled rule.** ADR-0038:40: "The operator records and withdraws, and is never refused". It would also need:
   - a clock-skew tolerance (a local time typed as `Z` is hours off);
   - a `created_at` floor;
   - an error reason;
   - a CNF item.

   Server time needs none of these.
4. **"Default to the recording time when omitted" gives one column two meanings**, and no reader can tell which one it holds.
5. **r30 already dropped the field.** Its edits read "body `restricted` + `operator_ref`" (r30/synthesis.md:33). The member at 13:1211 is left over from the pre-ADR `disabled` body.
6. **Two of your cases don't separate the options.** A `WIR-24` replay returns the stored time either way, because the fingerprint covers the parsed body (04:209-210). A later provider reading renders the same either way.
7. **`WIR-50` points the other way but doesn't transfer.** It does take a supplied `observed_at` (13:1251). But `STO-47` stores that beside `updated_at` (05:1072-1073), and `WIR-50` computes "at the recording instant" (13:1271-1272), so it keeps two instants. Copying that here needs a fifth column, which reopens Q15's four.

## Edits

- **`WIR-47`, 13:1211-1215:**
  - Body becomes `{"status": "restricted", "operator_ref": "opref-…"}`; withdrawal becomes `{"status": "unknown"}`; delete the 409.
  - Add: "The record's time is the instant this write commits. The request carries none; a body supplying `observed_at` is `WIR-2`'s unknown field. A later record replaces the time and `operator_ref`."
- **13:1222-1223, render rule:** "`source` and `observed_at` are null exactly when `status` is `unknown`. Beside `restricted` they are the positive observation's (`provider_api` where both): the provider's last read time or the operator's record time, both on this system's clock."
- **ADR-0038:** a dated clarification rejecting the supplied instant, citing defects 1–4, under the owner's next Q number (Q16 is `ADR-0040`'s).
- **05:271-273:** four columns: `provider_restricted`, `provider_observed_at` (our read time), `operator_recorded_at` (commit instant), `operator_ref`. Repoint 05:287.
- **`DOM-27`, 01:333-335:** the new enum, plus "beside `restricted`, when this system read the flag or recorded the notice". Cite the 05 columns, not `STO-44`.
- **`CNF-233`:** the rendered time falls between the request and its response, and a replay returns it unchanged. A body carrying `observed_at` is `invalid_request`; that covers the ticket's case where observation and recording differ.
- **`CNF-250`:** reword per Q15, and add that an operator-sourced `observed_at` equals the commit time.
- **04:44:** delete "no driver can read".

**Formal:** no impact. `recordNetworkRestriction` is a bare `Verb` constructor (Admission.lean:139) with no body, time or 409 modelled, and ADR-0038:85 says "No Lean declaration encodes this." `check-all.sh` passed at `7d21478` (run unpiped, exit 0). I edited no tracked files; the review is also in `docs/research/panels-2026-10/r33/opus-review.md`.
