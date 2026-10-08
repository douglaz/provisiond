# Panel r23 synthesis — what a provider's network-restriction flag can establish (PRV-35), 2026-10-07

Readers: sol, astra (codex xhigh), opus (claude xhigh). fable FAILED: weekly Fable quota 100%
(resets 2026-10-08 15:00 UTC). Clones at 82e7f37. Citations verified against the files.

## Verdict: none of (a)/(b)/(c) as offered — 3–0 for "positive evidence only; delete `none`".

- DOM-27: "The signal's job is to **stop** a remediation loop" (01:329). A stop signal needs only
  positive values; `none` is a "go" value no requirement branches on and no launch source supports:
  Robot `locked` is "Status of locking" with no server field; Cloud `blocked` is per IP family (a
  family may be null; Floating/Primary IPs carry their own); DigitalOcean exposes nothing.
- Deleting `none` is smaller than (a)'s per-driver "can establish none" declaration (every launch
  driver would set it false; a future driver that could support `none` and reports `unknown` fails
  safe). It makes "`unknown` MUST NOT be rendered as `none`" true by construction.
- The set writes `none` itself today: WIR-11's example (13:299) shows `{"status": "none", "source":
  "provider_api"}` on hetzner-cloud-1.

## Splits

- Storage: opus — one triple + a write rule ("neither source overwrites the other's positive, and
  each withdraws only its own"; a clear flag writes `unknown` only over the driver's own value or
  `unknown`; the operator withdraws by recording `unknown`); two triples "adds a second home".
  sol, astra — two per-source observations on the machine, the view derived ("different
  observations, not competing copies of one fact").
- `restricted` vs `disabled`: astra — collapse (no reader branches on it); opus — define by coverage
  or collapse (one blocked family fully blocks a single-family machine: V1's null family, RSC-45's
  Robot default without IPv4); sol — keep, defined (restricted = confirmed affected route; disabled =
  evidence the machine's networking is disabled). CNF-228 asserts `disabled`.

## Defects in my framing (verified)

1. "Every IP reads `locked: false`" is unobserved; V6 shows only that no server-level field exists.
   The argument survives: no source says a clear flag means unlocked. (all)
2. The harm story picked the wrong provider: Robot has no native rebuild (08:37) and its installs go
   over SSH (06:508), so a Robot install on a locked server fails before writing. The disk-wipe loop
   needs a network-free rebuild — Cloud and DigitalOcean. (opus)
3. "A set flag yields `restricted`" maps to an undefined term; nothing defines restricted vs disabled.
4. Cloud's `server.locked` cannot be settled by a live batch (no account action makes Hetzner lock a
   server) — it is a written inquiry; leave it unmapped like DigitalOcean's `locked`. (opus)
5. SEC-41 cost: an account-wide lock becomes one operator record per machine — the hand enumeration
   07:406 forbids for suspension; state the cost. (opus)

## Edits (union)

DOM-27 (enum; its STO-44 citation for the observed time is wrong → 05:268-270), PRV-35 (positives
only; the precedence sentence; Robot row confidence; Cloud row's null family and server.locked),
05:268-270 and the two-homes rationale 05:1045-1066, WIR-47 (13:1153-1166; the refusal narrowed),
WIR-11's example (13:299), API-63's "exactly as WIR-47 refuses" (04:1420), CNF-233, CNF-228,
transition coverage (interleaving, withdrawal, stale observation). Lean: none (no declaration
encodes DOM-27, PRV-35 or the 409; Verb.recordNetworkRestriction appears only in classification
tables).
