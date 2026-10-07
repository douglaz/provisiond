# A network restriction is positive evidence from either source

**Status:** accepted (2026-10-07, owner decision Q7 of the provider-research grill).

## Context

`DOM-27` puts a network restriction on the machine (`none | restricted | disabled | unknown`), so
that "The signal's job is to **stop** a remediation loop". An agent whose connections time out on a
blocked machine should not reset, rescue and reinstall it. `PRV-35` made the provider authoritative
where a driver reports, and `WIR-47` refused an operator's record "where the driver reports this
provider".

The provider research (`docs/research/provider-verify-2026-10.md` V1, V6, V15) showed that no launch
provider can establish `none`:
- Hetzner Cloud's `blocked` is per address family, and a family can be `null`.
- Robot's `locked` is per address, documented only as "Status of locking", while Hetzner also locks
  "entire servers".
- DigitalOcean exposes nothing.

So the set could show `none` on a locked machine and then refuse the operator who had Hetzner's lock
notice in hand. `WIR-11`'s example already renders `{"status": "none", "source": "provider_api"}`.
The harm lands hardest where a rebuild works without the network, on Cloud and DigitalOcean,
because there a reinstall loop wipes the disk.

Two panels decided it (`/var/tmp/provisiond-panel-r23/`, three readers;
`/var/tmp/provisiond-panel-r24/`, four readers, unanimous on every point below).

## Decision

1. **The status is `restricted | unknown`.** `none` is deleted, because only positive evidence
   stops a loop and no source can support the negative. `restricted` and `disabled` merge into one
   value, because no reader or remedy distinguishes them.
2. **Two observations sit side by side on the machine, and either makes it `restricted`.** The
   provider's last reading (whether a flag is set, and when it was read) and the operator's record
   (when it was recorded, and the notice it came from) are separate columns. Each source writes only
   its own. The view is `restricted` if either is positive and `unknown` otherwise. Its `source` is
   the positive one (`provider_api` where both are) and its `observed_at` is that source's. Nothing is
   ranked: a clear reading removes nothing an operator recorded, and an operator's withdrawal hides no
   set flag.
3. **The operator records and withdraws, and is never refused.** With `none` gone, an operator's value
   can only agree with the provider's or add to it. A record carries an `operator_ref` to the notice
   it came from. A withdrawal clears only the operator's own record, after the unlock is granted.

This is still one home. `DOM-27` places the fact on the machine as against the case. A machine can
have several cases open, and an account-level action opens none. Both observations sit on the
machine row, as `state` and `state_observed_at` already do.

## Considered and rejected

- **A per-driver declaration of whether its flag can establish `none`.** Every launch driver would
  declare that it cannot, and nothing would read the declaration.
- **One stored status with a write rule** (put to the owner, then reviewed). Four states do not fit
  three slots: nothing restricted, provider only, operator only, both.
  - A provider flag that set and then cleared erased an operator's notice.
  - A refusal while the flag was set kept the notice from being stored anywhere.
  - A withdrawal showed `unknown` while the flag was set.
- **Downgrading the confidence text only.** The operator refusal stays, and so does the loop.
- **Operator notices only.** It discards Cloud's documented abuse flag, which is a true positive.

## Consequences

- Accepted cost: a record nobody withdraws stays `restricted` after the provider unlocks, and a stale
  `restricted` invites the customer to delete a working machine, because delete is the remedy
  `DOM-26` names. The field is as fresh as the operator's response. The rendered `observed_at` shows
  the record's age, and `operator_ref` gives the follow-up an owner. Neither case closure nor a
  gone-write clears a record: closing a case does not unlock anything, and a gone machine needs no
  warning.
- An account-wide lock (`SEC-41`) becomes one operator record per machine. That is a cost of this
  shape, not a breach of the rule against enumerating machines by hand, which governs suspension.
- A whole-server lock the provider shows nowhere stays `unknown` until the operator records it. That
  is a limit of the source.
- Cloud's `server.locked` stays unmapped until a written answer from Hetzner says what it means. No
  account action can make Hetzner lock a server. Robot's `locked` mapping is kept, pending
  verification.
- Edits owed:
  - `DOM-27`: the enum, the two observations, its sentence that "even a boolean would lose
    information", and its citation of the columns.
  - `PRV-35`: positives only; its declaration and precedence sentences deleted; its per-provider
    rows.
  - `05-persistence.md`'s machine columns; `account_status`'s borrowed reasoning restated on its own
    ground; `STO-44`'s "true now".
  - `WIR-47`, `WIR-11`'s example, `WIR-43`'s fixture, `API-61`, `API-63`'s "exactly as", and the
    route table's "no driver can read".
  - `CNF-228`, `CNF-233` and interleaving coverage.
  - No Lean declaration encodes this.
