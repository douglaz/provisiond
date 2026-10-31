**Internal contradictions found: 6**

Line numbers are in `/var/tmp/provisiond-panel-r87/brief.md`. Under notes.md line 7, any change to a package's diagnostic, fixture or landing text makes it a new form. So repairs 1, 2, 5 and 6 create new forms. Repairs 3 and 4 only fix the brief's own descriptions.

1. **B never says it overrides the startup-refusal sentence it keeps (conditional contradiction).** B keeps line 101, "Startup acquisition refusal exits for supervisor retry", and adds (489–490) "retry admission with backoff within that bound." D's instructions (610) treat it as an open reading that the line-101 sentence "already governs" refusals during migration. On that reading, package B states two outcomes for the same refusal. A agrees with "exits", and C writes `migrate` into the sentence, so neither has this problem.
   - **Repair:** add one clause to B's first sentence: "this, not the startup-refusal sentence above, governs `migrate`."

2. **The shared fixture forbids a start that the A/B rule allows.** Lines 462–463, 536–537 and 592–593 say "In each fixture … no new-release component starts". The A/B STO-13 text (445–446, 513–514) says "MUST NOT start any component of the new release until the required migrations have completed successfully." In fixture (b), "an admitted runner holds `STO-12`'s migration key" and can finish every required migration. At that point the rule allows the start but the fixture still forbids it. The packages also assert later starts themselves: 470–472 and 547–548.
   - **Repair:** append "before the required migrations complete successfully" to "no new-release component starts" in all three packages.

3. **The brief describes C as unchanged in shape, but C's text changes it.** Line 606 says "Its 'exits' uses the existing startup-refusal shape", and 415 and 606 call C a scope amendment. C's text (564–566) says "Startup acquisition refusal, including … `migrate` …, exits non-zero for supervisor or deployment retry". That adds "non-zero" and "or deployment retry" to every startup acquisition refusal, including the engine's and `api`'s, not just `migrate`. Base line 101 says only "exits for supervisor retry".
   - **Repair:** change line 606 to say C's "exits non-zero … or deployment retry" changes the startup-refusal outcome for every startup acquisition refusal, not only `migrate`.

4. **The brief says A adds a release boundary that C lacks, yet C tests one.** Line 478 says "It adds a diagnostic and release-boundary assertion beyond C." C's CNF-57 case asserts that same boundary: "no new-release component starts" (593) and "before the new release's components start" (600–601).
   - **Repair:** change 478 to "adds a diagnostic and an explicit STO-13 release-boundary MUST beyond C; C's CNF-57 case asserts that start order without that sentence."

5. **The phase categories in the diagnostic overlap.** The A/B diagnostic must say "whether this was initial acquisition, acquisition by a runner scheduled alongside another runner, or reconnect" (431–433, 498–500). In fixture (b), the second runner's denied attempt (454–456) is that runner's initial acquisition and also acquisition alongside another runner. B's test asks for a diagnostic "identifying the release, acquisition phase and reason" (544–545), so for (b) either label could pass or fail.
   - **Repair:** add to both diagnostic sentences: "a runner's first acquisition while another runner is scheduled is reported as the latter."

6. **Minor: the fixtures name a capacity the quoted rules don't define.** Lines 459, 533 and 589 say "Exhaust the migration admission capacity". The quoted STO-55 (82) defines only "component capacity C", which the OVR-19 row at 405 lists. Nothing in the brief defines a separate capacity for migration.
   - **Repair:** change it to "Exhaust component admission capacity C (`STO-55`)".

**Consistent:**
- Every line range and anchor (312–317, 317, 1576) matches its quoted block.
- Every quote the brief attributes to STO-55, STO-13, OPS-49, CNF-57 and CNF-372 matches the quoted text.
- The quotations in OPS-49 and CNF-372 still hold under every package.
- notes.md agrees with the brief on the pin, seats, the grok fallback, the 3600 s limit, the gate ban and rule 6.
