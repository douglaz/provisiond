# pv-e45e Run instruction: verbatim quotations (Panels r98, r100 and r100b)

Every block below is exact bytes, shown between four-backtick fences. Pin `2cb8e1189310ae096e598bac798df3437be59500`. The adopted text is `docs/research/panels-2026-10/r86/r86b/Q2-A-cited.md` (SHA-256 `d611bbae87294a0fc0087c567fa82aa1404cd0c5a54abe394b5327488ec51ea2`) and pv-e45e comment 857, which is not edited.

## 1. Route decision r98 Q1-RUN (a), `/var/tmp/provisiond-panel-r98/brief.md:201-203`

````text
- **Q1-RUN (a).** Comment 857 is not edited. The pv-e45e Run also updates `PRV-10`'s quotation to the
  new text, as mechanical follow-through on the brief's step rewrites, and its instruction carries the
  Q2 form verbatim. No preparation commit.
````

## 2. Settled route r100b Q-ROUTE: R-NOTE (`R-NOTE.txt`, SHA-256 `d50de4177d3aa9c689d1bc4e6f1ff7cd6fbb08831ae8fd5702484ce3efff43a7`)

````text
Exactly as R-RUN, and in addition the Run appends exactly R-NOTE-append.md to docs/research/panels-2026-10/r86/r86b/Q2-A-cited.md, all original bytes remaining an exact prefix. Comment 857 is not edited. No branch or tracker edit occurs in this panel turn.
````

R-NOTE begins "Exactly as R-RUN"; R-RUN is (`R-RUN.txt`, SHA-256 `606973ea02527fc50d1ae9be52e073d69ff74c2009c455cd61a925e06c31a0dd`):

````text
No preparation commit; comment 857 and docs/research/panels-2026-10/r86/r86b/Q2-A-cited.md are not edited. The pv-e45e Run instruction quotes verbatim /var/tmp/provisiond-panel-r98/brief.md:201–203, the PRV-10 form (r100 check/F-QUOTE.txt, or check/F-QUOTE-Q5.txt if Q5 settles on Q5-QUOTE), and each settled r100 form whose bytes differ from the adopted text, each with the Q2-A-cited.md span it replaces; the Run writes those forms in place of those spans and archives the reviewed r100 record at docs/research/panels-2026-10/r100/. No branch or tracker edit occurs in this panel turn.
````

## 3. The PRV-10 form (Q5 settled KEEP, so this is r100 `check/F-QUOTE.txt`, SHA-256 `2393f71eef02a593e37ca93d6dc4bd441bfc928a0bbeff4e9939e43a34bf2323`, its final LF is not part of the form. It replaces `02-provider-contract.md`'s PRV-10 span that begins "The configuration half is `DOM-10`'s gate" and ends "then the capability gate”.")

````text
The configuration half is `DOM-10`'s gate on the create's ordering capability (`DOM-16`); `DOM-10` says “Every operation with a capability MUST be gated on it before the
driver is called, **including create**”. At admission, step 5d is the gate: `API-7` says “For create, open the existing LDG-35 admission transaction and read the provider account's
    stored offer listing in the same read-only snapshot the rich purchase tail will use,
    regardless of listing age; no stored listing means an empty offers set. If the named
    offer is present, take its kind and gate on DOM-10's matching ordering capability using
    the descriptor api runs with. A capability refusal stops here and is not collected by
    the tail. If the offer is absent, run no ordering-capability check and infer no kind from
    the provider account, capability set, offer-id spelling or caller input; continue to the
    ordinary tail's absent-offer verdict. No provider call or admission write is made here.
    On admission, retain the named offer's kind as machine_kind in the create's
    request_summary offer snapshot in the same transaction as the operation and commitment”. At claim, step 3 is the gate: `OPS-43` says “Repeat boundary validation under `OPS-23`: "Validation that was performed at the API boundary
   MUST be repeated in the worker before the driver is called". This includes `PRV-10`'s
   "explicit purchase acknowledgement", `PRV-8`'s "at least one SSH public key", and the
   missing-field checks in `OPS-23`. Validate `request_summary`'s `machine_kind` as `virtual`
   or `bare_metal`. The `api` writes `machine_kind` at admission; for missing or invalid
   fields, see `OPS-23`. Check caller-supplied fields first, then api-written admission
   fields, then gate on `DOM-10`'s matching ordering capability selected by that persisted
   `machine_kind`, using the descriptor the worker runs with. No current offer read supplies
   this gate”.
````

## 4. Settled forms whose bytes differ from the adopted text, each with the span it replaces

The Run writes each settled form in place of its adopted span wherever that span is written into the spec. Every adopted span occurs exactly once in Q2-A-cited.md and once in comment 857.

### Q1: Q1-ALT (settled 3–0 in r100b; SHA-256 `97035ff0c6bbfae893123db51d53b03bad68e512a47415554d3cf5350fe43816`) replaces Q2-A-cited.md:62-63 (comment 857:88-89); lands in `03-operation-lifecycle.md`: the OPS-23 insert written after lines 2076–2079

Adopted span:

