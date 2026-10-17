# Panel brief r55b: the kind for `OPS-23`'s missing-field failure, 2026-10-16

You are one of four independent reviewers. The working directory is a throwaway clone of the
specification repository `provisiond-spec` at `cdc6adf` (branch `pv-14b-triage`). Read `AGENTS.md` first.
Round 1 of this panel is copied, untracked, into `docs/research/panels-2026-10/r55/`: `brief.md`, the four
answers and `synthesis.md`. Read the synthesis's `OPS-23` lines and the `OPS-23` parts of the answers; no
need to read the rest. Do not edit tracked files; write scratch files only inside this clone (never `/tmp`
or `/var/tmp`). This is a text question; you need not run the gates. Never call a provider API. Verify every
fact below before relying on it: this owner often shows my framing wrong with a first-principles question.

## Settled and off-limits

- Everything r55's synthesis lists under "What the text already forces". In particular `OPS-23`'s checks
  run before `OPS-43`'s step 2; only the missing-field failure's kind is open.
- Owner decision 1 (2026-10-16, see the synthesis's "Owner decision"): the worker reads `STO-47`'s stored
  status as the new first step of `OPS-43`'s claim order and fails `conflict` with `details.reason:
  "state"` or `"account_terminated"`, releasing the commitment. `API-63`'s conditional write stays last.
- The absent-offer outcome and its home: a separate question.

## The question

`OPS-23` (03:1673-1676): "A field a previous-release `api` may not have written is a deterministic failure
in the worker, never a passed check". It names no kind. It is the rolling-upgrade rule for every future
release (`ADR-0024`); r53 found no deployment can hit it today. Example: release N adds a create field the
worker needs; an N−1 `api` replica admits a create without it mid-roll; the N worker claims it. Nothing is
bought. What does the caller's software read?

Round 1 split: fable `invalid_request`, `retryable: false`; astra `invalid_request` naming the field (no
`retryable` stated); opus `conflict`/`"state"`, `retryable: true`; sol `internal`/`incomplete_create_record`,
`retryable: false`, plus an `OPS-11` exception.

## Options

- **1′ (mine; no reader voted for it):** `conflict`, `details.reason: "incomplete_record"` (a new entry in
  `WIR-9a`'s closed `conflict` reason list, 13:137), `retryable: true` stated in `OPS-23` on the error and
  the operation view, settling `failed` under `OPS-11`, no provider call, commitment released under
  `LDG-39`'s "Deterministic rejection before acceptance" on a create.
- **2 (fable, astra):** `invalid_request`, `retryable: false`.
- **3 (sol):** `internal`/`incomplete_create_record`, `retryable: false`, with an `OPS-11` exception that
  settles it `failed`.

## My claims: break any that are wrong

- C1. `DOM-17` defines `invalid_request` as "Caller error, deterministic" (01:578). The caller made no
  error, so option 2 misdescribes the failure.
- C2. `retryable` "describes whether repeating the *same request* is safe and sensible" (01:653-654), and
  "It is normative guidance to callers" (`API-51`; 01:654). After the roll a re-submission is safe and
  succeeds, so `retryable: false` (options 2 and 3) is untrue, and an obedient caller drops a purchase that
  would work.
- C3. A `conflict` the worker raises before any provider call settles `failed` under `OPS-11` with no new
  exception: it is ambiguous only if "it arose from the worker being cut off mid-flight" (03:265).
- C4. Precedent: `OPS-43`'s claim-time price check fails "`conflict`, `details.reason: "price_moved"`, …
  telling the caller to re-submit" (03:723-724).
- C5. opus's `"state"` collides. On a create, `conflict`/`"state"` already means an account that is not
  healthy (13:163-164; `API-63`, 04:1411-1412), and decision 1 makes the claim-time account read emit it.
  A caller could not tell "account down, wait" from "re-submit now".
- C6. No text supplies a claim-time `retryable` for this failure, so `OPS-23` must state it.

## What I need from you

1. Each claim above you break, with the quote that breaks it. Silence means you checked it and it holds.
2. Your pick: 1′, 2, 3 or a better shape, with its single strongest argument.
3. Is `retryable: true` honest mid-roll, when an immediate re-send may reach an N−1 `api` again? `OPS-23`
   covers every operation kind, not only create: does your pick hold for install, power and delete?
4. Does 1′ need a new reason, or does an existing one fit?
5. The identifiers your pick lands on, and a one- or two-sentence `CNF-34` assertion.
6. Then, labelled "Strongest case for the other side (written on request)", the best argument against your
   pick. It is not your position.

Under 450 words. Cite `file:line` or identifiers for every claim.
