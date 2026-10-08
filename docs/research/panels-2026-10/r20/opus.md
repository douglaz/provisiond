**Verdict: named other.** Take (a), but key it on acceptance (a 2xx answer to the request that carries the correlator) instead of "sent", and apply it to `OPS-11`'s whole last row.

**Why.** The set already decides on acceptance. `LDG-39` debits "only when the order is known to have landed" (12:1073), with the rows "Order accepted by the provider" and "Deterministic rejection before acceptance" (12:1080-1081). `OPS-27` enters on "the provider accepting the order in its reply" (03:469). Only `OPS-11` keys on the kind of the last failed request, so an accepted create settles `failed` and falls between `LDG-39`'s rows.

"Sent" adds nothing on transport death, which is already `network`/`timeout` (03:251). It adds only a 4xx answer to the order itself, the one place where "did not act" is true. (b) misses Robot (defect 2). (c) is what `OPS-45` refuses for create (03:1169-1180). Driver reclassification misreports the kind and misses the engine's own search.

**Q1: the defect is real.**
- **Cloud.** `POST /servers` returns 201. The settle-time search gets a 429, which maps to `rate_limited` (02:32-35). That kind is off the ambiguity list (03:249-257), so the create settles `failed` (03:227) and `LDG-32` releases (12:299).
- **Robot.** The order is accepted. The poll allows "500 requests per 1 hour" and throttles with `403 RATE_LIMIT_EXCEEDED` (Robot docs, read 2026-10-06), which is a 4xx, so `failed`. `PRV-11` covers only a timeout (02:113-116).
- **Afterwards.** `OPS-33` searches only while the operation "remains open" (03:1383), and `OPS-36` follows from it. `OPS-32` reports, "MUST NOT be auto-attached" (03:1347).
- **Cost and access.** The operator pays, with no bound, until a human acts. The tenant has root through its mandatory key (02:90). On Cloud, user data (02:85) can report the machine's address back.

**Defects in the framing**
1. "The worker polls the action": nothing requires it. The mandated post-accept read is `OPS-27`'s settle-time search (03:458-460), on every create. Its zero-result branch has no outcome, which is T1 inside `PRV-36`'s window with no 4xx at all.
2. `PRV-5` gives `rate_limited` only "where the status warrants it" (02:33). Robot's throttle is a 403, which `F48` still calls unverified (11:170).
3. "An attacker drained it": `ADR-0034` makes that expensive. It says "Not covered here: a throttle that reaches an admitted operation after its mutating request was sent" (0034:72). Robot's poll limit, which the ADR also excludes, and a 401 after rotation need no attacker.
4. "The other kinds have `OPS-45`'s marker": a set marker forces nothing. "Everything else follows `OPS-11`'s classification" (03:1221-1222), and `classify` ignores markers there (Tables.lean:179-181). `OPS-48` then calls that `failed` "the provider did not act" (03:1029).
5. "Sent": a create sends up to three mutating requests: the `PRV-9` key upload, the order and the key delete (02:94). The one that matters is already named: "written in the same request that performs the mutation" (02:595).
6. `CNF-31a` requires the defect: "A create failing with a provider 4xx is `failed`" (10:172).

**Q2.** Under "sent", every refused order becomes `needs_reconciliation`: a sold-out product, a placement refusal or a throttled order. It holds the commitment and fee (12:1082) through the negative window (03:434), which on Robot is unbounded (03:1395), and it spends `ADR-0034`'s reserve. On Robot's standard channel (03:1386-1391) each refusal is an operator page, up to 20 a day per account (`PRV-40`), free to the attacker. Under acceptance, a reconciliation needs a placed order, which is a machine the attacker pays for. There is no collision with `ADR-0014`/`ADR-0017`, `OPS-36`, `WIR-35` or `LDG-39`.

**Other kinds**
- **Release attachment:** the `DELETE` returns 2xx, a read returns 4xx, and the release settles `failed` with `released_at` null. The customer is metered for a deleted volume and the commitment stays open (12:297-299). `OPS-32` never sweeps attachments (03:1365-1378). Acceptance moves this into resolution, but only "a successful release writes the row's `released_at`" (02:438).
- **Delete:** the `DELETE` returns 2xx, then `PRV-45`'s listing (02:427-429) is throttled, so the delete settles `failed`. The sweep later records the machine gone. But only `PRV-45` writes `machine_attachments` (05:322-337), so `STO-18` (05:338) holds nothing back and `LDG-32` closes while a volume bills the operator. This predates T1.
- **Power and reverse-DNS:** no money moves.

**Q6: the strongest "don't build".** `ADR-0034` prices a Cloud drain at about 60 machines, leaving a sweep report and a machine-hour. It fails because Robot's poll limit, rotation and visibility lag need no attacker, nothing deletes the orphan, and the tenant keeps root.

**Edits**
- **`OPS-11`** (03:227, 249-257): the last row becomes "ambiguous **or accepted**". Install is untouched (`deterministic_after_write_failed`).
- **`PRV-5`:** every error a driver call returns carries `details.accepted`. Without it, the driver reports `internal`, which is already ambiguous. That respects "There is no implicit default", and admission-only kinds never reach a driver. Map Robot's 403 to `rate_limited`.
- **`PRV-11`:** covers any failure after acceptance.
- **`OPS-27`** (03:458-460): after acceptance, anything but exactly one resource gives `needs_reconciliation`.
- **`CNF-31a`** and **`F48`**.
- **Resolution:** a resolved-`applied` release writes `released_at`. Separately, `PRV-45` runs on every gone path.

**Formal edits** (`OPS-11` has no render marker)
- In `Tables.lean`: `Failure` (92) gains `accepted`, `Rules` (109-120) gains `acceptedRow`, and `mutationRow`/`classify` (161, 179-181) change.
- New theorem: an accepted last-row failure is never `failed`.
- The four-field constructors break `classify_total` (187), `admission_only_failed` (197, which needs `accepted = false`), `install_marker_directions` and Witnesses.lean:2271-2283.
