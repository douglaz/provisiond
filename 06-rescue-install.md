# 06 — Rescue mode and image installation

The rescue engine is generic (`OVR-8`). It receives a provider driver, drives the
provider through the rescue lifecycle, and installs an image over SSH.

## Sequence

1. Generate a single-use Ed25519 keypair scoped to this one operation.
2. Ask the driver to activate rescue and initiate the reboot (`PRV-15`).
3. Poll the driver's session refresh (`PRV-19`) until host-key material is available or
   the caller's policy resolves the question.
4. Establish the host-key trust decision, and refuse to connect if it cannot be made.
5. Wait for rescue SSH to answer, then collect a preflight report (block devices, UEFI
   presence).
6. Download the image *inside the rescue environment*.
7. Verify the caller-supplied digest.
8. Install: run the provider's OS installer against a generated layout config, or stream
   and decompress a raw image onto a named block device.
9. Ask the driver to exit rescue and reset into the installed system (`PRV-21`).
10. Remove any temporary provider-side credential.

**RSC-1** The image MUST be downloaded by the rescue host, never by the control plane.
The control plane never holds image bytes.

**RSC-2** The engine MUST NOT contain provider conditionals. Everything provider-specific
lives behind the driver interface.

## Host-key trust

This is the security-critical decision in the whole workflow. The rescue environment
holds a credential that grants root on the customer's machine.

**RSC-3** The engine MUST NOT connect unless one of these is true:

| Condition | Behaviour |
|---|---|
| Caller supplied expected host keys | Pin exactly those. Strict checking. |
| Driver published host keys and caller supplied none | Pin the driver's. Strict checking. |
| Caller supplied keys *and* driver published keys | They MUST overlap. No overlap is an `integrity` failure, and the engine MUST abort before connecting. |
| Neither, and the caller explicitly opted into first-use trust | Accept-new. Permitted, but it is a documented downgrade. |
| Neither, and no explicit opt-in | Abort with an `integrity` error. |

**RSC-4** Caller-supplied keys and the first-use-trust opt-in MUST be mutually exclusive
in the request (`API-13`).

**RSC-5** A pinned connection MUST NEVER be silently downgraded to first-use trust — not
on retry, not on timeout, not when the driver returns an empty key set later.

**RSC-6** Host keys MUST be canonicalized before comparison: parse out the algorithm and
the base64 blob, discard comments and any leading host pattern, and compare the
`algorithm base64` pair. Comparing raw strings makes a formatting difference look like an
attack, and vice versa.

**RSC-7** The known-hosts entry MUST be written with the correct host/port form for
non-default ports and for literal IPv6 addresses.

**RSC-8** The global system known-hosts file MUST be disabled for these connections, and
the per-operation known-hosts file MUST live in a private temporary directory that
survives for the whole operation.

**RSC-9** The deadline for waiting on driver-published host keys MUST be derived from the
boot timeout, not from an unrelated hard-coded constant. Bare metal routinely takes
several minutes to POST and reach a rescue environment, and a provider that only
publishes keys after boot (`PRV-19`) will otherwise fail every pinned install. See
`DEF-5`.

## Credentials

**RSC-10** The rescue keypair MUST be generated per operation and MUST NOT be reused.

**RSC-11** A password-based rescue credential MUST be passed to the SSH client through
the environment or a file descriptor, never through the command line, where it is visible
in the process table.

**RSC-12** The installed system MUST NOT inherit the ephemeral rescue credential. Where
the provider's installer offers to copy rescue authorized keys into the target, the
generated configuration MUST explicitly disable that.

**RSC-13** A rootfs install MUST require at least one caller-supplied authorized key for
the installed system, precisely because of `RSC-12` — otherwise the result is a machine
nobody can reach.

**RSC-14** A raw-disk install MUST reject caller-supplied authorized keys. The filesystem
layout inside an arbitrary raw image is unknown, so keys cannot be injected generically.
Callers bake access into the image or use a post-install step that mounts it
deliberately. Silently ignoring the keys would be worse.

## Remote command transport

**RSC-15** Every caller-controlled value that reaches the rescue shell — URLs, digests,
hostnames, device paths, key material, post-install scripts, installer configuration —
MUST be transported base64-encoded and decoded on the remote side. No caller value may be
interpolated into shell text directly, even after validation.

**RSC-16** The remote script MUST run with errexit, nounset, and pipefail set, and with a
restrictive umask.

**RSC-17** Remote downloads MUST restrict the allowed protocols, including on redirect,
to exactly the scheme the URL declared. A redirect from `https` to `http`, or to a
non-HTTP protocol handler, MUST be refused by the fetch tool itself and not merely by
prior URL validation.

## Failure handling

**RSC-18** The caller MUST be able to choose between exiting rescue on failure and being
left in rescue for debugging. The default MUST be to exit.

**RSC-19** Whenever rescue exit is uncertain — activation failed ambiguously, cleanup
failed, or the caller asked to be left in rescue — the private key MUST be persisted
under a configured recovery directory, and its path MUST be reported in the operation's
error details along with the rescue address and port.

**RSC-20** The recovery directory MUST be absolute, MUST be created with owner-only
permissions, and MUST live on encrypted storage (`STO-15`). Its contents are root
credentials for customer machines.

**RSC-21** Persisted recovery keys MUST be inventoried and MUST be removable by an
operator once recovery is complete. There MUST be a documented cleanup procedure; keys
accumulating in a directory forever is a slow leak of live credentials.

## Rootfs-archive installation

Applies to providers whose rescue environment ships an OS installer that consumes a root
filesystem archive.

