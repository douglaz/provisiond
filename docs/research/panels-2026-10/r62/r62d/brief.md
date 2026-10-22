# Panel brief r62d: panel B's closing round (pv-ss4 scope, `API-40`, three reader-worded folds). 2026-10-22

You are one of four independent reviewers. Your working directory is a throwaway clone of `provisiond-spec` at
`07bac41`. Read `AGENTS.md` first.

Rules:
- You MAY edit tracked files in the clone to test a claim. Write nothing outside it. Never commit, push, call a
  provider API, or run `br`.
- `git apply /var/tmp/provisiond-panel-r62d/final-form.patch` puts panel B's whole reviewed text into your clone.
  It holds the NARROW row, the drafted `API-40`, and the three folds in item 3.
- The alternatives are applied on top of it with `python3 -I /var/tmp/provisiond-panel-r62d/amend.py . <name>`,
  where `<name>` is `a1-opus` (WIDE), `api40-opus` or `api40-sol`. The two `api40-*` options exclude each other:
  `git checkout .`, then re-apply the patch, between them.
- Citation gate alone: `mkdir -p tools/formal/.lake && cp /var/tmp/provisiond-panel-r62d/lake/*.jsonl
  tools/formal/.lake/`, then `python3 tools/check_citations.py > cit.log 2>&1; echo $?`. Never pipe a gate. Keep
  `TMPDIR` as set.
- Do not delegate, background or wait on anything. Have a draft by minute 15.

## Settled (not for re-vote)

- Owner, 2026-10-22, verbatim: pv-p3k "MUST, not retryable (Recommended)"; B6 "Yes, any unhealthy
  (Recommended)".
- Everything else in `final-form.patch` was reviewed in r62, r62b or r62c.
- pv-ss4's substance (r62, 4-0): `details.field` holds an RFC 6901 pointer, and with several rejected fields the
  least escaped pointer by unsigned UTF-16 code units wins. r62c voted the row's create stage wording S1 4-0.
- The manager ran the six text gates (citations, ids, fixtures, obligations, coverage, regions) on
  `final-form.patch` alone, on it + `a1-opus` + `api40-opus`, and on it + `a1-opus` + `api40-sol`. Every run exits
  0.
- Gate blind spot: `HISTORICAL` in `tools/check_citations.py` matches "withdraw" inside "withdrawal". The
  citation gate therefore skips the quote in item 3's `WIR-47` sentence, so check that quote by hand.

## Items

**(1) a1: the scope of `WIR-9a`'s tie-break.** The new `invalid_request` row's first cell cites `OPS-23`, which
says "For create, install, power and delete, a missing required field MUST fail as follows", and whose caller
bullet "fails `invalid_request` naming the field".
- **NARROW** (in the patch): "(an `API-7` step, the caller-supplied stage of `OPS-43`'s step 3, or `PRV-47`'s
  validation)".
- **WIDE** (opus, r62c; `a1-opus`): "(an `API-7` step, `OPS-23`'s repeated check of caller-supplied fields, or
  `PRV-47`'s validation)".
- Worked example. A stored `rootfs_via_rescue` install is missing both `trust` (required on the rescue installs,
  `13-wire-contract.md`, `WIR-20`) and `acknowledge_destruction`. At claim, `OPS-23`'s repeated check rejects both.
  - Under NARROW, no rule picks between `/acknowledge_destruction` and `/trust`.
  - Under WIDE, `/acknowledge_destruction` wins.
  - For a create, both forms pick the same field.
- r62b context: sol flagged that `OPS-23` changes covering "create, install, power and delete" are a scope
  extension that "should be deliberate".
- Label it **SCOPE** if it extends a rule to operations in a way the owner must decide. Label it **MECHANICS** if
  it follows from text already settled.

**(2) `API-40`'s attribution of `WIR-2`** (`04-api-contract.md`, "The order resolves a conflict between two
MUSTs"). Opus and sol showed that the drafted "`WIR-2` requires an unknown body field to be rejected **naming a
rejected field** in `details.field` (`WIR-9a`)" breaks `AGENTS.md`'s "Quote the sentence". The unquoted shape
predates panel B.
- **OPUS** (`api40-opus`) replaces that clause with: "`WIR-2` says "The field named in `details.field` MUST be
  selected under `WIR-9a`" of a rejected unknown body field;". The `WIR-12` half stays as it is, unquoted.
- **SOL** (`api40-sol`) replaces both halves, through "it was**.", with: "`WIR-2` says “Unknown fields in a request
  body MUST be rejected” (field selection: `WIR-9a`). `WIR-12` says “the message MUST NOT say which” for a bad
  admission token."
- The manager's claim, for you to test: under SOL the quoted `WIR-2` words no longer carry the duty to name a
  field. The paragraph's next sentence, "satisfies one and violates the other whichever way a handler goes", may
  then not follow from them.

**(3) Confirm three reader-worded folds** (in the patch; no reader but their authors has seen them):
- f1. `WIR-47` (opus and astra): "Under `WIR-2`'s "Unknown fields in a request body MUST be rejected" rule, a
  withdrawal body whose only rejected field is `operator_ref` returns `invalid_request` with `details.field:
  "/operator_ref"` (`WIR-9a`)."
- f2. `CNF-342` (opus): "Add a stored create carrying provider-options members `a/b` and `a~b`, both rejected by the
  driver, and assert `details.field: "/provider_options/a~0b"`, the least escaped pointer in `WIR-9a`'s order;
  unescaped, `a/b` sorts first."
- f3. `CNF-18` (fable): "… `CNF-19` and `CNF-55` cover its gate."

## Answer

- **(1)** NARROW: ACCEPT or CANNOT ACCEPT. WIDE: ACCEPT or CANNOT ACCEPT. PICK: NARROW or WIDE. LABEL: SCOPE or
  MECHANICS. One reason line.
- **(2)** OPUS: ACCEPT or CANNOT ACCEPT. SOL: ACCEPT or CANNOT ACCEPT. PICK: OPUS, SOL or BOTH. One reason line.
- **(3)** f1, f2, f3: ACCEPT or CANNOT ACCEPT, each with one line.

Every CANNOT ACCEPT gives a one-line reason (at most 25 words). If you can accept neither option of an item, give
the exact replacement text. List wrong facts under "Brief errors", with the grep that shows each one.

**Total: at most 300 words.**
