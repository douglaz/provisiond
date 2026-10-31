
## Wording correction — 2026-10-31 (Panel O r94)

The text above is retained as the historical form approved in owner item 19.
The executable pv-kv2 Agent Brief uses the following replacements under the
owner's 2026-10-28 wording rule; all other Q4-D text is retained.

Replacement for the serialization-retry sentence:

```text
For serialization failures and transaction repetition, see OPS-49.
A serialization failure is not a tenant-status refusal.
```

Replacement for the provider-call passage:

```text
Treat a create past the guard that is between the acknowledged transaction and its provider
call as the potentially dispatched case. For provider-call ordering, see LDG-69.
```

Source pin: `a7b6884878bc7e53dc403dd8a4383d85afac3634`.
Review head: `b85af778fda2a96fb0024a07c69092665303bfbe`.
Panel record: `../../r94/notes.md`.
