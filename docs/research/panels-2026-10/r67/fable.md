Verification is complete. Draft answer follows.

## Q1 (pv-tcs)

**F: CANNOT ACCEPT. S: AMEND. Pick: S, amended.**

F's losses, none listed by the form:

- `OPS-1` (03:17-18): "Every mutating request MUST create or return a durable operation record before any provider call is made". Trace: create passes 5d, F's List offers read goes out, the tail then writes the record or refuses. The call precedes the record, and a refused create makes a provider call that no record ever names.
- `PRV-40` (02:1211-1213): "refuse subsequent creates on that account and channel before any provider call". Trace: closure retained, create arrives, F reads, the tail refuses `rate_limited`. The read cannot move behind the closure check either, because 03:822-826 says a closed and unsellable create is "`offer_not_sellable` at admission". 03:277 carries PRV-40's quote and would drift too.
- `CNF-340` (10:4027-4028): "assert the `offer_not_sellable` tail response from `CNF-307`, before any provider call or write". Flipped, unlisted.

Also `OVR-9`: "`api` MUST NOT depend on `providers`", so F's "the `api` MUST first obtain one current driver List offers result" needs the engine trait, as WIR-30's route already does. F's kind list "`provider` or `timeout`" omits `network`, `authentication` and `rate_limited` from the taxonomy table.

S's strongest reason: the set has written admission purity into a dozen places, and S keeps every one of them true while matching `DOM-8`'s "Machine state is a *cache* of provider truth". S's gaps: the refresh pass is a new background component and `OVR-17` says "MUST be extended when a component is added"; its row write is then an engine write under `OPS-50`; the staleness refusal must be a numbered step, since API-7 says "Steps 1–5d still stop at their first refusal"; `OVR-19`'s "Mandated by" column needs an id for the 05 rule.

Replacement text for S:

```
04 API-7, new step after 5d:
5e. **refuse a create whose provider account has no stored offer listing** (`STO-60`)
    **or whose listing's `read_at` is older than the stated offer-listing age** (`OVR-19`):
    `provider` with `retryable: true` and `details.provider_account`. A refusal stops here
    and is not collected by the tail.

04 API-7, insert after "without an extra lock, ceiling slot, write or provider call." (04:264):
On create, the offers the check reads are the provider account's stored offer listing
(`STO-60`) as it stands in that snapshot, and the tail prices the commitment and takes the
offer snapshot from it.

05-persistence.md, new table and rule:
**STO-60** `offer_listings`: `provider_account` (primary key), `read_at` (timestamp),
`offers` (json: the driver's List offers result, prices as strings, `DOM-9`). Every
successful driver List offers read MUST replace the account's row when its `read_at` is
later. A refresh pass in `engine` (`OVR-17`) MUST read every account declaring
`list_offers` at least once per stated offer-listing refresh interval (`OVR-19`). `OPS-50`
says "every write transaction made in the engine process … MUST read `STO-59`'s row
`FOR SHARE` as its first statement".

00 OVR-17 table, new row:
| The offer-listing refresh pass (`STO-60`) | `engine` | Reads offers at a provider, so it needs a provider credential; see `OPS-50` |

00 OVR-19 register, two rows:
| Offer-listing age | `API-7` | finite, positive duration | yes |
| Offer-listing refresh interval | `STO-60` | finite, positive duration, shorter than the offer-listing age | yes |
```

**Q1.2.** The rule protected OPS-1's record-before-call invariant, PRV-40's closure, and the account's read budget: 08:471-474 observed `GET /server`, `GET /server/{n}` and cancellation "shared the 200/hour account counter", and the product listing is unmeasured. Under F each create attempt spends a read, bounded per principal by `SEC-39` at step 5c and in aggregate by nothing, so tenant traffic can starve OPS-32 and resolution reads if the listing path shares that counter. Under S the only tenant-driven read stays WIR-30's route. S's refresh-pass write needs OPS-50 through the OVR-17 row above; the route's write does not, since OPS-50 says "Writes made in the api process are not checked".

**Q1.3.** No. OPS-43 re-tests "one current driver List offers result taken at claim", and admission's reserve is released in full under LDG-39's deterministic-rejection row. Even F's two reads differ in time.

**Q1.4.** Neither. Both take "the offer snapshot from it", and S's `offers` is the same List offers result WIR-30 and OPS-43 read. Descriptor-declared values come from PRV-44's pure descriptor under either.

**Against my pick:** S adds a table, a background component, two parameters and a new refusal, and admits at a price up to one age old, so claim refuses `price_moved` more often on the auction market. F has no cache to keep coherent.

## Q2 (pv-ytv)

**K: AMEND. N: CANNOT ACCEPT. Pick: K.**

K's reason: 05:441, 05:326, `PRV-9` and `CNF-303` stay true as written, and the operation and machine rows keep agreeing on "what the create wrote into the provider". N splits them and adds a copy path from `request_summary` that exists nowhere else.

N's loss: `PRV-26` (02:895-897) says "Whichever it is, the kind and the value MUST be recorded on the operation row … before the order is sent". N's own PRV-32 insert makes every standard-channel order carry a per-order key, so the artifact exists, and N writes null: the same requirement then carries both answers. N also never says when the `request_summary` fingerprint is written, so a lost reply can leave it nowhere.

K's amendment: CNF-278's barrier cases include kills before step 8 commits, where the pair is unwritten on every channel.

```
10 CNF-278, replace "making no assertion about the correlator pair on the latter" with:
asserting the pair null on both before step 8 commits, and `correlator_kind`
`ssh_key_fingerprint` with the per-order key's fingerprint on both after it

If N is preferred, PRV-26 (02:897), after "before the order is sent," insert:
except on a channel declared `correlator: none` (`PRV-33`), where both are null and the
per-order key's fingerprint is written to `request_summary` in that same transaction,
```

**Q2.2.** After retention removes the row, PRV-9 says "the sweep MUST still check the provisioning condition against retained `machines` rows", through `machines.correlator_value` per CNF-303. Under K the machine pair is the fingerprint from the operation pair; under N it is the copy from `request_summary`. Both retain every key tagged with the operation id, caller key included, while the machine reads `provisioning`. A caller-only order is excluded by both forms' per-order key; were it reached, both would hold the caller key's fingerprint, which PRV-26 forbids as "anything else linkable to a person".

**Q2.3.** K: one match, but OPS-38 as amended gives it "no count", so OPS-27's "Exactly one" row cannot apply and the fourth row escalates. N: nothing recorded, OPS-38's existing sentence escalates. Neither auto-attaches. Under N the only consumer newly reading null is OPS-27's search; 05:360's index is on `machines`, and OPS-32 reads the machine pair.

**Q2.4.** K: none, once OPS-38 disambiguates OPS-27's two matching rows. N: yes, PRV-26's MUST above against N's "both are null".

**Against my pick:** K keeps a correlator-shaped value on a channel PRV-33 calls unverified, and only OPS-38's prose stops a literal engine from counting it. N makes "never to a guess" structural.

## Brief errors

- "05:360's index" is not a consumer of the operation pair. It sits in `### machines` (05:307-390), before `### machine_attachments` at 05:391.
- "`provider` or `timeout` (`DOM-17`)": DOM-17 lists no kinds. The closed set is 01's "Error taxonomy" table (01:580-592), which also holds `network`, `authentication` and `rate_limited`.
- F's "Unchanged" list omits `OPS-1`, `PRV-40` with 03:277's quote, and `CNF-340`, all flipped by the admission read.
- S omits the `OVR-17` row its refresh pass requires, so its OPS-50 question answers itself.
