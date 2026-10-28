# Q1 P4C — coordinator assembly, UNREVIEWED

This complete candidate is based on r74 sol's P4, with r75's returned CNF-362 repairs and complete editorial rendering of its timing, alarm and conformance obligations. It also states the already-admitted transaction boundary requested by opus. All additions/fixture restrictions are **behaviour changed relative to 4662d85**; no claim of wording-only acceptance is made. P3's unaccounted-session latch is not imported. No reader has reviewed this whole assembly. Its trust/infrastructure/outage costs are unapproved.

## STO-7 additions

Insert immediately after the paragraph ending “every write waits.”:

> The deployment MUST identify a sole change authority controlling database configuration, reloads, role/database defaults, deployed SQL, endpoint routing and server credentials. Ordinary administrative paths MUST be restricted to that authority. Session-setting invariants rely on trusted component SQL; parameter ACLs do not restrict user-settable GUCs. Changes not established safe MUST be refused while components serve. Before maintenance can invalidate that proof, the authority MUST close component admission, stop every component and fence pending connection attempts. Process exit is not backend drainage: outstanding component backends MUST clear naturally, or the primary MUST be shut down before such maintenance. No component may resume until safe posture is verified.
>
> An independent authenticated observer MUST start a complete round every C and finish or declare failure within Q, using a fresh direct administrative session outside component pools. It MUST check effective replication configuration, primary node/boot identity and role, and the topology evidence defined by STO-55. Each component MUST explicitly set and verify synchronous_commit=on on every connection, verify applicable transaction settings before use, and prohibit subsequent lowering/resetting. Idle sessions MUST be rechecked each round. Busy-session evidence persists only while original session identity and enforced unchanged settings are established; otherwise it is unobservable. An observer's SHOW/pg_settings reads do not prove another session's GUCs. A known residual backend alone is not evidence of unsafe replication configuration or topology; this observer does not establish a residual-capacity bound.
>
> Unsafe or unobservable posture evidence MUST latch refusal and alarm. Each component MUST gate requests, new transactions, claims, passes, provider-mutation dispatch and deposit exposure on current authority evidence. Evidence MUST expire within V measured monotonically from its request's start, never its delayed receipt; absence of notification cannot extend it. On refusal api rejects pre-transaction requests as overloaded and exits within A; the engine stops under OPS-21. A stop-record attempt is subject to the same gate. Already-sent COMMIT retains its checkout until reply, dead transport or process exit; unfinished api requests receive no success after refusal. Resumption requires operator reset, verified configuration/topology, discarded old connections and passing new-connection checks; changed history also requires STO-54's classification/procedure. Reset does not erase recorded posture violations.
>
> This permission gates new use, not completion of transactions already admitted. A transaction admitted before permission expires can still send COMMIT after expiry; an already-sent transaction retains its server-decided fate. No new external dispatch, deposit exposure or api success is permitted after refusal. Nothing here asserts prevention of a bypass commit between observation and refusal, or revocation of an action already dispatched. Local monotonic enforcement and watchdog execution MUST function for the refusal/exit bounds to hold.
>
> Declare startup-validated finite positive C, Q, V and A, with C+Q<V, preserving the existing store timeout ordering. Persistent observable drift is observed or declared unobservable within C+Q and new use is refused deployment-wide within C+Q+V. Those bounds do not claim a durable report by that time, completion of an admitted transaction, or detection of a privileged transient change reversed between observations. Administrative bypass remains outside prevention; the authority's durable change journal records changes it mediates.

STO-7's existing “MUST NOT release its connection before the reply arrives or the transport is found dead”, deposit check, warning treatment and “other than by shutting the primary down” exception retain their text. No new lost-reply category, backend-cancellation permission or early record exit is proposed.

## STO-55 topology addition

Insert after its transaction-mode pooler paragraph:

> The change authority MUST establish topology from controlled routing, endpoint and credential ownership, independently of the component SQL path. End-to-end authenticated database connections with keys confined to database endpoints are one admissible construction. SQL identity samples alone are insufficient. Observation connections and their possible residuals MUST be included in the deployment's connection budget; no service or observation-capacity guarantee follows merely from a separate pool.

This does not import Q3's external reservation mechanism.

## OPS-49 addition

Append to the store-error handling contract:

> An attempt denied by STO-7's posture gate is a store error for this loop and sends no SQL. A refused record attempt consumes the existing Stop-record and Store-retry bounds; it creates no immediate new exit.

## OVR-18 / OVR-19

Append to OVR-18's alarm roster, without rewriting its other entries:

> The posture refusal latch is alarmed; see STO-7.

Add these OVR-19 rows (ownership stays in STO-7/STO-55):

| Parameter | Mandated by | Type | Startup-validated |
|---|---|---|---|
| Posture observation cadence C | STO-7 | finite positive duration | yes |
| Posture round deadline Q | STO-7 | finite positive duration | yes |
| Posture evidence lifetime V | STO-7 | finite positive duration, C+Q<V | yes |
| api refusal drain bound A | STO-7 | finite positive duration | yes |
| Posture change authority, observation, reset and topology procedure | STO-7, STO-55 | human procedure and trust/inventory ownership | no |

## CNF-296 addition

Append these paragraphs within the item, before its owner references/history:

> Retain independently admitted live read sessions and functioning posture observation throughout the existing unchanged-configuration stall traces. A healthy busy COMMIT retains its setting evidence under the enforced unchanged-session conditions; legitimate standby unavailability alone does not trip the posture latch. After a contending engine exits, retain its known backend identity while it remains; residual existence alone is not posture drift. Assert the later one-standby success trace remains reachable.
>
> With authority enforcement enabled, attempt an unsafe replication change while components serve: assert refusal before the change takes effect. Exercise controlled maintenance through closed admission, stopped components and either verified backend drainage or primary shutdown; resume only after verification and operator reset.
>
> Separately disable the change boundary to inject a persistent empty standby list immediately after a retained-session check. Permit a pre-detection local commit and do not describe it as prevented. Assert observation/failure by C+Q, refusal of new use everywhere by C+Q+V, no new api success after refusal, api exit within A of refusal and engine stopping under its existing bounds. Repeat idle, with disconnected components, lost latch notification and delayed evidence replies; old challenges never extend expiry. Restore safe configuration without resetting: assert the latch remains. Reset only by the stated procedure.
>
> Keep one transaction admitted before expiry open across expiry. Assert its server-decided completion remains possible while no subsequent new transaction, provider dispatch, deposit exposure or api success passes refusal. Exercise an already-sent waiting COMMIT through stop expiry: retain its checkout while its process lives and transport remains live; never cancel or terminate the backend to force an outcome. Do not assert completion within the posture detection bound.

## CNF-365 addition

Append within the item before its owner references/history:

> Start with unsafe posture before first use and assert refused admission. On an already fronted client-to-pooler connection, introduce transaction-mode pooling and force backend reassignment, then repeat with unchanged PID observations; controlled independent topology evidence must refuse that path. SQL identity samples alone never certify absence of pooling. Test loss of endpoint authentication/inventory evidence and query failure: evidence expires and refusal applies. A direct already-established authenticated TCP session is a different case from a retained pooler client session. Do not infer historical safety or absence of a transient privileged bypass from current safe configuration alone.

## CNF-362 success restrictions and refusal control

Replace “with a working store.” with:

> with a working store and verified STO-7 posture throughout recording.

Replace the sentence “in each case the engine survives the stop and the store works before the Stop-record bound ends, unless the case says otherwise.” (line wrapping ignored) with:

> in each case the engine survives the stop and the store works with STO-7 posture admission available before the Stop-record bound ends, unless the case says otherwise.

Append within the item before owner references/history:

> With PostgreSQL working but posture admission denying every record attempt from its beginning, assert no SQL is sent, existing exhaustion bounds end recording, the row remains running, and restart recovery applies. Verify that a later stop, superseded generation or a bound ends recording only under its existing rule; posture refusal is not an additional immediate exit.

## Review boundary

The statement permits a pre-detection bypass acknowledgement and completion of an already admitted transaction; it does not claim total prevention. Restricted administration, independent control/observation, setting verification, capacity, maintenance and observer-failure outages remain owner costs. There is no adoption of Q2/Q3/Q4, no new historical certificate, and no proposal to weaken a formal theorem. Challenge every omitted consumer/fixture and every feasibility assumption; a necessary behavioural repair is AMEND of this printed candidate.
