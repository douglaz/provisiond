# r86 verification at 3109b5b44eae17e288cf52aaa976993bd8c5626c

No question dropped. At the pin API-7 step 5d is still create-only; OPS-43 step 3 still gates before step 4 obtains offers. The post-triage source history did not settle these clauses.

## Triage, verbatim

38: | `pv-5pmu` | P3 | It is unclear when non-create operations must check provider support. | needs a panel | **Panel G, Q1:** For power/hard-reset, each install strategy, rescue inventory, reverse DNS, delete, and attachment release, which capability gates run at admission, at claim, or both, and in what failure order? Distinguish automatic system cancellations from caller/operator requests. Apply `DOM-10`'s existing unsupported result rather than inventing a second taxonomy. Share one read with `pv-e45e`. | `01-domain-model.md:515–538` (`DOM-10`): “before the driver is called” and “There MUST be no operation whose only gate is a driver-internal check.” `04-api-contract.md:241–255` (`API-7`) names only a create gate at 5d. `03-operation-lifecycle.md:764–790` (`OPS-43`) names create ordering and List offers gates. The obligation exists; the admission/claim placement question is not settled by those clauses. | No cosmetic issue; cited claim checked on master. |
53: | `pv-e45e` | P4 | A create checks provider support before knowing the machine type it needs. | needs a panel | **Panel G, Q2:** What supplies the offer's machine kind before the create ordering gate at admission and claim, including absent offers and a mixed-kind account? Settle the source and refusal precedence without adding an admission provider call or violating the owner's stored-listing age/refusal order. Coordinate exact `API-7` / `OPS-43` ordering with the gate-placement question in `pv-5pmu`. | `04-api-contract.md:241,262–275` (`API-7`); `01-domain-model.md:525–526` (`DOM-10`) maps virtual and bare-metal creates differently. `13-wire-contract.md:640–667` (`WIR-17`) has no caller `kind`; `:1033–1046` (`WIR-30`) is the cited offer route. `03-operation-lifecycle.md:779–790` (`OPS-43`) gates in step 3 and obtains List offers in step 4. `10-conformance-checklist.md:335–348` (`CNF-55`) requires the chosen capability in the refusal. | CHANGED CONTEXT: PR #26 made admission use a stored listing (`API-7`:264); the filing's generic later offer-read premise still exposes the ordering gap. Keep P4 and the three settled panel-E choices; do not propose fresh provider reads as if they remained open. |
80: - **G — capability gates:** Q1 `pv-5pmu` non-create admission/claim placement; Q2 `pv-e45e` the source of create kind before either ordering gate. Respect PR #26's stored-listing policy and all three panel-E settlements.

## Beads from pinned committed JSONL, read only

```json
{
  "id": "pv-5pmu",
  "title": "DOM-10 gates power, install and rescue inventory on capabilities, but API-7 has no admission step for them; 5d covers only create (DOM-10, API-7, OPS-43)",
  "description": "Found by panel r62 (one reader, opus), while triaging `pv-009` (`docs/research/panels-2026-10/r62/final-form.md`, \"File with the drain PR\", item 2).\n\n`DOM-10` says \"Every operation with a capability MUST be gated on it before the driver is called, **including create**\", and its table maps power to `power_control`, hard reset to `hard_reset`, each install strategy to its capability, and rescue inventory to `rescue_ssh`. `API-7`'s admission pipeline gates only one of them: step 5d, added by `pv-p3k`, gates \"a create on its ordering capability\". Power, install and rescue inventory have no admission capability-check step. `OPS-43`'s `DOM-10` gates (step 3's ordering capability, step 4's `list_offers`) are create-only as well.\n\nWhether these operations need an admission gate, a claim-time gate, or both, is open. (`DOM-10` now fixes the failure's `retryable: false`.) The table also maps reverse DNS to `reverse_dns` and delete to `delete_machine`; the form named only power, install and rescue inventory, so whether those two need the same gate is part of the question.\n\nOwners: `DOM-10`, `API-7`, `OPS-43`.",
  "status": "open",
  "priority": 3,
  "issue_type": "task",
  "created_at": "2026-10-22T21:01:42.189533172Z",
  "created_by": "user",
  "updated_at": "2026-10-22T21:13:04.937814046Z",
  "source_repo": "provisiond-spec",
  "source_repo_path": "/home/user/projects/provisiond-spec",
  "compaction_level": 0,
  "original_size": 0,
  "labels": [
    "needs-triage"
  ]
}
```
```json
{
  "id": "pv-e45e",
  "title": "API-7 step 5d gates on 'the create's ordering capability', but the machine kind that picks it comes from the offer the tail reads later (API-7, OPS-43, DOM-10, CNF-55)",
  "description": "> *Filed 2026-10-22 while judging panel B (pv-7j3, pv-p3k, pv-009, pv-gpw, pv-ss4), from a full read of the set at `1bdf453`.*\n\nWhich capability does `API-7`'s new step 5d gate a create on, when a create's capability depends on the machine kind and admission reads offers only in the tail?\n\n- `API-7` step 5d (`04:241`): \"**gate a create on its ordering capability** under `DOM-10`\".\n- `DOM-10`'s table (`01:525-526`) maps \"create machine, `kind = virtual`\" to `provision_virtual` and \"create machine, `kind = bare_metal`\" to `provision_bare_metal`.\n- `WIR-17`'s create body has no `kind`: the machine kind is a property of the named `offer` (`WIR-30`). The tail reads offers after 5d, and `04:275` says \"No additional lookup is made for this verdict.\"\n- `CNF-55` asserts `details.capability` \"naming the account and that capability\".\n\nTwo engines:\n- **Engine A** derives the capability from the account's descriptor alone.\n- **Engine B** reads the offer's kind before 5d.\n\nThey diverge where an account declares one provisioning capability and the named offer is of the other kind, or is absent from the offers:\n- A fails `501 unsupported` naming one capability, or passes 5d.\n- B fails at 5d naming the other capability, or reaches the tail's `offer_not_sellable`.\n\nThe same gap sits at claim. `OPS-43` step 3 runs \"`DOM-10`'s gate on the create's ordering capability\", and only step 4 then says \"Gate on `list_offers` under `DOM-10`, then obtain the current driver List offers result\". The claim-time gate also runs before the offer, and with it the kind, is read.\n\nEvery v1 launch driver sells one machine kind per account, so both points are latent, which is why it is P4. Owners: `API-7`, `OPS-43`, `DOM-10`.\n",
  "status": "open",
  "priority": 4,
  "issue_type": "task",
  "created_at": "2026-10-22T20:58:59.838449238Z",
  "created_by": "manager",
  "updated_at": "2026-10-22T22:24:24.454132667Z",
  "source_repo": "provisiond-spec",
  "source_repo_path": "/home/user/projects/provisiond-spec",
  "compaction_level": 0,
  "original_size": 0,
  "labels": [
    "needs-triage"
  ]
}
```

## Post-triage source history

```text
cef4d26 Cover stopped cancellations before deletion retry (#38)
a585321 Persist restore marker provenance and correct retry clock (#36)
296fbd1 Add independent successor recovery witnesses (#35)
e02618e Bound database connection attempts across restarts (#32)
```
