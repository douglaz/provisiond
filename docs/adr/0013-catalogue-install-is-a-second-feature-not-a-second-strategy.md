# Catalogue install is a second feature, not a second strategy

## Context

`ADR-0010` made DigitalOcean a launch driver partly to prove the driver contract abstracts
over more than one company's API house style. `F32` then asked whether that driver could
run the differentiator at all — putting a caller's own operating system on a machine — and
the answer looked like no.

**It is confirmed that DigitalOcean exposes no way to boot a droplet into its recovery
environment through the public API.** Two independent research passes agreed, one of them
grepping the published 3 MB OpenAPI specification for `recovery`, `rescue` and `iso` and
finding no occurrence in any droplet context. A live probe against a real account settled it:
`{"type":"enable_recovery"}` and `{"type":"recovery"}` both return
`404 "The specified action type is not available."` against an unlocked, active droplet.
That is positive evidence of absence rather than an argument from silence, which is what
`PRV-30`'s lesson demands.

So the rescue route is closed there. **The differentiator is not.** DigitalOcean imports a
custom image from a URL and builds a droplet from it, entirely through the public API, and a
live test walked the whole path: `POST /v2/images` → poll to `available` → rebuild →
`DELETE`. The same test destroyed the documented obstacle: DigitalOcean's product pages say a
rebuild image must be "from the same operating system family", and the API does not enforce
it — one droplet went Ubuntu → Fedora → a custom Alpine image in under two minutes, every
action reporting `completed`.

That leaves the question this ADR answers. The customer's intent is identical on both
providers — *here is my operating system, put it on my machine* — but what actually happens
is not.

| | Rescue install | Catalogue install |
|---|---|---|
| Whose bytes reach the disk | the customer's, verbatim | the provider's conversion of them |
| Digest verified by provisiond | yes, on the rescue host before writing | no — the import API has no checksum field |
| Guest requirements | none; any bootloader, any filesystem | BIOS, ext3/ext4, cloud-init with `ConfigDrive` before `NoCloud` |
| Disk layout | caller-controlled: partitions, RAID, LVM | whatever was baked into the image |
| If it goes wrong | boot rescue and fix it | there is no way back in |

