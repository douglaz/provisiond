- **B1 ACCEPT.** Conditional on the owner choosing MUST; that remains a product call.

- **B2 ACCEPT.** Making retryability uniform across every capability gate is a scope choice.

- **B3 ACCEPT.** The ordering of caller, api and capability checks is an observable error-precedence policy.

- **B4 ACCEPT.** The `OPS-23` addition covers its full verb scope: “For create, install, power and delete”. That scope extension should be deliberate.

- **B5 CANNOT ACCEPT — `WIR-2` selection.** With `acknowledge_purchase: false` and unknown `z_extra`, step 5’s least rejected pointer is `/acknowledge_purchase`; the amended `WIR-2` instead requires `/z_extra`. Both rules cannot govern the same response.

  Replace `WIR-2`’s opening sentence with:

  > Unknown fields in a request body MUST be rejected with `invalid_request`; the named field is selected under `WIR-9a` from all fields rejected in that validation step.

- **B6 ACCEPT.** This aligns the wire refusal with `STO-36`: “A row MUST NOT be written naming a `provider_account` whose `STO-47` status is anything but `healthy`”.

**Brief errors**

“A system-written value meets validation only at step 7” is too broad. `OPS-23` explicitly includes “A field the `api` itself writes when it admits the operation”; its settlement paragraph places those missing-field failures at step 3. B4 additionally covers present invalid values there. “Worker-written value” would distinguish the intended case.

```bash
rg -n -A 10 '^For create, install, power and delete' 03-operation-lifecycle.md
```