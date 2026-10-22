**1. Grid.** (a) ACCEPT. (b) ACCEPT. Nothing I grepped blocks either. `RSC-46` already keeps paths out of the fingerprint, and `WIR-2` says "clients MUST ignore unknown response fields". Preference: **(b)**.

**2. My side's weakest point.** "Nothing in the set reads `name`" proves nothing. It's equally true of `model` and `type`, and nobody wants to drop those. `RSC-33`'s reader is a person: "the record that tells an operator afterwards which disk was actually overwritten". Calling it "a second copy" doesn't show any harm either, because the field selects nothing.

**3. Option (c): keep the word in `RSC-33`, add no field.** At `4c0bb4c`, `WIR-10b`'s device already has no `name`.

- `RSC-33` list: "(name, path, size, type, model, serial, WWN)", the same as (a).
- `WIR-10b` device: the same as (b).
- `WIR-10b` gets one sentence after the example: "A device's `path` reports both `RSC-33`'s name and its path, the device as the rescue environment names it, and `size_bytes` reports its size; the path selects nothing (`RSC-26`: "The identifier is authoritative; the path is derived.")."
- `CNF-363` asserts nothing about `name`.

**Why it holds:** the set already calls the path form a name. `RSC-26` says "those are device names with exactly the same instability — a rootfs install that partitions `/dev/sda`". The "size" → `size_bytes` mapping is the same kind of thing, and it's already there.

**Why each side can take it:** sol's list survives word for word, with WWN added, and so does astra's observed name. fable's and my objection was to a second *field*, and (c) has none.

**Cost:** `RSC-33` lists two items that one field covers, and only the `WIR-10b` sentence says so.
