# r93 independent assertion-preservation audit

O = PR #53 head fde983c, archived r86/r86b/Q1-A.md; Q = exact Q-QUOTE.md; B = prospective corrected Agent Brief. All line locations below are calculated from bytes. Every original assertion is also preserved in the historical archive prefix under L-NOTE.

## 1. Insertion site; mapping rows and error sentence retention

O:3 → Q:3 → B:28. Unchanged bytes.

Original span, without reflow:

```text
This form adds the following paragraphs after the existing mapping table in `DOM-10` (before its amendment note); existing mapping rows and error sentence stay as quoted:
```

## 2. Admission scope and caller/operator MUST check before enqueue

O:6–8 → Q:6–8 → B:31–33. Unchanged bytes.

Original span, without reflow:

```text
For power on, power off, reboot, hard reset, every install strategy, rescue inventory,
reverse DNS, delete/cancel and API-cleanable attachment release, a caller or operator
request MUST pass the capability check before admission enqueues the operation.
```

## 3. Admission ordering after API pipeline and local validation

O:8–10 → Q:8–10 → B:33–35. Unchanged bytes.

Original span, without reflow:

```text
This check
runs after API-7's steps 1–5c and all endpoint-local admission validation and admissibility
checks, immediately before the enqueue transaction's first write.
```

## 4. API descriptor and no provider request

O:10–11 → Q:10–11 → B:35–36. Unchanged bytes.

Original span, without reflow:

```text
It uses the descriptor
running in api and makes no provider request.
```

## 5. Refusal: no enqueue, endpoint-state write or money write

O:11–12 → Q:11–12 → B:36–37. Unchanged bytes.

Original span, without reflow:

```text
A failed check enqueues no operation and
makes no endpoint-state or money write.
```

## 6. Replay bypass

O:12–13 → Q:12–13 → B:37–38. Exact reviewed replacement; the original instruction remains explicit.

Original span, without reflow:

```text
A replay returned by API-7 step 5a never reaches
this check.
```

Executable replacement, without reflow:

```text
API-7 step 5a says "an equal fingerprint under the
    same `(principal, key)` returns the stored result, a different one fails `conflict`."; a replay returned there never reaches this check.
```

## 7. Operator retry capability and pre-transaction placement

O:13–14 → Q:13–14 → B:38–39. Unchanged bytes.

Original span, without reflow:

```text
An API-64 operator retry checks delete_machine before its state-change/enqueue
transaction;
```

## 8. Manual-release no driver operation and no capability check

O:14 → Q:14–15 → B:39–40. Exact reviewed replacement; the original instruction remains explicit.

Original span, without reflow:

```text
API-65's manual release has no driver operation and takes no capability check.
```

Executable replacement, without reflow:

```text
API-65 says "On a row whose `cleanup` is `manual` there is no driver call to make: it
writes `released_at` and answers `200` with the row, minting no operation,"; a manual attachment release takes no capability check under this timing rule.
```

## 9. Suspend parent unchecked at admission; children checked at claim

O:15–16 → Q:16–17 → B:41–42. Unchanged bytes.

Original span, without reflow:

```text
A suspend parent takes no per-machine capability check at admission: its cancellation
children are gated at claim as below.
```

## 10. Worker MUST recheck; descriptor; HTTP-independent work, retries and delete releases

O:18–20 → Q:19–21 → B:44–46. Unchanged bytes.

Original span, without reflow:

```text
Every operation in the preceding paragraph MUST also pass the capability check in the
worker using the descriptor running there, including operations enqueued without an HTTP
request, API-64 retry attempts and attachment releases enqueued by a successful delete.
```

## 11. Worker after claim/serialization, before first call and either marker

O:21–22 → Q:22–23 → B:47–48. Unchanged bytes.

Original span, without reflow:

```text
The check runs after claim and per-machine serialization, before the operation's first
driver call and before either OPS-45 marker is written.
```

## 12. Repeated validation order; capability last

O:22–25 → Q:23–26 → B:48–51. Unchanged bytes.

Original span, without reflow:

```text
Repeated validation checks caller-
supplied fields first, api-written admission fields second, then the other applicable
local validation, including machine install eligibility and OPS-40's signed-URL check;
the capability check follows.
```

## 13. First failure stops later checks

O:25 → Q:26 → B:51. Unchanged bytes.

Original span, without reflow:

```text
The first failing check stops subsequent checks.
```

## 14. Classifier and existing unsupported result

O:25–26 → Q:26–27 → B:51–52. Unchanged bytes.

Original span, without reflow:

```text
A capability
refusal is classified by OPS-11 and carries DOM-10's existing unsupported result.
```

## 15. No purchase checks introduced for non-purchases

O:26–27 → Q:27–28 → B:52–53. Unchanged bytes.

Original span, without reflow:

```text
This
paragraph introduces no commitment, rate or solvency check for a non-purchase.
```

