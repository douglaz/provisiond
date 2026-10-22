Reviewed r62b B1–B6 against `07bac41`.

- **B1 — ACCEPT**, conditional on the owner’s `DOM-16` MUST decision.
- **B2 — ACCEPT.** Also update `API-7`’s remaining “After steps 1–5c” and “Steps 1–5c” references to include 5d.
- **B3 — ACCEPT.** The intra-step precedence is a policy choice, not an ordering already established by the existing text.
- **B4 — ACCEPT.** Accept the split and `retryable: true`. Extending `incomplete_record` to present-but-invalid api-written fields is a classification policy choice.
- **B5 — CANNOT ACCEPT — `WIR-2` amendment.** “Naming the unknown field” conflicts with the broader minimum-pointer rule: step 5 can reject `/acknowledge_purchase` and unknown `/zzz`; the proposed sentences select different pointers.

  Replace `WIR-2`’s opening sentence with:

  > **Unknown fields in a request body MUST be rejected** with `invalid_request`. The field named in `details.field` MUST be selected under `WIR-9a`, including when the same validation step also rejects known fields.

  Accept the proposed `WIR-9a` row.
- **B6 — ACCEPT.** This supplies the wire outcome for `STO-36`’s existing prohibition: “A row MUST NOT be written naming a `provider_account` whose `STO-47` status is anything but `healthy`”.

**Brief errors**

“A system-written value meets validation only at step 7” is too broad. `OPS-23` covers “A field the `api` itself writes” and places those failures at step 3; B4 extends that treatment to present invalid values.

```bash
rg -n -A8 'A field the `api` itself writes' 03-operation-lifecycle.md
```

No files changed; gates not run.