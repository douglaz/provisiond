# Panel brief: what a provider's network-restriction flag can establish (`PRV-35`), 2026-10-07

You are one of four independent reviewers. The working directory is a throwaway clone of the
specification repository `provisiond-spec` at commit `82e7f37` (numbered Markdown requirements,
ADRs in `docs/adr/`, glossary `CONTEXT.md`, Lean in `tools/formal/`, beads readable with
`br show <id>` if `br` is on PATH). Read `AGENTS.md` first. Do not edit tracked files; you may write
scratch files, run the gates, and fetch public provider documentation. Search the Markdown with
whitespace normalised. This owner repeatedly shows my framing wrong with a first-principles question
and dissolves machinery rather than tuning it; check this framing too, and verify every fact I state
before relying on it.

## Background

- `DOM-27` (`01-domain-model.md:310`): a machine's network restriction is `none | restricted |
  disabled | unknown` with a source `provider_api | operator_notice` and an observed time; its job is
  to stop an agent's reset/rescue/install loop on a machine whose network the provider blocked.
- `PRV-35` (`02-provider-contract.md:756-778`): a driver MUST report the restriction where the
  provider exposes one; "`unknown` MUST NOT be rendered as `none`"; "`none` is a claim, and only an
  observation can support it"; "Where a driver *does* report, the provider is authoritative and an
  operator entry is the fallback for a provider that cannot answer". Its table lists Hetzner Cloud
  (`public_net.ipv4/ipv6.blocked`), Robot (`locked` on each IP and subnet, "documented; high") and
  DigitalOcean (do not map `locked`).
- `WIR-47` (`13-wire-contract.md`): the operator's `record-network-restriction` "MUST be refused with
  `409` `conflict`, `details.reason: "state"`, where the driver reports this provider".
- `05-persistence.md:268-270`: the columns; status defaults to `unknown`.
- Research note `docs/research/provider-verify-2026-10.md` V1, V6, V14, V15. V6: Robot's IP/subnet
  `locked` is documented only as "Status of locking"; there is no server-level lock field; Hetzner's
  locking guideline says locks can apply to "entire servers or storage boxes" and include
  "Non-payment". V1: Cloud's `blocked` is documented per family ("Whether the IP is blocked by our
  abuse department"); `server.locked` is "True if Server has been locked and is not available to
  user"; error `423 locked` means "there is already an Action running".

## The story put to the owner

Hetzner locks a whole Robot server. Every IP reads `locked: false`, so the driver reports `none`
from `provider_api`. The operator receives the notice and records `disabled`; `WIR-47` refuses it
with `409` because the driver reports this provider. The tenant's agent sees `none`, its connections
time out, and it reinstalls in a loop — the loop `DOM-27` exists to stop.

## Options

- **(a) A signal can be one-sided.** The driver declares whether its flag can establish `none`; none
  of the three launch drivers can. A set flag yields `restricted` (`provider_api`); a clear flag
  yields `unknown`, never `none`. Provider authority covers what the provider showed: an operator may
  record over `unknown`, and a later clear flag does not erase an operator's record; only the operator
  clears it. Cloud's `server.locked` meaning becomes a live-batch `[verify]` item.
- **(b)** Downgrade Robot's confidence text only (the research note's suggestion).
- **(c)** Drop provider signals; operator notices only.

My recommendation: (a).

## What I want from you

1. **Is the story true in this set?** Trace a whole-server Robot lock and a Cloud abuse block through
   `PRV-35`, `DOM-27`, `WIR-47`, `STO-*` columns, the machine view (`WIR-*`), `CNF-250` and any
   conformance item on `PRV-35`. Is `none` ever written today, and by whom?
2. **Where is (a) wrong?** What should a clear flag and an operator record each do over time — when
   does an operator-recorded restriction end, can the operator ever record `none`, what does a set
   flag do to an operator's `disabled` (provider says `restricted` per family)? Does "only the
   operator clears it" leave a stale `disabled` forever on a machine the provider unlocked? Does (a)
   break `DOM-7`'s exclusion, `LDG-71`, `SEC-41`–`SEC-45`, abuse cases (`STO-39`), or the "two homes"
   reasoning at `05-persistence.md:1045-1065`?
3. **Is `none` worth keeping at all?** If no launch driver can establish it, does any reader need it?
   Would deleting `none` from the enum be smaller than a one-sided declaration?
4. **The `disabled` vs `restricted` split and per-family data** (V1: a `null` family, Floating IPs
   with their own `blocked`): does the enum carry what Cloud reports, and does (a) need it to?
5. **Third shapes**, and **the strongest "don't build this"**.
6. **Formal layer:** any declaration encoding `DOM-27`, `PRV-35` or `WIR-47`'s refusal.

## Output

At most 900 words, no preamble: verdict (a), (b), (c) or a named other in one line; why in one
paragraph; every defect in my framing with `file:line` or source URL; the requirement ids,
conformance items and declarations the chosen answer edits.
