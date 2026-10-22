Facts checked against `4c0bb4c`: `RSC-33` text, `RSC-26` "The identifier is authoritative; the path is derived.", `RSC-27` "a simple path under the device directory", `RSC-46`'s `{wwn, serial, size_bytes}`, `WIR-2`'s "clients MUST ignore unknown response fields", today's `WIR-10b` device (no `name`), `CONTEXT.md:434`. All verbatim. Last conformance item is `CNF-362`.

**1. Verdicts**

- **fable-c: ACCEPT.** Consistent, but the added sentence restates what `RSC-26` already owns.
- **opus-c: CANNOT ACCEPT.** "A device's `path` reports both `RSC-33`'s name and its path": `RSC-33` lists `name` as a minimum, `WIR-10b`'s shape carries none, and a bridging sentence reconciles the two documents. That is the second-copy drift shape AGENTS.md cites via `SEC-46`.
- **sol-MAY: CANNOT ACCEPT.** "Each device MAY additionally carry `name`": an implementation-discretion response field with no precedent in the set, and `CNF-363` can assert nothing about it.

**2. Pick: (b).**

All four readers accept it, and every reader's own weakest-point statement concedes `name` adds nothing beyond `path` minus `RSC-27`'s directory. My fable-c sentence is unneeded once `name` is gone.
