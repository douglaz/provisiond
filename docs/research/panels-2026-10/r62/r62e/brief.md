# Panel brief r62e: `API-40`'s attribution of `WIR-2` and `WIR-12` (panel B, last open point). 2026-10-22

You are one of four independent reviewers. Your working directory is a throwaway clone of `provisiond-spec` at
`07bac41`. Read `AGENTS.md` first.

Rules:
- You MAY edit tracked files in the clone to test a claim. Write nothing outside it. Never commit, push, call a
  provider API, or run `br`.
- `git apply /var/tmp/provisiond-panel-r62/final-form.patch` puts panel B's whole text into your clone, with the
  drafted `API-40` span below.
- Apply an option on top of it with `python3 -I /var/tmp/provisiond-panel-r62e/variants.py . as2` or `. opus2`. They
  exclude each other: `git checkout .`, then re-apply the patch, between them.
- Citation gate alone: `mkdir -p tools/formal/.lake && cp /var/tmp/provisiond-panel-r62e/lake/*.jsonl
  tools/formal/.lake/`, then `python3 tools/check_citations.py > cit.log 2>&1; echo $?`. Never pipe a gate. Keep
  `TMPDIR` as set.
- Do not delegate, background or wait on anything. Have a draft by minute 10.

## Settled (not for re-vote)

- Everything in `final-form.patch` except the `API-40` span below. Owner, 2026-10-22, on `WIR-9a`'s tie-break:
  "Wide: all four ops (Recommended)".
- The behaviour is fixed and not in question: `04-api-contract.md` says "**The admission token MUST be checked
  before any other validation of the body**", and a body with a bad token and an unknown field gets
  `invalid_request` with no `details.field` and no token detail. Only the attribution wording is open.
- The drafted span is out: r62c found it breaks `AGENTS.md`'s "A claim about what another requirement says carries
  that requirement's own words", and r62d rejected both of its fixes (SOL 0-4, OPUS 1-3). Each of the two texts
  below was written in r62d by the reader(s) named, and no other reader has voted on it.

## The span

In `04-api-contract.md`, `API-40`, after "**The order resolves a conflict between two MUSTs, so it is stated as a
precedence.**", replace everything from "`WIR-2` requires" through "it was**." with one of:

- **as2** (astra and sol, word for word):
  > `WIR-2` says “Unknown fields in a request body MUST be rejected” and “The field named in `details.field` MUST be
  > selected under `WIR-9a`”. `WIR-12` says “a body with both a bad token and an unknown field is refused naming no
  > field at all”.
- **opus2** (opus):
  > `WIR-2` says "The field named in `details.field` MUST be selected under `WIR-9a`" of a rejected unknown body
  > field. `WIR-12` says of a bad admission token "absent, expired, unknown or already spent is `invalid_request`,
  > and the message MUST NOT say which".

The next sentence stays: "A body carrying both a bad token and an unknown field satisfies one and violates the
other whichever way a handler goes."

Manager's checks: on the patch + either option, all six text gates (citations, ids, fixtures, obligations,
coverage, regions) exit 0. Each quote in both options turns citations red when planted false. Joining opus2's two
sentences with a semicolon turns citations red (the gate checks the `WIR-12` quote against `WIR-2`).

## Two points to weigh

- **The manager's observation (unvoted).** as2's `WIR-12` quote is not `WIR-12`'s MUST. It is the words after
  "so" in `WIR-12`'s "that check precedes `WIR-2`'s unknown-field rule, so a body with both a bad token and an
  unknown field is refused naming no field at all**, `API-40`'s stated precedence" (`13-wire-contract.md`,
  around line 429). `API-40` would justify its precedence by quoting `WIR-12`'s restatement of that same
  precedence, which is circular.
- **Opus's point (r62d, unvoted).** opus2 quotes `WIR-12`'s real MUST, "the message MUST NOT say which", but "a
  field-first answer breaks none of the quoted `WIR-12` words either": naming the unknown field says nothing
  about which of absent, expired, unknown or spent the token was. Under opus2, "violates the other whichever way
  a handler goes" may not follow in that direction.

## Answer

- as2: ACCEPT or CANNOT ACCEPT. opus2: ACCEPT or CANNOT ACCEPT. PICK: as2, opus2 or BOTH. One reason line.
- Every CANNOT ACCEPT gives a one-line reason (at most 25 words).
- If you can accept neither, give the exact replacement text for the span, and say whether it changes the next
  sentence.
- List wrong facts under "Brief errors", with the grep that shows each one.

**Total: at most 200 words.**
