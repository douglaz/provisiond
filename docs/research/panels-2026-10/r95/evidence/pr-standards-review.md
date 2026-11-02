Reviewed `96a72898c7ace67790aec0bab3727eee858e2245` against fixed base `6a3b6014f1f8b36fc21b902e507e74d8c5264e99`. Standards result: **FAIL**.

Hard violations:

- **Blocker — unquoted OPS-11 attributions**, [03-operation-lifecycle.md:789](/home/user/projects/provisiond-spec/03-operation-lifecycle.md:789) and [line 818](/home/user/projects/provisiond-spec/03-operation-lifecycle.md:818). The added hunks prescribe “full commitment release and no setup-fee or first-unit debit under OPS-11's pre-step-9 create rule” and “settle failed under OPS-11's pre-step-9 rule”. These summarize another requirement without quoting it. [AGENTS.md:45](/home/user/projects/provisiond-spec/AGENTS.md:45) requires “every sentence asserting what another requirement says carries its quote.”

- **Blocker — unquoted OPS-27 attributions**, [04-api-contract.md:625](/home/user/projects/provisiond-spec/04-api-contract.md:625) and [line 670](/home/user/projects/provisiond-spec/04-api-contract.md:670). The hunks say “its machine follows OPS-27's suspended-attach cancellation” and “Orders already potentially dispatched retain OPS-27's attach and suspended-tenant cancellation path, including later evidence-based attachment after the suspension parent has settled.” Neither carries OPS-27’s words, violating the same documented standard.

These are review obligations: [the citation gate documentation](/home/user/projects/provisiond-spec/tools/check_citations.py:165) deliberately leaves summary attributions outside its enforced scope.

Both violations occur in the exact adopted executable blocks. **Stop for resolution of that standards conflict; changing those blocks would require departing from the settled text.** No behavioral repair or restoration of item 19’s relinquished publication duty is proposed.

No judgment-call baseline-smell findings.