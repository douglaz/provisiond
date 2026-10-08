**Amend.** Keep "positive evidence only" and the merge. Replace the one triple and its write rule with two observations combined by OR, and delete `WIR-47`'s refusal rather than narrowing it.

**Choice 2 (one triple or two observations) decides the rest.** There are four possible states: no source, provider only, operator only, or both. A `status`+`source` triple can hold only three. The recommendation also contradicts itself. Its bullet says "a provider read showing a set flag writes `restricted` / `provider_api`" with no guard, while its headline, "neither source overwrites the other's positive", needs one. Both readings fail:

| Sequence | Triple, set-flag write guarded | Triple, unguarded | Two observations |
|---|---|---|---|
| (i) operator records → flag sets → flag clears | R/operator ✓ (the provider read is discarded) | the flag takes over; the clear writes `unknown` ✗ | R/operator ✓ |
| (ii) flag sets → operator records → flag clears → operator withdraws | the record is refused (409); the clear writes `unknown` while the lock persists ✗ | same ✗ | R → R → R/operator → `unknown` ✓ |
| (iii) flag sets → flag clears, whole-server lock persists | `unknown` | `unknown` | `unknown` (a limit of the source, not of storage) |
| (iv) operator records → flag sets → operator withdraws | `unknown` while the flag is set, until some refresh ✗ (the account sweep writes `state`, not this field, 01:131-132) | the withdrawal is refused on a record that silently vanished | R/provider ✓ |

**The two-observation shape is no larger, and has fewer rules.**
- **Columns:** still three. The driver's last read is a flag plus `observed_at`; the operator's record is a nullable `observed_at`. `source` is derived.
- **Writers:** four conditional writes and a 409 become two unconditional writers and one render rule.
- **Conformance:** the interleaving matrix becomes two assertions.
- **Second home:** my round-1 objection ("adds a second home") was wrong. `DOM-27`'s one home means the machine as against the case (01:321-324, 05:1106), and both observations sit on the machine row.
- **Possible further cut:** no reader uses a clear read, so storage could shrink to two nullable timestamps.

**Choice 1: merge.** Nothing branches on `restricted` vs `disabled`. `LDG-71` (12:565) covers any block, and `DOM-26`'s delete covers both. `CNF-228`'s `disabled` is only a fixture value. The agent's remedy is the same either way: stop reinstalling, then delete or wait. No stated property is lost. Sol's split between the operator's whole-server notice and the provider's per-IP flag survives as `source`. One casualty: 01:317-319 ("even a boolean would lose information a single enum value cannot carry") now contradicts the enum and needs rewriting.

**The refusal.** After the merge, the only thing an operator can record over a provider `restricted` is `restricted`. So the narrowed refusal refuses agreement, and that refusal is what breaks (ii). The only possible shadowing is a withdrawal hiding a set flag, and "withdraws only its own" already prevents it. Precedence existed because `none` could contradict a positive. Without `none`, positives just combine by OR.

**Framing error.** 05:1045-1066 is not this field's rationale. It is `provider_account_status`'s argument, borrowed from this field: "on `machines.network_restriction`'s reasoning" (05:1047-1049) and "the precedence rule therefore bites" (05:1060). `API-63`'s "exactly as `WIR-47` refuses" (04:1420) borrows the same way. Account status has values that really do exclude each other (`healthy`/`terminated`), so it must state its own reason. That edit is needed even under the brief's narrowing.

**Forgotten record: accept the cost, add nothing.**
- Hetzner's guideline says the account holder files the unlock request through Robot. The operator therefore performs the act that should prompt the withdrawal, and `WIR-47` should say so.
- The rendered `observed_at` already shows the record's age.
- Case closure is the wrong thing to clear it: an account-level action "opens no case at all" (01:324), and closing a case doesn't unlock anything.
- Clearing on the gone-write has no reader. `OPS-26` lists operations and episodes, not machines.

**What the recommendation breaks that round 1 did not name**
- 02:757-758 says the field refreshes with "the same cache semantics as every other machine field". A guarded provider write makes that false.
- 02:757 "MUST declare that it cannot" loses its only reader, which was `WIR-47`'s "where the driver reports this provider".
- 13:1153's example body `{"status": "disabled"}` is missing from the brief's list.
- 04:44's "record a restriction no driver can read" becomes false. `API-61` (04:1266) gains withdrawal.
- `SEC-41`: one operator record per machine has the same shape that 07:406 forbids for `API-58` suspension. It is a cost, not a violation.

**Edits**
- **`DOM-27` (01:310-319):** values `restricted | unknown`, stored as two observations and rendered `restricted` if either holds. Rewrite 317-319. At 01:313, cite 05:268-270 instead of `STO-44`.
- **`PRV-35` (02:756-775):** delete the declaration. Replace 773-775 with "combined, never ranked: a clear read removes nothing an operator recorded". Lower Robot's confidence, add Cloud's null address family, and leave `server.locked` unmapped.
- **`05-persistence.md`:** 268-270 becomes the two observations; 284 and 1111 follow. 1047-1066 states its own precedence reason.
- **`WIR-47`:**
  - 13:1153-1157: the example body becomes `restricted`; `unknown` withdraws only the operator's own record, once the unlock is granted; delete the 409.
  - 13:1164-1166: render from the set flag, else the operator's record, else the last read.
- **`WIR-11` (13:299):** the example becomes `"status": "unknown"`.
- **`04-api-contract.md`:** `API-63` (04:1419-1421) drops its `WIR-47` clause; also amend 04:44 and 04:1266.
- **`CNF-228`:** `restricted`, from either source.
- **`CNF-233`:** a driver with no signal renders `unknown`/null; a clear read never removes an operator record; a withdrawal never hides a set flag; no 409.
- **`CNF-250`:** unchanged.
- **Lean:** no change. `Verb.recordNetworkRestriction` appears only in classification tables.

`check-all.sh` exits 0 at `82e7f37`, before and after this review; no tracked files were changed.
