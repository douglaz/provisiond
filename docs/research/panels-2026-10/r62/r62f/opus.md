**ACCEPT.** The deletion loses no normative content.

- **The ordering MUST** is still at `04:768`: "The admission token MUST be checked before any other validation of the body".
- **The precedence and the response** are still at `04:772`: "the token check wins: the response is `invalid_request` with no `details.field` and no token detail". `WIR-12` (`13:429-430`) also says it outright: "that check precedes `WIR-2`'s unknown-field rule, so a body with both a bad token and an unknown field is refused naming no field at all".
- **"The message MUST NOT say which"** is still at `13:428-429`, and `WIR-2`'s naming rule at `13:28-30`. Neither is touched.
- **What goes:** the claim of a "conflict between two MUSTs", and two restatements of rules whose own text is unchanged. None of it is a MUST or a behaviour.
- **The one dependent:** `13:430` points at "`API-40`'s stated precedence". That still resolves to "the token check wins" at `04:772`.
- **Search:** grep for "two MUSTs|stated as a precedence|whichever way a handler" (Markdown, Lean, JSONL) finds nothing else.
- **Gates:** I ran only the citations gate. It exited 0.

**Brief errors:** none of substance. "A body" also became "a body", which the brief's list of changes leaves out. It changes nothing.
