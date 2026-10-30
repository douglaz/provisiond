# Verification against master

Origin/master and check clone pin: 3109b5b44eae17e288cf52aaa976993bd8c5626c

- `04-api-contract.md:958–981` byte-equal at old and current pins: True.
- `07-security-requirements.md:280–281` byte-equal at old and current pins: True.
- `06-rescue-install.md:245–330` byte-equal at old and current pins: True.
- `CNF-200` entire block byte-equal at old and current pins: True.
- `CNF-363` entire block byte-equal at old and current pins: True.

All three selected JSONL beads remain open with needs-triage; no question is dropped. No API cap/path clause or exact trimming code-point set was added since triage. No outside-library behavior is asserted. Formal source evidence quotes the existing abstract Identifier/Inventory structures and resolution theorems; no model edit is proposed.
