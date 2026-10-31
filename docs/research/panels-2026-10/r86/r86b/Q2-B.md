### Complete candidate Q2-B — explicitly require one machine kind per provider account

This narrower form excludes a mixed-kind account instead of adding a retained kind field. In `PRV-44`, replace "`account`, `kind`, `capabilities`," with exactly:

```text
`account`, `kind`, `machine_kind: virtual | bare_metal`, `capabilities`,
```

Immediately after `PRV-44`'s descriptor field list, insert:

```text
machine_kind is the one machine kind this provider account can sell, independent of the
provider's kind field and independent of which provisioning capabilities are currently
withheld. Every offer returned for the account MUST have that machine kind. A mixed-kind
account or a descriptor without one valid machine_kind MUST be rejected as invalid deployment
configuration before api or engine enables that account; the deployment MUST NOT guess from
the declared capability set. machine_kind MUST NOT change for a retained provider-account
identity; selling another machine kind requires a distinct provider-account identity.
```

Replace `API-7` step 5d with exactly:

```text
5d. Gate a create on DOM-10's ordering capability selected by the running descriptor's
    machine_kind under PRV-44, including when the named offer is absent from the stored
    listing or no listing is stored. A refusal stops here and is not collected by the tail.
```

Replace `OPS-43` step 3 with exactly:

```text
3. Repeat boundary validation under OPS-23: validation performed at the API boundary MUST
   be repeated before the driver is called. This includes PRV-10's explicit purchase
   acknowledgement, PRV-8's at least one SSH public key and OPS-23's missing-field checks.
   Check caller-supplied fields first, then api-written admission fields, then gate on
   DOM-10's ordering capability selected by the worker's running descriptor's machine_kind
   under PRV-44. No offer read supplies this gate.
```

Append to `CNF-19` after its complete existing sentence:

```text
Use a descriptor with machine_kind virtual, then bare_metal. Withhold its matching
provisioning capability and assert API-7 step 5d names that capability, including with an
absent named offer or no stored listing; declaring only the other provisioning capability
MUST NOT pass the gate. Admit a fresh complete create, then withhold its matching capability
before claim and assert the CNF-55 refusal before List offers. Assert configuration refusal
before enabling a provider account for a descriptor with absent/invalid machine_kind, an
account selling both kinds, or a change of machine_kind for a retained account identity.
```

All other source and checklist text stays unchanged; no request_summary field is introduced. Existing `CNF-55` phase/refusal assertions and purchase-tail ranks stay as pinned. This form adds a real restriction on future provider-account shapes and configuration, rather than asserting that the present set already excludes a mixed account. Assess that scope cost. The descriptor is an operational contract, not a provider HTTP input.

