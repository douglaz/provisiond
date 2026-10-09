Verdict: choose (1), with “no retained observation”; the unchanged withdrawal-provenance contract at `843a2f2` is FAIL.

`DOM-27` says “The signal’s job is to **stop** a remediation loop” ([01-domain-model.md:351](https://github.com/douglaz/provisiond/blob/843a2f28650922383fc355972720cd69ac743fa0/01-domain-model.md#L351)). I found no specified caller or operator decision requiring “never looked” versus “looked, withdrawn.” Provenance can inform diagnosis, but neither history establishes safe networking. `WIR-47` says “A client MUST NOT read `unknown` as `none`” and “The same object is joined into the case projection at render time from the machine” ([13-wire-contract.md:1218](https://github.com/douglaz/provisiond/blob/843a2f28650922383fc355972720cd69ac743fa0/13-wire-contract.md#L1218)). Thus `WIR-11`/`WIR-43` are presentation paths; conformance currently demands a historical distinction without identifying an operational consumer.

Let `tP` be the last retained provider restriction-reading time; `t1` the active operator record’s time. The proposed total rendering is:

| Provider reading | Operator record | `status` | `source` | `observed_at` |
|---|---|---|---|---|
| Never read | Absent | `unknown` | null | null |
| Clear | Absent | `unknown` | `provider_api` | `tP` |
| Set | Absent | `restricted` | `provider_api` | `tP` |
| Never read | Active | `restricted` | `operator_notice` | `t1` |
| Clear | Active | `restricted` | `operator_notice` | `t1` |
| Set | Active | `restricted` | `provider_api` | `tP` |
| Never read | Withdrawn at `t2` | `unknown` | null | null |
| Clear | Withdrawn at `t2` | `unknown` | `provider_api` | `tP` |
| Set | Withdrawn at `t2` | `restricted` | `provider_api` | `tP` |

Withdrawal reveals the retained provider reading immediately. Its timestamp may predate `t1`; never substitute `t2` or require another refresh.

The framing needs these corrections:

- **“Current observation” is ambiguous.** A retained provider reading can be old. Use an exact condition: source/time are null iff both `provider_observed_at` and `operator_recorded_at` are null. ADR-0038 explicitly retains “the provider’s last reading” ([ADR-0038:34](https://github.com/douglaz/provisiond/blob/843a2f28650922383fc355972720cd69ac743fa0/docs/adr/0038-a-network-restriction-is-positive-evidence-from-either-source.md#L34)).
- **Latest observation across both sources is incompatible with settled positive provenance.** Provider set → operator withdrawal would label a surviving provider warning `operator_notice` at `t2`. Operator positive → provider clear would similarly misattribute it. ADR-0038 says source “is the positive one” ([ADR-0038:36](https://github.com/douglaz/provisiond/blob/843a2f28650922383fc355972720cd69ac743fa0/docs/adr/0038-a-network-restriction-is-positive-evidence-from-either-source.md#L36)).
- **Option (2) does not require full withdrawal history.** A last-operator `(positive?, time)` snapshot suffices. Calling withdrawal an observation is coherent, but adds retained state compared with the nullable timestamp proposal ([r24/fable.md:7](https://github.com/douglaz/provisiond/blob/843a2f28650922383fc355972720cd69ac743fa0/docs/research/panels-2026-10/r24/fable.md#L7)); no identified reader earns that addition.
- **“CNF-250 unchanged” is false under clearing.** “Null means no record” does not imply “nobody has looked” ([10-conformance-checklist.md:2522](https://github.com/douglaz/provisiond/blob/843a2f28650922383fc355972720cd69ac743fa0/10-conformance-checklist.md#L2522)). Nor did every r24 answer choose these semantics: [r24/astra.md:18](https://github.com/douglaz/provisiond/blob/843a2f28650922383fc355972720cd69ac743fa0/docs/research/panels-2026-10/r24/astra.md#L18) proposed latest-observation provenance when neither source was positive.

Required edits:

- **`WIR-47` first:** own the total rendering rule and exact null condition. Checklist/persistence changes alone leave its “where nobody has looked” wording unresolved ([13-wire-contract.md:1217](https://github.com/douglaz/provisiond/blob/843a2f28650922383fc355972720cd69ac743fa0/13-wire-contract.md#L1217)). Then record the dated ADR-0038 clarification; point other requirements to the owner.
- **Persistence:** replace the existing restriction rows ([05-persistence.md:271](https://github.com/douglaz/provisiond/blob/843a2f28650922383fc355972720cd69ac743fa0/05-persistence.md#L271)); require provider flag/time nullability to agree. Withdrawal clears only the operator record. Include the notice reference: “three columns” excludes ADR-0038’s additional `operator_ref` obligation, “A record carries an `operator_ref`” ([ADR-0038:41](https://github.com/douglaz/provisiond/blob/843a2f28650922383fc355972720cd69ac743fa0/docs/adr/0038-a-network-restriction-is-positive-evidence-from-either-source.md#L41)).
- **Conformance:** amend `CNF-250`’s null condition; retain its fresh, unobserved fixture. Rewrite `CNF-233` around the table and withdrawal interleavings, checking exact triples across machine and case renderings. Its no-signal case needs an absent operator record. Change `CNF-228`’s “reads `disabled`” to `restricted`, exercising either source and both while preserving billing/delete assertions ([10-conformance-checklist.md:2839](https://github.com/douglaz/provisiond/blob/843a2f28650922383fc355972720cd69ac743fa0/10-conformance-checklist.md#L2839)).
- **Fixtures:** change `WIR-11`’s `none` to `unknown`, retaining provider provenance ([13-wire-contract.md:322](https://github.com/douglaz/provisiond/blob/843a2f28650922383fc355972720cd69ac743fa0/13-wire-contract.md#L322)); add the missing joined object to `WIR-43` ([13-wire-contract.md:1088](https://github.com/douglaz/provisiond/blob/843a2f28650922383fc355972720cd69ac743fa0/13-wire-contract.md#L1088)).

No existing Lean restriction declaration changes. `WIR-11`’s modeled observation is `stateObservedAt`, not restriction provenance ([Wire.lean:717](https://github.com/douglaz/provisiond/blob/843a2f28650922383fc355972720cd69ac743fa0/tools/formal/Provisiond/Wire.lean#L717)). Do not weaken that theorem or add `CNF` identifiers to Lean.

Both required unpiped gate runs passed. Tracked files remain unchanged.