````text
The offer-kind consistency check at OPS-43 step 5 uses the same exception: it runs on
step 4's current List offers result, after that read and before any provider mutation.
````

Q1-ALT:

````text
The offer-kind consistency check at OPS-43 step 5 uses the same exception: it runs on
step 4's current List offers result, after that read and before any provider mutation;
`OPS-43` says "If present but its kind differs from request_summary's machine_kind, settle
failed with invalid_request" and "before any provider mutation", and its step 4 says "obtain
the current driver List offers result".
````

### Q2: Q2-QUOTE (settled 3–0 in r100; SHA-256 `d82170607ffaccca68bf057c8f6f3117caa7fcc02d65599ad19f9e02502c83f6`) replaces Q2-A-cited.md:131-134 (comment 857:160-163); lands in `tools/formal/Provisiond/Admission.lean`: replaces the docstring text at lines 317–319

Adopted span:

````text
`orderingCapabilityGuard` (`API-7`, 2026-10-22, `pv-p3k`; step 5d reworded 2026-10-30,
`pv-e45e`): step 5d gates a create on the ordering capability selected by the named offer's kind
in the stored listing, and takes no gate for an offer absent from it. Off, a create without that
declaration reaches the purchase tail.
````

Q2-QUOTE:

````text
`orderingCapabilityGuard` (`API-7`, 2026-10-22, `pv-p3k`; step 5d reworded 2026-10-30,
`pv-e45e`): step 5d gates a create on the ordering capability selected by the named offer's kind
in the stored listing, and takes no gate for an offer absent from it; `API-7` says "If the named
offer is present, take its kind and gate on DOM-10's matching ordering capability" and "If the
offer is absent, run no ordering-capability check". Off, a create without that declaration
reaches the purchase tail.
````

### Q3: Q3-QUOTE (settled 3–0 in r100; SHA-256 `83bc80552410d2e6292c1a0d1cf702e82d635878ce0858b089e43ee68cf8fc09`) replaces Q2-A-cited.md:144-146 (comment 857:173-175); lands in `tools/formal/Provisiond/Admission.lean`: replaces words on lines 1181–1182

Adopted span:

````text
whether the account declares the ordering capability selected by the named offer's kind in the
stored listing; for an offer absent from that listing step 5d takes no gate and the Boolean is
supplied `true`. Offer-kind selection and descriptor construction are outside this model.
````

Q3-QUOTE:

````text
whether the account declares the ordering capability selected by the named offer's kind in the
stored listing; for an offer absent from that listing step 5d takes no gate and the Boolean is
supplied `true` (`API-7` says "If the offer is absent, run no ordering-capability check").
Offer-kind selection and descriptor construction are outside this model.
````

### Q4: Q4-KEEP (settled 3–0 in r100; SHA-256 `5db74cb1fc638bf9250e7c8f2b733aaec85b88f905d22c9f9375aa091e4b1c94`) replaces Q2-A-cited.md:69-70 (comment 857:95-96); lands in `05-persistence.md`: inside the one-line table row at line 523

Adopted span:

````text
the **offer snapshot** (`offer_id`, `machine_kind` (`virtual` or `bare_metal`, copied from the
named offer at admission under API-7), the offer's `install_strategies` as accepted,
````

Q4-KEEP:

````text
the **offer snapshot** (`offer_id`, `machine_kind` (`virtual` or `bare_metal`, copied from the named offer at admission under API-7), the offer's `install_strategies` as accepted,
````

### Q6: Q6-QUOTE (settled 3–0 in r100; SHA-256 `ad77bbdd4095faa1336db546c6058f1ef58ee3239607af89299974aa0b4bf9d5`) replaces Q2-A-cited.md:55-56 (comment 857:81-82); lands in `03-operation-lifecycle.md`: the last clause of OPS-43 step 5, replacing lines 804–805

Adopted span:

````text
the same existing
   pre-step-9 settlement releases the commitment and any resource-offer exclusion.
````

Q6-QUOTE:

````text
the same existing
   pre-step-9 settlement releases the commitment and any resource-offer exclusion; `OPS-11`
   says "The commitment is released in full under `LDG-32`" and "Where the create holds a
   resource-offer exclusion, it is freed under `STO-58`".
````

Q5 (Q2-A-cited.md:39-43) and Q7 (:101) settled KEEP: the Run writes them exactly as adopted.

## 5. The append to Q2-A-cited.md (whole `R-NOTE-append.md`, SHA-256 `40db5de25fb651fc30575c9850d4397f78d0b76213df023e372f572238b58af9`, ending with one LF)

````text
## Wording correction — 2026-11-03 (Panel r100)

The text above is retained as the historical form approved in owner item 17; its original
bytes remain unchanged. Under the owner's 2026-10-28 wording rule (“For such wording
questions, try to solve by getting a consensus of the panel”), the pv-e45e Run writes the
exact replacements selected in the panel record below in place of the spans they replace.
Comment 857 is not edited. This note grants no independent authority to change a
requirement; any substantive unresolved conflict returns to the owner.

Source pin: `2cb8e1189310ae096e598bac798df3437be59500`.
Panel record: `../../r100/notes.md`.
````