## 16. Cancellation restore gate and ordered fence decision first

O:29–30 → Q:30–31 → B:55–56. Unchanged bytes.

Original span, without reflow:

```text
For an exposure-reducing cancellation, OPS-41's restore claim gate and ordered fence-
transaction decision run before this capability check.
```

## 17. Cancellation no-call success or defer bypass

O:30–31 → Q:31–32 → B:56–57. Unchanged bytes.

Original span, without reflow:

```text
A no-call success or defer returned
by that decision takes no capability check.
```

## 18. Proceeding cancellation MUST check after acknowledged fence, before call/marker

O:31–33 → Q:32–34 → B:57–59. Unchanged bytes.

Original span, without reflow:

```text
A decision that proceeds to cancellation MUST
pass the capability check after the fence transaction is acknowledged and before any
driver call or write-started marker.
```

## 19. Existing failure disposition; no additional automatic attempt or fence clearing

O:33–34 → Q:34–35 → B:59–60. Unchanged bytes.

Original span, without reflow:

```text
Capability failure follows the existing failed-attempt
and episode disposition; it does not authorize another automatic attempt or clear a fence.
```

## 20. Internal enqueue has no enqueue-time capability check

O:35 → Q:36 → B:61. Unchanged bytes.

Original span, without reflow:

```text
An internally enqueued operation takes no capability check at enqueue.
```

## 21. Operator retry ceiling and system exemption scopes retained

O:35–36 → Q:36–37 → B:61–62. Unchanged bytes.

Original span, without reflow:

```text
API-7's operator
retry ceiling and OPS-39's system-ceiling exemption retain their existing scope.
```

## 22. Mapping determines capability

O:38 → Q:39 → B:64. Unchanged bytes.

Original span, without reflow:

```text
The capability is the operation's entry in the mapping table.
```

## 23. Rescue install capability order; inventory capability

O:38–40 → Q:39–41 → B:64–66. Unchanged bytes.

Original span, without reflow:

```text
A rescue-based install checks
its strategy capability first and rescue_ssh second, before beginning rescue; an inventory
checks rescue_ssh.
```

## 24. Identical-PTR success remains after capability

O:40 → Q:41 → B:66. Unchanged bytes.

Original span, without reflow:

```text
PRV-25's identical-PTR success remains after its capability check.
```

## 25. No capability inferred from install eligibility

O:40–41 → Q:41–42 → B:66–67. Unchanged bytes.

Original span, without reflow:

```text
No
capability is inferred from an install-eligibility list,
```

## 26. Refresh, manual release and capability-less-method exclusions

O:41–42 → Q:42–43 → B:67–68. Unchanged bytes.

Original span, without reflow:

```text
this timing rule adds no gate
to refresh, a manual attachment release, or the capability-less methods named by PRV-4.
```

## 27. API-7 pointer placement

O:45 → Q:46 → B:71. Unchanged bytes.

Original span, without reflow:

```text
In `API-7`, insert after step 5d and before "The tail then depends on what the endpoint does:":
```

## 28. API-7 pointer content

O:48 → Q:49 → B:74. Unchanged bytes.

Original span, without reflow:

```text
For the non-create tails, capability-check placement and precedence belong to DOM-10.
```

## 29. OPS-23 pointer placement

O:51 → Q:52 → B:77. Unchanged bytes.

Original span, without reflow:

```text
In `OPS-23`, append before its amendment notes:
```

## 30. OPS-23 pointer content, including validation and OPS-40/OPS-41 ordering

O:54–55 → Q:55–56 → B:80–81. Unchanged bytes.

Original span, without reflow:

```text
For non-create capability-check placement and its order relative to this validation,
OPS-40 and OPS-41, see DOM-10.
```

## 31. No create-gate movement

O:58 → Q:59 → B:84. Unchanged bytes.

Original span, without reflow:

```text
No create gate moves under Q1-A.
```

## 32. Pre-rescue classifier and marker meanings retained

O:58 → Q:59 → B:84. Unchanged bytes.

Original span, without reflow:

```text
For a refusal before any rescue dispatch, the existing classifier and markers retain their quoted meanings.
```

## 33. Observable-phase assessment retained

O:58 → Q:59 → B:84. Unchanged bytes.

Original span, without reflow:

```text
The added early admission check does change an unsupported request's observable phase; assess that explicitly.
```

The observable-phase assessment does not establish that unsupported admission was formerly allowed. The historical owner-questions §1 already records that premise correction; no such permission is introduced here. This qualification explains the unchanged history and is not a replacement or additional adopted rule.

The API-65 quotation supplies the no-call/no-operation fact. The manual no-check instruction belongs to item 16’s own timing rule: O:14 and O:41–42. It remains explicit in Q:15 and Q:42–43. The qualification identifies the existing owner and scope, without permitting a new manual-release gate.
