# Panel brief r62f: delete `API-40`'s conflict rationale (panel B, last open point). 2026-10-22

You are one of four independent reviewers. Your working directory is a throwaway clone of `provisiond-spec` at
`07bac41`. Read `AGENTS.md` first.

Rules:
- You MAY edit tracked files in the clone to test a claim. Write nothing outside it, not even `/tmp`. Never commit,
  push, call a provider API, or run `br`.
- `git apply /var/tmp/provisiond-panel-r62f/candidate-del.patch` puts panel B's whole text, with the deletion below,
  into your clone. To see the text before the deletion: `git checkout .`, then
  `git apply /var/tmp/provisiond-panel-r62/final-form.patch`.
- Citation gate alone: `mkdir -p tools/formal/.lake && cp /var/tmp/provisiond-panel-r62f/lake/*.jsonl
  tools/formal/.lake/`, then `python3 tools/check_citations.py > cit.log 2>&1; echo $?`. Never pipe a gate. Keep
  `TMPDIR` as set.
- Do not delegate, background or wait on anything. Have a draft by minute 10.

## Settled (not for re-vote)

- Everything in `final-form.patch` except the `API-40` paragraph below.
- The behaviour: `04-api-contract.md` says "**The admission token MUST be checked before any other validation of the
  body**", and a body with a bad token and an unknown field gets `invalid_request` with no `details.field` and no
  token detail.
- Rewording is closed. Three rounds (r62c, r62d, r62e) produced new text each time and never converged. In r62e all
  four readers rejected both rewordings, and all four agreed that, against `WIR-12`'s MUST ("the message MUST NOT
  say which"), an answer naming the unknown field breaks nothing. The coordinator judged the conflict claim
  unsupported as written and routed it: delete the clause, don't reword it. The owner's standing lesson is to
  prefer deleting an unsupported clause to rewording it.

## The deletion

In `API-40`'s `API-7` bullet (`04-api-contract.md`, around line 772 once patched), these lines:

> **The order resolves a conflict between two MUSTs, so it is stated as a precedence.** `WIR-2`
> requires an unknown body field to be rejected **naming a rejected field** in `details.field`
> (`WIR-9a`); `WIR-12` requires a bad
> admission token to be refused **without saying which of absent, expired, unknown or spent it was**.
> A body carrying both a bad token and an unknown field satisfies one and violates the other
> whichever way a handler goes. **The token check wins**: the response is …

become:

> For a body carrying both a bad token and an unknown field, **the token check wins**: the response is …

The rest of the paragraph is unchanged ("… `invalid_request` with no `details.field` and no token detail. Enrolment
is the one route where naming a field is a free oracle …"). The only added words are the grammatical join "For"
and a comma; "The" became "the". `WIR-2` (`13-wire-contract.md:28`) and `WIR-12` (`13:426-430`) are not touched.

Manager's checks: on 07bac41 + `candidate-del.patch`, all six text gates (citations, ids, fixtures, obligations,
coverage, regions) exit 0. No quote is left in the paragraph. As a control, a true `WIR-2` quote planted in it keeps
citations at 0, and the same quote planted false turns citations red.

## The question

Does the deletion lose any normative content: a MUST or SHOULD, or a behaviour that a conforming server must or
must not show? Look for anything else in the repository that relies on the deleted words.

## Answer

- ACCEPT or CANNOT ACCEPT. Nothing else is counted.
- A CANNOT ACCEPT must name the specific normative content the deletion loses: quote the MUST/SHOULD with its
  file:line, or state the behaviour. Say why nothing left in the spec (for instance `04:768`, `WIR-2` or `WIR-12`)
  still carries it. A CANNOT that names no lost normative content is recorded but does not block.
- Replacement or added text is out of scope and will not be counted.
- List wrong facts under "Brief errors", with the grep that shows each one.

**Total: at most 150 words.**
