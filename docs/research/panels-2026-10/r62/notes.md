# r62 manager notes (verified at 07bac41, 2026-10-22) — for the tally; a fresh manager can resume from here

Line refs (07bac41):
- OPS-43 03-operation-lifecycle.md:700; steps 717-762; "The first failing check stops subsequent checks" :771
- OPS-23 03:1875 (bullets 1884-1888; "the worker-written correlator is not" :1886)
- OPS-11 03:223 (install row lists `unsupported` among "deterministic caller errors"; create row: failed whatever kind)
- PRV-10 02-provider-contract.md:158; PRV-47 02:163; PRV-9 temp-key name/tag 02:156; List offers capability 02:110-115
- DOM-10 01-domain-model.md:515 (table: list offers -> list_offers :531); DOM-15 :562; DOM-16 :566; DOM-17 :652; kind table :575-594
- SEC-15 07-security-requirements.md:84
- API-7 04-api-contract.md:159 (steps 1-5c :185-245; tail table; rich tail :258-290); API-15 04:986; API-63 04:1358
- grep "capabilit" 04-api-contract.md -> only :8 (GET /v1/providers row) and :787 ("leaked capability"): API-7 places no capability gate.
- WIR-1a 13-wire-contract.md:22 (no member-order text found); WIR-2 13:28; WIR-9a 13:123 (unsupported row :138; conflict union :137; retryable table ~:170-180); WIR-9b 13:220; WIR-29 fixture 13:1010-1013; WIR-48 13:1295 (terminated sentence :1310-1312)
- CNF-34 10-conformance-checklist.md:228; CNF-55 :310; CNF-248 :3018; CNF-342 :3938
- Lean: Admission.lean:1053 `inductive TailRefusal` closed (accountRecoverable|accountTerminated|fence|offerNotSellable|channelClosed|solvency|rate|cap|balance); rank :1224; retryable :1234 @[req "WIR-9a"]. None of OPS-43/OPS-23/PRV-47/PRV-10/DOM-10/DOM-16/WIR-48/WIR-2 is @[req]-tagged.
- No text states a `retryable` for `unsupported` (grep "unsupported" across *.md).
- No existing details key `field`/`fields`/`path`/`pointer` (grep).
- 00-overview.md config table: "| `allow_orders`, per ordering account | `DOM-16` | boolean | yes |" (column: Startup-validated).
- Claude quota at launch: session 10%, week all-models 20%, Fable 14%.
