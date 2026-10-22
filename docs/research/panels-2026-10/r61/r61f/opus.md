Checks are done, and here is my answer.

**1.**
- **fable-c: CANNOT ACCEPT.** "diagnostic record, not identity (`RSC-26`)" says what `RSC-26` says without quoting it. `AGENTS.md` requires that "every sentence asserting what another requirement says carries its quote". Also, `RSC-27` says "The target MUST be validated as a simple path under the device directory", which is a check on the install target. "under `RSC-27`'s device directory" turns it into a claim about every reported path.
- **opus-c: ACCEPT.** The `RSC-26` quote is verbatim and the citation gate checks it. But `RSC-33` lists two items for one wire field, and only a mapping sentence keeps that true.
- **sol-MAY: CANNOT ACCEPT.** "Each device MAY additionally carry `name`" would be the set's first response field left to the implementation's choice. `WIR-2` already says "the server can add fields without a version bump", so clients can't rely on the field and `CNF-363` has nothing to assert.

**2. Pick (b).** All four readers accept it. Both readers who preferred (a) admit in their weakest-point answers that they haven't shown `name` adds anything beyond `path`. It's also the smallest change.