*`sshd` stood in that last cell until 2026-09-02, and it contradicted this ADR's own decision three
sections down — "a custom image may legitimately ship no `sshd` at all", which is why provisiond
makes no reachability probe. The table was reproducing the provider's published *recommendations*
as though they were enforced preconditions. They are neither: nothing in the import path checks for
an SSH daemon, and an image without one is a supported outcome whose consequence is that the
customer, not provisiond, decides whether the machine works. What the offer relays is prose
(`WIR-30`'s `guest_requirements`), and prose is exactly where a recommendation belongs.*

## Decision

**Catalogue install is a separate capability from rescue install, with its own name, its own
requirements and its own conformance items.** It is not `rootfs_via_rescue` and `raw_disk`
with a third sibling; the promises differ, and one strategy list spanning both would let an
agent send a UEFI image to a provider that cannot boot one and read the refusal as a bug.

Seven decisions follow from it.

**The operator re-hosts the image and verifies it in transit.** DigitalOcean will not accept
an upload; it fetches a URL. Forwarding the caller's own signed URL would disclose a
credential (`SEC-21`) to a third party. So provisiond fetches the image, verifies the
`sha256` as it streams, and serves DigitalOcean a copy from operator-controlled immutable
storage (`RSC-30`). **`RSC-1` narrows to the rescue strategies** — "the control plane never
holds image bytes" was written for a path where the target machine does its own fetching, and
on this path there is no rescue host to do it. Without the re-host, catalogue install has no
integrity story at all.

**Both copies are purged on settle and on entry to `needs_reconciliation`.** This is
`ADR-0005` applied to a new object rather than a new rule invented for one, exactly as
`STO-42` did for abuse statements. A requeue carries a fresh payload (`OPS-34`) and
re-uploads.

**An orphaned image is found by the account sweep and deleted, not reported.** Each import
carries the operation's correlator as a provider-side tag; `OPS-32` extends to compare
imported images against live operations. The asymmetry with machines is deliberate: an
unclaimed machine is a customer's running server and goes to an operator, an unclaimed image
is caller data we are obliged to destroy. *A live test found that `DELETE /v2/images/{id}` is
not naively idempotent — the second call returns `422 "Can not delete an already deleted
image."` and never decays to 404, while `GET` on the same id at the same instant returns
404 — so the sweep must treat that rejection as success.*

**Success means the provider completed the rebuild, and nothing more.** provisiond does not
probe the machine for reachability, because a custom image may legitimately ship no `sshd` at
all — a database appliance, a game server, a mesh node — and requiring one would be the
lowest-common-denominator reduction `OVR-1` forbids. Verifying the machine works is the
customer's check.

**The machine records how it was last installed.** `last_install` carries the strategy,
whether provisiond verified the bytes, and when. It lives on the machine because `STO-14`
deletes the operation that knows, and the machine outlives it — the same reason `OPS-39`'s
trigger id had to move onto the machine row.

**The import happens outside the machine lock, and is bounded.** DigitalOcean publishes no
import-time figure. Holding `OPS-8`'s lock across an unbounded provider queue would idle a
billing machine, delay any cancellation queued behind it, and — because the 2026-08-15
amendment put the worst-case machine-lock hold inside `wind_down_cost` — inflate the reserve
every machine in the fleet is sized against. The import touches no machine; only the
switch-over needs the lock.

**provisiond measures caller images and never interprets them.** It counts bytes against a
declared maximum and hashes them. It does not parse the content — not the partition table,
not the image format, not the filesystem. Format and compression stay caller-declared and
unverified, exactly as `WIR-20` already treats them. The reason is written down so it is not
helpfully optimised away later: a parser for hostile binary from an anonymous caller, inside
the process that holds every provider credential and root on every customer machine, is the
worst possible place to put one, and `OVR-10a` calls that process's boundary the only
structural defence left.

## Consequences

- **The differentiator exists on both companies, by different means.** `ADR-0010`'s framing
  survives with a caveat rather than a correction: DigitalOcean cannot do rescue-based
  installation, and can do bring-your-own-image. What is Hetzner-only is *arbitrary* images —
  UEFI, xfs/btrfs/zfs roots, no cloud-init, byte-level control, chosen disk layout, and a
  verified digest.
- **A customer's image whose guest requirements are unmet produces a running, billing,
  unreachable machine with no remedy but delete.** That is disclosed, not solved. It is the
  same posture `RSC-29` takes toward raw-disk digest verification completing after the
  overwrite has begun, and it is the price of the provider owning the write.
- **A customer's operating system is briefly visible account-wide at the provider.** Custom
  images are not a Projects resource, so DigitalOcean offers no scoping below the team. No
  caller can reference another tenant's image — callers supply URLs, never image ids — and
  the window is bounded by the purge. Accepted and recorded, in the manner of `SEC-41`.
- **The control plane is now in the data path for up to 100 GB per install.** That is
  bandwidth and storage nobody had budgeted, and it is the direct cost of keeping a digest
  check.
- **`LDG-25` covers the money, and as of 2026-09-02 it says so.** Catalogue install is a privileged
  operation: free in v1, metered from the first release, and the units to meter are the transferred
  bytes and the storage-seconds of the operator's re-hosted copy. *This bullet said `LDG-25`
  "already covers" them while that requirement named no unit at all — it said only that privileged
  operations "MUST be metered", which is a requirement nobody can build against and nobody can test.
  The units are now in the requirement, which is where a developer looks.*

## Rejected

**One promise with two strategies.** The neatest option, and it was the standing
recommendation: keep "bring your own OS image" as one feature and let the offer's
`install_strategies` say which mechanism applies. Rejected because the two make different
promises about verification, layout and recoverability, and a single name would let an agent
believe its bytes were checked when nothing checked them.

**Forwarding the caller's signed URL to the provider.** Free, and it keeps the control plane
out of the data path. Rejected because it discloses a credential to a third party with no
documented retention behaviour, and because it abandons digest verification entirely. *One of
the two original arguments for re-hosting turned out to be wrong: a live test imported a URL
carrying a query string without difficulty, so the fear that signed URLs would break the
importer is unfounded. The decision stands on integrity, not on that.*

**Probing the machine for reachability before settling.** Attractive — it converts a silent
brick into an honest failure. Rejected because it presumes the image runs an SSH daemon, and
a custom image need not.

**Inspecting the image before importing it.** Newly possible once the operator holds the
bytes, and it would fail bad images before anything is bought. Rejected on the same ground
`WIR-43` stores statements uninspected: it is unreliable, untestable, and here it also means
running a parser over attacker-controlled binary inside the credential-holding process.

**A DigitalOcean team per tenant.** The only real isolation boundary the provider offers.
Rejected because team creation is not a self-serve API act, and `ADR-0002` chose enrolment
with no operator step — a team per anonymous stranger is not operable.

**Re-issuing a delete as a probe.** When a delete's reply is lost, sending it again is the
only evidence source that answers rather than waits, and unlike a create the worst case of
doing it twice is the outcome you wanted. Rejected: it rests on the provider never reusing an
identifier, which is unverified for every launch provider, and if that is ever false the probe
destroys a stranger's machine. `OPS-12`'s value is that it has no exceptions to reason about.
