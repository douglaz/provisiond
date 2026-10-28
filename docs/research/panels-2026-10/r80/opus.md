**Final: A.** I accept A and cannot accept B. The answer below is also saved at `/var/tmp/provisiond-panel-r80/opus.draft.md`. My clone is still clean at `f25c9a2` and no source file was edited.

## 1. Final: A

## 2. Acceptance

**A: ACCEPT. B: CANNOT ACCEPT.**

- **The rule:** `AGENTS.md:29–30` says "A claim about what another requirement says carries that requirement's own words". Its completion line says "every sentence asserting what another requirement says carries its quote".
- **The current sentence breaks it:** "Global guard for OPS-15's before-any-claim requirement" says that OPS-15 contains a before-any-claim requirement. That is a claim about what OPS-15 says. It is true, but it is not quoted: "before-any-claim" is a hyphenated paraphrase that nothing checks. So the finding's premise is accurate.
- **A is the remedy the finding asked for:** "Quote the relevant OPS-15 clause (“at startup, before any claim”) … keeping the explanation of the model's disabled guard separate".
- **A's quote is verbatim.** It comes from OPS-15's opening sentence (`03-operation-lifecycle.md:372`): "Subject to the exceptions below, at startup, before any claim, the engine MUST move every `running` operation…". I checked across line wraps: it occurs exactly once in the root documents plus the ADRs.
- **Truncation:** A leaves out "Subject to the exceptions below". That is not a misattribution. The exceptions (refresh, the null-column create, `suspend_tenant`) decide where particular rows go. They don't decide whether the pass comes before claims, and that ordering is the only thing `requirePass` gates (`(!requirePass || w.passDone)`).
- **B:** its only defence is the verbatim adoption: "adopt exactly the printed M-I package" and "No unread repair or union is approved". The owner's later direction, "For such wording questions, try to solve by getting a consensus of the panel", makes a wording fix the panel has read admissible. B would resolve a finding whose premise holds without addressing it, when the fix is one line.

## 3. Does A change anything beyond wording?

- **Behavior: unchanged.** The hunk touches only the `/-- … -/` text on line 13. The bodies of `permitsI`, `stepI`, `runI` and every theorem are byte-identical. Nothing in `tools/formal` reads docstrings (`findDocString`/`docString`).
- **Requirement: unchanged.**
  - The diff contains no `.md` file.
  - OPS-15 (`03:371–483`) and the `@[req "OPS-15"]` tag are untouched.
  - There is no `<!-- formal: Provisiond.RestoreIndependent… -->` region, and `check_regions.py` compares only the tables declarations emit.
  - Both sentences name the same ordering duty; no obligation is added or removed.
- **Check strength: unchanged, with one new passing comparison.** No gate rule, theorem, guard hypothesis, witness or negative control changes. I ran the citation gate's own functions (`exists()`, `find()`, `unpaired_marks()`) in memory on the pinned file, without patching it:

  | | EXISTS counted | EXISTS missing | QUOTED compared | Unpaired marks |
  |---|---|---|---|---|
  | Current text | 0 | none | 0 | none |
  | A | 1 | none | 0 | none |

  - The new quote's chunk is neither HISTORICAL nor TEACHING.
  - QUOTED doesn't reach the quote: `ATTRIB`, `POSSESSIVE` and `COLON` all require a backticked id, and the gate says "Colon coverage excludes Lean docstrings".
  - So EXISTS gains one comparison, it passes, and the printed count rises by one. No checked verdict changes: green before and after.
  - Nothing in `ci.yml`, `tools/*.py` or the baseline matches "Global guard", "before-any-claim" or `permitsI`.
  - M-I's `ci.yml` control rewrites only `def badRequirePass : Bool := false` and `def badPassEveryStartup : Bool := false`. The citation controls assert relative counts (`compared + 1`), not fixed ones.
  - I didn't run the full `check-all.sh`; the brief says I need not.

## 4. **Requested counterargument, not my vote**

The owner adopted M-I "exactly", and the repository's citation gate says "Summary verbs are deliberately OUT OF SCOPE". Read that way, "OPS-15's before-any-claim requirement" is a correct paraphrase, and the gate itself notes "most attributions in the set are of that shape". Changing owner-adopted text costs a push and a bot round for no change in meaning.

A minor style point: A writes `OPS-15` without backticks, while sibling Lean docstrings write `` `OPS-15`: "…" ``. Neither form brings the quote under QUOTED.

**Rebuttal:** the gate's scope limits what it enforces; it doesn't grant permission. `AGENTS.md` names unquoted summaries as the risky shape.

**For consensus:** I wouldn't insist on backticks. I'm not offering a backticked possessive either, because it isn't a printed option and the brief says "Do not silently combine or enlarge the options." I would move to B only if the owner explicitly prefers keeping the text verbatim over `AGENTS.md`'s completion line. Under the vote rule, a tie goes to the owner anyway.