**RSC-22** The engine MUST generate the installer's configuration from a structured
layout: drives, software-RAID flag and level, partitions (mountpoint, filesystem, size),
hostname, bootloader, image path, authorized-keys source, and an optional post-install
script.

**RSC-23** Layout validation MUST enforce: at least one drive; at least one partition;
every drive a simple path under the device directory with a restricted character set; no
whitespace, CR, LF, or NUL in any config field; a RAID level from the supported set when
software RAID is enabled.

**RSC-24** Supported archive formats and their canonical extensions MUST be declared, and
the downloaded file MUST be given the extension matching the declared format — installers
routinely dispatch on it.

**RSC-25** The digest MUST be verified after download and *before* the installer runs.
This path is safe: nothing has been written to the target disk yet.

## Raw-disk installation

**RSC-26** **AMENDED — naming a device is not enough, because the name is not stable.** The
target block device MUST be named explicitly by the caller and the engine MUST NOT guess one.
**But `/dev/sda` is an ordering artefact that can differ across boots, between the rescue
environment and the installed system, and after any hardware change** — so a caller that reads an
inventory today and installs tomorrow can name a device that has since become a different disk.
On a two-disk machine that is the customer's data, destroyed, with every requirement in this
document satisfied.

**The target MUST therefore be bound to identity, not to a name:**

- **`RSC-38` makes preflight its own non-destructive operation** returning the block-device
  inventory with **stable identifiers** — serial and WWN — plus an opaque `inventory_fingerprint`
  over the whole device set.
- **An install request MUST carry both** the chosen device's stable identifier and the
  `inventory_fingerprint` it was chosen from (`WIR-20`).
- **The worker MUST re-read the inventory immediately before any disk I/O** and abort with
  `integrity` — before writing a single byte — if the fingerprint differs, if the named identifier
  is absent, or if the inventory fails to parse (`RSC-34` keeps the raw capture).

`RSC-27`'s path validation still applies to whatever device path the identifier resolves to at
write time. **The identifier is authoritative; the path is derived.**

**An identifier that does not resolve to exactly one device MUST abort `integrity` before any
write.** Zero matches is the stale-inventory case; **more than one is the dangerous case** —
duplicate or empty serials are real on consumer and virtualised disks, and "pick the first" there
is the same coin-flip over which disk gets destroyed that naming `/dev/sda` was. The driver MUST
prefer WWN where the provider exposes it and MUST declare an offer unsellable for `raw_disk` and
`rootfs_via_rescue` where no per-device unique identifier is available at all.

**This binds every strategy that names a disk, not only `raw_disk`.** `RSC-22`'s installer layout
carries a `drives` list, and those are device names with exactly the same instability — a rootfs
install that partitions `/dev/sda` after the ordering shifted destroys the same customer data, and
scoping the rule to raw-disk would have left the launch product's primary install path on the
unstable identifier. Every caller-supplied disk reference MUST be a stable identifier checked
against the same `inventory_fingerprint`.

**RSC-38** **Preflight is a first-class read-only operation.** It boots rescue, collects the
`RSC-33` report, and returns it without writing anything. It exists because the previous design
gave a caller no way to see the inventory *before* committing to a destructive write — the
information arrived attached to the result of the operation that had already destroyed the disk.
Preflight MUST be free of side effects beyond entering and exiting rescue, and its report MUST
carry the same `inventory_fingerprint` an install will be checked against.

**RSC-27** The target MUST be validated as a simple path under the device directory, and
the remote script MUST additionally verify at runtime that it is a block device.

**RSC-28** The stream MUST be digested while it is decompressed and written, so the image
is read once.

**RSC-29** **Digest verification for this strategy completes only after data has begun
overwriting the target disk.** This is inherent to single-pass streaming and MUST be
documented in the API. A mismatch leaves the disk partially or wholly overwritten; the
operation MUST fail with an `integrity` error and route to reconciliation (`OPS-11`).

**RSC-30** Because of `RSC-29`, the deployment MUST host custom images on controlled,
immutable storage — defined (`F18`) as storage where the bytes behind a URL cannot change after
the digest is computed: a content-addressed store, or object storage with versioning or object
lock where the URL pins the version. A mutable path behind a signed URL fails this even though
the URL is signed. The caller SHOULD verify the digest independently before
submitting. An implementation MAY offer a two-pass mode (download to scratch, verify,
then write) for hosts with sufficient scratch space, and if it does, that mode SHOULD be
the default.

**RSC-31** Optional post-write partition growth MUST be one-based and MUST reject zero.
It MUST be best-effort and MUST NOT fail the operation if the growth tool is absent.

**RSC-32** After writing, buffers MUST be flushed and the partition table re-read before
any post-install step runs.

## Preflight

**RSC-33** Before writing anything, the engine MUST collect a machine-readable preflight
report — at minimum the block-device inventory (name, path, size, type, model, serial)
and whether the firmware is UEFI — and MUST attach it to the operation result. This is
the record that tells an operator afterwards which disk was actually overwritten.

**RSC-34** A preflight report that fails to parse MUST be captured raw rather than
discarded.

## Timeouts

**RSC-35** Three timeouts MUST be configurable and MUST be validated at startup: boot
(waiting for rescue SSH), command (a single remote command), and poll interval. Sensible
defaults: 10 minutes, 90 minutes, 5 seconds.

**RSC-36** The command timeout must accommodate a full image write over the provider's
network. It is normal for it to be an order of magnitude larger than the boot timeout.

**RSC-37** The operation lease (`OPS-7`) is unrelated to these and MUST be renewed by
heartbeat throughout, so a 90-minute install does not lose its lease at minute three.
