## B1: CANNOT ACCEPT (the `PRV-4` addition). This is an owner/product call, because it depends on the MUST.

`DOM-15` says "Declaration and implementation MUST agree", and `PRV-4`'s second clause cites it. The merge exempts `PRV-4` and `CNF-18` but not `DOM-15`, so `DOM-15` is still broken. Also, "the second clause there" sits inside `PRV-4`, so it has nothing to point at.

Replace the `PRV-4` addition with: "An ordering capability that `DOM-16` withholds from an account whose `allow_orders` is false is not declared for that account, and a driver that implements it breaches neither this requirement's second clause nor `DOM-15`." Add to `DOM-15`: "`PRV-4` states its exception for an ordering capability withheld under `DOM-16`."

The `DOM-16`, `CNF-18` and `WIR-29` edits are fine.

## B2: CANNOT ACCEPT (`API-7`)

Two sentences in `04-api-contract.md` still say 5c: line 261, "After steps 1–5c, the tail MUST collect", and line 290, "Steps 1–5c still stop at their first refusal". Read that way, 5d falls inside the collected tail, which contradicts 5d's own "not collected by the tail".

Replace "1–5c" with "1–5d" in both sentences. The `DOM-10` and `PRV-10` edits are fine.

## B3: ACCEPT

I applied it and the citation gate stayed green.

## B4: CANNOT ACCEPT (the `PRV-47` addition)

With the text applied, `check_citations.py` reports: "02-provider-contract.md attributes to DOM-17 a phrase DOM-17 does not contain: "defect in this system"". That phrase is the `internal` row of the error table (`01-domain-model.md:588`); `DOM-17` itself starts at line 652.

Replace `(`DOM-17`: "Defect in this system")` with `(`DOM-17`)`. That version passes the gate. I accept `true`, the split, `OPS-23` and `CNF-342`.

## B5: CANNOT ACCEPT (`WIR-2`, and one phrase in the `WIR-9a` row)

`API-7` step 5 rejects unknown fields and invalid fields in the same step. Take `{"acknowledge_purchase": false, "zzz": 1}`: `WIR-9a` names `/acknowledge_purchase`, but the new `WIR-2` names `/zzz`.

In `WIR-2`, replace "naming the first unknown field" with "naming a rejected field as `WIR-9a`'s `invalid_request` `field` row chooses it".

In `WIR-9a`, "one of the three stages of `OPS-43`'s step 3" puts a count into prose. Replace it with "a stage of `OPS-43`'s step 3".

## B6: ACCEPT. This is a scope call.

It widens the refusal from confirmed-terminated accounts to any account that isn't `healthy`. The mechanics hold, because `STO-36` already says "A row MUST NOT be written naming a `provider_account` whose `STO-47` status is anything but `healthy`".

## Brief errors

- B4 says "a system-written value meets validation only at step 7". Under Q3's own wording ("a value the system wrote"), that's false. `grep -n "the \`api\` itself writes" 03-operation-lifecycle.md` finds `OPS-23`'s bullet: fields the `api` writes meet validation at step 3. The new `OPS-23` sentence then sends a present, invalid value the `api` wrote to `conflict`/`incomplete_record`, not `internal`. Both give `retryable: true`, so I don't block on this. But if Q3 was meant to cover the `api`, the split departs from it.

I reverted my test edits. The answer is in `answer-r62b.md` (438 words). The only other untracked file is one `br` created in `.beads/`.
